# Project 2: read-only loaded-latency sweep

Place loaded_latency.cpp in src/, run_intensity.py in scripts/, and keep this
README in the project folder. Build and run from project2-memory:

    g++ -O3 -std=c++17 -Wall -Wextra -pthread src/loaded_latency.cpp -o bin/loaded_latency
    python3 scripts/run_intensity.py --smoke
    python3 scripts/run_intensity.py

Upload combined.csv and metadata.json from the FULL run directory printed by
the runner. The smoke run uses 8 MiB and is correctness validation only.

## Method

The probe runs on guest CPU 0. Load threads use guest CPUs 2,4,6,8,10,12,14,
in that order, matching the user's observed pairs 0/1,2/3,...14/15. The probe's
reported SMT sibling stays idle. Guest topology/affinity is not proof of host
physical-core placement under WSL2. Do not run this entire multithreaded program
under taskset -c 0: each thread sets and verifies its own affinity.

Probe: seed-42 random cycle of 64-byte nodes, dependent 8-byte pointer loads,
512 MiB in full mode. A complete traversal warms it before trials. Small guest
pages requested with MADV_NOHUGEPAGE. Data load workers each allocate, initialize,
and sequentially read a private 512 MiB buffer with eight scalar volatile
64-bit accumulators. They read every byte. Maximum allocated workload data is
4 GiB plus temporary initialization/storage overhead. Runner requires at least
6 GiB MemAvailable. This is not a peak SIMD/memory-controller benchmark.

All workers finish initialization before launch. A common timestamp gives
250 ms of concurrent warm-up followed by a 2-second measurement window. The
probe follows pointers in blocks of 1024; workers stream in 64 KiB chunks.
Only chunks wholly inside the common measurement window enter measurements.

load_GB_s = included worker bytes / common window nanoseconds (decimal GB/s).
This counts only background useful read bytes; it excludes probe traffic,
page walks and additional physical memory traffic. Boundary chunks are omitted,
which slightly undercounts traffic. excluded_load_chunks includes warm-up
chunks as well as boundary chunks; it is not a hardware drop counter.

probe_ns_per_load = sum of included probe-chunk durations / included probe loads.
This is dependent-load latency under traffic, including loop/timestamp overhead
and scheduling pauses inside included chunks. It is not isolated DRAM service
time. Time between chunks and chunks crossing boundaries is excluded.

The 0-worker case uses the same probe/timing path, serving as this experiment's
unloaded baseline. It need not exactly equal older baseline runs.

There are eight worker-count configurations and five trials each (40 rows).
Configuration order is seed-42 shuffled. Workers allocate fresh buffers each
trial; the probe allocation persists within a configuration. The seed/cycle
is fixed. Keep all raw data, and show min-max or other clearly labeled variability.
Checksums verify streamed values; final probe address is checked for alignment
and range. Worker errors abort rather than silently removing a load thread.
Metadata records topology, compiler, source/binary hashes, and guest swap counts.
Guest swap checks do not rule out Windows-side memory pressure.

## Interpretation

Plot achieved background bandwidth and probe latency versus worker count, plus
probe latency versus achieved bandwidth. Identify a throughput knee only if the
measured data supports one; 7 workers might not demonstrate a clear plateau.
A latency increase may reflect queuing, cache/translation contention, frequency,
or scheduling effects. It is not solely proof of memory-controller queuing.

Little's Law requires throughput and response time for the SAME request
population. Background sequential throughput and a separate random probe's
latency are different populations. Multiplying them can only give an explicitly
assumed proxy, not measured outstanding background requests. Do not assert that
worker count equals outstanding memory requests. Further concurrency work may
be needed for a quantitative Little's Law demonstration.

This is the read-only intensity sweep. It does not yet provide loaded latency
for all read/write mixes, a per-level cache-miss/AMAT model, or kernel correlation.

Validation: GCC -O3 -std=c++17 -Wall -Wextra -Werror -pthread compile;
zero, one, and four worker cases at 8 MiB passed; end-to-end smoke runner and
CSV arithmetic checked. Local smoke timings are not user-machine measurements.
