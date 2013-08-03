*********************************
*                               *
*    WILD! CD26b SOURCE CODE    *
*                               *
*           BY SPIKE            *
*                               *
* If you use this please credit *
* me for the lemming routines!! *
*                               *
*********************************

	move.l	4(a7),a3
	move.l	#mystack,a7
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	
	jsr	hblon

	move.b	#2,$484.w

	moveq	#4,d0
	bsr	music

	dc.w	$a00a

	move.w  #2,-(sp)
        trap    #14
        addq.l  #2,a7
        move.l  d0,xdummy

	move.b	#2,$ff820a

	move.l	#$ff8240,a1
	move.l	#font+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)

	move.w	#0,-(sp)
	move.l	#$76000,-(sp)
	move.l	#$76000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	;move.w	#8000,d0
	;lea	$44e,a0
	;move.l	(a0),a0
	;lea	picture+34,a1
nextlb	;move.l	(a1)+,(a0)+
	;dbf	d0,nextlb

	move.l  #text,mespt

keyprs	move.w	#$ff,-(a7)
	move.w	#$06,-(a7)
	trap	#1
	addq.l	#4,a7

	cmp.b	#'1',d0
	beq	Run1
	cmp.b	#'2',d0
	beq	Run2
	;cmp.b	#'3',d0
	;beq	Run3
	;cmp.b	#'*',d0
	;beq	star
	cmp.b	#'0',d0
	beq	zero


vurout	move.b	#8,$ffff8800.w			
	move.b	$ffff8800.w,ampa
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,ampb
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,ampc

	move.l	#0,a0
	lea	lemmy+34,a0
	move.l	a0,strtlem

vum1	move.l	strtlem,a0	;screen address of lemmings
	move.l	#$76000,a1
	adda	#0,a0		;start of 1st vu lemming
	;adda	#1280,a0	;don't need his head
	adda	#8,a1
	;adda	#1280,a1	;don't need his head
	move.b	ampa,amp
	moveq	#0,d4
	bsr	vu_go
	
vum2	move.l	strtlem,a0	;screen address of lemmings
	move.l	#$76000,a1
	adda	#0,a0		;start of 1st vu lemming
	;adda	#1280,a0	;don't need his head
	adda	#40,a1
	;adda	#1280,a1	;don't need his head
	move.b	ampb,amp
	moveq	#0,d4
	bsr	vu_go
	
vum3	move.l	strtlem,a0	;screen address of lemmings
	move.l	#$76000,a1
	adda	#0,a0		;start of 1st vu lemming
	;adda	#1280,a0	;don't need his head
	adda	#72,a1
	;adda	#1280,a1	;don't need his head
	move.b	ampc,amp
	moveq	#0,d4
	bsr	vu_go

vum4	move.l	strtlem,a0	;screen address of lemmings
	move.l	#$76000,a1
	adda	#0,a0		;start of 1st vu lemming
	;adda	#1280,a0	;don't need his head
	adda	#104,a1
	;adda	#1280,a1	;don't need his head
	move.b	ampb,amp
	moveq	#0,d4
	bsr	vu_go

vum5	move.l	strtlem,a0	;screen address of lemmings
	move.l	#$76000,a1
	adda	#0,a0		;start of 1st vu lemming
	;adda	#1280,a0	;don't need his head
	adda	#136,a1
	;adda	#1280,a1	;don't need his head
	move.b	ampa,amp
	moveq	#1,d4
	bsr	vu_go
	moveq	#0,d4
	bra	aszdf

vu_go	moveq	#0,d0
	move.b	amp,d0
	cmpi.b	#9,d0
	bgt.s	lem2
	bsr	pr_vu
	bra.s	ret
lem2	adda	#24,a0
	cmpi.b	#10,d0
	bgt.s	lem3
	bsr	pr_vu
	bra.s	ret
lem3	adda	#24,a0
	cmpi.b	#11,d0
	bgt.s	lem4
	bsr	pr_vu
	bra.s	ret
lem4	adda	#24,a0
	cmpi.b	#12,d0
	bgt.s	lem5
	bsr	pr_vu
	bra.s	ret
lem5	adda	#24,a0
	cmpi.b	#13,d0
	bgt.s	lem6
	bsr	pr_vu
	bra.s	ret
lem6	adda	#24,a0
	bsr	pr_vu
ret	rts

pr_vu	move.l	#$76000,a3
	moveq	#49,d1
