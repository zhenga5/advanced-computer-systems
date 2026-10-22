# Cache and Memory Performance Profiling

Andrew Zheng | Advanced Computer Systems | Project 2 | October 17, 2026

## Purpose

This project tests how quickly the computer accesses memory under different conditions. The tests change the amount of data, the order of accesses, the distance between accesses, and the amount of other memory activity.

Latency means the time taken for an access. Bandwidth means the amount of data processed per second. A test can have high bandwidth while individual accesses still take a long time.

## Computer and setup

| Item | Setup |
| --- | --- |
| CPU | AMD Ryzen 7 9850X3D, 8 cores and 16 threads |
| Cache | 48 KiB L1 data cache per core, 1 MiB L2 per core, 96 MiB shared L3 |
| OS | Ubuntu 24.04.5 LTS in WSL2 |
| Kernel | `6.18.33.2-microsoft-standard-WSL2` |
| Compiler | GCC 13.3.0 |
| Memory | 32 GB installed; WSL reported about 15 GiB of RAM and 4 GiB of swap |
| Pages | 4 KiB normal pages and 2 MiB huge pages |
| Other settings | SMT enabled; one NUMA node visible in WSL |

The CPU and memory BIOS settings stayed the same during testing. Actual CPU frequency and memory speed were not recorded. Most later single-thread tests used CPU 0. Background workers used CPUs 2, 4, 6, 8, 10, 12, and 14, which are separate cores according to WSL.

Most tests ran five times. The tables show the median, or middle result. Slow trials were kept. Setup and warmup happened before timing, except in the test that intentionally included initialization. The programs also checked their results outside the timed section.

## 1. Data size and latency

This test follows a chain of pointers. Each load tells the program where to load next, so it must wait for one load before continuing. Each trial uses eight million loads.

![Memory latency by data size](report/figures/01_latency.png)

*Figure 1. Median latency with minimum–maximum ranges. The vertical lines mark cache sizes.*

| Example region | Data size | Median ns/load |
| --- | ---: | ---: |
| L1 cache | 16 KiB | 0.717 |
| L2 cache | 512 KiB | 3.290 |
| L3 cache | 8 MiB | 10.636 |
| Main memory | 512 MiB | 103.839 |

Small amounts of data were faster to access because they could fit in the smaller caches. Latency increased as the data grew. For example, it rose from 0.744 ns at 48 KiB to 2.522 ns at 56 KiB, just above the L1 size.

These are times for the whole pointer-chain test, not exact specifications for each cache. There were no added background workers in this test, but Windows could still have other activity. Results stay in nanoseconds because CPU frequency was not measured for conversion to cycles.

## 2. Sequential and random access

This test used a 4 GiB allocation. Sequential access visits nodes in order. Random access follows a shuffled order.

| Distance between nodes | Sequential ns/load | Random ns/load |
| --- | ---: | ---: |
| 64 bytes | 1.379 | 125.774 |
| 256 bytes | 3.682 | 117.636 |
| 1024 bytes | 4.066 | 117.897 |

Sequential access was much faster. The processor can make better use of nearby data and may fetch upcoming data early. Random accesses are harder to predict.

Increasing the spacing also reduced how much data the chain touched. All three cases still touched more than the L3 cache could hold. The sequential results should not be read as the time for one isolated DRAM access.

## 3. Read and write bandwidth

This test processed 64-byte blocks with different read/write mixes. The stride is the spacing between the selected blocks.

| Pattern | Stride | All reads | 70% read | 50% read | All writes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Sequential | 64 B | 53.35 | 38.04 | 39.43 | 25.50 |
| Sequential | 256 B | 14.62 | 31.57 | 21.77 | 20.14 |
| Sequential | 1024 B | 13.52 | 16.87 | 14.91 | 13.53 |
| Random | 64 B | 3.93 | 5.11 | 5.73 | 7.79 |
| Random | 256 B | 3.94 | 5.12 | 5.60 | 8.65 |
| Random | 1024 B | 3.90 | 4.74 | 5.45 | 7.19 |

*Median bandwidth in GB/s. The part that is not reads is writes.*

Sequential reads at 64-byte stride gave the highest value in this test. Larger strides lowered sequential read bandwidth. Random reads were much slower and stayed near 3.9 GB/s.

These numbers count useful bytes processed by the program, not every byte moved by the hardware. Higher write bandwidth also does not prove lower write latency, since writes can be buffered. One sequential 256-byte read trial was unusually slow. A repeat gave a similar median to the original run, and both sets were kept.

## 4. Adding background memory traffic

A pointer-chain read test ran alongside zero to seven workers that accessed memory. Each thread had its own 512 MiB allocation. The timed window was two seconds.

![Bandwidth and latency under load](report/figures/04_throughput_latency.png)

*Figure 2. Bandwidth and read-test latency as workers are added. Small dots show trials; numbers label selected worker counts. The connected points use medians.*

| Background mix | Highest median GB/s | Latency with no workers | Latency with seven workers |
| --- | ---: | ---: | ---: |
| All reads | 57.28 | 103.27 ns | 240.72 ns |
| 70% read | 47.47 | 103.79 ns | 271.47 ns |
| 50% read | 41.85 | 106.33 ns | 241.77 ns |
| All writes | 27.07 | 106.06 ns | 250.33 ns |

Read bandwidth was already 54.74 GB/s with two workers. More workers added little bandwidth, but the read test took longer. This is the knee of the curve: the point where extra workers stop helping much.

