#
/* strcmp.s
 *
 *	int  strcmp(s1, s2)
 *	_CONST char *s1;
 *	_CONST char *s2;
 *
 * compare string s1 to s2, returns <0 for <, 0 for ==, >0 for >
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss

	.define _strcmp

	.sect .text
_strcmp:
	move.l	8(sp),a1	/* get s2 */
	move.l	4(sp),a0	/* get s1 */
#ifndef NOT_ANSI
	move.l	#0,d0		/* prepare unsigned char, .l for moveq */
	move.l	#0,d1		/* prepare unsigned char, .l for moveq */
#endif /* NOT_ANSI */
I1_3:
	move.b	(a1)+,d1	/* *s2++ */
	move.b	(a0)+,d0
	beq	I1_2		/* *s1++ == EOS ? */
	cmp.b	d1,d0
	beq	I1_3		/* *s1 == *s2 ? try next */
	tst.b	d1
	bne	I1_E		/* *s2 != EOS ? yes */
#ifdef __MLONG__
	move.l	#1,d0		/* only *s2 is EOS - return 1 */
#else
	move.w	#1,d0		/* only *s2 is EOS - return 1 */
#endif /* __MLONG__ */
	bra	I1_1
I1_2:
	tst.b	d1
	bne	I1_7		/* *s2 != EOS ? yes */
#ifdef __MLONG__
	clr.l	d0		/* boths are EOS - return 0 */
#else
	clr.w	d0		/* boths are EOS - return 0 */
#endif /* __MLONG__ */
	bra	I1_1
I1_7:
#ifdef __MLONG__
	move.l	#-1,d0		/* only *s1 is EOS - return -1 */
#else
	move.w	#-1,d0		/* only *s1 is EOS - return -1 */
#endif /* __MLONG__ */
	bra	I1_1
I1_E:
#ifndef NOT_ANSI
	sub.w	d1,d0		/* return *s1 - *s2, .w for unsigned! */
#else
	sub.b	d1,d0
	ext.w	d0
#endif /* NOT_ANSI */
#ifdef __MLONG__
	ext.l	d0
#endif /* __MLONG__ */
I1_1:
	rts

