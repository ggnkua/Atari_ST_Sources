	.include hardware
	.include defs
	.include macros
	.include nvram

	.extern video, vVGAm3, VGAPoint, maxx,maxy,bytperline, wrdmde, logplanes
	.extern init2key

	.text
* video.s  
*       Display submenu for video tests

* SPARROW TEST -------------------------------------------------
* V1.00 : 21JAN92 : RWS : Started from system.s
* V1.10 : 22JAN92 : RWS : added color & hires
* V2.00 : 01APR92 : RWS : added multiple monitor tests
* V2.01 : 02APR92 : RWS : made vNORMAL work (for color & VGA anyway)
* V2.02 : 06APR92 : RWS : Made all of vMonitors tests work. Working on vModes
* V2.03 : 07APR92 : RWS : made vModes all work, if rev 2+ combel (remove for production)
* V2.04 : 08APR92 : RWS : added vFAKE for running the test on a VGA monitor
* V2.05 : 18MAY92 : RWS : removed individual tests from menu, cleaned up mono exit
* V2.06 : 10AUG92 : RWS : Made color shades instead of bars
* --------------------------------------------------------------
.macro DELAY dval
	move.w	\dval,d7
.\~:
	nop
	dbra	d7,.\~
.endm
.macro WAITFORMONO
.\~:
	DELAY	#$ff
	move.b	SPConfig,d0
	andi.b	#$c0,d0
	cmp.b	#$00,d0
	bne	.\~
.endm

*********************************************************
*       Display title
*********************************************************
*       This is the return point for finished command
video:
s2menu:	bsr     clearsc
*	move.w  #bgrnd,palette

*------------------------------------------------
*       Print menu and wait for selection       

	bsr	init2key	;; RWS.TPE

	tst.b	ProdTestStat
	bpl	VideoProduction

        movea.l #s2menumsg,a5     ;display tests
        bsr     dspinv
        btst    #kfail,consol   ;keyboard ok?
        bne.s   s2getkey

        moveq   #$1a,d1         ;disable joysticks
        bsr     ikbdput

*--- Input selections
s2getkey: 
*-------------------------------
* Get immediate keystrokes

	bsr     uconin           ;get some upcase input

*       Check immediate type keys: help, ?, esc, ... 
        cmpi.b  #esc,d0
        bne     s2scanch
	popretaddr		; back to the old menu
	bra	menu

s2scanch:   
        cmpi.b  #$62,d1         ;help key scan code?
        beq     s2mhelp
        cmpi.b  #'?',d0
        beq     s2mhelp
        cmpi.b  #'C',d0         ;C - Color
        beq     vColor
	cmpi.b	#'M',d0
	beq	vMonitors
	cmpi.b	#'V',d0
	beq	vModes		; test vga video modes
	cmpi.b	#'1',d0
	beq	vXGAtst
	cmpi.b	#'2',d0
*	beq	vTVtst
	beq	vXGAtst		; same as color monitor test
	cmpi.b	#'3',d0		;old H - Hires test
	beq	vMONOtst        
	cmpi.b	#'4',d0
	beq	vVGAtst
s2gb_ret:
	bra	s2menu                     

*-------------------------------
VideoProduction:
	btst	#FAKECOLOR,v_stat_R	;are we in VGA?
	beq	vMonitors		; No. Do reg. test
; yes - error
	move.w	#red,palette
	bra	menu

********************************
vXGAtst:
	bsr	vXGA
	bsr	uconin
	bra	Videoexit
vVGAtst:
	bsr	vVGA
	bsr	uconin
	bra	Videoexit
vMONOtst:
	bsr	vMONO
	bsr     clearsc
        bsr     hires
	bsr	uconin
	bra	Videoexit
vTVtst:
	bsr	vTV
	bsr	uconin
*----------------------------
* return point for most tests
Videoexit:
	bsr	vNORMAL
	bsr	init2key
;	bclr.b	#0,SPControl	; turn off 16MHz
	tst	ProdTestStat
	bpl	menu
	bra	s2gb_ret

********************************* 22JAN92 : RWS
vColor:
        bsr     clearsc
        bsr     colortst
	bra	s2gb_ret

********************************* 22JAN92 : RWS
* vHires removed (now vMONO)

********************************* 23MAR92 : RWS
*test most modes in VGA graphics
vModes:		
	bsr	vVGA
	bsr	crlf
	lea.l	pBKeyMsg,a5
	bsr	dspmsg
	bsr	crlf
	lea.l	pSpaceMsg,a5
	bsr	dspmsg
	bsr	uconin
	cmp.b	#'B',d0
	beq	.skip
	bsr	vVGAm2
	bsr	crlf
	bsr	crlf
	lea.l	pSpaceMsg,a5
	bsr	dspmsg
	bsr	uconin
.skip:
	lea.l	TestSTeVGAMsg,a5
	bsr	dspmsg
	bsr	vVGAm3		; visible screen by here...
	bsr	DoVGAm3Stuff	; show palettes change..
	bra	Videoexit

*********************************
vMonitors:
	RTCCLEARPASS	#t_VIDEO
;	RTCSETPASS	#t_VIDEO	; BAD IDEA!

 	lea.l	vMonitorsMsg,a5
	bsr	dspmsg
	bsr	uconin
	bsr	vAUTONORM 
	bsr	vXGA

*	bsr	uconin	
*	bsr	vAUTONORM 	; test w/xga pic.
*	bsr	vTV		; instead of test
*	bsr	uconin 

;	bsr	uconin
;	WAITFORMONO
	bsr	init2key
	bsr	uconin 
	bsr	vAUTONORM 

	bsr	vMONO
	bsr     clearsc
        bsr     hires

	bsr	init2key
	bsr	uconin 
	bsr	vAUTONORM 
	bsr	vVGA
