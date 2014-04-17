*************************************
* SHIT INTRO coded by VAT for QUAST *
* Magazine on 1993.07/8-10/5....... *
*        ekstendend wersjon!!!      *
*************************************
	*opt	x+
	lea	(ACHTUNG-128)(pc),a7
	bra.s	pitch
UnForGiven
	rept	20
	move.l	d0,(a0)+
	endr
	dbf	d7,UnForGiven
	move.l	$4.w,$70.w
ACHTUNG
	bsr	ret
AchNie	moveq	#0,d0
	lea	$ffff8240.w,a0
	rept	8
	move.l	d0,(a0)+
	endr
	lea	ACHTUNG(pc),a0
	move.w	#7999,d7
	bra.s	UnForGiven
pitch	bsr	res
key:
	move.l	#$31415926,$426.w
	move.l	$4.w,$42a.w
	cmp.l	#$fa52235f,$fa0000
	bne.s	.Ufff
	bsr	ACHTUNG
.Ufff	stop	#$2300
	bra.s	key
	illegal



GScroll	lea	ZaScAd(pc),a6
	tst.w	CzyJuz
	bgt.s	Przesun
	move.w	#8*2,CzyJuz
	moveq	#0,d0
	lea	GTekst(pc),a0
	lea	LitNum(pc),a1
	lea	Szukaj(pc),a2
	move.w	(a1),d0
	move.b	(a0,d0.w),d0
	and.w	#$7f,d0
	addq.w	#1,(a1)
	cmp.w	#0,d0
	bne.s	DalTek
	move.w	#1,(a1)
	move.b	(a0),d0
DalTek	sub.w	#32,d0
	add.w	d0,d0
	move.w	(a2,d0.w),d0
	move.l	FONTALE(pc),a2
	add.w	d0,a2
	move.l	a2,(a6)
Przesun	
	moveq	#7,d7
	move.l	(a6),a2
	move.l	Screen(pc),a3
	lea	GBufor(pc),a4
	lea	160*90+2(a3),a3	;80
BigScrl	move.w	8(a3),d1
	move.w	d1,(a3)
	move.w	d1,160(a3)
	move.w	d1,320(a3)
	move.w	d1,480(a3)
	move.w	d1,640(a3)
	move.w	d1,800(a3)
	move.w	d1,960(a3)
	move.w	d1,1120(a3)
	move.w	d1,1280(a3)
	move.w	d1,1440(a3)
	move.w	16(a3),d1
	move.w	d1,8(a3)
	move.w	d1,168(a3)
	move.w	d1,328(a3)
	move.w	d1,488(a3)
	move.w	d1,648(a3)
	move.w	d1,808(a3)
	move.w	d1,968(a3)
	move.w	d1,1128(a3)
	move.w	d1,1288(a3)
	move.w	d1,1448(a3)
	move.w	24(a3),d1
	move.w	d1,16(a3)
	move.w	d1,176(a3)
	move.w	d1,336(a3)
	move.w	d1,496(a3)
	move.w	d1,656(a3)
	move.w	d1,816(a3)
	move.w	d1,976(a3)
	move.w	d1,1136(a3)
	move.w	d1,1296(a3)
	move.w	d1,1456(a3)
	move.w	32(a3),d1
	move.w	d1,24(a3)
	move.w	d1,184(a3)
	move.w	d1,344(a3)
	move.w	d1,504(a3)
	move.w	d1,664(a3)
	move.w	d1,824(a3)
	move.w	d1,984(a3)
	move.w	d1,1144(a3)
	move.w	d1,1304(a3)
	move.w	d1,1464(a3)
	move.w	40(a3),d1
	move.w	d1,32(a3)
	move.w	d1,192(a3)
	move.w	d1,352(a3)
	move.w	d1,512(a3)
	move.w	d1,672(a3)
	move.w	d1,832(a3)
	move.w	d1,992(a3)
	move.w	d1,1152(a3)
	move.w	d1,1312(a3)
	move.w	d1,1472(a3)
	move.w	48(a3),d1
	move.w	d1,40(a3)
	move.w	d1,200(a3)
	move.w	d1,360(a3)
	move.w	d1,520(a3)
	move.w	d1,680(a3)
	move.w	d1,840(a3)
	move.w	d1,1000(a3)
	move.w	d1,1160(a3)
	move.w	d1,1320(a3)
	move.w	d1,1480(a3)
	move.w	56(a3),d1
	move.w	d1,48(a3)
	move.w	d1,208(a3)
	move.w	d1,368(a3)
	move.w	d1,528(a3)
	move.w	d1,688(a3)
	move.w	d1,848(a3)
	move.w	d1,1008(a3)
	move.w	d1,1168(a3)
	move.w	d1,1328(a3)
	move.w	d1,1488(a3)
	move.w	64(a3),d1
	move.w	d1,56(a3)
	move.w	d1,216(a3)
	move.w	d1,376(a3)
	move.w	d1,536(a3)
	move.w	d1,696(a3)
	move.w	d1,856(a3)
	move.w	d1,1016(a3)
	move.w	d1,1176(a3)
	move.w	d1,1336(a3)
	move.w	d1,1496(a3)
	move.w	72(a3),d1
	move.w	d1,64(a3)
	move.w	d1,224(a3)
	move.w	d1,384(a3)
	move.w	d1,544(a3)
	move.w	d1,704(a3)
	move.w	d1,864(a3)
	move.w	d1,1024(a3)
	move.w	d1,1184(a3)
	move.w	d1,1344(a3)
	move.w	d1,1504(a3)
	move.w	80(a3),d1
	move.w	d1,72(a3)
	move.w	d1,160+72(a3)
	move.w	d1,320+72(a3)
	move.w	d1,480+72(a3)
	move.w	d1,640+72(a3)
	move.w	d1,800+72(a3)
	move.w	d1,960+72(a3)
	move.w	d1,1120+72(a3)
	move.w	d1,1280+72(a3)
	move.w	d1,1440+72(a3)
	move.w	88(a3),d1
	move.w	d1,80(a3)
	move.w	d1,160+80(a3)
	move.w	d1,320+80(a3)
	move.w	d1,480+80(a3)
	move.w	d1,640+80(a3)
	move.w	d1,800+80(a3)
	move.w	d1,960+80(a3)
	move.w	d1,1120+80(a3)
	move.w	d1,1280+80(a3)
	move.w	d1,1440+80(a3)
	move.w	96(a3),d1
	move.w	d1,88(a3)
	move.w	d1,160+88(a3)
	move.w	d1,320+88(a3)
	move.w	d1,480+88(a3)
	move.w	d1,640+88(a3)
	move.w	d1,800+88(a3)
	move.w	d1,960+88(a3)
	move.w	d1,1120+88(a3)
	move.w	d1,1280+88(a3)
	move.w	d1,1440+88(a3)
	move.w	104(a3),d1
	move.w	d1,96(a3)
	move.w	d1,160+96(a3)
	move.w	d1,320+96(a3)
	move.w	d1,480+96(a3)
	move.w	d1,640+96(a3)
	move.w	d1,800+96(a3)
	move.w	d1,960+96(a3)
	move.w	d1,1120+96(a3)
	move.w	d1,1280+96(a3)
	move.w	d1,1440+96(a3)
	move.w	112(a3),d1
	move.w	d1,104(a3)
	move.w	d1,160+104(a3)
	move.w	d1,320+104(a3)
	move.w	d1,480+104(a3)
	move.w	d1,640+104(a3)
	move.w	d1,800+104(a3)
	move.w	d1,960+104(a3)
	move.w	d1,1120+104(a3)
	move.w	d1,1280+104(a3)
	move.w	d1,1440+104(a3)
	move.w	120(a3),d1
	move.w	d1,112(a3)
	move.w	d1,160+112(a3)
	move.w	d1,320+112(a3)
	move.w	d1,480+112(a3)
	move.w	d1,640+112(a3)
	move.w	d1,800+112(a3)
	move.w	d1,960+112(a3)
	move.w	d1,1120+112(a3)
	move.w	d1,1280+112(a3)
	move.w	d1,1440+112(a3)
	move.w	128(a3),d1
	move.w	d1,120(a3)
	move.w	d1,160+120(a3)
	move.w	d1,320+120(a3)
	move.w	d1,480+120(a3)
	move.w	d1,640+120(a3)
	move.w	d1,800+120(a3)
	move.w	d1,960+120(a3)
	move.w	d1,1120+120(a3)
	move.w	d1,1280+120(a3)
	move.w	d1,1440+120(a3)
	move.w	136(a3),d1
	move.w	d1,128(a3)
	move.w	d1,160+128(a3)
	move.w	d1,320+128(a3)
	move.w	d1,480+128(a3)
	move.w	d1,640+128(a3)
	move.w	d1,800+128(a3)
	move.w	d1,960+128(a3)
	move.w	d1,1120+128(a3)
	move.w	d1,1280+128(a3)
	move.w	d1,1440+128(a3)
	move.w	144(a3),d1
	move.w	d1,136(a3)
	move.w	d1,160+136(a3)
	move.w	d1,320+136(a3)
	move.w	d1,480+136(a3)
	move.w	d1,640+136(a3)
	move.w	d1,800+136(a3)
	move.w	d1,960+136(a3)
	move.w	d1,1120+136(a3)
	move.w	d1,1280+136(a3)
	move.w	d1,1440+136(a3)
	move.w	152(a3),d1
	move.w	d1,144(a3)
	move.w	d1,160+144(a3)
	move.w	d1,320+144(a3)
	move.w	d1,480+144(a3)
	move.w	d1,640+144(a3)
	move.w	d1,800+144(a3)
	move.w	d1,960+144(a3)
	move.w	d1,1120+144(a3)
	move.w	d1,1280+144(a3)
	move.w	d1,1440+144(a3)
	move.b	(a2),d1
	move.b	d1,73+80(a3)
	move.b	d1,233+80(a3)
	move.b	d1,393+80(a3)
	move.b	d1,553+80(a3)
	move.b	d1,713+80(a3)
	move.b	d1,873+80(a3)
	move.b	d1,1033+80(a3)
	move.b	d1,1193+80(a3)
	move.b	d1,1353+80(a3)
	move.b	d1,1513+80(a3)
	move.b	(a4),d2
	move.b	d2,72+80(a3)
	move.b	d2,232+80(a3)
	move.b	d2,392+80(a3)
	move.b	d2,552+80(a3)
	move.b	d2,712+80(a3)
	move.b	d2,872+80(a3)
	move.b	d2,1032+80(a3)
	move.b	d2,1192+80(a3)
	move.b	d2,1352+80(a3)
	move.b	d2,1512+80(a3)
	move.b	d1,(a4)+ ;zapisz w buforze
	lea	1600(a3),a3
	add.w	#8*2,a2
	dbf	d7,BigScrl
	addq.l	#1,(a6)
	subq.w	#1,CzyJuz
	rts

