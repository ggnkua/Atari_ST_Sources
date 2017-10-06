;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set mouse form.
;*------------------------------------------------------------------------

_vsc_form::
	.cargs	#8,.handle.w,.pform.l
	link	a6,#0

	VContrl	#111,,,#37

	lea	-12(sp),sp	;* -> ptsout, intout, ptsin
	move.l	.pform(a6),-(sp)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
