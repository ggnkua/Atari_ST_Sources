#
/* memcmp.s
 *
 *	int  memcmp(s1, s2, size)
 *	_CONST _VOIDSTAR s1;
 *	_CONST _VOIDSTAR s2;
 *	size_t size;
 *
 * memcmp - compare bytes. result <0, == 0, >0
 */

	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _memcmp

	.sect .text
_memcmp:
	move.l	4(sp),a0	/* get s1 */
	move.l	8(sp),a1	/* get s2 */
#ifndef NOT_ANSI
	move.l	#0,d0		/* prepare unsigned, .l for moveq */
	move.l	d0,d1		/* prepare unsigned, .l for moveq */
#endif /* NOT_ANSI */
#ifdef __MLONG__
	move.l	12(sp),d2	/* get size */
#else
	move.w	12(sp),d2	/* get size */
#endif /* __MLONG__ */
I1_5:
	bls	I1_2		/* all bytes tested ? */
	cmp.b	(a1)+,(a0)+
	bne	I1_7		/* bytes are not equal ? */
#ifdef __MLONG__
	sub.l	#1,d2
#else
	sub.w	#1,d2
#endif /* __MLONG__ */
	bra	I1_5
I1_7:
	move.b	-(a0),d0
	move.b	-(a1),d1
#ifdef NOT_ANSI
	sub.b	d1,d0		/* get >0 or <0 */
	ext.w	d0
#else
	sub.w	d1,d0		! unsigned char sub
#endif /* NOT_ANSI */
#ifdef __MLONG__
	ext.l	d0
	bra	I1_1
I1_2:
	clr.l	d0
#else
	bra	I1_1
I1_2:
	clr.w	d0
#endif /* __MLONG__ */

I1_1:
	rts

