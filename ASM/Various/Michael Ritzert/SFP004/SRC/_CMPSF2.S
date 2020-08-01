| single floating point compare routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
|
| Revision 1.1, kub 12-89 :
| Created single float version for 68000
|
| Revision 1.0:
| original 8088 code from P.S.Housel for double floats

	.text
	.even
	.globl	__cmpsf2, ___cmpsf2

__cmpsf2:
___cmpsf2:
	moveml	sp@(4),d0-d1	| get u and v
	tstl	d1		| check sign bit
	bpl	one
	negl	d1		| negate
	eorl	#0x80000000,d1	| toggle sign bit
one:
	tstl	d0		| check sign bit
	bpl	two
	negl	d0		| negate
	eorl	#0x80000000,d0	| toggle sign bit
two:
	cmpl	d1,d0
	blt	lt
	bgt	gt
eq:
	clrl	d0
	rts
lt:
	moveq	#-1,d0
	rts
gt:
	moveq	#1,d0
	rts
