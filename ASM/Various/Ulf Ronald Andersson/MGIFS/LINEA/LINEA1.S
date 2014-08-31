*
*	linea1 - put pixel
*
*	synopsis:
*
*	void linea1 (struct line_a *ptr, x, y, color);
*

* linea struct offsets:

INTIN=8
PTSIN=12

* args: (wrt stack frame ptr a6)

ptr=8
x=12
y=14
color=16


	.globl	_linea1

	.text

_linea1:
	link	a6,#0
*	movem.l	a0,-(a7)

	move.l	ptr(a6),a0		* linea struct ptr
	move.l	INTIN(a0),a1
	move.l	PTSIN(a0),a2
	move.w	color(a6),(a1)		* put color in intin table
	move.l	x(a6),(a2)		* put coord in ptsin table

	dc.w	$A001			* draw pixel

*	movem.l	(a7)+,a0
	unlk	a6

	rts


	.end

