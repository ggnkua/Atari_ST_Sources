	move.l	a6,a0
	move.l	a5,a1
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d5
	move.l	a1,a2
	add.l	d0,a0
	add.l	d1,a2
	move.l	-(a0),d0
	eor.l	d0,d5
.BYT00:	lsr.l	#1,d0
	bne.s	.BYT01
	bsr.s	.BYT0E
.BYT01:	bcs.s	.BYT08
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	.BYT02
	bsr.s	.BYT0E
.BYT02:	bcs.s	.BYT0A
	moveq	#3,d1
	clr.w	d4
.BYT03:	bsr.s	.BYT0F
	move.w	d2,d3
	add.w	d4,d3
.BYT04:	moveq	#7,d1
.BYT05:	lsr.l	#1,d0
	bne.s	.BYT06
	bsr.s	.BYT0E
.BYT06:	roxl.l	#1,d2
	dbf	d1,.BYT05
	move.b	d2,-(a2)
	dbf	d3,.BYT04
	bra.s	.BYT0C
.BYT07:	moveq	#8,d1
	moveq	#8,d4
	bra.s	.BYT03
.BYT08:	moveq	#2,d1
	bsr.s	.BYT0F
	cmp.b	#2,d2
	blt.s	.BYT09
	cmp.b	#3,d2
	beq.s	.BYT07
	moveq	#8,d1
	bsr.s	.BYT0F
	move.w	d2,d3
	move.w	#$C,d1
	bra.s	.BYT0A
.BYT09:	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
.BYT0A:	bsr.s	.BYT0F
.BYT0B:	subq.w	#1,a2
	move.b	0(a2,d2.W),(a2)
	dbf	d3,.BYT0B
.BYT0C:	cmp.l	a2,a1
	blt.s	.BYT00
	tst.l	d5
	beq.s	.BYT0D
	nop
.BYT0D:	rts
.BYT0E:	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts
.BYT0F:	subq.w	#1,d1
	clr.w	d2
.BYT10:	lsr.l	#1,d0
	bne.s	.BYT11
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
.BYT11:	roxl.l	#1,d2
	dbf	d1,.BYT10
	rts
