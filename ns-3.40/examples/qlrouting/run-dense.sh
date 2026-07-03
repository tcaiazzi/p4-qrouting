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

# topo_prefix is derived from the topology filename by run-use-case.sh
# (abilene-dense.topology -> "abilene-dense"), so only RESOURCES_TAG needs setting.
export TOPOLOGY_FILE="${TOPOLOGY_FILE:-abilene-dense.topology}"

bash run-use-case.sh "$@"
