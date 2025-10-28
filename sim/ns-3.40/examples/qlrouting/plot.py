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

def plot_delay_histogram_figure(results, flow_info):

    def plot_delay_histogram(axes, src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path):
        sim: Simulation = parse_xml(flow_monitor_path)[0]

        axes.grid(linestyle="--", linewidth=0.5)

        to_plot = []
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            if t.sourceAddress == src_addr:
                if t.destinationAddress == dst_addr:
                    if t.destinationPort == dst_port:
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
                            bins=range(0, 1000, 10),
                        )
                        
                        axes.set_ylim([0.1, 100000])
                        axes.set_ylabel("N. Packets")
                        axes.set_yscale("log")

                        axes.set_yticks([0.1, 100, 100000])

    plt.clf()

    columns = 2
    fig, axs = plt.subplots(
        int(len(flow_info)/columns), columns, sharey="all", tight_layout=True, figsize=(10, 10)
    )
    handles = []
    for col_idx, axes in enumerate(axs):
        for ax_n, _ in enumerate(axes):
            (src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path) = flow_info[ax_n + col_idx*columns]
            plot_delay_histogram(axs[col_idx][ax_n], src_addr, dst_addr, dst_port, label, color, hatch, os.path.join(flow_monitor_path, str(col_idx), "flow_monitor.xml"))
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


def plot_jitter_histogram_figure(results, flow_info):

    def plot_jitter_histogram(axes, src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path):
        sim: Simulation = parse_xml(flow_monitor_path)[0]

        axes.grid(linestyle="--", linewidth=0.5)

        to_plot = []
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            if t.sourceAddress == src_addr:
                if t.destinationAddress == dst_addr:
                    if t.destinationPort == dst_port:
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
                            bins=range(0, 500, 10),
                        )
                        axes.set_xlim([0, 500])
                        axes.set_ylim([0.1, 100000])
                        axes.set_ylabel("N. Packets")
                        axes.set_yscale("log")

                        axes.set_yticks([0.1, 100, 100000])

    plt.clf()

    fig, axs = plt.subplots(
        len(flow_info), 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )
    handles = []
    for ax_n, (src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path) in enumerate(flow_info):
        plot_jitter_histogram(
            axs[ax_n], src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path
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


def plot_fct_histogram_figure(results, flow_info):
    flow_monitor_path = os.path.join(results, "flow_monitor.xml")

    def plot_fct_histogram(axes, src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path):
        fcts = []
        i = 0
        sim: Simulation = parse_xml(flow_monitor_path)[0]
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            # if t.sourceAddress == src_addr:
            if t.destinationAddress == dst_addr:
                if t.destinationPort == dst_port:
                    print(f"i: {i}, Flow {t.sourceAddress}, {t.destinationAddress}, {t.sourcePort}, {t.destinationPort}, {t.protocol} FCT: {flow.fct}")
                    fcts.append(flow.fct)
        axes.hist(
            fcts,
            label=label,
            fill=None,
            hatch=hatch,
            edgecolor=color,
            rwidth=0.8,
            bins=range(0, 25, 1),
        )

    plt.clf()
    plt.grid(linestyle="--", linewidth=0.5)
    fig, axs = plt.subplots(
        len(flow_info), 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )
    handles = []
    for ax_n, (src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path) in enumerate(flow_info):
        plot_fct_histogram(axs[ax_n], src_addr, dst_addr, dst_port, label, color, hatch, flow_monitor_path)
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
    def plot_throughput_line(axes, experiment_type, colors, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "throughput")
            color_idx = 0
            for i, file_name in enumerate(sorted(os.listdir(experiment_results_path))):
                if "s1" not in file_name:
                    continue
                port = file_name.split("-")[1].split(".")[0]
                if port == "0":
                    continue
                file_path = os.path.join(experiment_results_path, file_name)
                to_plot = parse_data_file(file_path)
                to_plot_x = [x for x in to_plot["x"] if x <= 25]
                to_plot_y = to_plot["y"][: len(to_plot_x)]

                
                axes.plot(
                    to_plot_x,
                    [y / 1000000 for y in to_plot_y],
                    label=f"{file_name.split('.')[0]}",
                    linestyle=linestyle,
                    fillstyle="none",
                    color=colors[color_idx],
                    marker=marker,
                )
                color_idx += 1
    plt.clf()
    plt.grid(linestyle="--", linewidth=0.5)

    fig, axs = plt.subplots(
        2, 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )        
    
    plot_throughput_line(axs[0], "qlr_1", ["green", "darkgreen"], None, "QLR", "solid") 
    plot_throughput_line(axs[1], "qlr_0", ["red", "darkred"], None, "NO-QLR", "solid")

    # plt.xticks(range(0, 13))
    # plt.xlim([0, 13])
    # plt.ylim([0, 15])

    plt.xlabel("Time [s]")
    plt.ylabel("Average Throughput [Mbps]", loc="bottom")
    axs[0].legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.2),
        labelspacing=0.2,
        ncols=3,
        prop={"size": 6},
    )
    axs[1].legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.2),
        labelspacing=0.2,
        ncols=3,
        prop={"size": 6},
    )
    axs[0].set_title("QLR", loc='left')
    axs[1].set_title("NO QLR", loc='left')
    plt.savefig(
        os.path.join(figures_path, f"throughput.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_tcp_retransmission_figure(results):
    def plot_retransmissions_line(axes, experiment_type, colors, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "retransmissions")
            for idx, file_name in enumerate(os.listdir(experiment_results_path)):
                to_plot = parse_data_file(os.path.join(experiment_results_path, file_name))
                label = "-".join(file_name.split("-")[:2])
                axes.plot(to_plot['x'], to_plot['y'], label=label,
                            linestyle=linestyle, fillstyle='none', color=colors[idx], marker=marker)
            break
        return to_plot['x']

    plt.clf()
    plt.grid(linestyle='--', linewidth=0.5)
    fig, axs = plt.subplots(
        2, 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )   

    plot_retransmissions_line(axs[0], "qlr_1", ["green", "limegreen", "forestgreen", "darkseagreen"], None, "QLR", "solid")
    plot_retransmissions_line(axs[1], "qlr_0", ["red", "firebrick", "indianred", "darkred"], None, "No-QLR", "solid")

    plt.xlabel('Time [s]')
    axs[0].set_xlim([0, 25])
    axs[1].set_xlim([0, 25])

    plt.ylabel('N. TCP Retransmissions', loc='bottom')
    # plt.yticks(range(0, 200, 20))
    axs[0].legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    axs[1].legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})


    plt.savefig(
        os.path.join(figures_path, f"retransmissions.pdf"), format="pdf", bbox_inches='tight'
    )


