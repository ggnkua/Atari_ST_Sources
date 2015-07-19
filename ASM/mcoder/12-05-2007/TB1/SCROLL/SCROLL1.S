	opt	w-
;	opt	m+
	opt	o+
;	opt	x+
	
	section	text
	
;	clr.l	-(sp)
;	move.w	#$20,-(sp)
;	trap	#1
;	addq.l	#6,sp
;	move.l	d0,savusp

;	lea	$ffff8240.w,a0
;	lea	savcol,a1
;	move.w	#15,d0
;savc	move.w	(a0)+,(a1)+
;	dbf	d0,savc
;
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#ecran1,d0
	and.l	#-256,d0
	add.l	#256,d0
	move.l	d0,phy

	move.l	#ecran2,d0
	and.l	#-256,d0
	add.l	#256,d0
	move.l	d0,log

	bsr	DECT

	bsr	DECAL_UN

	move.l	#logo1,SOURCE
	move.l	#logo2,DEST
	bsr	DECALAGE

	move.l	#logo2,SOURCE
	move.l	#logo3,DEST
	bsr	DECALAGE

	move.l	#logo3,SOURCE
	move.l	#logo4,DEST
	bsr	DECALAGE

	move.l	#logo4,SOURCE
	move.l	#logo5,DEST
	bsr	DECALAGE

	move.l	#logo5,SOURCE
	move.l	#logo6,DEST
	bsr	DECALAGE

	move.l	#logo6,SOURCE
	move.l	#logo7,DEST
	bsr	DECALAGE

	move.l	#logo7,SOURCE
	move.l	#logo8,DEST
	bsr	DECALAGE

	move.l	#logo8,SOURCE
	move.l	#logo9,DEST
	bsr	DECALAGE

	move.l	#logo9,SOURCE
	move.l	#logo10,DEST
	bsr	DECALAGE

	move.l	#logo10,SOURCE
	move.l	#logo11,DEST
	bsr	DECALAGE

	move.l	#logo11,SOURCE
	move.l	#logo12,DEST
	bsr	DECALAGE

	move.l	#logo12,SOURCE
	move.l	#logo13,DEST
	bsr	DECALAGE

	move.l	#logo13,SOURCE
	move.l	#logo14,DEST
	bsr	DECALAGE

	move.l	#logo14,SOURCE
	move.l	#logo15,DEST
	bsr	DECALAGE

	move.l	#logo15,SOURCE
	move.l	#logo16,DEST
	bsr	DECALAGE

	bsr	precalc

;	move.w	#0,-(sp)
;	move.l	phy,-(sp)
;	move.l	log,-(sp)
;	move.w	#5,-(sp)
;	trap	#14
;	add.l	#12,sp

;	dc.w	$a00a
;	move.b	#$12,$fffffc02.w

	moveq	#2,d0
	jsr	zik

	move.l	log,a0
	move.l	phy,a1
	move.w	#(38*230+160)/4,d0
	
bo4	move.l	#0,(a0)+
	move.l	#0,(a1)+
	dbf	d0,bo4

	move.l	log,a0
	lea	38*230+160(a0),a0
	move.l	phy,a1
	lea	38*230+160(a1),a1
	lea	fond+34+39*160,a2
	move.w	#6440-1,d0
eff	move.l	(a2),(a1)+
	move.l	(a2)+,(a0)+
	dbf	d0,eff

	move.b	$ffFFFA09.w,SAV09
	move.b	$FFffFA07.w,SAV07
	move.b	$FFFffA13.w,SAV13
	move.b	$FFFffA21.w,SAV21
	move.b	$FFFffA1B.w,SAV1B
	move.l	$120.w,SAV120

	move.b	#0,$fffffa09.w
	move.b	#0,$fffffa07.w


	move.l	$70,savvbl
	move.l	$70,savvbl2+2
	move.l	#vbl,$70

main	
	move.w	#25,nbnb
	move.l	#tab_scr,toto+2
	
	jsr	zik+8

*	move.b	#10,$ffff8800.w
*	move.b	#0,$ffff8802.w
*	move.b	#8,$ffff8800.w
*	move.b	#0,$ffff8802.w

	bsr	equalizer
	bsr	aff_bon
*	bsr	vague
	bsr	smiley
	
	bsr	SCROLL
	
	move.l	log,d0
	move.l	phy,log
	move.l	d0,phy
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.l	#8,d0
	move.b	d0,$ffff8201.w
