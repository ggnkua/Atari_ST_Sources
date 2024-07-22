	movem.l	d0-a6,-(a7)
	move.l	-(a0),a2
	add.l	a1,a2
	move.l	-(a0),d5
	move.l	-(a0),d0
	eor.l	d0,d5
.LSD0B:	lsr.l	#1,d0
	bne.s	.LSD0C
	bsr.s	.LSD18
.LSD0C:	bcs.s	.LSD13
	moveq	#8,d1
	moveq	#1,d3
	lsr.l	#1,d0
	bne.s	.LSD0D
	bsr.s	.LSD18
.LSD0D:	bcs.s	.LSD15
	moveq	#3,d1
	clr.w	d4
.LSD0E:	bsr.s	.LSD19
	move.w	d2,d3
	add.w	d4,d3
.LSD0F:	moveq	#7,d1
.LSD10:	lsr.l	#1,d0
	bne.s	.LSD11
	bsr.s	.LSD18
.LSD11:	roxl.l	#1,d2
	dbf	d1,.LSD10
	move.b	d2,-(a2)
	dbf	d3,.LSD0F
	bra.s	.LSD17
.LSD12:	moveq	#8,d1
	moveq	#8,d4
	bra.s	.LSD0E
.LSD13:	moveq	#2,d1
	bsr.s	.LSD19
	cmp.b	#2,d2
	blt.s	.LSD14
	cmp.b	#3,d2
	beq.s	.LSD12
	moveq	#8,d1
	bsr.s	.LSD19
	move.w	d2,d3
	move.w	#$C,d1
	bra.s	.LSD15
.LSD14:	move.w	#9,d1
	add.w	d2,d1
	addq.w	#2,d2
	move.w	d2,d3
.LSD15:	bsr.s	.LSD19
.LSD16:	subq.w	#1,a2
	move.b	0(a2,d2.W),(a2)
	dbf	d3,.LSD16
.LSD17:	cmp.l	a2,a1
	blt.s	.LSD0B
	movem.l	(a7)+,d0-a6
	rts
.LSD18:	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
	rts
.LSD19:	subq.w	#1,d1
	clr.w	d2
.LSD1A:	lsr.l	#1,d0
	bne.s	.LSD1B
	move.l	-(a0),d0
	eor.l	d0,d5
	move	#$10,CCR
	roxr.l	#1,d0
.LSD1B:	roxl.l	#1,d2
	dbf	d1,.LSD1A
	rts