def plot_qdepth_figure(results):
    
    def plot_qdepth_line(axes, experiment_type, colors, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "qdepth")
            for file_name in os.listdir(experiment_results_path):
                if "s1" not in file_name:
                    continue
                file_path = os.path.join(experiment_results_path, file_name)
                to_plot = parse_qdepth_file(file_path, divide_by=1000)
                
                for i, (port, port_results) in enumerate(sorted(to_plot.items(), key=lambda x: int(x[0]))): 
                    axes.plot(port_results['x'], port_results['y'], label=label + "-" + str(int(port)-1),
                        linestyle=linestyle, fillstyle='none', color=colors[i], marker=marker)
            break

    plt.clf()
    plt.grid(linestyle='--', linewidth=0.5)

    fig, axs = plt.subplots(
        2, 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )   
    plot_qdepth_line(axs[0], "qlr_1", ["green", "darkgreen"], None, "s1", "solid")
    plot_qdepth_line(axs[1], "qlr_0", ["red", "orange"], None, "s1", "solid")

    plt.xlabel('Time [s]')
    # plt.xticks(range(0, 13))
    # plt.xlim([0, 13])

    plt.ylabel('QDepth [KBytes]')
    # plt.yticks(range(0, 100, 1))
    axs[0].legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    axs[1].legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    axs[0].set_title("QLR", loc='left')
    axs[1].set_title("NO QLR", loc='left')
    plt.savefig(
        os.path.join(figures_path, f"qdepth.pdf"), format="pdf", bbox_inches='tight'
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

            to_plot['y'].append(np.sum(experiment_results))
        plt.bar(offset, np.mean(to_plot['y']), label=label,
                    linestyle=linestyle, color=color)
        return to_plot['x']

    plt.clf()
    plt.grid(linestyle='--', linewidth=0.5)
    plot_retransmissions_bar("qlr", "green", None, "QLR", "solid", offset=1)
    plot_retransmissions_bar("no-qlr", 'red', None, "NO-QLR", "solid", offset=2)

    plt.xticks([1, 2], ['QLR', 'NO-QLR'])

    plt.ylabel('N. TCP Retransmissions')
    # plt.yticks(range(0, 200, 20))
    #plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    plt.savefig(
        os.path.join(figures_path, f"cumulative_retransmissions_figure.pdf"), format="pdf", bbox_inches='tight'
    )


