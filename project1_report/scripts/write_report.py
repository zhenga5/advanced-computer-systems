from pathlib import Path
import json
import hashlib
from html import escape
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, Preformatted
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from PIL import Image as PILImage
R=Path(__file__).resolve().parents[1]
pages=[]
def page(title):
 p={'title':title,'blocks':[]};pages.append(p);return p['blocks']
def text(b,t):b.append(('text',t))
def sub(b,t):b.append(('sub',t))
def table(b,rows):b.append(('table',rows))
def figure(b,name,caption):b.append(('figure',{'name':name,'caption':caption}))
def code(b,t):b.append(('code',t))
b=page('SIMD Advantage Profiling')
text(b,'Andrew Zheng | Advanced Computer Systems | Project 1 | October 17, 2026')
sub(b,'Purpose and principal findings')
text(b,'This project measures when compiler-generated SIMD improves single-thread numeric kernels and when wider vectors offer little benefit. Elementwise multiplication, AXPY and dot product were tested with float32 and float64 across cache-sized and larger-than-cache arrays. Scalar, GCC-default auto-vectorized and CPU-targeted native builds use the same kernel source.')
text(b,'For N=1,024, native SIMD gives 6.00x speedup for float multiply and 8.69x for float AXPY. At N=33,554,432, those speedups shrink to 1.23x and 1.59x. Double multiply and AXPY show approximately 1x speedup at the largest size. Dot product remains close to scalar because its observed vector multiplication feeds a serial accumulation chain. Thus, a vectorization report alone does not establish a useful speedup.')
sub(b,'Measured platform and recorded environment')
table(b,[['Item','Recorded value'],['Processor','AMD Ryzen 7 9850X3D; 8 cores, 16 logical CPUs'],['Caches','L1D: 48 KiB/core; L2: 1 MiB/core; L3: 96 MiB shared'],['ISA exposed to guest','x86-64, SSE, AVX2, AVX-512 and FMA'],['OS / virtualization','Ubuntu 24.04.5 LTS; Microsoft WSL2'],['Kernel','6.18.33.2-microsoft-standard-WSL2'],['Compiler','GCC 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1)'],['Execution policy','One benchmark thread; final ISA sweep pinned to logical CPU 0'],['SMT / power snapshot','SMT active; Windows Balanced power scheme'],['Frequency policy','Linux cpufreq policy unavailable; operating frequency not logged']])
text(b,'The environment snapshot was collected after the experiments and is not proof that every earlier run used identical settings. The virtual CPU affinity does not reserve a physical core, disable its SMT sibling, or control Windows scheduling. BIOS and power-policy continuity between separate datasets was not independently verified.')
sub(b,'Dataset scope')
text(b,'The analysis uses 2,016 final ISA-sweep trials, 1,008 alignment/tail trials, 896 stride trials, 84 bandwidth-calibration trials and 504 counter trials: 4,508 recorded batch measurements. The earlier two-build sweep is superseded by the final three-build sweep for baseline comparisons. Raw data and processed summaries accompany this report.')

