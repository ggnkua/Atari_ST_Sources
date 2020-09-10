	opt	x+
	lea	$80000,a7
	bsr	res
	bsr	res1
loop	
	move.w	#$000,$ffff8240.w
	bsr	vbl
	move.w	#$111,$ffff8240.w
	bsr	kula5
	;bsr	kula8
	bsr	kula10
	bra.s	loop


kula5
	moveq	#4,d6
	lea	pkt05(pc),a0 ;data
	lea	pos05a(pc),a1 ;pozycja
	lea	adr05(pc),a2 ;adresy
	lea	64(a2),a3    ;negacja
	lea	0.w,a6  ;przesuniecie
	bsr	Ball_Vbl
	lea	pos05b(pc),a1
	lea	160*3.w,a6
	bsr	Ball_Vbl
	lea	pos05c(pc),a1
	lea	160*6.w,a6
	bsr	Ball_Vbl
	lea	pos05d(pc),a1
	lea	160*9.w,a6
	bsr	Ball_Vbl
	lea	pos05e(pc),a1
	lea	160*12.w,a6
	bsr	Ball_Vbl
	lea	pos05f(pc),a1
	lea	160*15.w,a6
	bsr	Ball_Vbl
	lea	pos05g(pc),a1
	lea	160*18.w,a6
	bsr	Ball_Vbl
	lea	pos05h(pc),a1
	lea	160*21.w,a6
	bsr	Ball_Vbl
	lea	pos05i(pc),a1
	lea	160*24.w,a6
	bsr	Ball_Vbl
	lea	pos05j(pc),a1
	lea	160*27.w,a6
	bsr	Ball_Vbl
	lea	pos05k(pc),a1
	lea	160*30.w,a6
	bsr	Ball_Vbl
	lea	pos05l(pc),a1
	lea	160*33.w,a6
	bsr	Ball_Vbl
	rts
kula8
	moveq	#7,d6
	lea	pkt08(pc),a0 ;data
	lea	pos08a(pc),a1 ;pozycja
	lea	adr08(pc),a2 ;adresy
	lea	64(a2),a3    ;negacja
	lea	0.w,a6  ;przesuniecie
	bsr	Ball_Vbl
	lea	pos08b(pc),a1
	lea	160*3.w,a6
	bsr	Ball_Vbl
	lea	pos08c(pc),a1
	lea	160*6.w,a6
	bsr	Ball_Vbl
	lea	pos08d(pc),a1
	lea	160*9.w,a6
	bsr	Ball_Vbl
	lea	pos08e(pc),a1
	lea	160*12.w,a6
	bsr	Ball_Vbl
	lea	pos08f(pc),a1
	lea	160*15.w,a6
	bsr	Ball_Vbl
	lea	pos08g(pc),a1
	lea	160*18.w,a6
	bsr	Ball_Vbl
	lea	pos08h(pc),a1
	lea	160*21.w,a6
	bsr	Ball_Vbl
	lea	pos08i(pc),a1
	lea	160*24.w,a6
	bsr	Ball_Vbl
	rts
kula10
	moveq	#9,d6
	lea	pkt10(pc),a0 ;data
	lea	pos10a(pc),a1 ;pozycja
	lea	adr10(pc),a2 ;adresy
	lea	64(a2),a3    ;negacja
	lea	0.w,a6  ;przesuniecie
	bsr	Ball_Vbl
	lea	pos10b(pc),a1
	lea	160*9.w,a6
	bsr	Ball_Vbl
	lea	pos10c(pc),a1
	lea	160*18.w,a6
	bsr	Ball_Vbl
	lea	pos10d(pc),a1
	lea	160*27.w,a6
	bsr	Ball_Vbl
	lea	pos10e(pc),a1
	lea	160*36.w,a6
	bsr	Ball_Vbl
	lea	pos10f(pc),a1
	lea	160*45.w,a6
	bsr	Ball_Vbl
	lea	pos10g(pc),a1
	lea	160*54.w,a6
	bsr	Ball_Vbl

	rts

