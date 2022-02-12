	.define	_get_bp

	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss

	.sect	.text
_get_bp:
	move.l	sp,d0
	rts
