#!/bin/bash

set -e

experiment_params="--default-bw=100Mbps --qlr-data-size=62500000 --qlr-rate=80Mbps --burst-flows=40 --burst-rate=5Mbps --end=20 --burst-start-time=2 --burst-end-time=2.2 --burst-num=10 --burst-interval=0.5 --qlr-start-time=1 --dump-traffic"

pip install --break-system-packages -r requirements.txt

mkdir -p logs/5_nodes/qlr
mkdir -p logs/5_nodes/no-qlr

for i in 1
do
    mkdir -p results/5_nodes/qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 1
    sleep 1
    ../../ns3 run qlr-5-nodes -- $experiment_params --results-path=examples/qlrouting/results/5_nodes/qlr/$i |& tee logs/5_nodes/qlr/qlr_$i.log

    mkdir -p results/5_nodes/no-qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 0
    sleep 1
    ../../ns3 run qlr-5-nodes -- $experiment_params --results-path=examples/qlrouting/results/5_nodes/no-qlr/$i |& tee logs/5_nodes/no-qlr/no-qlr_$i.log
done

chmod -R 777 results 
chmod -R 777 figures 
# python3 plot.py results/5_nodes figures/5_nodes

