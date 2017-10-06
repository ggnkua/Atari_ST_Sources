;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Exchange button change vector.
;* Exchange mouse movement vector.
;* Exchange cursor change vector.
;*------------------------------------------------------------------------

_vex_butv::
	moveq.l	#125,d0		;* Exchange button vector function.
	bra.s	vex
_vex_motv::
	moveq.l	#126,d0		;* Exchange movement vector function.
	bra.s	vex
_vex_curv::
	moveq.l	#127,d0		;* Exchange cursor change vector func.
vex:
	.cargs	#8,.handle.w,.newvec.l,.oldvec.l
	link	a6,#0

	clr.l	-(sp)		;* contrl[9-10], old vector.
	move.l	.newvec(a6),-(sp)	;* contrl[8-8],  new vector.

	VContrl	d0

	pea	(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.oldvec(a6),a0	;* Return old vector
	move.l	-4(a6),(a0)	;* from contrl[9-10].

	unlk	a6
	rts

	end
