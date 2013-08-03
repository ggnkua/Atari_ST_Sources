	.text

	.globl	_m_lptr2

	.xdef	_contrl

_m_lptr2:
	move.l	4(sp),a0
	move.l	_contrl+18,(a0)
	rts

	.end

