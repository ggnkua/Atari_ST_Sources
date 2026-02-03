
|	new version of bcopy, memcpy and memmove
|	handles overlap, odd/even alignment
|	uses movem to copy 256 bytes blocks faster.
|	Alexander Lehmann	alexlehm@iti.informatik.th-darmstadt.de
|	sortof inspired by jrbs bcopy

	.text
	.even
	.globl _bcopy
	.globl	__bcopy
	.globl _memcpy
	.globl _memmove

|	void *memcpy( void *dest, const void *src, size_t len );
|	void *memmove( void *dest, const void *src, size_t len );
|	returns dest
|	functions are aliased

#ifndef __SOZOBON__
_memcpy:
_memmove:
	movl	sp@(4),a1	| dest
	movl	sp@(8),a0	| src
	jra	common		| the rest is samea as bcopy
#else
|	_bcopy() is the base function below; for memcpy(), memmove()
|	and bcopy(), we have to sneak a size_t into an unsigned long first.

_memcpy:
_memmove:
	movl	sp@(4),a1	| dest
	movl	sp@(8),a0	| src
	clrl	d0		| here is the sneaky bit...
	movw	sp@(12),d0	| length
	jra	common2		| the rest is samea as bcopy

_bcopy:
	movl	sp@(4),a0	| src
	movl	sp@(8),a1	| dest
	clrl	d0		| here is the sneaky bit...
	movw	sp@(12),d0	| length
	jra	common2		| the rest is samea as bcopy
#endif

|	void bcopy( const void *src, void *dest, size_t length );
|	void _bcopy( const void *src, void *dest, unsigned long length );
|	return value not used (returns src)
|	functions are aliased (except for HSC -- sb)

#ifndef __SOZOBON__
_bcopy:
#endif
__bcopy:
	movl	sp@(4),a0	| src
	movl	sp@(8),a1	| dest
common:	movl	sp@(12),d0	| length
common2:
	jeq	exit		| length==0? (size_t)

				| a0 src, a1 dest, d0.l length
	movel	d2,sp@-

	| overlay ?
	cmpl	a0,a1
	jgt	top_down

	movw	a0,d1		| test for alignment
	movw	a1,d2
	eorw	d2,d1
	btst	#0,d1		| one odd one even ?
	jne	slow_copy
	btst	#0,d2		| both even ?
	jeq	both_even
	movb	a0@+,a1@+	| copy one byte, now we are both even
	subql	#1,d0
both_even:
	clrw	d1		| save length less 256
	movb	d0,d1
	lsrl	#8,d0		| number of 256 bytes blocks
	jeq	less256
	movml	d1/d3-d7/a2/a3/a5/a6,sp@-	| d2 is already saved
					| exclude a4 because of -mbaserel
copy256:
	movml	a0@+,d1-d7/a2/a3/a5/a6	| copy 5*44+36=256 bytes
	movml	d1-d7/a2/a3/a5/a6,a1@
	movml	a0@+,d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@(44)
	movml	a0@+,d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@(88)
	movml	a0@+,d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@(132)
	movml	a0@+,d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@(176)
	movml	a0@+,d1-d7/a2-a3
	movml	d1-d7/a2-a3,a1@(220)
	lea	a1@(256),a1		| increment dest, src is already
	subql	#1,d0
	jne	copy256 		| next, please
	movml	sp@+,d1/d3-d7/a2/a3/a5/a6
less256:			| copy 16 bytes blocks
	movw	d1,d0
	lsrw	#2,d0		| number of 4 bytes blocks
	jeq	less4		| less that 4 bytes left
	movw	d0,d2
	negw	d2
	andiw	#3,d2		| d2 = number of bytes below 16 (-n)&3
	subqw	#1,d0
	lsrw	#2,d0		| number of 16 bytes blocks minus 1, if d2==0
	addw	d2,d2		| offset in code (movl two bytes)
	jmp	pc@(2,d2:w)	| jmp into loop
copy16:
	movl	a0@+,a1@+
	movl	a0@+,a1@+
	movl	a0@+,a1@+
	movl	a0@+,a1@+
	dbra	d0,copy16
less4:
	btst	#1,d1
	jeq	less2
	movw	a0@+,a1@+
less2:
	btst	#0,d1
	jeq	none
	movb	a0@,a1@
none:
exit_d2:
	movl	sp@+,d2
exit:
	movl sp@(4),d0		| return dest (for memcpy only)
	rts

slow_copy:			| byte by bytes copy
	movw	d0,d1
	negw	d1
	andiw	#7,d1		| d1 = number of bytes blow 8 (-n)&7
	addql	#7,d0
	lsrl	#3,d0		| number of 8 bytes block plus 1, if d1!=0
	addw	d1,d1		| offset in code (movb two bytes)
	jmp	pc@(2,d1:w)	| jump into loop
scopy:
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	movb	a0@+,a1@+
	subql	#1,d0
	jne	scopy
	jra	exit_d2

top_down:
	addl	d0,a0		| a0 byte after end of src
	addl	d0,a1		| a1 byte after end of dest

	movw	a0,d1		| exact the same as above, only with predec
	movw	a1,d2
	eorw	d2,d1
	btst	#0,d1
	jne	slow_copy_d

	btst	#0,d2
	jeq	both_even_d
	movb	a0@-,a1@-
	subql	#1,d0
both_even_d:
	clrw	d1
	movb	d0,d1
	lsrl	#8,d0
	jeq	less256_d
	movml	d1/d3-d7/a2/a3/a5/a6,sp@-
copy256_d:
	movml	a0@(-44),d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@-
	movml	a0@(-88),d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@-
	movml	a0@(-132),d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@-
	movml	a0@(-176),d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@-
	movml	a0@(-220),d1-d7/a2/a3/a5/a6
	movml	d1-d7/a2/a3/a5/a6,a1@-
	movml	a0@(-256),d1-d7/a2-a3
	movml	d1-d7/a2-a3,a1@-
	lea	a0@(-256),a0
	subql	#1,d0
	jne	copy256_d
	movml	sp@+,d1/d3-d7/a2/a3/a5/a6
less256_d:
	movw	d1,d0
	lsrw	#2,d0
	jeq	less4_d
	movw	d0,d2
	negw	d2
	andiw	#3,d2
	subqw	#1,d0
	lsrw	#2,d0
	addw	d2,d2
	jmp	pc@(2,d2:w)
copy16_d:
	movl	a0@-,a1@-
	movl	a0@-,a1@-
	movl	a0@-,a1@-
	movl	a0@-,a1@-
	dbra	d0,copy16_d
less4_d:
	btst	#1,d1
	jeq	less2_d
	movw	a0@-,a1@-
less2_d:
	btst	#0,d1
	jeq	exit_d2
	movb	a0@-,a1@-
	jra	exit_d2
slow_copy_d:
	movw	d0,d1
	negw	d1
	andiw	#7,d1
	addql	#7,d0
	lsrl	#3,d0
	addw	d1,d1
	jmp	pc@(2,d1:w)
scopy_d:
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	movb	a0@-,a1@-
	subql	#1,d0
	jne	scopy_d
	jra	exit_d2

