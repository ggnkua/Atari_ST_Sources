	movem.l	d0-a6,-(a7)
	movea.l	-(a0),a2
	adda.l	a1,a2
	move.l	-(a0),d5
	move.l	-(a0),d0
	eor.l	d0,d5
.stdp09:	lsr.l	#1,d0
	bne.s	.stdp0A
	bsr.s	.stdp16
.stdp0A:	bcs.s	.stdp11
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	.stdp0B
	bsr.s	.stdp16
.stdp0B:	bcs.s	.stdp13
	moveq	#3,d1
	clr.w	d4
.stdp0C:	bsr.s	.stdp17
	move.w	d2,d3
	add.w	d4,d3
.stdp0D:	moveq	#7,d1
.stdp0E:	lsr.l	#1,d0
	bne.s	.stdp0F
	bsr.s	.stdp16
.stdp0F:	roxl.l	#1,d2
	dbf	d1,.stdp0E
	move.b	d2,-(a2)
	dbf	d3,.stdp0D
	bra.s	.stdp15
.stdp10:	moveq	#8,d1
	moveq	#8,d4
	bra.s	.stdp0C
.stdp11:	moveq	#2,d1
	bsr.s	.stdp17
	cmp.b	#2,d2
	blt.s	.stdp12
	cmp.b	#3,d2
	beq.s	.stdp10
	moveq	#8,d1
	bsr.s	.stdp17
	move.w	d2,d3
	move.w	#$C,d1
	bra.s	.stdp13
.stdp12:	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
.stdp13:	bsr.s	.stdp17
.stdp14:	subq.w	#1,a2
	move.b	(a2,d2.W),(a2)
	dbf	d3,.stdp14
.stdp15:	cmpa.l	a2,a1
	blt.s	.stdp09
	movem.l	(a7)+,d0-a6
	rts
.stdp16:	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts
.stdp17:	subq.w	#1,d1
	clr.w	d2
.stdp18:	lsr.l	#1,d0
	bne.s	.stdp19
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
.stdp19:	roxl.l	#1,d2
	dbf	d1,.stdp18
	rts
