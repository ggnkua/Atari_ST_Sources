#
/* strspn.s
 *
 *	size_t strspn(s, accept)
 *	_CONST char *s;
 *	_CONST char *accept;
 *
 * find length of initial segment of s consisting entirely of characters
 * from accept
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strspn

	.sect .text
_strspn:
	link	a6,#0
	move.l	a5,-(sp)
	move.l	8(a6),a1	/* get s */
	move.l	12(a6),a0	/* get accept */
	clr.w	d0		/* count = 0 */
I1_5:
	move.b	(a1)+,d2	/* *s++ */
	beq	I1_1		/* EOS of s ? */
	move.l	a0,a5		/* accept is changed in the inner loop */
I1_9:
	move.b	(a5),d1		/* *accept */
	beq	I1_1		/* EOS of accept ? yes */
	cmp.b	d1,d2
	bne	I1_7		/* *s != *accept ? */
	tst.b	d1
	beq	I1_1		/* EOS of accept ? yes */
	add.w	#1,d0		/* count++ */
	bra	I1_5
I1_7:
	add.l	#1,a5		/* accept++ */
	bra	I1_9
I1_1:
	move.l	(sp)+,a5
	unlk	a6
	rts

