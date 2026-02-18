#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="microbenchmark_2"
for CONGESTION_CONTROL in TcpLinuxReno
do
    for WORKLOAD_FILE in \
        "examples/qlrouting/resources/5_nodes/workloads2/wl1.csv" \
        "examples/qlrouting/resources/5_nodes/workloads2/wl7.csv" \
        "examples/qlrouting/resources/5_nodes/workloads2/wl8.csv" \
        "examples/qlrouting/resources/5_nodes/workloads2/wl9.csv" \
        "examples/qlrouting/resources/5_nodes/workloads2/wl10.csv"
    do
        WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
        WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
        RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
        QLR_ACTIVE=0 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" END=10 bash run_experiment.sh
        QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" END=10 bash run_experiment.sh
        python3 plot.py results/${RESULTS_DIR} figures/${RESULTS_DIR}
    done
done

chmod -R 777 figures

