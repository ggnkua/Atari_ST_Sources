;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire font information.
;*------------------------------------------------------------------------

_vqt_fontinfo::
	.cargs	#8,.handle.w,.minade.l,.maxade.l,.dist.l,.maxw.l,.effects.l
	link	a6,#-24		;* Allocate intout[2], ptsout[5].

	VContrl	#131

	pea	-20(a6)		;* -> ptsout
	pea	-24(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	lea	-24(a6),a0	;* Point to intout.
	move.l	.minade(a6),a1	;* Return minADE
	move.w	(a0)+,(a1)	;* from intout[0].
	move.l	.maxade(a6),a1	;* Return maxADE
	move.w	(a0)+,(a1)	;* from, intout[1].

	move.l	.maxw(a6),a1	;* Return maxwidth
	move.w	(a0)+,(a1)	;* from ptsout[0].

	move.l	a2,d2		;* Save a2 for Laser C compatibility.
	move.l	.dist(a6),a1	;* Pointer to distance
	move.l	.effects(a6),a2	;* Pointer to effects

	move.w	(a0)+,(a1)+	;* dist[0] = ptsout[1]
	move.w	(a0)+,(a2)+	;* eff[0]  = ptsout[2]
	move.w	(a0)+,(a1)+	;* dist[1] = ptsout[3]
	move.w	(a0)+,(a2)+	;* eff[1]  = ptsout[4]
	move.w	(a0)+,(a1)+	;* dist[2] = ptsout[5]
	move.w	(a0)+,(a2)+	;* eff[2]  = ptsout[6]
	move.w	(a0)+,(a1)+	;* dist[3] = ptsout[7]
	tst.w	(a0)+		;* notused - pstout[8]
	move.w	(a0),(a1) 	;* dist[4] = ptsout[9]

	move.l	d2,a2		;* Restore a2.
	unlk	a6
	rts

	end
