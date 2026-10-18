#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p build evidence
# Reuse the verified three kernel objects; do not enable LTO.
for mode in scalar default auto; do
    test -f "build/kernels_${mode}.o" || { echo 'Run bash build_default.sh first.'; exit 1; }
done
g++ -std=c++17 -O2 -Wall -Wextra -c benchmark_cycles.cpp -o build/benchmark_cycles.o
for mode in scalar default auto; do
    g++ build/benchmark_cycles.o "build/kernels_${mode}.o" -o "build/bench_cycles_${mode}"
done
printf 'Cycle-counting harness built for all three modes.\n'