prepare3
	lea	Fontki(pc),a0
	lea	8(a1),a1
	lea	FONTALE(pc),a2
	move.l	a1,(a2)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#-1,d2
	move.w	#64*8,d7
GetByte	move.b	(a0)+,d0
NetC0	btst	#7,d0
	beq.s	NetB1
	move.w	d2,(a1)+
	bra.s	NetC1
NetB1	move.w	d1,(a1)+
NetC1	btst	#6,d0
	beq.s	NetB2
	move.w	d2,(a1)+
	bra.s	NetC2
NetB2	move.w	d1,(a1)+
NetC2	btst	#5,d0
	beq.s	NetB3
	move.w	d2,(a1)+
	bra.s	NetC3
NetB3	move.w	d1,(a1)+
NetC3	btst	#4,d0
	beq.s	NetB4
	move.w	d2,(a1)+
	bra.s	NetC4
NetB4	move.w	d1,(a1)+
NetC4	btst	#3,d0
	beq.s	NetB5
	move.w	d2,(a1)+
	bra.s	NetC5
NetB5	move.w	d1,(a1)+
NetC5	btst	#2,d0
	beq.s	NetB6
	move.w	d2,(a1)+
	bra.s	NetC6
NetB6	move.w	d1,(a1)+
NetC6	btst	#1,d0
	beq.s	NetB7
	move.w	d2,(a1)+
	bra.s	NetC7
NetB7	move.w	d1,(a1)+
NetC7	btst	#0,d0
	beq.s	NetB8
	move.w	d2,(a1)+
	bra.s	NetC8
NetB8	move.w	d1,(a1)+
NetC8	dbf	d7,GetByte
	rts

LitNum	dc.w	0
CzyJuz	dc.w	-1
ZaScAd	dc.l	0
Szukaj	dc.w	128*00,128*01,128*02,128*03,128*04,128*05,128*06,128*07,128*08,128*09
	dc.w	128*10,128*11,128*12,128*13,128*14,128*15,128*16,128*17,128*18,128*19
	dc.w	128*20,128*21,128*22,128*23,128*24,128*25,128*26,128*27,128*28,128*29
	dc.w	128*30,128*31,128*32,128*33,128*34,128*35,128*36,128*37,128*38,128*39
	dc.w	128*40,128*41,128*42,128*43,128*44,128*45,128*46,128*47,128*48,128*49
	dc.w	128*50,128*51,128*52,128*53,128*54,128*55,128*56,128*57,128*58,128*59
	dc.w	128*60,128*61,128*62,128*63,128*64,128*65,128*66,128*67,128*68,128*69
FONTALE	dc.l	$20000
GBufor	ds.l	2

*************************************
* 13 traceing scrollers (9*13=117)! *
*************************************

SCRL:
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	lea	$6b000,a5
	move.l	Screen(pc),a6
	lea	80*160(a6),a6
	lea	Kolunt(pc),a4
	lea	Kalk(pc),a3
	move.w	(a4),d3
	cmp.w	#9,d3
	bne.s	Prk
	move.w	d4,(a4)	;clr counter
Prk	addq.w	#1,(a4) ;next UP scroller
	moveq	#7,d7	;high scrl
	add.w	d3,d3	;fast calc
	sub.w	(a3,d3.w),a6 ;sub start adr
	move.w	(a3,d3.w),d5
	lea	-160(a6),a4
NaRys	rept	20
	move.w	(a5),d3
	move.w	d3,(a6)
	move.w	d3,9*160(a6)
	move.w	d3,18*160(a6)
	move.w	d3,27*160(a6)
	move.w	d3,36*160(a6)
	move.w	d3,45*160(a6)
	move.w	d3,54*160(a6)
	move.w	d3,63*160(a6)
	move.w	d3,72*160(a6)
	move.w	d3,81*160(a6)
	move.w	d3,90*160(a6)
	move.w	d3,99*160(a6)
	addq.w	#8,a5
	addq.w	#8,a6
	endr
	dbf	d7,NaRys
	moveq	#12,d7
.clear	move.w	d4,(a4)
	move.w	d4,8(a4)
	move.w	d4,16(a4)
	move.w	d4,24(a4)
	move.w	d4,32(a4)
	move.w	d4,40(a4)
	move.w	d4,48(a4)
	move.w	d4,56(a4)
	move.w	d4,64(a4)
	move.w	d4,72(a4)
	move.w	d4,80(a4)
	move.w	d4,88(a4)
	move.w	d4,96(a4)
	move.w	d4,104(a4)
	move.w	d4,112(a4)
	move.w	d4,120(a4)
	move.w	d4,128(a4)
	move.w	d4,136(a4)
	move.w	d4,144(a4)
	move.w	d4,152(a4)
	lea	160*9(a4),a4
	dbf	d7,.clear
	lea	$6b000,a5	;roxle
	move.l	Screen(pc),a6	;get screen
	lea	188*160(a6),a6	;szift 6860-2*9*160
	sub.l	d5,a6
	divu	#160,d5
	moveq	#9,d3
	sub.w	d5,d3
	bra.s	DDBBFF
julka	move.w	(a5),(a6)
	move.w	8(a5),8(a6)
	move.w	16(a5),16(a6)
	move.w	24(a5),24(a6)
	move.w	32(a5),32(a6)
	move.w	40(a5),40(a6)
	move.w	48(a5),48(a6)
	move.w	56(a5),56(a6)
	move.w	64(a5),64(a6)
	move.w	72(a5),72(a6)
	move.w	80(a5),80(a6)
	move.w	88(a5),88(a6)
	move.w	96(a5),96(a6)
	move.w	104(a5),104(a6)
	move.w	112(a5),112(a6)
	move.w	120(a5),120(a6)
	move.w	128(a5),128(a6)
	move.w	136(a5),136(a6)
	move.w	144(a5),144(a6)
	move.w	152(a5),152(a6)
	lea	160(a5),a5
	lea	160(a6),a6
DDBBFF	dbf	d5,julka
	move.l	Screen(pc),a6
	lea	71*160(a6),a6 ;start walec $1400
	bra.s	DDBBFF2
