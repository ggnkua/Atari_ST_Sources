
	OPT	d+,c-,p=68030

rotta.run	=	1

screenkorkeus	= 128		;rotatiopisteen paikka
leveys		= 128
showrastertime	= 0
xsize		= 160
ysize		= 144
suurin		= 160
superpixels	= 1		; 0 = disabled, 1 = enabled



;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;
	ifne	rotta.run
zekker		=	0
memory	=	1536*1024
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
	DC.L	rotta.DSP_LOAD
	DC.L	initrotta
	DC.L	rotta_juoksee
	dc.l	viimeinen

address.screen1:DS.L	1
address.screen2:DS.L	1
	ENDC

;------------
rottaTV:
.HHT	SET 	$fe	*fe	; Horizontal Hold Timer
.HBB	SET 	$41+32	 $cb	*cb	; Horizontal Border Begin
.HBE	SET 	0+32	 $27-$27	*27	; Horizontal Border End
.HDB	SET 	0+32	 $2e-40	*1c	; Horizontal Display Begin
.HDE	SET 	$41+32	 $8f+40	*7d	; Horizontal Display End
.HSS	SET 	$d8	*d8	; Horizontal Synchro Start

.VFT	SET	$271	*271	; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$247	*265	; V BORDER BLANK
.VBE	SET 	$47	*2f	; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$47	*57	; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$247	*237	; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b	*26b	; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$183	*181	; Video Clock
.VCO	SET	$001		; Video Control
.WIDE	set	320		;screen wide (words)
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
* 24 bit rotator zoomer
*
*********************************************************************************

initrotta:
	move.l	#rottatv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr

	move.l	address.freemem,d0
	add.l	#rotta.ruutu+256,d0
	clr.b	d0
	move.l	d0,address.screen1
	move.l	d0,adr_screen1
	move.l	d0,d1
	add.l	#384*300*2,d1
	move.l	d1,address.screen2


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

	bsr	rotta_clear_dsp
	bsr	rotta_fix_gfx
	
	lea	$ffffa202.w,a1	
	lea	$ffffa204.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	2(a0),d0
	cmp.w	#$babe,d0
	bne.l	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#2,(a0)		; feed gfx to dsp frame buffer

.lp2	btst	#1,(a1)		
	beq.s	.lp2		

	move.l	#$0f0f0f,d0
	move.w	#(128*64)-1,d6
.ylp1:
	move.l	d0,(a0)
	dbf	d6,.ylp1


; feed texture to rotate

	lea	rotta.picture1,a2
.blpx2	btst	#0,(a1)		
	beq.s	.blpx2
	move.w	2(a0),d0
	cmp.w	#$babe,d0
	bne.l	reset

.blp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#2,(a0)		; feed gfx

.blp2	btst	#1,(a1)		
	beq.s	.lp2		

	moveq	#(64)-1,d6
.bylp1:
	moveq	#(128/16)-1,d7
.bxlp1:
	rept	16
	move.l	(a2)+,(a0)
	endr
	dbf	d7,.bxlp1
	lea	128*4(a2),a2
	dbf	d6,.bylp1

	move.l	#omavbl,own_vbl
	addq.w	#1,activepoint

	rts
;----------------------------------------------------
omavbl:
	move.l	#$0,$ffff9800.w
	rts

;---------------------------------------------
;24 bit motion-rotator-zoomer, 16 bit output  WizTom of AGGRESSION
; pitais skulata.. sourcegraffa alkaa $2000, pituus $2000
; max screensize 128*128
; x stepper deltana edelliseen
; y stepper absolut ram address
; kaskyt:
; 0 feed 16 bit to cpu
; just read
; 1 feed x-y stepper to dsp
; x_size, y_size, xstepit, ystepit
; 2 feed 24bit gfx to dsp
; graffaa 128*64
;
;
rotta_juoksee:

	bsr	rotta_write_gfx
	bsr	rotta_calcrotate
	bsr	rotta_write_curves

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr

