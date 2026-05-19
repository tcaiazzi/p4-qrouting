import os

import paper_plot


def main():
    results_path = "results_benchmark"
    paper_plot.figures_path = os.path.join("paper_figures", "benchmark1")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    workloads = [
        ("wl1", [(2.0, 2.3)]),
        ("wl2", [(2.0, 2.3), (2.6, 2.9)]),
        ("wl3", [(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]),
        ("wl4", [(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)]),
    ]

    for wl, congestions in workloads:
        paper_plot.plot_throughput_figure(
            os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}"),
            "h1",
            f"microbenchmark-1-throughput-{wl}",
            congestion_points=congestions,
            central=True,
            labels=["Baseline", "QLR", "Central"],
        )

        paper_plot.plot_delay_cdf_figure(
            os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}"),
            [
                (
                    22222,
                    "Baseline",
                    "red",
                    "-",
                    os.path.join(
                        results_path,
                        f"microbenchmark_1_TcpLinuxReno_{wl}",
                        "qlr_0/0/flow_monitor.xml",
                    ),
                ),
                (
                    22222,
                    "QLR",
                    "green",
                    "-.",
                    os.path.join(
                        results_path,
                        f"microbenchmark_1_TcpLinuxReno_{wl}",
                        "qlr_1/0/flow_monitor.xml",
                    ),
                ),
                (
                    22222,
                    "Central",
                    "blue",
                    ":",
                    os.path.join(
                        results_path,
                        f"microbenchmark_1_TcpLinuxReno_{wl}",
                        "central/0/flow_monitor.xml",
                    ),
                ),
                (
                    22222,
                    "Local",
                    "purple",
                    ":",
                    os.path.join(
                        results_path,
                        f"microbenchmark_1_TcpLinuxReno_{wl}",
                        "local_qlr/0/flow_monitor.xml",
                    ),
                ),
            ],
            f"microbenchmark-1-delay-cdf-{wl}",
        )


if __name__ == "__main__":
    main()
