;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;
; tekstiwriteri+diffusio
; 262k taulun wflowtable sorsan jalkeen.. luodaan initissa vain kerran..  
; vbl fixattu...

write.run	=	1

	IFNE	write.run
	OPT	d+,c-,p=68030

memory	=	500*1024

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

precalc
	move.w	#1000,d0
	move.l	#$0,d1
.xx	rept	20
	addq.l	#1,d1
	move.l	d1,$ffff9800.w
	endr
	dbf	d0,.xx	
	clr.l	$ffff9800.w
	rts

activepoint	dc.w	0	
activelist	
	DC.L	initwrite
	dc.l	precalc
	dc.l	viimeinen
	ENDC

;------------
writeTV:
.HHT	SET 	$fe	*fe	; Horizontal Hold Timer
.HBB	SET 	$a2	 $cb	*cb	; Horizontal Border Begin
.HBE	SET 	$20	 $27-$27	*27	; Horizontal Border End
.HDB	SET 	$30	 $2e-40	*1c	; Horizontal Display Begin
.HDE	SET 	$91	 $8f+40	*7d	; Horizontal Display End
.HSS	SET 	$d8	*d8	; Horizontal Synchro Start

.VFT	SET	$271	*271	; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$227	*265	; V BORDER BLANK
.VBE	SET 	$47	*2f	; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$47	*57	; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$227	*237	; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b	*26b	; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$183	*181	; Video Clock
.VCO	SET	$000		; Video Control
.WIDE	set	320		;screen wide (words)
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


*********************************************************************************
*
*********************************************************************************
initwscreen:

	move.l	address.freemem,d0
	add.l	#wruutu.write+255,d0
	clr.b	d0
	move.l	d0,adr_screen1	;set active
	MOVE.l  d0,wfalconscreen     ;used screen

	move.l	#writetv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr
	
	move.l	#writevbl,own_vbl
	rts

initwrite:
	BSR     wexpand_ball
	BSR     wmakeflowtable
	bsr	initwscreen

	addq.w	#1,activepoint

	rts
;----------------------------------------------------
writevbl:
	move.w	#$2500,sr
	move.l	writesukka,a0
	move.l	(a0),d0
	bne.s	.ok

; zekkaa onko susie precalc valmis, jos ei, exitoi
;	move.w	#$2300,sr
;	rts	
; jos on, tapa writeri..
	addq.w	#1,activepoint
	move.l	#.null,own_vbl
	move.w	#$2300,sr
	rts
.ok	move.l	d0,a0
	jsr	(a0)
	move.w	#$2300,sr
.null	rts

writesukka
	dc.l	.sukka
.sukka
	dc.l	clearpaper	;vbl:n sisainen suorituslista
	dc.l	clearpaper2
	dc.l	writepala
	dc.l	writecont
	dc.l	writeviive
	rept	6
	dc.l	diffupala
	endr

	dc.l	clearpaper
	dc.l	clearpaper2
	dc.l	writepala
	dc.l	writecont
	dc.l	writeviive
	rept	6
	dc.l	diffupala
	endr	

	dc.l	0
;---------------------------------------------
writepala
	move.l	writetask,a1
	move.l	(a1),a1
	add.l	#4,writetask
	BSR	wbezieri
	addq.l	#4,writesukka
	rts


writetask
	dc.l	.wlist
.wlist	
	dc.l	wkuppa		;lista piirrettavista kamoista
	dc.l	wkuppa2

diffupala
	bsr	wasm_diffuse
	addq.l	#4,writesukka
	rts

writeviive
	sub.w	#1,.time
	bgt.s	.ok
	move.w	#200,.time
	addq.l	#4,writesukka
.ok
	rts
.time	dc.w	200
;------------------------------------
clearpaper
	move.l	wfalconscreen,a0
	moveq.l	#0,d1
	move.w	#(320*128/16)-1,d0
.wiper
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,.wiper
	addq.l	#4,writesukka
	rts

clearpaper2
	move.l	wfalconscreen,a0
	add.l	#320*128*2,a0
	moveq.l	#0,d1
	move.w	#(320*128/16)-1,d0
.wiper
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,.wiper
	addq.l	#4,writesukka
	rts
;*********************************************************************
;*                                                                   *
;* Performs drawing of a bezier-file found from a1 to a 320*240      *
;* screen, the address of which is stored in falconscreen-variable   *
;*                                                                   *
;*********************************************************************

