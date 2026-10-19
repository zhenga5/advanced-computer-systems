#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")"
mkdir -p build evidence

common=(-std=c++17 -Wall -Wextra)
kernel_flags=(-O3 -march=native -ffp-contract=off)

# Record the environment used for this build.
g++ --version > evidence/compiler.txt
uname -a > evidence/kernel.txt
lscpu > evidence/cpu.txt

# Compile the same test and timing code for both versions.
g++ "${common[@]}" -O0 \
    -c kernels_check.cpp -o build/kernels_check.o

g++ "${common[@]}" -O2 \
    -c benchmark.cpp -o build/benchmark.o

# Optimized scalar kernels.
g++ "${common[@]}" "${kernel_flags[@]}" \
    -fno-tree-loop-vectorize -fno-tree-slp-vectorize \
    -c kernels.cpp -o build/kernels_scalar.o

# CPU-targeted auto-vectorized kernels.
g++ "${common[@]}" "${kernel_flags[@]}" \
    -fopt-info-vec-all \
    -c kernels.cpp -o build/kernels_auto.o \
    2> evidence/vectorization_auto.txt

for mode in scalar auto; do
    g++ "build/kernels_${mode}.o" build/kernels_check.o \
        -o "build/check_${mode}"

    g++ "build/kernels_${mode}.o" build/benchmark.o \
        -o "build/bench_${mode}"

    "./build/check_${mode}" > "evidence/check_${mode}.txt"
    cat "evidence/check_${mode}.txt"
done

echo "Build and correctness checks completed."