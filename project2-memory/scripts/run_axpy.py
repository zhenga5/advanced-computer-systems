import argparse,csv,datetime,hashlib,io,json,os,random,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--smoke',action='store_true');p.add_argument('--no-counters',action='store_true');a=p.parse_args()
if 0 not in os.sched_getaffinity(0):sys.exit('CPU 0 unavailable')
sizes=[16,1024] if a.smoke else [16,32,48,64,256,512,1024,2048,8192,32768,65536,98304,131072,262144,524288]
cases=[(s,'steady') for s in sizes]+[(8192 if a.smoke else 524288,m) for m in ['prepared','setup_inclusive']]
random.Random(42).shuffle(cases);trials=1 if a.smoke else 5;kind='none' if a.no_counters else 'cache'
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ');out=Path('results')/('axpy_'+('smoke_' if a.smoke else '')+stamp);out.mkdir(parents=True)
def swap():
 d=dict(l.split() for l in Path('/proc/vmstat').read_text().splitlines());return {k:int(d[k]) for k in ['pswpin','pswpout']}
meta={'case_order':cases,'smoke':a.smoke,'trials':trials,'counter_set':kind,'cpu':0,'swap_before':swap()}
for name,cmd in [('compiler',['g++','--version']),('kernel',['uname','-a']),('topology',['lscpu','-e'])]:meta[name]=subprocess.check_output(cmd,text=True)
for f in ['src/axpy_memory.cpp','bin/axpy_memory']:meta[f+'_sha256']=hashlib.sha256(Path(f).read_bytes()).hexdigest()
(out/'metadata.json').write_text(json.dumps(meta,indent=2))
with (out/'combined.csv').open('w',newline='') as f:
 w=None
 for size,mode in cases:
  cmd=['taskset','-c','0','./bin/axpy_memory',str(size),mode,str(trials),kind];print(size,mode,flush=True)
  r=subprocess.run(cmd,capture_output=True,text=True);(out/f'{size}_{mode}.csv').write_text(r.stdout);(out/f'{size}_{mode}.log').write_text(' '.join(cmd)+'\n'+r.stderr)
  if r.returncode:sys.exit('Benchmark failed: '+r.stderr)
  rows=list(csv.DictReader(io.StringIO(r.stdout)))
  if len(rows)!=trials:sys.exit('Unexpected trial count')
  if w is None:w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader()
  w.writerows(rows);f.flush()
meta['swap_after']=swap();meta['guest_swap_activity']=meta['swap_before']!=meta['swap_after'];(out/'metadata.json').write_text(json.dumps(meta,indent=2))
print('Upload',out/'combined.csv','and',out/'metadata.json')
