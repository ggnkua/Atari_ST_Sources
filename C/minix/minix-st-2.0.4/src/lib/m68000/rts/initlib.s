#
	.define initlib
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect .text
initlib:			! nothing to do in regular C-Library
	rts
