#!/usr/bin/env bash
# Run the use-case sweep on the PDH (SNDlib) topology, isolating all outputs
# from Abilene/abilene-dense/Atlanta:
#   - workloads -> resources/pdh/workloads
#   - P4 commands -> resources/pdh/commands
#   - results -> results/pdh_*
# Originals (other *.topology files, resources/{11_nodes,abilene-dense,atlanta}/*,
# results/{abilene,abilene-dense,atlanta}_*) are untouched.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

export TOPOLOGY_FILE="${TOPOLOGY_FILE:-pdh.topology}"

# Run both congestion-link-selection variants back to back. The sel_tag baked
# into workload/results names by run-use-case.sh keeps the two runs isolated
# (no overwriting), so a single run-pdh.sh call produces both datasets.
for congestion_link_selection in waypoint-random; do
    echo "=== run-pdh: CONGESTION_LINK_SELECTION=$congestion_link_selection ==="
    CONGESTION_LINK_SELECTION="$congestion_link_selection" bash run-use-case.sh "$@"
done
