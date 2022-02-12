#ifndef SOZOBON
|
| double floating point add/subtract routine
|
#ifndef __M68881__
	.text
	.even
	.globl	__subdf3, ___subdf3
	.globl	__adddf3, ___adddf3
# ifndef	sfp004
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 1.3.6 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
|   + ensure that x - x always returns +0, says IEEE,
|     unless x is Inf or NaN - then return NaN
|
| Revision 1.3.5 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
|   + code smoothing
|
| patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
|
| Revision 1.3.4 olaf 11-92 :
|  + added support for NaN and infinities
|    > floating point is now excellent!
|
|  -- still lacks trap handling for exceptions
|  -- dont know the external representation of quiet and signaling NaN
|     I decided 0x7fffffff,ffffffff to be a quiet NaN
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
|     >paranoia now detects no SERIOUS DEFECTS any more
|     ** Patches need _normdf Rev 1.6.1 (or higher) **
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

__subdf3:
___subdf3:
	eorb	#0x80,sp@(12)	| reverse sign of v
__adddf3:
___adddf3:
	lea	sp@(4),a0	| pointer to u and v parameter
	moveml	d2-d7,sp@-	| save registers
	moveml	a0@,d4-d5/d6-d7	| d4-d5 = v, d6-d7 = u

	movel	#0x0fffff,d3
	movel	d6,d0		| d0 = u.exp
	andl	d3,d6		| remove exponent from u.mantissa
	movel	d0,d2		| d2.h = u.sign
	swap	d0
	movew	d0,d2		| d2.l = u.sign

	movel	d4,d1		| d1 = v.exp
	andl	d3,d4		| remove exponent from v.mantissa
	swap	d1
	eorw	d1,d2		| d2.l = u.sign ^ v.sign (in bit 15)
	clrb	d2		| we will use the lowest byte as a flag
	moveq	#15,d3
	bclr	d3,d0		| kill sign bit u.exp
	bclr	d3,d1		| kill sign bit v.exp
	btst	d3,d2		| same sign for u and v?
	beq	0f
	cmpl	d0,d1		| different signs - maybe x - x ?
	bne	0f
	cmpl	d5,d7
	seq	d2		| set 'cancellation' flag

0:	lsrw	#4,d0		| keep here exponents only
	lsrw	#4,d1
|
| Now perform testing of NaN and infinities
|
	movew	#0x7ff,d3
	cmpw	d3,d0
	beq	0f
	cmpw	d3,d1
	bne	nospec
	bra	1f
|
|	u is special
|
0:	tstb	d2		
	bne	retnan		| cancellation of specials -> NaN
	movel	d7,d0
	orl	d6,d0
	bne	retnan		| arith with Nan gives always NaN
	addqw	#8,a0		| adding to an address propagates anyway
	cmpw	d3,d1
	bne	0f		| skip check for NaN if v not special
|
|	v is special
|
1:	movel	d5,d0
	orl	d4,d0
	bne	retnan
0:	movel	a0@,d0		| copy infinity
	moveq	#0,d1
	bra 	return
|
| return a quiet NaN
|
retnan: moveql	#-1,d1
	movel	d1,d0
	lsrl	#1,d0		| 0x7fffffff -> d0
	bra	return
|
| Ok, no inifinty or NaN involved..
|
nospec: tstb	d2
	beq	0f
	moveq	#0,d0		| x - x hence we always return +0
	movel	d0,d1
return:	moveml	sp@+,d2-d7
	rts

0:	moveq	#20,d3
	bset	d3,d6		| restore implied leading "1"
	tstw	d0		| check for zero exponent - no leading "1"
	bne	1f
	bclr	d3,d6		| no implied leading "1", instead ...
	addqw	#1,d0		| "normalize" exponent
1:
	bset	d3,d4		| restore implied leading "1"
	tstw	d1		| check for zero exponent - no leading "1"
	bne	1f
	bclr	d3,d4		| no implied leading "1", instead ...
	addqw	#1,d1		| "normalize" exponent
1:
	moveq	#0,d3		| init sticky register
	negw	d1		| d1 = u.exp - v.exp
	addw	d0,d1
	beq	5f		| exponents are equal - no shifting neccessary
	bgt	1f		| not equal but no exchange neccessary
	exg	d4,d6		| exchange u and v
	exg	d5,d7
	subw	d1,d0		| d0 = u.exp - (u.exp - v.exp) = v.exp
	negw	d1
	tstw	d2		| d2.h = u.sign ^ (u.sign ^ v.sign) = v.sign
	bpl	1f
	bchg	#31,d2
1:
	cmpw	#55,d1		| is u so much bigger that v is not
	bge	7f		| significant ?
|
| shift mantissa left two digits, to allow cancellation of
| most significant digit, while gaining an additional digit for
| rounding.
|
	moveq	#1,d3
2:	addl	d7,d7
	addxl	d6,d6
	subqw	#1,d0		| decrement exponent
	subqw	#1,d1		| decrement counter
	dbeq    d3,2b
	moveq	#0,d3
