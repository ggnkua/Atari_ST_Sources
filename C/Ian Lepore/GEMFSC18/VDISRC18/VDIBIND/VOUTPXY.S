;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vout_pxy.
;*  For VDI output calls that use only count and/or pxyarray.
;*
;*  This function is not exported to C, it's to be used only by other vdi
;*  bindings functions.
;*
;*  Entry: d0.w = function number.
;*	 d1.w = subfunction number.
;*	 d2.w = number of points in ptsin.
;*	 a0.l-> ptsin array
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vout_pxy::

	.cargs	#8,.handle.w
	link	a6,#0

	VContrl	d0,d1,d2

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	a0,-(sp)		;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
