;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Input valuator.
;*------------------------------------------------------------------------

_vsm_valuator::
	link	a6,#-6
	st	-6(a6)
	bra.s	v_valuator
_vrq_valuator::
	link	a6,#-6
	clr.b	-6(a6)
v_valuator:
	.cargs	#8,.handle.w,.valin.w,.valout.l,.term.l,.status.l

	VContrl	#29,,,#1

	subq.l	#4,sp		;* -> ptsout
	pea	-4(a6)		;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.valin(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.valout(a6),a0	;* Return value
	move.w	-4(a6),(a0)	;* from intout[0].
	move.l	.term(a6),a0	;* Return terminator
	move.w	-2(a6),(a0)	;* from intout[1].

	tst.b	-6(a6)		;* Check sample-mode flag, if
	beq.s	.skip		;* not sample mode, skip status.

	move.l	.status(a6),a0	;* In sample mode, we have to return
	move.w	28(sp),(a0)	;* status from contrl[4].
.skip:
	unlk	a6
	rts

	end
