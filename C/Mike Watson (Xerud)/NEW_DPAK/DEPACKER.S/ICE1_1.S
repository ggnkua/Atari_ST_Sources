	movem.l	d0-a6,-(a7)
	move.l	a1,a4
	lea	0(a0,d0.l),a5
	bsr.s	.ice117
	cmpi.l	#'Ice!',d7
	bne.s	.ice112
	adda.w	#$78,a0
	bsr.s	.ice117
	move.l	d7,(a7)
	lea	0(a1,d7.l),a6
	movea.l	a6,a3
	movea.l	a6,a1
	bsr.s	.ice117
	bsr.s	.ice113
	move.l	(a7),d0
.ice112:	movem.l	(a7)+,d0-a6
	rts
.ice113:	bsr.s	.ice11b
	bcc.s	.ice116
	moveq	#0,d1
	bsr.s	.ice11b
	bcc.s	.ice115
	lea	.ice128(pc),a1
	moveq	#3,d3
.ice114:	move.l	-(a1),d0
	bsr.s	.ice11e
	swap	d0
	cmp.w	d0,d1
	dbne	d3,.ice114
	add.l	16(a1),d1
.ice115:	move.b	-(a5),-(a6)
	dbra	d1,.ice115
.ice116:	cmpa.l	a4,a6
	bgt.s	.ice120
	rts
.ice117:	moveq	#3,d0
.ice118:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,.ice118
	rts
.ice119:	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice11a
	move.l	-(a5),d7
	addx.l	d7,d7
	addx.w	d1,d1
	dbra	d0,.ice11f
	rts
.ice11a:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	addx.w	d1,d1
	dbra	d0,.ice11f
	rts
.ice11b:	add.l	d7,d7
	beq.s	.ice11c
	rts
.ice11c:	move.w	a5,d7
	btst	#0,d7
	bne.s	.ice11d
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
.ice11d:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
.ice11e:	moveq	#0,d1
.ice11f:	add.l	d7,d7
	beq.s	.ice119
	addx.w	d1,d1
	dbra	d0,.ice11f
	rts
.ice120:	lea	.ice129(pc),a1
	moveq	#3,d2
.ice121:	bsr.s	.ice11b
	dbcc	d2,.ice121
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.ice122
	bsr.s	.ice11e
.ice122:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.ice124
	lea	.ice12a(pc),a1
	moveq	#1,d2
.ice123:	bsr.s	.ice11b
	dbcc	d2,.ice123
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.ice11e
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	.ice126
.ice124:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	.ice11b
	bcc.s	.ice125
	moveq	#8,d0
	moveq	#$40,d2
.ice125:	bsr.s	.ice11e
	add.w	d2,d1
.ice126:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.ice127:	move.b	-(a1),-(a6)
	dbra	d4,.ice127
	bra	.ice113

	dc.b	$03,$ff,$00,$09,$00,$07,$00,$02
	dc.b	$00,$03,$00,$01,$00,$03,$00,$01
.ice128:	dc.b	$00,$00
	dc.b	$00,$0e,$00,$00,$00,$07,$00,$00
	dc.b	$00,$04,$00,$00,$00,$01
.ice129:	dc.b	$09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b	$01,$00
.ice12a:	dc.b	$0b,$04,$07,$00,$01,$20,$00,$00
	dc.b	$00,$20
