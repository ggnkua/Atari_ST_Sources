	xdef	_Vbl
	xref	_do_VBL_ISR

_Vbl:
	movem.l	d0-d2/a0-a2,-(sp)
	jsr	_do_VBL_ISR
	movem.l	(sp)+,d0-d2/a0-a2
	rte