b=page('Methodology and vectorization evidence')
text(b,'Kernels are compiled separately from the timing harness, without link-time optimization. All kernels use -O3 and -ffp-contract=off. The scalar build adds -march=native -fno-tree-loop-vectorize -fno-tree-slp-vectorize; the default build has no -march/-mtune override; the native-auto build adds -march=native. The common harness uses -O2 and the correctness checker uses -O0.')
text(b,'Timing uses std::chrono::steady_clock. Repetition counts double until a batch reaches approximately 30 ms (or the repetition cap); seven batch-average trials are retained. Two warmup calls precede each trial. Allocation, initialization, validation and CSV output are excluded from the timed batch. The ISA sweep rotates kernel/build ordering and covers powers of two from 2^10 through 2^25. Alignment and stride runners vary configuration order and pin to an allowed logical CPU.')
table(b,[['Kernel','Operation','FLOP/element','Useful bytes/element'],['Multiply','z[i] = x[i] * y[i]','1','3T'],['AXPY','y[i] += a * x[i]','2','3T'],['Dot','sum += x[i] * y[i]','2 (convention)','2T']])
text(b,'T is the element size in bytes. Footprint counts unique arrays: 3NT for multiply and 2NT for AXPY/dot. Useful bandwidth counts algorithmic reads/writes, not physical DRAM traffic. GFLOP/s = N x FLOP/element / seconds / 10^9; GiB/s = useful bytes / seconds / 2^30. Speedup is the ratio of scalar and vector-build median times at matching kernel, type and N.')
text(b,'Multiply uses small positive integer-valued inputs. AXPY alternates a=+0.5 and -0.5 to restore y without timed reset copies; its intermediate result is checked too. Dot uses x[i]=(i mod 7)-3 and y[i]=1+(i mod 5), whose product sum over 35 elements is zero. The bounded exact reference avoids float accumulation overflow/precision drift in this test. Correctness checks cover N=0,1,5,8,16,17,27,32,33,1000 for both types.')
sub(b,'Evidence from compiler reports and inspected assembly')
text(b,'The default compiler report identifies 16-byte vectorization; native multiply/AXPY assembly shows 64-byte ZMM operations. The scalar designation means scalar arithmetic, even when instructions use XMM registers. No FMA is present in the inspected AXPY loop, consistent with disabled contraction. Selected native float instructions are:')
code(b,'multiply: vmovups zmm1, [x]    vmulps zmm0, zmm1, [y]\n          vmovups [z], zmm0\ndot:      vmulps zmm1, zmm5, [y]\n          vaddss xmm0, xmm0, xmm1  ... repeated into xmm0')
text(b,'The dot loop vectorizes products but extracts lanes into dependent scalar additions. Its limited speedup therefore does not contradict the compiler report. The stride kernel also checks stride==1 before its SIMD path; non-unit strides branch to vmulss/vmulsd scalar loops. Full dumps are retained as evidence; only explanatory excerpts are shown here.')

b=page('Throughput across working-set sizes')
figure(b,'throughput','Figure 1. Median throughput for all three kernels and builds. Shading shows each configuration\'s observed min-max range. Vertical dotted lines mark nominal L1D, L2 and L3 capacities (48 KiB, 1 MiB, 96 MiB).')
text(b,'At small footprints, multiply and AXPY benefit from processing many independent elements per vector instruction. Float also offers twice as many lanes as double at the same vector width. As footprints grow, data movement becomes increasingly important and the throughput curves fall or converge. Cache boundaries are approximate: associativity, shared capacity, prefetching and other activity can shift transitions.')
text(b,'At the largest N, native float multiply reaches 3.479 GFLOP/s and double reaches 1.743 GFLOP/s. AXPY reaches 11.967 and 5.309 GFLOP/s, respectively. These kernels have different arithmetic intensities and write behavior, so their GFLOP/s values should not be interpreted as equal memory traffic or equal fractions of compute peak.')
text(b,'The dot kernel stays near its scalar baseline. Serial reduction dependency and floating-point evaluation order limit the benefit of packed multiplication. The experiment deliberately does not enable fast-math reassociation to transform the reduction into a different numerical algorithm.')

b=page('Speedup, locality and data type')
figure(b,'speedup','Figure 2. Ratios of median scalar time to median default/native time. The horizontal line is 1x. Cache markers use the combined footprint. Ratios are point estimates; timing variability is retained in Figure 1 and the raw trials.')
text(b,'Native float multiply speedup decreases from 6.00x at N=1,024 to 1.23x at N=33,554,432; native float AXPY decreases from 8.69x to 1.59x. Double multiply falls from 3.70x to 0.98x and double AXPY from 4.21x to 0.99x. Increasing vector width therefore gives its clearest benefit where arithmetic and instruction overhead matter, not uniformly across memory regimes.')
text(b,'At equal N, double requires twice the storage and useful bytes, while a vector holds half as many elements. Both effects contribute to data-type differences. Comparisons plotted by footprint help locate cache transitions, but equal-footprint cases have different N and are not identical instruction-count workloads.')
text(b,'The 128-bit default build can match or slightly exceed the native build on large arrays. At the largest size its multiply throughput is 3.510 GFLOP/s float and 1.773 GFLOP/s double. These modest differences are insufficient to claim a general advantage for narrower vectors; bandwidth pressure and run-to-run variation can outweigh vector-width benefits.')

