;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;
; bezier test..
; 30*30 matto
; screen 320*240
; VGA version, runs in one frame on RGB..

bezi.vga = 0	; set to true for vga screensetup


bezi.run	=	1

bez.superpixels	=	0		; 0 = disabled, 1 = enabled

bez.blur	=	1

	IFNE	bezi.run
	
memory		=	500*1024

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
	DC.L	bez.DSP_LOAD
	DC.L	initbez
	DC.L	runbez
	dc.l	viimeinen
	ENDC

;------------
SQRT	MACRO
	moveq	#0,\2
	bfffo	\1{0:31},\3
	beq.s	.\@zero
	neg.w	\3
	add.w	#31,\3
	lsr.w	#1,\3
	addx.w	\2,\3

	move.l	\1,\2
	lsr.l	\3,\2
	beq.s	.\@zero

	move.l	\1,\3
	divu.w	\2,\3
	add.w	\3,\2
	lsr.w	#1,\2
	beq.s	.\@zero

	move.l	\1,\3
	divu.w	\2,\3
	add.w	\3,\2
	lsr.w	#1,\2
	beq.s	.\@zero

	divu.w	\2,\1
	add.w	\2,\1

	lsr.w	#1,\1

.\@zero
	ENDM
;------------
bezTV:
.HHT	SET 	$fe		; Horizontal Hold Timer
.HBB	SET 	$9a+32		; Horizontal Border Begin
.HBE	SET 	$30	 	; Horizontal Border End
.HDB	SET 	$38	 	; Horizontal Display Begin
.HDE	SET 	$98+32	 	; Horizontal Display End
.HSS	SET 	$d8		; Horizontal Synchro Start

.VFT	SET	$271		; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$270		; V BORDER BLANK
.VBE	SET 	$49		; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$49		; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$249		; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b		; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$183		; Video Clock
.VCO	SET	$000		; Video Control
.WIDE	set	160		;screen wide (words)
.modulo	set	0		;screen modulo
.VMODE	set	$010		;screen mode (true)
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
bez.cls
	move.w	#320*256/32-1,d7
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

initbez:
	move.l	#beztv,pointertv
;---------------------------------- modification for vga monitors
	IFEQ	bezi.vga
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
* 320*240, 256 Farben, 50.0 Hz, 31470 Hz

        MOVE.L   #$C6008D,$FFFF8282.W
        MOVE.L   #$15029A,$FFFF8286.W
        MOVE.L   #$7B0097,$FFFF828A.W
        MOVE.L   #$4EB04D1,$FFFF82A2.W
        MOVE.L   #$3F00A5,$FFFF82A6.W
        MOVE.L   #$46504E7,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$10,$FFFF8266.W
        MOVE.W   #$5,$FFFF82C2.W
        MOVE.W   #$A0,$FFFF8210.W
	
	ENDC
;-------------------------------	
	move.w	#$2300,sr

	move.l	address.freemem,d0
	add.l	#bez.screen+255,d0
	clr.b	d0
	bsr	bez.cls
	move.l	d0,adr_screen1
	move.l	d0,bez.physic

	IFEQ	bez.superpixels-1
	move.w	#$00c7,$ffff8282.w	hht
	move.w	#$00a0,$ffff8284.w	hbb
	move.w	#$001f,$ffff8286.w	hbe
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

	bsr	bez_feedtables

	lea	texture1,a2
	bsr	bez_feedtexture
	lea	texture2,a2
	bsr	bez_feedtexture
	lea	texture3,a2
	bsr	bez_feedtexture
	lea	texture4,a2
	bsr	bez_feedtexture
	lea	texture5,a2
	bsr	bez_feedtexture

	bsr	bez.clear
	bsr	prefeed.pal

	clr.l	d0
	move.w	d0,bez.mixer			;max ekalle
	move.w	d0,bez.mixspeed
	move.w	d0,bez.objectlistN		;objectilistan alkuun
	move.w	d0,lentopiste
	move.l	#lentocontrol,lentocontrolN
	move.l	d0,bez.xpos
	move.l	d0,bez.ypos
	move.l	d0,bez.zpos
	move.w	#0,d0
	jsr	xsin
	move.l	d1,bez.sinalfa
	move.l	d1,bez.sinbeta
	move.l	d1,bez.singamma
	move.w	#0,d0
	jsr	xcos
	move.l	d1,bez.cosalfa
	move.l	d1,bez.cosbeta
	move.l	d1,bez.cosgamma
	bsr	bez.rottamatikat
	bsr	bez.rottamatikat

	move.l	#bezvbl,own_vbl
	addq.w	#1,activepoint

	rts
