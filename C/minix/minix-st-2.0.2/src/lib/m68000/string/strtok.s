#
/* strtok.s
 *
 *	char *strtok(s, delim)
 *	char *s;
 *	register _CONST char *delim;
 *
 * Get next token from string s (NULL on 2nd, 3rd, etc. calls),
 * where tokens are nonempty strings separated by runs of
 * chars from delim.  Writes NULs into s to end tokens.  delim need not
 * remain constant from call to call. Returns NULL if no token left.
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.sect .data
_scanpoint:
	.data4 0

	.define _strtok

	.sect .text
_strtok:
	link	a6,#0
	movem.l	a5/a4,-(sp)
	move.l	12(a6),a5	! get delim
	move.l	8(a6),a4	! get s
	move.l	a4,d0
	bne	I1_8		! s != EOS ?
	tst.l	_scanpoint
	beq	I1_7		! scanpoint == EOS ?
	move.l	_scanpoint,a4	! s = scanpoint
I1_8:
	move.l	a5,a1		! store delim
I1_C:
	move.b	(a4)+,d0	! *s++
	beq	I1_E		! EOS of s ?
	move.l	a1,a5		! restore delim
I1_10:
	move.b	(a5)+,d1	! *delim++
	beq	I1_18		! EOS of delim ?
	cmp.b	d1,d0
	bne	I1_10		! *s != *delim ?
	bra	I1_C
I1_E:
	clr.l	_scanpoint	! scanpoint = NULL
I1_7:
	move.l	#0,d0		! return NULL
	bra	I1_1
I1_18:
	sub.l	#1,a4		! adjust s ( --s )
	move.l	a4,a0           ! token = s
I1_1D:
	move.b	(a4)+,d0	! *s++
	beq	I1_1A		! EOS of s ?
	move.l	a1,a5		! restore delim
I1_21:
	move.b	(a5)+,d1	! *delim++
	beq	I1_1D		! EOS of delim ?
	cmp.b	d1,d0
	bne	I1_21		! *s != *delim ?
	move.l	a4,_scanpoint	! scanpoint = s
	clr.b	-1(a4)		! *(s - 1) = EOS
	bra	I1_3
I1_1A:
	clr.l	_scanpoint
I1_3:
	move.l	a0,d0		/* return token */
I1_1:
	movem.l	(sp)+,a5/a4
	unlk	a6
	rts

