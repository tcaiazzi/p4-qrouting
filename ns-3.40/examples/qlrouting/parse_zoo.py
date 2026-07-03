import argparse
import random
import sys

import networkx as nx


def dag_to_target(G: nx.Graph, target):
    if target not in G:
        raise ValueError(f"Target {target} not in graph")

    dist = dict(nx.single_source_shortest_path_length(G, target))

    D = nx.DiGraph()
    D.add_nodes_from(dist.keys())

    for a, b, data in G.edges(data=True):
        if a in dist and b in dist:
            rank_a = (dist[a], str(a))
            rank_b = (dist[b], str(b))

            if rank_a > rank_b:
                D.add_edge(a, b, **data)
            elif rank_b > rank_a:
                D.add_edge(b, a, **data)

    return D, dist


def dag_to_target_with_slack(G: nx.Graph, target, k: int = 0):
    if target not in G:
        raise ValueError(f"Target {target} not in graph")

    dist = dict(nx.single_source_shortest_path_length(G, target))

    D = nx.DiGraph()
    D.add_nodes_from(dist.keys())

    for a, b, data in G.edges(data=True):
        if a in dist and b in dist:
            if dist[a] > dist[b]:
                u, v = a, b
            elif dist[b] > dist[a]:
                u, v = b, a
            else:
                continue
            if 1 + dist[v] <= dist[u] + k:
                D.add_edge(u, v, **data)

    return D, dist


def augment_graph(G: nx.Graph, target_degree: float, seed: int = 1234,
                  max_degree: int = None, forbidden=None) -> nx.Graph:
    """Add random non-existing edges (simple graph, no self-loops) until the
    average degree reaches target_degree. Deterministic given seed.

    If max_degree is set, never raise any node above that degree (a node at the
    cap is skipped as an endpoint). The target may then be unreachable; the
    function adds as many valid edges as possible.

    If forbidden(u, v) is provided and returns True for a pair, that edge is
    never added.
    """
    n = G.number_of_nodes()
    if n < 2:
        return G

    max_edges = n * (n - 1) // 2
    target_edges = min(max_edges, round(target_degree * n / 2.0))

    nodes = list(G.nodes())
    rng = random.Random(seed)

    # Candidate non-edges, shuffled deterministically.
    candidates = [
        (u, v)
        for i, u in enumerate(nodes)
        for v in nodes[i + 1:]
        if not G.has_edge(u, v)
    ]
    rng.shuffle(candidates)

    for u, v in candidates:
        if G.number_of_edges() >= target_edges:
            break
        if forbidden is not None and forbidden(u, v):
            continue
        if max_degree is not None and (
            G.degree(u) >= max_degree or G.degree(v) >= max_degree
        ):
            continue
        G.add_edge(u, v)

    return G


def spread_host_attachments(G: nx.Graph, host_nodes, core_nodes,
                            host_degree: int, seed: int = 1234):
    """Reattach host nodes to distinct core nodes, minimizing the number of core
    neighbors shared between hosts (greedy least-used-core assignment). This
    maximizes the pairwise distance between hosts so protected src->dst paths run
    through the core (>=3 hops) instead of a shared 1-hop gateway.

    Removes every existing host-incident edge first; hosts end up connected only
    to core nodes.
    """
    rng = random.Random(seed)
    host_set = set(host_nodes)

    # Drop all current host attachments (and any host-host edges).
    G.remove_edges_from(
        [(u, v) for u, v in list(G.edges()) if u in host_set or v in host_set]
    )

    core_use = {c: 0 for c in core_nodes}
    for h in host_nodes:
        # Prefer the least-used cores (spreads hosts across distinct cores);
        # random tie-break for reproducibility.
        candidates = sorted(core_nodes, key=lambda c: (core_use[c], rng.random()))
        for c in candidates[:host_degree]:
            G.add_edge(h, c)
            core_use[c] += 1
    return G


