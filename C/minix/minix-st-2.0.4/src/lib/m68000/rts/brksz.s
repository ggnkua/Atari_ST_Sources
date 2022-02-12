#
/*
 * The Gnu Linker defines _etext, _edata and _end internally and
 * does not support a section end.
 */
	.define	__brksize
#ifndef GNUOBJ
	.extern	__end
#endif /* GNUOBJ */
	.extern	__brksize
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect	.data
__brksize:
#ifdef GNUOBJ
	.long	_end
#else
	.data4	__end
#endif /* GNUOBJ */
