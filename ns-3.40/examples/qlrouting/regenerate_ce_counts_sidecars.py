#!/usr/bin/env python3
"""Backfill resources/<tag>/ce_counts/ sidecars for existing workload CSVs.

Reconstructs, from each workload filename, the exact CLI arguments
run-use-case.sh used to generate it, then re-invokes
generate_workloads_simple_ce_counts.py (the offline-instrumented COPY of the
generator -- see that file's docstring; the live generate_workloads_simple.py
used by in-progress experiments is never touched by this script) with:
  --output <scratch throwaway path>   (the CSV it writes is byte-identical to
                                        the existing one -- verified -- so
                                        it's discarded, never written into
                                        resources/<tag>/workloads/)
  --ce-counts-dir resources/<tag>/ce_counts   (the only output kept)

Only reads resources/<tag>/workloads/; never writes there.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

WORKLOAD_NAME_RE = re.compile(
    r"^use_case_burst-(\d+)_seed(\d+)_prot(\d+)_bg(\S+?)_ce(\d+)_cr(\S+?)"
    r"_dmin([\d.]+)dmax([\d.]+)_sel(\S+)\.csv$"
)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GENERATOR = os.path.join(SCRIPT_DIR, "generate_workloads_simple_ce_counts.py")


def hosts_from_topology(topology_file):
    with open(topology_file) as f:
        for line in f:
            if line.startswith("HOSTS="):
                return line.split("=", 1)[1].strip().strip('"')
    raise ValueError(f"No HOSTS= line found in {topology_file}")


def build_command(fname, topology_file, protected_host_vector, output_path, ce_counts_dir):
    m = WORKLOAD_NAME_RE.match(fname)
    if not m:
        return None
    burst, seed, pfc, _bg, ce, cr, dmin, dmax, sel = m.groups()
    return [
        sys.executable, GENERATOR,
        "--output", output_path,
        "--topology-file", topology_file,
        "--sim-start", "0.5",
        "--duration", "2.5",
        "--probing-rate", "100Kbps",
        "--background-rate", "1Mbps",
        "--background-packet-sizes", "64,512,1400",
        "--background-flows-per-link", "1",
        "--seed", seed,
        "--no-background",
        "--protected-flow-count", pfc,
        "--protected-host-vector", protected_host_vector,
        "--protected-rate", "1Mbps",
        "--protected-packet-size", "512",
        "--protected-number-of-flow", "1",
        "--num-congestion-events", ce,
        "--congestion-rate", f"{cr}bps",
        "--congestion-packet-size", "1400",
        "--congestion-duration-min", dmin,
        "--congestion-duration-max", dmax,
        "--congestion-start-time", "0.75",
        "--congestion-end-time", "2.75",
        "--congestion-mode", "per-destination",
        "--congestion-link-selection", sel,
        "--ce-counts-dir", ce_counts_dir,
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--resources-tag", default="atlanta")
    parser.add_argument("--topology-file", default="atlanta.topology")
    args = parser.parse_args()

    workloads_dir = os.path.join(SCRIPT_DIR, "resources", args.resources_tag, "workloads")
    ce_counts_dir = os.path.join(SCRIPT_DIR, "resources", args.resources_tag, "ce_counts")
    topology_file = os.path.join(SCRIPT_DIR, args.topology_file)
    protected_host_vector = hosts_from_topology(topology_file)

    filenames = sorted(f for f in os.listdir(workloads_dir) if f.endswith(".csv"))
    print(f"Found {len(filenames)} workload CSVs in {workloads_dir}")

    with tempfile.TemporaryDirectory() as scratch_dir:
        ok, skipped, mismatched = 0, 0, 0
        for fname in filenames:
            output_path = os.path.join(scratch_dir, fname)
            cmd = build_command(fname, topology_file, protected_host_vector, output_path, ce_counts_dir)
            if cmd is None:
                print(f"SKIP (name doesn't match expected pattern): {fname}")
                skipped += 1
                continue

            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"FAILED: {fname}\n{result.stderr}", file=sys.stderr)
                skipped += 1
                continue

            original_path = os.path.join(workloads_dir, fname)
            stem = os.path.splitext(fname)[0]
            sidecar_path = os.path.join(ce_counts_dir, f"{stem}.ce_counts.csv")
            with open(original_path, "rb") as f_orig, open(output_path, "rb") as f_new:
                if f_orig.read() != f_new.read():
                    print(f"MISMATCH (regenerated CSV differs -- discarding its sidecar): {fname}")
                    if os.path.exists(sidecar_path):
                        os.remove(sidecar_path)
                    mismatched += 1
                    continue

            ok += 1

        print(f"\nDone: {ok} sidecars written, {mismatched} mismatched (sidecar discarded, "
              f"CSV regeneration didn't reproduce the stored file byte-for-byte), {skipped} skipped")


if __name__ == "__main__":
    main()
