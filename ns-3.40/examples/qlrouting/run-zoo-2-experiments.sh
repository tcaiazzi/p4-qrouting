#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

congestion_control="${CONGESTION_CONTROL:-TcpLinuxReno}"
dump_traffic="${DUMP_TRAFFIC:-0}"
end_time="${END:-10}"
workload_sim_start="${WORKLOAD_SIM_START:-0.5}"
workload_link_capacity_mbps="${WORKLOAD_LINK_CAPACITY_MBPS:-100}"
workload_probing_rate="${WORKLOAD_PROBING_RATE:-200Kbps}"
workload_duration="${WORKLOAD_DURATION:-$(awk -v e="$end_time" -v s="$workload_sim_start" 'BEGIN{d=e-s; if (d<=0) d=0.001; printf "%.3f", d}')}"
sweep_seeds_csv="${SWEEP_SEEDS:-1234,4321}"
sweep_dry_run="${SWEEP_DRY_RUN:-0}"
workloads_dir="resources/11_nodes/workloads"

# Sweep over protected flow counts (1-100); override with SWEEP_PROTECTED_FLOW_COUNTS
protected_flow_counts_csv="${SWEEP_PROTECTED_FLOW_COUNTS:-25,50,75,100}"

# Protected flow parameters (host vector matches the abilene HOSTS definition in run-zoo-2.sh)
protected_flow_count="${WORKLOAD_PROTECTED_FLOW_COUNT:-5}"  # used only when SWEEP_PROTECTED_FLOW_COUNTS is empty
protected_host_vector="${WORKLOAD_PROTECTED_HOST_VECTOR:-1,1,1,1,1,0,0,0,0,0,0}"
protected_rate="${WORKLOAD_PROTECTED_RATE:-1Mbps}"
protected_packet_size="${WORKLOAD_PROTECTED_PACKET_SIZE:-512}"
protected_number_of_flow="${WORKLOAD_PROTECTED_NUMBER_OF_FLOW:-1}"

IFS=',' read -r -a sweep_seeds <<< "$sweep_seeds_csv"
IFS=',' read -r -a sweep_protected_flow_counts <<< "$protected_flow_counts_csv"

profile_matrix=(
"moderate-b-1000|1.2|1000|1|1.00|0.45|0.25"
"moderate-b-2000|1.2|2000|1|1.00|0.45|0.25"
"heavy-a-1000|1.5|1000|1|1.00|0.45|0.25"
"heavy-a-2000|1.5|2000|1|1.00|0.45|0.25"
"heavy-b-1000|2.5|1000|1|1.00|0.45|0.25"
"heavy-b-2000|2.5|2000|1|1.00|0.45|0.25"
)

mkdir -p "$workloads_dir"

for seed in "${sweep_seeds[@]}"; do
	for profile_entry in "${profile_matrix[@]}"; do
		IFS='|' read -r profile_name congestion_level number_of_lines number_of_flow edge_window_size_factor burst_duration_s burst_gap_mean_s <<< "$profile_entry"

		for pfc in "${sweep_protected_flow_counts[@]}"; do
			workload_base="generated_abilene_${profile_name}_seed${seed}_prot${pfc}"
			generated_workload_file="$workloads_dir/${workload_base}.csv"

			echo "[$profile_name][seed=$seed][protected=$pfc] workload=$generated_workload_file"

			if [[ "$sweep_dry_run" == "1" ]]; then
				echo "DRY_RUN: CONGESTION_CONTROL=$congestion_control END=$end_time WORKLOAD_SIM_START=$workload_sim_start WORKLOAD_DURATION=$workload_duration WORKLOAD_LINK_CAPACITY_MBPS=$workload_link_capacity_mbps WORKLOAD_SEED=$seed WORKLOAD_NUMBER_OF_LINES=$number_of_lines WORKLOAD_NUMBER_OF_FLOW=$number_of_flow WORKLOAD_CONGESTION_LEVEL=$congestion_level WORKLOAD_PROBING_RATE=$workload_probing_rate WORKLOAD_EDGE_WINDOW_SIZE_FACTOR=$edge_window_size_factor WORKLOAD_BURST_DURATION_S=$burst_duration_s WORKLOAD_BURST_GAP_MEAN_S=$burst_gap_mean_s WORKLOAD_PROTECTED_FLOW_COUNT=$pfc WORKLOAD_PROTECTED_HOST_VECTOR=$protected_host_vector WORKLOAD_PROTECTED_RATE=$protected_rate WORKLOAD_PROTECTED_PACKET_SIZE=$protected_packet_size WORKLOAD_PROTECTED_NUMBER_OF_FLOW=$protected_number_of_flow GENERATED_WORKLOAD_FILE=$generated_workload_file DUMP_TRAFFIC=$dump_traffic bash ./run-zoo-2.sh"
				continue
			fi

			CONGESTION_CONTROL="$congestion_control" \
			END="$end_time" \
			WORKLOAD_SIM_START="$workload_sim_start" \
			WORKLOAD_DURATION="$workload_duration" \
			WORKLOAD_LINK_CAPACITY_MBPS="$workload_link_capacity_mbps" \
			WORKLOAD_SEED="$seed" \
			WORKLOAD_NUMBER_OF_LINES="$number_of_lines" \
			WORKLOAD_NUMBER_OF_FLOW="$number_of_flow" \
			WORKLOAD_CONGESTION_LEVEL="$congestion_level" \
			WORKLOAD_PROBING_RATE="$workload_probing_rate" \
			WORKLOAD_EDGE_WINDOW_SIZE_FACTOR="$edge_window_size_factor" \
			WORKLOAD_BURST_DURATION_S="$burst_duration_s" \
			WORKLOAD_BURST_GAP_MEAN_S="$burst_gap_mean_s" \
			WORKLOAD_PROTECTED_FLOW_COUNT="$pfc" \
			WORKLOAD_PROTECTED_HOST_VECTOR="$protected_host_vector" \
			WORKLOAD_PROTECTED_RATE="$protected_rate" \
			WORKLOAD_PROTECTED_PACKET_SIZE="$protected_packet_size" \
			WORKLOAD_PROTECTED_NUMBER_OF_FLOW="$protected_number_of_flow" \
			GENERATED_WORKLOAD_FILE="$generated_workload_file" \
			DUMP_TRAFFIC="$dump_traffic" \
			bash ./run-zoo-2.sh
		done
	done
done

echo "Sweep complete."
