;                        //==========================\\
;                       //|  demo part handler 1.0   |\\
;                       \\|    24-08-2002 by earx    |//
;                        \\==========================//
;
;                                falcon030 only
; 
; beware: only 3 screenbuffers

;======= GLOBAL EQUATES ========

DEMO_SYSTEM:					; Indicates demosystem is active.
testmode:	=	0			; debug mode

MAX_SCREENSIZE:	=	320*200*2

; monitormode-equates
autodetect:	=	0
rgb50:		=	1			; RGB/TV, 50Hz
vga60:		=	2			; VGA, 60, noninterlaced
vga100:		=	3			; VGA, 100Hz, interlaced
; monitormode selector ( =autodetect ) or force mode ( >0 )
monitorequ:	=	autodetect

Part.INIT:	=	0
Part.START:	=	4
Part.STOP:	=	8

;======= ASM OPTIONS AND PATHS ========

	COMMENT	HEAD=%111
	OPT	P=68030
	IFEQ	testmode
	OPT	D-
	ENDC

;======= INCLUDES ========

	bra.l	START

	INCLUDE	SYS.I
	TEXT
	INCLUDE	MEM.I
	TEXT
	INCLUDE	MATH.I
	TEXT
	INCLUDE	DEPACK35.S
	INCLUDE	FSCR2.I
	TEXT
	INCLUDE	DSP_FIX.S
	TEXT
;	INCLUDE	DSP.I
	INCLUDE	TEXTURE.I
	TEXT
	INCLUDE	EARXPLAO.S
	TEXT
	INCLUDE	SFLY_DSP.S			; Include the CPU-DSP engine.
	TEXT
	INCLUDE	OBJECT3D.I
	TEXT
	INCLUDE	TUNNEL.I
	TEXT
	INCLUDE	FONT.I
	TEXT

;======= INITIALISING ========

START:
; Give back some mem to the system..
	move.l	$04(sp),a5			; mshrink
	move.l	$0C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	addi.l	#$00001000,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			; even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

; mxalloc - Reserve stram ONLY for screens.
	move.w	#0,-(sp)
	move.l	#MAX_SCREENSIZE*3+256,-(sp)	; size of screens..
	move.w	#$44,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0				; Check if there is ST-RAM enough.
	bgt.s	.ramok
; Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1

; Initialize screenaddresses..
.ramok	lea	scr,a0
	addi.l	#15,d0				; / long even
	andi.b	#%11110000,d0			; \ address..
	move.l	d0,(a0)+
	addi.l	#MAX_SCREENSIZE,d0
	move.l	d0,(a0)+
	addi.l	#MAX_SCREENSIZE,d0
	move.l	d0,(a0)+

; Calculate sine table.
	lea	sine_tbl,a0
	Init_SineTable

	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	bsr.l	getSettings
	tst.w	d0
	bmi.l	exit
	ENDC

; Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,oldsp
	move.l	#ustk,sp			; Install own stack..

; Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr

; Falcon check..
	move.l	$05A0.w,a0
	tst.l	a0
	beq.l	exit
.fndmch	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found	cmpi.w	#3,4(a0)
	bne.l	exit

; Initialize libs..
	bsr.l	System.init
	bsr	setDot
	bsr.l	Mem.init
	bsr	setDot
	bsr.l	Tunnel.genOffsetMap
	bsr	setDot
	bsr.l	Tunnel.calcFlareOctant
	bsr	setDot
	bsr.l	FlareGen.init
	bsr	setDot
	bsr.l	Texture.makeDefaults
	bsr	setDot
	bsr.l	Font.init
	bsr	setDot

; Call parts to initialize all their screens..
	bsr.l	initParts
	tst.l	d0
	bmi.l	exit
	bsr	setDot

; Initialize intro..
	movea.l	Intro.table+4,a1
	jsr	(a1)
	tst.l	d0
	bmi.l	exit
	bsr	setDot
; Initialize menuscreen..
	movea.l	Menu.table+4,a1
	jsr	(a1)
	tst.l	d0
	bmi.l	exit
	bsr	setDot

; Reserve enough mem for all fx.
	bsr.l	Mem.take
	tst.l	d0
	beq.l	exit

; Save and install nasty interrupts..
	IFEQ	testmode
	move.b	$0484.w,old484
	clr.b	$0484.w
; Save falcon-pallette..
	bsr.l	SAVE_FALCPAL
; Save resolution..
	bsr.l	SAVE_FV
