; AntiChrist / Sector Ones'  Soundchip Music Demo
; -----------------------------------------------
;
; If you leave the labels in, you pay the price !
;
; Should be easily adaptable for anybody elses music
; demo !!!
;
; Hacked by:  Chubby Brown / Profanity Inc.

	section	text


	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,stack
	dc.w	$a00a
	move.w	#2,-(a7)		;physbase
	trap	#$e
	addq.l	#2,a7
	move.l	d0,xb2
	move.w	#3,-(a7)		;logbase
	trap	#$e
	addq.l	#2,a7
	move.l	d0,xb3
	move.w	#4,-(a7)		;getrez
	trap	#$e
	addq.l	#2,a7
	move.w	d0,res
	move.l	#adfin,d0
	addi.l	#$100,d0
	andi.l	#$ffffff00,d0
	move.l	d0,ecr1
	addi.l	#$7e00,d0
	andi.l	#$ffffff00,d0
	move.l	d0,ecr2
	clr.w	-(a7)
	move.l	ecr1,-(a7)
	move.l	ecr1,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7
	movem.l	$ffff8240.l,d0-d7
	movem.l	d0-d7,color
	movem.l	palaff,d0-d7
	movem.l	d0-d7,$ffff8240.w
	moveq	#0,d1
	movea.l	ecr1,a0
	movea.l	ecr2,a1
	move.l	#$1f3f,d0
remp2	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,remp2
	move	sr,oldsr
	move	#$2700,sr
	move	usp,a0
	move.l	a0,oldusp
	move.l	$fffffa06.l,int
	clr.b	$fffffa07.l
	clr.b	$fffffa09.l
	move.l	$70.l,oldvbl
	move.l	#vblstart,$70.l
	move.l	#tmb,$120.l
	ori.b	#1,$fffffa13.l
	moveq	#1,d0
	jsr	zic1
	move	#$2300,sr
	move.b	l0047,$ffff8201.w
	move.b	l0048,$ffff8203.w
	movea.l	#anti,a0
	move.w	#$12,8480(a0)
	movea.l	ecr1,a1
	lea	11840(a1),a1
	move.w	#$847,d0
affanti1	move.l	(a0)+,(a1)+
	dbf	d0,affanti1
	clr.w	bcompt
	st	flag
attd	tst.b	flag
	bne	attd
	st	flag
	cmpi.w	#$64,bcompt
	beq	apattd
	cmpi.b	#1,$fffffc02.w
	beq	fin
	bra	attd
apattd	clr.w	bcompt
	st	flag
afondu1	tst.b	flag
	bne	afondu1
	st	flag
	cmpi.w	#$21,bcompt
	bge	aapf1
	movea.l	#col0,a1
	movea.l	#l0062,a0
	movea.l	#palaff,a2
	move.w	bcompt,d
	move.w	#$10,cec
	jsr	fondu
	movem.l	palaff,d0-d7
	movem.l	d0-d7,$ffff8240.w
	cmpi.b	#1,$fffffc02.w
	beq	fin
	bra	afondu1
aapf1	clr.w	bcompt
	st	flag
attd2	tst.b	flag
	bne	attd2
	st	flag
	cmpi.w	#$32,bcompt
	beq	apattd2
	cmpi.b	#1,$fffffc02.w
	beq	fin
	bra	attd2
apattd2	clr.w	bcompt
	st	flag
depanti	tst.b	flag
	bne	depanti
	st	flag
	cmpi.l	#0,adanti
	beq	apdep
	move.l	ecr1,d0
	move.l	ecr2,ecr1
	move.l	d0,ecr2
	move.b	l0047,$ffff8201.w
	move.b	l0048,$ffff8203.w
	movea.l	#anti,a0
	movea.l	ecr1,a1
	subi.l	#$a0,adanti
	adda.l	adanti,a1
	move.w	#$847,d0
depa1	move.l	(a0)+,(a1)+
	dbf	d0,depa1
	moveq	#0,d1
	move.w	#$4f,d0
effa1	move.l	d1,(a1)+
	dbf	d0,effa1
	cmpi.b	#1,$fffffc02.w
	bne	depanti
	bra	fin
