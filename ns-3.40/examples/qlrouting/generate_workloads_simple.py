#!/usr/bin/env python3
"""
Simple workload generator for qlrouting.

Generates exactly three kinds of flows:
  1. Probing flows  — one bidirectional pair per adjacent edge, UDP port 33333.
  2. Protected flows — TCP port 22222, from/to eligible hosts only.
  3. Background flows — constant-rate UDP, one row per directed link (both
                        directions of every edge), with a configurable
                        number_of_flow multiplier.
"""

import argparse
import random
from dataclasses import dataclass
from pathlib import Path


UDP_PROTOCOL = 17
TCP_PROTOCOL = 6
PROBING_PORT = 33333
PROTECTED_PORT = 22222
RESERVED_PORTS = {PROTECTED_PORT, PROBING_PORT}


@dataclass(frozen=True)
class WorkloadRow:
    src_id: int
    dst_id: int
    start_time: float
    end_time: float
    protocol: int
    dst_port: int
    rate: str
    packet_size: int
    data_size: int
    number_of_flow: int
    is_probing: bool = False
    is_protected: bool = False
    is_congestion: bool = False


class PortAllocator:
    def __init__(self, start_port: int = 20000):
        self.next_port = start_port
        self.used_ports: set[int] = set()

    def allocate(self) -> int:
        while self.next_port <= 65535:
            candidate = self.next_port
            self.next_port += 1
            if candidate in RESERVED_PORTS or candidate in self.used_ports:
                continue
            self.used_ports.add(candidate)
            return candidate
        raise ValueError("No valid destination ports available in range 20000-65535")


# ---------------------------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------------------------

def parse_edges(edges_str: str) -> list[tuple[int, int]]:
    if not edges_str.strip():
        raise ValueError("--edges cannot be empty")

    edge_set: set[tuple[int, int]] = set()
    for block in edges_str.split(";"):
        block = block.strip()
        if not block:
            continue

        parts = block.split(",")
        if len(parts) != 2:
            raise ValueError(f"Invalid edge '{block}'. Expected format 'u,v'")

        left, right = parts[0].strip(), parts[1].strip()
        if not left.isdigit() or not right.isdigit():
            raise ValueError(f"Invalid edge '{block}'. Node IDs must be non-negative integers")

        u, v = int(left), int(right)
        if u == v:
            raise ValueError(f"Invalid self-edge '{block}'")

        edge_set.add((min(u, v), max(u, v)))

    edges = sorted(edge_set)
    if not edges:
        raise ValueError("No valid edges were parsed from --edges")

    return edges


def parse_node_ids(node_ids_str: str | None, edges: list[tuple[int, int]]) -> list[int]:
    edge_nodes = sorted({node for edge in edges for node in edge})
    if node_ids_str is None:
        return edge_nodes

    nodes: list[int] = []
    seen: set[int] = set()
    for part in node_ids_str.split(","):
        part = part.strip()
        if not part:
            continue
        if not part.isdigit():
            raise ValueError(f"Invalid node id '{part}' in --node-ids")
        node = int(part)
        if node not in seen:
            seen.add(node)
            nodes.append(node)

    if not nodes:
        raise ValueError("--node-ids produced an empty node list")

    missing_nodes = [n for n in edge_nodes if n not in seen]
    if missing_nodes:
        missing_str = ",".join(str(n) for n in missing_nodes)
        raise ValueError(
            "--node-ids must include all nodes present in --edges. Missing: "
            f"{missing_str}"
        )

    return sorted(nodes)


def parse_host_vector(host_vector_str: str, max_node_id: int) -> list[int]:
    host_vector: list[int] = []
    for part in host_vector_str.split(","):
        part = part.strip()
        if part not in ("0", "1"):
            raise ValueError(f"Invalid host vector entry '{part}'. Expected 0 or 1")
        host_vector.append(int(part))

    if len(host_vector) <= max_node_id:
        raise ValueError(
            "--protected-host-vector does not cover topology nodes. "
            f"Need index up to {max_node_id}, got length {len(host_vector)}"
        )

    return host_vector


