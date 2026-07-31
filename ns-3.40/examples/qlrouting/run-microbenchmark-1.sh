#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="microbenchmark_1"
CONTROLPLANE_SPEED="500ms"
END=4

for WORKLOAD_FILE in \
    "examples/qlrouting/resources/3_nodes/workloads/wl3.csv"
do
WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
END=4

QLR_ACTIVE=0 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=${END} bash run_experiment.sh

mkdir -p results/${RESULTS_DIR}/baseline/0
cp -R results/${RESULTS_DIR}/qlr_0/0/* results/${RESULTS_DIR}/baseline/0
rm -rf results/${RESULTS_DIR}/qlr_0

mkdir -p results/${RESULTS_DIR}/central/0

QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2"  QLR_UPDATE_INTERVAL=${CONTROLPLANE_SPEED} END=${END} bash run_experiment.sh

cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/central/0
rm -rf results/${RESULTS_DIR}/qlr_1/0

mkdir -p results/${RESULTS_DIR}/local_qlr/0

QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2"  QLR_MODE=local END=${END} bash run_experiment.sh

cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/local_qlr/0
rm -rf results/${RESULTS_DIR}/qlr_1/0

QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" END=${END} bash run_experiment.sh

mkdir -p results/${RESULTS_DIR}/qlr/0
cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/qlr/0
rm -rf results/${RESULTS_DIR}/qlr_1
done

chmod -R 777 figures

