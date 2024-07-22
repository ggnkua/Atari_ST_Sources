	movem.l	d0-a6,-(a7)
	move.l	a1,a6
	move.l	a0,a4
	movep.w	$e(a4),d4
	move.b	$d(a4),d4
	swap	d4
	movep.w	$c(a4),d4
	move.b	$B(a4),d4
	moveq	#2,d0
	add.b	(a4),d0
	adda.w	d0,a4
	movea.l	a6,a3
	moveq	#0,d7
	move.l	a6,d5
	sub.l	#$FED,d5
	move.w	#$FFF,d3
	dbf	d7,.pfx08
.pfx07:	move.b	(a4)+,d6
	moveq	#7,d7
.pfx08:	lsr.b	#1,d6
	bcc.s	.pfx09
	move.b	(a4)+,(a6)+
	subq.l	#1,d4
	ble.s	.exit
	dbf	d7,.pfx08
	bra.s	.pfx07
.pfx09:	movep.w	1(a4),d0
	lsr.w	#4,d0
	move.b	(a4)+,d0
	move.l	a6,d1
	sub.l	d5,d1
	and.w	d3,d1
	sub.w	d1,d0
	neg.w	d0
	and.w	d3,d0
	neg.w	d0
	lea	-1(a6,d0.W),a0
	moveq	#$F,d1
	and.b	(a4)+,d1
	addq.w	#2,d1
	moveq	#1,d0
	add.w	d1,d0
.pfx0A:	move.b	(a0)+,(a6)+
	dbf	d1,.pfx0A
	sub.l	d0,d4
	ble.s	.exit
	dbf	d7,.pfx08
	bra.s	.pfx07
.exit:	movem.l	(a7)+,d0-a6
	rts
