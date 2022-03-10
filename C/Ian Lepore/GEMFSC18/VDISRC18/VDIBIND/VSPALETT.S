;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*-----------------------------------------------------------------------
;* Select pallete.	This has something to do with IBMPC screens...
;*-----------------------------------------------------------------------

_vs_palette::
	.cargs	#8,.handle.w,.palette.w
	link	a6,#0
	VContrl	#5,#60,,#1

	lea	-12(sp),sp	;* -> ptsout, intout, ptsin
	pea	.palette(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
