#include <minix/config.h>
#if ( CHIP == M68000 )
/* strchr.s
 *
 *	char *strchr(s, charwanted)
 *	_CONST char *s;
 *	char charwanted;
 *
 * returns found char, or NULL if none
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strchr

	.sect .text
_strchr:
	link	a6,#0
	move.l	8(a6),a0	/* get s */
	move.b	13(a6),d1	/* get charwanted */
I1_3:
	cmp.b	(a0),d1
	beq	I1_2		/* char found ? */
	tst.b	(a0)+
	bne	I1_3		/* EOS reached ? */
	move.l	#0,d0		/* return NULL */
	bra	I1_1
I1_2:
	move.l	a0,d0		/* return s */
I1_1:
	unlk	a6
	rts
#endif

