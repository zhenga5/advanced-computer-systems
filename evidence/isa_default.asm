
build/kernels_default.o:     file format elf64-x86-64


Disassembly of section .text._Z4axpyIfEvT_PKS0_PS0_m:

0000000000000000 <void axpy<float>(float, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f1             	mov    rcx,rsi
   7:	48 85 d2             	test   rdx,rdx
   a:	74 38                	je     44 <void axpy<float>(float, float const*, float*, unsigned long)+0x44>
   c:	48 83 fa 01          	cmp    rdx,0x1
  10:	0f 84 ca 00 00 00    	je     e0 <void axpy<float>(float, float const*, float*, unsigned long)+0xe0>
  16:	48 8d 47 04          	lea    rax,[rdi+0x4]
  1a:	48 29 c6             	sub    rsi,rax
  1d:	31 c0                	xor    eax,eax
  1f:	48 83 fe 08          	cmp    rsi,0x8
  23:	77 23                	ja     48 <void axpy<float>(float, float const*, float*, unsigned long)+0x48>
  25:	0f 1f 00             	nop    DWORD PTR [rax]
  28:	f3 0f 10 0c 87       	movss  xmm1,DWORD PTR [rdi+rax*4]
  2d:	f3 0f 59 c8          	mulss  xmm1,xmm0
  31:	f3 0f 58 0c 81       	addss  xmm1,DWORD PTR [rcx+rax*4]
  36:	f3 0f 11 0c 81       	movss  DWORD PTR [rcx+rax*4],xmm1
  3b:	48 83 c0 01          	add    rax,0x1
  3f:	48 39 c2             	cmp    rdx,rax
  42:	75 e4                	jne    28 <void axpy<float>(float, float const*, float*, unsigned long)+0x28>
  44:	c3                   	ret
  45:	0f 1f 00             	nop    DWORD PTR [rax]
  48:	48 8d 42 ff          	lea    rax,[rdx-0x1]
  4c:	48 83 f8 02          	cmp    rax,0x2
  50:	0f 86 91 00 00 00    	jbe    e7 <void axpy<float>(float, float const*, float*, unsigned long)+0xe7>
  56:	48 89 d6             	mov    rsi,rdx
  59:	0f 28 d0             	movaps xmm2,xmm0
  5c:	31 c0                	xor    eax,eax
  5e:	48 c1 ee 02          	shr    rsi,0x2
  62:	0f c6 d2 00          	shufps xmm2,xmm2,0x0
  66:	48 c1 e6 04          	shl    rsi,0x4
  6a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  70:	0f 10 0c 07          	movups xmm1,XMMWORD PTR [rdi+rax*1]
  74:	0f 10 1c 01          	movups xmm3,XMMWORD PTR [rcx+rax*1]
  78:	0f 59 ca             	mulps  xmm1,xmm2
  7b:	0f 58 cb             	addps  xmm1,xmm3
  7e:	0f 11 0c 01          	movups XMMWORD PTR [rcx+rax*1],xmm1
  82:	48 83 c0 10          	add    rax,0x10
  86:	48 39 f0             	cmp    rax,rsi
  89:	75 e5                	jne    70 <void axpy<float>(float, float const*, float*, unsigned long)+0x70>
  8b:	f6 c2 03             	test   dl,0x3
  8e:	74 b4                	je     44 <void axpy<float>(float, float const*, float*, unsigned long)+0x44>
  90:	48 89 d0             	mov    rax,rdx
  93:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  97:	48 29 c2             	sub    rdx,rax
  9a:	48 83 fa 01          	cmp    rdx,0x1
  9e:	74 29                	je     c9 <void axpy<float>(float, float const*, float*, unsigned long)+0xc9>
  a0:	f3 0f 7e 0c 87       	movq   xmm1,QWORD PTR [rdi+rax*4]
  a5:	0f 28 d0             	movaps xmm2,xmm0
  a8:	48 8d 34 81          	lea    rsi,[rcx+rax*4]
  ac:	0f c6 d2 e0          	shufps xmm2,xmm2,0xe0
  b0:	0f 59 ca             	mulps  xmm1,xmm2
  b3:	f3 0f 7e 16          	movq   xmm2,QWORD PTR [rsi]
  b7:	0f 58 ca             	addps  xmm1,xmm2
  ba:	0f 13 0e             	movlps QWORD PTR [rsi],xmm1
  bd:	f6 c2 01             	test   dl,0x1
  c0:	74 82                	je     44 <void axpy<float>(float, float const*, float*, unsigned long)+0x44>
  c2:	48 83 e2 fe          	and    rdx,0xfffffffffffffffe
  c6:	48 01 d0             	add    rax,rdx
  c9:	f3 0f 59 04 87       	mulss  xmm0,DWORD PTR [rdi+rax*4]
  ce:	48 8d 14 81          	lea    rdx,[rcx+rax*4]
  d2:	f3 0f 58 02          	addss  xmm0,DWORD PTR [rdx]
  d6:	f3 0f 11 02          	movss  DWORD PTR [rdx],xmm0
  da:	c3                   	ret
  db:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  e0:	31 c0                	xor    eax,eax
  e2:	e9 41 ff ff ff       	jmp    28 <void axpy<float>(float, float const*, float*, unsigned long)+0x28>
  e7:	31 c0                	xor    eax,eax
  e9:	eb b5                	jmp    a0 <void axpy<float>(float, float const*, float*, unsigned long)+0xa0>

Disassembly of section .text._Z4axpyIdEvT_PKS0_PS0_m:

0000000000000000 <void axpy<double>(double, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f9             	mov    rcx,rdi
   7:	48 85 d2             	test   rdx,rdx
   a:	74 38                	je     44 <void axpy<double>(double, double const*, double*, unsigned long)+0x44>
   c:	48 83 fa 01          	cmp    rdx,0x1
  10:	0f 84 8a 00 00 00    	je     a0 <void axpy<double>(double, double const*, double*, unsigned long)+0xa0>
  16:	48 8d 7f 08          	lea    rdi,[rdi+0x8]
  1a:	31 c0                	xor    eax,eax
  1c:	48 39 fe             	cmp    rsi,rdi
  1f:	75 27                	jne    48 <void axpy<double>(double, double const*, double*, unsigned long)+0x48>
  21:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  28:	f2 0f 10 0c c1       	movsd  xmm1,QWORD PTR [rcx+rax*8]
  2d:	f2 0f 59 c8          	mulsd  xmm1,xmm0
  31:	f2 0f 58 0c c6       	addsd  xmm1,QWORD PTR [rsi+rax*8]
  36:	f2 0f 11 0c c6       	movsd  QWORD PTR [rsi+rax*8],xmm1
  3b:	48 83 c0 01          	add    rax,0x1
  3f:	48 39 c2             	cmp    rdx,rax
  42:	75 e4                	jne    28 <void axpy<double>(double, double const*, double*, unsigned long)+0x28>
  44:	c3                   	ret
  45:	0f 1f 00             	nop    DWORD PTR [rax]
  48:	48 89 d7             	mov    rdi,rdx
  4b:	66 0f 28 d0          	movapd xmm2,xmm0
  4f:	48 d1 ef             	shr    rdi,1
  52:	66 0f 14 d2          	unpcklpd xmm2,xmm2
  56:	48 c1 e7 04          	shl    rdi,0x4
  5a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  60:	66 0f 10 0c 01       	movupd xmm1,XMMWORD PTR [rcx+rax*1]
  65:	66 0f 10 1c 06       	movupd xmm3,XMMWORD PTR [rsi+rax*1]
  6a:	66 0f 59 ca          	mulpd  xmm1,xmm2
  6e:	66 0f 58 cb          	addpd  xmm1,xmm3
  72:	0f 11 0c 06          	movups XMMWORD PTR [rsi+rax*1],xmm1
  76:	48 83 c0 10          	add    rax,0x10
  7a:	48 39 c7             	cmp    rdi,rax
  7d:	75 e1                	jne    60 <void axpy<double>(double, double const*, double*, unsigned long)+0x60>
  7f:	48 89 d7             	mov    rdi,rdx
  82:	48 83 e7 fe          	and    rdi,0xfffffffffffffffe
  86:	83 e2 01             	and    edx,0x1
  89:	74 b9                	je     44 <void axpy<double>(double, double const*, double*, unsigned long)+0x44>
  8b:	f2 0f 59 04 f9       	mulsd  xmm0,QWORD PTR [rcx+rdi*8]
  90:	48 8d 04 fe          	lea    rax,[rsi+rdi*8]
  94:	f2 0f 58 00          	addsd  xmm0,QWORD PTR [rax]
  98:	f2 0f 11 00          	movsd  QWORD PTR [rax],xmm0
  9c:	c3                   	ret
  9d:	0f 1f 00             	nop    DWORD PTR [rax]
  a0:	31 c0                	xor    eax,eax
  a2:	eb 84                	jmp    28 <void axpy<double>(double, double const*, double*, unsigned long)+0x28>

Disassembly of section .text._Z8multiplyIfEvPKT_S2_PS0_m:

0000000000000000 <void multiply<float>(float const*, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	49 89 f0             	mov    r8,rsi
   7:	48 85 c9             	test   rcx,rcx
   a:	0f 84 d1 00 00 00    	je     e1 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xe1>
  10:	48 83 f9 01          	cmp    rcx,0x1
  14:	0f 84 a6 00 00 00    	je     c0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xc0>
  1a:	48 8d 77 04          	lea    rsi,[rdi+0x4]
  1e:	48 89 d0             	mov    rax,rdx
  21:	48 29 f0             	sub    rax,rsi
  24:	48 83 f8 08          	cmp    rax,0x8
  28:	0f 86 92 00 00 00    	jbe    c0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xc0>
  2e:	49 8d 70 04          	lea    rsi,[r8+0x4]
  32:	48 89 d0             	mov    rax,rdx
  35:	48 29 f0             	sub    rax,rsi
  38:	48 83 f8 08          	cmp    rax,0x8
  3c:	0f 86 7e 00 00 00    	jbe    c0 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xc0>
  42:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  46:	48 83 f8 02          	cmp    rax,0x2
  4a:	0f 86 92 00 00 00    	jbe    e2 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xe2>
  50:	48 89 ce             	mov    rsi,rcx
  53:	31 c0                	xor    eax,eax
  55:	48 c1 ee 02          	shr    rsi,0x2
  59:	48 c1 e6 04          	shl    rsi,0x4
  5d:	0f 1f 00             	nop    DWORD PTR [rax]
  60:	0f 10 04 07          	movups xmm0,XMMWORD PTR [rdi+rax*1]
  64:	41 0f 10 14 00       	movups xmm2,XMMWORD PTR [r8+rax*1]
  69:	0f 59 c2             	mulps  xmm0,xmm2
  6c:	0f 11 04 02          	movups XMMWORD PTR [rdx+rax*1],xmm0
  70:	48 83 c0 10          	add    rax,0x10
  74:	48 39 f0             	cmp    rax,rsi
  77:	75 e7                	jne    60 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x60>
  79:	f6 c1 03             	test   cl,0x3
  7c:	74 63                	je     e1 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xe1>
  7e:	48 89 c8             	mov    rax,rcx
  81:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  85:	48 29 c1             	sub    rcx,rax
  88:	48 83 f9 01          	cmp    rcx,0x1
  8c:	74 1e                	je     ac <void multiply<float>(float const*, float const*, float*, unsigned long)+0xac>
  8e:	f3 0f 7e 04 87       	movq   xmm0,QWORD PTR [rdi+rax*4]
  93:	f3 41 0f 7e 0c 80    	movq   xmm1,QWORD PTR [r8+rax*4]
  99:	0f 59 c1             	mulps  xmm0,xmm1
  9c:	0f 13 04 82          	movlps QWORD PTR [rdx+rax*4],xmm0
  a0:	f6 c1 01             	test   cl,0x1
  a3:	74 3c                	je     e1 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xe1>
  a5:	48 83 e1 fe          	and    rcx,0xfffffffffffffffe
  a9:	48 01 c8             	add    rax,rcx
  ac:	f3 0f 10 04 87       	movss  xmm0,DWORD PTR [rdi+rax*4]
  b1:	f3 41 0f 59 04 80    	mulss  xmm0,DWORD PTR [r8+rax*4]
  b7:	f3 0f 11 04 82       	movss  DWORD PTR [rdx+rax*4],xmm0
  bc:	c3                   	ret
  bd:	0f 1f 00             	nop    DWORD PTR [rax]
  c0:	31 c0                	xor    eax,eax
  c2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  c8:	f3 0f 10 04 87       	movss  xmm0,DWORD PTR [rdi+rax*4]
  cd:	f3 41 0f 59 04 80    	mulss  xmm0,DWORD PTR [r8+rax*4]
  d3:	f3 0f 11 04 82       	movss  DWORD PTR [rdx+rax*4],xmm0
  d8:	48 83 c0 01          	add    rax,0x1
  dc:	48 39 c1             	cmp    rcx,rax
  df:	75 e7                	jne    c8 <void multiply<float>(float const*, float const*, float*, unsigned long)+0xc8>
  e1:	c3                   	ret
  e2:	31 c0                	xor    eax,eax
  e4:	eb a8                	jmp    8e <void multiply<float>(float const*, float const*, float*, unsigned long)+0x8e>

Disassembly of section .text._Z8multiplyIdEvPKT_S2_PS0_m:

0000000000000000 <void multiply<double>(double const*, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	49 89 f8             	mov    r8,rdi
   7:	48 89 f7             	mov    rdi,rsi
   a:	48 85 c9             	test   rcx,rcx
   d:	0f 84 8e 00 00 00    	je     a1 <void multiply<double>(double const*, double const*, double*, unsigned long)+0xa1>
  13:	48 8d 41 ff          	lea    rax,[rcx-0x1]
  17:	48 83 f8 01          	cmp    rax,0x1
  1b:	76 63                	jbe    80 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x80>
  1d:	48 8d 46 08          	lea    rax,[rsi+0x8]
  21:	48 39 c2             	cmp    rdx,rax
  24:	74 5a                	je     80 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x80>
  26:	49 8d 40 08          	lea    rax,[r8+0x8]
  2a:	48 39 c2             	cmp    rdx,rax
  2d:	74 51                	je     80 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x80>
  2f:	48 89 ce             	mov    rsi,rcx
  32:	31 c0                	xor    eax,eax
  34:	48 d1 ee             	shr    rsi,1
  37:	48 c1 e6 04          	shl    rsi,0x4
  3b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  40:	66 41 0f 10 04 00    	movupd xmm0,XMMWORD PTR [r8+rax*1]
  46:	66 0f 10 0c 07       	movupd xmm1,XMMWORD PTR [rdi+rax*1]
  4b:	66 0f 59 c1          	mulpd  xmm0,xmm1
  4f:	0f 11 04 02          	movups XMMWORD PTR [rdx+rax*1],xmm0
  53:	48 83 c0 10          	add    rax,0x10
  57:	48 39 f0             	cmp    rax,rsi
  5a:	75 e4                	jne    40 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x40>
  5c:	48 89 c8             	mov    rax,rcx
  5f:	48 83 e0 fe          	and    rax,0xfffffffffffffffe
  63:	83 e1 01             	and    ecx,0x1
  66:	74 39                	je     a1 <void multiply<double>(double const*, double const*, double*, unsigned long)+0xa1>
  68:	f2 41 0f 10 04 c0    	movsd  xmm0,QWORD PTR [r8+rax*8]
  6e:	f2 0f 59 04 c7       	mulsd  xmm0,QWORD PTR [rdi+rax*8]
  73:	f2 0f 11 04 c2       	movsd  QWORD PTR [rdx+rax*8],xmm0
  78:	c3                   	ret
  79:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  80:	31 c0                	xor    eax,eax
  82:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  88:	f2 41 0f 10 04 c0    	movsd  xmm0,QWORD PTR [r8+rax*8]
  8e:	f2 0f 59 04 c7       	mulsd  xmm0,QWORD PTR [rdi+rax*8]
  93:	f2 0f 11 04 c2       	movsd  QWORD PTR [rdx+rax*8],xmm0
  98:	48 83 c0 01          	add    rax,0x1
  9c:	48 39 c1             	cmp    rcx,rax
  9f:	75 e7                	jne    88 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x88>
  a1:	c3                   	ret

Disassembly of section .text._Z3dotIfET_PKS0_S2_m:

0000000000000000 <float dot<float>(float const*, float const*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 89 f9             	mov    rcx,rdi
   7:	48 85 d2             	test   rdx,rdx
   a:	0f 84 b0 00 00 00    	je     c0 <float dot<float>(float const*, float const*, unsigned long)+0xc0>
  10:	48 8d 42 ff          	lea    rax,[rdx-0x1]
  14:	48 83 f8 02          	cmp    rax,0x2
  18:	0f 86 a7 00 00 00    	jbe    c5 <float dot<float>(float const*, float const*, unsigned long)+0xc5>
  1e:	48 89 d7             	mov    rdi,rdx
  21:	31 c0                	xor    eax,eax
  23:	66 0f ef c0          	pxor   xmm0,xmm0
  27:	48 c1 ef 02          	shr    rdi,0x2
  2b:	48 c1 e7 04          	shl    rdi,0x4
  2f:	90                   	nop
  30:	0f 10 0c 01          	movups xmm1,XMMWORD PTR [rcx+rax*1]
  34:	0f 10 1c 06          	movups xmm3,XMMWORD PTR [rsi+rax*1]
  38:	48 83 c0 10          	add    rax,0x10
  3c:	0f 59 cb             	mulps  xmm1,xmm3
  3f:	f3 0f 58 c1          	addss  xmm0,xmm1
  43:	0f 28 d1             	movaps xmm2,xmm1
  46:	0f c6 d1 55          	shufps xmm2,xmm1,0x55
  4a:	f3 0f 58 c2          	addss  xmm0,xmm2
  4e:	0f 28 d1             	movaps xmm2,xmm1
  51:	0f 15 d1             	unpckhps xmm2,xmm1
  54:	0f c6 c9 ff          	shufps xmm1,xmm1,0xff
  58:	f3 0f 58 c2          	addss  xmm0,xmm2
  5c:	f3 0f 58 c1          	addss  xmm0,xmm1
  60:	48 39 f8             	cmp    rax,rdi
  63:	75 cb                	jne    30 <float dot<float>(float const*, float const*, unsigned long)+0x30>
  65:	f6 c2 03             	test   dl,0x3
  68:	74 5a                	je     c4 <float dot<float>(float const*, float const*, unsigned long)+0xc4>
  6a:	48 89 d0             	mov    rax,rdx
  6d:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  71:	f3 0f 10 0c 81       	movss  xmm1,DWORD PTR [rcx+rax*4]
  76:	f3 0f 59 0c 86       	mulss  xmm1,DWORD PTR [rsi+rax*4]
  7b:	4c 8d 40 01          	lea    r8,[rax+0x1]
  7f:	48 8d 3c 85 00 00 00 	lea    rdi,[rax*4+0x0]
  86:	00 
  87:	f3 0f 58 c1          	addss  xmm0,xmm1
  8b:	49 39 d0             	cmp    r8,rdx
  8e:	73 34                	jae    c4 <float dot<float>(float const*, float const*, unsigned long)+0xc4>
  90:	f3 0f 10 4c 39 04    	movss  xmm1,DWORD PTR [rcx+rdi*1+0x4]
  96:	f3 0f 59 4c 3e 04    	mulss  xmm1,DWORD PTR [rsi+rdi*1+0x4]
  9c:	48 83 c0 02          	add    rax,0x2
  a0:	f3 0f 58 c1          	addss  xmm0,xmm1
  a4:	48 39 d0             	cmp    rax,rdx
  a7:	73 1b                	jae    c4 <float dot<float>(float const*, float const*, unsigned long)+0xc4>
  a9:	f3 0f 10 4c 3e 08    	movss  xmm1,DWORD PTR [rsi+rdi*1+0x8]
  af:	f3 0f 59 4c 39 08    	mulss  xmm1,DWORD PTR [rcx+rdi*1+0x8]
  b5:	f3 0f 58 c1          	addss  xmm0,xmm1
  b9:	c3                   	ret
  ba:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  c0:	66 0f ef c0          	pxor   xmm0,xmm0
  c4:	c3                   	ret
  c5:	31 c0                	xor    eax,eax
  c7:	66 0f ef c0          	pxor   xmm0,xmm0
  cb:	eb a4                	jmp    71 <float dot<float>(float const*, float const*, unsigned long)+0x71>

Disassembly of section .text._Z3dotIdET_PKS0_S2_m:

0000000000000000 <double dot<double>(double const*, double const*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 d2             	test   rdx,rdx
   7:	74 57                	je     60 <double dot<double>(double const*, double const*, unsigned long)+0x60>
   9:	48 83 fa 01          	cmp    rdx,0x1
   d:	74 56                	je     65 <double dot<double>(double const*, double const*, unsigned long)+0x65>
   f:	48 89 d1             	mov    rcx,rdx
  12:	31 c0                	xor    eax,eax
  14:	66 0f ef c0          	pxor   xmm0,xmm0
  18:	48 d1 e9             	shr    rcx,1
  1b:	48 c1 e1 04          	shl    rcx,0x4
  1f:	90                   	nop
  20:	66 0f 10 0c 07       	movupd xmm1,XMMWORD PTR [rdi+rax*1]
  25:	66 0f 10 1c 06       	movupd xmm3,XMMWORD PTR [rsi+rax*1]
  2a:	48 83 c0 10          	add    rax,0x10
  2e:	66 0f 59 cb          	mulpd  xmm1,xmm3
  32:	f2 0f 58 c1          	addsd  xmm0,xmm1
  36:	66 0f 15 c9          	unpckhpd xmm1,xmm1
  3a:	f2 0f 58 c1          	addsd  xmm0,xmm1
  3e:	48 39 c8             	cmp    rax,rcx
  41:	75 dd                	jne    20 <double dot<double>(double const*, double const*, unsigned long)+0x20>
  43:	f6 c2 01             	test   dl,0x1
  46:	74 1c                	je     64 <double dot<double>(double const*, double const*, unsigned long)+0x64>
  48:	48 83 e2 fe          	and    rdx,0xfffffffffffffffe
  4c:	f2 0f 10 0c d6       	movsd  xmm1,QWORD PTR [rsi+rdx*8]
  51:	f2 0f 59 0c d7       	mulsd  xmm1,QWORD PTR [rdi+rdx*8]
  56:	f2 0f 58 c1          	addsd  xmm0,xmm1
  5a:	c3                   	ret
  5b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  60:	66 0f ef c0          	pxor   xmm0,xmm0
  64:	c3                   	ret
  65:	31 d2                	xor    edx,edx
  67:	66 0f ef c0          	pxor   xmm0,xmm0
  6b:	eb df                	jmp    4c <double dot<double>(double const*, double const*, unsigned long)+0x4c>
