import os

import paper_plot


def main():
    results_path = "results_benchmark"
    paper_plot.figures_path = os.path.join("benchmark_figures", "benchmark2")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    for wl in ["wl1", "wl2", "wl10", "wl100"]:
        base_path = os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}")

        flow_info = [
            (
                22222,
                "Static",
                "red",
                "-",
                os.path.join(base_path, "baseline/0/flow_monitor.xml"),
            ),
            (
                22222,
                "QLR",
                "green",
                "-.",
                os.path.join(base_path, "qlr/0/flow_monitor.xml"),
            ),
        ]

        paper_plot.plot_throughput_figure(
            base_path,
            f"microbenchmark-2-throughput-{wl}",
            congestion_points=[(2.0, 2.6)],
            labels=["Static", "QLR"],
        )

        paper_plot.plot_delay_cdf_figure(
            base_path,
            flow_info,
            f"microbenchmark-2-delay-cdf-{wl}",
        )

        paper_plot.plot_throughput_and_delay_cdf_figure(
            base_path,
            flow_info,
            f"microbenchmark-2-combined-{wl}",
            congestion_points=[(2.0, 2.6)],
            delay_ylim=(0.965, 1.0006),
            labels=["Static", "QLR"],
        )


if __name__ == "__main__":
    main()
