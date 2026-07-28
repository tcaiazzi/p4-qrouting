import os
import re

import paper_plot


def plot_for_link_selection(link_selection_value, results_path, workload_csv_dir, _SYSTEMS):
    # Full sel_tag as embedded in results/ directory names by run-use-case.sh
    # (e.g. "deepest" -> "seldeepest"), used to filter which experiments this
    # pass processes and to isolate this variant's output directory.
    congestion_link_selection = f"sel{link_selection_value}"
    base_figures_path = os.path.join("paper_figures", f"use-case-dense-6-{congestion_link_selection}")
    aggregate_figures_path = os.path.join(base_figures_path, "aggregate")
    os.makedirs(base_figures_path, exist_ok=True)
    os.makedirs(aggregate_figures_path, exist_ok=True)

    system_flags = {sub: en for en, _l, _c, _s, _h, sub in _SYSTEMS}
    plot_central = system_flags.get("central", False)
    plot_local_qlr = system_flags.get("local_qlr", False)
    PORT = 22222

    # Filtered relative-path configs (for cumulative plots)
    _rel_cdf  = [(PORT, lbl, col, sty, f"{sub}/0/flow_monitor.xml")
                 for en, lbl, col, sty, _h,  sub in _SYSTEMS if en]
    _rel_hist = [(PORT, lbl, col, hat, f"{sub}/0/flow_monitor.xml")
                 for en, lbl, col, _s,  hat, sub in _SYSTEMS if en]

    # Labels list for plot_throughput_figure (positional: baseline, qlr, central, local)
    _throughput_labels = [lbl for _en, lbl, *_ in _SYSTEMS]

    for experiment in os.listdir(results_path):
        if "bg10" in experiment:
            continue
        if congestion_link_selection not in experiment:
            continue
        print(f"Printing figures for experiment {experiment}")
        try:
            experiment_split = experiment.split("_")
            congestion_control = experiment_split[1]
            wl = "_".join(experiment_split[3:])
            experiment_path = os.path.join(results_path, experiment)

            paper_plot.figures_path = os.path.join(base_figures_path, experiment)
            os.makedirs(paper_plot.figures_path, exist_ok=True)

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

            paper_plot.plot_ipg_cdf_per_experiment(
                experiment_path,
                [
                    (port, lbl, col, sty, os.path.join(experiment_path, rel))
                    for port, lbl, col, sty, rel in _rel_cdf
                ],
                f"zoo-ipg-cdf-{congestion_control}-{wl}",
            )

            paper_plot.plot_jitter_cdf_figure(
                experiment_path,
                [
                    (port, lbl, col, sty, os.path.join(experiment_path, rel))
                    for port, lbl, col, sty, rel in _rel_cdf
                ],
                f"zoo-jitter-cdf-{congestion_control}-{wl}",
            )

            paper_plot.plot_deadline_miss_bar_multi_slo_figure(
                experiment_path,
                [
                    (port, lbl, col, sty, os.path.join(experiment_path, rel))
                    for port, lbl, col, sty, rel in _rel_cdf
                ],
                f"zoo-deadline-miss-{congestion_control}-{wl}",
                slo_ms_list=(10, 20, 50, 150),
            )
        except Exception as e:
            print(f"Error processing experiment {experiment}: {e}")
            continue

    paper_plot.figures_path = aggregate_figures_path

    # Known-corrupted run: seed=1927's qlr/local_qlr/central flow_monitor.xml
    # came out byte-identical across routing modes (a broken run, not a real
    # result), which skewed every pooled/aggregate figure. Excluded here so
    # it never enters a pool below.
    EXCLUDE_SEEDS = [1927]

    paper_plot.plot_delay_cdf_all_experiments(
        results_path,
        _rel_cdf,
        "zoo-delay-cdf-cumulative",
        ylim=(0.8, 1.00001),
        xlim=None,
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    paper_plot.plot_ipg_cdf_figure(
        results_path,
        _rel_cdf,
        "zoo-ipg-cdf",
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    paper_plot.plot_received_bytes_comparison(
        results_path,
        _rel_cdf,
        "zoo-rx-bytes-comparison",
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    paper_plot.plot_avg_throughput_comparison(
        results_path,
        _rel_cdf,
        "zoo-avg-throughput-comparison",
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    paper_plot.plot_deadline_miss_bar_all_experiments(
        results_path, _rel_cdf, "zoo-deadline-miss-aggregate",
        slo_ms_list=(10, 20, 50, 150),
        link_selection_tag=congestion_link_selection,
        workload_csv_dir=workload_csv_dir,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    # Real ce values found across experiments' workload CSVs (not the
    # "_ce<N>_" folder tag, which is only the REQUESTED count -- the
    # generator can produce fewer events when the topology lacks enough
    # redundant paths, and different protected destinations within the same
    # experiment can each get a different real count -- see
    # _per_destination_congestion_counts). Single source of truth for both
    # the per-ce loop and the subplots figure below, mirroring exactly what
    # those pooling functions will bucket per destination (falling back to
    # the whole-experiment average when the per-destination attribution is
    # inconclusive, same as the pooling functions do).
    ce_values = set()
    for experiment in os.listdir(results_path):
        if "bg10" in experiment or congestion_link_selection not in experiment:
            continue
        if paper_plot._experiment_has_excluded_seed(experiment, EXCLUDE_SEEDS):
            continue
        workload_csv = paper_plot._experiment_workload_csv_path(experiment, workload_csv_dir)
        per_dest_counts = paper_plot._per_destination_congestion_counts(workload_csv)
        if per_dest_counts is not None:
            ce_values.update(per_dest_counts.values())
        else:
            ce_values.add(paper_plot._count_congestion_events_in_workload(workload_csv))
    ce_values = sorted(ce_values - {0})

    for ce in ce_values:
        paper_plot.plot_deadline_miss_bar_all_experiments(
            results_path, _rel_cdf, f"zoo-deadline-miss-aggregate-ce{ce}",
            slo_ms_list=(10, 20, 50, 150),
            link_selection_tag=congestion_link_selection,
            ce_filter=ce,
            workload_csv_dir=workload_csv_dir,
            exclude_seeds=EXCLUDE_SEEDS,
        )

    if ce_values:
        # Same panels as zoo-deadline-miss-aggregate-ce<N>.pdf above, side by
        # side in one figure/file with a single shared legend.
        paper_plot.plot_deadline_miss_bar_by_ce_subplots_figure(
            results_path, _rel_cdf, "zoo-deadline-miss-aggregate-by-ce",
            ce_values=ce_values,
            slo_ms_list=(10, 20, 50, 150),
            link_selection_tag=congestion_link_selection,
            workload_csv_dir=workload_csv_dir,
            exclude_seeds=EXCLUDE_SEEDS,
        )

    # Real (occupied, free) path-capacity pairs found across experiments'
    # workload CSVs (see paper_plot._per_destination_free_occupied) --
    # occupied is the real CE count above, free is how much more successive-
    # block capacity that destination's (src,dst) pair could still sustain.
    # Controls for the destination-identity confound real-CE-only bucketing
    # has (see plot_deadline_miss_bar_by_ce_subplots_figure's docstring).
    free_occupied_pairs = set()
    for experiment in os.listdir(results_path):
        if "bg10" in experiment or congestion_link_selection not in experiment:
            continue
        if paper_plot._experiment_has_excluded_seed(experiment, EXCLUDE_SEEDS):
            continue
        workload_csv = paper_plot._experiment_workload_csv_path(experiment, workload_csv_dir)
        per_dest_pairs = paper_plot._per_destination_free_occupied(workload_csv)
        if per_dest_pairs is not None:
            free_occupied_pairs.update(per_dest_pairs.values())
    free_occupied_pairs = sorted(free_occupied_pairs - {(0, 0)})

    if free_occupied_pairs:
        paper_plot.plot_deadline_miss_bar_by_free_occupied_subplots_figure(
            results_path, _rel_cdf, "zoo-deadline-miss-aggregate-by-free-occupied",
            pairs=free_occupied_pairs,
            slo_ms_list=(10, 20, 50, 150),
            link_selection_tag=congestion_link_selection,
            workload_csv_dir=workload_csv_dir,
            exclude_seeds=EXCLUDE_SEEDS,
        )

    # Discover protected-flow-count values actually present in results/
    # (sweep_protected_flow_counts_csv in run-use-case.sh, not fixed) instead
    # of hardcoding a set that may not match what was actually run.
    pfc_values = sorted({
        int(m.group(1))
        for experiment in os.listdir(results_path)
        if (m := re.search(r"_prot(\d+)_", experiment))
    })
    for pfc in pfc_values:
        paper_plot.plot_deadline_miss_bar_all_experiments(
            results_path, _rel_cdf, f"zoo-deadline-miss-aggregate-prot{pfc}",
            slo_ms_list=(10, 20, 50, 150),
            link_selection_tag=congestion_link_selection,
            pfc_filter=pfc,
            exclude_seeds=EXCLUDE_SEEDS,
        )

    if pfc_values:
        # Same panels as zoo-deadline-miss-aggregate-prot<N>.pdf above, side
        # by side in one figure/file with a single shared legend.
        paper_plot.plot_deadline_miss_bar_by_pfc_subplots_figure(
            results_path, _rel_cdf, "zoo-deadline-miss-aggregate-by-pfc",
            pfc_values=pfc_values,
            slo_ms_list=(10, 20, 50, 150),
            link_selection_tag=congestion_link_selection,
            exclude_seeds=EXCLUDE_SEEDS,
        )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path, _rel_cdf, "zoo-protected-flow-slo_99",
        workload_csv_dir=workload_csv_dir, threshold=0.99,
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path, _rel_cdf, "zoo-protected-flow-slo_95",
        workload_csv_dir=workload_csv_dir, threshold=0.95,
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )

    paper_plot.plot_protected_flow_slo_comparison(
        results_path, _rel_cdf, "zoo-protected-flow-slo_90",
        workload_csv_dir=workload_csv_dir, threshold=0.90,
        link_selection_tag=congestion_link_selection,
        exclude_seeds=EXCLUDE_SEEDS,
    )


def main():
    results_path = "results"

    # Resources tag for the topology being plotted (must match RESOURCES_TAG used
    # at run time): "11_nodes" for the original Abilene, "abilene-dense" for the
    # denser variant. Drives where protected-flow SLO reads the workload CSVs.
    resources_tag = "pdh"
    # resources_tag = "11_nodes"
    workload_csv_dir = f"resources/{resources_tag}/workloads"

    # Master system table: (flag, label, color, cdf_linestyle, hist_hatch, subdir)
    _SYSTEMS = [
        (True,  "Baseline",  "red",    "-",    "//",    "baseline"),
        (True,  "QLR",       "green",  "-.",   "||",    "qlr"),
        (True,  "HP-QLR", "purple", "--",   "\\\\",  "local_qlr"),
        (True,  "Control Plane",   "blue",   ":",    "+",     "central"),
    ]

    # Both congestion-link-selection variants, each in its own output
    # directory (see run-dense.sh, which generates both datasets in one call).
    for link_selection_value in ("deepest", "waypoint-random"):
        print(f"=== plot_zoo: congestion_link_selection={link_selection_value} ===")
        plot_for_link_selection(link_selection_value, results_path, workload_csv_dir, _SYSTEMS)


if __name__ == "__main__":
    main()
