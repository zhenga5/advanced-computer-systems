#!/usr/bin/env python3
"""Run from the project folder after bash build_stride.sh. Python standard library only."""
import csv
import hashlib
import io
import json
import os
from pathlib import Path
import platform
import random
import shutil
import subprocess
from datetime import datetime, timezone

root = Path(__file__).resolve().parent
os.chdir(root)
required = ['benchmark_stride.cpp', 'kernels_stride.cpp', 'build_stride.sh',
            'build/bench_stride_scalar', 'build/bench_stride_auto']
for name in required:
    if not Path(name).is_file():
        raise SystemExit(f'Missing {name}; run bash build_stride.sh first.')

out = Path('results') / ('stride_' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ'))
(out / 'raw').mkdir(parents=True)
(out / 'sources').mkdir()
(out / 'evidence').mkdir()
for name in required[:3] + ['run_stride.py']:
    shutil.copy2(name, out / 'sources' / Path(name).name)
for p in Path('evidence').glob('*stride*'):
    if p.is_file(): shutil.copy2(p, out / 'evidence' / p.name)

cpu = min(os.sched_getaffinity(0))
os.sched_setaffinity(0, {cpu})  # Children inherit affinity; Windows scheduling remains outside our control.
jobs = []
for n in [1024, 16384, 262144, 4194304]:
    for stride in [1, 2, 4, 8]:
        for mode in ['scalar', 'auto']:
            jobs.append(('fixed_n', n, stride, mode, n))
# n*stride is constant within each group; exact address spans differ by <=7 elements.
for slots in [8192, 131072, 2097152, 33554432]:
    for stride in [1, 2, 4, 8]:
        for mode in ['scalar', 'auto']:
            jobs.append(('fixed_span', slots // stride, stride, mode, slots))
random.Random(20261017).shuffle(jobs)
metadata = {
    'started_utc': datetime.now(timezone.utc).isoformat(), 'status': 'running',
    'platform': platform.platform(), 'logical_cpu': cpu, 'shuffle_seed': 20261017,
    'jobs': jobs, 'trials_per_type': 7, 'calibration_target_seconds': 0.03,
    'binary_sha256': {m: hashlib.sha256(Path(f'build/bench_stride_{m}').read_bytes()).hexdigest()
                      for m in ['scalar', 'auto']},
    'notes': ['Single thread; two warmup calls per trial; validation outside timed region.',
              'Fixed N keeps operations constant but changes address span.',
              'Fixed span keeps n*stride constant but changes operations; compare time/element or useful bandwidth.',
              'Useful bandwidth counts 3*N*sizeof(T), not measured physical memory traffic.',
              'auto denotes the native-target auto-vectorized build, not a generic ISA build.']}
for command, filename in [(['lscpu'], 'cpu.txt'), (['g++', '--version'], 'compiler.txt')]:
    p = subprocess.run(command, capture_output=True, text=True)
    (out / 'evidence' / filename).write_text(p.stdout + p.stderr)
meta_path = out / 'metadata.json'
meta_path.write_text(json.dumps(metadata, indent=2))
try:
    with (out / 'measurements.csv').open('w', newline='') as f:
        writer = None
        for index, (suite, n, stride, mode, group) in enumerate(jobs, 1):
            print(f'[{index}/{len(jobs)}] {suite} {mode} N={n} stride={stride}', flush=True)
            p = subprocess.run([f'./build/bench_stride_{mode}', str(n), str(stride)],
                               capture_output=True, text=True)
            stem = f'{index:03d}_{suite}_{mode}_n{n}_s{stride}'
            (out / 'raw' / (stem + '.csv')).write_text(p.stdout)
            (out / 'raw' / (stem + '.log')).write_text(p.stderr)
            if p.returncode: raise RuntimeError(p.stderr)
            rows = list(csv.DictReader(io.StringIO(p.stdout)))
            if len(rows) != 14: raise RuntimeError('Expected 14 rows per job')
            for row in rows:
                row = dict(suite=suite, group=group, mode=mode, **row)
                row['nanoseconds_per_element'] = float(row['seconds_per_call']) * 1e9 / n
                if writer is None:
                    writer = csv.DictWriter(f, fieldnames=list(row))
                    writer.writeheader()
                writer.writerow(row)
            f.flush()
    metadata['status'] = 'complete'
except BaseException:
    metadata['status'] = 'failed_or_interrupted'
    raise
finally:
    metadata['finished_utc'] = datetime.now(timezone.utc).isoformat()
    meta_path.write_text(json.dumps(metadata, indent=2))
    print(f'Results saved in: {out.resolve()}', flush=True)