end	lea	old(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	clr.l	-(a7)
	dc.w	'NA'
	illegal
old	ds.w	16

vbl	move.l	d0,-(a7)
	move.l	$466.w,d0
vbl2	cmp.l	$466.w,d0
	beq.s	vbl2
	move.l	(a7)+,d0
	cmp.b	#$39,$fffffc02.w
	beq.s	end
	rts

Ball_Vbl
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a1),d0
	add.w	#4,(a1)
	move.w	0(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	move.w	-4(a0,d0.w),d3
	move.w	-2(a0,d0.w),d4
	cmp.w	#-1,d1
	bne.s	omin
	move.w	#4,(a1)
	move.w	(a0),d1
	move.w	2(a0),d2
omin	add.w	d4,d4
	add.w	d4,d4
	move.l	(a3,d4.w),a4
	move.w	d6,d7
	lea	$78000,a5
	add.l	a6,a5
	add.l	d3,a5
copy_a	movem.l	(a4)+,d3-d5
	and.l	d3,(a5)
	swap	d4
	and.w	d4,4(a5)
	swap	d4
	and.w	d4,8(a5)
	and.l	d5,10(a5)
	lea	160(a5),a5
	dbf	d7,copy_a
	lea	$78000,a5
	add.l	a6,a5
	add.l	d1,a5
	add.w	d2,d2
	add.w	d2,d2
	move.l	(a2,d2.w),a4
	move.w	d6,d7	
copy_b	movem.l	(a4)+,d3-d5
	or.l	d3,(a5)
	swap	d4
	or.w	d4,4(a5)
	swap	d4
	or.w	d4,8(a5)
	or.l	d5,10(a5)
	lea	160(a5),a5
	dbf	d7,copy_b
	rts











res
	clr.w	-(a7)
	pea	$78000
	pea	$78000
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
old_ssp	ds.l	1
	move.l	d0,old_ssp
	lea	old(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a1)+,(a0)+
	endr
	lea	pal(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	rts
res1	lea	new(pc),a0
	moveq	#0,d0
	move.w	#$dead,d7
prep1	move.l	d0,(a0)+
	dbf	d7,prep1
	lea	ball10(pc),a0
	lea	new(pc),a1
	lea	16*120(a1),a2
	lea	adr10(pc),a3
	lea	64(a3),a4
	lea	(a0),a5
	moveq	#15,d7 ;ilosc kopii
	moveq	#00,d4 ;przesuniecie
	moveq	#09,d5 ;wysokosc
	bsr	prep2
	lea	ball08(pc),a0
	lea	(a2),a1
	lea	16*96(a1),a2
	lea	adr08(pc),a3
	lea	64(a3),a4
	lea	(a0),a5
	moveq	#15,d7 ;ilosc kopii
	moveq	#00,d4 ;przesuniecie
	moveq	#07,d5 ;wysokosc
	bsr	prep2
	lea	ball05(pc),a0
	lea	(a2),a1
	lea	16*60(a1),a2
	lea	adr05(pc),a3
	lea	64(a3),a4
	lea	(a0),a5
	moveq	#15,d7 ;ilosc kopii
	moveq	#00,d4 ;przesuniecie
	moveq	#04,d5 ;wysokosc
	bsr	prep2
	rts
prep2	move.w	d5,d6
	lea	(a5),a0
	move.l	a1,(a3)+
	move.l	a2,(a4)+
prep3	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,6(a1)
	not.w	d0
	or.w	d0,6(a2)
	swap	d0
	or.w	d0,(a1)
	not.w	d0
	or.w	d0,(a2)
bp2	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,8(a1)
	not.w	d0
	or.w	d0,8(a2)
	swap	d0
	or.w	d0,2(a1)
	not.w	d0
	or.w	d0,2(a2)
bp3	moveq	#0,d0
	move.w	(a0)+,d0
	swap	d0
	lsr.l	d4,d0
	or.w	d0,10(a1)
	not.w	d0
	or.w	d0,10(a2)
	swap	d0
	or.w	d0,4(a1)
	not.w	d0
	or.w	d0,4(a2)
	add.l	#12,a1
	add.l	#12,a2
	dbf	d6,prep3
	addq.w	#1,d4
	dbf	d7,prep2
	rts

pos05a	dc.w	4*0
pos05b	dc.w	4*30
pos05c	dc.w	4*23
pos05d	dc.w	4*12
pos05e	dc.w	4*65
pos05f	dc.w	4*41
pos05g	dc.w	4*76
pos05h	dc.w	4*5
pos05i	dc.w	4*20
pos05j	dc.w	4*33
pos05k	dc.w	4*88
pos05l	dc.w	4*60

pos08a	dc.w	4*20
pos08b	dc.w	4*0
pos08c	dc.w	4*36
pos08d	dc.w	4*12
pos08e	dc.w	4*6
pos08f	dc.w	4*9
pos08g	dc.w	4*40
pos08h	dc.w	4*27
pos08i	dc.w	4*56

pos10a	dc.w	0
pos10b	dc.w	172
pos10c	dc.w	68
pos10d	dc.w	236
pos10e	dc.w	120
pos10f	dc.w	16
pos10g	dc.w	172

adr10	ds.l	32
adr08	ds.l	32
adr05	ds.l	32
	ds.l	1
pkt05	
	dc.w	1640,0
	dc.w	1640,2
	dc.w	1640,4
	dc.w	1640,6
	dc.w	1640,8
	dc.w	1640,10
	dc.w	1640,12
	dc.w	1640,14
	dc.w	1648,0
	dc.w	1648,2
	dc.w	1648,4
	dc.w	1648,6
	dc.w	1648,8
	dc.w	1648,10
	dc.w	1648,12
	dc.w	1648,14
	dc.w	1656,0
	dc.w	1656,2
	dc.w	1656,4
	dc.w	1656,6
	dc.w	1656,8
	dc.w	1656,10
	dc.w	1656,12
	dc.w	1656,14
	dc.w	1664,0
	dc.w	1664,2
	dc.w	1664,4
	dc.w	1664,6
	dc.w	1664,8
	dc.w	1664,10
	dc.w	1664,12
	dc.w	1664,14
	dc.w	1672,0
	dc.w	1672,2
	dc.w	1672,4
	dc.w	1672,6
	dc.w	1672,8
	dc.w	1672,10
	dc.w	1672,12
	dc.w	1672,14
	dc.w	1680,0
	dc.w	1680,2
	dc.w	1680,4
	dc.w	1680,6
	dc.w	1680,8
	dc.w	1680,10
	dc.w	1680,12
	dc.w	1680,14
	dc.w	1688,0
	dc.w	1688,2
	dc.w	1688,4
	dc.w	1688,6
	dc.w	1688,8
	dc.w	1688,10
	dc.w	1688,12
	dc.w	1688,14
	dc.w	1696,0
	dc.w	1696,2
	dc.w	1696,4
	dc.w	1696,6
	dc.w	1696,8
	dc.w	1696,10
	dc.w	1696,12
	dc.w	1696,14
	dc.w	1704,0
	dc.w	1704,2
	dc.w	1704,4
	dc.w	1704,6
	dc.w	1704,8
	dc.w	1704,10
	dc.w	1704,12
	dc.w	1704,14
	dc.l	-1,0
pkt08

	dc.w	1624,2
	dc.w	1624,5
	dc.w	1624,8
	dc.w	1624,11
	dc.w	1624,14
	dc.w	1632,1
	dc.w	1632,4
	dc.w	1632,7
	dc.w	1632,10
	dc.w	1632,13
	dc.w	1640,0
	dc.w	1640,3
	dc.w	1640,6
	dc.w	1640,9
	dc.w	1640,12
	dc.w	1640,15
	dc.w	1648,2
	dc.w	1648,5
	dc.w	1648,8
	dc.w	1648,11
	dc.w	1648,14
	dc.w	1656,1
	dc.w	1656,4
	dc.w	1656,7
	dc.w	1656,10
	dc.w	1656,13
	dc.w	1664,0
	dc.w	1664,3
	dc.w	1664,6
	dc.w	1664,9
	dc.w	1664,12
	dc.w	1664,15
	dc.w	1672,2
	dc.w	1672,5
	dc.w	1672,8
	dc.w	1672,11
	dc.w	1672,14
	dc.w	1680,1
	dc.w	1680,4
	dc.w	1680,7
	dc.w	1680,10
	dc.w	1680,13
	dc.w	1688,0
	dc.w	1688,3
	dc.w	1688,6
	dc.w	1688,9
	dc.w	1688,12
	dc.w	1688,15
	dc.w	1696,2
	dc.w	1696,5
	dc.w	1696,8
	dc.w	1696,11
	dc.w	1796,14
	dc.w	1704,1
	dc.w	1704,4
	dc.w	1704,7
	dc.w	1704,10
	dc.w	1704,13
	dc.w	1712,0
	dc.w	1712,3
	dc.w	1712,6
	dc.w	1712,9
	dc.w	1712,12
	dc.w	1712,15
	
	dc.l	-1,0
pkt10	
	dc.w	00,0
	dc.w	00,4
	dc.w	00,8
	dc.w	00,12
	dc.w	08,0
	dc.w	08,4
	dc.w	08,8
	dc.w	08,12
	dc.w	16,0
	dc.w	16,4
	dc.w	16,8
	dc.w	16,12
	dc.w	24,0
	dc.w	24,4
	dc.w	24,8
	dc.w	24,12
	dc.w	32,0
	dc.w	32,4
	dc.w	32,8
	dc.w	32,12
	dc.w	40,0
	dc.w	40,4
	dc.w	40,8
	dc.w	40,12
	dc.w	48,0
	dc.w	48,4
	dc.w	48,8
	dc.w	48,12
	dc.w	56,0
	dc.w	56,4
	dc.w	56,8
	dc.w	56,12
	dc.w	64,0
	dc.w	64,4
	dc.w	64,8
	dc.w	64,12
	dc.w	72,0
	dc.w	72,4
	dc.w	72,8
	dc.w	72,12
	dc.w	80,0
	dc.w	80,4
	dc.w	80,8
	dc.w	80,12
	dc.w	88,0
	dc.w	88,4
	dc.w	88,8
	dc.w	88,12
	dc.w	96,0
	dc.w	96,4
	dc.w	96,8
	dc.w	96,12
	dc.w	104,0
	dc.w	104,4
	dc.w	104,8
	dc.w	104,12
	dc.w	112,0
	dc.w	112,4
	dc.w	112,8
	dc.w	112,12
	dc.w	120,0
	dc.w	120,4
	dc.w	120,8
	dc.w	120,12
	dc.w	128,0
	dc.w	128,4
	dc.w	128,8
	dc.w	128,12
	dc.w	136,0
	dc.w	136,4
	dc.w	136,8
	dc.w	136,12
	dc.w	144,0
	dc.w	144,4
	dc.w	144,8
	dc.w	144,12
	dc.l	-1,0
pal	
	dc.w	$000,$300,$400,$510,$620,$730,$740,$752
	dc.w	$000,$020,$030,$040,$051,$062,$073,$777
ball10	dc.w	$1200,$0C00,$0000
	dc.w	$0600,$3F00,$0000
	dc.w	$0F00,$7180,$0E00
	dc.w	$8FC0,$7880,$0700
	dc.w	$7E80,$FEC0,$0100
	dc.w	$0600,$87C0,$7800
	dc.w	$FA40,$0380,$7C00
	dc.w	$3A00,$4380,$3C00
	dc.w	$1A00,$2300,$1C00
	dc.w	$1200,$0C00,$0000
ball08	dc.w	$1800,$0000,$0000
	dc.w	$0800,$3C00,$0000
	dc.w	$0C00,$7200,$0C00
	dc.w	$9F00,$5A00,$2400
	dc.w	$B900,$0E00,$7000
	dc.w	$3000,$4600,$3800
	dc.w	$0800,$3C00,$0000
	dc.w	$1800,$0000,$0000
ball05	dc.w	$5000,$2000,$0000
	dc.w	$B800,$5000,$2000
	dc.w	$5000,$E800,$1000
	dc.w	$E800,$7000,$0000
	dc.w	$5000,$2000,$0000
new	ds.l	1