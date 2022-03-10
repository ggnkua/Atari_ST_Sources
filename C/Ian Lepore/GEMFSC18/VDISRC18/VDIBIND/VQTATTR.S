;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire text attributes.
;*------------------------------------------------------------------------

_vqt_attributes::
	.cargs	#8,.handle.w,.attrib.l
	link	a6,#0

	VContrl	#38

	move.l	.attrib(a6),a0
	pea	12(a0)		;* -> ptsout
	move.l	a0,-(sp)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
