;      /| __    _    /  __      
;     / |/ _ __| \  <  <    _   
;    /__|\ // _| / / \  \ |/ \  |
;   <   | \ \ /|< <_  >  >|\_/|\|
;    \  |    \ | \ \ / _/ |   | | 
;     \        |    /
;
; tekstiwriteri+diffusio
; 262k taulun wflowtable sorsan jalkeen.. luodaan initissa vain kerran..  

write.run	=	1

	IFNE	write.run
	OPT	d+,c-,p=68030

memory	=	1500*1024

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
	DC.L	initwrite
	DC.L	runwrite
	DC.L	runwrite
;	dc.l	dummy
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

	bsr	clearpaper

	move.l	#writetv,pointertv
	jsr	middlesetscreen
	move.w	#$2300,sr
	
	move.l	#writevbl,own_vbl
	rts
initwrite:
	BSR     wexpand_ball
	BSR     wmakeflowtable

	addq.w	#1,activepoint

	rts
;----------------------------------------------------
writevbl:
	move.l	#$0,$ffff9800.w
	rts

;---------------------------------------------
runwrite
	bsr	initwscreen
	move.l	writetask,a1
	move.l	(a1),a1
	add.l	#4,writetask
	BSR	wbezieri
	rept	6
	bsr	wasm_diffuse
	endr
	addq.w	#1,activepoint
	rts


writetask
	dc.l	.wlist
.wlist	
	dc.l	waggro
	dc.l	waggro_ampi
	dc.l	wtest_bez
;---------------
dummy
	rts

;------------------------------------
clearpaper
	move.l	wfalconscreen,a0
	move.l	#$00000000,d1
	move.w	#(320*256/16)-1,d0
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

  MOVE.w  #31,d7

wbez_loop:
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

  DBRA  d7,wbez_loop
  LEA   28(a1),a1

  SWAP  d7

  DBRA  d7,wbez_main_loop

  RTS

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
  LEA wflowtable,a4
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
  LEA     wflowtable,a0
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

