;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*-----------------------------------------------------------------------
;* Direct alpha cursor address.
;*-----------------------------------------------------------------------

_vs_curaddress::
	.cargs	#8,.handle.w,.row.w,.col.w
	link	a6,#0

	VContrl	#5,#11,,#2

	lea	-12(sp),sp	;* -> ptsout, intout, ptsin
	pea	.row(a6)		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