The 50/50 mix also mostly leveled off near two workers. All-write traffic was close to its maximum with one worker. The 70/30 results varied more and did not have one clear knee. Every latency value comes from the read test, including when the background workers only write.

## 5. Normal and huge pages

The TLB remembers address translations. Huge pages cover more memory with each translation, which can reduce TLB misses. These tests used two separate runs with five trials each.

| Data size | Normal-page ns/load | Huge-page ns/load | Normal-page misses per 1,000 loads | Huge-page misses per 1,000 loads |
| --- | ---: | ---: | ---: | ---: |
| 32 MiB | 20.90 | 15.88 | 511.44 | 61.86 |
| 64 MiB | 41.63 | 25.91 | 756.55 | 159.98 |
| 512 MiB | 105.20 | 92.96 | 970.82 | 915.26 |

Huge pages reduced latency and reported TLB misses. The biggest latency improvement was about 38% at 64 MiB. At 512 MiB it was about 12%.

The recorded page information confirmed that the huge-page tests used huge pages inside WSL. An earlier unusual result was kept along with later repeats. The table uses the later counter runs. The event counts are not exact miss percentages.

## 6. AXPY and cache misses

AXPY updates two arrays using `y[i] = 0.5*x[i] + y[i]`. The listed size includes both arrays. This test used `-O3 -march=native`, which allows the compiler to use vector instructions.

| Combined size | Useful GB/s | ns/update |
| --- | ---: | ---: |
| 48 KiB | 695.93 | 0.0345 |
| 1 MiB | 319.75 | 0.0751 |
| 2 MiB | 226.38 | 0.1060 |
| 96 MiB | 122.40 | 0.1961 |
| 512 MiB | 64.91 | 0.3697 |

Larger arrays took longer per update. The very high bandwidth for small arrays came from reusing cached data, not from DRAM.

The cache-miss counters did not explain the slowdown well. Misses per 1,000 updates fell from 18.57 at 2 MiB to 3.15 at 512 MiB, even though the larger test was slower. The correlation across all 15 sizes was only 0.124. The exact meaning of these generic counters under WSL was not verified, so they cannot be treated as separate miss rates for each cache.

## 7. Why setup should be timed separately

One AXPY pass over 512 MiB was timed with and without initialization included.

| Timed work | Median time | Minor page faults |
| --- | ---: | ---: |
| AXPY only | 12.87 ms | 0 |
| Initialization and AXPY | 160.60 ms | 131,072 |

Including initialization made the result about 12.5 times slower. Filling the arrays and handling first-touch page faults added work. This shows why initialization should happen before timing when the goal is to measure the kernel itself. The difference is not just page-fault cost, because the extra work also changes cache state.

## Memory models

AMAT means average memory access time:

`AMAT = hit time + miss rate × miss penalty`

A small number of slow accesses can raise the average. For example, use the measured times for L1, L2, L3, and memory, and assume access shares of 90%, 8%, 1.5%, and 0.5%:

`0.90(0.717) + 0.08(3.290) + 0.015(10.636) + 0.005(103.839) = 1.587 ns`

Changing those shares to 90%, 7%, 1%, and 2% raises the average to 3.059 ns. These shares are made-up examples, not measured hit rates. This calculation explains the idea; it does not predict the AXPY result.

Little's Law is:

`requests in progress = requests per second × average request time`

At 103.839 ns per load, the pointer chain completes about 9.63 million loads per second. Multiplying gives about one request in progress, matching how the chain waits for each load.

For a rough loaded-test example, `54.735 billion bytes/s ÷ 64 bytes × 200.778 ns` gives about 172 requests after converting ns to seconds. This assumes each request is 64 bytes and has the measured probe latency. Those assumptions were not verified: the streaming workers and random probe do different work. The value is therefore not a measured hardware queue size.

## Limitations and conclusion

WSL depends on Windows scheduling, and CPU frequency and host background activity were not continuously recorded. Pinning did not reserve physical cores. The early latency CSV did not record CPU affinity. Later run metadata showed no swap activity. Counter enabled/running times matched, but their exact hardware meanings still need caution.

The main findings were that small data sets were faster, sequential access worked better than random access, and adding workers eventually increased delay without much extra bandwidth. Huge pages helped some sizes more than others. The setup test also showed that where timing starts and stops can greatly change the result.

## Code, data, and commands

- [Source code](src/) and [run scripts](scripts/)
- [Original results](results/) and [report input data](report/data/)
- [Summary tables](report/processed/) and [additional plots](report/figures/)
- [Build, run, and plotting commands](report/REPRODUCING.md)

The additional plots are kept as supporting results even though only two appear here.

## Use of Artificial Intelligence (AI)

Through the use of ChatGPT, I was able to teach myself about learning technical skills and details regarding Cache and Memory performance profiling. It was helpful in tweaking benchmarks and drawing conclusions about my work. Some things that I didn't understand were omitted from the report as I felt I could not grasp the AI's analysis. This left only the charts and data I did understand to be documented in the report. Overall AI was a very helpful tool in leveraging my way out of being stuck or confused.

## References

1. Linux man-pages, [perf_event_open](https://man7.org/linux/man-pages/man2/perf_event_open.2.html).
2. Linux kernel documentation, [Transparent Hugepage Support](https://docs.kernel.org/admin-guide/mm/transhuge.html).
3. John D. C. Little, [A Proof for the Queuing Formula L = λW](https://doi.org/10.1287/opre.9.3.383), 1961.
