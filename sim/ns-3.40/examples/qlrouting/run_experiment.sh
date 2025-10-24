#!/bin/bash

set -e

SEED_BASE=10

# Default parameters (can be overridden by environment or CLI)
DESTINATION_ID="${DESTINATION_ID:-4}"
QLR_FLOWS="${QLR_FLOWS:-1}"
QLR_START_TIME="${QLR_START_TIME:-0.5}"
QLR_DATA_SIZE="${QLR_DATA_SIZE:-50000000}"

BACKGROUND_FLOWS="${BACKGROUND_FLOWS:-1}"
BACKGROUND_RATE="${BACKGROUND_RATE:-10Mbps}"

BURST_FLOWS="${BURST_FLOWS:-40}"
BURST_MIN_START_TIME="${BURST_MIN_START_TIME:-1.0}"
BURST_MAX_START_TIME="${BURST_MAX_START_TIME:-5.0}"
BURST_MIN_DURATION="${BURST_MIN_DURATION:-0.1}"
BURST_MAX_DURATION="${BURST_MAX_DURATION:-0.4}"
BURST_MIN_INTERVAL="${BURST_MIN_INTERVAL:-0.3}"
BURST_MAX_INTERVAL="${BURST_MAX_INTERVAL:-0.6}"
BURST_DATA_SIZE="${BURST_DATA_SIZE:-0}"
BURST_RATE="${BURST_RATE:-1Mbps}"
SEED="${SEED:-10}"
HOST_BW="${HOST_BW:-100Gbps}"
SWITCH_BW="${SWITCH_BW:-100Mbps}"
EDGES="${EDGES:-0,1;0,2;1,2;1,3;2,3;2,4;3,4}"
HOSTS="${HOSTS:-1,1,1,1,1}"
SWITCHES="${SWITCHES:-5}"
DAGS="${DAGS:-0:1-0,2-0,3-1,3-4,4-2;1:0-1,2-0,2-1,3-1,3-4,4-2;2:0-1,0-2,1-2,1-3,3-2,4-2,4-3;3:0-1,0-2,1-3,2-3,2-4,4-3;4:0-1,0-2,1-3,2-4,3-2,3-4}"

END="${END:-20}"
FM_NAME="${FM_NAME:-flow_monitor.xml}"
DUMP_TRAFFIC="${DUMP_TRAFFIC:---dump-traffic}"




experiment_params="--destination-id=$DESTINATION_ID --qlr-flows=$QLR_FLOWS --qlr-start-time=$QLR_START_TIME --qlr-data-size=$QLR_DATA_SIZE --background-flows=$BACKGROUND_FLOWS --background-rate=$BACKGROUND_RATE --burst-flows=$BURST_FLOWS --burst-min-start-time=$BURST_MIN_START_TIME --burst-max-start-time=$BURST_MAX_START_TIME --burst-min-duration=$BURST_MIN_DURATION --burst-max-duration=$BURST_MAX_DURATION --burst-min-interval=$BURST_MIN_INTERVAL --burst-max-interval=$BURST_MAX_INTERVAL --burst-data-size=$BURST_DATA_SIZE --burst-rate=$BURST_RATE --seed=$SEED --host-bw=$HOST_BW --switch-bw=$SWITCH_BW --end=$END --fm-name=$FM_NAME $DUMP_TRAFFIC --edges=$EDGES --hosts=$HOSTS"

echo "$experiment_params"

pip install --break-system-packages -r requirements.txt

cc="TcpLinuxReno"

RESULTS_DIR="${SWITCHES}_nodes_${cc}_${BURST_FLOWS}_${BURST_RATE}"
RESULTS_PATH="results/$RESULTS_DIR"
mkdir -p logs/$RESULTS_DIR/qlr
mkdir -p logs/$RESULTS_DIR/no-qlr

experiment_params_cc="$experiment_params --cc=$cc"
i=0

SEED=$(($SEED_BASE + $i*5))
mkdir -p $RESULTS_PATH/qlr/$i
python3 generate_p4_commands.py "resources/${SWITCHES}_nodes" 1 --edges $EDGES --host-vector $HOSTS --dags $DAGS

sleep 1

../../ns3 run qlr-experiment -- $experiment_params_cc --results-path="examples/qlrouting/$RESULTS_PATH/qlr/$i/" --seed=$SEED  |& tee logs/$RESULTS_DIR/qlr/qlr_${cc}_$i.log

chmod -R 777 results
