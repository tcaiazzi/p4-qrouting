import ipaddress
import struct
import os

import networkx as nx


def generate_node_commands_from_dag(node_dag: nx.DiGraph, net: dict, start: int, goal: int) -> list[str]:
    cmd = []
    row_slices = [0, 0, 0, 0, 0, 0, 0, 0]
    for e in node_dag.edges:
        if start == e[0]:
            iface_num = net[start][e[1]]
            row_slices[iface_num] = 1

    for i, row_slice in enumerate(row_slices):
        if row_slice > 0:
            cmd.append(f"table_add select_port_from_row_col set_nhop {goal + 1} {i} => {i + 1}")

    row_slices.reverse()
    packed_bytes = struct.pack(">" + ("B" * len(row_slices)), *row_slices)

    cmd.append(f"register_write row{goal + 1} 0 {int.from_bytes(packed_bytes)}")

    return cmd


if __name__ == "__main__":
    network = {
        0: {1: 0, 2: 1},
        1: {0: 0, 2: 1, 3: 2},
        2: {0: 0, 1: 1, 3: 2, 4: 3},
        3: {1: 0, 2: 1, 4: 2},
        4: {3: 0, 2: 1},
    }

    dags = {k: nx.DiGraph() for k in network}

    dags[0].add_nodes_from(network.keys())
    dags[0].add_edges_from([(3, 1), (3, 4), (4, 2), (1, 0), (2, 0)])

    dags[1].add_nodes_from(network.keys())
    dags[1].add_edges_from([(0, 1), (2, 0), (2, 1), (4, 2), (3, 1), (3, 4)])

    dags[2].add_nodes_from(network.keys())
    dags[2].add_edges_from([(0, 1), (0, 2), (1, 2), (1, 3), (3, 2), (4, 2), (4, 3)])

    dags[3].add_nodes_from(network.keys())
    dags[3].add_edges_from([(0, 1), (0, 2), (1, 3), (2, 4), (2, 3), (4, 3)])

    dags[4].add_nodes_from(network.keys())
    dags[4].add_edges_from([(0, 1), (1, 3), (3, 2), (3, 4), (2, 4)])
    
    subnets = ipaddress.ip_network("10.0.0.0/16").subnets(prefixlen_diff=8)
    node_to_network = {k: next(subnets) for k in network}
    
    for node_name in network:
        commands = set()
        for tgt in network:
            if node_name == tgt:
                continue

            tgt_commands = generate_node_commands_from_dag(dags[tgt], network, node_name, tgt)
            commands.update(tgt_commands)

        dst_iface_to_headers = {}
        for dst in network:
            if dst == node_name:
                continue

            paths = list(nx.all_simple_paths(dags[dst], source=node_name, target=dst))
            neighbors = set(map(lambda x: x[1], paths))
            # print(f"node_name={node_name}", f"dst={dst}", f"neighbors={neighbors}")
            for neighbor in neighbors:
                # print(f"Processing neighbor: {neighbor}")
                headers_to_activate = set()
                for update_node, dag in dags.items():
                    if dst == update_node:
                        continue
                    for edge in dag.edges:
                        if edge[1] == node_name and edge[0] == neighbor:
                            if dst not in dst_iface_to_headers:
                                dst_iface_to_headers[dst] = {}

                            iface = network[node_name][edge[0]]
                            if iface not in dst_iface_to_headers[dst]:
                                dst_iface_to_headers[dst][iface] = set()

                            print(f"node_name={node_name}", f"dst={dst}", f"update={update_node}", f"edge={edge}", f"iface={iface}")

                            dst_iface_to_headers[dst][iface].add(str(update_node + 1))

        for dst, iface_to_headers in dst_iface_to_headers.items():
            for iface, headers_to_activate in iface_to_headers.items():
                if headers_to_activate:
                    headers_to_activate = sorted(list(headers_to_activate))

                    commands.add(f"table_add qlr_pkt_updates qlr_pkt_set_" + "_".join(headers_to_activate) + f" {dst + 1} {iface + 1} => ")

        for node, subnet in node_to_network.items():
            if node == node_name:
                continue
            commands.add(f"table_add select_row get_row_num {subnet} => {node + 1}")
        max_iface = max(network[node_name].values()) + 1
        commands.add(f"table_set_default select_row set_nhop_and_clear_qlr {max_iface + 1}")

        for iface in network[node_name].values():
            commands.add(f"table_add read_ig_qdepth get_ig_qdepth_and_idx {iface + 1} => {iface}")

        commands_path = os.path.join("emulator", "lab", f"s{node_name + 1}", "commands.txt")
        with open(commands_path, "w") as f: 
            f.write("\n".join(sorted(list(commands))))
