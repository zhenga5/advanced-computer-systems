"""Parse original FIO JSON, export tables, and recreate the report figures."""
import csv
import json
import re
import statistics as st
from collections import defaultdict
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'results' / 'analysis'
OUT.mkdir(exist_ok=True)
PLOTS = ROOT / 'plots'
PLOTS.mkdir(exist_ok=True)
rows = []
for path in sorted((ROOT / 'results').glob('*/*.json')):
    data = json.loads(path.read_text())
    if not isinstance(data, dict) or 'jobs' not in data:
        continue
    for job in data['jobs']:
        opts = {**data.get('global options', {}), **job.get('job options', {})}
        session = path.parent.name
        valid = not session.startswith('queue_2026')
        stem = path.stem
        case = re.sub(r'_rep\d+$', '', stem)
        base = dict(session=session, case=case, source=str(path.relative_to(ROOT)),
                    valid_sweep=valid, error=job['error'], rw=opts['rw'], bs=opts['bs'],
                    qd=int(opts['iodepth']), size=opts['size'],
                    direct=opts['direct'], numjobs=opts['numjobs'],
                    depth_distribution=json.dumps(job['iodepth_level'], sort_keys=True))
        active = [d for d in ('read', 'write') if job[d]['total_ios']]
        for direction in active + ['total']:
            vals = [job[d] for d in active] if direction == 'total' else [job[direction]]
            n = sum(v['total_ios'] for v in vals)
            latency = sum(v['lat_ns']['mean'] * v['total_ios'] for v in vals) / n / 1000
            iops = sum(v['iops'] for v in vals)
            row = dict(base, direction=direction, iops=iops,
                       mb_s=sum(v['bw_bytes'] for v in vals)/1e6,
                       mean_us=latency, ios=n,
                       little_law_L=iops*latency/1e6,
                       io_bytes=sum(v['io_bytes'] for v in vals),
                       short_ios=sum(v['short_ios'] for v in vals),
                       drop_ios=sum(v['drop_ios'] for v in vals))
            for label, key in [('p50_us','50.000000'),('p95_us','95.000000'),
                               ('p99_us','99.000000'),('p999_us','99.900000')]:
                # Percentiles cannot be averaged to combine read/write distributions.
                row[label] = vals[0]['lat_ns']['percentile'][key]/1000 if len(vals)==1 else ''
            rows.append(row)

def export(name, records):
    with (OUT/name).open('w', newline='') as f:
        w=csv.DictWriter(f, fieldnames=list(records[0])); w.writeheader();w.writerows(records)
export('all_runs.csv', rows)
totals=[r for r in rows if r['direction']=='total']
assert totals, 'No FIO results found'
assert all(r['error']==0 and r['short_ios']==0 and r['drop_ios']==0 for r in totals)
checks=[r for r in rows if r['session'].startswith('checks_')]
groups=defaultdict(list)
for r in checks:
    if r['case'] != 'sustained_write':groups[(r['case'],r['direction'])].append(r)
summary=[]
for (case,direction), group in sorted(groups.items()):
    assert len(group)==3
    rec=dict(case=case,direction=direction,n=3)
    for metric in ['iops','mb_s','mean_us','p50_us','p95_us','p99_us','p999_us','little_law_L']:
        values=[r[metric] for r in group if r[metric]!='']
        rec[metric+'_mean']=st.mean(values) if values else ''
        rec[metric+'_sd']=st.stdev(values) if len(values)>1 else ''
    summary.append(rec)
export('repeat_summary.csv', summary)
S={(r['case'],r['direction']):r for r in summary}
def s(case,metric):return S[(case,'total')][metric+'_mean']
def sd(case,metric):return S[(case,'total')][metric+'_sd']
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False})
colors={'randread':'#2465a8','randwrite':'#d76b25','read':'#228857','write':'#9555a1'}
labels={'randread':'Random read, 4 KiB','randwrite':'Random write, 4 KiB','read':'Sequential read, 128 KiB','write':'Sequential write, 128 KiB'}
def finish(fig,name):
    fig.tight_layout();fig.savefig(PLOTS/name,dpi=160);plt.close(fig)

# Keep sessions separate: this curve uses only the original corrected sweep.
fig,ax=plt.subplots(figsize=(8,5))
for rw in colors:
    a=sorted([r for r in totals if r['session'].startswith('queue_fixed_') and r['rw']==rw],key=lambda r:r['qd'])
    ax.plot([r['mean_us']/1000 for r in a],[r['mb_s'] for r in a],'o-',color=colors[rw],label=labels[rw])
    for r in a:ax.annotate(str(r['qd']),(r['mean_us']/1000,r['mb_s']),xytext=(4, 7 if rw in ('read','randread') else -13),textcoords='offset points',fontsize=7)
