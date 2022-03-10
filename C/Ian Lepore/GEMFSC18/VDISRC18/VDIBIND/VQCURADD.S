;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*-----------------------------------------------------------------------
;* Inquire current alpha cursor address.
;*-----------------------------------------------------------------------

_vq_curaddress::

	.cargs	#8,.handle.w,.row.l,.col.l
	link	a6,#-4

	VContrl	#5,#15

	subq.l	#4,sp		;* -> ptsout
	pea	-4(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.row(a6),a0
	move.w	-4(a6),(a0)	;* Return row.
	move.l	.col(a6),a0
	move.w	-2(a6),(a0)	;* Return column.

	unlk	a6
	rts

	end
