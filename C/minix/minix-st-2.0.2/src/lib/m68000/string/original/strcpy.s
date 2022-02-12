#include <minix/config.h>
#if ( CHIP == M68000 )
/* strcpy.s
 *
 *	char *strcpy(dst, src)
 *	char *dst;
 *	_CONST char *src;
 *
 * copy string src to dst
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strcpy

	.sect .text
_strcpy:
	link	a6,#0
	move.l	8(a6),a0	/* get dst */
	move.l	12(a6),a1	/* get src */
I1_3:
	move.b	(a1)+,(a0)+
	bne	I1_3		/* EOS of src reached ? */

	move.l	8(a6), d0	/* return dst */
	unlk	a6
	rts
#endif

