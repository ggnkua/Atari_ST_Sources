;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* v_gchar - Output a single character of graphics text using v_gtext.
;*------------------------------------------------------------------------

_v_gchar::

	.cargs	#8,.handle.w,.x.w,.y.w,.char.w
	link	a6,#0

	VContrl	#8,,#1,#1

	subq.l	#8,sp		;* -> ptsout, intout
	pea	.x(a6)		;* -> ptsin
	pea	.char(a6) 	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
