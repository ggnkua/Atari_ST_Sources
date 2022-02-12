#
/* strnlen.s
 *
 *	size_t strnlen(s, n)
 *	_CONST char *s;
 *	size_t n;
 *
 * length of string (not including NUL)
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strnlen

	.sect .text
_strnlen:
	move.l	4(sp),a0	/* get s */
#ifdef __MLONG__
	move.l	8(sp),d1	/* get n */
#else
	move.w	8(sp),d1	/* get n */
#endif /* __MLONG__ */
	beq	nzero		/* all done if n == zero */
	move.l	a0,d0		/* store s */
I1_3:
	tst.b	(a0)+
	beq	I1_4		/* *s++ == EOS ? yes */
#ifdef __MLONG__
	sub.l	#1,d1		/* n-- */
#else
	sub.w	#1,d1		/* n-- */
#endif
	bne	I1_3		/* n == 0 ? no */
	bra	I1_6

I1_4:	sub.l	#1,a0		/* s is one to far */
I1_6:	exg	a0,d0
	sub.l	a0,d0		/* return s - old_s */
I1_5:
	rts

nzero:	move.l	#0,d0
	bra	I1_5

