import os

import paper_plot


def main():
    results_path = "results_benchmark"
    paper_plot.figures_path = os.path.join("paper_figures", "benchmark2")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    for wl in ["wl1", "wl2", "wl3", "wl4", "wl5", "wl6", "wl7", "wl8", "wl9", "wl10"]:
        paper_plot.plot_throughput_figure(
            os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}"),
            "h1",
            f"microbenchmark-2-throughput-{wl}",
            congestion_points=[(2.0, 2.6)],
            labels=["Baseline", "QLR"],
        )

        paper_plot.plot_delay_cdf_figure(
            os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}"),
            [
                (
                    22222,
                    "Baseline",
                    "red",
                    "-",
                    os.path.join(
                        results_path,
                        f"microbenchmark_2_TcpLinuxReno_{wl}",
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
                        f"microbenchmark_2_TcpLinuxReno_{wl}",
                        "qlr_1/0/flow_monitor.xml",
                    ),
                ),
            ],
            f"microbenchmark-2-delay-cdf-{wl}",
        )


if __name__ == "__main__":
    main()
