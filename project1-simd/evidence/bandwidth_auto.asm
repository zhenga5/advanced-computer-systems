
build/kernels_bandwidth.o:     file format elf64-x86-64


Disassembly of section .text._Z10stream_addIfEvPKT_S2_PS0_m:

0000000000000000 <void stream_add<float>(float const*, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	0f 84 d6 01 00 00    	je     1e3 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e3>
   d:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  11:	48 83 f8 06          	cmp    rax,0x6
  15:	0f 86 95 01 00 00    	jbe    1b0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1b0>
  1b:	4c 8d 4f 04          	lea    r9,[rdi+0x4]
  1f:	49 89 d0             	mov    r8,rdx
  22:	4d 29 c8             	sub    r8,r9
  25:	49 83 f8 38          	cmp    r8,0x38
  29:	0f 86 81 01 00 00    	jbe    1b0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1b0>
  2f:	4c 8d 4e 04          	lea    r9,[rsi+0x4]
  33:	49 89 d0             	mov    r8,rdx
  36:	4d 29 c8             	sub    r8,r9
  39:	49 83 f8 38          	cmp    r8,0x38
  3d:	0f 86 6d 01 00 00    	jbe    1b0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1b0>
  43:	48 83 f8 0e          	cmp    rax,0xe
  47:	0f 86 97 01 00 00    	jbe    1e4 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e4>
  4d:	49 89 c8             	mov    r8,rcx
  50:	31 c0                	xor    eax,eax
  52:	49 c1 e8 04          	shr    r8,0x4
  56:	49 c1 e0 06          	shl    r8,0x6
  5a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  60:	62 f1 7c 48 10 0c 07 	vmovups zmm1,ZMMWORD PTR [rdi+rax*1]
  67:	62 f1 74 48 58 04 06 	vaddps zmm0,zmm1,ZMMWORD PTR [rsi+rax*1]
  6e:	62 f1 7c 48 11 04 02 	vmovups ZMMWORD PTR [rdx+rax*1],zmm0
  75:	48 83 c0 40          	add    rax,0x40
  79:	4c 39 c0             	cmp    rax,r8
  7c:	75 e2                	jne    60 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x60>
  7e:	48 89 c8             	mov    rax,rcx
  81:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  85:	f6 c1 0f             	test   cl,0xf
  88:	0f 84 52 01 00 00    	je     1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
  8e:	49 89 c9             	mov    r9,rcx
  91:	49 29 c1             	sub    r9,rax
  94:	4d 8d 41 ff          	lea    r8,[r9-0x1]
  98:	49 83 f8 06          	cmp    r8,0x6
  9c:	76 2e                	jbe    cc <void stream_add<float>(float const*, float const*, float*, unsigned long)+0xcc>
  9e:	4c 8d 04 85 00 00 00 	lea    r8,[rax*4+0x0]
  a5:	00 
  a6:	c4 a1 7c 10 14 07    	vmovups ymm2,YMMWORD PTR [rdi+r8*1]
  ac:	c4 a1 6c 58 04 06    	vaddps ymm0,ymm2,YMMWORD PTR [rsi+r8*1]
  b2:	c4 a1 7c 11 04 02    	vmovups YMMWORD PTR [rdx+r8*1],ymm0
  b8:	4d 89 c8             	mov    r8,r9
  bb:	49 83 e0 f8          	and    r8,0xfffffffffffffff8
  bf:	4c 01 c0             	add    rax,r8
  c2:	41 83 e1 07          	and    r9d,0x7
  c6:	0f 84 14 01 00 00    	je     1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
  cc:	4c 8d 04 85 00 00 00 	lea    r8,[rax*4+0x0]
  d3:	00 
  d4:	4c 8d 48 01          	lea    r9,[rax+0x1]
  d8:	c4 a1 7a 10 04 07    	vmovss xmm0,DWORD PTR [rdi+r8*1]
  de:	c4 a1 7a 58 04 06    	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1]
  e4:	c4 a1 7a 11 04 02    	vmovss DWORD PTR [rdx+r8*1],xmm0
  ea:	49 39 c9             	cmp    r9,rcx
  ed:	0f 83 ed 00 00 00    	jae    1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
  f3:	c4 a1 7a 10 44 07 04 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x4]
  fa:	c4 a1 7a 58 44 06 04 	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x4]
 101:	4c 8d 48 02          	lea    r9,[rax+0x2]
 105:	c4 a1 7a 11 44 02 04 	vmovss DWORD PTR [rdx+r8*1+0x4],xmm0
 10c:	49 39 c9             	cmp    r9,rcx
 10f:	0f 83 cb 00 00 00    	jae    1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 115:	c4 a1 7a 10 44 07 08 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x8]
 11c:	c4 a1 7a 58 44 06 08 	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x8]
 123:	4c 8d 48 03          	lea    r9,[rax+0x3]
 127:	c4 a1 7a 11 44 02 08 	vmovss DWORD PTR [rdx+r8*1+0x8],xmm0
 12e:	49 39 c9             	cmp    r9,rcx
 131:	0f 83 a9 00 00 00    	jae    1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 137:	c4 a1 7a 10 44 07 0c 	vmovss xmm0,DWORD PTR [rdi+r8*1+0xc]
 13e:	c4 a1 7a 58 44 06 0c 	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1+0xc]
 145:	4c 8d 48 04          	lea    r9,[rax+0x4]
 149:	c4 a1 7a 11 44 02 0c 	vmovss DWORD PTR [rdx+r8*1+0xc],xmm0
 150:	49 39 c9             	cmp    r9,rcx
 153:	0f 83 87 00 00 00    	jae    1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 159:	c4 a1 7a 10 44 07 10 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x10]
 160:	c4 a1 7a 58 44 06 10 	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x10]
 167:	4c 8d 48 05          	lea    r9,[rax+0x5]
 16b:	c4 a1 7a 11 44 02 10 	vmovss DWORD PTR [rdx+r8*1+0x10],xmm0
 172:	49 39 c9             	cmp    r9,rcx
 175:	73 69                	jae    1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 177:	c4 a1 7a 10 44 07 14 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x14]
 17e:	c4 a1 7a 58 44 06 14 	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x14]
 185:	48 83 c0 06          	add    rax,0x6
 189:	c4 a1 7a 11 44 02 14 	vmovss DWORD PTR [rdx+r8*1+0x14],xmm0
 190:	48 39 c8             	cmp    rax,rcx
 193:	73 4b                	jae    1e0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 195:	c4 a1 7a 10 44 07 18 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x18]
 19c:	c4 a1 7a 58 44 06 18 	vaddss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x18]
 1a3:	c4 a1 7a 11 44 02 18 	vmovss DWORD PTR [rdx+r8*1+0x18],xmm0
 1aa:	c5 f8 77             	vzeroupper
 1ad:	c3                   	ret
 1ae:	66 90                	xchg   ax,ax
 1b0:	31 c0                	xor    eax,eax
 1b2:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 1b9:	00 00 00 00 
 1bd:	0f 1f 00             	nop    DWORD PTR [rax]
 1c0:	c5 fa 10 04 87       	vmovss xmm0,DWORD PTR [rdi+rax*4]
 1c5:	c5 fa 58 04 86       	vaddss xmm0,xmm0,DWORD PTR [rsi+rax*4]
 1ca:	c5 fa 11 04 82       	vmovss DWORD PTR [rdx+rax*4],xmm0
 1cf:	48 ff c0             	inc    rax
 1d2:	48 39 c1             	cmp    rcx,rax
 1d5:	75 e9                	jne    1c0 <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x1c0>
 1d7:	c3                   	ret
 1d8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 1df:	00 
 1e0:	c5 f8 77             	vzeroupper
 1e3:	c3                   	ret
 1e4:	49 89 c9             	mov    r9,rcx
 1e7:	31 c0                	xor    eax,eax
 1e9:	e9 b0 fe ff ff       	jmp    9e <void stream_add<float>(float const*, float const*, float*, unsigned long)+0x9e>

