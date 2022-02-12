#
/* memset.s
 *
 *	void *memset(s, ucharfill, size)
 *	_VOIDSTAR s;
 *	int ucharfill;
 *	size_t size;
 *
 * memset - set bytes
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _memset

	.sect .text
_memset:
	link	a6,#0
	move.l	8(a6),a0	/* get s */
#ifdef __MLONG__
	move.b  15(a6),14(a6)	/* ucharfill[15:8] = [7:0] */
	move.w	14(a6),d1	/* get ucharfill */
	move.l	16(a6),d2	/* get size */
#else
	move.b  13(a6),12(a6)	/* ucharfill[15:8] = [7:0] */
	move.w	12(a6),d1	/* get ucharfill */
	move.w	14(a6),d2	/* get size */
#endif /* __MLONG__ */
	bls	I1_3		/* size <= 0 ? yes */
	move.l	a0,d0
	and	#1,d0
	beq	I1_9		/* s word aligned ? yes */
	move.b	d1,(a0)+	/* align */
#ifdef __MLONG__
	sub.l	#1,d2		/* size-- */
#else
	sub.w	#1,d2		/* size-- */
#endif /* __MLONG__ */
I1_9:
	cmp.w	#1,d2
	bls	I1_8		/* words done ? yes */
	move.w	d1,(a0)+	/* *( int *)s++ = ucharfill[15:0] */
#ifdef __MLONG__
	sub.l	#2,d2		/* size -= sizeof( int ) */
#else
	sub.w	#2,d2		/* size -= sizeof( int ) */
#endif /* __MLONG__ */
	bra	I1_9
I1_8:
#ifdef __MLONG__
	tst.l	d2
#else
	tst	d2
#endif /* __MLONG__ */
	beq	I1_3		/* done ? yes */
	move.b	d1,(a0)		/* fill last one */
I1_3:
	move.l	8(a6),d0	/* return s */
	unlk	a6
	rts

