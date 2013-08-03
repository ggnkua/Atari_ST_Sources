
	OPT	d+,c-,p=68030

showrastertime	= 0
linewidth	= 320*2
screenkorkeus	= 128
leveys		= 128
xsize		= 128-16
ysize		= 128
superpixels	= 1		; 0 = disabled, 1 = enabled
raster		= 0
motion		= 1
memory		= 1536


;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;

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
	DC.L	DSP_LOAD
	DC.L	initplasma
	DC.L	motionplasma
	dc.l	viimeinen


;------------
tuomioTV:
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


address.screen1:DS.L	1
address.screen2:DS.L	1

*********************************************************************************
*
* Motion plasma
*
*********************************************************************************

initplasma:
	move.l	#tuomiotv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr

	move.l	#screen+256,d0
	clr.b	d0
	move.l	d0,address.screen1
	move.l	d0,adr_screen1
	move.l	d0,d1
	add.l	#384*300*2,d1
	move.l	d1,address.screen2

	bsr	presin

	move.w	#$2700,sr
	move.b	#%00000000,$fffffa07.w
	move.b	#%11000000,$fffffa09.w
	move.b	#%00000000,$fffffa13.w
	move.b	#%11000000,$fffffa15.w
	move.l	#key_r,$118.w
	move.w	#$2300,sr

	IFEQ	superpixels-1
	move.w	#$00c7,$ffff8282.w	hht
	move.w	#$00a0,$ffff8284.w	hbb
	move.w	#$001f,$ffff8286.w	hbd
	move.w	#$02c7,$ffff8288.w	hdb
	move.w	#$0096,$ffff828a.w	hde
	move.w	#$00aa,$ffff828c.w	hss

	move.w	#$0271,$ffff82a2.w	vft
	move.w	#$0265,$ffff82a4.w	vbd
	move.w	#$002f,$ffff82a6.w	vbe
	move.w	#$004b,$ffff82a8.w	vdb
	move.w	#$004b+512,$ffff82aa.w	vde
	move.w	#$026b,$ffff82ac.w	vss

	move.b	#$02,$ffff820a.w	st 50hz
	move.w	#$0186,$ffff82c0.w	vclock
	move.w	#$000,$ffff8266.w	
	move.w	#$100,$ffff8266.w	spshift (vmode)
	move.w	#$001,$ffff82c2.w	vco
	move.w	#$140,$ffff8210.w	wide
	ENDC

	bsr	venko_write_curves_init
	bsr	venko_write_gfx

	move.l	#omavbl,own_vbl
	addq.w	#1,activepoint

	rts

omavbl:
	move.l	#$0,$ffff9800.w
	rts

motionplasma:
	bsr	venko_write_curves
	bsr	venko_write_values
	bsr	plasmie
*	move.l	#$ffff00ff,$ffff9800.w
	rts


sinposz:DC.W	0

plasmie:
	bsr	altervalues
	bsr	yrotate

	movec	cacr,d0
	bclr	#8,d0
	movec	d0,cacr

	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0		;read words..

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp1	btst	#1,(a1)		
	beq.s	.lp1
	move.l	#0,-2(a0)
.lp2	btst	#1,(a1)		; pakko hidastaa lukemista...
	beq.s	.lp2		; ts. pakko nopeuttaa dsp-kirjoitusta

	move.l	address.screen1(pc),a3
	lea	16*2(a3),a3
	move.w	abbaa(pc),d5
	*add.w	d5,a3
	IFNE	raster
	eor.w	#2,abbaa
	move.l	#linewidth-xsize*6,a5
	ELSE
	move.l	#linewidth-xsize*4,a5
	ENDC
	move.l	#pic+65536,d3
	move.l	#motiontab+65536*2,d4
	asr.l	d4
	clr.l	d1
	move.w	#ysize-1,d6
.ylp1:
	moveq	#xsize/8-1,d7
	clr.w	d2
	IFNE	raster
	eor.w	#2,d5
	ENDC
	add.w	d5,a3
.xlp1:
	REPT	4
	IFNE	motion
	move.w	(a0),d2
	move.w	d3,(a3)+
	IFNE	raster
	addq.l	#2,a3
	ENDC
	move.w	(a3),d4
	add.w	(d4.l*2),d2
	move.w	d2,(a3)+

	move.w	(a0),d3
	move.w	d2,(a3)+
	IFNE	raster
	addq.l	#2,a3
	ENDC
	move.w	(a3),d4
	add.w	(d4.l*2),d3
	move.w	d3,(a3)+
	ELSE
	move.w	(a0),d2
	move.w	d2,(a3)+
	IFNE	raster
	addq.l	#2,a3
	ENDC
	move.w	d2,(a3)+
	move.w	(a0),d2
	move.w	d2,(a3)+
	IFNE	raster
	addq.l	#2,a3
	ENDC
	move.w	d2,(a3)+
	ENDC
	ENDR
	dbf	d7,.xlp1
	sub.w	d5,a3
	add.l	a5,a3
