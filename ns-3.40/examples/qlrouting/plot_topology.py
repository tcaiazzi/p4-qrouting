#!/usr/bin/env python3
"""
Visualize the physical topology and per-destination DAGs.

Edge / DAG format mirrors run-use-case.sh:
  EDGES  "u,v;u,v;..."            (undirected, semicolon-separated)
  DAGS   "dst:u-v,u-v,...;dst:..." (per-destination directed edges)

Usage examples
--------------
# Standalone
python3 plot_topology.py \
    --edges "0,1;0,10;0,2;1,10;2,9;2,10;3,4;3,6;4,5;4,6;5,6;5,8;6,7;6,8;7,8;7,9;7,10;8,9;9,10" \
    --dags  "0:1-0,10-0,10-1,2-0,2-10,..." \
    --hosts "1,1,1,1,1,0,0,0,0,0,0"

# Only show topology (no DAGs):
python3 plot_topology.py --edges "..." --no-dags

# Save to a custom directory:
python3 plot_topology.py --edges "..." --dags "..." --output-dir figures/topology
"""

import argparse
import math
import os

import matplotlib
matplotlib.use("Agg")          # headless – use TkAgg / Qt5Agg locally if you want interactive
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import networkx as nx


# ---------------------------------------------------------------------------
# Parsing helpers (same string formats as run-use-case.sh)
# ---------------------------------------------------------------------------

def parse_edges(edges_str: str) -> list[tuple[int, int]]:
    """'0,1;0,10;...' -> [(0,1),(0,10),...]"""
    edges = []
    for token in edges_str.strip().split(";"):
        token = token.strip()
        if not token:
            continue
        u, v = token.split(",")
        edges.append((int(u), int(v)))
    return edges


def parse_dags(dags_str: str) -> dict[int, list[tuple[int, int]]]:
    """'0:1-0,10-0,...;1:...' -> {0: [(1,0),(10,0),...], 1: [...], ...}"""
    dags: dict[int, list[tuple[int, int]]] = {}
    for entry in dags_str.strip().split(";"):
        entry = entry.strip()
        if not entry:
            continue
        dst_part, edges_part = entry.split(":", 1)
        dst = int(dst_part.strip())
        dag_edges = []
        for e in edges_part.split(","):
            e = e.strip()
            if not e:
                continue
            u, v = e.split("-")
            dag_edges.append((int(u), int(v)))
        dags[dst] = dag_edges
    return dags


def parse_hosts(hosts_str: str) -> list[int]:
    """'1,1,1,1,1,0,0,0,0,0,0' -> list of node indices that are protected-flow sources"""
    return [i for i, h in enumerate(hosts_str.split(",")) if h.strip() == "1"]


def parse_workload(path: str) -> tuple[list[tuple[int, int]], list[tuple[int, int]]]:
    """Parse a workload CSV (headerless) produced by generate_workloads_simple.py.

    Columns: src, dst, start, end, proto, dst_port, rate, pkt, data, nflow.
    Returns (protected_flows, congested_links):
      - protected_flows: (src, dst) for rows with dst_port == PROTECTED_PORT
      - congested_links: (u, v) for congestion events (dst_port >= 20000 and not
        one of the protected/probing ports); (u, v) is the flooded direction.
    """
    protected_flows: list[tuple[int, int]] = []
    congested_links: list[tuple[int, int]] = []
    with open(path) as fh:
        for raw in fh:
            line = raw.strip()
            if not line:
                continue
            parts = line.split(",")
            if len(parts) < 6:
                continue
            try:
                src, dst, port = int(parts[0]), int(parts[1]), int(parts[5])
            except ValueError:
                continue
            if port == PROTECTED_PORT:
                protected_flows.append((src, dst))
            elif port >= 20000 and port not in (PROTECTED_PORT, PROBING_PORT):
                congested_links.append((src, dst))
    return protected_flows, congested_links


def compute_port_map(edges: list[tuple[int, int]]) -> dict[tuple[int, int], int]:
    """
    Compute ns-3 port numbers for every directed (node, neighbour) pair.

    Port numbering mirrors qlr-utils.cc::createTopology:
      - Port 0 is the internal loopback / CPU port (unused externally).
      - Ports 1, 2, … are inter-switch links assigned in the order edges are
        processed by the PointToPointHelper loop.

    Returns {(u, v): port_at_u} for every undirected edge {u, v}.
    """
    next_port: dict[int, int] = {}  # node -> next free port (starts at 1)
    port_map: dict[tuple[int, int], int] = {}
    for u, v in edges:
        pu = next_port.setdefault(u, 1)
        pv = next_port.setdefault(v, 1)
        port_map[(u, v)] = pu
        port_map[(v, u)] = pv
        next_port[u] += 1
        next_port[v] += 1
    return port_map


