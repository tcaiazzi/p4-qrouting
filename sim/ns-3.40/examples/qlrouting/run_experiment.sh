#!/bin/bash

set -e

experiment_params="--default-bw=100Mbps --qlr-data-size=62500000 --qlr-rate=100Mbps --burst-flows=20 --burst-rate=10Mbps --end=10 --burst-start-time=2 --burst-end-time=3 --qlr-start-time=1"

pip install --break-system-packages -r requirements.txt

for i in 1
do
    mkdir -p results/5_nodes/qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 1
    sleep 1
    ../../ns3 run qlr-5-nodes -- $experiment_params --results-path=examples/qlrouting/results/5_nodes/qlr/$i

    mkdir -p results/5_nodes/no-qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 0
    sleep 1
    ../../ns3 run qlr-5-nodes -- $experiment_params --results-path=examples/qlrouting/results/5_nodes/no-qlr/$i
done

chmod -R 777 results 
chmod -R 777 figures 
# python3 plot.py results/5_nodes figures/5_nodes