wbezieri:
  LEA wbeztable,a2

  MOVE.w  (a1)+,d7
  SUBQ  #1,d7

wbez_main_loop:
  SWAP  d7
  MOVE.l  a2,a0
  MOVEQ #0,d5
  MOVEQ #0,d6
  MOVE.w 16(a1),d5
  MOVE.w 18(a1),d6
  SUB.w  d5,d6
  SWAP  d5            ;size
  MOVE.w  #0,d5
  SWAP  d6
  MOVE.w  #0,d6
  ASR.l #5,d6         ;sizechange

  MOVE.l  d5,wsizepos
  MOVE.l  d6,wsizechange

  MOVE.l 20(a1),d3
  MOVE.l 24(a1),d4

;blue
  MOVEQ   #0,d5
  MOVEQ   #0,d6
  MOVE.b  d3,d5
  MOVE.b  d4,d6
  SWAP  d5
  SWAP  d6
  MOVE.l  d5,wbluepos
  SUB.l   d5,d6
  ASR.l   #5,d6
  MOVE.l  d6,wbluechange

;green
  LSR.l   #8,d3
  LSR.l   #8,d4
  MOVEQ   #0,d5
  MOVEQ   #0,d6
  MOVE.b  d3,d5
  MOVE.b  d4,d6
  SWAP  d5
  SWAP  d6
  MOVE.l  d5,wgreenpos
  SUB.l   d5,d6
  ASR.l   #5,d6
  MOVE.l  d6,wgreenchange

;red
  LSR.l   #8,d3
  LSR.l   #8,d4
  MOVEQ   #0,d5
  MOVEQ   #0,d6
  MOVE.b  d3,d5
  MOVE.b  d4,d6
  SWAP  d5
  SWAP  d6
  MOVE.l  d5,wredpos
  SUB.l   d5,d6
  ASR.l   #5,d6
  MOVE.l  d6,wredchange

  MOVE.w  #(32/4)-1,d7

wbez_loop:
	rept	4
  MOVE.l  wsizepos,d5
  MOVE.l  wsizechange,d6
  MOVE.l  d5,d0
  MOVE.w  #0,d0
  SWAP    d0
  ADD.l   d6,d5
  MOVE.l  d5,wsizepos

  MOVE.w  #0,d5
  ASR.l   #1,d5
  NEG.l   d5
  MOVE.l  d5,d6

  MOVE.l  (a0)+,d1
  MOVEQ   #0,d2
  MOVEQ   #0,d3
  MOVE.w  12(a1),d2
  MOVE.w  14(a1),d3
  MULU.l  d1,d2
;  Dc.l  $4c012002
  MULU.l  d1,d3
;  Dc.l  $4c013003
  ADD.l  d2,d5
  ADD.l  d3,d6

  MOVE.l  124(a0),d1
  MOVEQ   #0,d2
  MOVEQ   #0,d3
  MOVE.w  8(a1),d2
  MOVE.w  10(a1),d3
  MULU.l  d1,d2
;  Dc.l  $4c012002
  MULU.l  d1,d3
;  Dc.l  $4c013003
  ADD.l  d2,d5
  ADD.l  d3,d6

  MOVE.l  252(a0),d1
  MOVEQ   #0,d2
  MOVEQ   #0,d3
  MOVE.w  4(a1),d2
  MOVE.w  6(a1),d3
  MULU.l  d1,d2
;  Dc.l  $4c012002
  MULU.l  d1,d3
;  Dc.l  $4c013003
  ADD.l  d2,d5
  ADD.l  d3,d6

  MOVE.l  380(a0),d1
  MOVEQ   #0,d2
  MOVEQ   #0,d3
  MOVE.w  0(a1),d2
  MOVE.w  2(a1),d3
  MULU.l  d1,d2
;  Dc.l  $4c012002
  MULU.l  d1,d3
;  Dc.l  $4c013003
  ADD.l  d2,d5
  ADD.l  d3,d6

