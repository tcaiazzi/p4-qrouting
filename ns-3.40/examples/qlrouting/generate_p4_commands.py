import argparse
import ipaddress
from math import floor
import os
import sys
import struct

import networkx as nx

qlr_port = 22222
default_port = 20000


colors = [1, 2, 3, 4]
buffer_size = 64_000_000
row_slice_size = 64_000_000 / 4
max_congestion = 256


def generate_node_commands_from_dag(node_dag: nx.DiGraph, net: dict, start: int, goal: int) -> list[str]:
    cmd = []
    row_slices = [32] * 8
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
        if qlr_active and row_slice < 6:
            cmd.append(f"table_add select_port_from_row_col set_nhop {goal + 1} {i} => {i + 1}")

    row_slices.reverse()
    packed_bytes = struct.pack(">" + ("B" * len(row_slices)), *row_slices)
    print("Packed bytes for goal", goal, ":", packed_bytes)

    cmd.append(f"register_write row{goal + 1} 0 {int.from_bytes(packed_bytes, byteorder='big')}")

    return cmd


def generate_all_commands(network: dict, dags: dict, subnets):
    node_to_network = {}
    all_node_to_network = {}
    
    for k in sorted(network, key=lambda x: int(x)):
        subnet = next(subnets)
        if k in dags:
            node_to_network[k] = subnet
        all_node_to_network[k] = subnet

    for node_name in network:
        commands = set()
        # Record this switch's topology node id so P4 log_msg can identify it.
        commands.add(f"register_write node_id_reg 0 {int(node_name)}")
        for tgt in network:
            if node_name == tgt:
                continue
            if tgt not in dags:
                continue

            tgt_commands = generate_node_commands_from_dag(dags[tgt], network, node_name, tgt)
            commands.update(tgt_commands)

        if qlr_active:
            # Probes are 1-hop: this node sends a probe to EACH neighbor Y. On the
            # probe to Y we advertise this node's Q for the destinations D that Y
            # routes THROUGH this node -- i.e. (Y -> node_name) is an edge in D's
            # DAG. The table is keyed on the probe's 1-hop destination (row_num =
            # Y+1) and the egress toward Y, so EVERY neighbor probe (host AND core)
            # matches -> the qlr_pkt_set action sets ecn[0]=1 -> the receiver's
            # parser extracts the update headers and refreshes its Q-matrix.
            #
            # Previously this was keyed on the host destination, so probes toward
            # core neighbors (row_num >= 6) never matched, the ecn flag stayed 0,
            # the parser skipped the updates, and cores never learned any Q.
            neighbor_to_dest_rows = {}
            for dst, dag in dags.items():
                for edge in dag.edges:
                    if edge[1] == node_name:            # (neighbor -> node_name) in dag[dst]
                        neighbor = edge[0]
                        neighbor_to_dest_rows.setdefault(neighbor, set()).add(dst + 1)

            for neighbor, dest_rows in neighbor_to_dest_rows.items():
                headers = "_".join(str(r) for r in sorted(dest_rows))
                port = network[node_name][neighbor]
                commands.add(
                    f"table_add qlr_pkt_updates qlr_pkt_set_{headers} "
                    f"{neighbor + 1} {port + 1} => "
                )

            for iface in network[node_name].values():
                commands.add(f"table_add read_ig_qdepth get_ig_qdepth_and_idx {iface + 1} => {iface}")
                commands.add(f"register_write ig_qdepth {iface} 1")

        for (node, subnet) in filter(lambda x: x[0] != node_name, node_to_network.items()):
            port_num =  network[node_name][nx.shortest_path(network_graph, source=node_name, target=node)[1]]
            if qlr_active:
                commands.add(f"table_add select_row get_row_num {subnet} 6 => {node + 1}")
            else:
                commands.add(f"table_add select_row set_nhop {subnet} 6 => {port_num + 1}")


        commands.add(f"table_set_default select_row set_nhop 1")
        for (node, subnet) in filter(lambda x: x[0] != node_name, all_node_to_network.items()):
            port_num =  network[node_name][nx.shortest_path(network_graph, source=node_name, target=node)[1]]
            if qlr_active and node in network[node_name]:
                commands.add(f"table_add handle_update send_probe {subnet} 17 33333 0 => {port_num + 1} {node + 1}")
                commands.add(f"table_add handle_update process_probe {all_node_to_network[node_name]} 17 33333 1 =>")
            commands.add(f"table_add select_row set_nhop {subnet} 17 => {port_num + 1}")

        if qlr_active:
            color_weights = {}
            for destination, dag in dags.items():
                if int(node_name) == int(destination):
                    continue
                print(f"Generating weights for node {node_name} to destination {destination}")
                longest_path_length = nx.dag_longest_path_length(dag)
                node_congestion = floor(max_congestion/longest_path_length)
                for i, color in enumerate(colors):
                    if color not in color_weights:
                        color_weights[color] = []
                    if color == 1: 
                        color_weights[color].append(1)
                        continue
                    color_weight = floor(((row_slice_size * color)*node_congestion)/buffer_size)
                    print(f"Color {color} weight for node {node_name} to destination {destination}: {color_weight}")
                    color_weights[color].append(color_weight)

            for color, weights in color_weights.items():
                weights_bit_string = [0]*8
                print(int("".join(map(str, weights))))

                for i, weight in enumerate(weights):
                    weights_bit_string[i] = weight

                print(f"Bit string for color {color} weights:", weights_bit_string)
                weights_bit_string.reverse()

                packed_bytes = struct.pack(">" + ("B" * len(weights_bit_string)), *weights_bit_string)
                commands.add(f"table_add compute_weights get_weights_string {color} => {int.from_bytes(packed_bytes, byteorder='big')}")
                # commands.add(f"table_add compute_weights get_weights_string {destination + 1} {color} => {weights[i]}")
                    # 


        commands_path = os.path.join(dst_path, f"s{node_name + 1}.txt")
        with open(commands_path, "w") as f:
            f.write("\n".join(sorted(list(commands))))

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

    dags = {k: nx.DiGraph() for k in network if host_vector[k] == 1}
    dag_entries = args.dags.split(';')
    for entry in dag_entries:
        dst_str, edges_str = entry.split(':')
        dst = int(dst_str)
        if host_vector[dst] == 0:
            continue

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
