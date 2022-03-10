;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire input mode.
;*------------------------------------------------------------------------

_vqin_mode::
	.cargs	#8,.handle.w,.devtyp.w,.inmode.l
	link	a6,#0

	VContrl	#115,,,#1

	subq.l	#4,sp		;* -> ptsout
	move.l	.inmode(a6),-(sp)	;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.devtyp(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
