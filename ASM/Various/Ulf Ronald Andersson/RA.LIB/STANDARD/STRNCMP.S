;----------------------------------------------------------------------------
;File name:	strncmp.s			Revision date:	2000.08.25
;Revised by:	Ronald Andersson		Revision start:	2000.08.25
;----------------------------------------------------------------------------
strncmp:
	subq.l	#1,d0
	bcs.s	L37FE
	move.b	(a0)+,d1
	beq.s	L37FA
	cmp.b	(a1)+,d1
	beq.s	strncmp
	bhi.s	L3802
L37F6:
	moveq	#-$01,d0
	rts

L37FA:
	tst.b	(a1)+
	bne.s	L37F6
L37FE:
	moveq	#$00,d0
	rts

L3802:
	moveq	#$01,d0
	rts
;----------------------------------------------------------------------------
;End of file:	strncmp.s
;----------------------------------------------------------------------------