;  xpos=Int(beztable(n)*bezi\x4+beztable(n+32)*bezi\x3+beztable(n+64)*bezi\x2+beztable(n+96)*bezi\x1)-size/2
;  ypos=Int(beztable(n)*bezi\y4+beztable(n+32)*bezi\y3+beztable(n+64)*bezi\y2+beztable(n+96)*bezi\y1)-size/2

  MOVEQ #0,d2
  MOVEQ #0,d3

  SWAP  d5
  SWAP  d6
  MOVE.w  d5,d2
  MOVE.w  d6,d3

  MOVE.l  wredpos,d5
  MOVE.l  wredchange,d6
  MOVE.l  d5,d1
  MOVE.w  #0,d1
  ADD.l   d6,d5
  MOVE.l  d5,wredpos

  MOVE.l  wgreenpos,d5
  MOVE.l  wgreenchange,d6
  MOVE.l  d5,d4
  MOVE.w  #0,d4
  LSR.l   #8,d4
  MOVE.w  d4,d1
  ADD.l   d6,d5
  MOVE.l  d5,wgreenpos

  MOVE.l  wbluepos,d5
  MOVE.l  wbluechange,d6
  MOVE.l  d5,d4
  SWAP    d4
  MOVE.b  d4,d1
  ADD.l   d6,d5
  MOVE.l  d5,wbluepos

;* d0 - size                                                    *
;* d1 - 24-bit colour                                           *
;* d2 - x                                                       *
;* d3 - y                                                       *

  BSR wreal_ball
	endr
	movem.l	d0-a6,writesecure	;regut talteen ja poikki...
	rts

writecont
	movem.l	writesecure,d0-a6

  DBRA  d7,wbez_loop
  LEA   28(a1),a1

  SWAP  d7

  DBRA  d7,wbez_main_loop

	addq.l	#4,writesukka		;valmista.. seuraava sukka..
  RTS

writesecure
	ds.l	15
;****************************************************************
;*                                                              *
;* Real ball draw, adds ball to screen.                         *
;* d0 - size                                                    *
;* d1 - 24-bit colour                                           *
;* d2 - x                                                       *
;* d3 - y                                                       *
;****************************************************************

wreal_ball:
  MOVE.l  a2,wsailo

  BSR wcreate_colour_data

  LEA wrawball,a3
;  LEA wflowtable,a4
	move.l	address.freemem,a4
	add.l	#wflowtable,a4
  MOVE.l  wfalconscreen,a5
  LEA wcolourtable,a2
  MULU  #320*2,d3
  LSL   #1,d2
  ADD.l d3,d2
  ADD.l d2,a5
  MOVE.l  a3,a6

  MOVE.l #$400000,d2  ;decimal skip
  DIVU.l  d0,d2
  ;Dc.l  $4c402002

  MOVEQ #0,d1
  MOVEQ #0,d3         ;xcount
  MOVEQ #0,d4         ;ycount
  MOVEQ #0,d5

  SUBQ  #1,d0
  MOVE.w d0,d6

wrd_yloop:
  SWAP  d6
  MOVE.w  d0,d6
wrd_xloop:
  MOVE.b 0(a6,d3.w),d5
  CMP.w #0,d5
  BEQ   wnodraw

  LSL.w #1,d5
  MOVE.w  0(a2,d5.w),d5

  MOVE.w  (a5),d1
  ADD.l d1,d5
  LSL.l #1,d5
  MOVE.w 0(a4,d5.l),(a5)
;	move.w	#$ffff,(a5)

  MOVEQ #0,d5

wnodraw:
  ADDQ  #2,a5

  SWAP  d3
  ADD.l d2,d3
  SWAP  d3

  DBRA  d6,wrd_xloop

  MOVEQ #0,d3

  SWAP  d4
  ADD.l d2,d4
  SWAP  d4

  MOVE.w d4,d5
  LSL.l  #6,d5
  MOVE.l  a3,a6
  ADD.l   d5,a6
  MOVEQ  #0,d5

  MOVE.w #319,d5
  SUB.w d0,d5
  LSL.w #1,d5
  ADD.l d5,a5

  MOVEQ #0,d5

  SWAP  d6
  DBRA  d6,wrd_yloop
  MOVE.l  wsailo,a2
  RTS

;****************************************************************
;*                                                              *
;* Creates 16-bit colour fade from 0 to 24-bit colour in d1.    *
;\*                                                              *
;****************************************************************

;don't change d0,d2,d3,d7,a0,a1,a2

wcreate_colour_data:
  MOVE.l  d1,a4

;blue
  LEA wcolourtable,a3

  MOVEQ #0,d4
  MOVEQ #0,d5
  MOVE.b  d1,d4
  LSL.w #5,d4

  MOVE.w #255,d6
wcolour_b_loop:
  SWAP  d5
  ADD.l d4,d5
  SWAP  d5
  MOVE.w  d5,(a3)+
  DBRA  d6,wcolour_b_loop