; Install own vbl-routine..
	move	#$2700,sr
	move.l	$0070.w,oldvbl
	move.l	#NEWVBL,$70.w
	move	#$2300,sr

; Initialize mod-player.
	moveq	#2,d0				; 33KHz
;	moveq	#1,d0				; 49KHz
	bsr.l	EarxPlay.init
	tst.l	d0
	bmi.l	return2tos

; Black out palette..
	lea	$FFFF9800.w,a0
	clr.l	d0
	clr.b	d1
.loop:	move.l	d0,(a0)+
	addq.b	#1,d1
	bne.s	.loop
	ENDC					; IFEQ testmode

; Show intro..
	bsr.l	showIntro

; Show menu, request part...
showMenu:
	bsr.l	showActualMenu
	move.w	d0,partNum

; Set the demo to selected part.
	move.w	partNum,d0
	bsr.l	setPart

; Reset framecounters, timers.
	clr.l	d0
	move.l	d0,frmcnt
	move.l	d0,lastframecount
	move.l	$04BA.w,starttime

mainloopcycle:

	IFNE	0

; Test if a key is pressed.
	move.w	#$B,-(sp)
	trap	#1
	addq	#2,sp
	tst.w	d0
	beq.s	.key_done
; Read the waiting char.
	move.w	#1,-(sp)
	trap	#1
	addq	#2,sp
	swap	d0

	ELSE

	move.b	$FFFFFC02.w,d0

	ENDC

	cmpi.b	#$39,d0
	beq.l	showMenu
	cmpi.b	#$72,d0
	bne.s	.no_skip
	bsr.l	EarxPlay.nextPos
.no_skip:

.key_done:
	movea.l	actScreenAdr,a0
	tst.l	a0
	beq.s	.do
	movea.l	(a0),a1
	jsr	(a1)				; execute main-rout of screen
.do:	addq.l	#1,frmcnt
	bsr.l	handleDemoEvents
	bra.s	mainloopcycle

setDot:	move.w	#".",-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq	#4,sp
	rts

;======= INCLUDED PARTS ========

partTable:
	DC.L	alphaRoutTable
	DC.L	betaRoutTable
	DC.L	gammaRoutTable
	DC.L	0

alphaRoutTable:
	INCLUDE	ALPHA_P.S
	TEXT
betaRoutTable:
	INCLUDE	BETA_P.S
	TEXT
gammaRoutTable:
	INCLUDE	GAMMA_P.S
	TEXT

; A dark intermezzo.
	INCLUDE	BLACK.SO
	INCLUDE	INTRO.SO
	TEXT
	INCLUDE	MENU2.SO
	TEXT

;======= EXITTING CODE ========

return2tos:
OUT:
	IFEQ	testmode

; Stop current part..
;	move.w	partNum,d0
;	movea.l	(partTable,d0.w*4),a0
;	movea.l	Part.STOP(a0),a0
;	jsr	(a0)

exitMenu:
	bsr.l	EarxPlay.stop
	bsr.l	EarxPlay.deinit

; Restore interrupts..
	move.l	oldvbl,$70.w

; Restore video..
	lea	save_fv,a0
	bsr.l	CHANGE_FVFAST
	bsr.l	RESTORE_FALCPAL

; Restore screen..
	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

; Restore keyboard sound..
	move.b	old484,$0484.w

	ENDC					; IFEQ testmode

	bsr.l	dsp_load_bootstrap

exit:	clr.w	-(sp)
	trap	#1

;======= DEMO-OS SUBROUTINES ========

		RSRESET
Option.XPOS:	RS.B	1
Option.YPOS:	RS.B	1
Option.CHAR:	RS.B	1

Keycode.ESCAPE:	=	27		; escape
Keycode.RGB_50:	=	"1"
Keycode.VGA_100:=	"2"
Keycode.VGA_60:	=	"3"
Keycode.DETAIL:	=	"d"

; OUTPUT:
; d0.w:	0=Run demo, -1=Exit demo
getSettings:
	bsr	paintSelector

.repaint:
	tst.w	detail
	beq.s	.set_wtext
	pea	.detailb_txt(pc)
	bra.s	.paint_detail
.set_wtext:
	pea	.detailw_txt(pc)
.paint_detail:
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

; Read a key from the console into d0.
.get_newkey:
	move.w	#8,-(sp)
	trap	#1
	addq	#2,sp
