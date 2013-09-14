; gourand Texture map.. 25k pixel/50hz frame
; txt errors on some special case polygons..


	OPT	d+,c-,p=68030

memory		=	1500*1024

;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;

; fixed to run on vga at Imp8000, lots of little matematical bugs on 
; textures with negative steps..
; g-shade is added to texture so it's somekind of specular effect 
; and not like normal multiplicative gshade on modern pc 3d cards..
; but thenagain this code is like from year 95..
; no proper polygon setup maths.. the idea was just to try fit pixel loop
; in 6 dsp instructions ;)

vgahack = 0 	; setup to vga screen

superpixels	=	0		; 0 = disabled, 1 = enabled

	rsreset
TXtoikea	rs.l	2		;sortattu dsp feed order!!
TXToikeainc	rs.l	2
TXTvasen	rs.l	2		;y.16 - x.16
TXtvaseninc	rs.l	2
POLYbase1	rs.l	2		;x.12 - y*384*2
POLYinc		rs.l	2		;vasen.12 - oikea.12
TXTalin		rs.l	2
TXTalininc	rs.l	2
POLYbase2	rs.l	1
POLYinc2	rs.l	1
Geka		rs.l	1
Gtoka		rs.l	1
Gkolmas		rs.l	1
Yeka		rs.l	1
Ytoka		rs.l	1
Xwide		rs.l	1
Ghalf		rs.l	1
POLYflip	rs.l	1
POLYbaseY	rs.l	1

maxrs	equ	27

Overdose_Beyond_Braindamage
	include	freeintx.s
	even

DEMO:
	move.w	activepoint,d0
	move.l	(activelist,pc,d0.w*4),a0
	jsr	(a0)
	rts

viimeinen
	st 	Space_Pressed
	rts

activepoint	dc.w	0	
activelist	
	DC.L	DSP_LOAD
	DC.L	initgtmap
	DC.L	rungtmap
	dc.l	viimeinen


;------------
txtTV:
.HHT	SET 	$fe		; Horizontal Hold Timer
.HBB	SET 	$b8+10		; Horizontal Border Begin
.HBE	SET 	$30		; Horizontal Border End
.HDB	SET 	$18		; Horizontal Display Begin
.HDE	SET 	$b8		; Horizontal Display End
.HSS	SET 	$d8		; Horizontal Synchro Start

.VFT	SET	$271		; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$270		; V BORDER BLANK, dropattu color.time.zekkien takia
.VBE	SET 	$49		; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$49		; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$249		; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b		; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$183		; Video Clock
.VCO	SET	$000		; Video Control
.WIDE	set	384		;screen wide (words)
.modulo	set	0		;screen modulo
.VMODE	set	$110		;screen mode (true)
; Video Control TV Bits				3 2 1 0
;	Horizontal Resolution-------------------+-+ + +
;		00: LORES (320 Pixels)		    | |
;		01: HIRES (640 Pixels)		    | |
;		10: SUPER HIRES (1280 Pixels)	    | |
;		    (shires seems to work with	    | |
;		     16 colors only (???))	    | |
;	Interlace-----------------------------------' |
;		To enable interlacing, set VFT	      |
;		bit 0 to logic 0.		      |
;	Vertical Resolution---------------------------'
;		0: 200 lines
;		1: 100 lines

	dc.w	.HHT&$1ff,.HBB&$1ff,.HBE&$1ff,.HDB&$1ff,.HDE&$1ff,.HSS&$1ff
	dc.w	.VFT&$3ff,.VBB&$3ff,.VBE&$3ff,.VDB&$3ff,.VDE&$3ff,.VSS&$3ff
	dc.w	.VCLK&$1ff,.VCO&$00f
	dc.l	.wide,.modulo,.vmode


*********************************************************************************
*
* DSP Gourand Texture mapping junk..
*
*********************************************************************************
gtcls
	move.w	#384*256/16-1,d7
	move.l	#0,d1
	move.l	d0,a0
.wipe
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d7,.wipe
	rts

initgtmap:
	move.l	#txttv,pointertv
	IFEQ	vgahack
	jsr	middlesetscreen
	ELSE
