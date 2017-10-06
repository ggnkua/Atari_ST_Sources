;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Arc and Pie.
;*------------------------------------------------------------------------

_v_arc::
	moveq.l	#2,d1
	bra.s	varcpie
_v_pieslice::
	moveq.l	#3,d1
varcpie:
	.cargs	#8,.handle.w,.x.w,.y.w,.radius.w,.begang.w,.endang.w
	link	a6,#0

	clr.w	-(sp)		;* There are some unused words
	move.w	.radius(a6),-(sp)	;* (which must be zeroed) in the
	clr.l	-(sp)		;* ptsin definition for arc & pie,
	clr.l	-(sp)		;* so build a temporary ptsin
	move.l	.x(a6),-(sp)	;* array on the stack.
	move.l	sp,a0		;* Save pointer to ptsin.

	VContrl	#11,d1,#4,#2

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	a0,-(sp)		;* -> ptsin
	pea	.begang(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
