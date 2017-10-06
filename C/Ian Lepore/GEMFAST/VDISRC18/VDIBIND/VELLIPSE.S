;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Ellipse.
;*------------------------------------------------------------------------

_v_ellipse::

	.cargs	#8,.handle.w,.x.w,.y.w,.xradius.w,.yradius.w
	link	a6,#0

	VContrl	#11,#5,#2

	subq.l	#8,sp		;* -> ptsout, intout
	pea	.x(a6)		;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