;----------------------------------------------------
bezvbl:
	move.l	#$0,$ffff9800.w
	rts
;---------------------------------------------
; txt mapped bezier by  WizTom of AGGRESSION
; kaskyt:
; 0 - feed controlpoints (matto N, txt N, 16 x-y)
; 1 - render in dsp
; 2 - feed screen to cpu
; 3 - feed kerrointable, make x offsets etc precacl...
; 4 - clear screen1
; 5 - feed texture (txt number,1024 data)

runbez:
	bsr	feed.pal
	move.l	#$00200040,$ffff9800.w
	bsr	bez.render.screen

	bsr	feed.control
	ifeq	bez.blur
	bsr	bez.clear
	endc
	bsr	render.bez
	bsr	bez.rottamatikat


;.waitdsp
;	btst	#0,$ffffa202.w		
;	beq.s	.waitdsp

	rts

bez.physic	dc.l	0
;-------------------
bez.rottamatikat:

	bsr	bez.objectcontrol
; settaa objectit, morphit etc, ajastukset

	bsr	bez.objectmotion
; juoksee splinea, settaa paikan ja rotation

	bsr	bez.morph
; mophaa bez.object (xyzñ511pixel) bez.newcordiin (xyzñ511pixel)

	bsr	bez.rotta
; pyorita objectia bez.newcord (xyzñ511pixel)ja projisoi bez.newcordiin (ñxy+$7fff)

	rts

;--------
bez.objectcontrol:
	tst.b	keytab+$44
	beq.s	.noeka
	clr.b	keytab+$44
	move.w	#0,bez.objectlistN		;listapointer
	move.w	#$7fff,bez.mixer		;max ekalle
	move.w	#0,bez.mixspeed
.noeka
	tst.b	keytab+$43
	beq.s	.notoka
	clr.b	keytab+$43
	move.w	#1,bez.objectlistN
	move.w	#$7fff,bez.mixer		;max ekalle
	move.w	#0,bez.mixspeed
.notoka

;object anim
	lea	bez.objectlist,a0
	move.w	bez.objectlistN,d0
	lsl.w	#4,d0

	move.l	(a0,d0.w),a1			;object
	move.l	4(a0,d0.w),d3			;mattoN
	move.l	8(a0,d0.w),d1			;anim frame/max
	move.w	d3,bez.objectN			;mattomaara (ekasta objectista)
	move.l	d1,d2
	swap	d2
	add.w	#1,d2
	cmp.w	d1,d2
	blt	.nowarp1
	sub.w	d1,d2
.nowarp1
	move.w	d2,8(a0,d0.w)
	mulu.w	#98,d2				;(16*3)+1 wordia byteina
	mulu.w	d3,d2				;kertaa matot
	add.l	d2,a1
	move.l	a1,bez.eka			;haluttun framen alku

	move.l	16(a0,d0.w),a1			;object
	move.l	20(a0,d0.w),d3			;mattoN
	move.l	24(a0,d0.w),d1			;anim frame/max
	move.l	d1,d2
	swap	d2
	add.w	#1,d2
	cmp.w	d1,d2
	blt	.nowarp2
	sub.w	d1,d2
.nowarp2
	move.w	d2,24(a0,d0.w)
	mulu.w	#98,d2				;(16*3)+1 wordia byteina
	mulu.w	d3,d2				;kertaa matot
	add.l	d2,a1
	move.l	a1,bez.toka			;haluttun framen alku

