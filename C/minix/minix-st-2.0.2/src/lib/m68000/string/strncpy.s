#
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
	move.l	4(sp),a0	/* get dst */
	move.l	a0,d0		/* return dst */
	move.l	8(sp),a1	/* get src */
#ifdef __MLONG__
	move.l	12(sp),d1	/* get n */
I1_3:
	tst.l	d1
	beq	I1_8		/* n == 0 ? */
	sub.l	#1,d1		/* n-- */
	move.b	(a1)+,(a0)+	/* *dst++ = *src++ */
	bne	I1_3            /* EOS moved ? no */
I1_9:
	tst.l	d1
	beq	I1_8		/* n == 0 ? exit */
	sub.l	#1,d1
#else
	move.w	12(sp),d1	/* get n */
I1_3:
	tst	d1
	beq	I1_8		/* n == 0 ? */
	sub.w	#1,d1		/* n-- */
	move.b	(a1)+,(a0)+	/* *dst++ = *src++ */
	bne	I1_3            /* EOS moved ? no */
I1_9:
	tst	d1
	beq	I1_8		/* n == 0 ? exit */
	sub.w	#1,d1
#endif /* __MLONG__ */

	move.b	#0,(a0)+	/* fill with EOS */
	bra	I1_9
I1_8:
	rts

