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
    def plot_throughput_line(experiment_type, color, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "throughput")
            for file_name in os.listdir(experiment_results_path):
                if "host1" not in file_name:
                    continue
                file_path = os.path.join(experiment_results_path, file_name)
                to_plot = parse_data_file(file_path)
                to_plot_x = [x for x in to_plot["x"] if x <= 12]
                to_plot_y = to_plot["y"][: len(to_plot_x)]

                plt.plot(
                    to_plot_x,
                    [y / 1000000 for y in to_plot_y],
                    label=f"{file_name.split('.')[0]}-{experiment_type}",
                    linestyle=linestyle,
                    fillstyle="none",
                    color=color,
                    marker=marker,
                )

            break

    plt.clf()
    plt.grid(linestyle="--", linewidth=0.5)

    plot_throughput_line("qlr", "red", None, "QLR Flows", "solid")
    plot_throughput_line("tcp", "orange", None, "TCP Flows", "solid")

    # plt.xticks(range(0, 13))
    # plt.xlim([0, 13])
    plt.ylim([0, 80])

    plt.xlabel("Time [s]")
    plt.ylabel("Average Throughput [Mbps]")
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


def plot_tcp_retransmission_figure(results):
    def plot_retransmissions_line(experiment_type, color, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "retransmissions")
            for file_name in os.listdir(experiment_results_path):
                if "host1-host5" not in file_name:
                    continue
                to_plot = parse_data_file(os.path.join(experiment_results_path, file_name))
                print(f"to_plot: {to_plot}")
                label = "-".join(file_name.split("-")[:2])
                plt.plot(to_plot['x'], to_plot['y'], label=label,
                            linestyle=linestyle, fillstyle='none', color=color, marker=marker)
        return to_plot['x']

    plt.clf()
    plt.grid(linestyle='--', linewidth=0.5)
    plot_retransmissions_line("qlr", "red", None, "QLR Flows", "solid")
    plot_retransmissions_line("tcp", 'orange', None, "TCP Flows", "solid")

    plt.xlabel('Time [s]')
    # plt.xticks(range(0, 13))
    # plt.xlim([0, 13])

    plt.ylabel('N. TCP Retransmissions')
    # plt.yticks(range(0, 200, 20))
    #plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    experiment_name = "-".join(results.split("/")[-7:])
    plt.savefig(
        os.path.join(figures_path, f"retransmissions_figure_{experiment_name}.pdf"), format="pdf", bbox_inches='tight'
    )

def plot_cumulative_tcp_retransmission_figure(results):
    def plot_retransmissions_bar(experiment_type, color, marker, label, linestyle, offset):
        results_path = os.path.join(results, experiment_type)
        to_plot = {"x": [], "y": []}
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "retransmissions")
            experiment_results = []
            for file_name in os.listdir(experiment_results_path):
                exp_res = parse_data_file(os.path.join(experiment_results_path, file_name))
                if exp_res["y"]:
                    experiment_results.append(exp_res['y'][-1])
                    print(f"experiment_results: {exp_res}")

            to_plot['y'].append(np.sum(experiment_results))
        plt.bar(offset, np.mean(to_plot['y']), label=label,
                    linestyle=linestyle, color=color)
        return to_plot['x']

    plt.clf()
    plt.grid(linestyle='--', linewidth=0.5)
    plot_retransmissions_bar("qlr", "red", None, "QLR Flows", "solid", offset=1)
    plot_retransmissions_bar("tcp", 'orange', None, "TCP Flows", "solid", offset=2)

    plt.xticks([1, 2], ['QLR Flows', 'TCP Flows'])

    plt.ylabel('N. TCP Retransmissions')
    # plt.yticks(range(0, 200, 20))
    #plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    plt.savefig(
        os.path.join(figures_path, f"cumulative_retransmissions_figure.pdf"), format="pdf", bbox_inches='tight'
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
    plot_cumulative_tcp_retransmission_figure(results_path)
    plot_tcp_retransmission_figure(results_path)
    plot_throughput_figure(results_path)

    # plot_fct_histogram_figure(
    #     results_path,
    #     [
    #         (
    #             "10.0.1.1",
    #             "TCP Flow",
    #             "red",
    #             "////",
    #             os.path.join(results_path, "tcp-1.xml"),
    #         ),
    #         (
    #             "10.0.1.1",
    #             "QLR Flow",
    #             "green",
    #             "////",
    #             os.path.join(results_path, "qlr-1.xml"),
    #         ),
    #     ],
    # )

    # plot_delay_histogram_figure(
    #     results_path,
    #     [
    #         (
    #             "10.0.1.1",
    #             "TCP Flow",
    #             "red",
    #             "////",
    #             os.path.join(results_path, "tcp-1.xml"),
    #         ),
    #         (
    #             "10.0.1.1",
    #             "QLR Flow",
    #             "green",
    #             "////",
    #             os.path.join(results_path, "qlr-1.xml"),
    #         ),
    #     ],
    # )

    # plot_jitter_histogram_figure(
    #     results_path,
    #     [
    #         (
    #             "10.0.1.1",
    #             "TCP Flow",
    #             "red",
    #             "////",
    #             os.path.join(results_path, "tcp-1.xml"),
    #         ),
    #         (
    #             "10.0.1.1",
    #             "QLR Flow",
    #             "green",
    #             "////",
    #             os.path.join(results_path, "qlr-1.xml"),
    #         ),
    #     ],
    # )