.lpf	btst	#1,(a1)
	beq.s	.lpf
	dbf	d6,.ylp1
	rts
aaa:
abbaa:	DC.W	0


; yhdist„ y-distin sinik„yr„„n rotaation y-komponentit

yrotate:
	lea	sin2b(pc),a6
	lea	sin5b(pc),a5
	lea	sin(pc),a0
	move.w	angle1(pc),d0
	lea	(a0,d0.w*2),a0
	move.w	64*2(a0),d0		; - cos = y(x)
	sub.w	#128,d0
	neg.w	d0
	muls	z(pc),d0
	asr.l	#8,d0
	move.l	d0,a1
	move.w	d0,d1
	muls	#-screenkorkeus/2,d1
	move.w	(a0),d0			; sin = x(x)
	sub.w	#128,d0
 muls	#3,d0
 asr.l	d0
	muls	z(pc),d0
	asr.l	#8,d0
	move.l	d0,a2
	move.w	d0,d2
	muls	#-leveys/2,d2

	move.w	(a0),d0			; sin = y(y)
	sub.w	#128,d0
	muls	z(pc),d0
	asr.l	#8,d0
	move.l	d0,d6
	move.w	d0,d3
	muls	#-screenkorkeus/2,d3
	move.w	64*2(a0),d0		; cos = x(y)
	sub.w	#128,d0
 muls	#3,d0
 asr.l	d0
	muls	z(pc),d0
	asr.l	#8,d0
	move.l	d0,a0
	move.w	d0,d4
	muls	#-leveys/2,d4

	add.l	#128<<8,d2

	moveq	#2*xsize/4-1,d7
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


