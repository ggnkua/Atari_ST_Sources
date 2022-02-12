#
	.define	__brksize
	.extern	__end, __brksize
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect	.data
__brksize:
	.data4	__end