def eligible_protected_nodes(node_ids: list[int], host_vector: list[int]) -> list[int]:
    return [node_id for node_id in node_ids if host_vector[node_id] == 1]


def make_adjacency(edges: list[tuple[int, int]]) -> dict[int, list[int]]:
    adjacency: dict[int, list[int]] = {}
    for u, v in edges:
        adjacency.setdefault(u, []).append(v)
        adjacency.setdefault(v, []).append(u)
    for node in adjacency:
        adjacency[node].sort()
    return adjacency


# ---------------------------------------------------------------------------
# DAG helpers
# ---------------------------------------------------------------------------

def parse_dags(dags_str: str) -> dict[int, set[tuple[int, int]]]:
    """Parse DAG string 'target:u-v,u-v,...;target:...' into {target: {(u,v), ...}}.

    Edge format inside each DAG block uses '-' as separator (e.g. '3-5' means
    directed edge 3 -> 5 in the DAG rooted at that target).
    """
    dags: dict[int, set[tuple[int, int]]] = {}
    if not dags_str.strip():
        return dags
    for block in dags_str.split(";"):
        block = block.strip()
        if not block or ":" not in block:
            continue
        target_str, edges_part = block.split(":", 1)
        target = int(target_str.strip())
        edges: set[tuple[int, int]] = set()
        for e in edges_part.split(","):
            e = e.strip()
            if not e:
                continue
            a, b = e.split("-")
            edges.add((int(a), int(b)))
        dags[target] = edges
    return dags


def dag_all_directed_edges(dags: dict[int, set[tuple[int, int]]]) -> list[tuple[int, int]]:
    """Sorted union of all directed edges across all DAGs."""
    all_edges: set[tuple[int, int]] = set()
    for edges in dags.values():
        all_edges |= edges
    return sorted(all_edges)


def dag_undirected_edges(dags: dict[int, set[tuple[int, int]]]) -> list[tuple[int, int]]:
    """Sorted canonical undirected edges derived from all DAG directed edges."""
    undirected: set[tuple[int, int]] = set()
    for edges in dags.values():
        for u, v in edges:
            undirected.add((min(u, v), max(u, v)))
    return sorted(undirected)


def dag_reachable_srcs(dag_edges: set[tuple[int, int]], target: int) -> set[int]:
    """Return all nodes (including target) from which target is reachable via dag_edges."""
    predecessors: dict[int, set[int]] = {}
    for u, v in dag_edges:
        predecessors.setdefault(v, set()).add(u)
    reachable: set[int] = {target}
    frontier: set[int] = {target}
    while frontier:
        next_frontier: set[int] = set()
        for node in frontier:
            for pred in predecessors.get(node, set()):
                if pred not in reachable:
                    reachable.add(pred)
                    next_frontier.add(pred)
        frontier = next_frontier
    return reachable


def format_rate_mbps(rate_mbps: float) -> str:
    return f"{max(rate_mbps, 0.001):.3f}Mbps"


def parse_rate_mbps(rate_str: str) -> float:
    rate_str = rate_str.strip()
    if rate_str.endswith("Mbps"):
        return float(rate_str[:-4])
    if rate_str.endswith("Kbps"):
        return float(rate_str[:-4]) / 1000.0
    if rate_str.endswith("Gbps"):
        return float(rate_str[:-4]) * 1000.0
    raise ValueError(f"Unsupported rate unit in '{rate_str}'")


# ---------------------------------------------------------------------------
# Row builders
# ---------------------------------------------------------------------------

