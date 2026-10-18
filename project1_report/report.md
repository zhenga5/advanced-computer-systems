# Project 1 report package

This folder belongs inside the existing `project1-simd` repository. It supplements the benchmark source and original timestamped result directories; it does not replace them.

## Contents

- `SIMD_Project1_Report.pdf`: nine-page report for review.
- `report.md`: editable Markdown text with relative figure links.
- `figures/`: six report figures, each in PNG and PDF format.
- `data/`: selected raw measurements plus processed summaries.
- `evidence/`: supplied environment, final ISA-run metadata, compiler report and inspected assembly.
- `scripts/make_figures.py`: regenerate report figures and summaries from `data/`.
- `scripts/write_report.py`: regenerate the Markdown and PDF report; prose is defined in this script.
- `manifest.json`: source mapping and SHA-256 checksums for the included raw data/evidence.

## Reproduce the report

From the repository root, using the existing virtual environment:

```bash
source .venv/bin/activate
python3 -m pip install reportlab pillow
python3 project1_report/scripts/make_figures.py
python3 project1_report/scripts/write_report.py
```

NumPy, pandas and matplotlib are also required and were already installed for the experiments. Opening the supplied PDF does not require installing any of these packages. The report generator overwrites `report.md`; edit prose in `scripts/write_report.py` if regenerating. For manual-only Markdown edits, do not rerun that generator until the edits have been transferred.

## Data provenance

| Local report data | Intended role |
|---|---|
| isa.csv | Final three-build baseline, 2,016 rows |
| alignment.csv | Alignment/tails, 1,008 rows |
| stride.csv | Complete stride sweep, 896 rows |
| bandwidth.csv | Independent add calibration, 84 rows |
| cycles.csv | Dedicated hardware-counter sweep, 504 rows |

The incomplete stride upload measurements(4).csv and superseded two-build measurements(2).csv are not used in the final report. Original run directories contain additional source snapshots, raw process outputs, checks and metadata and should remain in the repository.

## Methodology notes

- The final ISA sweep is `results/isa_sweep_20261017T233950_282234Z`.
- Bandwidth calibration is `results/bandwidth_20261017T232651_908013Z`.
- Stride sweep is `results/stride_20261017T141742_111863Z`.
- The 4.7 GHz compute reference is an architectural modeling assumption, not measured frequency. The CPE data comes from actual guest-exposed counters, not that frequency assumption.
- Early background-load observations are not used as controlled stress-test evidence.
- Current Balanced power and SMT state do not establish historical settings for every run; this limitation is disclosed.
- Only largest-size multiply is shown on the streaming roofline; cache-resident results appear in separate throughput/speedup plots.

