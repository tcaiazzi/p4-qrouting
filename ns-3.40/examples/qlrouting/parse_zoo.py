import argparse
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
    args = parser.parse_args()

    return args.graphml_file, args.edges


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
    graphml_file, edges_arg = parse_arguments()

    try:
        if graphml_file:
            G = nx.read_graphml(graphml_file)
        else:
            G = graph_from_edges(edges_arg)
    except ValueError as exc:
        print(f"Error: {exc}")
        sys.exit(1)

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
    
    print("DAGS=\"" + ";".join(dags) + "\" EDGES=\"" + ";".join(edges_strs) + "\" HOSTS=\"" + ",".join(["1"] * G.number_of_nodes()) + f"\" SWITCHES={G.number_of_nodes()}")
