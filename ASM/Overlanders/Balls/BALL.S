************************************************
* The ziggy BALL-DEMO, for the DELIRIOUS-DEMO. *
*         (C) 1989 Ziggy STARDUST.	       *
*		OVERLANDERS		       *
************************************************
* OUR ADRESSES FOR YOUR DONATIONS:             *
************************************************
* OVERLANDERS/THE ALLLIANCE                    *
* 105,RUE COSTA DE BEAUREGARD                  *
* 73000 CHAMBERY                               *
* FRANCE                                       *
************************************************
* OR:                                          *
************************************************
* OVERLANDERS/THE ALLIANCE                     *
* 27,CHEMIN DES CYCLAMENS                      *
* 73000 CHAMBERY                               *
* FRANCE                                       *
************************************************
* Please use this source in no file..          *
************************************************


	section	text
	
testv	equ	0

	include	util.s
startprog:
	START
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#4,a7
	jmp	main
	
SETSCREEN	macro
	move.w	\3,-(a7)
	move.l	\2,-(a7)
	move.l	\1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	endm
	
repc:
	ext.w	d0
	neg.w	d0
	move.b	(a0)+,d1
looprepc:
	move.b	d1,(a1)+
	dbra	d0,looprepc
	bra	loopdect
althelp:
	rts
	
main:
	move.l	#althelp,$502	; Pas de hardcopy.
	move.b	#18,$fffc02	; Pas de souris non plus.
	move.b	$ff8260,d0
	ext.w	d0
	move.w	d0,oldrez
	move.l	#ecran,d0
	addi.l	#256,d0
	andi.l	#$ffffff00,d0
	move.l	d0,ec1
	addi.l	#256*160,d0
	move.l	d0,ec2
	move.l	$44e,oldec
	move.l	#oldpos,opos1
	move.l	#oldpos+20*4,opos2
	move.l	#ptexte,cpt
	
	SETSCREEN	ec1,ec1,#0
	VSYNC
	
	lea	texteini,a0
	move.l	texte,a1
loopdect:
	move.b	(a0)+,d0
	cmpi.b	#-127,d0
	beq	findect
	tst.b	d0
	blt	repc
	move.b	d0,(a1)+
	cmpa.l	#ftex,a0
	blt	loopdect
	
findect:
	suba.l	#1,a1
	move.l	a1,fintexte
	move.b	#50,(a1)+
	move.b	#50,(a1)+
	
	lea	boule,a1		; On fait les decalage des boules
					; d'avance, pour aller plus vite!!!
	lea	alliance,a0
	
	move.w	#4,d0
loopdecb:
	
	move.w	#15,d1
loopdecb2:
	move.w	#15,d7
loopdecb3:
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d6
	move.w	(a0),d2
	move.w	2(a0),d3
	move.w	d2,d6
	or.w	d3,d6
	lsl.l	d1,d2
	lsl.l	d1,d3
	lsl.l	d1,d6
	not.l	d6
	
	move.l	d6,(a1)+
	swap	d2
	swap	d3
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	swap	d2
	swap	d3
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	
	adda.l	#160,a0
	dbra	d7,loopdecb3
	
	suba.l	#16*160,a0
	dbra	d1,loopdecb2

	adda.l	#8,a0		; Prochaine boule.
	dbra	d0,loopdecb
	
	lea	alliance,a0	; Efface les boules de l'‚cran alliance.
	move.w	#40*16,d0
loopclb:
	clr.l	(a0)+
	dbra	d0,loopclb
	
	lea	masque,a1
	lea	alliance,a0	; Construction du masque de ALLIANCE.
	move.w	#20*200-1,d0
