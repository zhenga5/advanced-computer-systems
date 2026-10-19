#!/usr/bin/env python3
"""Usage: python3 plot_bandwidth.py results/bandwidth_TIMESTAMP/measurements.csv"""
from pathlib import Path
import argparse
import json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('csv',type=Path)
a=p.parse_args()
d=pd.read_csv(a.csv)
keys=['repeat','datatype','n']
expected={(r,t,n) for r in [1,2] for t in ['float','double'] for n in [16777216,33554432,67108864]}
assert len(d)==84 and set(d[keys].itertuples(index=False,name=None))==expected
assert not d.duplicated(keys+['trial']).any()
assert d.groupby(keys).trial.apply(lambda x:set(x)==set(range(7))).all()
assert (d.kernel=='stream_add').all() and (d.stride==1).all()
assert np.isfinite(d.select_dtypes(include='number')).all().all()
assert (d.seconds_per_call>0).all()
T=d.datatype.map({'float':4,'double':8})
assert (d.address_span_bytes==3*d.n*T).all()
assert np.allclose(d.useful_gib_per_second,3*d.n*T/d.seconds_per_call/2**30)
assert np.allclose(d.gflops,d.n/d.seconds_per_call/1e9)
for n,checksum in d[['n','checksum']].drop_duplicates().itertuples(index=False):
    expected_sum=sum((n//k)*sum(range(1,k+1))+sum(range(1,n%k+1)) for k in [7,5])
    assert checksum==expected_sum
out=a.csv.parent/'plots'
out.mkdir(exist_ok=True)
s=d.groupby(keys).agg(median_gib_s=('useful_gib_per_second','median'),min_gib_s=('useful_gib_per_second','min'),max_gib_s=('useful_gib_per_second','max'),span_bytes=('address_span_bytes','first')).reset_index()
s.to_csv(out/'bandwidth_summary.csv',index=False)
# Use both run medians at the largest tested size, avoiding the faster smaller footprint.
refs={}
for dtype,size in [('float',4),('double',8)]:
    b=float(s[(s.datatype==dtype)&(s.n==67108864)].median_gib_s.median())
    refs[dtype]={'useful_bandwidth_gib_s':b,'useful_bandwidth_gb_s':b*2**30/1e9,
                 'multiply_ai_flops_per_useful_byte':1/(3*size),
                 'multiply_memory_reference_gflops':b*2**30/(3*size)/1e9}
(out/'bandwidth_reference.json').write_text(json.dumps({'selection':'Median of two process-run medians at N=67108864, seven trials per run',
 'interpretation':'Empirical single-thread cached-store useful-bandwidth reference. Not physical DRAM counters or a universal peak.',
 'reference':refs},indent=2))
plt.rcParams.update({'font.size':11,'axes.spines.top':False,'axes.spines.right':False})
fig,axes=plt.subplots(1,2,figsize=(11,4.7),sharey=True)
for ax,dtype in zip(axes,['float','double']):
    for repeat,color,marker in [(1,'#1764a0','o'),(2,'#b64e14','s')]:
        v=s[(s.datatype==dtype)&(s['repeat']==repeat)].sort_values('span_bytes')
        y=v.median_gib_s.to_numpy()
        ax.errorbar(v.span_bytes/2**20,y,yerr=[y-v.min_gib_s.to_numpy(),v.max_gib_s.to_numpy()-y],color=color,marker=marker,capsize=4,label=f'Run {repeat}')
    ax.axhline(refs[dtype]['useful_bandwidth_gib_s'],color='#555555',linestyle=':',label='Largest-size reference')
    ax.set_title(dtype)
    ax.set_xscale('log',base=2)
    ticks=sorted(s[s.datatype==dtype].span_bytes.unique()/2**20)
    ax.set_xticks(ticks,labels=[f'{x:g}' for x in ticks])
    ax.set_xlabel('Combined array span (MiB)')
    ax.set_ylim(bottom=0)
    ax.grid(alpha=.2)
axes[0].set_ylabel('Useful bandwidth (GiB/s)')
axes[1].legend(fontsize=9)
fig.suptitle('Single-thread streaming-add bandwidth')
fig.text(.5,.02,'Points: seven-trial medians. Bars: min–max. Useful bytes = 3 × N × sizeof(T).',ha='center',fontsize=9)
fig.tight_layout(rect=(0,.055,1,.95))
for ext in ['png','pdf']:fig.savefig(out/f'bandwidth_calibration.{ext}',dpi=180)
print(json.dumps(refs,indent=2))
print(f'Validated 84 trials. Saved plots and processed data in: {out.resolve()}')
