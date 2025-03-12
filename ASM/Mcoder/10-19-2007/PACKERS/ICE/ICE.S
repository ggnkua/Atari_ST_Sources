SOURCE=$80000
DEST=$90000

	lea	source+4,a0
	lea	dest,a1
	move.l	(a0)+,d0
	lea	-8(a0,d0.l),a5
	move.l	(a0)+,d0
	move.l a1,a4
	move.l a1,a6
	add.l	d0,a6
	move.l a6,a3
	bsr.s	ice_08
	bsr.s	ice_04
	jmp	dest
ice_04:	bsr.s	ice_0c
	bcc.s	ice_07
	moveq	#0,d1
	bsr.s	ice_0c
	bcc.s	ice_06
	lea	ice_1a(pc),a1
	moveq	#4,d3
ice_05:	move.l	-(a1),d0
	bsr.s	ice_0f
	swap	d0
	cmp	d0,d1
	dbne	d3,ice_05
	add.l	20(a1),d1
ice_06:	move.b	-(a5),-(a6)
	dbra	d1,ice_06
ice_07:	cmp.l	a4,a6
	bgt.s	ice_12
	rts
ice_08:	moveq	#3,d0
ice_09:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,ice_09
	rts
ice_0a:	move	a5,d7
	btst	#0,d7
	bne.s	ice_0b
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	ice_11
ice_0b:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	ice_11
ice_0c:	add.l	d7,d7
	beq.s	ice_0d
	rts
ice_0d:	move	a5,d7
	btst	#0,d7
	bne.s	ice_0e
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
ice_0e:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
ice_0f:	moveq	#0,d1
ice_10:	add.l	d7,d7
	beq.s	ice_0a
ice_11:	addx	d1,d1
	dbra	d0,ice_10
	rts
ice_12:	lea	ice_1b(pc),a1
	moveq	#3,d2
ice_13:	bsr.s	ice_0c
	dbcc	d2,ice_13
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext	d0
	bmi.s	ice_14
	bsr.s	ice_0f
ice_14:	move.b	6(a1,d2.w),d4
	add	d1,d4
	beq.s	ice_16
	lea	ice_1c(pc),a1
	moveq	#1,d2
ice_15:	bsr.s	ice_0c
	dbcc	d2,ice_15
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext	d0
	bsr.s	ice_0f
	add	d2,d2
	add	6(a1,d2.w),d1
	bra.s	ice_18
ice_16:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	ice_0c
	bcc.s	ice_17
	moveq	#8,d0
	moveq	#$40,d2
ice_17:	bsr.s	ice_0f
	add	d2,d1
ice_18:	lea	2(a6,d4.w),a1
	add	d1,a1
	move.b	-(a1),-(a6)
ice_19:	move.b	-(a1),-(a6)
	dbra	d4,ice_19
	bra	ice_04

	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice_1a:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice_1b:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice_1c:	DC.B $0b,$04,$07,$00,$01,$20,$00,$00
	DC.B $00,$20
