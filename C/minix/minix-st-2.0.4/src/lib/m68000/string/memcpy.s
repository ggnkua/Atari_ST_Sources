#
/* memcpy.s
 *
 *      void *memcpy(dst, src, n)
 *      void *dst;
 *      void *src;
 *      size_t n;
 *
 * Moves a block of memory (without overlap checking).
 * Fast versions inspired by physcopy().
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss
	.sect .text

#ifdef NO_LINK
#define	LINK	/* nothing */
#define	UNLK	/* nothing */
#define	dst	4(sp)
#define	src	8(sp)
#define	cnt	12(sp)
#else
#define	LINK	link	a6,#0
#define	UNLK	unlk	a6
#define	dst	8(a6)
#define	src	12(a6)
#define	cnt	16(a6)
#endif /* NO_LINK */

/* Which version of memcpy() to build */
#define	MINIMAL		1	/* reasonable and small */
#define	FAST		2	/* reasonable and fast */
#define	VERY_FAST	3	/* fun, to copy greater amounts of memory */
#define	VERY_VERY_FAST	4	/* fun */
#ifndef MEMCPY_VERSION
#define	MEMCPY_VERSION	FAST
#endif /* defined MEMCPY_VERSION */

	.define	_memcpy
_memcpy:

#if (MEMCPY_VERSION == MINIMAL)
	LINK
#ifdef __MLONG__
	move.l	cnt,d0
#else
	move.w	cnt,d0
#endif /* __MLONG__ */
	beq	ret		/* b: count == 0 */
	move.l	dst,a1		/* dst */
	move.l	src,a0		/* src */
	bra	loope
bloop:	move.b	(a0)+,(a1)+
loope:	dbra	d0,bloop
#ifdef	__MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	bloop
#endif /* __MLONG__ */

ret:	move.l	dst,d0		/* return dst */
	UNLK
	rts
#endif /* MEMCPY_VERSION == MINIMAL */

#if (MEMCPY_VERSION == FAST)
	LINK
	move.l	dst,a1		/* dst */
	move.l	src,a0		/* src */
	move.l	a0,d0
	move.l	a1,d1
	eor.b	d1,d0
	btst	#0,d0		/* pointers mutually aligned? */
	bne	ucopy
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	beq	ret
	btst	#0,d1		/* pointers aligned, but odd? */
	beq	check4
	move.b	(a0)+,(a1)+	/* copy one odd byte */
#ifdef __MLONG__
	sub.l	#1,d0		/* decrement count */
#else
	sub.w	#1,d0		/* decrement count */
#endif /* __MLONG__ */

check4:	move.w	d0,d1
	and.w	#3,d1		/* count % 4 -> last bytes */
#ifdef __MLONG__
	lsr.l	#2,d0		/* count div 4 -> adjust for 4 byte loop */
#else
	lsr.w	#2,d0
#endif /* __MLONG__ */
	bra	w4lpe

w4lp:	move.l	(a0)+,(a1)+	/* copy 4 bytes a time */
w4lpe:	dbra	d0,w4lp
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	w4lp
#endif /* __MLONG__ */
	bra	b1lpe
b1lp:	move.b	(a0)+,(a1)+	/* byte loop, at most three byte to copy */
b1lpe:	dbra	d1,b1lp

ret:	move.l	dst,d0		/* return dst */
	UNLK
	rts

ucopy:
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	beq	ret
	move.w	d0,d1
	and.w	#3,d1
#ifdef __MLONG__
	lsr.l	#2,d0
#else
	lsr.w	#2,d0
#endif /* __MLONG__ */
	bra	b4lpe
b4lp:	move.b	(a0)+,(a1)+	/* copy 4 bytes a time */
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
b4lpe:	dbra	d0,b4lp
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	b4lp
#endif /* __MLONG__ */
	bra	b1lpe

#endif /* MEMCPY_VERSION == FAST */

#if (MEMCPY_VERSION == VERY_FAST) || (MEMCPY_VERSION == VERY_VERY_FAST)
	LINK
	move.l	dst,a1		/* dst */
	move.l	src,a0		/* src */
	move.l	a0,d0
	move.l	a1,d1
	eor.b	d1,d0
	btst	#0,d0		/* pointers mutually aligned? */
	bne	ucopy
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	beq	ret
	btst	#0,d1		/* pointers aligned, but odd? */
	beq	check64
	move.b	(a0)+,(a1)+	/* copy one odd byte */