*	move.w	#$700,$ffff8240.w	
	
	move.b	#0,vsync
wait_vbl	tst.b	vsync
	beq.s	wait_vbl


	cmp.b	#$39,$fffffc02.w
	bne	main


	move.l	savvbl,$70

	move.w	#$2700,sr

	move.b    SAV09,$FFFFFA09.w
	move.b    SAV07,$FFFFFA07.w
	move.b    SAV13,$FFFFFA13.w
	move.b    SAV1B,$FFFFFA1b.w
	move.b    SAV21,$FFFFFA21.w
	move.l    SAV120,$120.w
	
	move.w	#$2300,sr

;	dc.w	$a009
;	move.b	#$8,$fffffc02.w
		
;	lea	$ffff8240.w,a1
;	lea	savcol,a0
;	move.w	#15,d0
;savc2	move.w	(a0)+,(a1)+
;	dbf	d0,savc2

	moveq	#0,d0
	jsr	zik
	jsr	zik+8
	

;	move.l	savusp,-(sp)
;	move.w	#$20,-(sp)
;	trap	#1
;	addq.l	#6,sp
;
;	clr.w	-(sp)
;	trap	#1
;
	MOVEQ	#0,D0
	JMP	$500.W

vbl	
	and.b	#$DF,$ffFFFA09.w
	and.b	#$FE,$ffFFFA07.w
	or.b	#1,$ffFFFA07.w
	or.b	#1,$ffFFFA13.w
	clr.b     $FFFFFA1B.w
	move.l    #rout3,$120.w
	move.b    #40,$FFFFFA21.w
	move.b    #8,$FFFFFA1B.w
	move.b	#32,nbli1
	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	logo+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	vague

*	move.w	#$2700,sr

	lea	$FFFF8209.w,A3
	lea	$FFFF8260.w,A1
	lea	$FFFF820A.w,A0		* 12
	moveq	#0,D4
	moveq	#2,D3
	moveq	#$10,D6
	
SYNCHRO2	MOVE.B	(A3),D7
	BEQ.S	SYNCHRO2
	SUB.W	D7,D6		* 4
	LSL.W	D6,D6		* 6

	rept	97
	NOP			* 97*4=388
	endr

	rept	38

	MOVE.B	D3,(A1)	* HIRES	* 9
	nop
	MOVE.B	D4,(A1)	* LOWRES	* 9

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
				
	MOVE.B	D4,(A0)	* 60 HZ	* 9
	MOVE.B	D3,(A0)	* 50 HZ	* 9
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	


	MOVE.B	D3,(A1)	* HIRES	* 9
	NOP			* 4
	MOVE.B	D4,(A1)	* LOWRES	* 9
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	
	nop
	endr

	movem.l	(sp)+,d0-d7/a0-a6
	move.b	#1,vsync
	
*	move.w	#$700,$ffff8240.w
	rte
savvbl2	jmp	0.L

equalizer
	moveq	#0,d0
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#15,d0
	moveq	#0,d1
	move.b	vol1,d1
	cmp.b	d1,d0
	beq.s	equal1
	bgt.s	plus1
moins1	subq.b	#1,d1
	bra	equal1
plus1	addq.b	#1,d1
equal1	move.b	d1,vol1
	move.l	d1,d0

	add.b	d0,d0
	add.b	d0,d0
	moveq	#64,d1
	sub.b	d0,d1

	lea	tab_co+64,a0
	sub.l	d1,a0
	move.l	a0,pttabco1

	moveq	#0,d0
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#15,d0
	moveq	#0,d1
	move.b	vol2,d1
	cmp.b	d1,d0
	beq.s	equal2
	bgt.s	plus2
moins2	subq.b	#1,d1
	bra	equal2
plus2	addq.b	#1,d1
equal2	move.b	d1,vol2
	move.l	d1,d0

	add.b	d0,d0
	add.b	d0,d0
	moveq	#64,d1
	sub.b	d0,d1

	lea	tab_co+64,a0
	sub.l	d1,a0
	move.l	a0,pttabco2

	moveq	#0,d0
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#15,d0
	moveq	#0,d1
	move.b	vol3,d1
	cmp.b	d1,d0
	beq.s	equal3
	bgt.s	plus3
moins3	subq.b	#1,d1
	bra	equal3
