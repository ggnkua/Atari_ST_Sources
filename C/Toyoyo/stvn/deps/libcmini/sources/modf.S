#include "libc-symbols.h"

#if !defined (__M68881__) && !defined (sfp004)

 | take floating point to integer and fractional pieces
 |
 | C interface
 |  double modf( double value, double *iptr)
 |  returns fractional part of value
 |	   in *iptr returns the integral part
 |	   such that (*iptr + fractional) == value
 |
 |-----------------------------------------------------------------------------
 | ported to 68000 by Kai-Uwe Bloem, 12/89
 |  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
 |  #2  replaced shifts by swap if possible for speed increase	-kub-, 01/90
 |  #3  ported to gcc ++jrb 03/90
 |  #4  replaced by a completely new, smaller and faster implementation,
 |        Michal Jaegermann, ntomczak@vm.ucs.ualberta.ca - 05/93
 |-----------------------------------------------------------------------------

BIAS8	=	0x3ff - 1

	.text
	.even
	.globl C_SYMBOL_NAME(modf)
C_SYMBOL_NAME(modf):
	lea	%sp@(4),%a1	| a1 -> float argument
#ifdef __mcoldfire__
	lea	%sp@(-24),%sp
	moveml	%d2-%d7,%sp@	| save d2-d7
	movel	%a1@+,%d0
	movel	%a1@+,%d1
#else
	moveml	%d2-%d7,%sp@-	| save d2-d7
	moveml	%a1@+,%d0-%d1
#endif
#ifndef __FASTCALL__
	movel   %a1@,%a0		| a0 -> ipart result
#endif

	movel	%d0,%d2		| calculate exponent
	swap	%d2
#ifdef __mcoldfire__
	andil	#0x7fff,%d2	| kill sign bit
	lsrl	#4,%d2
#else
	bclr	#15,%d2		| kill sign bit
	lsrw	#4,%d2		| exponent in lower 12 bits of d2
#endif

	cmpw	#BIAS8,%d2
	jgt	1f		| fabs(value) >= 1.0
|				| return entire value as fractional part
	clrl	%a0@+		| d0, d1 already ok
	clrl	%a0@		| make integer part 0

0:
#ifdef __mcoldfire__
	moveml	%sp@,%d2-%d7	| restore saved d2-d7
	lea	%sp@(24),%sp
#else
	moveml	%sp@+,%d2-%d7	| restore saved d2-d7
#endif
	rts

1:
#ifdef __mcoldfire__
	movel	#BIAS8+53,%d3
	subl	%d2,%d3		| compute position of "binary point"
#else
	movew	#BIAS8+53,%d3
	subw	%d2,%d3		| compute position of "binary point"
#endif
	jgt	2f		| branch if we do have fractional part

	moveml  %d0-%d1,%a0@	| store entire value as the integer part
	moveq	#0,%d0		| return zero as fractional part
	movel	%d0,%d1
	jra	0b
2:
	movel	%d1,%d5		| save for computation of fractional part

	moveq	#32,%d6
	cmpw	%d6,%d3
	jlt	3f		| jump if "binary point" in a lower part
	movel	%d0,%d4
#ifdef __mcoldfire__
	subl	%d6,%d3
#else
	subw	%d6,%d3
#endif
	moveq	#0,%d6		| compute mask for splitting
	bset	%d3,%d6
	negl	%d6
	andl	%d6,%d0		| this is integer part
	moveq	#0,%d1
	notl	%d6
	andl	%d6,%d4		| and denormalized fractional part
	jra	4f
3:
	moveq	#0,%d6		| splitting on lower part
	bset	%d3,%d6
	negl	%d6
	andl	%d6,%d1		| this is integer part
	moveq	#0,%d4		| nothing in an upper fraction
	notl	%d6
	andl	%d6,%d5		| and clear those unneded bits
4:
	moveml	%d0-%d1,%a0@	| store computed integer part

	swap	%d0
#ifdef __mcoldfire__
	movl	%d2,%d3		| set registers for norm_df
	movl	%d0,%d2
	movl	%d3,%d0
#else
	exg	%d0,%d2		| set registers for norm_df
#endif
	clrw	%d1		| rounding = 0
|				| normalize fractional part
	jmp	C_SYMBOL_NAME(__norm_df)	| norm_df will pop d2/d7 we saved before
				| it will return to our caller via rts
				| with result in d0-d1

#endif	/* __M68881__, sfp004	*/
#ifdef	__M68881__
|
| modf: compiled by gcc from math-68881.h
|       manually optimized by Michael Ritzert
|
|	double modf( double X, double * IP )
|
|	30.11.92
|	ritzert@dfg.dbp.de
|

	.text
	.even

	.globl C_SYMBOL_NAME(modf)

C_SYMBOL_NAME(modf):
#ifndef __FASTCALL__
	fmoved	%sp@(4),%fp0	| load arg
	movel	%sp@(12),%a0	| get pointer to IP
#endif
	fintrzx	%fp0,%fp1		| get int part
	fmoved	%fp1,%a0@		| return it to IP
	fsubx 	%fp1,%fp0		| get remainder
#ifndef __FASTCALL__
	fmoved	%fp0,%sp@-	| return it
	moveml	%sp@+,%d0-%d1	|
#endif
	rts

#endif /* __M68881__ */
#ifdef sfp004

comm =	 -6
resp =	-16
zahl =	  0

.even
.text
	.globl C_SYMBOL_NAME(modf)
.even
C_SYMBOL_NAME(modf):
	lea	0xfffffa50:w,%a1
	movew	#0x5403,%a1@(comm)	| fintrz X -> fp0
	cmpiw	#0x8900,%a1@(resp)	| check
	movel	%sp@(4),%a1@		| load X_hi
	movel	%sp@(8),%a1@		| load X_low

	movew	#0x5480,%a1@(comm)	| X -> fp1
	.long	0x0c688900, 0xfff067f8
	movel	%sp@(4),%a1@		| load X_hi
	movel	%sp@(8),%a1@		| load X_low

|	000 000 001 0101000		| sub fp0 -> fp1
	movew	#0x00a8,%a1@(comm)	| sub fp0 -> fp1
	.word	0x4a68,0xfff0,0x6bfa	| test

	movew	#0x7400,%a1@(comm)	| fp0 to IntPart
#ifndef __FASTCALL__
	moveal	%sp@(12),%a0		| address of IntPart while the fpu is active
#endif
| wait
	.long	0x0c688900, 0xfff067f8
	movel	%a1@,%a0@+
	movel	%a1@,%a0@+
	movew	#0x7480,%a1@(comm)	| Rest to d0/d1
| wait
	.long	0x0c688900, 0xfff067f8
	movel	%a1@,%d0
	movel	%a1@,%d1
 	rts

#endif	/* sfp004 */
