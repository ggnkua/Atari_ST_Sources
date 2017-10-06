;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set input mode.
;*------------------------------------------------------------------------

_vsin_mode::
	.cargs	#8,.handle.w,.devtyp.w,.mode.w
	link	a6,#-2

	VContrl	#33,,,#2

	subq.l	#4,sp		;* -> ptsout
	pea	-2(a6)		;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.devtyp(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