plus3	addq.b	#1,d1
equal3	move.b	d1,vol3
	move.l	d1,d0

	add.b	d0,d0
	add.b	d0,d0
	moveq	#64,d1
	sub.b	d0,d1

	lea	tab_co+64,a0
	sub.l	d1,a0
	move.l	a0,pttabco3

	rts

rout1		
	movem.l	a0-a1,-(sp)
	tst.b	nbli1
	beq.s	fin_raster
	
	rept	5
	nop
	endr
	
	move.l	pttabco1,a0
	move.l	pttabco2,a1

	move.w	(a0)+,$ffff8252.w
	move.w	(a1)+,$ffff8242.w
	
	move.l	a0,pttabco1
	move.l	a1,pttabco2

	move.l	pttabco3,a0
	move.w	(a0)+,$ffff8252.w
	move.l	a0,pttabco3

	subq.b	#1,nbli1
	
	clr.b	$FFFFFA1B.w
	move.l	#rout1,$120.w
	move.b	#1,$FFFFFA21.w
	move.b	#8,$FFFFFA1B.w
	movem.l	(sp)+,a0-a1
	bclr	#0,$fffffa0f.w
	rte
	
fin_raster
	clr.b	$FFFFFA1B.w
	move.l	#rout10,$120.w
	move.b	#54,$FFFFFA21.w
	move.b	#8,$FFFFFA1B.w
	movem.l	(sp)+,a0-a1
	bclr	#0,$fffffa0f.w
	rte

rout10
	movem.l	d0-d3,-(sp)
	movem.l	LETTRES+2,d0-d3
	movem.l	d0-d3,$ffff8240.w
	movem.l	(sp)+,d0-d3
	clr.b	$FFFFFA1B.w
	move.l	#rout11,$120.w
	move.b	#1,$FFFFFA21.w
	move.b	#8,$FFFFFA1B.w
	bclr	#0,$fffffa0f.w
	rte

rout11
toto	move.w	tab_scr,$ffff8254.w
	addq.l	#2,toto+2
	subq.w	#1,nbnb
	beq.s	fin_raster2
	clr.b	$FFFFFA1B.w
	move.l	#rout11,$120.w
	move.b	#1,$FFFFFA21.w
	move.b	#8,$FFFFFA1B.w
	bclr	#0,$fffffa0f.w
	rte
	
fin_raster2
	clr.b	$FFFFFA1B.w
	bclr	#0,$fffffa0f.w
	rte

rout2	movem.l	d0-d7,-(sp)
	movem.l	fond+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$000,$ffff8242.w
	move.w	#$000,$ffff8252.w
	clr.b	$FFFFFA1B.w
	move.l	#rout1,$120.w
	move.b	#39,$FFFFFA21.w
	move.b	#8,$FFFFFA1B.w
	movem.l	(sp)+,d0-d7
	bclr	#0,$fffffa0f.w
	rte

rout3
	clr.b	$FFFFFA1B.w
	move.l	#rout2,$120.w
	move.b	#9,$FFFFFA21.w
	move.b	#8,$FFFFFA1B.w
	
	rept	105
	nop
	endr
	movem.l	a0-a1,-(sp)
	move.l	pt_xtc,a0
	lea	$ffff8240.w,a1
	move.w	(a0)+,(a1)
	cmp.l	#ftab_xtc,a0
	bne.s	pas_fin_xtc
	
	lea	tab_xtc,a0
pas_fin_xtc
	move.l	a0,pt_xtc
	rept	40
	move.w	(a0)+,(a1)
	endr
	move.w	#$0,$ffff8240.w
	movem.l	(sp)+,a0-a1
	bclr	#0,$fffffa0f.w
	rte

*rout4
*	move.w	#$000,$ffff8240.w
*	clr.b	$FFFFFA1B.w
*	move.l	#rout2,$120.w
*	move.b	#8,$FFFFFA21.w
*	move.b	#8,$FFFFFA1B.w
*	bclr	#0,$fffffa0f.w
*	rte


aff_bon
	moveq	#0,d0
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#15,d0
	lsr.b	#1,d0
	lea	batteur+34,a0
	add.b	d0,d0
	add.b	d0,d0
	lea	table_bat,a1
	move.l	(a1,d0.w),d0
	add.l	d0,a0
	
	move.l	log,a1
	lea	38*230+30*160+88(a1),a1
	
st	set	0
	rept	32
	movem.l	st(a0),d0-d5
	movem.l	d0-d5,st(a1)