#ifdef __MLONG__
	sub.l	#1,d0		/* decrement count */
#else
	sub.w	#1,d0		/* decrement count */
#endif /* __MLONG__ */

check64:
#ifdef __MLONG__
	cmp.l	#63,d0		/* more than 63 bytes left? */
#else
	cmp.w	#63,d0
#endif /* __MLONG__ */
	bls	copy4		/* count < 64 */
	movem.l	d2-d7/a4-a5,-(sp)
	move.w	d0,d1
	and.w	#0x3F,d1
#ifdef __MLONG__
	lsr.l	#6,d0
#else
	lsr.w	#6,d0
#endif /* __MLONG__ */
	bra	end64
loop64: movem.l	(a0)+,d2-d7/a4-a5	/* copy 8x4 bytes */
	movem.l	d2-d7/a4-a5,(a1)
	movem.l	(a0)+,d2-d7/a4-a5	/* copy 8x4 bytes */
	movem.l	d2-d7/a4-a5,32(a1)
	lea	64(a1),a1
end64:	dbra	d0,loop64
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	loop64
#endif /* __MLONG__ */

	movem.l	(sp)+,d2-d7/a4-a5	/* restore regs */
	move.w	d1,d0		/* remainder becomes new count */
	beq	ret

copy4:	move.w	d0,d1			/* remainder, < 64 */
	and.w	#3,d1
	lsr.w	#2,d0

#if (MEMCPY_VERSION == VERY_VERY_FAST)
	add.w	d0,d0
	neg.w	d0
	jmp	end4(pc,d0.w)
	move.l	(a0)+,(a1)+		/* 15 instructions */
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
end4:
	move.w	d1,d0			/* get remainder, < 16 */
copy1:
	add.w	d0,d0
	neg.w	d0
	jmp	end1(pc,d0.w)
	move.b	(a0)+,(a1)+		/* 15 instructions */
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
end1:

#else /* MEMCPY_VERSION == VERY_VERY_FAST */
	bra	copy4e			/* copy d0.w longs, less than 64 */
copy4lp:
	move.l	(a0)+,(a1)+
copy4e:	dbra	d0,copy4lp
	bra	end1
copy1lp:
	move.b	(a0)+,(a1)+
end1:	dbra	d1,copy1lp
#endif /* MEMCPY_VERSION == VERY_VERY_FAST */

ret:	move.l	dst,d0			/* return dst */
	UNLK
	rts
#endif /* MEMCPY_VERSION == VERY_FAST || MEMCPY_VERSION == VERY_VERY_FAST */

#if (MEMCPY_VERSION == VERY_VERY_FAST)
ucopy:
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
	cmp.l	#16,d0
#else
	move.w	cnt,d0		/* count */
	cmp.w	#16,d0
#endif /* __MLONG__ */
	blt	copy1
copy16:
	move.w	d0,d1
	and.w	#0x0F,d1	/* last bytes count, < 16 */
#ifdef __MLONG__
	lsr.l	#4,d0
#else
	lsr.w	#4,d0
#endif /* __MLONG__ */
	bra	end16
loop16: move.b	(a0)+,(a1)+	/* 16 instructions */
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
end16:	dbra	d0,loop16
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	loop16
#endif /* __MLONG__ */
	bra	end4
#endif /* MEMCPY_VERSION == VERY_VERY_FAST */

#if (MEMCPY_VERSION == VERY_FAST)
ucopy:
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
	cmp.l	#4,d0
#else
	move.w	cnt,d0		/* count */
	cmp.w	#4,d0
#endif /* __MLONG__ */
	blt	end1
	move.w	d0,d1
	and.w	#0x03,d1	/* last bytes count, < 4 */
#ifdef __MLONG__
	lsr.l	#2,d0
#else
	lsr.w	#2,d0
#endif /* __MLONG__ */
	bra	bloope
bloop:	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
bloope:	dbra	d0,bloop
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	bloop
#endif /* __MLONG__ */
	bra	end1
 
#endif /* MEMCPY_VERSION == VERY_FAST */