; kopaa graffa ruudulle

	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne.l	reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#0,-2(a0)

.lp2	btst	#1,(a1)		
	beq.s	.lp2		

	move.l	address.screen1,a3
;	lea	1*2(a3),a3

	move.l	#ysize-1,d6
.yl:
	move.l	#(xsize/16)-1,d7
.xl:
	REPT	16
	move.w	(a0),d1
	move	d1,(a3)+
	move	d1,(a3)+
	endr
	dbf	d7,.xl

.lpf	btst	#1,(a1)
	beq.s	.lpf
	add.l	#(320-xsize*2)*2,a3
	dbf	d6,.yl
	rts

;-------------------
rotta_calcrotate
	move.w	r.zetap,d0
	add.w	#142,d0
	move.w	d0,r.zetap
	jsr	Xsin
	ext.l	d1
	add.l	#$8000,d1
	lsr.l	#6,d1
	add.w	#350,d1
	move.w	d1,r.zeta

	move.w	r.angle(pc),d7
	add.w	#100,d7
	move.w	d7,r.angle
	move.w	d7,d0
	jsr	xsin			;get sin-angle
	move.w	d1,d7
	move.w	d7,d0

	jsr	xsin
	move.w	d1,r.rsin
	move.w	d7,d0
	jsr	xcos
	move.w	d1,r.rcos

	move.w	r.rcos,d0		;cosini
	move.w	d0,d7
	neg.w	d0
	muls	r.zeta(pc),d0
	swap	d0
	move.w	d0,a1
	move.w	d0,d1
	muls	#-screenkorkeus/2,d1
	move.w	r.rsin,d0			; sin = x(x)
	;muls	#3,d0			;x/y korjaus
	;asr.l	d0
	muls	r.zeta(pc),d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,a2
	move.w	d0,d2
	muls	#-leveys/2,d2

	move.w	r.rsin,d0			; sin = y(y)
	muls	r.zeta(pc),d0

	IFNE	superpixels
	asr.l	#2+1,d0
	swap	d0
	muls	#7,d0		;pixel suhde
	ELSE
	swap	d0
	ext.l	d0
	ENDC

	move.l	d0,d6
	move.w	d0,d3
	muls	#-screenkorkeus/2,d3
	move.w	d7,d0			; cos = x(y)
	;muls	#3,d0			;suhdekorjaus
	;asr.l	d0
	muls	r.zeta(pc),d0

	IFNE	superpixels
	asr.l	#1,d0
	swap	d0
	muls	#7,d0		;pixel suhde
	ELSE
	lsl.l	#2,d0
	swap	d0
	ENDC
	
	move.w	d0,a0
	move.w	d0,d4
	muls	#-leveys/2,d4

;	add.l	#128<<8,d2

	lea	rotta.xsteppi,a6
	lea	rotta.ysteppi,a5
	moveq	#suurin/4-1,d7
.lp1:
	REPT	4
	move.l	d1,d0
	move.l	d2,d5
	asr.l	#8,d5			
	move.b	d5,d0
	move.w	d0,(a6)+

	move.l	d3,d0
	move.l	d4,d5
	asr.l	#8,d5
	move.b	d5,d0
	move.w	d0,(a5)+

	add.l	a1,d1
	add.l	a2,d2
	add.l	d6,d3
	add.l	a0,d4
	ENDR
	dbf	d7,.lp1
	rts

r.angle	dc.w	0
r.zeta	dc.w	0
r.zetap	dc.w	0
r.rsin	dc.w	0
r.rcos	dc.w	0
;---------------------------------------------
rotta_clear_dsp
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne.l	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	#3,-2(a0)		; feed gfx

	rts
;---------------------------------------------
rotta_fix_gfx
	lea	rotta.picture1,a0
	move.w	#(4*128*128)-1,d7
	move.l	#$000f0f0f,d1
