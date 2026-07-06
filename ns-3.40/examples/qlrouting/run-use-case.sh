#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

# ---------------------------------------------------------------------------
# Topology (loaded from external file)
# ---------------------------------------------------------------------------
topology_file="${TOPOLOGY_FILE:-abilene.topology}"
if [[ ! -f "$topology_file" ]]; then
    echo "ERROR: topology file not found: $topology_file" >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$topology_file"
echo "[topology] loaded $topology_file (nodes=$SWITCHES)"

# ---------------------------------------------------------------------------
# Experiment-level settings
# ---------------------------------------------------------------------------
congestion_control="${CONGESTION_CONTROL:-TcpLinuxReno}"
dump_traffic="${DUMP_TRAFFIC:-1}"
end_time="${END:-3}"
controlplane_speed="${CONTROLPLANE_SPEED:-500ms}"

# ---------------------------------------------------------------------------
# Workload generator – global settings
# ---------------------------------------------------------------------------
workload_sim_start="${WORKLOAD_SIM_START:-0.5}"
workload_duration="${WORKLOAD_DURATION:-$(LC_NUMERIC=C awk -v e="$end_time" -v s="$workload_sim_start" \
    'BEGIN{d=e-s; if (d<=0) d=0.001; printf "%.3f", d}')}"
workload_probing_rate="${WORKLOAD_PROBING_RATE:-100Kbps}"
workload_link_capacity_mbps="${WORKLOAD_LINK_CAPACITY_MBPS:-1000}"

# Background flow settings
background_rate="${WORKLOAD_BACKGROUND_RATE:-2Mbps}"
background_packet_sizes="${WORKLOAD_BACKGROUND_PACKET_SIZES:-64,512,1400}"
background_flows_per_link="${WORKLOAD_BACKGROUND_FLOWS_PER_LINK:-1}"
no_background="${WORKLOAD_NO_BACKGROUND:-1}"

# Protected flow settings
protected_host_vector="${WORKLOAD_PROTECTED_HOST_VECTOR:-$HOSTS}"
protected_rate="${WORKLOAD_PROTECTED_RATE:-1Mbps}"
protected_packet_size="${WORKLOAD_PROTECTED_PACKET_SIZE:-512}"
protected_number_of_flow="${WORKLOAD_PROTECTED_NUMBER_OF_FLOW:-1}"

# ---------------------------------------------------------------------------
# Sweep axes
# ---------------------------------------------------------------------------
sweep_seeds_csv="${SWEEP_SEEDS:-1234}"
sweep_protected_flow_counts_csv="${SWEEP_PROTECTED_FLOW_COUNTS:-1}"
sweep_dry_run="${SWEEP_DRY_RUN:-0}"

# Which experiment types to run (1 = enabled, 0 = skip)
run_baseline="${RUN_BASELINE:-1}"
run_central="${RUN_CENTRAL:-1}"
run_local_qlr="${RUN_LOCAL_QLR:-1}"
run_qlr="${RUN_QLR:-1}"

# Topology identity / output isolation.
# topo_prefix defaults to the topology file's basename (abilene.topology ->
# "abilene", abilene-dense.topology -> "abilene-dense"). Both workloads and P4
# commands are placed under resources/<resources_tag>/, keyed by topology name.
topo_prefix="${TOPO_PREFIX:-$(basename "$topology_file" .topology)}"
resources_tag="${RESOURCES_TAG:-$topo_prefix}"

workloads_dir="resources/${resources_tag}/workloads"

IFS=',' read -r -a sweep_seeds               <<< "$sweep_seeds_csv"
IFS=',' read -r -a sweep_protected_flow_counts <<< "$sweep_protected_flow_counts_csv"

# ---------------------------------------------------------------------------
# Profile matrix
# Each entry:  name | bg_rate | bg_pkt_sizes | num_cong_events | cong_rate | cong_pkt_size | cong_dur_min | cong_dur_max | cong_start_frac | cong_end_frac
#   num_cong_events:   number of congestion events (0 = disabled)
#   cong_dur_min/max:  uniform distribution bounds for event duration (seconds)
#   cong_start_frac / cong_end_frac: fractions of duration defining the sampling
#   window for congestion event start times.
# ---------------------------------------------------------------------------
# Speed axis (QLR vs central): sweep the NUMBER of SHORT bursts. Each burst
# (100-250ms) is well below the 500ms control-plane interval, so central keeps
# missing them; as the count grows its disadvantage vs data-plane QLR/local
# accumulates. Baseline never reroutes. dur_min/dur_max are 0.1/0.25.
profile_matrix=(
    # "burst-1|1Mbps|64,512,1400|1|250Mbps|1400|0.25|0.5|0.1|0.1"
    # "burst-2|1Mbps|64,512,1400|2|250Mbps|1400|0.25|0.5|0.1|0.1"
    "burst-3|1Mbps|64,512,1400|3|250Mbps|1400|0.25|0.5|0.1|0.1"
    # "burst-4|1Mbps|64,512,1400|4|250Mbps|1400|0.25|0.5|0.1|0.1"
    # "burst-6|1Mbps|64,512,1400|6|250Mbps|1400|0.25|0.5|0.1|0.1"
    # Long-event variants (central can react to each -> schemes converge):
    # "heavy-2|1Mbps|64,512,1400|2|250Mbps|1400|0.5|2.0|0.2|0.2"
)

