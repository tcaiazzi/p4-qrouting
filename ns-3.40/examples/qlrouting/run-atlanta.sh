#!/usr/bin/env bash
# Run the use-case sweep on the Atlanta (SNDlib) topology, isolating all
# outputs from the Abilene/abilene-dense runs:
#   - workloads -> resources/atlanta/workloads
#   - P4 commands -> resources/atlanta/commands
#   - results -> results/atlanta_*
# Originals (abilene*.topology, resources/{11_nodes,abilene-dense}/*,
# results/{abilene,abilene-dense}_*) are untouched.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

export TOPOLOGY_FILE="${TOPOLOGY_FILE:-atlanta.topology}"

# Run both congestion-link-selection variants back to back. The sel_tag baked
# into workload/results names by run-use-case.sh keeps the two runs isolated
# (no overwriting), so a single run-atlanta.sh call produces both datasets.
for congestion_link_selection in waypoint-random; do
    echo "=== run-atlanta: CONGESTION_LINK_SELECTION=$congestion_link_selection ==="
    CONGESTION_LINK_SELECTION="$congestion_link_selection" bash run-use-case.sh "$@"
done
