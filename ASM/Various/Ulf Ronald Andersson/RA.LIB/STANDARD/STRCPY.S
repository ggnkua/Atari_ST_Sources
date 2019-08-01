;----------------------------------------------------------------------------
;File name:	strcpy.s			Revision date:	2000.07.24
;Revised by:	Ronald Andersson		Revision start:	2000.07.24
;----------------------------------------------------------------------------
strcpy:
	move.l	a0,d0
L7754:
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	beq.s	L7794
	move.b	(a1)+,(a0)+
	bne.s	L7754
L7794:
	movea.l	d0,a0
	rts
;----------------------------------------------------------------------------
;End of file:	strcpy.s
;----------------------------------------------------------------------------
