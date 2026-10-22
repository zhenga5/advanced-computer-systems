from pathlib import Path
import csv,statistics as st,json,hashlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
P=Path(__file__).resolve().parent;D=P/'data';F=P/'figures';O=P/'processed'
F.mkdir(exist_ok=True);O.mkdir(exist_ok=True)
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False})
def read(name):return list(csv.DictReader((D/name).open()))
def grouped(rows,keys,metric):
 g={}
 for r in rows:g.setdefault(tuple(r[k] for k in keys),[]).append(metric(r))
 return {k:(st.median(v),min(v),max(v),len(v)) for k,v in g.items()}
def write(name,keys,g):
 with (O/name).open('w',newline='') as f:
  w=csv.writer(f);w.writerow(keys+['median','min','max','trials']);w.writerows([list(k)+list(v) for k,v in g.items()])
def error(ax,x,v,**kw):ax.errorbar(x,[q[0] for q in v],yerr=[[q[0]-q[1] for q in v],[q[2]-q[0] for q in v]],capsize=3,elinewidth=1.3,**kw)
def save(fig,name):fig.savefig(F/name,dpi=180,bbox_inches='tight');plt.close(fig)
r=read('latency_sweep.csv');g=grouped(r,['size_kib'],lambda x:float(x['elapsed_ns'])/int(x['loads']));write('latency.csv',['size_kib'],g)
x=sorted(int(k[0]) for k in g);fig,ax=plt.subplots(figsize=(10,5),layout='constrained');error(ax,x,[g[str(k),] for k in x],marker='o',color='#176b9b');ax.set_xscale('log',base=2);ax.set_yscale('log');ax.set_xlabel('Working set (KiB)');ax.set_ylabel('ns per dependent load');ax.set_title('Random pointer chase across the memory hierarchy')
for size,label in [(48,'L1d 48 KiB'),(1024,'L2 1 MiB'),(98304,'L3 96 MiB')]:ax.axvline(size,color='gray',ls=':');ax.text(size,150,label,rotation=90,ha='right',va='top',fontsize=9)
ax.set_ylim(.5,180);ax.grid(alpha=.2);save(fig,'01_latency.png')
r=read('pattern_latency.csv');g=grouped(r,['pattern','spacing_bytes'],lambda x:float(x['ns_per_load']));write('pattern_latency.csv',['pattern','spacing_bytes'],g)
fig,ax=plt.subplots(figsize=(9,4.8),layout='constrained')
for pat,c in [('seq','#176b9b'),('random','#bf6526')]:error(ax,[64,256,1024],[g[pat,str(x)] for x in [64,256,1024]],marker='o',label=pat,color=c)
ax.set_xscale('log',base=4);ax.set_xticks([64,256,1024],['64','256','1024']);ax.set_yscale('log');ax.set_xlabel('Node spacing (bytes)');ax.set_ylabel('ns per dependent load');ax.set_title('Predictable and random loads across a 4 GiB span');ax.grid(alpha=.2);ax.legend();save(fig,'02_pattern_latency.png')
r=read('bandwidth.csv');g=grouped(r,['pattern','stride_bytes','read_percent'],lambda x:float(x['useful_GB_s']));write('bandwidth.csv',['pattern','stride_bytes','read_percent'],g)
fig,axs=plt.subplots(1,3,figsize=(13,4.8),sharey=True,layout='constrained')
for ax,stride in zip(axs,[64,256,1024]):
 for pat,c in [('seq','#176b9b'),('random','#bf6526')]:error(ax,range(4),[g[pat,str(stride),str(p)] for p in [100,70,50,0]],marker='o',color=c,label=pat)
 ax.set_xticks(range(4),['100/0','70/30','50/50','0/100']);ax.set_xlabel('Read/write mix');ax.set_title(f'{stride}-byte stride');ax.grid(alpha=.2)
axs[1].scatter([0],[g['seq','256','100'][1]],color='#176b9b',s=25,zorder=6)
axs[1].annotate('3.40 GB/s trial',(0,g['seq','256','100'][1]),xytext=(.35,7),arrowprops={'arrowstyle':'-','color':'gray'},fontsize=9)
axs[0].set_ylabel('Useful GB/s');axs[0].legend();fig.suptitle('Single-worker bandwidth over a 4 GiB span');save(fig,'03_bandwidth.png')
r=read('intensity_mixed.csv');bw=grouped(r,['load_read_percent','load_threads'],lambda x:float(x['load_GB_s']));la=grouped(r,['load_read_percent','load_threads'],lambda x:float(x['probe_ns_per_load']));write('intensity_bandwidth.csv',['read_percent','load_threads'],bw);write('intensity_latency.csv',['read_percent','load_threads'],la)
fig,axs=plt.subplots(2,2,figsize=(11,8),sharex=True,sharey=True,layout='constrained')
for ax,p,c in zip(axs.flat,[100,70,50,0],['#176b9b','#008577','#8956a4','#bf6526']):
 xs=[bw[str(p),str(n)][0] for n in range(8)];ys=[la[str(p),str(n)][0] for n in range(8)]
 ax.scatter([float(v['load_GB_s']) for v in r if int(v['load_read_percent'])==p],[float(v['probe_ns_per_load']) for v in r if int(v['load_read_percent'])==p],color=c,alpha=.22,s=15)
 ax.plot(xs,ys,'o-',color=c)
 for n,(x,y) in enumerate(zip(xs,ys)):
  if n in [0,1,2,7]:ax.annotate(str(n),(x,y),xytext=(5,7),textcoords='offset points',fontsize=9)
 ax.set_title(f'{p}% read / {100-p}% write');ax.set_xlabel('Background useful throughput (GB/s)');ax.set_ylabel('Probe read latency (ns/load)');ax.grid(alpha=.2)
