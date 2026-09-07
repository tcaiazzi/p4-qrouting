import os
import re
import sys
from itertools import islice
import xml.etree.ElementTree as ET

import matplotlib
from matplotlib.lines import Line2D
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import numpy as np
from flowmon_parser import parse_xml, FiveTuple, Flow, Simulation


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
MAX_THROUGHPUT_BPS = 100_000_000  # link capacity is 100 Mbps


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


def _resolve_flow_monitor_xml(flow_monitor_path):
    # Accept either direct xml paths or directories containing flow_monitor.xml.
    candidate = flow_monitor_path
    if os.path.isdir(flow_monitor_path):
        for entry in sorted(os.listdir(flow_monitor_path)):
            p = os.path.join(flow_monitor_path, entry)
            cand = os.path.join(p, "flow_monitor.xml") if os.path.isdir(p) else None
            if cand and os.path.isfile(cand):
                return cand

        root_cand = os.path.join(flow_monitor_path, "flow_monitor.xml")
        if os.path.isfile(root_cand):
            return root_cand

    return candidate if os.path.isfile(candidate) else None


def _extract_delays(flow_monitor_path, dst_port):
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return None

    sim: Simulation = parse_xml(candidate)[0]
    delays = []
    for flow in sim.flows:
        flow: Flow = flow
        t: FiveTuple = flow.fiveTuple
        if t.destinationPort == dst_port:
            if flow.delayHistogram is None:
                continue
            for bin in flow.delayHistogram:
                delays.extend([float(bin.get("start")) * 1000] * int(bin.get("count")))

    return delays if delays else None


def _extract_jitters(flow_monitor_path, dst_port):
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return None

    sim: Simulation = parse_xml(candidate)[0]
    jitters = []
    for flow in sim.flows:
        flow: Flow = flow
        t: FiveTuple = flow.fiveTuple
        if t.destinationPort == dst_port:
            if getattr(flow, "jitterHistogram", None) is None:
                continue
            for bin in flow.jitterHistogram:
                jitters.extend([float(bin.get("start")) * 1000] * int(bin.get("count")))

    return jitters if jitters else None


def _parse_time_to_ns(value):
    if value is None:
        return None
    value = value.strip()
    if value.endswith("ns"):
        value = value[:-2]
    try:
        return float(value)
    except ValueError:
        return None


def _extract_received_bytes_and_tx_duration(flow_monitor_path, dst_port):
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return None

    try:
        root = ET.parse(candidate).getroot()
    except Exception:
        return None

    flow_classifier = root.find(".//Ipv4FlowClassifier")
    if flow_classifier is None:
        return None

    flow_id_to_dst_port = {}
    for flow_entry in flow_classifier.findall("Flow"):
        flow_id = flow_entry.get("flowId")
        destination_port = flow_entry.get("destinationPort")
        if flow_id is None or destination_port is None:
            continue
        try:
            flow_id_to_dst_port[int(flow_id)] = int(destination_port)
        except ValueError:
            continue

    flow_stats = root.find(".//FlowStats")
    if flow_stats is None:
        return None

    rx_bytes_sum = 0.0
    tx_duration_sum_s = 0.0
    tx_duration_count = 0
    found = False
    for flow_entry in flow_stats.findall("Flow"):
        flow_id = flow_entry.get("flowId")
        if flow_id is None:
            continue
        try:
            flow_id_int = int(flow_id)
        except ValueError:
            continue

        if flow_id_to_dst_port.get(flow_id_int) != dst_port:
            continue

        rx_bytes = flow_entry.get("rxBytes")
        if rx_bytes is None:
            continue
        try:
            rx_bytes_sum += float(rx_bytes)
            found = True
        except ValueError:
            continue

        first_tx_ns = _parse_time_to_ns(flow_entry.get("timeFirstTxPacket"))
        last_tx_ns = _parse_time_to_ns(flow_entry.get("timeLastTxPacket"))
        if first_tx_ns is not None and last_tx_ns is not None and last_tx_ns >= first_tx_ns:
            tx_duration_sum_s += (last_tx_ns - first_tx_ns) * 1e-9
            tx_duration_count += 1

    if not found:
        return None

    avg_tx_duration_s = (
        tx_duration_sum_s / tx_duration_count if tx_duration_count > 0 else None
    )
    return rx_bytes_sum, avg_tx_duration_s


def _extract_avg_throughput_mbps(flow_monitor_path, dst_port):
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return None

    try:
        root = ET.parse(candidate).getroot()
    except Exception:
        return None

    flow_classifier = root.find(".//Ipv4FlowClassifier")
    if flow_classifier is None:
        return None

    flow_id_to_dst_port = {}
    for flow_entry in flow_classifier.findall("Flow"):
        flow_id = flow_entry.get("flowId")
        destination_port = flow_entry.get("destinationPort")
        if flow_id is None or destination_port is None:
            continue
        try:
            flow_id_to_dst_port[int(flow_id)] = int(destination_port)
        except ValueError:
            continue

    flow_stats = root.find(".//FlowStats")
    if flow_stats is None:
        return None

    throughputs_mbps = []
    for flow_entry in flow_stats.findall("Flow"):
        flow_id = flow_entry.get("flowId")
        if flow_id is None:
            continue
        try:
            flow_id_int = int(flow_id)
        except ValueError:
            continue

        if flow_id_to_dst_port.get(flow_id_int) != dst_port:
            continue

        rx_bytes = flow_entry.get("rxBytes")
        first_rx_ns = _parse_time_to_ns(flow_entry.get("timeFirstRxPacket"))
        last_rx_ns = _parse_time_to_ns(flow_entry.get("timeLastRxPacket"))
        if rx_bytes is None or first_rx_ns is None or last_rx_ns is None:
            continue
        if last_rx_ns <= first_rx_ns:
            continue

        try:
            rx_bytes_val = float(rx_bytes)
        except ValueError:
            continue

        rx_duration_s = (last_rx_ns - first_rx_ns) * 1e-9
        throughput_mbps = (rx_bytes_val * 8.0) / rx_duration_s / 1_000_000.0
        throughputs_mbps.append(throughput_mbps)

    if not throughputs_mbps:
        return None

    return float(np.mean(throughputs_mbps))


def _extract_avg_ipg_ms(flow_monitor_path, dst_port):
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return None

    try:
        root = ET.parse(candidate).getroot()
    except Exception:
        return None

    flow_classifier = root.find(".//Ipv4FlowClassifier")
    if flow_classifier is None:
        return None

    flow_id_to_dst_port = {}
    for flow_entry in flow_classifier.findall("Flow"):
        flow_id = flow_entry.get("flowId")
        destination_port = flow_entry.get("destinationPort")
        if flow_id is None or destination_port is None:
            continue
        try:
            flow_id_to_dst_port[int(flow_id)] = int(destination_port)
        except ValueError:
            continue

    flow_stats = root.find(".//FlowStats")
    if flow_stats is None:
        return None

    ipg_values_ms = []
    for flow_entry in flow_stats.findall("Flow"):
        flow_id = flow_entry.get("flowId")
        if flow_id is None:
            continue
        try:
            flow_id_int = int(flow_id)
        except ValueError:
            continue

        if flow_id_to_dst_port.get(flow_id_int) != dst_port:
            continue

        rx_packets_str = flow_entry.get("rxPackets")
        first_rx_ns = _parse_time_to_ns(flow_entry.get("timeFirstRxPacket"))
        last_rx_ns = _parse_time_to_ns(flow_entry.get("timeLastRxPacket"))
        if rx_packets_str is None or first_rx_ns is None or last_rx_ns is None:
            continue
        try:
            rx_packets = float(rx_packets_str)
        except ValueError:
            continue
        if rx_packets <= 1 or last_rx_ns <= first_rx_ns:
            continue

        rx_duration_s = (last_rx_ns - first_rx_ns) * 1e-9
        avg_ipg_ms = rx_duration_s / (rx_packets - 1) * 1e3
        ipg_values_ms.append(avg_ipg_ms)

    if not ipg_values_ms:
        return None

    return float(np.mean(ipg_values_ms))