def load_topology_file(path: str) -> dict[str, str]:
    """
    Read a KEY=value (or KEY="value") file and return a dict with keys
    EDGES, DAGS, HOSTS (whichever are present).  Shell-style: lines
    starting with '#' and blank lines are ignored; surrounding quotes
    are stripped from values.
    """
    recognised = {"EDGES", "DAGS", "HOSTS"}
    result: dict[str, str] = {}
    with open(path) as fh:
        for raw in fh:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                continue
            key, _, val = line.partition("=")
            key = key.strip()
            if key not in recognised:
                continue
            # Strip surrounding quotes (single or double)
            val = val.strip()
            if len(val) >= 2 and val[0] in ('"', "'") and val[-1] == val[0]:
                val = val[1:-1]
            result[key] = val
    return result


# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------

def build_layout(G: nx.Graph) -> dict[int, tuple[float, float]]:
    """Spring layout with a fixed seed for reproducibility."""
    return nx.spring_layout(G, seed=42, k=2.0 / math.sqrt(len(G)))


# ---------------------------------------------------------------------------
# Drawing helpers
# ---------------------------------------------------------------------------

NODE_REGULAR_COLOR = "#AED6F1"
NODE_PROT_COLOR    = "#A9DFBF"   # protected-flow source
NODE_DST_COLOR     = "#F9E79F"
EDGE_PHYS_COLOR    = "#BFC9CA"
DAG_EDGE_COLOR     = "#2980B9"
DAG_DST_EDGE_COLOR = "#E74C3C"   # last hop to destination
CONGESTED_LINK_COLOR = "#C0392B" # congested link (workload congestion event)
PORT_LABEL_COLOR   = "#5D4037"   # dark brown for port labels
PORT_LABEL_OFFSET  = 0.25        # fraction along edge from each endpoint

# Workload CSV port conventions (see generate_workloads_simple.py)
PROTECTED_PORT = 22222
PROBING_PORT   = 33333


def _draw_port_labels(
    ax,
    pos: dict[int, tuple[float, float]],
    port_map: dict[tuple[int, int], int],
    edges: list[tuple[int, int]],
    offset: float = PORT_LABEL_OFFSET,
) -> None:
    """Render 'p<N>' labels near each endpoint of every edge."""
    for u, v in edges:
        if (u, v) not in port_map or (v, u) not in port_map:
            continue
        xu, yu = pos[u]
        xv, yv = pos[v]
        # position for the u-side label
        lx_u = xu + offset * (xv - xu)
        ly_u = yu + offset * (yv - yu)
        # position for the v-side label
        lx_v = xv + offset * (xu - xv)
        ly_v = yv + offset * (yu - yv)
        ax.text(lx_u, ly_u, f"p{port_map[(u, v)]}",
                fontsize=6, color=PORT_LABEL_COLOR, ha="center", va="center",
                bbox=dict(boxstyle="round,pad=0.1", fc="white", ec="none", alpha=0.7))
        ax.text(lx_v, ly_v, f"p{port_map[(v, u)]}",
                fontsize=6, color=PORT_LABEL_COLOR, ha="center", va="center",
                bbox=dict(boxstyle="round,pad=0.1", fc="white", ec="none", alpha=0.7))