fig.suptitle('Throughput versus latency under increasing load\nLabels are worker counts; lines connect case medians in worker order');save(fig,'04_throughput_latency.png')
fig,axs=plt.subplots(1,2,figsize=(11,4.5),layout='constrained')
for p,c in zip([100,70,50,0],['#176b9b','#008577','#8956a4','#bf6526']):
 for ax,g in zip(axs,[bw,la]):error(ax,range(8),[g[str(p),str(n)] for n in range(8)],marker='o',color=c,label=f'{p}/{100-p}')
axs[0].set_ylabel('Background useful GB/s');axs[1].set_ylabel('Probe ns/load')
for ax in axs:ax.set_xlabel('Background workers');ax.grid(alpha=.2)
axs[0].legend(title='Read/write mix',ncol=2);save(fig,'05_intensity_workers.png')
r=[x for x in read('page_counters.csv') if x['counter_set']=='tlb'];la=grouped(r,['mode','size_kib'],lambda x:float(x['ns_per_load']));mi=grouped(r,['mode','size_kib'],lambda x:int(x['event2_raw'])*int(x['time_enabled_ns'])/int(x['time_running_ns'])/int(x['loads'])*1000);write('page_latency.csv',['mode','size_kib'],la);write('tlb_misses.csv',['mode','size_kib'],mi)
fig,axs=plt.subplots(1,2,figsize=(11,4.6),layout='constrained')
for mode,c,label in [('small','#176b9b','4 KiB pages'),('huge','#bf6526','Huge-page requested')]:
 for ax,g in zip(axs,[la,mi]):error(ax,range(3),[g[mode,str(x)] for x in [32768,65536,524288]],marker='o',color=c,label=label)
for ax in axs:ax.set_xticks(range(3),['32','64','512']);ax.set_xlabel('Working set (MiB)');ax.grid(alpha=.2)
axs[0].set_ylabel('ns per dependent load');axs[1].set_ylabel('dTLB-load-misses / 1,000 pointer loads');axs[0].legend();save(fig,'06_pages.png')
r=read('axpy.csv');sr=[x for x in r if x['mode']=='steady'];la=grouped(sr,['size_kib'],lambda x:float(x['ns_per_element']));bw=grouped(sr,['size_kib'],lambda x:float(x['useful_GB_s']));mi=grouped(sr,['size_kib'],lambda x:int(x['cache_misses_raw'])*int(x['time_enabled_ns'])/int(x['time_running_ns'])/(int(x['elements'])*int(x['passes']))*1000)
for name,g in [('axpy_time.csv',la),('axpy_bandwidth.csv',bw),('axpy_misses.csv',mi)]:write(name,['size_kib'],g)
fig,axs=plt.subplots(1,2,figsize=(11,4.7),layout='constrained');x=sorted(int(k[0]) for k in la);error(axs[0],x,[bw[str(k),] for k in x],marker='o',color='#176b9b');axs[0].set_xscale('log',base=2);axs[0].set_xlabel('Combined array size (KiB)');axs[0].set_ylabel('Useful GB/s');axs[0].grid(alpha=.2)
xs=[mi[str(k),][0] for k in x];ys=[la[str(k),][0] for k in x];corr=st.correlation(xs,ys);axs[1].scatter(xs,ys,color='#176b9b');axs[1].set_xlabel('Generic cache misses / 1,000 updates');axs[1].set_ylabel('ns per element update');axs[1].set_title(f'15 size medians: Pearson r = {corr:.3f}');axs[1].grid(alpha=.2)
for k in [16,2048,524288]:i=x.index(k);axs[1].annotate(('16 KiB' if k==16 else f'{k/1024:g} MiB'),(xs[i],ys[i]),xytext=(4,5),textcoords='offset points',fontsize=9)
save(fig,'07_axpy.png')
g=grouped([x for x in r if x['mode']!='steady'],['mode'],lambda x:float(x['elapsed_ns'])/1e6);write('pitfall_ms.csv',['mode'],g);fig,ax=plt.subplots(figsize=(8,4.6),layout='constrained');v=[g[m,] for m in ['prepared','setup_inclusive']];ax.bar([0,1],[a[0] for a in v],color=['#176b9b','#bf6526']);error(ax,[0,1],v,fmt='none',color='black');ax.set_xticks([0,1],['Prepared kernel','Initialization plus kernel']);ax.set_ylabel('One-pass elapsed time (ms)');ax.set_ylim(0,max(a[2] for a in v)*1.2)
for i,a in enumerate(v):ax.text(i,a[2]+5,f'{a[0]:.2f} ms',ha='center')
ax.set_title('Timing pitfall with 512 MiB of combined arrays');save(fig,'08_pitfall.png')
manifest={str(f.relative_to(P)):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(D.iterdir()) if f.is_file()};(O/'input_sha256.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Generated 8 figures and processed tables. AXPY Pearson:',corr)
