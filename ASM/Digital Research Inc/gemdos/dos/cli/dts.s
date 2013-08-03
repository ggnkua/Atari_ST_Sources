* dts.s - BDOS interface for DATE and TIME utilities

	.xref	_bdos

	.text

_bdos:
	move.l	(sp)+,ret_save
	trap	#1
	move.l	ret_save,-(sp)
	rts

	.bss

ret_save:
	.ds.l	1

	.end
