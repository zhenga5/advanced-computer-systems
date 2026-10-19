#!/usr/bin/env python3
"""Plot three-kernel measurements without combining different kernels."""
import argparse
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("csv", type=Path)
args = parser.parse_args()
data = pd.read_csv(args.csv)
keys = ["kernel", "build", "datatype", "n"]
if data.duplicated(keys + ["trial"]).any():
    raise ValueError("Duplicate trials found")
if not np.isfinite(data.seconds_per_call).all() or (data.seconds_per_call <= 0).any():
    raise ValueError("Invalid timing values")
summary = data.groupby(keys).agg(
    median_seconds=("seconds_per_call", "median"),
    min_seconds=("seconds_per_call", "min"),
    max_seconds=("seconds_per_call", "max"),
    trials=("seconds_per_call", "count"),
    working_set_bytes=("working_set_bytes", "first"),
).reset_index()
if not summary.trials.eq(7).all():
    raise ValueError("Expected seven trials per configuration")
summary["working_set_mib"] = summary.working_set_bytes / 2**20
summary["median_gflops"] = summary.n * summary.kernel.map(
    {"multiply": 1, "axpy": 2, "dot": 2}) / summary.median_seconds / 1e9
summary["median_useful_gib_per_second"] = (
    summary.n * summary.datatype.map({"float": 4, "double": 8})
    * summary.kernel.map({"multiply": 3, "axpy": 3, "dot": 2})
    / summary.median_seconds / 2**30)
out = args.csv.parent / "plots_all"
out.mkdir(exist_ok=True)
summary.to_csv(out / "summary.csv", index=False)

def decorate(ax):
    ax.set_xscale("log", base=2)
    ax.set_xlabel("Combined array size (MiB)")
    ax.grid(alpha=0.2)
    for x, label in [(48/1024, "L1d 48 KiB"), (1, "L2 1 MiB"), (96, "L3 96 MiB")]:
        ax.axvline(x, color="gray", linestyle=":", linewidth=1)
        ax.text(x, 0.98, label, transform=ax.get_xaxis_transform(),
                rotation=90, va="top", ha="right", fontsize=8)

def save(fig, name):
    fig.savefig(out / f"{name}.png", dpi=200)
    fig.savefig(out / f"{name}.pdf")
    plt.close(fig)

speedups = []
for kernel in ["multiply", "axpy", "dot"]:
    subset = summary[summary.kernel == kernel]
    fig, ax = plt.subplots(figsize=(9, 5), layout="constrained")
    for datatype, color in [("float", "#1769aa"), ("double", "#c75c10")]:
        part = subset[subset.datatype == datatype]
        a = part[part.build == "scalar"].set_index("n").sort_index()
        b = part[part.build == "auto"].set_index("n").sort_index()
        if not a.index.equals(b.index):
            raise ValueError("Scalar and auto sizes do not match")
        ratio = a.median_seconds / b.median_seconds
        ax.plot(a.working_set_mib, ratio, "o-", label=datatype, color=color)
        for n in a.index:
            speedups.append({"kernel": kernel, "datatype": datatype, "n": n,
                "working_set_mib": a.loc[n, "working_set_mib"], "speedup": ratio.loc[n]})
    ax.axhline(1, color="black", linestyle="--", linewidth=1)
    ax.set_ylim(bottom=0)
    ax.set_ylabel("Speedup (scalar median / native-auto median)")
    ax.set_title(f"{kernel}: speedup from median timings")
    decorate(ax)
    ax.legend(loc="upper right")
    save(fig, f"{kernel}_speedup")

    for metric, ylabel in [("gflops", "Throughput (GFLOP/s)"),
                            ("useful_gib_per_second", "Useful data throughput (GiB/s)")]:
        fig, axes = plt.subplots(1, 2, figsize=(13, 5), sharey=True, layout="constrained")
        for ax, datatype in zip(axes, ["float", "double"]):
            for build, label, color in [("scalar", "Scalar", "#1769aa"),
                                        ("auto", "Native auto", "#c75c10")]:
                part = subset[(subset.datatype == datatype) & (subset.build == build)].sort_values("n")
                median = part[f"median_{metric}"]
                low = median * part.median_seconds / part.max_seconds
                high = median * part.median_seconds / part.min_seconds
                ax.errorbar(part.working_set_mib, median,
                            yerr=np.array([median-low, high-median]),
                            fmt="o-", capsize=3, label=label, color=color)
            decorate(ax)
            ax.set_title(datatype)
            ax.set_ylim(bottom=0)
            ax.legend(loc="lower left")
        axes[0].set_ylabel(ylabel)
        note = "Useful bytes are algorithm reads/writes, not measured DRAM traffic." if metric != "gflops" else ""
        fig.suptitle(f"{kernel}: median and min–max across seven trials\n{note}")
        save(fig, f"{kernel}_{metric}")

pd.DataFrame(speedups).to_csv(out / "speedup.csv", index=False)
print(f"Saved nine plots (PNG and PDF) and two processed CSVs in: {out}")
