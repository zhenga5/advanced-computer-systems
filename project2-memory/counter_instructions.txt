Project 2: loop-scoped performance counters

Copy latency_counters.cpp into src/ and run_counters.py into scripts/.
From project root:
  g++ -O2 -std=c++17 -Wall -Wextra src/latency_counters.cpp -o bin/latency_counters
  taskset -c 0 ./bin/latency_counters small 32768 tlb 5 8000000
  python3 scripts/run_counters.py 0

CLI: small|huge SIZE_KIB [tlb|cache|core|none] [TRIALS] [LOADS]
Defaults: tlb, 5 trials, 8 million dependent loads.

Uses Linux perf_event_open directly; no perf executable or sudo required if
user-space counters are allowed. Two events are grouped per run:
 tlb: dTLB read accesses, dTLB read misses
 cache: generic cache references, generic cache misses
 core: cycles, instructions
 none: timing-only validation; zeros are placeholders, not measurements.

Events start disabled. Enable after allocation, chain construction, warm-up,
and smaps verification; disable after end timestamp, before output/smaps.
Counters include the loop and small clock/control boundary overhead.
Kernel and hypervisor execution excluded. Per-trial raw deltas and enabled/
running time deltas are recorded. If running_fraction <1, multiplexing or
scheduling affected the counts; retain this field and review before analysis.
Scaled estimate = raw * time_enabled_ns/time_running_ns. Never interpret
unscheduled counters as zero. Errors stop the run with nonzero exit status.

Generic event meanings are CPU/kernel dependent. cache-misses is not a
per-level L1/L2/L3 breakdown, and dTLB-loads is not necessarily the total
number of pointer loads. Prefer misses per known pointer load for comparisons;
do not assume generic miss/access ratios are universal TLB miss probabilities.

The runner tests 32,64,512 MiB, two counter pairs, two fresh process repetitions,
and five inner trials each: 120 rows. Page-mode order is reversed in repetition 2.
These inner trials share an allocation; they are not independent allocations.
Keeps per-process raw CSV/log files and combined.csv in a timestamped folder.
No system settings changed. Original source and results preserved.
Guest CPU pinning does not establish host physical-core pinning under WSL2.
AnonHugePages is guest mapping evidence, not evidence of host page size.
Seed 42 and 64-byte nodes retained from uploaded latency_pages.cpp.

Validation: compiled with GCC -O2 -std=c++17 -Wall -Wextra -Werror;
timing-only small/huge paths and invalid inputs checked locally.
Actual hardware-counter validation must occur on the user's WSL system.
Reference: https://man7.org/linux/man-pages/man2/perf_event_open.2.html