waggro_ampi:
  Dc.w  125
  Dc.w  99,106,89,111,83,115,80,126,4,8
  Dc.l  $00101010,$00281A10
  Dc.w  80,126,80,138,88,144,97,142,8,4
  Dc.l  $00281A10,$00101010
  Dc.w  115,98,99,104,93,112,90,125,4,8
  Dc.l  $00101010,$00302010
  Dc.w  89,125,89,139,98,147,108,144,8,4
  Dc.l  $00302010,$00101010
  Dc.w  131,94,112,98,103,108,100,122,4,8
  Dc.l  $00101010,$00402810
  Dc.w  99,122,99,139,109,148,122,146,8,4
  Dc.l  $00402810,$00101010
  Dc.w  152,91,130,89,120,106,117,122,4,8
  Dc.l  $00101010,$00302010
  Dc.w  116,122,116,138,127,148,139,146,8,4
  Dc.l  $00302010,$00101010
  Dc.w  193,95,182,88,172,89,162,94,4,8
  Dc.l  $00101010,$00202028
  Dc.w  162,93,154,98,149,105,150,115,8,4
  Dc.l  $00202028,$00101010
  Dc.w  186,135,199,129,188,137,198,126,4,4
  Dc.l  $00181010,$00181010
  Dc.w  164,114,148,118,135,121,128,124,4,8
  Dc.l  $00101010,$00202028
  Dc.w  127,128,127,133,131,145,135,157,8,4
  Dc.l  $00202028,$00101010
  Dc.w  131,158,105,159,127,157,99,153,4,4
  Dc.l  $00202028,$00202028
  Dc.w  170,114,161,117,155,118,153,119,4,8
  Dc.l  $00101010,$00202028
  Dc.w  151,122,152,126,157,140,160,153,8,4
  Dc.l  $00202028,$00101010
  Dc.w  159,158,148,170,157,161,143,167,4,4
  Dc.l  $00202028,$00202028
  Dc.w  174,114,177,116,178,117,179,117,4,8
  Dc.l  $00101010,$00202028
  Dc.w  179,121,180,126,180,141,182,154,8,4
  Dc.l  $00202028,$00101010
  Dc.w  182,156,186,163,187,158,189,169,4,4
  Dc.l  $00202028,$00202028
  Dc.w  202,100,201,94,206,87,216,91,4,8
  Dc.l  $00101010,$00202424
  Dc.w  215,91,221,93,227,96,235,106,8,4
  Dc.l  $00202424,$00101010
  Dc.w  222,91,227,93,234,96,242,106,8,4
  Dc.l  $00202424,$00101010
  Dc.w  214,106,206,101,206,102,206,102,4,4
  Dc.l  $00181010,$00181010
  Dc.w  212,119,204,126,223,125,258,130,6,6
  Dc.l  $00282020,$00101010
  Dc.w  256,127,249,116,249,116,240,109,4,8
  Dc.l  $00101010,$00202028
  Dc.w  176,95,146,79,134,73,99,56,4,12
  Dc.l  $00202028,$00202028
  Dc.w  99,56,55,32,27,18,55,59,12,4
  Dc.l  $00202028,$00202028
  Dc.w  174,98,106,71,97,67,63,57,4,25
  Dc.l  $00202028,$00101010
  Dc.w  180,90,161,73,153,67,131,51,4,12
  Dc.l  $00202028,$00202028
  Dc.w  131,51,104,27,86,12,103,54,12,4
  Dc.l  $00202028,$00202028
  Dc.w  173,88,135,66,130,62,109,51,4,25
  Dc.l  $00202028,$00101010
  Dc.w  26,195,0,229,14,162,30,162,5,12
  Dc.l  $00102030,$00081018
  Dc.w  31,162,38,162,28,187,30,204,12,5
  Dc.l  $00081018,$00102030
  Dc.w  28,200,2,234,16,166,32,167,5,12
  Dc.l  $00302010,$00181008
  Dc.w  33,167,40,167,30,192,33,209,12,5
  Dc.l  $00181008,$00302010
  Dc.w  12,197,12,188,14,182,17,175,2,5
  Dc.l  $00303030,$00303030
  Dc.w  17,175,21,168,25,165,29,162,5,2
  Dc.l  $00303030,$00303030
  Dc.w  33,170,32,176,30,183,30,189,2,5
  Dc.l  $00303030,$00303030
  Dc.w  30,189,30,194,30,199,30,205,5,2
  Dc.l  $00303030,$00303030
  Dc.w  16,203,16,206,16,207,16,209,8,2
  Dc.l  $00000000,$00303030
  Dc.w  28,161,27,164,28,165,28,167,8,2
  Dc.l  $00000000,$00303030
  Dc.w  56,195,30,229,44,162,60,162,5,12
  Dc.l  $00102030,$00081018
  Dc.w  61,162,68,162,57,187,60,204,12,5
  Dc.l  $00081018,$00102030
  Dc.w  60,204,63,228,64,234,41,221,5,12
  Dc.l  $00102030,$00081018
  Dc.w  57,199,32,234,46,166,61,167,5,12
  Dc.l  $00302010,$00181008
  Dc.w  63,167,70,167,59,192,62,209,12,5
  Dc.l  $00181008,$00302010
  Dc.w  62,209,65,233,66,239,44,225,5,12
  Dc.l  $00181008,$00302010
  Dc.w  42,197,42,188,44,182,47,175,2,5
  Dc.l  $00303030,$00303030
  Dc.w  47,175,50,168,54,165,58,162,5,2
  Dc.l  $00303030,$00303030
  Dc.w  62,170,61,176,60,183,60,189,2,5
  Dc.l  $00303030,$00303030
  Dc.w  60,189,59,194,59,199,59,205,5,2
  Dc.l  $00303030,$00303030
  Dc.w  61,216,63,225,61,231,54,227,2,5
  Dc.l  $00303030,$00303030
  Dc.w  54,227,49,225,44,223,40,220,5,2
  Dc.l  $00303030,$00303030
  Dc.w  46,203,45,206,46,207,46,209,8,2
  Dc.l  $00000000,$00303030
  Dc.w  57,161,56,164,57,165,57,167,8,2
  Dc.l  $00000000,$00303030
  Dc.w  47,227,46,230,47,231,47,233,8,2
  Dc.l  $00000000,$00303030
  Dc.w  87,196,61,230,75,162,91,162,5,12
  Dc.l  $00102030,$00081018
  Dc.w  92,162,99,163,88,188,91,204,12,5
  Dc.l  $00081018,$00102030
  Dc.w  91,204,94,229,95,235,72,222,5,12
  Dc.l  $00102030,$00081018
  Dc.w  88,200,63,234,77,167,92,167,5,12
  Dc.l  $00302010,$00181008
  Dc.w  94,167,101,168,90,193,93,209,12,5
  Dc.l  $00181008,$00302010
  Dc.w  93,209,96,234,97,240,75,226,5,12
  Dc.l  $00181008,$00302010
  Dc.w  73,197,73,189,75,183,78,176,2,5
  Dc.l  $00303030,$00303030
  Dc.w  78,176,81,169,85,165,89,162,5,2
  Dc.l  $00303030,$00303030
  Dc.w  93,171,92,177,91,184,91,190,2,5
  Dc.l  $00303030,$00303030
  Dc.w  91,190,90,195,90,200,90,206,5,2
  Dc.l  $00303030,$00303030
  Dc.w  92,217,94,226,92,232,85,228,2,5
  Dc.l  $00303030,$00303030
  Dc.w  85,228,80,226,75,223,71,221,5,2
  Dc.l  $00303030,$00303030
  Dc.w  77,204,76,206,77,208,77,209,8,2
  Dc.l  $00000000,$00303030
  Dc.w  88,162,87,165,88,166,88,168,8,2
  Dc.l  $00000000,$00303030
  Dc.w  78,227,77,230,78,232,78,234,8,2
  Dc.l  $00000000,$00303030
  Dc.w  106,162,117,172,107,197,108,206,12,5
  Dc.l  $00081018,$00102030
  Dc.w  109,200,111,185,114,145,130,172,5,12
  Dc.l  $00000000,$00102030
  Dc.w  111,164,122,174,112,199,113,209,12,5
  Dc.l  $00181008,$00302010
  Dc.w  114,206,116,187,119,148,135,174,5,12
  Dc.l  $00000000,$00302010
  Dc.w  109,164,112,174,111,179,109,186,2,5
  Dc.l  $00303030,$00303030
  Dc.w  110,186,109,192,109,198,107,205,5,2
  Dc.l  $00303030,$00303030
  Dc.w  107,162,106,165,107,167,107,168,8,2
  Dc.l  $00000000,$00303030
  Dc.w  159,192,130,225,134,190,138,177,5,12
  Dc.l  $00102030,$00081018
  Dc.w  138,178,144,148,180,163,150,183,12,5
  Dc.l  $00081018,$00102030
  Dc.w  164,194,135,226,139,193,143,179,5,12
  Dc.l  $00302010,$00181008
  Dc.w  142,180,149,151,185,166,151,189,12,5
  Dc.l  $00181008,$00302010
  Dc.w  150,162,142,164,140,169,136,179,2,5
  Dc.l  $00303030,$00303030
  Dc.w  136,179,135,191,133,199,140,206,5,2
  Dc.l  $00303030,$00303030
  Dc.w  150,181,149,184,151,188,151,189,8,2
  Dc.l  $00000000,$00303030
  Dc.w  156,193,155,196,155,199,155,199,8,2
  Dc.l  $00000000,$00303030
  Dc.w  185,168,179,153,164,165,178,183,5,12
  Dc.l  $00102030,$00081018
  Dc.w  177,183,190,205,170,213,161,202,12,5
  Dc.l  $00081018,$00102030
  Dc.w  191,169,184,155,170,167,183,185,5,12
  Dc.l  $00302010,$00181008
  Dc.w  182,185,196,206,176,214,167,203,12,5
  Dc.l  $00181008,$00302010
  Dc.w  172,167,171,174,175,181,180,190,2,5
  Dc.l  $00303030,$00303030
  Dc.w  179,191,184,206,174,210,163,204,5,2
  Dc.l  $00303030,$00303030
  Dc.w  171,162,170,165,171,167,171,169,8,2
  Dc.l  $00000000,$00303030
  Dc.w  215,168,209,153,194,165,208,183,5,12
  Dc.l  $00102030,$00081018
  Dc.w  207,183,220,205,200,213,191,202,12,5
  Dc.l  $00081018,$00102030
  Dc.w  221,169,214,155,200,167,213,185,5,12
  Dc.l  $00302010,$00181008
  Dc.w  212,185,226,206,206,214,197,203,12,5
  Dc.l  $00181008,$00302010
  Dc.w  202,167,201,174,205,181,210,190,2,5
  Dc.l  $00303030,$00303030
  Dc.w  209,191,214,206,204,210,193,204,5,2
  Dc.l  $00303030,$00303030
  Dc.w  201,162,200,165,201,167,201,169,8,2
  Dc.l  $00000000,$00303030
  Dc.w  231,170,233,190,225,195,234,207,5,12
  Dc.l  $00102030,$00081018
  Dc.w  238,158,233,156,232,160,234,165,2,12
  Dc.l  $00000000,$00081018
  Dc.w  234,173,236,193,228,197,237,210,5,12
  Dc.l  $00302010,$00181008
  Dc.w  241,160,236,159,235,163,237,167,2,12
  Dc.l  $00000000,$00181008
  Dc.w  231,172,230,179,231,183,231,189,2,5
  Dc.l  $00303030,$00303030
  Dc.w  230,188,229,198,230,203,236,209,5,2
  Dc.l  $00303030,$00303030
  Dc.w  230,157,229,160,230,161,230,163,8,2
  Dc.l  $00000000,$00303030
  Dc.w  268,168,255,147,244,185,247,197,5,12
  Dc.l  $00102030,$00081018
  Dc.w  247,197,256,219,275,186,264,172,12,5
  Dc.l  $00081018,$00102030
  Dc.w  271,172,260,151,248,187,252,200,5,12
  Dc.l  $00302010,$00181008
  Dc.w  252,199,261,223,279,189,269,174,12,5
  Dc.l  $00181008,$00302010
  Dc.w  254,165,250,172,248,176,247,183,2,5
  Dc.l  $00303030,$00303030
  Dc.w  247,181,245,188,245,196,253,205,5,2
  Dc.l  $00303030,$00303030
  Dc.w  257,204,261,201,263,196,265,191,2,5
  Dc.l  $00303030,$00303030
  Dc.w  266,191,266,186,266,181,264,174,5,2
  Dc.l  $00303030,$00303030
  Dc.w  283,162,288,173,283,191,281,207,12,5
  Dc.l  $00081018,$00102030
  Dc.w  284,167,307,148,306,184,298,207,12,5
  Dc.l  $00081018,$00102030
  Dc.w  288,164,293,175,288,193,286,209,12,5
  Dc.l  $00181008,$00302010
  Dc.w  289,169,312,150,311,186,303,209,12,5
  Dc.l  $00181008,$00302010
  Dc.w  283,166,285,172,285,177,284,184,2,5
  Dc.l  $00303030,$00303030
  Dc.w  284,183,283,192,281,197,281,205,5,2
  Dc.l  $00303030,$00303030
  Dc.w  302,169,304,174,304,180,303,187,2,5
  Dc.l  $00303030,$00303030
  Dc.w  303,186,302,195,300,199,299,205,5,2
  Dc.l  $00303030,$00303030
  Dc.w  293,162,292,165,293,166,293,168,8,2
  Dc.l  $00000000,$00303030

