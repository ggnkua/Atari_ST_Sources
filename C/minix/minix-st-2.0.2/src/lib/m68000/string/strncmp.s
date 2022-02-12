#
/* strncmp.s
 *
 *	int strncmp(s1, s2, n)
 *	_CONST char *s1;
 *	_CONST char *s2;
 *	size_t n;
 *
 * compare at most n characters of string s1 to s2
 * returns <0 for <, 0 for ==, >0 for >
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strncmp

	.sect .text
_strncmp:
	move.l	4(sp),a0	/* get s1 */
	move.l	8(sp),a1	/* get s2 */
#ifdef __MLONG__
	move.l	12(sp),d2	/* get n */
#else
	move.w	12(sp),d2	/* get n */
#endif /* __MLONG__ */
#ifndef NOT_ANSI
	move.l	#0,d0		/* prepare unsigned char, .l for moveq */
	move.l	#0,d1		/* prepare unsigned char, .l for moveq */
#endif /* NOT_ANSI */
I1_6:
#ifdef __MLONG__
	tst.l	d2
	beq	I1_2		/* n == 0 ? */
	sub.l	#1,d2
#else
	tst.w	d2
	beq	I1_2		/* n == 0 ? */
	sub.w	#1,d2
#endif /* __MLONG__ */
	move.b	(a1)+,d1	! *s2++
	move.b	(a0)+,d0
	beq	I1_5		! *s1++ == EOS ?
	cmp.b	d1,d0
	beq	I1_6		! *s1 == *s2 ? try next
	tst.b	d1
	bne	I1_12		! *s2 != EOS ? yes
	move.l	#1,d0		! only *s2 is EOS - return 1
	bra	I1_1
I1_5:
	tst.b	d1
	bne	I1_B		! *s2 != EOS ? yes
I1_2:
	clr.l	d0		! both are EOS or n == 0 - return 0
	bra	I1_1
I1_B:
	move.l	#-1,d0		! only *s1 is EOS - return -1
	bra	I1_1
I1_12:
#ifdef NOT_ANSI
	sub.b	d1,d0		! return *s1 - *s2
	ext.w	d0
#else
	sub.w	d1,d0		! unsigned sub
#endif /* NOT_ANSI */
#ifdef __MLONG__
	ext.l	d0
#endif /* __MLONG__ */
I1_1:
	rts