b=page('Alignment and tail handling')
figure(b,'alignment','Figure 3. Native multiply at consecutive lengths 1,024-1,039. Points are seven-trial medians; bars show min-max. Arrays start on a 64-byte boundary or one naturally aligned element beyond it.')
text(b,'All three arrays receive the same offset: 4 bytes for float or 8 bytes for double. This preserves natural type alignment. Consecutive lengths cover every remainder for 16-float vectors and twice every remainder for 8-double vectors. Larger cases N=65,536 and 65,537 test the same address offsets with a different footprint.')
table(b,[['Native multiply','Aligned time','Shifted time','Shifted / aligned'],['float, N=1,024','20.89 ns','30.40 ns','1.455'],['double, N=1,024','44.98 ns','56.87 ns','1.264'],['float, N=65,536','3.155 us','3.147 us','0.997'],['double, N=65,536','10.842 us','11.409 us','1.052']])
text(b,'The inspected code uses unaligned-capable vmovups/vmovupd in both address cases. It has no scalar alignment peel or masked tail in these multiply loops. The main loop processes 64-byte vectors, then an optional 32-byte block, followed by up to seven scalar floats or three scalar doubles. Runtime alias checks can also select a scalar fallback.')
text(b,'At small N, shifted addresses are slower in these measurements; cache-line-crossing vector accesses are a plausible contributor, not an isolated proven cause. Tail cost is not monotonic: aligned float N=65,537 was faster than 65,536 (2.562 versus 3.155 us). This anomaly cautions against assigning every adjacent-size difference to remainder overhead. Guard checks detect out-of-range writes and untouched-output corruption but do not prove absence of out-of-range reads.')

b=page('Stride and useful bandwidth')
figure(b,'stride','Figure 4. Largest stride-control groups, with medians and min-max bars. Top: fixed operation count while address span grows. Bottom: approximately fixed combined address span while the number of operations decreases.')
text(b,'Strides 1,2,4,8 access element i*stride. For fixed N, the useful work stays constant while the span becomes 3*((N-1)*stride+1)*T. The fixed-span control holds N*stride constant; actual spans differ by at most seven elements per array. Useful bandwidth remains 3NT/time, rather than counting skipped elements as useful work.')
text(b,'In the largest fixed-span native cases, useful bandwidth falls from 44.28 to 5.18 GiB/s for float and from 41.46 to 5.15 GiB/s for double between strides 1 and 8. The decline is consistent with using fewer elements from each fetched cache line. It is not a direct measurement of physical DRAM traffic or proof of a specific prefetch failure.')
text(b,'Assembly establishes a second effect: only unit stride reaches the vector loop; other tested strides use scalar multiplication. Thus the stride-1 to stride-2 change combines vectorization loss with a changed access pattern. No gather/scatter implementation is used. The scalar baseline and fixed-span control help interpret the loss, but do not fully isolate every memory-system mechanism.')

b=page('Bandwidth calibration and roofline model')
figure(b,'roofline','Figure 5. Largest-size multiply measurements from the final ISA sweep (384 MiB float, 768 MiB double). Error bars show min-max. The solid model combines measured useful bandwidth with a multiply-only compute estimate at an assumed 4.7 GHz.')
table(b,[['Quantity','float','double'],['Useful bandwidth reference','40.93 GiB/s','40.56 GiB/s'],['Multiply arithmetic intensity','1/12 FLOP/byte','1/24 FLOP/byte'],['Memory performance reference','3.662 GFLOP/s','1.815 GFLOP/s'],['Measured native multiply','3.479 GFLOP/s','1.743 GFLOP/s'],['Measured / memory reference','95.0%','96.1%']])
text(b,'The calibration uses an independent streaming-add loop with two reads and one ordinary cached write. Its reference is the median of two run medians at N=67,108,864, with seven trials per run. Largest-size totals are 768 MiB float and 1,536 MiB double. Inspected assembly confirms ZMM vaddps/vaddpd and cached stores. The reference uses the large-size plateau rather than the highest smaller-footprint rate.')
text(b,'P = min(P_compute, B_useful * I_useful). GiB/s is converted to decimal GB/s before multiplication. At the modeled 4.7 GHz, two 512-bit multiplies/cycle give 150.4 GFLOP/s float or 75.2 double. A conventional FMA-only reference doubles those numbers to 300.8/150.4; multiply itself performs one FLOP per lane. This architectural estimate uses the listed base clock [1] and desktop Zen 5 throughput research [2], not measured operating frequency.')
text(b,'The measured multiply points are near the empirical memory reference and far below the arithmetic ceiling, supporting a memory-bound interpretation. Useful bandwidth absorbs cache/write-allocation effects; it is not a physical-byte counter result or an absolute hardware bound. Cache-resident points are excluded from this streaming roofline because they can exceed its memory slope.')