vu_lem	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	move.l	16(a0),16(a1)
	move.l	20(a0),20(a1)
	move.l	16(a0),(a3)
	move.l	20(a0),4(a3)
	cmp.b	#0,d4
	bne	npr1
	move.l	16(a0),24(a1)
	move.l	20(a0),28(a1)

npr1	move.l	(a0),8000(a1)
	move.l	4(a0),8004(a1)
	move.l	8(a0),8008(a1)
	move.l	12(a0),8012(a1)
	move.l	16(a0),8016(a1)
	move.l	20(a0),8020(a1)
	move.l	16(a0),8000(a3)
	move.l	20(a0),8004(a3)
	cmp.b	#0,d4
	bne	npr2
	move.l	16(a0),8024(a1)
	move.l	20(a0),8028(a1)

npr2	move.l	(a0),16000(a1)
	move.l	4(a0),16004(a1)
	move.l	8(a0),16008(a1)
	move.l	12(a0),16012(a1)
	move.l	16(a0),16016(a1)
	move.l	20(a0),16020(a1)
	move.l	16(a0),16000(a3)
	move.l	20(a0),16004(a3)
	cmp.b	#0,d4
	bne	npr3
	move.l	16(a0),16024(a1)
	move.l	20(a0),16028(a1)

npr3	move.l	(a0),24000(a1)
	move.l	4(a0),24004(a1)
	move.l	8(a0),24008(a1)
	move.l	12(a0),24012(a1)
	move.l	16(a0),24016(a1)
	move.l	20(a0),24020(a1)
	move.l	16(a0),24000(a3)
	move.l	20(a0),24004(a3)
	cmp.b	#0,d4
	bne	npr4
	move.l	16(a0),24024(a1)
	move.l	20(a0),24028(a1)

npr4	adda	#160,a1
	adda	#160,a0
	adda	#160,a3
	dbf	d1,vu_lem
	rts

aszdf	jmp	keyprs

music	incbin	'pres_2.*'
	even

RunProg	jsr	hbloff
	move.w	#0,-(sp)
	move.l	xdummy,-(sp)
	move.l	xdummy,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.b	(hertz),$ff820a
	move.l	d5,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,a7
	move.l	#Empty,-(sp)
	move.l	#Empty,-(sp)
	move.l	d6,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(a7),a7

star	jsr	hbloff
	;move.w	#$0777,$ff8240
	;move.l	#0,$ff8244
	clr.w	-(sp)
	trap	#1			; just for the testing exit

Run1	move.l	#Emp,d5
	move.l	#Prog1,d6
	bra	RunProg

Run2	move.l	#Emp,d5
	move.l	#Prog2,d6
	bra	RunProg

Run3	move.l	#Emp,d5
	move.l	#Prog3,d6
	bra	RunProg

zero	eori.w	#$111,font+2
	move.b	(hertz),d0
	tst	d0
	beq	hz50
	move.b	#0,(hertz)
	jmp	aszdf

hz50	move.b	#2,(hertz)
	jmp	aszdf		; toggle 50/60Hz

hblon	move.l	$120,oldtb
	move.l	$70,old4
	move.l	$70,new4b+2
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
	and.b	#$df,$fffa09
	and.b	#$fe,$fffa07
	move.l	#killborder,$120
	move.l	#new4,$70
	or.b	#1,$fffffa07
	or.b	#1,$fffffa13
	rts			; starts the hb interupt

hbloff	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	old07(pc),$fffffa07
	move.b	old09(pc),$fffffa09
	move.l	oldtb,$120
	move.l	old4,$70
	move.l	#$8080000,$ff8820
	move.l	#$9090000,$ff8820
	move.l	#$a0a0000,$ff8820
	move.l	#$707ffff,$ff8820
	move.w	(sp)+,sr
	rts			; stops the hb int + clear sound

new4	movem.l	d0-a6,-(sp)
	bsr	(music+8)
	move.l	#$ff8240,a1
	move.l	#font+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21
	move.b	#8,$fffffa1b
	move.l	#killborder,$120 ; sets up the bottom border

morepix	move.w	delcon,d0
	subq.w	#1,d0
	beq	mskro
	move.w	d0,delcon
	jmp	endskro

mskro	move.w	_left,d1
	dbf	d1,noneed
        move.l  mespt,a0
        clr.l   d0
	move.b  (a0)+,d0
	cmp.b	#']',d0
	bne	gstring
	move.b	#100,d0
	move.w	d0,delcon
	move.l	a0,mespt
	jmp	morepix

gstring	cmp.b   #255,d0
        bne     cont
	move.b	#'[',d0
	move.l	#text,a0

