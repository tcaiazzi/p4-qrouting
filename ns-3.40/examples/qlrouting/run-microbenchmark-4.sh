#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpVegas}"
EXPERIMENT_NAME="benchmark4"
DUMP_TRAFFIC=0
END=3

for CONGESTION_CONTROL in TcpLinuxReno
do
    for WORKLOAD_FILE in \
        "examples/qlrouting/resources/benchmark_4/workloads/wl3.csv"
    do
        WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
        WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
        RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"

        mkdir -p results/${RESULTS_DIR}/qlr/0

        HYSTERESIS=1 QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=${END} DUMP_TRAFFIC=$DUMP_TRAFFIC bash run_experiment.sh
        cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/qlr/0
        rm -rf results/${RESULTS_DIR}/qlr_1

        mkdir -p results/${RESULTS_DIR}/qlr_no_hysteresis/0

        HYSTERESIS=0 QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=${END} DUMP_TRAFFIC=$DUMP_TRAFFIC bash run_experiment.sh
        cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/qlr_no_hysteresis/0
        rm -rf results/${RESULTS_DIR}/qlr_1
    done
done

chmod -R 777 figures