* ###########################################################################
* #                                                                         #
* #  'Screens Pain' coded 1993 by Chris of AURA & Scandion of the Mugwumps  #
* #                                                                         #
* #                 --- It's an INDEPENDENT-Product ---                     #
* #                                                                         #
* ###########################################################################
* Monitor: VGA
* 320*240, True Color, 50.0 Hz, 31470 Hz

        MOVE.L   #$C6008D,$FFFF8282.W
        MOVE.L   #$1502AC,$FFFF8286.W
        MOVE.L   #$8D0097,$FFFF828A.W
        MOVE.L   #$4EB04D1,$FFFF82A2.W
        MOVE.L   #$3F00A5,$FFFF82A6.W
        MOVE.L   #$46504E7,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$140,$FFFF8210.W
	move.w	#64,$ffff820e.w
	ENDC
;-----------------------
	move.w	#$2300,sr

	move.l	address.freemem,d0
	add.l	#txt.screen+256,d0
	clr.b	d0
	bsr	gtcls
	move.l	d0,adr_screen1
	move.l	d0,txt.physic
	add.l	#384*256*2+256,d0
	clr.b	d0
	bsr	gtcls
	move.l	d0,txt.logic

	IFEQ	superpixels-1
	move.w	#$00c7,$ffff8282.w	hht
	move.w	#$00a0,$ffff8284.w	hbb
	move.w	#$001f,$ffff8286.w	hbd
	move.w	#$02c7,$ffff8288.w	hdb
	move.w	#$0096,$ffff828a.w	hde
	move.w	#$00aa,$ffff828c.w	hss

	move.w	#$0271,$ffff82a2.w	vft
	move.w	#$0021+576,$ffff82a4.w	vbd
	move.w	#$0021,$ffff82a6.w	vbe
	move.w	#$0021,$ffff82a8.w	vdb
	move.w	#$0021+576,$ffff82aa.w	vde
	move.w	#$026b,$ffff82ac.w	vss

	move.b	#$02,$ffff820a.w	st 50hz
	move.w	#$0186,$ffff82c0.w	vclock
	move.w	#$000,$ffff8266.w	
	move.w	#$100,$ffff8266.w	spshift (vmode)
	move.w	#$001,$ffff82c2.w	vco
	move.w	#$140,$ffff8210.w	wide
	ENDC

	bsr	gtmap_feedtexture
	
	move.l	#omavbl,own_vbl
	addq.w	#1,activepoint

	rts
;----------------------------------------------------
omavbl:
	move.l	#$0,$ffff9800.w
	rts
;---------------------------------------------
; GTmap by  WizTom of AGGRESSION
; kaskyt:
; 0 feed 16 bit texture to dsp (128*120)
; 1 render poly
;   feed Tbase,Tinc,fakeinc,Gbase,Xsize,Ysize
; read X*Ysize

runGTmap:
	move.l	txt.logic,d0
;	bsr	gtcls
	bsr	calcpoly
	bsr	render_poly
;	not.w	$ffff9800.w
;	bsr	calcpoly
;	not.w	$ffff9800.w

	add.l	#$7000,.test2
	and.l	#$ffffff,.test2
	move.w	.test2,xpolycords
	add.l	#$11000,.test
	and.l	#$ffffff,.test
	move.w	.test,xpolycords+2
;	eor.w	#1,xpolycords+2
	

	lea	txt.physic,a0
	move.l	4(a0),d0
	move.l	(a0),4(a0)
	move.l	d0,(a0)
	move.l	d0,adr_screen1
	
	rts
.test	ds.l	1
.test2	ds.l	1
txt.physic	dc.l	0
txt.logic	dc.l	0
;-------------------
render_poly

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr

	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..

	lea	polysteps,a4
	move.l	Yeka(a4),d6
	add.l	Ytoka(a4),d6
	ble	.zeropoly

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#1,-2(a0)

	move.l	txt.logic(pc),a2
	add.l	polybaseY(a4),a2
	subq.l	#1,d6

	lea	-2(a0),a3
.write	btst	#1,(a1)		
	beq.s	.write
	rept	26
	move.l	(a4)+,(a3)
	endr

.yl:

.sync	btst	#0,(a1)
	beq.s	.sync

	move.w	(a0),d0
	move.w	(a0),d7		;wide, dbf
	move.w	(a0),d1		;      jmp

