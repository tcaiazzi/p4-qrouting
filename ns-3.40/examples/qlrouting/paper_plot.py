import os
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


def plot_received_bytes_comparison(results_root, flow_info, figure_name, link_selection_tag=None):
    label_order = [label for _, label, _, _, _ in flow_info]
    rx_bytes_by_label = {label: 0.0 for label in label_order}
    samples_by_label = {label: 0 for label in label_order}
    tx_duration_sum_by_label = {label: 0.0 for label in label_order}
    tx_duration_samples_by_label = {label: 0 for label in label_order}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
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
            if baseline_delays and qlr_delays:
                if max(qlr_delays) > max(baseline_delays):
                    print(
                        f"Skipping experiment {experiment}: QLR max delay {max(qlr_delays):.2f} ms "
                        f"> Baseline max delay {max(baseline_delays):.2f} ms"
                    )
                    continue

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


def plot_avg_throughput_comparison(results_root, flow_info, figure_name, link_selection_tag=None):
    label_order = [label for _, label, _, _, _ in flow_info]
    throughput_samples_by_label = {label: [] for label in label_order}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
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


def plot_delay_cdf_figure(results, flow_info, figure_name, xlim=(0, 700), ylim=(0.95, 1.001)):
    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()

    handles = []
    for dst_port, label, color, hatch, flow_monitor_path in flow_info:
        delays = _extract_delays(flow_monitor_path, dst_port)
        if delays is None:
            continue
        delays_sorted = np.sort(np.array(delays))
        cdf = np.arange(1, len(delays_sorted) + 1) / float(len(delays_sorted))
        ax.step(delays_sorted, cdf, where="post", label=label, color=color, linestyle=hatch)
        # handles.append(mpatches.Patch(fill=None, edgecolor=color, label=label))
    if xlim:
        ax.set_xlim(xlim)
    if ylim:
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


