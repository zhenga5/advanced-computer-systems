#!/usr/bin/env python3
"""Run from project root; fresh allocation per process, alternating page order."""
import csv, datetime, io, pathlib, subprocess, sys, os
cpu = int(sys.argv[1]) if len(sys.argv)>1 else min(os.sched_getaffinity(0))
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S_%fZ')
out=pathlib.Path('results')/('counters_'+stamp)
out.mkdir(parents=True)
with (out/'combined.csv').open('w', newline='') as merged:
    writer=None
    for repetition in (1,2):
        for size in (32768,65536,524288):
            for events in ('tlb','cache'):
                modes=('small','huge') if repetition==1 else ('huge','small')
                for mode in modes:
                    name=f'r{repetition}_{size}_{events}_{mode}'
                    cmd=['taskset','-c',str(cpu),'./bin/latency_counters',mode,str(size),events,'5','8000000']
                    print(name,flush=True)
                    result=subprocess.run(cmd,text=True,capture_output=True)
                    (out/(name+'.csv')).write_text(result.stdout)
                    (out/(name+'.log')).write_text('Command: '+ ' '.join(cmd)+'\n'+result.stderr)
                    if result.returncode:
                        sys.exit(f'Failed: {result.stderr}\nPartial results retained in {out}')
                    rows=list(csv.DictReader(io.StringIO(result.stdout)))
                    if len(rows)!=5:sys.exit('Expected five trials; check '+name)
                    for row in rows:
                        row={'run':repetition,'guest_cpu':cpu,**row}
                        if writer is None:
                            writer=csv.DictWriter(merged,fieldnames=list(row));writer.writeheader()
                        writer.writerow(row)
                    merged.flush()
print('Upload:',out/'combined.csv')