.sync4	btst	#0,(a1)
	beq.s	.sync4

	lea	(a2,d0.w*2),a3	
	jmp	.xl(pc,d1.w*2)
.xl:
	rept	32
	move.w	(a0),(a3)+	
	endr
	dbf	d7,.xl		

	add.l	#384*2,a2
	dbf	d6,.yl
.zeropoly

;	lea	polysteps,a4
;	move.l	Xwide(a4),d0
;	move.l	txt.logic(pc),a2
;	move.w	#$ffff,d1
;.junki
;	move.w	d1,(a2)+
;	dbf	d0,.junki

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr

	rts
;---------------------------------------------
calcpoly
	lea	xpolycords,a0
	lea	polycords,a1
	move.l	(a0)+,(a1)+		;copy cords from anim 
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+


	lea	polycords,a0
	lea	polysteps,a1
	lea	txtcords,a2
	lea	polydelta,a3
	lea	Gcords,a4

	move.l	(a4),Geka(a1)		;24 bit!
	move.l	4(a4),Gtoka(a1)		
	move.l	8(a4),Gkolmas(a1)
	bsr	Ysort

	movem.w	(a0),d0-d5		;laske polyn deltat
	sub.w	d0,d4
	sub.w	d1,d5
	movem.w	d4-d5,(a3)		;vasen reuna
	sub.w	d0,d2
	sub.w	d1,d3
	movem.w	d2-d3,4(a3)		;oikea reuna
	movem.w	4(a0),d2-d5
	sub.w	d2,d4	
	sub.w	d3,d5	
	movem.w	d4-d5,8(a3)		;alin reuna	

;zekkaa polyn yleiset 
	moveq	#0,d0
	moveq	#0,d1
	move.w	10(a3),d1
	move.w	6(a3),d0
	ble	.tasakattopoly

	move.l	d0,Yeka(a1)	
	move.l	d1,Ytoka(a1)

; calc poly eka partti stepit
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a3),d0
	move.w	2(a3),d1
	swap	d0
	asr.l	#4,d0
	divs.l	d1,d0			;vasen reuna step.12 (dx0)

	moveq	#0,d2
	move.w	4(a3),d1
	move.w	6(a3),d2
	swap	d1
	asr.l	#4,d1
	divs.l	d2,d1			;oikea reuna step.12 (dx1)

	move.w	2(a0),d2
	mulu.w	#384*2,d2
	move.l	d2,POLYbaseY(a1)
	moveq	#0,d2
	move.w	(a0),d2
	swap	d2
	lsr.l	#4,d2
	add.l	#$800,d2
	move.l	d2,d3
	moveq	#0,d4
; zek flip
	cmp.l	d0,d1			;poly kasvaa alaspain?
	bge.s	.noflip
	moveq	#1,d4
	exg.l	d0,d1
.noflip
	move.l	d4,POLYflip(a1)
	move.l	d0,POLYinc(a1)		;vasen
	move.l	d1,POLYinc+4(a1)	;oikea
	asr.l	d0
	asr.l	d1
	add.l	d0,d2
	add.l	d1,d3
	move.l	d2,POLYbase1(a1)
	move.l	d3,POLYbase1+4(a1)

; txt stepit polydeltan korkeuksista
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	8(a2),d0
	move.w	(a2),d2
	sub.w	d2,d0
	move.w	10(a2),d1
	move.w	2(a2),d3
	sub.w	d3,d1
	swap	d0
	swap	d1
	move.l	Yeka(a1),d4
	add.l	Ytoka(a1),d4
	divs.l	d4,d0
	divs.l	d4,d1			;vasen step

	moveq	#0,d4
	moveq	#0,d5
	move.w	4(a2),d4
	sub.w	d2,d4
	move.w	6(a2),d5
	sub.w	d3,d5
	swap	d4
	swap	d5
	move.l	Yeka(a1),d6
	divs.l	d6,d4
	divs.l	d6,d5			;oikea step

; zek poly flip - swap txt ?
	tst.w	polyflip+2(a1)
	beq.s	.notxtflip
	exg.l	d0,d4
	exg.l	d1,d5