st	set	st+160
	endr

	moveq	#0,d0
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#15,d0
	lsr.b	#1,d0
	lea	autres+34,a0
	mulu	#16,d0
	add.l	d0,a0
	move.l	log,a1
	lea	38*230+(59-38)*160+112+16(a1),a1

st	set	0	
	rept	40
	movem.l	st(a0),d0-d3
	movem.l	d0-d3,st(a1)
st	set	st+160
	endr

	moveq	#0,d0
	move.b	#10,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#15,d0
	lsr.b	#1,d0
	lea	autres+34+40*160,a0
	mulu	#16,d0
	add.l	d0,a0
	move.l	log,a1
	lea	38*230+(59-38)*160+112(a1),a1

st	set	0	
	rept	40
	movem.l	st(a0),d0-d3
	movem.l	d0-d3,st(a1)
st	set	st+160
	endr

	rts

vague
	move.l	pt_tab,a0
	move.l	log,a1
	lea	160(a1),a1
	move.l	a1,a3

ecr	set	0
spr	set	0
	rept	38

	move.l	(a0)+,d0
	move.l	(a0)+,a2
	move.l	a3,a1
	add.l	d0,a1

	movem.l	spr(a2),d0-d7/a4-a6
	movem.l	d0-d7/a4-a6,ecr(a1)

	movem.l	spr+44(a2),d0-d7/a4-a6
	movem.l	d0-d7/a4-a6,ecr+44(a1)

	movem.l	spr+88(a2),d0-d7/a4-a6
	movem.l	d0-d7/a4-a6,ecr+88(a1)

	movem.l	spr+132(a2),d0-d6
	movem.l	d0-d6,ecr+132(a1)

ecr	set	ecr+230
spr	set	spr+160
	endr

	add.l	#8,pt_tab
	lea	ftable,a0
	cmp.l	pt_tab,a0
	bne	cont
	move.l	#table,pt_tab
cont	
	rts		

DECALAGE	
	movem.l	D0-D7/A0-A6,-(SP)

	move.l	SOURCE,A0
	move.l	DEST,A1
	moveq.l	#0,D1

	move.w	#37,d7
PREDEC12
	move.w	#19,d0
PREDEC11	move.w	(A0),D1
	roxr.w	D1
	move.w	D1,(A1)
	add.l	#8,A0
	add.l	#8,A1
	dbf	D0,PREDEC11
	dbf	D7,PREDEC12

	move.l	SOURCE,A0
	move.l	DEST,A1
	moveq.l	#0,D1

	move.w	#37,d7
PREDEC22
	move.w	#19,d0
PREDEC21	move.w	2(A0),D1
	roxr.w	D1
	move.w	D1,2(A1)
	add.l	#8,A0
	add.l	#8,A1
	dbf	D0,PREDEC21
	dbf	D7,PREDEC22

	move.l	SOURCE,A0
	move.l	DEST,A1
	moveq.l	#0,D1

	move.w	#37,d7
PREDEC32
	move.w	#19,d0
PREDEC31	move.w	4(A0),D1
	roxr.w	D1
	move.w	D1,4(A1)
	add.l	#8,A0
	add.l	#8,A1
	dbf	D0,PREDEC31
	dbf	D7,PREDEC32

	move.l	SOURCE,A0
	move.l	DEST,A1
	moveq.l	#0,D1

	move.w	#37,d7
PREDEC42
	move.w	#19,d0
PREDEC41	move.w	6(A0),D1
	roxr.w	D1
	move.w	D1,6(A1)
	add.l	#8,A0
	add.l	#8,A1
	dbf	D0,PREDEC41
	dbf	D7,PREDEC42


	movem.l	(SP)+,D0-D7/A0-A6
	rts

DECAL_UN
	movem.l	d0-d1/a0-a1,-(sp)

	lea	logo+34,a0
	lea	logo1,a1
	move.l	#159,d0		* largeur-1
	move.l	#37,d1		* hauteur-1
trans_un	move.b	(a0)+,(a1)+
	dbf	d0,trans_un
	move.l	#159,d0
	add.l	#160-160,a0
	dbf	d1,trans_un

	movem.l	(sp)+,d0-d1/a0-a1
	rts

precalc
	lea	table,a0
	lea	logo1,a1

