|	new version of bcopy and memset
|	uses movem to set 256 bytes blocks faster.
|	Alexander Lehmann	alexlehm@iti.informatik.th-darmstadt.de
|	sortof inspired by jrbs bcopy
|	has to be preprocessed (int parameter in memset)

	.text
	.even

#include "libc-symbols.h"

#ifdef Lmemset
	.globl C_SYMBOL_NAME(memset)

|	void *memset( void *dest, int val, size_t len );
|	returns dest
|	two versions for 16/32 bits

C_SYMBOL_NAME(memset):
#ifndef __FASTCALL__
	movl	4(%sp),%a0	| dest
#ifdef __MSHORT__
	movb	9(%sp),%d0	| value
# ifndef __SOZOBON__
	movl	10(%sp),%d1	| length
# else
	clrl	%d1
	movw	10(%sp),%d1	| length
# endif
#else
	movb	11(%sp),%d0	| value
	movl	12(%sp),%d1	| length
#endif
#else
	tst.l   %d1
#endif
	jeq	exit		| length==0? (size_t)
#ifndef Lmemset
	jra	do_set
#endif
#endif /* Lmemset */

#ifndef Lmemset
	.globl C_SYMBOL_NAME(bzero)
	.globl C_SYMBOL_NAME(_bzero)
	.globl C_SYMBOL_NAME(__bzero)

|	void bzero( void *dest, size_t length );
|	void _bzero( void *dest, unsigned long length );
|	return value not used (returns dest)

#ifdef __SOZOBON__
C_SYMBOL_NAME(__bzero):
C_SYMBOL_NAME(bzero):
	movl	4(%sp),%a0	| dest
	clrl	%d1
	movw	8(%sp),%d1	| length
	jra	scommon
#else
C_SYMBOL_NAME(__bzero):
C_SYMBOL_NAME(bzero):
#endif
C_SYMBOL_NAME(_bzero):
#ifndef __FASTCALL__
	movl	4(%sp),%a0	| dest
	movl	8(%sp),%d1	| length
#else
	movl    %d0,%d1
#endif
scommon:
	jeq	exit		| length==0? (size_t)
	clrb	%d0		| value
#endif /* Lbzero */

do_set: 			| a0 dest, d0.b byte, d1.l length
	movel	%d2,-(%sp)

	addl	%d1,%a0		| a0 points to end of area, needed for predec

	movw	%a0,%d2		| test for alignment
	btst	#0,%d2		| odd ?
	jeq	areeven
	movb	%d0,-(%a0) 	| set one byte, now we are even
	subql	#1,%d1
areeven:
	movb	%d0,%d2
#ifdef __mcoldfire__
	lsll	#8,%d0
#else
	lslw	#8,%d0
#endif
	movb	%d2,%d0
	movw	%d0,%d2
	swap	%d2
	movw	%d0,%d2		| d2 has byte now four times

	movq	#0,%d0		| save length less 256
	movb	%d1,%d0
	lsrl	#8,%d1		| number of 256 bytes blocks
	jeq	less256
#ifdef __mcoldfire__
	lea	-40(%sp),%sp
	movml	%d0/%d3-%d7/%a2/%a3/%a5/%a6,(%sp)	| d2 is already saved
#else
	movml	%d0/%d3-%d7/%a2/%a3/%a5/%a6,-(%sp)	| d2 is already saved
#endif
				| exclude a4 because of -mbaserel
	movl	%d2,%d0
	movl	%d2,%d3
	movl	%d2,%d4
	movl	%d2,%d5
	movl	%d2,%d6
	movl	%d2,%d7
	movl	%d2,%a2
	movl	%d2,%a3
	movl	%d2,%a5
	movl	%d2,%a6
set256:
#ifdef __mcoldfire__
	lea	-256(%a0),%a0
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,212(%a0)	| set 5*44+36=256 bytes
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,168(%a0)
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,124(%a0)
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,80(%a0)
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,36(%a0)
	movml	%d0/%d2-%d7/%a2-%a3,(%a0)
#else
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,-(%a0)	| set 5*44+36=256 bytes
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,-(%a0)
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,-(%a0)
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,-(%a0)
	movml	%d0/%d2-%d7/%a2/%a3/%a5/%a6,-(%a0)
	movml	%d0/%d2-%d7/%a2-%a3,-(%a0)
#endif
	subql	#1,%d1
	jne	set256			| next, please
#ifdef __mcoldfire__
	movml	(%sp),%d0/%d3-%d7/%a2/%a3/%a5/%a6
	lea	40(%sp),%sp
#else
	movml	(%sp)+,%d0/%d3-%d7/%a2/%a3/%a5/%a6
#endif
less256:			| set 16 bytes blocks
	movw	%d0,-(%sp) 	| save length below 256 for last 3 bytes
#ifdef __mcoldfire__
	lsrl	#2,%d0
	jeq	less4		| less that 4 bytes left
	movl	%d0,%d1
	negl	%d1
	andil	#3,%d1		| d1 = number of bytes below 16 (-n)&3
	subql	#1,%d0
	lsrl	#2,%d0		| number of 16 bytes blocks minus 1, if d1==0
	addl	%d1,%d1		| offset in code (movl two bytes)
	jmp	2(%pc,%d1.l)	| jmp into loop
#else
	lsrw	#2,%d0		| number of 4 bytes blocks
	jeq	less4		| less that 4 bytes left
	movw	%d0,%d1
	negw	%d1
	andiw	#3,%d1		| d1 = number of bytes below 16 (-n)&3
	subqw	#1,%d0
	lsrw	#2,%d0		| number of 16 bytes blocks minus 1, if d1==0
	addw	%d1,%d1		| offset in code (movl two bytes)
	jmp	2(%pc,%d1.w)	| jmp into loop
#endif
set16:
	movl	%d2,-(%a0)
	movl	%d2,-(%a0)
	movl	%d2,-(%a0)
	movl	%d2,-(%a0)
#ifdef __mcoldfire__
	subql	#1,%d0
	bpl	set16
#else
	dbra	%d0,set16
#endif
less4:
	movw	(%sp)+,%d0
	btst	#1,%d0
	jeq	less2
	movw	%d2,-(%a0)
less2:
	btst	#0,%d0
	jeq	none
	movb	%d2,-(%a0)
none:
exit_d2:
	movl	(%sp)+,%d2
exit:
	movl %a0,%d0		| return dest (for memset only), in a0 by predec now
	rts