.notxtflip
	move.l	d1,TXTvaseninc(a1)
	move.l	d0,TXTvaseninc+4(a1)
	move.l	d5,TXToikeainc(a1)
	move.l	d4,TXToikeainc+4(a1)

	swap	d2	
	swap	d3	
	move.l	d2,d6
	move.l	d3,d7
	asr.l	d0
	asr.l	d1
	asr.l	d4
	asr.l	d5
	add.l	d0,d2
	add.l	d1,d3
	move.l	d3,TXTvasen(a1)
	move.l	d2,TXTvasen+4(a1)
	add.l	d4,d6
	add.l	d5,d7
	move.l	d7,TXToikea(a1)
	move.l	d6,TXToikea+4(a1)

; toka partti 
	move.l	Ytoka(a1),d4
	ble	.notokapartti
	moveq	#0,d0
	moveq	#0,d1
	move.w	8(a2),d0
	sub.w	4(a2),d0
	move.w	10(a2),d1
	sub.w	6(a2),d1
	swap	d0
	swap	d1
	divs.l	d4,d0
	divs.l	d4,d1
	move.l	d1,TXTalininc(a1)
	move.l	d0,TXTalininc+4(a1)
	moveq	#0,d2
	moveq	#0,d3
	move.w	4(a2),d2
	move.w	6(a2),d3
	swap	d2
	swap	d3
	asr.l	d0
	asr.l	d1
	add.l	d0,d2
	add.l	d1,d3
	move.l	d3,TXTalin(a1)	
	move.l	d2,TXTalin+4(a1)	

	moveq	#0,d0
	move.w	8(a3),d0
	swap	d0
	asr.l	#4,d0
	divs.l	d4,d0			;alin reuna step.12
	move.l	d0,POLYinc2(a1)
	move.w	4(a0),d1		;tokan kulman X pos
	swap	d1
	lsr.l	#4,d1
	add.l	#$800,d1
	asr.l	d0
	add.l	d0,d1
	move.l	d1,POLYbase2(a1)	;laske tokalle partille uusi base
.notokapartti

;---- Gshade junk...
	move.w	0(a0),d0		;absolut X positionit
	move.w	8(a0),d1
	move.l	Yeka(a1),d2		;ekan partin korkeus
	move.l	Ytoka(a1),d3		;tokan korkeus
	muls.w	d2,d1
	muls.w	d3,d0
	add.l	d0,d1
	add.l	d2,d3	
	divs.l	d3,d1			;pitkan sivun x pos, levein kohta
	move.w	4(a0),d0		;tokan pisteen x
	sub.w	d1,d0
	bge.s	.nonega
	neg.w	d0
.nonega
	ext.l	d0	
	move.l	d0,Xwide(a1)

	move.l	#$7f0000,d4
	move.w	#16,d5
	jsr	.fixGhalf
	moveq	#0,d7
	move.w	d4,d7
	swap	d7
	move.l	#$007f00,d4
	move.w	#8,d5
	jsr	.fixGhalf
	lsl.w	#8,d4
	move.w	d4,d7
	move.l	#$00007f,d4
	moveq	#0,d5
	jsr	.fixGhalf
	or.w	d4,d7
	move.l	d7,Ghalf(a1)

	rts
;-------------
.fixGhalf
	move.l	Yeka(a1),d2
	move.l	Ytoka(a1),d3
	move.l	Geka(a1),d0
	move.l	Gkolmas(a1),d1
	and.l	d4,d0
	and.l	d4,d1
	lsr.l	d5,d0
	lsr.l	d5,d1
	mulu.w	d3,d0
	mulu.w	d2,d1
	add.l	d2,d3
	add.l	d0,d1
	divs.l	d3,d1
	move.w	d1,d4
	rts
;---------
.nopolyatall
	moveq	#0,d0
	move.l	d0,Yeka(a1)	
	move.l	d0,Ytoka(a1)
	moveq	#1,d0
	move.l	d0,Xwide(a1)
	rts
