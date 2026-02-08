import sys

import networkx as nx


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


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: parse_zoo.py <file>")
        exit(1)

    path = sys.argv[1]

    G = nx.read_graphml(path)

    edges_strs = []
    for e in G.edges:
        edges_strs.append(f"{e[0]},{e[1]}")

    dags = []
    for t in G.nodes:
        dag, dist = dag_to_target_with_slack(G, t, k=2)

        succs = []
        for u in dag.nodes():
            succ = list(dag.successors(u))
            if succ:
                for s in succ:
                    succs.append(f"{u}-{s}")

        dag_str = f"{t}:" + (",".join(succs))
        dags.append(dag_str)
    
    print("DAGS=\"" + ";".join(dags) + "\" EDGES=\"" + ";".join(edges_strs) + "\" HOSTS=\"" + ",".join(["1"] * G.number_of_nodes()) + f"\" SWITCHES={G.number_of_nodes()}")
