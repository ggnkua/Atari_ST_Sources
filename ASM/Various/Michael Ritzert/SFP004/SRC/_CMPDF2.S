| double floating point compare routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
|
| Revision 1.1, kub 12-89 :
| Ported over to 68k assembler
|
| Revision 1.0:
| original 8088 code from P.S.Housel

	.text
	.even
	.globl	__cmpdf2, ___cmpdf2

__cmpdf2:
___cmpdf2:
	moveml	sp@(4),d0-d1/a0-a1 | get u and v
	tstl	d0		| check sign bit
	bpl	one
	negl	d1		| negate
	negxl	d0
	eorl	#0x80000000,d0	| toggle sign bit
one:
	exg	a0,d0
	exg	a1,d1
	tstl	d0		| check sign bit
	bpl	two
	negl	d1		| negate
	negxl	d0
	eorl	#0x80000000,d0	| toggle sign bit
two:
	cmpl	d0,a0
	blt	lt
	bgt	gt
	cmpl	d1,a1
	bhi	gt
	beq	eq
lt:
	moveq	#-1,d0
	rts
eq:
	clrl	d0
	rts
gt:
	moveq	#1,d0
	rts
