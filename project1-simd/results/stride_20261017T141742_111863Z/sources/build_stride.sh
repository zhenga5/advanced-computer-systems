#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p build evidence
common=(-std=c++17 -O3 -march=native -ffp-contract=off -Wall -Wextra)
g++ "${common[@]}" -fno-tree-loop-vectorize -fno-tree-slp-vectorize \
    -c kernels_stride.cpp -o build/kernels_stride_scalar.o
g++ "${common[@]}" -fopt-info-vec-all \
    -c kernels_stride.cpp -o build/kernels_stride_auto.o \
    2> evidence/vectorization_stride_auto.txt
# Separate compilation without LTO keeps timed calls from being eliminated.
g++ -std=c++17 -O2 -Wall -Wextra -c benchmark_stride.cpp -o build/benchmark_stride.o
for mode in scalar auto; do
    g++ build/benchmark_stride.o "build/kernels_stride_${mode}.o" -o "build/bench_stride_${mode}"
    "./build/bench_stride_${mode}" --check | tee "evidence/check_stride_${mode}.txt"
    objdump -d -C -Mintel "build/kernels_stride_${mode}.o" > "evidence/stride_${mode}.asm"
done
g++ --version > evidence/stride_compiler.txt
printf 'Stride build and correctness checks completed.\n'
