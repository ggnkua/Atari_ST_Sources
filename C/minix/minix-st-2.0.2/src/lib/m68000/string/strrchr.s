#
/* strrchr.s
 *
 *	char *strrchr(s, charwanted)
 *	_CONST char *s;
 *	register char charwanted;
 *
 * find last occurrence of a character in a string
 * returns found char, or NULL if none
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strrchr

	.sect .text
_strrchr:
	move.l	4(sp),a0	/* get s */
#ifdef __MLONG__
	move.b	11(sp),d1	/* get charwanted */
#else
	move.b	9(sp),d1	/* get charwanted */
#endif /* __MLONG__ */
	move.l	#0,a1		/* position = NULL */
I1_5:
	move.b	(a0),d0		/* *s */
	beq	I1_2		/* EOS of s ? */
	cmp.b	d1,d0
	bne	I1_3		/* *s != charwanted ? */
	move.l	a0,a1		/* position = s */
I1_3:
	add.l	#1,a0		/* s++ */
	bra	I1_5
I1_2:
	tst.b	d1
	bne	I1_A		/* charwanted != EOS ? */
	move.l	a0,a1		/* position = s */
I1_A:
	move.l	a1,d0		/* return position */
	rts

