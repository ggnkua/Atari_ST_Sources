#
/* memmove.s
 *
 *      void *memmove(dst, src, n)
 *      void *dst;
 *      void *src;
 *      size_t n;
 *
 * Moves a block of memory (with overlap checking).
 * In case of no overlapping it calls memcpy().
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
#define	VERY_FAST 	3	/* fun, copy greater amounts of memory */
#define	VERY_VERY_FAST 	4	/* fun */
#ifndef MEMMOVE_VERSION
#define	MEMMOVE_VERSION	FAST
#endif /* MEMMOVE_VERSION defined */

	.define	_memmove
_memmove:
	LINK
	move.l	dst,a1		/* dst */
	move.l	src,a0		/* src */
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	beq	ret		/* count == 0, nothing to do */
	cmp.l	a0,a1		/* dst < src? */
	blt	noover		/* b: yes */
#ifdef __MLONG__
	add.l	d0,a0		/* src = src + count */
#else
	add.w	d0,a0		/* src = src + count */
#endif /* __MLONG__ */
	cmp.l	a1,a0		/* src + n > dst? */
	bhi	overlap		/* b: yes */
noover:
	move.l	src,a0		/* a0 = src again */
#if (MEMMOVE_VERSION == MINIMAL)
	bra	loop1e
loop1:	move.b	(a0)+,(a1)+	/* simple copy loop */
loop1e:	dbra	d0,loop1
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	loop1
#endif /* __MLONG__ */
#else
	UNLK			/* clean up stack */
	jmp	_memcpy		/* let memcpy do the hard work */
#endif /* MEMMOVE_VERSION == MINIMAL */

ret:	move.l	dst,d0		/* return *dst */
	UNLK
	rts

overlap:
#ifdef __MLONG__
	add.l	d0,a1		/* dst += count */
#else
	add.w	d0,a1		/* dst += count */
#endif /* __MLONG__ */
#if (MEMMOVE_VERSION == MINIMAL)
	bra	loop2e
loop2:	move.b	-(a0),-(a1)	/* simple copy loop */
loop2e:	dbra	d0,loop2
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	loop2
#endif /* __MLONG__ */
	bra	ret

#else /* MEMMOVE_VERSION == MINIMAL */

	move.l	a0,d0		/* any other version checks alignment */
	move.l	a1,d1
	eor.b	d1,d0
	btst	#0,d0		/* pointers mutually aligned? */
	bne	ucopy
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	btst	#0,d1		/* pointers aligned, but odd? */
	beq	check64
	move.b	-(a0),-(a1)	/* copy last odd byte */
#ifdef __MLONG__
	sub.l	#1,d0		/* decrement count */
#else
	sub.w	#1,d0		/* decrement count */
#endif /* __MLONG__ */
check64:
#endif /* MEMMOVE_VERSION == MINIMAL */


#if (MEMMOVE_VERSION == VERY_FAST) || (MEMMOVE_VERSION == VERY_VERY_FAST)
#ifdef __MLONG__
	cmp.l	#63,d0			/* more than 63 bytes left? */
#else
	cmp.w	#63,d0
#endif /* __MLONG__ */
	bls	copy4			/* count < 64 */
	movem.l	d2-d7/a4-a5,-(sp)
	move.w	d0,d1
	and.w	#0x3F,d1
#ifdef __MLONG__
	lsr.l	#6,d0
#else
	lsr.w	#6,d0
#endif /* __MLONG__ */
	bra	end64
loop64:
	movem.l	-32(a0),d2-d7/a4-a5	/* copy 8x4 bytes */
	movem.l	d2-d7/a4-a5,-(a1)
	movem.l	-64(a0),d2-d7/a4-a5	/* copy 8x4 bytes */
	movem.l	d2-d7/a4-a5,-(a1)
	lea	-64(a0),a0
end64:	dbra	d0,loop64
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	loop64
#endif /* __MLONG__ */
	movem.l	(sp)+,d2-d7/a4-a5	/* restore regs */
	move.w	d1,d0			/* remainder becomes new count */
	beq	ret

