# SSD Performance Profiling

Andrew Zheng | Advanced Computer Systems | Project 3 | October 17, 2026

## Purpose

This project tests how quickly the SSD reads and writes data under different conditions. The tests change the size of each request, the order of accesses, the read/write mix, and the number of requests in progress.

Latency is how long a request takes. Throughput is how much data is transferred per second. IOPS means input/output operations per second. A test can transfer more data overall while each request takes longer.

## Computer and setup

| Item | Setup |
| --- | --- |
| SSD | Samsung SSD 9100 PRO 2TB, NVMe |
| CPU | AMD Ryzen 7 9850X3D, 8 cores and 16 logical CPUs |
| OS | Ubuntu 24.04.5 LTS in WSL2 on Windows 11 |
| Kernel | `6.18.33.2-microsoft-standard-WSL2` |
| Memory | WSL reported about 15 GiB of RAM |
| Tool | FIO 3.36 |
| Storage tested | A 16 GiB file on the ext4 filesystem inside WSL |
| I/O settings | `libaio`, `direct=1`, one worker |
| Normal timing | 5-second warmup, then 30 seconds of measurement |

The tests wrote only to a disposable file. Windows free space was checked before creating it. The file was filled before testing, and write buffers used changing pseudo-random data with compression set to zero. Requests used block-aligned offsets, with block sizes that were multiples of 4 KiB.

Direct I/O avoids the Linux file-data cache, but Windows and the SSD can still affect the results. The measurements include WSL's virtual storage system. They are not measurements of the SSD alone.

The main sweeps used one run per setting. Selected tests were repeated three times, with their order shuffled between rounds. Repeat tables use averages. The ± values and error bars show sample standard deviation, which describes how much the runs varied. They are not confidence intervals.

Throughput uses decimal MB/s. Block sizes use KiB. Latency uses FIO's total request time, including submission and completion.

## 1. One request at a time

Queue depth is the number of requests allowed to be in progress. QD1 allows one request at a time. These are the original baseline results:

| Workload | IOPS | MB/s | Average latency (µs) | p95 (µs) | p99 (µs) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Random read, 4 KiB | 8,683 | 35.6 | 113.6 | 154.6 | 191.5 |
| Random write, 4 KiB | 7,300 | 29.9 | 134.8 | 158.7 | 207.9 |
| Sequential read, 128 KiB | 8,006 | 1,049.3 | 123.7 | 173.1 | 224.3 |
| Sequential write, 128 KiB | 5,233 | 685.9 | 180.7 | 209.9 | 264.2 |

Sequential access reads or writes in order. Random access chooses different locations. The larger sequential requests transferred more data with each operation. Sequential reads therefore had much higher bandwidth even though their IOPS were similar to random reads. Since both block size and access pattern changed, this table does not separate their effects.

The later three-run checks averaged 32.8 MB/s for random reads, 29.8 MB/s for random writes, 972.5 MB/s for sequential reads, and 694.5 MB/s for sequential writes. The original and repeated results were both kept.

## 2. Queue depth and latency

![Throughput and latency](plots/queue_tradeoff.png)

*Figure 1. Throughput versus average latency in the corrected queue-depth sweep. Numbers label queue depth. Both axes use logarithmic scales. Each point is one run.*

Increasing queue depth helped at first because more requests could be handled together. Eventually, extra requests mainly added waiting time. The point where throughput starts to level off is called the knee.

In this sweep, sequential reads mostly leveled off around QD8. From QD8 to QD64, throughput increased from 2,079 to 2,109 MB/s, while average latency rose from 503 to 3,977 µs. That was little extra throughput for almost eight times the delay.

Sequential writes mostly leveled off around QD8–16. Random writes leveled off around QD16–32 at about 61,000–62,000 IOPS, then slowed at QD64. Random reads were still improving, so higher depths were tested in the next session:

| Random 4 KiB reads | IOPS | Average latency (ms) |
| --- | ---: | ---: |
| QD128 | 96,302 | 1.329 |
| QD256 | 97,252 | 2.632 |