; d0.b: result keycode

	cmpi.b	#Keycode.ESCAPE,d0
	beq.s	.exit
	cmpi.b	#Keycode.RGB_50,d0
	beq.s	.set_rgb50
	cmpi.b	#Keycode.VGA_100,d0
	beq.s	.set_vga100
	cmpi.b	#Keycode.VGA_60,d0
	beq.s	.set_vga60
	cmpi.b	#Keycode.DETAIL,d0
	beq.s	.switch_detail
	bra.s	.get_newkey

.set_rgb50:
	move.w	#rgb50,monitormode
	bra.s	.proceed
.set_vga100:
	move.w	#vga100,monitormode
	bra.s	.proceed
.set_vga60:
	move.w	#vga60,monitormode
	bra.s	.proceed
.switch_detail:
	not.w	detail
	bra.s	.repaint

.proceed:
	moveq	#0,d0
	rts
.exit:	moveq	#-1,d0
	rts

.detailw_txt:
	DC.B	27,89,32+11,32+18,"detail",27,89,32+13,32+15,0
.detailb_txt:
	DC.B	27,89,32+11,32+18,27,112,"detail",27,113,27,89,32+13,32+15,0
	EVEN

paintSelector:
	pea	selector_txt
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

; Run the intro..
showIntro:
	clr.l	d0
	move.l	d0,frmcnt
	move.l	d0,lastframecount
	move.l	$04BA.w,starttime

.intro_loop:
; Test if a key is pressed.
	move.w	#$B,-(sp)
	trap	#1
	addq	#2,sp
	tst.w	d0
	beq.s	.no_introkey_waiting

; Read the waiting char.
	move.w	#7,-(sp)
	trap	#1
	addq	#2,sp

	cmpi.b	#' ',d0
	beq	.intro_done

.no_introkey_waiting:
	move.l	$04BA.w,d0
	sub.l	starttime,d0
	cmpi.l	#100,d0
	blt.s	.intro_events_done
	cmpi.l	#700+400,d0
	blt.s	.try_crew_logo
	cmpi.l	#1300+400,d0
	blt.s	.try_presents
	cmpi.l	#2000+400,d0
	bge.s	.intro_done

.try_delta:
	tst.w	.delta_shown(pc)
	bne.s	.intro_events_done
	st	.delta_shown
	movea.l	Intro.table+4*5,a1
	jsr	(a1)
	bra.s	.intro_events_done

.try_presents:
	tst.w	.presents_shown(pc)
	bne.s	.intro_events_done
	st	.presents_shown
	movea.l	Intro.table+4*4,a1
	jsr	(a1)
	bra.s	.intro_events_done

.try_crew_logo:
	tst.w	.crew_shown(pc)
	bne.s	.intro_events_done
	st	.crew_shown
	movea.l	Intro.table+4*3,a1
	jsr	(a1)

.intro_events_done:
	movea.l	Intro.table,a1
	jsr	(a1)
	addq.l	#1,frmcnt
	bra	.intro_loop

.intro_done:
	rts

.crew_shown:
	DC.W	0
.presents_shown:
	DC.W	0
.delta_shown:
	DC.W	0

; Shows a nice graphic delta menu..
; OUPUT:
; d0.w= partnumber
showActualMenu:
	bsr.l	EarxPlay.stop
	clr.l	d0
	move.w	d0,.options_shown
	move.w	d0,.logo_shown
	move.l	d0,frmcnt
	move.l	d0,lastframecount
	move.l	$04BA.w,starttime

.menu_loop:
; Test if a key is pressed.
	move.w	#$B,-(sp)
	trap	#1
	addq	#2,sp
	tst.w	d0
	beq.s	.no_char_waiting

; Read the waiting char.
	move.w	#7,-(sp)
	trap	#1
	addq	#2,sp

	cmpi.b	#27,d0				; escape
	beq	exitMenu
	ori.b	#$20,d0
	cmpi.b	#'a',d0
	beq.s	.a_key
	cmpi.b	#'b',d0
	beq.s	.b_key
	cmpi.b	#'c',d0
	beq.s	.c

.no_char_waiting:
	move.l	$04BA.w,d0
	sub.l	starttime,d0
	cmpi.l	#400,d0
	blt.s	.end_menu_event
	tst.w	.logo_shown(pc)
	bne.s	.end_logo_stuff
	st	.logo_shown
	movea.l	Menu.table+4*3,a1
	jsr	(a1)
	bra.s	.end_menu_event
.end_logo_stuff:
	cmpi.l	#600,d0
	blt.s	.end_menu_event
	tst.w	.options_shown(pc)
	bne.s	.end_options_stuff
	st	.options_shown
	movea.l	Menu.table+4*5,a1
	jsr	(a1)