def plot_deadline_miss_bar_all_experiments(results_root, flow_info, figure_name, slo_ms_list=(50, 150), link_selection_tag=None):
    """Aggregate deadline-miss rate of protected flows pooled over all experiments.

    For each routing scheme, concatenate per-packet delays across every experiment,
    then compute the overall fraction exceeding each SLO. Grouped bars:
    x = SLO threshold, one bar per scheme.
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    pooled = {label: [] for label in label_order}
    colors = {label: color for _, label, color, _, _ in flow_info}

    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment or ("ce1" not in experiment and "ce2" not in experiment and "ce3" not in experiment):
            continue
        if link_selection_tag is not None and link_selection_tag not in experiment:
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
                pooled[label].extend(delays)

    labels = [label for label in label_order if pooled[label]]
    if not labels:
        print("Skipping deadline-miss-aggregate: no protected-flow delay samples found")
        return

    x = np.arange(len(slo_ms_list))
    n = len(labels)
    width = 0.8 / n

    fig, ax = plt.subplots(figsize=(max(6, len(slo_ms_list) * 2), 3.5))

    for i, label in enumerate(labels):
        delays = np.array(pooled[label])
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
        print(
            "  "
            + label
            + ": "
            + ", ".join(f"{slo}ms={m:.2f}%" for slo, m in zip(slo_ms_list, miss))
            + f"  (n_packets={len(delays)})"
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


def plot_ipg_cdf_per_experiment(experiment_path, flow_info, figure_name, xlim=None, ylim=(0.95, 1.001)):
    """One figure per experiment: CDF of per-packet IPG of protected flows,
    one step curve per routing scheme. Reads the .ipg files written by the tracer.
    """
    aggregated = {}
    for dst_port, label, color, linestyle, flow_monitor_path in flow_info:
        scheme_dir = os.path.dirname(flow_monitor_path)
        ipgs = _extract_packet_ipgs_ms(scheme_dir)
        if not ipgs:
            continue
        aggregated[label] = {"ipgs": ipgs, "color": color, "linestyle": linestyle}

    if not aggregated:
        return

    fig = plt.figure(figsize=(5, 3))
    ax = plt.gca()

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

    if xlim:
        ax.set_xlim(xlim)
    if ylim:
        ax.set_ylim(ylim)
    ax.set_xlabel("IPG [ms]", fontsize=12)
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


def plot_ipg_cdf_figure(results_root, flow_info, figure_name, link_selection_tag=None):
    """CDF of per-experiment average IPG across all routing schemes in flow_info.

    flow_info entries: (dst_port, label, color, linestyle, flow_monitor_relative_path)
    Each experiment contributes one avg-IPG data point per label.
    """
    aggregated = {}
    for experiment in sorted(os.listdir(results_root)):
        if "bg10" in experiment:
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
        if link_selection_tag is not None and link_selection_tag not in experiment:
            continue
        experiment_path = os.path.join(results_root, experiment)
        if not os.path.isdir(experiment_path):
            continue

        # if "heavy-a-2000" in experiment or "2000" in experiment:
        #     print(f"Skipping experiment {experiment}: matches filter")
        #     continue

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
            if max_experiment_delay_ms is not None and max_delay > max_experiment_delay_ms:
                skip_experiment = True
                break

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


def plot_throughput_figure(results, source_node, figure_name, congestion_points=None, central=False, local=False,labels=None):
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
    plot_throughput_line(ax, "baseline", ["red", "darkred"], None, labels[0], "-.")
    plot_throughput_line(ax, "qlr", ["green", "darkgreen"], None, labels[1], "--")
    if central:
        plot_throughput_line(ax, "central", ["blue", "darkblue"], None, labels[2], ":")
    if local:
        plot_throughput_line(ax, "local_qlr", ["purple", "darkpurple"], None, labels[3], "-")

    ax.set_xlabel("Time [s]", fontsize=12)
    ax.set_ylabel("Average Throughput [Mbps]", loc="bottom", fontsize=12)
    ax.tick_params(axis='both', which='major', labelsize=12)
    # ax.set_xlim([1, 7])

    # draw congestion regions if provided (each item may be (start,end) pair)
    if congestion_points:
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

    # consolidated legend (include congestion entry if any)
    handles, labels = ax.get_legend_handles_labels()
    if congestion_points:
        handles.append(Line2D([0], [0], color="black", lw=4, alpha=0.12))
        labels.append("Congestion")
    if handles:
        ax.legend(handles=handles, labels=labels, loc="upper center", bbox_to_anchor=(0.5, 1.30) if congestion_points else (0.5, 1.15), ncol=2, prop={"size": 12})

    plt.savefig(os.path.join(figures_path, f"{figure_name}.pdf"), format="pdf", bbox_inches="tight")


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
        "Baseline": "red",
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
):
    """Grouped bar chart: fraction of protected flows meeting >= threshold * set_throughput.

    X-axis groups = number of protected flows (prot<N> suffix in experiment folder name).
    One bar per protocol label; error bars = std across experiments with the same prot value.
    """
    label_order = [label for _, label, _, _, _ in flow_info]
    data_by_prot: dict = {}  # prot_value -> label -> list[float]

    for experiment in sorted(os.listdir(results_root)):
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
        "Baseline": "red",
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


if __name__ == "__main__":

        results_path = "results_benchmark"


        ## BENCHMARK 1 
        figures_path = os.path.join("paper_figures","benchmark1")

        os.makedirs(figures_path, exist_ok=True)

        for wl, congestions in [("wl1",[(2.0, 2.3)]) , ("wl2",[(2.0, 2.3), (2.6, 2.9)]) , ("wl3",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]) , ("wl4",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)])]:

            plot_throughput_figure(os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}"), "h1", f"microbenchmark-1-throughput-{wl}", congestion_points=congestions, central=True, labels=["Baseline", "QLR", "Central"])
        
            plot_delay_cdf_figure(
                os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}"),
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "-",
                        os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}", "baseline/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "-.",
                        os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}", "qlr/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Central",
                        "blue",
                        ":",
                        os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}", "central/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "Local",
                        "purple",
                        ":",
                        os.path.join(results_path, f"microbenchmark_1_TcpLinuxReno_{wl}", "local_qlr/0/flow_monitor.xml"),
                    ),
                ],
                f"microbenchmark-1-delay-cdf-{wl}"
            )

        ## BENCHMARK 2
        figures_path = os.path.join("paper_figures","benchmark2")

        os.makedirs(figures_path, exist_ok=True)

        for wl in ["wl1", "wl2", "wl3", "wl4", "wl5", "wl6", "wl7", "wl8", "wl9", "wl10"]:

            plot_throughput_figure(os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}"), "h1", f"microbenchmark-2-throughput-{wl}", congestion_points=[(2.0, 2.6)], labels=["Baseline", "QLR"])
        
            plot_delay_cdf_figure(
                os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}"),
                [
                    (
                        22222,
                        "Baseline",
                        "red",
                        "-",
                        os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}", "baseline/0/flow_monitor.xml"),
                    ),
                    (
                        22222,
                        "QLR",
                        "green",
                        "-.",
                        os.path.join(results_path, f"microbenchmark_2_TcpLinuxReno_{wl}", "qlr/0/flow_monitor.xml"),
                    ),
                ],
                f"microbenchmark-2-delay-cdf-{wl}"
            )
        figures_path = os.path.join("paper_figures","benchmark3")

        os.makedirs(figures_path, exist_ok=True)

        for congestion_control in ["TcpLinuxReno", "TcpVegas"]:
            for wl, congestions in [("wl1",[(2.0, 2.3)]) , ("wl2",[(2.0, 2.3), (2.6, 2.9)]) , ("wl3",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5)]) , ("wl4",[(2.0, 2.3), (2.6, 2.9), (3.2, 3.5), (3.8, 4.1)])]:

                plot_throughput_figure(os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}"), "h1", f"microbenchmark-3-throughput-{congestion_control}-{wl}", congestion_points=congestions, central=True, local=True, labels=["Baseline", "QLR", "Central", "QLR Local"])
        
                plot_delay_cdf_figure(
                    os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}"),
                    [
                        (
                            22222,
                            "Baseline",
                            "red",
                            "-",
                            os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}", "baseline/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "QLR",
                            "green",
                            "-.",
                            os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}", "qlr/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "Central",
                            "blue",
                            ":",
                            os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}", "central/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "QLR Local",
                            "purple",
                            "--",
                            os.path.join(results_path, f"microbenchmark_3_{congestion_control}_{wl}", "local_qlr/0/flow_monitor.xml"),
                        ),
                    ],
                    f"microbenchmark-3-delay-cdf-{congestion_control}-{wl}",
                    ylim=(0.9995, 1.00001) if congestion_control == "TcpVegas" else (0.95, 1.001)
                )

                plot_delay_cdf_all_experiments(
                results_path,
                [
                    (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
                    (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
                ],
                "benchmark3-delay-cdf-cumulative",
                ylim=(0.8, 1.00001),
                xlim=None,
            )

            plot_received_bytes_comparison(
                results_path,
                [
                    (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
                    (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
                ],
                "benchmark3-tx-bytes-comparison",
            )

            plot_avg_throughput_comparison(
                results_path,
                [
                    (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
                    (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
                    (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
                    (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
                ],
                "zoo-avg-throughput-comparison",
            )

        figures_path = os.path.join("paper_figures","zoo")
        results_path = "results"
        

        os.makedirs(figures_path, exist_ok=True)

        for experiment in os.listdir(results_path):
            print(f"Printing figures for experiment {experiment}")
            try:
                experiment_split = experiment.split("_")
                congestion_control = experiment_split[1]
                wl = "_".join(experiment_split[3:])

                plot_throughput_figure(os.path.join(results_path, experiment), "h3", f"zoo-throughput-{congestion_control}-{wl}", central=False, local=False, labels=["Baseline", "QLR", "Central", "QLR Local"])

                plot_delay_cdf_figure(
                    os.path.join(results_path, experiment),
                    [
                        (
                            22222,
                            "Baseline",
                            "red",
                            "-",
                            os.path.join(results_path, experiment, "baseline/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "QLR",
                            "green",
                            "-.",
                            os.path.join(results_path, experiment, "qlr/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "Local QLR",
                            "purple",
                            "--",
                            os.path.join(results_path, experiment, "local_qlr/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "Central",
                            "blue",
                            ":",
                            os.path.join(results_path, experiment, "central/0/flow_monitor.xml"),
                        ),
                    ],
                    f"zoo-delay-cdf-{congestion_control}-{wl}",
                    ylim=(0.8, 1.00001),
                    xlim=None,
                )

                plot_fct_histogram_figure(
                    os.path.join(results_path, experiment),
                    [
                        (
                            22222,
                            "Baseline",
                            "red",
                            "//",
                            os.path.join(results_path, experiment, "baseline/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "QLR",
                            "green",
                            "||",
                            os.path.join(results_path, experiment, "qlr/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "Local QLR",
                            "purple",
                            "\\\\",
                            os.path.join(results_path, experiment, "local_qlr/0/flow_monitor.xml"),
                        ),
                        (
                            22222,
                            "Central",
                            "blue",
                            "+",
                            os.path.join(results_path, experiment, "central/0/flow_monitor.xml"),
                        ),
                        
                    ],
                    f"zoo-fct-histogram-{congestion_control}-{wl}",
                )
            except Exception as e:
                print(f"Error processing experiment {experiment}: {e}")
                continue

        

        plot_delay_cdf_all_experiments(
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

        plot_ipg_cdf_figure(
            results_path,
            [
                (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
                (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
                (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
                (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
            ],
            "zoo-ipg-cdf",
        )

        plot_received_bytes_comparison(
            results_path,
            [
                (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
                (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
                (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
                (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
            ],
            "zoo-rx-bytes-comparison",
        )

        plot_avg_throughput_comparison(
            results_path,
            [
                (22222, "Baseline", "red", "-", "baseline/0/flow_monitor.xml"),
                (22222, "QLR", "green", "-.", "qlr/0/flow_monitor.xml"),
                (22222, "Local QLR", "purple", "--", "local_qlr/0/flow_monitor.xml"),
                (22222, "Central", "blue", ":", "central/0/flow_monitor.xml"),
            ],
            "zoo-avg-throughput-comparison",
        )


        
    

    