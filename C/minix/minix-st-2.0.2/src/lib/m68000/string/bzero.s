#
!	bzero()
!	
.sect .text; .sect .rom; .sect .data; .sect .bss

! void bzero(void *s, size_t n)
!	Set a chunk of memory to zero.
!	This is a BSD routine that escaped from the kernel.  Don't use.
!
.sect .text
.define _bzero
	.align	2
_bzero:
	link	a6,#0
#ifdef __MLONG__
	move.l	12(a6),-(sp)	! Size
	clr.l	-(sp)		! Zero
#else
	move.w	12(a6),-(sp)	! Size
	clr.w	-(sp)		! Zero
#endif /* __MLONG__ */
	move.l	8(a6),-(sp)	! String
	jsr	_memset		! Call the proper routine
#ifdef __MLONG__
	lea	12(sp),sp
#else
	lea	8(sp),sp
#endif
	unlk	a6
	rts
