	.text
	.globl	_bcopy
_bcopy:

	move.l	4(sp),a0	;from
	move.l	8(sp),a1	;to
	move.w	12(sp),d0	;count
	bra	L2
L1:
	move.b	(a0)+,(a1)+
L2:
	dbf	d0,L1

	rts


