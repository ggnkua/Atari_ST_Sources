#ifndef SOZOBON
|
| single floating point add/subtract routine
|
#ifndef	__M68881__
	.text
	.even
	.globl	__subsf3, ___subsf3
	.globl	__addsf3, ___addsf3
# ifndef sfp004
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 1.3.5 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
|   + ensure that x - x always returns +0, says IEEE,
|     unless x is Inf or NaN - then return NaN
|   + code smoothing
|
| patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
|
| Revision 1.3.4 olaf 11-92 :
|  + added support for NaN and infinities
|    > paranoia now dont complains about unbalanced range any more
|  -- still lacks trap handling for exceptions
|  -- dont know the external representation of quiet and signaling NaN
|     I decided 0x7fffffff to be a quiet NaN
|     the rest should be signaling (but isnt)
|
| Revision 1.3.3 olaf 11-92 :
|  + changed to get rid of rounding bits. a sticky register (d3) is
|    sufficient.
|
| Revision 1.3.2 olaf 10-92 :
|  + increased comparson by one again. (Dont understand, but it works)
|  + corrected negation of rounding bits and mantissa
|     >enquire now detects correct IEEE precision
|     >paranoia now qualifies add/sub as correctly rounded
|
| Revision 1.3.1 olaf 10-92 :
|  + increased comparison of exponents by one.
|  + initialized sticky byte
|  + corrected handling of rounding bits
|  + corrected swapping of register halves
|     >paranoia now detects only one (obscure) SERIOUS DEFECT.
|     ** Patches need _normsf Rev 1.4.1 (or higher) **
|
| Revision 1.3, kub 01-90 :
| added support for denormalized numbers
|
| Revision 1.2, kub 01-90 :
| replace far shifts by swaps to gain speed (more optimization is of course
| possible by doing shifts all in one intruction, but what about the rounding
| bits)
|
| Revision 1.1, kub 12-89 :
| Created single float version for 68000
|
| Revision 1.0:
| original 8088 code from P.S.Housel for double floats

__subsf3:
___subsf3:
	eorb	#0x80,sp@(8)	| reverse sign of v
__addsf3:
___addsf3:
	lea	sp@(4),a0	| pointer to u and v parameter
	moveml	d2-d5,sp@-	| save registers
	moveml	a0@,d4/d5	| d4 = v, d5 = u

	movel	#0x7fffff,d3
	movel	d5,d0		| d0 = u.exp
	movel	d5,d2		| d2.h = u.sign
	swap	d0
	movew	d0,d2		| d2 = u.sign
	andl	d3,d5		| remove exponent from u.mantissa

	movel	d4,d1		| d1 = v.exp
	andl	d3,d4		| remove exponent from v.mantissa
	swap	d1
	eorw	d1,d2		| d2 = u.sign ^ v.sign (in bit 15)
	clrb	d2		| we will use the lowest byte as a flag
	moveq	#15,d3
	bclr	d3,d1		| kill sign bit u.exp
	bclr	d3,d0		| kill sign bit u.exp
	btst	d3,d2		| same sign for u and v?
	bne	0f
	cmpl	d0,d1		| different signs - maybe x - x ?
	seq	d2		| set 'cancellation' flag
0:
	lsrw	#7,d0		| keep here exponents only
	lsrw	#7,d1
|
| Now perform testing of NaN and infinities
|
	moveq	#-1,d3
	cmpb	d3,d0
	beq	0f
	cmpb	d3,d1
	bne	nospec
	bra	1f
|
|	u is special
|
0:	tstb	d2		
	bne	retnan		| cancellation of specials -> NaN
	tstl	d5
	bne	retnan		| arith with Nan gives always NaN

	addqw	#4,a0		| here is an infinity
	cmpb    d3,d1
	bne	0f		| skip check for NaN if v not special
|
|	v is special
|
1:	tstl	d4
	bne	retnan
0:	movel	a0@,d0
	bra	return
