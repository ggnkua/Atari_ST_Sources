#
/* strcat.s
 *
 *	char *strcat(dst, src)
 *	char *dst;
 *	_CONST char *src;
 *
 * append string src to dst
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss

	.define _strcat

	.sect .text
_strcat:
	move.l	4(sp),a0	/* get dst */
	move.l	a0,d0		/* save for return */
	move.l	8(sp),a1	/* get src */
I1_5:
	tst.b	(a0)+
	bne	I1_5		/* EOS of dst ? */
	sub.l	#1,a0
I1_7:
	move.b	(a1)+,(a0)+
	bne	I1_7

	rts