apdep	movea.l	ecr2,a0
	movea.l	ecr1,a1
	move.w	#$1f3f,d0
eff2	move.l	(a1)+,(a0)+
	dbf	d0,eff2
	move.b	#1,frast
	st	flag
attrast1	tst.b	flag
	bne	attrast1
redebut	movea.l	text,a0
	movea.l	ecr1,a2
	lea	8960(a2),a2
	jsr	afftext
	clr.w	bcompt
	st	flag
fondu1	tst.b	flag
	bne	fondu1
	st	flag
	cmpi.w	#$21,bcompt
	bge	apf1
	movea.l	#col0,a1
	movea.l	#col8x8,a0
	movea.l	#palaff2,a2
	move.w	bcompt,d
	move.w	#$10,cec
	jsr	fondu
	cmpi.b	#1,$fffffc02.w
	beq	fin
	bra	fondu1
apf1	st	flag
bouc	tst.b	flag
	bne	bouc
	st	flag
	movea.l	ecr1,a0
	adda.l	adlig,a0
	lea	-114(a0),a0
	moveq	#0,d2
	move.w	#9,d0
effbar1	move.w	d2,(a0)
	lea	8(a0),a0
	dbf	d0,effbar1
	lea	80(a0),a0
	moveq	#-1,d2
	move.w	#8,d0
affbar1	move.w	#9,d1
affbar2	move.w	d2,(a0)
	lea	8(a0),a0
	dbf	d1,affbar2
	lea	80(a0),a0
	dbf	d0,affbar1
	moveq	#0,d2
	move.w	#9,d0
effbar2	move.w	d2,(a0)
	lea	8(a0),a0
	dbf	d0,effbar2
	move.b	$fffffc02.w,clav
	tst.w	flig
	beq	ligok
	move.l	addl,d0
	add.l	d0,adlig
	subi.w	#1,flig
	tst.w	flig
	bne	plig
ligok	cmpi.b	#$48,clav
	bne	clp48
	tst.w	nbzic
	beq	plig
	subi.w	#1,nbzic
	move.l	#$ffffff60,addl
	move.w	#$a,flig
clp48	cmpi.b	#$50,clav
	bne	clp50
	move.w	max,d7
	move.w	nbzic,d6
	cmp.w	d7,d6
	bgt	plig
	addi.w	#1,nbzic
	move.l	#$a0,addl
	move.w	#$a,flig
clp50	cmpi.b	#$39,clav
	beq	zicplay
	move.w	#1,zicok
plig	cmpi.b	#1,clav
	beq	fin
	bra	fondu1
zicplay	clr.w	bcompt
	st	flag
zfondu1	tst.b	flag
	bne	zfondu1
	st	flag
	cmpi.w	#$21,bcompt
	bge	zapf1
	movea.l	#col0,a0
	movea.l	#col8x8,a1
	movea.l	#palaff2,a2
	move.w	bcompt,d
	move.w	#$10,cec
	jsr	fondu
	cmpi.b	#1,$fffffc02.w
	beq	fin
	bra	zfondu1
l0020	equ	*-2
zapf1	move.w	side,d0
	move.w	nbzic,d1
	cmp.w	d0,d1
	bne	d0pd1
	cmpi.w	#$c,side
	bne	sp12
	move.l	#text2,text
	move.l	#adzic2,adzic
	move.w	#6,max
	move.w	#7,nbzic
	move.w	#7,side
	subi.l	#$1f40,adlig
	bra	redebut
sp12	move.l	#text1,text
	move.w	#$b,max
	move.l	#adzic1,adzic
	move.w	#$c,nbzic
	move.w	#$c,side
	addi.l	#$1f40,adlig
	bra	redebut
d0pd1	movea.l	ecr2,a0
	lea	8480(a0),a0
	moveq	#0,d1
	move.w	#$16cf,d0
efeq	move.l	d1,(a0)+
	dbf	d0,efeq
	move.b	l004a,$ffff8201.w
	move.b	l004b,$ffff8203.w
	st	flag
attec	tst.b	flag
	bne	attec
	move.l	adzicp,d0
	cmp.l	adzic(pc),d0
	bne	pcok
	move.w	nbzic,d0
	cmp.w	play(pc),d0
	beq	cok