|
| return a quiet NaN
|
retnan: moveql	#-1,d0
	lsrl	#1,d0		| 0x7fffffff -> d0
	bra	return
|
| Ok, no inifinty or NaN involved..
|
nospec:	tstb	d2
	beq	0f
	moveq	#0,d0		| x - x hence we always return +0
return:	moveml	sp@+,d2-d5
	rts

0:	moveq	#23,d3
	bset	d3,d5		| restore implied leading "1"
	tstw	d0		| check for zero exponent - no leading "1"
	bne	1f
	bclr	d3,d5		| remove it
	addqw	#1,d0		| "normalize" exponent
1:
	bset	d3,d4		| restore implied leading "1"
	tstw	d1		| check for zero exponent - no leading "1"
	bne	1f
	bclr	d3,d4		| remove it
	addqw	#1,d1		| "normalize" exponent
1:
	moveq	#0,d3		| (put initial zero rounding bits in d3)
	negw	d1		| d1 = u.exp - v.exp
	addw	d0,d1
	beq	5f		| exponents are equal - no shifting neccessary
	bgt	1f		| not equal but no exchange neccessary
	exg	d4,d5		| exchange u and v
	subw	d1,d0		| d0 = u.exp - (u.exp - v.exp) = v.exp
	negw	d1
	tstw	d2		| d2.h = u.sign ^ (u.sign ^ v.sign) = v.sign
	bpl	1f
	bchg	#31,d2
1:
	cmpw	#26,d1		| is u so much bigger that v is not
	bge	7f		| significant ?
|
| shift mantissa left two digits, to allow cancellation of
| most significant digit, while gaining an additional digit for
| rounding.
|
	moveql	#1,d3
2:	addl	d5,d5
	subqw	#1,d0		| decrement exponent
	subqw	#1,d1		| done shifting altogether ?
	dbeq	d3,2b		| loop if still can shift u.mant more
	moveq	#0,d3

	cmpw	#16,d1		| see if fast rotate possible
	blt	4f
	orw	d4,d3		| set rounding bits
	clrw	d4
	swap	d4
	subqw	#8,d1
	subqw	#8,d1
        bra     4f

0:	moveb   d4,d2
	andb	#1,d2
	orb	d2,d3
	lsrl	#1,d4		| shift v.mant right the rest of the way
4:	dbra	d1,0b		| loop

5:
	tstw	d2		| are the signs equal ?
	bpl	6f		| yes, no negate necessary


	tstw	d3		| negate rounding bits and v.mant
	beq	9f
	addql	#1,d4
9:	negl	d4

6:
	addl	d4,d5		| u.mant = u.mant + v.mant
	bcs	7f		| needn not negate
	tstw	d2		| opposite signs ?
	bpl	7f		| do not need to negate result

	negl	d5
	notl	d2		| switch sign
7:
	movel	d5,d4		| move result for normalization
	clrl	d1
	tstl	d3
	beq	8f
	moveql	#-1,d1
8:	swap	d2		| put sign into d2 (exponent is in d0)
	jmp	norm_sf		| leave registers on stack for norm_sf

# else	sfp004

| single precision floating point stuff for Atari-gcc using the SFP004
| developed with gas
|
|  single floating point add/subtract routine
|
| M. Ritzert (mjr at dmzrzu71)
|
| 4.10.1990
|
| no NAN checking implemented since the 68881 treats this situation "correct",
| i.e. according to IEEE

| addresses of the 68881 data port. This choice is fastest when much data is
| transferred between the two processors.

comm =	 -6
resp =	-16
zahl =	  0

| waiting loop ...
|
| wait:
| ww:	cmpiw	#0x8900,a0@(resp)
| 	beq	ww
| is coded directly by
|	.long	0x0c688900, 0xfff067f8

__subsf3:
___subsf3:
	lea	0xfffffa50:w,a0
	movew	#0x4400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movew	#0x4428,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@
	movew	#0x6400,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
 	rts

