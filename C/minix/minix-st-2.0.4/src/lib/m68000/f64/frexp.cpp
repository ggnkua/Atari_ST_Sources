#ifndef SOZOBON
#if !defined (__M68881__) && !defined (sfp004)
#
 |-----------------------------------------------------------------------------
 | remove exponent from floating point number
 | C Interface
 | double frexp(double value, int *eptr)
 |
 | returns significand (|significand| < 1)
 |	   in *eptr returns n such that value = significand * 2**n
 |-----------------------------------------------------------------------------
 | ported to 68000 by Kai-Uwe Bloem, 12/89
 |  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
 |  #2	added support for denormalized numbers			-kub-, 01/90
 |  #3  ported to gcc  ++jrb 04/90
 |  #4  support for signed 0 - consistently with the rest - michal, 05/93
 |      and some code cleanup
 |  #5  fixed __MSHORT__ bug - V.S. 11/93
 |-----------------------------------------------------------------------------

BIAS8	=	0x3ff - 1

	.text; .even
	.globl _frexp
_frexp:
	movel	sp@(12),a0	| initialize exponent for loop
#ifdef __MSHORT__
	clrw	a0@
#else
	clrl	a0@
#endif
	lea	sp@(4),a1	| sp@(4) -> a1 - an address of value
|				|   and a1@(8) - an address of *eptr
	movel	a1@,d0		| keep value.sign
	movel	d0,d1
	bclr	#31,d1		| kill sign bit
	tstl	d1		| 1st arg == 0 ?
	bne	nonzero
	tstl	a1@(4)
	bne	nonzero
	rts			| if 0 or -0 then d0 and d1 already set
nonzero:
	movel	d2,sp@-
2:				| return here when looping
	swap	d0		| sign and exponent into lower 16 bits
	movew	d0,d2		| set d2 for norm_df
	bclr	#15,d0		| kill sign bit
	lsrw	#4,d0

	cmpw	#BIAS8,d0	| get out of loop if finally (a1) in [0.5,1.0)
	beq	3f

	moveq	#0x0f,d1	| remove exponent from value.mantissa
	andb	d2,d1		| four upper bits of value in d1
	bset	#4,d1		| implied leading 1
	tstw	d0		| check for zero exponent
	bne	1f
	addqw	#1,d0
	bclr	#4,d1		| nah, we do not need stinkin leadin 1
1:	movew	d1,a1@		| save results of our efforts

	movel	a1@,d1		| check for zero
	orl	a1@(4),d1
	beq	3f		| if zero, all done : exp = 0, num = 0.0
				| sign of zero is correct
	subw	#BIAS8,d0	| remove bias
#ifdef __MSHORT__
	addw	d0,a0@		| add current exponent in
#else
	extl	d0
	addl	d0,a0@		| add current exponent in
#endif

	movew	#BIAS8,d0	| set bias for return value
	clrw	d1		| rounding = 0
	pea	L0		| call to norm_df (dirty, but dont ...
	moveml	d2-d7,sp@-	| ... need to copy with -mshort)
	moveml	a1@,d4-d5
	jmp	norm_df		| normalize result
L0:				| norm_df does not affect a0 or a1
|				| but it pops d2-d7
	moveml	d0-d1,a1@
	bra	2b		| loop around to catch denormalized numbers
3:
	moveml	a1@,d0-d1
	movel	sp@+,d2
				| d0-d1 has normalized mantissa
	rts

#endif	!__M68881__ && !sfp004
#ifdef	__M68881__

