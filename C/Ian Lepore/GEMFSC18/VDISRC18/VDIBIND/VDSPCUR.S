;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*-----------------------------------------------------------------------
;* Place graphic cursor at location.
;*-----------------------------------------------------------------------

_v_dspcur::
	.cargs	#8,.handle.w,.x.w,.y.w
	link	a6,#0

	VContrl	#5,#18,#1

	subq.l	#8,sp		;* -> ptsout, intout
	pea	.x(a6)		;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
