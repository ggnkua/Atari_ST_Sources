	movem.l	d0-a6,-(a7)
	lea	224(a0),a3
	move.l	a1,a2
.sq226:	moveq	#6,d6
.sq227:	move.b	(a3)+,d4
	moveq	#7,d2
.sq228:	add.b	d4,d4
	bcc.s	.sq22C
	moveq	#0,d0
	move.b	(a3)+,d0
	bmi.s	.sq229
	beq.s	.sq22E
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	bclr	d6,d0
	bra.s	.sq22A
.sq229:	bclr	#7,d0
	move.w	d0,d1
	lsl.w	d6,d1
	andi.b	#3,d0
	bne.s	.sq22A
	move.b	(a3)+,d0
	addq.w	#4,d0
.sq22A:	addq.w	#1,d0
	move.b	(a3)+,d1
	lea	-1(a2),a0
	suba.w	d1,a0
.sq22B:	move.b	(a0)+,(a2)+
	dbf	d0,.sq22B
	bra.s	.sq22D
.sq22C:	move.b	(a3)+,(a2)+
.sq22D:	dbf	d2,.sq228
	bra.s	.sq227
.sq22E:	movem.l	(a7)+,d0-a6
	rts
