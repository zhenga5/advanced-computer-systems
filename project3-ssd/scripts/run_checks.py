import json
import random
import shutil
import subprocess
import tarfile
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parent.parent
test_file = root / "test-data" / "ssd-test.bin"

if not test_file.is_file() or test_file.stat().st_size < 16 * 1024**3:
    raise SystemExit("The prepared 16 GiB test file is missing or too small.")

stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
out = root / "results" / f"checks_{stamp}"
out.mkdir(parents=True)
shutil.copy2(__file__, out / "run_checks.py")

common = {
    "filename": str(test_file),
    "size": "16G",
    "allow_file_create": 0,
    "ioengine": "libaio",
    "direct": 1,
    "numjobs": 1,
    "time_based": 1,
    "runtime": 30,
    "ramp_time": 5,
    "refill_buffers": 1,
    "scramble_buffers": 1,
    "buffer_compress_percentage": 0,
    "lat_percentiles": 1,
    "percentile_list": "50:95:99:99.9",
}

commands = [
    ["uname", "-a"],
    ["fio", "--version"],
    ["lscpu"],
    ["free", "-h"],
    ["df", "-h", str(test_file)],
    ["findmnt", "-T", str(test_file)],
    ["cat", "/etc/os-release"],
]

with (out / "system_info.txt").open("w") as f:
    for command in commands:
        f.write("\n$ " + " ".join(command) + "\n")
        result = subprocess.run(
            command, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        f.write(result.stdout)

cases = []
queue_cases = [
    ("randread", "4k", (1, 16, 128)),
    ("randwrite", "4k", (1, 8, 16)),
    ("read", "128k", (1, 8, 16)),
    ("write", "128k", (1, 8, 16)),
]

for workload, block_size, depths in queue_cases:
    for depth in depths:
        cases.append((
            f"queue_{workload}_qd{depth}",
            {"rw": workload, "bs": block_size, "iodepth": depth},
        ))

for percent in (100, 70, 50, 0):
    cases.append((
        f"mix_read{percent}",
        {
            "rw": "randrw", "bs": "4k",
            "iodepth": 16, "rwmixread": percent,
        },
    ))

# Compare with the 16 GiB random-read QD16 case above.
cases.append((
    "working_set_1G",
    {"rw": "randread", "bs": "4k", "iodepth": 16, "size": "1G"},
))

tests = []
rng = random.Random(2026)

for repeat in range(1, 4):
    ordered = cases.copy()
    rng.shuffle(ordered)
    for name, settings in ordered:
        tests.append((f"{name}_rep{repeat}", settings))

tests.append((
    "sustained_write",
    {
        "rw": "write",
        "bs": "128k",
        "iodepth": 16,
        "runtime": 120,
        "ramp_time": 0,
        "write_bw_log": str(out / "sustained"),
        "log_avg_msec": 1000,
    },
))

(out / "test_order.json").write_text(json.dumps(tests, indent=2))

for index, (name, settings) in enumerate(tests, 1):
    options = {**common, **settings}
    config = out / f"{name}.fio"
    result = out / f"{name}.json"

    config.write_text(
        "[global]\n"
        + "\n".join(f"{key}={value}" for key, value in options.items())
        + "\n\n[test]\n"
    )

    print(f"[{index}/{len(tests)}] {name}", flush=True)
    subprocess.run(
        ["fio", "--output-format=json",
         f"--output={result}", str(config)],
        check=True,
    )

    data = json.loads(result.read_text())
    job = data["jobs"][0]
    recorded = {
        **data.get("global options", {}),
        **job.get("job options", {}),
    }

    if job["error"] != 0:
        raise SystemExit(f"STOP: FIO error in {name}")

    for key in ("rw", "bs", "iodepth", "size", "direct", "numjobs"):
        if str(recorded.get(key)) != str(options[key]):
            raise SystemExit(f"STOP: Incorrect {key} in {name}")

    if options["iodepth"] > 1:
        if job["iodepth_level"].get("1", 0) > 99:
            raise SystemExit(f"STOP: Depth stayed at 1 in {name}")

    print("Checks passed.", flush=True)

archive = out.with_suffix(".tar.gz")
with tarfile.open(archive, "w:gz") as tar:
    tar.add(out, arcname=out.name)

print(f"\nFinished. Upload: {archive}")
