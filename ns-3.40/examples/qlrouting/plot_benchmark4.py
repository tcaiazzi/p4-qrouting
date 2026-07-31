import os

import matplotlib.pyplot as plt

import paper_plot
import plot_topology

EDGES = "0,1;0,2;1,2"
DAGS = "0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2"
HOSTS = "1,1,1"


def plot_switch_port_throughput_figure(base_path, figure_name, schemes, congestion_points=None):
    """Throughput of switch ports s1-1 and s2-1 (the two candidate links), one
    subplot per port, overlaying every scheme so a flapping route shows up as
    an oscillating throughput trace on one port and its mirror on the other.
    """
    ports = [("s1-1", "s1 port 1"), ("s2-1", "s2 port 1")]

    fig, axes = plt.subplots(len(ports), 1, sharex=True, figsize=(5, 4))

    for ax, (port_file, port_label) in zip(axes, ports):
        ax.grid(linestyle="--", linewidth=0.5)
        for experiment_type, colors, marker, label, linestyle in schemes:
            file_path = os.path.join(base_path, experiment_type, "0", "throughput", f"{port_file}.tp")
            if not os.path.exists(file_path):
                continue
            data = paper_plot.parse_data_file(file_path)
            ax.plot(
                data["x"],
                [y / 1e6 for y in data["y"]],
                label=label,
                color=colors[0],
                linestyle=linestyle,
                marker=marker,
            )
        paper_plot._draw_congestion_regions(ax, congestion_points)
        ax.set_ylabel(f"{port_label}\nThroughput [Mbps]", fontsize=10)
        ax.tick_params(axis="both", which="major", labelsize=10)

    axes[-1].set_xlabel("Time [s]", fontsize=12)

    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", bbox_to_anchor=(0.5, 1.05), ncol=2, fontsize=10)

    plt.savefig(
        os.path.join(paper_plot.figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def main():
    results_path = "results"
    paper_plot.figures_path = os.path.join("benchmark_figures", "benchmark4")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    workloads = [
        ("wl3", [(2.0, 2.2)]),
    ]

    schemes = [
        ("qlr", ["green", "darkgreen"], None, "QLR", "-"),
        ("qlr_no_hysteresis", ["orange", "darkorange"], None, "QLR (no hysteresis)", "--"),
    ]

    for congestion_control in ["TcpLinuxReno"]:
        for wl, congestions in workloads:
            base_path = os.path.join(results_path, f"benchmark4_{congestion_control}_{wl}")

            plot_topology.generate_topology_figures(
                EDGES, DAGS, HOSTS,
                output_dir=os.path.join(paper_plot.figures_path, "topology"),
                workload_file=os.path.join("resources", "benchmark_4", "workloads", f"{wl}.csv"),
            )

            paper_plot.plot_throughput_subplots_figure(
                base_path,
                f"benchmark4-throughput-subplots-{congestion_control}-{wl}",
                congestion_points=congestions,
                schemes=schemes,
            )

            plot_switch_port_throughput_figure(
                base_path,
                f"benchmark4-switch-port-throughput-{congestion_control}-{wl}",
                schemes,
                congestion_points=congestions,
            )

            flow_info = [
                (
                    22222,
                    "QLR",
                    "green",
                    "-",
                    os.path.join(base_path, "qlr/0/flow_monitor.xml"),
                ),
                (
                    22222,
                    "QLR (no hysteresis)",
                    "orange",
                    "--",
                    os.path.join(base_path, "qlr_no_hysteresis/0/flow_monitor.xml"),
                ),
            ]

            paper_plot.plot_delay_cdf_figure(
                base_path,
                flow_info,
                f"benchmark4-delay-cdf-{congestion_control}-{wl}",
                ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001),
            )

            paper_plot.plot_jitter_cdf_figure(
                base_path,
                flow_info,
                f"benchmark4-jitter-cdf-{congestion_control}-{wl}",
                ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001),
            )

            paper_plot.plot_ipg_cdf_per_experiment(
                base_path,
                flow_info,
                f"benchmark4-ipg-cdf-{congestion_control}-{wl}",
                ylim=(0.993, 1.0003),
                xlim=(0.03, 1000),
            )

            paper_plot.plot_throughput_delay_ipg_figure(
                base_path,
                f"benchmark4-throughput-delay-ipg-{congestion_control}-{wl}",
                flow_info,
                congestion_points=congestions,
                schemes=schemes,
                delay_ylim=(0.999, 1.00001) if congestion_control == "TcpVegas" else (0.93, 1.001),
                ipg_ylim=(0.93, 1.0006),
                ipg_xlim=(0.03, 1000),
            )


if __name__ == "__main__":
    main()