loopmask:
	move.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	not.w	d1
	move.w	d1,(a1)+
	
	dbra	d0,loopmask
	
	VSYNC
	jsr	inter		; Overscan.

	move.w	#0,d0
	jsr	setmusic	; Music on.
 
	lea	alliance,a0
	move.l	ec1,a1
	move.w	#199,d0
	jsr	bmove32
	lea	alliance,a0
	move.l	ec2,a1
	move.w	#199,d0
	jsr	bmove32
	
	lea	ttaille,a0	; On calcul les tailles des petite lettres
	move.w	#1,d0
looptaille:
	move.w	#-8,d1
looptaille2:
	move.w	d1,d2
	cmpi.w	#5,d0
	beq	n5
	muls	d0,d2
	divs	#4,d2
n5:
	muls	#160,d2
	move.w	d2,(a0)+
	addq.w	#1,d1
	cmpi.w	#8,d1
	blt	looptaille2

	addq.w	#1,d0
	cmpi.w	#5,d0
	ble	looptaille
	
mainloop:
	move.l	ec1,a0
	move.l	ec2,ec1
	move.l	a0,ec2
	SETSCREEN	ec1,ec2,#-1
	ifne	testv
	move.w	#$777,$ff8240
	endc
	VSYNC
	ifne	testv
	move.w	#$000,$ff8240
	endc
	
	move.w	curdegr,d0
	add.w	sensdegr,d0
	tst.w	d0
	bgt	ok0degr
	move.w	#1,sensdegr
ok0degr:
	cmpi.w	#50,d0
	blt	ok50degr
	move.w	#-1,sensdegr
ok50degr:
	move.w	d0,curdegr
	
	move.l	opos1,a0
	move.l	opos2,opos1
	move.l	a0,opos2
		
	move.l	opos1,a6
	
	move.w	#15,d0
