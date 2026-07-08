#!/usr/bin/env bash
# Run the use-case sweep on the denser abilene-dense topology, isolating all
# outputs from the original Abilene run:
#   - workloads -> resources/abilene-dense/workloads
#   - P4 commands -> resources/abilene-dense/commands
#   - results -> results/abilene-dense_*
# Originals (abilene.topology, resources/11_nodes/*, results/abilene_*) are untouched.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

export TOPOLOGY_FILE="${TOPOLOGY_FILE:-abilene.topology}"

# Run both congestion-link-selection variants back to back. The sel_tag baked
# into workload/results names by run-use-case.sh keeps the two runs isolated
# (no overwriting), so a single run-dense.sh call produces both datasets.
for congestion_link_selection in deepest waypoint-random; do
    echo "=== run-dense: CONGESTION_LINK_SELECTION=$congestion_link_selection ==="
    CONGESTION_LINK_SELECTION="$congestion_link_selection" bash run-use-case.sh "$@"
done
