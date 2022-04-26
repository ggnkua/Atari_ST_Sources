***************************************************************************
*		Guest screen to Even Worse by OB of Anatomica		  *
***************************************************************************
	jsr	setsuper
	jsr	setscreen
	jsr	gubbe
	jsr	prerotate
	jsr	prerotateob

	move.l	$70.w,oldvbl
	move.l	$114.w,old114

*	-------> F„rg interuptet
	lea	vps,a0
	move.b	#54,(a0)
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	clr.b	$fffa1b
	and.b	#$df,$fffa09
	lea	obpal,a0
	move.l	a0,$120
	bset	#0,$fffa07
	bset	#0,$fffa13
	move.b	#0,$fffa21
	move.b	#8,$fffa1b

	lea 6(sp),sp				
	move.l d0,stack
	bclr #0,$484.w				

*	-------------> Musiken skall p†
	LEA	zak,A0
	LEA	$6fe28,A1
	MOVE.L	#zakend-zak,D0
musloop	MOVE.B	(A0)+,(A1)+
	DBF	D0,musloop

	jsr	$6fe28
	move.l	#vbl,$70.w

	move.w	#$566,$ff8252
	move.w	#$455,$ff8254
	move.w	#$344,$ff8256
	move.w	#$233,$ff8258
	move.w	#$122,$ff825a
	move.w	#$011,$ff825c
	move.w	#$777,$ff825e
	move.w	#$777,$ff8250

	move.w	#0,d2

	move.w	#2,bok_ptr

	move.w	#2,$ff8240

	move.l	#str„ng,-(sp)	; St„ng av all trafik mellan CPU och tangetbords chip
	move.w	#0,-(sp)
	move.w	#25,-(sp)
*	trap	#14
	addq.l	#8,sp

***************************************************************************
mainloop:
	jsr	waitvbl

*	cmp.b	#185,$fffc02.l
*	beq	end
*	-------------> Bakgrunds disten

	addq.w	#8,distmove	; distens snabbhet
	cmp.w	#719,distmove
	ble	nosinwrap
	move.w	#0,distmove
nosinwrap:
	move.w	#79,d0		;h”jd p† dist i yled
	clr.w	d5
	move.w	ymove,d4
	addq.w	#1,ymove
	cmp.w	#16,ymove
	bne	ymovech
	move.w	#0,ymove
ymovech:
	move.l	#$85c80,a1
	move.l	#back+17034,a0
	move.w	d4,d6
	mulu	#64,d6
	add.w	d6,a0
loop:
	move.l	#sin+1,a2
	add.w	distmove,a2
	addq	#4,d5		; b”jdhet (vackert ord !!!)
	add.w	d5,a2
	move.w	(a2),d3
	add.w	d3,a0
	move.l	(a0),d1

	move.l	d1,2(a1)
	move.l	d1,10(a1)
	move.l	d1,18(a1)
	move.l	d1,26(a1)
	move.l	d1,34(a1)
	move.l	d1,42(a1)
	move.l	d1,50(a1)
	move.l	d1,58(a1)
	move.l	d1,66(a1)
	move.l	d1,74(a1)
	move.l	d1,82(a1)
	move.l	d1,90(a1)
	move.l	d1,98(a1)
	move.l	d1,106(a1)
	move.l	d1,114(a1)
	move.l	d1,122(a1)
	move.l	d1,130(a1)
	move.l	d1,138(a1)
	move.l	d1,146(a1)
	move.l	d1,154(a1)
	sub.w	d3,a0

	add.w	#64,a0
	add.w	#160,a1
	addq.w	#1,d4
	cmp.w	#16,d4
	bne	nobrickwrap
	clr.w	d4
	move.l	#back+17034,a0
nobrickwrap:
	dbf.w	d0,loop

*	-------------> Byte bendern

	move.l	#$346a0,a2

	clr.w	d1
	clr.w	d2
	move.w	#19,d0
	move.l	#bend,a3

