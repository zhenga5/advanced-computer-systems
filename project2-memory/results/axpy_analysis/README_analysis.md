# AXPY analysis

Extract into project2-memory/results/axpy_analysis. No benchmark rerun is needed.
The ZIP includes raw measurements, metadata, summary CSV, plot, and plotting code.
Regenerate with: python3 plot_axpy.py (requires matplotlib).

Validation: 85 rows, 17 cases with five trials each. Source hash matches the
provided benchmark. Throughput and time-per-element arithmetic checks passed.
All counter running fractions are 1.0; metadata reports no guest swapping.

Steady useful throughput decreases from 695.93 GB/s at 48 KiB combined array size
to 426.42 GB/s at 64 KiB, and from 319.75 GB/s at 1 MiB to 226.38 GB/s at 2 MiB.
At 64, 96, 128, 256 and 512 MiB, median useful throughput is respectively 184.40,
122.40, 94.73, 73.38 and 64.91 GB/s. These are logical read/write bytes per second,
including cache-served accesses, not measured DRAM bandwidth. Vectorized independent
updates overlap, so ns per element update must not be called individual load latency.
The transitions are consistent with capacity effects but do not isolate them.

At 512 MiB, the prepared single-pass median is 12.866 ms; initialization plus one
pass takes 160.598 ms (about 12.48 times as long). Median minor faults are 0 versus
131072, consistent with first writes to 512 MiB in 4 KiB pages. This is an explicit
benchmark pitfall: including initialization changes the question being measured.
The difference includes initialization work, faults and cache-state effects, not
solely page-fault servicing. mmap itself was outside both timed regions.

Generic cache misses do not rise monotonically with time per update. For example,
median misses per 1000 updates are about 18.57 at 2 MiB and 3.15 at 512 MiB, while
time per update rises. Therefore these results do not establish a simple positive
miss/runtime relationship. Retain the observation and document the limitation:
the generic event mapping has not been verified for this CPU/WSL setup, and the
streaming kernel has prefetching and overlapping accesses. Do not relabel the event
as L1 or L3 misses or derive per-level AMAT miss probabilities from it.

Plots show median and observed min–max range, not confidence intervals. Dotted
lines mark the previously reported 48 KiB L1d, 1 MiB L2 and 96 MiB shared L3 capacities.
Original trials are retained. Counter validity beyond arithmetic/running time is
not established simply by a successful perf_event_open call.
