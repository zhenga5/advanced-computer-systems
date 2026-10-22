#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f test-data/ssd-test.bin ]]; then
    echo "The prepared test file is missing."
    exit 1
fi

run_id=$(date -u +%Y%m%dT%H%M%SZ)
output_dir="results/queue_${run_id}"
mkdir -p "$output_dir"

cp configs/baseline.fio "$output_dir/base_config.fio"
cp scripts/run_queue.sh "$output_dir/run_queue.sh"
fio --version > "$output_dir/fio_version.txt"

for workload in randread randwrite read write
do
    case "$workload" in
        randread|randwrite) block_size=4k ;;
        read|write) block_size=128k ;;
    esac

    for depth in 1 2 4 8 16 32 64
    do
        echo "Running $workload, block size $block_size, QD=$depth"

        fio configs/baseline.fio \
            --rw="$workload" \
            --bs="$block_size" \
            --iodepth="$depth" \
            --output-format=json \
            --output="$output_dir/${workload}_qd${depth}.json"
    done
done

tar -czf "${output_dir}.tar.gz" \
    -C results "$(basename "$output_dir")"

echo "Finished. Upload: ${output_dir}.tar.gz"
