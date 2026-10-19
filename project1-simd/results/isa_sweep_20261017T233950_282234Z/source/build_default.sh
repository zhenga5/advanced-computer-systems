#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
# Rebuild scalar and native-auto with the same current sources and compiler.
bash build_all.sh
# No -march or -mtune override: record GCC's default target explicitly.
g++ -std=c++17 -O3 -ffp-contract=off -Wall -Wextra \
    -fopt-info-vec-all -c kernels.cpp -o build/kernels_default.o \
    2> evidence/vectorization_default.txt
g++ build/kernels_default.o build/kernels_check.o -o build/check_default
./build/check_default | tee evidence/check_default.txt
g++ build/kernels_default.o build/benchmark_all.o -o build/bench_all_default
g++ -Q -O3 --help=target > evidence/default_target.txt
for mode in scalar default auto; do
    objdump -d -C -Mintel "build/kernels_${mode}.o" > "evidence/isa_${mode}.asm"
done
printf 'All three builds and correctness checks completed.\n'
