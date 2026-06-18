import os

import paper_plot


def main():
    # --- system selection (set to False to skip a system) ---
    plot_baseline  = True
    plot_qlr       = True
    plot_central   = True
    plot_local_qlr = True

    results_path = "results"
    paper_plot.figures_path = os.path.join("paper_figures", "zoo-new-gen")
    os.makedirs(paper_plot.figures_path, exist_ok=True)

    # Master system table: (flag, label, color, cdf_linestyle, hist_hatch, subdir)
    _SYSTEMS = [
        (plot_baseline,  "Baseline",  "red",    "-",    "//",    "baseline"),
        (plot_qlr,       "QLR",       "green",  "-.",   "||",    "qlr"),
        (plot_local_qlr, "Local QLR", "purple", "--",   "\\\\",  "local_qlr"),
        (plot_central,   "Central",   "blue",   ":",    "+",     "central"),
    ]
    PORT = 22222

    # Filtered relative-path configs (for cumulative plots)
    _rel_cdf  = [(PORT, lbl, col, sty, f"{sub}/0/flow_monitor.xml")
                 for en, lbl, col, sty, _h,  sub in _SYSTEMS if en]
    _rel_hist = [(PORT, lbl, col, hat, f"{sub}/0/flow_monitor.xml")
                 for en, lbl, col, _s,  hat, sub in _SYSTEMS if en]

    # Labels list for plot_throughput_figure (positional: baseline, qlr, central, local)
    _throughput_labels = [lbl for _en, lbl, *_ in _SYSTEMS]

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
                central=plot_central,
                local=plot_local_qlr,
                labels=_throughput_labels,
            )

            paper_plot.plot_delay_cdf_figure(
                experiment_path,
                [
                    (port, lbl, col, sty, os.path.join(experiment_path, rel))
                    for port, lbl, col, sty, rel in _rel_cdf
                ],
                f"zoo-delay-cdf-{congestion_control}-{wl}",
                ylim=(0.8, 1.00001),
                xlim=None,
            )

            paper_plot.plot_fct_histogram_figure(
                experiment_path,
                [
                    (port, lbl, col, hat, os.path.join(experiment_path, rel))
                    for port, lbl, col, hat, rel in _rel_hist
                ],
                f"zoo-fct-histogram-{congestion_control}-{wl}",
            )
        except Exception as e:
            print(f"Error processing experiment {experiment}: {e}")
            continue

    paper_plot.plot_delay_cdf_all_experiments(
        results_path,
        _rel_cdf,
        "zoo-delay-cdf-cumulative",
        ylim=(0.8, 1.00001),
        xlim=None,
    )

    paper_plot.plot_received_bytes_comparison(
        results_path,
        _rel_cdf,
        "zoo-rx-bytes-comparison",
    )

    paper_plot.plot_avg_throughput_comparison(
        results_path,
        _rel_cdf,
        "zoo-avg-throughput-comparison",
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path, _rel_cdf, "zoo-protected-flow-slo_99", threshold=0.99
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path, _rel_cdf, "zoo-protected-flow-slo_95", threshold=0.95
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path, _rel_cdf, "zoo-protected-flow-slo_90", threshold=0.90
    )
if __name__ == "__main__":
    main()
