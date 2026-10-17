
build/kernels_stride_auto.o:     file format elf64-x86-64


Disassembly of section .text._Z15multiply_strideIfEvPKT_S2_PS0_mm:

0000000000000000 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	0f 84 e6 01 00 00    	je     1f3 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f3>
   d:	49 83 f8 01          	cmp    r8,0x1
  11:	0f 85 e9 01 00 00    	jne    200 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x200>
  17:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  1b:	48 83 f8 06          	cmp    rax,0x6
  1f:	0f 86 9b 01 00 00    	jbe    1c0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1c0>
  25:	4c 8d 4f 04          	lea    r9,[rdi+0x4]
  29:	49 89 d0             	mov    r8,rdx
  2c:	4d 29 c8             	sub    r8,r9
  2f:	49 83 f8 38          	cmp    r8,0x38
  33:	0f 86 87 01 00 00    	jbe    1c0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1c0>
  39:	4c 8d 4e 04          	lea    r9,[rsi+0x4]
  3d:	49 89 d0             	mov    r8,rdx
  40:	4d 29 c8             	sub    r8,r9
  43:	49 83 f8 38          	cmp    r8,0x38
  47:	0f 86 73 01 00 00    	jbe    1c0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1c0>
  4d:	48 83 f8 0e          	cmp    rax,0xe
  51:	0f 86 d4 01 00 00    	jbe    22b <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x22b>
  57:	49 89 c8             	mov    r8,rcx
  5a:	31 c0                	xor    eax,eax
  5c:	49 c1 e8 04          	shr    r8,0x4
  60:	49 c1 e0 06          	shl    r8,0x6
  64:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  6b:	00 00 00 00 
  6f:	90                   	nop
  70:	62 f1 7c 48 10 0c 07 	vmovups zmm1,ZMMWORD PTR [rdi+rax*1]
  77:	62 f1 74 48 59 04 06 	vmulps zmm0,zmm1,ZMMWORD PTR [rsi+rax*1]
  7e:	62 f1 7c 48 11 04 02 	vmovups ZMMWORD PTR [rdx+rax*1],zmm0
  85:	48 83 c0 40          	add    rax,0x40
  89:	4c 39 c0             	cmp    rax,r8
  8c:	75 e2                	jne    70 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x70>
  8e:	48 89 c8             	mov    rax,rcx
  91:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  95:	f6 c1 0f             	test   cl,0xf
  98:	0f 84 52 01 00 00    	je     1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
  9e:	49 89 c9             	mov    r9,rcx
  a1:	49 29 c1             	sub    r9,rax
  a4:	4d 8d 41 ff          	lea    r8,[r9-0x1]
  a8:	49 83 f8 06          	cmp    r8,0x6
  ac:	76 2e                	jbe    dc <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0xdc>
  ae:	4c 8d 04 85 00 00 00 	lea    r8,[rax*4+0x0]
  b5:	00 
  b6:	c4 a1 7c 10 14 07    	vmovups ymm2,YMMWORD PTR [rdi+r8*1]
  bc:	c4 a1 6c 59 04 06    	vmulps ymm0,ymm2,YMMWORD PTR [rsi+r8*1]
  c2:	c4 a1 7c 11 04 02    	vmovups YMMWORD PTR [rdx+r8*1],ymm0
  c8:	4d 89 c8             	mov    r8,r9
  cb:	49 83 e0 f8          	and    r8,0xfffffffffffffff8
  cf:	4c 01 c0             	add    rax,r8
  d2:	41 83 e1 07          	and    r9d,0x7
  d6:	0f 84 14 01 00 00    	je     1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
  dc:	4c 8d 04 85 00 00 00 	lea    r8,[rax*4+0x0]
  e3:	00 
  e4:	4c 8d 48 01          	lea    r9,[rax+0x1]
  e8:	c4 a1 7a 10 04 06    	vmovss xmm0,DWORD PTR [rsi+r8*1]
  ee:	c4 a1 7a 59 04 07    	vmulss xmm0,xmm0,DWORD PTR [rdi+r8*1]
  f4:	c4 a1 7a 11 04 02    	vmovss DWORD PTR [rdx+r8*1],xmm0
  fa:	49 39 c9             	cmp    r9,rcx
  fd:	0f 83 ed 00 00 00    	jae    1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
 103:	c4 a1 7a 10 44 07 04 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x4]
 10a:	c4 a1 7a 59 44 06 04 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x4]
 111:	4c 8d 48 02          	lea    r9,[rax+0x2]
 115:	c4 a1 7a 11 44 02 04 	vmovss DWORD PTR [rdx+r8*1+0x4],xmm0
 11c:	49 39 c9             	cmp    r9,rcx
 11f:	0f 83 cb 00 00 00    	jae    1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
 125:	c4 a1 7a 10 44 07 08 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x8]
 12c:	c4 a1 7a 59 44 06 08 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x8]
 133:	4c 8d 48 03          	lea    r9,[rax+0x3]
 137:	c4 a1 7a 11 44 02 08 	vmovss DWORD PTR [rdx+r8*1+0x8],xmm0
 13e:	49 39 c9             	cmp    r9,rcx
 141:	0f 83 a9 00 00 00    	jae    1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
 147:	c4 a1 7a 10 44 07 0c 	vmovss xmm0,DWORD PTR [rdi+r8*1+0xc]
 14e:	c4 a1 7a 59 44 06 0c 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0xc]
 155:	4c 8d 48 04          	lea    r9,[rax+0x4]
 159:	c4 a1 7a 11 44 02 0c 	vmovss DWORD PTR [rdx+r8*1+0xc],xmm0
 160:	49 39 c9             	cmp    r9,rcx
 163:	0f 83 87 00 00 00    	jae    1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
 169:	c4 a1 7a 10 44 07 10 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x10]
 170:	c4 a1 7a 59 44 06 10 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x10]
 177:	4c 8d 48 05          	lea    r9,[rax+0x5]
 17b:	c4 a1 7a 11 44 02 10 	vmovss DWORD PTR [rdx+r8*1+0x10],xmm0
 182:	49 39 c9             	cmp    r9,rcx
 185:	73 69                	jae    1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
 187:	c4 a1 7a 10 44 07 14 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x14]
 18e:	c4 a1 7a 59 44 06 14 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x14]
 195:	48 83 c0 06          	add    rax,0x6
 199:	c4 a1 7a 11 44 02 14 	vmovss DWORD PTR [rdx+r8*1+0x14],xmm0
 1a0:	48 39 c8             	cmp    rax,rcx
 1a3:	73 4b                	jae    1f0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1f0>
 1a5:	c4 a1 7a 10 44 07 18 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x18]
 1ac:	c4 a1 7a 59 44 06 18 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x18]
 1b3:	c4 a1 7a 11 44 02 18 	vmovss DWORD PTR [rdx+r8*1+0x18],xmm0
 1ba:	c5 f8 77             	vzeroupper
 1bd:	c3                   	ret
 1be:	66 90                	xchg   ax,ax
 1c0:	31 c0                	xor    eax,eax
 1c2:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 1c9:	00 00 00 00 
 1cd:	0f 1f 00             	nop    DWORD PTR [rax]
 1d0:	c5 fa 10 04 87       	vmovss xmm0,DWORD PTR [rdi+rax*4]
 1d5:	c5 fa 59 04 86       	vmulss xmm0,xmm0,DWORD PTR [rsi+rax*4]
 1da:	c5 fa 11 04 82       	vmovss DWORD PTR [rdx+rax*4],xmm0
 1df:	48 ff c0             	inc    rax
 1e2:	48 39 c1             	cmp    rcx,rax
 1e5:	75 e9                	jne    1d0 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x1d0>
 1e7:	c3                   	ret
 1e8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 1ef:	00 
 1f0:	c5 f8 77             	vzeroupper
 1f3:	c3                   	ret
 1f4:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 1fb:	00 00 00 00 
 1ff:	90                   	nop
 200:	49 c1 e0 02          	shl    r8,0x2
 204:	31 c0                	xor    eax,eax
 206:	45 31 c9             	xor    r9d,r9d
 209:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
 210:	c5 fa 10 04 07       	vmovss xmm0,DWORD PTR [rdi+rax*1]
 215:	c5 fa 59 04 06       	vmulss xmm0,xmm0,DWORD PTR [rsi+rax*1]
 21a:	49 ff c1             	inc    r9
 21d:	c5 fa 11 04 02       	vmovss DWORD PTR [rdx+rax*1],xmm0
 222:	4c 01 c0             	add    rax,r8
 225:	4c 39 c9             	cmp    rcx,r9
 228:	75 e6                	jne    210 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x210>
 22a:	c3                   	ret
 22b:	49 89 c9             	mov    r9,rcx
 22e:	31 c0                	xor    eax,eax
 230:	e9 79 fe ff ff       	jmp    ae <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0xae>

