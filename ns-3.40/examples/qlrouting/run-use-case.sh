#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

# ---------------------------------------------------------------------------
# Abilene topology (fixed)
# ---------------------------------------------------------------------------
EDGES="0,1;0,10;0,2;1,10;2,9;2,10;3,4;3,6;4,5;4,6;5,6;5,8;6,7;6,8;7,8;7,9;7,10;8,9;9,10"
DAGS="0:1-0,10-0,10-1,2-0,2-10,7-10,9-10,9-2,9-7,6-7,8-9,8-6,8-7,3-6,4-3,4-6,5-4,5-6,5-8;1:0-1,10-0,10-1,2-0,2-10,7-10,9-10,9-2,9-7,6-7,8-9,8-6,8-7,3-6,4-3,4-6,5-4,5-6,5-8;10:0-10,1-0,1-10,2-0,2-10,7-10,9-10,9-2,9-7,6-7,8-9,8-6,8-7,3-6,4-3,4-6,5-4,5-6,5-8;2:0-2,9-10,9-2,10-0,10-2,1-0,1-10,7-10,7-9,8-9,8-7,6-5,6-7,6-8,5-8,3-6,4-3,4-5,4-6;9:2-10,2-9,7-10,7-9,8-9,8-7,10-9,0-10,0-2,6-5,6-7,6-8,5-8,1-0,1-10,3-6,4-3,4-5,4-6;3:4-3,6-3,6-4,5-4,5-6,7-6,8-6,8-5,8-7,9-10,9-7,9-8,10-7,2-0,2-10,2-9,0-10,1-0,1-10;4:3-4,5-4,6-3,6-4,6-5,8-6,8-5,8-7,7-6,9-10,9-7,9-8,10-7,2-0,2-10,2-9,0-10,1-0,1-10;6:3-6,4-3,4-6,5-4,5-6,7-6,8-6,8-5,8-7,9-10,9-7,9-8,10-7,2-0,2-10,2-9,0-10,1-0,1-10;5:4-5,6-4,6-5,8-6,8-5,3-4,3-6,7-6,7-8,9-7,9-8,10-7,10-9,2-10,2-9,0-10,0-2,1-0,1-10;8:5-8,6-5,6-8,7-6,7-8,9-7,9-8,4-3,4-5,4-6,3-6,10-7,10-9,2-10,2-9,0-10,0-2,1-0,1-10;7:6-7,8-6,8-7,9-10,9-7,9-8,10-7,3-6,4-3,4-6,5-4,5-6,5-8,2-0,2-10,2-9,0-10,1-0,1-10"
HOSTS="1,1,1,1,1,0,0,0,0,0,0"
SWITCHES=11

# ---------------------------------------------------------------------------
# Experiment-level settings
# ---------------------------------------------------------------------------
congestion_control="${CONGESTION_CONTROL:-TcpLinuxReno}"
dump_traffic="${DUMP_TRAFFIC:-0}"
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
background_rate="${WORKLOAD_BACKGROUND_RATE:-10Mbps}"
background_packet_sizes="${WORKLOAD_BACKGROUND_PACKET_SIZES:-64,512,1400}"
background_flows_per_link="${WORKLOAD_BACKGROUND_FLOWS_PER_LINK:-1}"

# Protected flow settings
protected_host_vector="${WORKLOAD_PROTECTED_HOST_VECTOR:-$HOSTS}"
protected_rate="${WORKLOAD_PROTECTED_RATE:-10Mbps}"
protected_packet_size="${WORKLOAD_PROTECTED_PACKET_SIZE:-512}"
protected_number_of_flow="${WORKLOAD_PROTECTED_NUMBER_OF_FLOW:-1}"

# ---------------------------------------------------------------------------
# Sweep axes
# ---------------------------------------------------------------------------
sweep_seeds_csv="${SWEEP_SEEDS:-1234}"
sweep_protected_flow_counts_csv="${SWEEP_PROTECTED_FLOW_COUNTS:-5, 10}"
sweep_dry_run="${SWEEP_DRY_RUN:-0}"

workloads_dir="resources/11_nodes/workloads"

IFS=',' read -r -a sweep_seeds               <<< "$sweep_seeds_csv"
IFS=',' read -r -a sweep_protected_flow_counts <<< "$sweep_protected_flow_counts_csv"

