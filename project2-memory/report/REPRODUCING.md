# Reproducing the experiments

[Back to the report](../README.md)


### Regenerate the report figures

The figure builder uses the report's archived measurement snapshots, so it does not rerun benchmarks or overwrite original result folders. From the repository root:

```bash
python3 -m venv .venv-report
source .venv-report/bin/activate
python3 -m pip install -r project2-memory/report/requirements.txt
python3 project2-memory/report/make_figures.py
```

This generates eight PNG figures, the median/min/max tables in `report/processed`, and a SHA-256 manifest of the archived inputs. The README is the report text. Figure/table interpretation is written explicitly rather than generated from a fitted model.

### Build the benchmarks

Use an x86-64 Linux environment with G++, Python 3 and `taskset`. The code uses Linux mappings and counter APIs. From the repository root:

```bash
cd project2-memory
mkdir -p bin

for name in latency latency_sweep latency_pages latency_counters bandwidth pattern_latency; do
    g++ -O3 -std=c++17 -Wall -Wextra "src/$name.cpp" -o "bin/$name"
done

for name in loaded_latency loaded_latency_mixed; do
    g++ -O3 -std=c++17 -pthread -Wall -Wextra "src/$name.cpp" -o "bin/$name"
done

g++ -O3 -march=native -std=c++17 -Wall -Wextra \
    src/axpy_memory.cpp -o bin/axpy_memory
```

`-march=native` makes the AXPY binary specific to the build host; rebuild on another CPU. These commands are the intended reproduction build. Original source/binary hashes are available in the later metadata files, but the earliest standalone CSVs do not contain complete build provenance.

### Collect new measurements

Run each experiment separately with other heavy workloads closed. Full bandwidth and pattern-latency runs need at least 6 GiB of available guest memory. The runners check availability where implemented. Do not wrap the multiworker runners in `taskset -c 0`: they pin their own threads.

```bash
# From project2-memory. Quick correctness checks first:
python3 scripts/run_bandwidth.py --smoke
python3 scripts/run_intensity.py --smoke
python3 scripts/run_intensity_mixed.py --smoke
python3 scripts/run_axpy.py --smoke
python3 scripts/run_pattern_latency.py --smoke

# Full experiments; each creates a new timestamped result folder:
python3 scripts/run_counters.py 0
python3 scripts/run_bandwidth.py --cpu 0
python3 scripts/run_intensity.py
python3 scripts/run_intensity_mixed.py
python3 scripts/run_axpy.py
python3 scripts/run_pattern_latency.py
```

A counter failure should be investigated rather than silently replaced with zeros. The AXPY runner's `--no-counters` mode is for diagnosis and does not reproduce the counter experiment.

For the standalone latency and page sweeps, use a new directory to preserve earlier data:

```bash
run_dir="results/latency_reproduction_$(date -u +%Y%m%dT%H%M%S)_$$"
mkdir -p "$run_dir"
taskset -c 0 ./bin/latency > "$run_dir/latency_baseline.csv"
taskset -c 0 ./bin/latency_sweep > "$run_dir/latency_sweep.csv"
taskset -c 0 ./bin/latency_pages small > "$run_dir/latency_pages_small.csv"
taskset -c 0 ./bin/latency_pages huge > "$run_dir/latency_pages_huge.csv"
```

Inspect exit status, expected row counts, page backing, running fractions, faults and swap counters before accepting a new run. Smoke-test folders and an unreviewed earlier mixed-intensity run are not used for any report result. Existing local untracked files are not required for figure reproduction.