scroll:
	move.l	a2,a0
	move.l	a2,a1
	move.l	a2,a4
	move.l	a2,a5

	add.w	#4,a3	; B”jningen
	add.w	2(a3),a0
	add.w	0(a3),a1
	add.w	4(a3),a4
	add.w	2(a3),a5

	add.w	d1,a0
	add.w	d1,a1
	add.w	d1,a4
	add.w	d1,a5

	move.b	648(a4),641(a5)
	move.b	801(a0),800(a1)
	move.b	808(a4),801(a5)
	move.b	961(a0),960(a1)
	move.b	968(a4),961(a5)
	move.b	1121(a0),1120(a1)
	move.b	1128(a4),1121(a5)
	move.b	1281(a0),1280(a1)
	move.b	1288(a4),1281(a5)
	move.b	1441(a0),1440(a1)
	move.b	1448(a4),1441(a5)
	move.b	1601(a0),1600(a1)
	move.b	1608(a4),1601(a5)
	move.b	1761(a0),1760(a1)
	move.b	1768(a4),1761(a5)
	move.b	1921(a0),1920(a1)
	move.b	1928(a4),1921(a5)
	move.b	2081(a0),2080(a1)
	move.b	2088(a4),2081(a5)
	move.b	2241(a0),2240(a1)
	move.b	2248(a4),2241(a5)
	move.b	2401(a0),2400(a1)
	move.b	2408(a4),2401(a5)
	move.b	2561(a0),2560(a1)
	move.b	2568(a4),2561(a5)
	move.b	2721(a0),2720(a1)
	move.b	2728(a4),2721(a5)
	move.b	2881(a0),2880(a1)
	move.b	2888(a4),2881(a5)
	move.b	3041(a0),3040(a1)
	move.b	3048(a4),3041(a5)
	move.b	3201(a0),3200(a1)
	move.b	3208(a4),3201(a5)
	move.b	3361(a0),3360(a1)
	move.b	3368(a4),3361(a5)
	move.b	3521(a0),3520(a1)
	move.b	3528(a4),3521(a5)
	move.b	3681(a0),3680(a1)
	move.b	3688(a4),3681(a5)
	move.b	3841(a0),3840(a1)
	move.b	3848(a4),3841(a5)
	move.b	4001(a0),4000(a1)
	move.b	4008(a4),4001(a5)
	move.b	4161(a0),4160(a1)
	move.b	4168(a4),4161(a5)
	move.b	4321(a0),4320(a1)
	move.b	4328(a4),4321(a5)

	addq.w	#8,d1

	dbf.w	d0,scroll

	addq.w	#1,bok_ptr
	cmp.w	#4,bok_ptr
	bne	ickebok”
	move.w	#0,bok_ptr
	addq.w	#1,bokstav
	cmp.w	#2454,bokstav	; l„ngd of scroller (tecken)
	bne	ickebok”
	move.w	#1,bokstav
ickebok”:
	move.l	#text,a0
	move.w	bokstav,d0
	add.w	d0,a0
	move.w	#0,d0
	move.b	(a0),d0
	cmp.w	#32,d0
	bne	ickespace
	move.w	#100,d0
ickespace:
	sub.w	#65,d0
	mulu	#128,d0
	move.l	#font,a0
	add.w	d0,a0
	add.w	bok_ptr,a0

	move.l	a2,a1
	move.l	#bend,a3
	add.w	#0,a3
	add.w	82(a3),a1
	add.w	#153,a1

	move.b	16(a0),640(a1)
	move.b	20(a0),800(a1)
	move.b	24(a0),960(a1)
	move.b	28(a0),1120(a1)
	move.b	32(a0),1280(a1)	
	move.b	36(a0),1440(a1)
	move.b	40(a0),1600(a1)
	move.b	44(a0),1760(a1)
	move.b	48(a0),1920(a1)
	move.b	52(a0),2080(a1)
	move.b	56(a0),2240(a1)
	move.b	60(a0),2400(a1)
	move.b	64(a0),2560(a1)
	move.b	68(a0),2720(a1)
	move.b	72(a0),2880(a1)
	move.b	76(a0),3040(a1)	
	move.b	80(a0),3200(a1)
	move.b	84(a0),3360(a1)
	move.b	88(a0),3520(a1)
	move.b	92(a0),3680(a1)
	move.b	96(a0),3840(a1)
	move.b	100(a0),4000(a1)
	move.b	104(a0),4160(a1)
	move.b	108(a0),4320(a1)
	move.b	112(a0),4480(a1)