.end_options_stuff:
.end_menu_event:

	movea.l	Menu.table,a1
	jsr	(a1)
	addq.l	#1,frmcnt
	bra.w	.menu_loop

.a_key:	moveq	#0,d0
	bra.s	.blink_it
.b_key:	moveq	#1,d0
	bra.s	.blink_it
.c:	moveq	#2,d0
;	bra.s	.blink_it
.blink_it:
	move.w	d0,-(sp)
	bsr.l	Menu.setBlinking
	move.w	(sp)+,d0
	rts

.logo_shown:
	DC.W	0
.options_shown:
	DC.W	0

; Initializes all parts.
; OUTPUT:
; d0.l: =0: success, <0: error
initParts:
	lea	partTable,a0
	lea	partInfoTable,a2
	clr.w	numParts

.loop:	movea.l	(a0)+,a1
	tst.l	a1
	beq.s	.end
; a1: part's rout table
	movea.l	Part.INIT(a1),a1		; a1: part's init rout
	movem.l	a0/a2,-(sp)
	jsr	(a1)
	move.l	a0,d1
	move.l	a1,d2
	movem.l	(sp)+,a0/a2
	tst.l	d0
	bmi.s	.abort
	move.l	d1,(a2)+
	move.l	d2,(a2)+
	addq.w	#1,numParts
	bra.s	.loop

.end:	clr.l	d0
.abort:	rts

; Initializes a part's screens.
; INPUT:
; a0: part's screentable
; OUTPUT:
; d0.l: =0: success, <0: error
initScreens:
	addq	#4,a0				; a0: first object-pointer

; Count screens..
	movea.l	a0,a6
  	moveq	#-1,d0
.countloop:
	addq.w	#1,d0
	tst.l	(a6)+
	bne.s	.countloop

; If 0 screens in part, abort.
	tst.w	d0
	beq.s	.abort

; Initialize screens.
	clr.l	d0				; d0.w: screencounter

.loop:	;cmpi.b	#$39,$FFFFFC02.w
	;beq	.abort

	movea.l	(a0)+,a1			; a1: screen's rout-table
	tst.l	a1
	beq.s	.end
	move.l	4(a1),a1			; a1: screen's init-rout

	move.w	d0,-(sp)
	move.l	a0,-(sp)
	jsr	(a1)				; Execute to screen's initialization.
	move.l	d0,d1
	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	tst.l	d1				; Screen init failed?
	bmi.s	.abort

	addq.w	#1,d0				; Increase counter.
	bra.s	.loop

.end:	rts

.abort:	moveq	#-1,d0
	rts

; Counts a part's event-subroutines for every screen.
; INPUT:
; a0: part's screentable
; a1: dst. subevent count table
countSubFx:
	addq	#1,a1
	lea	4(a0),a2

.countloop:
	movea.l	(a2)+,a3
	tst.l	a3
	beq.s	.endcounting
	moveq	#-1,d1

.incountloop:
	addq.w	#1,d1
	tst.l	(a3)+
	bne.s	.incountloop

	move.b	d1,(a1)+
	bra.s	.countloop

.endcounting:
	rts

; Sets the demo to a specified part.
; INPUT:
; d0.w= part number
setPart:cmp.w	numParts,d0
	blt.s	.ok
	move.l	#showMenu,(sp)			; If last part done, return to menu.
	rts

.ok:	move.w	d0,partNum			; If it's a legal part, set it.

; Temporary blindness.
	move.l	#Darkness.table,actScreenAdr
	move.l	frmcnt,lastframecount

; Start the part.
	lea	partInfoTable,a0
	move.l	(a0,d0.w*8),actPartAdr
	move.l	4(a0,d0.w*8),subEffectTableAdr
	movea.l	(partTable,d0.w*4),a0
	movea.l	Part.START(a0),a0
	jsr	(a0)
	move.w	d0,screenCount
	bmi	return2tos
	rts

; Processes one new event from the eventlist.
; PRE:
; - subeffects_tbl contains number of routs for each fx.
; - screenCount = number of fx in table
handleDemoEvents:

.loop:
; Get command from modplayer..
	bsr.l	EarxPlay.getSyncInfo

	cmpi.b	#255,d0
	beq	.end				; no new command -> do nothing

	tst.b	d0
	beq.s	.next_part			; end command -> next part

	btst	#7,d0				; test intern indicator
	bne.s	.intern