Disassembly of section .text._Z15multiply_strideIdEvPKT_S2_PS0_mm:

0000000000000000 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	0f 84 66 01 00 00    	je     173 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x173>
   d:	49 83 f8 01          	cmp    r8,0x1
  11:	0f 85 69 01 00 00    	jne    180 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x180>
  17:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  1b:	48 83 f8 02          	cmp    rax,0x2
  1f:	0f 86 1b 01 00 00    	jbe    140 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x140>
  25:	4c 8d 4f 08          	lea    r9,[rdi+0x8]
  29:	49 89 d0             	mov    r8,rdx
  2c:	4d 29 c8             	sub    r8,r9
  2f:	49 83 f8 30          	cmp    r8,0x30
  33:	0f 86 07 01 00 00    	jbe    140 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x140>
  39:	4c 8d 4e 08          	lea    r9,[rsi+0x8]
  3d:	49 89 d0             	mov    r8,rdx
  40:	4d 29 c8             	sub    r8,r9
  43:	49 83 f8 30          	cmp    r8,0x30
  47:	0f 86 f3 00 00 00    	jbe    140 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x140>
  4d:	49 89 c8             	mov    r8,rcx
  50:	48 83 f8 06          	cmp    rax,0x6
  54:	0f 86 51 01 00 00    	jbe    1ab <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x1ab>
  5a:	49 c1 e8 03          	shr    r8,0x3
  5e:	49 c1 e0 06          	shl    r8,0x6
  62:	31 c0                	xor    eax,eax
  64:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  6b:	00 00 00 00 
  6f:	90                   	nop
  70:	62 f1 fd 48 10 0c 07 	vmovupd zmm1,ZMMWORD PTR [rdi+rax*1]
  77:	62 f1 f5 48 59 04 06 	vmulpd zmm0,zmm1,ZMMWORD PTR [rsi+rax*1]
  7e:	62 f1 fd 48 11 04 02 	vmovupd ZMMWORD PTR [rdx+rax*1],zmm0
  85:	48 83 c0 40          	add    rax,0x40
  89:	4c 39 c0             	cmp    rax,r8
  8c:	75 e2                	jne    70 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x70>
  8e:	48 89 c8             	mov    rax,rcx
  91:	48 83 e0 f8          	and    rax,0xfffffffffffffff8
  95:	f6 c1 07             	test   cl,0x7
  98:	0f 84 d2 00 00 00    	je     170 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x170>
  9e:	49 89 c8             	mov    r8,rcx
  a1:	49 29 c0             	sub    r8,rax
  a4:	4d 8d 48 ff          	lea    r9,[r8-0x1]
  a8:	49 83 f9 02          	cmp    r9,0x2
  ac:	76 2b                	jbe    d9 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0xd9>
  ae:	4c 8d 0c c5 00 00 00 	lea    r9,[rax*8+0x0]
  b5:	00 
  b6:	c4 a1 7d 10 14 0f    	vmovupd ymm2,YMMWORD PTR [rdi+r9*1]
  bc:	c4 a1 6d 59 04 0e    	vmulpd ymm0,ymm2,YMMWORD PTR [rsi+r9*1]
  c2:	c4 a1 7d 11 04 0a    	vmovupd YMMWORD PTR [rdx+r9*1],ymm0
  c8:	41 f6 c0 03          	test   r8b,0x3
  cc:	0f 84 9e 00 00 00    	je     170 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x170>
  d2:	49 83 e0 fc          	and    r8,0xfffffffffffffffc
  d6:	4c 01 c0             	add    rax,r8
  d9:	4c 8d 04 c5 00 00 00 	lea    r8,[rax*8+0x0]
  e0:	00 
  e1:	4c 8d 48 01          	lea    r9,[rax+0x1]
  e5:	c4 a1 7b 10 04 06    	vmovsd xmm0,QWORD PTR [rsi+r8*1]
  eb:	c4 a1 7b 59 04 07    	vmulsd xmm0,xmm0,QWORD PTR [rdi+r8*1]
  f1:	c4 a1 7b 11 04 02    	vmovsd QWORD PTR [rdx+r8*1],xmm0
  f7:	49 39 c9             	cmp    r9,rcx
  fa:	73 74                	jae    170 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x170>
  fc:	48 83 c0 02          	add    rax,0x2
 100:	c4 a1 7b 10 44 07 08 	vmovsd xmm0,QWORD PTR [rdi+r8*1+0x8]
 107:	c4 a1 7b 59 44 06 08 	vmulsd xmm0,xmm0,QWORD PTR [rsi+r8*1+0x8]
 10e:	c4 a1 7b 11 44 02 08 	vmovsd QWORD PTR [rdx+r8*1+0x8],xmm0
 115:	48 39 c8             	cmp    rax,rcx
 118:	73 56                	jae    170 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x170>
 11a:	c4 a1 7b 10 44 07 10 	vmovsd xmm0,QWORD PTR [rdi+r8*1+0x10]
 121:	c4 a1 7b 59 44 06 10 	vmulsd xmm0,xmm0,QWORD PTR [rsi+r8*1+0x10]
 128:	c4 a1 7b 11 44 02 10 	vmovsd QWORD PTR [rdx+r8*1+0x10],xmm0
 12f:	c5 f8 77             	vzeroupper
 132:	c3                   	ret
 133:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 13a:	00 00 00 00 
 13e:	66 90                	xchg   ax,ax
 140:	31 c0                	xor    eax,eax
 142:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 149:	00 00 00 00 
 14d:	0f 1f 00             	nop    DWORD PTR [rax]
 150:	c5 fb 10 04 c7       	vmovsd xmm0,QWORD PTR [rdi+rax*8]
 155:	c5 fb 59 04 c6       	vmulsd xmm0,xmm0,QWORD PTR [rsi+rax*8]
 15a:	c5 fb 11 04 c2       	vmovsd QWORD PTR [rdx+rax*8],xmm0
 15f:	48 ff c0             	inc    rax
 162:	48 39 c1             	cmp    rcx,rax
 165:	75 e9                	jne    150 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x150>
 167:	c3                   	ret
 168:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 16f:	00 
 170:	c5 f8 77             	vzeroupper
 173:	c3                   	ret
 174:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 17b:	00 00 00 00 
 17f:	90                   	nop
 180:	49 c1 e0 03          	shl    r8,0x3
 184:	31 c0                	xor    eax,eax
 186:	45 31 c9             	xor    r9d,r9d
 189:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
 190:	49 ff c1             	inc    r9
 193:	c5 fb 10 04 07       	vmovsd xmm0,QWORD PTR [rdi+rax*1]
 198:	c5 fb 59 04 06       	vmulsd xmm0,xmm0,QWORD PTR [rsi+rax*1]
 19d:	c5 fb 11 04 02       	vmovsd QWORD PTR [rdx+rax*1],xmm0
 1a2:	4c 01 c0             	add    rax,r8
 1a5:	4c 39 c9             	cmp    rcx,r9
 1a8:	75 e6                	jne    190 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x190>
 1aa:	c3                   	ret
 1ab:	31 c0                	xor    eax,eax
 1ad:	e9 fc fe ff ff       	jmp    ae <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0xae>
