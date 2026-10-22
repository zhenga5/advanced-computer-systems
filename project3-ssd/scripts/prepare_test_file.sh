#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p test-data results
if [[ -e test-data/ssd-test.bin ]]; then
    echo "Test file already exists; refusing to overwrite it."
    exit 1
fi
fio --name=prepare --filename="$PWD/test-data/ssd-test.bin" \
    --size=16G --rw=write --bs=1M --ioengine=libaio --iodepth=16 \
    --direct=1 --refill_buffers=1 --scramble_buffers=1 \
    --buffer_compress_percentage=0 --end_fsync=1 \
    --output-format=json --output=results/prepare.json
