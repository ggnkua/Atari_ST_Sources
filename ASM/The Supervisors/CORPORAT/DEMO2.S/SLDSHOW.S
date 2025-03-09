;
;                                 *      *      *
;
;         SOURCE CODE OF SPECTRUM 512 SLIDESHOW      version 1.0
;      ONLY FOR ADVANCED PROGRAMMERS (because it is not documented).
;      ALL PROGRAMMING,INCLUDING MUSIC COMPOSING BY RALPH RUDZKI.
;           ALL GRAPHICS AND COLOURS BY JACK STRZAœKOWSKI.
;
;             our address:
;                                THE SUPERVISORS
;                              UL.SUCHARSKIEGO 3/16
;                                01-390 WARSZAWA
;                                     POLAND
;
;                                 *      *      *
;

	dc.w	$a00a
	pea	mystack
	move.w	#32,-(a7)
	trap	#1
	lea	6(a7),a7
	move.w	#$2700,sr

	move.l	#$70000,$ffff8200.w
	move.b	#0,$ffff820d.w
	move.b	#1,$fffffa07.w
	clr.b	$fffffa09.w
	move.b	#1,$fffffa13.w
	move.b	#$12,$fffffc02.w
	move.l	#nodisplay,$70.w
	move.l	#raster1,$120.w
	move.l	#aga1,$404.w
	lea	$70000,a0
	lea	$80000,a1
clr:	clr.l	(a0)+
	cmp.l	a1,a0
	bmi	clr

	move.b	#2,$ffff8260.w
	move.w	#$2700,d0
ad0:	move.w	#$00cd,d1
ad1:	dbf	d1,ad1
	dbf	d0,ad0

	move.w	#$2300,sr

	moveq	#8,d6
	moveq	#0,d7
st3:	bsr	col
	addq.w	#1,d7
	dbf	d6,st3

	pea	dta
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7
	clr.w	-(a7)
	pea	fname
	move.w	#$4e,-(a7)
	trap	#1
	add.l	#8,a7

ania:	move.l	#buffer,lof+2
	move.l	#buffer,point+2
	moveq	#5,d7
aga2:	bsr	load
point:	lea	buffer,a0
	bsr	decrunch
	add.l	#51104,lof+2
	add.l	#51104,point+2
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	tst.w	d0
	beq	aga0
	clr.w	-(a7)
	pea	fname
	move.w	#$4e,-(a7)
	trap	#1
	add.l	#8,a7
aga0:	dbf	d7,aga2

	moveq	#8,d6
	moveq	#8,d7
st1:	bsr	col
	subq.w	#1,d7
	dbf	d6,st1

	clr.b	$fffffa13.w
	move.l	#display,$70.w
	lea	$70000,a0
	add.l	#1280*8,a0
	move.w	#639,d0
	moveq	#0,d7
cls:	move.l	d7,(a0)+
	dbf	d0,cls

	clr.l	mi+2
	clr.l	ma+2
	clr.l	szw+2
	clr.l	grz+2
	moveq	#5,d7
agd:	lea	buffer+160*196,a0
mi:	add.l	#0,a0
	lea	$70000+160*196,a1
	lea	buffer+32000+96*197,a2
ma:	add.l	#0,a2
	lea	$7b000+96*197,a3
	move.l	a0,d2
	move.l	a1,d3
	move.l	a2,d4
	move.l	a3,d5
	lea	buffer+160,a0
szw:	add.l	#0,a0
	lea	$70000+160,a1
	lea	buffer+32000,a2
grz:	add.l	#0,a2
	lea	$7b000,a3
	move.w	#98,d0
copy1:	stop	#$2300
	move.w	#39,d1
copy2:	move.l	(a0)+,(a1)+
	dbf	d1,copy2
	lea	160(a0),a0
	lea	160(a1),a1
	move.w	#23,d1
copy3:	move.l	(a2)+,(a3)+
	dbf	d1,copy3
	lea	96(a2),a2
	lea	96(a3),a3
	exg.l	a0,d2
	exg.l	a1,d3
	exg.l	a2,d4
	exg.l	a3,d5
	move.w	#39,d1
copy22:	move.l	(a0)+,(a1)+
	dbf	d1,copy22
	lea	-480(a0),a0
	lea	-480(a1),a1
	move.w	#23,d1