; green
  LEA wcolourtable,a3

  MOVEQ #0,d4
  MOVEQ #0,d5
  MOVE.l  a4,d4
  LSL.l #3,d4
  AND.l #$0007f800,d4

  MOVE.w #255,d6
wcolour_g_loop:
  ADD.l d4,d5
  MOVE.l  d5,d1
  SWAP  d1
  AND.w #$07c0,d1
  OR.w  d1,(a3)+
  DBRA  d6,wcolour_g_loop

; red
  LEA wcolourtable,a3

  MOVEQ #0,d4
  MOVEQ #0,d5
  MOVE.l  a4,d4
  AND.l #$00ff0000,d4

  MOVE.w #255,d6
wcolour_r_loop:
  ADD.l d4,d5
  MOVE.l  d5,d1
  SWAP  d1
  AND.w #$f000,d1
  OR.w  d1,(a3)+
  DBRA  d6,wcolour_r_loop

  RTS

;********************************************************************
;*                                                                  *
;* Expands incbin'ed data of one quarter of a ball to a whole ball. *
;*                                                                  *
;********************************************************************
wexpand_ball:
  LEA     wrawball,a0
  LEA     32*63(a0),a1
  LEA     32*32(a0),a0
  MOVE.l  a1,a2
  LEA     64(a1),a3
  MOVE.l  a3,a4
  MOVE.w  #31,d7
wexpand_y_loop:
  MOVE.w  #31,d6
wexpand_x_loop:
  MOVE.b  -(a0),d0
  MOVE.b  d0,-(a1)
  MOVE.b  d0,(a2)+
  MOVE.b  d0,-(a3)
  MOVE.b  d0,(a4)+
  DBRA    d6,wexpand_x_loop
  LEA     -32(a1),a1
  LEA     -96(a2),a2
  LEA     96(a3),a3
  LEA     32(a4),a4
  DBRA    d7,wexpand_y_loop
  RTS

;********************************************************************
;*                                                                  *
;* Creates look-up table used to avoid overflow of colours inside   *
;* true-colour word. Plotting routine does not use lowest bits of   *
;* red and green, but they are used to indicate that either green   *
;* or blue overflowed.                                              *
;*                                                                  *
;********************************************************************

wmakeflowtable:
 ; LEA     wflowtable,a0
	move.l	address.freemem,a0
	add.l	#wflowtable,a0 
  MOVE.l  a0,a1
  ADD.l   #$20000,a0
  ADD.l   #$40000,a1
  MOVEQ   #0,d0
  MOVEQ   #0,d1
  MOVEQ   #0,d2
  MOVEQ   #0,d3
  MOVEQ   #-1,d7
wmake_flow_loop:
  MOVE.w  d7,d0
  MOVE.w  d7,d1
  MOVE.w  d7,d2
  AND.w   #$20,d0
  CMP.w   #0,d0
  BEQ     wno_null_1
  AND.w   #$ffdf,d2
  OR.w    #$001f,d2
wno_null_1:
  AND.w   #$800,d1
  CMP.w   #0,d1
  BEQ     wno_null_2
  AND.w   #$f7ff,d2
  OR.w    #$07c0,d2
wno_null_2:
  MOVE.w  d2,-(a0)
  OR.w    #$f000,d2
  MOVE.w  d2,-(a1)
  DBRA d7,wmake_flow_loop
  RTS

;----------------------------------
; DIFFUUSI FADE VEKE
;----------------------------------
wasm_diffuse:
  MOVEQ   #0,d0
  MOVEQ   #0,d1
  MOVEQ   #0,d2
  MOVEQ   #0,d3
  MOVE.l	wfalconscreen,a0

  LEA     wxtable,a1
  LEA     wytable,a2
  LEA     wrndxtable,a3
  LEA     wrndytable,a4

  MOVE.w  #253-1,d7
wdiff_yloop:
  SWAP    d7
  MOVE.w  #320-1,d7
