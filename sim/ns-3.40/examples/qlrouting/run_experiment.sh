#!/bin/bash

set -ex

export PATH="$PATH:$(pwd)/../../src/p4-switch/helper"
# Default parameters (can be overridden by environment or CLI)

QLR_ACTIVE="${QLR_ACTIVE:-1}"
HOST_BW="${HOST_BW:-100Gbps}"
SWITCH_BW="${SWITCH_BW:-100Mbps}"
EDGES="${EDGES:-0,1;0,2;1,2;1,3;2,3;2,4;3,4}"
HOSTS="${HOSTS:-1,1,1,1,1}"
SWITCHES="${SWITCHES:-5}"
DAGS="${DAGS:-0:1-0,2-0,3-1,3-4,4-2;1:0-1,2-0,2-1,3-1,3-4,4-2;2:0-1,0-2,1-2,1-3,3-2,4-2,4-3;3:0-1,0-2,1-3,2-3,2-4,4-3;4:0-1,0-2,1-3,2-4,3-2,3-4}"
WORKLOAD_FILE="${WORKLOAD_FILE:-examples/qlrouting/resources/3_nodes/workloads/wl1.csv}"
WORKLOAD_NAME="$(basename "$WORKLOAD_FILE")"
WORKLOAD_BASE="${WORKLOAD_NAME%.*}"
END="${END:-20}"
DUMP_TRAFFIC="${DUMP_TRAFFIC:---dump-traffic}"
CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="${EXPERIMENT_NAME:qlr-experiment}"
QLR_UPDATE_INTERVAL="${QLR_UPDATE_INTERVAL:200ns}"

experiment_params="--host-bw=$HOST_BW --switch-bw=$SWITCH_BW --edges=$EDGES --hosts=$HOSTS --switches=$SWITCHES --workload-file=$WORKLOAD_FILE --end=$END  --cc=$CONGESTION_CONTROL --color-update-interval=$QLR_UPDATE_INTERVAL"


echo "$experiment_params"

RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
RESULTS_PATH="results/$RESULTS_DIR"

i=0
mkdir -p $RESULTS_PATH/qlr_${QLR_ACTIVE}/${i}

python3 generate_tables.py 5
python3 generate_p4_commands.py "resources/${SWITCHES}_nodes/commands" ${QLR_ACTIVE} --edges $EDGES --host-vector $HOSTS --dags $DAGS

cd p4src && p4c -o ../qlr_build ./qlr.p4 && cd ..

sleep 1

../../ns3 run qlr-experiment -- $experiment_params --results-path="examples/qlrouting/$RESULTS_PATH/qlr_${QLR_ACTIVE}/${i}/"  |& tee $RESULTS_PATH/qlr_${QLR_ACTIVE}/${i}/run.log

chmod -R 777 results