; morphi boink
	move.w	bez.mixer,d0
	move.w	bez.mixspeed,d1
 	add.w	#100,d1			;kiihtyvyys
	sub.w	d1,d0
	bgt.s	.noboink_oink_ink_nk_k
	clr.w	d0
	neg.w	d1			;kimpoa
	muls	#3,d1
	asr.l	#2,d1	
.noboink_oink_ink_nk_k
	move.w	d0,bez.mixer
	move.w	d1,bez.mixspeed

	rts

bez.mixer	dc.w	0
bez.mixspeed	dc.w	0
bez.eka		dc.l	0
bez.toka	dc.l	0
bez.objectN	dc.w	0
bez.objectlistN	dc.w	0
bez.objectlist:
	dc.l	bez.object1,10,36,0	;object,mattoN,framecount/frameN,(time?)
	dc.l	bez.object2,8,1,0
	dc.l	bez.object1,10,36,0	;object,mattoN,framecount/frameN,(time?)
	dc.l	bez.object2,8,1,0
	dc.l	-1
;-------------
bez.objectmotion:
	move.l	lentocontrolN,a1
	move.w	lentopiste,d0
	add.w	#1,d0
	cmp.w	#31,d0
	blt	.samatpisteet
	sub.w	#31,d0
	addq.l	#6,a1
	move.w	24(a1),d1
	cmp.w	#$7fff,d1
	bne.s	.nowarp
	lea	lentocontrol,a1
.nowarp
	move.l	a1,lentocontrolN
.samatpisteet
	move.w	d0,lentopiste

	lea	lentotable,a0
	lea	(a0,d0.w*8),a0
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2		;kontrol x,y,z
	muls.w	(a0),d0
	muls.w	(a0),d1
	muls.w	(a0)+,d2		;kertoimilla

	rept	3
	move.w	(a1)+,d3
	move.w	(a1)+,d4
	move.w	(a1)+,d5
	muls.w	(a0),d3	
	muls.w	(a0),d4	
	muls.w	(a0)+,d5	
	add.l	d3,d0
	add.l	d4,d1
	add.l	d5,d2
	endr

	asr.l	#7,d0
	asr.l	#7,d1
	asr.l	#7,d2
	sub.l	#100*256,d2

	move.l	bez.xpos,d3
	move.l	bez.ypos,d4
	move.l	bez.zpos,d5

	move.l	d0,bez.xpos
	move.l	d1,bez.ypos
	move.l	d2,bez.zpos

	sub.l	d3,d0		;deltat
	sub.l	d4,d1
	sub.l	d5,d2
	neg.l	d0
	neg.l	d1
	neg.l	d2

;-----beta
	move.l	d0,d3
	muls.w	d3,d3		;x^2
	move.l	d2,d4
	muls.w	d4,d4		;z^2
	add.l	d4,d3		;r^2
	move.l	r3,r7

	sqrt	d3,d4,d5	;matka pixeleina (hypotenuusa)
	and.l	#$ffff,d3
	bne.s	.nozeror
	not.w	$ffff9802.w
	moveq	#1,d3
.nozeror
	move.l	d3,d6		;r

	move.l	d0,d4
	asl.l	#8,d4		;
	asl.l	#7,d4		;
	divs.l	d3,d4		;z/r
	move.l	d4,bez.sinbeta	

	move.l	d2,d4
	neg.l	d4
	asl.l	#8,d4
	asl.l	#7,d4
	divs.l	d3,d4		;x/r
	move.l	d4,bez.cosbeta

;------alfa
	move.l	d1,d3
	muls.w	d3,d3		;y^2
	move.l	d7,d4		;r^2
	add.l	d4,d3		;r2^2

	sqrt	d3,d4,d5	;matka pixeleina (hypotenuusa)
	and.l	#$ffff,d3
	bne.s	.nozeror2
	not.w	$ffff9802.w
	moveq	#1,d3
.nozeror2

	move.l	d1,d4
	neg.l	d4
	asl.l	#8,d4		;
	asl.l	#7,d4		;
	divs.l	d3,d4		;y/r2
	move.l	d4,bez.sinalfa	

	move.l	d6,d4
	asl.l	#8,d4
	asl.l	#7,d4
	divs.l	d3,d4		;r/r2
	move.l	d4,bez.cosalfa

