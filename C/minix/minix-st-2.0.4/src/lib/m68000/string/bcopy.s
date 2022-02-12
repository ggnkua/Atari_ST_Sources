!	bcopy()
!	
.sect .text; .sect .rom; .sect .data; .sect .bss

! void bcopy(const void *s1, void *s2, size_t n)
!	Copy a chunk of memory.  Handle overlap.
!	This is a BSD routine that escaped from the kernel.  Don't use.
!
.sect .text
.define _bcopy
	.align	2
_bcopy:
	move.l	4(sp),d0	! Exchange string arguments
	move.l	8(sp),4(sp)
	move.l	d0,8(sp)
	jmp	_memmove