Doubling the depth added only about 1% more IOPS and nearly doubled latency. QD128 was therefore near the useful limit in that session. Later QD128 repeats averaged 93,348 IOPS.

The highest observed 4 KiB random-read rate was 97,252 IOPS. The highest random-write rate was 75,169 IOPS in a later QD16 repeat. These are the highest measured values in these tests, not the SSD's advertised limits.

Results changed between sessions. Sequential 128 KiB reads at QD16 reached 2,105 MB/s in the first corrected sweep, 4,538 MB/s in the block-size sweep, and an average of 4,430 ± 520 MB/s in the final repeats. QD8 averaged 3,434 MB/s in those repeats, so QD16 still helped. The earlier knee was not a fixed limit for the SSD.

## 3. Block size and access pattern

![Block-size results](plots/block_size.png)

*Figure 2. Throughput and average latency for different block sizes. Queue depth stayed at 16 with one worker and a 16 GiB file. Each point is one run.*

Larger blocks moved more data per request. Sequential-read throughput increased from 214.5 MB/s at 4 KiB to 6,967.9 MB/s at 256 KiB. IOPS fell from 52,364 to 26,580, but each operation transferred more bytes. The 256 KiB read was the highest bandwidth measured in the project.

Sequential-write throughput increased from 241.7 to 2,518.0 MB/s over the same block sizes. Larger requests also generally took longer to complete.

Random access was not always slower. At 256 KiB, random reads reached 6,921.9 MB/s, close to the sequential result. SSDs do not have the mechanical seek delay of hard drives. WSL and variation between runs also affect the comparison.

## 4. Read/write mix and data range

![Read/write mix and working-set results](plots/mix_working_set.png)

*Figure 3. Averages of three runs with standard-deviation error bars. All tests used random 4 KiB requests at QD16.*

| Read/write mix | Average IOPS | Average MB/s ± SD |
| --- | ---: | ---: |
| All reads | 57,022 | 233.6 ± 20.7 |
| 70% read / 30% write | 60,028 | 245.9 ± 60.5 |
| 50% read / 50% write | 55,677 | 228.1 ± 25.2 |
| All writes | 51,126 | 209.4 ± 23.9 |

The first mix sweep became slower as more writes were added. The repeats did not follow that pattern consistently. The 70/30 mix had the highest average, but it also varied the most. These results do not clearly show that 70/30 is faster than all reads.

The working set is the range of data being accessed. Reads over the first 1 GiB of the file averaged 229.6 ± 7.4 MB/s. Reads over the full 16 GiB averaged 232.6 ± 17.1 MB/s. The difference was small compared with the variation.

The 16 GiB file covers about 0.86% of the SSD's capacity. Both ranges started at the beginning of the same file. This comparison does not show what would happen when accessing the entire drive.

## 5. Slow requests and tail latency

An average can hide occasional slow requests. The p50 value is the median. A p99 value means about 99% of requests finished within that time. The p99.9 value shows delays farther out in the slow end, or tail, of the results.

| Workload | QD | p50 (µs) | p95 (µs) | p99 (µs) | p99.9 (µs) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Random read, 4 KiB | 16 | 284.7 | 374.8 | 436.2 | 1,130.5 |
| Random read, 4 KiB | 128 | 1,362.6 | 1,559.2 | 1,728.5 | 3,260.4 |
| Random write, 4 KiB | 8 | 150.4 | 226.3 | 291.2 | 425.3 |
| Random write, 4 KiB | 16 | 238.3 | 381.6 | 468.3 | 763.2 |
| Sequential write, 128 KiB | 8 | 261.5 | 1,170.1 | 1,400.8 | 2,506.8 |
| Sequential write, 128 KiB | 16 | 494.9 | 1,493.7 | 1,750.4 | 4,014.1 |

*Values are averages of the three separate runs' percentiles, not percentiles calculated from all requests combined.*

Random-read QD16 is a middle depth, while QD128 is near the measured plateau. Its p99.9 latency rose from about 1.13 to 3.26 ms. The write cases also had longer delays at higher depth. More requests in progress can improve throughput while making the slow requests take longer.