;	bsr	uconin
	tst.b	ProdTestStat	; if in production test, do all VGA & set pass bits
	bmi	.skip
	lea.l	pSpaceMsg,a5
	bsr	dspmsg
; UNCOMMENT WHEN REV 2 COMBEL IS HERE
	bsr	init2key
	bsr	uconin		;	"
	bsr	vVGAm2		;	"
	bsr	crlf
	lea.l	pSpaceMsg,a5
	bsr	dspmsg
	bsr	init2key
	bsr	uconin
	lea.l	TestSTeVGAMsg,a5
	bsr	dspmsg
	bsr	vVGAm3		; visible screen by here...
	bsr	DoVGAm3Stuff	; show palettes change..
;	bsr	vAUTONORM
;	bsr	vGENLOCK
	RTCSETPASS #t_VIDEO
.skip:
	bsr	init2key
	bsr	uconin
	bra	Videoexit

*---------------------------------------------------------
******* VIDEO SUBROUTINES *******
*---------------------------------------------------------
vXGA:
	move.b	SPConfig,d0
	andi.b	#$c0,d0
	cmp.b	#$40,d0
	beq	.contd
	lea.l	PluginCOLORmsg,a5
	bsr	dspmsg
	bsr	init2key
	bsr	uconin
	cmp.b	#esc,d0
	beq	Videoexit
	bra	vXGA
.contd:
*--------------------------------
* Sparrow Mode, XGA 640x200, Color Monitor
* (SP example 12)
	move.w	palette,colsav
.settime:	
	movea.l	#spex12,a0		; - SET TIMING
	movea.l	#spex1v,a1
	bsr	stuffSPregs
.setvid:
	move.b	#spscrh,v_bas_h	; - SET VIDEO BASE ADDR
	move.b	#spscrm,v_bas_m
	move.b	#spscrl,v_bas_l
.setxga:
	move.w	#$100,v_spshiftmd	; - TURN ON XGA
	move.w	#4,v_VTC
.misc:
	move.b	#$0,synmod
	andi.w	#$ff,v_VMC	; 4us Burst
	move.w	#0,v_hoffset	; no extra words of video
	move.w	#0,v_pixscroll	; no pixel scroll
	move.w	#640,v_DLW	; displayed line width
.readpal:
	move.l	#$000,sppalette	; hit sparrow palette = bkgnd color
.set16mhz:
	ori.b	#1,SPControl	; turn on 16MHz
	bsr	BlankXGA	; kill screen memory
	bsr	DoXGAlines
	rts

*--------------------------------
* STe Mode, 640x200, Color Monitor
* (SP example 1) ...back to normal...
vNORMAL:
	btst	#FAKECOLOR,v_stat_R
	bne	vFAKE
	move.b	SPConfig,d0
	andi.b	#$c0,d0
	cmp.b	#$40,d0
	beq	.contd
	lea.l	PluginCOLORmsg,a5
	bsr	dspmsg
	bsr	init2key
	bsr	uconin
	cmp.b	#esc,d0
	beq	Videoexit
	bra	vNORMAL
.contd:
vAUTONORM:			; don't check bits.
	movea.l	#spex1,a0		; - SET TIMING
	movea.l	#spex1v,a1
	bsr	stuffSPregs
	move.w	#$00,v_spshiftmd
	move.b	#$0,synmod
	move.w	v_VMC,d0
	andi.w	#$f8,d0		; 4us Burst, 32MHz primary
	ori.w	#1,d0		; ST color monitor
	move.w	d0,v_VMC
	move.w	#4,v_VTC
	move.w	#0,v_hoffset	; no extra words of video
	move.w	#0,v_pixscroll	; no pixel scroll
	move.w	#80,v_DLW	; displayed line width
	move.b	#1,v_shf_mod	; should set VCK = 2MHz
	move.w	colsav,palette	; back to st mode - READ ST PALETTE
	bsr	setdsp
	rts

*-------------------------------
vTV:
	rts

* THIS TEST IS NOT NEEDED W/A GOOD SYSTEM
* TEST THE TV with XGA pic from color test]

;	move.b	SPConfig,d0
;	andi.b	#$c0,d0
;	cmp.b	#$c0,d0
;	beq	.contd
;	lea.l	PluginTVmsg,a5
;	bsr	dspmsg
;	bsr	uconin
;	cmp.b	#esc,d0
;	beq	Videoexit
;	bra	vTV
;.contd:
;	bsr	BlankXGA
;	movea.l	#spex13,a0
;	movea.l	#spex4v,a1
;	bsr	stuffSPregs
;	ori.w	#3,v_VMC
;*	move.w	#6,v_VTC
;	bsr	DoXGAlines
;	rts

*-------------------------------
vMONO:
	move.b	SPConfig,d0
	andi.b	#$c0,d0
	cmp.b	#$00,d0
	beq	.contd
	lea.l	PluginMONOmsg,a5
	bsr	dspmsg
	bsr	init2key
	bsr	uconin
	cmp.b	#esc,d0
	beq	Videoexit
	bra	vMONO
.contd:
	movea.l	#spex2,a0	;640 x 400, VCK = 2MHz, lw = 28us, 501 lines
	movea.l	#spex2v,a1
	bsr	stuffSPregs
*	move.w	#$400,v_spshiftmd	;don't do this.. dunno why, but LT says so.
	move.b	#2,v_shf_mod
	move.w	#8,v_VTC	; 32 MHz dotclock, VCK = 2MHz, 
	move.w	v_VMC,d0
	andi.w	#$fffc,d0	; ST MONO
