;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set clipping rectangle.
;*------------------------------------------------------------------------

_vs_clip::
	.cargs	#8,.handle.w,.clipflag.w,.pxy.l
	link	a6,#0

	VContrl	#129,,#2,#1

	subq.l	#8,sp		;* -> ptsout, ptsin
	move.l	.pxy(a6),-(sp)	;* -> ptsin
	pea	.clipflag(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
