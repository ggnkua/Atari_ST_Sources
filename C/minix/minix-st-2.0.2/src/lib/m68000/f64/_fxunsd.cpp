#ifndef SOZOBON
|
| double float to unsigned long conversion routine
| does not really return unsigned long: max result is 0x7fffffff
| mjr
	.text
	.even
	.globl	__fixunsdfsi, ___fixunsdfsi

#ifdef ERROR_CHECK
#include "errbase.h"
_Overflow:
	.ascii "OVERFLOW\0"
_Negative:
	.ascii "NEGATIVE NUMBER\0"
_Error_String:
	.ascii "_fixunsdfsi: %s error\n\0"
.even
#endif ERROR_CHECK

__fixunsdfsi:
___fixunsdfsi:

#ifdef ERROR_CHECK
	tstl	a7@(4)			| negative?
	beq	Continue
	moveq	#ERANGE,d0
	Emove	d0,Errno
	pea	pc@(_Negative)
	bra	error_exit
Continue:
#endif /* ERROR_CHECK */
#ifdef __M68881__

	fintrzd a7@(4),fp0		| convert
	fmovel	fp0,d0

#endif __M68881__

#ifdef	sfp004
| double float to unsigned long conversion routine
| does not really return unsigned long: max result is 0x7fffffff
| mjr

comm =	 -6
resp =	-16
zahl =	  0

	lea	0xfffffa50:w,a0
	movew	#0x5403,a0@(comm)	| fintrz to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x6000,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
#endif	sfp004

# if !defined (sfp004) && !defined (__M68881__)

| double float to unsigned long conversion routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
|
| Revision 1.3, kub 01-90 :
| added support for denormalized numbers
|
| Revision 1.2, kub 01-90 :
| replace far shifts by swaps to gain speed
|
| Revision 1.1, kub 12-89 :
| Ported over to 68k assembler
|
| Revision 1.0:
| original 8088 code from P.S.Housel

BIAS8	=	0x3FF-1

	lea	sp@(4),a0	| pointer to parameters
	moveml	d4/d5,sp@-	| save registers
	moveml	a0@,d4-d5	| get the number
	movew	a0@,d0		| extract exp
	lsrw	#4,d0
	andw	#0x07ff,d0	| kill sign bit

	andl	#0x0fffff,d4	| remove exponent from mantissa
	orl	#0x100000,d4	| restore implied leading "1"

	cmpw	#BIAS8,d0	| check exponent
	blt	zero		| strictly factional, no integer part ?
	cmpw	#BIAS8+32,d0	| is it too big to fit in a 32-bit integer ?
	bgt	toobig

	subw	#BIAS8+21,d0	| adjust exponent
	bgt	2f		| shift up
	beq	3f		| no shift

	cmpw	#-8,d0		| replace far shifts by swap
	bgt	1f
	movew	d4,d5		| shift fast, 16 bits
	swap	d5
	clrw	d4
	swap	d4
	addw	#16,d0		| account for swap
	bgt	2f
	beq	3f

1:	lsrl	#1,d4		| shift down to align radix point;
	addw	#1,d0		| extra bits fall off the end (no rounding)
	blt	1b		| shifted all the way down yet ?
	bra	3f

2:	addl	d5,d5		| shift up to align radix point
	addxl	d4,d4
	subw	#1,d0
	bgt	2b
3:
	movel	d4,d0		| put integer into result register
7:
	moveml	sp@+,d4/d5
	rts

zero:
	clrl	d0		| make the whole thing zero
	bra	7b

toobig:
	moveml	sp@+,d4/d5
	movel	#0x7fffffff,d0	| ugh. Should cause a trap here.
#endif

#ifdef	ERROR_CHECK
	cmpil	#0x7fffffff,d0	| >= long_max
	bge	error_plus	|
	rts
error_plus:
	moveml	d0-d1,a7@-
	moveq	#ERANGE,d0
	Emove	d0,Errno
	pea	pc@(_Overflow)	| for printf
error_exit:
	pea	pc@(_Error_String)	|
	pea	Stderr
	jbsr	_fprintf	|
	addl	#12,a7		|
	moveml	a7@+,d0-d1
#endif	ERROR_CHECK
	rts

#else /* SOZOBON */
	
	.text
	.even
#ifdef GNUNAMES
	.globl	__fixunsdfsi, ___fixunsdfsi
__fixunsdfsi:
___fixunsdfsi:
#else
	.globl	fpdtoul
#endif /* GNUNAMES */
fpdtoul:

* double float to unsigned long conversion routine
*
* written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
* Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
*
*
* Revision 1.3, kub 01-90 :
* added support for denormalized numbers
*
* Revision 1.2, kub 01-90 :
* replace far shifts by swaps to gain speed
*
* Revision 1.1, kub 12-89 :
* Ported over to 68k assembler
*
* Revision 1.0:
* original 8088 code from P.S.Housel

BIAS8	.equ	$3FF-1

	move.w	4(sp),d0	* extract exp
	move.w	d0,a1		* extract sign
	lsr.w	#4,d0
	and.w	#$07ff,d0	* kill sign bit

	cmp.w	#BIAS8,d0	* check exponent
	blt	zero		* strictly factional, no integer part ?
	cmp.w	#BIAS8+32,d0	* is it too big to fit in a 32-bit integer ?
	bgt	toobig

	movem.l	4(sp),d1-d2	* get the value
	and.l	#$0fffff,d1	* remove exponent from mantissa
	or.l	#$100000,d1	* restore implied leading "1"

	sub.w	#BIAS8+21,d0	* adjust exponent
	bgt	m2		* shift up
	beq	m3		* no shift

	cmp.w	#-8,d0		* replace far shifts by swap
	bgt	m1
	move.w	d1,d2		* shift fast, 16 bits
	swap	d2
	clr.w	d1
	swap	d1
	add.w	#16,d0		* account for swap
	bgt	m2
	beq	m3

m1:	lsr.l	#1,d1		* shift down to align radix point;
	add.w	#1,d0		* extra bits fall off the end (no rounding)
	blt	m1		* shifted all the way down yet ?
	bra	m3

m2:	add.l	d2,d2		* shift up to align radix point
	addx.l	d1,d1
	sub.w	#1,d0
	bgt	m2
m3:
	move.l	d1,d0
	move.w	a1,d2		* get sign into d2
	tst.w	d2		* is it negative?
	bpl	m7
	neg.l	d0		* negate
m7:
	rts

zero:
	clr.l	d0		* make the whole thing zero
	bra	m7

toobig:
	move.l	#$ffffffff,d0	* ugh. Should cause a trap here.
	bra	m7

#endif /* SOZOBON */