def build_udp_row(
    src_id: int,
    dst_id: int,
    start_time: float,
    end_time: float,
    dst_port: int,
    rate: str,
    packet_size: int,
    data_size: int,
    number_of_flow: int = 1,
    is_probing: bool = False,
) -> WorkloadRow:
    if src_id == dst_id:
        raise ValueError("src_id and dst_id must be different")
    if dst_port < 1 or dst_port > 65535:
        raise ValueError(f"Invalid destination port {dst_port}")
    if is_probing and dst_port != PROBING_PORT:
        raise ValueError(f"Probing flows must use destination port {PROBING_PORT}")
    if (not is_probing) and dst_port in RESERVED_PORTS:
        raise ValueError(f"Destination port {dst_port} is reserved")
    if number_of_flow < 1:
        raise ValueError("number_of_flow must be >= 1")
    if packet_size <= 0:
        raise ValueError("packet_size must be > 0")
    if start_time < 0:
        raise ValueError("start_time must be >= 0")
    if data_size < 0:
        raise ValueError("data_size must be >= 0")

    normalized_end_time = end_time
    if data_size > 0:
        normalized_end_time = 0.0
    elif end_time <= start_time:
        raise ValueError("end_time must be > start_time when data_size is 0")

    if parse_rate_mbps(rate.strip()) <= 0:
        raise ValueError("rate must be > 0")

    return WorkloadRow(
        src_id=src_id,
        dst_id=dst_id,
        start_time=start_time,
        end_time=normalized_end_time,
        protocol=UDP_PROTOCOL,
        dst_port=dst_port,
        rate=rate.strip(),
        packet_size=packet_size,
        data_size=data_size,
        number_of_flow=number_of_flow,
        is_probing=is_probing,
        is_protected=False,
    )


def build_protected_row(
    src_id: int,
    dst_id: int,
    start_time: float,
    end_time: float,
    rate: str,
    packet_size: int,
    number_of_flow: int,
) -> WorkloadRow:
    if src_id == dst_id:
        raise ValueError("Protected flow src_id and dst_id must be different")
    if start_time < 0:
        raise ValueError("Protected flow start_time must be >= 0")
    if end_time <= start_time:
        raise ValueError("Protected flow end_time must be > start_time")
    if packet_size <= 0:
        raise ValueError("Protected flow packet_size must be > 0")
    if number_of_flow < 1:
        raise ValueError("Protected flow number_of_flow must be >= 1")
    rate_mbps = parse_rate_mbps(rate)
    if rate_mbps <= 0:
        raise ValueError("Protected flow rate must be > 0")

    # Data-driven: send exactly rate × window_duration bytes, then stop
    # naturally. end_time is set to 0 per the CSV convention for data-sized flows.
    duration_s = end_time - start_time
    data_size = int(rate_mbps * 1e6 / 8.0 * duration_s)

    return WorkloadRow(
        src_id=src_id,
        dst_id=dst_id,
        start_time=start_time,
        end_time=0.0,
        protocol=TCP_PROTOCOL,
        dst_port=PROTECTED_PORT,
        rate=rate,
        packet_size=packet_size,
        data_size=data_size,
        number_of_flow=number_of_flow,
        is_probing=False,
        is_protected=True,
    )


def row_to_csv(row: WorkloadRow) -> str:
    return (
        f"{row.src_id},{row.dst_id},{row.start_time:.3f},{row.end_time:.3f},"
        f"{row.protocol},{row.dst_port},{row.rate},{row.packet_size},"
        f"{row.data_size},{row.number_of_flow}"
    )


# ---------------------------------------------------------------------------
# Generators
# ---------------------------------------------------------------------------

def generate_probing_flows(
    adjacency: dict[int, list[int]],
    sim_start: float,
    sim_end: float,
    probing_rate: str,
) -> list[WorkloadRow]:
    rows: list[WorkloadRow] = []
    for src_id in sorted(adjacency.keys()):
        for dst_id in adjacency[src_id]:
            rows.append(
                build_udp_row(
                    src_id=src_id,
                    dst_id=dst_id,
                    start_time=sim_start,
                    end_time=sim_end,
                    dst_port=PROBING_PORT,
                    rate=probing_rate,
                    packet_size=64,
                    data_size=0,
                    number_of_flow=1,
                    is_probing=True,
                )
            )
    return rows