*	ori.b	#$00,d0
	move.b	d0,v_VMC
	move.w	#$000,palette	; back to STe mode???
	rts

*-------------------------------
* Sparrow Mode, VGA 640x480, 256 colors VGA Monitor
* (SP example 3)
vVGA:
	move.b	SPConfig,d0
	andi.b	#$c0,d0
	cmp.b	#$80,d0
	beq	.contd
	lea.l	PluginVGAmsg,a5
	bsr	dspmsg
	bsr	init2key
	bsr	uconin
	cmp.b	#esc,d0
	beq	Videoexit
	bra	vVGA
.contd:
;- VGA plugged in
 	move.w	#639,maxx
	move.w	#479,maxy
	move.w	#7,wrdmde	; # planes (was -1)
	move.w	#640,bytperline
	move.w	#4,logplanes	; log2(#planes*2) ??
*--------------------------------------

	move.l	#sppalette+4,a0
	bsr	FillTestValues
	move.l	#$40000000,(a0)+	; 5 red
	move.l	#$80000000,(a0)+	; 6 red
	move.l	#$40,(a0)+	; 5 blue
	move.l	#$80,(a0)+	; 6 blue
	move.l	#$400000,(a0)+	; 5 green
	move.l	#$800000,(a0)+	; 6 green
	move.l	#$40000000,(a0)+	; 5 red

*-----------------------------------------

	ori.b	#1,SPControl	; turn on 16MHz
	move.w	palette,colsav
.settime:	
	movea.l	#spex3,a0		; - SET TIMING
	movea.l	#spex3v,a1
	bsr	stuffSPregs
.setvid:
	move.b	#spscrh,v_bas_h	; - SET VIDEO BASE ADDR
	move.b	#spscrm,v_bas_m
	move.b	#spscrl,v_bas_l
.setxga:
	move.w	#$10,v_spshiftmd	; - 8bpp, palette bank 0
	move.w	#8,v_VTC		; 25/32 mhz.
.misc:
	move.b	#$0,synmod
	move.w	v_VMC,d0
	andi.w	#$1f0,d0
	ori.w	#$106,d0	; 2us Burst, 25Mhz secondary, VGA moiotor
	move.w	d0,v_VMC
	move.w	#0,v_hoffset	; no extra words of video
	move.w	#0,v_pixscroll	; no pixel scroll
	move.w	#320,v_DLW	; displayed line width
.readpal:	
	bclr.b	#0,SPControl	; 8Mhz
	move.l	#$000,sppalette	; hit sparrow palette = bkgnd color
	bset.b	#0,SPControl;	; 16
;;	bsr	LoadSPPal	; put colors into palette
	bsr	CheckSPPal
.set16mhz:
	bsr	BlankVGA
	bsr	DrawVGAStuff
	rts


*-------------------------------
* Sparrow Mode, VGA 320x400, XGA on VGA Monitor
* (SP example 10) !! DOESN'T WORK W/REV 1 COMBELS !!
vVGAm2:
;- VGA plugged in already
*-----------------------------------------
	ori.b	#1,SPControl	; turn on 16MHz
.settime:	
	movea.l	#spex10,a0		; - SET TIMING
	movea.l	#spex3v,a1
	bsr	stuffSPregs
.setvid:
	move.w	#$100,v_spshiftmd	; XGA mode
*	move.w	#8,v_VTC		; 25/32 mhz.
	move.w	#4,v_VTC		; 16/12.5 MHz Mode
.misc:
*	move.w	v_VMC,d0
*	andi.w	#$0f0,d0
*	ori.w	#$006,d0	; 4us Burst, 25Mhz secondary, VGA monitor
*	ori.w	#$004,d0	; no 25MHz secondary..
*	move.w	d0,v_VMC
	move.w	#0,v_hoffset	; no extra words of video
	move.w	#$fe,v_pixscroll	; some pixel scroll
	move.w	#320,v_DLW	; displayed line width
.setpal:
	move.l	#$000,sppalette	; hit sparrow palette = bkgnd color
.set16mhz:
	bsr	BlankXGA
	bsr	DoXGAlines
	rts

*--------
;.macro	SDELAY
;	move.l	#200000,d0
;.\~:
;	nop
;	sub.l	#1,d0
;	bne	.\~
;.endm
*-------------------------------
* STe Mode, VGA 640x200, 4 colors VGA Monitor
* (SP example 9) - shows old test screen
vFAKE:
	move.b	SPConfig,d0
	andi.b	#$c0,d0
	cmp.b	#$80,d0
	beq	.contd
	lea.l	PluginVGAmsg,a5
	bsr	dspmsg
	bsr	init2key
	bsr	uconin
	bra	vFAKE
.contd:
vVGAm3:
;- VGA plugged in
*	ori.b	#1,SPControl	; turn on 16MHz
.settime:	
	movea.l	#spex9,a0		; - SET TIMING
	movea.l	#spex9v,a1
	bsr	stuffSPregs
.setvid:
	move.b	#scrmemh,v_bas_h	; - SET VIDEO BASE ADDR BACK TO NORMAL SCREEN
	move.b	#scrmemm,v_bas_m
	move.b	#scrmeml,v_bas_l
	move.b	#$01,v_shf_mod		; STe MODE REGISTER
	move.w	#9,v_VTC		; 25/32 mhz. - repeat lines on!
.misc:
	move.b	#$0,synmod
	move.w	v_VMC,d0
	andi.w	#$1f0,d0
	ori.w	#$106,d0	; 2us Burst, 25Mhz secondary, VGA monitor
	move.w	d0,v_VMC
	move.w	#0,v_hoffset	; no extra words of video
	move.w	#0,v_pixscroll	; no pixel scroll
	move.w	#80,v_DLW	; displayed line width
