*************************************
*Lajn Drajwing rout baj Vat of kors!*
*************************************
	opt	x+
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	bsr	Rez
Loop
	bsr	ClrScrX
	bsr	PrepPkt1
	bsr	DrawLine
	bsr	PrepPkt2
	bsr	DrawLine
	bsr	PrepPkt3
	bsr	DrawLine
	bsr	PrepPkt4
	bsr	DrawLine
	move.w	#-1,$ffff8240.w
	bsr	Vbl
	move.w	#7,$ffff8240.w
	bra.s	Loop

Vbl	move.l	$466.w,d0
Sync	cmp.l	$466.w,d0
	beq.s	Sync
	cmp.b	#$39,$fffffc02.w
	bne.s	.rts
	clr.l	(a7)
	trap	#1
.rts	rts
ClrScrX
	not.w	$ffff8240.w
	lea	$7a400,a0
	moveq	#0,d0
	move.w	#21,d7 ;high (max.49)
i	set	0
loopzy	rept	80
	move.w	d0,i(a0) ;one plane!
i	set	i+8
	endr
	lea	640(a0),a0
	dbf	d7,loopzy
	not.w	$ffff8240.w
	rts
cnt1	dc.w	0
cnt2	dc.w	180
cnt3	dc.w	180
cnt4	dc.w	360
cnt5	dc.w	360
cnt6	dc.w	540
cnt7	dc.w	540
cnt8	dc.w	720
PrepPkt1
	lea	elipsa(pc),a0
	lea	cnt1(pc),a1
	lea	cnt2(pc),a2
	move.w	(a1),d4
	move.w	(a0,d4.w),d0
	bne.s	.noCLR
	move.w	(a0),d0
	moveq	#0,d4
	move.w	d4,(a1)
.noCLR	move.w	2(a0,d4.w),d1
	addq.w	#4,(a1)
	nop
	move.w	(a2),d4
	move.w	(a0,d4.w),d2
	bne.s	.noCLS
	move.w	(a0),d2
	moveq	#0,d4
	move.w	d4,(a2)
.noCLS	move.w	2(a0,d4.w),d3
	addq.w	#4,(a2)
	cmp.w	d0,d2
	bgt.s	.nochg
	exg.l	d0,d2
	exg.l	d1,d3
.nochg	rts
PrepPkt2
	lea	elipsa(pc),a0
	lea	cnt3(pc),a1
	lea	cnt4(pc),a2
	move.w	(a1),d4
	move.w	(a0,d4.w),d0
	bne.s	.noCLR
	move.w	(a0),d0
	moveq	#0,d4
	move.w	d4,(a1)
.noCLR	move.w	2(a0,d4.w),d1
	addq.w	#4,(a1)
	nop
	move.w	(a2),d4
	move.w	(a0,d4.w),d2
	bne.s	.noCLS
	move.w	(a0),d2
	moveq	#0,d4
	move.w	d4,(a2)
.noCLS	move.w	2(a0,d4.w),d3
	addq.w	#4,(a2)
	cmp.w	d0,d2
	bgt.s	.nochg
	exg.l	d0,d2
	exg.l	d1,d3
.nochg	rts
PrepPkt3
	lea	elipsa(pc),a0
	lea	cnt5(pc),a1
	lea	cnt6(pc),a2
	move.w	(a1),d4
	move.w	(a0,d4.w),d0
	bne.s	.noCLR
	move.w	(a0),d0
	moveq	#0,d4
	move.w	d4,(a1)
.noCLR	move.w	2(a0,d4.w),d1
	addq.w	#4,(a1)
	nop
	move.w	(a2),d4
	move.w	(a0,d4.w),d2
	bne.s	.noCLS
	move.w	(a0),d2
	moveq	#0,d4
	move.w	d4,(a2)
.noCLS	move.w	2(a0,d4.w),d3
	addq.w	#4,(a2)
	cmp.w	d0,d2
	bgt.s	.nochg
	exg.l	d0,d2
	exg.l	d1,d3
.nochg	rts
PrepPkt4
	lea	elipsa(pc),a0
	lea	cnt7(pc),a1
	lea	cnt8(pc),a2
	move.w	(a1),d4
	move.w	(a0,d4.w),d0
	bne.s	.noCLR
	move.w	(a0),d0
	moveq	#0,d4
	move.w	d4,(a1)
.noCLR	move.w	2(a0,d4.w),d1
	addq.w	#4,(a1)
	nop
	move.w	(a2),d4
	move.w	(a0,d4.w),d2
	bne.s	.noCLS
	move.w	(a0),d2
	moveq	#0,d4
	move.w	d4,(a2)
