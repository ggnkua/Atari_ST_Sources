;----------------------------------------------------------------------------
;File name:	strcat.s			Revision date:	2000.08.25
;Revised by:	Ronald Andersson		Revision start:	2000.08.25
;----------------------------------------------------------------------------
strcat:
	move.l	a0,d0
L3660:
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	beq.s	L3680
	tst.b	(a0)+
	bne.s	L3660
L3680:
	subq	#1,a0
L3682:
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	beq.s	L36A2
	move.b	(a1)+,(a0)+
	bne.s	L3682
L36A2:
	movea.l	d0,a0
	rts
;----------------------------------------------------------------------------
;End of file:	strcat.s
;----------------------------------------------------------------------------
