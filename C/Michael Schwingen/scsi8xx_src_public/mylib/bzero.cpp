#define Lmemset 1
|	new version of bcopy and memset
|	uses movem to set 256 bytes blocks faster.
|	Alexander Lehmann	alexlehm@iti.informatik.th-darmstadt.de
|	sortof inspired by jrbs bcopy
|	has to be preprocessed (int parameter in memset)

	.text
	.even

#ifdef Lmemset
	.globl _memset

|	void *memset( void *dest, int val, size_t len );
|	returns dest
|	two versions for 16/32 bits

_memset:
	movl	sp@(4),a0	| dest
#ifdef __MSHORT__
	movb	sp@(9),d0	| value
# ifndef __SOZOBON__
	movl	sp@(10),d1	| length
# else
	clrl	d1
	movw	sp@(10),d1	| length
# endif
#else
	movb	sp@(11),d0	| value
	movl	sp@(12),d1	| length
#endif
	jeq	exit		| length==0? (size_t)
#ifdef Lbzero
	jra	do_set
#endif
#endif /* Lmemset */

#ifdef Lbzero
	.globl _bzero
	.globl __bzero

|	void bzero( void *dest, size_t length );
|	void _bzero( void *dest, unsigned long length );
|	return value not used (returns dest)

#ifdef __SOZOBON__
_bzero:
	movl	sp@(4),a0	| dest
	clrl	d1
	movw	sp@(8),d1	| length
	jra	scommon
#else
_bzero:
#endif
__bzero:
	movl	sp@(4),a0	| dest
	movl	sp@(8),d1	| length
scommon:
	jeq	exit		| length==0? (size_t)
	clrb	d0		| value
#endif /* Lbzero */

do_set: 			| a0 dest, d0.b byte, d1.l length
	movel	d2,sp@-

	addl	d1,a0		| a0 points to end of area, needed for predec

	movw	a0,d2		| test for alignment
	btst	#0,d2		| odd ?
	jeq	areeven
	movb	d0,a0@- 	| set one byte, now we are even
	subql	#1,d1
areeven:
	movb	d0,d2
	lslw	#8,d0
	movb	d2,d0
	movw	d0,d2
	swap	d2
	movw	d0,d2		| d2 has byte now four times

	clrw	d0		| save length less 256
	movb	d1,d0
	lsrl	#8,d1		| number of 256 bytes blocks
	jeq	less256
	movml	d0/d3-d7/a2/a3/a5/a6,sp@-	| d2 is already saved
				| exclude a4 because of -mbaserel
	movl	d2,d0
	movl	d2,d3
	movl	d2,d4
	movl	d2,d5
	movl	d2,d6
	movl	d2,d7
	movl	d2,a2
	movl	d2,a3
	movl	d2,a5
	movl	d2,a6
set256:
	movml	d0/d2-d7/a2/a3/a5/a6,a0@-	| set 5*44+36=256 bytes
	movml	d0/d2-d7/a2/a3/a5/a6,a0@-
	movml	d0/d2-d7/a2/a3/a5/a6,a0@-
	movml	d0/d2-d7/a2/a3/a5/a6,a0@-
	movml	d0/d2-d7/a2/a3/a5/a6,a0@-
	movml	d0/d2-d7/a2-a3,a0@-
	subql	#1,d1
	jne	set256			| next, please
	movml	sp@+,d0/d3-d7/a2/a3/a5/a6
less256:			| set 16 bytes blocks
	movw	d0,sp@- 	| save length below 256 for last 3 bytes
	lsrw	#2,d0		| number of 4 bytes blocks
	jeq	less4		| less that 4 bytes left
	movw	d0,d1
	negw	d1
	andiw	#3,d1		| d1 = number of bytes below 16 (-n)&3
	subqw	#1,d0
	lsrw	#2,d0		| number of 16 bytes blocks minus 1, if d1==0
	addw	d1,d1		| offset in code (movl two bytes)
	jmp	pc@(2,d1:w)	| jmp into loop
set16:
	movl	d2,a0@-
	movl	d2,a0@-
	movl	d2,a0@-
	movl	d2,a0@-
	dbra	d0,set16
less4:
	movw	sp@+,d0
	btst	#1,d0
	jeq	less2
	movw	d2,a0@-
less2:
	btst	#0,d0
	jeq	none
	movb	d2,a0@-
none:
exit_d2:
	movl	sp@+,d2
exit:
	movl sp@(4),d0		| return dest (for memset only)
	rts

