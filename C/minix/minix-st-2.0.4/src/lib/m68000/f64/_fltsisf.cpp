#ifndef SOZOBON
|
| long integer to single float conversion routine
|
| Andreas Schwab (schwab@ls5.informatik.uni-dortmund.de)
|  mostly copied from _floatsi.cpp

#ifndef __M68881__
	.text
	.even
	.globl	___floatsisf

___floatsisf:
#ifdef	sfp004

| addresses of the 68881 data port. This choice is fastest when much data is
| transferred between the two processors.

comm =	 -6	|	fpu command reg
resp =	-16	|	fpu response reg
zahl =	  0	|	fpu data reg

	lea	0xfffffa50:w,a0
	movew	#0x4000,a0@(comm)	| load long int to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movew	#0x7400,a0@(comm)	| get double from fp0
| wait loop is NOT coded directly
1:	cmpw	#0x8900,a0@(resp)
	beq	1b
	movel	a0@,d0
	rts

#else /* !sfp004 */

BIAS4	=	0x7F-1

	moveml	d2-d5,sp@-	| save registers to make norm_sf happy

	movel	sp@(20),d4	| prepare result mantissa
	movew	#BIAS4+32-8,d0	| radix point after 32 bits
	movel	d4,d2		| set sign flag
	swap	d2
	tstw	d2		| check sign of number
	bge	1f		| nonnegative
	negl	d4		| take absolute value
1:
	clrw	d1		| set rounding = 0
	jmp	norm_sf

#endif /* !sfp004 */

#endif /* !__M68881__ */

#else /* SOZOBON */

	.text
	.even
#ifdef GNUNAMES
	.globl	___floatsisf

___floatsisf:
#else
	.globl	fpltof
#endif /* GNUNAMES */
fpltof:

BIAS4	.equ	$7F-1

	movem.l	d2-d5,-(sp)	* save registers to make norm_sf happy

	move.l	20(sp),d4	* prepare result mantissa
	move.w	#BIAS4+32-8,d0	* radix point after 32 bits
	move.l	d4,d2		* set sign flag
	swap	d2
	tst.w	d2		* check sign of number
	bge	m1		* nonnegative
	neg.l	d4		* take absolute value
m1:
	clr.w	d1		* set rounding = 0
	jmp	norm_sf

	.globl	fpultof
fpultof:
	movem.l	d2-d5,-(sp)	* save registers to make norm_sf happy

	move.l	20(sp),d4	* prepare result mantissa
	move.w	#BIAS4+32-8,d0	* radix point after 32 bits
	clr.w	d2		* set sign flag
	bra	m1
#endif /* SOZOBON */
