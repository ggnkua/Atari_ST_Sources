#
/* strchr.s
 *
 *	char *strchr(s, charwanted)
 *	_CONST char *s;
 *	char charwanted;
 *
 * returns found char, or NULL if none
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strchr

	.sect .text
_strchr:
	move.l	4(sp),a0	/* get s */
#ifdef __MLONG__
	move.b	11(sp),d1	/* get charwanted */
#else
	move.b	9(sp),d1	/* get charwanted */
#endif /* __MLONG__ */
I1_3:
	cmp.b	(a0),d1
	beq	I1_2		/* char found ? */
	tst.b	(a0)+
	bne	I1_3		/* EOS reached ? */
	move.l	#0,d0		/* return NULL */
	bra	I1_1
I1_2:
	move.l	a0,d0		/* return s */
I1_1:
	rts

