
build/kernels_auto.o:     file format elf64-x86-64


Disassembly of section .text._Z4axpyIfEvT_PKS0_PS0_m:

0000000000000000 <void axpy<float>(float, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f1             	mov    rcx,rsi
   7:	48 85 d2             	test   rdx,rdx
   a:	0f 84 73 01 00 00    	je     183 <void axpy<float>(float, float const*, float*, unsigned long)+0x183>
  10:	48 8d 72 ff          	lea    rsi,[rdx-0x1]
  14:	48 83 fe 06          	cmp    rsi,0x6
  18:	0f 86 72 01 00 00    	jbe    190 <void axpy<float>(float, float const*, float*, unsigned long)+0x190>
  1e:	48 8d 47 04          	lea    rax,[rdi+0x4]
  22:	49 89 c8             	mov    r8,rcx
  25:	49 29 c0             	sub    r8,rax
  28:	31 c0                	xor    eax,eax
  2a:	49 83 f8 38          	cmp    r8,0x38
  2e:	77 20                	ja     50 <void axpy<float>(float, float const*, float*, unsigned long)+0x50>
  30:	c5 fa 59 0c 87       	vmulss xmm1,xmm0,DWORD PTR [rdi+rax*4]
  35:	c5 f2 58 0c 81       	vaddss xmm1,xmm1,DWORD PTR [rcx+rax*4]
  3a:	c5 fa 11 0c 81       	vmovss DWORD PTR [rcx+rax*4],xmm1
  3f:	48 ff c0             	inc    rax
  42:	48 39 c2             	cmp    rdx,rax
  45:	75 e9                	jne    30 <void axpy<float>(float, float const*, float*, unsigned long)+0x30>
  47:	c3                   	ret
  48:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  4f:	00 
  50:	48 83 fe 0e          	cmp    rsi,0xe
  54:	0f 86 7b 01 00 00    	jbe    1d5 <void axpy<float>(float, float const*, float*, unsigned long)+0x1d5>
  5a:	48 89 d6             	mov    rsi,rdx
  5d:	62 f2 7d 48 18 d0    	vbroadcastss zmm2,xmm0
  63:	48 c1 ee 04          	shr    rsi,0x4
  67:	48 c1 e6 06          	shl    rsi,0x6
  6b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  70:	62 f1 6c 48 59 0c 07 	vmulps zmm1,zmm2,ZMMWORD PTR [rdi+rax*1]
  77:	62 f1 74 48 58 0c 01 	vaddps zmm1,zmm1,ZMMWORD PTR [rcx+rax*1]
  7e:	62 f1 7c 48 11 0c 01 	vmovups ZMMWORD PTR [rcx+rax*1],zmm1
  85:	48 83 c0 40          	add    rax,0x40
  89:	48 39 f0             	cmp    rax,rsi
  8c:	75 e2                	jne    70 <void axpy<float>(float, float const*, float*, unsigned long)+0x70>
  8e:	48 89 d0             	mov    rax,rdx
  91:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  95:	f6 c2 0f             	test   dl,0xf
  98:	0f 84 e2 00 00 00    	je     180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
  9e:	48 89 d6             	mov    rsi,rdx
  a1:	48 29 c6             	sub    rsi,rax
  a4:	4c 8d 46 ff          	lea    r8,[rsi-0x1]
  a8:	49 83 f8 06          	cmp    r8,0x6
  ac:	76 34                	jbe    e2 <void axpy<float>(float, float const*, float*, unsigned long)+0xe2>
  ae:	4c 8d 0c 85 00 00 00 	lea    r9,[rax*4+0x0]
  b5:	00 
  b6:	c4 e2 7d 18 c8       	vbroadcastss ymm1,xmm0
  bb:	4e 8d 04 09          	lea    r8,[rcx+r9*1]
  bf:	c4 a1 74 59 0c 0f    	vmulps ymm1,ymm1,YMMWORD PTR [rdi+r9*1]
  c5:	c4 c1 74 58 08       	vaddps ymm1,ymm1,YMMWORD PTR [r8]
  ca:	c4 c1 7c 11 08       	vmovups YMMWORD PTR [r8],ymm1
  cf:	49 89 f0             	mov    r8,rsi
  d2:	49 83 e0 f8          	and    r8,0xfffffffffffffff8
  d6:	4c 01 c0             	add    rax,r8
  d9:	83 e6 07             	and    esi,0x7
  dc:	0f 84 9e 00 00 00    	je     180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
  e2:	48 8d 34 85 00 00 00 	lea    rsi,[rax*4+0x0]
  e9:	00 
  ea:	4c 8d 04 31          	lea    r8,[rcx+rsi*1]
  ee:	c5 fa 59 0c 37       	vmulss xmm1,xmm0,DWORD PTR [rdi+rsi*1]
  f3:	c4 c1 72 58 08       	vaddss xmm1,xmm1,DWORD PTR [r8]
  f8:	c4 c1 7a 11 08       	vmovss DWORD PTR [r8],xmm1
  fd:	4c 8d 40 01          	lea    r8,[rax+0x1]
 101:	49 39 d0             	cmp    r8,rdx
 104:	73 7a                	jae    180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
 106:	4c 8d 44 31 04       	lea    r8,[rcx+rsi*1+0x4]
 10b:	c5 fa 59 4c 37 04    	vmulss xmm1,xmm0,DWORD PTR [rdi+rsi*1+0x4]
 111:	c4 c1 72 58 08       	vaddss xmm1,xmm1,DWORD PTR [r8]
 116:	c4 c1 7a 11 08       	vmovss DWORD PTR [r8],xmm1
 11b:	4c 8d 40 02          	lea    r8,[rax+0x2]
 11f:	49 39 d0             	cmp    r8,rdx
 122:	73 5c                	jae    180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
 124:	4c 8d 44 31 08       	lea    r8,[rcx+rsi*1+0x8]
 129:	c5 fa 59 4c 37 08    	vmulss xmm1,xmm0,DWORD PTR [rdi+rsi*1+0x8]
 12f:	c4 c1 72 58 08       	vaddss xmm1,xmm1,DWORD PTR [r8]
 134:	c4 c1 7a 11 08       	vmovss DWORD PTR [r8],xmm1
 139:	4c 8d 40 03          	lea    r8,[rax+0x3]
 13d:	49 39 d0             	cmp    r8,rdx
 140:	73 3e                	jae    180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
 142:	4c 8d 44 31 0c       	lea    r8,[rcx+rsi*1+0xc]
 147:	c5 fa 59 4c 37 0c    	vmulss xmm1,xmm0,DWORD PTR [rdi+rsi*1+0xc]
 14d:	c4 c1 72 58 08       	vaddss xmm1,xmm1,DWORD PTR [r8]
 152:	c4 c1 7a 11 08       	vmovss DWORD PTR [r8],xmm1
 157:	4c 8d 40 04          	lea    r8,[rax+0x4]
 15b:	49 39 d0             	cmp    r8,rdx
 15e:	73 20                	jae    180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
 160:	4c 8d 44 31 10       	lea    r8,[rcx+rsi*1+0x10]
 165:	c5 fa 59 4c 37 10    	vmulss xmm1,xmm0,DWORD PTR [rdi+rsi*1+0x10]
 16b:	c4 c1 72 58 08       	vaddss xmm1,xmm1,DWORD PTR [r8]
 170:	c4 c1 7a 11 08       	vmovss DWORD PTR [r8],xmm1
 175:	4c 8d 40 05          	lea    r8,[rax+0x5]
 179:	49 39 d0             	cmp    r8,rdx
 17c:	72 22                	jb     1a0 <void axpy<float>(float, float const*, float*, unsigned long)+0x1a0>
 17e:	66 90                	xchg   ax,ax
 180:	c5 f8 77             	vzeroupper
 183:	c3                   	ret
 184:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 18b:	00 00 00 00 
 18f:	90                   	nop
 190:	31 c0                	xor    eax,eax
 192:	e9 99 fe ff ff       	jmp    30 <void axpy<float>(float, float const*, float*, unsigned long)+0x30>
 197:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
 19e:	00 00 
 1a0:	c5 fa 59 4c 37 14    	vmulss xmm1,xmm0,DWORD PTR [rdi+rsi*1+0x14]
 1a6:	4c 8d 44 31 14       	lea    r8,[rcx+rsi*1+0x14]
 1ab:	48 83 c0 06          	add    rax,0x6
 1af:	c4 c1 72 58 08       	vaddss xmm1,xmm1,DWORD PTR [r8]
 1b4:	c4 c1 7a 11 08       	vmovss DWORD PTR [r8],xmm1
 1b9:	48 39 d0             	cmp    rax,rdx
 1bc:	73 c2                	jae    180 <void axpy<float>(float, float const*, float*, unsigned long)+0x180>
 1be:	c5 fa 59 44 37 18    	vmulss xmm0,xmm0,DWORD PTR [rdi+rsi*1+0x18]
 1c4:	48 8d 44 31 18       	lea    rax,[rcx+rsi*1+0x18]
 1c9:	c5 fa 58 00          	vaddss xmm0,xmm0,DWORD PTR [rax]
 1cd:	c5 fa 11 00          	vmovss DWORD PTR [rax],xmm0
 1d1:	c5 f8 77             	vzeroupper
 1d4:	c3                   	ret
 1d5:	48 89 d6             	mov    rsi,rdx
 1d8:	31 c0                	xor    eax,eax
 1da:	e9 cf fe ff ff       	jmp    ae <void axpy<float>(float, float const*, float*, unsigned long)+0xae>

Disassembly of section .text._Z4axpyIdEvT_PKS0_PS0_m:

0000000000000000 <void axpy<double>(double, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f1             	mov    rcx,rsi
   7:	48 85 d2             	test   rdx,rdx
   a:	74 47                	je     53 <void axpy<double>(double, double const*, double*, unsigned long)+0x53>
   c:	48 8d 72 ff          	lea    rsi,[rdx-0x1]
  10:	48 83 fe 02          	cmp    rsi,0x2
  14:	0f 86 36 01 00 00    	jbe    150 <void axpy<double>(double, double const*, double*, unsigned long)+0x150>
  1a:	48 8d 47 08          	lea    rax,[rdi+0x8]
  1e:	49 89 c8             	mov    r8,rcx
  21:	49 29 c0             	sub    r8,rax
  24:	31 c0                	xor    eax,eax
  26:	49 83 f8 30          	cmp    r8,0x30
  2a:	77 34                	ja     60 <void axpy<double>(double, double const*, double*, unsigned long)+0x60>
  2c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  30:	c5 fb 59 0c c7       	vmulsd xmm1,xmm0,QWORD PTR [rdi+rax*8]
  35:	c5 f3 58 0c c1       	vaddsd xmm1,xmm1,QWORD PTR [rcx+rax*8]
  3a:	c5 fb 11 0c c1       	vmovsd QWORD PTR [rcx+rax*8],xmm1
  3f:	48 ff c0             	inc    rax
  42:	48 39 c2             	cmp    rdx,rax
  45:	75 e9                	jne    30 <void axpy<double>(double, double const*, double*, unsigned long)+0x30>
  47:	c3                   	ret
  48:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  4f:	00 
  50:	c5 f8 77             	vzeroupper
  53:	c3                   	ret
  54:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  5b:	00 00 00 00 
  5f:	90                   	nop
  60:	48 83 fe 06          	cmp    rsi,0x6
  64:	0f 86 ed 00 00 00    	jbe    157 <void axpy<double>(double, double const*, double*, unsigned long)+0x157>
  6a:	48 89 d6             	mov    rsi,rdx
  6d:	62 f2 fd 48 19 d0    	vbroadcastsd zmm2,xmm0
  73:	48 c1 ee 03          	shr    rsi,0x3
  77:	48 c1 e6 06          	shl    rsi,0x6
  7b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  80:	62 f1 ed 48 59 0c 07 	vmulpd zmm1,zmm2,ZMMWORD PTR [rdi+rax*1]
  87:	62 f1 f5 48 58 0c 01 	vaddpd zmm1,zmm1,ZMMWORD PTR [rcx+rax*1]
  8e:	62 f1 fd 48 11 0c 01 	vmovupd ZMMWORD PTR [rcx+rax*1],zmm1
  95:	48 83 c0 40          	add    rax,0x40
  99:	48 39 f0             	cmp    rax,rsi
  9c:	75 e2                	jne    80 <void axpy<double>(double, double const*, double*, unsigned long)+0x80>
  9e:	48 89 d0             	mov    rax,rdx
  a1:	48 83 e0 f8          	and    rax,0xfffffffffffffff8
  a5:	f6 c2 07             	test   dl,0x7
  a8:	74 a6                	je     50 <void axpy<double>(double, double const*, double*, unsigned long)+0x50>
  aa:	48 89 d6             	mov    rsi,rdx
  ad:	48 29 c6             	sub    rsi,rax
  b0:	4c 8d 46 ff          	lea    r8,[rsi-0x1]
  b4:	49 83 f8 02          	cmp    r8,0x2
  b8:	76 34                	jbe    ee <void axpy<double>(double, double const*, double*, unsigned long)+0xee>
  ba:	4c 8d 0c c5 00 00 00 	lea    r9,[rax*8+0x0]
  c1:	00 
  c2:	c4 e2 7d 19 c8       	vbroadcastsd ymm1,xmm0
  c7:	4e 8d 04 09          	lea    r8,[rcx+r9*1]
  cb:	c4 a1 75 59 0c 0f    	vmulpd ymm1,ymm1,YMMWORD PTR [rdi+r9*1]
  d1:	c4 c1 75 58 08       	vaddpd ymm1,ymm1,YMMWORD PTR [r8]
  d6:	c4 c1 7d 11 08       	vmovupd YMMWORD PTR [r8],ymm1
  db:	49 89 f0             	mov    r8,rsi
  de:	49 83 e0 fc          	and    r8,0xfffffffffffffffc
  e2:	4c 01 c0             	add    rax,r8
  e5:	83 e6 03             	and    esi,0x3
  e8:	0f 84 62 ff ff ff    	je     50 <void axpy<double>(double, double const*, double*, unsigned long)+0x50>
  ee:	48 8d 34 c5 00 00 00 	lea    rsi,[rax*8+0x0]
  f5:	00 
  f6:	4c 8d 04 31          	lea    r8,[rcx+rsi*1]
  fa:	c5 fb 59 0c 37       	vmulsd xmm1,xmm0,QWORD PTR [rdi+rsi*1]
  ff:	c4 c1 73 58 08       	vaddsd xmm1,xmm1,QWORD PTR [r8]
 104:	c4 c1 7b 11 08       	vmovsd QWORD PTR [r8],xmm1
 109:	4c 8d 40 01          	lea    r8,[rax+0x1]
 10d:	49 39 d0             	cmp    r8,rdx
 110:	0f 83 3a ff ff ff    	jae    50 <void axpy<double>(double, double const*, double*, unsigned long)+0x50>
 116:	4c 8d 44 31 08       	lea    r8,[rcx+rsi*1+0x8]
 11b:	48 83 c0 02          	add    rax,0x2
 11f:	c5 fb 59 4c 37 08    	vmulsd xmm1,xmm0,QWORD PTR [rdi+rsi*1+0x8]
 125:	c4 c1 73 58 08       	vaddsd xmm1,xmm1,QWORD PTR [r8]
 12a:	c4 c1 7b 11 08       	vmovsd QWORD PTR [r8],xmm1
 12f:	48 39 d0             	cmp    rax,rdx
 132:	0f 83 18 ff ff ff    	jae    50 <void axpy<double>(double, double const*, double*, unsigned long)+0x50>
 138:	48 8d 44 31 10       	lea    rax,[rcx+rsi*1+0x10]
 13d:	c5 fb 59 44 37 10    	vmulsd xmm0,xmm0,QWORD PTR [rdi+rsi*1+0x10]
 143:	c5 fb 58 00          	vaddsd xmm0,xmm0,QWORD PTR [rax]
 147:	c5 fb 11 00          	vmovsd QWORD PTR [rax],xmm0
 14b:	c5 f8 77             	vzeroupper
 14e:	c3                   	ret
 14f:	90                   	nop
 150:	31 c0                	xor    eax,eax
 152:	e9 d9 fe ff ff       	jmp    30 <void axpy<double>(double, double const*, double*, unsigned long)+0x30>
 157:	48 89 d6             	mov    rsi,rdx
 15a:	31 c0                	xor    eax,eax
 15c:	e9 59 ff ff ff       	jmp    ba <void axpy<double>(double, double const*, double*, unsigned long)+0xba>

Disassembly of section .text._Z8multiplyIfEvPKT_S2_PS0_m:

0000000000000000 <void multiply<float>(float const*, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	0f 84 d6 01 00 00    	je     1e3 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e3>
   d:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  11:	48 83 f8 06          	cmp    rax,0x6
  15:	0f 86 95 01 00 00    	jbe    1b0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1b0>
  1b:	4c 8d 4f 04          	lea    r9,[rdi+0x4]
  1f:	49 89 d0             	mov    r8,rdx
  22:	4d 29 c8             	sub    r8,r9
  25:	49 83 f8 38          	cmp    r8,0x38
  29:	0f 86 81 01 00 00    	jbe    1b0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1b0>
  2f:	4c 8d 4e 04          	lea    r9,[rsi+0x4]
  33:	49 89 d0             	mov    r8,rdx
  36:	4d 29 c8             	sub    r8,r9
  39:	49 83 f8 38          	cmp    r8,0x38
  3d:	0f 86 6d 01 00 00    	jbe    1b0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1b0>
  43:	48 83 f8 0e          	cmp    rax,0xe
  47:	0f 86 97 01 00 00    	jbe    1e4 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e4>
  4d:	49 89 c8             	mov    r8,rcx
  50:	31 c0                	xor    eax,eax
  52:	49 c1 e8 04          	shr    r8,0x4
  56:	49 c1 e0 06          	shl    r8,0x6
  5a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  60:	62 f1 7c 48 10 0c 07 	vmovups zmm1,ZMMWORD PTR [rdi+rax*1]
  67:	62 f1 74 48 59 04 06 	vmulps zmm0,zmm1,ZMMWORD PTR [rsi+rax*1]
  6e:	62 f1 7c 48 11 04 02 	vmovups ZMMWORD PTR [rdx+rax*1],zmm0
  75:	48 83 c0 40          	add    rax,0x40
  79:	4c 39 c0             	cmp    rax,r8
  7c:	75 e2                	jne    60 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x60>
  7e:	48 89 c8             	mov    rax,rcx
  81:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  85:	f6 c1 0f             	test   cl,0xf
  88:	0f 84 52 01 00 00    	je     1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
  8e:	49 89 c9             	mov    r9,rcx
  91:	49 29 c1             	sub    r9,rax
  94:	4d 8d 41 ff          	lea    r8,[r9-0x1]
  98:	49 83 f8 06          	cmp    r8,0x6
  9c:	76 2e                	jbe    cc <void multiply<float>(float const*, float const*, float*, unsigned long)+0xcc>
  9e:	4c 8d 04 85 00 00 00 	lea    r8,[rax*4+0x0]
  a5:	00 
  a6:	c4 a1 7c 10 14 07    	vmovups ymm2,YMMWORD PTR [rdi+r8*1]
  ac:	c4 a1 6c 59 04 06    	vmulps ymm0,ymm2,YMMWORD PTR [rsi+r8*1]
  b2:	c4 a1 7c 11 04 02    	vmovups YMMWORD PTR [rdx+r8*1],ymm0
  b8:	4d 89 c8             	mov    r8,r9
  bb:	49 83 e0 f8          	and    r8,0xfffffffffffffff8
  bf:	4c 01 c0             	add    rax,r8
  c2:	41 83 e1 07          	and    r9d,0x7
  c6:	0f 84 14 01 00 00    	je     1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
  cc:	4c 8d 04 85 00 00 00 	lea    r8,[rax*4+0x0]
  d3:	00 
  d4:	4c 8d 48 01          	lea    r9,[rax+0x1]
  d8:	c4 a1 7a 10 04 07    	vmovss xmm0,DWORD PTR [rdi+r8*1]
  de:	c4 a1 7a 59 04 06    	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1]
  e4:	c4 a1 7a 11 04 02    	vmovss DWORD PTR [rdx+r8*1],xmm0
  ea:	49 39 c9             	cmp    r9,rcx
  ed:	0f 83 ed 00 00 00    	jae    1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
  f3:	c4 a1 7a 10 44 07 04 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x4]
  fa:	c4 a1 7a 59 44 06 04 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x4]
 101:	4c 8d 48 02          	lea    r9,[rax+0x2]
 105:	c4 a1 7a 11 44 02 04 	vmovss DWORD PTR [rdx+r8*1+0x4],xmm0
 10c:	49 39 c9             	cmp    r9,rcx
 10f:	0f 83 cb 00 00 00    	jae    1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 115:	c4 a1 7a 10 44 07 08 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x8]
 11c:	c4 a1 7a 59 44 06 08 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x8]
 123:	4c 8d 48 03          	lea    r9,[rax+0x3]
 127:	c4 a1 7a 11 44 02 08 	vmovss DWORD PTR [rdx+r8*1+0x8],xmm0
 12e:	49 39 c9             	cmp    r9,rcx
 131:	0f 83 a9 00 00 00    	jae    1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 137:	c4 a1 7a 10 44 07 0c 	vmovss xmm0,DWORD PTR [rdi+r8*1+0xc]
 13e:	c4 a1 7a 59 44 06 0c 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0xc]
 145:	4c 8d 48 04          	lea    r9,[rax+0x4]
 149:	c4 a1 7a 11 44 02 0c 	vmovss DWORD PTR [rdx+r8*1+0xc],xmm0
 150:	49 39 c9             	cmp    r9,rcx
 153:	0f 83 87 00 00 00    	jae    1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 159:	c4 a1 7a 10 44 07 10 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x10]
 160:	c4 a1 7a 59 44 06 10 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x10]
 167:	4c 8d 48 05          	lea    r9,[rax+0x5]
 16b:	c4 a1 7a 11 44 02 10 	vmovss DWORD PTR [rdx+r8*1+0x10],xmm0
 172:	49 39 c9             	cmp    r9,rcx
 175:	73 69                	jae    1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 177:	c4 a1 7a 10 44 07 14 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x14]
 17e:	c4 a1 7a 59 44 06 14 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x14]
 185:	48 83 c0 06          	add    rax,0x6
 189:	c4 a1 7a 11 44 02 14 	vmovss DWORD PTR [rdx+r8*1+0x14],xmm0
 190:	48 39 c8             	cmp    rax,rcx
 193:	73 4b                	jae    1e0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1e0>
 195:	c4 a1 7a 10 44 07 18 	vmovss xmm0,DWORD PTR [rdi+r8*1+0x18]
 19c:	c4 a1 7a 59 44 06 18 	vmulss xmm0,xmm0,DWORD PTR [rsi+r8*1+0x18]
 1a3:	c4 a1 7a 11 44 02 18 	vmovss DWORD PTR [rdx+r8*1+0x18],xmm0
 1aa:	c5 f8 77             	vzeroupper
 1ad:	c3                   	ret
 1ae:	66 90                	xchg   ax,ax
 1b0:	31 c0                	xor    eax,eax
 1b2:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 1b9:	00 00 00 00 
 1bd:	0f 1f 00             	nop    DWORD PTR [rax]
 1c0:	c5 fa 10 04 87       	vmovss xmm0,DWORD PTR [rdi+rax*4]
 1c5:	c5 fa 59 04 86       	vmulss xmm0,xmm0,DWORD PTR [rsi+rax*4]
 1ca:	c5 fa 11 04 82       	vmovss DWORD PTR [rdx+rax*4],xmm0
 1cf:	48 ff c0             	inc    rax
 1d2:	48 39 c1             	cmp    rcx,rax
 1d5:	75 e9                	jne    1c0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x1c0>
 1d7:	c3                   	ret
 1d8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 1df:	00 
 1e0:	c5 f8 77             	vzeroupper
 1e3:	c3                   	ret
 1e4:	49 89 c9             	mov    r9,rcx
 1e7:	31 c0                	xor    eax,eax
 1e9:	e9 b0 fe ff ff       	jmp    9e <void multiply<float>(float const*, float const*, float*, unsigned long)+0x9e>

