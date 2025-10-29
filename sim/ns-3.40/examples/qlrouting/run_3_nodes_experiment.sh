#!/bin/bash

set -e

SEED_BASE=10

EDGES="0,1;0,2;1,2" HOSTS="1,1,1" SWITCHES=3 DAGS="0:1-0,2-0,2-1;1:0-1,0-2,2-1;2:0-1,0-2,1-2" DESTINATION_ID="1" BURST_FLOWS="20" BURST_RATE="10Mbps" END=5 bash run_experiment.sh