julka2	move.w	(a5),(a6)
	move.w	8(a5),8(a6)
	move.w	16(a5),16(a6)
	move.w	24(a5),24(a6)
	move.w	32(a5),32(a6)
	move.w	40(a5),40(a6)
	move.w	48(a5),48(a6)
	move.w	56(a5),56(a6)
	move.w	64(a5),64(a6)
	move.w	72(a5),72(a6)
	move.w	80(a5),80(a6)
	move.w	88(a5),88(a6)
	move.w	96(a5),96(a6)
	move.w	104(a5),104(a6)
	move.w	112(a5),112(a6)
	move.w	120(a5),120(a6)
	move.w	128(a5),128(a6)
	move.w	136(a5),136(a6)
	move.w	144(a5),144(a6)
	move.w	152(a5),152(a6)
	lea	160(a5),a5
	lea	160(a6),a6
DDBBFF2	dbf	d3,julka2
	rts

Scroll
	lea	LitBuf(pc),a3
	lea	Shift(pc),a4
	cmp.w	#-1,Shift
	bne.s	Roluj
	moveq	#0,d3
	MOVEQ	#0,D4
	lea	TekstM(pc),a5
	lea	WitchL(pc),a6
	move.w	#7,(a4)
	move.w	(a6),d3
	move.b	(a5,d3.w),d4
	MOVE.W	D4,D3
	addq.w	#1,(a6)
	cmp.b	#0,d3
	bne.s	NotLast
	move.b	(a5),d3
	clr.w	(a6)
NotLast	lea	Font(pc),a6
	sub.w	#32,d3
	add.w	d3,d3
	lsl.w	#2,d3
	move.l	(a6,d3.w),d4
	move.l	4(a6,d3.w),d5
	movem.l	d4-d5,(a3)
Roluj	lea	$6b000,a5
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a4),d4
Shifting
	rept	8
	roxl	152(a5)
	roxl	144(a5)
	roxl	136(a5)
	roxl	128(a5)
	roxl	120(a5)
	roxl	112(a5)
	roxl	104(a5)
	roxl	96(a5)
	roxl	88(a5)
	roxl	80(a5)
	roxl	72(a5)
	roxl	64(a5)
	roxl	56(a5)
	roxl	48(a5)
	roxl	40(a5)
	roxl	32(a5)
	roxl	24(a5)
	roxl	16(a5)
	roxl	8(a5)
	roxl	(a5)
	move.b	(a3)+,d3
	lsr.w	d4,d3
	and.w	#1,d3
	bclr	#0,153(a5)
	or.w	d3,152(a5)
	lea	160(a5),a5
	endr
	subq.w	#1,(a4)
	rts

FALUJ_Z_VATem
	moveq	#39,d7
	move.l	Screen(pc),a3
	lea	26*160+56(a3),a3
	move.w	last(pc),d3
	lea	droga(pc),a4
	add.w	d3,a4
	addq.w	#2,last
pierdol	lea	adresiki(pc),a5
	moveq	#0,d3
	move.w	(a4),d3
	cmp.w	#-1,d3
	bne.s	dallej
	clr.w	last
	lea	droga(pc),a4
dallej	move.w	(a4)+,d3
	ror.l	#4,d3
	cmp.b	#0,d3
	beq.s	nie_zm
	moveq	#0,d4
	move.b	d3,d4
	lsl.w	#3,d4
	add.w	d4,a3
	bset	#0,zmiana
nie_zm	rol.l	#4,d3
	and.w	#15,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a5,d3.w),a6
	move.w	linia(pc),d3
	mulu	#7*4,d3
	add.l	d3,a6
	move.l	(a6)+,(a3)
	move.l	(a6)+,8(a3)
	move.l	(a6)+,16(a3)
	move.l	(a6)+,24(a3)
	move.l	(a6)+,32(a3)
	move.l	(a6)+,40(a3)
	move.l	(a6)+,48(a3)
	addq.w	#1,linia
	lea	160(a3),a3
	tst.b	zmiana
	beq.s	bez_zmian
	clr.w	zmiana
	subq.l	#8,a3
bez_zmian
	dbf	d7,pierdol
	clr.w	linia
	rts
prepare1
	lea	copies,a0
	moveq	#0,d0
	move.w	#2000,d7
wycz_it	rept	8
	move.l	d0,(a0)+
	endr
	dbf	d7,wycz_it
	rts
prepare2
	lea	copies,a1
	lea	adresiki(pc),a2
	moveq	#15,d7 ;ilosc obrazow
	moveq	#00,d4 ;wart. przesun
Do_It	moveq	#39,d6 ;wysokosc (40)
	moveq	#05,d5 ;dlugosc  (96)
	lea	oryginal,a0
	move.l	a1,(a2)+
Go_And_Do
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,4(a1)
	swap	d0
	or.w	d0,(a1)
	addq.l	#2,a1
	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,4(a1)
	swap	d0
	or.w	d0,(a1)
	addq.l	#2,a1
	dbf	d5,Go_And_Do
	addq.l	#4,a1
	moveq	#5,d5
	dbf	d6,Go_And_Do
	addq.w	#1,d4
	dbf	d7,Do_It
	rts
zmiana	ds.w	1
linia	ds.w	1
last	ds.w	1
droga	
 ds.w	50
 dc.w 1,2,4,6,8,10,12,13,14,14,15,16
 dc.w 16,15,14,14,13,12,10,8,6,4,2,1
 dc.w 1,2,4,6,8,10,12,13,14,14,15,16
 dc.w 16,15,14,14,13,12,10,8,6,4,2,1
 ds.w	50
 dc.w 1,0,0,1,0,0,1,0,0,1
 dc.w 0,0,1,0,0,1,0,0,1,0
 dc.w 0,1,0,0,1,0,0,1,0,0
 dc.w 1,0,0,1,0,0,1,0,0,1
 dc.w 0,0,1,0,0,1,0,0,1,0
 dc.w 0,1,0,0,1,0,0,1,0,0
 ds.w	20
 dc.w 0,0,0,0,0,0,0,0,0,1
 dc.w 2,4,6,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,6,5,5,6,8,9
 dc.w 9,10,9,8,9,6,4,2,1,0
 dc.w 9,6,4,2,1,0,0,1,0,1
 dc.w 0,2,0,2,0,3,0,3,0,4
 dc.w 0,4,0,5,0,5,0,6,0,6
 dc.w 0,7,0,7,0,8,0,8,0,9
 dc.w 0,9,0,10,0,10,0,11,0,11
 dc.w 0,12,0,12,0,13,0,13,0,12
 dc.w 0,12,0,11,0,11,0,10,0,10
 dc.w 0,9,0,9,0,8,0,8,0,7
 dc.w 0,7,0,6,0,6,0,5,0,5
 dc.w 0,4,0,4,0,3,0,3,0,2
 dc.w 0,2,0,1,0,1,0,1,0,2
 dc.w 0,3,0,4,0,5,0,6,0,7
 dc.w 0,8,0,9,0,10,0,11,0,12
 dc.w 0,13,0,12,0,11,0,10,0,9
 dc.w 0,8,0,7,0,6,0,5,0,4
 dc.w 0,3,0,2,0,1,0,1,0,2
 dc.w 0,3,0,4,0,5,0,6,0,7
 dc.w 0,8,0,9,0,10,0,11,0,12
 dc.w 0,13,0,12,0,11,0,10,0,9
 dc.w 0,8,0,7,0,6,0,5,0,4
 dc.w 0,3,0,2,0,1,0,1,0,2
 dc.w 0,3,0,4,0,5,0,6,0,7
 dc.w 0,8,0,9,0,10,0,11,0,12
 dc.w 0,13,0,12,0,11,0,10,0,9
 dc.w 0,8,0,7,0,6,0,5,0,4
 dc.w 0,3,0,2,0,1,0,1,0,1
 dc.w 0,2,0,2,0,3,0,3,0,4
 dc.w 0,4,0,5,0,5,0,6,0,6
 dc.w 0,7,0,7,0,8,0,8,0,9
 dc.w 0,9,0,10,0,10,0,11,0,11
 dc.w 0,12,0,12,0,13,0,13,0,12
 dc.w 0,12,0,11,0,11,0,10,0,10
 dc.w 0,9,0,9,0,8,0,8,0,7
 dc.w 0,7,0,6,0,6,0,5,0,5
 dc.w 0,4,0,4,0,3,0,3,0,2
 dc.w 0,2,0,1,0,1,4,8,12,15
 dc.w 14,13,11,9,6,4,2,1,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0
 dc.w 1,0,0,1,0,0,1,0,0,1
 dc.w 0,0,1,0,0,1,0,0,1,0
 dc.w 0,1,0,0,1,0,0,1,0,0
 dc.w 1,0,0,1,0,0,1,0,0,1
 dc.w 0,0,1,0,0,1,0,0,1,0
 dc.w 0,1,0,0,1,0,0,1,0,0
 dc.w 0,0,0,0,0,0,0,0,0,0
 dc.w 1,0,0,1,0,0,1,0,0,1
 dc.w 0,0,1,0,0,1,0,0,1,0
 dc.w 0,1,0,0,1,0,0,1,0,0
 dc.w 1,0,0,1,0,0,1,0,0,1
 dc.w 0,0,1,0,0,1,0,0,1,0
 dc.w 0,1,0,0,1,0,0,1,0,0
 dc.w 0,2,4,4,2,0,0,2,4,4
 dc.w 2,0,0,2,4,4,2,0,0,2
 dc.w 4,4,2,0,0,2,4,4,2,0
 dc.w 0,2,4,4,2,0,0,2,4,4
 dc.w 2,0,0,2,4,4,2,0,0,2
 dc.w 4,4,2,0,0,2,4,4,2,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 5,5,6,8,9,9,10,9,8,6
 dc.w 4,2,1,0,1,2,2,1,0,0
 dc.w 1,2,2,1,0,0,1,2,2,1
 dc.w 0,0,1,2,2,1,0,0,1,2
 dc.w 2,1,0,0,1,2,2,1,0,0
 dc.w 1,2,2,1,0,0,1,2,2,1
 dc.w 0,0,1,2,2,1,0,0,1,2
 dc.w 2,1,0,0,2,4,4,2,0,0
 dc.w 2,4,4,2,0,0,2,4,4,2
 dc.w 0,0,2,4,4,2,0,0,2,4
 dc.w 4,2,0,0,2,4,4,2,0,0
 dc.w 2,4,4,2,0,0,2,4,4,2
 dc.w 0,0,2,4,4,2,0,0,2,4
 dc.w 4,2,0,0,1,2,3,4,5,6
 dc.w 2,1,0,6,4,2,1,0,1,2
 dc.w 2,1,0,0,1,2,2,1,0,0
 dc.w 1,2,2,1,0,0,1,2,2,1
 dc.w 0,0,1,2,2,1,0,0,1,2
 dc.w 2,1,0,0,1,2,2,1,0,0
 dc.w 1,2,2,1,0,0,1,2,2,1
 dc.w 0,0,1,2,2,1,0,0,2,4
 dc.w 4,2,0,0,2,4,4,2,0,0
 dc.w 2,4,4,2,0,0,2,4,4,2
 dc.w 0,0,2,4,4,2,0,0,2,4
 dc.w 4,2,0,0,2,4,4,2,0,0
 dc.w 2,4,4,2,0,0,2,4,4,2
 dc.w 0,0,2,4,4,2,0,0,0,0
 ds.w 40
 dcb.l	-1,4