Disassembly of section .text._Z8multiplyIdEvPKT_S2_PS0_m:

0000000000000000 <void multiply<double>(double const*, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	0f 84 56 01 00 00    	je     163 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x163>
   d:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  11:	48 83 f8 02          	cmp    rax,0x2
  15:	0f 86 15 01 00 00    	jbe    130 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x130>
  1b:	4c 8d 4f 08          	lea    r9,[rdi+0x8]
  1f:	49 89 d0             	mov    r8,rdx
  22:	4d 29 c8             	sub    r8,r9
  25:	49 83 f8 30          	cmp    r8,0x30
  29:	0f 86 01 01 00 00    	jbe    130 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x130>
  2f:	4c 8d 4e 08          	lea    r9,[rsi+0x8]
  33:	49 89 d0             	mov    r8,rdx
  36:	4d 29 c8             	sub    r8,r9
  39:	49 83 f8 30          	cmp    r8,0x30
  3d:	0f 86 ed 00 00 00    	jbe    130 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x130>
  43:	48 83 f8 06          	cmp    rax,0x6
  47:	0f 86 17 01 00 00    	jbe    164 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x164>
  4d:	49 89 c8             	mov    r8,rcx
  50:	31 c0                	xor    eax,eax
  52:	49 c1 e8 03          	shr    r8,0x3
  56:	49 c1 e0 06          	shl    r8,0x6
  5a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  60:	62 f1 fd 48 10 0c 07 	vmovupd zmm1,ZMMWORD PTR [rdi+rax*1]
  67:	62 f1 f5 48 59 04 06 	vmulpd zmm0,zmm1,ZMMWORD PTR [rsi+rax*1]
  6e:	62 f1 fd 48 11 04 02 	vmovupd ZMMWORD PTR [rdx+rax*1],zmm0
  75:	48 83 c0 40          	add    rax,0x40
  79:	4c 39 c0             	cmp    rax,r8
  7c:	75 e2                	jne    60 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x60>
  7e:	48 89 c8             	mov    rax,rcx
  81:	48 83 e0 f8          	and    rax,0xfffffffffffffff8
  85:	f6 c1 07             	test   cl,0x7
  88:	0f 84 d2 00 00 00    	je     160 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x160>
  8e:	49 89 c9             	mov    r9,rcx
  91:	49 29 c1             	sub    r9,rax
  94:	4d 8d 41 ff          	lea    r8,[r9-0x1]
  98:	49 83 f8 02          	cmp    r8,0x2
  9c:	76 2e                	jbe    cc <void multiply<double>(double const*, double const*, double*, unsigned long)+0xcc>
  9e:	4c 8d 04 c5 00 00 00 	lea    r8,[rax*8+0x0]
  a5:	00 
  a6:	c4 a1 7d 10 14 07    	vmovupd ymm2,YMMWORD PTR [rdi+r8*1]
  ac:	c4 a1 6d 59 04 06    	vmulpd ymm0,ymm2,YMMWORD PTR [rsi+r8*1]
  b2:	c4 a1 7d 11 04 02    	vmovupd YMMWORD PTR [rdx+r8*1],ymm0
  b8:	4d 89 c8             	mov    r8,r9
  bb:	49 83 e0 fc          	and    r8,0xfffffffffffffffc
  bf:	4c 01 c0             	add    rax,r8
  c2:	41 83 e1 03          	and    r9d,0x3
  c6:	0f 84 94 00 00 00    	je     160 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x160>
  cc:	4c 8d 04 c5 00 00 00 	lea    r8,[rax*8+0x0]
  d3:	00 
  d4:	4c 8d 48 01          	lea    r9,[rax+0x1]
  d8:	c4 a1 7b 10 04 07    	vmovsd xmm0,QWORD PTR [rdi+r8*1]
  de:	c4 a1 7b 59 04 06    	vmulsd xmm0,xmm0,QWORD PTR [rsi+r8*1]
  e4:	c4 a1 7b 11 04 02    	vmovsd QWORD PTR [rdx+r8*1],xmm0
  ea:	49 39 c9             	cmp    r9,rcx
  ed:	73 71                	jae    160 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x160>
  ef:	48 83 c0 02          	add    rax,0x2
  f3:	c4 a1 7b 10 44 07 08 	vmovsd xmm0,QWORD PTR [rdi+r8*1+0x8]
  fa:	c4 a1 7b 59 44 06 08 	vmulsd xmm0,xmm0,QWORD PTR [rsi+r8*1+0x8]
 101:	c4 a1 7b 11 44 02 08 	vmovsd QWORD PTR [rdx+r8*1+0x8],xmm0
 108:	48 39 c8             	cmp    rax,rcx
 10b:	73 53                	jae    160 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x160>
 10d:	c4 a1 7b 10 44 07 10 	vmovsd xmm0,QWORD PTR [rdi+r8*1+0x10]
 114:	c4 a1 7b 59 44 06 10 	vmulsd xmm0,xmm0,QWORD PTR [rsi+r8*1+0x10]
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
 145:	c5 fb 59 04 c6       	vmulsd xmm0,xmm0,QWORD PTR [rsi+rax*8]
 14a:	c5 fb 11 04 c2       	vmovsd QWORD PTR [rdx+rax*8],xmm0
 14f:	48 ff c0             	inc    rax
 152:	48 39 c1             	cmp    rcx,rax
 155:	75 e9                	jne    140 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x140>
 157:	c3                   	ret
 158:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
 15f:	00 
 160:	c5 f8 77             	vzeroupper
 163:	c3                   	ret
 164:	49 89 c9             	mov    r9,rcx
 167:	31 c0                	xor    eax,eax
 169:	e9 30 ff ff ff       	jmp    9e <void multiply<double>(double const*, double const*, double*, unsigned long)+0x9e>

Disassembly of section .text._Z3dotIfET_PKS0_S2_m:

0000000000000000 <float dot<float>(float const*, float const*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f1             	mov    rcx,rsi
   7:	48 85 d2             	test   rdx,rdx
   a:	0f 84 30 02 00 00    	je     240 <float dot<float>(float const*, float const*, unsigned long)+0x240>
  10:	48 8d 42 ff          	lea    rax,[rdx-0x1]
  14:	48 83 f8 0e          	cmp    rax,0xe
  18:	0f 86 27 02 00 00    	jbe    245 <float dot<float>(float const*, float const*, unsigned long)+0x245>
  1e:	48 89 d6             	mov    rsi,rdx
  21:	31 c0                	xor    eax,eax
  23:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
  27:	48 c1 ee 04          	shr    rsi,0x4
  2b:	48 c1 e6 06          	shl    rsi,0x6
  2f:	90                   	nop
  30:	62 f1 7c 48 10 2c 07 	vmovups zmm5,ZMMWORD PTR [rdi+rax*1]
  37:	62 f1 54 48 59 0c 01 	vmulps zmm1,zmm5,ZMMWORD PTR [rcx+rax*1]
  3e:	48 83 c0 40          	add    rax,0x40
  42:	c5 f0 c6 e1 55       	vshufps xmm4,xmm1,xmm1,0x55
  47:	c5 f0 c6 d9 ff       	vshufps xmm3,xmm1,xmm1,0xff
  4c:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
  50:	62 f3 75 28 03 d1 07 	valignd ymm2,ymm1,ymm1,0x7
  57:	c5 fa 58 c4          	vaddss xmm0,xmm0,xmm4
  5b:	c5 f0 15 e1          	vunpckhps xmm4,xmm1,xmm1
  5f:	c5 fa 58 c4          	vaddss xmm0,xmm0,xmm4
  63:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
  67:	62 f3 7d 28 19 cb 01 	vextractf32x4 xmm3,ymm1,0x1
  6e:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
  72:	62 f3 75 28 03 d9 05 	valignd ymm3,ymm1,ymm1,0x5
  79:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
  7d:	62 f3 75 28 03 d9 06 	valignd ymm3,ymm1,ymm1,0x6
  84:	62 f3 7d 48 1b c9 01 	vextractf32x8 ymm1,zmm1,0x1
  8b:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
  8f:	c5 f0 c6 d9 55       	vshufps xmm3,xmm1,xmm1,0x55
  94:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
  98:	c5 f0 c6 d1 ff       	vshufps xmm2,xmm1,xmm1,0xff
  9d:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
  a1:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
  a5:	c5 f0 15 d9          	vunpckhps xmm3,xmm1,xmm1
  a9:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
  ad:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
  b1:	62 f3 7d 28 19 ca 01 	vextractf32x4 xmm2,ymm1,0x1
  b8:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
  bc:	62 f3 75 28 03 d1 05 	valignd ymm2,ymm1,ymm1,0x5
  c3:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
  c7:	62 f3 75 28 03 d1 06 	valignd ymm2,ymm1,ymm1,0x6
  ce:	62 f3 75 28 03 c9 07 	valignd ymm1,ymm1,ymm1,0x7
  d5:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
  d9:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
  dd:	48 39 c6             	cmp    rsi,rax
  e0:	0f 85 4a ff ff ff    	jne    30 <float dot<float>(float const*, float const*, unsigned long)+0x30>
  e6:	48 89 d0             	mov    rax,rdx
  e9:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  ed:	f6 c2 0f             	test   dl,0xf
  f0:	0f 84 3a 01 00 00    	je     230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
  f6:	48 89 d6             	mov    rsi,rdx
  f9:	48 29 c6             	sub    rsi,rax
  fc:	4c 8d 46 ff          	lea    r8,[rsi-0x1]
 100:	49 83 f8 06          	cmp    r8,0x6
 104:	76 67                	jbe    16d <float dot<float>(float const*, float const*, unsigned long)+0x16d>
 106:	c5 fc 10 34 87       	vmovups ymm6,YMMWORD PTR [rdi+rax*4]
 10b:	c5 cc 59 0c 81       	vmulps ymm1,ymm6,YMMWORD PTR [rcx+rax*4]
 110:	49 89 f0             	mov    r8,rsi
 113:	49 83 e0 f8          	and    r8,0xfffffffffffffff8
 117:	4c 01 c0             	add    rax,r8
 11a:	83 e6 07             	and    esi,0x7
 11d:	c5 f0 c6 d9 55       	vshufps xmm3,xmm1,xmm1,0x55
 122:	c5 f0 c6 d1 ff       	vshufps xmm2,xmm1,xmm1,0xff
 127:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 12b:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
 12f:	c5 f0 15 d9          	vunpckhps xmm3,xmm1,xmm1
 133:	c5 fa 58 c3          	vaddss xmm0,xmm0,xmm3
 137:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
 13b:	62 f3 7d 28 19 ca 01 	vextractf32x4 xmm2,ymm1,0x1
 142:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
 146:	62 f3 75 28 03 d1 05 	valignd ymm2,ymm1,ymm1,0x5
 14d:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
 151:	62 f3 75 28 03 d1 06 	valignd ymm2,ymm1,ymm1,0x6
 158:	62 f3 75 28 03 c9 07 	valignd ymm1,ymm1,ymm1,0x7
 15f:	c5 fa 58 c2          	vaddss xmm0,xmm0,xmm2
 163:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 167:	0f 84 c3 00 00 00    	je     230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 16d:	48 8d 34 85 00 00 00 	lea    rsi,[rax*4+0x0]
 174:	00 
 175:	4c 8d 40 01          	lea    r8,[rax+0x1]
 179:	c5 fa 10 0c 37       	vmovss xmm1,DWORD PTR [rdi+rsi*1]
 17e:	c5 f2 59 0c 31       	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1]
 183:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 187:	49 39 d0             	cmp    r8,rdx
 18a:	0f 83 a0 00 00 00    	jae    230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 190:	c5 fa 10 4c 37 04    	vmovss xmm1,DWORD PTR [rdi+rsi*1+0x4]
 196:	c5 f2 59 4c 31 04    	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1+0x4]
 19c:	4c 8d 40 02          	lea    r8,[rax+0x2]
 1a0:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 1a4:	49 39 d0             	cmp    r8,rdx
 1a7:	0f 83 83 00 00 00    	jae    230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 1ad:	c5 fa 10 4c 37 08    	vmovss xmm1,DWORD PTR [rdi+rsi*1+0x8]
 1b3:	c5 f2 59 4c 31 08    	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1+0x8]
 1b9:	4c 8d 40 03          	lea    r8,[rax+0x3]
 1bd:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 1c1:	49 39 d0             	cmp    r8,rdx
 1c4:	73 6a                	jae    230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 1c6:	c5 fa 10 4c 37 0c    	vmovss xmm1,DWORD PTR [rdi+rsi*1+0xc]
 1cc:	c5 f2 59 4c 31 0c    	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1+0xc]
 1d2:	4c 8d 40 04          	lea    r8,[rax+0x4]
 1d6:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 1da:	49 39 d0             	cmp    r8,rdx
 1dd:	73 51                	jae    230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 1df:	c5 fa 10 4c 37 10    	vmovss xmm1,DWORD PTR [rdi+rsi*1+0x10]
 1e5:	c5 f2 59 4c 31 10    	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1+0x10]
 1eb:	4c 8d 40 05          	lea    r8,[rax+0x5]
 1ef:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 1f3:	49 39 d0             	cmp    r8,rdx
 1f6:	73 38                	jae    230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 1f8:	c5 fa 10 4c 37 14    	vmovss xmm1,DWORD PTR [rdi+rsi*1+0x14]
 1fe:	c5 f2 59 4c 31 14    	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1+0x14]
 204:	48 83 c0 06          	add    rax,0x6
 208:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 20c:	48 39 d0             	cmp    rax,rdx
 20f:	73 1f                	jae    230 <float dot<float>(float const*, float const*, unsigned long)+0x230>
 211:	c5 fa 10 4c 37 18    	vmovss xmm1,DWORD PTR [rdi+rsi*1+0x18]
 217:	c5 f2 59 4c 31 18    	vmulss xmm1,xmm1,DWORD PTR [rcx+rsi*1+0x18]
 21d:	c5 fa 58 c1          	vaddss xmm0,xmm0,xmm1
 221:	c5 f8 77             	vzeroupper
 224:	c3                   	ret
 225:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 22c:	00 00 00 00 
 230:	c5 f8 77             	vzeroupper
 233:	c3                   	ret
 234:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 23b:	00 00 00 00 
 23f:	90                   	nop
 240:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
 244:	c3                   	ret
 245:	31 c0                	xor    eax,eax
 247:	c5 f8 57 c0          	vxorps xmm0,xmm0,xmm0
 24b:	e9 a6 fe ff ff       	jmp    f6 <float dot<float>(float const*, float const*, unsigned long)+0xf6>