Disassembly of section .text._Z10stream_addIdEvPKT_S2_PS0_m:

0000000000000000 <void stream_add<double>(double const*, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	0f 84 56 01 00 00    	je     163 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x163>
   d:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  11:	48 83 f8 02          	cmp    rax,0x2
  15:	0f 86 15 01 00 00    	jbe    130 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x130>
  1b:	4c 8d 4f 08          	lea    r9,[rdi+0x8]
  1f:	49 89 d0             	mov    r8,rdx
  22:	4d 29 c8             	sub    r8,r9
  25:	49 83 f8 30          	cmp    r8,0x30
  29:	0f 86 01 01 00 00    	jbe    130 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x130>
  2f:	4c 8d 4e 08          	lea    r9,[rsi+0x8]
  33:	49 89 d0             	mov    r8,rdx
  36:	4d 29 c8             	sub    r8,r9
  39:	49 83 f8 30          	cmp    r8,0x30
  3d:	0f 86 ed 00 00 00    	jbe    130 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x130>
  43:	48 83 f8 06          	cmp    rax,0x6
  47:	0f 86 17 01 00 00    	jbe    164 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x164>
  4d:	49 89 c8             	mov    r8,rcx
  50:	31 c0                	xor    eax,eax
  52:	49 c1 e8 03          	shr    r8,0x3
  56:	49 c1 e0 06          	shl    r8,0x6
  5a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  60:	62 f1 fd 48 10 0c 07 	vmovupd zmm1,ZMMWORD PTR [rdi+rax*1]
  67:	62 f1 f5 48 58 04 06 	vaddpd zmm0,zmm1,ZMMWORD PTR [rsi+rax*1]
  6e:	62 f1 fd 48 11 04 02 	vmovupd ZMMWORD PTR [rdx+rax*1],zmm0
  75:	48 83 c0 40          	add    rax,0x40
  79:	4c 39 c0             	cmp    rax,r8
  7c:	75 e2                	jne    60 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x60>
  7e:	48 89 c8             	mov    rax,rcx
  81:	48 83 e0 f8          	and    rax,0xfffffffffffffff8
  85:	f6 c1 07             	test   cl,0x7
  88:	0f 84 d2 00 00 00    	je     160 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x160>
  8e:	49 89 c9             	mov    r9,rcx
  91:	49 29 c1             	sub    r9,rax
  94:	4d 8d 41 ff          	lea    r8,[r9-0x1]
  98:	49 83 f8 02          	cmp    r8,0x2
  9c:	76 2e                	jbe    cc <void stream_add<double>(double const*, double const*, double*, unsigned long)+0xcc>
  9e:	4c 8d 04 c5 00 00 00 	lea    r8,[rax*8+0x0]
  a5:	00 
  a6:	c4 a1 7d 10 14 07    	vmovupd ymm2,YMMWORD PTR [rdi+r8*1]
  ac:	c4 a1 6d 58 04 06    	vaddpd ymm0,ymm2,YMMWORD PTR [rsi+r8*1]
  b2:	c4 a1 7d 11 04 02    	vmovupd YMMWORD PTR [rdx+r8*1],ymm0
  b8:	4d 89 c8             	mov    r8,r9
  bb:	49 83 e0 fc          	and    r8,0xfffffffffffffffc
  bf:	4c 01 c0             	add    rax,r8
  c2:	41 83 e1 03          	and    r9d,0x3
  c6:	0f 84 94 00 00 00    	je     160 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x160>
  cc:	4c 8d 04 c5 00 00 00 	lea    r8,[rax*8+0x0]
  d3:	00 
  d4:	4c 8d 48 01          	lea    r9,[rax+0x1]
  d8:	c4 a1 7b 10 04 07    	vmovsd xmm0,QWORD PTR [rdi+r8*1]
  de:	c4 a1 7b 58 04 06    	vaddsd xmm0,xmm0,QWORD PTR [rsi+r8*1]
  e4:	c4 a1 7b 11 04 02    	vmovsd QWORD PTR [rdx+r8*1],xmm0
  ea:	49 39 c9             	cmp    r9,rcx
  ed:	73 71                	jae    160 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x160>
  ef:	48 83 c0 02          	add    rax,0x2
  f3:	c4 a1 7b 10 44 07 08 	vmovsd xmm0,QWORD PTR [rdi+r8*1+0x8]
  fa:	c4 a1 7b 58 44 06 08 	vaddsd xmm0,xmm0,QWORD PTR [rsi+r8*1+0x8]
 101:	c4 a1 7b 11 44 02 08 	vmovsd QWORD PTR [rdx+r8*1+0x8],xmm0
 108:	48 39 c8             	cmp    rax,rcx
 10b:	73 53                	jae    160 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x160>
 10d:	c4 a1 7b 10 44 07 10 	vmovsd xmm0,QWORD PTR [rdi+r8*1+0x10]
 114:	c4 a1 7b 58 44 06 10 	vaddsd xmm0,xmm0,QWORD PTR [rsi+r8*1+0x10]
 11b:	c4 a1 7b 11 44 02 10 	vmovsd QWORD PTR [rdx+r8*1+0x10],xmm0
 122:	c5 f8 77             	vzeroupper
 125:	c3                   	ret
 126:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
 12d:	00 00 00 
 130:	31 c0                	xor    eax,eax
 132:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 139:	00 00 00 00 
 13d:	0f 1f 00             	nop    DWORD PTR [rax]
 140:	c5 fb 10 04 c7       	vmovsd xmm0,QWORD PTR [rdi+rax*8]
 145:	c5 fb 58 04 c6       	vaddsd xmm0,xmm0,QWORD PTR [rsi+rax*8]
 14a:	c5 fb 11 04 c2       	vmovsd QWORD PTR [rdx+rax*8],xmm0
 14f:	48 ff c0             	inc    rax
 152:	48 39 c1             	cmp    rcx,rax
 155:	75 e9                	jne    140 <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x140>
 157:	c3                   	ret
 158:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 15f:	00 
 160:	c5 f8 77             	vzeroupper
 163:	c3                   	ret
 164:	49 89 c9             	mov    r9,rcx
 167:	31 c0                	xor    eax,eax
 169:	e9 30 ff ff ff       	jmp    9e <void stream_add<double>(double const*, double const*, double*, unsigned long)+0x9e>
