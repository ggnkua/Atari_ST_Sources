;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;
; realtime DSP fader
; delta anim player
; -> anim fader (inputs deltapacked anim to fade to screen)

	TEXT

fader.run	= 1

	IFNE	fader.run

memory	= 500*1024

Overdose_Beyond_Braindamage
	include freeintx.s
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
	dc.l	fade.dsp_load
	dc.l	fadeinit
;	DC.L	fade_play	;plain anim player
	dc.l	fade_anim	;fades anim frames
	dc.l	dummy
	dc.l	viimeinen
	ENDC

;-----------------------------------------------------
; FADER-DSP
;-----------------------------------------------------
fadeinit:

	move.l	address.freemem,d0
	add.l	#fade.ruutu+256,d0
	clr.b	d0
	move.l	d0,adr_screen1

	move.l	d0,a0
	lea	fade.kuva,a1
	move.w	#(384*100/20)-1,d0
.tayta
	rept	20
	move.w	(a1)+,(a0)+
	endr
	dbf	d0,.tayta

	move.l	#fadetv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr

	lea	fade.delta,a0
	move.l	a0,fp_delta
	lea	fade.data,a0
	move.l	a0,fp_data

	lea	fade.vdelta,a0
	move.l	a0,fp_vdelta
	lea	fade.vdata,a0
	move.l	a0,fp_vdata

	addq.w	#1,activepoint
dummy	rts
;------------------------------------
fade_anim
	moveq	#0,d0
	moveq	#0,d1
	move.w	.test,d0
	sub.w	#4*10,d0
	bpl.s	.fadeold
	bsr	fade.gennew
	move.w	#255,d0
.fadeold
	move.w	d0,.test
	move.w	#255,d1
	sub.w	d0,d1
	move.w	d0,fade_control+2	
	move.w	d1,fade_control+4	

	bsr	fade_jako

	rts

.test	dc.w	0
fp_vdelta	dc.l	0
fp_vdata	dc.l	0
fp_xxdelta	dc.l	0
fp_xxdata	dc.l	0
;------------
fade.gennew
	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr	

	move.l	fp_vdelta,a0
	move.l	a0,fp_xxdelta
	move.l	adr_screen1,a1
	move.l	address.freemem,a2
	add.l	#fade.buffer,a2
	
	move.w	#(24*180)-1,d7
	moveq	#0,d0
.delta
	move.w	(a0)+,d0
	rept	16
	bpl.s	*+4
	move.w	(a1),(a2)+		;copy screen > buffer
	addq.l	#2,a1
	lsl.w	#1,d0
	endr
	dbf	d7,.delta

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr	

	move.l	address.freemem,d0
	add.l	#fade.buffer,d0
	move.l	d0,fade_control+6

	move.l	a2,d1
	sub.l	d0,d1
	lsr.l	#1,d1			;wordimaara (pixelit)
	move.w	d1,fade_control
	move.l	fp_vdata,fade_control+10


	move.l	a0,fp_vdelta
	move.l	a0,d0
	cmp.l	#fade.deltavika,d0
	blt.s	.out
	addq.w	#1,activepoint
.out
	rts

;-----------------------
fade_jako
; splittaa fade.buffer paloihin ja tulosta ruutuun fader_contrlilla

;	rept	4
	move.w	#1080,fade_control+14
	move.w	fadekuolotaulu,d0
	move.w	fadekuolotaulu(pc,d0.w*2),a0	;pixelisize!!!!
	add.w	#1,fadekuolotaulu
	move.w	a0,fade_control	
	bsr	fade_write
	bsr	fade_read

;	endr
	
	move.w	fade_control,d0
	move.l	fade_control+10,a0
	lea	(a0,d0.w*2),a0
	move.l	a0,fp_data

	rts

fade_control
	dc.w	0		;monta pixelia
	dc.w	0		;%osuus (0-255) ekalle
	dc.w	0		;tokalle
	dc.l	0
	dc.l	0
	dc.w	0		;monta deltacontrolwordia
fadekuolotaulu
	dc.w	1
	dc.w	1,2,3,4,5
	dc.w	6,7,8,9,10
	dc.w	11,12,13,14,15
	dc.w	16,17,18,19,20

