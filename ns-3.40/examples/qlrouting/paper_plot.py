import os
import sys
from itertools import islice

import matplotlib
from matplotlib.lines import Line2D
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
from flowmon_parser import parse_xml, FiveTuple, Flow, Simulation
from sortedcontainers import SortedDict


class OOMFormatter(matplotlib.ticker.ScalarFormatter):
    def __init__(self, order=0, fformat="%1.1f", offset=True, mathText=False):
        self.oom = order
        self.fformat = fformat
        matplotlib.ticker.ScalarFormatter.__init__(
            self, useOffset=offset, useMathText=mathText
        )

    def _set_order_of_magnitude(self):
        self.orderOfMagnitude = self.oom

    def _set_format(self, vmin=None, vmax=None):
        self.format = self.fformat
        if self._useMathText:
            self.format = r"$\mathdefault{%s}$" % self.format


figures_path = "figures"


def parse_data_file(file_path):
    parsed_result = {"x": [], "y": []}
    with open(file_path, "r") as cwnd_file:
        lines = cwnd_file.readlines()

    for line in lines:
        line = line.strip().split(" ")
        parsed_result["x"].append(float(line[0]))
        parsed_result["y"].append(float(line[1]))

    return parsed_result

def parse_qdepth_file(file_path, divide_by=None):
    parsed_result = {}
    with open(file_path, "r") as cwnd_file:
        lines = cwnd_file.readlines()

    for line in lines:
        line = line.strip().split(" ")
        # if float(line[0]) > 12:
        #     continue
        if line[1] not in parsed_result:
            parsed_result[line[1]] = {"x": [], "y": []}
        
        parsed_result[line[1]]["x"].append(float(line[0]))
        parsed_result[line[1]]["y"].append(float(line[2]) if divide_by is None else float(line[2])/divide_by)

    return parsed_result


