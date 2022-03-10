;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Sample mouse button state.
;*------------------------------------------------------------------------

_vq_mouse::
	.cargs	#8,.handle.w,.status.l,.x.l,.y.l
	link	a6,#-4		;* Allocate ptsout[2].

	VContrl	#124

	pea	-4(a6)		;* -> ptsout
	move.l	.status(a6),-(sp)	;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.x(a6),a0 	;* Return mouse x
	move.w	-4(a6),(a0)	;* from ptsout[0].
	move.l	.y(a6),a0 	;* Return mouse y
	move.w	-2(a6),(a0)	;* from ptsout[1].

	unlk	a6
	rts

	end
