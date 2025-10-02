#!/bin/bash

set -e

SEED_BASE=10

# Default parameters (can be overridden by environment or CLI)
DEFAULT_BW="${DEFAULT_BW:-100Mbps}"
QLR_DATA_SIZE="${QLR_DATA_SIZE:-50000000}"
BURST_FLOWS="${BURST_FLOWS:-70}"
BURST_RATE="${BURST_RATE:-1Mbps}"
END="${END:-20}"
BURST_MAX_TIME="${BURST_MAX_TIME:-0.2}"
BURST_NUM="${BURST_NUM:-5}"
BURST_INTERVAL="${BURST_INTERVAL:-0.7}"
QLR_START_TIME="${QLR_START_TIME:-0.5}"
DUMP_TRAFFIC="${DUMP_TRAFFIC:---dump-traffic}"
CC="${CC:-TcpLinuxReno}"


experiment_params="--default-bw=$DEFAULT_BW --qlr-data-size=$QLR_DATA_SIZE --burst-flows=$BURST_FLOWS --burst-rate=$BURST_RATE --end=$END --burst-max-time=$BURST_MAX_TIME --burst-num=$BURST_NUM --burst-interval=$BURST_INTERVAL --qlr-start-time=$QLR_START_TIME $DUMP_TRAFFIC --cc=$CC"

pip install --break-system-packages -r requirements.txt




for cc in "TcpLinuxReno" "TcpNewReno" "TcpCubic" "TcpBbr"; do
    CC=$cc

    RESULTS_DIR="5_nodes_${BURST_NUM}_${CC}"

    RESULTS_PATH="examples/qlrouting/results/$RESULTS_DIR"
    mkdir -p logs/$RESULTS_DIR/qlr
    mkdir -p logs/$RESULTS_DIR/no-qlr

    experiment_params="$experiment_params --cc=$CC"
    
    for i in {0..0}; 
    do
        SEED=$(($SEED_BASE + $i*5))
        mkdir -p $RESULTS_PATH/qlr/$cc/$i
        python3 generate_commands_5_nodes.py resources/5_nodes 1
        sleep 1
        ../../ns3 run qlr-5-nodes -- $experiment_params --seed=$SEED --results-path=$RESULTS_PATH/qlr/$cc/$i/ |& tee logs/$RESULTS_DIR/qlr/qlr_${cc}_$i.log

        mkdir -p $RESULTS_PATH/no-qlr/$cc/$i
        python3 generate_commands_5_nodes.py resources/5_nodes 0
        sleep 1
        ../../ns3 run qlr-5-nodes -- $experiment_params --seed=$SEED --results-path=$RESULTS_PATH/no-qlr/$cc/$i/ |& tee logs/$RESULTS_DIR/no-qlr/no-qlr_${cc}_$i.log
    done
done
for i in {0..0}; 
do
    SEED=$(($SEED_BASE + $i*5))
    mkdir -p $RESULTS_PATH/qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 1
    sleep 1
    ../../ns3 run qlr-5-nodes -- $experiment_params --seed=$SEED --results-path=$RESULTS_PATH/qlr/$i/ |& tee logs/$RESULTS_DIR/qlr/qlr_$i.log

    mkdir -p $RESULTS_PATH/no-qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 0
    sleep 1
    ../../ns3 run qlr-5-nodes -- $experiment_params --seed=$SEED --results-path=$RESULTS_PATH/no-qlr/$i/ |& tee logs/$RESULTS_DIR/no-qlr/no-qlr_$i.log
done

chmod -R 777 results 
chmod -R 777 figures 
# python3 plot.py results/5_nodes figures/5_nodes