Not every percentile increased in every workload. The full tables and additional tail-latency plot are included in the supporting results.

## 6. Writing for a longer period

A final test wrote sequentially for 120 seconds using 128 KiB requests at QD16. It reused the 16 GiB file and recorded throughput roughly once per second, without excluding a warmup period.

| Part of the test | Average MB/s |
| --- | ---: |
| First ten logged samples | 2,729 |
| Last ten logged samples | 2,013 |
| Complete FIO run | 2,356 |

The last ten samples were about 26% slower than the first ten. The trace also had several short bursts of higher throughput. It is included in `plots/sustained_write.png`.

An SSD's fast write cache, internal cleanup called garbage collection, temperature, or Windows activity could affect this behavior. These were not measured directly, so the slowdown cannot be assigned to one cause. The drive had already been used by earlier tests. This was not a fresh-drive test, and two minutes does not prove long-term steady-state performance.

## 7. A misleading test setup

The first queue-depth script produced files named `qd1`, `qd2`, and so on, but the configuration kept every test at QD1. Looking only at the filenames would have made it seem that higher queue depth did not help.

The problem was found by checking the actual settings and depth distribution in the JSON output. The corrected script created a separate configuration for each test and checked the result afterward.

The 28 incorrect runs were kept as evidence but excluded from the performance plots. FIO groups depths of 64 and above together in its depth histogram, so the saved settings and Little's Law calculation were also used to check the higher-depth runs.

## Little's Law

Little's Law is:

`requests in progress = requests per second × average request time`

For the corrected random-read QD16 run:

`56,988.5 IOPS × 0.000280215 seconds ≈ 15.97 requests`

This is close to the requested depth of 16. It helps explain the tradeoff: if throughput stops increasing, keeping more requests in progress means they spend longer waiting. This calculation describes requests measured by FIO, not the SSD's internal queue directly.

## Limitations and conclusion

WSL includes Windows and virtual-disk overhead. Background activity, temperature, CPU frequency, and the negotiated PCIe link speed were not continuously recorded. The SSD controller, flash memory, interface, or software could limit performance, and these tests do not separate those limits.

The file was filled before testing, but the whole drive was not prepared to a controlled starting state. Direct I/O also does not remove every possible cache effect. Writes were not forced to permanent storage after every request, so their latency does not measure protection against power loss.

The main findings were that larger blocks increased bandwidth and higher queue depth helped until throughput began leveling off. Beyond that point, extra depth mostly increased delay. Results also varied between sessions, which shows why checking settings and repeating measurements were important.

## Code, data, and commands

- [Benchmark and analysis scripts](scripts/)
- [Original results and configurations](results/)
- [Parsed data and repeat summaries](results/analysis/)
- [Figures and additional plots](plots/)

There are 114 valid runs and 28 preserved runs from the incorrect setup. All returned zero FIO errors and zero short or dropped I/Os. This does not replace a separate data-integrity test.

To recreate the tables and plots from the saved data:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python scripts/analyze.py
```

The corrected benchmark runners are `run_queue_fixed.sh`, `run_more.py`, and `run_checks.py`. They perform writes to the prepared test file. The old `run_queue.sh` is retained only to document the mistake. The additional plots are kept even though only three appear in this report.

## Use of Artificial Intelligence (AI)

Through the use of ChatGPT, I was able to help explain SSD profiling concepts, write benchmark scripts, and interpret results. This was all very useful in organizing the plots used in the report and analyzing the measurements that came from FIO runs on my computer. AI was hlepful in simplifying the explaination to me so I could understand it. There was a particularly helpful time when AI helped me fix a configuration mistake while running the queue-depth scripts, which I found by checking the output and comparing it to the expected results.

## References

1. [FIO documentation](https://fio.readthedocs.io/en/latest/fio_doc.html).
2. Microsoft, [How to manage WSL disk space](https://learn.microsoft.com/en-us/windows/wsl/disk-space).
