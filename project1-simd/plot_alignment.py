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
keys = ["build", "datatype", "n", "offset_elements"]
if data.duplicated(keys + ["trial"]).any():
    raise ValueError("Duplicate trials")
summary = data.groupby(keys).seconds_per_call.agg(
    median_seconds="median", min_seconds="min",
    max_seconds="max", trials="count").reset_index()
if not summary.trials.eq(7).all():
    raise ValueError("Expected seven trials")
summary["median_ns_per_element"] = summary.median_seconds * 1e9 / summary.n
out = args.csv.parent / "plots_alignment"
out.mkdir(exist_ok=True)
summary.to_csv(out / "summary.csv", index=False)
wide = summary.pivot(index=["build", "datatype", "n"],
                     columns="offset_elements", values="median_seconds")
wide["shifted_over_aligned_time"] = wide[1] / wide[0]
wide.to_csv(out / "alignment_ratios.csv")

def save(fig, name):
    fig.savefig(out / (name + ".png"), dpi=200)
    fig.savefig(out / (name + ".pdf"))
    plt.close(fig)

fig, axes = plt.subplots(2, 2, figsize=(12, 8), layout="constrained")
for row, build in enumerate(["scalar", "auto"]):
    for col, datatype in enumerate(["float", "double"]):
        ax = axes[row, col]
        for offset, label in [(0, "64-byte aligned"), (1, "Shifted one element")]:
            part = summary[(summary.build == build) & (summary.datatype == datatype)
                           & (summary.offset_elements == offset) & (summary.n < 1040)].sort_values("n")
            median = part.median_seconds.to_numpy() * 1e9
            low = part.min_seconds.to_numpy() * 1e9
            high = part.max_seconds.to_numpy() * 1e9
            ax.errorbar(part.n - 1024, median, yerr=[median-low, high-median],
                        fmt="o-", capsize=2, label=label)
        lanes = 16 if datatype == "float" else 8
        for remainder in range(0, 16, lanes):
            ax.axvline(remainder, color="gray", linestyle=":", linewidth=1)
        ax.set_title(f"{build}, {datatype}")
        ax.set_xlabel("Extra elements beyond 1024")
        ax.set_ylabel("Time per call (ns)")
        ax.set_xticks(range(0, 16, 2))
        ax.grid(alpha=0.2)
        ax.legend(fontsize=8)
fig.suptitle("Multiplication: alignment and tails\nMedian and min–max of seven trials; dotted lines mark multiples of 512-bit lane count")
save(fig, "tail_timings")

fig, axes = plt.subplots(1, 2, figsize=(12, 5), layout="constrained")
for ax, datatype in zip(axes, ["float", "double"]):
    x = np.arange(2)
    for j, (build, offset) in enumerate([("scalar", 0), ("scalar", 1), ("auto", 0), ("auto", 1)]):
        part = summary[(summary.datatype == datatype) & (summary.build == build)
                       & (summary.offset_elements == offset) & (summary.n >= 65536)].sort_values("n")
        median = part.median_ns_per_element.to_numpy()
        low = (part.min_seconds * 1e9 / part.n).to_numpy()
        high = (part.max_seconds * 1e9 / part.n).to_numpy()
        ax.bar(x + (j-1.5)*0.2, median, width=0.2,
               yerr=[median-low, high-median], capsize=2,
               label=f"{build}, {'aligned' if offset == 0 else 'shifted'}")
    ax.set_xticks(x, ["65536", "65537"])
    ax.set_xlabel("Elements per array")
    ax.set_ylabel("Time per element (ns)")
    ax.set_title(datatype)
    ax.legend(fontsize=8)
fig.suptitle("Larger multiplication arrays: median and min–max across seven trials")
save(fig, "larger_alignment")
print(f"Saved two figures (PNG/PDF) and processed CSVs in: {out}")
