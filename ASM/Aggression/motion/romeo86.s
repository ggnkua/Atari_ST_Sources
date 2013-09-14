;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;
; DSP booter,dsp time test
; Motion, color shader
; DSP feed C value format: 
; Cx,Cy  * 256*256*64, signed
; walkpaths with destinations (no more sin curves)

	TEXT

romeo.run	= 1

rslidespeed	equ	500
rwalkspeed	equ	2000

	IFNE	romeo.run

memory	= 1536*1024

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
	dc.l	romeo.dsp_load
	DC.L	romeoinit
	dc.l	romeo
	dc.l	viimeinen
	ENDC

;-----------------------------------------------------
; ROMEO-DSP
;-----------------------------------------------------
romeoinit:
	move.l	address.freemem,d0
	add.l	#romeo.ruutu+256,d0
	clr.b	d0
	move.l	d0,adr_screen1
	bsr	.wipe
	add.l	#768*256,d0
	move.l	d0,adr_screen2
	bsr	.wipe
	clr.w	romeo.time
	addq.w	#1,activepoint

	lea	romeo.col.listat,a0
	move.l	a0,romeoslidepointer
	
	lea	romeo.walk,a0
	move.l	a0,romeo.walk.pointer

	bsr	romeo_write2
	bsr	romeo_read

	move.l	address.freemem,a0
	move.l	a0,a1
	add.l	#X_old,a0
	add.l	#X_buf,a1
	move.l	#$00020002,d1
	move.w	#(1024*2)-1,d7
.ww2	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	dbf	d7,.ww2

	lea	Xcolor,a0
	moveq	#0,d0
	move.w	#255,d7
.test2	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d7,.test2	

	bsr	romeo_write2

	rts
;----
.wipe
	move.l	d0,a0
	moveq	#0,d1
	move.w	#384*256/8,d7
.ww
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d7,.ww
	rts
;------------------------------------
romeo
	bsr	romeo_read
	bsr	romeo_write2
	bsr	romeo.gen_color
	bsr	romeo_render

	lea	adr_screen1,a0
	movem.l	(a0),d0-d1
	move.l	d1,(a0)+
	move.l	d0,(a0)


	rts

romeo.time:
	DC.W	0

;---------------------------------------------
romeo_read
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..
	move.l	address.freemem,a4
	lea	x_buf(a4),a4
	move.w	#(128*64)-1,d0

.lp2	btst	#0,(a1)		
	beq.s	.lp2

.www	move.w	(a0),(a4)+
	dbf	d0,.www
	rts
;---------------------------------------------
romeo_write2
	lea	$ffffa202.w,a1	
	lea	$ffffa204.w,a2

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	romeo.walk.pointer,a0
	moveq	#0,d7
	move.w	romeo.walk.slide,d7
	add.w	#rwalkspeed,d7
	bcc.s	.nonextr
	lea	8(a0),a0
	tst.l	8(a0)
	bne.s	.nonextr
	lea	romeo.walk,a0			
.nonextr
	move.w	d7,romeo.walk.slide
	move.l	a0,romeo.walk.pointer

	move.w	d7,d0
	lsr.w	d0
	add.w	#$7fff,d0
	jsr	Xcos

	moveq	#0,d7
	move.w	d1,d7
	add.w	#$8000,d7

;	lsr.w	#8,d7
;	move.l	adr_screen2,a3
;	lea	(a3,d7.l*2),a3
;	move.l	#0,(a3)+
;	move.l	#0,(a3)+
;	move.l	#-1,(a3)+
;	move.l	#0,(a3)+
;	move.l	#0,(a3)+

