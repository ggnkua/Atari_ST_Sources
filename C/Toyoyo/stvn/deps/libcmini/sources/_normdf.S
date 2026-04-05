| mjr: not needed _normdf for -__HAVE_68881__ or the sfp004

|#######################################################################

| double floating point normalization routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
| Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 1.6.3 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
|  + restored and ensured future synchronization with errno codes
|  + removed bogus error when normalizing legitimate zero
|  + small mods to shave off few cycles
|
| patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
|
| Revision 1.6.2 olaf 12-92:
|  + added support for -0.
|
| Revision 1.6.1 olaf 10-92:
|  + corrected rounding in tie case: round up, not down.
|    (needed for enquire 4.3)
|
| Revision 1.6, kub 04-90 :
| more robust handling exponent and sign handling for 32 bit integers. There
| are now overflow tests for 32 bit exponents, and bit 31 of the sign flag
| is or ed to bit 15 for later checks (i.e. both bits 31 and 15 are now sign
| bits). Take care, the upper 16 bits of rounding info are ignored for 32 bit
| integers !
|
| Revision 1.5, ++jrb 03-90:
| change __normdf interface to expect ints instead of shorts. easier
| to interface to 32 bit int code. this file is now pre-processed,
| with __MSHORT__ defined when ints are 16 bits.
|
| Revision 1.4, kub 03-90 :
| export ___normdf entry to C language. Rename the internal entry to a name
| not accessible from C to prevent crashes
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

#include "libc-symbols.h"

	.text
	.even
	.globl	C_SYMBOL_NAME(_infinitydf)

#if !defined (__HAVE_68881__) && !defined (sfp004)
	.globl	C_SYMBOL_NAME(__normdf)
	.globl	C_SYMBOL_NAME(__norm_df)
#include "errbase.h"
# ifdef	ERROR_CHECK
LC0:
	.ascii "normdf: OVERFLOW\12\15\0"
	.even
# endif	/* ERROR_CHECK */

	| C entry, for procs dealing with the internal representation :
	| double __normdf(long long mant, int exp, int sign, int rbits);
C_SYMBOL_NAME(__normdf):
/* note: long long value is passed on stack, even for -mfastcall */
	lea	%sp@(4),%a0	| parameter pointer
#ifdef __mcoldfire__
	lea	%sp@(-24),%sp
	moveml	%d2-%d7,%sp@	| save working registers
	movel	%a0@+,%d4		| get mantissa
	movel	%a0@+,%d5
#else
	moveml	%d2-%d7,%sp@-	| save working registers
	moveml	%a0@+,%d4-%d5	| get mantissa
#endif

# ifdef __MSHORT__
#ifdef __FASTCALL__
#ifdef __mcoldfire__
	movel   %d2,%d3
	movel   %d1,%d2
	movel   %d3,%d1
#else
	exg		%d1,%d2
#endif
#else
	movew	%a0@+,%d0		| get exponent
	movew	%a0@+,%d2		| get sign
	movew	%a0@+,%d1		| rounding information
#endif
# else
#ifdef __FASTCALL__
#ifdef __mcoldfire__
	movel   %d2,%d3
	movel   %d1,%d2
	movel   %d3,%d1
#else
	exg		%d1,%d2
#endif
#else
	movel	%a0@+,%d0		| get exponent
	movel	%a0@+,%d2		| get sign
	movel	%a0@+,%d1		| rounding information
#endif
	tstl	%d2
	jpl	0f		| or bit 31 to bit 15 for later tests
	bset	#15,%d2
0:	movel	#0x7fff,%d3
	cmpl	%d3,%d0		| test exponent
	jgt	oflow
	notl	%d3		| #-0x8000 -> d3
	cmpl	%d3,%d0
	jlt	retz
# endif

	| internal entry for floating point package, saves time
	| d0=u.exp, d2=u.sign, d1=rounding bits, d4/d5=mantissa
	| registers d2-d7 must be saved on the stack !
C_SYMBOL_NAME(__norm_df):
#ifdef __mcoldfire__
	movel	#0xffff,%d3	| clean high words of arguments
	andl	%d3,%d0
	andl	%d3,%d1
	andl	%d3,%d2
#endif
	movel	%d4,%d3		| rounding and u.mant == 0 ?
	orl	%d5,%d3
	jne	1f
	tstb	%d1
	jeq	retzok
1:
	movel	%d4,%d3
	andl	#0xfffff000,%d3	| fast shift, 16 bits ?
	jne	2f
	cmpw	#9,%d0		| shift is going to far; do normal shift
	jle	2f		|  (minimize shifts here : 10l = 16l + 6r)
	swap	%d4		| yes, swap register halfs
	swap	%d5
	movew	%d5,%d4
	moveb	%d1,%d5		| some doubt about this one !
#ifdef __mcoldfire__
	movew	%d5,%d3
	lsll	#8,%d3
	movew	%d3,%d5
#else
	lslw	#8,%d5
#endif
	clrw	%d1
#ifdef __mcoldfire__
	subl	#16,%d0		| account for swap
#else
	subw	#16,%d0		| account for swap
#endif
	jra	1b
2:
#ifdef __mcoldfire__
	andil	#0xffffff00,%d2	| sticky byte
#else
	clrb	%d2		| sticky byte
#endif
	movel	#0xffe00000,%d6
3:	tstw	%d0		| divide (shift)
	jle	0f		|  denormalized number
	movel	%d4,%d3
	andl	%d6,%d3		|  or until no bits above 53
	jeq	4f