b=page('Hardware cycles per element')
figure(b,'cycles','Figure 6. Hardware user-mode cycles per element from a separate counter run. Points are medians of seven trials; bars are min-max. K=1,024 and M=1,048,576 elements.')
text(b,'A successful perf availability check was followed by a dedicated perf_event_open harness [3]. Each trial creates a fresh disabled, pinned CPU_CYCLES event for the calling thread, excludes kernel/hypervisor execution, enables it around the kernel batch and disables it before validation. CPE = raw counted cycles / (calls*N). No assumed clock is used to calculate CPE.')
text(b,'All 504 accepted measurements report running_time/enabled_time=1.0, so no multiplex scaling was applied. Counts include batch-loop, function-call and timer overhead; initialization, calibration, warmups, correctness checks and output are excluded. These are guest-exposed hardware-event measurements under WSL, not bare-metal isolation.')
text(b,'For N=1,024, float multiply uses 1.097 cycles/element scalar versus 0.175 native; double multiply uses 1.290 versus 0.281. At the largest size, double AXPY is nearly unchanged at 2.126 scalar and 2.139 native. Counter and timing sweeps are separate datasets, so small cross-run differences should not be interpreted as contradictions or converted into precise effective clock rates.')

b=page('Conclusions, limitations and reproducibility')
sub(b,'What the experiments establish')
text(b,'SIMD is most beneficial for independent, contiguous work that can exploit cache locality. Wider vectors do not guarantee proportional speedup. Large-array double multiply provides the required negative example: inspected code contains SIMD, yet the final timing sweep gives 0.98x native/scalar speedup. Its throughput is close to the independently calibrated memory reference. Dot product is a second caution: packed multiplication coexists with a serial reduction. Non-unit runtime stride is a third: the vectorized code path is bypassed entirely.')
sub(b,'Limitations and honest interpretation')
text(b,'Early informal observations included other background application load; they are not treated as a controlled CPU-stress study or used as the final baseline. Background load was not continuously logged. The current snapshot shows Balanced power and SMT enabled, but historical BIOS/power continuity is unverified. Linux frequency controls are unavailable in this WSL guest. Core affinity reduces migration but does not isolate host scheduling or sibling activity.')
text(b,'Several configurations have large timing ranges. All observations are retained; medians and min-max ranges are used without claiming confidence intervals. Alignment, stride and calibration datasets were collected separately. Cache-residency boundaries are nominal. No cache-miss or physical-memory-traffic counters were collected, so explanations involving those mechanisms are reasoned interpretations, not direct counter measurements.')
sub(b,'Reproducing and auditing the work')
text(b,'The final ISA run is identified by UTC timestamp 20261017T233950_282234Z and contains 2,016 trials on logical CPU 0. Metadata records Git HEAD 77f8fc15eab74b7bb0df49a6df6ac6f5a83dd840 plus a dirty/untracked working tree, binary SHA-256 values and source snapshots. The commit alone therefore does not identify the complete run; retain the run directory and its snapshots. The accompanying report package maps each dataset to its source upload and includes checksums.')
text(b,'The repository should retain build/run scripts, original run directories, compiler reports, assembly evidence, raw measurements, processed tables and plotting scripts. This report package includes the selected raw data and reproducible figure/PDF generators. The final step is to commit the completed deliverables and verify that the repository access meets the instructor\'s submission requirements.')
sub(b,'AI assistance and reference use')
text(b,'ChatGPT/Codex assisted with setup, benchmark/checking code, scripts, assembly interpretation, analysis, figures and report drafting. Measurements were run on the student\'s machine. A peer repository was reviewed for scope and organization [4]; its code, prose and measured results were not copied into this project. Compiler reports were checked against assembly to avoid the misleading inference that every runtime path was vectorized. The student should review the final interpretation and disclosure before submission.')
sub(b,'References')
text(b,'[1] AMD, Ryzen 7 9850X3D specifications: https://shop-us-en.amd.com/amd-ryzen-7-9850x3d-processor/\n[2] Alexander Yee, Zen5\'s AVX512 Teardown, original instruction-throughput experiments: https://www.numberworld.org/blogs/2024_8_7_zen5_avx512_teardown/\n[3] Linux man-pages, perf_event_open(2): https://man7.org/linux/man-pages/man2/perf_event_open.2.html\n[4] Peer scope reference: https://github.com/yuming-2003/ACS-PROJECT123/tree/main/Project%201')

styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyReport',fontName='Helvetica',fontSize=9.7,leading=13.5,spaceAfter=8))
styles.add(ParagraphStyle(name='SubReport',fontName='Helvetica-Bold',fontSize=11,leading=14,spaceBefore=5,spaceAfter=6,textColor=colors.HexColor('#175176')))
styles.add(ParagraphStyle(name='CapReport',fontName='Helvetica',fontSize=8,leading=10.5,spaceAfter=9,textColor=colors.HexColor('#444444')))
styles.add(ParagraphStyle(name='CellReport',fontName='Helvetica',fontSize=8.6,leading=11))
styles.add(ParagraphStyle(name='CodeReport',fontName='Courier',fontSize=8,leading=10,spaceAfter=8))
story=[];md=[]
def para(t,style='BodyReport'):return Paragraph(escape(t).replace('\n','<br/>'),styles[style])
for pi,p in enumerate(pages):
 if pi:story.append(PageBreak())
 story.append(Paragraph(escape(p['title']),styles['Heading1']));md.append('# '+p['title']+'\n')
 for typ,v in p['blocks']:
  if typ=='text':story.append(para(v));md.append(v+'\n')
  elif typ=='sub':story.append(para(v,'SubReport'));md.append('## '+v+'\n')
  elif typ=='code':story.append(Preformatted(v,styles['CodeReport']));md.append('```asm\n'+v+'\n```\n')
  elif typ=='table':
   cells=[[para(c,'CellReport') for c in row] for row in v]
   widths=([125,375] if len(v[0])==2 else ([125,125,125,125] if len(v[0])==4 else [250,125,125]))
   t=Table(cells,colWidths=widths,hAlign='LEFT',repeatRows=1)
   t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e5eef4')),('VALIGN',(0,0),(-1,-1),'TOP'),('LINEBELOW',(0,0),(-1,0),.7,colors.HexColor('#175176')),('LINEBELOW',(0,1),(-1,-1),.25,colors.HexColor('#dddddd')),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5)]))
   story.extend([t,Spacer(1,9)])
   md.extend(['| '+' | '.join(v[0])+' |','| '+' | '.join(['---']*len(v[0]))+' |']+['| '+' | '.join(row)+' |' for row in v[1:]]+[''])
  elif typ=='figure':
   f=R/'figures'/(v['name']+'.png');w,h=PILImage.open(f).size
   story.append(Image(str(f),width=500,height=500*h/w));story.append(para(v['caption'],'CapReport'))
   md.append('!['+v['caption']+'](figures/'+v['name']+'.png)\n')
(R/'report.md').write_text('\n'.join(md))
(R/'report_content.json').write_text(json.dumps(pages,indent=2))
def footer(c,doc):
 c.setStrokeColor(colors.HexColor('#ccd6df'));c.line(48,39,548,39)
 c.setFont('Helvetica',8);c.setFillColor(colors.HexColor('#555555'))
 c.drawString(48,27,'Andrew Zheng | SIMD Advantage Profiling');c.drawRightString(548,27,str(doc.page))
doc=SimpleDocTemplate(str(R/'SIMD_Project1_Report.pdf'),pagesize=(596,842),rightMargin=48,leftMargin=48,topMargin=43,bottomMargin=52,title='SIMD Advantage Profiling',author='Andrew Zheng')
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print('Wrote report.md and SIMD_Project1_Report.pdf')