ax.set(xscale='log',yscale='log',xlabel='Mean total I/O latency (ms)',ylabel='Throughput (MB/s)',title='Queue-depth tradeoff: corrected sweep session')
ax.grid(alpha=.2);ax.legend(fontsize=8,loc='lower right');finish(fig,'queue_tradeoff.png')

fig,axes=plt.subplots(1,2,figsize=(11,4))
for rw in colors:
    a=sorted([r for r in totals if r['session'].startswith('more_') and r['case'].startswith('block_') and r['rw']==rw],key=lambda r:int(r['bs'][:-1]))
    x=[int(r['bs'][:-1]) for r in a]
    for ax,metric in zip(axes,['mb_s','mean_us']):
        ax.plot(x,[r[metric] for r in a],'o-',color=colors[rw],label=rw)
        ax.set_xscale('log',base=2);ax.set_xticks(x,labels=x);ax.set_xlabel('Block size (KiB)');ax.grid(alpha=.2)
axes[0].set_ylabel('Throughput (MB/s)');axes[1].set_ylabel('Mean total latency (µs)')
axes[0].legend(fontsize=8);fig.suptitle('Block-size sweep: QD16, one worker, 16 GiB (one trial per point)');finish(fig,'block_size.png')

fig,axes=plt.subplots(1,2,figsize=(10,4))
cases=[f'mix_read{p}' for p in [100,70,50,0]]
axes[0].bar(range(4),[s(c,'mb_s') for c in cases],yerr=[sd(c,'mb_s') for c in cases],capsize=5,color='#2465a8')
axes[0].set_xticks(range(4),['100/0','70/30','50/50','0/100']);axes[0].set_xlabel('Read/write ratio');axes[0].set_title('Random 4 KiB mix, QD16')
cases=['working_set_1G','queue_randread_qd16']
axes[1].bar(range(2),[s(c,'mb_s') for c in cases],yerr=[sd(c,'mb_s') for c in cases],capsize=5,color='#228857')
axes[1].set_xticks(range(2),['1 GiB','16 GiB']);axes[1].set_title('Random 4 KiB reads, QD16');axes[1].set_xlabel('Working-set range')
for ax in axes:ax.set_ylabel('Throughput (MB/s)');ax.grid(axis='y',alpha=.2);ax.set_axisbelow(True)
fig.suptitle('Three repeats: mean ± sample standard deviation');finish(fig,'mix_working_set.png')

fig,axes=plt.subplots(1,2,figsize=(10,4))
for ax,rw,depths in [(axes[0],'randread',[16,128]),(axes[1],'randwrite',[8,16])]:
    for qd in depths:
        case=f'queue_{rw}_qd{qd}';metrics=['p50_us','p95_us','p99_us','p999_us']
        ax.errorbar(range(4),[s(case,m) for m in metrics],yerr=[sd(case,m) for m in metrics],marker='o',capsize=4,label=f'QD{qd}')
    ax.set_xticks(range(4),['p50','p95','p99','p99.9']);ax.set_ylabel('Total I/O latency (µs)');ax.set_title(rw+', 4 KiB');ax.legend();ax.grid(alpha=.2)
fig.suptitle('Tail latency: mean of three per-run percentiles ± sample SD');finish(fig,'tail_latency.png')

log=next((ROOT/'results').glob('checks_*/sustained_bw.1.log'))
trace=[]
for line in log.read_text().splitlines():
    fields=line.split(',');trace.append({'time_s':float(fields[0])/1000,'mb_s':float(fields[1])*1024/1e6})
export('sustained_trace.csv',trace)
fig,ax=plt.subplots(figsize=(8,3.5));ax.plot([r['time_s'] for r in trace],[r['mb_s'] for r in trace],color='#9555a1')
ax.set(xlabel='Elapsed time (s)',ylabel='Write throughput (MB/s)',title='120-second sequential write: 128 KiB, QD16, 16 GiB file');ax.grid(alpha=.2);finish(fig,'sustained_write.png')
valid=[r for r in totals if r['valid_sweep']]
notes={'valid_runs':len(valid),'misconfigured_runs':len(totals)-len(valid),
       'all_errors_zero':True,'all_short_and_dropped_ios_zero':True,
       'sustained_log_samples':len(trace),
       'first_10_samples_mb_s':st.mean(r['mb_s'] for r in trace[:10]),
       'last_10_samples_mb_s':st.mean(r['mb_s'] for r in trace[-10:]),
       'max_observed_iops':max(r['iops'] for r in valid),
       'max_observed_mb_s':max(r['mb_s'] for r in valid)}
(OUT/'validation.json').write_text(json.dumps(notes,indent=2))
print(json.dumps(notes,indent=2))
print('Saved CSV tables and five plots.')
