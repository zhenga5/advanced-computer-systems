import argparse,csv,datetime,hashlib,io,json,os,random,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--smoke',action='store_true');a=p.parse_args()
if 0 not in os.sched_getaffinity(0):sys.exit('CPU 0 unavailable')
mem={l.split(':')[0]:int(l.split()[1]) for l in Path('/proc/meminfo').read_text().splitlines()}
if not a.smoke and mem['MemAvailable']<6*1024*1024:sys.exit('Need at least 6 GiB available guest RAM; close heavy workloads.')
cases=[(p,s) for p in ['seq','random'] for s in [64,256,1024]];random.Random(42).shuffle(cases)
mib=8 if a.smoke else 4096;trials=1 if a.smoke else 5;loads=100000 if a.smoke else 8000000
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ');out=Path('results')/('pattern_latency_'+('smoke_' if a.smoke else '')+stamp);out.mkdir(parents=True)
def swaps():
 d=dict(l.split() for l in Path('/proc/vmstat').read_text().splitlines());return {k:int(d[k]) for k in ['pswpin','pswpout']}
meta={'utc_start':stamp,'smoke':a.smoke,'case_order':cases,'cpu':0,'span_mib':mib,'trials':trials,'loads_per_trial':loads,'seed':42,'swap_before':swaps(),'mem_available_kib':mem['MemAvailable']}
for name,cmd in [('compiler',['g++','--version']),('kernel',['uname','-a']),('topology',['lscpu','-e'])]:meta[name]=subprocess.check_output(cmd,text=True)
for f in ['src/pattern_latency.cpp','bin/pattern_latency']:meta[f+'_sha256']=hashlib.sha256(Path(f).read_bytes()).hexdigest()
(out/'metadata.json').write_text(json.dumps(meta,indent=2))
with (out/'combined.csv').open('w',newline='') as f:
 writer=None
 for pattern,spacing in cases:
  cmd=['taskset','-c','0','./bin/pattern_latency',str(mib),pattern,str(spacing),str(trials),str(loads)]
  print(f'Measuring {pattern}, {spacing}-byte spacing',flush=True)
  r=subprocess.run(cmd,capture_output=True,text=True);(out/f'{pattern}_{spacing}.csv').write_text(r.stdout);(out/f'{pattern}_{spacing}.log').write_text(' '.join(cmd)+'\n'+r.stderr)
  if r.returncode:sys.exit('Failed: '+r.stderr+'\nPartial results: '+str(out))
  rows=list(csv.DictReader(io.StringIO(r.stdout)))
  if len(rows)!=trials:sys.exit('Unexpected trial count')
  if writer is None:writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader()
  writer.writerows(rows);f.flush()
meta['swap_after']=swaps();meta['guest_swap_activity']=meta['swap_before']!=meta['swap_after'];(out/'metadata.json').write_text(json.dumps(meta,indent=2))
if meta['guest_swap_activity']:print('Guest swap detected: flag this run for review.')
print('Upload:',out/'combined.csv','and',out/'metadata.json')