;----------------
.tasakattopoly
	tst.w	d1
	ble	.nopolyatall

	move.l	d0,Yeka(a1)		;zero
	move.l	d1,Ytoka(a1)		;koko polyn korkeus

	moveq	#0,d0
	move.w	(a3),d0
	swap	d0
	asr.l	#4,d0
	divs.l	d1,d0			;vasen reuna step.12 (dx0) (ok)

	moveq	#0,d2
	move.w	8(a3),d2
	swap	d2
	asr.l	#4,d2
	divs.l	d1,d2			;alin reuna step.12 (dx1)

	move.w	2(a0),d3
	mulu.w	#384*2,d3
	move.l	d3,POLYbaseY(a1)

	moveq	#0,d3
	moveq	#0,d4
	move.w	(a0),d3
	move.w	4(a0),d4
	cmp.w	d3,d4
	bge.s	.noflip2
	exg.l	d3,d4
	exg.l	d0,d2
	move.w	(a2),d5
	move.w	4(a2),(a2)
	move.w	d5,4(a2)		;swap TXT x cords coz polyflip
	move.w	2(a2),d5
	move.w	6(a2),2(a2)
	move.w	d5,6(a2)
.noflip2
	moveq	#0,d5
	move.l	d5,POLYflip(a1)
	swap	d3
	swap	d4
	lsr.l	#4,d3
	lsr.l	#4,d4
	add.l	#$800,d3
	add.l	#$800,d4
	move.l	d0,POLYinc(a1)		;vasen
	move.l	d2,POLYinc2(a1)		;alin (oikea)
	asr.l	d0
	asr.l	d2
	add.l	d0,d3
	add.l	d2,d4
	move.l	d3,POLYbase1(a1)
	move.l	d4,POLYbase2(a1)

; txt stepit polydeltan korkeuksista
	moveq	#0,d0
	moveq	#0,d2
	move.w	8(a2),d0
	move.w	(a2),d2
	sub.w	d2,d0
	move.w	10(a2),d2
	move.w	2(a2),d3
	sub.w	d3,d2
	swap	d0
	swap	d2
	divs.l	d1,d0
	divs.l	d1,d2
	move.l	d2,TXTvaseninc(a1)
	move.l	d0,TXTvaseninc+4(a1)

	moveq	#0,d3
	moveq	#0,d4
	move.w	8(a2),d3
	move.w	4(a2),d4
	sub.w	d4,d3
	move.w	10(a2),d4
	move.w	6(a2),d5
	sub.w	d5,d4
	swap	d3
	swap	d4
	divs.l	d1,d3
	divs.l	d1,d4
	move.l	d4,TXTalininc(a1)		;flip aina zero, alin tulee oikeaksi
	move.l	d3,TXTalininc+4(a1)		;

	moveq	#0,d5
	moveq	#0,d6
	move.w	(a2),d5
	move.w	2(a2),d6
	swap	d5
	swap	d6
	asr.l	d0
	asr.l	d2
	add.l	d0,d5
	add.l	d2,d6
	move.l	d6,TXTvasen(a1)
	move.l	d5,TXTvasen+4(a1)

	moveq	#0,d5
	moveq	#0,d6
	move.w	4(a2),d5
	move.w	6(a2),d6
	swap	d5
	swap	d6
	asr.l	d3
	asr.l	d4
	add.l	d3,d5
	add.l	d4,d6
	move.l	d6,TXTalin(a1)
	move.l	d5,TXTalin+4(a1)
	
	move.l	Geka(a1),d1
	move.l	Gtoka(a1),d2
	move.w	4(a0),d0
	sub.w	(a0),d0			;wide polycordeista
	bge.s	.nonega2
	neg.w	d0
	exg.l	d1,d2
.nonega2
	ext.l	d0
	move.l	d0,Xwide(a1)
	move.l	d1,Ghalf(a1)
	move.l	d1,Geka(a1)
	move.l	d2,Gtoka(a1)

	rts
;-------------------
Ysort
	move.w	2(a0),d0
	move.w	6(a0),d1
	cmp.w	d0,d1
	bge	.zippo1
	move.w	(a0),d0			;swap eka ja toka piste	
	move.w	4(a0),(a0)
	move.w	d0,4(a0)
	move.w	2(a0),d0
	move.w	6(a0),2(a0)
	move.w	d0,6(a0)
	move.w	(a2),d0			
	move.w	4(a2),(a2)
	move.w	d0,4(a2)
	move.w	2(a2),d0
	move.w	6(a2),2(a2)
	move.w	d0,6(a2)
	move.l	Geka(a1),d0
	move.l	Gtoka(a1),Geka(a1)
	move.l	d0,Gtoka(a1)
