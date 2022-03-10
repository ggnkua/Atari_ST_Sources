;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Input choice, sample mode.
;*------------------------------------------------------------------------

_vsm_choice::
	.cargs	#8,.handle.w,.choice.l
	link	a6,#0

	VContrl	#30

	subq.l	#4,sp		;* -> ptsout
	pea	.choice(a6)	;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2
	move.w	28(sp),d0 	;* Return status from contrl[4].
	unlk	a6
	rts

	end
