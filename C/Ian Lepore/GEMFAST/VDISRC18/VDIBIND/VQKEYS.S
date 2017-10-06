;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Sample keyboard state.
;*------------------------------------------------------------------------

_vq_key_s::
	.cargs	#8,.handle.w,.status.l
	link	a6,#0

	VContrl	#128

	subq.l	#4,sp		;* -> ptsout
	move.l	.status(a6),-(sp)	;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
