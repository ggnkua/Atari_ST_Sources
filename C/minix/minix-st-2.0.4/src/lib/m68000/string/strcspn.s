#
/* strcspn.s
 *
 *	size_t strcspn(s, reject)
 *	_CONST char *s;
 *	_CONST char *reject;
 *
 * find length of initial segment of s consisting entirely of characters
 * not from reject
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strcspn

	.sect .text
_strcspn:
	link	a6,#-6
	move.l	a5,-(sp)
	move.l	8(a6),a0	/* get s */
	move.l	12(a6),a1	/* get reject */
	clr.w	d0		/* count = 0 */
I1_5:
	move.b	(a0)+,d1	/* *s++ */
	beq	I1_2
	move.l	a1,a5		/* reject is changed in the inner loop */
I1_7:
	tst.b	(a5)
	beq	I1_6		/* EOS of reject ? */
	cmp.b	(a5)+,d1
	bne	I1_7		/* *s != *reject ? */
	bra	I1_2		/* try next one */
I1_6:
	add.w	#1,d0
	bra	I1_5
I1_2:
	move.l	(sp)+,a5
	unlk	a6
	rts
	