.readpal:
	move.w	#$000,palette	; hit STe palette = bkgnd color
	rts

DoVGAm3Stuff:
;	SDELAY			; don't bother with this stuff...
;	move.w	#11,d4
;	move.w	#$800,palette
;.chgpal:
;	SDELAY
;	ror.w	palette
;	dbra	d4,.chgpal
.set16mhz:
	lea.l	DoneVGAMsg,a5
	bsr	dspinv
	rts

*-------------------------------
* load sp palette with TT standard values
* uses: d0, d1, d2, a0, a1
;LoadSPPal:
;	bsr	CheckSPPal
;	movem.l	d0-d2/a0-a1,-(sp)
;	move.l	#_colors,a0
;	move.l	#sppalette+4,a1
;	move.l	#250,d0
;.red:
;	move.w	(a0),d1
;	andi.w	#$f00,d1
;	rol.w	#4,d1
;;green
;	move.w	(a0),d2
;	andi.w	#$0f0,d2
;	or.w	d1,d2
;	move.w	d2,(a1)+
;blue
;	move.w	(a0)+,d1
;	andi.w	#$00f,d1
;	rol.w	#4,d1
;	move.w	d1,(a1)+
;	
;	dbra	d0,.red
;	movem.l	(sp)+,d0-d2/a0-a1
;
;	rts	
;	
*---------------------------------
* CheckSPPal -  RAM TEST SP PALETTE
CheckSPPal:
	movem.l	d0-d3/a1,-(sp)
	move.l	#$FCFC00FC,d3
	bsr	.compare
	move.l	#$00000000,d3
	bsr	.compare
	move.l	#$a4a400a4,d3
	bsr	.compare
	move.l	#$58580058,d3
	bsr	.compare
	move.l	#$0,sppalette
	movem.l	(sp)+,d0-d3/a1
	rts
.error:
	move.w	#$fc00,sppalette
	move.w	#$0000,sppalette+2
	bra	.exit

* check all palette = d3.l
.compare:
	move.l	#sppalette,a1
	move.w	#250,d0
.lp:
	cmp.l	(a1)+,d3
	bne	.error
	dbra	d0,.lp
.exit:
	rts

*-------------------------------
BlankVGA:
	move.l	#spscrmem,a0
	move.w	#479,d0
	move.w	#0,d3		; clear to 0 bit
.draw1:
	move.w	v_DLW,d2
	subq.w	#1,d2
.drawline:			; draw one line
	move.w	d3,(a0)+
	dbra	d2,.drawline
	rol.w	#1,d3
	dbra	d0,.draw1	; loop through lines

	rts
*-------------------------------
* draw color blocks (test dac pin connections) IN VGA
.macro	DOVBLOCK color,x,y,height
	move.w	#\height,d3	;times to draw
	move.w	#\x,d0		;x1 for Hline
	move.w	#\y,d1		;y1
	move.w	#\x+100,d2	;x2+100 = width
	move.w	#\color,d4	;line color
.\~:
	bsr	DrawVGALine
	add.w	#1,d1		; next line
	dbra	d3,.\~		; until all drawn
.endm
*-------------------------------
* draw color blocks (test dac pin connections) IN VGA
.macro	DOVSHADE stcolor,x,y,height
	move.w	#\height,d3	;times to draw
	move.w	#\x,d0		;x1 for Hline
	move.w	#\y,d1		;y1
	move.w	#\x+45,d2	;x2+100 = width
	move.w	#\stcolor,d4	;line color
.\~:
	move.w	#5,d5
.2\~:	bsr	DrawVGALine
	add.w	#1,d1		; next line
	dbra	d5,.2\~
	add.w	#1,d4
	dbra	d3,.\~		; until all drawn
.endm
*-------------------------------
* DrawVGAStuff
DrawVGAStuff:
	move.w	#0,d0		; do big X on screen
	move.w	#0,d1
	move.w	#$fe,d4
.dvs:
	bsr	VGAPoint
	add.w	#1,d0
	add.w	#1,d1
	cmp.w	#480,d1	
	bne	.dvs 
       	
	move.w	#$fe,d4
	move.w	#0,d0 
.dvs2:
	bsr	VGAPoint
	add.w	#1,d0
	sub.w	#1,d1
	cmp.w	#0,d1	
	bne	.dvs2
*-----				
	move.w	#320,d0		; do big | on screen
	move.w	#1,d1
	move.w	#$fe,d4
.dvs3:
	bsr	VGAPoint
	add.w	#1,d1
	cmp.w	#480,d1	
	bne	.dvs3

	move.w	#1,d0		; do big - on screen
	move.w	#240,d1
	move.w	#$fe,d4
.dvs4:
	bsr	VGAPoint
	add.w	#1,d0
	cmp.w	#640,d0	
	bne	.dvs4

*---- do box on screen
	move.w	#$fe,d4
; top
	move.w	#0,d0		; x1
	move.w	#0,d1		; y
	move.w	#640,d2		; x2	
	bsr	DrawVGALine
;bottom
;	move.w	#0,d0		; x1
	move.w	#479,d1		; y
	move.w	#640,d2		; x2	
	bsr	DrawVGALine
;left
	move.w	#0,d0		; do big | on screen
	move.w	#0,d1
.dvsl:
	bsr	VGAPoint
	add.w	#1,d1
	cmp.w	#481,d1	
	bne	.dvsl
;right
	move.w	#639,d0		; do big | on screen
	move.w	#0,d1
.dvsr:
	bsr	VGAPoint
	add.w	#1,d1
	cmp.w	#481,d1	
	bne	.dvsr

       	
*--------------------------------------
;	bsr	LoadSPPal
;
	move.l	#sppalette+4,a0