Disassembly of section .text._Z3dotIdET_PKS0_S2_m:

0000000000000000 <double dot<double>(double const*, double const*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f1             	mov    rcx,rsi
   7:	48 85 d2             	test   rdx,rdx
   a:	0f 84 40 01 00 00    	je     150 <double dot<double>(double const*, double const*, unsigned long)+0x150>
  10:	48 8d 42 ff          	lea    rax,[rdx-0x1]
  14:	48 83 f8 06          	cmp    rax,0x6
  18:	0f 86 37 01 00 00    	jbe    155 <double dot<double>(double const*, double const*, unsigned long)+0x155>
  1e:	48 89 d6             	mov    rsi,rdx
  21:	31 c0                	xor    eax,eax
  23:	c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
  27:	48 c1 ee 03          	shr    rsi,0x3
  2b:	48 c1 e6 06          	shl    rsi,0x6
  2f:	90                   	nop
  30:	62 f1 fd 48 10 2c 07 	vmovupd zmm5,ZMMWORD PTR [rdi+rax*1]
  37:	62 f1 d5 48 59 0c 01 	vmulpd zmm1,zmm5,ZMMWORD PTR [rcx+rax*1]
  3e:	48 83 c0 40          	add    rax,0x40
  42:	62 f3 f5 28 03 d1 03 	valignq ymm2,ymm1,ymm1,0x3
  49:	c5 f1 15 d9          	vunpckhpd xmm3,xmm1,xmm1
  4d:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  51:	c5 fb 58 c3          	vaddsd xmm0,xmm0,xmm3
  55:	62 f3 fd 28 19 cb 01 	vextractf64x2 xmm3,ymm1,0x1
  5c:	62 f3 fd 48 1b c9 01 	vextractf64x4 ymm1,zmm1,0x1
  63:	c5 fb 58 c3          	vaddsd xmm0,xmm0,xmm3
  67:	c5 fb 58 c2          	vaddsd xmm0,xmm0,xmm2
  6b:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
  6f:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  73:	c5 fb 58 c2          	vaddsd xmm0,xmm0,xmm2
  77:	62 f3 fd 28 19 ca 01 	vextractf64x2 xmm2,ymm1,0x1
  7e:	62 f3 f5 28 03 c9 03 	valignq ymm1,ymm1,ymm1,0x3
  85:	c5 fb 58 c2          	vaddsd xmm0,xmm0,xmm2
  89:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  8d:	48 39 c6             	cmp    rsi,rax
  90:	75 9e                	jne    30 <double dot<double>(double const*, double const*, unsigned long)+0x30>
  92:	48 89 d0             	mov    rax,rdx
  95:	48 83 e0 f8          	and    rax,0xfffffffffffffff8
  99:	f6 c2 07             	test   dl,0x7
  9c:	0f 84 9e 00 00 00    	je     140 <double dot<double>(double const*, double const*, unsigned long)+0x140>
  a2:	48 89 d6             	mov    rsi,rdx
  a5:	48 29 c6             	sub    rsi,rax
  a8:	4c 8d 46 ff          	lea    r8,[rsi-0x1]
  ac:	49 83 f8 02          	cmp    r8,0x2
  b0:	76 3b                	jbe    ed <double dot<double>(double const*, double const*, unsigned long)+0xed>
  b2:	c5 fd 10 34 c7       	vmovupd ymm6,YMMWORD PTR [rdi+rax*8]
  b7:	c5 cd 59 0c c1       	vmulpd ymm1,ymm6,YMMWORD PTR [rcx+rax*8]
  bc:	49 89 f0             	mov    r8,rsi
  bf:	49 83 e0 fc          	and    r8,0xfffffffffffffffc
  c3:	4c 01 c0             	add    rax,r8
  c6:	83 e6 03             	and    esi,0x3
  c9:	c5 f1 15 d1          	vunpckhpd xmm2,xmm1,xmm1
  cd:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  d1:	c5 fb 58 c2          	vaddsd xmm0,xmm0,xmm2
  d5:	62 f3 fd 28 19 ca 01 	vextractf64x2 xmm2,ymm1,0x1
  dc:	62 f3 f5 28 03 c9 03 	valignq ymm1,ymm1,ymm1,0x3
  e3:	c5 fb 58 c2          	vaddsd xmm0,xmm0,xmm2
  e7:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
  eb:	74 53                	je     140 <double dot<double>(double const*, double const*, unsigned long)+0x140>
  ed:	48 8d 34 c5 00 00 00 	lea    rsi,[rax*8+0x0]
  f4:	00 
  f5:	4c 8d 40 01          	lea    r8,[rax+0x1]
  f9:	c5 fb 10 0c 37       	vmovsd xmm1,QWORD PTR [rdi+rsi*1]
  fe:	c5 f3 59 0c 31       	vmulsd xmm1,xmm1,QWORD PTR [rcx+rsi*1]
 103:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 107:	49 39 d0             	cmp    r8,rdx
 10a:	73 34                	jae    140 <double dot<double>(double const*, double const*, unsigned long)+0x140>
 10c:	48 83 c0 02          	add    rax,0x2
 110:	c5 fb 10 4c 37 08    	vmovsd xmm1,QWORD PTR [rdi+rsi*1+0x8]
 116:	c5 f3 59 4c 31 08    	vmulsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x8]
 11c:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 120:	48 39 d0             	cmp    rax,rdx
 123:	73 1b                	jae    140 <double dot<double>(double const*, double const*, unsigned long)+0x140>
 125:	c5 fb 10 4c 37 10    	vmovsd xmm1,QWORD PTR [rdi+rsi*1+0x10]
 12b:	c5 f3 59 4c 31 10    	vmulsd xmm1,xmm1,QWORD PTR [rcx+rsi*1+0x10]
 131:	c5 fb 58 c1          	vaddsd xmm0,xmm0,xmm1
 135:	c5 f8 77             	vzeroupper
 138:	c3                   	ret
 139:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
 140:	c5 f8 77             	vzeroupper
 143:	c3                   	ret
 144:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
 14b:	00 00 00 00 
 14f:	90                   	nop
 150:	c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
 154:	c3                   	ret
 155:	31 c0                	xor    eax,eax
 157:	c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
 15b:	e9 42 ff ff ff       	jmp    a2 <double dot<double>(double const*, double const*, unsigned long)+0xa2>
