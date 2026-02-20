import random


node2port = {}


def make_port(src, dst, base=20000):
    if src not in node2port:
        node2port[src] = base + src * 100 + dst

    curr = node2port[src]
    node2port[src] += 1

    return curr


def normalize_matrix(W):
    s = sum(sum(row) for row in W)
    return [[x / s for x in row] for row in W]


def gen_gravity_weights(n, seed):
    rng = random.Random(seed)
    mass = [rng.lognormvariate(0.0, 0.6) for _ in range(n)]
    dist = [[0.0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            dist[i][j] = rng.uniform(0.5, 2.0)

    alpha = 0.7
    W = [[0.0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            base = mass[i] * mass[j] / (dist[i][j] ** alpha)
            skew = rng.lognormvariate(0.0, 1.0)
            W[i][j] = base * skew

    return normalize_matrix(W)


def scale_to_total_mbps(W, total_mbps):
    return [[x * total_mbps for x in row] for row in W]


def emit_csv_line(src, dst, start, end, port, rate, packet_size, proto, data_size, flows_number):
    return f"{src},{dst},{start:.3f},{end:.3f},{proto},{port},{rate},{packet_size},{data_size},{flows_number}"


def pick_k_ordered_pairs(node_ids, k, seed):
    rng = random.Random(seed)
    pairs = [(s, d) for s in node_ids for d in node_ids if s != d]
    rng.shuffle(pairs)
    return pairs[:k]


def parse_dags_edges(dags_str: str):
    directed = set()
    if not dags_str:
        return directed

    for block in dags_str.split(";"):
        if not block:
            continue
        if ":" not in block:
            continue
        _, edges_part = block.split(":", 1)
        if not edges_part:
            continue
        for e in edges_part.split(","):
            e = e.strip()
            if not e:
                continue
            a, b = e.split("-")
            directed.add((int(a), int(b)))
    return directed


def dag_adjacency_for_probing(directed_edges):
    undirected = set()
    for u, v in directed_edges:
        if u == v:
            continue
        undirected.add((min(u, v), max(u, v)))
    return undirected


def generate_probing(node_ids, dags_str, start, end, rate):
    directed_edges = parse_dags_edges(dags_str)

    lines = []
    undirected = dag_adjacency_for_probing(directed_edges)
    for a, b in sorted(undirected):
        lines.append(emit_csv_line(a, b, start, end, 33333, "100Kbps", 64, 17, 0, 1))
        lines.append(emit_csv_line(b, a, start, end, 33333, "100Kbps", 64, 17, 0, 1))

    return lines


def generate_flows(node_ids, sim_start, sim_end, seed, link_capacity_mbps, steady_total_mbps, bursty_avg_total_mbps, burst_duration_s, burst_gap_mean_s, max_burst_rate_mbps, packet_size, microflows_per_demand):
    n_nodes = len(node_ids)
    rng = random.Random(seed)
    W = gen_gravity_weights(n_nodes, seed=seed)

    steady_mbps = scale_to_total_mbps(W, steady_total_mbps)
    steady_lines = []
    for i in range(n_nodes):
        for j in range(n_nodes):
            if i == j:
                continue
            rate = steady_mbps[i][j]
            if microflows_per_demand > 1:
                rate /= microflows_per_demand
            if rate <= 0:
                continue
            
            src_id = node_ids[i]
            dst_id = node_ids[j]

            port = make_port(src_id, dst_id)
            rate = min(rate, link_capacity_mbps * 0.9)
            steady_lines.append(emit_csv_line(src_id, dst_id, sim_start, sim_end, port, f"{rate:.2f}Mbps", packet_size, 17, 0, microflows_per_demand))

    burst_avg_mbps = scale_to_total_mbps(W, bursty_avg_total_mbps)
    burst_lines = []
    for i in range(n_nodes):
        for j in range(n_nodes):
            if i == j:
                continue

            avg_rate = burst_avg_mbps[i][j]
            if microflows_per_demand > 1:
                avg_rate /= microflows_per_demand
            if avg_rate <= 0:
                continue

            duty = burst_duration_s / (burst_duration_s + burst_gap_mean_s)
            burst_rate = avg_rate / max(duty, 1e-6)
            burst_rate = min(burst_rate, max_burst_rate_mbps)
            t = sim_start + rng.uniform(0.0, 1.0)

            src_id = node_ids[i]
            dst_id = node_ids[j]

            while t < sim_end:
                start = t
                end = min(t + burst_duration_s, sim_end)
                port = make_port(src_id, dst_id)
                burst_lines.append(emit_csv_line(src_id, dst_id, start, end, port, f"{burst_rate:.2f}Mbps", packet_size, 17, 0, 1))
                gap = rng.expovariate(1.0 / burst_gap_mean_s)
                t = end + gap

    return steady_lines, burst_lines


def generate_delay_sensitive_flows(node_ids, k_flows, start, end, seed, base_port, rate_mbps, packet_size):
    pairs = pick_k_ordered_pairs(node_ids, k_flows, seed)
    lines = []
    for idx, (src, dst) in enumerate(pairs):
        port = base_port + idx
        lines.append(emit_csv_line(src, dst, start, end, port, f"{rate_mbps:.3f}Mbps", packet_size, 6, 0, 1))
    return lines


if __name__ == "__main__":
    sim_end = 10.0
    node_ids = [0, 1, 2, 9, 10]
    dag_str = "0:1-0,2-0,10-1,9-2,7-10,8-9,6-7,5-8,3-6,4-5,4-6;1:0-1,10-1,2-0,7-10,9-10,6-7,8-7,8-9,3-6,4-6,5-8;2:0-2,9-2,1-0,8-9,10-9,5-8,7-8,7-10,4-5,6-7,3-4,3-6;3:4-3,6-3,5-4,7-6,8-5,8-7,10-7,9-8,9-10,1-10,2-9,0-1;4:3-4,5-4,6-4,8-5,7-6,9-8,10-7,2-9,1-10,0-1,0-2;5:4-5,8-5,3-4,6-4,7-8,9-8,10-7,10-9,2-9,1-10,0-2;6:3-6,4-6,7-6,5-4,8-7,10-7,9-8,9-10,1-10,2-9,0-1;7:6-7,8-7,10-7,3-6,4-6,5-8,9-8,9-10,1-10,2-9,0-1;8:5-8,7-8,9-8,4-5,6-7,10-7,10-9,2-9,3-4,3-6,1-10,0-2;9:2-9,8-9,10-9,0-2,5-8,7-8,7-10,1-10,4-5,6-7,3-4,3-6;10:1-10,7-10,9-10,0-1,6-7,8-7,8-9,2-9,3-6,4-6,5-8"

    probes = generate_probing(node_ids=node_ids, dags_str=dag_str, start=0.5, end=sim_end, rate="100Kbps")

    delay_tcp = generate_delay_sensitive_flows(node_ids, k_flows=4, start=1.0, end=10.0, seed=1234, base_port=22222, rate_mbps=3.0, packet_size=512)

    steady, bursty = generate_flows(
        node_ids=node_ids,
        sim_start=1.5,
        sim_end=sim_end,
        seed=1234,
        link_capacity_mbps=100.0,
        steady_total_mbps=80.0,
        bursty_avg_total_mbps=40.0,
        burst_duration_s=0.6,
        burst_gap_mean_s=4.0,
        max_burst_rate_mbps=80.0,
        packet_size=1400,
        microflows_per_demand=1
    )

    with open("flows.csv", "w") as f:
        for line in probes:
            f.write(line + "\n")
        for line in delay_tcp:
            f.write(line + "\n")
        for line in steady:
            f.write(line + "\n")
        for line in bursty:
            f.write(line + "\n")

    print(f"wrote flows.csv with {len(steady)} steady + {len(bursty)} burst flows")