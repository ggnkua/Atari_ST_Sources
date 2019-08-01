;----------------------------------------------------------------------------
;File name:	strcmp.s			Revision date:	2000.08.25
;Revised by:	Ronald Andersson		Revision start:	2000.08.25
;----------------------------------------------------------------------------
strcmp:
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	bne.s	L3716
	move.b	(a0)+,d0
	beq.s	L3720
	cmp.b	(a1)+,d0
	beq.s	strcmp
L3716:
	bcs.s	L371C
	moveq	#$01,d0
	rts

L371C:
	moveq	#-$01,d0
	rts

L3720:
	tst.b	(a1)
	bne.s	L371C
	moveq	#$00,d0
	rts
;----------------------------------------------------------------------------
;End of file:	strcmp.s
;----------------------------------------------------------------------------
