
* Universal demo-Q8	(c) 1989 Mega

	jmp	main

scrlpre	lea	font,a0
	lea	font0,a1
	moveq	#39,d0
pre0	moveq	#31,d1
pre1	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	4(a1),a1
	dbf	d1,pre1
	dbf	d0,pre0

	lea	font0,a0
	lea	font1,a1
	moveq	#2,d3
pre6	moveq	#39,d0
pre2	moveq	#31,d1
pre3	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	move.l	(a0)+,8(a1)
	moveq	#3,d2
pre4	move.b	#0,ccr
	roxr.w	(a1)
	roxr.w	4(a1)
	roxr.w	8(a1)
	move.b	#0,ccr
	roxr.w	2(a1)
	roxr.w	6(a1)
	roxr.w	10(a1)
	dbf	d2,pre4
	lea	12(a1),a1
	dbf	d1,pre3
	dbf	d0,pre2
	lea	15360(a0),a1
	dbf	d3,pre6

	lea	convtab,a0
	move.w	#255,d0
pre5	moveq	#0,d1
	move.w	(a0),d1
	mulu	#384,d1
	move.w	d1,(a0)+
	dbf	d0,pre5
	rts

scrl	move.l	14(a0),a1		*	buffpo
	move.l	46(a0),a2		*	fontpo
	move.l	(a0),a3			*	txtpo
	move.l	4(a0),d0
	andi.l	#$ffff,d0
	cmp.w	12(a0),d0
	bne.s	inteslut
	moveq	#0,d0
	move.l	d0,4(a0)
inteslut	move.b	(a3,d0.w),d1
	andi.w	#$ff,d1
	add.w	d1,d1
	lea	convtab,a3
	move.w	(a3,d1.w),d1
	move.w	8(a0),d3
	andi.w	#12,d3
	add.w	d3,d1
	move.l	62(a0),d3
a	set	0
b	set	80
	rept	32
	move.l	(a2,d1.w),d4
	and.l	d3,a(a1)
	and.l	d3,b(a1)
	or.l	d4,a(a1)
	or.l	d4,b(a1)
a	set	a+160
b	set	b+160
	lea	12(a2),a2
	endr
	move.l	14(a0),a1
	lea	4(a1),a1
	move.l	currbas,a2
	lea	16000(a2),a2
	moveq	#31,d0
utmeddet
a	set	0
	rept	20
	move.l	(a1)+,a(a2)
a	set	a+8
	endr
	lea	80(a1),a1
	lea	160(a2),a2
	dbf	d0,utmeddet

	move.l	4(a0),d0
	swap	d0
	add.l	#$00004000,d0
	swap	d0
	move.l	d0,4(a0)	
	lsl.w	62(a0)
	lsl.w	64(a0)
	addq.w	#1,8(a0)
	addq.l	#4,14(a0)
	move.l	14(a0),d0
	move.l	18(a0),14(a0)
	move.l	22(a0),18(a0)
	move.l	26(a0),22(a0)
	move.l	d0,26(a0)

	move.l	30(a0),d0
	move.l	34(a0),30(a0)
	move.l	38(a0),34(a0)
	move.l	42(a0),38(a0)
	move.l	d0,42(a0)

	move.l	46(a0),d0
	move.l	50(a0),46(a0)
	move.l	54(a0),50(a0)
	move.l	58(a0),54(a0)
	move.l	d0,58(a0)
	rts

cls	move.l	currbas,d0
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	move.l	currbas,a0
	move.l	othbas,a1
	moveq	#0,d1
	move.w	#7999,d0
clsloop
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,clsloop
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

ch_bas	move.l	othbas,d0
	move.l	currbas,othbas
	move.l	d0,currbas
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rts

*	The MAIN

