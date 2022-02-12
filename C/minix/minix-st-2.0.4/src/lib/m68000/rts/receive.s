#
	.define _receive
	.extern __receive, _receive
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect .text
_receive:	jmp __receive
