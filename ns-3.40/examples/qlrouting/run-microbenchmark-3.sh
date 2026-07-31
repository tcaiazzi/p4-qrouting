#!/bin/bash

set -e

CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="microbenchmark_3"
CONTROLPLANE_SPEED="500ms"
DUMP_TRAFFIC=0
END=4

for WORKLOAD_FILE in \
    "examples/qlrouting/resources/microbenchmark_3/workloads/wl3.csv" \
    "examples/qlrouting/resources/microbenchmark_3/workloads/wl3-udp.csv"
do
    if [[ "$WORKLOAD_FILE" == *udp* ]]; then
        CC_LIST="None"
    else
        CC_LIST="TcpLinuxReno TcpVegas"
    fi

    for CONGESTION_CONTROL in $CC_LIST
    do
        WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
        WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
        RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
        
        QLR_ACTIVE=0 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" END=${END} DUMP_TRAFFIC=$DUMP_TRAFFIC bash run_experiment.sh
        
        mkdir -p results/${RESULTS_DIR}/baseline/0
        cp -R results/${RESULTS_DIR}/qlr_0/0/* results/${RESULTS_DIR}/baseline/0
        rm -rf results/${RESULTS_DIR}/qlr_0

        mkdir -p results/${RESULTS_DIR}/central/0

        QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" QLR_UPDATE_INTERVAL=${CONTROLPLANE_SPEED} END=${END} DUMP_TRAFFIC=$DUMP_TRAFFIC bash run_experiment.sh
        cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/central/0
        rm -rf results/${RESULTS_DIR}/qlr_1/0

        mkdir -p results/${RESULTS_DIR}/local_qlr/0

        QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} QLR_MODE=local EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" END=${END} DUMP_TRAFFIC=$DUMP_TRAFFIC bash run_experiment.sh

        cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/local_qlr/0
        rm -rf results/${RESULTS_DIR}/qlr_1/0

        QLR_ACTIVE=1 P4_PROGRAM=examples/qlrouting/qlr_build/qlr.json P4_COMMANDS="examples/qlrouting/resources/" EXPERIMENT_NAME=${EXPERIMENT_NAME} CONGESTION_CONTROL=${CONGESTION_CONTROL} WORKLOAD_FILE=${WORKLOAD_FILE} EDGES="0,1;1,2;0,3;3,4;2,4" HOSTS="1,1,1,1,1" SWITCHES=5 DAGS="0:1-0,2-1,3-0,4-3,2-4;1:0-1,2-1,3-0,4-3,4-2;2:0-1,1-2,0-3,3-4,4-2;3:0-3,4-3,1-0,2-1;4:3-4,2-4,1-2,0-1,0-3" END=${END} DUMP_TRAFFIC=$DUMP_TRAFFIC bash run_experiment.sh
        mkdir -p results/${RESULTS_DIR}/qlr/0
        cp -R results/${RESULTS_DIR}/qlr_1/0/* results/${RESULTS_DIR}/qlr/0
        rm -rf results/${RESULTS_DIR}/qlr_1
    done
done

chmod -R 777 figures

