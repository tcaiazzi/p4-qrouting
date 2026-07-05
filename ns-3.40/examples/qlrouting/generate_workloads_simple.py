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

def parse_topology_file(path: str) -> dict[str, str]:
    """Parse a shell-style topology file and return a dict of variable assignments.

    Lines of the form  KEY="value"  or  KEY=value  are extracted.
    Comments (#) and blank lines are ignored.
    """
    result: dict[str, str] = {}
    import re
    pattern = re.compile(r'^([A-Z_][A-Z0-9_]*)=(?:"([^"]*)"|(.*))$')
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            m = pattern.match(line)
            if m:
                key = m.group(1)
                value = m.group(2) if m.group(2) is not None else (m.group(3) or "")
                result[key] = value
    return result


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


def dag_path(dag_edges: set[tuple[int, int]], src: int, dst: int) -> list[int]:
    """BFS path from src to dst following directed DAG edges for dst.

    Returns ordered node list [src, ..., dst].
    Raises ValueError if no path exists in the DAG.
    """
    if src == dst:
        return [src]
    dag_adj: dict[int, list[int]] = {}
    for u, v in dag_edges:
        dag_adj.setdefault(u, []).append(v)
    prev: dict[int, int] = {src: -1}
    queue: list[int] = [src]
    head = 0
    while head < len(queue):
        node = queue[head]
        head += 1
        for nb in dag_adj.get(node, []):
            if nb not in prev:
                prev[nb] = node
                if nb == dst:
                    path: list[int] = []
                    cur = dst
                    while cur != -1:
                        path.append(cur)
                        cur = prev[cur]
                    path.reverse()
                    return path
                queue.append(nb)
    raise ValueError(f"No DAG path from {src} to {dst}")


def dag_connected_without_edge(
    dag_edges: set[tuple[int, int]], src: int, dst: int, remove_u: int, remove_v: int
) -> bool:
    """Return True if dst is still reachable from src in the DAG after removing directed edge (remove_u, remove_v)."""
    dag_adj: dict[int, list[int]] = {}
    for u, v in dag_edges:
        if u == remove_u and v == remove_v:
            continue
        dag_adj.setdefault(u, []).append(v)
    visited: set[int] = {src}
    stack: list[int] = [src]
    while stack:
        node = stack.pop()
        if node == dst:
            return True
        for nb in dag_adj.get(node, []):
            if nb not in visited:
                visited.add(nb)
                stack.append(nb)
    return False


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