wdiff_xloop:
  MOVE.w  0(a1,d0.w),a5       ;x offset
  ADD.l   0(a2,d1.w),a5       ;y  offset
  ADD.l   a0,a5               ;current point

  MOVE.l  a5,a6
  MOVEQ   #0,d4
  move.w  0(a3,d2.w),d4       ;x rnd offset
  ADD.w   0(a4,d3.w),d4       ;y rnd offset
  EXT.l	  d4
  ADD.l   d4,a6               ;other point

  MOVE.w  (a5),d4             ;halve current colour
  LSR.w   #1,d4
  AND.w   #$7bef,d4
  MOVE.w  d4,(a5)

  MOVE.w  (a6),d5             ;add to other colour
  LSR.w   #1,d5
  AND.w   #$7bef,d5
  ADD.w   d4,d5
  MOVE.w  d5,(a6)

  ADDQ    #2,d0
  ADDQ    #4,d1
  ADDQ    #2,d2
  ADDQ    #2,d3

  CMP.w   #320*2,d0
  BNE     wno_xptr_loop
  MOVEQ   #0,d0
wno_xptr_loop
  CMP.w   #253*4,d1
  BNE     wno_yptr_loop
  MOVEQ   #0,d1
wno_yptr_loop
  CMP.w   #59*2,d2
  BNE     wno_xrndptr_loop
  MOVEQ   #0,d2
wno_xrndptr_loop
  CMP.w   #53*2,d3
  BNE     wno_yrndptr_loop
  MOVEQ   #0,d3
wno_yrndptr_loop

  DBRA    d7,wdiff_xloop
  SWAP    d7
  DBRA    d7,wdiff_yloop
  RTS

wxtable:
  IncBin "difxtabl.bin"
wytable:
  IncBin "difytabl.bin"
wrndxtable:
  IncBin "rndxtabl.bin"
wrndytable:
  IncBin "rndytabl.bin"
