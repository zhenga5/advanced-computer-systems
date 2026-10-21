import csv,collections,statistics,sys
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
source=Path(sys.argv[1]);out=Path(sys.argv[2]) if len(sys.argv)>2 else Path('results/intensity_plots');out.mkdir(parents=True,exist_ok=True)
g=collections.defaultdict(list)
with source.open() as f:
 for r in csv.DictReader(f):g[int(r['load_threads'])].append(r)
x=sorted(g)
def vals(field):
 a=[[float(r[field]) for r in g[k]] for k in x];m=[statistics.median(v) for v in a]
 return a,m,[[z-min(v) for z,v in zip(m,a)],[max(v)-z for z,v in zip(m,a)]]
b,bm,be=vals('load_GB_s');l,lm,le=vals('probe_ns_per_load')
fig,axes=plt.subplots(1,3,figsize=(14,4.8),layout='constrained')
for ax,med,err,color,label in [(axes[0],bm,be,'#176b9b','Background useful bandwidth (GB/s)'),(axes[1],lm,le,'#b75630','Probe latency (ns/load)')]:
 ax.errorbar(x,med,yerr=err,fmt='o-',capsize=3,color=color);ax.set_xticks(x);ax.set_xlabel('Load threads (plus one probe)');ax.set_ylabel(label);ax.grid(alpha=.2);ax.set_ylim(bottom=0)
axes[0].axvspan(1.5,2.5,color='#176b9b',alpha=.08);axes[0].set_title('Throughput plateaus near 2 load threads')
axes[1].set_title('Latency continues rising under load')
axes[2].plot(bm,lm,'o-',color='#66579b')
for k,bs,ls in zip(x,b,l):axes[2].scatter(bs,ls,s=13,alpha=.35,color='#66579b')
for k in (0,1,2,7):
 i=x.index(k);axes[2].annotate(str(k)+' threads',(bm[i],lm[i]),xytext=(5,-12 if k==2 else 8),textcoords='offset points',fontsize=9)
axes[2].set_xlabel('Background useful bandwidth (GB/s)');axes[2].set_ylabel('Probe latency (ns/load)');axes[2].grid(alpha=.2);axes[2].set_xlim(-3,70);axes[2].set_ylim(80,280);axes[2].set_title('Latency vs. achieved background bandwidth')
fig.suptitle('Read-only loaded latency: limited throughput gains beyond the knee',fontweight='bold',fontsize=14)
fig.text(.01,-.075,'Medians of five trials; error bars show min–max; faint dots show paired trials. 512 MiB per thread, 2-second windows.\nWSL guest CPU 0: probe; CPUs 2–14 (even): load threads. Bandwidth excludes probe traffic and extra hardware traffic.',fontsize=9)
fig.savefig(out/'intensity_comparison.png',dpi=170,bbox_inches='tight')
with (out/'intensity_summary.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['load_threads','trials','median_GB_s','min_GB_s','max_GB_s','median_latency_ns','min_latency_ns','max_latency_ns'])
 for k,bs,ls in zip(x,b,l):w.writerow([k,len(bs),statistics.median(bs),min(bs),max(bs),statistics.median(ls),min(ls),max(ls)])