;------gamma
	move.l	d0,d3
	muls.w	d3,d3		;x^2
	move.l	d2,d4
	muls.w	d4,d4		;z^2
	add.l	d4,d3		;r^2
	move.l	r3,r7

	sqrt	d3,d4,d5	;matka pixeleina (hypotenuusa)
	and.l	#$ffff,d3
	bne.s	.nozeror3
	not.w	$ffff9802.w
	moveq	#1,d3
.nozeror3
	move.l	d3,d6		;r

	move.l	d0,d4
	bge.s	.zetapositive
	neg.l	d4
.zetapositive
	asl.l	#8,d4		;
	asl.l	#7,d4		;
	divs.l	d3,d4		;z/r
	move.l	d4,bez.singamma

	move.l	d2,d4
	asl.l	#8,d4
	asl.l	#7,d4
	divs.l	d3,d4		;x/r
	move.l	d4,bez.cosgamma
	
;	move.l	bez.singamma,d0
;	cmp.l	#200,d0
;	bgt.s	.ok1
;	cmp.l	#-200,d0
;	blt.s	.ok1
;	move.l	#0,bez.singamma
;	move.l	#$7fff,bez.cosgamma
;.ok1

	rts
;-----
bez.sinalfa	dc.l	0
bez.cosalfa	dc.l	0
bez.sinbeta	dc.l	0
bez.cosbeta	dc.l	0
bez.singamma	dc.l	0
bez.cosgamma	dc.l	0
bez.xpos	dc.l	0
bez.ypos	dc.l	0
bez.zpos	dc.l	0
lentopiste	dc.w	0		;kohta splinessa
lentocontrolN	dc.l	0
lentocontrol
	dc.w	-120,0,900	
	dc.w	0,0,900
	dc.w	120,0,900
;	dc.w	80,0,700
	dc.w	0,0,600
;	dc.w	-80,0,700
	dc.w	-120,0,900	
	dc.w	0,0,900
	dc.w	120,0,900
;	dc.w	80,0,700
	dc.w	0,0,600
;	dc.w	-80,0,700


	dc.w	$7fff
;lentocontrol
	Dc.w	-130,-100,720
	Dc.w	-160,-60,860
	Dc.w	-90,-30,1020
	Dc.w	-120,0,1340
	Dc.w	-60,30,1500
	Dc.w	30,60,1500
	Dc.w	100,100,1400
	Dc.w	60,70,1140
	Dc.w	170,40,1000
	Dc.w	180,10,640
	Dc.w	100,-20,640
	Dc.w	40,-50,540
	Dc.w	-30,-75,560

	Dc.w	-130,-100,720
	Dc.w	-160,-60,860
	Dc.w	-90,-30,1020
	Dc.w	-120,0,1340
	dc.w	$7fff
;rata2
;lentocontrol
	Dc.w	-10,0,500
	Dc.w	-320,0,1060
	Dc.w	-60,0,1500
	Dc.w	170,0,1500
	Dc.w	320,0,1120
	Dc.w	50,0,580
	Dc.w	-130,0,660
	Dc.w	-190,0,1060
	Dc.w	-150,50,1400
	Dc.w	-10,0,1500
	Dc.w	100,-50,1480
	Dc.w	150,0,1320
	Dc.w	150,0,1040
	Dc.w	100,0,940
	Dc.w	20,0,820
	Dc.w	-70,0,860
	Dc.w	-110,0,1000
	Dc.w	-100,0,1160
	Dc.w	-50,0,1300
	Dc.w	70,0,1380
	Dc.w	170,50,1360
	Dc.w	200,100,1260
	Dc.w	210,50,1060
	Dc.w	100,0,660
	Dc.w	-10,0,500
	Dc.w	-320,0,1060
	Dc.w	-60,0,1500
	Dc.w	170,0,1500
	dc.w	$7fff
;--------------
bez.rotta:

