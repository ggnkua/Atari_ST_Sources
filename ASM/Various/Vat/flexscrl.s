*************************************
* This flexi scroller was easly (as *
* always) coded by ~VAT~ on 18-6.93 *
*************************************
	opt	x+
	lea	$7fffe,a7
	bsr	Res
Loop
	lea	ScrAdr(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	move.l	d0,$ffff8200.w
	bsr	DoPattern
	move.w	#$00,$ffff8240.w
	bsr	Vbl
	move.w	#$03,$ffff8240.w
	bra.s	Loop
Vbl
	move.l	d0,-(a7)
	move.l	$466.w,d0
Vbl2	cmp.l	$466.w,d0
	beq.s	 Vbl2
	cmp.b	#$39,$fffffc02.w
	beq.s	Koniec
	move.l	(a7)+,d0
	rts
Koniec	lea	OldPal(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.b	#8,$fffffc02.w
	move.w	#$555,$ffff8240.w
	clr.l	-(a7)
	trap	#1
	illegal
Sprawdz	dc.l	0



DoPattern
	moveq	#0,d0
	moveq	#0,d1
	lea	Sprawdz(pc),a0
	cmp.w	#32,(a0)
	bne.s	Gudul
	move.w	d0,(a0)
Gudul	move.w	(a0),d0
	addq.w	#1,(a0)
	addq.w	#2,a0
	cmp.w	#-1,(a0)
	bne.s	Gudul2
	move.w	#31,(a0)
Gudul2	move.w	(a0),d1
	subq.w	#1,(a0)
	move.l	d0,d2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d0,d0
	add.w	d0,d2
	add.w	d0,d0
	add.w	d2,d2
	add.w	d2,d2
	lea	AdrVat1(pc),a0
	move.l	(a0,d0.w),a0
	add.w	d2,a0
	lea	AdrVat2(pc),a2
	move.l	(a2,d1.w),a2
	move.l	ScrAdr(pc),d7
	lsl.w	#8,d7
	exg	d7,a1
	moveq	#31,d7
Flex	move.l	(a0)+,d0
	move.w	(a0)+,d2
	move.l	(a2)+,d4
	move.w	(a2)+,d6
	moveq	#0,d5	;czysc D5
	move.w	d4,d5	;zapisz
	swap	d4	;obrot D4
	or.w	d4,d5	;dodaj D4 D5
	swap	d4	;obrot D4
	or.w	d6,d5	;dodaj D6 D5
	not.w	d5	;zaneguj D5
	and.w	d5,d0	;odejmij D5 D0
	and.w	d5,d2	;odejmij D5 D2
	swap	d0	;obrot D0
	and.w	d5,d0	;odejmij D5 D0
	swap	d0	;obrot D0
	or.l	d4,d0	;dodaj D4 D0
	or.w	d6,d2	;dodaj D6 D2
	move.l	(a0)+,d1
	move.w	(a0)+,d3
	move.l	(a2)+,d4
	move.w	(a2)+,d6
	moveq	#0,d5
	move.w	d4,d5
	swap	d4
	or.w	d4,d5
	swap	d4
	or.w	d6,d5
	not.w	d5
	and.w	d5,d1
	and.w	d5,d3
	swap	d1
	and.w	d5,d1
	swap	d1
	or.l	d4,d1
	or.w	d6,d3
	move.l	d0,(a1)
	move.w	d2,4(a1)
	move.l	d1,8(a1)
	move.w	d3,12(a1)
	move.l	d0,16(a1)
	move.w	d2,20(a1)
	move.l	d1,24(a1)
	move.w	d3,28(a1)
	move.l	d0,32(a1)
	move.w	d2,36(a1)
	move.l	d1,40(a1)
	move.w	d3,44(a1)
	move.l	d0,48(a1)
	move.w	d2,52(a1)
	move.l	d1,56(a1)
	move.w	d3,60(a1)
	move.l	d0,64(a1)
	move.w	d2,68(a1)
	move.l	d1,72(a1)
	move.w	d3,76(a1)
	move.l	d0,80(a1)
	move.w	d2,84(a1)
	move.l	d1,88(a1)
	move.w	d3,92(a1)
	move.l	d0,96(a1)
	move.w	d2,100(a1)
	move.l	d1,104(a1)
	move.w	d3,108(a1)
	move.l	d0,112(a1)
	move.w	d2,116(a1)
	move.l	d1,120(a1)
	move.w	d3,124(a1)
	move.l	d0,128(a1)
	move.w	d2,132(a1)
	move.l	d1,136(a1)
	move.w	d3,140(a1)
	move.l	d0,144(a1)
	move.w	d2,148(a1)
	move.l	d1,152(a1)
	move.w	d3,156(a1)
	move.l	d0,160*32(a1)
	move.w	d2,4+160*32(a1)
	move.l	d1,8+160*32(a1)
	move.w	d3,12+160*32(a1)
	move.l	d0,16+160*32(a1)
	move.w	d2,20+160*32(a1)
	move.l	d1,24+160*32(a1)
	move.w	d3,28+160*32(a1)
	move.l	d0,32+160*32(a1)
	move.w	d2,36+160*32(a1)
	move.l	d1,40+160*32(a1)
	move.w	d3,44+160*32(a1)
	move.l	d0,48+160*32(a1)
	move.w	d2,52+160*32(a1)
	move.l	d1,56+160*32(a1)
	move.w	d3,60+160*32(a1)
	move.l	d0,64+160*32(a1)
	move.w	d2,68+160*32(a1)
	move.l	d1,72+160*32(a1)
	move.w	d3,76+160*32(a1)
	move.l	d0,80+160*32(a1)
	move.w	d2,84+160*32(a1)
	move.l	d1,88+160*32(a1)
	move.w	d3,92+160*32(a1)
	move.l	d0,96+160*32(a1)
	move.w	d2,100+160*32(a1)
	move.l	d1,104+160*32(a1)
	move.w	d3,108+160*32(a1)
	move.l	d0,112+160*32(a1)
	move.w	d2,116+160*32(a1)
	move.l	d1,120+160*32(a1)
	move.w	d3,124+160*32(a1)
	move.l	d0,128+160*32(a1)
	move.w	d2,132+160*32(a1)
	move.l	d1,136+160*32(a1)
	move.w	d3,140+160*32(a1)
	move.l	d0,144+160*32(a1)
	move.w	d2,148+160*32(a1)
	move.l	d1,152+160*32(a1)
	move.w	d3,156+160*32(a1)
	move.l	d0,320*32(a1)
	move.w	d2,4+320*32(a1)
	move.l	d1,8+320*32(a1)
	move.w	d3,12+320*32(a1)
	move.l	d0,16+320*32(a1)
	move.w	d2,20+320*32(a1)
	move.l	d1,24+320*32(a1)
	move.w	d3,28+320*32(a1)
	move.l	d0,32+320*32(a1)
	move.w	d2,36+320*32(a1)
	move.l	d1,40+320*32(a1)
	move.w	d3,44+320*32(a1)
	move.l	d0,48+320*32(a1)
	move.w	d2,52+320*32(a1)
	move.l	d1,56+320*32(a1)
	move.w	d3,60+320*32(a1)
	move.l	d0,64+320*32(a1)
	move.w	d2,68+320*32(a1)
	move.l	d1,72+320*32(a1)
	move.w	d3,76+320*32(a1)
	move.l	d0,80+320*32(a1)
	move.w	d2,84+320*32(a1)
	move.l	d1,88+320*32(a1)
	move.w	d3,92+320*32(a1)
	move.l	d0,96+320*32(a1)
	move.w	d2,100+320*32(a1)
	move.l	d1,104+320*32(a1)
	move.w	d3,108+320*32(a1)
	move.l	d0,112+320*32(a1)
	move.w	d2,116+320*32(a1)
	move.l	d1,120+320*32(a1)
	move.w	d3,124+320*32(a1)
	move.l	d0,128+320*32(a1)
	move.w	d2,132+320*32(a1)
	move.l	d1,136+320*32(a1)
	move.w	d3,140+320*32(a1)
	move.l	d0,144+320*32(a1)
	move.w	d2,148+320*32(a1)
	move.l	d1,152+320*32(a1)
	move.w	d3,156+320*32(a1)
	move.l	d0,480*32(a1)
	move.w	d2,4+480*32(a1)
	move.l	d1,8+480*32(a1)
	move.w	d3,12+480*32(a1)
	move.l	d0,16+480*32(a1)
	move.w	d2,20+480*32(a1)
	move.l	d1,24+480*32(a1)
	move.w	d3,28+480*32(a1)
	move.l	d0,32+480*32(a1)
	move.w	d2,36+480*32(a1)
	move.l	d1,40+480*32(a1)
	move.w	d3,44+480*32(a1)
	move.l	d0,48+480*32(a1)
	move.w	d2,52+480*32(a1)
	move.l	d1,56+480*32(a1)
	move.w	d3,60+480*32(a1)
	move.l	d0,64+480*32(a1)
	move.w	d2,68+480*32(a1)
	move.l	d1,72+480*32(a1)
	move.w	d3,76+480*32(a1)
	move.l	d0,80+480*32(a1)
	move.w	d2,84+480*32(a1)
	move.l	d1,88+480*32(a1)
	move.w	d3,92+480*32(a1)
	move.l	d0,96+480*32(a1)
	move.w	d2,100+480*32(a1)
	move.l	d1,104+480*32(a1)
	move.w	d3,108+480*32(a1)
	move.l	d0,112+480*32(a1)
	move.w	d2,116+480*32(a1)
	move.l	d1,120+480*32(a1)
	move.w	d3,124+480*32(a1)
	move.l	d0,128+480*32(a1)
	move.w	d2,132+480*32(a1)
	move.l	d1,136+480*32(a1)
	move.w	d3,140+480*32(a1)
	move.l	d0,144+480*32(a1)
	move.w	d2,148+480*32(a1)
	move.l	d1,152+480*32(a1)
	move.w	d3,156+480*32(a1)
	move.l	d0,640*32(a1)
	move.w	d2,4+640*32(a1)
	move.l	d1,8+640*32(a1)
	move.w	d3,12+640*32(a1)
	move.l	d0,16+640*32(a1)
	move.w	d2,20+640*32(a1)
	move.l	d1,24+640*32(a1)
	move.w	d3,28+640*32(a1)
	move.l	d0,32+640*32(a1)
	move.w	d2,36+640*32(a1)
	move.l	d1,40+640*32(a1)
	move.w	d3,44+640*32(a1)
	move.l	d0,48+640*32(a1)
	move.w	d2,52+640*32(a1)
	move.l	d1,56+640*32(a1)
	move.w	d3,60+640*32(a1)
	move.l	d0,64+640*32(a1)
	move.w	d2,68+640*32(a1)
	move.l	d1,72+640*32(a1)
	move.w	d3,76+640*32(a1)
	move.l	d0,80+640*32(a1)
	move.w	d2,84+640*32(a1)
	move.l	d1,88+640*32(a1)
	move.w	d3,92+640*32(a1)
	move.l	d0,96+640*32(a1)
	move.w	d2,100+640*32(a1)
	move.l	d1,104+640*32(a1)
	move.w	d3,108+640*32(a1)
	move.l	d0,112+640*32(a1)
	move.w	d2,116+640*32(a1)
	move.l	d1,120+640*32(a1)
	move.w	d3,124+640*32(a1)
	move.l	d0,128+640*32(a1)
	move.w	d2,132+640*32(a1)
	move.l	d1,136+640*32(a1)
	move.w	d3,140+640*32(a1)
	move.l	d0,144+640*32(a1)
	move.w	d2,148+640*32(a1)
	move.l	d1,152+640*32(a1)
	move.w	d3,156+640*32(a1)
	move.l	d0,800*32(a1)
	move.w	d2,4+800*32(a1)
	move.l	d1,8+800*32(a1)
	move.w	d3,12+800*32(a1)
	move.l	d0,16+800*32(a1)
	move.w	d2,20+800*32(a1)
	move.l	d1,24+800*32(a1)
	move.w	d3,28+800*32(a1)
	move.l	d0,32+800*32(a1)
	move.w	d2,36+800*32(a1)
	move.l	d1,40+800*32(a1)
	move.w	d3,44+800*32(a1)
	move.l	d0,48+800*32(a1)
	move.w	d2,52+800*32(a1)
	move.l	d1,56+800*32(a1)
	move.w	d3,60+800*32(a1)
	move.l	d0,64+800*32(a1)
	move.w	d2,68+800*32(a1)
	move.l	d1,72+800*32(a1)
	move.w	d3,76+800*32(a1)
	move.l	d0,80+800*32(a1)
	move.w	d2,84+800*32(a1)
	move.l	d1,88+800*32(a1)
	move.w	d3,92+800*32(a1)
	move.l	d0,96+800*32(a1)
	move.w	d2,100+800*32(a1)
	move.l	d1,104+800*32(a1)
	move.w	d3,108+800*32(a1)
	move.l	d0,112+800*32(a1)
	move.w	d2,116+800*32(a1)
	move.l	d1,120+800*32(a1)
	move.w	d3,124+800*32(a1)
	move.l	d0,128+800*32(a1)
	move.w	d2,132+800*32(a1)
	move.l	d1,136+800*32(a1)
	move.w	d3,140+800*32(a1)
	move.l	d0,144+800*32(a1)
	move.w	d2,148+800*32(a1)
	move.l	d1,152+800*32(a1)
	move.w	d3,156+800*32(a1)
	lea	160(a1),a1
	dbf	d7,Flex
	rts






Res
	dc.w	$a00a
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.w	#6,a7
	move.w	#$12,$fffffc02.w
	moveq	#0,d0
	move.w	#4059,d7
	lea	$70000,a0
ClearSc	rept	4
	move.l	d0,(a0)+
	endr
	dbf	d7,ClearSc
	lea	$ffff8200.w,a0
	bsr	Vbl
	move.b	#0,$60(a0)
	bsr	Vbl
	move.b	#2,$0A(a0)
	bsr	Vbl
	move.l	#$70080,(a0)
	lea	Pal(pc),a1
	lea	64(a0),a0
	rept	8
	move.l	(a1)+,(a0)+
	endr
	BSR	Prepare2
	rts
Prepare2
	lea	Magnify(pc),a0
	lea	VatPat(pc),a1
	lea	AdrVat1(pc),a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#31,d7
Ring	moveq	#31,d6
	move.l	a0,(a2)+
Ring2	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	swap	d0
	swap	d1
	swap	d2
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	ror.l	d3,d0
	ror.l	d3,d1
	ror.l	d3,d2
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,32*12(a0)
	move.w	d0,(a0)+
	move.w	d1,32*12(a0)
	move.w	d1,(a0)+
	move.w	d2,32*12(a0)
	move.w	d2,(a0)+
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,32*12(a0)
	move.w	d0,(a0)+
	move.w	d1,32*12(a0)
	move.w	d1,(a0)+
	move.w	d2,32*12(a0)
	move.w	d2,(a0)+
	dbf	d6,Ring2
	addq.w	#1,d3
	lea	32*12(a0),a0
	lea	VatPat(pc),a1
	dbf	d7,Ring
	lea	Pat1(pc),a1
	lea	AdrVat2(pc),a2
	lea	32*12(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#31,d7
Ring3	moveq	#31,d6
	move.l	a0,(a2)+
Ring4	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	swap	d0
	swap	d1
	swap	d2
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	ror.l	d3,d0
	ror.l	d3,d1
	ror.l	d3,d2
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,32*12(a0)
	move.w	d0,(a0)+
	move.w	d1,32*12(a0)
	move.w	d1,(a0)+
	move.w	d2,32*12(a0)
	move.w	d2,(a0)+
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,32*12(a0)
	move.w	d0,(a0)+
	move.w	d1,32*12(a0)
	move.w	d1,(a0)+
	move.w	d2,32*12(a0)
	move.w	d2,(a0)+
	dbf	d6,Ring4
	addq.w	#1,d3
	lea	32*12(a0),a0
	lea	Pat1(pc),a1
	dbf	d7,Ring3
	rts
ScrAdr	dc.l	$70000,$70080
AdrVat1	ds.l	32
AdrVat2	ds.l	32
OldPal	dc.w	$555,$000,$0f0,$ff0,$00f,$f0f,$0ff,$555
	dc.w	$333,$f33,$3f3,$ff3,$33f,$f3f,$3ff,$000
Pal	dc.w	$000,$020,$030,$040,$050,$300,$501,$701
	dc.w	$022,$033,$044,$055,$313,$423,$533,$643
VatPat	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8C03,$73FC,$FFFF,$67F9,$9807,$FFFF
	dc.w	$8C06,$73F9,$FFFF,$EFF9,$1007,$FFFF
	dc.w	$8C0D,$73F2,$FFFF,$EC01,$13FF,$FFFF
	dc.w	$8C1B,$73E4,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8C36,$73C9,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8C6C,$7393,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8CD8,$7327,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8DBF,$7240,$FFFF,$EC01,$13FF,$FFFF
	dc.w	$8F60,$709F,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8EC0,$713F,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8D80,$727F,$FFFF,$6C01,$93FF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$81CB,$7E34,$FFFF,$85C1,$7A3F,$FFFF
	dc.w	$812A,$7ED5,$FFFF,$4481,$BB7F,$FFFF
	dc.w	$812A,$7ED5,$FFFF,$4481,$BB7F,$FFFF
	dc.w	$81CB,$7E34,$FFFF,$8481,$7B7F,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$9E79,$6186,$FFFF,$EEF1,$110F,$FFFF
	dc.w	$A282,$5D7D,$FFFF,$2489,$DB77,$FFFF
	dc.w	$A29A,$5D65,$FFFF,$2489,$DB77,$FFFF
	dc.w	$BE8B,$4174,$FFFF,$E489,$1B77,$FFFF
	dc.w	$A2FA,$5D05,$FFFF,$2E89,$D177,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$8000,$7FFF,$FFFF,$0001,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$FFFF,$FFFF,$0001,$FFFF
Pat1	dc.w	$0000,$0800,$0000,$0000,$0010,$0000
	dc.w	$0800,$1000,$0000,$0010,$0008,$0000
	dc.w	$1000,$1000,$0000,$0008,$0008,$0000
	dc.w	$3000,$7800,$0000,$000C,$001E,$0000
	dc.w	$4802,$9C01,$0000,$4012,$8039,$0000
	dc.w	$050B,$0E07,$0000,$D0A0,$E070,$0000
	dc.w	$0308,$07F8,$0007,$10C0,$1FE0,$E000
	dc.w	$07F9,$03FE,$0000,$9FE0,$7FC0,$0000
	dc.w	$0128,$0330,$00C0,$1480,$0CC0,$0300
	dc.w	$0140,$0360,$0080,$0280,$06C0,$0100
	dc.w	$0180,$03C0,$0000,$0180,$03C0,$0000
	dc.w	$0100,$0380,$0000,$0080,$01C0,$0000
	dc.w	$0780,$0300,$0000,$01E0,$00C0,$0000
	dc.w	$0000,$0500,$0200,$0000,$00A0,$0040
	dc.w	$0C00,$0500,$0200,$0030,$00A0,$0040
	dc.w	$0500,$0C00,$0200,$00A0,$0030,$0040
	dc.w	$0500,$0C00,$0200,$00A0,$0030,$0040
	dc.w	$0C00,$0500,$0200,$0030,$00A0,$0040
	dc.w	$0000,$0500,$0200,$0000,$00A0,$0040
	dc.w	$0780,$0300,$0000,$01E0,$00C0,$0000
	dc.w	$0100,$0380,$0000,$0080,$01C0,$0000
	dc.w	$0180,$03C0,$0000,$0180,$03C0,$0000
	dc.w	$0140,$0360,$0080,$0280,$06C0,$0100
	dc.w	$0128,$0330,$00C0,$0480,$1CC0,$0300
	dc.w	$07F9,$03FE,$0000,$9FE0,$7FC0,$0000
	dc.w	$0308,$07F8,$0007,$10C0,$1FE0,$E000
	dc.w	$050B,$0E07,$0000,$D0A0,$E070,$0000
	dc.w	$4802,$9C01,$0000,$4012,$8039,$0000
	dc.w	$3000,$7800,$0000,$000C,$001E,$0000
	dc.w	$1000,$1000,$0000,$0008,$0008,$0000
	dc.w	$0800,$1000,$0000,$0010,$0008,$0000
	dc.w	$0000,$0800,$0000,$0000,$0010,$0000
Magnify	dc.l	0