;	bclr.b	#0,SPControl		; downto 8 MHz
; PUT PALETTE SWEEP IN HERE...

*--- sweep through all green bits
	move.l	#$00040000,d0
	bsr	.colorSweep
	move.l	#$00000004,d0
	bsr	.colorSweep
	move.l	#$04000000,d0
	bsr	.colorSweep
*--- Fill in other test values
	bsr	FillTestValues
	clr.l	d0
.lp:	add.l	#$11111111,d0
	cmp.l	#$ff9c00,a0
	beq	.continue
	move.l	d0,(a0)+
	bra	.lp
*---
	bra	.continue
*-----------------------------------
* set palette to each color sweeping for 64 colors
.colorSweep:
	move.l	d0,d1	
	move.w	#64,d2
.glp:
	move.l	d1,(a0)+
	add.l	d0,d1
	dbra	d2,.glp
	rts
*---	
.continue:
;	move.l	#$00040000,(a0)+	; 1 green
;	move.l	#$00080000,(a0)+	; 2 green
;	move.l	#$00100000,(a0)+	; 3 green
;	move.l	#$00200000,(a0)+	; 4 green
;	move.l	#$00400000,(a0)+	; 5 green
;	move.l	#$00800000,(a0)+	; 6 green
;
;	move.l	#$00000004,(a0)+	; 1 blue
;	move.l	#$00000008,(a0)+	; 2 blue
;	move.l	#$00000010,(a0)+	; 3 blue
;	move.l	#$00000020,(a0)+	; 4 blue
;	move.l	#$00000040,(a0)+	; 5 blue
;	move.l	#$00000080,(a0)+	; 6 blue
;
;	move.l	#$04000000,(a0)+	; 1 red
;	move.l	#$08000000,(a0)+	; 2 red
;	move.l	#$10000000,(a0)+	; 3 red
;	move.l	#$20000000,(a0)+	; 4 red
;	move.l	#$40000000,(a0)+	; 5 red
;	move.l	#$80000000,(a0)+	; 6 red

	move.l	#$ffffffff,sppalette+(4*$fe)	; set white for blocks

;	bset.b	#0,SPControl		; back to 16MHz
*-----------------------------------------

; - RED PIXELS				; one per possible color pin. (turn the brightness way up)
	DOVSHADE	0,500,0+60,65
;	DOVBLOCK	1,500,0+60,20	; color,x,y,height
;	DOVBLOCK	2,500,20+60,20
;	DOVBLOCK	3,500,40+60,20
;	DOVBLOCK	4,500,60+60,20
;	DOVBLOCK	5,500,80+60,20
;	DOVBLOCK	6,500,100+60,20
; - GREEN PIXELS				; one per possible color pin. (turn the brightness way up)
	DOVSHADE	65,545,0+60,65
;	DOVBLOCK	7,500,130+60,20
;	DOVBLOCK	8,500,140+60,20
;	DOVBLOCK	9,500,160+60,20
;	DOVBLOCK	10,500,180+60,20
;	DOVBLOCK	11,500,200+60,20
;	DOVBLOCK	12,500,220+60,20
; - BLUE PIXELS					; one per possible color pin. (turn the brightness way up)
	DOVSHADE	130,590,0+60,65
;	DOVBLOCK	13,500,260+60,20
;	DOVBLOCK	14,500,260+60,20
;	DOVBLOCK	15,500,280+60,20
;	DOVBLOCK	16,500,300+60,20
;	DOVBLOCK	17,500,320+60,20
;	DOVBLOCK	18,500,340+60,20

*----------------------------------------
; draw white block for jitter finding..
	DOVBLOCK	$fe,400,90,300

;	move.l	#$0,sppalette

; put black lines through it..
	move.w	#400,d0		; do \ on screen
	move.w	#90,d1
	move.w	#$00,d4		; CHANGE THIS WHEN BLACK IS AVAILABLE
.dvs5:
	bsr	VGAPoint
	add.w	#1,d1
	bsr	VGAPoint
	add.w	#1,d1
	bsr	VGAPoint
	add.w	#1,d1
	add.w	#1,d0
	cmp.w	#501,d0	
	bne	.dvs5 

	move.w	#499,d0		; do / on screen
	move.w	#90,d1
.dvs6:
	bsr	VGAPoint
	add.w	#1,d1
	bsr	VGAPoint
	add.w	#1,d1
	bsr	VGAPoint
	add.w	#1,d1
	sub.w	#1,d0
	cmp.w	#399,d0	
	bne	.dvs6
                  	
*-----				
	move.w	#450,d0		; do | on screen
	move.w	#90,d1
.dvs7:
	bsr	VGAPoint
	add.w	#1,d1
	cmp.w	#390,d1	
	bne	.dvs7

	move.w	#400,d0		; do - on screen
	move.w	#240,d1
	move.w	#500,d2	; x2
	bsr	DrawVGALine

*-----
* color blocks of all colors
	move.w	#160,d1		; initial y
	move.w	#0,d0		; initial x
	move.w	#0,d4		; inital color
.nextcol:
	bsr	VGACBlock
	add.w	#1,d4
	add.w	#10,d0		; 16 more for x
	cmp.w	#160,d0
	blt	.nextcol
	move.w	#0,d0
	add.w	#1,d4
	add.w	#10,d1
	cmp.w	#160+160,d1
	blt	.nextcol

	rts
*-------------------------------
; VGACBlock - color block 16 * 16 of vga colors
; x = d0, y = d1, color = d4. d2,d3 used.
VGACBlock:
	movem.l	d1-d2,-(sp)
	move.w	#10,d3		;times to draw
	move.w	d0,d2
	add.w	#10,d2
