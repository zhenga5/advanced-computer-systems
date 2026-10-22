#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
test -f test-data/ssd-test.bin

run_id=$(date -u +%Y%m%dT%H%M%SZ)
output_dir="results/queue_fixed_${run_id}"
mkdir -p "$output_dir"

cp scripts/run_queue_fixed.sh "$output_dir/"
fio --version > "$output_dir/fio_version.txt"

for workload in randread randwrite read write
do
    case "$workload" in
        randread|randwrite) block_size=4k ;;
        read|write) block_size=128k ;;
    esac

    for depth in 1 2 4 8 16 32 64
    do
        prefix="$output_dir/${workload}_qd${depth}"

        cat > "${prefix}.fio" <<CONFIG
[global]
filename=$PWD/test-data/ssd-test.bin
size=16G
allow_file_create=0
ioengine=libaio
direct=1
iodepth=$depth
numjobs=1
rw=$workload
bs=$block_size
time_based=1
runtime=30
ramp_time=5
refill_buffers=1
scramble_buffers=1
buffer_compress_percentage=0
lat_percentiles=1
percentile_list=50:95:99:99.9

[test]
CONFIG

        echo "Running $workload, $block_size, QD=$depth"

        fio --output-format=json \
            --output="${prefix}.json" "${prefix}.fio"

        python3 - "${prefix}.json" "$depth" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

expected = int(sys.argv[2])
job = data["jobs"][0]
options = {
    **data.get("global options", {}),
    **job.get("job options", {}),
}

if job["error"] != 0:
    raise SystemExit("STOP: FIO reported an error.")

if int(options.get("iodepth", -1)) != expected:
    raise SystemExit("STOP: Configured queue depth is incorrect.")

levels = job["iodepth_level"]
if expected > 1 and levels.get("1", 0) > 99:
    raise SystemExit("STOP: Actual queue depth stayed at 1.")

print("Depth check passed:", levels)
PY
    done
done

tar -czf "${output_dir}.tar.gz" \
    -C results "$(basename "$output_dir")"

echo "Finished. Upload: ${output_dir}.tar.gz"