.noCLS	move.w	2(a0,d4.w),d3
	addq.w	#4,(a2)
	cmp.w	d0,d2
	bgt.s	.nochg
	exg.l	d0,d2
	exg.l	d1,d3
.nochg	rts


DrawLine
	lea	Pixie(pc),a0
	lea	$78000,a1
	cmp.w	d0,d2
	beq	Pion_0
	cmp.w	d1,d3
	beq	Poziom_0
	blt.s	kat0_90
	bgt	kat90_180
	rts
kat0_90
	move.w	d2,d4
	sub.w	d0,d4	; D4=dx
	bpl.s	.dx
	neg.w	d4
	move.w	d3,d6
	mulu	#160,d6
	add.w	d6,a1
	exg.l	d0,d2
	bra.s	.dx2
.dx	move.w	d1,d6
	mulu	#160,d6
	add.w	d6,a1
.dx2	move.w	d0,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d2
	lsr.w	#1,d0
	and.w	#$f8,d0
	add.w	d0,a1	;add x-pos

	move.w	d3,d5
	sub.w	d1,d5	; D5=dy
	bpl.s	.dy
	neg.w	d5
.dy	move.w	d5,d0
	move.w	d4,d1
	sub.w	d4,d5	; dx-dy
	bpl.s	kat45_90

	move.w	d4,d7
	subq.w	#1,d7
.drw	or.w	d2,(a1)
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	sub.w	d0,d1
	bgt.s	.no_sub
	add.w	d4,d1
	lea	-160(a1),a1
.no_sub	dbf	d7,.drw
	rts

kat45_90
	move.w	d0,d7
	subq.w	#1,d7
	move.w	d0,d3
.drw	or.w	d2,(a1)
	lea	-160(a1),a1
	sub.w	d1,d0
	bgt.s	.no_add
	add.w	d3,d0
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	dbf	d7,.drw
	rts

kat90_180
	move.w	d2,d4
	sub.w	d0,d4	; D4=dx
	bpl.s	.dx
	neg.w	d4
	move.w	d3,d6
	mulu	#160,d6
	add.w	d6,a1
	exg.l	d0,d2
	bra.s	.dx2
.dx	move.w	d1,d6
	mulu	#160,d6
	add.w	d6,a1
.dx2	move.w	d0,d2
	and.w	#$f,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d2
	lsr.w	#1,d0
	and.w	#$f8,d0
	add.w	d0,a1	;add x-pos

	move.w	d3,d5
	sub.w	d1,d5	; D5=dy
	bpl.s	.dy
	neg.w	d5
.dy	move.w	d5,d0
	move.w	d4,d1
	sub.w	d4,d5	; dx-dy
uu	bpl.s	kat135_180
	neg.w	d5
	move.w	d4,d7
	subq.w	#1,d7
.drw	or.w	d2,(a1)
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	sub.w	d0,d1
	bgt.s	.no_sub
	add.w	d4,d1
	lea	160(a1),a1
.no_sub	dbf	d7,.drw
	rts
kat135_180
	move.w	d0,d7
	subq.w	#1,d7
	move.w	d0,d3
.drw	or.w	d2,(a1)
	lea	160(a1),a1
	sub.w	d1,d0
	bgt.s	.no_add
	add.w	d3,d0
	ror.w	#1,d2
	bpl.s	.no_add
	addq.w	#8,a1
.no_add	dbf	d7,.drw
	rts

Poziom_0
	move.w	d2,d4
	sub.w	d0,d4
	bpl.s	Poziom_1
	exg	d0,d2
	neg.w	d4
Poziom_1
	mulu	#160,d1
	add.w	d1,a1
	lea	(a1),a2
	move.w	d0,d4
	move.w	d2,d6
	and.w	#$f,d4
	and.w	#$f,d6
	add.w	d4,d4
	add.w	d6,d6
	move.w	(a0,d4.w),d4
	move.w	(a0,d6.w),d6
	and.w	#$ff0,d0
	and.w	#$ff0,d2
	lsr.w	#1,d0
	lsr.w	#1,d2
	add.w	d0,a1
	add.w	d2,a2
	cmpa.l	a1,a2
	beq.s	OneWrd
	move.w	d4,d5
	subq.w	#1,d5
	subq.w	#1,d6
	or.w	d5,d4
	not.w	d6
	or.w	d4,(a1)+
	addq.l	#6,a1
.drw	cmpa.l	a1,a2
	beq.s	LastWrd
	or.w	#-1,(a1)+
	addq.l	#6,a1
	bra.s	.drw
