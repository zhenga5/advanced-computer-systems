#!/usr/bin/env python3
"""Run the scalar/default-auto/native-auto three-kernel sweep on one allowed Linux CPU."""
import csv
import hashlib
import io
import json
import math
import os
from pathlib import Path
import shutil
import subprocess
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parent
SIZES = [2**power for power in range(10, 26)]
KERNELS = ["multiply", "axpy", "dot"]
MODES = ["scalar", "default", "auto"]
FIELDS = ["kernel", "datatype", "n", "trial", "repetitions",
          "seconds_per_call", "gflops", "working_set_bytes",
          "useful_gib_per_second", "checksum"]


def main():
    sources = ["benchmark_all.cpp", "kernels.hpp", "kernels.cpp",
               "kernels_check.cpp", "benchmark.cpp", "build.sh", "build_all.sh",
               "run_isa_sweep.py", "build_default.sh"]
    evidence = ["compiler.txt", "kernel.txt", "cpu.txt",
                "vectorization_auto.txt", "check_scalar.txt", "check_auto.txt",
                "vectorization_default.txt", "check_default.txt", "default_target.txt",
                "isa_scalar.asm", "isa_default.asm", "isa_auto.asm"]
    required = [ROOT / name for name in sources]
    required += [ROOT / "evidence" / name for name in evidence]
    binaries = [ROOT / "build" / f"bench_all_{mode}" for mode in MODES]
    for path in required + binaries:
        if not path.is_file():
            raise RuntimeError(f"Missing {path}. Save the scripts and run bash build_default.sh first.")

    allowed = sorted(os.sched_getaffinity(0))
    cpu = allowed[0]
    os.sched_setaffinity(0, {cpu})
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
    # Read Git state before creating this run's untracked results directory.
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    status = subprocess.check_output(["git", "status", "--short"], cwd=ROOT, text=True)
    output = ROOT / "results" / f"isa_sweep_{stamp}"
    output.mkdir(parents=True)
    for folder in ["source", "evidence", "raw"]:
        (output / folder).mkdir()
    for name in sources:
        shutil.copy2(ROOT / name, output / "source" / name)
    for name in evidence:
        shutil.copy2(ROOT / "evidence" / name, output / "evidence" / name)
    metadata = {
        "started_utc": stamp, "git_commit": commit, "git_status_before_run": status,
        "selected_logical_cpu": cpu, "original_allowed_cpus": allowed,
        "sizes": SIZES, "kernels": KERNELS, "builds": MODES,
        "trials_per_configuration": 7, "calibration_target_seconds": 0.030,
        "default_build": "GCC default target, -O3 -ffp-contract=off; no march/mtune override",
        "auto_build": "CPU-targeted native auto-vectorization, not generic default ISA",
        "axpy_method": "Alternate +0.5 and -0.5; each call counts separately",
        "dot_inputs": "x = i % 7 - 3; y = 1 + i % 5; bounded exact reference",
        "bandwidth_definition": "Useful algorithm bytes/time, not measured DRAM traffic",
        "binary_sha256": {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in binaries},
        "completed": False,
    }
    meta_path = output / "metadata.json"
    meta_path.write_text(json.dumps(metadata, indent=2) + "\n")
    expected_keys = {(dtype, trial) for dtype in ["float", "double"] for trial in range(1, 8)}
    runs = 0
    with (output / "measurements.csv").open("w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=["build"] + FIELDS)
        writer.writeheader()
        for size_index, n in enumerate(SIZES):
            # Rotate kernel order and alternate build order to reduce fixed-order bias.
            rotation = size_index % len(KERNELS)
            kernel_order = KERNELS[rotation:] + KERNELS[:rotation]
            for kernel_index, kernel in enumerate(kernel_order):
                offset = (size_index + kernel_index) % len(MODES)
                modes = MODES[offset:] + MODES[:offset]
                if size_index % 2: modes = modes[::-1]
                for mode in modes:
                    print(f"[{runs + 1}/144] {kernel}, {mode}, N={n:,}", flush=True)
                    result = subprocess.run(
                        [str(ROOT / "build" / f"bench_all_{mode}"), kernel, str(n)],
                        cwd=ROOT, text=True, capture_output=True,
                    )
                    prefix = output / "raw" / f"{kernel}_{mode}_{n}"
                    prefix.with_suffix(".csv").write_text(result.stdout)
                    prefix.with_suffix(".log").write_text(result.stderr)
                    if result.returncode:
                        raise RuntimeError(f"Benchmark failed: {result.stderr}\nPartial results: {output}")
                    reader = csv.DictReader(io.StringIO(result.stdout))
                    rows = list(reader)
                    if reader.fieldnames != FIELDS or len(rows) != 14:
                        raise RuntimeError(f"Unexpected CSV format or row count: {prefix}")
                    if {(r['datatype'], int(r['trial'])) for r in rows} != expected_keys:
                        raise RuntimeError(f"Missing or duplicate trial: {prefix}")
                    for row in rows:
                        seconds = float(row["seconds_per_call"])
                        if (row["kernel"] != kernel or int(row["n"]) != n
                                or not math.isfinite(seconds) or seconds <= 0):
                            raise RuntimeError(f"Invalid measurement: {prefix}")
                        writer.writerow({"build": mode, **row})
                    file.flush()
                    print(result.stderr.strip(), flush=True)
                    runs += 1
    metadata.update(completed=True, completed_utc=datetime.now(timezone.utc).isoformat(),
                    measurement_rows=runs * 14)
    meta_path.write_text(json.dumps(metadata, indent=2) + "\n")
    print(f"\nSaved {runs * 14} measurements in: {output}")


if __name__ == "__main__":
    main()
