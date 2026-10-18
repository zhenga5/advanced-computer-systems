from pathlib import Path
import json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
R=Path(__file__).resolve().parents[1];O=R/'figures';O.mkdir(exist_ok=True)
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False})
colors={'scalar':'#b64e14','default':'#1764a0','auto':'#137a50'}
D={name:pd.read_csv(R/'data'/f'{name}.csv') for name in ['isa','alignment','stride','bandwidth','cycles']}
for name,count in [('isa',2016),('alignment',1008),('stride',896),('bandwidth',84),('cycles',504)]:
 assert len(D[name])==count,(name,'Unexpected row count')
 assert np.isfinite(D[name].select_dtypes(include='number')).all().all()
 assert (D[name].seconds_per_call>0).all()
s=D['isa'].groupby(['kernel','datatype','n','build']).agg(seconds=('seconds_per_call','median'),gflops=('gflops','median'),low=('gflops','min'),high=('gflops','max'),bytes=('working_set_bytes','first')).reset_index()
s.to_csv(R/'data'/'isa_summary.csv',index=False)
def save(fig,name):
 fig.tight_layout()
 for ext in ['png','pdf']:fig.savefig(O/f'{name}.{ext}',dpi=180,bbox_inches='tight')
 plt.close(fig)
for metric in ['throughput','speedup']:
 fig,axes=plt.subplots(3,2,figsize=(10,7),sharex=True)
 for row,k in enumerate(['multiply','axpy','dot']):
  for col,t in enumerate(['float','double']):
   ax=axes[row,col];v=s[(s.kernel==k)&(s.datatype==t)]
   base=v[v.build=='scalar'].set_index('n').seconds
   for mode in (['scalar','default','auto'] if metric=='throughput' else ['default','auto']):
    q=v[v.build==mode].sort_values('n')
    y=q.gflops.to_numpy() if metric=='throughput' else base.loc[q.n].to_numpy()/q.seconds.to_numpy()
    ax.plot(q.bytes/2**20,y,color=colors[mode],marker='o',markersize=2,label=mode)
    if metric=='throughput':ax.fill_between(q.bytes/2**20,q.low,q.high,color=colors[mode],alpha=.12)
   for capacity in [48/1024,1,96]:ax.axvline(capacity,color='#999999',linestyle=':',linewidth=.7)
   if metric=='speedup':ax.axhline(1,color='#777777',linewidth=.7)
   ax.set_title(f'{k}, {t}');ax.set_xscale('log',base=2);ax.grid(alpha=.15)
   ax.set_ylabel('GFLOP/s' if metric=='throughput' else 'Scalar time / build time')
   ax.set_ylim(bottom=0)
   if row==2:ax.set_xlabel('Combined footprint (MiB)')
 axes[0,0].legend(fontsize=8)
 save(fig,metric)
# Alignment: raw time per call, not a purported pure tail penalty.
a=D['alignment'].groupby(['datatype','build','n','offset_elements']).seconds_per_call.agg(['median','min','max']).reset_index()
fig,axes=plt.subplots(1,2,figsize=(10,3.5))
for ax,t in zip(axes,['float','double']):
 for off,color in [(0,'#1764a0'),(1,'#b64e14')]:
  q=a[(a.datatype==t)&(a.build=='auto')&(a.n<1040)&(a.offset_elements==off)].sort_values('n')
  y=q['median'].to_numpy()*1e9
  ax.errorbar(q.n,y,yerr=[y-q['min'].to_numpy()*1e9,q['max'].to_numpy()*1e9-y],color=color,marker='o',markersize=3,capsize=2,label='64-byte aligned' if off==0 else 'Shifted one element')
 ax.set_title(t);ax.set_xlabel('N (consecutive lengths)');ax.set_ylabel('Median time per call (ns)');ax.grid(alpha=.2);ax.legend(fontsize=8)
