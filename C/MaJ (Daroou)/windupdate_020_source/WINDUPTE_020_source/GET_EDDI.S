/*
 *	Read EdDI version
 *
 *	Patrice Mandin
 */

	.text

	.globl	_get_eddi_version

/*--- Vector installer ---*/

_get_eddi_version:

	movel	sp@(4),a0	/* Value of EdDI cookie */

	/* Call EdDI function #0 */

	clrl	d0
	jsr	(a0)

	rts
