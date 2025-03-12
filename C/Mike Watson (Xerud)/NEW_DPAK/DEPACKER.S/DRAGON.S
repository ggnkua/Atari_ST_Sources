	movea.l	a1,a2
	move.l	-(a0),d0
	adda.l	d0,a2
	lea	.ivd0F(PC),a4
	move.l	-(a0),d0
	move.l	-(a0),d4
.ivd01:	bsr	.ivd0D
	bcs.s	.ivd02
	moveq	#7,d1
	bsr	.ivd0A
	move.b	d2,-(a2)
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd02:	bsr	.ivd0D
	bcs.s	.ivd06
	bsr	.ivd0D
	bcs.s	.ivd04
	moveq	#3,d1
	bsr	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	adda.w	#1,a3
	move.b	-(a3),-(a2)
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd03:	moveq	#8,d1
	bsr	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	move.b	-(a3),-(a2)
	move.b	-(a3),-(a2)
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd04:	moveq	#2,d1
	bsr	.ivd0A
	beq.s	.ivd03
	move.w	d2,d3
	addi.w	#1,d3
	moveq	#1,d1
	bsr	.ivd0A
	move.w	d2,d7
	lsl.w	#1,d7
	move.w	0(a4,d7.W),d1
	bsr	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	adda.w	8(a4,d7.W),a3
.ivd05:	move.b	-(a3),-(a2)
	dbf	d3,.ivd05
	cmpa.l	a2,a1
	blt.s	.ivd01
	rts
.ivd06:	bsr	.ivd0D
	bcs.s	.ivd08
	moveq	#1,d1
	bsr.s	.ivd0A
	move.w	d2,d1
	lsl.w	#1,d1
	move.w	d1,d7
	addi.w	#1,d1
	bsr.s	.ivd0A
	add.w	$10(a4,d7.W),d2
	move.w	d2,d3
	addi.w	#9,d3
	moveq	#1,d1
	bsr.s	.ivd0A
	move.w	d2,d7
	lsl.w	#1,d7
	move.w	0(a4,d7.W),d1
	bsr.s	.ivd0A
	movea.l	a2,a3
	adda.w	d2,a3
	adda.w	8(a4,d7.W),a3
.ivd07:	move.b	-(a3),-(a2)
	dbf	d3,.ivd07
	cmpa.l	a2,a1
	blt	.ivd01
	rts
.ivd08:	moveq	#1,d1
	bsr.s	.ivd0A
	move.w	d2,d1
	lsl.w	#1,d1
	move.w	d1,d7
	addi.w	#1,d1
	bsr.s	.ivd0A
	add.w	$10(a4,d7.W),d2
	move.w	d2,d3
	addi.w	#7,d3
.ivd09:	moveq	#7,d1
	bsr.s	.ivd0A
	move.b	d2,-(a2)
	dbf	d3,.ivd09
	cmpa.l	a2,a1
	blt	.ivd01
	rts
.ivd0A:	clr.w	d2
.ivd0B:	lsr.l	#1,d0
	bne.s	.ivd0C
	move.l	d4,d0
	move.l	-(a0),d4
	move	#$10,CCR
	roxr.l	#1,d0
.ivd0C:	roxl.l	#1,d2
	dbf	d1,.ivd0B
	rts
.ivd0D:	lsr.l	#1,d0
	bne.s	.ivd0E
	move.l	d4,d0
	move.l	-(a0),d4
	move	#$10,CCR
	roxr.l	#1,d0
.ivd0E:	rts
.ivd0F:	dc.b	$00,$07,$00,$09,$00,$0B,$00,$0C
	dc.b	$00,$00,$01,$00,$05,$00,$15,$00
	dc.b	$00,$00,$00,$03,$00,$12,$00,'Q'

.ivd1F:	dc.b	'&',$00
.ivd20:	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00
	dcb.w	14,0
	dc.b	$00
.ivd21:	dc.b	'&',$00
.ivd22:	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00
	dcb.w	17,0
	even