*	---------------> Vu meters

	move.l	#$843a6,a0
	move.w	#$ffff,d2
	move.w	#$0,d3

	clr.l	d0
	move.b	#8,$ff8800
	move.b	$ff8800,d0
	move.w	#17,d1
	sub.w	d0,d1
erasevu1:
	move.w	d3,(a0)
	move.w	d3,8(a0)
	move.w	d3,16(a0)
	add.w	#320,a0
	dbf.w	d1,erasevu1
drawvu1:
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	add.w	#320,a0
	dbf.w	d0,drawvu1

	move.l	#$843c6,a0

	clr.w	d0
	move.b	#9,$ff8800
	move.b	$ff8800,d0
	move.w	#17,d1
	sub.w	d0,d1
erasevu2:
	move.w	d3,(a0)
	move.w	d3,8(a0)
	move.w	d3,16(a0)
	add.w	#320,a0
	dbf.w	d1,erasevu2
drawvu2:
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	add.w	#320,a0
	dbf.w	d0,drawvu2

	move.l	#$843e6,a0

	clr.w	d0
	move.b	#10,$ff8800
	move.b	$ff8800,d0
	move.w	#17,d1
	sub.w	d0,d1
erasevu3:
	move.w	d3,(a0)
	move.w	d3,8(a0)
	move.w	d3,16(a0)
	add.w	#320,a0
	dbf.w	d1,erasevu3
drawvu3:
	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	add.w	#320,a0
	dbf.w	d0,drawvu3

*	--------------> Cool logo

	move.l	#back+50,a0
	move.l	#$82130,a1
	add.w	#2,timer
	cmp.w	#300,timer
	bgt	still
	move.w	#78,sinlogo
still:
	cmp.w	#660,timer
	bne	fwrap
	move.w	#0,timer
	addq.w	#2,plus
	cmp.w	#8,plus
	bne	fwrap
	move.w	#2,plus
fwrap:
	move.l	#logodata+1,a2
	move.w	plus,d4
	add.w	d4,sinlogo
	cmp.w	#178,sinlogo
	ble	noflip
	move.w	#0,sinlogo
	cmp.w	#0,flipflag
	beq	flag
	move.w	#0,flipflag
	jmp	noflip
flag:
	move.w	#1,flipflag
noflip:
	move.w	sinlogo,d1
	mulu.w	#56,d1
	add.w	d1,a2

	cmp.w	#0,flipflag
	beq	noadd
	add.w	#8800,a1
noadd:

	move.w	#53,d0
	move.w	flipflag,d3

logo:
	move.w	(a2),d2
	add.w	#2,a2
	add.w	d2,a0

	move.l	(a0),(a1)
	move.w	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.w	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.w	20(a0),20(a1)
	move.l	24(a0),24(a1)
	move.w	28(a0),28(a1)
	move.l	32(a0),32(a1)
	move.w	36(a0),36(a1)
	move.l	40(a0),40(a1)
	move.w	44(a0),44(a1)
	move.l	48(a0),48(a1)
	move.w	52(a0),52(a1)
	move.l	56(a0),56(a1)
	move.w	60(a0),60(a1)
	move.l	64(a0),64(a1)
	move.w	68(a0),68(a1)
	move.l	72(a0),72(a1)
	move.w	76(a0),76(a1)
	move.l	80(a0),80(a1)
	move.w	84(a0),84(a1)
	move.l	88(a0),88(a1)
	move.w	92(a0),92(a1)
	move.l	96(a0),96(a1)
	move.w	100(a0),100(a1)
	move.l	104(a0),104(a1)
	move.w	108(a0),108(a1)
	move.l	112(a0),112(a1)
	move.w	116(a0),116(a1)
	move.l	120(a0),120(a1)
	move.w	124(a0),124(a1)
	move.l	128(a0),128(a1)
	move.w	132(a0),132(a1)
	sub	d2,a0

	cmp.w	#0,d3		; flipflag
	bne	sub
	add.w	#160,a1
	jmp	passsub