adresiki ds.l	17




SKROLL
	lea	SvdAdr(pc),a4
	cmp.w	#4,Control
	bne.s	NotNext
	moveq	#0,d4
	moveq	#0,d5
	lea	LCount(pc),a6
	lea	Tekst(pc),a3
	lea	FntAdr(pc),a5
	move.w	(a6),d4
	move.b	(a3,d4.w),d4
	move.w	d5,Control
	cmp.b	#-1,d4
	bne.s	Viol
	move.w	d5,(a6)
	move.b	(a3),d4
Viol	addq.w	#1,(a6) ;Txt Count
	and.w	#$7f,d4
	sub.w	#32,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a5,d4.w),a5
	move.l	a5,(a4)
NotNext	move.l	(a4),a5
	move.l	Screen(pc),a3
	lea	$7e74(a3),a3
	lea	Bufor(pc),a6
	moveq	#4,d7
Doom	rept	5
	move.l	8(a3),(a3)
	move.w	12(a3),4(a3)
	move.l	16(a3),8(a3)
	move.w	20(a3),12(a3)
	move.l	24(a3),16(a3)
	move.w	28(a3),20(a3)
	move.l	32(a3),24(a3)
	move.w	36(a3),28(a3)
	move.l	40(a3),32(a3)
	move.w	44(a3),36(a3)
	move.l	48(a3),40(a3)
	move.w	52(a3),44(a3)
	move.l	56(a3),48(a3)
	move.w	60(a3),52(a3)
	move.l	64(a3),56(a3)
	move.w	68(a3),60(a3)
	move.l	72(a3),64(a3)
	move.w	76(a3),68(a3)
	move.l	80(a3),72(a3)
	move.w	84(a3),76(a3)
	move.l	88(a3),80(a3)
	move.w	92(a3),84(a3)
	move.l	96(a3),88(a3)
	move.w	100(a3),92(a3)
	move.l	104(a3),96(a3)
	move.w	108(a3),100(a3)
	move.l	112(a3),104(a3)
	move.w	116(a3),108(a3)
	move.l	120(a3),112(a3)
	move.w	124(a3),116(a3)
	move.l	128(a3),120(a3)
	move.w	132(a3),124(a3)
	move.l	136(a3),128(a3)
	move.w	140(a3),132(a3)
	move.l	144(a3),136(a3)
	move.w	148(a3),140(a3)
	move.l	152(a3),144(a3)
	move.w	156(a3),148(a3)
	move.l	160(a3),152(a3)
	move.w	164(a3),156(a3)
	move.l	168(a3),160(a3)
	move.w	172(a3),164(a3)
	move.l	176(a3),168(a3)
	move.w	180(a3),172(a3)
	move.l	184(a3),176(a3)
	move.w	188(a3),180(a3)
	move.l	192(a3),184(a3)
	move.w	196(a3),188(a3)
	move.l	200(a3),192(a3)
	move.w	204(a3),196(a3)
	move.l	208(a3),200(a3)
	move.w	212(a3),204(a3)
	move.l	216(a3),208(a3)
	move.w	220(a3),212(a3)
	move.b	(a6)+,216(a3)
	move.b	(a6)+,218(a3)
	move.b	(a6)+,220(a3)
	subq.w	#3,a6
	move.b	(a5),(a6)+
	move.b	2(a5),(a6)+
	move.b	4(a5),(a6)+
	move.b	(a5),217(a3)
	move.b	2(a5),219(a3)
	move.b	4(a5),221(a3)
	lea	230(a3),a3
	lea	12(a5),a5
	endr
	dbf	d7,Doom
	bchg	#0,AGH
	bne.s	Add5
	addq.l	#1,(a4)
	bra.s	Add1
Add5	addq.l	#5,(a4)
Add1	addq.w	#1,Control
	rts
AGH	ds.l	1
AGH2	ds.l	1
RastScrl
	cmp.w	#0,Kontrol
	bne.s	RNotNext
	moveq	#0,d4
	MOVEQ	#0,D5
	lea	RCount(pc),a6
	lea	RTekst(pc),a3
	move.w	(a6),d4
	move.b	(a3,d4.w),d5
	move.w	#8,Kontrol
	cmp.b	#-1,d5
	bne.s	RViol
	move.w	#0,(a6)
	move.b	(a3),d5
RViol	addq.w	#1,(a6) ;Txt Count
	LEA	(WPizdu+2)(pc),A5
	CMP.B	#'x',D5	;czy zmn kol
	BNE.S	N_Z_K
	MOVE.W	#$3481,(A5)
	ADDQ.W	#1,(A6)	;nast lit
	ADDQ.W	#1,D4	;nast lit
	MOVE.B	(a3,d4.w),d5 ;wez ja
	BRA.S	N_Z_K1
N_Z_K	move.w	#$3482,(a5)
N_Z_K1	sub.w	#32,d5
	and.w	#$3f,d5
	LSL.W	#3,D5
	lea	Fontki(pc),a6
	movem.l	(a6,d5.w),d3-d4
	lea	RBufor(pc),a6
	movem.l	d3-d4,(a6)
RNotNext
	move.w	#$3480,d1 ;[d0]