;---------------------------------------------
fade_write
	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr	

	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0
	lea	fade_control,a2

.test	btst	#0,(a1)		
	beq.s	.test	
	move.l	-2(a0),d0
	cmp.l	#$feed,d0
	bne.l	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	moveq	#0,d0
	move.w	(a2)+,d0
	move.l	d0,-2(a0)		;pikselimaara

	lea	fadertable,a3
	move.w	(a2)+,d1	
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.l	(a3,d1.w*4),-2(a0)

	move.w	(a2)+,d1
.lp3	btst	#1,(a1)		
	beq.s	.lp3		
	move.l	(a3,d1.w*4),-2(a0)


.lp4	btst	#1,(a1)		
	beq.s	.lp4		

	move.l	(a2)+,a3
	move.l	(a2)+,a4
;	lsr.w	#4,d0
	subq.w	#1,d0
.hikka
	rept	1
	move.w	(a3)+,(a0)
	move.w	(a4)+,(a0)
	endr
	dbf	d0,.hikka

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr	

	rts
;----------
fadertable
x	set	0
	rept	64
	dc.l	x*$20000
	dc.l	x*$20000
	dc.l	x*$20000
	dc.l	x*$20000
x	set	x+1
	endr
;-------------------------------------------
fade_read
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..
	move.l	adr_screen1,a2
	move.l	fp_xxdelta,a3

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr	

.lp2	btst	#0,(a1)		
	beq.s	.lp2

	move.w	fade_control+14,d7
	subq.w	#1,d7
	moveq	#0,d0
.delta
	move.w	(a3)+,d0
	rept	16
	bpl.s	*+4
	move.w	(a0),(a2)	
	addq.l	#2,a2
	lsl.w	#1,d0
	endr
	dbf	d7,.delta

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr	

	move.l	a3,fp_xxdelta
	rts
fp_xdelta	dc.l	0
;------------------------------------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
fade.DSP_LOAD:

	MOVE.W	#1,-(SP)
	move.l	#(fade.dsp_ende-fade.dsp_code)/3,-(sp)
	move.l	#fade.dsp_code+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi.l	reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi.l	reset			;dsp melted beyond braindamage..

	lea	$ffffa202.w,a1	
	lea	$ffffa204.w,a0

	move.l	#$babe,d0		;testaa varmuuden vuoksi dsp rutiini..
.lp2	btst	#0,(a1)		
	beq.s	.lp2		
	move.l	(a0),d1
	cmp.l	d0,d1
	bne.l	reset

	addq.w	#1,activepoint
	rts

fade.dsp_code
	incbin	dsp\fade.p56
fade.dsp_ende
	even
;------------------------------
fadeTV:
.HHT	SET 	$fe		; Horizontal Hold Timer
.HBB	SET 	$c0		; Horizontal Border Begin
.HBE	SET 	$30		; Horizontal Border End
.HDB	SET 	$18		; Horizontal Display Begin
.HDE	SET 	$b8		; Horizontal Display End
.HSS	SET 	$d8		; Horizontal Synchro Start

.VFT	SET 	$271		; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$265		; V BORDER BLANK
.VBE	SET 	$49		; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$49		; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$249		; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b		; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$182		; Video Clock
.VCO	SET	$000		; Video Control
.WIDE	set	384		;screen wide (words)
.modulo	set	0		;screen modulo
.VMODE	set	$100		;screen mode (true)
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

;-------------------------------
fade_play
	sub.w	#1,fp_frame
	bgt	.out
	move.w	#3,fp_frame

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr	

	move.l	fp_delta,a0
	move.l	fp_data,a1
	move.l	adr_screen1,a2
	move.w	#(384*100/16)-1,d7
	moveq	#0,d0
.delta
	move.w	(a0)+,d0

	rept	16
	bpl.s	*+4
	move.w	(a1)+,(a2)	

	addq.l	#2,a2
	lsl.w	#1,d0
	endr

	dbf	d7,.delta

	movec	cacr,d0
	bset	#8,d0
	movec	d0,cacr	

	move.l	a0,fp_delta
	move.l	a1,fp_data
	move.l	a0,d0
	cmp.l	#fade.data,d0
	blt.s	.out
	addq.w	#1,activepoint