sub:
	sub.w	#160,a1
passsub:
	dbf.w	d0,logo

	jsr	oblogo

	jsr	of

	jmp	mainloop
***************************************************************************
setsuper:
	clr.l	-(sp)			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,savesuper
	rts
***************************************************************************
endsuper:
	move.l	savesuper,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
***************************************************************************
vbl:
	jsr	$6fe5e
	move.w	#1,vbiflag

	move.w	#$566,$ff8242
	move.w	#$455,$ff8244
	move.w	#$344,$ff8246
	move.w	#$233,$ff8248
	move.w	#$122,$ff824a
	move.w	#$011,$ff824c
	move.w	#$777,$ff8250
	
	clr.b	$fffa1b
	lea	vps,a0
	move.b	(a0),$fffa21
	move.b	#8,$fffa1b

	lea	obpal,a0
	move.l	a0,$120

	rte
***************************************************************************
waitvbl:
	cmpi.w	#1,vbiflag
	bne	waitvbl
	move.w	#0,vbiflag

	rts 
***************************************************************************
obpal:
	move.l	a0,-(sp)

	cmp.w	#0,flipflag
	bne	dark
	move.w	#$001,$ff8242
	move.w	#$012,$ff8244
	move.w	#$023,$ff8246
	move.w	#$034,$ff8248
	move.w	#$045,$ff824a
	move.w	#$056,$ff824c
	move.w	#$067,$ff824e
	jmp	light
dark:
	move.w	#$000,$ff8242
	move.w	#$000,$ff8244
	move.w	#$001,$ff8246
	move.w	#$012,$ff8248
	move.w	#$023,$ff824a
	move.w	#$034,$ff824c
	move.w	#$045,$ff824e
light:
	clr.b	$fffa1b
	move.b	#53,$fffa21
	move.b	#8,$fffa1b

	bclr	#0,$fffa0f

	lea	palchange1,a0
	move.l	a0,$120

	move.l (sp)+,a0
	rte
***************************************************************************
palchange1:
	move.l	a0,-(sp)

	move.w	#$756,$ff8242
	move.w	#$645,$ff8244
	move.w	#$534,$ff8246
	move.w	#$423,$ff8248
	move.w	#$312,$ff824a
	move.w	#$777,$ff8250

	clr.b	$fffa1b
	move.b	#4,$fffa21
	move.b	#8,$fffa1b

	bclr	#0,$fffa0f

	lea	vurasters,a0
	move.l	a0,$120

	move.l (sp)+,a0

	rte
***************************************************************************
palchange2:
	move.l a0,-(sp)
	
	move.w	#$777,$ff8242
	move.w	#$565,$ff8244
	move.w	#$777,$ff8246
	move.w	#$343,$ff8248
	move.w	#$777,$ff824a
	move.w	#$121,$ff824c
	move.w	#$777,$ff824e

	clr.b	$fffa1b
	move.b	#52,$fffa21
	move.b	#8,$fffa1b

	bclr	#0,$fffa0f

	lea	border,a0
	move.l	a0,$120

	move.l (sp)+,a0
	rte
***************************************************************************
vurasters:
	move.l a0,-(sp)

	add.w	#2,rasters
	move.l	#rasterdata,a0
	add.w	rasters,a0
	move.w	(a0),$ff8250

	clr.b	$fffa1b
	move.b	#4,$fffa21
	move.b	#8,$fffa1b

	bclr	#0,$fffa0f

	lea	vurasters,a0

	cmp.w	#16,rasters
	ble	raststop
	move.w	#0,rasters
	lea	palchange2,a0
raststop:
	move.l	a0,$120

	move.l (sp)+,a0

	rte
***************************************************************************
border:
	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(sp)	
	movea.w	#$fa21,a0
	move.b	#200,(a0)
	move.b	#$8,$fffffa1b.W
	move.b	(a0),d0
bwait:	cmp.b	(a0),d0			
	beq	bwait
	clr.b	$ffff820a.w
	moveq.w	#2,d0