; Activate new effect.
	movea.l	actPartAdr,a1
	andi.w	#$007F,d0
	cmp.w	screenCount,d0
	bgt	.end				; fx-index >= #fx, error
	move.w	d0,actScreenNum			; Set fx-number.
	move.l	(a1,d0.w*4),actScreenAdr	; Set new fx-base.
	move.l	frmcnt,lastframecount		; Store time of this fx-change.

	bra.s	.loop

; Call a routine in the current effect.
.intern:andi.w	#$007F,d0			; Mask out indicator, d0.w=fx index
	movea.l	subEffectTableAdr,a2
	move.w	actScreenNum,d1
	move.b	(a2,d1.w),d1			; d1.w=#fx-routs
	cmp.w	d1,d0
	bge.s	.end				; fx-rout-index >= #fx-routs, error
	movea.l	actScreenAdr,a0
	movea.l	(a0,d0.w*4),a0
	jsr	(a0)				; Call fx-subroutine.

	bra.s	.loop

; Start the next part, if any.
; pre: a part is running.
.next_part:
	move.w	partNum,d0
	addq.w	#1,d0
	bsr.w	setPart

.end:	rts

; INPUT:
; a0: filename
playMod:
; fopen
	clr.w	-(sp)
	move.l	a0,-(sp)
	move.w	#$3D,-(sp)
	trap	#1
	addq	#8,sp

	tst.l	d0
	blt.s	.fin				; d0.w=handle
	move.l	d0,d6

; fread
	pea	mod
	move.l	#-1,-(sp)
	move.w	d6,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	lea	12(sp),sp

; fclose
	move.w	d6,-(sp)
	move.w	#$3E,-(sp)
	trap	#1
	addq	#4,sp

; Decrunch the file using atomik. If not packed nothing happens.
	lea	mod,a0
	bsr.l	depack

	IFEQ	testmode
	lea	mod,a0
	bsr.l	EarxPlay.play
	ENDC

.fin:	rts					; d0.l=resultcode

;======= INTERRUPTS ========

NEWVBL:	addq.l	#1,$0466.w
	movem.l	d0-a6,-(sp)
	bsr.l	Screen.update
	move.l	vbl_gfx(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_gfx:DC.L	rts

rts:	rts

;======= DATA + INCBINS ========

	DATA

selector_txt:
	DC.B	27,72
	DC.B	"........................................",$a,$d
	DC.B	"|                                      |",$a,$d
	DC.B	"|      . .   //\                       |",$a,$d
	DC.B	"|           //  \                      |",$a,$d
	DC.B	"|        . //    \                     |",$a,$d
	DC.B	"|    .  . //______\..e..l..t..a.. .    |",$a,$d
	DC.B	"|                                      |",$a,$d
	DC.B	"|   ..b..y.....l..i..n..e..o..u..t..   |",$a,$d
	DC.B	"|                                      |",$a,$d
	DC.B	"|   1.rgb50 2.vga100 3.vga60 esc.exit  |",$a,$d
	DC.B	"|                                      |",$a,$d
	DC.B	"|               d.detail               |",$a,$d	; 19,11, len=6
	DC.B	"|                                      |",$a,$d
	DC.B	"!.............[          ].............!",$a,$d
	DC.B	0
	EVEN

;======= RESERVES ========

	BSS

; Init-data
	DS.L	256
ustk:	DS.L	1
oldsp:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1
old484:	DS.W	1
old468:	DS.W	1
fvbuf:	DS.W	24

sine_tbl:
	DS.L	sintbllen

; Stats shit
monitormode:
	DS.W	1
detail:	DS.W	1

; Object handling
numParts:
	DS.W	1					; #parts in demo
partNum:DS.W	1					; current part
screenCount:
	DS.W	1					; #screens in current part
actScreenNum:
	DS.W	1					; selected screen
actScreenAdr:
	DS.L	1					; Points to current screen.
actPartAdr:
	DS.L	1					; Points to current part.
subEffectTableAdr:
	DS.L	1					; Points to current part's sub-effect counttable
partInfoTable:
	DS.L	2*3					; 3 parts (screentbl ptr, counttable ptr)

; Counter and timer shit
frmcnt:	DS.L	1					; #frames animated
lastframecount:
	DS.L	1					; #frames animated when current screen started
starttime:
	DS.L	1

; Key vars.
keycode:DS.W	1

; Scr-stuff
scr:	DS.L	3

mod:	DS.B	530000					; max(mod1,mod2,mod3)