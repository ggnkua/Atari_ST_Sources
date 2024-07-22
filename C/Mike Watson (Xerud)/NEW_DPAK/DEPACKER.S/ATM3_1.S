	movem.l	a0-a6/D0-d7,-(a7)
	cmpi.l	#$41544F4D,(a0)+
	bne	.a311C
	move.l	(a0)+,d0
	move.l	d0,-(a7)
	lea	(a1,d0.L),a5
	movea.l	a5,a4
	lea	.a3128(PC),a3
	moveq	#$19,d0
.a3100:	move.b	-(a4),(a3)+
	dbf	d0,.a3100
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.l	(a0)+,d0
	lea	0(a0,d0.L),a6
	bsr	.a3114
	bra.s	.a3111
.a3101:	moveq	#6,d6
.a3102:	add.w	d7,d7
	beq.s	.a3106
.a3103:	dbcc	d6,.a3102
	bcs.s	.a3104
	moveq	#6,d5
	sub.w	d6,d5
	bra.s	.a3108
.a3104:	moveq	#3,d6
	bsr.s	.a3109
	beq.s	.a3105
	addq.w	#6,d5
	bra.s	.a3108
.a3105:	moveq	#7,d6
	bsr.s	.a3109
	beq.s	.a3107
	addi.w	#$15,d5
	bra.s	.a3108
.a3106:	bsr.s	.a3114
	addx.w	d7,d7
	bra.s	.a3103
.a3107:	moveq	#$D,d6
	bsr.s	.a3109
	addi.w	#$114,d5
.a3108:	move.w	d5,-(a7)
	bne.s	.a310D
	lea	.a311F(PC),a4
	bra.s	.a310E
.a3109:	clr.w	d5
.a310A:	add.w	d7,d7
	beq.s	.a310C
.a310B:	addx.w	d5,d5
	dbf	d6,.a310A
	tst.w	d5
	rts
.a310C:	bsr.s	.a3114
	addx.w	d7,d7
	bra.s	.a310B
.a310D:	lea	.a311E(PC),a4
.a310E:	moveq	#2,d6
	bsr.s	.a3109
	move.w	d5,d4
	move.b	$E(a4,d4.W),d6
	ext.w	d6
	bsr.s	.a3109
	add.w	d4,d4
	beq.s	.a310F
	add.w	-2(a4,d4.W),d5
.a310F:	lea	1(a5,d5.W),a4
	move.w	(a7)+,d5
	move.b	-(a4),-(a5)
.a3110:	move.b	-(a4),-(a5)
	dbf	d5,.a3110
.a3111:	moveq	#$B,d6
	moveq	#$B,d5
.a3112:	add.w	d7,d7
	beq.s	.a311D
.a3113:	dbcc	d6,.a3112
	bcs.s	.a3115
	sub.w	d6,d5
	bra.s	.a3117
.a3114:	move.b	-(a6),-(a7)
	move.w	(a7)+,d7
	move.b	-(a6),d7
	rts
.a3115:	moveq	#7,d6
	bsr.s	.a3109
	beq.s	.a3116
	addq.w	#8,d5
	addq.w	#3,d5
	bra.s	.a3117
.a3116:	moveq	#2,d6
	bsr.s	.a3109
	swap	d5
	moveq	#$F,d6
	bsr.s	.a3109
	addq.l	#8,d5
	addq.l	#3,d5
.a3117:	subq.w	#1,d5
	bmi.s	.a3119
	moveq	#1,d6
	swap	d6
.a3118:	move.b	-(a6),-(a5)
	dbf	d5,.a3118
	sub.l	d6,d5
	bpl.s	.a3118
.a3119:	cmpa.l	a6,a0
.a311A:	bne	.a3101
	cmp.w	#-$8000,d7
	bne.s	.a311A
	movea.l	(a7)+,a0
	bsr.s	.a3120
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	moveq	#$19,d0
.a311B:	move.b	-(a3),(a4)+
	dbf	d0,.a311B
.a311C:	movem.l	(a7)+,a0-a6/D0-d7
	rts
.a311D:	bsr.s	.a3114
	addx.w	d7,d7
	bra.s	.a3113
.a311E:	dc.b	$00,' ',$00,'`',$01,'`',$03,'`'
	dc.b	$07,'`',$0F,'`',$1F,'`',$04,$05
	dc.b	$07,$08,$09,$0A,$0B,$0C
.a311F:	dc.b	$00,' ',$00,'`',$00,$E0,$01,$E0
	dc.b	$03,$E0,$05,$E0,$07,$E0,$04,$05
	dc.b	$06,$07,$08,$08,$08,$08
.a3120:	move.w	-(a0),d7
	clr.w	(a0)
.a3121:	dbf	d7,.a3122
	rts
.a3122:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.L),a1
	lea	$7D00(a1),a2
.a3123:	moveq	#3,d6
.a3124:	move.w	(a1)+,d0
	moveq	#3,d5
.a3125:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,.a3125
	dbf	d6,.a3124
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	.a3123
	bra.s	.a3121
.a3128:	dcb.w	14,0
