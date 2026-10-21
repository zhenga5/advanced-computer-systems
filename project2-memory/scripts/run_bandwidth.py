#!/usr/bin/env python3
import argparse, csv, datetime, hashlib, io, itertools, json, os
from pathlib import Path
import random, subprocess, sys

p=argparse.ArgumentParser()
p.add_argument('--cpu',type=int,default=0)
p.add_argument('--smoke',action='store_true')
a=p.parse_args()
if a.cpu not in os.sched_getaffinity(0):sys.exit('Selected CPU is not available.')
if not Path('bin/bandwidth').is_file():sys.exit('Compile bin/bandwidth first.')
mem={}
for line in Path('/proc/meminfo').read_text().splitlines():
    k,v=line.split(':',1);mem[k]=int(v.strip().split()[0])
if not a.smoke and mem['MemAvailable']<6*1024*1024:
    sys.exit('Need at least 6 GiB MemAvailable for this 4 GiB-span sweep; close heavy workloads and retry.')
span=8 if a.smoke else 4096
trials=1 if a.smoke else 5
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ')
out=Path('results')/('bandwidth_'+('smoke_' if a.smoke else '')+stamp)
out.mkdir(parents=True)
cases=list(itertools.product(('seq','random'),(64,256,1024),(100,0,70,50)))
random.Random(42).shuffle(cases)
metadata={'utc_start':stamp,'guest_cpu':a.cpu,'span_mib':span,'trials':trials,
          'smoke':a.smoke,'config_order':cases,'MemAvailable_kib':mem['MemAvailable'],
          'command_line':sys.argv,'build_command':'g++ -O3 -std=c++17 -Wall -Wextra src/bandwidth.cpp -o bin/bandwidth'}
for name,cmd in [('cpu',['lscpu']),('kernel',['uname','-a']),('compiler',['g++','--version'])]:
    result=subprocess.run(cmd,capture_output=True,text=True);metadata[name]=result.stdout+result.stderr
for filename in ('src/bandwidth.cpp','bin/bandwidth'):
    path=Path(filename)
    if path.exists():metadata[filename+'_sha256']=hashlib.sha256(path.read_bytes()).hexdigest()
def swap_counts():
    d=dict(line.split() for line in Path('/proc/vmstat').read_text().splitlines())
    return {k:int(d[k]) for k in ('pswpin','pswpout')}
metadata['swap_before']=swap_counts()
(out/'metadata.json').write_text(json.dumps(metadata,indent=2))
with (out/'combined.csv').open('w',newline='') as merged:
    writer=None
    for number,(pattern,stride,reads) in enumerate(cases,1):
        label=f'{number:02}_{pattern}_stride{stride}_read{reads}'
        cmd=['taskset','-c',str(a.cpu),'./bin/bandwidth',str(span),pattern,str(stride),str(reads),str(trials)]
        print(f'[{number}/24] {label}',flush=True)
        result=subprocess.run(cmd,capture_output=True,text=True)
        (out/(label+'.csv')).write_text(result.stdout)
        (out/(label+'.log')).write_text('Command: '+' '.join(cmd)+'\n'+result.stderr)
        if result.returncode:sys.exit(f'Failed: {result.stderr}\nPartial results: {out}')
        rows=list(csv.DictReader(io.StringIO(result.stdout)))
        if len(rows)!=trials:sys.exit('Unexpected row count: '+label)
        for row in rows:
            row={'config_order':number,'guest_cpu':a.cpu,**row}
            if writer is None:
                writer=csv.DictWriter(merged,fieldnames=list(row));writer.writeheader()
            writer.writerow(row)
        merged.flush()
metadata['swap_after']=swap_counts()
metadata['guest_swap_activity']=metadata['swap_before']!=metadata['swap_after']
(out/'metadata.json').write_text(json.dumps(metadata,indent=2))
if metadata['guest_swap_activity']:print('Guest swap activity detected: flag these results for review.')
print('Finished. Upload these two files:')
print(out/'combined.csv');print(out/'metadata.json')