pcok	move	#$2700,sr
	move.w	play,d0
	movea.l	adzicp,a0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	0(a0,d0.w),a0
	jsr	4(a0)
	move.w	nbzic,play
	move.w	play,d0
	move.l	adzic,adzicp
	movea.l	adzicp,a0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	0(a0,d0.w),a0
	moveq	#1,d0
	jsr	(a0)
	move	#$2300,sr
cok	movem.l	equapal,d0-d7
	movem.l	d0-d7,palaff2
	clr.w	bcompt
	st	flag
equa	tst.b	flag
	bne	equa
	st	flag
	move	#$2700,sr
	moveq	#0,d0
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	d0,vola
	moveq	#0,d0
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	d0,volb
	moveq	#0,d0
	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d0
	move.w	d0,volc
	move	#$2300,sr
	cmpi.w	#$11,vola
	blt	aok
	move.w	#$11,vola
aok	cmpi.w	#$11,volb
	blt	bok
	move.w	#$11,volb
bok	cmpi.w	#$11,volc
	blt	cok2
	move.w	#$11,volc
cok2	movea.l	ecr2,a0
	lea	31840(a0),a0
	moveq	#-1,d2
	move.w	vola,d0
eqa1	move.w	#3,d1
eqa2	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	move.w	d2,32(a0)
	move.w	d2,40(a0)
	lea	-320(a0),a0
	dbf	d1,eqa2
	dbf	d0,eqa1
	moveq	#$10,d0
	sub.w	vola,d0
	tst.w	d0
	blt	pd0a
	moveq	#0,d2
eqa3	move.w	#3,d1
eqa4	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	move.w	d2,32(a0)
	move.w	d2,40(a0)
	lea	-320(a0),a0
	dbf	d1,eqa4
	dbf	d0,eqa3
pd0a	movea.l	ecr2,a0
	lea	31898(a0),a0
	moveq	#-1,d2
	move.w	volb,d0
eqb1	move.w	#3,d1
eqb2	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	move.w	d2,32(a0)
	move.w	d2,40(a0)
	lea	-320(a0),a0
	dbf	d1,eqb2
	dbf	d0,eqb1
	moveq	#$10,d0
	sub.w	volb,d0
	tst.w	d0
	blt	pd0b
	moveq	#0,d2
eqb3	move.w	#3,d1
eqb4	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	move.w	d2,32(a0)
	move.w	d2,40(a0)
	lea	-320(a0),a0
	dbf	d1,eqb4
	dbf	d0,eqb3
pd0b	movea.l	ecr2,a0
	lea	31956(a0),a0
	moveq	#-1,d2
	move.w	volc,d0
eqc1	move.w	#3,d1
eqc2	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	move.w	d2,32(a0)
	move.w	d2,40(a0)
	lea	-320(a0),a0
	dbf	d1,eqc2
	dbf	d0,eqc1
	moveq	#$10,d0
	sub.w	volc,d0
	tst.w	d0
	blt	pd0c
	moveq	#0,d2
eqc3	move.w	#3,d1
eqc4	move.w	d2,(a0)
	move.w	d2,8(a0)
	move.w	d2,16(a0)
	move.w	d2,24(a0)
	move.w	d2,32(a0)
	move.w	d2,40(a0)
	lea	-320(a0),a0
	dbf	d1,eqc4
	dbf	d0,eqc3
pd0c	move.b	$fffffc02.w,clav
	cmpi.b	#1,clav
	beq	fin
	cmpi.b	#$39,clav
	bne	equa
	movem.l	col0,d0-d7
	movem.l	d0-d7,palaff2
	move.b	l0047,$ffff8201.w
	move.b	l0048,$ffff8203.w
	bra	redebut
fin	move	#$2700,sr
	move.w	play,d0
	movea.l	adzicp,a0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	0(a0,d0.w),a0
	jsr	4(a0)
	movea.l	oldusp,a0
	move	a0,usp
	move.l	int,$fffffa06.l
	move.l	oldvbl,$70.l
	move	oldsr,sr
	move.w	res,-(a7)
	move.l	xb2,-(a7)
	move.l	xb3,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7
	movem.l	color,d0-d7
	movem.l	d0-d7,$ffff8240.l
	move.l	stack,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	dc.b	$a0,$a
	clr.w	-(a7)		;pterm0
	trap	#1