def _draw_topology(ax, G: nx.Graph, pos, prot_nodes: list[int],
                   highlighted_nodes: list[int] | None = None,
                   dag_edges: list[tuple[int, int]] | None = None,
                   dst: int | None = None,
                   dst_nodes: list[int] | None = None,
                   congested_links: list[tuple[int, int]] | None = None,
                   port_map: dict[tuple[int, int], int] | None = None,
                   title: str = ""):
    ax.set_title(title, fontsize=11, pad=8)
    ax.axis("off")

    # Destination node set (single `dst` for a per-destination panel, or a set
    # `dst_nodes` for the multi-destination overview).
    dst_set = set(dst_nodes) if dst_nodes is not None else (
        {dst} if dst is not None else set()
    )

    # Node colours
    node_colors = []
    for n in G.nodes():
        if n in dst_set:
            node_colors.append(NODE_DST_COLOR)
        elif n in prot_nodes:
            node_colors.append(NODE_PROT_COLOR)
        else:
            node_colors.append(NODE_REGULAR_COLOR)

    # Draw physical edges (undirected, grey)
    nx.draw_networkx_edges(
        G, pos, ax=ax,
        edge_color=EDGE_PHYS_COLOR,
        width=1.5,
        arrows=False,
    )

    # Draw DAG edges on top (directed, coloured)
    if dag_edges:
        last_hop = [(u, v) for (u, v) in dag_edges if v == dst]
        other    = [(u, v) for (u, v) in dag_edges if v != dst]

        if other:
            nx.draw_networkx_edges(
                G, pos, ax=ax,
                edgelist=other,
                edge_color=DAG_EDGE_COLOR,
                width=2.0,
                arrows=True,
                arrowstyle="-|>",
                arrowsize=14,
                connectionstyle="arc3,rad=0.08",
                min_source_margin=15,
                min_target_margin=15,
            )
        if last_hop:
            nx.draw_networkx_edges(
                G, pos, ax=ax,
                edgelist=last_hop,
                edge_color=DAG_DST_EDGE_COLOR,
                width=2.5,
                arrows=True,
                arrowstyle="-|>",
                arrowsize=16,
                connectionstyle="arc3,rad=0.08",
                min_source_margin=15,
                min_target_margin=15,
            )

    # Draw congested links on top of everything else (bold red arrows).
    if congested_links:
        present = [(u, v) for (u, v) in congested_links if G.has_edge(u, v)]
        if present:
            nx.draw_networkx_edges(
                G, pos, ax=ax,
                edgelist=present,
                edge_color=CONGESTED_LINK_COLOR,
                width=3.5,
                arrows=True,
                arrowstyle="-|>",
                arrowsize=18,
                connectionstyle="arc3,rad=0.08",
                min_source_margin=15,
                min_target_margin=15,
            )

    nx.draw_networkx_nodes(G, pos, ax=ax, node_color=node_colors,
                           node_size=600, linewidths=1.2, edgecolors="#5D6D7E")
    nx.draw_networkx_labels(G, pos, ax=ax, font_size=9, font_weight="bold")

    if port_map:
        _draw_port_labels(ax, pos, port_map, list(G.edges()))


# ---------------------------------------------------------------------------
# Figure: full topology
# ---------------------------------------------------------------------------

def plot_topology(G: nx.Graph, pos, prot_nodes: list[int], output_dir: str,
                  port_map: dict[tuple[int, int], int] | None = None):
    fig, ax = plt.subplots(figsize=(8, 6))
    _draw_topology(ax, G, pos, prot_nodes, port_map=port_map, title="Physical Topology")

    # Legend
    legend_handles = [
        mpatches.Patch(color=NODE_PROT_COLOR,    label="Protected-flow source"),
        mpatches.Patch(color=NODE_REGULAR_COLOR, label="Node"),
    ]
    if port_map:
        legend_handles.append(
            mpatches.Patch(color=PORT_LABEL_COLOR, label="ns-3 port number")
        )
    ax.legend(handles=legend_handles, loc="upper left", fontsize=9)

    out_path = os.path.join(output_dir, "topology.pdf")
    fig.savefig(out_path, bbox_inches="tight")
    plt.close(fig)
    print(f"  saved {out_path}")


# ---------------------------------------------------------------------------
# Figure: one DAG per destination
# ---------------------------------------------------------------------------