# ---------------------------------------------------------------------------
# Profile matrix
# Each entry:  name | bg_rate | bg_pkt_sizes | cong_targets | cong_rate | cong_pkt_size | burst_dur | burst_gap | target_shift | cong_start_frac | cong_end_frac
#   cong_start_frac / cong_end_frac: fractions of duration added to sim_start /
#   subtracted from sim_end to define the congestion window.
#   Use "" for cong_targets to disable congestion.
# ---------------------------------------------------------------------------
profile_matrix=(
    "light|10Mbps|64,512,1400|||1400|1.0|1.0|1.0|0.2|0.2"
    "heavy-single|10Mbps|64,512,1400|0|50Mbps|1400|1.0|1.0|1.0|0.2|0.2"
    "heavy-multi|10Mbps|64,512,1400|0,5|50Mbps|1400|1.0|1.0|0.5,1.0,1.5|0.2|0.2"
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
            cong_targets \
            cong_rate \
            cong_pkt_size \
            burst_dur \
            burst_gap \
            target_shift \
            cong_start_frac \
            cong_end_frac \
            <<< "$profile_entry"

        # Compute absolute congestion window times
        cong_start_time="$(LC_NUMERIC=C awk -v s="$workload_sim_start" -v d="$workload_duration" -v f="$cong_start_frac" \
            'BEGIN{printf "%.3f", s + d*f}')"
        cong_end_time="$(LC_NUMERIC=C awk -v s="$workload_sim_start" -v d="$workload_duration" -v f="$cong_end_frac" \
            'BEGIN{printf "%.3f", s + d - d*f}')"

        # Compact rate tags: "10Mbps" → "10M", "100Kbps" → "100K", "1Gbps" → "1G"
        bg_rate_tag="$(echo "$bg_rate" | sed 's/bps$//')"
        if [[ -n "$cong_targets" ]]; then
            ct_tag="ct$(echo "$cong_targets" | tr ',' '-')"
            cr_tag="cr$(echo "$cong_rate" | sed 's/bps$//')"
            burst_tag="bd${burst_dur}bg${burst_gap}"
        else
            ct_tag="ctNone"
            cr_tag="crNone"
            burst_tag="bdNone"
        fi

        for pfc in "${sweep_protected_flow_counts[@]}"; do
            workload_base="use_case_${profile_name}_seed${seed}_prot${pfc}_bg${bg_rate_tag}_${ct_tag}_${cr_tag}_${burst_tag}"
            workload_file="$workloads_dir/${workload_base}.csv"

            echo "[$profile_name][seed=$seed][protected=$pfc] workload=$workload_file"

            # ----------------------------------------------------------------
            # Build generate_workloads_simple.py command
            # ----------------------------------------------------------------
            gen_cmd=(
                python3 generate_workloads_simple.py
                --output "$workload_file"
                --edges "$EDGES"
                --dags  "$DAGS"
                --sim-start "$workload_sim_start"
                --duration  "$workload_duration"
                --probing-rate "$workload_probing_rate"
                --background-rate "$bg_rate"
                --background-packet-sizes "$bg_pkt_sizes"
                --background-flows-per-link "$background_flows_per_link"
                --seed "$seed"
            )

            if [[ "$pfc" -gt 0 ]]; then
                gen_cmd+=(
                    --protected-flow-count "$pfc"
                    --protected-host-vector "$protected_host_vector"
                    --protected-rate "$protected_rate"
                    --protected-packet-size "$protected_packet_size"
                    --protected-number-of-flow "$protected_number_of_flow"
                )
            fi

            if [[ -n "$cong_targets" ]]; then
                gen_cmd+=(
                    --congestion-target      "$cong_targets"
                    --congestion-rate        "$cong_rate"
                    --congestion-packet-size "$cong_pkt_size"
                    --congestion-burst-duration "$burst_dur"
                    --congestion-burst-gap   "$burst_gap"
                    --congestion-target-shift "$target_shift"
                    --congestion-start-time  "$cong_start_time"
                    --congestion-end-time    "$cong_end_time"
                )
            fi

            if [[ "$sweep_dry_run" == "1" ]]; then
                echo "DRY_RUN (generate): ${gen_cmd[*]}"
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
            results_dir="abilene_${congestion_control}_${workload_base}"

            # --- baseline (no QLR) ---
            mkdir -p "results/${results_dir}/baseline/0"

            QLR_ACTIVE=0 \
            P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
            P4_COMMANDS="examples/qlrouting/resources/" \
            EXPERIMENT_NAME="abilene" \
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
            rm -rf "results/${results_dir}/qlr_0/0"

            # --- central (slow control plane at CONTROLPLANE_SPEED) ---
            mkdir -p "results/${results_dir}/central/0"

            QLR_ACTIVE=1 \
            P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
            P4_COMMANDS="examples/qlrouting/resources/" \
            EXPERIMENT_NAME="abilene" \
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
            rm -rf "results/${results_dir}/qlr_1/0"

            # --- qlr local (fast control plane, local mode) ---
            mkdir -p "results/${results_dir}/local_qlr/0"

            QLR_ACTIVE=1 \
            P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
            P4_COMMANDS="examples/qlrouting/resources/" \
            EXPERIMENT_NAME="abilene" \
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
            rm -rf "results/${results_dir}/qlr_1/0"

            # --- qlr (fast control plane, default interval) ---
            mkdir -p "results/${results_dir}/qlr/0"

            QLR_ACTIVE=1 \
            P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json \
            P4_COMMANDS="examples/qlrouting/resources/" \
            EXPERIMENT_NAME="abilene" \
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
            rm -rf "results/${results_dir}/qlr_1/0"
        done
    done
done

chmod -R 777 figures 2>/dev/null || true

echo "Sweep complete."
