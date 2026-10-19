#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p build evidence
g++ -std=c++17 -O3 -march=native -ffp-contract=off -Wall -Wextra \
    -fopt-info-vec-all -c kernels_bandwidth.cpp -o build/kernels_bandwidth.o \
    2> evidence/vectorization_bandwidth.txt
g++ -std=c++17 -O2 -Wall -Wextra -c benchmark_bandwidth.cpp -o build/benchmark_bandwidth.o
g++ build/benchmark_bandwidth.o build/kernels_bandwidth.o -o build/bench_bandwidth
./build/bench_bandwidth --check | tee evidence/check_bandwidth.txt
objdump -d -C -Mintel build/kernels_bandwidth.o > evidence/bandwidth_auto.asm
g++ --version > evidence/bandwidth_compiler.txt
printf 'Bandwidth calibration build completed.\n'
