	movem.l	d0-a6,-(a7)
	move.l	-(a0),d6	
	move.l	-(a0),d2
	move.l	a2,a4
	add.l	d6,a2
	moveq	#0,d0
.pp150:	move.b	-(a0),d0
	beq.s	.pp150
.pp151:	moveq	#0,d2
	cmpa.l	a2,a0
	bgt	.exit
	bsr.s	.pp1515
	bcs.s	.pp154
	move.b	-(a0),d2
.pp152:	move.b	d2,-(a2)
	bra.s	.pp156
.pp153:	moveq	#15,d4
	moveq	#2,d3
	bsr.s	.pp1518
	bne.s	.pp1513
	move.w	d4,d2
	bra.s	.pp152
.pp154:	bsr.s	.pp1515
	bcc.s	.pp159
	bsr.s	.pp1515
	bcc.s	.pp153
	bsr.s	.pp1515
	bcs.s	.pp155
	moveq	#2,d1
	bsr	.pp1522
	exg	d1,d2
	addq.w	#1,d2
	bset	d1,d2
	bra.s	.pp152
.pp155:	bsr.s	.pp1515
	bcs.s	.pp158
	moveq	#15,d4
	moveq	#3,d3
	bsr.s	.pp1518
	bne.s	.pp1513
	move.b	(a2),-(a2)
.pp156:	cmpa.l	a2,a4
	blt.s	.pp151
.pp157:
	movem.l	(a7)+,d0-a6
	rts
.pp158:	moveq	#4,d3
	bra.s	.pp1512
.pp159:	bsr.s	.pp1515
	bcs.s	.pp1527
	moveq	#1,d1
.pp1510:	lsr.b	#1,d0
	bne.s	.pp1511
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp1511:	addx.w	d2,d2
	dbf	d1,.pp1510
	move.w	d2,d1
	beq.s	.pp1526
	addq.w	#1,d1
	add.w	d1,d1
	subq.w	#1,d1
	bsr.s	.pp1522
	move.w	d2,d3
.pp1512:	bsr.s	.pp1517
.pp1513:	movea.l	a2,a1
	adda.l	d2,a1
.pp1514:	move.b	-(a1),-(a2)
	dbf	d3,.pp1514
	bra.s	.pp156
.pp1515:	lsr.b	#1,d0
	bne.s	.pp1516
	move.b	-(a0),d0
	roxr.b	#1,d0
.pp1516:	rts
.pp1517:	moveq	#0,d4
.pp1518:	moveq	#1,d1
	moveq	#0,d2
.pp1519:	lsr.b	#1,d0
	bne.s	.thanks_jpm
.pp1520:	move.b	-(a0),d0
	roxr.b	#1,d0
.thanks_jpm:
	addx.w	d2,d2
	dbf	d1,.pp1519
	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	eor.b	d1,d4
	bne.s	.pp1522
	rts
.pp1521:	moveq	#7,d1
.pp1522:	moveq	#0,d2
.pp1523:	lsr.b	#1,d0
	bne.s	.pp1525
.pp1524:	move.b	-(a0),d0
	roxr.b	#1,d0
.pp1525:	addx.w	d2,d2
	dbf	d1,.pp1523
	rts
.pp1526:	bsr.s	.pp1517
	move.w	d2,d3
	moveq	#1,d2
	bra.s	.pp1513
.pp1527:	moveq	#1,d3
	move.b	-(a0),d2
	bra.s	.pp1513
.exit:	rts

