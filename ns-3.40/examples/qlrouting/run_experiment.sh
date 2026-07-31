#!/bin/bash


export PATH="$PATH:$(pwd)/../../src/p4-switch/helper"

# Default parameters (can be overridden by environment or CLI)
MODE="${MODE:-qlr}"
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
DUMP_TRAFFIC="${DUMP_TRAFFIC:-0}"
CONGESTION_CONTROL="${CONGESTION_CONTROL:-TcpLinuxReno}"
EXPERIMENT_NAME="${EXPERIMENT_NAME:-qlr-experiment}"
QLR_UPDATE_INTERVAL="${QLR_UPDATE_INTERVAL:-200ns}"
P4_PROGRAM="${P4_PROGRAM:-examples/qlrouting/qlr_build/qlr.json}"
QLR_MODE="${QLR_MODE:-global}"  # local or global
HYSTERESIS="${HYSTERESIS:-1}"

# Commands live in a topology-named directory (defaults to "<N>_nodes" for
# standalone/microbenchmark runs). The commands are both GENERATED here and
# passed as the full path to the simulator, so the two always agree.
RESOURCES_TAG="${RESOURCES_TAG:-${SWITCHES}_nodes}"
commands_reldir="resources/${RESOURCES_TAG}/commands"

experiment_params="--host-bw=$HOST_BW --switch-bw=$SWITCH_BW --edges=$EDGES --hosts=$HOSTS --switches=$SWITCHES --workload-file=$WORKLOAD_FILE --end=$END  --cc=$CONGESTION_CONTROL --color-update-interval=$QLR_UPDATE_INTERVAL --mode=$MODE --p4-program=$P4_PROGRAM --hysteresis=$HYSTERESIS"
experiment_params+=" --p4-command=examples/qlrouting/${commands_reldir}"

if [ "$DUMP_TRAFFIC" = "1" ]; then
    experiment_params+=" --dump-traffic"
fi

if [ "$QLR_ACTIVE" = "0" ]; then
    experiment_params+=" --mode=baseline"
fi

echo "Running experiment with parameters: $experiment_params"

RESULTS_DIR="${EXPERIMENT_NAME}_${CONGESTION_CONTROL}_${WORKLOAD_BASE}"
RESULTS_PATH="results/$RESULTS_DIR"

i=0
result_path=""

result_path="$RESULTS_PATH/qlr_${QLR_ACTIVE}/${i}/"
mkdir -p $result_path

if [ "$QLR_MODE" = "local" ]; then
    python3 generate_tables.py 5 1
else
    python3 generate_tables.py 5 0
fi


# Generate commands into the same topology-named dir that is passed to the
# simulator (--p4-command above), so tables always match the running topology.
echo "Generating P4 commands with command: python3 generate_p4_commands.py \"${commands_reldir}\" ${QLR_ACTIVE} --edges \"$EDGES\" --host-vector \"$HOSTS\" --dags \"$DAGS\""
python3 generate_p4_commands.py "${commands_reldir}" ${QLR_ACTIVE} --edges $EDGES --host-vector $HOSTS --dags $DAGS

cd p4src && p4c -o ../qlr_build ./qlr.p4 && cd ..

sleep 1

../../ns3 run qlr-experiment -- $experiment_params --results-path="examples/qlrouting/$result_path"  |& tee $result_path/run.log

chmod -R 777 results