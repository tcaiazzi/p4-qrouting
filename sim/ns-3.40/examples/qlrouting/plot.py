import os
import sys
from itertools import islice

import matplotlib
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
        # if float(line[0]) > 12:
        #     continue
        if parsed_result["x"] and float(line[0]) - parsed_result["x"][-1] < 0.1:
            continue
        parsed_result["x"].append(float(line[0]))
        parsed_result["y"].append(float(line[1]))

    return parsed_result


def plot_delay_histogram_figure(results, addresses):

    def plot_delay_histogram(axes, src_addr, label, color, hatch, flow_monitor_path):
        sim: Simulation = parse_xml(flow_monitor_path)[0]

        axes.grid(linestyle="--", linewidth=0.5)

        to_plot = []
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            if t.sourceAddress == src_addr:
                for bin in flow.delayHistogram:
                    to_plot.extend(
                        [float(bin.get("start")) * 1000] * int(bin.get("count"))
                    )
                axes.hist(
                    to_plot,
                    label=label,
                    fill=None,
                    hatch=hatch,
                    edgecolor=color,
                    rwidth=0.8,
                    bins=range(0, 125, 5),
                )
                axes.set_xlim([0, 125])
                axes.set_ylim([0.1, 100000])
                axes.set_ylabel("N. Packets")
                axes.set_yscale("log")

                axes.set_yticks([0.1, 100, 100000])

                break

    plt.clf()

    fig, axs = plt.subplots(
        len(addresses), 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )
    handles = []
    for ax_n, (address, label, color, hatch, flow_monitor_path) in enumerate(addresses):
        plot_delay_histogram(axs[ax_n], address, label, color, hatch, flow_monitor_path)
        handles.append(
            mpatches.Patch(fill=None, hatch=hatch, edgecolor=color, label=label)
        )
    plt.xlabel("Delay [ms]")

    fig.legend(
        handles=handles,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.04),
        ncol=len(handles),
        prop={"size": 6},
    )

    plt.savefig(
        os.path.join(figures_path, f"delay_histogram_figure.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_jitter_histogram_figure(results, addresses):

    def plot_jitter_histogram(axes, src_addr, label, color, hatch, flow_monitor_path):
        sim: Simulation = parse_xml(flow_monitor_path)[0]

        axes.grid(linestyle="--", linewidth=0.5)

        to_plot = []
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            if t.sourceAddress == src_addr:
                for bin in flow.jitterHistogram:
                    to_plot.extend(
                        [float(bin.get("start")) * 1000] * int(bin.get("count"))
                    )
                axes.hist(
                    to_plot,
                    label=label,
                    fill=None,
                    hatch=hatch,
                    edgecolor=color,
                    rwidth=0.8,
                    bins=range(0, 125, 5),
                )
                axes.set_xlim([0, 125])
                axes.set_ylim([0.1, 100000])
                axes.set_ylabel("N. Packets")
                axes.set_yscale("log")

                axes.set_yticks([0.1, 100, 100000])

                break

    plt.clf()

    fig, axs = plt.subplots(
        len(addresses), 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )
    handles = []
    for ax_n, (address, label, color, hatch, flow_monitor_path) in enumerate(addresses):
        plot_jitter_histogram(
            axs[ax_n], address, label, color, hatch, flow_monitor_path
        )
        handles.append(
            mpatches.Patch(fill=None, hatch=hatch, edgecolor=color, label=label)
        )
    plt.xlabel("Jitter [ms]")

    fig.legend(
        handles=handles,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.04),
        ncol=len(handles),
        prop={"size": 6},
    )

    plt.savefig(
        os.path.join(figures_path, f"jitter_histogram_figure.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_fct_histogram_figure(results, addresses):
    flow_monitor_path = os.path.join(results, "tcp-1.xml")

    def plot_fct_histogram(axes, src_addr, label, color, hatch, flow_monitor_path):
        fcts = []
        i = 0
        sim: Simulation = parse_xml(flow_monitor_path)[0]
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            if t.sourceAddress == src_addr and t.protocol == 6:
                print(f"i: {i}, Flow {t} FCT: {flow.fct}")
                fcts.append(flow.fct)
        axes.hist(
            fcts,
            label=label,
            fill=None,
            hatch=hatch,
            edgecolor=color,
            rwidth=0.8,
            bins=range(0, 10, 1),
        )

    plt.clf()
    plt.grid(linestyle="--", linewidth=0.5)
    fig, axs = plt.subplots(
        len(addresses), 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )
    handles = []
    for ax_n, (address, label, color, hatch, flow_monitor_path) in enumerate(addresses):
        plot_fct_histogram(axs[ax_n], address, label, color, hatch, flow_monitor_path)
        handles.append(
            mpatches.Patch(fill=None, hatch=hatch, edgecolor=color, label=label)
        )
    plt.ylabel("FCT [ms]")

    fig.legend(
        handles=handles,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.04),
        ncol=len(handles),
        prop={"size": 6},
    )

    plt.savefig(
        os.path.join(figures_path, f"fct_histogram_figure.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_throughput_figure(results):
    def closest(sorted_dict, key):
        assert len(sorted_dict) > 0
        keys = list(islice(sorted_dict.irange(minimum=key), 1))
        keys.extend(islice(sorted_dict.irange(maximum=key, reverse=True), 1))
        return min(keys, key=lambda k: abs(key - k))

    cwnd_results_path = os.path.join(results, "throughput")

    def plot_throughput_line(node_type, color, marker, label, linestyle):
        for file_name in os.listdir(cwnd_results_path):
            if node_type not in file_name:
                continue

            to_plot = parse_data_file(os.path.join(cwnd_results_path, file_name))

            to_plot_x = [x for x in to_plot["x"] if x <= 12]
            to_plot_y = to_plot["y"][: len(to_plot_x)]

            plt.plot(
                to_plot_x,
                [y / 1000000 for y in to_plot_y],
                label=label,
                linestyle=linestyle,
                fillstyle="none",
                color=color,
                marker=marker,
            )

            break

    def plot_throughput_line_merge(node_type, color, marker, label, experiment_time):
        to_plot_type = SortedDict(
            {round(x, 1): [] for x in np.arange(0, experiment_time, 0.5)}
        )

        for file_name in os.listdir(cwnd_results_path):
            if node_type not in file_name:
                continue

            to_plot_file = SortedDict(
                {round(x, 1): 0 for x in np.arange(0, experiment_time, 0.5)}
            )
            to_plot = parse_data_file(os.path.join(cwnd_results_path, file_name))

            for idx, t in enumerate(to_plot["x"]):
                r_t = closest(to_plot_file, round(t, 1))

                if to_plot_file[r_t] == 0:
                    to_plot_file[r_t] = to_plot["y"][idx]
                else:
                    to_plot_file[r_t] = (to_plot_file[r_t] + to_plot["y"][idx]) / 2

            for t, val in to_plot_file.items():
                to_plot_type[t].append(val)

        to_plot_filtered = {}
        for t, vals in to_plot_type.items():
            if t > 13:
                continue

            to_plot_filtered[t] = sum(vals)

        plt.plot(
            to_plot_filtered.keys(),
            [y / 1000000 for y in to_plot_filtered.values()],
            label=label,
            linestyle="dashed",
            fillstyle="none",
            color=color,
            marker=marker,
        )

    plt.clf()
    plt.grid(linestyle="--", linewidth=0.5)

    plot_throughput_line("ll", "red", None, "Live-Live Flow", "solid")
    plot_throughput_line("active-fg", "green", None, "TCP Flow (Path 1)", "dashed")
    plot_throughput_line("backup-fg", "blue", None, "TCP Flow (Path 2)", "dashed")

    # plt.xticks(range(0, 13))
    # plt.xlim([0, 13])
    plt.ylim([0, 80])

    plt.xlabel("Time [s]")
    plt.ylabel("Throughput [Mbps]")
    plt.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.2),
        labelspacing=0.2,
        ncols=3,
        prop={"size": 6},
    )
    experiment_name = "-".join(results.split("/")[-7:])
    plt.savefig(
        os.path.join(figures_path, f"tp_figure_{experiment_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: plot.py <results_path>")
        exit(1)

    results_path = os.path.abspath(sys.argv[1])
    figures_path = os.path.abspath(sys.argv[2])

    print(f"Results Path: {results_path}")
    print(f"Figures Path: {figures_path}")

    os.makedirs(figures_path, exist_ok=True)

    plt.figure(figsize=(3.5, 2))

    # plot_seqn_figure(results_path)
    # plot_cwnd_figure(results_path)
    # plot_tcp_retransmission_figure(results_path)
    # plot_throughput_figure(results_path)

    plot_fct_histogram_figure(
        results_path,
        [
            (
                "10.0.1.1",
                "TCP Flow",
                "red",
                "////",
                os.path.join(results_path, "tcp-1.xml"),
            ),
            (
                "10.0.1.1",
                "QLR Flow",
                "green",
                "////",
                os.path.join(results_path, "qlr-1.xml"),
            ),
        ],
    )

    plot_delay_histogram_figure(
        results_path,
        [
            (
                "10.0.1.1",
                "TCP Flow",
                "red",
                "////",
                os.path.join(results_path, "tcp-1.xml"),
            ),
            (
                "10.0.1.1",
                "QLR Flow",
                "green",
                "////",
                os.path.join(results_path, "qlr-1.xml"),
            ),
        ],
    )

    plot_jitter_histogram_figure(
        results_path,
        [
            (
                "10.0.1.1",
                "TCP Flow",
                "red",
                "////",
                os.path.join(results_path, "tcp-1.xml"),
            ),
            (
                "10.0.1.1",
                "QLR Flow",
                "green",
                "////",
                os.path.join(results_path, "qlr-1.xml"),
            ),
        ],
    )
