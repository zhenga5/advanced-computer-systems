#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
bash build.sh
g++ -std=c++17 -O2 -Wall -Wextra -c benchmark_alignment.cpp -o build/benchmark_alignment.o
for mode in scalar auto; do
    g++ "build/kernels_${mode}.o" build/benchmark_alignment.o -o "build/bench_alignment_${mode}"
    objdump -d -C -Mintel "build/kernels_${mode}.o" > "evidence/alignment_${mode}.asm"
done
echo "Alignment benchmarks built."
