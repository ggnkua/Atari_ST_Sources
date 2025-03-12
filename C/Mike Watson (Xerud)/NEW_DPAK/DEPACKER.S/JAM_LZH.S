; depack LZH (jam3/4)

	movem.w	d0-d1/D3/D5,-(a7)
	bra	.UNPACK
.RESET:
	move.l	a1,a2
	moveq	#$00,d2
	moveq	#-$02,d4
	moveq	#$00,d1
	move.w	#$0139,d5
.OUTER:	addq.w	#2,d4
	cmp.w	(a2)+,d7
	bhi.s	.OUTER
	move.w	$00(a3,d4.W),d3
	addq.w	#1,d3
	lsr.w	#1,d3
	cmp.w	-$02(a3,d2.W),d3
	bls.s	.BIDDLE
	move.w	$00(a3,d1.W),d0
	add.w	$02(a3,d1.W),d0
	cmp.w	d0,d3
	bls.s	.BIDDLE
.BITH:	move.w	d0,$00(a3,d2.W)
	move.w	d1,$00(a1,d2.W)
	move.w	d2,$00(a0,d1.W)
	move.w	d2,$02(a0,d1.W)
	addq.w	#2,d2
	addq.l	#4,d1
	move.w	$00(a3,d1.W),d0
	add.w	$02(a3,d1.W),d0
	cmp.w	d0,d3
	bhi.s	.BITH
.BIDDLE:	move.w	d3,$00(a3,d2.W)
	move.w	$00(a1,d4.W),d0
	move.w	d0,$00(a1,d2.W)
	move.w	d2,$00(a0,d0.W)
	addq.w	#2,d2
	dbf	d5,.OUTER
.MAKETABLE2:
	move.w	$00(a3,d1.W),d0
	add.w	$02(a3,d1.W),d0
	move.w	d0,$00(a3,d2.W)
	move.w	d1,$00(a1,d2.W)
	move.w	d2,$00(a0,d1.W)
	move.w	d2,$02(a0,d1.W)
	addq.w	#2,d2
	addq.l	#4,d1
	cmp.w	d7,d2
	bne.s	.MAKETABLE2
	rts
.CREATE:	move.l	.TABLE7(PC),a0
	lea	.TDATA1(PC),a1
	moveq	#$00,d0
	moveq	#$1F,d1
	moveq	#$00,d2
.LOOP1:	move.b	d0,(a0)+
	dbf	d1,.LOOP1
	dbf	d2,.EXIT1
	move.w	(a1)+,d3
	moveq	#$03,d2
.EXIT1:	rol.w	#4,d3
	move.w	d3,d1
	andi.w	#$000F,d1
	addq.b	#4,d0
	bcc.s	.LOOP1
	move.l	.TABLE8(PC),a0
	lea	.TDATA2(PC),a1
	moveq	#$05,d0
	moveq	#$03,d1
.LOOP2:	move.b	$00(a1,d0.W),d2
	ext.w	d2
.LOOP3:	move.b	d1,(a0)+
	dbf	d2,.LOOP3
	addq.w	#1,d1
	dbf	d0,.LOOP2
	rts
.CREATE2:	move.l	.TABLE1(PC),a0
	move.l	.TABLE5(PC),a1
	move.l	.TABLE4(PC),a2
	moveq	#$01,d1
	move.w	#$04E6,d2
	moveq	#$00,d4
	move.w	#$0139,d0
.CONTINUE:
	move.w	d1,(a0)+
	move.w	d2,(a1)+
	move.w	d4,(a2)+
	addq.w	#2,d2
	addq.w	#2,d4
	dbf	d0,.CONTINUE
	move.l	.TABLE1(PC),a0
	move.l	.TABLE2(PC),a3
	move.l	.TABLE6(PC),a1
	move.l	.TABLE3(PC),a2
	move.w	#$0274,d2
	moveq	#$00,d4
	move.w	#$0138,d0
.DOMORE:	move.w	(a0)+,d1
	add.w	(a0)+,d1
	move.w	d1,(a3)+
	move.w	d4,(a1)+
	move.w	d2,(a2)+
	move.w	d2,(a2)+
	addq.w	#4,d4
	addq.w	#2,d2
	dbf	d0,.DOMORE
	move.w	#$FFFF,(a3)
	clr.w	(a2)
	rts
.RESTORE:	bsr	.RESET
	bra	.BACK
.TABLE1:	dc.l	00
.TABLE2:	dc.l	00
.TABLE3:	dc.l	00
.TABLE4:	dc.l	00
.TABLE5:	dc.l	00
.TABLE6:	dc.l	00
.TABLE7:	dc.l	00
.TABLE8:	dc.l	00
.EXIT:	addq.l	#4,a7
	movem.w	(a7)+,d0-d1/D3/D5
	rts
.UNPACK:	move.l	a0,a5
	move.l	a1,a6
	lea	.TABLE1(PC),a0
	move.l	#0,(a0)
	move.l	#$274,4(a0)
	move.l	#$4E8,8(a0)
	move.l	#$9CE,12(a0)
	move.l	#$C42,16(a0)
	move.l	#$EB6,20(a0)
	move.l	#$112A,24(a0)
	move.l	#$122A,28(a0)
	move.l	a7,d1
	sub.l	#$1500,d1
	move.w	#7,d0
