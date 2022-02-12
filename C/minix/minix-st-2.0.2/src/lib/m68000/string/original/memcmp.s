#include <minix/config.h>
#if ( CHIP == M68000 )
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
	link	a6,#0
	move.l	8(a6),a0	/* get s1 */
	move.l	12(a6),a1	/* get s2 */
	move.w	16(a6),d2	/* get size */
I1_5:
	bls	I1_2		/* all bytes tested ? */
	cmp.b	(a1)+,(a0)+
	bne	I1_7		/* bytes are not equal ? */
	sub.w	#1,d2
	bra	I1_5
I1_7:
	move.b	-(a0),d0
	move.b	-(a1),d1
	sub.b	d1,d0		/* get >0 or <0 */
	ext.w	d0
	bra	I1_1
I1_2:
	clr.w	d0
I1_1:
	unlk	a6
	rts
#endif

