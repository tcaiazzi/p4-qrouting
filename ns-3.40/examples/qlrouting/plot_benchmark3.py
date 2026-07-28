import os

import paper_plot


def main():
    results_path = "results_benchmark"
    paper_plot.figures_path = os.path.join("paper_figures", "benchmark3")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    workloads = [
        ("wl1", [(2.0, 2.3)]),
        ("wl2", [(2.0, 2.3), (2.6, 2.9)]),
        ("wl3", [(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]),
        ("wl4", [(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)]),
    ]

    for congestion_control in ["TcpLinuxReno", "TcpVegas"]:
        for wl, congestions in workloads:
            base_path = os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}")
            paper_plot.plot_throughput_figure(
                base_path,
                "h1",
                f"microbenchmark-3-throughput-{congestion_control}-{wl}",
                congestion_points=congestions,
                central=True,
                local=True,
                labels=["Baseline", "QLR", "Control Plane", "HP-QLR"],
            )

            paper_plot.plot_delay_cdf_figure(
                base_path,
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "-",
                        os.path.join(base_path, "qlr_0/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "-.",
                        os.path.join(base_path, "qlr_1/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Central",
                        "blue",
                        ":",
                        os.path.join(base_path, "central/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR Local",
                        "purple",
                        "--",
                        os.path.join(base_path, "local_qlr/0/flow_monitor.xml"),
                    ),
                ],
                f"microbenchmark-3-delay-cdf-{congestion_control}-{wl}",
                ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001),
            )

    paper_plot.plot_delay_cdf_all_experiments(
        results_path,
        [
            (22222, "Baseline", "red", "-", "qlr_0/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr_1/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "benchmark3-delay-cdf-cumulative",
        ylim=(0.8, 1.00001),
        xlim=None,
    )

    paper_plot.plot_received_bytes_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "qlr_0/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr_1/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "benchmark3-rx-bytes-comparison",
    )

    paper_plot.plot_avg_throughput_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "qlr_0/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr_1/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "benchmark3-avg-throughput-comparison",
    )


if __name__ == "__main__":
    main()