.bsxk	EQUR	d0
.bcxk	EQUR	d1
.bsyk	EQUR	d2
.bcyk	EQUR	d3
.bszk	EQUR	d4
.bczk	EQUR	d5

	lea	bez.sinalfa,a0
	movem.l	(a0)+,a1-a6

	move.l	a1,.bsxk
	move.l	a2,.bcxk
	move.l	a3,.bsyk
	move.l	a4,.bcyk
	move.l	a5,.bszk
	move.l	a6,.bczk

	asr.l	#7,.bsxk
	asr.l	#7,.bcxk
	asr.l	#7,.bsyk
	asr.l	#7,.bcyk
	asr.l	#7,.bszk
	asr.l	#7,.bczk

	move.w	.bcyk,d6
	muls.w	.bczk,d6
	asr.l	#8,d6
	move.w	.bsxk,d7
	muls	.bsyk,d7
	asr.l	#8,d7
	muls	.bszk,d7
	asr.l	#8,d7
	sub.w	d7,d6
	move.w	d6,.bmatrix0

	move.w	.bcyk,d6
	muls.w	.bszk,d6
	asr.l	#8,d6
	move.w	.bsxk,d7
	muls	.bsyk,d7
	asr.l	#8,d7
	muls	.bczk,d7
	asr.l	#8,d7
	add.w	d7,d6
	move.w	d6,.bmatrix1

	move.w	.bcxk,d6
	muls	.bsyk,d6
	asr.l	#8,d6
	neg.w	d6
	move.w	d6,.bmatrix2

	move.w	.bcxk,d6
	muls	.bszk,d6
	asr.l	#8,d6
	neg.w	d6
	move.w	d6,.bmatrix3

	move.w	.bcxk,d6
	muls	.bczk,d6
	asr.l	#8,d6
	move.w	d6,.bmatrix4

	move.w	.bsxk,.bmatrix5

	move.w	.bsyk,d6
	muls.w	.bczk,d6
	asr.l	#8,d6
	move.w	.bsxk,d7
	muls	.bcyk,d7
	asr.l	#8,d7
	muls	.bszk,d7
	asr.l	#8,d7
	add.w	d7,d6
	move.w	d6,.bmatrix6

	move.w	.bsyk,d6
	muls.w	.bszk,d6
	asr.l	#8,d6
	move.w	.bsxk,d7
	muls	.bcyk,d7
	asr.l	#8,d7
	muls	.bczk,d7
	asr.l	#8,d7
	sub.w	d7,d6
	move.w	d6,.bmatrix7

	move.w	.bcxk,d6
	muls	.bcyk,d6
	asr.l	#8,d6
	move.w	d6,.bmatrix8

	movec	cacr,d0
	or.w	#$808,d0
	movec	d0,cacr

;------------------------------------ rotatoi matriisissa objecti

	lea	bez.newcords,a0		;rotta xyz source
	lea	bez.newcords,a1		;rotta xyz destination

	move.w	bez.objectN,d6
	ble	.noobject
	subq.w	#1,d6
.bhi
	move.w	(a0)+,(a1)+		;txt number
	move.w	#16-1,d7


.bloop	movem.w	(a0)+,d0/d1/d2

	move.w	d0,d3
.bmatrix0	= *+2
	muls.w	#$1234,d3
	move.w	d1,d4
.bmatrix1	= *+2
	muls.w	#$1234,d4
	add.l	d4,d3
	move.w	d2,d4
.bmatrix2	= *+2
	muls.w	#$1234,d4
	add.l	d4,d3

	move.w	d0,d4
.bmatrix3	= *+2
	muls.w	#$1234,d4
	move.w	d1,d5
.bmatrix4	= *+2
	muls.w	#$1234,d5
	add.l	d5,d4
	move.w	d2,d5
.bmatrix5	= *+2
	muls.w	#$1234,d5
	add.l	d5,d4

.bmatrix6	= *+2
	muls.w	#$1234,d0
.bmatrix7	= *+2
	muls.w	#$1234,d1
	add.l	d1,d0
.bmatrix8	= *+2
	muls.w	#$1234,d2
	add.l	d2,d0

	add.l	bez.xpos,d3
	add.l	bez.ypos,d4
	add.l	bez.zpos,d0
	asr.l	#8,d0			
	asr.w	#1,d0

	bne	.nozero