mkdir -p "$workloads_dir"

# ---------------------------------------------------------------------------
# Main sweep
# ---------------------------------------------------------------------------
for seed in "${sweep_seeds[@]}"; do
    for profile_entry in "${profile_matrix[@]}"; do
        IFS='|' read -r \
            profile_name \
            bg_rate \
            bg_pkt_sizes \
            num_cong_events \
            cong_rate \
            cong_pkt_size \
            cong_dur_min \
            cong_dur_max \
            cong_start_frac \
            cong_end_frac \
            <<< "$profile_entry"

        # Compute absolute congestion window times
        cong_start_time="$(LC_NUMERIC=C awk -v s="$workload_sim_start" -v d="$workload_duration" -v f="$cong_start_frac" \
            'BEGIN{printf "%.3f", s + d*f}')"
        cong_end_time="$(LC_NUMERIC=C awk -v s="$workload_sim_start" -v d="$workload_duration" -v f="$cong_end_frac" \
            'BEGIN{printf "%.3f", s + d - d*f}')"

        # Compact rate tags
        bg_rate_tag="$(echo "$bg_rate" | sed 's/bps$//')"
        if [[ "${num_cong_events:-0}" -gt 0 ]]; then
            ce_tag="ce${num_cong_events}"
            cr_tag="cr$(echo "$cong_rate" | sed 's/bps$//')"
            dur_tag="dmin${cong_dur_min}dmax${cong_dur_max}"
        else
            ce_tag="ceNone"
            cr_tag="crNone"
            dur_tag="durNone"
        fi

        for pfc in "${sweep_protected_flow_counts[@]}"; do
            workload_base="use_case_${profile_name}_seed${seed}_prot${pfc}_bg${bg_rate_tag}_${ce_tag}_${cr_tag}_${dur_tag}"
            workload_file="$workloads_dir/${workload_base}.csv"

            echo "[$profile_name][seed=$seed][protected=$pfc] workload=$workload_file"

            # ----------------------------------------------------------------
            # Build generate_workloads_simple.py command
            # ----------------------------------------------------------------
            gen_cmd=(
                python3 generate_workloads_simple.py
                --output        "$workload_file"
                --topology-file "$topology_file"
                --sim-start     "$workload_sim_start"
                --duration      "$workload_duration"
                --probing-rate  "$workload_probing_rate"
                --background-rate "$bg_rate"
                --background-packet-sizes "$bg_pkt_sizes"
                --background-flows-per-link "$background_flows_per_link"
                --seed "$seed"
            )

            if [[ "$no_background" == "1" ]]; then
                gen_cmd+=(--no-background)
            fi

            if [[ "$pfc" -gt 0 ]]; then
                gen_cmd+=(
                    --protected-flow-count "$pfc"
                    --protected-host-vector "$protected_host_vector"
                    --protected-rate "$protected_rate"
                    --protected-packet-size "$protected_packet_size"
                    --protected-number-of-flow "$protected_number_of_flow"
                )
            fi

            if [[ "${num_cong_events:-0}" -gt 0 ]]; then
                gen_cmd+=(
                    --num-congestion-events  "$num_cong_events"
                    --congestion-rate        "$cong_rate"
                    --congestion-packet-size "$cong_pkt_size"
                    --congestion-duration-min "$cong_dur_min"
                    --congestion-duration-max "$cong_dur_max"
                    --congestion-start-time  "$cong_start_time"
                    --congestion-end-time    "$cong_end_time"
                    --congestion-mode        per-destination
                )
            fi

            if [[ "$sweep_dry_run" == "1" ]]; then
                echo "DRY_RUN (generate): ${gen_cmd[*]}" >&2
                echo "DRY_RUN (experiment): CONGESTION_CONTROL=$congestion_control END=$end_time" \
                     "WORKLOAD_FILE=examples/qlrouting/$workload_file" \
                     "EDGES=... HOSTS=$HOSTS SWITCHES=$SWITCHES DUMP_TRAFFIC=$dump_traffic bash run_experiment.sh"
                continue
            fi

            # ----------------------------------------------------------------
            # Generate workload
            # ----------------------------------------------------------------
            "${gen_cmd[@]}"

            # ----------------------------------------------------------------
            # Run experiments
            # ----------------------------------------------------------------
            results_dir="${topo_prefix}_${congestion_control}_${workload_base}"

            # --- baseline (no QLR) ---
            if [[ "$run_baseline" == "1" ]]; then
                mkdir -p "results/${results_dir}/baseline/0"

                QLR_ACTIVE=0 \
                P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
                EXPERIMENT_NAME="$topo_prefix" \
                RESOURCES_TAG="$resources_tag" \
                CONGESTION_CONTROL="$congestion_control" \
                WORKLOAD_FILE="examples/qlrouting/$workload_file" \
                DAGS="$DAGS" \
                EDGES="$EDGES" \
                HOSTS="$HOSTS" \
                SWITCHES="$SWITCHES" \
                END="$end_time" \
                DUMP_TRAFFIC="$dump_traffic" \
                bash run_experiment.sh

                cp -R "results/${results_dir}/qlr_0/0/"* "results/${results_dir}/baseline/0/"
                rm -rf "results/${results_dir}/qlr_0"
            fi

            # --- central (slow control plane at CONTROLPLANE_SPEED) ---
            if [[ "$run_central" == "1" ]]; then
                mkdir -p "results/${results_dir}/central/0"

                QLR_ACTIVE=1 \
                P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
                EXPERIMENT_NAME="$topo_prefix" \
                RESOURCES_TAG="$resources_tag" \
                CONGESTION_CONTROL="$congestion_control" \
                WORKLOAD_FILE="examples/qlrouting/$workload_file" \
                DAGS="$DAGS" \
                EDGES="$EDGES" \
                HOSTS="$HOSTS" \
                SWITCHES="$SWITCHES" \
                QLR_UPDATE_INTERVAL="$controlplane_speed" \
                END="$end_time" \
                DUMP_TRAFFIC="$dump_traffic" \
                bash run_experiment.sh

                cp -R "results/${results_dir}/qlr_1/0/"* "results/${results_dir}/central/0/"
                rm -rf "results/${results_dir}/qlr_1"
            fi

            # --- qlr local (fast control plane, local mode) ---
            if [[ "$run_local_qlr" == "1" ]]; then
                mkdir -p "results/${results_dir}/local_qlr/0"

                QLR_ACTIVE=1 \
                P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
                EXPERIMENT_NAME="$topo_prefix" \
                RESOURCES_TAG="$resources_tag" \
                CONGESTION_CONTROL="$congestion_control" \
                WORKLOAD_FILE="examples/qlrouting/$workload_file" \
                DAGS="$DAGS" \
                EDGES="$EDGES" \
                HOSTS="$HOSTS" \
                SWITCHES="$SWITCHES" \
                QLR_MODE=local \
                END="$end_time" \
                DUMP_TRAFFIC="$dump_traffic" \
                bash run_experiment.sh

                cp -R "results/${results_dir}/qlr_1/0/"* "results/${results_dir}/local_qlr/0/"
                rm -rf "results/${results_dir}/qlr_1"
            fi

            # --- qlr (fast control plane, default interval) ---
            if [[ "$run_qlr" == "1" ]]; then
                mkdir -p "results/${results_dir}/qlr/0"

                QLR_ACTIVE=1 \
                P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
                EXPERIMENT_NAME="$topo_prefix" \
                RESOURCES_TAG="$resources_tag" \
                CONGESTION_CONTROL="$congestion_control" \
                WORKLOAD_FILE="examples/qlrouting/$workload_file" \
                DAGS="$DAGS" \
                EDGES="$EDGES" \
                HOSTS="$HOSTS" \
                SWITCHES="$SWITCHES" \
                END="$end_time" \
                DUMP_TRAFFIC="$dump_traffic" \
                bash run_experiment.sh

                cp -R "results/${results_dir}/qlr_1/0/"* "results/${results_dir}/qlr/0/"
                rm -rf "results/${results_dir}/qlr_1"
            fi
        done
    done
done

chmod -R 777 figures 2>/dev/null || true

echo "Sweep complete."