#ifdef __mcoldfire__
0:	addl	#1,%d0		| increment exponent
	movew	%d4,%d3		| backup bit 0 of highest long
	lsrl	#1,%d4
	lsrl	#1,%d5
	lsrl	#1,%d1		| shift into rounding bits
	btst	#0,%d3
	jeq	33f
	bset	#31,%d5
	bset	#7,%d1
33:	orl	%d1,%d2		| set sticky
#else
0:	addw	#1,%d0		| increment exponent
	lsrl	#1,%d4
	roxrl	#1,%d5
	orb	%d1,%d2		| set sticky
	roxrb	#1,%d1		| shift into rounding bits
#endif
	jra	3b
4:
#ifdef __mcoldfire__
	andl	#0xffffff01,%d2
	movel	%d2,%d3
	andil	#1,%d3
	orl	%d3,%d1		| make least sig bit sticky
#else
	andb	#1,%d2
	orb	%d2,%d1		| make least sig bit sticky
#endif
	asrl	#1,%d6		| #0xfff00000 -> d6
5:	movel	%d4,%d3		| multiply (shift) until
	andl	%d6,%d3		| one in implied position
	jne	6f
#ifdef __mcoldfire__
	subl	#1,%d0		| decrement exponent
#else
	subw	#1,%d0		| decrement exponent
#endif
	jeq	6f		|  too small. store as denormalized number
#ifdef __mcoldfire__
	addl	%d1,%d1		| some doubt about this one *
#else
	addb	%d1,%d1		| some doubt about this one *
#endif
	addxl	%d5,%d5
	addxl	%d4,%d4
	jra	5b
6:
	tstb	%d1		| check rounding bits
	jge	8f		| round down - no action neccessary
#ifdef __mcoldfire__
	cmpb	#0x80,%d1
	jne	7f		| round up
	movew   %d5,%d1           | tie case - round to even
				| dont need rounding bits any more
	andl    #1,%d1           | check if even
#else
	negb	%d1
	jvc	7f		| round up
	movew   %d5,%d1           | tie case - round to even
				| dont need rounding bits any more
	andw    #1,%d1           | check if even
#endif
	jeq     8f              | mantissa is even - no action necessary
				| fall through
7:
	clrl	%d1		| zero rounding bits
	addl	#1,%d5
	addxl	%d1,%d4
	tstw	%d0
	jne	0f		| renormalize if number was denormalized
#ifdef __mcoldfire__
	addl	#1,%d0		| correct exponent for denormalized numbers
#else
	addw	#1,%d0		| correct exponent for denormalized numbers
#endif
	jra	2b
0:	movel	%d4,%d3		| check for rounding overflow
	asll	#1,%d6		| #0xffe00000 -> d3
	andl	%d6,%d3
	jne	2b		| go back and renormalize
8:
	movel	%d4,%d3		| check if normalization caused an underflow
	orl	%d5,%d3
	jeq	retz
	tstw	%d0		| check for exponent overflow or underflow
	jlt	retz
	cmpw	#2047,%d0
	jge	oflow

#ifdef __mcoldfire__
	swap	%d0		| map to upper word
	lsll	#4,%d0		| re-position exponent
	andil	#0x7ff00000,%d0
	btst	#15,%d2
	jeq	9f
	bset 	#31,%d0
9:
#else
	lslw	#5,%d0		| re-position exponent - one bit too high
	lslw	#1,%d2		| get X bit
	roxrw	#1,%d0		| shift it into sign position
	swap	%d0		| map to upper word
	clrw	%d0
#endif
	andl	#0x0fffff,%d4	| top mantissa bits
	orl	%d0,%d4		| insert exponent and sign
	movel	%d4,%d0
	movel	%d5,%d1
#ifdef __mcoldfire__
	moveml	%sp@,%d2-%d7
	lea	%sp@(24),%sp
#else
	moveml	%sp@+,%d2-%d7
#endif
	rts

retz:
	moveq	#Erange,%d0
	Emove   %d0,Errno
retzok:
	moveq	#0,%d0		| return zero value
	movel	%d0,%d1
#ifdef __mcoldfire__
	movw	%d2,%d0
	swap	%d0
	andil	#0x80000000,%d0
	moveml	%sp@,%d2-%d7
	lea	%sp@(24),%sp
#else
	lslw	#1,%d2		| set value of extension
	roxrl	#1,%d0		| and move it to hight bit of d0
	moveml	%sp@+,%d2-%d7
#endif
	rts

oflow:
#ifdef	ERROR_CHECK
#ifdef __FASTCALL__
	lea	%pc@(LC0),%a1
	movel	Stderr,%a0
	jbsr	C_SYMBOL_NAME(fprintf)	|
#else
	pea	%pc@(LC0)
	movel	Stderr,%sp@-
	jbsr	C_SYMBOL_NAME(fprintf)	|
	addql	#8,%sp		|
#endif
	moveq	#Erange,%d0
	Emove	%d0,Errno
#endif	/* ERROR_CHECK */

|	moveml	%pc@(C_SYMBOL_NAME(_infinitydf)),%d0-%d1 | return infinity value
#ifdef __mcoldfire__
	movel	C_SYMBOL_NAME(_infinitydf),%d0	| return infinty value
	movel	C_SYMBOL_NAME(_infinitydf+4),%d1
#else
	moveml	C_SYMBOL_NAME(_infinitydf),%d0-%d1 | return infinty value
#endif
	tstw	%d2
	jpl	1f
	bset	#31,%d0
1:
#ifdef __mcoldfire__
	moveml	%sp@,%d2-%d7	| should really cause trap ?!? (mjr: why?)
	lea	%sp@(24),%sp
#else
	moveml	%sp@+,%d2-%d7	| should really cause trap ?!? (mjr: why?)
#endif
	rts

#endif /* __HAVE_68881__ */