def plot_dags(G: nx.Graph, pos, prot_nodes: list[int],
              dags: dict[int, list[tuple[int, int]]],
              output_dir: str,
              port_map: dict[tuple[int, int], int] | None = None):
    dsts = sorted(dags.keys())
    n = len(dsts)
    if n == 0:
        return

    # ---- individual per-destination PDF ----
    for dst in dsts:
        dag_edges = dags[dst]
        fig, ax = plt.subplots(figsize=(7, 5))
        _draw_topology(
            ax, G, pos, prot_nodes,
            dag_edges=dag_edges,
            dst=dst,
            port_map=port_map,
            title=f"DAG  →  destination {dst}",
        )
        legend_handles = [
            mpatches.Patch(color=NODE_DST_COLOR,     label=f"Destination ({dst})"),
            mpatches.Patch(color=NODE_PROT_COLOR,    label="Protected-flow source"),
            mpatches.Patch(color=NODE_REGULAR_COLOR, label="Node"),
            mpatches.Patch(color=DAG_EDGE_COLOR,     label="DAG edge"),
            mpatches.Patch(color=DAG_DST_EDGE_COLOR, label="DAG last-hop edge"),
            mpatches.Patch(color=EDGE_PHYS_COLOR,    label="Physical edge"),
        ]
        if port_map:
            legend_handles.append(
                mpatches.Patch(color=PORT_LABEL_COLOR, label="ns-3 port number")
            )
        ax.legend(handles=legend_handles, loc="upper left", fontsize=8)
        out_path = os.path.join(output_dir, f"dag_dst{dst}.pdf")
        fig.savefig(out_path, bbox_inches="tight")
        plt.close(fig)
        print(f"  saved {out_path}")

    # ---- combined grid figure ----
    cols = min(4, n)
    rows = math.ceil(n / cols)
    fig, axes = plt.subplots(rows, cols, figsize=(cols * 5, rows * 4))
    axes_flat = [axes] if n == 1 else (axes.flat if rows > 1 else list(axes))

    for idx, dst in enumerate(dsts):
        ax = axes_flat[idx]
        _draw_topology(
            ax, G, pos, prot_nodes,
            dag_edges=dags[dst],
            dst=dst,
            port_map=port_map,
            title=f"dst={dst}",
        )

    # hide unused subplots
    for idx in range(n, rows * cols):
        axes_flat[idx].set_visible(False)

    fig.suptitle("All DAGs", fontsize=13, y=1.01)
    fig.tight_layout()
    out_path = os.path.join(output_dir, "dags_all.pdf")
    fig.savefig(out_path, bbox_inches="tight")
    plt.close(fig)
    print(f"  saved {out_path}")


# ---------------------------------------------------------------------------
# Figure: one experiment (protected flows + congested links from a workload)
# ---------------------------------------------------------------------------