.out
	rts

fp_delta	dc.l	0
fp_data		dc.l	0
fp_frame	dc.w	0
;---------------------------------------------------
fade.kuva
	incbin	alkuanim\frame000.ftc
	even
fade.vdelta
	incbin	alkuanim\light000.dlb
	incbin	alkuanim\light001.dlb
	incbin	alkuanim\light002.dlb
	incbin	alkuanim\light003.dlb
	incbin	alkuanim\light004.dlb
	incbin	alkuanim\light005.dlb

fade.delta
	IFEQ	1

	incbin	alkuanim\frame000.dlb	
	incbin	alkuanim\frame001.dlb	
	incbin	alkuanim\frame002.dlb	
	incbin	alkuanim\frame003.dlb	
	incbin	alkuanim\frame004.dlb	
	incbin	alkuanim\frame005.dlb	
	incbin	alkuanim\frame006.dlb	
	incbin	alkuanim\frame007.dlb	
	incbin	alkuanim\frame008.dlb	
	incbin	alkuanim\frame009.dlb	
	incbin	alkuanim\frame010.dlb	
	incbin	alkuanim\frame011.dlb	
	incbin	alkuanim\frame012.dlb	
	incbin	alkuanim\frame013.dlb	
	incbin	alkuanim\frame014.dlb	
	incbin	alkuanim\frame015.dlb	
	incbin	alkuanim\frame016.dlb	
	incbin	alkuanim\frame017.dlb	
	incbin	alkuanim\frame018.dlb	
	incbin	alkuanim\frame019.dlb	
	incbin	alkuanim\frame020.dlb	
	incbin	alkuanim\frame021.dlb	
	incbin	alkuanim\frame022.dlb	
	incbin	alkuanim\frame023.dlb	
	incbin	alkuanim\frame024.dlb	
	incbin	alkuanim\frame025.dlb	
	incbin	alkuanim\frame026.dlb	
	incbin	alkuanim\frame027.dlb	
	incbin	alkuanim\frame028.dlb	
	incbin	alkuanim\frame029.dlb	
	incbin	alkuanim\frame030.dlb	
	incbin	alkuanim\frame031.dlb	
	incbin	alkuanim\frame032.dlb	
	incbin	alkuanim\frame033.dlb	
	incbin	alkuanim\frame034.dlb	
	incbin	alkuanim\frame035.dlb	
	incbin	alkuanim\frame036.dlb	
	incbin	alkuanim\frame037.dlb	
	incbin	alkuanim\frame038.dlb	
	incbin	alkuanim\frame039.dlb	
	incbin	alkuanim\frame040.dlb	
	incbin	alkuanim\frame041.dlb	
	incbin	alkuanim\frame042.dlb	
	incbin	alkuanim\frame043.dlb	
	incbin	alkuanim\frame044.dlb	
	incbin	alkuanim\frame045.dlb	
	incbin	alkuanim\frame046.dlb	
	incbin	alkuanim\frame047.dlb	
	incbin	alkuanim\frame048.dlb	
	incbin	alkuanim\frame049.dlb	
	incbin	alkuanim\frame050.dlb	
	incbin	alkuanim\frame051.dlb	
	incbin	alkuanim\frame052.dlb	
	incbin	alkuanim\frame053.dlb	
	incbin	alkuanim\frame054.dlb	
	incbin	alkuanim\frame055.dlb	
	incbin	alkuanim\frame056.dlb	
	incbin	alkuanim\frame057.dlb	
	incbin	alkuanim\frame058.dlb	
	incbin	alkuanim\frame059.dlb	
	incbin	alkuanim\frame060.dlb
	incbin	alkuanim\frame061.dlb	
	incbin	alkuanim\frame062.dlb	
	incbin	alkuanim\frame063.dlb	
	incbin	alkuanim\frame064.dlb	
	incbin	alkuanim\frame065.dlb	
	incbin	alkuanim\frame066.dlb	
	incbin	alkuanim\frame067.dlb	
	incbin	alkuanim\frame068.dlb	
	incbin	alkuanim\frame069.dlb	
	incbin	alkuanim\frame070.dlb	
	incbin	alkuanim\frame071.dlb	
	incbin	alkuanim\frame072.dlb	
	incbin	alkuanim\frame073.dlb	
	incbin	alkuanim\frame074.dlb	
	incbin	alkuanim\frame075.dlb	
	incbin	alkuanim\frame076.dlb	
	incbin	alkuanim\frame077.dlb	
	incbin	alkuanim\frame078.dlb	
	incbin	alkuanim\frame079.dlb	
	incbin	alkuanim\frame080.dlb	
	incbin	alkuanim\frame081.dlb	
	incbin	alkuanim\frame082.dlb	
	incbin	alkuanim\frame083.dlb	
	incbin	alkuanim\frame084.dlb	
	incbin	alkuanim\frame085.dlb	
	incbin	alkuanim\frame086.dlb	
	incbin	alkuanim\frame087.dlb	
	incbin	alkuanim\frame088.dlb	
	incbin	alkuanim\frame089.dlb	
	incbin	alkuanim\frame090.dlb	
	incbin	alkuanim\frame091.dlb	
	incbin	alkuanim\frame092.dlb	
	incbin	alkuanim\frame093.dlb	
	incbin	alkuanim\frame094.dlb	
	incbin	alkuanim\frame095.dlb	
	incbin	alkuanim\frame096.dlb	
	incbin	alkuanim\frame097.dlb	
	incbin	alkuanim\frame098.dlb	
	incbin	alkuanim\frame099.dlb	
	incbin	alkuanim\frame100.dlb	
	incbin	alkuanim\frame101.dlb	
	incbin	alkuanim\frame102.dlb	
	incbin	alkuanim\frame103.dlb	
	incbin	alkuanim\frame104.dlb	
	incbin	alkuanim\frame105.dlb	
	incbin	alkuanim\frame106.dlb	
	incbin	alkuanim\frame107.dlb	
	incbin	alkuanim\frame108.dlb	
	incbin	alkuanim\frame109.dlb	
	incbin	alkuanim\frame110.dlb	
	incbin	alkuanim\frame111.dlb	
	ENDC