copy33:	move.l	(a2)+,(a3)+
	dbf	d1,copy33
	lea	-288(a2),a2
	lea	-288(a3),a3
	exg.l	a0,d2
	exg.l	a1,d3
	exg.l	a2,d4
	exg.l	a3,d5
	dbf	d0,copy1

loop:	stop	#$2300
	cmp.b	#$39,$fffffc02.w
	bne	loop

	add.l	#51104,mi+2
	add.l	#51104,ma+2
	add.l	#51104,szw+2
	add.l	#51104,grz+2
	dbf	d7,agd

	lea	$70000+160*196,a0
	lea	$7b000+96*197,a1
	lea	$70000+160,a2
	lea	$7b000,a3
	moveq	#0,d7
	move.w	#98,d0
copy4:	stop	#$2300
	move.w	#39,d1
copy5:	move.l	d7,(a2)+
	dbf	d1,copy5
	lea	160(a2),a2
	move.w	#23,d1
copy6:	move.l	d7,(a3)+
	dbf	d1,copy6
	lea	96(a3),a3
	move.w	#39,d1
copy44:	move.l	d7,(a0)+
	dbf	d1,copy44
	lea	-480(a0),a0
	move.w	#23,d1
copy55:	move.l	d7,(a1)+
	dbf	d1,copy55
	lea	-288(a1),a1
	dbf	d0,copy4
	move.l	#nodisplay,$70.w
	move.b	#1,$fffffa13.w

	moveq	#8,d6
	moveq	#0,d7
st2:	bsr	col
	addq.w	#1,d7
	dbf	d6,st2
	bra	ania

col:	moveq	#5,d0
while:	bsr	frame
	dbf	d0,while
	lea	fonts+2,a0
	lea	tab,a1
	moveq	#15,d0
mod:	move.w	(a0)+,d1
	move.w	d1,d2
	move.w	d2,d3
	lsr.w	#8,d1
	lsr.w	#4,d2
	and.w	#7,d1
	and.w	#7,d2
	and.w	#7,d3
	mulu	d7,d1
	lsr.w	#3,d1
	mulu	d7,d2
	lsr.w	#3,d2
	mulu	d7,d3
	lsr.w	#3,d3
	lsl.w	#8,d1
	lsl.w	#4,d2
	or.w	d1,d3
	or.w	d2,d3
	move.w	d3,(a1)+
	dbf	d0,mod

	lea	tab2,a0
	lea	tab1,a1
	moveq	#6,d0
doc:	move.w	(a0)+,d1
	move.w	d1,d2
	move.w	d2,d3
	lsr.w	#8,d1
	lsr.w	#4,d2
	and.w	#7,d1
	and.w	#7,d2
	and.w	#7,d3
	mulu	d7,d1
	lsr.w	#3,d1
	mulu	d7,d2
	lsr.w	#3,d2
	mulu	d7,d3
	lsr.w	#3,d3
	lsl.w	#8,d1
	lsl.w	#4,d2
	or.w	d1,d3
	or.w	d2,d3
	move.w	d3,(a1)+
	dbf	d0,doc
	rts

frame:	tst.w	vbl
	beq	frame
	clr.w	vbl
aga1:	rts

tab:	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000

tab1:	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000000
tab2:	dc.l	$00010002
	dc.l	$00030004
	dc.l	$00050006
	dc.l	$00070000

raster1:
	move.w	tab1,$ffff8240.w
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#raster2,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster2:
	move.w	tab1+2,$ffff8240.w
	move.b	#1,$fffffa21.w
	move.l	#raster3,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster3:
	move.w	tab1+4,$ffff8240.w
	move.b	#1,$fffffa21.w
	move.l	#raster4,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster4:
	move.w	tab1+6,$ffff8240.w
	move.b	#1,$fffffa21.w
	move.l	#raster5,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster5:
	move.w	tab1+8,$ffff8240.w
	move.b	#1,$fffffa21.w
	move.l	#raster6,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster6:
	move.w	tab1+10,$ffff8240.w
	move.b	#1,$fffffa21.w
	move.l	#raster7,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster7:
	move.w	tab1+12,$ffff8240.w
	move.b	#1,$fffffa21.w
	move.l	#raster8,$120.w
	bclr	#0,$fffffa0f.w
	rte
