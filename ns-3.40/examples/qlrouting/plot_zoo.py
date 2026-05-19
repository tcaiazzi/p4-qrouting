import os

import paper_plot


def main():
    results_path = "results"
    paper_plot.figures_path = os.path.join("paper_figures", "zoo-new-gen")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    for experiment in os.listdir(results_path):
        print(f"Printing figures for experiment {experiment}")
        try:
            experiment_split = experiment.split("_")
            congestion_control = experiment_split[1]
            wl = "_".join(experiment_split[3:])
            experiment_path = os.path.join(results_path, experiment)

            paper_plot.plot_throughput_figure(
                experiment_path,
                "h3",
                f"zoo-throughput-{congestion_control}-{wl}",
                central=True,
                local=True,
                labels=["Baseline", "QLR", "Central", "QLR Local"],
            )

            paper_plot.plot_delay_cdf_figure(
                experiment_path,
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "-",
                        os.path.join(experiment_path, "baseline/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "-.",
                        os.path.join(experiment_path, "qlr/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Local QLR",
                        "purple",
                        "--",
                        os.path.join(experiment_path, "local_qlr/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Central",
                        "blue",
                        ":",
                        os.path.join(experiment_path, "central/0/flow_monitor.xml"),
                    ),
                ],
                f"zoo-delay-cdf-{congestion_control}-{wl}",
                ylim=(0.8, 1.00001),
                xlim=None,
            )

            paper_plot.plot_fct_histogram_figure(
                experiment_path,
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "//",
                        os.path.join(experiment_path, "baseline/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "||",
                        os.path.join(experiment_path, "qlr/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Local QLR",
                        "purple",
                        "\\\\",
                        os.path.join(experiment_path, "local_qlr/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Central",
                        "blue",
                        "+",
                        os.path.join(experiment_path, "central/0/flow_monitor.xml"),
                    ),
                ],
                f"zoo-fct-histogram-{congestion_control}-{wl}",
            )
        except Exception as e:
            print(f"Error processing experiment {experiment}: {e}")
            continue

    paper_plot.plot_delay_cdf_all_experiments(
        results_path,
        [
            (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "zoo-delay-cdf-cumulative",
        ylim=(0.8, 1.00001),
        xlim=None,
    )

    paper_plot.plot_received_bytes_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "zoo-rx-bytes-comparison",
    )

    paper_plot.plot_avg_throughput_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "zoo-avg-throughput-comparison",
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "zoo-protected-flow-slo_99",
        threshold=0.99
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "zoo-protected-flow-slo_95",
        threshold=0.95
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path,
        [
            (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
            (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
            (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
            (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
        ],
        "zoo-protected-flow-slo_90",
        threshold=0.90
    )
if __name__ == "__main__":
    main()