bwait2:	nop
	dbf	d0,bwait2
	move.b	#2,$ffff820a.w
	movem.l	(sp)+,d0/a0
	bclr	#0,$fffffa0f.w
	rte
***************************************************************************
setscreen:
	move.w	#0,-(sp)
	move.l	#$80000,-(sp)
	move.l	#$80000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	#$80000,a0
	move.w	#16000,d0
clear:	move.l	#0,(a0)+
	dbf.w	d0,clear

	rts
***************************************************************************
prerotate:
	move.l	#back+34,a0
	move.l	#back+34,a1
	add.w	#17000,a1
	move.w	#15,d1
lines:
	move.w	#15,d0
rotate:
	move.w	2(a0),(a1)
	move.w	4(a0),2(a1)
	move.w	2(a0),d2
	ror.w	#1,d2
	move.w	d2,2(a0)
	move.w	4(a0),d2
	ror.w	#1,d2
	move.w	d2,4(a0)
	addq	#4,a1

	dbf.w	d0,rotate

	add.w	#160,a0
	dbf.w	d1,lines
	rts
***************************************************************************
gubbe:
	move.l	#back+8834,a0
	move.l	#$844c0,a1
	move.w	#40,d0
gubbeloop:
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.l	20(a0),20(a1)
	move.l	(a0),136(a1)
	move.l	4(a0),140(a1)
	move.l	8(a0),144(a1)
	move.l	12(a0),148(a1)
	move.l	16(a0),152(a1)
	move.l	20(a0),156(a1)
	add.w	#160,a0
	add.w	#160,a1

	dbf.w	d0,gubbeloop
	
	rts
***************************************************************************
oblogo:
	move.l	#$429b4,a0
	move.l	#$80008,a1
	addq.w	#4,pls
	addq.w	#2,pls2
	cmp.w	#1438,pls
	ble	hopp
	move.w	#0,pls
	move.w	#0,pls2
hopp:
	move.w	#45,d0
	move.l	#sn,a2
	move.l	#sn2,a3
	add.w	pls,a2
	add.w	pls2,a3
up:
	add.l	(a2),a0
	add.w	(a3),a1

	move.l	(a0),(a1)
	move.w	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.w	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.w	20(a0),20(a1)
	move.l	24(a0),24(a1)
	move.w	28(a0),28(a1)
	move.l	32(a0),32(a1)
	move.w	36(a0),36(a1)
	move.l	40(a0),40(a1)
	move.w	44(a0),44(a1)
	move.l	48(a0),48(a1)
	move.w	52(a0),52(a1)

	sub.l	(a2),a0
	sub.w	(a3),a1

	sub.w	#54,a0
	add.w	#160,a1
	addq.w	#4,a2
	addq.w	#2,a3

	dbf.w	d0,up

	rts
***************************************************************************
prerotateob:
	move.l	#$42000,a1	Precalculate address
	move.w	#15,d2
bigloop:
	move.l	#back+9144+34,a0
	add.w	#7200,a0
	move.w	#45,d0