def plot_experiment(G: nx.Graph, pos,
                    protected_flows: list[tuple[int, int]],
                    congested_links: list[tuple[int, int]],
                    dags: dict[int, list[tuple[int, int]]],
                    output_dir: str, prefix: str,
                    port_map: dict[tuple[int, int], int] | None = None):
    """Render, for one experiment (topology + workload):
      - an overview: physical topology with protected sources (green),
        protected destinations (blue) and congested links (red);
      - one panel per protected destination: its routing DAG plus the congested
        links that lie on that DAG.
    """
    src_nodes = sorted({s for s, _ in protected_flows})
    dst_nodes = sorted({d for _, d in protected_flows})

    # ---- overview ----
    fig, ax = plt.subplots(figsize=(9, 7))
    _draw_topology(
        ax, G, pos, prot_nodes=src_nodes, dst_nodes=dst_nodes,
        congested_links=congested_links, port_map=port_map,
        title=f"{prefix}  —  overview",
    )
    ax.legend(handles=[
        mpatches.Patch(color=NODE_PROT_COLOR,       label="Protected source"),
        mpatches.Patch(color=NODE_DST_COLOR,        label="Protected destination"),
        mpatches.Patch(color=CONGESTED_LINK_COLOR,  label="Congested link"),
        mpatches.Patch(color=EDGE_PHYS_COLOR,       label="Physical edge"),
    ], loc="upper left", fontsize=9)
    out_path = os.path.join(output_dir, f"{prefix}_overview.pdf")
    fig.savefig(out_path, bbox_inches="tight")
    plt.close(fig)
    print(f"  saved {out_path}")

    # ---- one panel per protected destination ----
    dag_edge_set = {d: set(edges) for d, edges in dags.items()}
    for dst in dst_nodes:
        srcs_for_dst = sorted({s for s, d in protected_flows if d == dst})
        dag_edges = dags.get(dst, [])
        if not dag_edges:
            print(f"  WARNING: no DAG for destination {dst}; panel will omit paths")
        cong_on_dag = [
            (u, v) for (u, v) in congested_links
            if (u, v) in dag_edge_set.get(dst, set())
        ]
        fig, ax = plt.subplots(figsize=(8, 6))
        _draw_topology(
            ax, G, pos, prot_nodes=srcs_for_dst,
            dag_edges=dag_edges, dst=dst,
            congested_links=cong_on_dag, port_map=port_map,
            title=f"{prefix}  —  destination {dst}",
        )
        ax.legend(handles=[
            mpatches.Patch(color=NODE_DST_COLOR,       label=f"Destination ({dst})"),
            mpatches.Patch(color=NODE_PROT_COLOR,      label="Protected source"),
            mpatches.Patch(color=DAG_EDGE_COLOR,       label="DAG edge"),
            mpatches.Patch(color=DAG_DST_EDGE_COLOR,   label="DAG last-hop"),
            mpatches.Patch(color=CONGESTED_LINK_COLOR, label="Congested link"),
        ], loc="upper left", fontsize=8)
        out_path = os.path.join(output_dir, f"{prefix}_dag_dst{dst}.pdf")
        fig.savefig(out_path, bbox_inches="tight")
        plt.close(fig)
        print(f"  saved {out_path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Visualize topology and per-destination DAGs."
    )
    parser.add_argument(
        "--topology-file", default="",
        help=(
            "Path to a KEY=value file with EDGES, DAGS, HOSTS "
            "(same variable names and format as run-use-case.sh). "
            "CLI flags override values from the file."
        ),
    )
    parser.add_argument(
        "--edges", default="",
        help='Undirected edges: "u,v;u,v;..." (same format as run-use-case.sh EDGES)',
    )
    parser.add_argument(
        "--dags", default="",
        help='Per-destination DAGs: "dst:u-v,u-v,...;dst:..." (same as DAGS in run-use-case.sh)',
    )
    parser.add_argument(
        "--hosts", default="",
        help='Comma-separated 0/1 vector marking protected-flow source nodes, e.g. "1,1,1,1,1,0,0,0,0,0,0"',
    )
    parser.add_argument(
        "--workload-file", default="",
        help=(
            "Path to an experiment workload CSV (as generated by "
            "generate_workloads_simple.py). If given, renders an experiment "
            "figure: protected sources/destinations, DAG paths and congested links."
        ),
    )
    parser.add_argument(
        "--output-dir", default="figures/topology",
        help=(
            "Base directory for figures. A subfolder named after the topology "
            "(e.g. 'abilene-dense') is created inside it."
        ),
    )
    parser.add_argument(
        "--no-dags", action="store_true",
        help="Skip DAG plots (topology only).",
    )
    args = parser.parse_args()

    # ---- resolve values: file first, then CLI overrides ----
    file_vals: dict[str, str] = {}
    if args.topology_file:
        file_vals = load_topology_file(args.topology_file)
        print(f"Loaded topology file: {args.topology_file} (keys: {sorted(file_vals)})")

    edges_str = args.edges or file_vals.get("EDGES", "")
    dags_str  = args.dags  or file_vals.get("DAGS",  "")
    hosts_str = args.hosts or file_vals.get("HOSTS", "")

    if not edges_str:
        parser.error("EDGES must be provided via --edges or --topology-file")

    # Figures go into a subfolder named after the topology.
    if args.topology_file:
        topo_name = os.path.splitext(os.path.basename(args.topology_file))[0]
    else:
        topo_name = "topology"
    output_dir = os.path.join(args.output_dir, topo_name)
    os.makedirs(output_dir, exist_ok=True)
    print(f"Output directory: {output_dir}")

    # Build undirected graph
    edges = parse_edges(edges_str)
    G = nx.Graph()
    G.add_edges_from(edges)

    host_nodes = parse_hosts(hosts_str) if hosts_str else []
    prot_nodes = host_nodes
    pos = build_layout(G)

    print(f"Topology: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")

    # Port map (computed from edge order, mirrors ns-3 qlr-utils.cc port assignment)
    port_map = compute_port_map(edges)

    dags = parse_dags(dags_str) if dags_str else {}

    if args.workload_file:
        # Experiment figure: protected sources/destinations, DAG paths, congested links.
        protected_flows, congested_links = parse_workload(args.workload_file)
        prefix = os.path.splitext(os.path.basename(args.workload_file))[0]
        print(f"Workload: {args.workload_file}")
        print(f"  protected flows: {protected_flows}")
        print(f"  congested links: {congested_links}")
        plot_experiment(G, pos, protected_flows, congested_links, dags,
                        output_dir, prefix, port_map=port_map)
    else:
        if prot_nodes:
            print(f"Protected-flow source nodes: {prot_nodes}")
        # Topology figure
        plot_topology(G, pos, prot_nodes, output_dir, port_map=port_map)
        # DAG figures
        if not args.no_dags and dags:
            print(f"DAGs: {len(dags)} destinations ({sorted(dags.keys())})")
            plot_dags(G, pos, prot_nodes, dags, output_dir, port_map=port_map)

    print("Done.")


if __name__ == "__main__":
    main()