VGC2:
	bsr	DrawVGALine
	add.w	#1,d1		; next line
	dbra	d3,VGC2		; until all drawn
	movem.l	(sp)+,d1-d2
	rts

*-------------------------------
*	d0,d1 = x1,y1 d2 = x2 	d4=color
DrawVGALine:
	movem.l	d0,-(sp)
.draw2:
	cmp.w	d0,d2
	beq	.dexit
	bsr	VGAPoint	;do start of line
	add.w	#1,d0		; and next pixel along until done
	bra	.draw2
.dexit:
	movem.l	(sp)+,d0
	rts
*-------------------------------
* VGAPoint: d0=x d1 = y. d4 = color. Plots point (x,y) w/color
VGAPoint:
	movem.l	d0-d4/a0,-(sp)
	move.l	d4,d2		; move color
	bsr	cplot
	movem.l	(sp)+,d0-d4/a0
	rts

*-------------------------------
* draw color blocks (test dac pin connections) and rainbow lines in XGA 
.macro	DOXBLOCK color,x,y,height
	move.w	#\height,d3	;times to draw
	move.w	#\x,d0		;x1 for Hline
	move.w	#\y,d1		;y1
	move.w	#\x+100,d2	;x2+100 = width
	move.w	#\color,d4	;line color
.\~:
	bsr	DrawHLine
	add.w	#1,d1		; next line
	dbra	d3,.\~		; until all drawn
.endm

*---------------------------------
* draw varying color stripes to test DAC pins (Leo and Richard want this)
.macro DOXGSHADE coloradd,x,y,height
	move.w	#\height,d3	;times to draw
	move.w	#\x,d0		;x1 for Hline
	move.w	#\y,d1		;y1
	move.w	#\x+100,d2	;x2+100 = width
	move.w	#0,d4		;line color starts at 0
.\~:
	bsr	DrawHLine
	add.w	#1,d1		; next line
	bsr	DrawHLine
	add.w	#1,d1		; next line
	bsr	DrawHLine
	add.w	#1,d1		; next line
	add.w	#\coloradd,d4
	dbra	d3,.\~		; until all drawn
.exit\~:
.endm
*---------------------------------
* draw varying color stripes to test DAC pins (Leo and Richard want this)
.macro DOXSHADE coloradd,x,y,height
	move.w	#\height,d3	;times to draw
	move.w	#\x,d0		;x1 for Hline
	move.w	#\y,d1		;y1
	move.w	#\x+100,d2	;x2+100 = width
	move.w	#0,d4		;line color starts at 0
.\~:
	bsr	DrawHLine
	add.w	#1,d1		; next line
	bsr	DrawHLine
	add.w	#1,d1		; next line
	bsr	DrawHLine
	add.w	#1,d1		; next line
	add.w	#\coloradd,d4
	dbra	d3,.\~		; until all drawn
.exit\~:
.endm
*---------------------------------
DoXGAlines:
	bsr	BlankXGA		; clear whole screen
; - RED PIXELS				; one per possible color pin. (turn the brightness way up)
	DOXSHADE	$0800,0,0,65
;	DOXBLOCK	$0800,0,0,40
;	DOXBLOCK	$1000,0,40,40
;	DOXBLOCK	$2000,0,80,40
;	DOXBLOCK	$4000,0,120,40
;	DOXBLOCK	$8000,0,160,40
; - GREEN PIXELS
	DOXGSHADE	$0020,100,0,65
;	DOXBLOCK	$0020,100,0,33
;	DOXBLOCK	$0040,100,33,33
;	DOXBLOCK	$0080,100,66,33
;	DOXBLOCK	$0100,100,99,33
;	DOXBLOCK	$0200,100,133,33
;	DOXBLOCK	$0400,100,166,33
; - BLUE PIXELS
	DOXSHADE	$0001,200,0,65
;	DOXBLOCK	$0001,200,0,40
;	DOXBLOCK	$0002,200,40,40
;	DOXBLOCK	$0004,200,80,40
;	DOXBLOCK	$0008,200,120,40
;	DOXBLOCK	$0010,200,160,40
DrawRainbow:
	move.l	#$f800,d4	; color = full red
	move.l	#1,d1		; y1
	move.l	#320,d0		; x1
	move.l	#640,d2		; x2
.draw1:
	bsr	DrawHLine
	addq.l	#1,d1		; y1
	add.w	#$40,d4		; color
	cmp.w	#$0000,d4
	beq	.dr2		; overflow? 
	cmpi.l	#200,d1
	blt	.draw1
	rts
.dr2:
	move.l	#$ffe0,d4	; color
.draw2:
	bsr	DrawHLine
	sub.l	#$800,d4		; color
	cmpi.w	#$07e0,d4
	beq	.dr3
	addq.l	#1,d1			; y1
	cmpi.l	#200,d1
	blt	.draw2
	rts
.dr3:
	move.l	#$07e0,d4	; color
.draw3:
	bsr	DrawHLine
	add.w	#$01,d4
	sub.w	#$40,d4		; color
	bmi	.dr4
	addq.l	#1,d1			; y1
	cmpi.l	#200,d1
	blt	.draw3
	rts
.dr4:
	move.l	#$001f,d4	; color = blue
.draw4:
	bsr	DrawHLine
	add.w	#$0800,d4		; color
	cmp.w	#$f81f,d4
	beq	.dr5
	addq.l	#1,d1			; y1
	cmpi.l	#200,d1
	blt	.draw4
	rts
.dr5:
	move.l	#$f81f,d4	; color = blue
.draw5:
	bsr	DrawHLine
	sub.w	#$01,d4		; color
	cmp.w	#$f800,d4
	beq	.dr6
	addq.l	#1,d1			; y1
	cmpi.l	#200,d1
	blt	.draw5
	rts
