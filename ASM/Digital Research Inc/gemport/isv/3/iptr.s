	.text

	.globl	_i_ptr

	.xdef	_contrl

_i_ptr:
	move.l	4(sp),_contrl+14
	rts

	.end
