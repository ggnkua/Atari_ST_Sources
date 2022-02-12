#
!	bcmp()
!	
.sect .text; .sect .rom; .sect .data; .sect .bss

! int bcmp(const void *s1, const void *s2, size_t n)
!	Compare two chunks of memory.
!	This is a BSD routine that escaped from the kernel.  Don't use.
!	(Alas it is not without some use, it reports the number of bytes
!	after the bytes that are equal.  So it can't be simply replaced.)
!
.sect .text
.define _bcmp
	.align	2
_bcmp:
#ifdef __MLONG__
	move.l	12(sp),-(sp)	! n
	move.l	4+4(sp),-(sp)	! s1
	move.l	8+8(sp),-(sp)	! s2
	jsr	_memcmp		! Let memcmp do the work
	lea	12(sp),sp
	tst.l	d0		! equal?
	beq	equal
	move.l	d2,d0		! Number of bytes that are unequal
#else
	move.w	12(sp),-(sp)	! n
	move.l	4+2(sp),-(sp)	! s1
	move.l	8+6(sp),-(sp)	! s2
	jsr	_memcmp		! Let memcmp do the work
	lea	10(sp),sp
	tst.w	d0		! equal?
	beq	equal
	move.w	d2,d0		! Number of bytes that are unequal
#endif /* __MLONG__ */
equal:	rts
