#
/* strncat.s
 *
 *	char *strncat(dst, src, n)
 *	char *dst;
 *	_CONST char *src;
 *	size_t n;
 *
 * append at most n characters of string src to dst
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strncat

	.sect .text
_strncat:
	move.l	4(sp),a0	/* get dst */
	move.l	a0,d0		/* return dst */
	move.l	8(sp),a1	/* get src */
#ifdef __MLONG__
	move.l	12(sp),d2	/* get n */
#else
	move.w	12(sp),d2	/* get n */
#endif /* __MLONG__ */
I1_5:
	tst.b	(a0)+
	bne	I1_5		/* EOS of dst reached ? */
	sub.l	#1,a0		/* we are one to far */
I1_7:
	move.b	(a1)+,d1	/* *src */
	beq	I1_6		/* EOS of src reached ? */
#ifdef __MLONG__
	tst.l	d2
	beq	I1_6		/* n == 0 ? finished */
	sub.l	#1,d2
#else
	tst.w	d2
	beq	I1_6		/* n == 0 ? finished */
	sub.w	#1,d2
#endif /* __MLONG__ */
	move.b	d1,(a0)+
	bra	I1_7
I1_6:
	move.b	#0,(a0)+
	rts

