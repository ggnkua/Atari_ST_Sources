;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Exchange timer interupt vector.
;*------------------------------------------------------------------------

_vex_timv::
	.cargs	#8,.handle.w,.newtim.l,.oldtim.l,.cnvtim.l
	link	a6,#0

	clr.l	-(sp)		;* Old vector here; contrl[9-10].
	move.l	.newtim(a6),-(sp)	;* New vector in contrl[7-8].

	VContrl	#118

	subq.l	#4,sp		;* -> ptsout
	move.l	.cnvtim(a6),-(sp)	;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.oldtim(a6),a0	;* Return old vector
	move.l	-4(a6),(a0)	;* from contrl[9-10].

	unlk	a6
	rts

	end
