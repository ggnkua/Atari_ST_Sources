#
	.define _send
	.extern __send, _send
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect .text
_send:	jmp __send
