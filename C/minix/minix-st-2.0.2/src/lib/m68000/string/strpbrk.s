#
/* strpbrk.s
 *
 *	char *strpbrk(s, breakat)
 *	_CONST char *s;
 *	_CONST char *breakat;
 *
 * find first occurrence of any char from breakat in s
 * return found char, or NULL if none
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss

	.define _strpbrk

	.sect .text
_strpbrk:
	link	a6,#0
	move.l	a5,-(sp)
	move.l	8(a6),a1	/* get s */
	move.l	12(a6),a0	/* get breakat */
I1_5:
	move.b	(a1)+,d0	/* *s */
	beq	I1_2            /* EOS of s ? */
	move.l	a0,a5		/* breakat is changed in the inner loop */
I1_9:
	move.b	(a5)+,d1	/* *breakat++ */
	beq	I1_5		/* EOS of breakat ? */
	cmp.b	d0,d1
	bne	I1_9		/* *s != *breakat ? try next */
	sub.l	#1,a1		/* s is one to far */
	move.l	a1,d0		/* return s */
	bra	I1_1
I1_2:
	move.l	#0,d0		/* return NULL */
I1_1:
	move.l	(sp)+,a5
	unlk	a6
	rts

