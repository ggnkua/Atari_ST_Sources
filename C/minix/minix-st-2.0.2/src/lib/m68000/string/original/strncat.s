#include <minix/config.h>
#if ( CHIP == M68000 )
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
	link	a6,#0
	move.l	8(a6),a0	/* get dst */
	move.l	12(a6),a1	/* get src */
	move.w	16(a6),d0	/* get n */
I1_5:
	tst.b	(a0)+
	bne	I1_5		/* EOS of dst reached ? */
	sub.l	#1,a0		/* we are one to far */
I1_7:
	move.b	(a1)+,d1	/* *src */
	beq	I1_6		/* EOS of src reached ? */
	tst.w	d0
	beq	I1_6		/* n == 0 ? finished */
	sub.w	#1,d0
	move.b	d1,(a0)+
	bra	I1_7
I1_6:
	move.b	#0,(a0)+
	move.l	8(a6),d0	/* return dst */
	unlk	a6
	rts
#endif

