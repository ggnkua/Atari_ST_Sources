;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Extended inquire.
;*  02/06/89    v1.1 - Changed misspelling of vq_extnd (was vq_extend).
;*		   Changed handle.l to handle.w in vq_extnd
;*------------------------------------------------------------------------

_vq_extnd::
	.cargs	#8,.handle.w,.owflag.w,.workout.l
	link	a6,#0

	VContrl	#102,,,#1

	move.l	.workout(a6),a0

	pea	90(a0)		;* -> ptsout
	move.l	a0,-(sp)		;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.owflag(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
