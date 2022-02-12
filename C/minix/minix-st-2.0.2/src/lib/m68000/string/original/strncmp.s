#include <minix/config.h>
#if ( CHIP == M68000 )
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
	link	a6,#0
	move.l	8(a6),a0	/* get s1 */
	move.l	12(a6),a1	/* get s2 */
	move.w	16(a6),d2	/* get n */
I1_6:
	tst.w	d2
	beq	I1_2		/* n == 0 ? */
	sub.w	#1,d2
	move.b	(a1)+,d1	/* *s2++ */
	move.b	(a0)+,d0
	beq	I1_5		/* *s1++ == EOS ? */
	cmp.b	d1,d0
	beq	I1_6		/* *s1 == *s2 ? try next */
	tst.b	d1
	bne	I1_12		/* *s2 != EOS ? yes */
	move.w	#1,d0		/* only *s2 is EOS - return 1 */
	bra	I1_1
I1_5:
	tst.b	d1
	bne	I1_B		/* *s2 != EOS ? yes */
I1_2:
	clr.w	d0		/* both are EOS or n == 0 - return 0 */
	bra	I1_1
I1_B:
	move.w	#-1,d0		/* only *s1 is EOS - return -1 */
	bra	I1_1
I1_12:
	sub.b	d1,d0		/* return *s1 - *s2 */
	ext.w	d0
I1_1:
	unlk	a6
	rts
#endif