def generate_background_flows(
    edges: list[tuple[int, int]],
    sim_start: float,
    sim_end: float,
    rate: str,
    flows_per_link: int,
    packet_sizes: list[int],
    port_allocator: PortAllocator,
    rng: random.Random,
) -> list[WorkloadRow]:
    """One constant-rate UDP flow per directed link (both directions per edge).

    The packet size for each flow is drawn uniformly at random from
    ``packet_sizes``.
    """
    rows: list[WorkloadRow] = []
    for u, v in edges:
        for src_id, dst_id in ((u, v), (v, u)):
            rows.append(
            build_udp_row(
                src_id=src_id,
                dst_id=dst_id,
                start_time=sim_start,
                end_time=sim_end,
                dst_port=port_allocator.allocate(),
                rate=rate,
                packet_size=rng.choice(packet_sizes),
                data_size=0,
                number_of_flow=flows_per_link,
            )
        )
    return rows


def generate_protected_flows(
    node_ids: list[int],
    adjacency: dict[int, list[int]],
    host_vector_str: str,
    protected_flow_count: int,
    protected_rate: str,
    protected_packet_size: int,
    protected_start_time: float,
    protected_end_time: float,
    protected_number_of_flow: int,
    rng: random.Random,
) -> list[WorkloadRow]:
    if protected_flow_count <= 0:
        return []

    max_node_id = max(node_ids) if node_ids else -1
    host_vector = parse_host_vector(host_vector_str, max_node_id)
    eligible_nodes = eligible_protected_nodes(node_ids, host_vector)
    if len(eligible_nodes) < 2:
        raise ValueError(
            "--protected-host-vector must enable at least 2 topology nodes for protected flows"
        )

    n = len(eligible_nodes)

    def _best_shift_srcs() -> list[int]:
        """Return a source list parallel to eligible_nodes using a circular shift.

        A shift by k gives src[i] = eligible_nodes[(i+k) % n], which is a
        derangement (src != dst for every position) as long as 0 < k < n.
        We pick the shift that maximises the number of non-adjacent (src, dst)
        pairs (preferred for multi-hop Q-routing flows), breaking ties randomly.
        """
        shifts = list(range(1, n))
        rng.shuffle(shifts)  # randomise tie-breaking order
        best_shift = shifts[0]
        best_score = -1
        for shift in shifts:
            score = sum(
                1
                for i, dst in enumerate(eligible_nodes)
                if dst not in adjacency.get(eligible_nodes[(i + shift) % n], [])
            )
            if score > best_score:
                best_score = score
                best_shift = shift
        return [eligible_nodes[(i + best_shift) % n] for i in range(n)]

    rows: list[WorkloadRow] = []
    round_srcs: list[int] = []
    for index in range(protected_flow_count):
        if index % n == 0:
            round_srcs = _best_shift_srcs()
        dst_id = eligible_nodes[index % n]
        src_id = round_srcs[index % n]
        rows.append(
            build_protected_row(
                src_id=src_id,
                dst_id=dst_id,
                start_time=protected_start_time,
                end_time=protected_end_time,
                rate=protected_rate,
                packet_size=protected_packet_size,
                number_of_flow=protected_number_of_flow,
            )
        )

    return rows


# ---------------------------------------------------------------------------
# Congestion
# ---------------------------------------------------------------------------

