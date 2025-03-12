; depack LZW file

	movem.l	d0-a6,-(a7)
;	move.l	a0,a1
;	lea	$100(a1),a1
.LZW0D:	move.l	a0,a4
	move.l	a1,a6
	add.l	8(a0),a4
	add.l	4(a0),a6
	move.l	a6,a5
	move.l	4(a0),d4
	move.b	#$20,d3
	move.w	#$FED,d5
	move.l	a6,a3
	moveq	#0,d7
.LZW0E:	dbf	d7,.LZW0F
	move.b	-(a4),d6
	moveq	#7,d7
.LZW0F:	lsr.b	#1,d6
	bcc.s	.LZW10
	move.b	-(a4),-(a6)
	addq.w	#1,d5
	subq.l	#1,d4
	bgt.s	.LZW0E
	bra.s	.LZW13
.LZW10:	move.b	-2(a4),d0
	lsl.w	#4,d0
	move.b	-(a4),d0
	sub.w	d5,d0
	neg.w	d0
	and.w	#$FFF,d0
	lea	1(a6,d0.W),a0
	moveq	#$F,d1
	and.b	-(a4),d1
	addq.w	#2,d1
	moveq	#1,d0
	add.w	d1,d0
	cmp.l	a5,a0
	bgt.s	.LZW14
.LZW11:	move.b	-(a0),-(a6)
	dbf	d1,.LZW11
.LZW12:	add.l	d0,d5
	sub.l	d0,d4
	bgt.s	.LZW0E
.LZW13:
	movem.l	(a7)+,d0-a6
	rts
.LZW14:	cmp.l	a5,a0
	ble.s	.LZW11
	move.b	d3,-(a6)
	subq.l	#1,a0
	dbf	d1,.LZW14
	bra.s	.LZW12
