import argparse
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument("csv", type=Path)
args = parser.parse_args()

data = pd.read_csv(args.csv)
output = args.csv.parent / "plots"
output.mkdir(exist_ok=True)

# Summarize the seven trials for each configuration.
summary = (
    data.groupby(["build", "datatype", "n"])["seconds_per_call"]
    .agg(
        median_seconds="median",
        min_seconds="min",
        max_seconds="max",
        trials="count",
    )
    .reset_index()
)

# Multiplication uses three arrays and performs one FLOP per element.
summary["working_set_mib"] = (
    3 * summary["n"]
    * summary["datatype"].map({"float": 4, "double": 8})
    / 2**20
)
summary["median_gflops"] = (
    summary["n"] / summary["median_seconds"] / 1e9
)
summary.to_csv(output / "summary.csv", index=False)

# Cache capacities reported by your lscpu output.
caches = [
    (48 / 1024, "L1d: 48 KiB"),
    (1, "L2: 1 MiB"),
    (96, "L3: 96 MiB"),
]


def format_axis(ax):
    ax.set_xscale("log", base=2)
    ax.set_xlabel("Combined array size (MiB)")
    ax.grid(True, alpha=0.25)

    for size, label in caches:
        ax.axvline(size, color="gray", linestyle=":", alpha=0.7)
        ax.text(
            size, 0.98, label,
            transform=ax.get_xaxis_transform(),
            rotation=90, va="top", ha="right", fontsize=8,
        )


# Speedup is the ratio of the two median execution times.
fig, ax = plt.subplots(figsize=(10, 6))
speedup_tables = []

for datatype in ["float", "double"]:
    subset = summary[summary["datatype"] == datatype]
    scalar = subset[subset["build"] == "scalar"].set_index("n")
    auto = subset[subset["build"] == "auto"].set_index("n")

    speedup = scalar["median_seconds"] / auto["median_seconds"]

    ax.plot(
        scalar["working_set_mib"], speedup,
        marker="o", label=datatype,
    )

    speedup_tables.append(pd.DataFrame({
        "datatype": datatype,
        "n": scalar.index,
        "working_set_mib": scalar["working_set_mib"].to_numpy(),
        "speedup": speedup.to_numpy(),
    }))

pd.concat(speedup_tables, ignore_index=True).to_csv(
    output / "speedup.csv", index=False
)

ax.axhline(1, color="black", linestyle="--", linewidth=1)
ax.set_ylabel("Speedup (scalar median / auto median)")
ax.set_title("Elementwise multiplication: SIMD speedup")
ax.set_ylim(bottom=0)
format_axis(ax)
ax.legend(loc="upper right")
fig.tight_layout()
fig.savefig(output / "speedup.png", dpi=200)
plt.close(fig)

# Throughput error bars show the full observed trial range.
fig, axes = plt.subplots(1, 2, figsize=(13, 5), sharey=True)

for ax, datatype in zip(axes, ["float", "double"]):
    for build in ["scalar", "auto"]:
        subset = summary[
            (summary["datatype"] == datatype)
            & (summary["build"] == build)
        ].sort_values("n")

        median = subset["median_gflops"]
        low = subset["n"] / subset["max_seconds"] / 1e9
        high = subset["n"] / subset["min_seconds"] / 1e9

        ax.errorbar(
            subset["working_set_mib"], median,
            yerr=[median - low, high - median],
            marker="o", capsize=3, label=build,
        )

    ax.set_title(datatype)
    format_axis(ax)
    ax.legend(loc="upper right")

axes[0].set_ylabel("Throughput (GFLOP/s)")
axes[0].set_ylim(bottom=0)
fig.suptitle(
    "Multiplication throughput: median and min–max across seven trials"
)
fig.tight_layout()
fig.savefig(output / "throughput.png", dpi=200)
plt.close(fig)

print(f"Saved plots and processed data in: {output}")