__addsf3:
___addsf3:
	lea	0xfffffa50:w,a0
	movew	#0x4400,a0@(comm)		| load fp0
	cmpiw	#0x8900,a0@(resp)		| got it?
	movel	a7@(4),a0@			| take a from stack to FPU
	movew	#0x4422,a0@(comm)		| add second arg to fp0
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@			| move b from stack to FPU
	movew	#0x6400,a0@(comm)		| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0				| download result
 	rts

# endif	sfp004
#endif	__M68881__

#else

;
; single floating point add/subtract routine
;
	.text
	.even
#ifdef GNUNAMES
	.globl	__subsf3, ___subsf3
	.globl	__addsf3, ___addsf3
__subsf3:
___subsf3:
#else
	.globl	fpfadd,fpfsub
#endif /* GNUNAMES */
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
; Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
;
; Revision 1.3.5 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
;   + ensure that x - x always returns +0, says IEEE,
;     unless x is Inf or NaN - then return NaN
;   + code smoothing
;
; patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
;
; Revision 1.3.4 olaf 11-92 :
;  + added support for NaN and infinities
;    > paranoia now dont complains about unbalanced range any more
;  -- still lacks trap handling for exceptions
;  -- dont know the external representation of quiet and signaling NaN
;     I decided 0x7fffffff to be a quiet NaN
;     the rest should be signaling (but isnt)
;
; Revision 1.3.3 olaf 11-92 :
;  + changed to get rid of rounding bits. a sticky register (d3) is
;    sufficient.
;
; Revision 1.3.2 olaf 10-92 :
;  + increased comparson by one again. (Dont understand, but it works)
;  + corrected negation of rounding bits and mantissa
;     >enquire now detects correct IEEE precision
;     >paranoia now qualifies add/sub as correctly rounded
;
; Revision 1.3.1 olaf 10-92 :
;  + increased comparison of exponents by one.
;  + initialized sticky byte
;  + corrected handling of rounding bits
;  + corrected swapping of register halves
;     >paranoia now detects only one (obscure) SERIOUS DEFECT.
;     ** Patches need _normsf Rev 1.4.1 (or higher) **
;
; Revision 1.3, kub 01-90 :
; added support for denormalized numbers
;
; Revision 1.2, kub 01-90 :
; replace far shifts by swaps to gain speed (more optimization is of course
; possible by doing shifts all in one intruction, but what about the rounding
; bits)
;
; Revision 1.1, kub 12-89 :
; Created single float version for 68000
;
; Revision 1.0:
; original 8088 code from P.S.Housel for double floats

fpfsub:
	eor.b	#$80,8(sp)	; reverse sign of v
fpfadd:
#ifdef GNUNAMES
__addsf3:
___addsf3:
#endif /* GNUNAMES */
	lea	4(sp),a0	; pointer to u and v parameter
	movem.l	d2-d5,-(sp)	; save registers
	movem.l	(a0),d4/d5	; d4 = v, d5 = u

	move.l	#$7fffff,d3
	move.l	d5,d0		; d0 = u.exp
	move.l	d5,d2		; d2.h = u.sign
	swap	d0
	move.w	d0,d2		; d2 = u.sign
	and.l	d3,d5		; remove exponent from u.mantissa

	move.l	d4,d1		; d1 = v.exp
	and.l	d3,d4		; remove exponent from v.mantissa
	swap	d1
	eor.w	d1,d2		; d2 = u.sign ^ v.sign (in bit 15)
	clr.b	d2		; we will use the lowest byte as a flag
	moveq	#15,d3
	bclr	d3,d1		; kill sign bit u.exp
	bclr	d3,d0		; kill sign bit u.exp
	btst	d3,d2		; same sign for u and v?
	bne	l00
	cmp.l	d0,d1		; different signs - maybe x - x ?
	seq	d2		; set 'cancellation' flag
l00:
	lsr.w	#7,d0		; keep here exponents only
	lsr.w	#7,d1
