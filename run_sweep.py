import csv
import io
import json
import os
from pathlib import Path
import subprocess
import sys
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parent

# Powers of two from 1,024 through 33,554,432 elements.
SIZES = [2**power for power in range(10, 26)]

# Keep this process and its child benchmarks on one allowed logical CPU.
allowed_cpus = sorted(os.sched_getaffinity(0))
selected_cpu = allowed_cpus[0]
os.sched_setaffinity(0, {selected_cpu})

stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
output_dir = ROOT / "results" / f"sweep_{stamp}"
output_dir.mkdir(parents=True)

def git_output(*args):
    return subprocess.check_output(
        ["git", *args], cwd=ROOT, text=True
    ).strip()

metadata = {
    "started_utc": stamp,
    "kernel": "elementwise_multiply",
    "environment": "WSL",
    "selected_logical_cpu": selected_cpu,
    "original_allowed_cpus": allowed_cpus,
    "sizes": SIZES,
    "trials_per_datatype": 7,
    "calibration_target_seconds": 0.030,
    "git_commit": git_output("rev-parse", "HEAD"),
    "git_status": git_output("status", "--short"),
    "python_version": sys.version,
}

(output_dir / "metadata.json").write_text(
    json.dumps(metadata, indent=2) + "\n"
)

# Preserve build evidence alongside this particular run.
for filename in [
    "compiler.txt",
    "kernel.txt",
    "cpu.txt",
    "vectorization_auto.txt",
    "check_scalar.txt",
    "check_auto.txt",
]:
    source = ROOT / "evidence" / filename
    (output_dir / filename).write_bytes(source.read_bytes())

(output_dir / "build.sh").write_bytes((ROOT / "build.sh").read_bytes())

fields = [
    "build", "datatype", "n", "trial", "repetitions",
    "seconds_per_call", "gflops", "checksum"
]

with (output_dir / "measurements.csv").open("w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=fields)
    writer.writeheader()

    for index, n in enumerate(SIZES):
        modes = ["scalar", "auto"]
        if index % 2:
            modes.reverse()

        for mode in modes:
            print(f"Running {mode}, N={n:,}", flush=True)

            result = subprocess.run(
                [str(ROOT / "build" / f"bench_{mode}"), str(n)],
                cwd=ROOT,
                text=True,
                capture_output=True,
            )

            (output_dir / f"{mode}_{n}.csv").write_text(result.stdout)
            (output_dir / f"{mode}_{n}.log").write_text(result.stderr)

            if result.returncode != 0:
                print(result.stderr, file=sys.stderr)
                raise SystemExit("Benchmark failed; sweep stopped.")

            rows = list(csv.DictReader(io.StringIO(result.stdout)))
            if len(rows) != 14:
                raise SystemExit("Unexpected number of measurement rows.")

            for row in rows:
                writer.writerow({"build": mode, **row})

            file.flush()
            print(result.stderr.strip(), flush=True)

print(f"\nResults saved in: {output_dir}")