; slide d7 mukaan 0-ffff (start-dest)
	move.l	#$ffff,d6
	sub.l	d7,d6
	move.l	(a0),d0
	move.l	8(a0),d2
	muls.l	d6,d1:d0
	muls.l	d7,d3:d2
	move.w	d1,d0
	move.w	d3,d2
	swap	d0
	swap	d2
	add.l	d2,d0
	move.l	d0,(a2)		;Cx

	move.l	4(a0),d0
	move.l	12(a0),d2
	muls.l	d6,d1:d0
	muls.l	d7,d3:d2
	move.w	d1,d0
	move.w	d3,d2
	swap	d0
	swap	d2
	add.l	d2,d0
	move.l	d0,(a2)		;Cy

	rts

romeo.walk.slide	dc.w	0
romeo.walk.pointer	dc.l	0
;---------------------------------------------
romeo_render

	move.l	adr_screen2,a2
	move.l	a2,a3
	add.l	#(768*64)+128,a2
	add.l	#(768*63)+512+128,a3
	move.l	address.freemem,a4
	lea	x_buf(a4),a4
	lea	x_old(a4),a5
	
	movec	cacr,d0
	bclr	#13,d0
	bclr	#8,d0
	bset	#0,d0
	movec	d0,cacr

	move.w	#63,d0			;render_2_screen
.hi
	move.w	#128/4-1,d1
.lo
	rept	4
	move.w	(a4)+,d2
	add.w	(a5),d2
	move.l	xcolor(pc,d2.w*4),d7
	move.l	d7,(a2)+		
	lsr	d2
	move.w	d2,(a5)+
	move.l	d7,-(a3)		
	endr
	dbf	d1,.lo
		
	lea	768-512(a2),a2
	lea	512-768(a3),a3
	dbf	d0,.hi

	lea	Xcolor,a0
	move.l	adr_screen2,a1
	move.w	#128,d7
.test	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	lea	768(a1),a1
	dbf	d7,.test	
	rts
;---------------
xcolor
	ds.w	128*4			;convaus colorlookuptable
	ds.w	128*4			;varaa yli-iteroille
;------------------------------------------------------------------------
romeo.gen_color
rpalat		equ	3
	
	move.l	romeoslidepointer,a6
	lea	.slidevalue,a0
	move.w	(a0),d6
	add.w	#rslidespeed,d6
	bcc.s	.noslidejump
	lea	16(a6),a6
	tst.l	16(a6)
	bge.s	.nowapr
	lea	romeo.col.listat,a6
.nowapr
	move.l	a6,romeoslidepointer	
.noslidejump
	move.w	d6,(a0)
	move.w	#$ffff,d5
	sub.w	d6,d5
	movem.w	d5-d6,-(sp)
	
	moveq	#rpalat-1,d7			;partit
	lea	xcolor(pc),a5
.slideone
	movem.w	(sp),d5-d6
	move.w	#$00ff,d4	;Blue
	move.l	(a6),d0
	and.w	d4,d0
	move.l	16(a6),d1
	and.w	d4,d1
	mulu.w	d5,d0
	mulu.w	d6,d1				;slide d0 > d1
	add.l	d1,d0

	move.l	4(a6),d1
	and.w	d4,d1
	move.l	20(a6),d2
	and.w	d4,d2
	mulu.w	d5,d1
	mulu.w	d6,d2
	add.l	d2,d1		;shade B d0 -> d1, 256/4 steps

	sub.l	d0,d1
	divs.l	#256/rpalat,d1
	asr.l	#3,d1
	asr.l	#3,d0
	move.l	d1,a0

	move.l	(a6),d1			;Green
	lsr.l	#8,d1
	and.w	d4,d1
	move.l	16(a6),d2
	lsr.l	#8,d2
	and.w	d4,d2
	mulu.w	d5,d1
	mulu.w	d6,d2				;slide d0 > d1
	add.l	d2,d1

	move.l	4(a6),d2
	lsr.l	#8,d2
	and.w	d4,d2
	move.l	20(a6),d3
	lsr.l	#8,d3
	and.w	d4,d3
	mulu.w	d5,d2
	mulu.w	d6,d3
	add.l	d3,d2		;shade G d0 -> d1, 256/4 steps

	sub.l	d1,d2
	divs.l	#256/rpalat,d2
	asl.l	#3,d2
	asl.l	#3,d1
	move.l	d2,a1

	move.l	(a6),d2		;RED
	swap	d2
	and.w	d4,d2
	move.l	16(a6),d3
	swap	d3
	and.w	d4,d3
	mulu.w	d5,d2
	mulu.w	d6,d3				;slide d0 > d1
	add.l	d3,d2

	move.l	d7,a2
	move.l	4(a6),d3
	swap	d3
	and.w	d4,d3
	move.l	20(a6),d7
	swap	d7
	and.w	d4,d7
	mulu.w	d5,d3
	mulu.w	d6,d7
	add.l	d7,d3		;shade R d0 -> d1, 256/4 steps
	move.l	a2,d7

	sub.l	d2,d3
	divs.l	#256/rpalat,d3
	asr.l	#8,d3
	move.l	d3,a2
	lsr.l	#8,d2

	moveq	#(255/rpalat)-1,d6