.hi
	move.l	(a0),d0
	lsr.l	#4,d0
	and.l	d1,d0
	move.l	d0,(a0)+
	dbf	d7,.hi
	rts
;---------------------------------------------
rotta_write_gfx:
	tst.b	keytab+$2
	beq	.skip
	lea	rotta.picture1,a2
	bra	.riisto
.skip
	tst.b	keytab+$3
	beq	.skip2
	lea	rotta.picture2,a2
	bra	.riisto
.skip2
	tst.b	keytab+$4
	beq	.skip3
	lea	rotta.picture3,a2
	bra	.riisto
.skip3
	tst.b	keytab+$5
	beq	.skip4
	lea	rotta.picture4,a2
	bra	.riisto
.skip4
	rts

.riisto
	lea	$ffffa202.w,a1	
	lea	$ffffa204.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	2(a0),d0
	cmp.w	#$babe,d0
	bne.l	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		
	move.l	#2,(a0)		; feed gfx

.lp2	btst	#1,(a1)		
	beq.s	.lp2		

	moveq	#(64)-1,d6
.ylp1:
	moveq	#(128/16)-1,d7
.xlp1:
	rept	16
	move.l	(a2)+,(a0)
	endr
	dbf	d7,.xlp1
	lea	128*4(a2),a2
	dbf	d6,.ylp1
	rts
;---------------------------------------------
rotta_write_curves:
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne.l	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	#1,-2(a0)	; feed curve
.lp1	btst	#1,(a1)		
	beq.s	.lp1	
	move.w	#xsize,(a0)	; length
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.w	#ysize,(a0)	; length

.lp3	btst	#1,(a1)		
	beq.s	.lp3
	lea	rotta.xsteppi,a2
	move.w	#$1fff,d2
	moveq	#0,d1
	move.w	#xsize-1,d7
.curvelp1:
	move.w	(a2)+,d0
	asr.w	#1,d0
	and.w	d2,d0
	move.w	d0,d3
	sub.w	d1,d0
	move.w	d3,d1	

	move.w	d0,(a0)
	dbf	d7,.curvelp1

.lp4	btst	#1,(a1)		
	beq.s	.lp4
	lea	rotta.ysteppi,a2
	move.w	#$1fff,d1
	move.w	#$2000,d2
	move.w	#ysize-1,d7
.curvelp2:
	move.w	(a2)+,d0
	asr.w	d0
	and.w	d1,d0
	add.w	d2,d0
	move.w	d0,(a0)
	dbf	d7,.curvelp2
	rts

rotta.xsteppi	ds.w	suurin
	dc.l	$12345678
rotta.ysteppi	ds.w	suurin
	dc.l	$12345678
;---------------------------------------------
;  DSP ROUTINES..
;------------------------------------------------------------------------
rotta.DSP_LOAD:
	move.w	#$2300,sr
	MOVE.W	#1,-(SP)
	move.l	#(rotta.dsp_end-rotta.dsp_boot)/3,-(sp)
	move.l	#rotta.dsp_boot+9,-(sp)		;devpac56:n headereita
	MOVE.W	#$6e,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	tst.l	d0
	bmi.l	reset			;dsp melted beyond braindamage..
	tst.l	d1
	bmi.l	reset			;dsp melted beyond braindamage..

	addq.w	#1,activepoint
	rts

rotta.dsp_boot
	incbin	"dsp\rotta4.p56",0
	*incbin	a:\rotta4.p56
	even
rotta.dsp_end
	even
;----------------------------------------
	DATA

rotta.picture1:
	INCBIN	eye.c24
rotta.picture2:
	INCBIN	joker.c24
rotta.picture3:
	dcb.l	128*128,0
rotta.picture4:
	rept	64
	dcb.l	64,-1
	dcb.l	64,0
	endr
	rept	64
	dcb.l	64,0
	dcb.l	64,-1
	endr
	BSS
 
	RSRESET

rotta.ruutu:	RS.W	128*256*2
