;DSMP-Acc version
;v1.3 by STGHOST
; -> maxi 64 samples
;         256 positions

	opt	o+
	opt	ow+

	section	text
install	move.l	a7,oldpile
	lea	STGpile(pc),a7
	lea	control(pc),a2
	clr.w	2(a2)
	move.w	#1,4(a2)
	clr.l	6(a2)
	moveq	#10,d0	;Appl_init
	bsr	aes
	tst.w	d0
	bmi	no_install
	move.w	d0,ap_id

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7

	move.l	$5a0.w,a0
	move.l	a0,d1
	beq	stfleave
	move.l	#'_MCH',d0
	bsr.s	grabcook
	swap	d1
	tst.w	d1
	beq	stfleave
	sf	falcon
	subq.w	#1,d1
	beq.s	no_matr
	move.l	#'_SND',d0
	bsr.s	grabcook
	and.l	#$fffffffc,d1
	tst.l	d1
	beq.s	no_matr

	st	falcon
	clr.w	-(sp)
	move.l	#$820006,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#1,-(sp)
	clr.w	-(sp)
	move.w	#$87,-(sp)
	trap	#14
	addq.l	#6,sp
	clr.l	-(sp)
	move.w	#$89,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#1,-(sp)
	clr.l	-(sp)
	move.w	#$7,-(sp)
	clr.w	-(sp)
	move.w	#$8b,-(sp)
	trap	#14
	lea	12(sp),sp
no_matr	move.l	d7,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	bra.s	goon_acc

grabcook	move.l	$5a0.w,a0
cookier	move.l	(a0),d1
	beq.s	nocookie
	cmp.l	#'_MCH',d1
	beq.s	identify
	addq.l	#8,a0
	bra.s	cookier
identify	move.l	4(a0),d1
	rts
nocookie	moveq	#0,d1
	rts

stfleave	move.l	d7,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
half_ins	lea	control+2(pc),a0
	move.w	#19,d0
	clr.l	(a0)+
	clr.l	(a0)
	bsr	aes
no_install
	move.l	oldpile(pc),a7
	clr.w	-(sp)
	trap	#1


goon_acc	move.w	ap_id(pc),intin
	move.l	#title,addrin
	lea	control(pc),a2
	move.l	#$10001,2(a2)
	move.w	#1,6(a2)
	moveq	#35,d0	;Menu_register
	bsr	aes
	tst.w	d0
	bmi.s	half_ins
	move.w	#25,-(sp)
	trap	#1
	addq.l	#2,sp
	add.b	d0,path

wt_msg	move.l	#msgbuf,addrin
	lea	control(pc),a2
	clr.w	2(a2)
	move.l	#$10001,4(a2)
	moveq	#23,d0	;Evnt_mesag
	bsr	aes
	lea	msgbuf(pc),a1
	move.w	(a1),d0
	cmp.w	#40,d0
	bne.s	wt_msg

;debut programme
mainacc	move.w	#1,intin
	tst.w	active
	bne.s	actbox1
	lea	mainbox(pc),a1
	bra.s	actbox0
actbox1	lea	mainbox2(pc),a1
actbox0	move.l	a1,addrin
	bsr	box
	cmp.w	#1,d0
	beq.s	wt_msg
	cmp.w	#2,d0
	beq.s	LoaderP

Stopzic	bsr	DSM_Stop
	sf	active
	move.l	adr(pc),-(sp)
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	adr
	bra.s	mainacc

LoaderP	pea	InputF(pc)
	bsr	Fsel
	addq.l	#4,sp
	tst.w	intout+2
	beq.s	mainacc

	lea	control+2(pc),a0
	moveq	#78,d0		;Graf_mouse(2)
	move.l	#$10001,(a0)+
	move.l	#$10000,(a0)
	move.w	#2,intin
	bsr	aes
	bsr	Load
	lea	control+2(pc),a0
	moveq	#78,d0		;Graf_mouse(0)
	move.l	#$10001,(a0)+
	move.l	#$10000,(a0)
	clr.w	intin
	bsr	aes
	tst.l	adr
	beq	mainacc
	move.l	adr(pc),a0
	cmp.l	#'DMA!',(a0)
	bne.s	badffile
	moveq	#0,d0
	move.b	25(a0),d0
	beq.s	badffile
	lsl.w	#4,d0
	tst.b	26(a0,d0.w)
	bne.s	gudffile
badffile	move.l	#not_DMA,addrin
	bsr.s	box
	bra	mainacc
gudffile	lea	control+2(pc),a0
	moveq	#78,d0		;Graf_mouse(2)
	move.l	#$10001,(a0)+
	move.l	#$10000,(a0)
	move.w	#2,intin
	bsr.s	aes
	bsr	DSM_Play
	lea	control+2(pc),a0
	moveq	#78,d0		;Graf_mouse(0)
	move.l	#$10001,(a0)+
	move.l	#$10000,(a0)
	clr.w	intin
	bsr.s	aes
	st	active
	bra	mainacc