LastWrd	or.w	d6,(a1)
	rts
OneWrd	move.w	d4,d5
	subq.w	#1,d5
	subq.w	#1,d6
	or.w	d5,d4
	move.w	d4,d5
	not.w	d6
	and.w	d6,d4
	beq.s	zero
	or.w	d4,(a1)
	rts
zero	or.w	d5,(a1)
	or.w	d6,(a2)
	rts

Pion_0	move.w	d3,d4
	sub.w	d1,d4
	bpl.s	Pion_1
	neg.w	d4
	exg	d1,d3
Pion_1	move.w	d4,d7
	subq.w	#1,d7
	move.w	d0,d4
	and.w	#$f,d4
	add.w	d4,d4
	move.w	(a0,d4.w),d4
	and.w	#$ff0,d0
	lsr.w	#1,d0
	add.w	d0,a1
	mulu	#160,d1
	add.w	d1,a1
.drw	or.w	d4,(a1)
	lea	160(a1),a1
	dbf	d7,.drw
	rts

Rez
	moveq	#0,d0
	move.w	#999,d7
	lea	$78000,a0
.ClrScr	dcb.w	$20c0,8
	dbf	d7,.ClrScr
	move.l	#$70080,$ffff8200.w
	rts
Pixie	dc.w	$8000,$4000,$2000,$1000
	dc.w	$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010
	dc.w	$0008,$0004,$0002,$0001
elipsa	dc.l  $A2008B,$A5008B,$A8008B,$AB008B
	dc.l  $AD008B,$B0008B,$B3008A,$B6008A
	dc.l  $B8008A,$BB0089,$BD0089,$C00088
	dc.l  $C30087,$C50087,$C80086,$CA0085
	dc.l  $CC0085,$CF0084,$D10083,$D30082
	dc.l  $D50081,$D70080,$D9007F,$DB007E
	dc.l  $DD007D,$DF007C,$E0007B,$E2007A
	dc.l  $E30079,$E50078,$E60076,$E70075
	dc.l  $E90074,$EA0072,$EB0071,$EC0070
	dc.l  $EC006F,$ED006D,$EE006C,$EE006A
	dc.l  $EF0069,$EF0068,$EF0066,$EF0065
	dc.l  $F00064,$EF0062,$EF0061,$EF005F
	dc.l  $EF005E,$EE005D,$EE005B,$ED005A
	dc.l  $EC0058,$EC0057,$EB0056,$EA0055
	dc.l  $E90053,$E70052,$E60051,$E50050
	dc.l  $E3004E,$E2004D,$E0004C,$DF004B
	dc.l  $DD004A,$DB0049,$D90048,$D70047
	dc.l  $D50046,$D30045,$D10044,$CF0043
	dc.l  $CC0042,$CA0042,$C80041,$C50040
	dc.l  $C30040,$C0003F,$BD003E,$BB003E
	dc.l  $B8003D,$B6003D,$B3003D,$B0003C
	dc.l  $AD003C,$AB003C,$A8003C,$A5003C
	dc.l  $A2003C,$A0003C,$9D003C,$9A003C
	dc.l  $97003C,$94003C,$92003C,$8F003C
	dc.l  $8C003D,$89003D,$87003D,$84003E
	dc.l  $82003E,$7F003F,$7C0040,$7A0040
	dc.l  $780041,$750042,$730042,$700043
	dc.l  $6E0044,$6C0045,$6A0046,$680047
	dc.l  $660048,$640049,$62004A,$60004B
	dc.l  $5F004C,$5D004D,$5C004E,$5A004F
	dc.l  $590051,$580052,$560053,$550055
	dc.l  $540056,$530057,$530058,$52005A
	dc.l  $51005B,$51005D,$50005E,$50005F
	dc.l  $500061,$500062,$500063,$500065
	dc.l  $500066,$500068,$500069,$51006A
	dc.l  $51006C,$52006D,$53006F,$530070
	dc.l  $540071,$550072,$560074,$580075
	dc.l  $590076,$5A0077,$5C0079,$5D007A
	dc.l  $5F007B,$60007C,$62007D,$64007E
	dc.l  $66007F,$680080,$6A0081,$6C0082
	dc.l  $6E0083,$700084,$730085,$750085
	dc.l  $770086,$7A0087,$7C0087,$7F0088
	dc.l  $820089,$840089,$87008A,$89008A
	dc.l  $8C008A,$8F008B,$92008B,$94008B
	dc.l  $97008B,$9A008B,$9D008B,$9F008C
	ds.l	1