.zippo1

	move.w	2(a0),d0
	move.w	10(a0),d1
	cmp.w	d0,d1
	bge	.zippo2
	move.w	(a0),d0			;swap eka ja kolmas piste	
	move.w	8(a0),(a0)
	move.w	d0,8(a0)
	move.w	2(a0),d0
	move.w	10(a0),2(a0)
	move.w	d0,10(a0)
	move.w	(a2),d0			
	move.w	8(a2),(a2)
	move.w	d0,8(a2)
	move.w	2(a2),d0
	move.w	10(a2),2(a2)
	move.w	d0,10(a2)
	move.l	Geka(a1),d0
	move.l	Gkolmas(a1),Geka(a1)
	move.l	d0,Gkolmas(a1)
.zippo2

	move.w	6(a0),d0
	move.w	10(a0),d1
	cmp.w	d0,d1
	bge	.zippo3
	move.w	4(a0),d0			;swap toka ja kolmas piste	
	move.w	8(a0),4(a0)
	move.w	d0,8(a0)
	move.w	6(a0),d0
	move.w	10(a0),6(a0)
	move.w	d0,10(a0)
	move.w	4(a2),d0			
	move.w	8(a2),4(a2)
	move.w	d0,8(a2)
	move.w	6(a2),d0
	move.w	10(a2),6(a2)
	move.w	d0,10(a2)
	move.l	Gtoka(a1),d0
	move.l	Gkolmas(a1),Gtoka(a1)
	move.l	d0,Gkolmas(a1)
.zippo3
	rts
;------
tasakattoflagi	
	dc.w	0
.null	dcb.l	8,0
xpolycords
	dc.w	0,0
	dc.w	150,50
	dc.w	50,200
xtxtcords
	dc.w	1,1
	dc.w	126,1	
	dc.w	126,118	
Gcords	dc.l	$702020
	dc.l	$207020
	dc.l	$202070

polycords
	ds.w	6
txtcords
	ds.w	6
flip	ds.w	1
polydelta
	ds.w	6
polysteps
	ds.l	maxrs
freeb	ds.l	30
;---------------------------------------------
gtmap_feedtexture
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#0,-2(a0)		; feed gfx

.lp2	btst	#1,(a1)		
	beq.s	.lp2		

	lea	picture1,a2
	move.w	#(128*120)-1,d7
.loop
	move.l	(a2)+,d0
	lsr.l	#4,d0
	move.l	d0,d1
	and.w	#$000f,d1
	lsr.l	#2,d0
	move.l	d0,d2
	and.w	#$03c0,d2
	or.w	d2,d1
	lsr.l	#3,d0
	and.w	#$7800,d0
	or.w	d0,d1
	move.w	d1,(a0)			;write 24>16 bit conv texture to dsp
;	move.w	(a2)+,(a0)			;write 24>16 bit conv texture to dsp
	dbf	d7,.loop
	rts

;---------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
DSP_LOAD:
	move.w	#$2300,sr
	MOVE.W	#1,-(SP)
	move.l	#(dsp_end-dsp_boot)/3,-(sp)
	move.l	#dsp_boot+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi	reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi	reset			;dsp melted beyond braindamage..

	addq.w	#1,activepoint
	rts

dsp_boot
	incbin	dsp\gtmap7b.p56
	even
dsp_end
	even
;----------------------------------------

	DATA

picture1:
;	INCBIN	eye.c24
 	INCBIN	joker.c24
*	dcb.l	128*128,$00ffffff
	rept	32
	dcb.l	32,0
	dcb.l	32,-1
	dcb.l	32,0
	dcb.l	32,-1
	endr
	rept	32
	dcb.l	32,-1
	dcb.l	32,0
	dcb.l	32,-1
	dcb.l	32,0
	endr
	rept	32
	dcb.l	32,0
	dcb.l	32,-1
	dcb.l	32,0
	dcb.l	32,-1
	endr
	rept	32
	dcb.l	32,-1
	dcb.l	32,0
	dcb.l	32,-1
	dcb.l	32,0
	endr

	BSS

	rsreset
txt.screen:	rs.w	384*256*2