raster8:
	clr.w	$ffff8240.w
	clr.b	$fffffa1b.w
	st	$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#raster1,$120.w
	bclr	#0,$fffffa0f.w
	rte

vbl:	dc.w	0

nodisplay:
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	move.w	#1,vbl
	clr.b	$fffffa1b.w
	move.b	#78,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(a7)
	lea	tab,a0
	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	tst.w	handy
	beq	nomusak
	bsr	muzak+$98
nomusak:cmp.b	#62,$fffffc02.w
	bne	nof4
	clr.w	handy
	move.l	#$08080000,$ffff8840.w
	move.l	#$09090000,$ffff8840.w
	move.l	#$0a0a0000,$ffff8840.w
nof4:	cmp.b	#63,$fffffc02.w
	bne	nof5
	move.w	#1,handy
nof5:	bsr	ste
	bsr	pw
	movem.l	(a7)+,d0-d7/a0-a6
	rte

handle:	dc.w	0
handy:	dc.w	1
reset:	dc.l	0

display:
	movem.l	d0-d7/a0-a6,-(a7)
	lea	$7b000,a0
	lea	$ffff8240.w,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	bsr	scroll
	tst.w	handle
	beq	nospeed
	bsr	scroll
nospeed:
	tst.w	handy
	beq	nomuzak
	bsr	muzak+$98
nomuzak:
	cmp.b	#59,$fffffc02.w
	bne	nof1
	clr.w	handle
nof1:	cmp.b	#60,$fffffc02.w
	bne	nof2
	move.w	#1,handle
nof2:	cmp.b	#61,$fffffc02.w
	bne	nof3
	move.w	#2,handle
nof3:	cmp.b	#62,$fffffc02.w
	bne	nofu4
	clr.w	handy
	move.l	#$08080000,$ffff8840.w
	move.l	#$09090000,$ffff8840.w
	move.l	#$0a0a0000,$ffff8840.w
nofu4:	cmp.b	#63,$fffffc02.w
	bne	nofu5
	move.w	#1,handy
nofu5:
	lea	$7b020,a0
	lea	$ffff8240.w,a1
	lea	corr,a6
	move.w	#197,d0
	moveq	#0,d6
wait:	tst.b	$ffff8209.w
	beq	wait
	move.b	$ffff8209.w,d6
	add.l	d6,a6
	jmp	(a6)
corr:	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
rep:	nop
	nop
	lea	(a1),a2
	lea	(a1),a3
	lea	(a1),a4
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a3)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	move.l	(a0)+,(a4)+
	dbf	d0,rep

	move.l	#$00000707,$ffff8240.w
	move.l	#$07750773,$ffff8244.w
	move.l	#$07710760,$ffff8248.w
	move.l	#$06500540,$ffff824c.w
	move.l	#$00000000,$ffff8250.w
	move.l	#$00000000,$ffff8254.w
	move.l	#$00000000,$ffff8258.w
	move.l	#$00000000,$ffff825c.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	#0,$ffff820a.w
	nop
	nop
	nop
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.w	#7,d0
ad:	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	#0,$ffff820a.w
	move.b	#2,$ffff820a.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dbf	d0,ad
	move.b	#2,$ffff8260.w
	nop
	move.b	#0,$ffff8260.w
	cmp.w	#2,handle
	bne	sf	
	bsr	scroll
sf:	bsr	ste
	movem.l	(a7)+,d0-d7/a0-a6
	rte

load:	move.w	#2,-(a7)
	pea	dta+30
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.w	d0,close+2
lof:	pea	buffer
	pea	51104
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	add.l	#12,a7
close:	move.w	#0,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

pnt:	dc.w	0
pix:	dc.w	7
scroll:	lea	$70000,a0
	add.l	#32000,a0
	lea	(a0),a1
	moveq	#7,d1
loop1:	roxl.w	216(a1)
	roxl.w	208(a1)
	roxl.w	200(a1)
	roxl.w	192(a1)
	roxl.w	184(a1)
	roxl.w	176(a1)
	roxl.w	168(a1)
	roxl.w	160(a1)
	roxl.w	152(a1)
	roxl.w	144(a1)
	roxl.w	136(a1)
	roxl.w	128(a1)
	roxl.w	120(a1)
	roxl.w	112(a1)
	roxl.w	104(a1)
	roxl.w	96(a1)
	roxl.w	88(a1)
	roxl.w	80(a1)
	roxl.w	72(a1)
	roxl.w	64(a1)
	roxl.w	56(a1)
	roxl.w	48(a1)
	roxl.w	40(a1)
	roxl.w	32(a1)
	roxl.w	24(a1)
	roxl.w	16(a1)
	roxl.w	8(a1)
	roxl.w	(a1)
	lea	230(a1),a1
	dbf	d1,loop1
	lea	2(a0),a1
	moveq	#7,d1
