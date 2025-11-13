import ipaddress
import os
import sys
import struct

import networkx as nx

qlr_port = 22222
default_port = 20000


def generate_node_commands_from_dag(node_dag: nx.DiGraph, net: dict, start: int, goal: int) -> list[str]:
    cmd = []
    row_slices = [127] * 8
    print("Generating commands for node:", start, "to goal:", goal)
    # print(f"Node {start} neighbors:", net[start])

    print("Initial Slices:", row_slices)
    for e in node_dag.edges:
        # print(f"Processing edge: {e}")
        if start == e[0]:
            iface_num = net[start][e[1]]
            row_slices[iface_num] = 1

    print("Updated Slices after neighbors:", row_slices)
    # print("Row slices:", row_slices)
    for i, row_slice in enumerate(row_slices):
        if row_slice < 6:
            cmd.append(f"table_add select_port_from_row_col set_nhop {goal + 1} {i} => {i + 1}")

    row_slices.reverse()
    packed_bytes = struct.pack(">" + ("B" * len(row_slices)), *row_slices)
    print("Packed bytes for goal", goal, ":", packed_bytes)

    cmd.append(f"register_write row{goal + 1} 0 {int.from_bytes(packed_bytes, byteorder='big')}")

    return cmd


def generate_all_commands(network: dict, dags: dict, subnets):
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

                            # print(f"node_name={node_name}", f"dst={dst}", f"update={update_node}", f"edge={edge}", f"iface={iface}")

                            dst_iface_to_headers[dst][iface].add(str(update_node + 1))

        for dst, iface_to_headers in dst_iface_to_headers.items():
            for iface, headers_to_activate in iface_to_headers.items():
                if headers_to_activate:
                    headers_to_activate = sorted(list(headers_to_activate))

                    commands.add(f"table_add qlr_pkt_updates qlr_pkt_set_" + "_".join(
                        headers_to_activate) + f" {dst + 1} {iface + 1} => ")

        ports = list(network[node_name].values())
        for i, (node, subnet) in enumerate(filter(lambda x: x[0] != node_name, node_to_network.items())):
            port_num =  network[node_name][nx.shortest_path(network_graph, source=node_name, target=node)[1]]
            if qlr_active:
                commands.add(f"table_add select_row get_row_num {subnet} 6 => {node + 1}")
                if node in network[node_name]:
                    commands.add(f"table_add handle_update send_probe {subnet} 17 33333 0 => {port_num + 1} {node + 1}")
                    commands.add(f"table_add handle_update process_probe {node_to_network[node_name]} 17 33333 1 =>")
            else:
                commands.add(f"table_add select_row set_nhop {subnet} 6 => {port_num + 1}")

            commands.add(f"table_add select_row set_nhop {subnet} 17 => {port_num + 1}")

        max_iface = max(network[node_name].values()) + 1
        commands.add(f"table_set_default select_row set_nhop 1")

        for iface in network[node_name].values():
            commands.add(f"table_add read_ig_qdepth get_ig_qdepth_and_idx {iface + 1} => {iface}")
            commands.add(f"register_write ig_qdepth {iface} 1")

        commands_path = os.path.join(dst_path, f"s{node_name + 1}.txt")
        with open(commands_path, "w") as f:
            f.write("\n".join(sorted(list(commands))))


import argparse
import ipaddress
import os
import sys
import networkx as nx

def parse_edges_from_string(edges_str):
    """
    Parse edges from string format: "0,1;0,2;1,2;1,3;2,3;2,4;3,4"
    Returns a list of tuples: [(0,1), (0,2), ...]
    """
    edges = []
    edge_pairs = edges_str.split(';')
    for pair in edge_pairs:
        node1, node2 = pair.split(',')
        edges.append((int(node1), int(node2)))
    return edges

def edges_to_network(edges):
    """
    Convert edge list to network dictionary with port assignments
    """
    network = {}

    # Build adjacency information
    for src, dst in edges:
        if src not in network:
            network[src] = {}
        if dst not in network:
            network[dst] = {}

    # Assign ports (incrementally for each node)
    for src, dst in edges:
        # Assign port for src->dst
        if dst not in network[src]:
            network[src][dst] = len(network[src]) + 1
        # Assign port for dst->src (bidirectional)
        if src not in network[dst]:
            network[dst][src] = len(network[dst]) + 1

    return network

def parse_host_vector(host_vector_str):
    """
    Parse host vector from string format: "1,1,1,1,1"
    Returns a list of integers
    """
    return [int(x) for x in host_vector_str.split(',')]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Generate P4 commands for QLR routing'
    )

    parser.add_argument('dst_path', type=str, help='Destination path for generated files')
    parser.add_argument('qlr_active', type=int, choices=[0, 1], help='QLR active flag (0 or 1)')

    parser.add_argument(
        '--edges',
        type=str,
        required=True,
        help='Edge list as pairs of node IDs (format: 0,1;0,2;1,2;...)'
    )

    parser.add_argument(
        '--host-vector',
        type=str,
        required=True,
        help='Host vector for each switch (format: 1,1,1,1,1)'
    )

    parser.add_argument(
        '--dags',
        required=True,
        type=str,
        help='DAGs string (format: "0:1-0,2-0,3-1;1:0-1,2-0,2-1;...").'
    )

    args = parser.parse_args()

    dst_path = os.path.abspath(args.dst_path)
    qlr_active = bool(args.qlr_active)

    os.makedirs(dst_path, exist_ok=True)

    print(f"Destination path: {dst_path}")
    print(f"QLR active: {qlr_active}")
    print(f"Edges: {args.edges}")
    print(f"Host vector: {args.host_vector}")

    # Parse topology from edges
    edges = parse_edges_from_string(args.edges)
    network = edges_to_network(edges)
    host_vector = parse_host_vector(args.host_vector)

    network_graph = nx.Graph()
    network_graph.add_edges_from(edges)

    print("Parsed network graph edges:", network_graph.edges)
    print("Parsed network graph nodes:", network_graph.nodes)

    print(f"Parsed network: {network}")
    print(f"Parsed host vector: {host_vector}")

    # Parse or create DAGs

    # Parse DAGs from command line
    dags = {k: nx.DiGraph() for k in network}
    dag_entries = args.dags.split(';')
    for entry in dag_entries:
        dst_str, edges_str = entry.split(':')
        dst = int(dst_str)

        dags[dst].add_nodes_from(network.keys())

        if edges_str.strip():
            dag_edges = []
            for edge_entry in edges_str.split(','):
                src, dest = edge_entry.split('-')
                dag_edges.append((int(src), int(dest)))
            dags[dst].add_edges_from(dag_edges)

    subnets = ipaddress.ip_network("10.0.0.0/16").subnets(prefixlen_diff=8)
    next(subnets)

    generate_all_commands(network, dags, subnets)
