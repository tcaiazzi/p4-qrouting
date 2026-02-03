#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="microbenchmark_3"

DATAPLANE_SPEED="200ns"
CONTROLPLANE_SPEED="10us"

for WORKLOAD_FILE in \
    "examples/qlrouting/resources/microbenchmark_3/workloads/wl2.csv" #\
    # "examples/qlrouting/resources/microbenchmark_3/workloads/wl2.csv" \
    # "examples/qlrouting/resources/microbenchmark_3/workloads/wl3.csv" \
    # "examples/qlrouting/resources/microbenchmark_3/workloads/wl4.csv" \
    # "examples/qlrouting/resources/microbenchmark_3/workloads/wl5.csv" 
do
WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
# QLR_ACTIVE=1 EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" QLR_UPDATE_INTERVAL=${DATAPLANE_SPEED} END=10 bash run_experiment.sh
QLR_ACTIVE=1 EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" QLR_UPDATE_INTERVAL=${CONTROLPLANE_SPEED} END=10 bash run_experiment.sh
mkdir -p results/${RESULTS_DIR}/qlr_0/0
# mv results/${RESULTS_DIR}/qlr_1/${DATAPLANE_SPEED}/* results/${RESULTS_DIR}/qlr_1/0
# rm -rf results/${RESULTS_DIR}/qlr_1/${DATAPLANE_SPEED}
mv results/${RESULTS_DIR}/qlr_1/${CONTROLPLANE_SPEED}/* results/${RESULTS_DIR}/qlr_0/0
rm -rf results/${RESULTS_DIR}/qlr_1/${CONTROLPLANE_SPEED}   
python3 plot.py results/${RESULTS_DIR} figures/${RESULTS_DIR}
done

chmod -R 777 figures

