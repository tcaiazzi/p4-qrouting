import struct

import networkx as nx
import matplotlib.pyplot as plt

def generate_node_commands_from_dag(dag: nx.DiGraph, node, goal):
    commands = []
    row_slice = [0, 0, 0, 0, 0, 0, 0, 0]
    for edge in dag.edges:
        if node == edge[0]:
            iface_num = nodes[node][edge[1]]
            row_slice[iface_num] = 1
    
    for i, slice in enumerate(row_slice): 
        if slice > 0:
            commands.append(f"table_add select_port_from_row_col set_nhop {goal} {i} => {i+1}")

    row_slice.reverse()
    packed_bytes = struct.pack(">" + ("B" * len(row_slice)), *row_slice)

    commands.append(f"register_write IngressPipe.row{goal+1} 0 {int.from_bytes(packed_bytes)}")
    return commands   


if __name__ == "__main__":
    nodes = {
        0: { 1: 0, 2: 1 },
        1: { 0: 0, 2: 1, 3: 2 },
        2: { 0: 0, 1: 1, 3: 2, 4: 3},
        3: { 1: 0, 2: 1, 4: 2},
        4: { 3: 0, 2: 1},
    }

    dags = {}

    dag0 = nx.DiGraph()
    dag0.add_nodes_from(nodes.keys())
    edges = [(3, 1), (3, 4), (4, 2), (1, 0), (2, 0)]
    dag0.add_edges_from(edges)
    dags[0] = dag0

    dag1 = nx.DiGraph()
    dag1.add_nodes_from(nodes.keys())
    edges = [(0, 1), (2, 0), (2, 1), (4, 2), (3, 1), (3, 4)]
    dag1.add_edges_from(edges)
    dags[1] = dag1

    dag3 = nx.DiGraph()
    dag3.add_nodes_from(nodes.keys())
    edges = [(0, 1), (1, 3), (3, 2), (3, 4), (2, 4)]
    dag3.add_edges_from(edges)
    dags[3] = dag3

    #Commands for B
    commands = []
    commands.extend(generate_node_commands_from_dag(dag0, 1, 0))
    #commands.extend(generate_node_commands_from_dag(dag1, 1, 1))
    commands.extend(generate_node_commands_from_dag(dag3, 1, 3))

    node_name = 1
    for dst in dags.keys(): 
        if dst == node_name: 
            continue
        for update_node, dag in dags.items():
            if dst == update_node: 
                continue
            headers_to_activate = set()
            for edge in dag.edges: 
                if edge[1] == node_name:
                    headers_to_activate.add(str(update_node + 1))
        headers_to_activate = sorted(list(headers_to_activate))
        command = f"table_add qlr_pkt_updates {dst + 1} => qlr_pkt_set_" + "_".join(headers_to_activate)
        print(command)

    print(commands)
    
    # plt.figure(figsize=(6, 4))
    # pos = nx.kamada_kawai_layout(dag1)  # Kamada-Kawai layout to minimize edge crossings

    # nx.draw(dag1, pos=pos, with_labels=True, node_color='lightblue', edge_color='red', node_size=2000, font_size=12)
    # plt.title("NetworkX Undirected Graph Representation")
    # plt.savefig("network.pdf")