save(fig,'alignment')
a.to_csv(R/'data'/'alignment_summary.csv',index=False)
# Stride controls, largest group in each suite.
st=D['stride'].groupby(['suite','group','datatype','mode','stride']).useful_gib_per_second.agg(['median','min','max']).reset_index()
fig,axes=plt.subplots(2,2,figsize=(10,6))
for row,(suite,g) in enumerate([('fixed_n',4194304),('fixed_span',33554432)]):
 for col,t in enumerate(['float','double']):
  ax=axes[row,col]
  for mode in ['scalar','auto']:
   q=st[(st.suite==suite)&(st.group==g)&(st.datatype==t)&(st['mode']==mode)].sort_values('stride')
   y=q['median'].to_numpy()
   ax.errorbar(q.stride,y,yerr=[y-q['min'].to_numpy(),q['max'].to_numpy()-y],marker='o',color=colors[mode],capsize=3,label=mode)
  ax.set_title(f'{t}: '+('fixed N = 4,194,304' if row==0 else 'fixed span ≈ '+('384' if t=='float' else '768')+' MiB'))
  ax.set_xticks([1,2,4,8]);ax.set_yscale('log');ax.set_ylabel('Useful bandwidth (GiB/s)');ax.set_xlabel('Stride (elements)');ax.grid(alpha=.2);ax.legend(fontsize=8)
save(fig,'stride')
# Separate counter run.
c=D['cycles'];assert np.allclose(c.cycles_per_element,c.cycles/(c.repetitions*c.n));assert (c.counter_running_fraction==1).all()
c=c.groupby(['kernel','datatype','n','build']).cycles_per_element.agg(['median','min','max']).reset_index()
c.to_csv(R/'data'/'cycles_summary.csv',index=False)
fig,axes=plt.subplots(3,2,figsize=(10,7))
for row,k in enumerate(['multiply','axpy','dot']):
 for col,t in enumerate(['float','double']):
  ax=axes[row,col]
  for mode in colors:
   q=c[(c.kernel==k)&(c.datatype==t)&(c.build==mode)].sort_values('n');y=q['median'].to_numpy()
   ax.errorbar(q.n,y,yerr=[y-q['min'].to_numpy(),q['max'].to_numpy()-y],color=colors[mode],marker='o',markersize=3,capsize=2,label=mode)
  ax.set_title(f'{k}, {t}');ax.set_xscale('log',base=2);ax.set_xticks([1024,32768,1048576,33554432],labels=['1K','32K','1M','32M']);ax.set_ylim(bottom=0);ax.set_ylabel('Cycles / element');ax.grid(alpha=.2)
  if row==2:ax.set_xlabel('Elements (K=1024, M=1048576)')
axes[0,0].legend(fontsize=8);save(fig,'cycles')
# Roofline uses latest ISA sweep, not the superseded two-build dataset.
b=D['bandwidth'].groupby(['datatype','n','repeat']).useful_gib_per_second.median()
refs={t:float(b.loc[(t,67108864)].median()) for t in ['float','double']}
fig,axes=plt.subplots(1,2,figsize=(10,4))
comparisons=[]
for ax,(t,T,lanes) in zip(axes,[('float',4,16),('double',8,8)]):
 B=refs[t]*2**30/1e9;ai=1/(3*T);peak=2*lanes*4.7
 x=np.logspace(-2,2,500)
 ax.plot(x,np.minimum(B*x,peak),color='#1764a0',label='Multiply roofline model')
 ax.axhline(2*peak,color='#888888',linestyle=':',label='FMA-only reference')
 for mode,marker in [('scalar','o'),('default','^'),('auto','s')]:
  q=s[(s.kernel=='multiply')&(s.datatype==t)&(s.n==33554432)&(s.build==mode)].iloc[0]
  ax.errorbar(ai,q.gflops,yerr=[[q.gflops-q.low],[q.high-q.gflops]],marker=marker,color=colors[mode],markersize=6,capsize=3,label=f'{mode}: {q.gflops:.2f}')
  comparisons.append(dict(datatype=t,build=mode,measured_gflops=q.gflops,memory_reference_gflops=B*ai,compute_estimate_gflops=peak,relative_to_memory_reference=q.gflops/(B*ai)))
 ax.set_xscale('log');ax.set_yscale('log');ax.set_ylim(.1,1000);ax.set_xlim(.01,100)
 ax.set_title(t);ax.set_xlabel('FLOP / useful byte');ax.set_ylabel('GFLOP/s');ax.grid(alpha=.2);ax.legend(fontsize=7.5,loc='lower right')
save(fig,'roofline')
pd.DataFrame(comparisons).to_csv(R/'data'/'roofline_comparison.csv',index=False)
(R/'data'/'bandwidth_reference.json').write_text(json.dumps(refs,indent=2))
print('Generated six report figures and processed tables from the final datasets.')