altervalues:
	move.w	angle1(pc),d0
	add.w	#1,d0
	and.w	#$ff,d0
	move.w	d0,angle1
	move.w	sinposz(pc),d0
	add.w	#6,d0
	and.w	#$3ff,d0
	move.w	d0,sinposz

	lea	sin(pc),a0
	move.w	sinposz(pc),d0
	asr.w	#2,d0
	lea	(a0,d0.w*2),a0
	move.w	(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	#96,d0
	move.w	d0,z
	rts

sinsize:	DC.L	0
delay1:		DC.W	0
delay2:		DC.W	0

presin:
	lea	sin(pc),a0
	lea	256*2(a0),a1
	move.w	#128*7-1,d7
.sinlp1:
	move.l	(a0)+,(a1)+
	dbf	d7,.sinlp1

	move.l	#motiontab+65536*2,d0
	and.l	#-65536*2,d0
	move.l	d0,a1
	moveq	#0,d2
	move.w	#32768-1,d7
	move.w	#%0011100111100111,d3
.motionlp1:
	REPT	2
	move.w	d2,d0
	move.w	d0,d1		1
	move.w	d0,d4
	and.w	#%11111,d0
	and.w	#%11111100000,d1
	and.w	#%1111100000000000,d4
	mulu	#3,d0
	mulu	#3,d1
	mulu	#3,d4
	lsr.w	#2,d0	
	lsr.w	#2,d1	
	lsr.l	#2,d4	
	and.w	#%11111,d0
	and.w	#%11111100000,d1
	and.w	#%1111100000000000,d4
	or.w	d1,d0
	or.w	d4,d0

*	lsr.w	#2,d1		1
*	and.w	d3,d1		1
*	sub.w	d1,d0		1

	move.w	d0,(a1)+
	addq.l	#1,d2
	ENDR
	dbf	d7,.motionlp1

	lea	picture,a0
	move.l	#pic+65536,d0
	clr.w	d0
	move.l	d0,a1
	move.w	#128-1,d6
.ylp1:
	move.w	#128-1,d7
.xlp1:
	move.w	(a0)+,d0
	IFNE	motion
	and.w	#$e0,d0
	lsl.w	#8-2,d0
	move.b	(a0)+,d1
	and.w	#$f0,d1
	lsl.w	#1,d1
	or.w	d1,d0
	move.b	(a0)+,d1
	and.w	#$e0,d1
	lsr.w	#5,d1
	or.w	d1,d0
	ELSE
	and.w	#$f8,d0
	lsl.w	#8,d0
	move.b	(a0)+,d1
	and.w	#$fc,d1
	lsl.w	#3,d1
	or.w	d1,d0
	move.b	(a0)+,d1
	and.w	#$f8,d1
	lsr.w	#3,d1
	or.w	d1,d0
	ENDC
	move.w	d0,(256*128.l,a1)
	move.w	d0,(a1)+
	dbf	d7,.xlp1
	*lea	320*3-128*6(a0),a0
	dbf	d6,.ylp1
	rts
aaaaa
	lea	picture+320*3*64+3*64+15,a0
	move.l	#pic+65536,d0
	clr.w	d0
	move.l	d0,a1
	move.w	#128*2-1,d6
.ylp1:
	move.w	#128*2-1,d7
.xlp1:
	move.b	(a0)+,d0
	and.w	#$e0,d0
	lsl.w	#8-2,d0
	move.b	(a0)+,d1
	and.w	#$f0,d1
	lsl.w	#1,d1
	or.w	d1,d0
	move.b	(a0)+,d1
	and.w	#$e0,d1
	lsr.w	#5,d1
	or.w	d1,d0
	move.w	d0,(a1)+
	dbf	d7,.xlp1
	lea	320*3-128*6(a0),a0
	dbf	d6,.ylp1
	rts

; 0	x steppaa joka pixel 
; 1	x sama
; 2	x sama
; 3	x0 offset scanline alkuun
; 4	x1 sama
; 5	y steppaa joka scanline (sin*leveys)
; 6	y sama 
; 7	y steppaa joka pikseli

;---------------------------------------------
venko_write_values:
	lea	incs(pc),a0
	lea	baset(pc),a1
	lea	modit(pc),a2

	moveq	#8-1,d7
.inclp1:
	move.w	(a2)+,d0
	move.w	(a1),d1
	move.w	d1,d2
	add.w	(a0)+,d1
	and.w	d0,d1
	not.w	d0
	and.w	d0,d2
	or.w	d1,d2
	move.w	d2,(a1)+
	dbf	d7,.inclp1

	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	#1,-2(a0)		; feed x and y size,bases,steps,mods

	lea	infot(pc),a2
	moveq	#26-1,d7
.infolp1:
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.w	(a2)+,(a0)
	dbf	d7,.infolp1
	rts

;---------------------------------------------
venko_write_gfx:
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	#3,-2(a0)		; feed gfx

	move.l	#pic+65536,d0
	clr.w	d0
	move.l	d0,a2
	moveq	#128-1,d6
.ylp1:
	moveq	#128-1,d7
.xlp1:
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.w	(a2)+,(a0)
	dbf	d7,.xlp1
	dbf	d6,.ylp1
	rts

infot:
	dc.w	xsize
	dc.w	ysize
baset:	dc.w	$0400,$1000,$0200,$1000,$0200,$0500,$1000,$1000	;base
stepit:	dc.w	$0001,$0004,$0000,$0002,$0001,$0001,$0003,$0004	;step
modit:	dc.w	$00ff,$00ff,$00ff,$00ff,$00ff,$00ff,$00ff,$00ff	;mod

incs:	DC.W	$0000,$0001,$0000,$0002,$0000,$0000,$0001,$0003 ;base increments

;---------------------------------------------
venko_write_curves_init:
	lea	nullsin(pc),a2
	move.w	#$200,d6
	bsr	feed
	lea	countsin(pc),a2
	move.w	#$300,d6
	bsr	feed

	lea	sin(pc),a0
	lea	dspsin(pc),a1
	move.w	#$10,d1
	move.w	#256-1,d7
.lp1dsp:
	move.w	(a0)+,d0
	mulu	d1,d0
	asr.l	#8,d0
	move.w	d0,(a1)+
	dbf	d7,.lp1dsp
	move.w	#$1000,d6
	lea	dspsin(pc),a2
	bsr	feed
	rts

;---------------------------------------------
venko_write_curves:
	lea	sin2b(pc),a2
	move.w	#$400,d6
	bsr	feed
	lea	sin5b(pc),a2
	move.w	#$500,d6
	bsr	feed
	rts

feed:
	lea	$ffffa202.w,a1	
	lea	$ffffa206.w,a0

.lpx	btst	#0,(a1)		
	beq.s	.lpx
	move.w	(a0),d0
	cmp.w	#$babe,d0
	bne	reset

.lp	btst	#1,(a1)		
	beq.s	.lp		

	move.l	#2,-2(a0)	; feed curve
.lp2	btst	#1,(a1)		
	beq.s	.lp2		
	move.w	d6,(a0)		; base location in x ram
.lp3	btst	#1,(a1)		
	beq.s	.lp3	
	move.w	#256,(a0)	; length

	move.w	#256-1,d7
.curvelp1:
.lp4	btst	#1,(a1)		
	beq.s	.lp4
	move.w	(a2)+,d0
	ext.l	d0
	add.l	d0,d0
	move.l	d0,-2(a0)
	dbf	d7,.curvelp1
	rts

nullsin:
	DCB.W	256,0
countsin:
n	SET	0
	REPT	256
	DC.W	n
n	SET	n+1
	ENDR

sin2b:	DS.W	256*2
sin5b:	DS.W	256*2

;---------------------------------------------
tuomio_read
*	lea	$ffffa202.w,a1	
*	lea	$ffffa206.w,a0		;read words..
*	lea	z_buffer,a2
*
*.lp	btst	#0,(a1)		
*	beq.s	.lp		
*	move.w	#384-1,d0
*.lp2	
*	move.w	(a0),(a2)+
*	move.w	(a0),(a2)+
*	move.w	(a0),(a2)+		;get z,txt,x_off
*	dbf	d0,.lp2
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
	incbin	"dsp\venko3.p56",0
	even
dsp_end
	even
;----------------------------------------

angle1:	DC.W	0
z:	DC.W	64

dspsin:	DCB.W	256
sin:
	DC.W	$007F,$0082,$0085,$0088,$008B,$008E,$0091,$0094
	DC.W	$0097,$009B,$009E,$00A1,$00A4,$00A7,$00AA,$00AD
	DC.W	$00B0,$00B2,$00B5,$00B8,$00BB,$00BE,$00C0,$00C3
	DC.W	$00C6,$00C8,$00CB,$00CD,$00D0,$00D2,$00D5,$00D7
	DC.W	$00D9,$00DB,$00DD,$00DF,$00E2,$00E3,$00E5,$00E7
	DC.W	$00E9,$00EB,$00EC,$00EE,$00EF,$00F1,$00F2,$00F4
	DC.W	$00F5,$00F6,$00F7,$00F8,$00F9,$00FA,$00FB,$00FB
	DC.W	$00FC,$00FD,$00FD,$00FE,$00FE,$00FE,$00FE,$00FE
	DC.W	$00FE,$00FE,$00FE,$00FE,$00FE,$00FE,$00FD,$00FD
	DC.W	$00FC,$00FB,$00FB,$00FA,$00F9,$00F8,$00F7,$00F6
	DC.W	$00F5,$00F3,$00F2,$00F1,$00EF,$00EE,$00EC,$00EA
	DC.W	$00E9,$00E7,$00E5,$00E3,$00E1,$00DF,$00DD,$00DB
	DC.W	$00D9,$00D7,$00D4,$00D2,$00CF,$00CD,$00CA,$00C8
	DC.W	$00C5,$00C3,$00C0,$00BD,$00BB,$00B8,$00B5,$00B2
	DC.W	$00AF,$00AC,$00A9,$00A6,$00A3,$00A0,$009D,$009A
	DC.W	$0097,$0094,$0091,$008E,$008B,$0088,$0084,$0081
	DC.W	$007F,$007C,$0079,$0076,$0073,$006F,$006C,$0069
	DC.W	$0066,$0063,$0060,$005D,$005A,$0057,$0054,$0051
	DC.W	$004E,$004B,$0048,$0046,$0043,$0040,$003D,$003B
	DC.W	$0038,$0035,$0033,$0030,$002E,$002C,$0029,$0027
	DC.W	$0025,$0022,$0020,$001E,$001C,$001A,$0018,$0017
	DC.W	$0015,$0013,$0011,$0010,$000E,$000D,$000C,$000A
	DC.W	$0009,$0008,$0007,$0006,$0005,$0004,$0003,$0002
	DC.W	$0002,$0001,$0001,$0000,$0000,$0000,$0000,$0000
	DC.W	$0000,$0000,$0000,$0000,$0000,$0001,$0001,$0001
	DC.W	$0002,$0003,$0003,$0004,$0005,$0006,$0007,$0008
	DC.W	$0009,$000B,$000C,$000D,$000F,$0010,$0012,$0014
	DC.W	$0015,$0017,$0019,$001B,$001D,$001F,$0021,$0023
	DC.W	$0025,$0028,$002A,$002C,$002F,$0031,$0034,$0036
	DC.W	$0039,$003C,$003E,$0041,$0044,$0047,$0049,$004C
	DC.W	$004F,$0052,$0055,$0058,$005B,$005E,$0061,$0064
	DC.W	$0067,$006A,$006D,$0071,$0074,$0077,$007A,$007D
	DS.W	256*7

	DATA

picture:
	INCBIN	eye.c24
*	rept	64
*	dcb.l	64,$000000
*	dcb.l	64,$ffffff
*	endr
*	rept	64
*	dcb.l	64,$ffffff
*	dcb.l	64,$000000
*	endr
	*INCBIN	c:\sources\joker.c24
	*INCBIN	c:\sources\atari.ppm

	BSS

screen:	DCB.W	128*256*2,0
pic:	DS.W	256*384+32768
motiontab:
	DS.B	65536*3