;	not.l	$ffff9800.w
	move.w	#1,d0
.nozero	

	divs.w	d0,d3
	divs.w	d0,d4			

	add.w	#$7fff,d3
	move.w	d3,(a1)+
	add.w	#$7fff,d4
	move.w	d4,(a1)+

	dbra	d7,.bloop
	dbf	d6,.bhi
.noobject
	rts
;---------
bez.morph
	move.l	bez.eka,a0
	move.l	bez.toka,a1
	lea	bez.newcords,a2
	move.w	bez.mixer,d0		;tokan suhde
	move.w	#$7fff,d1
	sub.w	d0,d1			;ekan suhde
	move.w	bez.objectN,d7
	ble	.noobject
	subq.w	#1,d7
.hi
	move.w	(a0)+,(a2)+		;copy texture ekasta
	move.w	(a1)+,d2		;skip tokan texture
	move.w	#16-1,d6
.lo
	move.w	(a0)+,d2
	muls.w	d1,d2
	move.w	(a1)+,d3
	muls.w	d0,d3
	add.l	d3,d2			;mix X
	add.l	d2,d2
	swap	d2
	move.w	d2,(a2)+

	move.w	(a0)+,d2
	muls.w	d1,d2
	move.w	(a1)+,d3
	muls.w	d0,d3
	add.l	d3,d2			;mix Y
	add.l	d2,d2
	swap	d2
	move.w	d2,(a2)+

	move.w	(a0)+,d2
	muls.w	d1,d2
	move.w	(a1)+,d3
	muls.w	d0,d3
	add.l	d3,d2			;mix Z
	add.l	d2,d2
	swap	d2
	move.w	d2,(a2)+

	dbf	d6,.lo

	dbf	d7,.hi
.noobject
	rts

bez.newcords
	ds.w	10*(16+16+16+1)
;-------------------
feed.control
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0	

	move.w	bez.objectN,d6
	ble	.no_objects

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	bez.reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#0,-2(a0)

	lea	bez.newcords,a2

.sync2	btst	#1,(a1)
	beq.s	.sync2
	move.w	d6,(a0)				;matto N
	subq	#1,d6
.filler2
.sync	btst	#1,(a1)
	beq.s	.sync
	rept	33
	move.w	(a2)+,(a0)		;txt number, 16 x-y
	endr
	dbf	d6,.filler2

.no_objects
	rts
;-------------------
render.bez
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0	


.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	bez.reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#1,-2(a0)		;render beziers
	rts
;-------------------
bez.clear
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0	

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	bez.reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#4,-2(a0)		;clear screen

	rts

;-------------------
bez.render.screen
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	bez.reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#2,-2(a0)		;render poly!

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr
	
	move.l	bez.physic(pc),a2
	lea	.killerlist,a5
	move.w	bez.palpoint,d1
	move.l	a2,a3
	move.l	a2,a4
	add.w	(a5,d1.w*8),a2
	add.w	2(a5,d1.w*8),a3
	add.w	4(a5,d1.w*8),a4

	move.l	#16,d0
	move.w	#(238*2)-1,d7
.sync	btst	#0,(a1)
	beq.s	.sync

.fil
	rept	10
	move.w	(a0),(a2)
	add.l	d0,a2
	move.w	(a0),(a3)
	add.l	d0,a3
	move.w	(a0),(a4)
	add.l	d0,a4
	endr
	dbf	d7,.fil

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr

	rts

.killerlist
	dc.w	10,12,14,0
	dc.w	12,14,0,0
	dc.w	14,0,2,0
	dc.w	0,2,4,0
	dc.w	2,4,6,0
	dc.w	4,6,8,0
	dc.w	6,8,10,0
	dc.w	8,10,12,0
;---------------------------------------------
feed.pal
	move.w	bez.palpoint,d0
	ifne	bez.blur
	addq.w	#1,d0
	endc
	and.w	#$7,d0
	move.w	d0,bez.palpoint
	move.l	address.freemem,a0
	add.l	#bez.palette,a0
	lsl.w	#8,d0
	lea	(a0,d0.w*4),a0
	lea	$ffff9800.w,a1
	move.w	#16-1,d7