def branching_summary(G: nx.Graph):
    """Return (multi, total, avg_choices) over (dest, switch) DAG branching."""
    total = multi = 0
    choices = []
    for t in G.nodes:
        D, _ = dag_to_target(G, t)
        for u in D.nodes:
            if u == t:
                continue
            d = D.out_degree(u)
            if d > 0:
                total += 1
                choices.append(d)
                if d > 1:
                    multi += 1
    avg = sum(choices) / len(choices) if choices else 0.0
    return multi, total, avg


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Generate DAGS/EDGES/HOSTS/SWITCHES from a topology"
    )
    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument(
        "--file",
        dest="graphml_file",
        help="Path to GraphML file",
    )
    input_group.add_argument(
        "--edges",
        help='Edge list as "u,v;v,w;..." (also accepts "u-v")',
    )
    parser.add_argument(
        "--augment-degree",
        type=float,
        default=None,
        help="Add random edges until the average degree reaches this target",
    )
    parser.add_argument(
        "--augment-seed",
        type=int,
        default=1234,
        help="Seed for reproducible edge augmentation (default: 1234)",
    )
    parser.add_argument(
        "--max-degree",
        type=int,
        default=None,
        help="Cap the per-node degree during augmentation (no node exceeds it)",
    )
    parser.add_argument(
        "--no-host-host-edges",
        action="store_true",
        help="Forbid direct edges between two host nodes (per --hosts); removes "
             "any pre-existing host-host edges too. Requires --hosts.",
    )
    parser.add_argument(
        "--spread-hosts",
        action="store_true",
        help="Reattach hosts to distinct core nodes (minimizing shared cores) so "
             "protected src->dst paths run through the core (>=3 hops). Then only "
             "the core is densified. Requires --hosts.",
    )
    parser.add_argument(
        "--host-degree",
        type=int,
        default=1,
        help="Number of core uplinks per host when --spread-hosts is set (default: 1)",
    )
    parser.add_argument(
        "--hosts",
        default=None,
        help='HOSTS vector override, e.g. "1,1,1,1,1,0,0,0,0,0,0" (default: all 1s)',
    )
    parser.add_argument(
        "--out",
        default=None,
        help="Write a multi-line .topology file instead of printing a single line",
    )
    args = parser.parse_args()

    return args


def graph_from_edges(edges_arg: str) -> nx.Graph:
    graph = nx.Graph()
    raw_edges = [edge.strip() for edge in edges_arg.split(";") if edge.strip()]

    if not raw_edges:
        raise ValueError("--edges is empty")

    for raw_edge in raw_edges:
        if "," in raw_edge:
            left, right = [part.strip() for part in raw_edge.split(",", 1)]
        elif "-" in raw_edge:
            left, right = [part.strip() for part in raw_edge.split("-", 1)]
        else:
            raise ValueError(
                f"Invalid edge '{raw_edge}'. Use 'u,v' or 'u-v' and separate edges with ';'"
            )

        if not left or not right:
            raise ValueError(f"Invalid edge '{raw_edge}'")

        graph.add_edge(left, right)

    return graph


