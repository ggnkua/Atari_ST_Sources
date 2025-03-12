	movem.l	a0-a6/d0-d7,-(a7)
	addq	#4,a0
	link	a2,#-$1C
	move.l	(a0)+,d0
	movea.l	a1,a5
	adda.l	d0,a5
	movea.l	a5,a4
	lea	-$C(a4),a4
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	pea	(a5)
	move.b	-(a6),d7
	bra	.A351F
.A3500:	move.w	d3,d5
.A3501:	add.b	d7,d7
.A3502:	dbcs	d5,.A3501
	beq.s	.A3505
	bcc.s	.A3503
	sub.w	d3,d5
	neg.w	d5
	bra.s	.A3508
.A3503:	moveq	#3,d6
	bsr.s	.A350E
	beq.s	.A3504
	bra.s	.A3507
.A3504:	moveq	#7,d6
	bsr.s	.A350E
	beq.s	.A3506
	addi.w	#$F,d5
	bra.s	.A3507
.A3505:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.A3502
.A3506:	moveq	#$D,d6
	bsr.s	.A350E
	addi.w	#$10E,d5
.A3507:	add.w	d3,d5
.A3508:	lea	.A352A(PC),a4
	move.w	d5,d2
	bne.s	.A3512
	add.b	d7,d7
	bne.s	.A3509
	move.b	-(a6),d7
	addx.b	d7,d7
.A3509:	bcs.s	.A350A
	moveq	#1,d6
	bra.s	.A3513
.A350A:	moveq	#3,d6
	bsr.s	.A350E
	tst.b	-$1C(a2)
	beq.s	.A350B
	move.b	-$12(a2,d5.W),-(a5)
	bra	.A351E
.A350B:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.A350C
	bra.s	.A350D
.A350C:	addi.b	#-$10,d5
.A350D:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	.A351E
.A350E:	clr.w	d5
.A350F:	add.b	d7,d7
	beq.s	.A3511
.A3510:	addx.w	d5,d5
	dbf	d6,.A350F
	tst.w	d5
	rts
.A3511:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.A3510
.A3512:	moveq	#2,d6
.A3513:	bsr.s	.A350E
	move.w	d5,d4
	move.b	$E(a4,d4.W),d6
	ext.w	d6
	tst.b	-$1B(a2)
	bne.s	.A3514
	addq.w	#4,d6
	bra.s	.A3518
.A3514:	bsr.s	.A350E
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	.A350E
	cmp.b	#7,d5
	blt.s	.A3516
	moveq	#0,d6
	bsr.s	.A350E
	beq.s	.A3515
	moveq	#2,d6
	bsr.s	.A350E
	add.w	d5,d5
	or.w	d1,d5
	bra.s	.A3519
.A3515:	or.b	-$1A(a2),d1
	bra.s	.A3517
.A3516:	or.b	-$19(a2,d5.W),d1
.A3517:	move.w	d1,d5
	bra.s	.A3519
.A3518:	bsr.s	.A350E
.A3519:	add.w	d4,d4
	beq.s	.A351A
	add.w	-2(a4,d4.W),d5
.A351A:	lea	1(a5,d5.W),a4
	move.b	-(a4),-(a5)
.A351B:	move.b	-(a4),-(a5)
	dbf	d2,.A351B
	bra.s	.A351E
.A351C:	add.b	d7,d7
	bne.s	.A351D
	move.b	-(a6),d7
	addx.b	d7,d7
.A351D:	bcs.s	.A3527
	move.b	-(a6),-(a5)
.A351E:	cmpa.l	a5,a3
	bne.s	.A351C
	cmpa.l	a6,a0
	beq.s	.A3528
.A351F:	moveq	#0,d6
	bsr	.A350E
	beq.s	.A3522
	move.b	-(a6),d0
	lea	-$1A(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.A3520:	cmp.b	d0,d1
	bne.s	.A3521
	addq.w	#2,d1
.A3521:	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,.A3520
	st	-$1B(a2)
	bra.s	.A3523
.A3522:	sf	-$1B(a2)
.A3523:	moveq	#0,d6
	bsr	.A350E
	beq.s	.A3525
	lea	-$12(a2),a1
	moveq	#$F,d0
.A3524:	move.b	-(a6),(a1)+
	dbf	d0,.A3524
	st	-$1C(a2)
	bra.s	.A3526
.A3525:	sf	-$1C(a2)
.A3526:	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	.A351C
.A3527:	bra	.A3500
.A3528:	movea.l	(a7)+,a0
	pea	(a2)
	bsr.s	.A352B
	movea.l	(a7)+,a2
	unlk	a2
.A3529:	movem.l	(a7)+,a0-a6/D0-d7
	rts
.A352A:	dc.b	$00,' ',$00,'`',$01,'`',$03,'`'
	dc.b	$07,'`',$0F,'`',$1F,'`',$00,$01
	dc.b	$03,$04,$05,$06,$07,$08
.A352B:	move.w	-2(a2),d7
.A352C:	dbf	d7,.A352D
	rts
.A352D:	move.l	-(a0),d0
	lea	0(a5,d0.L),a1
	lea	$7D00(a1),a2
.A352E:	moveq	#3,d6
.A352F:	move.w	(a1)+,d0
	moveq	#3,d5
.A3530:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,.A3530
	dbf	d6,.A352F
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	.A352E
	bra.s	.A352C
	dcb.w	2,0