def _congestion_events_per_destination(
    protected_rows: list[WorkloadRow],
    dags: dict[int, set[tuple[int, int]]],
    events_per_dest: int,
    congestion_start: float,
    congestion_end: float,
    duration_min: float,
    duration_max: float,
    rate: str,
    packet_size: int,
    port_allocator: PortAllocator,
    rng: random.Random,
) -> list[WorkloadRow]:
    """Per-destination congestion that blocks DIFFERENT paths concurrently.

    For each distinct protected destination we allocate a DISJOINT time slot
    (destinations never overlap in time) and, within that slot, place up to
    ``events_per_dest`` CONCURRENT floods, each on a link of a different path
    toward the destination (successive-path blocking: block a link, recompute
    the path on the residual DAG, block a link of that new path, ...). A route
    to the destination is always left open (never disconnect) — that is the
    path the global scheme can still find, while a purely-local scheme reroutes
    from one blocked path into another that is congested at the same time.
    """
    import sys

    rows: list[WorkloadRow] = []
    # Distinct destinations, insertion order preserved for reproducible slots.
    dest_to_src: dict[int, int] = {}
    for r in protected_rows:
        dest_to_src.setdefault(r.dst_id, r.src_id)
    destinations = list(dest_to_src.keys())
    num_dests = len(destinations)
    if num_dests == 0 or events_per_dest <= 0:
        return rows

    slot_len = (congestion_end - congestion_start) / num_dests

    for k, dst in enumerate(destinations):
        dag_edges = dags.get(dst)
        if dag_edges is None:
            print(
                f"WARNING: no DAG entry for destination {dst}; skipping",
                file=sys.stderr,
            )
            continue
        src = dest_to_src[dst]

        # Disjoint time slot for this destination; one shared window inside it
        # so all its events are concurrent.
        slot_start = congestion_start + k * slot_len
        slot_end = slot_start + slot_len
        duration = min(rng.uniform(duration_min, duration_max), slot_len)
        start_time = slot_start
        end_time = min(start_time + duration, slot_end)
        if end_time <= start_time:
            continue

        blocked: set[tuple[int, int]] = set()
        for _ in range(events_per_dest):
            residual = dag_edges - blocked
            try:
                path = dag_path(residual, src, dst)
            except ValueError:
                break  # no path left in the residual DAG; keep dst reachable
            # Prefer the DEEPEST reroutable link on the path (farthest from
            # src, i.e. largest index along the path). A local scheme commits at
            # the upstream branch BEFORE it can observe a deep block and gets
            # trapped, while the global scheme (downstream color propagation)
            # diverts around it. Blocking the branch-adjacent link instead would
            # be visible to local -> local recovers -> no local-vs-global gap.
            candidates = [
                (i, path[i], path[i + 1])
                for i in range(len(path) - 1)
                if (path[i], path[i + 1]) not in blocked
                and dag_connected_without_edge(
                    residual, src, dst, path[i], path[i + 1]
                )
            ]
            if not candidates:
                break  # remaining links are bridges; stop to leave a live route
            _, u, v = max(candidates, key=lambda c: c[0])
            blocked.add((u, v))
            rows.append(
                WorkloadRow(
                    src_id=u,
                    dst_id=v,
                    start_time=start_time,
                    end_time=end_time,
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
    return rows


def generate_congestion_events(
    protected_rows: list[WorkloadRow],
    dags: dict[int, set[tuple[int, int]]],
    num_events: int,
    congestion_start: float,
    congestion_end: float,
    duration_min: float,
    duration_max: float,
    rate: str,
    packet_size: int,
    port_allocator: PortAllocator,
    rng: random.Random,
    mode: str = "independent",
) -> list[WorkloadRow]:
    """Generate point-to-point congestion events tied to protected flows.

    mode="independent" (default): for each event pick a protected flow at
    random, find the routing path from its src to dst using the DAG for dst,
    select a link on that path whose removal still leaves an alternate DAG path
    (i.e. not a DAG bridge), then schedule a UDP flood for a uniformly drawn
    duration within the congestion window.

    mode="per-destination": see ``_congestion_events_per_destination`` — blocks
    ``num_events`` different paths per destination, concurrently, in disjoint
    time slots across destinations.
    """
    if mode == "per-destination":
        return _congestion_events_per_destination(
            protected_rows=protected_rows,
            dags=dags,
            events_per_dest=num_events,
            congestion_start=congestion_start,
            congestion_end=congestion_end,
            duration_min=duration_min,
            duration_max=duration_max,
            rate=rate,
            packet_size=packet_size,
            port_allocator=port_allocator,
            rng=rng,
        )

    import sys

    rows: list[WorkloadRow] = []
    for _ in range(num_events):
        flow = rng.choice(protected_rows)
        dag_edges = dags.get(flow.dst_id)
        if dag_edges is None:
            print(
                f"WARNING: no DAG entry for destination {flow.dst_id}; "
                "skipping congestion event",
                file=sys.stderr,
            )
            continue
        try:
            path = dag_path(dag_edges, flow.src_id, flow.dst_id)
        except ValueError as exc:
            print(f"WARNING: {exc}; skipping congestion event", file=sys.stderr)
            continue
        path_edges = [(path[i], path[i + 1]) for i in range(len(path) - 1)]
        candidate_edges = [
            (u, v) for u, v in path_edges
            if dag_connected_without_edge(dag_edges, flow.src_id, flow.dst_id, u, v)
        ]
        if not candidate_edges:
            print(
                f"WARNING: all links on DAG path {flow.src_id}->{flow.dst_id} are bridges; "
                "skipping congestion event",
                file=sys.stderr,
            )
            continue
        u, v = rng.choice(candidate_edges)
        start_time = rng.uniform(congestion_start, congestion_end)
        duration = rng.uniform(duration_min, duration_max)
        end_time = min(start_time + duration, congestion_end)
        if end_time <= start_time:
            continue
        rows.append(
            WorkloadRow(
                src_id=u,
                dst_id=v,
                start_time=start_time,
                end_time=end_time,
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
        "--topology-file",
        default=None,
        help=(
            "Path to a shell-style topology file defining EDGES, DAGS, and HOSTS variables "
            "(e.g. abilene.topology). When provided, --edges, --dags, and "
            "--protected-host-vector default to the values in this file."
        ),
    )
    parser.add_argument(
        "--edges",
        default=None,
        help="Physical topology edges in format '0,1;0,2;1,2' (undirected). "
             "Required if --topology-file is not given.",
    )
    parser.add_argument(
        "--dags",
        default=None,
        help=(
            "Logical DAGs in format 'target:u-v,u-v,...;target:...' "
            "(same format produced by parse_zoo.py). Used to compute routing paths. "
            "Required if --topology-file is not given."
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
    parser.add_argument(
        "--no-background",
        action="store_true",
        default=False,
        help="Skip background flow generation entirely",
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
        "--num-congestion-events",
        type=int,
        default=0,
        help="Number of congestion events to generate (default: 0, disabled)",
    )
    parser.add_argument(
        "--congestion-rate",
        type=str,
        default="50Mbps",
        help="Rate for each congestion flow (default: 50Mbps)",
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
        help="Lower bound of the congestion event start-time sampling window (default: sim_start + 20%% of duration)",
    )
    parser.add_argument(
        "--congestion-end-time",
        type=float,
        default=None,
        help="Upper bound of the congestion event start-time sampling window (default: sim_end - 20%% of duration)",
    )
    parser.add_argument(
        "--congestion-duration-min",
        type=float,
        default=0.5,
        help="Minimum duration of a congestion event in seconds (default: 0.5)",
    )
    parser.add_argument(
        "--congestion-duration-max",
        type=float,
        default=2.0,
        help="Maximum duration of a congestion event in seconds (default: 2.0)",
    )
    parser.add_argument(
        "--congestion-mode",
        choices=["independent", "per-destination"],
        default="independent",
        help=(
            "independent (default): --num-congestion-events random events over "
            "the whole window. per-destination: --num-congestion-events events "
            "PER protected destination, each blocking a DIFFERENT path toward it, "
            "concurrent within a destination but in disjoint time slots across "
            "destinations."
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
    # Note: protected-host-vector may still be None here if it comes from --topology-file;
    # the definitive check is performed after topology file resolution below.
    if args.num_congestion_events < 0:
        raise ValueError("--num-congestion-events must be >= 0")
    if args.num_congestion_events > 0:
        if args.protected_flow_count == 0:
            raise ValueError("--protected-flow-count > 0 is required when --num-congestion-events > 0")
        if args.congestion_packet_size <= 0:
            raise ValueError("--congestion-packet-size must be > 0")
        if args.congestion_duration_min <= 0:
            raise ValueError("--congestion-duration-min must be > 0")
        if args.congestion_duration_max < args.congestion_duration_min:
            raise ValueError("--congestion-duration-max must be >= --congestion-duration-min")

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

    # --- Resolve topology source (file or explicit args) ---
    topo_vars: dict[str, str] = {}
    if args.topology_file is not None:
        topo_vars = parse_topology_file(args.topology_file)

    edges_str = args.edges or topo_vars.get("EDGES")
    dags_str = args.dags or topo_vars.get("DAGS")
    if not edges_str:
        raise ValueError("--edges is required (or provide --topology-file with an EDGES variable)")
    if not dags_str:
        raise ValueError("--dags is required (or provide --topology-file with a DAGS variable)")

    # Fill protected-host-vector from topology file HOSTS if not given explicitly
    if args.protected_host_vector is None and "HOSTS" in topo_vars:
        args.protected_host_vector = topo_vars["HOSTS"]
    if args.protected_flow_count > 0 and args.protected_host_vector is None:
        raise ValueError(
            "--protected-host-vector is required when --protected-flow-count > 0 "
            "(or provide --topology-file with a HOSTS variable)"
        )

    # --- Parse topology ---
    rng = random.Random(args.seed)
    edges = parse_edges(edges_str)
    dags = parse_dags(dags_str)
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
    if args.num_congestion_events > 0:
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

    background_rows = (
        []
        if args.no_background
        else generate_background_flows(
            edges=edges,
            sim_start=args.sim_start,
            sim_end=sim_end,
            rate=args.background_rate,
            flows_per_link=args.background_flows_per_link,
            packet_sizes=background_packet_sizes,
            port_allocator=port_allocator,
            rng=rng,
        )
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
    if args.num_congestion_events > 0:
        congestion_rows = generate_congestion_events(
            protected_rows=protected_rows,
            dags=dags,
            num_events=args.num_congestion_events,
            congestion_start=congestion_start,
            congestion_end=congestion_end,
            duration_min=args.congestion_duration_min,
            duration_max=args.congestion_duration_max,
            rate=args.congestion_rate,
            packet_size=args.congestion_packet_size,
            port_allocator=port_allocator,
            rng=rng,
            mode=args.congestion_mode,
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
    print(f"  congestion_events_requested: {args.num_congestion_events}")
    print(f"  congestion_flows: {len(congestion_rows)}")
    if args.num_congestion_events > 0:
        print(f"  congestion_rate: {args.congestion_rate}")
        print(f"  congestion_packet_size: {args.congestion_packet_size}")
        print(f"  congestion_window: [{congestion_start:.3f}s, {congestion_end:.3f}s]")
        print(f"  congestion_duration: [{args.congestion_duration_min:.3f}s, {args.congestion_duration_max:.3f}s]")
    if args.dry_run:
        print("  output: dry-run (no file written)")
    else:
        print(f"  output: {args.output}")


if __name__ == "__main__":
    main()
