#!/usr/bin/env python3

import argparse
import random
from dataclasses import dataclass
from pathlib import Path

from gen_traffic import gen_gravity_weights


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


class PortAllocator:
	def __init__(self, start_port: int = 20000):
		self.next_port = start_port
		self.used_ports = set()

	def allocate(self) -> int:
		while self.next_port <= 65535:
			candidate = self.next_port
			self.next_port += 1
			if candidate in RESERVED_PORTS or candidate in self.used_ports:
				continue
			self.used_ports.add(candidate)
			return candidate
		raise ValueError("No valid destination ports available in range 20000-65535")


def parse_edges(edges_str: str) -> list[tuple[int, int]]:
	if not edges_str.strip():
		raise ValueError("--edges cannot be empty")

	edge_set = set()
	for block in edges_str.split(";"):
		block = block.strip()
		if not block:
			continue

		parts = block.split(",")
		if len(parts) != 2:
			raise ValueError(f"Invalid edge '{block}'. Expected format 'u,v'")

		left = parts[0].strip()
		right = parts[1].strip()
		if not left.isdigit() or not right.isdigit():
			raise ValueError(f"Invalid edge '{block}'. Node IDs must be non-negative integers")

		u = int(left)
		v = int(right)
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

	nodes = []
	seen = set()
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
	host_vector = []
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
	adjacency = {}
	for u, v in edges:
		adjacency.setdefault(u, []).append(v)
		adjacency.setdefault(v, []).append(u)
	for node in adjacency:
		adjacency[node].sort()
	return adjacency


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


def scale_weight_matrix_to_total_mbps(
	weight_matrix: list[list[float]],
	total_mbps: float,
) -> list[list[float]]:
	return [[weight * total_mbps for weight in row] for row in weight_matrix]


def latest_non_probing_start_time(sim_start: float, sim_end: float) -> float:
	if sim_end - sim_start <= 1.0:
		return sim_start
	return sim_end - 1.0


