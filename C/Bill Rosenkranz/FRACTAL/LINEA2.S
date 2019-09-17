*
*	NAME:		linea2 - get pixel
*
*
*	SYNOPSIS:	int linea2 (struct line_a *ptr, int x, int y);
*
*
*	AUTHOR:		(c) 1989 Bill Rosenkranz
*
*			net:	rosenkra%boston@hall.cray.com
*			CIS:	71460,17
*			GENIE:	W.ROSENKRANZ
*
*			Feel free to copy. Leave this comment alone! No other
*			restrictions on copying or hacking. Use as you like.
*

* linea struct offsets:

PTSIN=12

* args: (wrt stack frame ptr a6)

ptr=8
x=12
y=14


	.globl	_linea2

	.text

_linea2:
	link	a6,#0
	movem.l	a0-a1,-(a7)

	move.l	ptr(a6),a0		* linea struct ptr
	move.l	PTSIN(a0),a1
	move.l	x(a6),(a1)		* put coord in ptsin table

	dc.w	$A002			* get pixel. returns d0.w

	movem.l	(a7)+,a0-a1
	unlk	a6

	rts


	.end