loopeffsp:
	move.l	(a6)+,d1
	lea	alliance,a0
	adda.l	d1,a0
	move.l	ec1,a1
	adda.l	d1,a1
	rept	16
	move.l	(a0),(a1)
	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
	move.l	12(a0),12(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	endr

	dbra	d0,loopeffsp
	move.l	a6,olda6
	
affpl:				; Affichage des petite lettres.
	clr.w	d5
	move.l	cpt,a6
	move.w	pospt,d7
	addq.w	#1,d7
	cmpi.w	#150,d7
	blt	ok150
	move.w	#-11,pospt
	add.l	#20,cpt
	bra	affpl
ok150:
	move.w	d7,pospt
	lsr.w	#1,d7
	subi.w	#1,d7
looppt1:
	move.w	d7,d4
	cmpi.w	#5,d5
	bge	p2
	addi.w	#20,d4
p2:
	move.b	(a6,d4.w),d0

	addq.w	#1,d7
	addq.w	#1,d5
	cmpi.w	#8,d5
	bgt	finipt
	tst.w	d7
	blt	looppt1
	cmpi.w	#20,d7
	bge	looppt1
	cmpi.b	#-1,d0
	bne	goodcar
	move.l	#ptexte,cpt
	move.l	#ptexte,a6

	bra	looppt1
goodcar:
	ext.w	d0
	cmpi.w	#'a',d0
	blt	space
	cmpi.w	#'z',d0
	bgt	space
	subi.w	#'a',d0
	move.w	d0,d1
	ext.l	d1
	divs	#19,d1
	move.w	d1,d2
	muls	#19,d2
	sub.w	d2,d0
	asl.w	#3,d0
	mulu	#16*160,d1
	ext.l	d0

	lea	plettres+34,a0
	adda.l	d0,a0
	adda.l	d1,a0
	move.l	ec1,a1
	move.w	d7,d2
	asl.w	#3,d2
	ext.l	d2
	adda.l	d2,a1
	adda.l	#20*160,a1
	lea	alliance+20*160,a2
	adda.l	d2,a2
	lea	ttaille,a5
	move.w	d5,d0
	subi.w	#5,d0
	tst.w	d0
	bge	posn
	neg.w	d0
posn:
	lsl.w	#5,d0
	lea	(a5,d0.w),a5

	rept	16
	move.w	(a5)+,d1
	lea	(a1,d1.w),a3
	lea	(a2,d1.w),a4
	move.l	(a0),d0
	move.l	d0,(a3)
	move.l	d0,(a4)
	move.l	4(a0),d0
	move.l	d0,4(a3)
	move.l	d0,4(a4)
	adda.l	#160,a0
	endr
	
	bra	looppt1
	
space:
	move.l	ec1,a1
	move.w	d7,d2
	asl.w	#3,d2
	ext.l	d2
	adda.l	d2,a1
	adda.l	#12*160,a1
	lea	alliance+12*160,a2
	adda.l	d2,a2
	move.w	#15,d0
	moveq.l	#0,d1
loopaffpl2:
	move.l	d1,(a1)
	move.l	d1,(a2)
	move.l	d1,4(a1)
	move.l	d1,4(a2)
	lea	160(a1),a1
	lea	160(a2),a2
	dbra	d0,loopaffpl2
	bra	looppt1
	
finipt:
	move.l	olda6,a6
	move.w	poss,d7
	move.w	#15,d5
loopaffs:			; Affiche les sprites. 16 a la fois, 
				; pas mal, non?
	move.w	d7,d0
	addi.w	#80,d0
	lea	sinus,a0
	lsl.w	#1,d0
	move.w	(a0,d0.w),d0
	muls	#150,d0
	divs	#1000,d0
	addi.w	#152,d0
	lsl.w	#1,d7
	move.w	(a0,d7.w),d1
	lsr.w	#1,d7
	move.w	d1,d2
	muls	#90,d1
	divs	#1000,d1
	ext.l	d2
	divs	#340,d2
	neg.w	d2
	addi.w	#2,d2
	
	tst.w	curanim
	beq	ani1
	
	asr.w	#1,d1
	addi.w	#46,d1
	move.w	poss2,d3
	cmpi.w	#2,curanim
	blt	nowave
	sub.w	d7,d3
	addi.w	#320,d3
nowave:
	lsl.w	#1,d3
	move.w	(a0,d3.w),d3
	btst	#0,d5
	beq	pair
	neg.w	d1
	
pair:
	muls	d3,d1
	divs	#1000,d1
	addi.w	#92,d1
	bra	affsprite
	
ani1:
	move.w	poss2,d3
	lsl.w	#1,d3
	move.w	(a0,d3.w),d3
	muls	d3,d1
	divs	#1500,d1
	addi.w	#92,d1
	bra	affsprite
	
affsprite:			; Affiche la boule
	cmpi.w	#1,d2
	bgt	bigspr
	
	jsr	affspr
	bra	littlespr
	
bigspr:
	jsr	affspr2
	
littlespr:
	move.l	d6,-(a6)	;Sauvegarde la pos. du sprite.

	addi.w	#20,d7
	cmpi.w	#320,d7
	blt	ok320b
	subi.w	#320,d7
ok320b:
	dbra	d5,loopaffs
	
	move.w	poss,d0
	addq.w	#2,d0
	cmpi.w	#320,d0
	blt	ok320
	subi.w	#320,d0
ok320:
	move.w	d0,poss

	move.w	poss2,d0
	addq.w	#1,d0
	cmpi.w	#320,d0
	blt	ok3203
	subi.w	#320,d0
	addi.w	#1,curanim
	cmpi.w	#6,curanim
	bne	ok3203
	clr.w	curanim
ok3203:
	move.w	d0,poss2

	move.l	ec1,a1		; Scrolling lettres
	adda.l	#201*160,a1
	lea	8(a1),a0
	move.w	#22,d0
loopscroll:
	move.l	(a0),(a1)
	move.l	8(a0),8(a1)
	move.l	16(a0),16(a1)
	move.l	24(a0),24(a1)
	move.l	32(a0),32(a1)
	move.l	40(a0),40(a1)
	move.l	48(a0),48(a1)
	move.l	56(a0),56(a1)
	move.l	64(a0),64(a1)
	move.l	72(a0),72(a1)
	move.l	80(a0),80(a1)
	move.l	88(a0),88(a1)
	move.l	96(a0),96(a1)
	move.l	104(a0),104(a1)
	move.l	112(a0),112(a1)
	move.l	120(a0),120(a1)
	move.l	128(a0),128(a1)
	move.l	136(a0),136(a1)
	move.l	144(a0),144(a1)
	move.l	152(a0),152(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	dbra	d0,loopscroll
	
	move.l	texte,a0
	adda.l	plet,a0
	moveq.l	#0,d0
	move.b	(a0),d0
	ext.w	d0
	cmp.l	fintexte,a0
	bne	nfint
	move.l	#0,plet
	move.w	#4,tlet
	bra	badcar
nfint:
	tst.w	d0
	blt	badcar
	cmpi.w	#50,d0
	bge	badcar
	
	move.l	d0,d1
	divu	#10,d1
	move.w	d1,d2
	mulu	#10,d2
	sub.w	d2,d0
	lea	lettres+34,a0
	lsl.w	#4,d0
	mulu	#24*160,d1
	add.l	d1,d0
	add.l	d0,a0
contbadc:
	move.l	ec1,a1
	adda.l	#201*160+9*16+8,a1
	
	cmpi.w	#3,tlet
	bne	sc1
	move.l	a1,a2
	
	rept	23
	move.b	0(a0),1(a1)
	move.b	2(a0),3(a1)
*	move.b	4(a0),5(a1)
*	move.b	6(a0),7(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	endr
	move.l	a2,a1
	move.l	oldl,a0
	rept	23
	move.b	9(a0),(a1)
	move.b	11(a0),2(a1)
*	move.b	13(a0),4(a1)
*	move.b	15(a0),6(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	endr
	
	bra	finscroll
	
sc1:	
	cmpi.w	#2,tlet
	bne	sc2
	
	move.l	a0,oldl
	rept	23
	move.l	(a0),(a1)
*	move.l	4(a0),4(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	endr
	bra	finscroll
	
sc2:
	cmpi.w	#1,tlet
	bne	sc3
	
	suba.l	#8,a1
	rept	23
	move.b	1(a0),8(a1)
	move.b	3(a0),10(a1)
*	move.b	5(a0),12(a1)
*	move.b	7(a0),14(a1)
	move.b	8(a0),9(a1)
	move.b	10(a0),11(a1)
*	move.b	12(a0),13(a1)
*	move.b	14(a0),15(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	endr
	bra	finscroll
sc3:
	suba.l	#8,a1
	rept	23
	move.l	(a0),(a1)
*	move.l	4(a0),4(a1)
	move.l	8(a0),8(a1)
*	move.l	12(a0),12(a1)
	lea	160(a0),a0
	lea	160(a1),a1
	endr
	addi.l	#1,plet
	move.w	#4,tlet
	bra	finscroll
	
finscroll:
	subi.w	#1,tlet

	move.w	#$b,-(a7)
	trap	#1
	addq.l	#2,a7
	tst.l	d0
	beq	mainloop
	
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	
	cmpi.w	#' ',d0
	beq	fin
	
	jmp	mainloop
badcar:
	lea	lettres+34+160*160+304,a0
	bra	contbadc
	
fin:
	clr.l	$4d2
	move.w	#7,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	VSYNC
	jsr	nointer
	SETSCREEN	oldec,oldec,oldrez
	move.b	#8,$fffc02	; Revoila la souris.
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#2,a7
	trap	#1
	
affspr:				; Sprites normaux(?)
	move.w	d0,d3
	and.w	#$f,d3
	mulu	#192,d3
	mulu	#192*16,d2
	add.l	d3,d2
	lea	boule,a0
	adda.l	d2,a0
	lsr.w	#4,d0
	lsl.w	#3,d0
	ext.l	d0
	move.l	ec1,a1
	mulu	#160,d1
	add.l	d0,d1
	adda.l	d1,a1
	move.l	d1,d6
	
	rept	16
	move.l	(a0)+,d1
	move.l	d1,d2
	move.w	d1,d3
	swap	d2
	move.w	d2,d1
	move.w	d3,d2
	and.l	d1,(a1)
	and.l	d1,4(a1)
	and.l	d2,8(a1)
	and.l	d2,12(a1)
	
	move.l	(a0)+,d0
	or.l	d0,(a1)
	move.l	(a0)+,d0
	or.l	d0,8(a1)
	
	lea	160(a1),a1
	endr
	
	rts
	
affspr2:			; Sprites qui passent derrieres le ALLIANCE
	move.w	d0,d3
	and.w	#$f,d3
	mulu	#192,d3
	mulu	#192*16,d2
	add.l	d3,d2
	lea	boule,a0
	adda.l	d2,a0
	lsr.w	#4,d0
	lsl.w	#3,d0
	ext.l	d0
	move.l	ec1,a1
	mulu	#160,d1
	add.l	d0,d1
	adda.l	d1,a1
	move.l	d1,d6
	lsr.l	#2,d1
	lea	masque,a2
	adda.l	d1,a2
	
	rept	16
	addq.l	#4,a0
	
	move.w	(a2),d4
	swap	d4
	move.w	(a2),d4
	move.l	(a0)+,d0
	and.l	d4,d0
	or.l	d0,(a1)
	move.w	2(a2),d4
	swap	d4
	move.w	2(a2),d4
	move.l	(a0)+,d0
	and.l	d4,d0
	or.l	d0,8(a1)
	
	lea	160(a1),a1
	lea	40(a2),a2
	endr
	
	rts
	
inter:	
	lea	$fffa00,a0
	lea	ancvec,a6
	move.b	$07(a0),(a6)
	move.b	$13(a0),1(a6)
	move.b	$1b(a0),2(a6)
	move.b	$21(a0),3(a6)
	move.l	$120,4(a6)
	clr.b	$01b(a0)
	bset	#$0,$7(a0)
	bset	#$0,$13(a0)
	bclr	#5,$fffa09
	move.l	#overscan,$120
	
	lea	midi_or+2,a0
	move.l	$118,(a0)
	lea	midi,a0
	move.l	a0,$118
	
	lea	vbl_orig+2,a0
	move.l	$70,(a0)
	lea	vbl,a0
	move.l	a0,$70
	rts
	
nointer	move.w	#$2700,sr
	lea	$0fffa00,a0
	lea	ancvec,a6
	move.b	(a6),$07(a0)
	move.b	1(a6),$13(a0)
	move.b	2(a6),$1b(a0)
	move.b	3(a6),$21(a0)
	move.l	4(a6),$0120
	bset	#5,$fffa09
	bset	#5,$fffa09
	move.l	midi_or+2,$118
	move.l  vbl_orig+2,$70
	move.w	#$000,$ff8240
	move.w	#$777,$ff8240+3*2
	move.w	#$777,$ff8240+15*2
	rts
		
midi	move.w	#$2500,sr
midi_or	jmp	$0	

overscan:
	movem.l	a0-a1/d1,-(a7)
	
	rept	50
	nop
	endr
	moveq.l	#0,d1
	lea	$ff8209,a0
wait:
	move.b	(a0),d1
	cmp	#218,d1
	blt.s	wait
	lea	nnop-218,a0
	jmp	(a0,d1.w)
nnop:
	rept	27
	nop
	endr
	move.b	#0,$ff820a
	rept	6
	nop
	endr
	move.b	#2,$ff820a

	lea	lettres+2,a0
	lea	$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	
	clr.b	$fffa1b
	move.b	#2,$fffa21
	move.b	#8,$fffa1b
	move.l	#degr,$120
	
	movem.l	(a7)+,a0-a1/d1
	bclr	#$0,$fffa0f
	rte
	
degr:
	move.w	alliance,$ff8240+1*2
	add.l	#2,degr+2
	bclr	#$0,$fffa0f
	rte
	
changecol:
	movem.l	a0-a1,-(a7)
	
	lea	alliance+32000,a0
	lea	$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	
	clr.b	$fffa1b
	move.b	#158-44,$fffa21
	move.b	#8,$fffa1b
	move.l	#ccol2,$120
	
	movem.l	(a7)+,a0-a1
	bclr	#$0,$fffa0f
	rte
	
ccol2:
	movem.l	a0-a1/d0,-(a7)	
	lea	deg+8,a0
	move.w	curdegr,d0
	cmpi.w	#43,d0
	blt	ok43
	subi.w	#43,d0
	lsl.w	#5,d0
	lea	(a0,d0.w),a0
ok43:
	lea	$ff8240+8,a1
	rept	6
	move.l	(a0)+,(a1)+
	endr
	
	clr.b	$fffa1b
	move.b	#44,$fffa21
	move.b	#8,$fffa1b
	move.l	#overscan,$120
	
	movem.l	(a7)+,a0-a1/d0
	bclr	#$0,$fffa0f
	rte
	
vbl:
	clr.b	$fffa1b
	move.b	#40,$fffa21
	move.b	#8,$fffa1b
	move.l	#changecol,$120
	movem.l	a0-a6/d0-d7,-(a7)
	
	lea	plettres+2,a0
	lea	$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	
	move.w	curc,d0
	addi.w	#2,d0
	cmpi.w	#84*2,d0
	blt	ok94
	subi.w	#84*2,d0
ok94:
	move.w	d0,curc

	lsr.w	#1,d0	
	lsl.w	#1,d0
	lea	palette,a0
	lea	(a0,d0.w),a0
	move.l	a0,degr+2
	
	movem.l	(a7)+,a0-a6/d0-d7
	
vbl_orig jmp	$0

bmove32:
	rept	40
	move.l	(a0)+,(a1)+
	endr
	dbra	d0,bmove32
	rts

	section	data
*	ds.b	160
deg:
	incbin	degr
plettres:
	incbin	fontbubl.pi1	; Petite lettres.
lettres:
	incbin	best2.pi1	; Font.
alliance:
	incbin	alliance.art	; Logo ALLIANCE et boule.
texteini:
	incbin	texte
ftex:
	even
sinus:
	incbin	sinus
music:
	incbin	enduro.b
palette:
	incbin	palette.pal
	even
sensdegr dc.w	1
tlet	dc.w	2
plet	dc.l	0
ec1	dc.l	0
ec2	dc.l	0
texte
oldec	dc.l	0		; Ancien adresse d'ecran, et texte.
oldrez	dc.w	0
tall	dc.w	1

ptexte:
	dc.b	"                   "
	dc.b	"                    "
	dc.b	"  OVERLANDERS      "
	DC.B	"  OVERLANDERS      "
	
	dc.b	"                    "
	dc.b	"                    "
	dc.b	-1
cpt	dc.l	0
pospt	dc.w	-10

	section	bss

curpal:
	ds.l	1
boule:				; Voici les 5 boules: 15Kb!!!
	ds.b	192*16*5
ancvec:
	ds.b	256
ecran:
	ds.b	264*160*2+2048	; Les deux ecrans de 264 lignes.
curc	ds.w	1
oldl	ds.l	1
temp	ds.w	1
temp2	ds.l	1
fintexte	ds.l	1
poss	ds.w	1
poss2	ds.w	1
curanim	ds.w	1
oldpos	ds.l	40
opos1	ds.l	1
opos2	ds.l	1
masque	ds.b	8000
olda6	ds.l	1
curdegr	ds.w	1
ttaille	ds.w	5*16		; Les differentes  tailles des lettres

	section	text
ibytes	macro
	incbin	\1
	endm
	
setmusic:
	include	cud_mus2.l
	
	
				END