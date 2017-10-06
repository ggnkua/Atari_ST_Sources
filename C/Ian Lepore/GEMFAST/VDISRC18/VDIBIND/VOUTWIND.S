;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*-----------------------------------------------------------------------
;* Output window contents to printer. (Or something like that).
;*-----------------------------------------------------------------------

_v_output_window::
	.cargs	#8,.handle.w,.pxy.l
	link	a6,#0

	VContrl	#5,#21,#2

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	.pxy(a6),-(sp)	;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
