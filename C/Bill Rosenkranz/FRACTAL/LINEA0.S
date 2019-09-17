*
*	NAME:		linea0 - return pointer to line A struct
*
*
*	SYNOPSIS:	ptr = (struct line_a *) linea0 ();
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

Init=$A000

	.globl	_linea0

	.text

_linea0:
	link	a6,#0			* stack frame
	movem.l	a0-a2,-(a7)		* save regs we clobber (except d0)

	dc.w	Init

* pointer to struct now in d0 and a0. a1 -> array of font headers, a2 -> array
* of linea functions

	movem.l	(a7)+,a0-a2		* restore regs
	unlk	a6			* fix stack frame

	rts				* d0 is pointer

	.end