.dr6:
	bra	.draw1
	rts

***********************
* clear screen
BlankXGA:
	move.l	#spscrmem,a0
	move.w	#200,d0
	move.w	#$0,d3	; clear to white
.draw1:
	move.w	v_DLW,d2
	subq.l	#1,d2
.drawline:			; draw one line
	move.w	d3,(a0)+
	dbra	d2,.drawline
	dbra	d0,.draw1	; loop through lines
	rts

********************************
* stuffSPregs - load horiz & vert data blocks into sp video
* entry:
*	a0 - address of horizontal data block
* 	a1 - address of vertical data block 
* uses: a0, a1, a2

stuffSPregs:
	movea.l	#v_VFT,a2
.spl2:
	move.w	(a1)+,(a2)+
	cmpa.l	#v_VSS+2,a2
	bne	.spl2

	movea.l	#v_HHT,a2	
.spl1:
	move.w	(a0)+,(a2)+
	cmpa.l	#v_HEE+2,a2
	bne	.spl1
	
	rts	

*================================
* Carefully crafted test numbers
* for general purpose use. Try not to change these
* a0 = location

FillTestValues:
	move.l	#$ff000b0d,(a0)+
	move.l	#$52575320,(a0)+
	move.l	#$48493220,(a0)+
	move.l	#$44532026,(a0)+
	move.l	#$20485320,(a0)+
	move.l	#$4d4b4220,(a0)+
	move.l	#$4c4c2043,(a0)+
	move.l	#$53204252,(a0)+
	move.l	#$4f532048,(a0)+
	move.l	#$54204b57,(a0)+
	move.l	#$0d0b00ff,(a0)+
	rts

********************************
* SaveSPRegs - save horiz & vert data blocks onto stack
* uses: a2 & a5 points to save space
;SaveSPRegs:
;	movea.l	#v_VFT,a2
;.spl2:	move.w	(a2)+,(a5)+
;	cmpa.l	#v_VSS+2,a2
;	bne	.spl2
;	movea.l	#v_HHT,a2	
;.spl1:	move.w	(a2)+,(a5)+
;	cmpa.l	#v_HEE+2,a2
;	bne	.spl1
;
;	move.w	v_spshiftmd,(a5)+
;	move.w	v_VTC,(a5)+
;	move.w	synmod,(a5)+
;	move.w	v_VMC,(a5)+
;	move.w	v_hoffset,(a5)+
;	move.w	v_pixscroll,(a5)+
;	move.w	v_DLW,(a5)+
;	rts	

********************************
* UnSaveSPRegs - load horiz & vert data blocks off stack
* uses: a2 & a5 points to save space
;UnSaveSPRegs:
;	movea.l	#v_VFT,a2
;.spl2:	move.w	(a5)+,(a2)+
;	cmpa.l	#v_VSS+2,a2
;	bne	.spl2
;	movea.l	#v_HHT,a2	
;.spl1:	move.w	(a5)+,(a2)+
;	cmpa.l	#v_HEE+2,a2
;	bne	.spl1
;
;	move.w	(a5)+,v_spshiftmd
;	move.w	(a5)+,v_VTC
;	move.w	(a5)+,synmod
;	move.w	(a5)+,v_VMC
;	move.w	(a5)+,v_hoffset
;	move.w	(a5)+,v_pixscroll
;	move.w	(a5)+,v_DLW
;	rts	

*-----------------------------------------------------
* DrawHLine - draw horizontal line left to right ONLY!
*	d0,d1 = x1,y1 d2 = x2 	d4=color !!NO BOUNDS CHECKING!!
*	spscrmem = screen memory location
DrawHLine:
	movem.l	d0-d4/a0,-(sp)
	andi.l	#$ffff,d0
	andi.l	#$ffff,d1
	andi.l	#$ffff,d2
	andi.l	#$ffff,d4
	move.w	v_DLW,d3	; get pixels (words)/line
	asl.l	#1,d3		; get bytes per line
	mulu.w	d3,d1		; figure y value
	asl.l	#1,d0		; get x pixel offset in words
	asl.l	#1,d2
	move.l	#spscrmem,a0
	add.l	d1,a0
.dhl:
*TESTING!	andi.w	#$ffdf,d4	;RWS.TPE !! TAKE THIS OUT
	move.w	d4,(a0,d0)
	addq.l	#2,d0	
	cmp.l	d2,d0
	blt	.dhl
	movem.l	(sp)+,d0-d4/a0
	rts

*********************************
*       Display Help screen
s2mhelp:  bsr     clearsc
        lea     s2help1,a5
        bsr     dspmsg
        bsr     conin
	bra	s2gb_ret

**************************************************
* SWIPED FROM FXGR.S (was: ttgr.s) : 25MAR92 : RWS
; cplot(x, y, color)
;   D0=x, D1=y, D2=color

cplot:	bsr	pelsu		; pixel setup
 	beq.s	.4		; pixel not on screen

.1:	ror.w	#1,d2		; modified to do lsb first
	bcc.s	.2
	or.w	d1,(a0)+
	bra.s	.3
.2:	not.w	d1
	and.w	d1,(a0)+
	not.w	d1
.3:	dbra	d3,.1

.4:	rts

; pelsu
;	entry:	d0 = x, d1 = y, d2 = color
;	exit:	d0 used, d1 = bit mask
;		a0 -> word to modify
;
pelsu:
	andi.l	#$ffff,d0
	andi.l	#$ffff,d1
	andi.l	#$ffff,d2
	tst.w	d0		; is x<0?
	bmi.s	.9
	cmp.w	maxx,d0		; is x>maxx?
	bgt.s	.9
	tst.w	d1		; is y<0?
	bmi.s	.9
	cmp.w	maxy,d1		; is y>maxy
	bgt.s	.9

	move.l	#spscrmem,a0	; start of display
	mulu.w	bytperline,d1	; y*BytesPerLine
