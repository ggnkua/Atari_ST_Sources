;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*-----------------------------------------------------------------------
;* Inquire addressable alpha character cells.  Right.
;*-----------------------------------------------------------------------

_vq_chcells::
	.cargs	#8,.handle.w,.rows.l,.columns.l
	link	a6,#-4

	VContrl	#5,#1

	subq.l	#4,sp		;* -> ptsout
	pea	-4(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.rows(a6),a0
	move.w	-4(a6),(a0)	;* Return rows.
	move.l	.columns(a6),a0
	move.w	-2(a6),(a0)	;* Return columns.

	unlk	a6
	rts

	end