;
; Now perform testing of NaN and infinities
;
	moveq	#-1,d3
	cmp.b	d3,d0
	beq	l01
	cmp.b	d3,d1
	bne	nospec
	bra	l11
;
;	u is special
;
l01:	tst.b	d2		
	bne	retnan		; cancellation of specials -> NaN
	tst.l	d5
	bne	retnan		; arith with Nan gives always NaN

	addq.w	#4,a0		; here is an infinity
	cmp.b   d3,d1
	bne	l02		; skip check for NaN if v not special
;
;	v is special
;
l11:	tst.l	d4
	bne	retnan
l02:	move.l	(a0),d0
	bra	return
;
; return a quiet NaN
;
retnan: moveq.l	#-1,d0
	lsr.l	#1,d0		; 0x7fffffff -> d0
	bra	return
;
; Ok, no inifinty or NaN involved..
;
nospec:	tst.b	d2
	beq	l03
	moveq	#0,d0		; x - x hence we always return +0
return:	movem.l	(sp)+,d2-d5
	rts

l03:	moveq	#23,d3
	bset	d3,d5		; restore implied leading "1"
	tst.w	d0		; check for zero exponent - no leading "1"
	bne	l12
	bclr	d3,d5		; remove it
	addq.w	#1,d0		; "normalize" exponentl
l12:
	bset	d3,d4		; restore implied leading "1"
	tst.w	d1		; check for zero exponent - no leading "1"
	bne	l125
	bclr	d3,d4		; remove it
	addq.w	#1,d1		; "normalize" exponent
l125:
	moveq	#0,d3		; (put initial zero rounding bits in d3)
	neg.w	d1		; d1 = u.exp - v.exp
	add.w	d0,d1
	beq	l5		; exponents are equal - no shifting neccessary
	bgt	l13		; not equal but no exchange neccessary
	exg	d4,d5		; exchange u and v
	sub.w	d1,d0		; d0 = u.exp - (u.exp - v.exp) = v.exp
	neg.w	d1
	tst.w	d2		; d2.h = u.sign ^ (u.sign ^ v.sign) = v.sign
	bpl	l13
	bchg	#31,d2
l13:
	cmp.w	#26,d1		; is u so much bigger that v is not
	bge	l7		; significant ?
;
; shift mantissa left two digits, to allow cancellation of
; most significant digit, while gaining an additional digit for
; rounding.
;
	moveq.l	#1,d3
l2b:	add.l	d5,d5
	subq.w	#1,d0		; decrement exponent
	subq.w	#1,d1		; done shifting altogether ?
	dbeq	d3,l2b		; loop if still can shift u.mant more
	moveq	#0,d3

	cmp.w	#16,d1		; see if fast rotate possible
	blt	l4
	or.w	d4,d3		; set rounding bits
	clr.w	d4
	swap	d4
	subq.w	#8,d1
	subq.w	#8,d1
        bra     l4

l0b:	move.b   d4,d2
	and.b	#1,d2
	or.b	d2,d3
	lsr.l	#1,d4		; shift v.mant right the rest of the way
l4:	dbra	d1,l0b		; loop

l5:
	tst.w	d2		; are the signs equal ?
	bpl	l6		; yes, no negate necessary


	tst.w	d3		; negate rounding bits and v.mant
	beq	l9
	addq.l	#1,d4
l9:	neg.l	d4

l6:
	add.l	d4,d5		; u.mant = u.mant + v.mant
	bcs	l7		; needn not negate
	tst.w	d2		; opposite signs ?
	bpl	l7		; do not need to negate result

	neg.l	d5
	not.l	d2		; switch sign
l7:
	move.l	d5,d4		; move result for normalization
	clr.l	d1
	tst.l	d3
	beq	l8
	moveq.l	#-1,d1
l8:	swap	d2		; put sign into d2 (exponent is in d0)
	jmp	norm_sf		; leave registers on stack for norm_sf

#endif /* SOZOBON */
