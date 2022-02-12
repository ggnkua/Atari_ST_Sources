#include <minix/config.h>
#if ( CHIP == M68000 )
/* strncpy.s
 *
 *	char *strncpy(dst, src, n)
 *	char *dst;
 *	_CONST char *src;
 *	size_t n;
 *
 * copy at most n characters of string src to dst
 */

	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strncpy

	.sect .text
_strncpy:
	link	a6,#0
	move.l	8(a6),a0	/* get dst */
	move.l	12(a6),a1	/* get src */
	move.w	16(a6),d0	/* get n */
I1_3:
	tst	d0
	beq	I1_9		/* n == 0 ? */
	sub.w	#1,d0		/* n-- */
	move.b	(a1)+,(a0)+	/* *dst++ = *src++ */
	bne	I1_3            /* EOS moved ? no */
I1_9:
	tst	d0
	beq	I1_8		/* n == 0 ? exit */
	sub.w	#1,d0
	move.b	#0,(a0)+	/* fill with EOS */
	bra	I1_9
I1_8:
	move.l	8(a6),d0
	unlk	a6
	rts
#endif