;----------------------------------
;----------------------------------
;***************************
;*                         *
;* bezier drawings here... *
;*                         *
;***************************
wkuppa
; PC1:keepinmo.s
	dc.w	89
	dc.w	231,111,224,116,221,123,223,129,10,4
	dc.l	$00181818,$00181818
	dc.w	222,129,215,138,217,148,212,158,10,4
	dc.l	$00181818,$00181818
	dc.w	208,159,203,149,193,157,180,144,12,4
	dc.l	$00181818,$00181818
	dc.w	180,144,168,130,171,154,165,163,8,4
	dc.l	$00181818,$00181818
	dc.w	166,171,174,155,176,151,180,154,4,7
	dc.l	$00181818,$00181818
	dc.w	181,154,198,165,206,171,216,174,4,12
	dc.l	$00181818,$00181818
	dc.w	217,174,225,162,234,152,242,128,10,4
	dc.l	$00181818,$00181818
	dc.w	240,136,249,152,256,154,262,168,4,4
	dc.l	$00181818,$00181818
	dc.w	265,169,265,191,280,191,285,216,10,4
	dc.l	$00181818,$00202020
	dc.w	286,219,285,239,293,229,304,219,4,8
	dc.l	$00181818,$00181818
	dc.w	308,212,293,216,294,219,290,209,4,4
	dc.l	$00181818,$00181818
	dc.w	289,207,285,189,280,182,278,169,4,8
	dc.l	$00181818,$00181818
	dc.w	275,163,268,149,260,134,250,117,4,10
	dc.l	$00181818,$00181818
	dc.w	251,118,249,106,257,91,257,76,4,9
	dc.l	$00181818,$00181818
	dc.w	256,86,261,97,272,112,274,99,4,10
	dc.l	$00181818,$00181818
	dc.w	274,91,283,93,287,74,274,78,4,4
	dc.l	$00181818,$00181818
	dc.w	275,80,268,76,273,87,267,95,4,4
	dc.l	$00181818,$00181818
	dc.w	266,86,263,78,260,61,252,63,4,9
	dc.l	$00181818,$00181818
	dc.w	252,66,248,62,249,60,250,55,4,4
	dc.l	$00181818,$00181818
	dc.w	244,52,256,59,258,58,258,53,4,4
	dc.l	$00181818,$00181818
	dc.w	258,47,257,23,232,27,237,45,4,12
	dc.l	$00181818,$00202020
	dc.w	238,49,238,57,238,60,235,60,4,4
	dc.l	$00181818,$00181818
	dc.w	238,62,226,59,224,66,218,73,10,4
	dc.l	$00181818,$00181818
	dc.w	218,75,213,78,208,85,204,92,8,4
	dc.l	$00181818,$00181818
	dc.w	207,94,210,101,220,102,229,107,4,4
	dc.l	$00181818,$00181818
	dc.w	230,109,232,114,239,116,246,109,4,4
	dc.l	$00181818,$00181818
	dc.w	245,108,244,96,236,108,228,101,4,10
	dc.l	$00181818,$00181818
	dc.w	232,103,227,99,222,95,217,88,4,9
	dc.l	$00181818,$00181818
	dc.w	218,93,221,86,227,81,231,76,4,9
	dc.l	$00181818,$00181818
	dc.w	227,83,230,90,232,96,233,104,4,6
	dc.l	$00181818,$00181818
	dc.w	226,60,152,23,137,13,137,45,8,12
	dc.l	$00181818,$00181818
	dc.w	232,59,185,23,177,12,170,38,8,10
	dc.l	$00101010,$00101010
	dc.w	141,48,191,57,173,52,223,63,4,6
	dc.l	$00181818,$00181818
	dc.w	230,111,238,117,247,115,250,114,4,6
	dc.l	$00181818,$00181818
	dc.w	224,118,232,119,240,121,248,123,12,6
	dc.l	$00221100,$00000000
	dc.w	222,129,227,131,235,134,238,134,9,4
	dc.l	$00181000,$00180800
	dc.w	217,138,222,142,230,145,233,145,9,4
	dc.l	$00181000,$00181000
	dc.w	215,149,221,152,227,153,228,154,9,4
	dc.l	$00181000,$00181000
	dc.w	212,157,215,159,220,162,223,162,9,4
	dc.l	$00181000,$00181000
	dc.w	239,137,245,135,252,132,254,128,9,4
	dc.l	$00100800,$00100800
	dc.w	244,145,249,143,257,139,259,136,9,4
	dc.l	$00100800,$00100800
	dc.w	251,154,256,152,263,146,264,144,9,4
	dc.l	$00100800,$00100800
	dc.w	259,162,263,160,268,156,270,154,9,4
	dc.l	$00100800,$00100800
	dc.w	264,170,268,169,274,168,275,165,9,4
	dc.l	$00100800,$00100800
	dc.w	39,56,54,60,40,80,32,112,12,5
	dc.l	$00302010,$00302010
	dc.w	45,55,53,58,46,79,34,111,2,5
	dc.l	$00304050,$00304050
	dc.w	67,70,63,76,56,90,40,90,12,5
	dc.l	$00181008,$00302010
	dc.w	42,90,61,93,59,99,61,113,12,5
	dc.l	$00181008,$00302010
	dc.w	71,71,67,77,60,91,44,91,5,2
	dc.l	$00304050,$00304050
	dc.w	40,91,59,94,57,100,56,112,2,4
	dc.l	$00304050,$00304050
	dc.w	40,59,38,57,42,53,46,55,4,4
	dc.l	$00181818,$00181818
	dc.w	64,74,64,67,68,68,69,68,4,4
	dc.l	$00181818,$00181818
	dc.w	69,91,117,95,100,71,86,70,5,12
	dc.l	$00302010,$00181008
	dc.w	87,71,61,74,61,129,95,105,12,5
	dc.l	$00302010,$00302010
	dc.w	72,93,120,97,103,73,89,72,5,2
	dc.l	$00304050,$00000010
	dc.w	90,73,64,76,64,131,98,107,2,8
	dc.l	$00000000,$00203040
	dc.w	72,79,75,75,79,72,84,70,4,4
	dc.l	$00181818,$00181818
	dc.w	106,92,154,96,137,72,123,71,5,12
	dc.l	$00302010,$00181008
	dc.w	124,72,98,75,98,130,132,106,12,5
	dc.l	$00302010,$00302010
	dc.w	109,94,157,98,140,74,126,73,5,2
	dc.l	$00304050,$00000010
	dc.w	127,74,101,77,101,132,135,108,2,8
	dc.l	$00000000,$00203040
	dc.w	109,80,112,76,116,73,121,71,4,4
	dc.l	$00181818,$00181818
	dc.w	143,102,168,139,191,48,145,77,5,12
	dc.l	$00302010,$00302010
	dc.w	146,71,144,91,138,116,131,132,12,5
	dc.l	$00302010,$00302010
	dc.w	141,105,170,142,195,50,148,80,7,5
	dc.l	$00203040,$00001020
	dc.w	149,73,147,93,145,117,132,132,2,5
	dc.l	$00102030,$00102030
	dc.w	144,76,143,75,146,68,149,70,4,4
	dc.l	$00181818,$00181818
	dc.w	59,152,64,161,58,183,54,194,12,6
	dc.l	$00181008,$00302010
	dc.w	62,143,75,136,51,136,61,141,12,5
	dc.l	$00181008,$00302010
	dc.w	64,154,72,160,61,181,54,197,2,12
	dc.l	$00001020,$00081018
	dc.w	65,145,78,137,53,136,65,145,4,7
	dc.l	$00001020,$00001020
	dc.w	59,157,57,149,60,145,64,153,4,4
	dc.l	$00181818,$00181818
	dc.w	58,141,58,136,62,136,62,136,4,4
	dc.l	$00101010,$00101010
	dc.w	77,150,83,159,79,180,75,194,12,5
	dc.l	$00181008,$00302010
	dc.w	106,158,110,168,109,178,103,194,12,7
	dc.l	$00181008,$00181008
	dc.w	83,161,88,152,99,150,104,155,6,12
	dc.l	$00181008,$00181008
	dc.w	84,165,89,156,100,154,106,158,10,2
	dc.l	$00081018,$00081018
	dc.w	83,151,87,160,83,181,76,197,2,9
	dc.l	$00102030,$00081018
	dc.w	107,154,113,158,117,167,103,199,2,7
	dc.l	$00102030,$00102030
	dc.w	78,155,76,149,79,146,83,151,4,4
	dc.l	$00181818,$00181818
	dc.w	129,196,142,189,118,189,128,194,12,5
	dc.l	$00181008,$00302010
	dc.w	132,198,145,190,120,189,132,198,4,7
	dc.l	$00001020,$00001020
	dc.w	125,194,125,189,129,189,129,189,4,4
	dc.l	$00101010,$00101010
	dc.w	147,195,160,188,136,188,146,193,12,5
	dc.l	$00181008,$00302010
	dc.w	150,197,163,189,138,188,150,197,4,7
	dc.l	$00001020,$00001020
	dc.w	143,193,143,188,147,188,147,188,4,4
	dc.l	$00101010,$00101010
	dc.w	165,195,178,188,154,188,164,193,12,5
	dc.l	$00181008,$00302010
	dc.w	168,197,181,189,156,188,168,197,4,7
	dc.l	$00001020,$00001020
	dc.w	161,193,161,188,165,188,165,188,4,4
	dc.l	$00101010,$00101010