vblstart	move.l	#vbl,$70.l
	rte

vbl	cmpi.b	#1,frast
	bne	frp1
	move.l	#tmb,$120.w
	ori.b	#1,$fffffa07.w
	clr.b	$fffffa1b.w
	move.b	#$36,$fffffa21.w
	move.b	#$18,$fffffa1b.w
frp1	addi.w	#1,bcompt
	sf	flag
	movem.l	a0-a6/d0-d7,-(a7)
	movem.l	palaff,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	play,d0
	movea.l	adzicp,a0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	0(a0,d0.w),a0
	jsr	8(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	rte

tmb	movem.l	d0-d7,-(a7)
	movem.l	palaff2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(a7)+,d0-d7
	andi.b	#$fe,$fffffa0f.w
	andi.b	#$fe,$fffffa07.w
	rte

stack	dcb.w	4
xb2	dcb.w	2
xb3	dcb.w	2
oldusp	dcb.w	2
oldvbl	dcb.w	2
int	dcb.w	2
ecr1	dc.b	0
l0047	dc.b	0
l0048	dc.b	0,0
ecr2	dc.b	0
l004a	dc.b	0
l004b	dc.b	0,0
color	dcb.w	16
res	dc.b	0,0
oldsr	dc.b	0,0
bcompt	dc.b	0,0
vola	dc.b	0,0
volb	dc.b	0,0
volc	dc.b	0,0
nbzic	dc.b	0,0
play	dc.b	0,0
zicok	dc.b	0,0
adlig	dc.b	0,0,'#',0
addl	dcb.w	2
flig	dc.b	0,0
clav	dc.b	0,0
flag	dc.b	0
frast	dc.b	0
font8x8	incbin	'font8x8.bin'
	even
adanti	dc.b	0,0,'.@'
	
anti	incbin	'ANTI.BIN'

l0062	dc.b	0,0,2,$10,3,'!',4,'2'
	dc.b	5,'C',6,'T',7,'e',7,'v'
	dc.b	7,'w',3,'4',2,'#',3,'3'
	dc.b	4,'L',$d,']',$e,'f',7,'w'
max	dc.b	0,$b
adzic	dc.l	adzic1
adzicp	dc.l	adzic1
text	dc.l	text1
side	dc.b	0,12
adzic1	dc.l	zic1
	dc.l	zic2
	dc.l	zic3
	dc.l	zic4
	dc.l	zic5
	dc.l	zic6
	dc.l	zic7
	dc.l	zic8
	dc.l	zic9
	dc.l	zic10
	dc.l	zic11
	dc.l	zic12
	dc.l	zic1
adzic2	dc.l	zic13
	dc.l	zic14
	dc.l	zic15
	dc.l	zic16
	dc.l	zic17
	dc.l	zic18
	dc.l	zic19
equapal	dc.b	0,$12,0,5,5,'U',0,0
	dc.b	5,0

zic1	incbin	'ZIC1.THK'
	even

zic2	incbin	'ZIC2.THK'
	even

zic3	incbin	'ZIC3.THK'
	even

zic4	incbin	'ZIC4.THK'
	even

zic5	incbin	'ZIC5.THK'
	even

zic6	incbin	'ZIC6.THK'
	even

zic7	incbin	'ZIC7.THK'
	even

zic8	incbin	'ZIC8.THK'
	even

zic9	incbin	'ZIC9.THK'
	even

zic10	incbin	'ZIC10.THK'
	even

zic11	incbin	'ZIC11.THK'
	even

zic12	incbin	'ZIC12.THK'
	even

zic13	incbin	'ZIC13.THK'
	even

zic14	incbin	'ZIC14.THK'
	even

zic15	incbin	'ZIC15.THK'
	even

zic16	incbin	'ZIC16.THK'
	even

zic17	incbin	'ZIC17.THK'
	even

zic18	incbin	'ZIC18.THK'
	even

zic19	incbin	'ZIC19.THK'
	even

	dcb.w	122
text1	dc.b	'        '
	dc.b	'      OH'
	dc.b	' NO !! .'
	dc.b	'..      '
	dc.b	'        '
	dc.b	'        '
	dc.b	'      NE'
	dc.b	'W  HISTO'
	dc.b	'RY      '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'SAD TUNE'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	' ENIGMA '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'       C'
	dc.b	'HRISTELL'
	dc.b	'E       '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	' OCEANS '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'     CON'
	dc.b	'COURS  C'
	dc.b	'SC2     '
	dc.b	'        '
	dc.b	'        '
	dc.b	'       T'
	dc.b	'HE  UNIO'
	dc.b	'N       '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	' VERITY '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'      ST'
	dc.b	'EPHANIE.'
	dc.b	'..      '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	' MELODY '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'TAKE OFF'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'       <'
	dc.b	' SIDE B '
	dc.b	'>       '
	dc.b	'        '
	dc.b	' ARROWS '
	dc.b	'AND SPAC'
	dc.b	'E TO SEL'
	dc.b	'ECT,ESC '
	dc.b	'TO QUIT '
text2	dc.b	'        '
	dc.b	'      CH'
	dc.b	'ELOU NO '
	dc.b	'!!      '
	dc.b	'        '
	dc.b	'        '
	dc.b	'     SAN'
	dc.b	'DRA',$27,'S  L'
	dc.b	'AND     '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'  SLOW  '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'COOLBASS'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'      TH'
	dc.b	'E  MYSTE'
	dc.b	'RY      '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'LOW TUNE'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'   OPERA'
	dc.b	'TION  JU'
	dc.b	'PITER   '
	dc.b	'        '
	dc.b	'        '
	dc.b	'       <'
	dc.b	' SIDE A '
	dc.b	'>       '
	dc.b	'        '
	dc.b	'        '
	dc.b	'                                        '
	dc.b	'ANTICHRIST: Joel  Le Griguer :TSIRHCITNA'
	dc.b	'          11  Avenue Leon Blum          '
	dc.b	'         93140  Bondy  / FRANCE         '
	dc.b	'                                        '
	dc.b	'    CODE-GFX : DRABOB-SPS / DNT-CREW    '

afftext	move.w	#$d,d0
afftxt1	move.w	#$13,d1
afftxt2	movea.l	#font8x8,a1
	moveq	#0,d2
	move.b	(a0)+,d2
	subi.w	#$20,d2
	mulu	#$28,d2
	adda.l	d2,a1
	move.b	(a1)+,0(a2)
	move.b	(a1)+,2(a2)
	move.b	(a1)+,4(a2)
	move.b	(a1)+,6(a2)
	move.b	(a1)+,160(a2)
	move.b	(a1)+,162(a2)
	move.b	(a1)+,164(a2)
	move.b	(a1)+,166(a2)
	move.b	(a1)+,320(a2)
	move.b	(a1)+,322(a2)
	move.b	(a1)+,324(a2)
	move.b	(a1)+,326(a2)
	move.b	(a1)+,480(a2)
	move.b	(a1)+,482(a2)
	move.b	(a1)+,484(a2)
	move.b	(a1)+,486(a2)
	move.b	(a1)+,640(a2)
	move.b	(a1)+,642(a2)
	move.b	(a1)+,644(a2)
	move.b	(a1)+,646(a2)
	move.b	(a1)+,800(a2)
	move.b	(a1)+,802(a2)
	move.b	(a1)+,804(a2)
	move.b	(a1)+,806(a2)
	move.b	(a1)+,960(a2)
	move.b	(a1)+,962(a2)
	move.b	(a1)+,964(a2)
	move.b	(a1)+,966(a2)
	move.b	(a1)+,1120(a2)
	move.b	(a1)+,1122(a2)
	move.b	(a1)+,1124(a2)
	move.b	(a1)+,1126(a2)
	move.b	(a1)+,1280(a2)
	move.b	(a1)+,1282(a2)
	move.b	(a1)+,1284(a2)
	move.b	(a1)+,1286(a2)
	move.b	(a1)+,1440(a2)
	move.b	(a1)+,1442(a2)
	move.b	(a1)+,1444(a2)
	move.b	(a1)+,1446(a2)
	addq.l	#1,a2
	movea.l	#font8x8,a1
	moveq	#0,d2
	move.b	(a0)+,d2
	subi.w	#$20,d2
	mulu	#$28,d2
	adda.l	d2,a1
	move.b	(a1)+,0(a2)
	move.b	(a1)+,2(a2)
	move.b	(a1)+,4(a2)
	move.b	(a1)+,6(a2)
	move.b	(a1)+,160(a2)
	move.b	(a1)+,162(a2)
	move.b	(a1)+,164(a2)
	move.b	(a1)+,166(a2)
	move.b	(a1)+,320(a2)
	move.b	(a1)+,322(a2)
	move.b	(a1)+,324(a2)
	move.b	(a1)+,326(a2)
	move.b	(a1)+,480(a2)
	move.b	(a1)+,482(a2)
	move.b	(a1)+,484(a2)
	move.b	(a1)+,486(a2)
	move.b	(a1)+,640(a2)
	move.b	(a1)+,642(a2)
	move.b	(a1)+,644(a2)
	move.b	(a1)+,646(a2)
	move.b	(a1)+,800(a2)
	move.b	(a1)+,802(a2)
	move.b	(a1)+,804(a2)
	move.b	(a1)+,806(a2)
	move.b	(a1)+,960(a2)
	move.b	(a1)+,962(a2)
	move.b	(a1)+,964(a2)
	move.b	(a1)+,966(a2)
	move.b	(a1)+,1120(a2)
	move.b	(a1)+,1122(a2)
	move.b	(a1)+,1124(a2)
	move.b	(a1)+,1126(a2)
	move.b	(a1)+,1280(a2)
	move.b	(a1)+,1282(a2)
	move.b	(a1)+,1284(a2)
	move.b	(a1)+,1286(a2)
	move.b	(a1)+,1440(a2)
	move.b	(a1)+,1442(a2)
	move.b	(a1)+,1444(a2)
	move.b	(a1)+,1446(a2)
	addq.l	#7,a2
	dbf	d1,afftxt2
	lea	1440(a2),a2
	dbf	d0,afftxt1
	rts

fondu	move.w	d,d3
	moveq	#$20,d7
	sub.w	d3,d7
newcol	move.w	(a0)+,d0
	andi.w	#$777,d0
	move.w	(a1)+,d4
	andi.w	#$777,d4
	move.w	d0,d1
	move.w	d4,d5
	andi.w	#$f00,d1
	lsr.w	#8,d1
	mulu	d3,d1
	move.w	d0,d2
	andi.w	#$f00,d5
	lsr.w	#8,d5
	mulu	d7,d5
	add.w	d5,d1
	addi.w	#$10,d1
	lsr.w	#5,d1
	andi.w	#7,d1
	lsl.w	#8,d1
	move.w	d4,d6
	andi.w	#$f0,d2
	lsr.w	#4,d2
	mulu	d3,d2
	andi.w	#$f0,d6
	lsr.w	#4,d6
	mulu	d7,d6
	add.w	d6,d2
	addi.w	#$10,d2
	lsr.w	#5,d2
	andi.w	#7,d2
	lsl.w	#4,d2
	add.w	d2,d1
	andi.w	#$f,d0
	mulu	d3,d0
	andi.w	#$f,d4
	mulu	d7,d4
	add.w	d4,d0
	addi.w	#$10,d0
	lsr.w	#5,d0
	andi.w	#7,d0
	add.w	d0,d1
	move.w	d1,(a2)+
	subq.w	#1,cec
	bne.s	newcol
	rts

d	dc.b	0,0
cec	dc.b	0,0
col0	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
palaff	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
palaff2	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
	dc.b	0,$12,0,$12,0,$12,0,$12
col8x8	dc.b	0,$12,0,$12,2,$13,2,'4'
	dc.b	3,'E',4,'V',5,'g',5,'w'
	dc.b	0,'"',0,$12,2,$13,2,'4'
	dc.b	3,'E',4,'V',5,'g',5,'w'

adfin	dc.l	0