loop2:	roxl.w	216(a1)
	roxl.w	208(a1)
	roxl.w	200(a1)
	roxl.w	192(a1)
	roxl.w	184(a1)
	roxl.w	176(a1)
	roxl.w	168(a1)
	roxl.w	160(a1)
	roxl.w	152(a1)
	roxl.w	144(a1)
	roxl.w	136(a1)
	roxl.w	128(a1)
	roxl.w	120(a1)
	roxl.w	112(a1)
	roxl.w	104(a1)
	roxl.w	96(a1)
	roxl.w	88(a1)
	roxl.w	80(a1)
	roxl.w	72(a1)
	roxl.w	64(a1)
	roxl.w	56(a1)
	roxl.w	48(a1)
	roxl.w	40(a1)
	roxl.w	32(a1)
	roxl.w	24(a1)
	roxl.w	16(a1)
	roxl.w	8(a1)
	roxl.w	(a1)
	lea	230(a1),a1
	dbf	d1,loop2
	lea	4(a0),a1
	moveq	#7,d1
loop3:	roxl.w	216(a1)
	roxl.w	208(a1)
	roxl.w	200(a1)
	roxl.w	192(a1)
	roxl.w	184(a1)
	roxl.w	176(a1)
	roxl.w	168(a1)
	roxl.w	160(a1)
	roxl.w	152(a1)
	roxl.w	144(a1)
	roxl.w	136(a1)
	roxl.w	128(a1)
	roxl.w	120(a1)
	roxl.w	112(a1)
	roxl.w	104(a1)
	roxl.w	96(a1)
	roxl.w	88(a1)
	roxl.w	80(a1)
	roxl.w	72(a1)
	roxl.w	64(a1)
	roxl.w	56(a1)
	roxl.w	48(a1)
	roxl.w	40(a1)
	roxl.w	32(a1)
	roxl.w	24(a1)
	roxl.w	16(a1)
	roxl.w	8(a1)
	roxl.w	(a1)
	lea	230(a1),a1
	dbf	d1,loop3
	lea	tex,a0
	move.w	pnt,d0
	moveq	#0,d1
	move.b	0(a0,d0.w),d1
	move.l	d1,d0
	divu	#40,d0
	move.w	d0,d2
	mulu	#1280,d0
	mulu	#40,d2
	sub.w	d2,d1
	move.w	d1,d2
	lsr.w	#1,d1
	mulu	#8,d1
	and.w	#1,d2	
	lea	$70000,a0
	add.l	#32216,a0
	lea	fonts+34,a2
	adda.w	d0,a2
	adda.w	d1,a2
	adda.w	d2,a2
	move.w	pix,d1

	lea	(a0),a1
	lea	(a2),a3
	moveq	#7,d0
do1:	move.b	(a1),d3
	and.b	#$fe,d3
	move.b	(a3),d2
	lsr.b	d1,d2
	and.b	#$01,d2
	or.b	d2,d3
	move.b	d3,(a1)
	lea	160(a3),a3
	lea	230(a1),a1
	dbf	d0,do1
	lea	2(a0),a1
	lea	2(a2),a3
	moveq	#7,d0
do2:	move.b	(a1),d3
	and.b	#$fe,d3
	move.b	(a3),d2
	lsr.b	d1,d2
	and.b	#$01,d2
	or.b	d2,d3
	move.b	d3,(a1)
	lea	160(a3),a3
	lea	230(a1),a1
	dbf	d0,do2
	lea	4(a0),a1
	lea	4(a2),a3
	moveq	#7,d0
do3:	move.b	(a1),d3
	and.b	#$fe,d3
	move.b	(a3),d2
	lsr.b	d1,d2
	and.b	#$01,d2
	or.b	d2,d3
	move.b	d3,(a1)
	lea	160(a3),a3
	lea	230(a1),a1
	dbf	d0,do3
	sub.w	#1,pix
	cmp.w	#-1,pix
	bne	same
	move.w	#7,pix
	add.w	#1,pnt
	lea	tex,a0
	move.w	pnt,d0
	adda.w	d0,a0
	tst.b	(a0)
	bne	same
	clr.w	pnt
