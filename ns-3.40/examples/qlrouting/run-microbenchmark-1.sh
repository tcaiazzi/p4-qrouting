#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="microbenchmark_1"
CONTROLPLANE_SPEED="200ms"

for WORKLOAD_FILE in \
    "examples/qlrouting/resources/3_nodes/workloads/wl1.csv" \
    "examples/qlrouting/resources/3_nodes/workloads/wl2.csv" \
    "examples/qlrouting/resources/3_nodes/workloads/wl3.csv" \
    "examples/qlrouting/resources/3_nodes/workloads/wl4.csv"
do
WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"


QLR_ACTIVE=0 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=10 bash run_experiment.sh

mkdir -p results/${RESULTS_DIR}/central/0

QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2"  QLR_UPDATE_INTERVAL=${CONTROLPLANE_SPEED} END=10 bash run_experiment.sh

cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/central/0
rm -rf results/${RESULTS_DIR}/qlr_1/0


QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=10 bash run_experiment.sh
done

chmod -R 777 figures

