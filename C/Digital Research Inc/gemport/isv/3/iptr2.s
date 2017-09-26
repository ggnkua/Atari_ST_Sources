	.text

	.globl	_i_ptr2

	.xdef	_contrl

_i_ptr2:
	move.l	4(sp),_contrl+18
	rts

	.end