WPizdu	move.w	#$3482,d2 ;[d2]
	move.w	Kontrol(pc),d3
	lea	RBufor(pc),a6
	lea	Glue(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,(a6)
	beq.s	Zero0
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden0
Zero0	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden0	lea	Glue2(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,1(a6)
	beq.s	Zero1
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden1
Zero1	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden1	lea	Glue3(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,2(a6)
	beq.s	Zero2
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden2
Zero2	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden2	lea	Glue4(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,3(a6)
	beq.s	Zero3
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden3
Zero3	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden3	lea	Glue5(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,4(a6)
	beq.s	Zero4
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden4
Zero4	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden4	lea	Glue6(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,5(a6)
	beq.s	Zero5
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden5
Zero5	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden5	lea	Glue7(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,6(a6)
	beq.s	Zero6
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden6
Zero6	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden6	lea	Glue8(pc),a5
	lea	2(a5),a4
	rept	7
	movem.l	(a4)+,d4-d7
	movem.l	d4-d7,(a5)
	movem.l	d4-d7,128(a5)
	movem.l	d4-d7,256(a5)
	lea	16(a5),a5
	endr
	btst.b	d3,7(a6)
	beq.s	Zero7
	move.w	d2,-2(a5)
	move.w	d2,-2+128(a5)
	move.w	d2,-2+256(a5)
	bra.s	Jeden7
Zero7	move.w	d1,-2(a5)
	move.w	d1,-2+128(a5)
	move.w	d1,-2+256(a5)
Jeden7	subq.w	#1,Kontrol
	rts



*************************************
*************************************
*************************************
***                               ***
***            V B L              ***
***                               ***
*************************************
*************************************
*************************************


VBL
	lea	$ffff8242.w,a0
	move.l	#$6660444,(a0)+
	move.l	#$5550070,(a0)+
	move.l	#$0330044,(a0)+
	move.l	#$0550014,(a0)+
	move.l	#$0250036,(a0)+
	move.l	#$0470057,(a0)+
	move.l	#$0670467,(a0)
	lea	Screen(pc),a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	clr.b	$fffffa1b.w
	move.l	#HBL,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bsr	SKROLL
	bsr	Scroll
	bsr	SCRL
	bsr	FALUJ_Z_VATem
	bsr	GScroll
	lea	Cykl(pc),a4
	bchg	#0,AGH2
	beq.s	Movex
	move.w	#$4e71,(a4)	[4]
	bra.s	Nopx
Movex	move.w	#$3480,(a4)	[8]
	bsr	RastScrl
Nopx	bsr	(Muzyka+8)
***	nop
***	move.w	#450,d7		[5416]
***dbfx	dbf	d7,dbfx
	rte



*************************************
*************************************
*************************************
***                               ***
***             H B L             ***
***                               ***
*************************************
*************************************
*************************************



HBL	clr.b	$fffffa1b.w
	move.l	#HBL_01,$120.w
	move.b	#30,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
HBL_01	lea	$ffff8209.w,a0
	lea	$ffff8240.w,a2
	moveq	#0,d0
	moveq	#16,d1
	moveq	#$60,d2
BegLine	move.b	(a0),d0
	beq.s	BegLine
	sub.b	d0,d1
	lsl.b	d1,d0
	rept	94
	nop
	endr
	move.w	#$522,d1
Cykl	move.w	d0,(a2)
Glue	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue2	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue3	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue4	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue5	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue6	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue7	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
Glue8	rept	32*3
	move.w	d0,(a2)
	move.w	d0,(a2)
	endr
	move.w	d0,(a2)
	move.l	#HBL_1a,$120.w
	rte
HBL_1a	clr.b	$fffffa1b.w
	move.l	#HBL_A0,$120.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
HBL_A0	move.w	#$300,$ffff8242.w
	move.l	#HBL_A1,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A1	move.w	#$400,$ffff8242.w
	move.l	#HBL_A2,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A2	move.w	#$510,$ffff8242.w
	move.l	#$50510,$ffff8244.w
	move.l	#HBL_A3,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A3	move.w	#$620,$ffff8242.w
	move.l	#$50620,$ffff8244.w
	move.l	#HBL_A4,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A4	move.w	#$730,$ffff8242.w
	move.l	#$50730,$ffff8244.w
	move.l	#HBL_A5,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A5	move.w	#$740,$ffff8242.w
	move.l	#$50740,$ffff8244.w
	move.l	#HBL_A6,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A6	move.w	#$750,$ffff8242.w
	move.l	#$50750,$ffff8244.w
	move.l	#HBL_A7,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A7	move.w	#$740,$ffff8242.w
	move.l	#$50740,$ffff8244.w
	move.l	#HBL_A8,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A8	move.w	#$730,$ffff8242.w
	move.l	#$50730,$ffff8244.w
	move.l	#HBL_A9,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_A9	move.w	#$620,$ffff8242.w
	move.l	#$50620,$ffff8244.w
	move.l	#HBL_B0,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_B0	move.w	#$510,$ffff8242.w
	move.l	#$50510,$ffff8244.w
	move.l	#HBL_B1,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_B1	move.w	#$400,$ffff8242.w
	move.l	#HBL_B2,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_B2	move.w	#$300,$ffff8242.w
	move.l	#HBL_B3,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_B3	move.w	#$000,$ffff8242.w
	move.l	#HBL_1b,$120.w
	bclr	#0,$fffffa0f.w
	rte
HBL_1b	move.l	#$0000022,$ffff8240.w
	move.l	#$0330044,$ffff8244.w
	move.l	#$0550066,$ffff8248.w
	move.l	#$0770277,$ffff824c.w
	clr.b	$fffffa1b.w
	move.l	#HBL_1c,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	rte
HBL_1c	move.b	#0,$fffffa1b.w
	movem.l	d0/a1,-(a7)
	lea	$fffffa21.w,a1
	move.b	#200,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
BegLow	cmp.b	(a1),d0
	beq	BegLow
	clr.b	$ffff820a.w
	rept	16
	nop
	endr
	move.b	#2,$ffff820a.w
	movem.l	(a7)+,d0/a1
	movem.l	d0-d2/a0-a2,-(a7)
	lea	$ffff8260.w,a1
	lea	$ffff8209.w,a0
	moveq	#0,d0
	moveq	#$42,d1
	move.b	#16,d2
	moveq	#0,d0
BegLinf	move.b	(a0),d0
	beq.s	BegLinf
	sub.b	d0,d2
	lsl.b	d2,d0
	rept	144
	nop
	endr
	not.w	d2
	lea	1(a0),a0
	moveq	#25,d2
	moveq	#0,d0
	bsr.s	Borders
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	13
	nop
	endr
	move.b	d1,(a1)
	moveq	#0,d0
	move.b	d0,(a1)
	lea	$ffff8240.w,a0
	rept	8
	move.l	d0,(a0)+
	endr
	movem.l	(a7)+,d0-d2/a0-a2
	rte
Borders	rept	3
	nop
	endr
	moveq	#0,d0
	moveq	#$42,d1
	move.b	d0,(a0)
	move.b	d1,(a0)
	rept	12
	nop
	endr
	moveq	#$42,d1
	move.b	d1,(a1)
	moveq	#0,d0
	move.b	d0,(a1)
	rept	11
	nop
	endr
	moveq	#$42,d1
	move.b	d1,(a1)
	moveq	#0,d0
	move.b	d0,(a1)
	rept	81
	nop
	endr
	dbf	d2,Borders
	RTS


*************************************
*** S E T  A L L  P A R A M E T R ***
*************************************
Panda:	rept	8
	move.l	d0,(a0)+
	endr
	move.l	$466.w,d1
Sync	cmp.l	$466.w,d1
	beq.s	Sync
	cmp.l	#$fa52235f,$fa0000
	bne.s	.Ufff
	bsr	ACHTUNG
.Ufff	move.l	$466.w,d1
Sync2	cmp.l	$466.w,d1
	beq.s	Sync2
	cmp.l	#$fa52235f,$fa0000
	bne.s	.Ufff2
	bsr	ACHTUNG
.Ufff2	rts
res:
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	#$31415926,$426.w
	move.l	$4.w,$42a.w
	cmp.l	#$fa52235f,$fa0000
	bne.s	.Ufff
	bsr	ACHTUNG
.Ufff	move.l	#$7770777,d0
	moveq	#6,d7
TopCat	lea	$ffff8240.w,a0
	bsr	Panda
	sub.l	#$1110111,d0
	dbf	d7,TopCat
	lea	$60000,a0
	lea	$ffff8200.w,a1
	moveq	#0,d0
	move.w	#1999,d7
clear	rept	16
	move.l	d0,(a0)+
	endr
	dbf	d7,clear
	bsr	prepare0
	bsr	prepare1
	bsr	prepare2
	bsr	prepare3
	move.b	#2,10(a1)
	move.b	#0,96(a1)
	move.w	#-1,$7de74
	lea	save(pc),a1
	lea	$fffffa00.w,a0
	move.b	$07(a0),(a1)+
	move.b	$09(a0),(a1)+
	move.b	$13(a0),(a1)+
	move.b	$15(a0),(a1)+
	move.l	$70.w,(a1)+
	move.l	$120.w,(a1)+
	moveq	#0,d0
	moveq	#1,d1
EofI	bclr	#3,$17(a0)
	move.b	d1,$07(a0)
	move.b	d0,$09(a0)
	move.b	d1,$13(a0)
	move.b	d0,$15(a0)
	move.b	#0,$21(a0)
	move.b	#2,$ffff820a.w
	move.b	#0,$1b(a0)
	move.b	#$12,$202(a0)
	moveq	#1,d0
	bsr	Muzyka
	stop	#$2300
	move.l	$466.w,d0
Synch	cmp.l	$466.w,d0
	beq.s	Synch
	move.l	#VBL,$70.w
	rts
ret	lea	save(pc),a3
	lea	$fffffa00.w,a4
	move.b	(a3)+,$07(a4)
	move.b	(a3)+,$09(a4)
	move.b	(a3)+,$13(a4)
	move.b	(a3)+,$15(a4)
	move.l	(a3)+,$70.w
	move.l	(a3)+,$120.w
	move.b	#8,$202(a4)
	move.b	#$c0,$23(a4)
	move.w	#$444,$ffff8240.w
	move.w	#$002,$ffff825e.w
	lea	$ffff8800.w,a6
	move.l	#$707ffff,(a6)
	move.l	#$8080000,(a6)
	move.l	#$909ffff,(a6)
	move.l	#$a0a0000,(a6)
	rts
Control	dc.w	4
Kontrol	dc.w	8
SvdAdr	ds.l	1
Screen	dc.l	$6c000,$76000
save	ds.l	6
LCount	ds.l	1
RCount	ds.l	1
Kolunt	ds.w	1
WitchL	ds.w	1
Shift	dc.w	-1
LitBuf	ds.b	8
GTekst	dcb.w	$2020,9
	dc.b	'HEJA!!!  NAST&PNY SKROLL BAJ VAT.  KURWA MA%! OSTATNIO ZOSTA*EM SKRYTYKOWANY '
	dc.b	'NA GIE*DZIE W WARSZAWIE/ ZA TO/ >E JA NIC NIE ROBI& POZA SKROLAMI!?!  PO '
	dc.b	'CZ&<CI TO PRAWDA/ ALE JA JAK JU> CO< ROBI& TO STARAM SI& DOPROWADZI% TO DO '
	dc.b	'PERFEKCJI (ALBO JEJ GRANIC).  ABY UDA*O SI& WSADZI% W TYM DEMKU TYLE SKROLI '
	dc.b	'POTRZEBOWA*EM U>Y% KILKU INTERESUJ$CYCH TECHNIK/ KT,RYCH MOMENT POWSTANIA W '
	dc.b	'MOJEJ G*OWIE SI&GA MARCA ',39,'93.  '
	dc.b	'TERAZ KR,TKO OPISZ& EKRAN:   1. TEN NA DOLNEJ RAMCE JEST 3-PLANOWY I MA '
	dc.b	'D*UGO<% 456 PIXELI/ (DLA INFORMACJI NIEKT,RYCH: NORMALNIE JEST 320 PIX).  '
	dc.b	'POS,WA ON NA EKRANIE Z PR&DKO<CI$ (8 PIX NA VBL)/ TEKST NAPISANY PRZEZ -GA*GANA-.  '
	dc.b	'2. TYCH MALUTKICH OBRACAJ$CYCH SI& SKROLIK,W JEST 13 PO 8 PIX WYSOKO<CI KA>DY.  '
	dc.b	'ONE ZA< PRZES,WAJ$ SI& CO 1 PIX W LEWO I W G,R& NA VBL (ONE NIE S$ KALKULOWANE).  '
	dc.b	'3. TEN SKROLL/ KT,RY W*A<NIE CZYTASZ MA 80 PIX WYSOKOSCI I SUNIE JAK JEGO KOLE< '
	dc.b	'NA DOLE CO 8 PIX (PER VBL OF KORS).  '
	dc.b	'4. NO I TEN TE> JEST D*U>SZY NI> STANDARDOWE SKRLE I ZAPIERDALA CO 4 PIX.    '
	dc.b	'NO DOBRA DOSY% TYCH KWAS,W...  TERAZ PEWNA RADA DLA TYCH/ KT,RZY POSIADAJ$ MONITOR '
	dc.b	'SC 1224 I NIE MOG$ PRZECZYTA% DOLNEGO SKROLA:  JE<LI NIE BOISZ SI& TO ZDEJMIJ '
	dc.b	'OBUDOW& Z MONITORA I PO STRONIE GDZIE REGULUJESZ G*O<NO<% ZNAJDUJE SI& RZ$D MA*YCH '
	dc.b	'POKR&TE*.  OSTATNI Z NICH (TEN NAJBLI>EJ EKRANU) UMO>LIWIA PODNIESIENIE OBRAZU...  '
	dc.b	'CO BY TU JESZCZE NAPISA%???    NO DOBRA/ MO>E TERAZ TROCH& >ALI DO LUDZI PISZ$CYCH '
	dc.b	'SCREENY DO QUAST MAGA/ I NIE TYLKO.  DLACZEGO W WI&KSZO<CI DEMEK:  SKACZ$ RASTRY/  '
	dc.b	'SKROLE ZAPIERDALAJ$ ZBYT SZYBKO (16 PIX NA VBL) LUB ZBYT WOLNO (1/2 PIX NA VBL)/ '
	dc.b	'PIERDOLI SI& GRAFIKA (JA TO NAZYWAM PKT. PRZEGI&CIA)/  WEKTOROWE? ROTACJE GUBI$ PUNKTY NA EKRANIE (DU>Y ROZMACH M.B???)/  '
	dc.b	'KOLORY S$ =LE DOBRANE DO GRAFIKI/ A TAK>E =LE PRZELICZONE (NIEKT,RZY CHYBA DO TEJ PORY NIE '
	dc.b	'ROZUMIEJ$ NA CZYM POLEGA ZWI$ZEK PLAN,W I KOLOR,W!!!). WSZYSTKIE TE WADY MO>NA ZAUWA>Y% W INTRACH '
	dc.b	'(QUAST',39,'A NR.5).  POLE%MY DALEJ:  T.F.T.E.  1. WASZ CIRCLE Z KROPEK/ NIE JEST PIERWSZYM W POLSCE (PRZED '
	dc.b	'WAMI BY* CONAJMNIEJ -ZYP- (DWA LATA TEMU))! A POZATEM W WASZYM EFEKCIE ZWANYM KOSIARK$ DZIEJE SI& COSIK DZIWNEGO: '
	dc.b	'FONTKI WKR&CONE W WIR WYCHODZ$ Z NIEGO TROCH& INNE!?! (MO>E TO TAK SPECJALNIE?).  NO TO NA TYLE/ PRZYKRO MI JE>ELI '
	dc.b	'UWA>ACIE/ >E SI& PRZYSYSAM!  I JESZCZE DLA PORZ$DKU DATA Z*O>ENIA: 1993.08-17.    9.........8........7.......6......5.....4....3...2..1.0  CIACH!!!',0
TekstM	dc.b	'  A OTO MALUTKI OBRACAJ$CY SI& SKROLIK KODED BAJ VAT!!!  (*IW A*T PREKALKULEJSZYN!) '
	dc.b	'A W NIM MA*E OG*OSZENIE:    SPRZEDAM OK. 600 DYSK,W 5/25". '
	dc.b	'( T A N I O )  WSZYSTKIE W BARDZO DOBRYM STANIE. NA KA=DYM '
	dc.b	'NAGRANE S$ NAJLEPSZE PROGRAMY NA ST(E). CENA DO UZGODNIENIA!!! '
	dc.b	'JAKBY CO TO PODAJ& NAMIARY:    ARTUR  KARWATKA   UL.APTECZNA  4-6 M.40   '
	dc.b	'04-367   WARSZAWA ......... OCZYWI<CIE W MIAR& MO=LIWO<CI EWENTUALNEMU '
	dc.b	'KUPCOWI GWARANTUJ& DOST&P DO WSZYSTKICH NOWO<CI GIE*DOWYCH (ZAR,WNO U=YTK,W JAK I GIEREK)!!! '
	dc.b	'TO BY BY*O NA TYLE. NIE WIEM CO DALEJ PISA%. MO=E PO PROSTU ZOSAWI& TROCHE WOLNEGO MIEJSCA???'
	dc.b	'9.........8........7.......6......5.....4....3...2..1.0....'
	dc.b	'.................................................................',0
Tekst	dcb.w	$2020,14
	dc.b	"NO TO JADZIEM, TUTAJ GA*GAN PRZY KLAWIATURZE!!!   WSZYSTKO ZACZ%*O SI% OD TEGO, =E VAT ZADZWONI* DO MNIE "
	dc.b	"KT<REGO> DNIA I ZAPODA*:  GA*GAN WE> WYDUMAJ JAKI> G*UPI TEKST DO SKROLLA "
	dc.b	"BO NAJEBA*EM SKROLLI W MOIM DEMIE I NIE MAM CO W NICH NAPISA$!  NO TO JA MU M<WI%:  "
	dc.b	"A CO TO, KURWA, MOJE DEMO CZY TWOJE?  A VAT NA TO:  JAK NAPISZESZ TEN TEKST "
	dc.b	"TO W SOBOT% POJAD% NA GIE*D% I ZA*ATWI% CO> NOWEGO, OK?   DOBRA! (CHOCIA= NIE "
	dc.b	"MUSIA*EM ZAPIERDALA$ NA GIE*D%, KIEDY NA DWORZU PANUJE TEMPERATURA PUSTYNNA...)  "
	dc.b	"MIN%*O PAR% DNI, A SCROLL BY* DALEJ NIE NAPISANY.  BYNAJMNIEJ NIE PRZEJMOWA*EM SI%, =E "
	dc.b	"VAT MNIE OPIERDOLI, BO MI TO ZWISA*O (I DALEJ ZWISA).  CHC% DODA$, =E SKROLL TEN BY*BY "
	dc.b	"DALEJ NIE NAPISANY, GDYBY NIE FATALNY INCYDENT Z SAMPLEREM, KT<RY ZRESZT# JEST NIE M<J, "
	dc.b	"ANI VAT'A.  TRZYMA*EM GO JU= D*U=SZY OKRES CZASU I VAT SI% W KO+CU WKURWI* NA MNIE.  =EBY "
	dc.b	"GO UDOBRUCHA$ MUSIA*EM NAPISA$ TEN TEKST.  NA RAZIE O TYM DOSY$.  TERAZ ZMIENIAM TEMAT.  "
	dc.b	"KT<REGO> DNIA SPOTKA*EM MOJEGO KUMPLA AMIGOWCA, A TEN MI M<WI:  NIE LUBI% AJBIEMOWC<W!  "
	dc.b	"JA TE=!  (B*EEEEE...).  TAK NA MARGINESIE TO JEST ON JEDNYM Z NIEWIELU AMIGOWC<W, Z KT<RYM MO=NA "
	dc.b	"PRZEPROWADZI$ KONKRETN# GADK%.  (WI%KSZO>$ (ALE NIE WSZYSCY!) AMIGOWC<W JEST JEDNAK PRYMITYWNA TAK JAK AJBIEMOWCY "
	dc.b	"I CHWALI SI% T# SWOJ# AMIG# TAK, =E JAK BY MOG*I, TO BY WYRUCHALI T# SWOJ# AMIG% W PORT D=OJSTIKA...  "
	dc.b	"TAK NA MARGINESIE TO AMIGA BY WTEDY PIERDOLN%*A, BO JEJ NIE MO=NA NIC WK*ADA$ DO PORT<W W CZASIE PRACY...)  "
	dc.b	"JEDNAK=E NIE MO=NA NA AMIG% PUSZCZA$ ZA BARDZO SMARU, BO PRZECIE= W JEJ >RODKU SIEDZI MOTOROLA.  NATOMIAST "
	dc.b	"NAJWI%KSZY CH*AM NA >WIECIE STANOWI# AJBIEMOWCY.  ICH KOMPUTER TO Z*OM.  SYTEM OPERACYJNY MS-DOS JEST CHUJOWY JAK BARSZCZ "
	dc.b	"(KA=DY BY CHYBA DOSTA* SZOKU, KIEDY ABY CO> WGRA$ WKLEPYWA$ SEKWENCJ% A, DWUKROPEK, BACKSLASH, NAZWA PLIKU (O ILE NIE MA PRZEDTEM 10-CIU KATALOG<W).  OCZYWI>CIE "
	dc.b	"MO=EMY SOBIE WGRA$ WINDOWS, ALE NA ZWYK*YM AT ZAJM# Z P<* PAMI%CI, A ICH PRACA MO=E PRZYPRAWI$ KA=DEGO ATAROWCA O ATAK >MIECHU.  "
	dc.b	"JA OSOBI>$IE OSTRO SI% U>MIA*EM JAK US*YSZA*EM MUZYCZK% Z GRY 'GODS' NA AJBIEMA WYDOBYWAJ#C# SI% Z WBUDOWANEGO BRZ%CZYKA. MAKABRA!  "
	dc.b	"TERAZ PORA NA POZDROWIENIA:   VAT (=ADNEGO TEKSTU WI%CEJ!!!),   ANDREAS (CWKS-IE, KLUBIE KOCHANY, STRZELISZ DWIE BRAMY, A MY POCHLAMY!),   "
	dc.b	"DYMIN (AMIGA),   PETER (KICK OFF FAN),   CIAPKI,   POZDRAWIAM TAK=E CA*# EKIP% ZE SCENY ST W POLSCE:  (QUAST MAGAZINE,  TFTE,  I WSZYSCY, O KT<RYCH "
	dc.b	"ZAPOMNIA*EM...).  POZDRAWIAM TAK=E WSZYSTKICH PIERZASTYCH METALI (Z WY*#CZENIEM LESZCZY S*UCHAJ#CH KAPEL TYPU:  METALLICA, GUNS N ROSES ITD...  I UWA=AJ#CYCH SI% ZA WIELKICH METALI).  "
	dc.b	"JEDNOCZE>NIE PRZYPOMINAM, =E GUNS N ROSES TO =ADEN THRASH METAL, JAK SI% NIEKT<RYM G*UPKOM WYDAJE (BLEEE....).  "
	dc.b	"A TERAZ ZAMIAST ROZWODZI$ SI% NAD FUCKAMI DLA POSZCZEG<LNYCH LUDZI, TO NAPISZ% TYLKO, =E:  PIERDOL% WSZYSTKICH AJBIEMOWC<W, I WSZYSTKICH WYKR%T<W "
	dc.b	"KT<RYCH NIE LUBI%.  NA TYM KONIEC.  TEN TEKST NIE M<G* BY$ CHYBA BARDZIEJ FATALNY, ALE W SUMIE CO B#D@, VAT O TO BARDZO ZABIEGA*, WI%C "
	dc.b	"MA CO CHCIA*.  A JAK MU SI% CO> NIE SPODOBA, TO:  'DOSTANIE W CABAN Z PRZYCZAJKI...'      ZJAZD!!!                   ",-1
RTekst	dcb.w	$2020,6
	dc.b	'HEJ LUDZIKI! W TYM SKROLU B&D$ SWOBODNIE PRZELATYWA% POZDROWIENIA W '
	dc.b	'BLI>EJ (ANI DALEJ) NIE OKRE<LONEJ KOLEJNO<CI. A WI&C DO DZIE*A:   '
	dc.b	'xZxYxP (JE<LI KUPISZ COSIK INNEGO NI> FALCON 030 TO... )/   '
	dc.b	'xGxAx*xGxAxN (I CO TAM RAFCIU/ KIEDY NOWE DEMKO?)/   '
	dc.b	'xPxExTxExR (WARSZAWSKI MEMBER OF -QUANT- (*UDZ& SI& NADZIEJ$/ >E NAJDZIE CI& OCHOTA DO NARYSOWANIA CZEGOKOLWIEK... WCI$> NAJLEPSZY!!!))/   '
	dc.b	'xPxExTxExR x2 (HEJ MISTRZU!  xKICK xOFF x2/ xJOUST/ xCHAOS xENGINE  (TWO PLAYERS GAMES FOREVER))/   '
	dc.b	'xPxExRxVxExRxT (CO NOWEGO S*YCHA%/ ODEZWIJ SI&)/   '
	dc.b	'xRxAxFxAx* (xTHE xSUPERxVISORS)/   '
	dc.b	'xAxCxIxD xMxAxKxExR (DOBRE DRAGONNELS DEMO!)/   '
	dc.b	'xAxMxIxGxAxNxT ZE ZLOTU W ORNECIE (BY*E< JEDYN$ OSOB$/ Z KT,R$ BY*O O CZYM POGADA%! (SCORPIO???))/   '
	dc.b	'xVxOxN xBxOxBxO (CO Z NOWYMI MOD-SAMI?)/   '
	dc.b	'xCxIxAxPxKxI/   '
	dc.b	'xMxAxCxIxExK xMx. (MCMAT... DZI&KI ZA NIE PRZESPAN$ NOC...(ARMOURGEDDON..RS232..2 ST)/   '
	dc.b	'xMxAxRxExK xJx. (DZI&KI ZA WSZYSTKIE NOWO<CI!)/   '
	dc.b	'xB xAxNxD xB (HEJA LUDZIKI!!!)/   '
	dc.b	'xTxOxMxExK xI xTxAxTxUx< (Z GIE*DY NA GRZYBOWSKIEJ)/   '
	dc.b	'xAxNxDxRxExAxS (KIEDY NAST&PNA ZABAWA???)/   '
	dc.b	'xMxIxXxX (COMMODOROWIEC Z KOSZALINA)/   '
	dc.b	'xAxRxTxUxR xBx. (BARONTRONIC)/   '
	dc.b	'xVxAxN xExIxJxK (DZI&KI ZA SAMPLER I ...(MAM NADZIEJ&/ >E TWOJA KOLE>ANKA NIE GNIEWA SI& NA MNIE I MA%KA ZA OSTATNI$ BEZSENN$ NOC NA PARTY... (NIE MY<LCIE SOBIE...))/   '
	dc.b	'xCxOxSxTxExK (NIE CHC& NIC M,WI%/ ALE DOBRZE SI& ZAPOWIADASZ...)/   '
	dc.b	'xMxAxRxCxHxExW (KIEDY VISION 2 DEMO???)/   '
	dc.b	'xTx.xFx.xTx.xEx. (CZEKAM NA KOLEJNE DEMKA (MO>E LEPSZE?))/   '
	dc.b	'xLxExCxH xZx. (BILBO)/   '
	dc.b	'xGxAxC xKxAxZxIxMxIxExRxZ (TOKAMAK/ PLAZMA/ ...)/   '
	dc.b	'xKxOxDxExRxZxY Z TR,JMIASTA/   '
	dc.b	'xPxAxSxKxUxD I KUMPLE/   '
	dc.b	'xIxLxLxUxSxIxOxNxS (NIEZ*Y MAGAZYN... I CO DALEJ!)/   '
	dc.b	'xRxExDxAxKxCxJxA xSxTxExFxAxNxA (SZCZEG,LNIE CI CO PRZYWIE=LI FALCONA DO ORNETY)/   '
	dc.b	'xSxFxJ (POZNA+).     '
	dc.b	'TO NA TYLE Z POZDROWIE+. JE<LI KOGO< POMIN$*EM TO TYLKO DLATEGO/ >E ZAPOMNIA*EM! '
	dc.b	'CO DO FUCKS,W TO JAK ZWYKLE LEC$ DO TYCH/ KT,RZY MNIE NIE LUBI$ JAK I DO TYCH/ '
	dc.b	'CO SKLECAJ$ DEMKA Z CUDZYCH PROCEDUR I UWA>AJ$ JE ZA W*ASNE! (OSTATNIO BIJE REKORDY '
	dc.b	'POPULARNO<CI DOLNA RAMKA)!    xNO xTO xHEJA xJEBANI xMILUSI+SCY!!! ',-1
	even
prepare0
	lea	copies(pc),a0
	lea	Screen(pc),a2
	move.l	(a2)+,a1
	move.l	(a2),a2
	moveq	#19,d6
	moveq	#15,d7
SzutUp	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d6,SzutUp
	moveq	#19,d6
	dbf	d7,SzutUp
	rts
RBufor	ds.l	8
Bufor	ds.l	25*6
Kalk	dc.w	0*160,1*160,2*160,3*160,4*160,5*160,6*160,7*160,8*160,9*160
	dc.w	$0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007,$0008,$0009
FntAdr	dc.l	00*300+Fonty,01*300+Fonty,02*300+Fonty,03*300+Fonty,04*300+Fonty,05*300+Fonty,06*300+Fonty,07*300+Fonty,08*300+Fonty,09*300+Fonty
	dc.l	10*300+Fonty,11*300+Fonty,12*300+Fonty,13*300+Fonty,14*300+Fonty,15*300+Fonty,16*300+Fonty,17*300+Fonty,18*300+Fonty,19*300+Fonty
	dc.l	20*300+Fonty,21*300+Fonty,22*300+Fonty,23*300+Fonty,24*300+Fonty,25*300+Fonty,26*300+Fonty,27*300+Fonty,28*300+Fonty,29*300+Fonty
	dc.l	30*300+Fonty,31*300+Fonty,32*300+Fonty,33*300+Fonty,34*300+Fonty,35*300+Fonty,36*300+Fonty,37*300+Fonty,38*300+Fonty,39*300+Fonty
	dc.l	40*300+Fonty,41*300+Fonty,42*300+Fonty,43*300+Fonty,44*300+Fonty,45*300+Fonty,46*300+Fonty,47*300+Fonty,48*300+Fonty,49*300+Fonty
	dc.l	50*300+Fonty,51*300+Fonty,52*300+Fonty,53*300+Fonty,54*300+Fonty,55*300+Fonty,56*300+Fonty,57*300+Fonty,58*300+Fonty,59*300+Fonty
Font	incbin	\data\vat-font.dat
Fontki	incbin	\data\vat_font.img
Muzyka	incbin	\data\cynix.mus
Fonty	incbin	\data\fonty_1m.img
oryginal
	dc.l	$FFFC8004,$00030002,$FF830004,$80014001,$FFFFFFFF,$FFFCFFFC,$FFFC0000,$00030000
	dc.l	$FF870008,$E0012002,$FFFF0000,$FFFC0002,$7FF88004,$00010003,$FF0F0090,$E0031000
	dc.l	$FFFF0000,$FFFE0002,$3FF00000,$00000000,$FE1F8110,$F0030804,$FFFF0000,$FFFE0000
	dc.l	$1FF02000,$00000000,$7C1F8220,$F8030804,$F83F0600,$E0FE0301,$1FF00000,$00000000
	dc.l	$7C3F8400,$F8070404,$E03F1000,$E03E0041,$0FF01008,$00000000,$783F8440,$FC070000
	dc.l	$C03F2000,$E01E0021,$0FF81008,$00000000,$F87F0000,$FC070200,$803F4000,$E00E0011
	dc.l	$0FF80000,$00000001,$F87B0884,$FE070000,$003F8000,$E000000F,$07F80804,$00000001
	dc.l	$F0F9080A,$FE000106,$003F0000,$E0000000,$07F80804,$00010001,$F0F10908,$FF000000
	dc.l	$003F0000,$E0000000,$07FC0000,$00010000,$F1F00001,$FF000080,$003F0000,$E0000000
	dc.l	$03FC0402,$00010002,$E1E01210,$FF800000,$003F0000,$E0000000,$03FC0002,$00030002
	dc.l	$E3E01000,$7F808040,$003F0000,$E0000000,$03FE0200,$00030000,$E3C00420,$7FC00000
	dc.l	$003F0000,$E0000000,$01FE0201,$00030004,$C7C02400,$7FC04020,$003F0000,$E0000000
	dc.l	$01FE0001,$00070004,$C7C00040,$3FE04020,$003F0000,$E0000000,$00FF0100,$00070000
	dc.l	$C7804840,$3FE02010,$003F0000,$E0000000,$00FF0100,$00078008,$8F804000,$1FE02010
	dc.l	$003F0000,$E0000000,$00FF0080,$800F8000,$8F001080,$1FF00000,$003F0000,$E0000000
	dc.l	$007F0080,$800F4010,$8F009080,$0FF01008,$003F0000,$E0000000,$007F0000,$801F4010
	dc.l	$1F008000,$0FF80008,$003F0000,$E0000000,$003F0040,$C01F0020,$1E002100,$0FF80804
	dc.l	$003F0000,$E0000000,$003F0040,$C01E2021,$3FFF2000,$FFF80004,$003F0000,$E0000000
	dc.l	$003F0020,$E03E0000,$3FFF0000,$FFFC0000,$003F0000,$E0000000,$001F0020,$E03E1042
	dc.l	$3FFF4000,$FFFC0002,$003F0000,$E0000000,$001F0010,$F07C0002,$7FFF4000,$FFFE0002
	dc.l	$003F0000,$E0000000,$000F0010,$F07C0880,$7C000000,$03FE0000,$003F0000,$E0000000
	dc.l	$000F0000,$F8F80084,$78008400,$01FE0201,$003F0000,$E0000000,$00070008,$F8F80500
	dc.l	$F8008400,$01FF0201,$003F0000,$E0000000,$00070000,$FDF00108,$F8000000,$01FF0100
	dc.l	$003F8000,$E0000000,$00030004,$FFF00201,$F0000800,$00FF0100,$003F8020,$E0000000
	dc.l	$00030000,$FFE00011,$F0000800,$00FF0000,$803F0020,$E0000000,$00010002,$FFE10000
	dc.l	$F0000000,$00FF0080,$803F4020,$E0000000,$00010001,$FFC10022,$F0000000,$007F0080
	dc.l	$803F4020,$E0000000,$00000001,$FFC30040,$F0000000,$007F0080,$C03F0000,$E0001000
	dc.l	$00000000,$7F878044,$F0000800,$00FF0080,$E03F2040,$F0000800,$00000000,$7F0F4090
	dc.l	$FC000400,$01FF0300,$F0FF1900,$FC000600,$00000000,$3F0F2110,$FC000200,$01FF0200
	dc.l	$F1FF0800,$FC000200,$00000000,$1E0F1210,$FC000400,$01FF0200,$F0FF0900,$FC000200
copies	incbin	\data\big_shit.img