if __name__ == "__main__":
    args = parse_arguments()

    try:
        if args.graphml_file:
            G = nx.read_graphml(args.graphml_file)
        else:
            G = graph_from_edges(args.edges)
    except ValueError as exc:
        print(f"Error: {exc}")
        sys.exit(1)

    host_set = None
    if args.hosts is not None:
        host_flags = [h.strip() for h in args.hosts.split(",") if h.strip()]
        host_set = {str(i) for i, h in enumerate(host_flags) if h != "0"}

    if args.spread_hosts:
        if host_set is None:
            print("Error: --spread-hosts requires --hosts", file=sys.stderr)
            sys.exit(1)
        host_nodes = sorted(host_set, key=int)
        core_nodes = sorted((n for n in G.nodes() if n not in host_set), key=int)
        G = spread_host_attachments(G, host_nodes, core_nodes,
                                    args.host_degree, args.augment_seed)
        print(
            f"[spread-hosts] host={host_nodes} attaccati a {args.host_degree} core "
            f"distinti; core={core_nodes}",
            file=sys.stderr,
        )
        # Densify only the core (never touch host uplinks).
        if args.augment_degree is not None:
            before = 2 * G.number_of_edges() / G.number_of_nodes()
            forbid_host = lambda u, v: (u in host_set or v in host_set)
            G = augment_graph(G, args.augment_degree, args.augment_seed,
                              args.max_degree, forbid_host)
            after = 2 * G.number_of_edges() / G.number_of_nodes()
            print(
                f"[augment-core] grado medio {before:.2f} -> {after:.2f} "
                f"(archi {G.number_of_edges()}, seed {args.augment_seed})",
                file=sys.stderr,
            )
    else:
        # 1) Densify first (so host nodes get well connected), 2) then strip
        # host-host edges, 3) DAGs are regenerated afterwards on the pruned graph.
        if args.augment_degree is not None:
            before = 2 * G.number_of_edges() / G.number_of_nodes()
            G = augment_graph(G, args.augment_degree, args.augment_seed,
                              args.max_degree)
            after = 2 * G.number_of_edges() / G.number_of_nodes()
            print(
                f"[augment] grado medio {before:.2f} -> {after:.2f} "
                f"(archi {G.number_of_edges()}, seed {args.augment_seed})",
                file=sys.stderr,
            )

        if args.no_host_host_edges:
            if host_set is None:
                print("Error: --no-host-host-edges requires --hosts", file=sys.stderr)
                sys.exit(1)
            is_hh = lambda u, v: (str(u) in host_set and str(v) in host_set)
            removed = [(u, v) for u, v in G.edges() if is_hh(u, v)]
            G.remove_edges_from(removed)
            after = 2 * G.number_of_edges() / G.number_of_nodes()
            print(
                f"[no-host-host] host nodes={sorted(host_set, key=int)}; "
                f"rimossi {len(removed)} archi host-host; grado medio -> {after:.2f}",
                file=sys.stderr,
            )

    edges_strs = []
    for e in G.edges:
        edges_strs.append(f"{e[0]},{e[1]}")

    dags = []
    for t in G.nodes:
        dag, dist = dag_to_target(G, t)

        succs = []
        for u in dag.nodes():
            succ = list(dag.successors(u))
            if succ:
                for s in succ:
                    succs.append(f"{u}-{s}")

        dag_str = f"{t}:" + (",".join(succs))
        dags.append(dag_str)

    n = G.number_of_nodes()
    if args.hosts is not None:
        hosts_str = args.hosts
        n_hosts = len([h for h in hosts_str.split(",") if h.strip()])
        if n_hosts != n:
            print(
                f"Error: --hosts has {n_hosts} entries but the graph has {n} nodes",
                file=sys.stderr,
            )
            sys.exit(1)
    else:
        hosts_str = ",".join(["1"] * n)

    edges_joined = ";".join(edges_strs)
    dags_joined = ";".join(dags)

    multi, total, avg_choices = branching_summary(G)
    print(
        f"[summary] nodi={n} archi={G.number_of_edges()} "
        f"grado_medio={2 * G.number_of_edges() / n:.2f} "
        f"switch_con_scelta_multipla={multi}/{total} "
        f"({(multi / total * 100 if total else 0):.0f}%) "
        f"next_hop_medi={avg_choices:.2f}",
        file=sys.stderr,
    )

    if args.out:
        with open(args.out, "w") as out_file:
            out_file.write(f'# Generated by parse_zoo.py (nodes={n})\n')
            out_file.write(f'EDGES="{edges_joined}"\n')
            out_file.write(f'DAGS="{dags_joined}"\n')
            out_file.write(f'HOSTS="{hosts_str}"\n')
            out_file.write(f'SWITCHES={n}\n')
        print(f"[out] scritto {args.out}", file=sys.stderr)
    else:
        print(
            f'DAGS="{dags_joined}" EDGES="{edges_joined}" '
            f'HOSTS="{hosts_str}" SWITCHES={n}'
        )
