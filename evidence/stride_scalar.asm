
build/kernels_stride_scalar.o:     file format elf64-x86-64


Disassembly of section .text._Z15multiply_strideIfEvPKT_S2_PS0_mm:

0000000000000000 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	74 2e                	je     37 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x37>
   9:	31 c0                	xor    eax,eax
   b:	49 83 f8 01          	cmp    r8,0x1
   f:	75 2f                	jne    40 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x40>
  11:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  18:	00 00 00 00 
  1c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  20:	c5 fa 10 04 86       	vmovss xmm0,DWORD PTR [rsi+rax*4]
  25:	c5 fa 59 04 87       	vmulss xmm0,xmm0,DWORD PTR [rdi+rax*4]
  2a:	c5 fa 11 04 82       	vmovss DWORD PTR [rdx+rax*4],xmm0
  2f:	48 ff c0             	inc    rax
  32:	48 39 c8             	cmp    rax,rcx
  35:	75 e9                	jne    20 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x20>
  37:	c3                   	ret
  38:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  3f:	00 
  40:	49 c1 e0 02          	shl    r8,0x2
  44:	45 31 c9             	xor    r9d,r9d
  47:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  4e:	00 00 
  50:	c5 fa 10 04 07       	vmovss xmm0,DWORD PTR [rdi+rax*1]
  55:	c5 fa 59 04 06       	vmulss xmm0,xmm0,DWORD PTR [rsi+rax*1]
  5a:	49 ff c1             	inc    r9
  5d:	c5 fa 11 04 02       	vmovss DWORD PTR [rdx+rax*1],xmm0
  62:	4c 01 c0             	add    rax,r8
  65:	4c 39 c9             	cmp    rcx,r9
  68:	75 e6                	jne    50 <void multiply_stride<float>(float const*, float const*, float*, unsigned long, unsigned long)+0x50>
  6a:	c3                   	ret

Disassembly of section .text._Z15multiply_strideIdEvPKT_S2_PS0_mm:

0000000000000000 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)>:
   0:	f3 0f 1e fa          	endbr64
   4:	48 85 c9             	test   rcx,rcx
   7:	74 2e                	je     37 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x37>
   9:	31 c0                	xor    eax,eax
   b:	49 83 f8 01          	cmp    r8,0x1
   f:	75 2f                	jne    40 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x40>
  11:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  18:	00 00 00 00 
  1c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  20:	c5 fb 10 04 c6       	vmovsd xmm0,QWORD PTR [rsi+rax*8]
  25:	c5 fb 59 04 c7       	vmulsd xmm0,xmm0,QWORD PTR [rdi+rax*8]
  2a:	c5 fb 11 04 c2       	vmovsd QWORD PTR [rdx+rax*8],xmm0
  2f:	48 ff c0             	inc    rax
  32:	48 39 c8             	cmp    rax,rcx
  35:	75 e9                	jne    20 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x20>
  37:	c3                   	ret
  38:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  3f:	00 
  40:	49 c1 e0 03          	shl    r8,0x3
  44:	45 31 c9             	xor    r9d,r9d
  47:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  4e:	00 00 
  50:	49 ff c1             	inc    r9
  53:	c5 fb 10 04 07       	vmovsd xmm0,QWORD PTR [rdi+rax*1]
  58:	c5 fb 59 04 06       	vmulsd xmm0,xmm0,QWORD PTR [rsi+rax*1]
  5d:	c5 fb 11 04 02       	vmovsd QWORD PTR [rdx+rax*1],xmm0
  62:	4c 01 c0             	add    rax,r8
  65:	4c 39 c9             	cmp    rcx,r9
  68:	75 e6                	jne    50 <void multiply_stride<double>(double const*, double const*, double*, unsigned long, unsigned long)+0x50>
  6a:	c3                   	ret