box	lea	control(pc),a1
	move.w	#52,(a1)		;Form_alert
	move.l	#$10001,2(a1)
	move.w	#1,6(a1)
	clr.w	8(a1)
	move.w	#200,d0
	move.l	#aestab,d1
	trap	#2
	move.w	intout(pc),d0
	rts

aes	lea	control(pc),a1
	move.w	d0,(a1)
	clr.w	8(a1)
	move.l	#aestab,d1
	move.w	#200,d0
	trap	#2
	move.w	intout(pc),d0
	rts

Load	tst.w	active
	beq.s	quikload
	bsr	DSM_Stop
	sf	active
	move.l	adr(pc),-(sp)
	move.w	#73,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	adr
quikload	bsr	mkname
	clr.w	-(sp)
	pea	pathfile(pc)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	Abort_ld
	move.w	d0,hand
	move.w	#2,-(sp)
	move.w	d0,-(sp)
	clr.l	-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	move.l	d0,length
	addi.l	#16,d0
	move.l	d0,-(sp)
	move.w	#72,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bpl.s	Mem_Ok
	move.w	hand(pc),-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	bra.s	Abort_ld
Mem_Ok	move.l	d0,adr
	clr.w	-(sp)
	move.w	hand(pc),-(sp)
	clr.l	-(sp)
	move.w	#66,-(sp)
	trap	#1
	lea	10(sp),sp
	move.l	adr,-(sp)
	move.l	length,-(sp)
	move.w	hand(pc),-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	move.w	hand(pc),-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
Abort_ld	move.w	#1,intin
	move.l	#error,addrin
	bsr	box
	clr.l	adr
	rts

Fsel	move.w	#91,control
	clr.w	control+2
	move.w	#2,control+4
	move.w	#3,control+6
	move.l	#path,addrin
	move.l	#filename,addrin+4
	move.l	4(sp),addrin+8
	move.l	#aestab,d1
	move.w	#$c8,d0
	trap	#2
	rts

mkname	movem.l	d0/d2/d7/a0-a2,-(sp)
	lea	path(pc),a0
	lea	pathfile(pc),a1
	moveq	#57,d7
.loup1
	move.b	(a0)+,d0
	beq.s	.loup2
	move.b	d0,(a1)+
	bra.s	.loup1
.loup2
	move.l	a1,a2
.loup3
	move.b	-(a1),d2
	cmp.b	#'\',d2
	beq.s	.loup4
	dbf	d7,.loup3
	move.l	a2,a1
.loup4
	move.b	#'\',(a1)+
	lea	filename(pc),a0
.loup5
	move.b	(a0)+,d0
	beq.s	.loup6
	move.b	d0,(a1)+
	bra.s	.loup5
.loup6
	clr.b	(a1)+
	movem.l	(sp)+,d0/d2/d7/a0-a2
	rts

;DMA Samples Modules Player
;Appel en superviseur
; a0 = adresse du module *.DMA

