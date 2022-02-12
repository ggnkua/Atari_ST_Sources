#ifdef ACK
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
	.sect	.end

	.define	_etext
	.define	_edata
	.define	_end

	.sect	.text
_etext:

	.sect	.data
_edata:

	.sect	.end
_end:
#endif
