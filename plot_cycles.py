#!/usr/bin/env python3
"""Usage: python3 plot_cycles.py results/cycles_TIMESTAMP/measurements.csv"""
import argparse
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=argparse.ArgumentParser(description=__doc__);p.add_argument('csv',type=Path);a=p.parse_args()
d=pd.read_csv(a.csv)
k=['kernel','datatype','n','build']
assert len(d)==504 and not d.duplicated(k+['trial']).any()
assert d.groupby(k).size().eq(7).all()
assert (d.counter_running_fraction>=.99).all()
assert np.allclose(d.cycles_per_element,d.cycles/(d.repetitions*d.n))
s=d.groupby(k).cycles_per_element.agg(['median','min','max']).reset_index()
out=a.csv.parent/'plots';out.mkdir(exist_ok=True)
s.to_csv(out/'cycles_summary.csv',index=False)
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False})
fig,axes=plt.subplots(3,2,figsize=(11,10))
for row,kernel in enumerate(['multiply','axpy','dot']):
    for col,dtype in enumerate(['float','double']):
        ax=axes[row,col]
        for mode,color,marker in [('scalar','#b64e14','o'),('default','#1764a0','^'),('auto','#137a50','s')]:
            v=s[(s.kernel==kernel)&(s.datatype==dtype)&(s.build==mode)].sort_values('n')
            y=v['median'].to_numpy()
            ax.errorbar(v.n,y,yerr=[y-v['min'].to_numpy(),v['max'].to_numpy()-y],label=mode,color=color,marker=marker,capsize=3)
        ax.set_title(f'{kernel}, {dtype}');ax.set_xscale('log',base=2)
        ax.set_xticks([1024,32768,1048576,33554432],labels=['1K','32K','1M','32M'])
        ax.set_xlabel('Elements (K = 2¹⁰, M = 2²⁰)');ax.set_ylabel('User-mode cycles / element')
        ax.set_ylim(bottom=0);ax.grid(alpha=.2)
fig.suptitle('Measured cycles per element across three compiler builds',fontsize=15)
handles,labels=axes[0,0].get_legend_handles_labels()
fig.legend(handles,labels,loc='upper center',bbox_to_anchor=(.5,.965),ncol=3,frameon=False)
fig.text(.5,.015,'Median of 7 trials; bars show min–max. Kernel batches include loop/call/timer overhead; initialization and checks excluded.',ha='center',fontsize=8.5)
fig.tight_layout(rect=(0,.04,1,.93))
for ext in ['png','pdf']:fig.savefig(out/f'cycles_per_element.{ext}',dpi=180)
print(f'Saved cycle plots and summary in: {out.resolve()}')
