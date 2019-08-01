;----------------------------------------------------------------------------
;File name:	strncpy.s			Revision date:	2000.07.24
;Revised by:	Ronald Andersson		Revision start:	2000.07.24
;----------------------------------------------------------------------------
strncpy:
	move.l	a0,d1
L779A:
	subq.l	#1,d0
	bcs.s	L77AE
	move.b	(a1)+,(a0)+
	bne.s	L779A
	clr.b	d2
	tst.l	d0
	beq.s	L77AE
L77A8:
	move.b	d2,(a0)+
	subq.l	#1,d0
	bne.s	L77A8
L77AE:
	movea.l	d1,a0
	rts
;----------------------------------------------------------------------------
;End of file:	strncpy.s
;----------------------------------------------------------------------------
