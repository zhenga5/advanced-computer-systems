from pathlib import Path
import csv,statistics as st
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
root=Path(__file__).resolve().parent
rows=list(csv.DictReader((root/'combined.csv').open()))
summary=[]
for p in [100,70,50,0]:
 for n in range(8):
  group=[r for r in rows if int(r['load_read_percent'])==p and int(r['load_threads'])==n]
  d={'read_percent':p,'load_threads':n,'trials':len(group)}
  for col in ['load_GB_s','probe_ns_per_load']:
   vals=[float(r[col]) for r in group]
   for label,fn in [('median',st.median),('min',min),('max',max)]:d[col+'_'+label]=fn(vals)
  summary.append(d)
with (root/'summary.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(summary[0]));w.writeheader();w.writerows(summary)
fig,axs=plt.subplots(2,2,figsize=(12,8),sharex=True)
for ax,p,color in zip(axs.flat,[100,70,50,0],['#1565c0','#008577','#a054b4','#d56b12']):
 ds=[r for r in summary if r['read_percent']==p];n=list(range(8))
 for axis,col,c,label in [(ax,'load_GB_s',color,'Background useful throughput (GB/s)'),(ax.twinx(),'probe_ns_per_load','#555555','Random-read latency (ns/load)')]:
  mid=[d[col+'_median'] for d in ds]
  err=[[d[col+'_median']-d[col+'_min'] for d in ds],[d[col+'_max']-d[col+'_median'] for d in ds]]
  axis.errorbar(n,mid,yerr=err,color=c,marker='o' if col=='load_GB_s' else 's',linestyle='-' if col=='load_GB_s' else '--',capsize=3,label=label)
  axis.set_ylabel(label,color=c);axis.tick_params(axis='y',labelcolor=c);axis.set_ylim(0,65 if col=='load_GB_s' else 330)
 ax.set_title(f'{p}% read / {100-p}% write');ax.set_xticks(n);ax.set_xlabel('Background workers');ax.grid(alpha=.15)
fig.suptitle('Mixed traffic: bandwidth saturation and loaded read latency\nMedians with min–max ranges across five trials',fontsize=14)
fig.tight_layout(rect=[0,0,1,.93]);fig.savefig(root/'mixed_intensity_comparison.png',dpi=180);plt.close(fig)