cont	sub.b   #32,d0
	divu	#10,d0
	move.l	d0,d1
        mulu    #160*32,d0
	swap	d1
	lsl	#4,d1
	add.w	d1,d0
        add.l   #font+34,d0
	move.l	a0,mespt
        move.l  d0,a0
	move.l	#_blk,a1
	move.w	#31,d2

loup1	move.w	2(a0),128(a1)
	move.w	10(a0),130(a1)
	move.w	4(a0),256(a1)
	move.w	12(a0),258(a1)
	move.w	6(a0),384(a1)
	move.w	14(a0),386(a1)
	move.w	(a0),(a1)+
	move.w	8(a0),(a1)+
	add.l	#160,a0
	dbf	d2,loup1
	move.w	#3,d1

noneed	move.w	d1,_left
	move.l	#_blk+3,a1
	sub.w	d1,a1
	move.l	#$7dd00,a2
	;adda.l	scp,a2
	move.w	#2,d0	;no of planes

nexbp	move.l	a2,a0
	lea	2(a2),a2
	move.w	#31,d1

nexln	move.b	1(a0),(a0)
	move.b	8(a0),1(a0)
	move.b	9(a0),8(a0)
	move.b	16(a0),9(a0)
	move.b	17(a0),16(a0)
	move.b	24(a0),17(a0)
	move.b	25(a0),24(a0)
	move.b	32(a0),25(a0)
	move.b	33(a0),32(a0)
	move.b	40(a0),33(a0)
	move.b	41(a0),40(a0)
	move.b	48(a0),41(a0)
	move.b	49(a0),48(a0)
	move.b	56(a0),49(a0)
	move.b	57(a0),56(a0)
	move.b	64(a0),57(a0)
	move.b	65(a0),64(a0)
	move.b	72(a0),65(a0)
	move.b	73(a0),72(a0)
	move.b	80(a0),73(a0)
	move.b	81(a0),80(a0)
	move.b	88(a0),81(a0)
	move.b	89(a0),88(a0)
	move.b	96(a0),89(a0)
	move.b	97(a0),96(a0)
	move.b	104(a0),97(a0)
	move.b	105(a0),104(a0)
	move.b	112(a0),105(a0)
	move.b	113(a0),112(a0)
	move.b	120(a0),113(a0)
	move.b	121(a0),120(a0)
	move.b	128(a0),121(a0)
	move.b	129(a0),128(a0)
	move.b	136(a0),129(a0)
	move.b	137(a0),136(a0)
	move.b	144(a0),137(a0)
	move.b	145(a0),144(a0)
	move.b	152(a0),145(a0)
	move.b	153(a0),152(a0)
	move.b	(a1),153(a0)

	lea	160(a0),a0
	lea	4(a1),a1

	dbf	d1,nexln
	dbf	d0,nexbp

	;eori.w	#$200,$ffff8240.w

endskro	movem.l (sp)+,d0-a6

new4b	jmp	0		; will be set up by prog

killborder
	movem.l	d0-d7/a0-a1,-(sp)
	move.w	#$fa21,a1
	clr.b	-6(a1)
	move.b	#200,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0

wait4	cmp.b	(a1),d0
	beq	wait4
	clr.b	$ffff820a.w
	REPT	16
	nop
	ENDR
	move.b	#2,$ffff820a.w
	move.l	#$ff8240,a0
	move.b	(a1),d0		; bottom border now away

del	cmp.b	(a1),d0
	beq	del
	move.l	#font+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,($ff8240)
	movem.l	(sp)+,d0-d7/a0-a1
	bclr	#0,$fffffa0f.w
	rte

_left	dc.w	0
_blk	ds.w	256
amp	dc.b	0
ampa	dc.b	0
ampb	dc.b	0
ampc	dc.b	0
strtlem	ds.l	1
scp	dc.l	32000
ww	dc.b	0
delcon	dc.w	2
mespt	dc.l	text
xdummy	dc.l	0
old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
stdum	ds.l	16

text	incbin	'cd26b.doc'
	dc.b	255

stback	ds.l	100
mystack	ds.l	1

font	EVEN
	INCBIN	'cd26font.pi1'

picture
	;INCBIN	'a:\twb24b.pi1'

lemmy	incbin	'cd26lem1.pi1'

Emp	dc.b	'a:\',0
Empty	dc.b	0
Prog1	dc.b	'desktop',0
Prog2	dc.b	'desktop',0
Prog3	dc.b	'desktop',0
hertz	dc.b	2

	EVEN






    