main	pea	0
	move.w	#32,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,susp+2
	bsr	cls
	bsr	scrlpre
	move.w	sr,ssr+2
	move.w	#$2700,sr
	move.l	$70.w,svbl+2
	move.l	$68.w,shbl+2
	move.l	$118.w,skbd+2
	move.l	$134.w,sta+2
	move.l	$120.w,stb+2
	move.l	$114.w,stc+2
	move.b	$fffffa07.w,s07+3
	move.b	$fffffa09.w,s09+3
	move.b	$fffffa0b.w,s0b+3
	move.b	$fffffa0d.w,s0d+3
	move.b	$fffffa0f.w,s0f+3
	move.b	$fffffa11.w,s11+3
	move.b	$fffffa13.w,s13+3
	move.b	$fffffa15.w,s15+3
	move.b	$fffffa17.w,s17+3
	move.b	$fffffa19.w,s19+3
	move.b	$fffffa1b.w,s1b+3
	move.b	$fffffa1d.w,s1d+3
	move.b	$fffffa1f.w,s1f+3
	move.b	$fffffa21.w,s21+3
	move.b	$fffffa23.w,s23+3
	move.b	$fffffa25.w,s25+3
	move.l	#vbl,$70.w
	move.l	#hbl,$68.w
	move.l	#ta,$134.w
	move.l	#tb,$120.w
	move.l	#tc,$114.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	bclr.b	#3,$fffffa17.w
	move.w	#$2300,sr
	move.b	$ffff8260.w,s60+3
	andi.b	#3,s60+3
	sf	vsync
sync0	tst.b	vsync
	beq.s	sync0
	move.b	#0,$ffff8260.w
	sf	vsync
demoloop
	tst.b	vsync
	beq.s	demoloop
	bsr	ch_bas
.sync0	move.b	$ffff8209.w,d0
	beq.s	.sync0
	move.w	#$707,$ffff8240.w
	lea	texta,a0
	bsr	scrl
	move.w	#0,$ffff8240.w
	sf	vsync
	cmp.b	#$81,$fffffc02.w
	bne.s	demoloop

	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	sf	vsync
sync1	tst.b	vsync
	beq.s	sync1
s60	move.b	#2,$ffff8260.w
	move.w	#$2700,sr
svbl	move.l	#vbl,$70.w
shbl	move.l	#hbl,$68.w
skbd	move.l	#kbd,$118.w
sta	move.l	#ta,$134.w
stb	move.l	#tb,$120.w
stc	move.l	#tc,$114.w
s07	move.b	#0,$fffffa07.w
s09	move.b	#0,$fffffa09.w
s0b	move.b	#0,$fffffa0b.w
s0d	move.b	#0,$fffffa0d.w
s0f	move.b	#0,$fffffa0f.w
s11	move.b	#0,$fffffa11.w
s13	move.b	#0,$fffffa13.w
s15	move.b	#0,$fffffa15.w
s17	move.b	#0,$fffffa17.w
s19	move.b	#0,$fffffa19.w
s1b	move.b	#0,$fffffa1b.w
s1d	move.b	#0,$fffffa1d.w
s1f	move.b	#0,$fffffa1f.w
s21	move.b	#0,$fffffa21.w
s23	move.b	#0,$fffffa23.w
s25	move.b	#0,$fffffa25.w
	move.b	#$90,$fffffa23.w
	bset.b	#3,$fffffa17.w
ssr	move.w	#$2100,sr
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$777,$ffff8240.w
	move.w	#0,$ffff8246.w
susp	move.l	#0,-(sp)
	move.w	#32,-(sp)
	trap	#1
	lea	6(sp),sp
	clr.w	-(sp)
	trap	#1

vbl	st	vsync
	rte

hbl	rte

kbd	rte

ta	rte

tb	rte

tc	rte

td	rte

	section	data

palette	dc.w	0
	dcb.w	$777,15
currbas	dc.l	$000f0000
othbas	dc.l	$000f8000

font	incbin	a:\data\2plfnt.b

convtab	dcb.w	0,32
	dc.w	39
	dcb.w	0,8
	dc.w	36,37,0,0,38,0,26,27,28,29,30,31,32,33,34,35
	dcb.w	0,6
	dc.w	38,0
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
	dc.w	21,22,23,24,25
	dcb.w	0,200

	dc.b	"                                    "
txta	dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
txtaend	dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"


texta	dc.l	txta					*	0
	dc.l	0					*	4
	dc.w	0					*	8
	dc.l	txtaend-txta				*	10
	dc.l	buff3,buff2,buff1,buff0			*	14
	dc.l	buff3+80,buff2+80,buff1+80,buff0+80	*	30
	dc.l	font3,font2,font1,font0			*	46
	dc.l	$fff0fff0
							*	66
	section	bss

vsync	ds.w	1
oldpal	ds.l	8

font0	ds.l	3840
font1	ds.l	3840
font2	ds.l	3840
font3	ds.l	3840

buff0	ds.w	80*32
buff1	ds.w	80*32
buff2	ds.w	80*32
buff3	ds.w	80*32