def build_udp_row(
	src_id: int,
	dst_id: int,
	start_time: float,
	end_time: float,
	dst_port: int,
	rate_mbps: float | str,
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

	if isinstance(rate_mbps, str):
		rate_value = rate_mbps.strip()
		if parse_rate_mbps(rate_value) <= 0:
			raise ValueError("rate_mbps must be > 0")
	else:
		rate_value = format_rate_mbps(rate_mbps)

	return WorkloadRow(
		src_id=src_id,
		dst_id=dst_id,
		start_time=start_time,
		end_time=normalized_end_time,
		protocol=UDP_PROTOCOL,
		dst_port=dst_port,
		rate=rate_value,
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

	# Compute the exact byte count needed to transmit at 'rate' from
	# start_time to (end_time - 2 s), so the flow ends naturally 2 s before
	# the simulation end rather than relying on a stop-time signal.
	active_duration_s = max(0.0, (end_time - 2.0) - start_time)
	data_size = int(rate_mbps * 1e6 / 8.0 * active_duration_s)

	return WorkloadRow(
		src_id=src_id,
		dst_id=dst_id,
		start_time=start_time,
		end_time=end_time,
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


def generate_background_flows(
	node_ids: list[int],
	sim_start: float,
	sim_end: float,
	link_capacity_mbps: float,
	seed: int,
	rng: random.Random,
	port_allocator: PortAllocator,
	number_of_flow: int,
) -> list[WorkloadRow]:
	node_count = len(node_ids)
	if node_count < 2:
		return []

	gravity_weights = gen_gravity_weights(node_count, seed=seed)
	steady_total_mbps = max(5.0, 0.65 * link_capacity_mbps)
	steady_rate_matrix = scale_weight_matrix_to_total_mbps(gravity_weights, steady_total_mbps)

	rows = []
	for src_index, src_id in enumerate(node_ids):
		for dst_index, dst_id in enumerate(node_ids):
			if src_id == dst_id:
				continue

			rate_mbps = steady_rate_matrix[src_index][dst_index]
			rate_mbps = min(rate_mbps, 0.20 * link_capacity_mbps)
			if rate_mbps < 0.15:
				continue

			packet_size = rng.choice([128, 256, 512, 900, 1200])
			rows.append(
				build_udp_row(
					src_id=src_id,
					dst_id=dst_id,
					start_time=sim_start,
					end_time=sim_end,
					dst_port=port_allocator.allocate(),
					rate_mbps=rate_mbps,
					packet_size=packet_size,
					data_size=0,
					number_of_flow=number_of_flow,
				)
			)
	return rows


def generate_probing_flows(
	adjacency: dict[int, list[int]],
	sim_start: float,
	sim_end: float,
	probing_rate: str,
) -> list[WorkloadRow]:
	rows = []
	for src_id in sorted(adjacency.keys()):
		for dst_id in adjacency[src_id]:
			rows.append(
				build_udp_row(
					src_id=src_id,
					dst_id=dst_id,
					start_time=sim_start,
					end_time=sim_end,
					dst_port=PROBING_PORT,
					rate_mbps=probing_rate,
					packet_size=64,
					data_size=0,
					number_of_flow=1,
					is_probing=True,
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

	all_pairs = [(src, dst) for src in eligible_nodes for dst in eligible_nodes if src != dst]
	preferred_pairs = [
		(src, dst)
		for src, dst in all_pairs
		if dst not in adjacency.get(src, [])
	]
	pair_pool = preferred_pairs if preferred_pairs else all_pairs
	rng.shuffle(pair_pool)

	rows = []
	for index in range(protected_flow_count):
		src_id, dst_id = pair_pool[index % len(pair_pool)]
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


def pick_alternate_neighbor(
	node: int,
	forbidden_neighbor: int,
	adjacency: dict[int, list[int]],
	rng: random.Random,
) -> int | None:
	candidates = [n for n in adjacency.get(node, []) if n != forbidden_neighbor]
	if not candidates:
		return None
	return rng.choice(candidates)


def generate_edge_congestion_flows(
	edges: list[tuple[int, int]],
	adjacency: dict[int, list[int]],
	sim_start: float,
	sim_end: float,
	link_capacity_mbps: float,
	rng: random.Random,
	port_allocator: PortAllocator,
	number_of_flow: int,
	congestion_level: float,
	edge_window_size_factor: float,
	burst_duration_s: float | None,
	burst_gap_mean_s: float | None,
) -> list[WorkloadRow]:
	rows = []
	duration = sim_end - sim_start
	latest_start_time = latest_non_probing_start_time(sim_start, sim_end)
	shuffled_edges = list(edges)
	rng.shuffle(shuffled_edges)

	slot_count = len(shuffled_edges)
	slot_size = duration / max(slot_count, 1)
	burst_duration = max(0.6, min(1.8, slot_size * 0.85))

	for index, (left_node, right_node) in enumerate(shuffled_edges):
		window_start = sim_start + index * slot_size
		window_length = slot_size * edge_window_size_factor
		window_end = min(sim_end, window_start + window_length, latest_start_time)
		if window_end <= window_start:
			continue

		computed_burst_duration_s = max(0.25, min(1.00, burst_duration * 0.45))
		computed_burst_gap_mean_s = max(0.20, min(1.50, slot_size * 0.35))
		effective_burst_duration_s = burst_duration_s
		if effective_burst_duration_s is None:
			effective_burst_duration_s = computed_burst_duration_s
		effective_burst_gap_mean_s = burst_gap_mean_s
		if effective_burst_gap_mean_s is None:
			effective_burst_gap_mean_s = computed_burst_gap_mean_s

		effective_burst_duration_s = max(0.05, min(effective_burst_duration_s, window_length))
		effective_burst_gap_mean_s = max(0.01, effective_burst_gap_mean_s / congestion_level)
		current_time = window_start + rng.uniform(0.0, min(0.15, slot_size * 0.15))

		while current_time < window_end:
			burst_start = current_time
			burst_end = min(window_end, burst_start + effective_burst_duration_s)
			if burst_end <= burst_start:
				break

			direct_rate = rng.uniform(0.82, 0.95) * link_capacity_mbps * congestion_level
			packet_size = rng.choice([1200, 1350, 1400])

			rows.append(
				build_udp_row(
					src_id=left_node,
					dst_id=right_node,
					start_time=burst_start,
					end_time=burst_end,
					dst_port=port_allocator.allocate(),
					rate_mbps=direct_rate,
					packet_size=packet_size,
					data_size=0,
					number_of_flow=number_of_flow,
				)
			)

			rows.append(
				build_udp_row(
					src_id=right_node,
					dst_id=left_node,
					start_time=burst_start,
					end_time=burst_end,
					dst_port=port_allocator.allocate(),
					rate_mbps=direct_rate * rng.uniform(0.75, 0.92),
					packet_size=packet_size,
					data_size=0,
					number_of_flow=number_of_flow,
				)
			)

			left_neighbor = pick_alternate_neighbor(left_node, right_node, adjacency, rng)
			if left_neighbor is not None:
				rows.append(
					build_udp_row(
						src_id=left_neighbor,
						dst_id=right_node,
						start_time=burst_start,
						end_time=burst_end,
						dst_port=port_allocator.allocate(),
						rate_mbps=rng.uniform(0.22, 0.40) * link_capacity_mbps * congestion_level,
						packet_size=rng.choice([900, 1200, 1350]),
						data_size=0,
						number_of_flow=number_of_flow,
					)
				)

			right_neighbor = pick_alternate_neighbor(right_node, left_node, adjacency, rng)
			if right_neighbor is not None:
				rows.append(
					build_udp_row(
						src_id=right_neighbor,
						dst_id=left_node,
						start_time=burst_start,
						end_time=burst_end,
						dst_port=port_allocator.allocate(),
						rate_mbps=rng.uniform(0.22, 0.40) * link_capacity_mbps * congestion_level,
						packet_size=rng.choice([900, 1200, 1350]),
						data_size=0,
						number_of_flow=number_of_flow,
					)
				)

			gap = rng.expovariate(1.0 / effective_burst_gap_mean_s)
			current_time = burst_end + gap

	return rows


def generate_data_size_flows(
	node_ids: list[int],
	sim_start: float,
	sim_end: float,
	rng: random.Random,
	port_allocator: PortAllocator,
	number_of_flow: int,
) -> list[WorkloadRow]:
	rows = []
	if len(node_ids) < 2:
		return rows

	latest_start_time = latest_non_probing_start_time(sim_start, sim_end)

	pair_candidates = [(src, dst) for src in node_ids for dst in node_ids if src != dst]
	rng.shuffle(pair_candidates)
	flow_count = min(max(3, len(node_ids)), len(pair_candidates))

	for src_id, dst_id in pair_candidates[:flow_count]:
		start_time = rng.uniform(sim_start, latest_start_time)
		rate_mbps = rng.uniform(2.0, 8.0)
		packet_size = rng.choice([96, 128, 256, 512])
		data_size = rng.randint(200_000, 2_000_000)
		rows.append(
			build_udp_row(
				src_id=src_id,
				dst_id=dst_id,
				start_time=start_time,
				end_time=sim_end,
				dst_port=port_allocator.allocate(),
				rate_mbps=rate_mbps,
				packet_size=packet_size,
				data_size=data_size,
				number_of_flow=number_of_flow,
			)
		)

	return rows


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
			# data_size may be non-zero (exact bytes computed from rate × active duration)
		elif row.protocol != UDP_PROTOCOL:
			raise ValueError("Non-probing/non-protected flows must use UDP protocol")
		elif row.dst_port in RESERVED_PORTS:
			raise ValueError(f"Reserved port used: {row.dst_port}")
		if row.data_size > 0 and row.end_time != 0.0 and not row.is_protected:
			raise ValueError("Rows with data_size > 0 must have end_time = 0")
		if row.data_size == 0 and row.end_time <= row.start_time:
			raise ValueError("Rows with data_size = 0 must have end_time > start_time")


def enforce_number_of_lines(
	rows: list[WorkloadRow],
	target_line_count: int,
	sim_start: float,
	sim_end: float,
	rng: random.Random,
	port_allocator: PortAllocator,
) -> list[WorkloadRow]:
	if target_line_count == len(rows):
		return rows

	latest_start_time = latest_non_probing_start_time(sim_start, sim_end)

	if target_line_count < len(rows):
		return rng.sample(rows, target_line_count)

	if not rows:
		raise ValueError("Cannot expand line count because there are no generated rows")

	base_rows = list(rows)
	expanded_rows = list(rows)
	index = 0
	while len(expanded_rows) < target_line_count:
		base_row = base_rows[index % len(base_rows)]
		index += 1

		if base_row.data_size > 0:
			start_time = rng.uniform(sim_start, latest_start_time)
			end_time = 0.0
			data_size = base_row.data_size
		else:
			start_time = rng.uniform(sim_start, latest_start_time)
			end_time = min(sim_end, start_time + rng.uniform(0.4, max(0.8, (sim_end - sim_start) * 0.2)))
			data_size = 0

		rate_mbps = parse_rate_mbps(base_row.rate) * rng.uniform(0.85, 1.15)
		expanded_rows.append(
			build_udp_row(
				src_id=base_row.src_id,
				dst_id=base_row.dst_id,
				start_time=start_time,
				end_time=end_time,
				dst_port=port_allocator.allocate(),
				rate_mbps=rate_mbps,
				packet_size=base_row.packet_size,
				data_size=data_size,
				number_of_flow=base_row.number_of_flow,
			)
		)

	return expanded_rows


def scale_row_rates(
	rows: list[WorkloadRow],
	rate_scale: float,
	link_capacity_mbps: float,
) -> list[WorkloadRow]:
	if rate_scale <= 0:
		raise ValueError("rate_scale must be > 0")

	scaled_rows = []
	for row in rows:
		if row.is_probing or row.is_protected:
			scaled_rows.append(row)
			continue

		rate_mbps = parse_rate_mbps(row.rate) * rate_scale
		rate_mbps = min(rate_mbps, 0.95 * link_capacity_mbps)
		rate_mbps = max(rate_mbps, 0.001)
		scaled_rows.append(
			WorkloadRow(
				src_id=row.src_id,
				dst_id=row.dst_id,
				start_time=row.start_time,
				end_time=row.end_time,
				protocol=row.protocol,
				dst_port=row.dst_port,
				rate=format_rate_mbps(rate_mbps),
				packet_size=row.packet_size,
				data_size=row.data_size,
				number_of_flow=row.number_of_flow,
			)
		)

	return scaled_rows


def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(
		description=(
			"Generate UDP workload CSV for qlrouting from topology edges, with time-staggered "
			"link congestion episodes."
		)
	)
	parser.add_argument("--output", required=True, help="Path to output CSV file")
	parser.add_argument(
		"--edges",
		required=True,
		help="Topology edges in format '0,1;0,2;1,2' (undirected)",
	)
	parser.add_argument(
		"--node-ids",
		default=None,
		help="Optional comma-separated node ids override; must include all nodes in --edges",
	)
	parser.add_argument("--sim-start", type=float, default=0.5, help="Workload start time in seconds")
	parser.add_argument(
		"--duration",
		type=float,
		default=10.0,
		help="Workload duration in seconds (default: 10.0)",
	)
	parser.add_argument(
		"--link-capacity-mbps",
		type=float,
		default=100.0,
		help="Reference link capacity in Mbps used to scale rates",
	)
	parser.add_argument("--seed", type=int, default=1234, help="Random seed")
	parser.add_argument(
		"--number-of-lines",
		type=int,
		default=None,
		help="Target number of lines in the output CSV",
	)
	parser.add_argument(
		"--number-of-flow",
		type=int,
		default=1,
		help="Value for CSV number_of_flow field (default: 1)",
	)
	parser.add_argument(
		"--congestion-level",
		type=float,
		default=1.0,
		help="Congestion intensity multiplier (>0). 1.0 keeps default behavior",
	)
	parser.add_argument(
		"--edge-window-size-factor",
		type=float,
		default=1.0,
		help="Fraction of each per-edge slot used as congestion window (0,1]",
	)
	parser.add_argument(
		"--burst-duration-s",
		type=float,
		default=None,
		help="Optional fixed burst duration in seconds (default: auto from slot)",
	)
	parser.add_argument(
		"--burst-gap-mean-s",
		type=float,
		default=None,
		help="Optional fixed exponential mean gap between bursts in seconds (default: auto from slot)",
	)
	parser.add_argument(
		"--probing-rate",
		type=str,
		default="100Kbps",
		help="Rate for probing flows sent to each neighbor (default: 100Kbps)",
	)
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
	parser.add_argument("--dry-run", action="store_true", help="Generate and validate without writing file")
	return parser.parse_args()


def main() -> None:
	args = parse_args()

	if args.duration <= 0:
		raise ValueError("--duration must be > 0")
	if args.sim_start < 0:
		raise ValueError("--sim-start must be >= 0")
	if args.link_capacity_mbps <= 0:
		raise ValueError("--link-capacity-mbps must be > 0")
	if args.edge_window_size_factor <= 0 or args.edge_window_size_factor > 1:
		raise ValueError("--edge-window-size-factor must be in (0, 1]")
	if args.burst_duration_s is not None and args.burst_duration_s <= 0:
		raise ValueError("--burst-duration-s must be > 0")
	if args.burst_gap_mean_s is not None and args.burst_gap_mean_s <= 0:
		raise ValueError("--burst-gap-mean-s must be > 0")
	if parse_rate_mbps(args.probing_rate) <= 0:
		raise ValueError("--probing-rate must be > 0")
	if args.congestion_level <= 0:
		raise ValueError("--congestion-level must be > 0")
	if args.number_of_lines is not None and args.number_of_lines < 1:
		raise ValueError("--number-of-lines must be >= 1")
	if args.number_of_flow < 1:
		raise ValueError("--number-of-flow must be >= 1")
	if args.protected_flow_count < 0:
		raise ValueError("--protected-flow-count must be >= 0")
	if args.protected_number_of_flow < 1:
		raise ValueError("--protected-number-of-flow must be >= 1")
	if args.protected_packet_size <= 0:
		raise ValueError("--protected-packet-size must be > 0")
	if parse_rate_mbps(args.protected_rate) <= 0:
		raise ValueError("--protected-rate must be > 0")

	sim_end = args.sim_start + args.duration
	margin = min(0.5, args.duration * 0.1)
	protected_start_time = args.protected_start_time if args.protected_start_time is not None else args.sim_start + margin
	protected_end_time = args.protected_end_time if args.protected_end_time is not None else sim_end - margin
	if protected_start_time < args.sim_start or protected_end_time > sim_end:
		raise ValueError(
			"Protected flow time window must be inside simulation window "
			f"[{args.sim_start:.3f}, {sim_end:.3f}]"
		)
	if protected_end_time <= protected_start_time:
		raise ValueError("--protected-end-time must be > --protected-start-time")
	if args.protected_flow_count > 0 and args.protected_host_vector is None:
		raise ValueError("--protected-host-vector is required when --protected-flow-count > 0")

	rng = random.Random(args.seed)
	edges = parse_edges(args.edges)
	node_ids = parse_node_ids(args.node_ids, edges)
	adjacency = make_adjacency(edges)
	traffic_start = args.sim_start + min(0.001, max((sim_end - args.sim_start) * 0.05, 0.0))

	port_allocator = PortAllocator(start_port=20000)

	probing_rows = generate_probing_flows(
		adjacency=adjacency,
		sim_start=args.sim_start,
		sim_end=sim_end,
		probing_rate=args.probing_rate,
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

	non_probing_rows = []
	non_probing_rows.extend(
		generate_background_flows(
			node_ids=node_ids,
			sim_start=traffic_start,
			sim_end=sim_end,
			link_capacity_mbps=args.link_capacity_mbps,
			seed=args.seed,
			rng=rng,
			port_allocator=port_allocator,
			number_of_flow=args.number_of_flow,
		)
	)
	non_probing_rows.extend(
		generate_edge_congestion_flows(
			edges=edges,
			adjacency=adjacency,
			sim_start=traffic_start,
			sim_end=sim_end,
			link_capacity_mbps=args.link_capacity_mbps,
			rng=rng,
			port_allocator=port_allocator,
			number_of_flow=args.number_of_flow,
				congestion_level=args.congestion_level,
			edge_window_size_factor=args.edge_window_size_factor,
			burst_duration_s=args.burst_duration_s,
			burst_gap_mean_s=args.burst_gap_mean_s,
		)
	)
	non_probing_rows.extend(
		generate_data_size_flows(
			node_ids=node_ids,
			sim_start=traffic_start,
			sim_end=sim_end,
			rng=rng,
			port_allocator=port_allocator,
			number_of_flow=args.number_of_flow,
		)
	)

	if not probing_rows and not protected_rows and not non_probing_rows:
		raise ValueError("No workload rows generated; check input topology and parameters")

	base_line_count = len(non_probing_rows)
	if args.number_of_lines is not None:
		minimum_lines = len(probing_rows) + len(protected_rows)
		if args.number_of_lines < minimum_lines:
			raise ValueError(
				"--number-of-lines is too small. It must be >= number of probing + protected flows "
				f"({minimum_lines})"
			)

		target_non_probing_lines = args.number_of_lines - minimum_lines
		if target_non_probing_lines == 0:
			non_probing_rows = []
		elif not non_probing_rows:
			raise ValueError(
				"No non-probing rows available to satisfy --number-of-lines beyond probing flows"
			)
		else:
			non_probing_rows = enforce_number_of_lines(
				rows=non_probing_rows,
				target_line_count=target_non_probing_lines,
				sim_start=traffic_start,
				sim_end=sim_end,
				rng=rng,
				port_allocator=port_allocator,
			)

	line_scale = 1.0
	if args.number_of_lines is not None and len(non_probing_rows) > 0:
		line_scale = base_line_count / max(len(non_probing_rows), 1)

	flow_scale = 1.0 / args.number_of_flow
	applied_rate_scale = line_scale * flow_scale
	non_probing_rows = scale_row_rates(
		rows=non_probing_rows,
		rate_scale=applied_rate_scale,
		link_capacity_mbps=args.link_capacity_mbps,
	)

	rows = probing_rows + protected_rows + non_probing_rows

	validate_rows(rows)

	rows.sort(key=lambda row: (row.start_time, row.src_id, row.dst_id, row.dst_port))
	csv_lines = [row_to_csv(row) for row in rows]

	if not args.dry_run:
		output_path = Path(args.output)
		output_path.parent.mkdir(parents=True, exist_ok=True)
		output_path.write_text("\n".join(csv_lines) + "\n", encoding="utf-8")

	udp_count = sum(1 for row in rows if row.protocol == UDP_PROTOCOL)
	tcp_count = sum(1 for row in rows if row.protocol == TCP_PROTOCOL)
	probing_count = sum(1 for row in rows if row.is_probing)
	protected_count = sum(1 for row in rows if row.is_protected)
	data_size_count = sum(1 for row in rows if row.data_size > 0)
	timed_count = len(rows) - data_size_count

	print("Generated workload summary")
	print(f"  seed: {args.seed}")
	print(f"  edges: {len(edges)}")
	print(f"  nodes: {len(node_ids)}")
	print(f"  workload_start: {args.sim_start:.3f}s")
	print(f"  workload_duration: {args.duration:.3f}s")
	print(f"  workload_end: {sim_end:.3f}s")
	print(f"  total_flows: {len(rows)}")
	print(f"  udp_flows: {udp_count}")
	print(f"  tcp_flows: {tcp_count}")
	print(f"  probing_flows: {probing_count}")
	print(f"  probing_rate: {args.probing_rate}")
	print(f"  protected_flows: {protected_count}")
	if protected_count > 0:
		print(f"  protected_rate: {args.protected_rate}")
		print(f"  protected_packet_size: {args.protected_packet_size}")
		print(f"  protected_start_time: {protected_start_time:.3f}")
		print(f"  protected_end_time: {protected_end_time:.3f}")
		print(f"  protected_number_of_flow: {args.protected_number_of_flow}")
	print(f"  timed_flows(data_size=0): {timed_count}")
	print(f"  sized_flows(data_size>0): {data_size_count}")
	if args.number_of_lines is None:
		print(f"  number_of_lines: auto ({len(rows)})")
	else:
		print(f"  number_of_lines: {args.number_of_lines}")
	print(f"  number_of_flow: {args.number_of_flow}")
	print(f"  congestion_level: {args.congestion_level:.3f}")
	print(f"  edge_window_size_factor: {args.edge_window_size_factor:.3f}")
	if args.burst_duration_s is None:
		print("  burst_duration_s: auto")
	else:
		print(f"  burst_duration_s: {args.burst_duration_s:.3f}")
	if args.burst_gap_mean_s is None:
		print("  burst_gap_mean_s: auto")
	else:
		print(f"  burst_gap_mean_s: {args.burst_gap_mean_s:.3f}")
	print(f"  applied_rate_scale: {applied_rate_scale:.4f}")
	if args.dry_run:
		print("  output: dry-run (no file written)")
	else:
		print(f"  output: {args.output}")


if __name__ == "__main__":
	main()
