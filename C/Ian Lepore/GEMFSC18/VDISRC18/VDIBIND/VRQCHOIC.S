;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Input choice, request mode.
;*------------------------------------------------------------------------

_vrq_choice::
	.cargs	#8,.handle.w,.chin.w,.chout.l
	link	a6,#0

	VContrl	#30,,,#1

	subq.l	#4,sp		;* -> ptsout
	move.l	.chout(a6),-(sp)	;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.chin(a6) 	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
