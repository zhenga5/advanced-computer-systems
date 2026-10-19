import csv
import io
import json
import os
from pathlib import Path
import random
import shutil
import subprocess
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parent

def main():
    allowed = sorted(os.sched_getaffinity(0))
    os.sched_setaffinity(0, {allowed[0]})
    sizes = list(range(1024, 1040)) + [65536, 65537]
    jobs = [(n, offset, mode) for n in sizes for offset in [0, 1]
            for mode in ["scalar", "auto"]]
    random.Random(20260929).shuffle(jobs)
    sources = ["benchmark_alignment.cpp", "kernels.cpp", "kernels.hpp",
               "build_alignment.sh", "build.sh", "run_alignment.py"]
    for name in sources:
        if not (ROOT / name).is_file():
            raise RuntimeError(f"Missing {name}")
    for mode in ["scalar", "auto"]:
        if not (ROOT / "build" / f"bench_alignment_{mode}").is_file():
            raise RuntimeError("Run bash build_alignment.sh first")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
    out = ROOT / "results" / f"alignment_{stamp}"
    out.mkdir(parents=True)
    for directory in ["source", "raw"]:
        (out / directory).mkdir()
    for name in sources:
        shutil.copy2(ROOT / name, out / "source" / name)
    shutil.copytree(ROOT / "evidence", out / "evidence")
    meta = {"cpu": allowed[0], "original_allowed_cpus": allowed,
            "sizes": sizes, "job_order": jobs, "random_seed": 20260929,
            "kernel": "multiply", "completed": False,
            "git_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()}
    metadata = out / "metadata.json"
    metadata.write_text(json.dumps(meta, indent=2) + "\n")
    with (out / "measurements.csv").open("w", newline="") as file:
        writer = None
        for index, (n, offset, mode) in enumerate(jobs, 1):
            print(f"[{index}/{len(jobs)}] {mode} N={n} offset={offset}", flush=True)
            result = subprocess.run([str(ROOT / "build" / f"bench_alignment_{mode}"),
                                     "multiply", str(n), str(offset)],
                                    cwd=ROOT, text=True, capture_output=True)
            prefix = out / "raw" / f"{mode}_{n}_{offset}"
            prefix.with_suffix(".csv").write_text(result.stdout)
            prefix.with_suffix(".log").write_text(result.stderr)
            if result.returncode:
                raise RuntimeError(result.stderr)
            reader = csv.DictReader(io.StringIO(result.stdout))
            rows = list(reader)
            expected = {(d, t) for d in ["float", "double"] for t in range(1, 8)}
            if len(rows) != 14 or {(r['datatype'], int(r['trial'])) for r in rows} != expected:
                raise RuntimeError("Incomplete or duplicated trials")
            for row in rows:
                width = 4 if row['datatype'] == 'float' else 8
                if (int(row['n']) != n or int(row['offset_elements']) != offset
                    or int(row['address_mod64']) != offset * width):
                    raise RuntimeError("Configuration mismatch")
            if writer is None:
                writer = csv.DictWriter(file, fieldnames=["build"] + reader.fieldnames)
                writer.writeheader()
            for row in rows:
                writer.writerow({"build": mode, **row})
            file.flush()
    meta.update(completed=True, measurement_rows=len(jobs)*14)
    metadata.write_text(json.dumps(meta, indent=2) + "\n")
    print(f"Saved {len(jobs)*14} measurements in: {out}")

if __name__ == "__main__":
    main()
