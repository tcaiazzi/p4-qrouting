#!/usr/bin/env bash
# Complete the current atlanta sweep (run-use-case.sh: 7 seeds x 3 profiles x
# 5 pfc = 105 combos) by running ONLY the combos missing from results_atlanta/.
#
# Does not modify run-use-case.sh. Instead, it calls it twice with a narrower
# SWEEP_SEEDS/SWEEP_PROTECTED_FLOW_COUNTS scope per call, chosen so that the
# union of both calls is exactly the 69 missing combos, with zero overlap
# with the 36 already completed:
#   - seeds {1234,1312,1927,7262} already have pfc {1,5,10} done -> only
#     pfc {20,50} are missing for them (24 combos).
#   - seeds {2023,3141,2718} haven't been touched at all -> all 5 pfc values
#     are missing for them (45 combos).
# profile_matrix (burst-1/2/3) is unchanged/untouched -- both calls run all
# 3 profiles, since none of the missing combos need a profile subset.
#
# If results_atlanta/ changes (e.g. a partial run gets manually completed or
# cleaned up), recheck with the same enumeration logic before relying on this
# script again -- it does not inspect results_atlanta/ itself, it encodes a
# one-time snapshot of what was missing when it was written.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

# run_experiment.sh writes to results/<dir> (hardcoded path). Point it at
# results_atlanta/ so this continues the existing sweep in place, instead of
# starting a fresh (empty) results/ directory.
if [[ -e results && ! -L results ]]; then
    echo "ERROR: results/ already exists and is not a symlink -- resolve manually before running this script." >&2
    exit 1
fi
mkdir -p results_atlanta
ln -sfn results_atlanta results

export TOPOLOGY_FILE="atlanta.topology"
export CONGESTION_LINK_SELECTION="waypoint-random"

echo "=== run-atlanta-missing: seeds {1234,1312,1927,7262}, pfc {20,50} (24 combos) ==="
SWEEP_SEEDS="1234,1312,1927,7262" \
SWEEP_PROTECTED_FLOW_COUNTS="20,50" \
bash run-use-case.sh "$@"

echo "=== run-atlanta-missing: seeds {2023,3141,2718}, pfc {1,5,10,20,50} (45 combos) ==="
SWEEP_SEEDS="2023,3141,2718" \
SWEEP_PROTECTED_FLOW_COUNTS="1,5,10,20,50" \
bash run-use-case.sh "$@"
