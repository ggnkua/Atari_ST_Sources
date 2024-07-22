	movem.l	a0-a6/D0-d7,-(a7)
	lea	0(a0,d0.L),a5
	bsr.s	.fir149F
	cmp.l	#$46697265,d7
	bne.s	.fir149E
	movea.l	a1,a0
	bsr.s	.fir149F
	move.l	d7,(a7)
	lea	0(a0,d7.L),a6
	bsr.s	.fir149F
	lea	.fir14BC(PC),a4
	moveq	#1,d6
	swap	d6
	moveq	#0,d5
.fir149A:	bsr.s	.fir14A3
	bcc.s	.fir149D
	moveq	#0,d1
	bsr.s	.fir14A3
	bcc.s	.fir149C
	movea.l	a4,a1
	moveq	#3,d3
.fir149B:	move.l	-(a1),d0
	bsr.s	.fir14A6
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.fir149B
	add.l	$10(a1),d1
.fir149C:	move.b	-(a5),-(a6)
	dbf	d1,.fir149C
.fir149D:	cmpa.l	a0,a6
	bgt.s	.fir14A9
.fir149E:	movem.l	(a7)+,a0-a6/D0-d7
	rts
.fir149F:	moveq	#3,d0
.fir14A0:	move.b	-(a5),d7
	ror.l	#8,d7
	dbf	d0,.fir14A0
	rts
.fir14A1:	move.w	a5,d7
	btst	#0,d7
	bne.s	.fir14A2
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	.fir14A8
.fir14A2:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	.fir14A8
.fir14A3:	add.l	d7,d7
	beq.s	.fir14A4
	rts
.fir14A4:	move.w	a5,d7
	btst	#0,d7
	bne.s	.fir14A5
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.fir14A5:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.fir14A6:	moveq	#0,d1
.fir14A7:	add.l	d7,d7
	beq.s	.fir14A1
.fir14A8:	addx.w	d1,d1
	dbf	d0,.fir14A7
	rts
.fir14A9:	moveq	#1,d0
	bsr.s	.fir14A6
	subq.w	#1,d1
	bmi.s	.fir14AD
	beq.s	.fir14AF
	subq.w	#1,d1
	beq.s	.fir14B0
	bsr.s	.fir14A3
	bcc.s	.fir14AE
	bsr.s	.fir14A3
	bcc.s	.fir14B1
	bra.s	.fir14B2
.fir14AA:	moveq	#1,d0
	bsr.s	.fir14A6
	subq.w	#1,d1
	bpl.s	.fir14AC
	moveq	#0,d0
	rts
.fir14AB:	moveq	#1,d0
	bsr.s	.fir14A6
.fir14AC:	add.w	d1,d1
	add.w	d1,d1
	movem.w	$10(a4,d1.W),d5/D0
	bsr.s	.fir14A6
	add.l	d5,d1
	rts
.fir14AD:	moveq	#1,d0
	bsr.s	.fir14A6
	subq.w	#1,d1
	bmi.s	.fir14B6
	add.w	d1,d1
	add.w	d1,d1
	movem.w	$20(a4,d1.W),d2/D0
	bsr.s	.fir14A6
	add.w	d1,d2
	bsr.s	.fir14AB
	move.w	d2,d0
	bra.s	.fir14B8
.fir14AE:	moveq	#2,d0
	bsr.s	.fir14A6
	moveq	#0,d0
	bset	d1,d0
	bra.s	.fir14B5
.fir14AF:	moveq	#7,d0
	bsr.s	.fir14A6
	moveq	#0,d0
	bra.s	.fir14B9
.fir14B0:	bsr.s	.fir14AA
	tst.w	d0
	beq.s	.fir14B5
	moveq	#1,d0
	bra.s	.fir14B9
.fir14B1:	bsr.s	.fir14AA
	tst.w	d0
	beq.s	.fir14B4
	moveq	#2,d0
	bra.s	.fir14B9
.fir14B2:	bsr.s	.fir14AA
	tst.w	d0
	beq.s	.fir14B3
	moveq	#3,d0
	bra.s	.fir14B9
.fir14B3:	moveq	#-1,d0
	bra.s	.fir14B5
.fir14B4:	move.b	(a6),d0
.fir14B5:	move.b	d0,-(a6)
	bra.s	.fir14BB
.fir14B6:	bsr.s	.fir14AB
	beq.s	.fir14BB
	move.b	(a6),d0
.fir14B7:	move.b	d0,-(a6)
	dbf	d1,.fir14B7
	sub.l	d6,d1
	bmi.s	.fir14BB
	bra.s	.fir14B7
.fir14B8:	subq.w	#2,d0
.fir14B9:	lea	2(a6,d1.L),a1
	adda.w	d0,a1
	move.b	-(a1),-(a6)
.fir14BA:	move.b	-(a1),-(a6)
	dbf	d0,.fir14BA
.fir14BB:	bra	.fir149A
	dc.b	$03,$FF,$00,$09
	ori.b	#2,d7
	ori.b	#1,d3
	ori.b	#1,d3
.fir14BC:	ori.b	#$E,d0
	ori.b	#7,d0
	ori.b	#4,d0
	ori.b	#1,d0
	ori.b	#0,d3
	ori.b	#$10,d7
	dc.b	$00,$0B
	btst	d0,(a0)
	dc.b	$00,$0F
	move.b	(a0),-(a0)
	ori.b	#5,d3
	ori.b	#$15,d5
	ori.b	#$55,d7
	dcb.w	2,0
