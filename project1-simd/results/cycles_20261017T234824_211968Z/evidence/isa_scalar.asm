
build/kernels_scalar.o:     file format elf64-x86-64


Disassembly of section .text._Z4axpyIfEvT_PKS0_PS0_m:

0000000000000000 <void axpy<float>(float, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 d2             	test   rdx,rdx
   7:	74 1e                	je     27 <void axpy<float>(float, float const*, float*, unsigned long)+0x27>
   9:	31 c0                	xor    eax,eax
   b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  10:	c5 fa 59 0c 87       	vmulss xmm1,xmm0,DWORD PTR [rdi+rax*4]
  15:	c5 f2 58 0c 86       	vaddss xmm1,xmm1,DWORD PTR [rsi+rax*4]
  1a:	c5 fa 11 0c 86       	vmovss DWORD PTR [rsi+rax*4],xmm1
  1f:	48 ff c0             	inc    rax
  22:	48 39 c2             	cmp    rdx,rax
  25:	75 e9                	jne    10 <void axpy<float>(float, float const*, float*, unsigned long)+0x10>
  27:	c3                   	ret

Disassembly of section .text._Z4axpyIdEvT_PKS0_PS0_m:

0000000000000000 <void axpy<double>(double, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 d2             	test   rdx,rdx
   7:	74 1e                	je     27 <void axpy<double>(double, double const*, double*, unsigned long)+0x27>
   9:	31 c0                	xor    eax,eax
   b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  10:	c5 fb 59 0c c7       	vmulsd xmm1,xmm0,QWORD PTR [rdi+rax*8]
  15:	c5 f3 58 0c c6       	vaddsd xmm1,xmm1,QWORD PTR [rsi+rax*8]
  1a:	c5 fb 11 0c c6       	vmovsd QWORD PTR [rsi+rax*8],xmm1
  1f:	48 ff c0             	inc    rax
  22:	48 39 c2             	cmp    rdx,rax
  25:	75 e9                	jne    10 <void axpy<double>(double, double const*, double*, unsigned long)+0x10>
  27:	c3                   	ret

Disassembly of section .text._Z8multiplyIfEvPKT_S2_PS0_m:

0000000000000000 <void multiply<float>(float const*, float const*, float*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	74 1e                	je     27 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x27>
   9:	31 c0                	xor    eax,eax
   b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  10:	c5 fa 10 04 87       	vmovss xmm0,DWORD PTR [rdi+rax*4]
  15:	c5 fa 59 04 86       	vmulss xmm0,xmm0,DWORD PTR [rsi+rax*4]
  1a:	c5 fa 11 04 82       	vmovss DWORD PTR [rdx+rax*4],xmm0
  1f:	48 ff c0             	inc    rax
  22:	48 39 c1             	cmp    rcx,rax
  25:	75 e9                	jne    10 <void multiply<float>(float const*, float const*, float*, unsigned long)+0x10>
  27:	c3                   	ret

Disassembly of section .text._Z8multiplyIdEvPKT_S2_PS0_m:

0000000000000000 <void multiply<double>(double const*, double const*, double*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	74 1e                	je     27 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x27>
   9:	31 c0                	xor    eax,eax
   b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  10:	c5 fb 10 04 c7       	vmovsd xmm0,QWORD PTR [rdi+rax*8]
  15:	c5 fb 59 04 c6       	vmulsd xmm0,xmm0,QWORD PTR [rsi+rax*8]
  1a:	c5 fb 11 04 c2       	vmovsd QWORD PTR [rdx+rax*8],xmm0
  1f:	48 ff c0             	inc    rax
  22:	48 39 c1             	cmp    rcx,rax
  25:	75 e9                	jne    10 <void multiply<double>(double const*, double const*, double*, unsigned long)+0x10>
  27:	c3                   	ret

Disassembly of section .text._Z3dotIfET_PKS0_S2_m:

0000000000000000 <float dot<float>(float const*, float const*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 d2             	test   rdx,rdx
   7:	74 27                	je     30 <float dot<float>(float const*, float const*, unsigned long)+0x30>
   9:	31 c0                	xor    eax,eax
   b:	c5 f0 57 c9          	vxorps xmm1,xmm1,xmm1
   f:	90                   	nop
  10:	c5 fa 10 04 87       	vmovss xmm0,DWORD PTR [rdi+rax*4]
  15:	c5 fa 59 04 86       	vmulss xmm0,xmm0,DWORD PTR [rsi+rax*4]
  1a:	48 ff c0             	inc    rax
  1d:	c5 f2 58 c8          	vaddss xmm1,xmm1,xmm0
  21:	48 39 c2             	cmp    rdx,rax
  24:	75 ea                	jne    10 <float dot<float>(float const*, float const*, unsigned long)+0x10>
  26:	c5 f8 28 c1          	vmovaps xmm0,xmm1
  2a:	c3                   	ret
  2b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  30:	c5 f0 57 c9          	vxorps xmm1,xmm1,xmm1
  34:	c5 f8 28 c1          	vmovaps xmm0,xmm1
  38:	c3                   	ret

Disassembly of section .text._Z3dotIdET_PKS0_S2_m:

0000000000000000 <double dot<double>(double const*, double const*, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 d2             	test   rdx,rdx
   7:	74 27                	je     30 <double dot<double>(double const*, double const*, unsigned long)+0x30>
   9:	31 c0                	xor    eax,eax
   b:	c5 f1 57 c9          	vxorpd xmm1,xmm1,xmm1
   f:	90                   	nop
  10:	c5 fb 10 04 c7       	vmovsd xmm0,QWORD PTR [rdi+rax*8]
  15:	c5 fb 59 04 c6       	vmulsd xmm0,xmm0,QWORD PTR [rsi+rax*8]
  1a:	48 ff c0             	inc    rax
  1d:	c5 f3 58 c8          	vaddsd xmm1,xmm1,xmm0
  21:	48 39 c2             	cmp    rdx,rax
  24:	75 ea                	jne    10 <double dot<double>(double const*, double const*, unsigned long)+0x10>
  26:	c5 f3 10 c1          	vmovsd xmm0,xmm1,xmm1
  2a:	c3                   	ret
  2b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  30:	c5 f1 57 c9          	vxorpd xmm1,xmm1,xmm1
  34:	c5 f3 10 c1          	vmovsd xmm0,xmm1,xmm1
  38:	c3                   	ret
