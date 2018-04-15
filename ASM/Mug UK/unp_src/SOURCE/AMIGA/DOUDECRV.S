;------------------------------------------------------------------------
;	Double-Action V1.0 Decruncher ripped by NATIVE/EFFECT
;------------------------------------------------------------------------
Decr:	lea	$dff000.l,A3
	move.w	#$4000,$009a(A3)
	move.w	#$0200,$0096(a3)
	lea	$bfd100.l,A1
	move.b	#$00fd,(A1)
	move.b	#$0087,(A1)
	move.b	#$00fd,(A1)
	bset	#$0001,$0f01(A1)
;	move.l	Z2025c+30(pc),A7		;Stack-Ptr

	lea	Z20068(pc),A0
	move.l	Z2025c+22(pc),A1
	move.l	A1,A2
	move.w	#$0215,D0
Z2005c:	move.b	(A0)+,(A1)+
	dbf	D0,Z2005c
	lea	Z2025c+34(pc),A0
	jmp	(A2)
Z20068:	move.l	Z2025c+10(pc),A1
	move.l	Z2025c+4(pc),D0
	sub.l	A1,D0
	cmp.l	A1,A0
	bcs.s	Z200aa
Z20076:	move.l	(A0)+,(A1)+
Z20078:	subq.l	#4,D0
	bne.s	Z20076
	bra.s	Z200ee
;------------------------------------------------------------------------
Z200aa:	add.l	D0,A0
	add.l	D0,A1
Z200ae:	move.l	-(A0),-(A1)
	subq.l	#4,D0
	bne.s	Z200ae
	bra.s	Z200ee
Z200b6:	subq.w	#1,D6
Z200b8:	move.l	D6,D3
	lea	Z200c2(pc),A6
Z200be:	moveq	#$08,D4
	jmp	(A4)
Z200c2:	move.b	D6,-(A2)
	dbf	D3,Z200be
	lea	Z200ce(pc),A6
	bra.s	Z20136
Z200ce:	tst.b	D6
	beq.s	Z20124
	bra.s	Z2011e
Z200d4:	moveq	#$03,D4
	lea	Z200dc(pc),A6
	jmp	(A4)
Z200dc:	add.w	#$0006,D6
	bra.s	Z200b8
Z200e2:	moveq	#$0a,D4
Z200e4:	lea	Z200b6(pc),a6
	jmp	(A4)
Z200ea:	moveq	#$10,D4
	bra.s	Z200e4
Z200ee:	move.l	Z2025c+4(pc),A0
	move.l	Z2025c(pc),A2
	add.l	Z2025c+26(pc),A2
	move.l	Z2025c+10(pc),A1
	moveq	#$00,D7
	move.l	-(a0),D5
	lea	Z201d6(pc),A4
	lea	Z2013a(pc),A5
	moveq	#$00,D2
Z2010c:	lea	Z20114(pc),A6
	moveq	#$03,D4
	jmp	(A4)
Z20114:	cmp.b	#$0006,D6
	bcs.s	Z200b8
	beq.s	Z20124
Z2011e:	lea	Z2015a(pc),A6
	jmp	(A5)
Z20124:	lea	Z2012a(pc),A6
	jmp	(A5)
Z2012a:	cmp.b	#$0002,D6
	bcs.s	Z20142
	beq.s	Z2013e
	lea	Z2014a(pc),A6
Z20136:	moveq	#$01,D4
	jmp	(A4)
Z2013a:	moveq	#$02,D4
	jmp	(A4)
Z2013e:	moveq	#$03,D3
	bra.s	Z20184
Z20142:	moveq	#$01,D3
	tst.b	D6
	beq.s	Z20194
	bra.s	Z2019a
Z2014a:	tst.b	D6
	beq.s	Z200d4
	lea	Z20154(pc),A6
	bra.s	Z20136
Z20154:	tst.b	D6
	beq.s	Z200e2
	bra.s	Z200ea
Z2015a:	cmp.b	#$0003,D6
	bcs.s	Z201ca
	lea	Z20166(pc),A6
	jmp	(A5)
