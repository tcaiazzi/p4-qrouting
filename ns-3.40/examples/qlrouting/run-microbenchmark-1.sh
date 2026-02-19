#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="microbenchmark_1"

# for WORKLOAD_FILE in \
#     "examples/qlrouting/resources/3_nodes/workloads/wl1.csv" \
#     "examples/qlrouting/resources/3_nodes/workloads/wl2.csv" \
#     "examples/qlrouting/resources/3_nodes/workloads/wl3.csv" \
#     "examples/qlrouting/resources/3_nodes/workloads/wl4.csv"
# do
# WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
# WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
# RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
# # QLR_ACTIVE=0 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=10 bash run_experiment.sh

# QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=10 bash run_experiment.sh
# # MODE=central P4_PROGRAM=examples/qlrouting/fwd_build/fwd.json EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=10 bash run_experiment.sh
# python3 plot.py results/${RESULTS_DIR} figures/${RESULTS_DIR}
# done


for WORKLOAD_FILE in \
    "examples/qlrouting/resources/3_nodes/workloads_central/wl1.csv" \
    "examples/qlrouting/resources/3_nodes/workloads_central/wl2.csv" \
    "examples/qlrouting/resources/3_nodes/workloads_central/wl3.csv" \
    "examples/qlrouting/resources/3_nodes/workloads_central/wl4.csv"
do
WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
MODE=central P4_PROGRAM=examples/qlrouting/fwd_build/fwd.json EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=10 bash run_experiment.sh
python3 plot.py results/${RESULTS_DIR} figures/${RESULTS_DIR}
done

chmod -R 777 figures

