#!/bin/bash

pip install --break-system-packages -r requirements.txt

for i in 2
do
    mkdir -p results/5_nodes/qlr/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 1
    sleep 1
    ../../ns3 run qlr-5-nodes -- --default-bw=10Mbps --active-rate-tcp=1Mbps --backup-flows=10 --backup-rate-udp=1Mbps --flow-end=3 --end=10 --udp-start-time=1.5 --udp-end-time=3.5 --tcp-start-time=1 --tcp-end-time=4 --dump-traffic --results-path=examples/qlrouting/results/5_nodes/qlr/$i

    mkdir -p results/5_nodes/tcp/$i
    python3 generate_commands_5_nodes.py resources/5_nodes 0
    sleep 1
    ../../ns3 run qlr-5-nodes -- --default-bw=10Mbps --active-rate-tcp=1Mbps --backup-flows=10 --backup-rate-udp=1Mbps --flow-end=3 --end=10 --udp-start-time=1.5 --udp-end-time=3.5 --tcp-start-time=1 --tcp-end-time=4 --dump-traffic --results-path=examples/qlrouting/results/5_nodes/tcp/$i
done

chmod -R 777 results
