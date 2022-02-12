#ifndef SOZOBON
|
|  single float to long conversion routine
|
| Andreas Schwab (schwab@ls5.informatik.uni-dortmund.de)
|  mostly copied from _fixdfsi.cpp
|  (error check removed because no checking possible)

#ifndef __M68881__

	.text
	.even
	.globl	___fixsfsi

___fixsfsi:

#ifdef sfp004

comm =	 -6
resp =	-16
zahl =	  0

	lea	0xfffffa50:w,a0
	movew	#0x5403,a0@(comm)	| fintrz to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x6000,a0@(comm)	| result to d0
| waiting loop is NOT coded directly
1:	cmpiw	#0x8900,a0@(resp)
	beq	1b
	movel	a0@,d0
		
#else /* !sfp004 */

BIAS4	=	0x7F-1

	movel	sp@(4),d0	| get number
	movel	d2,sp@-		| save register
	movel	d0,d1
	swap	d1		| extract exp
	movew	d1,d2		| extract sign
	lsrw	#7,d1
	andw	#0xff,d1	| kill sign bit

	andl	#0x7fffff,d0	| remove exponent from mantissa
	orl	#0x800000,d0	| restore implied leading "1"

	cmpw	#BIAS4,d1	| check exponent
	blt	zero		| strictly factional, no integer part ?
	cmpw	#BIAS4+32,d1	| is it too big to fit in a 32-bit integer ?
	bgt	toobig

	subw	#BIAS4+24,d1	| adjust exponent
	bgt	2f		| shift up
	beq	7f		| no shift (never too big)

1:	negw	d1
	lsrl	d1,d0		| shift down to align radix point;
				| extra bits fall off the end (no rounding)
	bra	7f		| never too big

2:	lsll	d1,d0		| shift up to align radix point

3:	cmpl	#0x80000000,d0	| -2147483648 is a nasty evil special case
	bne	6f
	tstw	d2		| this had better be -2^31 and not 2^31
	bpl	toobig
	bra	8f
6:	tstl	d0		| sign bit set ? (i.e. too big)
	bmi	toobig
7:
	tstw	d2		| is it negative ?
	bpl	8f
	negl	d0		| negate
8:
	movel	sp@+,d2
	rts

zero:
	clrl	d0		| make the whole thing zero
	bra	8b

toobig:
	movel	#0x7fffffff,d0	| ugh. Should cause a trap here.
	bra	8b

#endif /* !sfp004*/

#endif /* !__M68881__ */

#else /* SOZOBON */

	.text
	.even
#ifdef GNUNAMES
	.globl	___fixsfsi

___fixsfsi:
#else
	.globl	fpftol
#endif /* GNUNAMES */
fpftol:

BIAS4	.equ	$7F-1

	move.l	4(sp),d0	* get number
	move.l	d2,-(sp)	* save register
	move.l	d0,d1
	swap	d1		* extract exp
	move.w	d1,d2		* extract sign
	lsr.w	#7,d1
	and.w	#$ff,d1		* kill sign bit

	and.l	#$7fffff,d0	* remove exponent from mantissa
	or.l	#$800000,d0	* restore implied leading "1"

	cmp.w	#BIAS4,d1	* check exponent
	blt	zero		* strictly factional, no integer part ?
	cmp.w	#BIAS4+32,d1	* is it too big to fit in a 32-bit integer ?
	bgt	toobig

	sub.w	#BIAS4+24,d1	* adjust exponent
	bgt	m2		* shift up
	beq	m7		* no shift (never too big)

m1:	neg.w	d1
	lsr.l	d1,d0		* shift down to align radix point;
				* extra bits fall off the end (no rounding)
	bra	m7		* never too big

m2:	lsl.l	d1,d0		* shift up to align radix point

m3:	cmp.l	#$80000000,d0	* -2147483648 is a nasty evil special case
	bne	m6
	tst.w	d2		* this had better be -2^31 and not 2^31
	bpl	toobig
	bra	m8
m6:	tst.l	d0		* sign bit set ? (i.e. too big)
	bmi	toobig
m7:
	tst.w	d2		* is it negative ?
	bpl	m8
	neg.l	d0		* negate
m8:
	move.l	(sp)+,d2
	rts

zero:
	clr.l	d0		* make the whole thing zero
	bra	m8

toobig:
	move.l	#$7fffffff,d0	* ugh. Should cause a trap here.
	bra	m8

#endif /* SOZOBON */