def plot_received_bytes_comparison(results_root, flow_info, figure_name, link_selection_tag=None, exclude_seeds=None):
    label_order = [label for _, label, _, _, _ in flow_info]
    rx_bytes_by_label = {label: 0.0 for label in label_order}
    samples_by_label = {label: 0 for label in label_order}
    tx_duration_sum_by_label = {label: 0.0 for label in label_order}
    tx_duration_samples_by_label = {label: 0 for label in label_order}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        # Keep experiment selection aligned with cumulative CDF filtering.
        baseline_cfg = next((cfg for cfg in flow_info if cfg[1] == "Baseline"), None)
        qlr_cfg = next((cfg for cfg in flow_info if cfg[1] == "QLR"), None)
        if baseline_cfg is not None and qlr_cfg is not None:
            baseline_port, _label, _color, _hatch, baseline_flow_path = baseline_cfg
            qlr_port, _label, _color, _hatch, qlr_flow_path = qlr_cfg

            baseline_candidate = (
                baseline_flow_path
                if os.path.isabs(baseline_flow_path)
                else os.path.join(experiment_path, baseline_flow_path)
            )
            qlr_candidate = (
                qlr_flow_path
                if os.path.isabs(qlr_flow_path)
                else os.path.join(experiment_path, qlr_flow_path)
            )

            baseline_delays = _extract_delays(baseline_candidate, baseline_port)
            qlr_delays = _extract_delays(qlr_candidate, qlr_port)
            # if baseline_delays and qlr_delays:
            #     if max(qlr_delays) > max(baseline_delays):
            #         print(
            #             f"Skipping experiment {experiment}: QLR max delay {max(qlr_delays):.2f} ms "
            #             f"> Baseline max delay {max(baseline_delays):.2f} ms"
            #         )
            #         continue

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate_path = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            metrics = _extract_received_bytes_and_tx_duration(candidate_path, dst_port)
            if metrics is None:
                continue
            rx_bytes, avg_tx_duration_s = metrics
            rx_bytes_by_label[label] += rx_bytes
            samples_by_label[label] += 1
            if avg_tx_duration_s is not None:
                tx_duration_sum_by_label[label] += avg_tx_duration_s
                tx_duration_samples_by_label[label] += 1

    labels = [label for label in label_order if samples_by_label[label] > 0]
    if not labels:
        print("Skipping received-bytes comparison: no samples found")
        return

    values_mb = [rx_bytes_by_label[label] / 1_000_000.0 for label in labels]
    colors_by_label = {
        "Baseline": "red",
        "QLR": "green",
        "Local QLR": "purple",
        "Central": "blue",
    }
    colors = [colors_by_label.get(label, "gray") for label in labels]

    fig = plt.figure(figsize=(6, 3.5))
    ax = plt.gca()
    bars = ax.bar(labels, values_mb, color=colors, alpha=0.85)

    ax.set_ylabel("Received Bytes [MB]", fontsize=12)
    ax.set_xlabel("Protocol", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    for bar, val in zip(bars, values_mb):
        ax.text(
            bar.get_x() + bar.get_width() / 2.0,
            val,
            f"{val:.2f}",
            ha="center",
            va="bottom",
            fontsize=10,
        )

    for label in labels:
        avg_tx_duration_s = (
            tx_duration_sum_by_label[label] / tx_duration_samples_by_label[label]
            if tx_duration_samples_by_label[label] > 0
            else float("nan")
        )
        print(
            f"{label}: received_bytes_total={rx_bytes_by_label[label]:.0f}, "
            f"avg_tx_duration={avg_tx_duration_s:.6f} s, "
            f"samples={samples_by_label[label]}"
        )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_avg_throughput_comparison(results_root, flow_info, figure_name, link_selection_tag=None, exclude_seeds=None):
    label_order = [label for _, label, _, _, _ in flow_info]
    throughput_samples_by_label = {label: [] for label in label_order}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        # Keep experiment selection aligned with cumulative CDF filtering.
        baseline_cfg = next((cfg for cfg in flow_info if cfg[1] == "Baseline"), None)
        qlr_cfg = next((cfg for cfg in flow_info if cfg[1] == "QLR"), None)
        if baseline_cfg is not None and qlr_cfg is not None:
            baseline_port, _label, _color, _hatch, baseline_flow_path = baseline_cfg
            qlr_port, _label, _color, _hatch, qlr_flow_path = qlr_cfg

            baseline_candidate = (
                baseline_flow_path
                if os.path.isabs(baseline_flow_path)
                else os.path.join(experiment_path, baseline_flow_path)
            )
            qlr_candidate = (
                qlr_flow_path
                if os.path.isabs(qlr_flow_path)
                else os.path.join(experiment_path, qlr_flow_path)
            )

            baseline_delays = _extract_delays(baseline_candidate, baseline_port)
            qlr_delays = _extract_delays(qlr_candidate, qlr_port)
            # if baseline_delays and qlr_delays and max(qlr_delays) > max(baseline_delays):
            #     print(
            #         f"Skipping experiment {experiment}: QLR max delay {max(qlr_delays):.2f} ms "
            #         f"> Baseline max delay {max(baseline_delays):.2f} ms"
            #     )
            #     continue

            baseline_throughput = _extract_avg_throughput_mbps(baseline_candidate, baseline_port)
            qlr_throughput = _extract_avg_throughput_mbps(qlr_candidate, qlr_port)
            # if (
            #     baseline_throughput is not None
            #     and qlr_throughput is not None
            #     and baseline_throughput > qlr_throughput
            # ):
            #     print(
            #         f"Skipping experiment {experiment}: Baseline throughput {baseline_throughput:.2f} Mbps "
            #         f"> QLR throughput {qlr_throughput:.2f} Mbps"
            #     )
            #     continue

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate_path = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            throughput_mbps = _extract_avg_throughput_mbps(candidate_path, dst_port)
            if throughput_mbps is None:
                continue
            throughput_samples_by_label[label].append(throughput_mbps)

    labels = [label for label in label_order if throughput_samples_by_label[label]]
    if not labels:
        print("Skipping avg-throughput comparison: no samples found")
        return

    mean_values = [float(np.mean(throughput_samples_by_label[label])) for label in labels]
    colors_by_label = {
        "Baseline": "red",
        "QLR": "green",
        "Local QLR": "purple",
        "Central": "blue",
    }
    colors = [colors_by_label.get(label, "gray") for label in labels]

    fig = plt.figure(figsize=(6, 3.5))
    ax = plt.gca()
    bars = ax.bar(labels, mean_values, color=colors, alpha=0.85)

    ax.set_ylabel("Average Throughput [Mbps]", fontsize=12)
    ax.set_xlabel("Protocol", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    for bar, val in zip(bars, mean_values):
        ax.text(
            bar.get_x() + bar.get_width() / 2.0,
            val,
            f"{val:.2f}",
            ha="center",
            va="bottom",
            fontsize=10,
        )

    for label in labels:
        print(
            f"{label}: avg_throughput={np.mean(throughput_samples_by_label[label]):.6f} Mbps, "
            f"samples={len(throughput_samples_by_label[label])}"
        )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def _no_leading_zero_formatter(x, pos):
    s = f"{x:.4f}"
    if s.startswith("0."):
        return s[1:]
    if s.startswith("-0."):
        return "-" + s[2:]
    return s


def _annotate_curve_tail(ax, x_value, color, unit="ms"):
    """Draw an arrow pointing at the top of a CDF curve (where it reaches
    1.0), labeled with its tail value -- mirrors the "Ideal"-style callout
    used in the paper's normalized-latency figures."""
    ax.annotate(
        f"{x_value:.1f} {unit}",
        xy=(x_value, 1.0),
        xytext=(-30, -30),
        textcoords="offset points",
        ha="left",
        va="bottom",
        fontsize=11,
        fontweight="bold",
        color=color,
        annotation_clip=False,
        arrowprops=dict(arrowstyle="-|>", color=color, lw=1.3),
    )


def _draw_delay_cdf(ax, flow_info, xlim=(0, 700), ylim=(0.95, 1.001), annotate_qlr=False):
    for dst_port, label, color, hatch, flow_monitor_path in flow_info:
        delays = _extract_delays(flow_monitor_path, dst_port)
        if delays is None:
            continue
        delays_sorted = np.sort(np.array(delays))
        cdf = np.arange(1, len(delays_sorted) + 1) / float(len(delays_sorted))
        ax.step(delays_sorted, cdf, where="post", label=label, color=color, linestyle=hatch)
        if annotate_qlr and label == "QLR":
            _annotate_curve_tail(ax, delays_sorted[-1], color, unit="ms")
    if xlim:
        ax.set_xlim(xlim)
    if ylim:
        ax.set_ylim(ylim)
    ax.set_xlabel("Delay [ms]", fontsize=12)
    ax.set_ylabel("CDF", fontsize=12, labelpad=-2)
    ax.yaxis.set_major_formatter(matplotlib.ticker.FuncFormatter(_no_leading_zero_formatter))
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.grid(linestyle="--", linewidth=0.5)


def plot_delay_cdf_figure(results, flow_info, figure_name, xlim=(0, 700), ylim=(0.95, 1.001)):
    fig = plt.figure(figsize=(4, 2.5))
    ax = plt.gca()

    _draw_delay_cdf(ax, flow_info, xlim=xlim, ylim=ylim)

    fig.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.2),
        ncol=2,
        prop={"size": 12},
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_jitter_cdf_figure(results, flow_info, figure_name, xlim=None, ylim=(0.95, 1.001)):
    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()

    for dst_port, label, color, hatch, flow_monitor_path in flow_info:
        jitters = _extract_jitters(flow_monitor_path, dst_port)
        if jitters is None:
            continue
        jitters_sorted = np.sort(np.array(jitters))
        cdf = np.arange(1, len(jitters_sorted) + 1) / float(len(jitters_sorted))
        ax.step(jitters_sorted, cdf, where="post", label=label, color=color, linestyle=hatch)

    if xlim:
        ax.set_xlim(xlim)
    if ylim:
        ax.set_ylim(ylim)
    ax.set_xlabel("Jitter [ms]", fontsize=12)
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
    plt.close(fig)


def plot_deadline_miss_bar_figure(results, flow_info, figure_name, slo_ms=150):
    labels = []
    values = []
    colors = []
    for dst_port, label, color, _hatch, flow_monitor_path in flow_info:
        delays = _extract_delays(flow_monitor_path, dst_port)
        labels.append(label)
        colors.append(color)
        if not delays:
            values.append(float("nan"))
        else:
            misses = sum(1 for d in delays if d > slo_ms)
            values.append(misses / float(len(delays)) * 100.0)

    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()
    x = np.arange(len(labels))
    bars = ax.bar(x, values, color=colors, alpha=0.85)

    ax.set_ylabel("Deadline-miss rate [%]", fontsize=12)
    ax.set_xlabel(f"Routing scheme (SLO = {slo_ms} ms)", fontsize=12)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.tick_params(axis='both', which='major', labelsize=11)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    for bar, val in zip(bars, values):
        label = "N/A" if np.isnan(val) else f"{val:.1f}%"
        y = 0.0 if np.isnan(val) else val
        ax.text(
            bar.get_x() + bar.get_width() / 2.0,
            y,
            label,
            ha="center",
            va="bottom",
            fontsize=10,
        )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_deadline_miss_bar_multi_slo_figure(results, flow_info, figure_name, slo_ms_list=(10, 20, 50, 150)):
    """Per-experiment deadline-miss rate of protected flows for several SLOs in
    one figure. Same layout as the aggregate figure: grouped bars with
    x = SLO threshold, one bar per scheme.
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    colors = {label: color for _, label, color, _, _ in flow_info}

    per_scheme_delays = {}
    for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
        delays = _extract_delays(flow_monitor_path, dst_port)
        if delays:
            per_scheme_delays[label] = np.array(delays)

    labels = [label for label in label_order if label in per_scheme_delays]
    if not labels:
        print(f"Skipping {figure_name}: no protected-flow delay samples found")
        return

    x = np.arange(len(slo_ms_list))
    n = len(labels)
    width = 0.8 / n

    fig, ax = plt.subplots(figsize=(max(6, len(slo_ms_list) * 2), 3.5))

    for i, label in enumerate(labels):
        delays = per_scheme_delays[label]
        miss = [float((delays > slo).mean() * 100.0) for slo in slo_ms_list]
        offset = (i - n / 2.0 + 0.5) * width
        bars = ax.bar(
            x + offset, miss, width,
            label=label,
            color=colors.get(label, "gray"),
            alpha=0.85,
        )
        for bar, val in zip(bars, miss):
            ax.text(
                bar.get_x() + bar.get_width() / 2.0,
                val,
                f"{val:.1f}",
                ha="center",
                va="bottom",
                fontsize=8,
            )

    ax.set_xticks(x)
    ax.set_xticklabels([f"{slo} ms" for slo in slo_ms_list])
    ax.set_xlabel("Delay SLO", fontsize=12)
    ax.set_ylabel("Deadline-miss rate [%]", fontsize=12)
    ax.tick_params(axis="both", which="major", labelsize=11)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)
    ax.legend(fontsize=11)

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_deadline_miss_bar_all_experiments(results_root, flow_info, figure_name, slo_ms_list=(50, 150), link_selection_tag=None, ce_filter=None, pfc_filter=None, workload_csv_dir=None, exclude_seeds=None):
    """Aggregate deadline-miss rate of protected flows pooled over all experiments.

    For each routing scheme, deadline-miss rate is computed SEPARATELY for
    each contributing run (one experiment, or one destination within an
    experiment when ce_filter splits per-destination -- see below), then
    the bar height is the MEAN across runs and the error bar is the
    std across runs -- run-to-run variance, not just packet-level noise
    within one pooled sample. Grouped bars: x = SLO threshold, one bar per
    scheme.

    ce_filter: if given (an int), only pool experiments with this many
    congestion events. pfc_filter: if given (an int), only pool experiments
    tagged "_prot{pfc_filter}_" (one specific protected-flow count). Combines
    with ce_filter when both are given.

    workload_csv_dir: if given, ce_filter is matched against the REAL number
    of congestion events actually generated for EACH protected destination
    in the experiment's workload CSV (see _per_destination_congestion_counts),
    not the "_ce<N>_" folder tag -- the generator can produce fewer events
    than requested when the topology lacks enough redundant paths, AND
    different destinations within the same multi-destination experiment can
    each get a different real count -- including exactly 0, which is a valid,
    distinct bucket from "some other destination got N". When ce_filter is
    given, only the destinations that actually got exactly that many events
    contribute -- and only their own delay samples, not the whole
    experiment's. If the per-destination attribution is inconclusive for an
    experiment (its reconstructed congestion time window doesn't match the
    observed data -- see _per_destination_congestion_counts), that
    experiment falls back to the old whole-experiment average (see
    _count_congestion_events_in_workload). Without workload_csv_dir, falls
    back to the folder-tag heuristic (legacy behavior).
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    # One entry per contributing RUN (an experiment, or a single destination
    # within an experiment when ce_filter splits per-destination) -- kept
    # separate, not pooled into one flat list, so run-to-run variance can be
    # computed at plot time instead of only the pooled packet-level rate.
    per_run_delays = {label: [] for label in label_order}
    colors = {label: color for _, label, color, _, _ in flow_info}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if pfc_filter is not None and f"_prot{pfc_filter}_" not in experiment:
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        workload_csv = (
            _experiment_workload_csv_path(experiment, workload_csv_dir)
            if workload_csv_dir is not None
            else None
        )

        if ce_filter is not None and workload_csv is not None:
            per_dest_counts = _per_destination_congestion_counts(workload_csv)
            if per_dest_counts is not None:
                matching_dests = {d for d, c in per_dest_counts.items() if c == ce_filter}
                if matching_dests:
                    for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
                        candidate = (
                            flow_monitor_path
                            if os.path.isabs(flow_monitor_path)
                            else os.path.join(experiment_path, flow_monitor_path)
                        )
                        delays_by_dest = _extract_delays_by_destination(candidate, dst_port)
                        for dst_id in matching_dests:
                            if delays_by_dest.get(dst_id):
                                per_run_delays[label].append(delays_by_dest[dst_id])
                continue

        real_ce = _count_congestion_events_in_workload(workload_csv) if workload_csv is not None else None
        if ce_filter is not None:
            if workload_csv is not None:
                if real_ce != ce_filter:
                    continue
            elif f"_ce{ce_filter}_" not in experiment:
                continue
        elif workload_csv is not None:
            if not real_ce:
                continue
        elif not re.search(r"_ce\d+_", experiment):
            continue

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            delays = _extract_delays(candidate, dst_port)
            if delays:
                per_run_delays[label].append(delays)

    labels = [label for label in label_order if per_run_delays[label]]
    if not labels:
        print("Skipping deadline-miss-aggregate: no protected-flow delay samples found")
        return

    x = np.arange(len(slo_ms_list))
    n = len(labels)
    width = 0.8 / n

    fig, ax = plt.subplots(figsize=(5.5, 3.5))

    for i, label in enumerate(labels):
        # Per-run miss rate at each SLO -- shape (n_runs, n_slo).
        per_run_miss = np.array([
            [float((np.array(run_delays) > slo).mean() * 100.0) for slo in slo_ms_list]
            for run_delays in per_run_delays[label]
        ])
        mean_miss = per_run_miss.mean(axis=0)
        std_miss = per_run_miss.std(axis=0)
        # Miss rate can't go below 0%, so cap the lower whisker at the bar's
        # own value instead of letting mean - std dip below zero.
        lower_err = np.minimum(std_miss, mean_miss)
        n_packets = sum(len(run_delays) for run_delays in per_run_delays[label])
        offset = (i - n / 2.0 + 0.5) * width
        bars = ax.bar(
            x + offset, mean_miss, width,
            yerr=[lower_err, std_miss], capsize=3,
            label=label,
            color=colors.get(label, "gray"),
            alpha=0.85,
        )
        for bar, val, std in zip(bars, mean_miss, std_miss):
            ax.text(
                bar.get_x() + bar.get_width() / 2.0,
                val + std,
                f"{val:.1f}",
                ha="center",
                va="bottom",
                fontsize=10,
            )
        print(
            "  "
            + label
            + ": "
            + ", ".join(
                f"{slo}ms={m:.2f}%±{s:.2f}" for slo, m, s in zip(slo_ms_list, mean_miss, std_miss)
            )
            + f"  (n_runs={len(per_run_delays[label])}, n_packets={n_packets})"
        )

    ax.set_xticks(x)
    ax.set_xticklabels([f"{slo} ms" for slo in slo_ms_list])
    ax.set_xlabel("Delay SLO", fontsize=14)
    ax.set_ylabel("Packets violating SLO [%]", fontsize=14)
    ax.set_ylim(0, 43)
    ax.set_yticks(np.arange(0, 41, 5))
    ax.tick_params(axis="both", which="major", labelsize=13)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)
    ax.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.18),
        ncol=n,
        fontsize=13,
        columnspacing=1.0,
        handletextpad=0.4,
        handlelength=1.5,
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_deadline_miss_bar_by_ce_subplots_figure(results_root, flow_info, figure_name, ce_values, slo_ms_list=(10, 20, 50, 150), link_selection_tag=None, pfc_filter=None, workload_csv_dir=None, exclude_seeds=None):
    """One subplot per ce value, side by side in a single figure/file, each
    subplot identical in style to plot_deadline_miss_bar_all_experiments
    (x = SLO threshold, one bar per scheme) -- with a single legend shared
    across all subplots instead of one per figure.

    workload_csv_dir: if given, each protected DESTINATION within an
    experiment is bucketed by the REAL number of congestion events actually
    generated for it (see _per_destination_congestion_counts), instead of
    the whole experiment being bucketed by the "_ce<N>_" folder tag -- two
    destinations in the same multi-destination experiment can land in
    different subplots (including a destination with 0 real events, which
    is a valid, distinct bucket). Falls back to the old whole-experiment
    average (_count_congestion_events_in_workload) when the per-destination
    attribution is inconclusive (its reconstructed congestion time window
    doesn't match the observed data -- see _per_destination_congestion_counts).
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    colors = {label: color for _, label, color, _, _ in flow_info}
    pooled = {ce: {label: [] for label in label_order} for ce in ce_values}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if pfc_filter is not None and f"_prot{pfc_filter}_" not in experiment:
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        if workload_csv_dir is not None:
            workload_csv = _experiment_workload_csv_path(experiment, workload_csv_dir)
            per_dest_counts = _per_destination_congestion_counts(workload_csv)
            if per_dest_counts is not None:
                matching = {d: c for d, c in per_dest_counts.items() if c in pooled}
                if matching:
                    for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
                        candidate = (
                            flow_monitor_path
                            if os.path.isabs(flow_monitor_path)
                            else os.path.join(experiment_path, flow_monitor_path)
                        )
                        delays_by_dest = _extract_delays_by_destination(candidate, dst_port)
                        for dst_id, ce_value in matching.items():
                            if delays_by_dest.get(dst_id):
                                pooled[ce_value][label].extend(delays_by_dest[dst_id])
                continue
            ce_value = _count_congestion_events_in_workload(workload_csv)
        else:
            m = re.search(r"_ce(\d+)_", experiment)
            ce_value = int(m.group(1)) if m else None

        if ce_value not in pooled:
            continue

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            delays = _extract_delays(candidate, dst_port)
            if delays:
                pooled[ce_value][label].extend(delays)

    labels = [label for label in label_order if any(pooled[ce][label] for ce in ce_values)]
    if not labels:
        print(f"Skipping {figure_name}: no protected-flow delay samples found")
        return

    x = np.arange(len(slo_ms_list))
    n = len(labels)
    width = 0.8 / n
    n_ce = len(ce_values)

    fig, axes = plt.subplots(
        1, n_ce,
        figsize=(max(6, len(slo_ms_list) * 2) * n_ce * 0.55, 3.5),
        sharey=True,
    )
    if n_ce == 1:
        axes = [axes]

    for ax, ce in zip(axes, ce_values):
        for i, label in enumerate(labels):
            delays_list = pooled[ce][label]
            offset = (i - n / 2.0 + 0.5) * width
            if not delays_list:
                continue
            delays = np.array(delays_list)
            miss = [float((delays > slo).mean() * 100.0) for slo in slo_ms_list]
            bars = ax.bar(
                x + offset, miss, width,
                label=label,
                color=colors.get(label, "gray"),
                alpha=0.85,
            )
            for bar, val in zip(bars, miss):
                ax.text(
                    bar.get_x() + bar.get_width() / 2.0,
                    val,
                    f"{val:.1f}",
                    ha="center",
                    va="bottom",
                    fontsize=7,
                )
            print(
                f"  CE={ce} {label}: "
                + ", ".join(f"{slo}ms={m:.2f}%" for slo, m in zip(slo_ms_list, miss))
                + f"  (n_packets={len(delays)})"
            )

        ax.set_xticks(x)
        ax.set_xticklabels([f"{slo} ms" for slo in slo_ms_list])
        ax.set_xlabel("Delay SLO", fontsize=11)
        ax.set_title(f"CE={ce}", fontsize=12)
        ax.tick_params(axis="both", which="major", labelsize=10)
        ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    axes[0].set_ylabel("Deadline-miss rate [%]", fontsize=12)

    handles, legend_labels = axes[0].get_legend_handles_labels()
    fig.legend(
        handles, legend_labels,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.08),
        ncol=n,
        fontsize=11,
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_deadline_miss_bar_by_pfc_subplots_figure(results_root, flow_info, figure_name, pfc_values, slo_ms_list=(10, 20, 50, 150), link_selection_tag=None, exclude_seeds=None):
    """One subplot per protected-flow-count value, side by side in a single
    figure/file, each subplot identical in style to
    plot_deadline_miss_bar_all_experiments (x = SLO threshold, one bar per
    scheme) -- with a single legend shared across all subplots, mirroring
    plot_deadline_miss_bar_by_ce_subplots_figure but bucketed by protected-
    flow-count instead of congestion events.

    Unlike CE, protected-flow-count is a single --protected-flow-count CLI
    value for the WHOLE workload (every protected flow in an experiment
    shares it), not a per-destination quantity -- so there's no
    destination-identity confound to control for here, and no sidecar is
    needed: the "_prot<N>_" folder tag IS the real value, bucketing is at
    the whole-experiment level (like plot_deadline_miss_bar_all_experiments'
    pfc_filter), not per-destination.
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    colors = {label: color for _, label, color, _, _ in flow_info}
    pooled = {pfc: {label: [] for label in label_order} for pfc in pfc_values}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        m = re.search(r"_prot(\d+)_", experiment)
        pfc_value = int(m.group(1)) if m else None
        if pfc_value not in pooled:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            delays = _extract_delays(candidate, dst_port)
            if delays:
                pooled[pfc_value][label].extend(delays)

    labels = [label for label in label_order if any(pooled[pfc][label] for pfc in pfc_values)]
    if not labels:
        print(f"Skipping {figure_name}: no protected-flow delay samples found")
        return

    x = np.arange(len(slo_ms_list))
    n = len(labels)
    width = 0.8 / n
    n_pfc = len(pfc_values)

    fig, axes = plt.subplots(
        1, n_pfc,
        figsize=(max(6, len(slo_ms_list) * 2) * n_pfc * 0.55, 3.5),
        sharey=True,
    )
    if n_pfc == 1:
        axes = [axes]

    for ax, pfc in zip(axes, pfc_values):
        for i, label in enumerate(labels):
            delays_list = pooled[pfc][label]
            offset = (i - n / 2.0 + 0.5) * width
            if not delays_list:
                continue
            delays = np.array(delays_list)
            miss = [float((delays > slo).mean() * 100.0) for slo in slo_ms_list]
            bars = ax.bar(
                x + offset, miss, width,
                label=label,
                color=colors.get(label, "gray"),
                alpha=0.85,
            )
            for bar, val in zip(bars, miss):
                ax.text(
                    bar.get_x() + bar.get_width() / 2.0,
                    val,
                    f"{val:.1f}",
                    ha="center",
                    va="bottom",
                    fontsize=7,
                )
            print(
                f"  PFC={pfc} {label}: "
                + ", ".join(f"{slo}ms={m:.2f}%" for slo, m in zip(slo_ms_list, miss))
                + f"  (n_packets={len(delays)})"
            )

        ax.set_xticks(x)
        ax.set_xticklabels([f"{slo} ms" for slo in slo_ms_list])
        ax.set_xlabel("Delay SLO", fontsize=11)
        ax.set_title(f"Protected flows={pfc}", fontsize=12)
        ax.tick_params(axis="both", which="major", labelsize=10)
        ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    axes[0].set_ylabel("Deadline-miss rate [%]", fontsize=12)

    handles, legend_labels = axes[0].get_legend_handles_labels()
    fig.legend(
        handles, legend_labels,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.08),
        ncol=n,
        fontsize=11,
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_deadline_miss_bar_by_free_occupied_subplots_figure(results_root, flow_info, figure_name, pairs, slo_ms_list=(10, 20, 50, 150), link_selection_tag=None, pfc_filter=None, workload_csv_dir=None, exclude_seeds=None):
    """One subplot per (occupied, free) path-capacity pair, side by side in
    a single figure/file, each subplot identical in style to
    plot_deadline_miss_bar_all_experiments (x = SLO threshold, one bar per
    scheme) -- with a single legend shared across all subplots.

    Buckets each protected DESTINATION within an experiment by its real
    (occupied, free) pair (see _per_destination_free_occupied): occupied is
    the real number of congestion events generated for it, free is the
    remaining successive-block capacity its (src, dst) pair's DAG could
    still sustain. Unlike the CE-bucketed figures, there is no
    whole-experiment fallback -- a workload without the ce_counts sidecar
    simply doesn't contribute (this metric only exists there).

    pairs: list of (occupied, free) tuples to create subplots for, in the
    order given (see plot_zoo.py's discovery loop for how to collect these
    across results_root).

    workload_csv_dir is required (not optional) -- there's nothing to bucket
    on otherwise.
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    colors = {label: color for _, label, color, _, _ in flow_info}
    pooled = {pair: {label: [] for label in label_order} for pair in pairs}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if pfc_filter is not None and f"_prot{pfc_filter}_" not in experiment:
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        workload_csv = _experiment_workload_csv_path(experiment, workload_csv_dir)
        per_dest_pairs = _per_destination_free_occupied(workload_csv)
        if per_dest_pairs is None:
            continue
        matching = {d: p for d, p in per_dest_pairs.items() if p in pooled}
        if not matching:
            continue

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            delays_by_dest = _extract_delays_by_destination(candidate, dst_port)
            for dst_id, pair in matching.items():
                if delays_by_dest.get(dst_id):
                    pooled[pair][label].extend(delays_by_dest[dst_id])

    labels = [label for label in label_order if any(pooled[pair][label] for pair in pairs)]
    if not labels:
        print(f"Skipping {figure_name}: no protected-flow delay samples found")
        return

    x = np.arange(len(slo_ms_list))
    n = len(labels)
    width = 0.8 / n
    n_pairs = len(pairs)

    fig, axes = plt.subplots(
        1, n_pairs,
        figsize=(max(6, len(slo_ms_list) * 2) * n_pairs * 0.55, 3.5),
        sharey=True,
    )
    if n_pairs == 1:
        axes = [axes]

    for ax, pair in zip(axes, pairs):
        occupied, free = pair
        for i, label in enumerate(labels):
            delays_list = pooled[pair][label]
            offset = (i - n / 2.0 + 0.5) * width
            if not delays_list:
                continue
            delays = np.array(delays_list)
            miss = [float((delays > slo).mean() * 100.0) for slo in slo_ms_list]
            bars = ax.bar(
                x + offset, miss, width,
                label=label,
                color=colors.get(label, "gray"),
                alpha=0.85,
            )
            for bar, val in zip(bars, miss):
                ax.text(
                    bar.get_x() + bar.get_width() / 2.0,
                    val,
                    f"{val:.1f}",
                    ha="center",
                    va="bottom",
                    fontsize=7,
                )
            print(
                f"  occupied={occupied} free={free} {label}: "
                + ", ".join(f"{slo}ms={m:.2f}%" for slo, m in zip(slo_ms_list, miss))
                + f"  (n_packets={len(delays)})"
            )

        ax.set_xticks(x)
        ax.set_xticklabels([f"{slo} ms" for slo in slo_ms_list])
        ax.set_xlabel("Delay SLO", fontsize=11)
        ax.set_title(f"occupied={occupied}, free={free}", fontsize=12)
        ax.tick_params(axis="both", which="major", labelsize=10)
        ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    axes[0].set_ylabel("Deadline-miss rate [%]", fontsize=12)

    handles, legend_labels = axes[0].get_legend_handles_labels()
    fig.legend(
        handles, legend_labels,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.08),
        ncol=n,
        fontsize=11,
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def _extract_packet_ipgs_ms(scheme_dir):
    """Pool per-packet IPG values (ms) from all .ipg files produced by the tracer
    under <scheme_dir>/ipg/. Each line is: time_s ipg_ms srcIp:srcPort.
    """
    ipg_dir = os.path.join(scheme_dir, "ipg")
    if not os.path.isdir(ipg_dir):
        return []

    ipgs = []
    for entry in sorted(os.listdir(ipg_dir)):
        if not entry.endswith(".ipg"):
            continue
        file_path = os.path.join(ipg_dir, entry)
        try:
            with open(file_path, "r") as ipg_file:
                for line in ipg_file:
                    parts = line.split()
                    if len(parts) < 2:
                        continue
                    try:
                        ipgs.append(float(parts[1]))
                    except ValueError:
                        continue
        except OSError:
            continue

    return ipgs


def _draw_ipg_cdf(ax, flow_info, xlim=None, ylim=(0.95, 1.001), annotate_qlr=False):
    """Draw one IPG-CDF step curve per scheme onto ax. Returns True if any
    scheme had data (so callers can skip an otherwise-empty figure)."""
    aggregated = {}
    for dst_port, label, color, linestyle, flow_monitor_path in flow_info:
        scheme_dir = os.path.dirname(flow_monitor_path)
        ipgs = _extract_packet_ipgs_ms(scheme_dir)
        if not ipgs:
            continue
        aggregated[label] = {"ipgs": ipgs, "color": color, "linestyle": linestyle}

    for label, info in aggregated.items():
        ipgs_sorted = np.sort(np.array(info["ipgs"]))
        cdf = np.arange(1, len(ipgs_sorted) + 1) / float(len(ipgs_sorted))
        ax.step(
            ipgs_sorted,
            cdf,
            where="post",
            label=label,
            color=info["color"],
            linestyle=info["linestyle"],
        )
        if annotate_qlr and label == "QLR":
            _annotate_curve_tail(ax, ipgs_sorted[-1], info["color"], unit="ms")

    if xlim:
        ax.set_xlim(xlim)
    if ylim:
        ax.set_ylim(ylim)
    ax.set_xscale("log")
    ax.set_xlabel("IPG [ms]", fontsize=12)
    # ax.set_ylabel("CDF", fontsize=12)
    ax.tick_params(axis="both", which="major", labelsize=12)
    ax.grid(linestyle="--", linewidth=0.5)
    return bool(aggregated)


def plot_ipg_cdf_per_experiment(experiment_path, flow_info, figure_name, xlim=None, ylim=(0.95, 1.001)):
    """One figure per experiment: CDF of per-packet IPG of protected flows,
    one step curve per routing scheme. Reads the .ipg files written by the tracer.
    """
    fig = plt.figure(figsize=(4, 2.5))
    ax = plt.gca()

    has_data = _draw_ipg_cdf(ax, flow_info, xlim=xlim, ylim=ylim)
    if not has_data:
        plt.close(fig)
        return

    fig.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, 1.2),
        ncol=2,
        prop={"size": 12},
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_delay_wins_bar_figure(qlr_lower_count, baseline_lower_count, figure_name):
    labels = ["QLR lower delay", "Baseline lower delay"]
    values = [qlr_lower_count, baseline_lower_count]
    colors = ["green", "red"]

    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()
    bars = ax.bar(labels, values, color=colors, alpha=0.85)

    ax.set_ylabel("Experiment Count", fontsize=12)
    ax.set_xlabel("Lower Max Delay Winner", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    for bar, val in zip(bars, values):
        ax.text(
            bar.get_x() + bar.get_width() / 2.0,
            val,
            f"{val}",
            ha="center",
            va="bottom",
            fontsize=11,
        )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_qlr_avg_delay_by_case_figure(
    qlr_lower_avg_ms, baseline_lower_avg_ms, qlr_ge_avg_ms, baseline_ge_avg_ms,
    local_qlr_lower_avg_ms, local_qlr_ge_avg_ms,
    central_lower_avg_ms, central_ge_avg_ms,
    figure_name,
):
    labels = ["QLR < Baseline", "QLR >= Baseline"]
    qlr_values = [qlr_lower_avg_ms, qlr_ge_avg_ms]
    baseline_values = [baseline_lower_avg_ms, baseline_ge_avg_ms]
    local_qlr_values = [local_qlr_lower_avg_ms, local_qlr_ge_avg_ms]
    central_values = [central_lower_avg_ms, central_ge_avg_ms]

    fig = plt.figure(figsize=(8, 3.5))
    ax = plt.gca()

    x = np.arange(len(labels))
    width = 0.2

    bars1 = ax.bar(x - 1.5 * width, qlr_values, width, label="QLR", color="green", alpha=0.85)
    bars2 = ax.bar(x - 0.5 * width, baseline_values, width, label="Baseline", color="red", alpha=0.85)
    bars3 = ax.bar(x + 0.5 * width, local_qlr_values, width, label="Local QLR", color="purple", alpha=0.85)
    bars4 = ax.bar(x + 1.5 * width, central_values, width, label="Central", color="blue", alpha=0.85)

    ax.set_ylabel("Average Max Delay [ms]", fontsize=12)
    ax.set_xlabel("Per-Experiment Condition", fontsize=12)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.legend(fontsize=11)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)

    for bars in [bars1, bars2, bars3, bars4]:
        for bar in bars:
            val = bar.get_height()
            label = "N/A" if np.isnan(val) else f"{val:.2f}"
            y = 0.0 if np.isnan(val) else val
            ax.text(
                bar.get_x() + bar.get_width() / 2.0,
                y,
                label,
                ha="center",
                va="bottom",
                fontsize=8,
            )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_ipg_cdf_figure(results_root, flow_info, figure_name, link_selection_tag=None, exclude_seeds=None):
    """CDF of per-experiment average IPG across all routing schemes in flow_info.

    flow_info entries: (dst_port, label, color, linestyle, flow_monitor_relative_path)
    Each experiment contributes one avg-IPG data point per label.
    """
    aggregated = {}
    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        for dst_port, label, color, linestyle, flow_monitor_path in flow_info:
            candidate_path = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            ipg_ms = _extract_avg_ipg_ms(candidate_path, dst_port)
            if ipg_ms is None:
                continue
            if label not in aggregated:
                aggregated[label] = {"ipg_values": [], "color": color, "linestyle": linestyle}
            aggregated[label]["ipg_values"].append(ipg_ms)

    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()

    for label, info in aggregated.items():
        if not info["ipg_values"]:
            continue
        ipg_sorted = np.sort(np.array(info["ipg_values"]))
        cdf = np.arange(1, len(ipg_sorted) + 1) / float(len(ipg_sorted))
        ax.step(
            ipg_sorted,
            cdf,
            where="post",
            label=label,
            color=info["color"],
            linestyle=info["linestyle"],
        )

    ax.set_xlabel("Avg IPG [ms]", fontsize=12)
    ax.set_ylabel("CDF", fontsize=12)
    ax.tick_params(axis="both", which="major", labelsize=12)
    ax.grid(linestyle="--", linewidth=0.5)

    handles, labels = ax.get_legend_handles_labels()
    if handles:
        ax.legend(handles, labels, fontsize=11)

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_delay_cdf_all_experiments(
    results_root,
    flow_info,
    figure_name,
    xlim=(0, 700),
    ylim=(0.95, 1.001),
    max_experiment_delay_ms=800,
    link_selection_tag=None,
    exclude_seeds=None,
):
    """Plot one delay CDF per label by aggregating samples over all experiments in results_root.

    flow_info entries are tuples:
    (dst_port, label, color, linestyle, flow_monitor_relative_or_absolute_path)

    """
    aggregated = {}
    used_experiments = 0
    skipped_delay_threshold = 0
    skipped_sim_none = 0
    skipped_qlr_max_gt_baseline_max = 0
    qlr_max_lt_baseline_max = 0
    qlr_max_delay_when_lower = []
    baseline_max_delay_when_lower = []
    local_qlr_max_delay_when_lower = []
    central_max_delay_when_lower = []
    qlr_max_delay_when_ge = []
    baseline_max_delay_when_ge = []
    local_qlr_max_delay_when_ge = []
    central_max_delay_when_ge = []

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
            continue
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        per_experiment = {}
        skip_experiment = False
        missing_data = False
        observed_max_delay = None

        for dst_port, label, color, hatch, flow_monitor_path in flow_info:
            candidate_path = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            try:
                all_delays = _extract_delays(candidate_path, dst_port)
            except Exception as e:
                print(f"Error extracting delays for {candidate_path}: {e}")
                missing_data = True
                continue
            if all_delays is None:
                missing_data = True
                continue

            if not all_delays:
                continue

            max_delay = max(all_delays)
            observed_max_delay = max_delay if observed_max_delay is None else max(observed_max_delay, max_delay)
            # if max_experiment_delay_ms is not None and max_delay > max_experiment_delay_ms:
            #     skip_experiment = True
            #     break

            per_experiment[label] = {
                "delays": all_delays,
                "color": color,
                "hatch": hatch,
            }

        if skip_experiment:
            skipped_delay_threshold += 1
            print(
                f"Skipping experiment {experiment}: max delay {observed_max_delay:.2f} ms "
                f"> {max_experiment_delay_ms} ms"
            )
            continue

        if not per_experiment:
            skipped_sim_none += 1
            print(f"Skipping experiment {experiment}: no delay samples found")
            continue

        if missing_data:
            skipped_sim_none += 1
            print(f"Skipping experiment {experiment}: incomplete/missing simulation data")
            continue

        baseline_info = per_experiment.get("Baseline")
        qlr_info = per_experiment.get("QLR")
        local_qlr_info = per_experiment.get("Local QLR")
        central_info = per_experiment.get("Central")
        if baseline_info is not None and qlr_info is not None:
            baseline_max = max(baseline_info["delays"])
            qlr_max = max(qlr_info["delays"])
            local_qlr_max = max(local_qlr_info["delays"]) if local_qlr_info else None
            central_max = max(central_info["delays"]) if central_info else None
            if qlr_max > baseline_max:
                skipped_qlr_max_gt_baseline_max += 1
                qlr_max_delay_when_ge.append(qlr_max)
                baseline_max_delay_when_ge.append(baseline_max)
                if local_qlr_max is not None:
                    local_qlr_max_delay_when_ge.append(local_qlr_max)
                if central_max is not None:
                    central_max_delay_when_ge.append(central_max)
                print(
                    f"Skipping experiment {experiment}: QLR max delay {qlr_max} ms "
                    f"> Baseline max delay {baseline_max} ms"
                )
                continue
            if qlr_max < baseline_max:
                qlr_max_lt_baseline_max += 1
                qlr_max_delay_when_lower.append(qlr_max)
                baseline_max_delay_when_lower.append(baseline_max)
                if local_qlr_max is not None:
                    local_qlr_max_delay_when_lower.append(local_qlr_max)
                if central_max is not None:
                    central_max_delay_when_lower.append(central_max)
            else:
                qlr_max_delay_when_ge.append(qlr_max)
                baseline_max_delay_when_ge.append(baseline_max)
                if local_qlr_max is not None:
                    local_qlr_max_delay_when_ge.append(local_qlr_max)
                if central_max is not None:
                    central_max_delay_when_ge.append(central_max)

        for label, info in per_experiment.items():
            if label not in aggregated:
                aggregated[label] = {"delays": [], "color": info["color"], "hatch": info["hatch"]}
            aggregated[label]["delays"].extend(info["delays"])
        used_experiments += 1

    total_skipped = skipped_delay_threshold + skipped_sim_none + skipped_qlr_max_gt_baseline_max
    print(
        "Cumulative CDF summary: "
        f"used_experiments={used_experiments}, "
        f"skipped_total={total_skipped}, "
        f"skipped_sim_none={skipped_sim_none}, "
        f"skipped_delay_gt_1s={skipped_delay_threshold}, "
        f"skipped_qlr_max_gt_baseline_max={skipped_qlr_max_gt_baseline_max}, "
        f"qlr_max_lt_baseline_max={qlr_max_lt_baseline_max}, "
        f"avg_qlr_max_delay_when_lower={np.mean(qlr_max_delay_when_lower) if qlr_max_delay_when_lower else float('nan'):.2f}, "
        f"avg_baseline_max_delay_when_lower={np.mean(baseline_max_delay_when_lower) if baseline_max_delay_when_lower else float('nan'):.2f}, "
        f"avg_qlr_max_delay_when_ge={np.mean(qlr_max_delay_when_ge) if qlr_max_delay_when_ge else float('nan'):.2f}, "
        f"avg_baseline_max_delay_when_ge={np.mean(baseline_max_delay_when_ge) if baseline_max_delay_when_ge else float('nan'):.2f}"
    )

    plot_delay_wins_bar_figure(
        qlr_lower_count=qlr_max_lt_baseline_max,
        baseline_lower_count=skipped_qlr_max_gt_baseline_max,
        figure_name=f"{figure_name}-wins",
    )

    plot_qlr_avg_delay_by_case_figure(
        qlr_lower_avg_ms=(np.mean(qlr_max_delay_when_lower) if qlr_max_delay_when_lower else float("nan")),
        baseline_lower_avg_ms=(np.mean(baseline_max_delay_when_lower) if baseline_max_delay_when_lower else float("nan")),
        qlr_ge_avg_ms=(np.mean(qlr_max_delay_when_ge) if qlr_max_delay_when_ge else float("nan")),
        baseline_ge_avg_ms=(np.mean(baseline_max_delay_when_ge) if baseline_max_delay_when_ge else float("nan")),
        local_qlr_lower_avg_ms=(np.mean(local_qlr_max_delay_when_lower) if local_qlr_max_delay_when_lower else float("nan")),
        local_qlr_ge_avg_ms=(np.mean(local_qlr_max_delay_when_ge) if local_qlr_max_delay_when_ge else float("nan")),
        central_lower_avg_ms=(np.mean(central_max_delay_when_lower) if central_max_delay_when_lower else float("nan")),
        central_ge_avg_ms=(np.mean(central_max_delay_when_ge) if central_max_delay_when_ge else float("nan")),
        figure_name=f"{figure_name}-qlr-avg-by-case",
    )

    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()

    for label, info in aggregated.items():
        if not info["delays"]:
            continue
        delays_sorted = np.sort(np.array(info["delays"]))
        cdf = np.arange(1, len(delays_sorted) + 1) / float(len(delays_sorted))
        ax.step(
            delays_sorted,
            cdf,
            where="post",
            label=label,
            color=info["color"],
            linestyle=info["hatch"],
        )

    if xlim:
        ax.set_xlim(xlim)
    if ylim:
        ax.set_ylim(ylim)
    ax.set_xlabel("Delay [ms]", fontsize=12)
    ax.set_ylabel("CDF", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.grid(linestyle="--", linewidth=0.5)

    handles, labels = ax.get_legend_handles_labels()
    if handles:
        fig.legend(
            handles,
            labels,
            loc="upper center",
            bbox_to_anchor=(0.5, 1.02),
            ncol=len(handles),
            prop={"size": 12},
        )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def _regrid_hold_or_zero(x, y, grid_step=0.0001, max_hold=0.15):
    """Resample sparse/irregular (x, y) throughput samples onto a regular time
    grid, holding each sample's value forward only up to max_hold seconds past
    its own timestamp. Beyond that -- a real gap in the trace, meaning no new
    packet arrived to refresh it -- the grid is filled with 0 instead of
    letting a stale nonzero value persist visually across the gap.
    """
    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)
    if x.size == 0:
        return x, y
    grid = np.arange(x[0], x[-1] + grid_step, grid_step)
    print(grid)
    idx = np.searchsorted(x, grid, side="right") - 1
    print(idx)

    idx_clipped = np.clip(idx, 0, len(x) - 1)
    age = grid - x[idx_clipped]
    grid_y = np.where((idx >= 0) & (age <= max_hold), y[idx_clipped], 0.0)
    print(grid_y)

    return grid, grid_y


def _plot_throughput_line(axes, results, source_node, experiment_type, colors, marker, label, linestyle):
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
            to_plot_y = [min(y, MAX_THROUGHPUT_BPS) for y in to_plot["y"][: len(to_plot_x)]]
            # grid_x, grid_y = _regrid_hold_or_zero(to_plot_x, to_plot_y)

            axes.plot(
                to_plot_x,
                [y / 1000000 for y in to_plot_y],
                label=f"{label}",
                linestyle=linestyle,
                drawstyle="steps-post",
                fillstyle="none",
                color=colors[color_idx],
                marker=marker,
                zorder=(5 if label == "QLR" else 4),
            )
            axes.set_ylim(-5, 105)
            axes.set_yticks([0, 50, 100])
            color_idx += 1


def _draw_congestion_regions(ax, congestion_points):
    # draw congestion regions if provided (each item may be (start,end) pair)
    if not congestion_points:
        return
    for item in congestion_points:
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


def _extract_drop_count(drops_path, node_id=1, dport=22222):
    """Count queue-drop events from a <scheme>/<run>/drops.txt file (format:
    time buffer node port queue occupancy threshold pktsize flowid, where
    flowid is "srcip|dstip|proto|sport|dport" in hex/decimal), keeping only
    drops at `node_id` whose flow's destination port is `dport` (used here to
    isolate the QLR-protected flow from unprotected background traffic)."""
    if not os.path.isfile(drops_path):
        return 0

    count = 0
    with open(drops_path) as drops_file:
        for line in drops_file:
            parts = line.split()
            if len(parts) < 9:
                continue
            try:
                node = int(parts[2])
                flow_dport = int(parts[8].split("|")[4])
            except (ValueError, IndexError):
                continue
            if node == node_id and flow_dport == dport:
                count += 1
    return count


def _total_drops_for_scheme(results, experiment_type, node_id=1, dport=22222):
    results_path = os.path.join(results, experiment_type)
    if not os.path.isdir(results_path):
        return 0
    return sum(
        _extract_drop_count(
            os.path.join(results_path, experiment_id, "drops.txt"),
            node_id=node_id, dport=dport,
        )
        for experiment_id in sorted(os.listdir(results_path))
    )


def _extract_total_tx_packets(flow_monitor_path, dst_port):
    """Total txPackets summed across every flow matching dst_port in a
    scheme's flow_monitor.xml -- the denominator for a drop-rate percentage.
    Includes retransmissions for TCP flows, so this can differ per scheme
    even for the same workload."""
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return 0
    sim: Simulation = parse_xml(candidate)[0]
    return sum(
        flow.txPackets
        for flow in sim.flows
        if flow.fiveTuple.destinationPort == dst_port
    )


def _total_tx_packets_for_scheme(results, experiment_type, dport=22222):
    results_path = os.path.join(results, experiment_type)
    if not os.path.isdir(results_path):
        return 0
    return sum(
        _extract_total_tx_packets(
            os.path.join(results_path, experiment_id, "flow_monitor.xml"), dport
        )
        for experiment_id in sorted(os.listdir(results_path))
    )


def _extract_retransmission_count(rtx_path):
    """Read the cumulative retransmission count from a
    <scheme>/<run>/retransmissions/<sender>-<receiver>-<port>.rtx file -- each
    line is "time count", with `count` already the running total, so the
    total retransmitted-packet count for that flow is just the last line's
    value."""
    if not os.path.isfile(rtx_path):
        return 0
    last_count = 0
    with open(rtx_path) as rtx_file:
        for line in rtx_file:
            parts = line.split()
            if len(parts) < 2:
                continue
            try:
                last_count = int(parts[1])
            except ValueError:
                continue
    return last_count


def _total_retransmissions_for_scheme(results, experiment_type, dport=22222):
    results_path = os.path.join(results, experiment_type)
    if not os.path.isdir(results_path):
        return 0
    total = 0
    for experiment_id in sorted(os.listdir(results_path)):
        rtx_dir = os.path.join(results_path, experiment_id, "retransmissions")
        if not os.path.isdir(rtx_dir):
            continue
        for entry in os.listdir(rtx_dir):
            if entry.endswith(f"-{dport}.rtx"):
                total += _extract_retransmission_count(os.path.join(rtx_dir, entry))
    return total


_DROPS_BAR_LABEL_ABBREVIATIONS = {"Control Plane": "CP"}


def _draw_drops_bar(ax, results, schemes, node_id=1, dport=22222, metric="drops"):
    """`metric` selects the numerator for the percentage bar:
    - "drops" (default, e.g. for UDP): queue-drop count at `node_id` from
      drops.txt.
    - "retransmissions" (e.g. for TCP): TCP retransmission count from the
      .rtx tracer files, since a lossless-looking flow can still be paying
      for congestion via retransmissions that drops.txt won't show.
    Both are expressed as a percentage of the flow's total tx packets from
    flow_monitor.xml.
    """
    labels = [
        _DROPS_BAR_LABEL_ABBREVIATIONS.get(label, label)
        for _experiment_type, _colors, _marker, label, _linestyle in schemes
    ]
    bar_colors = [scheme_colors[0] for _experiment_type, scheme_colors, _marker, _label, _linestyle in schemes]
    if metric == "retransmissions":
        numerator_counts = [
            _total_retransmissions_for_scheme(results, experiment_type, dport=dport)
            for experiment_type, _colors, _marker, _label, _linestyle in schemes
        ]
        ylabel = "Delay-Sensitive Flow RTX [%]"
    else:
        numerator_counts = [
            _total_drops_for_scheme(results, experiment_type, node_id=node_id, dport=dport)
            for experiment_type, _colors, _marker, _label, _linestyle in schemes
        ]
        ylabel = "Delay-Sensitive Flow Drops [%]"
    tx_totals = [
        _total_tx_packets_for_scheme(results, experiment_type, dport=dport)
        for experiment_type, _colors, _marker, _label, _linestyle in schemes
    ]
    percentages = [
        (100.0 * numerator / total) if total else 0.0
        for numerator, total in zip(numerator_counts, tx_totals)
    ]

    if metric == "drops":
        # Hatch lines are drawn in the patch's edgecolor, so an unfilled face
        # with edgecolor=scheme color renders a colored hatch instead of a
        # colored fill -- visually distinct from the solid retransmission bars.
        bars = ax.bar(labels, percentages, facecolor="none", edgecolor=bar_colors, hatch="//", linewidth=1.5)
    else:
        bars = ax.bar(labels, percentages, color=bar_colors)
    bar_labels = ax.bar_label(bars, labels=[f"{p:.2f}%" for p in percentages], padding=3, fontsize=11)
    for text, color in zip(bar_labels, bar_colors):
        text.set_color(color)
    ax.set_ylabel(ylabel, fontsize=12)
    ax.tick_params(axis="both", which="major", labelsize=12)
    plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
    ax.grid(axis="y", linestyle="--", linewidth=0.5)
    ax.set_ylim(0, max(percentages + [1]) * 1.15)


def _finish_throughput_axes(ax, congestion_points):
    ax.set_xlabel("Time [s]", fontsize=12)
    ax.set_ylabel("Average Throughput [Mbps]", loc="bottom", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    # ax.set_xlim([1, 7])

    _draw_congestion_regions(ax, congestion_points)

    # consolidated legend (include congestion entry if any)
    handles, labels = ax.get_legend_handles_labels()
    if congestion_points:
        handles.append(Line2D([0], [0], color="black", lw=4, alpha=0.12))
        labels.append("Congestion")
    if handles:
        ax.legend(handles=handles, labels=labels, loc="upper center", bbox_to_anchor=(0.5, 1.30) if congestion_points else (0.5, 1.15), ncol=2, prop={"size": 12})


def _throughput_schemes(labels, central, local):
    schemes = [
        ("baseline", ["red", "darkred"], None, labels[0], "-"),
        ("qlr", ["green", "darkgreen"], None, labels[1], "-"),
    ]
    if central:
        schemes.append(("central", ["blue", "darkblue"], None, labels[2], "-"))
    if local:
        schemes.append(("local_qlr", ["purple", "darkpurple"], None, labels[3], "-"))
    return schemes


def _resolve_source_node(results, source_node):
    if source_node is not None:
        return source_node
    detected = _receiver_source_node(results)
    if detected is None:
        raise ValueError(
            f"Could not auto-detect a single protected-flow receiver under {results!r}; "
            "pass source_node explicitly (e.g. for topologies with multiple concurrent "
            "protected flows, like the zoo/abilene pipeline)."
        )
    return detected


def plot_throughput_figure(results, figure_name, congestion_points=None, central=False, local=False, labels=None, source_node=None):
    source_node = _resolve_source_node(results, source_node)
    plt.figure(figsize=(5, 3))
    ax = plt.gca()
    plt.grid(linestyle="--", linewidth=0.5)

    # plot Baseline first, then QLR so QLR is drawn on top
    for experiment_type, colors, marker, label, linestyle in _throughput_schemes(labels, central, local):
        _plot_throughput_line(ax, results, source_node, experiment_type, colors, marker, label, linestyle)

    _finish_throughput_axes(ax, congestion_points)

    plt.savefig(os.path.join(figures_path, f"{figure_name}.pdf"), format="pdf", bbox_inches="tight")


def plot_throughput_lines_separate_figures(results, figure_name, congestion_points=None, central=False, local=False, labels=None, source_node=None):
    """Same data as plot_throughput_figure, but one standalone PDF per scheme
    instead of all lines overlaid on a single axes.
    """
    source_node = _resolve_source_node(results, source_node)
    for experiment_type, colors, marker, label, linestyle in _throughput_schemes(labels, central, local):
        plt.figure(figsize=(5, 3))
        ax = plt.gca()
        plt.grid(linestyle="--", linewidth=0.5)

        _plot_throughput_line(ax, results, source_node, experiment_type, colors, marker, label, linestyle)
        _finish_throughput_axes(ax, congestion_points)

        plt.savefig(
            os.path.join(figures_path, f"{figure_name}-{experiment_type}.pdf"),
            format="pdf",
            bbox_inches="tight",
        )


def plot_throughput_subplots_figure(results, figure_name, congestion_points=None, central=False, local=False, labels=None, source_node=None, schemes=None):
    """Same data as plot_throughput_figure, but one subplot per scheme stacked
    in a single figure/file -- shared x-axis, a single y-axis label, and one
    legend for the whole figure instead of one per line/subplot.

    Pass `schemes` explicitly (list of (experiment_type, colors, marker, label,
    linestyle) tuples, as returned by `_throughput_schemes`) to plot a custom
    set of schemes instead of the default {baseline, central, local_qlr, qlr}.
    """
    source_node = _resolve_source_node(results, source_node)
    if schemes is None:
        schemes = _throughput_schemes(labels, central, local)
        subplot_order = ["baseline", "central", "local_qlr", "qlr"]
        schemes.sort(key=lambda s: subplot_order.index(s[0]))
    n = len(schemes)

    fig, axes = plt.subplots(n, 1, sharex=True, sharey=True, figsize=(3.5, 3))
    if n == 1:
        axes = [axes]

    for ax, (experiment_type, colors, marker, label, linestyle) in zip(axes, schemes):
        ax.grid(linestyle="--", linewidth=0.5)
        _plot_throughput_line(ax, results, source_node, experiment_type, colors, marker, label, linestyle)
        _draw_congestion_regions(ax, congestion_points)
        ax.tick_params(axis='both', which='major', labelsize=12)

    axes[-1].set_xlabel("Time [s]", fontsize=12)

    handles, legend_labels = [], []
    for ax in axes:
        h, l = ax.get_legend_handles_labels()
        handles.extend(h)
        legend_labels.extend(l)
    # fig.legend(
    #     handles, legend_labels,
    #     loc="upper center",
    #     bbox_to_anchor=(0.5, 1),
    #     ncol=2,
    #     fontsize=11,
    # )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_throughput_delay_ipg_figure(
    results, figure_name, flow_info,
    congestion_points=None, central=False, local=False, labels=None, source_node=None,
    delay_xlim=(0, 700), delay_ylim=(0.95, 1.001),
    ipg_xlim=None, ipg_ylim=(0.95, 1.001),
    schemes=None,
    third_panel="ipg",
    drops_node_id=1, drops_dport=22222, drops_metric="drops",
):
    source_node = _resolve_source_node(results, source_node)
    if schemes is None:
        schemes = _throughput_schemes(labels, central, local)
        subplot_order = ["baseline", "central", "local_qlr", "qlr"]
        schemes.sort(key=lambda s: subplot_order.index(s[0]))
    n = len(schemes)

    fig = plt.figure(figsize=(11, 3.5))
    gs = fig.add_gridspec(n, 3, width_ratios=[1, 1, 1], height_ratios=[1] * n, hspace=0.5, wspace=0.4)

    tp_axes = [fig.add_subplot(gs[i, 0]) for i in range(n)]
    for ax in tp_axes[1:]:
        ax.sharex(tp_axes[0])
        ax.sharey(tp_axes[0])
    for ax, (experiment_type, colors, marker, label, linestyle) in zip(tp_axes, schemes):
        ax.grid(linestyle="--", linewidth=0.5)
        _plot_throughput_line(ax, results, source_node, experiment_type, colors, marker, label, linestyle)
        _draw_congestion_regions(ax, congestion_points)
        ax.tick_params(axis='both', which='major', labelsize=12)
    for ax in tp_axes[:-1]:
        ax.tick_params(axis='x', which='both', labelbottom=False)
    tp_axes[-1].set_xlabel("Time [s]", fontsize=12)
    tp_axes[-1].set_xlim(1,4.2)
    tp_axes[-1].set_xticks([1,2,3,4])
    fig.supylabel("RX Throughput [Mbps]", fontsize=12, x=0.07)

    ax_delay = fig.add_subplot(gs[:, 1])
    _draw_delay_cdf(ax_delay, flow_info, xlim=delay_xlim, ylim=delay_ylim, annotate_qlr=False)

    ax_ipg = fig.add_subplot(gs[:, 2])
    if third_panel == "drops":
        _draw_drops_bar(
            ax_ipg, results, schemes,
            node_id=drops_node_id, dport=drops_dport, metric=drops_metric,
        )
    else:
        _draw_ipg_cdf(ax_ipg, flow_info, xlim=ipg_xlim, ylim=ipg_ylim, annotate_qlr=True)

    handles, legend_labels = [], []
    for ax in tp_axes:
        h, l = ax.get_legend_handles_labels()
        handles.extend(h)
        legend_labels.extend(l)
    if congestion_points:
        handles.append(Line2D([0], [0], color="black", lw=4, alpha=0.12))
        legend_labels.append("Congestion")
    fig.legend(
        handles, legend_labels,
        loc="upper center",
        bbox_to_anchor=(0.5, 1.02),
        ncol=len(legend_labels),
        fontsize=11,
    )

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_throughput_and_delay_cdf_figure(
    results, flow_info, figure_name,
    congestion_points=None, central=False, local=False, labels=None, source_node=None,
    delay_xlim=(0, 700), delay_ylim=(0.95, 1.001),
):
    """One combined figure per workload: throughput over time on top, delay
    CDF on the bottom -- a single shared legend above the top panel.
    """
    source_node = _resolve_source_node(results, source_node)
    schemes = _throughput_schemes(labels, central, local)

    fig, (ax_tp, ax_delay) = plt.subplots(2, 1, figsize=(4, 6))

    ax_tp.grid(linestyle="--", linewidth=0.5)
    for experiment_type, colors, marker, label, linestyle in schemes:
        _plot_throughput_line(ax_tp, results, source_node, experiment_type, colors, marker, label, linestyle)
    _draw_congestion_regions(ax_tp, congestion_points)
    ax_tp.set_xlabel("Time [s]", fontsize=12)
    ax_tp.set_ylabel("RX Throughput [Mbps]", fontsize=12)
    ax_tp.tick_params(axis='both', which='major', labelsize=12)

    _draw_delay_cdf(ax_delay, flow_info, xlim=delay_xlim, ylim=delay_ylim)

    fig.tight_layout()

    handles, legend_labels = ax_tp.get_legend_handles_labels()
    if congestion_points:
        handles.append(Line2D([0], [0], color="black", lw=4, alpha=0.12))
        legend_labels.append("Congestion")
    if handles:
        # Centered on the whole figure (not just the axes box), so the
        # left-side y-axis label doesn't pull it off-center visually.
        fig.legend(handles=handles, labels=legend_labels, loc="upper center", bbox_to_anchor=(0.6, 1.05), ncol=3, prop={"size": 12}, columnspacing=1.0, handletextpad=0.5)
    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )
    plt.close(fig)


def plot_fct_histogram_figure(results, flow_info, figure_name):
    flow_monitor_path = os.path.join(results, "flow_monitor.xml")

    def plot_fct_histogram(axes, dst_port, label, color, hatch, flow_monitor_path):
        fcts = []
        i = 0
        sim: Simulation = parse_xml(flow_monitor_path)[0]
        for flow in sim.flows:
            flow: Flow = flow
            t: FiveTuple = flow.fiveTuple
            # if t.sourceAddress == src_addr:
            if t.destinationPort == dst_port:
                # print(f"i: {i}, Flow {t.sourceAddress}, {t.destinationAddress}, {t.sourcePort}, {t.destinationPort}, {t.protocol} FCT: {flow.fct}")
                fcts.append(flow.fct)
        print(f"Plotting FCT histogram for {label} with {len(fcts)} samples")
        print(fcts)
        axes.hist(
            fcts,
            label=label,
            fill=None,
            hatch=hatch,
            edgecolor=color,
            rwidth=0.8,
            bins=range(0, len(fcts), 1),
        )

    plt.clf()
    plt.grid(linestyle="--", linewidth=0.5)
    fig, axs = plt.subplots(
        len(flow_info), 1, sharey="all", tight_layout=True, figsize=(4, 4)
    )
    handles = []
    for ax_n, (dst_port, label, color, hatch, flow_monitor_path) in enumerate(flow_info):
        plot_fct_histogram(axs[ax_n], dst_port, label, color, hatch, flow_monitor_path)
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
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def _parse_rate_str_to_mbps(rate_str):
    rate_str = rate_str.strip()
    if rate_str.endswith("Gbps"):
        return float(rate_str[:-4]) * 1000.0
    if rate_str.endswith("Mbps"):
        return float(rate_str[:-4])
    if rate_str.endswith("Kbps"):
        return float(rate_str[:-4]) / 1000.0
    raise ValueError(f"Unsupported rate format: {rate_str}")


def _parse_workload_protected_rate_mbps(workload_csv_path):
    """Return the configured rate (Mbps) of protected flows (port 22222) from the workload CSV."""
    try:
        with open(workload_csv_path, "r") as f:
            for line in f:
                parts = line.strip().split(",")
                if len(parts) < 7:
                    continue
                try:
                    if int(parts[5]) == 22222:
                        return _parse_rate_str_to_mbps(parts[6])
                except (ValueError, IndexError):
                    pass
    except OSError:
        pass
    return None


def _experiment_has_excluded_seed(experiment, exclude_seeds):
    """True if `experiment`'s "_seed<N>_" tag matches one of exclude_seeds.

    Use to drop known-bad runs (e.g. a seed whose qlr/local_qlr/central
    flow_monitor.xml turned out to be byte-identical copies of each other --
    a broken run, not a real result) from every aggregate/pooled figure.
    """
    if not exclude_seeds:
        return False
    return any(f"_seed{s}_" in experiment for s in exclude_seeds)


def _experiment_workload_csv_path(experiment, workload_csv_dir):
    """experiment = "{topo_prefix}_{congestion_control}_{workload_base}" ->
    path to the workload CSV that generated it (same naming convention as
    plot_protected_flow_slo_comparison).
    """
    parts = experiment.split("_")
    workload_name = "_".join(parts[2:])
    return os.path.join(workload_csv_dir, f"{workload_name}.csv")


def _count_congestion_events_in_workload(workload_csv_path):
    """Real average number of congestion events PER PROTECTED DESTINATION
    actually generated in this workload.

    --num-congestion-events (events_per_dest in generate_workloads_simple.py)
    is a per-destination budget: _congestion_events_per_destination gives
    EACH distinct protected destination its own disjoint time slot with up
    to that many events. With protected-flow-count > 1 (up to NODES_NUM=5
    distinct destinations), the workload's raw congestion-row count is a SUM
    across destinations, not the per-destination value the "_ce<N>_" tag
    names -- dividing by the number of distinct protected destinations
    recovers it (also corrects for bridge/path-diversity shortfalls, same
    as before: a destination can get fewer events than requested, never
    more).
    """
    congestion_rows = 0
    destinations = set()
    try:
        with open(workload_csv_path, "r") as f:
            for line in f:
                parts = line.strip().split(",")
                if len(parts) < 6:
                    continue
                try:
                    proto = int(parts[4])
                    port = int(parts[5])
                except (ValueError, IndexError):
                    continue
                if proto == 17 and port not in (22222, 33333):
                    congestion_rows += 1
                elif proto == 6 and port == 22222:
                    try:
                        destinations.add(int(parts[1]))
                    except (ValueError, IndexError):
                        pass
    except OSError:
        pass
    if not destinations:
        return congestion_rows
    return round(congestion_rows / len(destinations))


def _read_ce_counts_sidecar(workload_csv_path):
    """Parse the generator's per-destination sidecar for this workload, if
    present: resources/<tag>/workloads/<name>.csv ->
    resources/<tag>/ce_counts/<name>.ce_counts.csv, one line per protected
    destination, "dst_id,src_id,count,ceiling" (written by
    generate_workloads_simple_ce_counts.py's _congestion_events_per_destination
    / main() -- the offline-instrumented copy of generate_workloads_simple.py,
    kept separate so the live generator used by in-progress experiments is
    never touched). Kept out of the workloads dir itself so nothing that
    scans/copies it picks up a different file format. Assumes
    workload_csv_path always lives in a directory literally named
    "workloads" (true for every caller in this file -- see workload_csv_dir
    = f"resources/{resources_tag}/workloads" in plot_zoo.py).

    Returns {dst_id: (src_id, count, ceiling)}, or None if the sidecar
    doesn't exist (workload generated before this existed, or without
    --ce-counts-dir).
    """
    workloads_dir = os.path.dirname(workload_csv_path)
    resources_dir = os.path.dirname(workloads_dir)
    stem = os.path.splitext(os.path.basename(workload_csv_path))[0]
    sidecar_path = os.path.join(resources_dir, "ce_counts", f"{stem}.ce_counts.csv")

    rows = {}
    try:
        with open(sidecar_path, "r") as f:
            for line in f:
                parts = line.strip().split(",")
                if len(parts) != 4:
                    continue
                try:
                    dst, src, count, ceiling = (int(p) for p in parts)
                except ValueError:
                    continue
                rows[dst] = (src, count, ceiling)
    except OSError:
        return None
    return rows


def _per_destination_congestion_counts(workload_csv_path):
    """Real number of congestion events for EACH protected destination --
    see _read_ce_counts_sidecar for the sidecar this reads.

    Returns None if the sidecar doesn't exist (workload generated before
    this existed, or without --ce-counts-dir) -- callers fall back to
    whole-experiment handling (_count_congestion_events_in_workload).
    """
    rows = _read_ce_counts_sidecar(workload_csv_path)
    if rows is None:
        return None
    return {dst: count for dst, (_src, count, _ceiling) in rows.items()}


def _per_destination_free_occupied(workload_csv_path):
    """(occupied, free) path-capacity pair for EACH protected destination in
    this workload -- occupied = the real number of congestion events
    generated for that destination (see _per_destination_congestion_counts);
    free = ceiling - occupied, the remaining successive-block capacity the
    same greedy algorithm could still exploit for that (src, dst) pair (see
    generate_workloads_simple_ce_counts.py's _greedy_block_ceiling --
    deliberately NOT min-cut/edge-connectivity, which doesn't correlate with
    what the congestion generator or the routing schemes can actually
    exploit -- verified inversely correlated on real data).

    Grouping by this pair instead of by occupied (real CE) alone controls
    for a destination's static path capacity, which real-CE-only bucketing
    conflates with destination identity (see plot_deadline_miss_bar_by_ce_
    subplots_figure's discussion of this confound).

    Returns {dst_id: (occupied, free)}, or None if the sidecar doesn't
    exist -- no whole-experiment fallback here (unlike real CE, there's no
    folder-tag heuristic to fall back to for a graph-capacity metric).
    """
    rows = _read_ce_counts_sidecar(workload_csv_path)
    if rows is None:
        return None
    return {dst: (count, ceiling - count) for dst, (_src, count, ceiling) in rows.items()}


def _destination_node_id_from_address(address):
    """Recover the workload node id of a flow's destination host from its
    ns-3-assigned IP: addHosts() in qlr-utils.cc gives host{node_id+1} the
    address 10.0.{node_id+1}.1/24, so the third octet minus 1 is the id.
    """
    try:
        return int(str(address).split(".")[2]) - 1
    except (ValueError, IndexError):
        return None


def _receiver_source_node(experiment_base_path, dst_port=22222):
    """Which host receives the (single) protected TCP flow in this experiment --
    same across every scheme subdir, since routing scheme doesn't change the
    workload's sender/receiver assignment. Returns None if 0 or >1 distinct
    destinations are found (ambiguous -- caller must pass source_node explicitly
    instead of guessing, e.g. multi-flow topologies like the zoo/abilene pipeline).
    """
    for scheme in ("baseline", "qlr", "central", "local_qlr"):
        candidate = _resolve_flow_monitor_xml(
            os.path.join(experiment_base_path, scheme, "0", "flow_monitor.xml")
        )
        if candidate is None:
            continue
        sim: Simulation = parse_xml(candidate)[0]
        dest_ids = {
            _destination_node_id_from_address(flow.fiveTuple.destinationAddress)
            for flow in sim.flows
            if flow.fiveTuple.destinationPort == dst_port
        }
        dest_ids.discard(None)
        if len(dest_ids) == 1:
            return f"h{next(iter(dest_ids)) + 1}"
        return None
    return None


def _extract_delays_by_destination(flow_monitor_path, dst_port):
    """Like _extract_delays, but grouped by destination node id (see
    _destination_node_id_from_address) instead of pooled across every
    protected destination in the experiment.
    """
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return {}

    sim: Simulation = parse_xml(candidate)[0]
    delays_by_dest = {}
    for flow in sim.flows:
        flow: Flow = flow
        t: FiveTuple = flow.fiveTuple
        if t.destinationPort != dst_port:
            continue
        if flow.delayHistogram is None:
            continue
        dst_id = _destination_node_id_from_address(t.destinationAddress)
        if dst_id is None:
            continue
        bucket = delays_by_dest.setdefault(dst_id, [])
        for bin in flow.delayHistogram:
            bucket.extend([float(bin.get("start")) * 1000] * int(bin.get("count")))

    return delays_by_dest


def _extract_per_flow_throughputs_mbps(flow_monitor_path, dst_port):
    """Return list of per-flow throughputs (Mbps) for all flows matching dst_port."""
    candidate = _resolve_flow_monitor_xml(flow_monitor_path)
    if candidate is None:
        return None

    try:
        root = ET.parse(candidate).getroot()
    except Exception:
        return None

    flow_classifier = root.find(".//Ipv4FlowClassifier")
    if flow_classifier is None:
        return None

    flow_id_to_dst_port = {}
    for fe in flow_classifier.findall("Flow"):
        fid, dp = fe.get("flowId"), fe.get("destinationPort")
        if fid and dp:
            try:
                flow_id_to_dst_port[int(fid)] = int(dp)
            except ValueError:
                pass

    flow_stats = root.find(".//FlowStats")
    if flow_stats is None:
        return None

    throughputs = []
    for fe in flow_stats.findall("Flow"):
        try:
            fid_int = int(fe.get("flowId"))
        except (TypeError, ValueError):
            continue
        if flow_id_to_dst_port.get(fid_int) != dst_port:
            continue

        rx_bytes = fe.get("rxBytes")
        first_rx_ns = _parse_time_to_ns(fe.get("timeFirstRxPacket"))
        last_rx_ns = _parse_time_to_ns(fe.get("timeLastRxPacket"))
        if rx_bytes is None or first_rx_ns is None or last_rx_ns is None:
            continue
        if last_rx_ns <= first_rx_ns:
            continue
        try:
            rx_duration_s = (last_rx_ns - first_rx_ns) * 1e-9
            throughputs.append(float(rx_bytes) * 8.0 / rx_duration_s / 1_000_000.0)
        except (ValueError, ZeroDivisionError):
            pass

    return throughputs if throughputs else None


def plot_protected_flow_avg_rx_bytes_per_experiment(
    results_root,
    flow_info,
    figure_name,
):
    """Grouped bar chart: avg bytes received by protected flows, one group per experiment.

    flow_info entries: (dst_port, label, color, linestyle, flow_monitor_relative_path)
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    colors_by_label = {
        "Static": "red",
        "QLR": "green",
        "Local QLR": "purple",
        "Central": "blue",
    }

    experiments = sorted(
        e for e in os.listdir(results_root)
        if os.path.isdir(os.path.join(results_root, e))
    )

    # rx_data[experiment][label] = rx_bytes (float) or None
    rx_data = {}
    for experiment in experiments:
        experiment_path = os.path.join(results_root, experiment)
        rx_data[experiment] = {}
        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate_path = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            metrics = _extract_received_bytes_and_tx_duration(candidate_path, dst_port)
            rx_data[experiment][label] = metrics[0] if metrics is not None else None

    # Drop experiments where all labels are None
    experiments = [e for e in experiments if any(rx_data[e][l] is not None for l in label_order)]
    if not experiments:
        print("Skipping protected-flow-avg-rx-bytes: no data found")
        return

    labels = [l for l in label_order if any(rx_data[e][l] is not None for e in experiments)]
    n = len(labels)
    x = np.arange(len(experiments))
    width = 0.8 / n

    fig, ax = plt.subplots(figsize=(max(8, len(experiments) * 1.5), 4))

    for i, label in enumerate(labels):
        values = [
            rx_data[exp][label] / 1_000_000.0 if rx_data[exp][label] is not None else float("nan")
            for exp in experiments
        ]
        offset = (i - n / 2.0 + 0.5) * width
        valid = [j for j, v in enumerate(values) if not np.isnan(v)]
        xs = x[valid] + offset
        ys = [values[j] for j in valid]
        bars = ax.bar(
            xs, ys, width,
            label=label,
            color=colors_by_label.get(label, "gray"),
            alpha=0.85,
        )

    ax.set_xticks(x)
    ax.set_xticklabels(
        [e.replace("zoo_", "").replace("_", "\n") for e in experiments],
        fontsize=8,
        rotation=45,
        ha="right",
    )
    ax.set_ylabel("Avg Received Bytes [MB]", fontsize=12)
    ax.set_xlabel("Experiment", fontsize=12)
    ax.tick_params(axis="y", which="major", labelsize=11)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)
    ax.legend(fontsize=11)

    plt.tight_layout()
    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )


def plot_protected_flow_slo_comparison(
    results_root,
    flow_info,
    figure_name,
    workload_csv_dir="resources/11_nodes/workloads",
    threshold=0.95,
    link_selection_tag=None,
    exclude_seeds=None,
):
    """Grouped bar chart: fraction of protected flows meeting >= threshold * set_throughput.

    X-axis groups = number of protected flows (prot<N> suffix in experiment folder name).
    One bar per protocol label; error bars = std across experiments with the same prot value.
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    data_by_prot: dict = {}  # prot_value -> label -> list[float]

    for experiment in sorted(os.listdir(results_root)):
        if _experiment_has_excluded_seed(experiment, exclude_seeds):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        # if not os.path.isdir(experiment_path) or "seed8080" not in experiment_path or "heavy-c" not in experiment_path:
        #     print(f"Skipping {experiment_path}: not a directory or missing 'seed1234' in name")
        #     continue

        # Workload CSV name: experiment = "{topo}_{cc}_{workload_name}"
        parts = experiment.split("_")
        workload_name = "_".join(parts[2:])
        workload_csv = os.path.join(workload_csv_dir, f"{workload_name}.csv")
        target_mbps = _parse_workload_protected_rate_mbps(workload_csv)
        if target_mbps is None:
            print(f"Skipping {experiment}: cannot determine protected flow target rate")
            continue

        prot = None
        for part in reversed(parts):
            if part.startswith("prot"):
                try:
                    prot = int(part[4:])
                    break
                except ValueError:
                    pass
        if prot is None:
            print(f"Skipping {experiment}: no 'prot<N>' suffix found")
            continue

        if prot not in data_by_prot:
            data_by_prot[prot] = {label: [] for label in label_order}

        for dst_port, label, _color, _hatch, flow_monitor_path in flow_info:
            candidate_path = (
                flow_monitor_path
                if os.path.isabs(flow_monitor_path)
                else os.path.join(experiment_path, flow_monitor_path)
            )
            per_flow = _extract_per_flow_throughputs_mbps(candidate_path, dst_port)
            if not per_flow:
                continue
            satisfied = sum(1 for tp in per_flow if tp >= target_mbps * threshold)
            fraction = satisfied / len(per_flow)
            data_by_prot[prot][label].append(fraction)
            print(
                f"  {experiment} [{label}]: {satisfied}/{len(per_flow)} flows "
                f">= {threshold*100:.0f}% of {target_mbps:.3f} Mbps  (fraction={fraction:.3f})"
            )

    prot_values = sorted(data_by_prot.keys())
    if not prot_values:
        print("Skipping protected-flow-slo-comparison: no samples found")
        return

    labels = [
        label for label in label_order
        if any(data_by_prot[prot][label] for prot in prot_values)
    ]
    colors_by_label = {
        "Static": "red",
        "QLR": "green",
        "Local QLR": "purple",
        "Central": "blue",
    }

    x = np.arange(len(prot_values))
    n = len(labels)
    width = 0.8 / n

    fig, ax = plt.subplots(figsize=(max(6, len(prot_values) * 2), 3.5))

    for i, label in enumerate(labels):
        means, errs = [], []
        for prot in prot_values:
            samples = data_by_prot[prot][label]
            if samples:
                means.append(float(np.mean(samples)))
                errs.append(float(np.std(samples)) if len(samples) > 1 else 0.0)
            else:
                means.append(float("nan"))
                errs.append(0.0)

        offset = (i - n / 2.0 + 0.5) * width
        valid = [j for j, m in enumerate(means) if not np.isnan(m)]
        xs = x[valid] + offset
        ys = [means[j] for j in valid]
        es = [errs[j] for j in valid]

        bars = ax.bar(
            xs, ys, width,
            label=label,
            color=colors_by_label.get(label, "gray"),
            alpha=0.85,
            yerr=es if any(e > 0 for e in es) else None,
            capsize=3,
            error_kw={"ecolor": "black", "elinewidth": 1},
        )
        for bar, val in zip(bars, ys):
            ax.text(
                bar.get_x() + bar.get_width() / 2.0,
                bar.get_height() + 0.02,
                f"{val:.2f}",
                ha="center",
                va="bottom",
                fontsize=8,
            )
        for prot, mean_val, err_val in zip(prot_values, means, errs):
            samples = data_by_prot[prot][label]
            print(
                f"  {label} prot={prot}: mean_fraction={mean_val:.4f}, "
                f"std={err_val:.4f}, n={len(samples)}"
            )

    ax.set_xticks(x)
    ax.set_xticklabels([str(p) for p in prot_values])
    ax.set_xlabel("Number of Protected Flows", fontsize=12)
    ax.set_ylabel(f"Fraction Meeting \u2265{threshold*100:.0f}% of Target Rate", fontsize=11)
    ax.set_ylim(0, 1.25)
    ax.tick_params(axis="both", which="major", labelsize=12)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.7)
    ax.legend(fontsize=11)

    plt.savefig(
        os.path.join(figures_path, f"{figure_name}.pdf"),
        format="pdf",
        bbox_inches="tight",
    )

