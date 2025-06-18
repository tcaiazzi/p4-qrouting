#!/bin/bash

pip install --break-system-packages -r requirements.txt

for i in 2
do
    mkdir -p results/5_nodes/qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 1
    sleep 1
    ../../ns3 run qlr-5-nodes -- --default-bw=100Mbps --active-rate-tcp=10Mbps --backup-flows=10 --backup-rate-udp=10Mbps --end=10 --udp-start-time=2 --udp-end-time=5 --tcp-start-time=1 --tcp-end-time=7 --dump-traffic --results-path=examples/qlrouting/results/5_nodes/qlr/$i

    mkdir -p results/5_nodes/tcp/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 0
    sleep 1
    ../../ns3 run qlr-5-nodes -- --default-bw=100Mbps --active-rate-tcp=10Mbps --backup-flows=10 --backup-rate-udp=10Mbps --end=10 --udp-start-time=2 --udp-end-time=5 --tcp-start-time=1 --tcp-end-time=7 --dump-traffic --results-path=examples/qlrouting/results/5_nodes/tcp/$i
done

chmod -R 777 results
