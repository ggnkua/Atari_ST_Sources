.GOL00:	bra.s	.GOL04
.GOL02:	dcb.w	2,0

.GOL04:	movem.l	d0-a6,-(a7)
	lea	564(a0),a0
	pea	.GOL00(PC)
	move.l	a0,-(a7)
	move.l	a1,a0
	move.l	a0,-(a7)
	add.l	d0,a0
	lea	.GOL02(PC),a1
	move.l	a0,(a1)
	move.l	4(a7),a0
	move.l	(a7),a1
	lea	.GOL0C(PC),a3
	move.l	a1,d2
.GOL05:	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,d1
	subq.w	#1,d0
	bmi.s	.GOL07
.GOL06:	move.b	(a0)+,(a1)+
	dbf	d0,.GOL06
	cmp.w	#$FF,d1
	beq.s	.GOL05
.GOL07:	moveq	#0,d0
	move.b	(a0)+,(a3)
	bmi.s	.GOL09
	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	lsr.w	#5,d0
	tst.w	d0
	beq.s	.exit
	move.l	a1,a4
	suba.w	d0,a4
	move.w	(a3),d0
	andi.w	#$1F,d0
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GOL08:	move.b	(a4)+,(a1)+
	dbf	d0,.GOL08
	bra.s	.GOL05
.GOL09:	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	andi.w	#$7FFF,d0
	move.l	a1,a4
	suba.w	d0,a4
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	(a4)+,(a1)+
.GOL0A:	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GOL0B:	move.b	(a4)+,(a1)+
	dbf	d0,.GOL0B
	bra.s	.GOL05
.GOL0C:	dcb.w	2,0
.exit:	lea	12(a7),a7
	movem.l	(a7)+,d0-a6
	rts