.shader
	add.l	a0,d0		;steppaa rpalan shade
	add.l	a1,d1
	add.l	a2,d2

	move.l	d0,d3		;B
	move.l	d1,d4		;G
	move.l	d2,d5		;R
	swap	d3
	swap	d4
	and.w	#$f800,d5
	or.w	d4,d5
	and.w	#$ffe0,d5
	or.w	d3,d5
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	dbf	d6,.shader

	add.l	#4,a6
	dbf	d7,.slideone
	addq.l	#4,sp
	move.w	d5,d6
	swap	d6
	move.w	d5,d6
	move.l	d6,(a5)+
	move.l	d6,(a5)+
	move.l	d6,(a5)+
	move.l	d6,(a5)+
	rts
;---
.slidevalue	dc.w	0
romeoslidepointer	dc.l	0
;------------------------------------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
romeo.DSP_LOAD:
	move.l	#romeotv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr


	MOVE.W	#1,-(SP)
	move.l	#(romeo.dsp_ende-romeo.dsp_code)/3,-(sp)
	move.l	#romeo.dsp_code+9,-(sp)		;devpac56:n headereita
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
.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	d0,(a0)	
.lp2	btst	#0,(a1)		
	beq.s	.lp2		
	move.l	(a0),d1
	lsl.l	#1,d0
	cmp.l	d0,d1
	bne.l	reset

	addq.w	#1,activepoint
	rts

romeo.dsp_code
	incbin	dsp\romeo.p56
romeo.dsp_ende
	even
;-------------
romeoTV:
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
.VCO	SET	$001		; Video Control
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

;---------------------------------------------------

		DATA

romeo.col.listat
	dc.l	$000040,$0140ff,$ff80ff,$ffffff
	dc.l	$0000ff,$00ffff,$ffffff,$ff0000
	dc.l	$ff0000,$00ff00,$ffffff,$ffffff
	dc.l	$800000,$ff8000,$ffff00,$ffffff
	dc.l	$000040,$0140ff,$ff80ff,$ffffff

	dc.l	-1

romeo.walk
; Cr: 64*256*256 sign, Ci: -64*256*256  (6 first desimals floty) 
	dc.l	$00000001,$00000001
	dc.l	-3269602,-382839
	dc.l	2123456,1231456
	dc.l	1243345,-564352
	dc.l	-123456,12
	dc.l	2121212,6661234
	dc.l	-123456,-1234
	dc.l	2000000,0
	dc.l	-6000000,0
	dc.l	1200,123456
	dc.l	-5000,-234567
	dc.l	6523676,-123456
	dc.l	-123245,5465472

	dc.l	$00000001,$00000001
	dc.l	0

		RSRESET

x_buf		RS.W	128*64
x_old		RS.W	128*64
romeo.ruutu:	RS.W	(384*256*2)+256
romeo.memend:	RS.W	0

		IFGE	romeo.memend-memory
		FAIL
		ENDC

***********************************************************