copy4:	move.w	d0,d1			/* remainder, < 64 */
	and.w	#3,d1
	lsr.w	#2,d0
#endif /* MEMMOVE_VERSION == VERY_FAST || MEMMOVE_VERSION == VERY_VERY_FAST */

#if (MEMMOVE_VERSION == FAST)
	move.w	d0,d1
	and.w	#3,d1		/* cnt mod 4 in d1 */
#ifdef __MLONG__
	lsr.l	#2,d0		/* cnt div 4 in d0 */
#else
	lsr.w	#2,d0
#endif /* __MLONG__ */
#endif /* MEMMOVE_VERSION == FAST */

#if (MEMMOVE_VERSION == FAST) || (MEMMOVE_VERSION == VERY_FAST)
	bra	loop4e
loop4:	move.l	-(a0),-(a1)	/* copy 4 byte a time */
loop4e:	dbra	d0,loop4
#if (MEMMOVE_VERSION == FAST)
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	loop4
#endif /* __MLONG__ */
#endif /* MEMMOVE_VERSION == FAST */
	bra	loop5e
loop5:	move.b	-(a0),-(a1)
loop5e:	dbra	d1,loop5
	bra	ret
#endif /* MEMMOVE_VERSION == FAST || MEMMOVE_VERSION == VERY_FAST */

#if (MEMMOVE_VERSION == VERY_VERY_FAST)
	add.w	d0,d0
	neg.w	d0
	jmp	end4(pc,d0.w)
	move.l	-(a0),-(a1)		/* 15 instructions */
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
end4:	move.w	d1,d0			/* get remainder, < 16 */
copy1:	add.w	d0,d0
	neg.w	d0
	jmp	end1(pc,d0.w)
	move.b	-(a0),-(a1)		/* 15 instructions */
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
end1:	bra	ret

#endif /* MEMMOVE_VERSION == VERY_VERY_FAST */

ucopy:

#if (MEMMOVE_VERSION == FAST)
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	move.w	d0,d1
	and.w	#0x03,d1	/* d1 = count % 4 */
#ifdef __MLONG__
	lsr.l	#2,d0		/* d0 = count div 4 */
#else
	lsr.w	#2,d0
#endif /* __MLONG__ */
	bra	bloop4e
bloop4:	move.b	-(a0),-(a1)	/* copy ... */
	move.b	-(a0),-(a1)	/* ... 4 ... */
	move.b	-(a0),-(a1)	/* ... byte ... */
	move.b	-(a0),-(a1)	/* ... ... a time */
bloop4e:dbra	d0,bloop4
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	bloop4
#endif /* __MLONG__ */
	bra	blp5e
blp5:	move.b	-(a0),-(a1)	/* last 3 bytes (at most) */
blp5e:	dbra	d1,blp5
	bra	ret
#endif /* MEMMOVE_VERSION == FAST */

#if (MEMMOVE_VERSION == VERY_FAST) || (MEMMOVE_VERSION == VERY_VERY_FAST)
#ifdef __MLONG__
	move.l	cnt,d0		/* count */
#else
	move.w	cnt,d0		/* count */
#endif /* __MLONG__ */
	move.w	d0,d1
	and.w	#0x07,d1	/* d1 = count mod 8 */
#ifdef __MLONG__
	lsr.l	#3,d0		/* d0 = count div 8 */
#else
	lsr.w	#3,d0
#endif /* __MLONG__ */
	bra	end8
copy8:	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
	move.b	-(a0),-(a1)
end8:	dbra	d0,copy8
#ifdef __MLONG__
	add.w	#1,d0
	sub.l	#1,d0
	bhi	copy8
#endif /* __MLONG__ */
	bra	blp5e
blp5:	move.b	-(a0),-(a1)	/* last 7 bytes (at most) */
blp5e:	dbra	d1,blp5
	bra	ret

#endif /* MEMMOVE_VERSION == VERY_FAST || MEMMOVE_VERSION == VERY_VERY_FAST */

