*
*	linea0 - return long pointer to struct
*
*	synopsis:
*
*	ptr = (struct line_a *) linea0 ();
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

