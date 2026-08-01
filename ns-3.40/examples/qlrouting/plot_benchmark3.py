import os

import paper_plot
import plot_topology

EDGES = "0,1;1,2;0,3;3,4;2,4"
DAGS = "0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3"
HOSTS = "1,1,1,1,1"


def main():
    results_path = "results_benchmark"
    paper_plot.figures_path = os.path.join("benchmark_figures", "benchmark3")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    workloads = [
        # ("wl1", [(2.0, 2.2)]),
        # ("wl2", [(2.0, 2.3), (2.6, 2.9)]),
        ("wl3", [(2.0, 2.2), (2.3, 2.5), (2.6, 2.8)]),
        # ("wl4", [(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)]),
    ]

    udp_workloads = [
        ("wl3-udp", [(2.0, 2.2), (2.3, 2.5), (2.6, 2.8)]),
    ]

    for congestion_control, wl_list in [("TcpLinuxReno", workloads), ("TcpVegas", workloads), (None, udp_workloads)]:
        for wl, congestions in wl_list:
            base_path = os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}")

            plot_topology.generate_topology_figures(
                EDGES, DAGS, HOSTS,
                output_dir=os.path.join(paper_plot.figures_path, "topology"),
                workload_file=os.path.join("resources", "microbenchmark_3", "workloads", f"{wl}.csv"),
            )

            # paper_plot.plot_throughput_figure(
            #     base_path,
            #     f"microbenchmark-3-throughput-{congestion_control}-{wl}",
            #     congestion_points=congestions,
            #     central=True,
            #     local=True,
            #     labels=["Baseline", "QLR", "Control Plane", "HP-QLR"],
            # )

            # paper_plot.plot_throughput_lines_separate_figures(
            #     base_path,
            #     f"microbenchmark-3-throughput-{congestion_control}-{wl}",
            #     congestion_points=congestions,
            #     central=True,
            #     local=True,
            #     labels=["Baseline", "QLR", "Control Plane", "HP-QLR"],
            # )

            paper_plot.plot_throughput_subplots_figure(
                base_path,
                f"microbenchmark-3-throughput-subplots-{congestion_control}-{wl}",
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
                f"microbenchmark-3-delay-cdf-{congestion_control}-{wl}",
                ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001),
            )

            paper_plot.plot_jitter_cdf_figure(
                base_path,
                flow_info,
                f"microbenchmark-3-jitter-cdf-{congestion_control}-{wl}",
                ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001),
            )

            paper_plot.plot_ipg_cdf_per_experiment(
                base_path,
                flow_info,
                f"microbenchmark-3-ipg-cdf-{congestion_control}-{wl}",
                ylim=(0.993, 1.0003),
                xlim=(0.03, 1000),
            )

            paper_plot.plot_throughput_delay_ipg_figure(
                base_path,
                f"microbenchmark-3-throughput-delay-drops-{congestion_control}-{wl}",
                flow_info,
                congestion_points=congestions,
                central=True,
                local=True,
                labels=["Static", "QLR", "Control Plane", "HP-QLR"],
                delay_xlim=(0, 600) if congestion_control is not None else (0, 800),
                delay_ylim=(0.999, 1.00001) if congestion_control == "TcpVegas" else (0.93, 1.001) if congestion_control == "TcpLinuxReno" else (0, 1.01),
                third_panel="drops",
                drops_node_id=1,
                drops_dport=22222,
                drops_metric="retransmissions" if congestion_control else "drops",
            )

    # paper_plot.plot_delay_cdf_all_experiments(
    #     results_path,
    #     [
    #         (22222, "Static", "red", "-", "baseline/0/flow_monitor.xml"),
    #         (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
    #         (22222, "HP-QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
    #         (22222, "Control Plane", "blue", ":", "central/0/flow_monitor.xml"),
    #     ],
    #     "benchmark3-delay-cdf-cumulative",
    #     ylim=(0.8, 1.00001),
    #     xlim=None,
    # )

    # paper_plot.plot_received_bytes_comparison(
    #     results_path,
    #     [
    #         (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
    #         (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
    #         (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
    #         (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
    #     ],
    #     "benchmark3-rx-bytes-comparison",
    # )

    # paper_plot.plot_avg_throughput_comparison(
    #     results_path,
    #     [
    #         (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
    #         (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
    #         (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
    #         (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
    #     ],
    #     "benchmark3-avg-throughput-comparison",
    # )


if __name__ == "__main__":
    main()