|
| remove exponent from floating point number
| C Interface
| double frexp(double value, int *eptr)
|
| returns significand (#significand# < 1)
|	   in *eptr returns n such that value = significand * 2**n
|#######################################################################
| hacked for the 68881 by Michael Ritzert, 5.10.90
|#######################################################################
| ported from sfp004 board to real 68881, mjr, August 1991
|#######################################################################
| a0:	pointer to n
| 	sp@(12) address of resulting exponent (n)

	.text; .even

.globl _frexp

_frexp:
	moveal	a7@(12),a1		| address of n
	fmoved	a7@(4),fp0		| load first_argument to fp0
	fcmpd	#0r0.0,fp0		| 1st arg == 0 ?
	fjeq	null_			| both parts of result are 0
	fgetexpx fp0,fp1		| get expnent
	fgetmanx fp0,fp0		| get mantissa
	fscaleb #-1,fp0			|
#ifdef __MSHORT__
	fmovew	fp1,a1@			| fetch exp (fmovew from fp1)
	addqw	#1,a1@			| correct result
#else
	fmovel	fp1,a1@			| fetch exp (fmovel from fp1)
	addql	#1,a1@			| correct result
#endif
	fmoved	fp0,a7@-		| now fetch significand
	moveml	a7@+,d0-d1
	rts
null_:
	moveml	a7@(4),d0-d1
#ifdef __MSHORT__
	clrw	a1@
#else
	clrl	a1@
#endif
	rts

#endif	__M68881__
#ifdef	sfp004

| remove exponent from floating point number
| C Interface
| double frexp(double value, int *eptr)
|
| returns significand (|significand| < 1)
|	   in *eptr returns n such that value = significand * 2**n
|
| hacked for the 68881 by Michael Ritzert, 5.10.90/18.12.91
|
| addresses of the 68881 data port. This choice is fastest when much data is
| transferred between the two processors.

comm =	 -6	|	fpu command reg
resp =	-16	|	fpu response reg
zahl =	  0	|	fpu data reg

| a1:	fpu base register
| a0:	pointer to n
| 	sp@(12) address of resulting exponent (n)

| waiting loop ...
|
| wait:
| ww:	cmpiw	#0x8900,a0@(resp)
| 	beq	ww
| is coded directly by
|	.long	0x0c688900, 0xfff067f8                 (fpu base a1)
| and
| www:	tst.w	a0@(resp)
|	bmi.b	www
| is coded by
|	.word	0x4a68,0xfff0,0x6bfa		| test

	.text; .even

.globl _frexp

_frexp:
	tstl	sp@(4)		| 1st arg == 0 ?
	bne	nonzero
	tstl	sp@(8)
	bne	nonzero
	movel	sp@(12),a0
#ifdef __MSHORT__
	clrw	a0@
#else
	clrl	a0@
#endif
	clrl	d0
	clrl	d1
	rts
nonzero:
	lea	0xfffffa50:w,a0
	movew	#0x5418,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@

	movew	#0x009f,a0@(comm)	| fgetman fp0,fp1
	.word	0x4a68,0xfff0,0x6bfa	| test

	movew	#0x001e,a0@(comm)	| fgetexp fp0,fp0
	moveal	a7@(12),a1		| address of n while the fpu is active
	.word	0x4a68,0xfff0,0x6bfa	| test

	movew	#5026,a0@(comm)		| fscalew #-1,fp0
	.long	0x0c688900, 0xfff067f8
	movew	#-1,a0@

#ifdef __MSHORT__
	movew	#0x7080,a0@(comm)	| fetch exp (fmovew from fp1)
	.long	0x0c688900, 0xfff067f8
	movew	a0@,a1@			| return exp
#else
	movew	#0x6080,a0@(comm)	| fetch exp (fmovel from fp1)
	.long	0x0c688900, 0xfff067f8
	movel	a0@,a1@			| return exp
#endif
	movew	#0x7400,a0@(comm)	| now fetch significand
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	btst	#31,a7@(4)		| test sign of 1st arg
	bge	fini			| arg neg ?
	bset	#31,d0			| =>  negate result
fini:	rts

#endif	sfp004

#else

 ;-----------------------------------------------------------------------------
 ; remove exponent from floating point number
 ; C Interface
 ; double frexp(double value, int *eptr)
 ;
 ; returns significand (;significand; < 1)
 ;	   in *eptr returns n such that value = significand * 2**n
 ;-----------------------------------------------------------------------------
 ; ported to 68000 by Kai-Uwe Bloem, 12/89
 ;  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
 ;  #2	added support for denormalized numbers			-kub-, 01/90
 ;  #3  ported to gcc  ++jrb 04/90
 ;  #4  support for signed 0 - consistently with the rest - michal, 05/93
 ;      and some code cleanup
 ;  #5  fixed __MSHORT__ bug - V.S 11/93
 ;-----------------------------------------------------------------------------

BIAS8	.equ	$3ff - 1

	.text
	.even
	.globl _frexp
_frexp:
	move.l	12(sp),a0	; initialize exponent for loop
#ifdef __MSHORT__
	clr.w	(a0)
#else
	clr.l	(a0)
#endif
	lea	4(sp),a1	; sp@(4) -> a1 - an address of value
;				;   and a1@(8) - an address of *eptr
	move.l	(a1),d0		; keep value.sign
	move.l	d0,d1
	bclr	#31,d1		; kill sign bit
	tst.l	d1		; 1st arg == 0 ?
	bne	nonzero
	tst.l	4(a1)
	bne	nonzero
	rts			; if 0 or -0 then d0 and d1 already set
nonzero:
	move.l	d2,-(sp)
l2:				; return here when looping
	swap	d0		; sign and exponent into lower 16 bits
	move.w	d0,d2		; set d2 for norm_df
	bclr	#15,d0		; kill sign bit
	lsr.w	#4,d0

	cmp.w	#BIAS8,d0	; get out of loop if finally (a1) in [0.5,1.0)
	beq	l3

	moveq	#$0f,d1		; remove exponent from value.mantissa
	and.b	d2,d1		; four upper bits of value in d1
	bset	#4,d1		; implied leading 1
	tst.w	d0		; check for zero exponent
	bne	l1
	addq.w	#1,d0
	bclr	#4,d1		; nah, we do not need stinkin leadin 1
l1:	move.w	d1,(a1)		; save results of our efforts

	move.l	(a1),d1		; check for zero
	or.l	4(a1),d1
	beq	l3		; if zero, all done : exp = 0, num = 0.0
				; sign of zero is correct
	sub.w	#BIAS8,d0	; remove bias
#ifdef __MSHORT__
	add.w	d0,(a0)		; add current exponent in
#else
	ext.l	d0
	add.l	d0,(a0)		; add current exponent in
#endif

	move.w	#BIAS8,d0	; set bias for return value
	clr.w	d1		; rounding = 0
	pea	L0		; call to norm_df (dirty, but dont ...
	movem.l	d2-d7,-(sp)	; ... need to copy with -mshort)
	movem.l	(a1),d4-d5
	jmp	norm_df		; normalize result
L0:				; norm_df does not affect a0 or a1
;				; but it pops d2-d7
	movem.l	d0-d1,(a1)
	bra	l2		; loop around to catch denormalized numbers
l3:
	movem.l	(a1),d0-d1
	move.l	(sp)+,d2
				; d0-d1 has normalized mantissa
	rts

#endif /* SOZOBON */