bo_calc	move.l	a1,a2
	move.l	(a0),d0
	cmp.l	#-1,d0
	beq	fin_calc
	add.l	#-20,d0
	move.l	d0,d1
	lsr.l	#4,d1
	lsl.l	#3,d1
	move.l	d1,(a0)+
	and.l	#15,d0
	mulu	#6080+38*8,d0
	add.l	d0,a2
	move.l	a2,(a0)+
	bra	bo_calc	
fin_calc
	rts

smiley
	move.l	log,a0
	lea	38*230+(120-38)*160+6*16(a0),a0
	lea	smileyd+34,a2
	move.l	pt_sm1,a1
	move.l	(a1)+,d0
	cmp.l	#ftab_sm1,a1
	bne.s	pas_fin_sm1
	lea	tab_sm1,a1
pas_fin_sm1
	move.l	a1,pt_sm1
	add.l	d0,a2
st	set	0
	rept	16
	movem.l	st(a2),d0-d1
	movem.l	d0-d1,st(a0)
st	set	st+160
	endr

	move.l	log,a0
	lea	38*230+(120-38)*160+7*16(a0),a0
	lea	smileyd+34+16*160,a2
	move.l	pt_sm2,a1
	move.l	(a1)+,d0
	cmp.l	#ftab_sm2,a1
	bne.s	pas_fin_sm2
	lea	tab_sm2,a1
pas_fin_sm2
	move.l	a1,pt_sm2
	add.l	d0,a2
st	set	0
	rept	16
	movem.l	st(a2),d0-d1
	movem.l	d0-d1,st(a0)
st	set	st+160
	endr

	move.l	log,a0
	lea	38*230+(120-38)*160+8*16(a0),a0
	lea	smileyd+34+32*160,a2
	move.l	pt_sm3,a1
	move.l	(a1)+,d0
	cmp.l	#ftab_sm3,a1
	bne.s	pas_fin_sm3
	lea	tab_sm3,a1
pas_fin_sm3
	move.l	a1,pt_sm3
	add.l	d0,a2
st	set	0
	rept	16
	movem.l	st(a2),d0-d1
	movem.l	d0-d1,st(a0)
st	set	st+160
	endr

	rts
	
BADCAR	LEA	BUF,A0
	BRA	CONTBADC

REPC	EXT.W	D0
	NEG.W	D0
	MOVE.B	(A0)+,D1
LOOPREPC	MOVE.B	D1,(A1)+
	DBF	D0,LOOPREPC
	BRA	LOOPDECT

DECT	LEA	TEXTEINI,A0
	LEA	TEXTE,A1
LOOPDECT	MOVE.B	(A0)+,D0
	CMPI.B	#-1,D0
	BEQ	FINDECT
	TST.B	D0
	BLT.S	REPC
SPACE	CMP.B	#32,D0
	BNE	EXCLA
	MOVE.B	#49,(A1)+
	BRA	FINTST
EXCLA	CMP.B	#33,D0
	BNE	INTER
	MOVE.B	#26,(A1)+
	BRA	FINTST
INTER	CMP.B	#63,D0
	BNE	DEPNTS
	MOVE.B	#27,(A1)+
	BRA	FINTST
DEPNTS	CMP.B	#58,D0
	BNE	PVIR
	MOVE.B	#28,(A1)+
	BRA	FINTST
PVIR	CMP.B	#59,D0
	BNE	GUILLE
	MOVE.B	#29,(A1)+
	BRA	FINTST
GUILLE	CMP.B	#34,D0
	BNE	APOS
	MOVE.B	#40,(A1)+
	BRA	FINTST		
APOS	CMP.B	#39,D0
	BNE	PAROUV
	MOVE.B	#46,(A1)+
	BRA	FINTST		
PAROUV	CMP.B	#40,D0
	BNE	PARFER
	MOVE.B	#41,(A1)+
	BRA	FINTST		
PARFER	CMP.B	#41,D0
	BNE	VIRG
	MOVE.B	#42,(A1)+
	BRA	FINTST		
VIRG	CMP.B	#44,D0
	BNE	MOINS
	MOVE.B	#43,(A1)+
	BRA	FINTST		
MOINS	CMP.B	#45,D0
	BNE	POINT
	MOVE.B	#44,(A1)+
	BRA	FINTST		
POINT	CMP.B	#46,D0
	BNE	CHIFFRES
	MOVE.B	#45,(A1)+
	BRA	FINTST		
