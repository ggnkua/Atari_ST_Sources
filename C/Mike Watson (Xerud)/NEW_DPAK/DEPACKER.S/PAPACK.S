
	move.l	d3,d4
	add.l	a1,d4
	move.l	d5,d6
	add.l	d4,d6

.pa5C:	clr.w	d0
	move.b	(a2)+,d0
	blt.s	.pa5F
	bne.s	.pa5E
	move.b	(a2)+,d0
	asl.w	#8,d0
	move.b	(a2)+,d0
	tst.w	d0
	beq.s	.exit
	bra.s	.pa5E

.pa5D:	move.b	(a2)+,(a1)+

.pa5E:	dbf	d0,.pa5D
	bra.s	.pa5C

.pa5F:	move.b	d0,d1
	andi.b	#$1F,d0
	addq.b	#2,d0
	asl.w	#3,d1
	move.b	(a2)+,d1
	ori.w	#-$800,d1
	lea	0(a1,d1.W),a3

.pa60:	move.b	(a3)+,(a1)+
	dbf	d0,.pa60
	bra.s	.pa5C

.exit:	rts
