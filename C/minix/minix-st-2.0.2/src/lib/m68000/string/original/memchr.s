#include <minix/config.h>
#if ( CHIP == M68000 )
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
	link	a6,#0
	move.l	8(a6),a0	/* get s */
	move.w  12(a6),d1	/* get ucharwanted */
	move.w	14(a6),d2	/* get size */
I1_5:
	bls	I1_2		/* all bytes tested ? */
	cmp.b	(a0)+,d1
	beq	I1_7		/* ucharwant found ? */
!	add.l	#1,a0		/* s++ */
	sub.w	#1,d2		/* size-- */
	bra	I1_5
I1_2:
	move.l	#0,d0		/* return NULL */
	bra	I1_1
I1_7:
	sub.l	#1,a0		/* s is one to far */
	move.l	a0,d0		/* return s */
I1_1:
	unlk	a6
	rts
#endif

