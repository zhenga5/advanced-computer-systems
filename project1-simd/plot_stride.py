#!/usr/bin/env python3
"""Usage: python3 plot_stride.py results/stride_TIMESTAMP/measurements.csv"""
from pathlib import Path
import argparse
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('csv', type=Path)
args = parser.parse_args()
df = pd.read_csv(args.csv)
keys = ['suite', 'group', 'mode', 'datatype', 'n', 'stride']
expected = set()
for suite, groups in [('fixed_n', [1024,16384,262144,4194304]),
                      ('fixed_span', [8192,131072,2097152,33554432])]:
    for g in groups:
        for mode in ['scalar','auto']:
            for dtype in ['float','double']:
                for s in [1,2,4,8]:
                    expected.add((suite,g,mode,dtype,g if suite=='fixed_n' else g//s,s))
assert set(df[keys].itertuples(index=False,name=None)) == expected, 'Missing or unexpected configurations'
assert len(df)==896 and not df.duplicated(keys+['trial']).any(), 'Incomplete or duplicate trials'
assert df.groupby(keys).trial.apply(lambda x: set(x)==set(range(7))).all(), 'Invalid trial IDs'
assert np.isfinite(df.select_dtypes(include='number')).all().all(), 'Nonfinite data'
assert (df.seconds_per_call>0).all() and (df.repetitions>0).all()
T = df.datatype.map({'float':4,'double':8})
assert (df.address_span_bytes == 3*((df.n-1)*df.stride+1)*T).all()
assert np.allclose(df.gflops, df.n/df.seconds_per_call/1e9)
assert np.allclose(df.useful_gib_per_second,3*df.n*T/df.seconds_per_call/2**30)
assert np.allclose(df.nanoseconds_per_element,df.seconds_per_call*1e9/df.n)
for row in df[keys+['checksum']].drop_duplicates().itertuples(index=False):
    period=[(1+(i*row.stride)%7)*(1+(i*row.stride)%5) for i in range(35)]
    expected_sum=(row.n//35)*sum(period)+sum(period[:row.n%35])
    assert row.checksum==expected_sum, 'Incorrect checksum'
out=args.csv.parent/'plots'
out.mkdir(exist_ok=True)
summary=df.groupby(keys).agg(
    median_seconds=('seconds_per_call','median'),
    min_seconds=('seconds_per_call','min'),max_seconds=('seconds_per_call','max'),
    median_ns=('nanoseconds_per_element','median'),min_ns=('nanoseconds_per_element','min'),max_ns=('nanoseconds_per_element','max'),
    median_bw=('useful_gib_per_second','median'),min_bw=('useful_gib_per_second','min'),max_bw=('useful_gib_per_second','max'),
    address_span_bytes=('address_span_bytes','first'),trials=('trial','count')).reset_index()
summary['spread_percent']=100*(summary.max_seconds-summary.min_seconds)/summary.median_seconds
summary.to_csv(out/'stride_summary.csv',index=False)
pairs=summary.pivot(index=['suite','group','datatype','n','stride'],columns='mode',values='median_seconds')
pairs['speedup']=pairs.scalar/pairs.auto
pairs.to_csv(out/'stride_speedup.csv')
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False})
for suite in ['fixed_n','fixed_span']:
    data=summary[summary.suite==suite]
    for metric,label in [('ns','Time per useful element (ns)'),('bw','Useful bandwidth (GiB/s)')]:
        fig,axes=plt.subplots(2,2,figsize=(11,8))
        for ax,g in zip(axes.flat,sorted(data.group.unique())):
            sub=data[data.group==g]
            for dtype,color in [('float','#1764a0'),('double','#b64e14')]:
                for mode,style,marker in [('scalar','--','o'),('auto','-','s')]:
                    v=sub[(sub.datatype==dtype)&(sub['mode']==mode)].sort_values('stride')
                    med=v['median_'+metric].to_numpy()
                    ax.errorbar(v.stride,med,yerr=[med-v['min_'+metric].to_numpy(),v['max_'+metric].to_numpy()-med],
                                color=color,linestyle=style,marker=marker,capsize=3,
                                label=f'{dtype}, '+('native auto' if mode=='auto' else 'scalar'))
            if suite=='fixed_n':
                ax.set_title(f'N = {g:,} multiplications')
            else:
                ax.set_title(f'Combined span ≈ {3*g*4/2**20:g} MiB float / {3*g*8/2**20:g} MiB double')
            ax.set_xticks([1,2,4,8])
            ax.set_xlabel('Stride (elements)')
            ax.set_ylabel(label)
            ax.set_yscale('log')
            ax.grid(alpha=.2,which='both')
        handles,labels=axes.flat[0].get_legend_handles_labels()
        fig.legend(handles,labels,loc='upper center',bbox_to_anchor=(.5,.94),ncol=4,frameon=False)
        title='Fixed operation count' if suite=='fixed_n' else 'Approximately fixed address span'
        fig.suptitle(f'Strided multiplication: {title.lower()}',fontsize=15,y=.985)
        fig.text(.5,.015,'Median of 7 trials; bars show min–max, not confidence intervals. Useful bytes = 3 × N × sizeof(T).',ha='center',fontsize=9)
        fig.tight_layout(rect=(0,.045,1,.89))
        for ext in ['png','pdf']:
            fig.savefig(out/f'stride_{suite}_{metric}.{ext}',dpi=180)
        plt.close(fig)
print(f'Validated 896 trials. Saved plots and processed data in: {out.resolve()}')
