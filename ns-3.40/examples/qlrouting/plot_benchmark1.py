import os

import paper_plot
import plot_topology

EDGES = "0,1;0,2;1,2"
DAGS = "0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2"
HOSTS = "1,1,1"


def main():
    results_path = "results_benchmark"
    paper_plot.figures_path = os.path.join("benchmark_figures", "benchmark1")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    workloads = [
        # ("wl1", [(2.0, 2.2)]),
        # ("wl2", [(2.0, 2.3), (2.6, 2.9)]),
        ("wl3", [(2.0, 2.2), (2.3, 2.5), (2.6, 2.8)]),
        # ("wl4", [(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)]),
    ]

    for wl, congestions in workloads:
        base_path = os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}")

        plot_topology.generate_topology_figures(
            EDGES, DAGS, HOSTS,
            output_dir=os.path.join(paper_plot.figures_path, "topology"),
            workload_file=os.path.join("resources", "3_nodes", "workloads", f"{wl}.csv"),
        )

        paper_plot.plot_throughput_subplots_figure(
            base_path,
            f"microbenchmark-1-throughput-subplots-{wl}",
            congestion_points=congestions,
            central=True,
            local=True,
            labels=["Static", "QLR", "Control Plane", "HP-QLR"],
        )

        flow_info = [
            (
                22222,
                "Static",
                "red",
                "-.",
                os.path.join(base_path, "baseline/0/flow_monitor.xml"),
            ),
            (
                22222,
                "Control Plane",
                "blue",
                "--",
                os.path.join(base_path, "central/0/flow_monitor.xml"),
            ),
            (
                22222,
                "HP-QLR",
                "purple",
                "--",
                os.path.join(base_path, "local_qlr/0/flow_monitor.xml"),
            ),
            (
                22222,
                "QLR",
                "green",
                "-.",
                os.path.join(base_path, "qlr/0/flow_monitor.xml"),
            ),
        ]

        paper_plot.plot_delay_cdf_figure(
            base_path,
            flow_info,
            f"microbenchmark-1-delay-cdf-{wl}",
            ylim=(0.95, 1.001),
        )

        paper_plot.plot_jitter_cdf_figure(
            base_path,
            flow_info,
            f"microbenchmark-1-jitter-cdf-{wl}",
            ylim=(0.95, 1.001),
        )

        paper_plot.plot_ipg_cdf_per_experiment(
            base_path,
            flow_info,
            f"microbenchmark-1-ipg-cdf-{wl}",
            ylim=(0.993, 1.0003),
            xlim=(0.03, 1000),
        )

        paper_plot.plot_throughput_delay_ipg_figure(
            base_path,
            f"microbenchmark-1-throughput-delay-ipg-{wl}",
            flow_info,
            congestion_points=congestions,
            central=True,
            local=True,
            labels=["Static", "QLR", "Control Plane", "HP-QLR", ],
            delay_ylim=(0.93, 1.001),
            ipg_ylim=(0.98, 1.0003),
            ipg_xlim=(0.03, 1000),
        )


if __name__ == "__main__":
    main()
