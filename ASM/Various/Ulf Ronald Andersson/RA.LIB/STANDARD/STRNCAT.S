;----------------------------------------------------------------------------
;File name:	strncat.s			Revision date:	2000.08.25
;Revised by:	Ronald Andersson		Revision start:	2000.08.25
;----------------------------------------------------------------------------
strncat:
	move.l	a0,d1
L37C8:
	tst.b	(a0)+
	beq.s	L37D8
	tst.b	(a0)+
	beq.s	L37D8
	tst.b	(a0)+
	beq.s	L37D8
	tst.b	(a0)+
	bne.s	L37C8
L37D8:
	subq	#1,a0
L37DA:
	subq.l	#1,d0
	bcs.s	L37E2
	move.b	(a1)+,(a0)+
	bne.s	L37DA
L37E2:
	clr.b	(a0)
	movea.l	d1,a0
	rts
;----------------------------------------------------------------------------
;End of file:	strncat.s
;----------------------------------------------------------------------------