def plot_delay_cdf_figure(results, flow_info, figure_name, xlim=(0, 700), ylim=(0.95, 1.001)):
    def extract_delays(flow_monitor_path, dst_port):
        # find xml file if a directory is given
        candidate = flow_monitor_path
        if os.path.isdir(flow_monitor_path):
            # look for flow_monitor.xml in subdirs or root
            for entry in sorted(os.listdir(flow_monitor_path)):
                p = os.path.join(flow_monitor_path, entry)
                cand = os.path.join(p, "flow_monitor.xml") if os.path.isdir(p) else None
                if cand and os.path.isfile(cand):
                    candidate = cand
                    break
            else:
                root_cand = os.path.join(flow_monitor_path, "flow_monitor.xml")
                if os.path.isfile(root_cand):
                    candidate = root_cand

        if not os.path.isfile(candidate):
            return None

        sim: Simulation = parse_xml(candidate)[0]
        delays = []
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            if t.destinationPort == dst_port:
                for bin in flow.delayHistogram:
                    delays.extend([float(bin.get("start")) * 1000] * int(bin.get("count")))

        return delays if delays else None

    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()

    handles = []
    for dst_port, label, color, hatch, flow_monitor_path in flow_info:
        delays = extract_delays(flow_monitor_path, dst_port)
        if delays is None:
            continue
        delays_sorted = np.sort(np.array(delays))
        cdf = np.arange(1, len(delays_sorted) + 1) / float(len(delays_sorted))
        ax.step(delays_sorted, cdf, where="post", label=label, color=color, linestyle=hatch)
        # handles.append(mpatches.Patch(fill=None, edgecolor=color, label=label))

    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    ax.set_xlabel("Delay [ms]", fontsize=12)
    ax.set_ylabel("CDF", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.grid(linestyle="--", linewidth=0.5)

    fig.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.02),
        ncol=len(flow_info),
        prop={"size": 12},
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_throughput_figure(results, source_node, figure_name, congetion_points=None, central=False, labels=None):
    def plot_throughput_line(axes, experiment_type, colors, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "throughput")
            color_idx = 0
            for i, file_name in enumerate(sorted(os.listdir(experiment_results_path))):
                #port = file_name.split("-")[1].split(".")[0]
                if source_node not in file_name:
                    continue
                file_path = os.path.join(experiment_results_path, file_name)
                to_plot = parse_data_file(file_path)
                to_plot_x = [x for x in to_plot["x"] if x <= 25]
                to_plot_y = to_plot["y"][: len(to_plot_x)]

                
                axes.plot(
                    to_plot_x,
                    [y / 1000000 for y in to_plot_y],
                    label=f"{label}",
                    linestyle=linestyle,
                    fillstyle="none",
                    color=colors[color_idx],
                    marker=marker,
                    zorder=(5 if label == "QLR" else 4),
                )
                color_idx += 1
    plt.figure(figsize=(5, 3))
    ax = plt.gca()
    plt.grid(linestyle="--", linewidth=0.5)

    # plot Baseline first, then QLR so QLR is drawn on top
    plot_throughput_line(ax, "qlr_0", ["red", "darkred"], None, labels[0], "-.")
    plot_throughput_line(ax, "qlr_1", ["green", "darkgreen"], None, labels[1], "--")
    if central:
        plot_throughput_line(ax, "central", ["blue", "darkblue"], None, labels[2], ":")

    ax.set_xlabel("Time [s]", fontsize=12)
    ax.set_ylabel("Average Throughput [Mbps]", loc="bottom", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.set_xlim([1, 7])

    # draw congestion regions if provided (each item may be (start,end) pair)
    if congetion_points:
        for item in congetion_points:
            try:
                s, e = item[0], item[1]
            except Exception:
                # fallback: single time -> vertical line
                s = item
                e = None
            if e is None:
                ax.axvline(s, color="black", linestyle=":", linewidth=1.0, alpha=0.8, zorder=0)
            else:
                ax.axvspan(s, e, color="black", alpha=0.12, zorder=0)

    # consolidated legend (include congestion entry if any)
    handles, labels = ax.get_legend_handles_labels()
    if congetion_points:
        handles.append(Line2D([0], [0], color="black", lw=4, alpha=0.12))
        labels.append("Congestion")
    if handles:
        ax.legend(handles=handles, labels=labels, loc="upper center", bbox_to_anchor=(0.5, 1.30) if congetion_points else (0.5, 1.15), ncol=2, prop={"size": 12})

    plt.savefig(os.path.join(figures_path, f"{figure_name}.pdf"), format="pdf", bbox_inches="tight")



if __name__ == "__main__":

        # ## BENCHMARK 1 
        figures_path = os.path.join("paper_figures","benchmark1")

        os.makedirs(figures_path, exist_ok=True)

        for wl, congestions in [("wl1",[(2.0, 2.3)]) , ("wl2",[(2.0, 2.3), (2.6, 2.9)]) , ("wl3",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]) , ("wl4",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)])]:

            plot_throughput_figure(os.path.join("results", f"microbenchmark_1_TcpLinuxReno_{wl}"), "h1", f"microbenchmark-1-throughput-{wl}", congetion_points=congestions, central=True, labels=["Baseline", "QLR", "Central"])
        
            plot_delay_cdf_figure(
                os.path.join("results", f"microbenchmark_1_TcpLinuxReno_{wl}"),
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "-",
                        os.path.join("results", f"microbenchmark_1_TcpLinuxReno_{wl}", "qlr_0/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "-.",
                        os.path.join("results", f"microbenchmark_1_TcpLinuxReno_{wl}", "qlr_1/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Central",
                        "blue",
                        ":",
                        os.path.join("results", f"microbenchmark_1_TcpLinuxReno_{wl}", "central/0/flow_monitor.xml"),
                    ),
                ],
                f"microbenchmark-1-delay-cdf-{wl}"
            )

        ## BENCHMARK 2
        figures_path = os.path.join("paper_figures","benchmark2")

        os.makedirs(figures_path, exist_ok=True)

        for wl in ["wl1", "wl2", "wl3", "wl4", "wl5", "wl6", "wl7", "wl8", "wl9", "wl10"]:

            plot_throughput_figure(os.path.join("results", f"microbenchmark_2_TcpLinuxReno_{wl}"), "h1", f"microbenchmark-2-throughput-{wl}", congetion_points=[(2.0, 2.6)], labels=["Baseline", "QLR"])
        
            plot_delay_cdf_figure(
                os.path.join("results", f"microbenchmark_2_TcpLinuxReno_{wl}"),
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "-",
                        os.path.join("results", f"microbenchmark_2_TcpLinuxReno_{wl}", "qlr_0/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "-.",
                        os.path.join("results", f"microbenchmark_2_TcpLinuxReno_{wl}", "qlr_1/0/flow_monitor.xml"),
                    ),
                ],
                f"microbenchmark-2-delay-cdf-{wl}"
            )

        figures_path = os.path.join("paper_figures","benchmark3")

        os.makedirs(figures_path, exist_ok=True)

        for congestion_control in ["TcpLinuxReno", "TcpVegas"]:
            for wl, congestions in [("wl1",[(2.0, 2.3)]) , ("wl2",[(2.0, 2.3), (2.6, 2.9)]) , ("wl3",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]) , ("wl4",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)])]:

                plot_throughput_figure(os.path.join("results", f"microbenchmark_3_{congestion_control}_{wl}"), "h1", f"microbenchmark-3-throughput-{congestion_control}-{wl}", congetion_points=congestions, central=True, labels=["Baseline", "QLR", "Central"])
        
                plot_delay_cdf_figure(
                    os.path.join("results", f"microbenchmark_3_{congestion_control}_{wl}"),
                    [
                        (
                            22222,
                            "Baseline",
                            "red",
                            "-",
                            os.path.join("results", f"microbenchmark_3_{congestion_control}_{wl}", "qlr_0/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "QLR",
                            "green",
                            "-.",
                            os.path.join("results", f"microbenchmark_3_{congestion_control}_{wl}", "qlr_1/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "Central",
                            "blue",
                            ":",
                            os.path.join("results", f"microbenchmark_3_{congestion_control}_{wl}", "central/0/flow_monitor.xml"),
                        ),
                    ],
                    f"microbenchmark-3-delay-cdf-{congestion_control}-{wl}",
                    ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001)
                )

        # figures_path = os.path.join("paper_figures","benchmark4")

        # os.makedirs(figures_path, exist_ok=True)

        # for congestion_control in ["TcpLinuxReno"]:
        #     for wl, congestions in [("wl1",[(2.0, 2.3)]) , ("wl2",[(2.0, 2.3), (2.6, 2.9)]) , ("wl3",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]) , ("wl4",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)])]:

        #         plot_throughput_figure(os.path.join("results", f"microbenchmark_4_{congestion_control}_{wl}"), "h1", f"microbenchmark-4-throughput-{congestion_control}-{wl}", congetion_points=congestions, labels=["Control Plane QLR", "QLR"])
        
        #         plot_delay_cdf_figure(
        #             os.path.join("results", f"microbenchmark_4_{congestion_control}_{wl}"),
        #             [
        #                 (
        #                     22222,
        #                     "Control Plane QLR",
        #                     "red",
        #                     "-",
        #                     os.path.join("results", f"microbenchmark_4_{congestion_control}_{wl}", "qlr_0/0/flow_monitor.xml"),
        #                 ),
        #                 (
        #                     22222,
        #                     "QLR",
        #                     "green",
        #                     "-.",
        #                     os.path.join("results", f"microbenchmark_4_{congestion_control}_{wl}", "qlr_1/0/flow_monitor.xml"),
        #                 ),
        #             ],
        #             f"microbenchmark-4-delay-cdf-{congestion_control}-{wl}"
        #         )
        

        