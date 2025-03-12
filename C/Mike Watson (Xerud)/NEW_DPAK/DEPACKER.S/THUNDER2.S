	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a2
	move.l	a1,a4
	
	movea.l	a2,a0
	add.l	8(a0),a0
	add.l	#12,a2			
	sub.l	-(a0),a0
	movea.l	a0,a3
	moveq	#0,d7
	bset	#15,d7

m1:	moveq	#0,d1
	bsr.s	u3
	bcc.s	u7
	bsr.s	u3
	bcs.s	r23
	bra.s	u9
u7:	move.b	(a0)+,(a4)+
u30:	cmpa.l	a3,a2
	ble.s	m1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
u8:	move.b	d1,(a4)+
	bra.s	u30
u9:	moveq	#2,d2
u1:	bsr.s	u3
	roxl.b	#1,d1
	dbf	d2,u1
	cmpi.w	#1,d1
	beq.s	u21
	ble.s	u8
	bsr.s	u14
u20:	move.w	d2,d0
	bsr.s	u4
u18:	movea.l	a4,a1	
	sub.l	d2,a1
mlp:	move.b	(a1)+,(a4)+
	dbf	d0,mlp
	bra.s	u30
u21:	move.w	#9,d0
u22:	move.b	(a0)+,(a4)+
	dbf	d0,u22
	bra.s	u30
u3:	lsl.w	#1,d7
	bne.s	u10
	move.w	(a2)+,d7
	lsl.w	#1,d7
	bset	#0,d7
u10:	rts
r23:	bsr.s	u3
	bcc.s	u19
	moveq	#1,d0
	moveq	#0,d2
	move.b	(a0)+,d2
	bra.s	u18
u19:	moveq	#3,d2
u11:	bsr.s	u3
	roxl.b	d1
	dbf	d2,u11
	cmpi.w	#1,d1
	beq.s	u17
	blt.s	u12
	bsr.s	u14
	moveq	#2,d0
	bra.s	u18
u17:	move.b	(a0,d2.w),(a4)+
	bra	u30
u16:	bsr.s	u4
	bra.s	u20
u12:	bsr.s	u4
	move.w	d2,d0
	beq.s	u16
	bsr.s	u3
	bcc.s	u2
	moveq	#0,d2
	bra.s	u15
u2:	move.b	(a0)+,d2
u15:	move.b	d2,(a4)+
	dbf	d0,u15
	bra	u30
u4:	moveq	#3,d2
u5:	bsr.s	u3
	roxl.b	d1
	dbf	d2,u5
u14:	moveq	#0,d2
	move.b	d1,d1
	beq.s	u6
	subq.w	#1,d1
u13:	lsl.w	#1,d7
	bne.s	u77
	move.w	(a2)+,d7
	lsl.w	#1,d7
	bset	#0,d7
u77:	roxl.w	d2
	dbf	d1,u13
	moveq	#0,d1
u6:	rts