*---
;	mulu.w	#640,d1		; RWS : NEW!
*---
	add.l	d1,a0
	move.w	d0,-(sp)	; preserve d0

	asr.w	#4,d0		; x/16
	move.w	logplanes,d1
	asl.w	d1,d0		; (x/16)*(2*NumberOfPlanes)
*---
;	and.w	#$fff0,d0	; RWS : NEW!
*---
	add.l	d0,a0		; a0 points to first word to mung

	move.w	wrdmde,d3	; number of words Doug makes us change

	move.w	#$8000,d1	; start of a bit mask
	move.w	(sp)+,d0	; recall x
	andi.w	#$0F,d0		; x%16
	ror.w	d0,d1		; d1 = bit mask for this x

	rts			; bit mask is non-zero, signalling on screen

.9:	clr.l	d3		; signal quick return
	rts

* ENDSWIPE
	.data
	.even
*		VFT,VBB,VBE,VDB,VDE,VSS		* NOTE! WATCH VSS & HSS!!
spex1v:
*	dc.w	623-100,613-100,47-25,127-50,527-50,618-100
*	dc.w	623,613, 47,127,527,618
	dc.w	625,613, 47,117,517,619
spex2v:	dc.w	1001, 0,  0, 67,867,999
spex3v:	dc.w	1049,1039,47,63,1023,1045
spex4v:	dc.w	624,613, 47,127,527,618
spex9v:	dc.w	1049,1039,47,143,943,1045	
*
*		HHT,HBB,HBE,HDB,HDE,HSS,HFS,HEE
spex1:	dc.w	 62, 50,  9,575, 28, 52,  0,  0
spex2:	dc.w	 26,  0,  0,527, 12, 20,  0,  0
spex3:	dc.w	198,147, 19,686,135,150,  0,  0
spex9:	dc.w	 23, 19,  2,526, 13, 18,  0,  0
spex10:	dc.w	198,146, 19,694,143,150,  0,  0
spex12: ;(NOT REALLY SPEX12 anymore)
*	dc.w	254,203,39,  34,147,214,362,474
	dc.w	510,410,92,1102,287,435,362,474
spex13:
	dc.w	510,412,92, 96, 295,436,362,474

**************
*            *
*  messages  *
*            *
**************
	
vMonitorsMsg:	dc.b	cr,lf,'Video Monitors Test - Press space bar after each screen. ESC to exit',cr,lf
		dc.b	tab,'Switch monitors if screen does not change after space bar',cr,lf,eot

*       character preceded by 1 is printed in inverse video
s2menumsg:
	dc.b	tab,tab,invtog,'Video Test Submenu',invtog,cr,lf,cr,lf	
	dc.b	tab,iv,'C Color Test',cr,lf 
	dc.b	tab,iv,'V VGA Modes Test',cr,lf
	dc.b	tab,iv,'M Video Monitors Test',cr,lf
	dc.b	cr,lf
	dc.b	tab,iv,'1 Color Monitor Test',cr,lf
	dc.b	tab,iv,'2 TV Test',cr,lf
	dc.b	tab,iv,'3 Mono Test',cr,lf
	dc.b	tab,iv,'4 VGA Test',cr,lf
	dc.b	cr,lf
	dc.b	tab,iv,'? Submenu Help',cr,lf
	dc.b	lf
	dc.b	tab,'Enter letter: ',eot


*               '1234567890123456789012345678901234567890'

s2help1:

	dc.b	'Video Monitors Test - color->Mono->VGA->Color=exit',cr,lf
	dc.b	'VGA Modes Test - test various sparrow modes on VGA monitor',cr,lf
	dc.b	'use RS232 terminal for user prompts',cr,lf
	dc.b	'Check the TV modulator with the color monitor test',cr,lf
	dc.b    'Use ESC to exit this submenu'
        dc.b    cr,lf
        dc.b    eot 

RWSMsg:
	dc.b	cr,lf,'by Roy Stedman - Atari Texas',cr,lf,eot
DoneVGAMsg:
	dc.b	cr,lf,cr,lf,invtog,'Done with VGA tests',invtog,cr,lf,eot
PluginVGAmsg:
	dc.b	cr,lf,'Plug in VGA monitor and press SPACE',eot
PluginMONOmsg:
	dc.b	cr,lf,'Plug in Mono monitor and press SPACE',eot
PluginCOLORmsg:
	dc.b	cr,lf,'Plug in Color monitor and '
pSpaceMsg:
	dc.b	'press SPACE',cr,lf,eot
pBKeyMsg:
;	dc.b	'PRESS B NOW IF THIS SYSTEM HAS A REV 1 COMBEL'
	dc.b	eot
TestSTeVGAMsg:
	dc.b	cr,lf,'Now Testing STe VGA mode. If you can see this on the screen, OK.',cr,lf,eot
;PluginTVmsg:
;	dc.b	cr,lf,'Plug in TV, unplug other monitor and press SPACE',eot

;	.include palette
* defines _colors to be an index to 256 words of $0RGB...

	.bss

* NEW VIDEO STORAGE : 24MAR92 : RWS
	         
rbcolor:	ds.l	1
rbdir:		ds.l	1

vbhstore:	ds.w	1
vbmstore:	ds.w	1
vblstore:	ds.w	1


maxx:	ds.w	1
maxy:	ds.w	1
wrdmde:	ds.w	1
bytperline:	ds.w	1
logplanes:	ds.w	1

