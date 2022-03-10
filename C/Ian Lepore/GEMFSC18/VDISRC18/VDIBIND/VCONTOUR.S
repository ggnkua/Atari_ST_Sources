;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Contour fill.
;*------------------------------------------------------------------------

_v_contourfill::
	.cargs	#8,.handle.w,.x.w,.y.w,.index.w
	link	a6,#0

	VContrl	#103,,#1,#1

	subq.l	#8,sp		;* -> ptsout, intout
	pea	.x(a6)		;* -> ptsin
	pea	.index(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
