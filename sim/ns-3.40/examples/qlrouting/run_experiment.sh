#!/bin/bash

pip install --break-system-packages networkx

for i in 1
do
    python3 generate_commands_5_nodes.py resources/5_nodes 1
    sleep 1
    ../../ns3 run qlr-5-nodes -- --default-bw=10Mbps --active-rate-tcp=2Mbps --backup-flows=15 --backup-rate-udp=1Mbps --flow-end=3 --end=10 --results-path=examples/qlrouting/results/5_nodes --fm-name=qlr-$i.xml

    python3 generate_commands_5_nodes.py resources/5_nodes 0
    sleep 1
    ../../ns3 run qlr-5-nodes -- --default-bw=10Mbps --active-rate-tcp=2Mbps --backup-flows=15 --backup-rate-udp=1Mbps --flow-end=3 --end=10 --results-path=examples/qlrouting/results/5_nodes --fm-name=tcp-$i.xml
done

chmod -R 777 results