|
| now shift other mantissa right as fast as possible (almost).
|
3:
	cmpw	#16,d1		| see if fast rotate possible
	blt	4f
	orw	d5,d3		| set sticky word
	movew	d4,d5		| rotate by swapping register halfs
	swap	d5
	clrw	d4
	swap	d4
	subqw	#8,d1
	subqw	#8,d1
	bra	3b

0:	moveb   d5,d2		| use d2.b as scratch
	andb	#1,d2		| test if 1 is shifted out
	orb	d2,d3		| and put it in sticky
	lsrl	#1,d4		| shift v.mant right the rest of the way
	roxrl	#1,d5		| to line it up with u.mant
4:	dbra	d1,0b		| loop

5:
	tstw	d2		| are the signs equal ?
	bpl	6f		| yes, no negate necessary
|
| negate second mantissa. One has to check the sticky word in order
| to correct the twos complement.
|
	tstw	d3		|
	beq     9f		| No correction necessary
	moveq	#0,d1
	addql   #1,d5
	addxl   d1,d4
9:	negl	d5
	negxl	d4

6:
	addl	d5,d7		| u.mant = u.mant + v.mant
	addxl	d4,d6
	bcs	7f		| need not negate
	tstw	d2		| opposite signs ?
	bpl	7f		| do not need to negate result

	negl	d7
	negxl	d6
	notl    d2		| switch sign
7:
	movel	d6,d4		| move result for normalization
	movel	d7,d5
	moveq	#0,d1
	tstl    d3
	beq     8f
	moveql   #-1,d1
8:	swap	d2		| put sign into d2 (exponent is in d0)
	jmp	norm_df		| leave registers on stack for norm_df
#else	sfp004
| double precision floating point stuff for Atari-gcc using the SFP004
| developed with gas
|
| double floating point add/subtract routine
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

__subdf3:
___subdf3:
| double precision subtraction
| sub second arg from fp0
	lea	0xfffffa50:w,a0
	movew	#0x5400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	sp@(4),a0@
	movel	sp@(8),a0@
	movew	#0x5428,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	sp@(12),a0@
	movel	sp@(16),a0@
	movew	#0x7400,a0@(comm)	| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
 	rts

__adddf3:
___adddf3:
	lea	0xfffffa50:w,a0
	movew	#0x5400,a0@(comm)		| load fp0
	cmpiw	#0x8900,a0@(resp)		| got it?
	movel	sp@(4),a0@			| take a hi from stack to FPU
	movel	sp@(8),a0@			| take a lo from stack to FPU
	movew	#0x5422,a0@(comm)		| add second arg to fp0
	.long	0x0c688900, 0xfff067f8
	movel	sp@(12),a0@			| move b hi from stack to FPU
	movel	sp@(16),a0@			| move b lo from stack to FPU
	movew	#0x7400,a0@(comm)		| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0				| download result
	movel	a0@,d1				| download result
 	rts
#endif	sfp004
#endif	__M68881__

#else

;
; double floating point add/subtract routine
;
	.text
	.even
#ifdef GNUNAMES
	.globl	__subdf3, ___subdf3
	.globl	__adddf3, ___adddf3
__subdf3:
___subdf3:
#else
	.globl	fpdsub
	.globl	fpdadd
#endif /* GNUNAMES */
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
; Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
;
; Revision 1.3.6 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
;   + ensure that x - x always returns +0, says IEEE,
;     unless x is Inf or NaN - then return NaN
;
; Revision 1.3.5 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
;   + code smoothing
;
; patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
;
; Revision 1.3.4 olaf 11-92 :
;  + added support for NaN and infinities
;    > floating point is now excellent!
;
;  -- still lacks trap handling for exceptions
;  -- dont know the external representation of quiet and signaling NaN
;     I decided 0x7fffffff,ffffffff to be a quiet NaN
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
;     >paranoia now detects no SERIOUS DEFECTS any more
;     ** Patches need _normdf Rev 1.6.1 (or higher) **
;
; Revision 1.3, kub 01-90 :
; added support for denormalized numbers
;
; Revision 1.2, kub 01-90 :
; replace far shifts by swaps to gain speed
;
; Revision 1.1, kub 12-89 :
; Ported over to 68k assembler
;
; Revision 1.0:
; original 8088 code from P.S.Housel

fpdsub:
	eor.b	#$80,12(sp)	; reverse sign of v
fpdadd:
#ifdef GNUNAMES
__adddf3:
___adddf3:
#endif /* GNUNAMES */
	lea	4(sp),a0	; pointer to u and v parameter
	movem.l	d2-d7,-(sp)	; save registers
	movem.l	(a0),d4-d5/d6-d7	; d4-d5 = v, d6-d7 = u

	move.l	#$0fffff,d3
	move.l	d6,d0		; d0 = u.exp
	and.l	d3,d6		; remove exponent from u.mantissa
	move.l	d0,d2		; d2.h = u.sign
	swap	d0
	move.w	d0,d2		; d2.l = u.sign

	move.l	d4,d1		; d1 = v.exp
	and.l	d3,d4		; remove exponent from v.mantissa
	swap	d1
	eor.w	d1,d2		; d2.l = u.sign ^ v.sign (in bit 15)
	clr.b	d2		; we will use the lowest byte as a flag
	moveq	#15,d3
	bclr	d3,d0		; kill sign bit u.exp
	bclr	d3,d1		; kill sign bit v.exp
	btst	d3,d2		; same sign for u and v?
	beq	l01
	cmp.l	d0,d1		; different signs - maybe x - x ?
	bne	l01
	cmp.l	d5,d7
	seq	d2		; set 'cancellation' flag

