#
/* strlen.s
 *
 *	size_t strlen(s)
 *	_CONST char *s;
 *
 * length of string (not including NUL)
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strlen

	.sect .text
_strlen:
	move.l	4(sp),a0	/* get s */
	move.l	a0,d0		/* store s */
I1_3:
	tst.b	(a0)+
	bne	I1_3		/* *s++ == EOS ? no */
	sub.l	#1,a0		/* s is one to far */
	exg	a0,d0
	sub.l	a0,d0		/* return s - old_s */
	rts

