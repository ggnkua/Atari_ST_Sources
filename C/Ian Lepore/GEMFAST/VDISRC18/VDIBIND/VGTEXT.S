;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Text.
;*------------------------------------------------------------------------

_v_gtext::

	.cargs	#8,.handle.w,.x.w,.y.w,.p_str.l
	link	a6,#0

	move.l	.p_str(a6),a0	;* Get the string pointer.
	jsr	vstr_stack	;* Go integerize and stack string.

	VContrl	#8,,#1,d0

	subq.l	#8,sp		;* -> ptsout, intout
	pea	.x(a6)		;* -> ptsin
	move.l	a0,-(sp)		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