waggro:
  Dc.w  20
  Dc.w  15,149,5,9,92,4,46,154
  Dc.w  4*6,4*4
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  10,101,37,85,42,84,70,67
  Dc.w  4*4,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  82,107,36,124,78,41,88,81
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  93,69,81,117,68,185,51,124
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  113,104,71,126,102,39,118,81
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  121,67,113,117,101,179,87,113
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  172,64,138,27,123,64,116,143
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  133,95,142,91,171,88,172,88
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  172,88,137,16,111,137,168,100
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  211,40,185,42,175,76,181,88
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  181,88,196,102,188,148,142,130
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  250,51,225,26,193,75,202,87
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  202,87,220,101,207,185,136,155
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  230,69,231,69,218,140,221,119
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  252,67,235,69,233,104,251,101
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  252,101,263,99,273,64,252,67
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  277,65,275,78,273,84,262,140
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  276,70,297,62,308,67,293,139
  Dc.w  4*2,4*2
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  240,57,235,42,211,69,236,62
  Dc.w  4*1,4*1
  Dc.l  $ff7f3f,$7f3fff

  Dc.w  40,200,100,150,200,170,300,180
  Dc.w  4*10,4*4
  Dc.l  $ff7f3f,$7f3fff

wtest_bez:
  Dc.w  1
  Dc.w  30,30,30,240,290,240,290,30
  Dc.w  60,60
  Dc.l  $3f3f3f,$3f3f3f

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
wflowtable:
		ds.b  $40000

	RSRESET
wqqa		RS.b 3600
wruutu.write:	RS.w	320*256+256
wqqae		RS.b 3600