.loop
	rept	16
	move.l	(a0)+,(a1)+	
	endr
	dbf	d7,.loop	
	rts
bez.palpoint
	dc.w	0

;---------------------------------------------
prefeed.pal
	lea	bez.prepalette,a0
	move.l	address.freemem,a1
	add.l	#bez.palette,a1
	moveq	#0,d0
	moveq	#8-1,d6
.framet
	moveq	#0,d1
	move.w	#256-1,d7
.loop
	move.w	d1,d2
	ror.b	d0,d2
	move.w	d2,d4
	add.w	d4,d4
	add.w	d2,d4
	moveq	#0,d3
	move.b	(a0,d4.w),d3
	lsl.w	#8,d3
	move.b	1(a0,d4.w),d3
	swap	d3
	move.b	2(a0,d4.w),d3
	move.l	d3,(a1)+	
	addq	#1,d1
	dbf	d7,.loop	

	addq	#1,d0
	dbf	d6,.framet
	rts
;---------------------------------------------
; a2 - texture number.b, 32*32 texture.b 3 bittisena
bez_feedtexture

	lea	$ffffa202.w,a1	
	lea	$ffffa207.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	-1(a0),d0
	cmp.w	#$babe,d0
	bne	bez.reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#5,-3(a0)		; feed gfx

.lp2	btst	#1,(a1)		
	beq.s	.lp2		

	move.b	(a2)+,(a0)		;texture number

.lp3	btst	#1,(a1)		
	beq.s	.lp3

	move.w	#30-1,d7
.loop
	moveq	#30-1,d6

.wlo	move.b	(a2)+,(a0)			;write texture (0-7) to dsp (dot order)
	dbf	d6,.wlo

	addq.l	#2,a2
	dbf	d7,.loop

	rts
;---------------------------------------------
bez_feedtables:
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	bez.reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#3,-2(a0)		;feed tables

.lp2	btst	#1,(a1)		
	beq.s	.lp2		

	lea	kerrointable,a2
	move.w	#120-1,d7
.loop2
	move.l	(a2)+,d0
	lsl.l	#7,d0
	move.l	d0,-2(a0)
	dbf	d7,.loop2

	rts

;---------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
bez.DSP_LOAD:
	move.w	#$2300,sr
	MOVE.W	#1,-(SP)
	move.l	#(bez.dsp_end-bez.dsp_boot)/3,-(sp)
	move.l	#bez.dsp_boot+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi	bez.reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi	bez.reset			;dsp melted beyond braindamage..

	addq.w	#1,activepoint
	rts

bez.reset
	jmp	reset

bez.dsp_boot
	incbin	d:\motion\revenge\dsp\bezier6.p56
	even
bez.dsp_end
	even
;----------------------------------------

	cnop	4,0
bez.prepalette
;	dc.l	0
;x	set	36*256
;	rept	255
;	dc.b	x/256,x/256,0
;x	set	x+(255-36)
;	endr
	incbin	bezier\pal.bin
	even
texture1	
	dc.b	0
;	dcb.b	900,4
	incbin	bezier\tmap1.bin
	even
texture2
	dc.b	1
	incbin	bezier\tmap2.bin
	even
texture3
	dc.b	2
	incbin	bezier\tmap3.bin
	even
texture4
	dc.b	3
	incbin	bezier\tmap4.bin
	even
texture5
	dc.b	4
	incbin	bezier\tmap5.bin
	even
kerrointable
	incbin	bezier\beztab30.bin
	even
lentotable
	incbin	bezier\bspltabl.bin
	even
bez.object1
	incbin	bezier\amppari.ani
;	incbin	bezier\mato.ani
;	incbin  bezier\a.ani
	even
bez.object2
;	incbin	bezier\mato.ani
	incbin	bezier\torus.ani
	even

	rsreset
bez.palette	rs.l	256*8
bez.screen:	rs.w	320*256/2+128


