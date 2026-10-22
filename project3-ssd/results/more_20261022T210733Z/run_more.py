import json
import shutil
import subprocess
import tarfile
from datetime import datetime, timezone
from pathlib import Path

root = Path(__file__).resolve().parent.parent
test_file = root / "test-data" / "ssd-test.bin"

if not test_file.is_file():
    raise SystemExit("Prepared test file is missing.")

stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
out = root / "results" / f"more_{stamp}"
out.mkdir(parents=True)
shutil.copy2(__file__, out / "run_more.py")

version = subprocess.check_output(["fio", "--version"], text=True)
(out / "fio_version.txt").write_text(version)

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

tests = []

for depth in (128, 256):
    tests.append((
        f"queue_randread_qd{depth}",
        {"rw": "randread", "bs": "4k", "iodepth": depth},
    ))

for workload in ("randread", "randwrite", "read", "write"):
    for size in (4, 16, 32, 64, 128, 256):
        tests.append((
            f"block_{workload}_{size}k",
            {"rw": workload, "bs": f"{size}k", "iodepth": 16},
        ))

for read_percent in (100, 70, 50, 0):
    tests.append((
        f"mix_read{read_percent}",
        {
            "rw": "randrw",
            "bs": "4k",
            "iodepth": 16,
            "rwmixread": read_percent,
        },
    ))

for index, (name, settings) in enumerate(tests, start=1):
    options = {**common, **settings}
    config = out / f"{name}.fio"
    result = out / f"{name}.json"

    text = "[global]\n"
    text += "\n".join(f"{key}={value}" for key, value in options.items())
    text += "\n\n[test]\n"
    config.write_text(text)

    print(f"[{index}/{len(tests)}] {name}", flush=True)

    subprocess.run(
        [
            "fio",
            "--output-format=json",
            f"--output={result}",
            str(config),
        ],
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

    for key, expected in settings.items():
        if str(recorded.get(key)) != str(expected):
            raise SystemExit(f"STOP: Incorrect {key} in {name}")

    if job["iodepth_level"].get("1", 0) > 99:
        raise SystemExit(f"STOP: Queue depth stayed at 1 in {name}")

    print("Settings and depth checks passed.", flush=True)

archive = out.with_suffix(".tar.gz")
with tarfile.open(archive, "w:gz") as tar:
    tar.add(out, arcname=out.name)

print(f"\nFinished. Upload: {archive}")