DSM_Play	pea	DSMPplay(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
DSM_Stop	pea	DSMPstop(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	rts
DSMPplay	movem.l	d0-a6,-(sp)
	move.l	adr(pc),a0
	cmp.l	#'DMA!',(a0)
	bne.s	DSMabort
	lea	relocmod(pc),a1
	move.l	a0,(a1)
	lea	24(a0),a0
	move.l	a0,a1
	moveq	#0,d0
	move.b	1(a0),d0
	beq.s	DSMabort
	lsl.w	#4,d0
	tst.b	2(a0,d0.w)
	bne.s	DSMinit
DSMabort	movem.l	(sp)+,d0-a6
	rts
DSMPstop	move.w	#$2700,sr
	clr.b	$ffff8901.w
	clr.b	$fffffa07.w
	bclr	#3,$fffffa17.w
	move.w	#$2300,sr
	rts
DSMinit	bsr.s	DSMPstop
	move.w	#$2700,sr
	clr.b	$ffff8901.w

	tst.b	falcon
	beq.s	moreinit
	move.b	#4,$ffff8900.w
	clr.b	$ffff8920.w
moreinit
	addq.l	#2,a1
	lea	samplestart(pc),a2
	moveq	#0,d0
	move.b	(a0),$ffff8921.w
	move.b	1(a0),d0
	subq.w	#1,d0
	move.l	relocmod(pc),d1
spl_transform
	addq.l	#8,a1
	move.l	(a1)+,d2
	add.l	d1,d2
	move.l	(a1)+,d3
	add.l	d2,d3
	or.l	#$3000000,d2
	move.l	d2,(a2)+
	move.l	d3,(a2)+
	dbf	d0,spl_transform
	lea	reppos(pc),a2
	move.l	a1,(a2)+
	addq.l	#2,a1
	move.l	a1,(a2)+
;reconstitue les samples
	lea	samplestart(pc),a5
	move.l	relocmod(pc),d0
	add.l	#25,d0
	move.l	d0,a6
	moveq	#0,d7
	moveq	#0,d6
	moveq	#0,d5
	move.b	(a6),d5
	move.l	(a5)+,d6
	move.l	(a5)+,d7
	subq.w	#2,d5
	bmi.s	no_calc_end
calc_end	move.l	(a5)+,d4
	cmp.l	d6,d4
	bhi.s	notnewbegining00
	move.l	d4,d6
notnewbegining00
	move.l	(a5)+,d4
	cmp.l	d7,d4
	bls.s	notnewfinish00
	move.l	d4,d7
notnewfinish00
	dbf	d5,calc_end
no_calc_end
	and.l	#$ffffff,d6
	move.l	d6,a3
	move.l	d7,a4
un_delta	move.b	(a3)+,d0
	add.b	d0,(a3)
	cmp.l	a4,a3
	bne.s	un_delta

	lea	curpos(pc),a1
	clr.b	(a1)
	move.l	postab(pc),a1
	lea	samplestart(pc),a2
	lea	nextspl(pc),a3
	moveq	#0,d5
	move.b	(a1),d5
	lsl.w	#3,d5
	add.l	d5,a2
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	lea	nadaplay(pc),a0
	move.l	a0,d0
	or.l	#$3000000,d0
	move.l	d0,d1
	addi.l	#20,d1
	clr.b	$fffffa19.w
	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	lea	init_DSM(pc),a0
	move.l	a0,$134.w
	lea	$ffff8900.w,a0
	move.b	#1,$fffffa1f.w
	move.b	#8,$fffffa19.w
	movep.w	d0,5(a0)
	swap	d0
	move.b	d0,3(a0)
	movep.w	d1,$11(a0)
	swap	d1
	move.b	d1,$ffff890f.w
	swap	d0
	swap	d1
	move.b	#1,$ffff8901.w
	move.w	#$2300,sr
	movep.l	d0,1(a0)
	movep.w	d1,$11(a0)
	swap	d1
	move.b	d1,$ffff890f.w
	movem.l	(sp)+,d0-a6
	rts
init_DSM	movem.l	d0/a0,-(sp)
	lea	playerDSM(pc),a0
	move.l	a0,$134.w
	movem.l	(sp)+,d0/a0
	bclr	#5,$fffffa0f.w
	rte
playerDSM
	movem.l	d1/a0/a1,-(sp)
	lea	nextspl(pc),a0
	lea	$ffff8900.w,a1
	move.l	(a0)+,d1
	movep.l	d1,1(a1)
	move.l	(a0),d1
	movep.w	d1,$11(a1)
	swap	d1
	move.b	d1,$ffff890f.w
	move.b	curpos(pc),d1
	addq.b	#1,d1
	move.l	reppos(pc),a0
	cmp.b	(a0),d1
	bne.s	notonceagain
	move.b	1(a0),d1
notonceagain
	lea	curpos(pc),a0
	move.b	d1,(a0)
	move.l	postab(pc),a0
	move.b	(a0,d1.w),d1
	move.l	relocmod(pc),a0
	cmp.b	25(a0),d1
	blo.s	goodsamp
	moveq	#0,d1
goodsamp	lsl.w	#3,d1
	lea	samplestart(pc,d1.w),a1
	lea	nextspl(pc),a0
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	movem.l	(sp)+,d1/a0/a1
	bclr	#5,$fffffa0f.w
	rte

relocmod	ds.l	1
samplestart
	ds.l	128
nadaplay	ds.w	10
reppos	ds.l	1
postab	ds.l	1
nextspl	ds.l	2
curpos	ds.b	1
	even

	section	data
aestab	dc.l	control,global
	dc.l	intin,intout
	dc.l	addrin,addrout
title	dc.b	'  DSMP v1.3  ',0
mainbox	dc.b	'[1]['
	dc.b	'DMA Sample Module Player|'
	dc.b	' v1.3 by STGHOST  ½|]'
	dc.b	'[ OK | Load ]',0
mainbox2	dc.b	'[1]['
	dc.b	'DMA Sample Module Player|'
	dc.b	' v1.3 by STGHOST  ½|]'
	dc.b	'[ OK | Load | Stop ]',0
InputF	dc.b	'Select DMA-Sample Mod:',0
error	dc.b	"[2][| I can't load it ! |][ Cancel ]",0
not_DMA	dc.b	'[2][ This is not a DMA | Sample module... |][ Cancel ]',0
path	dc.b	'A:\*.DMA',0
	ds.b	58

	section	bss
oldpile	ds.l	1
falcon	ds.w	1
active	ds.w	1
ap_id	ds.w	1
control	ds.w	5
global	ds.w	14
intin	ds.w	16
intout	ds.w	7
addrin	ds.l	3
addrout	ds.l	1
msgbuf	ds.b	16
filename	ds.b	64
pathfile	ds.b	128
adr	ds.l	1
length	ds.l	1
hand	ds.w	1
	ds.l	150
STGpile