obloop:	move.w	48(a0),d1
	roxl.w	#1,d1
	move.w	d1,48(a0)
	move.w	d1,48(a1)
	move.w	40(a0),d1
	roxl.w	#1,d1
	move.w	d1,40(a0)
	move.w	d1,40(a1)
	move.w	32(a0),d1
	roxl.w	#1,d1
	move.w	d1,32(a0)
	move.w	d1,32(a1)
	move.w	24(a0),d1
	roxl.w	#1,d1
	move.w	d1,24(a0)
	move.w	d1,24(a1)
	move.w	16(a0),d1
	roxl.w	#1,d1
	move.w	d1,16(a0)
	move.w	d1,16(a1)
	move.w	8(a0),d1
	roxl.w	#1,d1
	move.w	d1,8(a0)
	move.w	d1,8(a1)
	move.w	(a0),d1
	roxl.w	#1,d1
	move.w	d1,(a0)
	move.w	d1,(a1)
	move.w	50(a0),d1
	roxl.w	#1,d1
	move.w	d1,50(a0)
	move.w	d1,50(a1)
	move.w	42(a0),d1
	roxl.w	#1,d1
	move.w	d1,42(a0)
	move.w	d1,42(a1)
	move.w	34(a0),d1
	roxl.w	#1,d1
	move.w	d1,34(a0)
	move.w	d1,34(a1)
	move.w	26(a0),d1
	roxl.w	#1,d1
	move.w	d1,26(a0)
	move.w	d1,26(a1)
	move.w	18(a0),d1
	roxl.w	#1,d1
	move.w	d1,18(a0)
	move.w	d1,18(a1)
	move.w	10(a0),d1
	roxl.w	#1,d1
	move.w	d1,10(a0)
	move.w	d1,10(a1)
	move.w	2(a0),d1
	roxl.w	#1,d1
	move.w	d1,2(a0)
	move.w	d1,2(a1)
	move.w	52(a0),d1
	roxl.w	#1,d1
	move.w	d1,52(a0)
	move.w	d1,52(a1)
	move.w	44(a0),d1
	roxl.w	#1,d1
	move.w	d1,44(a0)
	move.w	d1,44(a1)
	move.w	36(a0),d1
	roxl.w	#1,d1
	move.w	d1,36(a0)
	move.w	d1,36(a1)
	move.w	28(a0),d1
	roxl.w	#1,d1
	move.w	d1,28(a0)
	move.w	d1,28(a1)
	move.w	20(a0),d1
	roxl.w	#1,d1
	move.w	d1,20(a0)
	move.w	d1,20(a1)
	move.w	12(a0),d1
	roxl.w	#1,d1
	move.w	d1,12(a0)
	move.w	d1,12(a1)
	move.w	4(a0),d1
	roxl.w	#1,d1
	move.w	d1,4(a0)
	move.w	d1,4(a1)

	sub.w	#160,a0
	add.w	#54,a1

	dbf.w	d0,obloop

	dbf.w	d2,bigloop
	
	rts	
***************************************************************************
of:
	move.l	#back+10856,a0
	move.l	#$807c6,a1
	move.l	#studs,a2
	addq	#4,stc
	cmp	#362,stc
	bls	hopp2
	move.w	#0,stc
hopp2:
	add.w	stc,a2
	add.w	(a2),a1

	move.w	#28,d0
bitplan:
	move.w	(a0),(a1)
	move.w	8(a0),8(a1)
	move.w	16(a0),16(a1)
	add.w	#160,a0
	add.w	#160,a1
	dbf.w	d0,bitplan

	rts
***************************************************************************
end:
	move.l	oldvbl,$70.w
	move.l	old114,$114.w

	move.l	#$08080000,$ff8800		
	move.l	#$09090000,$ff8800		
	move.l	#$0a0a0000,$ff8800		

	jsr	endsuper

SLUT:	JMP	SLUT
	clr.w	-(sp)				
	trap	#1					
***************************************************************************

savesuper:	dc.l	0
vbiflag:	dc.w	0
oldvbi:		dc.l	0
ymove:		dc.w	0
distmove:	dc.w	0

bok_ptr:	dc.w	0
bokstav:	dc.w	0
scrsw:		dc.w	0
text:		incbin	b:\newyear.s
	EVEN
	DC.B	" "

sin:		include "a:\ob\backdist.dat"
back:		incbin "a:\ob\backdist.pi1"
font:		incbin	a:\ob\32x24.fon
bend:		include	a:\ob\bytebend.dat
zak		incbin "a:\ob\gfxshow.rel"
zakend

oldvbl	dc.l 0
old114	dc.l 0
stack	dc.l 0
vps:	dc.b	0

logodata:	include "a:\ob\sinlogo.dat"
sinlogo:	dc.w	0
flipflag:	dc.w	0
timer:		dc.w	0
plus:		dc.w	0
rasterdata:	dc.w	$733,$711,$601,$502,$403,$304,$205,$106,$006,$004
rasters:	dc.w	0
pls:	dc.w	0
sn:	include	"a:\ob\obdist.dat"
sn2:	include "a:\ob\obdist2.dat"
pls2:	dc.w	0
str„ng:	dc.b	$13
stc:	dc.w	0
	even
studs:	include	"a:\ob\ofstuds.dat"