CHIFFRES	CMP.B	#57,D0
	BGT	CAR
	SUB.B	#18,D0
	MOVE.B	D0,(A1)+
	BRA	FINTST	
CAR	SUB.L	#65,D0
	MOVE.B	D0,(A1)+
FINTST	CMPA.L	#FTEXTE,A0
	BLT	LOOPDECT
FINDECT	SUBA.L	#1,A1
	MOVE.L	A1,FINTEXT
	MOVE.B	#47,(A1)+
	MOVE.B	#47,(A1)+
	RTS

SCROLL	MOVEA.L	log,A1
	ADDA.L	#38*230+137*160,A1
	LEA	8(A1),A0
LOOPSCROLL		
	rept	1000
	MOVE.L	(a0)+,(a1)+
	endr

	LEA	TEXTE,A0
	ADDA.L	PLET,A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	EXT.W	D0
	CMPA.L	FINTEXT,A0
	BNE	NFINT
	MOVE.L	#0,PLET
	MOVE.W	#0,TLET
	BRA	BADCAR
NFINT	TST.W	D0
	BLT	BADCAR

	CMPI.W	#$32,D0	*	caractere maxi

	BGE	BADCAR
	MOVE.L	D0,D1
	DIVU	#$A,D1
	MOVE.W	D1,D2
	MULU	#$A,D2
	SUB.W	D2,D0
	LEA	LETTRES+34,A0
	LSL.W	#4,D0
	MULU	#4000,D1
	ADD.L	D1,D0
	ADDA.L	D0,A0
CONTBADC	MOVEA.L	log,A1
	ADDA.L	#38*230+137*160+152,A1		* A1=156*160+152
	CMPI.W	#3,TLET
	BNE	SC1
	MOVEA.L	A1,A2
	
	rept	24
	
	MOVE.B	(A0),1(A1)
	MOVE.B	2(A0),3(A1)	
	MOVE.B	4(A0),5(A1)
	MOVE.B	6(A0),7(A1)
	LEA	$A0(A0),A0
	LEA	$A0(A1),A1
	
	endr
	
	
	MOVEA.L	A2,A1
	MOVEA.L	OLDL,A0
	
	
	rept	24
	
	MOVE.B	9(A0),(A1)
	MOVE.B	$B(A0),2(A1)
	MOVE.B	$D(A0),4(A1)
	MOVE.B	$F(A0),6(A1)
	LEA	$A0(A0),A0
	LEA	$A0(A1),A1
	
	endr
	
	BRA	FINSCROLL
SC1	CMPI.W	#2,TLET
	BNE	SC2
	MOVE.L	A0,OLDL
	
	
	rept	24
	
	
	MOVE.L	(A0),(A1)
	MOVE.L	4(A0),4(A1)
	LEA	$A0(A0),A0
	LEA	$A0(A1),A1
	
	endr
	
	BRA	FINSCROLL

SC2	CMPI.W	#1,TLET
	BNE	SC3
	SUBA.L	#8,A1
	
	
	rept	24
	
	MOVE.B	1(A0),8(A1)
	MOVE.B	3(A0),$A(A1)
	MOVE.B	5(A0),$C(A1)
	MOVE.B	7(A0),$E(A1)
	MOVE.B	8(A0),9(A1)
	MOVE.B	$A(A0),$B(A1)
	MOVE.B	$C(A0),$D(A1)
	MOVE.B	$E(A0),$F(A1)
	LEA	$A0(A0),A0
	LEA	$A0(A1),A1
	
	endr
	
	
	
	BRA	FINSCROLL

SC3	SUBA.L	#8,A1
	
	rept	24
	
	MOVE.L	(A0),(A1)
	MOVE.L	4(A0),4(A1)
	MOVE.L	8(A0),8(A1)
	MOVE.L	$C(A0),$C(A1)
	LEA	$A0(A0),A0
	LEA	$A0(A1),A1
	
	endr
	

	ADDI.L	#1,PLET
	MOVE.W	#4,TLET
	BRA	FINSCROLL

FINSCROLL	SUBI.W	#1,TLET
	RTS
	
	
	section	data

tab_scr
	dc.w	$001,$002,$003,$004
	dc.w	$005,$006,$007,$107
	dc.w	$207,$307,$407,$507
	dc.w	$607,$707,$706,$705
	dc.w	$704,$703,$702,$701
	dc.w	$700,$710,$720,$730
	dc.w	$740,$750,$760,$770

