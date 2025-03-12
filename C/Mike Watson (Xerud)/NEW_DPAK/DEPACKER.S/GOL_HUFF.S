	movem.l	d0-a6,-(a7)
.GHF01:	bra.s	.GHF05
.GHF03:	dcb.w	2,0
.upl:	dc.l	0
.GHF05:	pea	.GHF01(PC)
	lea	698(a0),a1
	move.l	144(a0),.upl
	move.l	d0,.GHF00
	lea	698(a0),a0
	move.l	a0,-(a7)
	move.l	.upl(PC),d0
	addq.l	#8,d0
	add.l	d0,a0
	move.l	a0,-(a7)
	add.l	d0,a0
	lea	.GHF03(PC),a1
	move.l	a0,(a1)
	move.l	4(a7),a4
	lea	$100(a4),a2
	lea	$300(a4),a0
	move.l	(a7),a1
	move.l	.GHF03(PC),a6
	moveq	#0,d0
	move.l	d0,d2
	move.l	d0,d1
.GHF06:	move.w	(a2)+,d1
	moveq	#$10,d2
	sub.b	(a4)+,d2
	bmi.s	.GHF08
	moveq	#1,d3
	lsl.l	d2,d3
	lea	0(a6,d1.L),a5
.GHF07:	move.b	d0,(a5)+
	subq.l	#1,d3
	bne.s	.GHF07
.GHF08:	addq.w	#1,d0
	cmp.w	#$100,d0
	bne.s	.GHF06
	move.l	.GHF03(PC),a5
	move.l	4(a7),a4
	lea	$100(a4),a2
	move.l	(a7),a1
	lea	$300(a4),a0
	move.l	4(a7),a6
	move.l	.GHF00(PC),d0
	add.l	d0,a6
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d3
	move.w	(a0),d0
.GHF09:	move.b	0(a5,d0.L),d1
	move.b	d1,(a1)+
	add.b	0(a4,d1.W),d3
	cmp.w	#$10,d3
	bcs.s	.GHF0A
	addq.l	#2,a0
	sub.w	#$10,d3
.GHF0A:	move.l	(a0),d0
	lsl.l	d3,d0
	clr.w	d0
	swap	d0
	cmp.l	a6,a0
	bcs.s	.GHF09
	move.l	4(a7),d0
	move.l	(a7),4(a7)
	move.l	d0,(a7)
	move.l	4(a7),a0
	move.l	(a7),a1
	lea	.GHF11(PC),a3
	move.l	a1,d2
.GHF0B:	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,d1
	subq.w	#1,d0
	bmi.s	.GHF0D
.GHF0C:	move.b	(a0)+,(a1)+
	dbf	d0,.GHF0C
	cmp.w	#$FF,d1
	beq.s	.GHF0B
.GHF0D:	moveq	#0,d0
	move.b	(a0)+,(a3)
	bmi.s	.GHF0F
	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	lsr.w	#5,d0
	tst.w	d0
	beq.s	.EXIT
	move.l	a1,a4
	suba.w	d0,a4
	move.w	(a3),d0
	andi.w	#$1F,d0
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GHF0E:	move.b	(a4)+,(a1)+
	dbf	d0,.GHF0E
	bra.s	.GHF0B
.GHF0F:	move.b	(a0)+,1(a3)
	move.w	(a3),d0
	andi.w	#$7FFF,d0
	move.l	a1,a4
	suba.w	d0,a4
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.GHF10:	move.b	(a4)+,(a1)+
	dbf	d0,.GHF10
	bra.s	.GHF0B
.GHF11:	dcb.w	2,0
.EXIT:	lea	12(a7),a7
	movem.l	(a7)+,d0-a6
	rts
.GHF00:	dc.l	0