fade.deltavika
	incbin	alkuanim\frame112.dlb
	even

fade.vdata
	incbin	alkuanim\light000.dld
	incbin	alkuanim\light001.dld
	incbin	alkuanim\light002.dld
	incbin	alkuanim\light003.dld
	incbin	alkuanim\light004.dld
	incbin	alkuanim\light005.dld

fade.data
	IFEQ	1
	incbin	alkuanim\frame000.dld	
	incbin	alkuanim\frame001.dld	
	incbin	alkuanim\frame002.dld	
	incbin	alkuanim\frame003.dld	
	incbin	alkuanim\frame004.dld	
	incbin	alkuanim\frame005.dld	
	incbin	alkuanim\frame006.dld	
	incbin	alkuanim\frame007.dld	
	incbin	alkuanim\frame008.dld	
	incbin	alkuanim\frame009.dld	
	incbin	alkuanim\frame010.dld	
	incbin	alkuanim\frame011.dld	
	incbin	alkuanim\frame012.dld	
	incbin	alkuanim\frame013.dld	
	incbin	alkuanim\frame014.dld	
	incbin	alkuanim\frame015.dld	
	incbin	alkuanim\frame016.dld	
	incbin	alkuanim\frame017.dld	
	incbin	alkuanim\frame018.dld	
	incbin	alkuanim\frame019.dld	
	incbin	alkuanim\frame020.dld	
	incbin	alkuanim\frame021.dld	
	incbin	alkuanim\frame022.dld	
	incbin	alkuanim\frame023.dld	
	incbin	alkuanim\frame024.dld	
	incbin	alkuanim\frame025.dld	
	incbin	alkuanim\frame026.dld	
	incbin	alkuanim\frame027.dld	
	incbin	alkuanim\frame028.dld	
	incbin	alkuanim\frame029.dld	
	incbin	alkuanim\frame030.dld	
	incbin	alkuanim\frame031.dld	
	incbin	alkuanim\frame032.dld	
	incbin	alkuanim\frame033.dld	
	incbin	alkuanim\frame034.dld	
	incbin	alkuanim\frame035.dld	
	incbin	alkuanim\frame036.dld	
	incbin	alkuanim\frame037.dld	
	incbin	alkuanim\frame038.dld	
	incbin	alkuanim\frame039.dld	
	incbin	alkuanim\frame040.dld	
	incbin	alkuanim\frame041.dld	
	incbin	alkuanim\frame042.dld	
	incbin	alkuanim\frame043.dld	
	incbin	alkuanim\frame044.dld	
	incbin	alkuanim\frame045.dld	
	incbin	alkuanim\frame046.dld	
	incbin	alkuanim\frame047.dld	
	incbin	alkuanim\frame048.dld	
	incbin	alkuanim\frame049.dld	
	incbin	alkuanim\frame050.dld	
	incbin	alkuanim\frame051.dld	
	incbin	alkuanim\frame052.dld	
	incbin	alkuanim\frame053.dld	
	incbin	alkuanim\frame054.dld	
	incbin	alkuanim\frame055.dld	
	incbin	alkuanim\frame056.dld	
	incbin	alkuanim\frame057.dld	
	incbin	alkuanim\frame058.dld	
	incbin	alkuanim\frame059.dld	
	incbin	alkuanim\frame060.dld
	incbin	alkuanim\frame061.dld	
	incbin	alkuanim\frame062.dld	
	incbin	alkuanim\frame063.dld	
	incbin	alkuanim\frame064.dld	
	incbin	alkuanim\frame065.dld	
	incbin	alkuanim\frame066.dld	
	incbin	alkuanim\frame067.dld	
	incbin	alkuanim\frame068.dld	
	incbin	alkuanim\frame069.dld	
	incbin	alkuanim\frame070.dld	
	incbin	alkuanim\frame071.dld	
	incbin	alkuanim\frame072.dld	
	incbin	alkuanim\frame073.dld	
	incbin	alkuanim\frame074.dld	
	incbin	alkuanim\frame075.dld	
	incbin	alkuanim\frame076.dld	
	incbin	alkuanim\frame077.dld	
	incbin	alkuanim\frame078.dld	
	incbin	alkuanim\frame079.dld	
	incbin	alkuanim\frame080.dld	
	incbin	alkuanim\frame081.dld	
	incbin	alkuanim\frame082.dld	
	incbin	alkuanim\frame083.dld	
	incbin	alkuanim\frame084.dld	
	incbin	alkuanim\frame085.dld	
	incbin	alkuanim\frame086.dld	
	incbin	alkuanim\frame087.dld	
	incbin	alkuanim\frame088.dld	
	incbin	alkuanim\frame089.dld	
	incbin	alkuanim\frame090.dld	
	incbin	alkuanim\frame091.dld	
	incbin	alkuanim\frame092.dld	
	incbin	alkuanim\frame093.dld	
	incbin	alkuanim\frame094.dld	
	incbin	alkuanim\frame095.dld	
	incbin	alkuanim\frame096.dld	
	incbin	alkuanim\frame097.dld	
	incbin	alkuanim\frame098.dld	
	incbin	alkuanim\frame099.dld	
	incbin	alkuanim\frame100.dld	
	incbin	alkuanim\frame101.dld	
	incbin	alkuanim\frame102.dld	
	incbin	alkuanim\frame103.dld	
	incbin	alkuanim\frame104.dld	
	incbin	alkuanim\frame105.dld	
	incbin	alkuanim\frame106.dld	
	incbin	alkuanim\frame107.dld	
	incbin	alkuanim\frame108.dld	
	incbin	alkuanim\frame109.dld	
	incbin	alkuanim\frame110.dld	
	incbin	alkuanim\frame111.dld	
	ENDC

	incbin	alkuanim\frame112.dld	

	even
		RSRESET
fade.ruutu:	RS.W	(384*256)+256
fade.buffer	rs.w	65536
***********************************************************

