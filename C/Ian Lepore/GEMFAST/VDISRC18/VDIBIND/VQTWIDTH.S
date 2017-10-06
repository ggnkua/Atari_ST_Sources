;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire character cell width.
;*------------------------------------------------------------------------

_vqt_width::
	.cargs	#8,.handle.w,.character.w,.cellw.l,.left.l,.right.l
	link	a6,#-14		;* Allocate intout[1], ptsout[6].

	VContrl	#117,,,#1

	pea	-12(a6)		;* -> ptsout
	pea	-14(a6)		;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.character(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.cellw(a6),a0	;* Return cell width
	move.w	-12(a6),(a0)	;* from ptsout[0].
	move.l	.right(a6),a0	;* Return cell right delta
	move.w	-8(a6),(a0)	;* from ptsout[2].
	move.l	.left(a6),a0	;* Return cell left delta
	move.w	-4(a6),(a0)	;* from ptsout[4].
	move.w	-14(a6),d0	;* Return status from intout[0].

	unlk	a6
	rts

	end