.TABLOOP:
	add.l	d1,(a0)+
	dbf	d0,.TABLOOP
	bsr	.CREATE
	bsr	.CREATE2
	move.l	.TABLE3(PC),a0
	move.l	.TABLE5(PC),a1
	move.l	.TABLE1(PC),a3
	move.l	a6,-(a7)
	add.l	4(a5),a6
	add.l	8(a5),a5
	add.l	#$0C,a5
	move.l	a6,a4
	move.w	#59,d0
.SPACES:	move.b	#$20,(a4)+
	dbf	d0,.SPACES
	moveq	#$08,d6
	move.b	-(a5),d5
	move.w	#$04E6,d7
	move.l	.TABLE8(PC),a4
.TOP:	cmp.l	(a7),a6
	ble	.EXIT
	move.w	$04E4(a1),d0
.MORE:	dbf	d6,.NOTEMPTY
	moveq	#$07,d6
	move.b	-(a5),d5
.NOTEMPTY:
	add.b	d5,d5
	bcc.s	.ZERO
	addq.w	#2,d0
.ZERO:	move.w	$00(a1,d0.W),d0
	cmp.w	d7,d0
	blt.s	.MORE
	move.w	d0,d1
	sub.w	d7,d0
	move.w	$04E4(a3),d4
	bmi	.RESTORE
.BACK:	move.w	$00(a0,d1.W),d1
.SCAN:	lea	$00(a3,d1.W),a2
	addq.w	#1,(a2)
	cmpm.w	(a2)+,(a2)+
	bcs.s	.FRSTGTR
	move.w	$00(a0,d1.W),d1
	bne.s	.SCAN
	lsr.w	#1,d0
	cmp.w	#$0100,d0
	bge.s	.GTE256
.WRITE:	move.b	d0,-(a6)
	bra.s	.TOP
.FRSTGTR:	subq.w	#1,-$0004(a2)
	move.w	-$0004(a2),d4
.SAME:	cmp.w	(a2)+,d4
	beq.s	.SAME
	subq.l	#4,a2
	addq.w	#1,(a2)
	suba.l	a3,a2
	move.w	$00(a1,d1.W),d4
	move.w	a2,$00(a0,d4.W)
	cmp.w	d7,d4
	bcc.s	.SKIP
	move.w	a2,$02(a0,d4.W)
.SKIP:	move.w	$00(a1,a2.W),d2
	move.w	d4,$00(a1,a2.W)
	move.w	d1,$00(a0,d2.W)
	cmp.w	d7,d2
	bcc.s	.SKIP2
	move.w	d1,$02(a0,d2.W)
.SKIP2:	move.w	d2,$00(a1,d1.W)
	move.w	$00(a0,a2.W),d1
	bne.s	.SCAN
	lsr.w	#1,d0
	cmp.w	#$0100,d0
	blt.s	.WRITE
.GTE256:	move.b	-1(a5),d1
	moveq	#$00,d2
	lsr.b	d6,d1
	or.b	d5,d1
	move.b	$00(a4,d1.W),d2
	sub.w	d2,d6
	bpl.s	.POSITIVE
	move.b	-(a5),d5
	move.b	d5,d4
	addq.w	#2,d6
	bmi.s	.OVERFLOW
	beq.s	.MODD4
	lsr.b	#1,d4
	lsl.b	#7,d5
	bra.s	.MODD4
.READONE:	move.b	-(a5),d5
	move.b	d5,d4
	lsl.b	#6,d5
	moveq	#$02,d6
	lsr.b	d6,d4
	bra.s	.DOCOPY
.POSITIVE:
	beq.s	.READONE
	move.b	(a5),d5
	subq.w	#6,d6
.OVERFLOW:
	neg.w	d6
	lsl.b	d6,d5
	move.b	d5,d4
	move.b	-(a5),d5
	move.b	d5,d2
	lsl.b	d6,d5
	subq.w	#8,d6
	neg.w	d6
	lsr.b	d6,d2
	or.b	d2,d4
.MODD4:	andi.w	#$003F,d4
.DOCOPY:	move.l	.TABLE7(PC),a0
	move.b	(a0,d1.W),d2
	lsl.w	#4,d2
	or.b	d4,d2
	lea	$01(a6,d2.W),a0
	subi.w	#$00FE,d0
	move.w	d0,d1
.COPY:	move.b	-(a0),d0
	move.b	d0,-(a6)
	dbf	d1,.COPY
	move.l	.TABLE3(PC),a0
	bra	.TOP

.TDATA2:	btst	d7,$2F3F(a7)
	move.l	(a7)+,-(a7)
.TDATA1:
	dc.w	$FFF7
	dc.w	$7777
	dc.w	$7773
	dc.w	$3333
	dc.w	$3333
	dc.w	$3331
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a1),-(a0)
	move.b	(a0),-(a0)
	ori.b	#$00,d0
	ori.b	#$00,d0
