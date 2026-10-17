#!/usr/bin/env python3
"""Collect empirical single-thread useful bandwidth for a three-stream add kernel."""
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

os.chdir(Path(__file__).resolve().parent)
files=['benchmark_bandwidth.cpp','kernels_bandwidth.cpp','build_bandwidth.sh','run_bandwidth.py']
exe=Path('build/bench_bandwidth')
for p in files+[str(exe)]:
    if not Path(p).is_file(): raise SystemExit(f'Missing {p}; run bash build_bandwidth.sh first.')
out=Path('results')/('bandwidth_'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ'))
for sub in ['sources','evidence','raw']: (out/sub).mkdir(parents=True,exist_ok=True)
for p in files: shutil.copy2(p,out/'sources'/p)
for p in Path('evidence').glob('*bandwidth*'):
    if p.is_file(): shutil.copy2(p,out/'evidence'/p.name)
cpu=min(os.sched_getaffinity(0))
os.sched_setaffinity(0,{cpu})
# Combined array spans: 192/384/768 MiB float; 384/768/1536 MiB double.
# Two independent process runs per size expose between-run variation.
jobs=[(repeat,n) for repeat in [1,2] for n in [16777216,33554432,67108864]]
random.Random(20261017).shuffle(jobs)
meta={'status':'running','started_utc':datetime.now(timezone.utc).isoformat(),
      'platform':platform.platform(),'logical_cpu':cpu,'jobs':jobs,
      'binary_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
      'useful_bytes_per_call':'3*N*sizeof(T)', 'timing':'steady_clock; calibrated >=30 ms batches (unless repetition cap reached); 7 trials',
      'notes':['One thread; ordinary cached stores; initialization/validation excluded from timing.',
               'Empirical useful bandwidth, not measured physical DRAM bandwidth or a universal hardware peak.',
               'No cache flushing; repeated streaming over arrays larger than reported 96 MiB L3.',
               'Use consistent useful-byte arithmetic intensity when comparing the multiply kernel.',
               'Largest combined allocation is approximately 1.5 GiB; float and double run sequentially.']}
for command,name in [(['lscpu'],'cpu.txt'),(['uname','-a'],'kernel.txt'),(['g++','--version'],'compiler.txt'),(['free','-b'],'memory.txt')]:
    p=subprocess.run(command,capture_output=True,text=True)
    (out/'evidence'/name).write_text(p.stdout+p.stderr)
meta_path=out/'metadata.json'
meta_path.write_text(json.dumps(meta,indent=2))
try:
    with (out/'measurements.csv').open('w',newline='') as f:
        writer=None
        for i,(repeat,n) in enumerate(jobs,1):
            print(f'[{i}/{len(jobs)}] repeat={repeat} N={n}',flush=True)
            p=subprocess.run(['./'+str(exe),str(n)],capture_output=True,text=True)
            stem=f'repeat{repeat}_n{n}'
            (out/'raw'/(stem+'.csv')).write_text(p.stdout)
            (out/'raw'/(stem+'.log')).write_text(p.stderr)
            if p.returncode: raise RuntimeError(p.stderr or f'Process exited with code {p.returncode}')
            rows=list(csv.DictReader(io.StringIO(p.stdout)))
            if len(rows)!=14: raise RuntimeError('Expected 14 trial rows per job')
            for row in rows:
                row=dict(kernel='stream_add',repeat=repeat,**row)
                if writer is None:
                    writer=csv.DictWriter(f,fieldnames=list(row));writer.writeheader()
                writer.writerow(row)
            f.flush()
            print(p.stderr,end='',flush=True)
    meta['status']='complete'
except BaseException:
    meta['status']='failed_or_interrupted'
    raise
finally:
    meta['finished_utc']=datetime.now(timezone.utc).isoformat()
    meta_path.write_text(json.dumps(meta,indent=2))
    print(f'Results saved in: {out.resolve()}',flush=True)
