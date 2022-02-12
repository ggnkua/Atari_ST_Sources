#
	.define _sendrec
	.extern __sendrec, _sendrec
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect .text
_sendrec:	jmp __sendrec
