#include "libc-symbols.h"

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
 |-----------------------------------------------------------------------------

BIAS8	=	0x3ff - 1

	.text; .even
	.globl C_SYMBOL_NAME(frexp)
C_SYMBOL_NAME(frexp):
#ifndef __FASTCALL__
	movel	%sp@(12),%a0	| initialize exponent for loop
#endif
#ifdef __MSHORT__
	clrw	%a0@
#else
	clrl	%a0@
#endif
	lea	%sp@(4),%a1	| sp@(4) -> a1 - an address of value
|				|   and a1@(8) - an address of *eptr
	movel	%a1@,%d0		| keep value.sign
	movel	%d0,%d1
	bclr	#31,%d1		| kill sign bit
	tstl	%d1		| 1st arg == 0 ?
	jne	nonzero
	tstl	%a1@(4)
	jne	nonzero
	rts			| if 0 or -0 then d0 and d1 already set
nonzero:
	movel	%d2,%sp@-
2:				| return here when looping
	swap	%d0		| sign and exponent into lower 16 bits
	movew	%d0,%d2		| set d2 for norm_df
#ifdef __mcoldfire__
	andil	#0x7fff,%d0	| kill sign bit
	lsrl	#4,%d0
#else
	bclr	#15,%d0		| kill sign bit
	lsrw	#4,%d0
#endif

	cmpw	#BIAS8,%d0	| get out of loop if finally (a1) in [0.5,1.0)
	jeq	3f

	moveq	#0x0f,%d1	| remove exponent from value.mantissa
#ifdef __mcoldfire__
	andl	%d2,%d1		| four upper bits of value in d1
#else
	andb	%d2,%d1		| four upper bits of value in d1
#endif
	bset	#4,%d1		| implied leading 1
	tstw	%d0		| check for zero exponent
	jne	1f
#ifdef __mcoldfire__
	addql	#1,%d0
#else
	addqw	#1,%d0
#endif
	bclr	#4,%d1		| nah, we do not need stinkin leadin 1
1:	movew	%d1,%a1@		| save results of our efforts

	movel	%a1@,%d1		| check for zero
	orl	%a1@(4),%d1
	jeq	3f		| if zero, all done : exp = 0, num = 0.0
				| sign of zero is correct
#ifdef __mcoldfire__
	subl	#BIAS8,%d0	| remove bias
#else
	subw	#BIAS8,%d0	| remove bias
#endif
#ifdef __MSHORT__
#ifdef __mcoldfire__
	move	%a0@,%d1
	addl	%d0,%d1		| add current exponent in
	move	%d1,%a0@
#else
	addw	%d0,%a0@		| add current exponent in
#endif
#else
	extl	%d0
	addl	%d0,%a0@		| add current exponent in
#endif

	movew	#BIAS8,%d0	| set bias for return value
	clrw	%d1		| rounding = 0
	pea	L0		| call to norm_df (dirty, but dont ...
#ifdef __mcoldfire__
	lea	%sp@(-24),%sp
	moveml	%d2-%d7,%sp@	| ... need to copy with -mshort)
#else
	moveml	%d2-%d7,%sp@-	| ... need to copy with -mshort)
#endif
	moveml	%a1@,%d4-%d5
	jmp	C_SYMBOL_NAME(__norm_df)	| normalize result
L0:				| norm_df does not affect a0 or a1
|				| but it pops d2-d7
	moveml	%d0-%d1,%a1@
	jra	2b		| loop around to catch denormalized numbers
3:
	moveml	%a1@,%d0-%d1
	movel	%sp@+,%d2
				| d0-d1 has normalized mantissa
	rts

#endif	/* !__M68881__ && !sfp004 */
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

	.text
	.even

.globl C_SYMBOL_NAME(frexp)

C_SYMBOL_NAME(frexp):
#ifndef __FASTCALL__
	moveal	%sp@(12),%a0		| address of n
#endif
	fmoved	%sp@(4),%fp0		| load first_argument to fp0
	fcmpd	#0r0.0,%fp0		| 1st arg == 0 ?
	fjeq	null_			| both parts of result are 0
	fgetexpx %fp0,%fp1		| get expnent
	fgetmanx %fp0,%fp0		| get mantissa
	fscaleb #-1,%fp0			|
#ifdef __MSHORT__
	fmovew	%fp1,%a0@			| fetch exp (fmovew from fp1)
	addqw	#1,%a0@			| correct result
#else
	fmovel	%fp1,%a0@			| fetch exp (fmovel from fp1)
	addql	#1,%a0@			| correct result
#endif
	fmoved	%fp0,%sp@-		| now fetch significand
	moveml	%sp@+,%d0-%d1
	rts
null_:
	moveml	%sp@(4),%d0-%d1
#ifdef __MSHORT__
	clrw	%a0@
#else
	clrl	%a0@
#endif
	rts

#endif	/* __M68881__ */
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

.globl C_SYMBOL_NAME(frexp)

C_SYMBOL_NAME(frexp):
	tstl	%sp@(4)		| 1st arg == 0 ?
	jne	nonzero
	tstl	%sp@(8)
	jne	nonzero
#ifndef __FASTCALL__
	movel	%sp@(12),%a0
#endif
#ifdef __MSHORT__
	clrw	%a0@
#else
	clrl	%a0@
#endif
	clrl	%d0
	clrl	%d1
	rts
nonzero:
	lea	0xfffffa50:w,%a1
	movew	#0x5418,%a1@(comm)	| load first argument to fp0
	cmpiw	#0x8900,%a1@(resp)	| check
	movel	%sp@(4),%a1@
	movel	%sp@(8),%a1@

	movew	#0x009f,%a1@(comm)	| fgetman fp0,fp1
	.word	0x4a68,0xfff0,0x6bfa	| test

	movew	#0x001e,%a1@(comm)	| fgetexp fp0,fp0
	.word	0x4a68,0xfff0,0x6bfa	| test

	movew	#5026,%a1@(comm)		| fscalew #-1,fp0
	.long	0x0c688900, 0xfff067f8
	movew	#-1,%a1@

#ifdef __MSHORT__
	movew	#0x7080,%a1@(comm)	| fetch exp (fmovew from fp1)
	.long	0x0c688900, 0xfff067f8
	movew	%a1@,%a0@			| return exp
#else
	movew	#0x6080,%a1@(comm)	| fetch exp (fmovel from fp1)
	.long	0x0c688900, 0xfff067f8
	movel	%a1@,%a0@			| return exp
#endif
	movew	#0x7400,%a1@(comm)	| now fetch significand
	.long	0x0c688900, 0xfff067f8
	movel	%a1@,%d0
	movel	%a1@,%d1
	btst	#31,%sp@(4)		| test sign of 1st arg
	jge	fini			| arg neg ?
	bset	#31,%d0			| =>  negate result
fini:	rts

#endif	/* sfp004 */
