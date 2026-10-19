#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
bash build.sh
g++ -std=c++17 -O2 -Wall -Wextra -c benchmark_all.cpp -o build/benchmark_all.o
for mode in scalar auto; do
    g++ "build/kernels_${mode}.o" build/benchmark_all.o -o "build/bench_all_${mode}"
done
echo "All-kernel benchmarks built."
