.globl _setjmp
_setjmp:
	move.l	$4(sp),a0		* address of jmp_buf[]
	move.l	sp,(a0)+		* save stack pointer
	move.l	a6,(a0)+		* save frame pointer
	move.l	(sp),(a0)+		* save return address
	movem.l	d2-d7/a2-a5,(a0)	* save registers
	clr.l	d0			* return value is 0
	rts
.globl _longjmp
_longjmp:
	move.l	$4(sp),a0		* address of jmp_buf[]
	move.w	$8(sp),d0		* value to return
	bne	nonzero
	moveq.l	#1,d0			* make it non-zero
nonzero:
	ext.l	d0
	move.l	(a0)+,sp		* restore stack pointer
	move.l	(a0)+,a6		* restore frame pointer
	move.l	(a0)+,(sp)		* restore return address
	movem.l	(a0),d2-d7/a2-a5	* restore registers
	rts
