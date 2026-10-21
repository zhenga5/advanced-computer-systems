#!/usr/bin/env python3
import argparse,csv,datetime,hashlib,io,json,os,random,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--smoke',action='store_true');a=p.parse_args()
levels=[0,1] if a.smoke else list(range(8))
cases=[(n,r) for r in [100,70,50,0] for n in levels];random.Random(42).shuffle(cases)
needed={0}|{2*i for i in range(1,max(levels)+1)}
if not needed.issubset(os.sched_getaffinity(0)):sys.exit('Required CPUs unavailable: '+str(sorted(needed)))
mem=dict((l.split(':')[0],int(l.split()[1])) for l in Path('/proc/meminfo').read_text().splitlines())
if not a.smoke and mem['MemAvailable']<6*1024*1024:sys.exit('Need >=6 GiB MemAvailable. Close heavy workloads first.')
trials=1 if a.smoke else 5;seconds=1 if a.smoke else 2;mib=8 if a.smoke else 512
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ')
out=Path('results')/('intensity_mixed_'+('smoke_' if a.smoke else '')+stamp);out.mkdir(parents=True)
def swaps():
 d=dict(l.split() for l in Path('/proc/vmstat').read_text().splitlines());return {k:int(d[k]) for k in ['pswpin','pswpout']}
meta={'utc_start':stamp,'smoke':a.smoke,'case_order':cases,'probe_cpu':0,'load_cpus':[2*i for i in range(1,8)],'buffer_mib_per_thread':mib,'window_seconds':seconds,'trials':trials,'load_read_percents':[100,70,50,0],'swap_before':swaps(),'mem_available_kib':mem['MemAvailable']}
for k,c in [('topology',['lscpu','-e=CPU,CORE,SOCKET,NODE,ONLINE']),('kernel',['uname','-a']),('compiler',['g++','--version'])]:
 r=subprocess.run(c,capture_output=True,text=True);meta[k]=r.stdout+r.stderr
for f in ['src/loaded_latency_mixed.cpp','bin/loaded_latency_mixed']:
 meta[f+'_sha256']=hashlib.sha256(Path(f).read_bytes()).hexdigest()
(out/'metadata.json').write_text(json.dumps(meta,indent=2))
with (out/'combined.csv').open('w',newline='') as merged:
 writer=None
 for n,read_percent in cases:
  cmd=['./bin/loaded_latency_mixed',str(n),str(trials),str(seconds),str(mib),str(read_percent)]
  print(f'Measuring {read_percent}% read: {n} load threads + 1 probe',flush=True)
  r=subprocess.run(cmd,capture_output=True,text=True)
  (out/f'read_{read_percent}_load_{n}.csv').write_text(r.stdout);(out/f'read_{read_percent}_load_{n}.log').write_text('Command: '+' '.join(cmd)+'\n'+r.stderr)
  if r.returncode:sys.exit('Failed: '+r.stderr+'\nPartial results: '+str(out))
  rows=list(csv.DictReader(io.StringIO(r.stdout)))
  if len(rows)!=trials:sys.exit('Unexpected trial count')
  for row in rows:
   if writer is None:writer=csv.DictWriter(merged,fieldnames=list(row));writer.writeheader()
   writer.writerow(row)
  merged.flush()
meta['swap_after']=swaps();meta['guest_swap_activity']=meta['swap_before']!=meta['swap_after'];(out/'metadata.json').write_text(json.dumps(meta,indent=2))
if meta['guest_swap_activity']:print('Guest swap detected; flag results for review.')
print('Upload:',out/'combined.csv','and',out/'metadata.json')