tab_sm1
	dc.l	0,0,8,8,16,16,24,24,32,32,40,40,48,48,56,56,64,64,72,72,80,80
	dc.l	88,88,96,96
ftab_sm1

tab_sm2
	dc.l	0,0,0,8,8,8,16,16,16,24,24,24,32,32,32,40,40,40
ftab_sm2

tab_sm3
	dc.l	0,0,0,0,8,8,8,8,16,16,16,16,24,24,24,24,32,32,32,32,40,40,40,40
ftab_sm3
pt_sm1	dc.l	tab_sm1
pt_sm2	dc.l	tab_sm2
pt_sm3	dc.l	tab_sm3+8

table_bat
	dc.l	0,24,48,72,96,120,32*160,32*160+24
	
smileyd	incbin	"spr3.pi1"
	even

fond	incbin	"fond2.pi1"
	even

zik	incbin	"ancool2.mus"
	even

batteur	incbin	"spr1.pi1"
	even

autres	incbin	"spr2.pi1"
	even

logo	incbin	"transboc.pi1"
	even
table	
	rept	45
	dc.l	83
	dc.l	83
	endr

*	incbin	"large1.sin"
ggg	incbin	"large2.sin"
ftable	
	rept	45
	dc.l	83
	dc.l	83
	endr
	dc.l	-1
	dc.l	-1
	dc.l	-1
	dc.l	-1

pt_tab	dc.l	table
	
tab_co
	ds.w	32
	dc.w	$770,$771,$772,$773,$774,$775,$776
	dc.w	$777,$677,$577,$477,$377,$277,$177,$077
	dc.w	$076,$075,$074,$073,$072,$071,$070
	dc.w	$170,$270,$370,$470,$570,$670,$770
	dc.w	$760,$750,$740,$730,$720,$710,$700
tab_xtc
	rept	100
	dc.w	$0
	endr
	dc.w	$100,$200,$300,$400,$500,$600
	dc.w	$700,$700,$710,$710,$720,$720,$730,$730,$740,$740,$750,$750,$760,$760,$770,$770
	dc.w	$077,$077,$076,$076,$075,$075,$074,$074,$073,$073,$072,$072,$071,$071,$070,$070
	dc.w	$060,$050,$040,$030,$020,$010
	rept	100
	dc.w	$0
	endr
ftab_xtc
	rept	400
	dc.w	$0
	endr 
pt_xtc	dc.l	tab_xtc

TEXTEINI	dc.b	"                                             "
	dc.b	"INTRO CODEE PAR LES BUSH QUELQUE CHOSE !!!!!     ",-1

LETTRES	incbin	"tcb1.PI1"
	even

OLDL	dc.l	LETTRES+4*160*32+144



	section	bss

attente	ds.b	1
SAV07	ds.b	1
SAV09	ds.b	1
SAV13	ds.b	1
SAV1B	ds.b	1
SAV21	ds.b	1
nbli1	ds.b	1
vsync	ds.b	1
vol1	ds.b	1
vol2	ds.b	1
vol3	ds.b	1
	even
SAV120	ds.l	1
log	ds.l	1
phy	ds.l	1
savcol	ds.w	16
savusp	ds.l	1
pttabco1	ds.l	1
pttabco2	ds.l	1
pttabco3	ds.l	1
savvbl	ds.l	1
logo1	ds.b	6080+38*8
logo2	ds.b	6080+38*8
logo3	ds.b	6080+38*8
logo4	ds.b	6080+38*8
logo5	ds.b	6080+38*8
logo6	ds.b	6080+38*8
logo7	ds.b	6080+38*8
logo8	ds.b	6080+38*8
logo9	ds.b	6080+38*8
logo10	ds.b	6080+38*8
logo11	ds.b	6080+38*8
logo12	ds.b	6080+38*8
logo13	ds.b	6080+38*8
logo14	ds.b	6080+38*8
logo15	ds.b	6080+38*8
logo16	ds.b	6080+38*8
SOURCE	ds.l	1
nbnb	ds.w	1
DEST	ds.l	1
FINTEXT	ds.l	1
PLET	ds.l	1
TLET	ds.l	1
FTEXTE	ds.l	1
TEXTE	ds.l	1000
BUF	ds.b	5048
ecran1	ds.b	34916
ecran2	ds.b	34916
fin	end
