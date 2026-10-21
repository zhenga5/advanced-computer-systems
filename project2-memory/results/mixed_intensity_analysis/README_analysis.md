# Mixed intensity results

Extract this analysis package into project2-memory/results/mixed_intensity_analysis.
It contains analysis, not benchmark source. No benchmark rerun is required to use it.

160 rows: four traffic mixes, eight worker counts, five trials. Arithmetic checks
passed for byte totals, read/write proportions, throughput, and probe latency.
Metadata reports no guest swap activity. Source SHA256 matches the delivered
mixed benchmark. All original trials are retained.

The chart shows medians and observed min–max ranges (not confidence intervals).
Colored solid lines use the left throughput axis; gray dashed lines use the right
latency axis. Axis scales are the same across panels.

Approximate saturation regions:
- 100% read: most bandwidth is reached at two workers (54.735 GB/s), with
  subsequent medians around 55–57 GB/s. Latency rises from 103.270 ns idle to
  240.724 ns at seven workers.
- 70/30: throughput grows from 41.485 GB/s at two workers to 47.470 GB/s at five,
  then declines. Latency is non-monotonic, so a single sharp knee is not supported.
- 50/50: throughput levels off around two workers, roughly 40–42 GB/s.
- Write-only: throughput already reaches 24.817 GB/s with one worker and grows
  only to 27.069 GB/s with seven. Probe latency grows from 106.060 to 250.326 ns.

Peak median useful throughput is 57.284, 47.470, 41.849, and 27.069 GB/s for
100/0, 70/30, 50/50, and 0/100 respectively. These are maxima across worker-count
medians, not individual-trial peaks. This metric excludes write allocation,
writeback, prefetch, page walks and probe traffic; it is not DRAM bus bandwidth.

All latency values describe dependent random reads under the stated background
mix, including the write-only case. They do not measure write latency. Different
mixes need not produce monotonic or equally sized latency effects. Preserve
variation and avoid attributing it specifically to DRAM queues without more evidence.
The four no-worker baselines have medians 103.270–106.328 ns.

Compare mixes within this version. Its chunk size and fence differ from the
previous read-only implementation. Worker count is not outstanding request count.
Background bandwidth and probe latency describe different request populations;
their product is not an exact Little's Law estimate.

To regenerate summary.csv and the PNG, install/use matplotlib in your Python
environment and run: python3 plot_mixed_intensity.py
