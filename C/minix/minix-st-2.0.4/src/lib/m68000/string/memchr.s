#
/* memchr.s
 *
 *	void *memchr(s, ucharwanted, size)
 *	_CONST _VOIDSTAR s;
 *	int ucharwanted;
 *	size_t size;
 *
 * memchr - search for a byte
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _memchr

	.sect .text
_memchr:
	move.l	4(sp),a0	/* get s */
#ifdef __MLONG__
	move.l  8(sp),d1	/* get ucharwanted */
	move.l	12(sp),d2	/* get size */
#else
	move.w  8(sp),d1	/* get ucharwanted */
	move.w	10(sp),d2	/* get size */
#endif /* __MLONG__ */
I1_5:
	bls	I1_2		/* all bytes tested ? */
	cmp.b	(a0)+,d1
	beq	I1_7		/* ucharwant found ? */
!	add.l	#1,a0		/* s++ */
#ifdef __MLONG__
	sub.l	#1,d2		/* size-- */
#else
	sub.w	#1,d2		/* size-- */
#endif /* __MLONG__ */
	bra	I1_5
I1_2:
	move.l	#0,d0		/* return NULL */
	bra	I1_1
I1_7:
	sub.l	#1,a0		/* s is one to far */
	move.l	a0,d0		/* return s */
I1_1:
	rts