wkuppa2	dc.w	54
	dc.w	17,78,22,94,17,120,15,140,15,7
	dc.l	$00081018,$00102030
	dc.w	19,86,42,58,41,110,33,143,15,7
	dc.l	$00081018,$00102030
	dc.w	38,85,61,57,60,109,52,142,15,7
	dc.l	$00081018,$00102030
	dc.w	23,83,28,99,23,125,20,144,15,7
	dc.l	$00181008,$00302010
	dc.w	25,89,48,61,47,113,39,145,15,7
	dc.l	$00181008,$00302010
	dc.w	45,88,68,60,67,112,59,144,15,7
	dc.l	$00181008,$00302010
	dc.w	17,81,19,89,19,97,18,107,2,6
	dc.l	$00303030,$00303030
	dc.w	18,113,17,125,15,132,15,140,6,2
	dc.l	$00303030,$00303030
	dc.w	37,84,39,92,39,100,38,110,2,6
	dc.l	$00303030,$00303030
	dc.w	38,114,37,126,35,133,34,141,6,2
	dc.l	$00303030,$00303030
	dc.w	55,85,57,93,57,101,56,111,2,6
	dc.l	$00303030,$00303030
	dc.w	56,113,55,125,53,132,52,140,6,2
	dc.l	$00303030,$00303030
	dc.w	115,85,98,55,84,109,87,127,7,15
	dc.l	$00102030,$00081018
	dc.w	87,127,99,158,124,111,110,90,15,7
	dc.l	$00081018,$00102030
	dc.w	118,90,104,60,89,112,95,131,7,15
	dc.l	$00302010,$00181008
	dc.w	95,129,107,163,129,115,116,94,15,7
	dc.l	$00181008,$00302010
	dc.w	97,81,91,90,89,97,87,106,2,6
	dc.l	$00303030,$00303030
	dc.w	87,104,85,114,85,125,95,138,6,2
	dc.l	$00303030,$00303030
	dc.w	101,136,107,132,109,125,111,118,2,6
	dc.l	$00303030,$00303030
	dc.w	112,118,112,111,112,104,110,91,6,2
	dc.l	$00303030,$00303030
	dc.w	146,55,147,105,130,114,152,136,7,15
	dc.l	$00102030,$00081018
	dc.w	130,75,142,73,148,78,158,77,7,15
	dc.l	$0002040C,$00081018
	dc.w	152,68,151,114,139,118,160,140,7,15
	dc.l	$00302010,$00181008
	dc.w	134,80,142,79,150,85,161,82,7,15
	dc.l	$000C0402,$00181008
	dc.w	147,60,145,71,145,83,140,102,2,6
	dc.l	$00303030,$00303030
	dc.w	141,103,143,116,139,118,149,132,6,2
	dc.l	$00303030,$00303030
	dc.w	199,65,194,63,192,68,194,75,2,15
	dc.l	$00000000,$00081018
	dc.w	190,82,192,112,182,117,192,136,7,15
	dc.l	$00102030,$00081018
	dc.w	203,69,197,67,195,73,197,79,2,15
	dc.l	$00000000,$00181008
	dc.w	194,87,195,116,186,121,198,139,7,15
	dc.l	$00302010,$00181008
	dc.w	190,63,189,67,190,69,189,72,10,2
	dc.l	$00000000,$00303030
	dc.w	190,85,189,94,190,100,189,109,2,6
	dc.l	$00303030,$00303030
	dc.w	188,108,187,122,187,129,194,138,6,2
	dc.l	$00303030,$00303030
	dc.w	251,83,234,53,220,107,223,125,7,15
	dc.l	$00102030,$00081018
	dc.w	223,125,235,156,260,109,246,88,15,7
	dc.l	$00081018,$00102030
	dc.w	254,88,240,58,225,110,231,129,7,15
	dc.l	$00302010,$00181008
	dc.w	232,128,244,162,266,114,253,93,15,7
	dc.l	$00181008,$00302010
	dc.w	233,79,227,88,225,95,223,104,2,6
	dc.l	$00303030,$00303030
	dc.w	223,102,221,112,221,123,232,136,6,2
	dc.l	$00303030,$00303030
	dc.w	237,134,243,130,245,123,247,116,2,6
	dc.l	$00303030,$00303030
	dc.w	248,116,251,107,249,97,246,91,6,2
	dc.l	$00303030,$00303030
	dc.w	280,74,286,90,280,116,278,137,15,7
	dc.l	$00081018,$00102030
	dc.w	281,82,309,56,307,106,298,137,15,7
	dc.l	$00081018,$00102030
	dc.w	286,79,292,93,286,117,284,141,15,7
	dc.l	$00181008,$00302010
	dc.w	287,85,315,59,313,108,304,139,15,7
	dc.l	$00181008,$00302010
	dc.w	280,80,282,89,282,96,281,106,2,6
	dc.l	$00303030,$00303030
	dc.w	281,105,280,117,278,124,278,136,6,2
	dc.l	$00303030,$00303030
	dc.w	303,84,305,92,305,100,304,110,2,6
	dc.l	$00303030,$00303030
	dc.w	304,108,303,121,300,127,299,136,6,2
	dc.l	$00303030,$00303030
	dc.w	292,74,291,79,292,80,292,83,10,2
	dc.l	$00000000,$00303030
	dc.w	11,179,45,169,85,167,120,168,5,30
	dc.l	$00203010,$00302820
	dc.w	119,168,151,168,212,182,296,179,30,10
	dc.l	$00302820,$00302020
	dc.w	22,190,56,180,96,178,131,179,5,30
	dc.l	$00101808,$00181410
	dc.w	130,179,162,179,223,193,307,190,30,10
	dc.l	$00181410,$00181010

	even
;***********************
;*                     *
;* Space for variables *
;*                     *
;***********************

wfalconscreen:
  Dc.l  0
wsizepos:
  Dc.l  0
wsizechange:
  Dc.l  0
wredpos:
  Dc.l  0
wredchange:
  Dc.l  0
wgreenpos:
  Dc.l  0
wgreenchange:
  Dc.l  0
wbluepos:
  Dc.l  0
wbluechange:
  Dc.l  0
wsailo:
  Dc.l  0

;----------------------------------------

wbeztable:
  IncBin	beztable.bin

wrawball:
  IncBin	ball2.bin
  Ds.b  3*32*32

wcolourtable:
  Ds.w  256
;wflowtable:
;		ds.b  $40000

	RSRESET			;susieen ruutu 524 416 bytes..
wflowtable	rs.w	$40000/2
wqqa		RS.b 3600
wruutu.write:	RS.w	320*256+256
wqqae		RS.b 3600