same:	rts

tex:	DC.B	'THE SUPERVISORS ARE VERY PROUD TO PRESENT THEIR LAST PRODUCTION,THIS TIME A SPECTRUM 512 SLIDESHOW.ALL PICTURES INCLUDED ON THIS DISK WERE SCANNED ON ATARI TT BY -JACK-,PAINTER OF THE SUPERVISORS.HE ALSO MADE CHARACTERS AND LOGO.'
	DC.B	'ALL CODING,MUSIC COMPOSING,THIS TEXT,PACKING AND PUTTING EVERYTHING TOGETHER WERE MADE BY -RALPH-.YOU SHOULD ALSO NOTICE,THAT OUR SPECTRUM 512-DISPLAYER WORKS AT 50HZ.WE REMEMBERED THAT SOME TV SETS ARE NOT LIKELY TO DISPLAY AT '
	DC.B	'60HZ.SO WE CORRECTED THE ROUTINE NOT THINKING OF THE AMERICAN ST USERS (ARE THERE ANY ?).   NOW A FEW WORDS ABOUT KEYBOARD.     F1,F2,F3-CONTROL THE SPEED OF THE SCROLLING TEXT   F4-SWITCHS OFF THE MUSIC   F5-SWITCHS ON THE MUSIC   '
	DC.B	'SPACEBAR-DISPLAYING THE NEXT PIECE OF GRAPHICS.    YOU CAN USE OUR PROGRAM TO DISPLAY YOUR OWN PICTURES,BUT THEY HAVE TO BE SAVED IN UNCOMPRESSED FORMAT (*.SPU).      NOW A FEW GREETINGS.       TO CAMY MAERTENS FROM -BUDGIE UK- '
	DC.B	'(I HOPE YOU WILL COPYRIGHT SOME OF OUR PRODUCTIONS),    TO -SAMMY JOE- FROM -THE LOST BOYS- (IF YOU REMEMBER US,MIKE...)    TO CHRIS H. FROM TLB MAGGIE CORRESPONDANCE  (KEEP CORRESPONDING WITH ME !!!),    TO OUR GREAT FRIENDS FROM POLAND:'
	DC.B	'     ROMAN (ACTUALLY MARRIED...  HA,HA,HA !!!)   '    
	DC.B	'SLAWEK (MANY THANKS !!! WITHOUT YOUR TT AND SCANNER THIS DEMO WOULD NOT BE COMPLETED.)    '    
	DC.B	'-PETER- FROM -QUANT- (ARE YOU STILL ALIVE,PETER ???)     -ZYP- (NO LETTERS RECENTLY ?!?)     ANDRZEJ AND HIS FRIEND (I HEARD YOUR LAST DEMOS WERE OUTSTANDING)     '
	DC.B	'  -VENTYLSOFT-    -GORSSOFT-    -KIJOP-    -IMMORTALS- (ANYWAY...)    AND ALL OTHER PEOPLE I HAVE FORGOTTEN ABOUT.            AND THAT SEEMS TO BE ALL FOR TODAY.      MAYBE YOU WOULD LIKE TO KNOW THAT NOW,IT IS 21:46,FRIDAY,08-11-91.    '
	DC.B	'        LOOK FOR SOME OTHER PRODUCTIONS MARKED BY -BUDGIE UK- OR -THE SUPERVISORS-.I AM SURE,YOU WILL NOT REGRET.           SEE YOU LATER !!!                                                                                         '
	DC.B	'                                                                                  IT IS SO LATE THAT WE SHOULD WRAP           ... ... ... ... ... ... ...................................... ... ... ... ... ... ...           ',0
	even

ste:	cmp.b	#29,$fffffc02.w
	bne	no1
	st	reset+1
no1:	cmp.b	#157,$fffffc02.w
	bne	no2
	clr.b	reset+1
no2:	cmp.b	#56,$fffffc02.w
	bne	no3
	st	reset+2
no3:	cmp.b	#184,$fffffc02.w
	bne	no4
	clr.b	reset+2
no4:	cmp.b	#83,$fffffc02.w
	bne	no5
	st	reset+3
