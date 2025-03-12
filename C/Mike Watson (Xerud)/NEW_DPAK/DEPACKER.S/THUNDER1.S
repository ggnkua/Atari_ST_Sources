	movem.l	d0-a6,-(a7)
	move.l	a0,a2
	move.l	a1,a4

	adda.l	#$C,a2
	movea.l	a2,a3
	adda.l	-4(a2),a3
	clr.l	d0
	move.l	d0,d1
.thu102:	clr.l	d4
	move.b	(a2)+,d4
	lsl.w	#8,d4
	move.b	(a2)+,d4
	btst	#14,d4
	beq.s	.thu103
	btst	#15,d4
	bne.s	.thu10B
	bra.s	.thu109
.thu103:	btst	#15,d4
	beq.s	.thu104
	bclr	#15,d4
	move.b	(a2)+,d1
.thu104:	addi.w	#$2000,d4
.thu105:	lsr.w	#1,d4
	beq.s	.thu108
	bcc.s	.thu106
	move.b	d1,(a4)+
	bra.s	.thu107
.thu106:	move.b	(a2)+,(a4)+
.thu107:	bra.s	.thu105
.thu108:	cmpa.l	a3,a2
	blt.s	.thu102
	movem.l	(a7)+,d0-a6
	rts
.thu109:	bclr	#14,d4
	move.b	(a2)+,d2
.thu10A:	move.b	d2,(a4)+
	dbf	d4,.thu10A
	bra.s	.thu102
.thu10B:	clr.l	d0
	bclr	#14,d4
	bclr	#15,d4
	lsl.l	#8,d4
	move.b	(a2)+,d4
	swap	d4
	move.b	d4,d0
	clr.w	d4
	swap	d4
	subq.l	#1,d0
	movea.l	a4,a1
	suba.l	d4,a1
.thu10C:	move.b	(a1)+,(a4)+
	dbf	d0,.thu10C
	bra.s	.thu102