l01:	lsr.w	#4,d0		; keep here exponents only
	lsr.w	#4,d1
;
; Now perform testing of NaN and infinities
;
	move.w	#$7ff,d3
	cmp.w	d3,d0
	beq	l02
	cmp.w	d3,d1
	bne	nospec
	bra	l11
;
;	u is special
;
l02:	tst.b	d2		
	bne	retnan		; cancellation of specials -> NaN
	move.l	d7,d0
	or.l	d6,d0
	bne	retnan		; arith with Nan gives always NaN
	addq.w	#8,a0		; adding to an address propagates anyway
	cmp.w	d3,d1
	bne	l03		; skip check for NaN if v not special
;
;	v is special
;
l11:	move.l	d5,d0
	or.l	d4,d0
	bne	retnan
l03:	move.l	(a0),d0		; copy infinity
	moveq	#0,d1
	bra 	return
;
; return a quiet NaN
;
retnan: moveq.l	#-1,d1
	move.l	d1,d0
	lsr.l	#1,d0		; 0x7fffffff -> d0
	bra	return
;
; Ok, no inifinty or NaN involved..
;
nospec: tst.b	d2
	beq	l04
	moveq	#0,d0		; x - x hence we always return +0
	move.l	d0,d1
return:	movem.l	(sp)+,d2-d7
	rts

l04:	moveq	#20,d3
	bset	d3,d6		; restore implied leading "1"
	tst.w	d0		; check for zero exponent - no leading "1"
	bne	l12
	bclr	d3,d6		; no implied leading "1", instead ...
	addq.w	#1,d0		; "normalize" exponent
l12:
	bset	d3,d4		; restore implied leading "1"
	tst.w	d1		; check for zero exponent - no leading "1"
	bne	l13
	bclr	d3,d4		; no implied leading "1", instead ...
	addq.w	#1,d1		; "normalize" exponent
l13:
	moveq	#0,d3		; init sticky register
	neg.w	d1		; d1 = u.exp - v.exp
	add.w	d0,d1
	beq	l5		; exponents are equal - no shifting neccessary
	bgt	l14		; not equal but no exchange neccessary
	exg	d4,d6		; exchange u and v
	exg	d5,d7
	sub.w	d1,d0		; d0 = u.exp - (u.exp - v.exp) = v.exp
	neg.w	d1
	tst.w	d2		; d2.h = u.sign ^ (u.sign ^ v.sign) = v.sign
	bpl	l14
	bchg	#31,d2
l14:
	cmp.w	#55,d1		; is u so much bigger that v is not
	bge	l7		; significant ?
;
; shift mantissa left two digits, to allow cancellation of
; most significant digit, while gaining an additional digit for
; rounding.
;
	moveq	#1,d3
l21:	add.l	d7,d7
	addx.l	d6,d6
	subq.w	#1,d0		; decrement exponent
	subq.w	#1,d1		; decrement counter
	dbeq    d3,l21
	moveq	#0,d3
;
; now shift other mantissa right as fast as possible (almost).
;
l31:
	cmp.w	#16,d1		; see if fast rotate possible
	blt	l4
	or.w	d5,d3		; set sticky word
	move.w	d4,d5		; rotate by swapping register halfs
	swap	d5
	clr.w	d4
	swap	d4
	subq.w	#8,d1
	subq.w	#8,d1
	bra	l31

l0b:	move.b  d5,d2		; use d2.b as scratch
	and.b	#1,d2		; test if 1 is shifted out
	or.b	d2,d3		; and put it in sticky
	lsr.l	#1,d4		; shift v.mant right the rest of the way
	roxr.l	#1,d5		; to line it up with u.mant
l4:	dbra	d1,l0b		; loop

l5:
	tst.w	d2		; are the signs equal ?
	bpl	l6		; yes, no negate necessary
;
; negate second mantissa. One has to check the sticky word in order
; to correct the twos complement.
;
	tst.w	d3		;
	beq     l9		; No correction necessary
	moveq	#0,d1
	addq.l  #1,d5
	addx.l  d1,d4
l9:	neg.l	d5
	negx.l	d4

l6:
	add.l	d5,d7		; u.mant = u.mant + v.mant
	addx.l	d4,d6
	bcs	l7		; need not negate
	tst.w	d2		; opposite signs ?
	bpl	l7		; do not need to negate result

	neg.l	d7
	negx.l	d6
	not.l   d2		; switch sign
l7:
	move.l	d6,d4		; move result for normalization
	move.l	d7,d5
	moveq	#0,d1
	tst.l   d3
	beq     l8
	moveq.l #-1,d1
l8:	swap	d2		; put sign into d2 (exponent is in d0)
	jmp	norm_df		; leave registers on stack for norm_df

#endif SOZOBON