no5:	cmp.b	#211,$fffffc02.w
	bne	no6
	clr.b	reset+3
no6:	cmp.l	#$ffffff,reset
	bne	ok
	move.l	$4.w,a0
	jmp	(a0)
ok:	rts

place:	dc.w	0
string:	dc.w	80,85,89,92,94,96,97,98,99,99,99,98,97,96,94,92,89,85
	dc.w	80,75,71,68,66,64,63,62,61,61,61,62,63,64,66,68,71,75
	dc.w	80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,80,81,81
	dc.w	82,83,84,85,86,88,91,95,100,105,110,115,120,125,130,135,140,145
	dc.w	149,153,156,159,162,164,166,168,170,171,172,173,174,174,174,173
	dc.w	172,170,168,166,164,162,160,158,156,154,152,150,148,146,144,142
	dc.w	140,138,136,134,132,130,128,126,124,122,120,118,116,114,112,110
	dc.w	108,106,104,102,100,98,96,94,92,90,88,86,84,82,80,77,74,70
	dc.w	65,60,55,50,45,40,35,30,25,20,16,13,11,9,8,7,6,5,4,3,2,1,0
	dc.w	0,1,3,6,10,15,20,25,30,35,40,45,50,55,60,65,70,75

	dc.w	80,85,89,92,94,96,97,98,99,99,99,98,97,96,94,92,89,85	

pw:	lea	$70000,a0
	add.l	#1280*8,a0
	lea	fonts+34,a1
	add.l	#1280*8,a1
	lea	string,a4
	move.w	place,d4
	lsl.w	#1,d4
	adda.w	d4,a4
	moveq	#15,d0
aga5:	lea	(a0),a2
	lea	(a1),a3
	move.w	(a4)+,d1
	move.w	d1,d2
	move.w	d2,d3
	and.w	#$f,d1
	and.w	#1,d2
	lsr.w	#4,d3
	lsr.w	#1,d1
	mulu	#2560,d1
	mulu	#80,d2
	mulu	#8,d3
	adda.w	d1,a3
	adda.w	d2,a3
	adda.w	d3,a2

	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	lea	160(a1),a1
	lea	160(a0),a0
	dbf	d0,aga5
	add.w	#1,place
	cmp.w	#180,place
	bne	nol
	clr.w	place
nol:	rts

;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
decrunch:	movem.l d0-a6,-(sp)		; save registers
		cmpi.l	#'Ice!',(a0)+		; Data packed?
		bne.s	ice2_07			; no!
		move.l	(a0)+,d0
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			; save 120 bytes
		lea	ice2_21+120(pc),a2	; at the end of the
		moveq	#$77,d0			; unpacked data
ice2_00:	move.b	-(a1),-(a2)
		dbra	d0,ice2_00
		bsr	ice2_0c
		bsr.s	ice2_08
		bsr	ice2_10		;; Picture decrunch!
		bcc.s	ice2_04		;; These marked lines are only
		movea.l a3,a1		;; necessary, if you selected the
		move.w	#$0f9f,d7	;; additional picture packer
ice2_01:	moveq	#3,d6		;; in Pack-Ice.
ice2_02:	move.w	-(a1),d4	;;
		moveq	#3,d5		;; If you never use the picture
ice2_03:	add.w	d4,d4		;; pack option, you may delete
		addx.w	d0,d0		;; all the lines marked with ";;"
		add.w	d4,d4		;;
		addx.w	d1,d1		;;
		add.w	d4,d4		;;
		addx.w	d2,d2		;;
		add.w	d4,d4		;;
		addx.w	d3,d3		;;
		dbra	d5,ice2_03	;;
		dbra	d6,ice2_02	;;
		movem.w d0-d3,(a1)	;;
		dbra	d7,ice2_01	;;
ice2_04:	move.l	(sp),d0			; move all data to
		lea	-120(a4),a1		; 120 bytes lower
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0			; restore saved data
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	movem.l (sp)+,d0-a6		; restore registers
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr.s	ice2_13
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		dbra	d1,ice2_0a
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60			; free space (can be put in BSS)
	
muzak:	incbin	a:\demo2.s\sldshow.mux
fonts:	incbin	a:\demo2.s\sldshow.pi1

fname:	dc.b	'*.spu',0
	even
dta:	ds.l	11
	ds.l	100
mystack:
	ds.l	100
buffer:
