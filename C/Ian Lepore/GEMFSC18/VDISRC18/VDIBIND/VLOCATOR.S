;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Input locator.
;*------------------------------------------------------------------------

_vsm_locator::
_vrq_locator::
	.cargs	#8,.handle.w,.x.w,.y.w,.xout.l,.yout.l,.term.l
	link	a6,#-4		;* Allocate ptsout[2].

	VContrl	#28,,#1

	pea	-4(a6)		;* -> ptsout
	move.l	.term(a6),-(sp)	;* -> intout
	pea	.x(a6)		;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.xout(a6),a0	;* Return x
	move.w	-4(a6),(a0)	;* from ptsout[0].
	move.l	.yout(a6),a0	;* Return y
	move.w	-2(a6),(a0)	;* from ptsout[1].

	move.w	28(sp),d0 	;* Contrl[4] (number of intout's)
	lsl.w	#1,d0		;* Shifted by one, per specs, OR
	or.w	24(sp),d0 	;* in Contrl[2] (number of ptsout's).

	unlk	a6
	rts

	end