def generate_congestion_flows(
    dag_edges: set[tuple[int, int]],
    target: int,
    congestion_start: float,
    congestion_end: float,
    burst_duration: float,
    burst_gap: float,
    rate: str,
    packet_size: int,
    port_allocator: PortAllocator,
) -> list[WorkloadRow]:
    """Incast congestion: all DAG sources simultaneously burst toward target.

    Every node reachable in the DAG (except the target itself) sends UDP
    traffic to the target in repeating bursts of length ``burst_duration``
    separated by gaps of ``burst_gap``.  All sources fire at the same time,
    creating incast at intermediate switches along the DAG paths.
    """
    sources = dag_reachable_srcs(dag_edges, target) - {target}
    if not sources:
        raise ValueError(f"No source nodes found in DAG for target {target}")

    rows: list[WorkloadRow] = []
    burst_start = congestion_start
    while burst_start < congestion_end:
        burst_end = min(burst_start + burst_duration, congestion_end)
        if burst_end <= burst_start:
            break
        for src_id in sorted(sources):
            rows.append(
                WorkloadRow(
                    src_id=src_id,
                    dst_id=target,
                    start_time=burst_start,
                    end_time=burst_end,
                    protocol=UDP_PROTOCOL,
                    dst_port=port_allocator.allocate(),
                    rate=rate,
                    packet_size=packet_size,
                    data_size=0,
                    number_of_flow=1,
                    is_probing=False,
                    is_protected=False,
                    is_congestion=True,
                )
            )
        burst_start = burst_end + burst_gap
    return rows


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def validate_rows(rows: list[WorkloadRow]) -> None:
    for row in rows:
        if row.is_probing:
            if row.protocol != UDP_PROTOCOL:
                raise ValueError("Probing flows must use UDP protocol")
            if row.dst_port != PROBING_PORT:
                raise ValueError(f"Probing flow must use port {PROBING_PORT}")
            if row.data_size != 0:
                raise ValueError("Probing flow must use data_size = 0")
        elif row.is_protected:
            if row.protocol != TCP_PROTOCOL:
                raise ValueError("Protected flows must use TCP protocol")
            if row.dst_port != PROTECTED_PORT:
                raise ValueError(f"Protected flow must use port {PROTECTED_PORT}")
        elif row.protocol != UDP_PROTOCOL:
            raise ValueError("Non-probing/non-protected flows must use UDP protocol")
        elif row.dst_port in RESERVED_PORTS:
            raise ValueError(f"Reserved port used: {row.dst_port}")
        if row.data_size > 0 and row.end_time != 0.0:
            raise ValueError("Rows with data_size > 0 must have end_time = 0")
        if row.data_size == 0 and row.end_time <= row.start_time:
            raise ValueError("Rows with data_size = 0 must have end_time > start_time")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Simple workload generator for qlrouting. Produces probing flows, "
            "optional protected TCP flows, and constant-rate background UDP flows."
        )
    )
    # Topology
    parser.add_argument("--output", required=True, help="Path to output CSV file")
    parser.add_argument(
        "--edges",
        required=True,
        help="Physical topology edges in format '0,1;0,2;1,2' (undirected)",
    )
    parser.add_argument(
        "--dags",
        required=True,
        help=(
            "Logical DAGs in format 'target:u-v,u-v,...;target:...' "
            "(same format produced by parse_zoo.py)."
        ),
    )
    parser.add_argument(
        "--node-ids",
        default=None,
        help="Optional comma-separated node id override; must include all nodes in --edges",
    )
    # Timing
    parser.add_argument("--sim-start", type=float, default=0.5, help="Workload start time in seconds")
    parser.add_argument(
        "--duration",
        type=float,
        default=10.0,
        help="Workload duration in seconds (default: 10.0)",
    )
    # Probing
    parser.add_argument(
        "--probing-rate",
        type=str,
        default="100Kbps",
        help="Rate for probing flows sent to each neighbor (default: 100Kbps)",
    )
    # Background
    parser.add_argument(
        "--background-rate",
        type=str,
        default="10Mbps",
        help="Rate for background UDP flows on each directed link (default: 10Mbps)",
    )
    parser.add_argument(
        "--background-flows-per-link",
        type=int,
        default=1,
        help="number_of_flow multiplier for background rows (default: 1)",
    )
    parser.add_argument(
        "--background-packet-sizes",
        type=str,
        default="512",
        help=(
            "Comma-separated list of packet sizes in bytes for background flows. "
            "Each flow picks uniformly at random from this list (default: 512)"
        ),
    )
    # Protected
    parser.add_argument(
        "--protected-flow-count",
        type=int,
        default=0,
        help="Number of protected TCP flows to generate (default: 0)",
    )
    parser.add_argument(
        "--protected-host-vector",
        type=str,
        default=None,
        help="Host vector (0/1 comma-separated) used to select protected-flow endpoints",
    )
    parser.add_argument(
        "--protected-rate",
        type=str,
        default="1Mbps",
        help="Rate for protected flows (default: 1Mbps)",
    )
    parser.add_argument(
        "--protected-packet-size",
        type=int,
        default=512,
        help="Packet size for protected flows (default: 512)",
    )
    parser.add_argument(
        "--protected-start-time",
        type=float,
        default=None,
        help="Start time for protected flows (default: sim_start + 10%% of duration)",
    )
    parser.add_argument(
        "--protected-end-time",
        type=float,
        default=None,
        help="End time for protected flows (default: sim_end - 10%% of duration)",
    )
    parser.add_argument(
        "--protected-number-of-flow",
        type=int,
        default=1,
        help="number_of_flow value for protected rows (default: 1)",
    )
    # Misc
    parser.add_argument("--seed", type=int, default=1234, help="Random seed (used for protected-flow pair selection)")
    parser.add_argument("--dry-run", action="store_true", help="Generate and validate without writing file")
    # Congestion
    parser.add_argument(
        "--congestion-target",
        type=str,
        default=None,
        help="Comma-separated DAG target node(s) for incast congestion flows (omit to disable congestion)",
    )
    parser.add_argument(
        "--congestion-rate",
        type=str,
        default="50Mbps",
        help="Rate per congestion source flow (default: 50Mbps)",
    )
    parser.add_argument(
        "--congestion-packet-size",
        type=int,
        default=1400,
        help="Packet size for congestion flows in bytes (default: 1400)",
    )
    parser.add_argument(
        "--congestion-start-time",
        type=float,
        default=None,
        help="Start of the congestion window in seconds (default: sim_start + 20%% of duration)",
    )
    parser.add_argument(
        "--congestion-end-time",
        type=float,
        default=None,
        help="End of the congestion window in seconds (default: sim_end - 20%% of duration)",
    )
    parser.add_argument(
        "--congestion-burst-duration",
        type=float,
        default=1.0,
        help="Duration of each congestion burst in seconds (default: 1.0)",
    )
    parser.add_argument(
        "--congestion-burst-gap",
        type=float,
        default=1.0,
        help="Gap between consecutive congestion bursts in seconds (default: 1.0)",
    )
    parser.add_argument(
        "--congestion-target-shift",
        type=str,
        default="1.0",
        help=(
            "Comma-separated possible time-shift values (seconds) between successive "
            "congestion targets. Each target's start is shifted by a value drawn "
            "uniformly at random from this list (default: 1.0)"
        ),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    # --- Validate scalar args ---
    if args.duration <= 0:
        raise ValueError("--duration must be > 0")
    if args.sim_start < 0:
        raise ValueError("--sim-start must be >= 0")
    if parse_rate_mbps(args.probing_rate) <= 0:
        raise ValueError("--probing-rate must be > 0")
    if parse_rate_mbps(args.background_rate) <= 0:
        raise ValueError("--background-rate must be > 0")
    if args.background_flows_per_link < 1:
        raise ValueError("--background-flows-per-link must be >= 1")
    background_packet_sizes = [
        int(s.strip()) for s in args.background_packet_sizes.split(",") if s.strip()
    ]
    if not background_packet_sizes:
        raise ValueError("--background-packet-sizes must contain at least one value")
    if any(s <= 0 for s in background_packet_sizes):
        raise ValueError("All --background-packet-sizes values must be > 0")
    if args.protected_flow_count < 0:
        raise ValueError("--protected-flow-count must be >= 0")
    if args.protected_number_of_flow < 1:
        raise ValueError("--protected-number-of-flow must be >= 1")
    if args.protected_packet_size <= 0:
        raise ValueError("--protected-packet-size must be > 0")
    if parse_rate_mbps(args.protected_rate) <= 0:
        raise ValueError("--protected-rate must be > 0")
    if args.protected_flow_count > 0 and args.protected_host_vector is None:
        raise ValueError("--protected-host-vector is required when --protected-flow-count > 0")
    congestion_targets: list[int] = []
    if args.congestion_target is not None:
        congestion_targets = [int(s.strip()) for s in args.congestion_target.split(",") if s.strip()]
        if not congestion_targets:
            raise ValueError("--congestion-target must contain at least one node id")
        if args.congestion_burst_duration <= 0:
            raise ValueError("--congestion-burst-duration must be > 0")
        if args.congestion_burst_gap < 0:
            raise ValueError("--congestion-burst-gap must be >= 0")
        if args.congestion_packet_size <= 0:
            raise ValueError("--congestion-packet-size must be > 0")
    congestion_target_shifts: list[float] = [float(s.strip()) for s in args.congestion_target_shift.split(",") if s.strip()]
    if not congestion_target_shifts:
        raise ValueError("--congestion-target-shift must contain at least one value")
    if any(v < 0 for v in congestion_target_shifts):
        raise ValueError("All --congestion-target-shift values must be >= 0")

    sim_end = args.sim_start + args.duration
    margin = min(0.5, args.duration * 0.1)
    protected_start_time = (
        args.protected_start_time if args.protected_start_time is not None
        else args.sim_start + margin
    )
    protected_end_time = (
        args.protected_end_time if args.protected_end_time is not None
        else sim_end - margin
    )
    if protected_start_time < args.sim_start or protected_end_time > sim_end:
        raise ValueError(
            "Protected flow time window must be inside simulation window "
            f"[{args.sim_start:.3f}, {sim_end:.3f}]"
        )
    if protected_end_time <= protected_start_time:
        raise ValueError("--protected-end-time must be > --protected-start-time")

    # --- Parse topology ---
    rng = random.Random(args.seed)
    edges = parse_edges(args.edges)
    dags = parse_dags(args.dags)
    if not dags:
        raise ValueError("--dags produced no DAG entries")
    node_ids = parse_node_ids(args.node_ids, edges)
    adjacency = make_adjacency(edges)
    port_allocator = PortAllocator(start_port=20000)

    # Congestion window defaults: inner 60 % of the simulation
    congestion_margin = args.duration * 0.2
    congestion_start = (
        args.congestion_start_time
        if args.congestion_start_time is not None
        else args.sim_start + congestion_margin
    )
    congestion_end = (
        args.congestion_end_time
        if args.congestion_end_time is not None
        else sim_end - congestion_margin
    )
    if congestion_targets:
        missing = [t for t in congestion_targets if t not in dags]
        if missing:
            raise ValueError(
                f"--congestion-target node(s) {missing} not found in DAGs. "
                f"Available targets: {sorted(dags.keys())}"
            )
        if congestion_start < args.sim_start or congestion_end > sim_end:
            raise ValueError(
                "Congestion window must be inside simulation window "
                f"[{args.sim_start:.3f}, {sim_end:.3f}]"
            )
        if congestion_end <= congestion_start:
            raise ValueError("--congestion-end-time must be > --congestion-start-time")

    # --- Generate flows ---
    probing_rows = generate_probing_flows(
        adjacency=adjacency,
        sim_start=args.sim_start,
        sim_end=sim_end,
        probing_rate=args.probing_rate,
    )

    background_rows = generate_background_flows(
        edges=edges,
        sim_start=args.sim_start,
        sim_end=sim_end,
        rate=args.background_rate,
        flows_per_link=args.background_flows_per_link,
        packet_sizes=background_packet_sizes,
        port_allocator=port_allocator,
        rng=rng,
    )

    protected_rows = generate_protected_flows(
        node_ids=node_ids,
        adjacency=adjacency,
        host_vector_str=args.protected_host_vector if args.protected_host_vector else "",
        protected_flow_count=args.protected_flow_count,
        protected_rate=args.protected_rate,
        protected_packet_size=args.protected_packet_size,
        protected_start_time=protected_start_time,
        protected_end_time=protected_end_time,
        protected_number_of_flow=args.protected_number_of_flow,
        rng=rng,
    )

    congestion_rows: list[WorkloadRow] = []
    _target_start = congestion_start
    _target_starts: list[float] = []
    for _i, _ct in enumerate(congestion_targets):
        if _i > 0:
            _shift = rng.choice(congestion_target_shifts)
            _target_start += _shift
        _target_starts.append(_target_start)
        if _target_start >= congestion_end:
            break
        congestion_rows += generate_congestion_flows(
            dag_edges=dags[_ct],
            target=_ct,
            congestion_start=_target_start,
            congestion_end=congestion_end,
            burst_duration=args.congestion_burst_duration,
            burst_gap=args.congestion_burst_gap,
            rate=args.congestion_rate,
            packet_size=args.congestion_packet_size,
            port_allocator=port_allocator,
        )

    rows = probing_rows + protected_rows + background_rows + congestion_rows

    if not rows:
        raise ValueError("No workload rows generated; check input topology and parameters")

    validate_rows(rows)

    def _sort_key(row: WorkloadRow) -> tuple:
        if row.is_probing:
            priority = 0
        elif row.is_protected:
            priority = 1
        elif row.is_congestion:
            priority = 3
        else:
            priority = 2
        return (priority, row.start_time, row.src_id, row.dst_id, row.dst_port)

    rows.sort(key=_sort_key)
    csv_lines = [row_to_csv(row) for row in rows]

    if not args.dry_run:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text("\n".join(csv_lines) + "\n", encoding="utf-8")

    udp_count = sum(1 for row in rows if row.protocol == UDP_PROTOCOL)
    tcp_count = sum(1 for row in rows if row.protocol == TCP_PROTOCOL)

    print("Generated workload summary")
    print(f"  seed: {args.seed}")
    print(f"  edges: {len(edges)}")
    print(f"  dags: {len(dags)}")
    print(f"  nodes: {len(node_ids)}")
    print(f"  sim_start: {args.sim_start:.3f}s")
    print(f"  duration: {args.duration:.3f}s")
    print(f"  sim_end: {sim_end:.3f}s")
    print(f"  total_flows: {len(rows)}")
    print(f"  udp_flows: {udp_count}")
    print(f"  tcp_flows: {tcp_count}")
    print(f"  probing_flows: {len(probing_rows)}")
    print(f"  probing_rate: {args.probing_rate}")
    print(f"  background_flows: {len(background_rows)}")
    print(f"  background_rate: {args.background_rate}")
    print(f"  background_flows_per_link: {args.background_flows_per_link}")
    print(f"  background_packet_sizes: {background_packet_sizes}")
    print(f"  protected_flows: {len(protected_rows)}")
    if len(protected_rows) > 0:
        print(f"  protected_rate: {args.protected_rate}")
        print(f"  protected_packet_size: {args.protected_packet_size}")
        print(f"  protected_start_time: {protected_start_time:.3f}s")
        print(f"  protected_end_time: {protected_end_time:.3f}s")
        print(f"  protected_number_of_flow: {args.protected_number_of_flow}")
    print(f"  congestion_flows: {len(congestion_rows)}")
    if congestion_targets:
        print(f"  congestion_targets: {congestion_targets}")
        print(f"  congestion_target_shifts: {congestion_target_shifts}")
        print(f"  congestion_rate: {args.congestion_rate}")
        print(f"  congestion_packet_size: {args.congestion_packet_size}")
        print(f"  congestion_window: [{congestion_start:.3f}s, {congestion_end:.3f}s]")
        print(f"  congestion_burst_duration: {args.congestion_burst_duration:.3f}s")
        print(f"  congestion_burst_gap: {args.congestion_burst_gap:.3f}s")
        for _i, _ct in enumerate(congestion_targets):
            if _i >= len(_target_starts):
                break
            n_src = len(dag_reachable_srcs(dags[_ct], _ct) - {_ct})
            n_bst = len([r for r in congestion_rows if r.dst_id == _ct]) // max(n_src, 1) if n_src else 0
            print(f"    target={_ct}: start={_target_starts[_i]:.3f}s, sources={n_src}, bursts={n_bst}")
    if args.dry_run:
        print("  output: dry-run (no file written)")
    else:
        print(f"  output: {args.output}")


if __name__ == "__main__":
    main()
