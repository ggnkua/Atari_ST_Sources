;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Circle.
;*------------------------------------------------------------------------

_v_circle::
	.cargs	#8,.handle.w,.x.w,.y.w,.radius.w
	link	a6,#0

	clr.w	-(sp)		;* There are some holes in the
	move.w	.radius(a6),-(sp)	;* pstin definitions for circle,
	clr.l	-(sp)		;* so build a temporary ptsin on
	move.l	.x(a6),-(sp)	;* the stack.
	move.l	sp,a0		;* Save a pointer to ptsin.

	VContrl	#11,#4,#3

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	a0,-(sp)		;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
