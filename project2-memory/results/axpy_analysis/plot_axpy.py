from pathlib import Path
import csv,statistics as st
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=Path(__file__).resolve().parent
rows=list(csv.DictReader((p/'combined.csv').open()));summary=[]
for mode,size in sorted({(r['mode'],int(r['size_kib'])) for r in rows}):
 rs=[r for r in rows if r['mode']==mode and int(r['size_kib'])==size];d={'mode':mode,'size_kib':size,'trials':len(rs)}
 vals={k:[float(r[k]) for r in rs] for k in ['elapsed_ns','ns_per_element','useful_GB_s','minor_faults']}
 vals['misses_per_1000_updates']=[int(r['cache_misses_raw'])*int(r['time_enabled_ns'])/int(r['time_running_ns'])*1000/(int(r['elements'])*int(r['passes'])) for r in rs]
 for k,v in vals.items():
  for suffix,fn in [('median',st.median),('min',min),('max',max)]:d[k+'_'+suffix]=fn(v)
 summary.append(d)
with (p/'summary.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=list(summary[0]));w.writeheader();w.writerows(summary)
fig,axs=plt.subplots(2,2,figsize=(12,8),layout='constrained');ds=[d for d in summary if d['mode']=='steady'];x=[d['size_kib'] for d in ds]
for ax,col,title,ylabel in [(axs[0,0],'useful_GB_s','Steady-state useful throughput','Useful GB/s'),(axs[0,1],'ns_per_element','Steady-state time per update','ns / element update'),(axs[1,0],'misses_per_1000_updates','Generic cache misses are non-monotonic','Misses / 1,000 element updates')]:
 y=[d[col+'_median'] for d in ds];err=[[d[col+'_median']-d[col+'_min'] for d in ds],[d[col+'_max']-d[col+'_median'] for d in ds]]
 ax.errorbar(x,y,yerr=err,marker='o',capsize=3,color='#176b9c');ax.set_xscale('log',base=2);ax.set_xlabel('Combined array size (KiB)');ax.set_ylabel(ylabel);ax.set_title(title);ax.grid(alpha=.2)
 for boundary in [48,1024,98304]:ax.axvline(boundary,color='gray',linestyle=':',alpha=.5)
 ax.set_xticks([16,64,1024,32768,524288],['16','64','1,024','32,768','524,288'])
ax=axs[1,1];ds=[next(d for d in summary if d['mode']==m) for m in ['prepared','setup_inclusive']]
y=[d['elapsed_ns_median']/1e6 for d in ds];err=[[ (d['elapsed_ns_median']-d['elapsed_ns_min'])/1e6 for d in ds],[(d['elapsed_ns_max']-d['elapsed_ns_median'])/1e6 for d in ds]]
ax.bar(['Prepared kernel','Setup + kernel'],y,yerr=err,capsize=5,color=['#176b9c','#c86c32']);ax.set_ylabel('Elapsed time (ms)');ax.set_title('Timing pitfall: one pass, 512 MiB');ax.set_ylim(0,max(d['elapsed_ns_max']/1e6 for d in ds)*1.22)
for i,(v,d) in enumerate(zip(y,ds)):ax.text(i,d['elapsed_ns_max']/1e6+6,f'{v:.2f} ms\n{d["minor_faults_median"]:,.0f} minor faults',ha='center')
fig.suptitle('AXPY memory sweep and initialization overhead\nMedians and min–max ranges, five trials; dotted lines: reported cache capacities',fontsize=14)
fig.savefig(p/'axpy_comparison.png',dpi=180)