def plot_cwnd_figure(results):
    def plot_cwnd_line(axes, experiment_type, color, marker, label, linestyle):
        results_path = os.path.join(results, experiment_type)
        to_plot = {}
        for experiment_id in os.listdir(results_path):
            experiment_results_path = os.path.join(results_path, experiment_id, "cwnd")
            for file_name in os.listdir(experiment_results_path):
                if "host1-" not in file_name:
                    continue
                to_plot = parse_data_file(os.path.join(experiment_results_path, file_name))
                to_plot["y"] = [val/1000 for val in to_plot["y"]] 
                label = "-".join(file_name.split("-")[:2])
                axes.plot(to_plot['x'], to_plot['y'], label=label,
                            linestyle=linestyle, fillstyle='none', color=color, marker=marker)
            break
        return to_plot['x']
        
    plt.clf()
    plt.grid(linestyle='--', linewidth=0.5)
    fig, axs = plt.subplots(
        2, 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )   

    plot_cwnd_line(axs[0], "qlr_1", "red", None, "QLR Flows", "solid")
    plot_cwnd_line(axs[1], "qlr_0", 'orange', None, "TCP Flows", "solid")

    plt.xlabel('Time [s]')
    plt.ylabel('Cwnd Size [KB]')

    axs[0].legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    axs[1].legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), labelspacing=0.2, ncols=3, prop={'size': 6})
    axs[0].set_title("QLR", loc='left')
    axs[1].set_title("NO QLR", loc='left')

    plt.savefig(
        os.path.join(figures_path, f"cwnd.pdf"), format="pdf", bbox_inches='tight'
    )


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: plot.py <results_path> <figures_path>")
        exit(1)

    results_path = os.path.abspath(sys.argv[1])
    figures_path = os.path.abspath(sys.argv[2])

    print(f"Results Path: {results_path}")
    print(f"Figures Path: {figures_path}")

    os.makedirs(figures_path, exist_ok=True)

    plt.figure(figsize=(3.5, 2))

    plot_cwnd_figure(results_path)
    plot_cumulative_tcp_retransmission_figure(results_path)
    plot_tcp_retransmission_figure(results_path)
    plot_throughput_figure(results_path)
    plot_qdepth_figure(results_path)

    plt.figure(figsize=(3.5, 10))

    plot_fct_histogram_figure(
        results_path,
        [
            (
                "10.0.1.1",
                "10.0.2.1",
                22222,
                "NO-QLR",
                "red",
                "////",
                os.path.join(results_path, "no-qlr/0/flow_monitor.xml"),
            ),
            (
                "10.0.1.1",
                "10.0.2.1",
                22222,
                "QLR",
                "green",
                "////",
                os.path.join(results_path, "qlr/0/flow_monitor.xml"),
            ),
        ],
    )

    plot_delay_histogram_figure(
        results_path,
        [
            (
                "10.0.1.1",
                "10.0.2.1",
                22222,
                "NO-QLR-1-5",
                "red",
                "////",
                os.path.join(results_path, "no-qlr"),
            ),
            (
                "10.0.1.1",
                "10.0.2.1",
                22222,
                "QLR-1-5",
                "green",
                "////",
                os.path.join(results_path, "qlr"),
            ),
            (
                "10.0.2.1",
                "10.0.2.1",
                22222,
                "NO-QLR-2-5",
                "red",
                "||||",
                os.path.join(results_path, "no-qlr"),
            ),
            (
                "10.0.2.1",
                "10.0.2.1",
                22222,
                "QLR-2-5",
                "green",
                "||||",
                os.path.join(results_path, "qlr"),
            ),
            (
                "10.0.3.1",
                "10.0.2.1",
                22222,
                "NO-QLR-3-5",
                "red",
                "x",
                os.path.join(results_path, "no-qlr"),
            ),
            (
                "10.0.3.1",
                "10.0.2.1",
                22222,
                "QLR-3-5",
                "green",
                "x",
                os.path.join(results_path, "qlr"),
            ),
            (
                "10.0.4.1",
                "10.0.2.1",
                22222,
                "NO-QLR-4-5",
                "red",
                "x",
                os.path.join(results_path, "no-qlr"),
            ),
            (
                "10.0.4.1",
                "10.0.2.1",
                22222,
                "QLR-4-5",
                "green",
                "x",
                os.path.join(results_path, "qlr"),
            ),
        ],
    )

    plot_jitter_histogram_figure(
        results_path,
        [
            (
                "10.0.1.1",
                "10.0.2.1",
                22222,
                "NO-QLR",
                "red",
                "////",
                os.path.join(results_path, "no-qlr/0/flow_monitor.xml"),
            ),
            (
                "10.0.1.1",
                "10.0.2.1",
                22222,
                "QLR",
                "green",
                "////",
                os.path.join(results_path, "qlr/0/flow_monitor.xml"),
            ),
        ],
    )
