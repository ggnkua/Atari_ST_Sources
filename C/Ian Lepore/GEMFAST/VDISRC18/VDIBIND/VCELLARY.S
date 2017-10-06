;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Cell array.  What a weird function.
;*------------------------------------------------------------------------

_v_cellarray::
	.cargs	#8,.handle.w,.pxy.l,.rowlen.w,.elused.w,.numrows.w,.wrmode.w,.colarray.l
	link	a6,#0

	move.w	.numrows(a6),d0	;* Save numrows and number of
	move.w	.elused(a6),d1	;* elements used for intin count
	move.w	.wrmode(a6),-(sp)	;* calculation later.  Stack the
	move.w	d0,-(sp)		;* extra contrl parms first.
	move.w	d1,-(sp)
	move.w	.rowlen(a6),-(sp)

	mulu	d1,d0		;* Calc intin count=numrows*elused.

	VContrl	#10,,#2,d0

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	.pxy(a6),-(sp)	;* -> ptsin
	move.l	.colarray(a6),-(sp) ;* -> intin
	pea	 16(sp)		;* -> contrl

	jmp	vdicall

	end