Z20166:	cmp.b	#$0003,D6
	bcs.s	Z201c6
	lea	Z20172(pc),A6
	jmp	(A5)
Z20172:	cmp.b	#$0003,D6
	bcs.s	Z201c2
	moveq	#$08,D4
	moveq	#$0a,D3
	lea	Z20182(pc),A6
	jmp	(A4)
Z20182:	add.w	D6,D3
Z20184:	lea	Z2018a(pc),A6
	bra.s	Z20136
Z2018a:	tst.b	D6
	beq.s	Z20194
	lea	Z201a2(pc),A6
	bra.s	Z20136
Z20194:	moveq	#$08,D4
	moveq	#$02,D2
	bra.s	Z201ac
Z2019a:	moveq	#$09,D4
	move.w	#$0102,D2
	bra.s	Z201ac
Z201a2:	tst.b	D6
	beq.s	Z2019a
Z201a6:	moveq	#$0a,D4
	move.w	#$0302,D2
Z201ac:	lea	Z201b2(pc),A6
	jmp	(A4)
Z201b2:	add.l	D2,D6
	move.l	A2,A6
	add.l	D6,A6
Z201b8:	move.b	-(A6),-(A2)
	dbf	D3,Z201b8
	bra	Z2010c
Z201c2:	moveq	#$07,D3
	bra.s	Z20182
Z201c6:	moveq	#$04,D3
	bra.s	Z20182
Z201ca:	moveq	#$02,D3
	cmp.b	#$0001,D6
	bcs.s	Z20194
	beq.s	Z2019a
	bra.s	Z201a6
Z201d6:	moveq	#$00,D6
	bra.s	Z201e0
Z201da:	lsl.l	#1,D5
	beq.s	Z201e6
Z201de:	roxl.w	#1,D6
Z201e0:	dbf	D4,Z201da
	jmp	(A6)
Z201e6:	cmp.l	A1,A0
	beq.s	Z201f4
	move.l	-(A0),D5
	move.w	D5,$0180(A3)		;1e Flashing-Colors
	roxl.l	#1,D5
	bra.s	Z201de
Z201f4:	move.l	A3,A4
	move.l	Z2025c(pc),A1
	move.l	Z2025c+10(pc),A2
	move.l	A2,A3
	add.l	Z2025c+26(pc),A2
Z20204:	move.b	(A2)+,(A3)+
	cmp.l	A3,A1
	bcc.s	Z20204
	move.l	Z2025c(pc),A0
	move.l	Z2025c+10(pc),A1
	move.l	Z2025c+14(pc),A2
	move.b	Z2025c+8(pc),D5
	move.b	Z2025c+9(pc),D6
Z2021e:	move.b	-(A0),D0
	cmp.l	A1,A0
	beq.s	Z20232
	bcs.s	Z20234
	cmp.b	D5,D0
	beq.s	Z20246
	cmp.b	D6,D0
	beq.s	Z20256
	move.b	D0,-(A2)
	bra.s	Z2021e
Z20232:	move.b	D0,-(A2)
;------------------------------------------------------------------------
Z20234:	move.l	Z2025c+18(pc),A2
	move.w	#$8200,$0096(A4)
	move.w	#$c000,$009a(A4)
	jmp	(A2)			;Jump In Adres
;------------------------------------------------------------------------
Z20246:	move.b	-(A0),D2
	move.b	-(A0),D1
Z2024a:	move.b	D1,-(A2)
	subq.b	#1,D2
	bne.s	Z2024a
	move.w	D1,$0180(A4)		;2e Flashing-Colors
	bra.s	Z2021e
Z20256:	moveq	#$00,D1
	move.b	-(A0),D2
	bra.s	Z2024a

Z2025c:	;	Crunched Double Action File !!!

	;Decruncher moet je zelf van de file afhalen nadat je het
	;gecrunched hebt !!!
	;Shit cruncher, je kan geen eens een data-file wegschrijven !!!

End:
