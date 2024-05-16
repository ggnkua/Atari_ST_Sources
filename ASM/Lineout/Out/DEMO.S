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
MANUAL_CONTROL:	=	0			; 1=manual effect-trigger, 0=auto (music) trigger
testmode:	=	0			; debug mode
MOD_FROM_FILE:	=	0			; 1= from file, 0=incbinned

MAX_SCREENSIZE:	=	320*200*2

; monitormode-equates
autodetect:	=	0
rgb50:		=	1			; RGB/TV, 50Hz
vga60:		=	2			; VGA, 60, noninterlaced
vga100:		=	3			; VGA, 100Hz, interlaced
; monitormode selector ( =autodetect ) or force mode ( >0 )
monitorequ:	=	autodetect

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
	INCLUDE	FSCR2.I
	TEXT
	INCLUDE	DSP_FIX.S
	TEXT
;	INCLUDE	DSP.I
	INCLUDE	EARXPLAO.S
	TEXT
	INCLUDE	SFLY_DSP.S			; Include the CPU-DSP engine.
	TEXT
	INCLUDE	OBJECT3D.I
	TEXT
	INCLUDE	TEXTURE.I
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
	bsr.l	Mem.init

; Initialize all screens..
	bsr.l	countSubFx
	bsr.l	initScreens
	tst.l	d0
	bmi.l	exit
	move.w	d0,screenCount

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

	bsr	setVoid
	ENDC					; IFEQ testmode

	IFEQ	testmode
	IFNE	MOD_FROM_FILE
	lea	modname_txt,a0
	bsr	playMod
	ELSE
	lea	mod,a0
	bsr.l	EarxPlay.play
	ENDC
	ENDC
	move.w	#0,EarxPlay.position

; Reset framecounters.
	clr.l	d0
	move.l	d0,frmcnt
	move.l	d0,lastframecount

	IFNE	MANUAL_CONTROL

; manual
triggerloopcycle:
	clr.l	d0
	move.b	$FFFFFC02.w,d0
	cmp.w	.oldkey(pc),d0
	seq	.isold
	move.w	d0,.oldkey
	cmpi.b	#$39,d0
	beq.l	return2tos
	cmpi.w	#.subeffects-.key2object_tbl,d0
	bhs.s	.do_subeffect
	move.b	(.key2object_tbl.w,pc,d0.l),d0
	beq.s	.do_old
	cmp.w	screenCount,d0
	bhi.s	.do_old
	lea	screenTable,a0
	movea.l	(a0,d0.l*4),a0
	cmpa.l	actScreenAdr,a0
	beq.s	.do_old

; Kick in new object..
	move.l	frmcnt,lastframecount
	move.w	d0,.actpart
	movea.l	actScreenAdr,a1				; a1: old fx
	move.l	a0,actScreenAdr				; Set new fx.

; Deinitialise old fx.
	tst.l	a1
	beq.s	.deinit_done
	movea.l	12(a1),a1
	jsr	(a1)
.deinit_done:

; Initialise new fx.
	bsr	setTime					; Reset running time for new screen.
	movea.l	actScreenAdr,a0				; a0: new fx
	movea.l	8(a0),a0
	jsr	(a0)					; Perform runtime initialisation.

.do_old:movea.l	actScreenAdr,a0
	tst.l	a0
	beq	triggerloopcycle
	movea.l	(a0),a0
	jsr	(a0)					; Jump to fx-mainloop.
	addq.l	#1,frmcnt
	bra	triggerloopcycle

.do_subeffect:
	move.b	(.key2object_tbl.w,pc,d0.l),d0
	beq.s	.do_old
	tst.b	.isold(pc)
	bne.s	.do_old
	movea.l	actScreenAdr,a0
	tst.l	a0
	beq	triggerloopcycle
	move.w	.actpart(pc),d1
	cmp.b	(subEffectTable,d1.w),d0
	bhi.s	.do_old
	movea.l	12(a0,d0.l*4),a0
	jsr	(a0)
	bra.s	.do_old

.actpart:
	DC.W	0
.oldkey:DC.W	0
.isold:	DC.W	0

.key2object_tbl:
	DC.B	0,0
	DC.B	$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c
	DC.B	0,0
	DC.B	$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18
	DC.B	0,0,0
	DC.B	$19,$1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23
	DC.B	0,0,0
	DC.B	$24,$25,$26,$27,$28,$29,$2a,$2b,$2d,$2e
	DS.B	19
.subeffects:
	DC.B	8				; numpad "-": $4a
	DS.B	3
	DC.B	12				; numpad "+": $4e
	DS.B	$14
	DC.B	1				; numpad "(": $63
	DC.B	2				; numpad ")": $64
	DC.B	3				; numpad "/": $65
	DC.B	4				; numpad "*": $66
	DC.B	5				; numpad "7": $67
	DC.B	6				; numpad "8": $68
	DC.B	7				; numpad "9": $69
	DC.B	9				; numpad "4": $6a
	DC.B	10				; numpad "5": $6b
	DC.B	11				; numpad "6": $6c
	DC.B	13				; numpad "1": $6d
	DC.B	14				; numpad "2": $6e
	DC.B	15				; numpad "3": $6f
	DC.B	16				; numpad "0": $70
	DC.B	17				; numpad ".": $71
	DC.B	18				; numpad "ENTER": $72
	DS.B	$8e
	EVEN

	ELSE

mainloop:
	cmpi.b	#$39,$FFFFFC02.w
	beq.l	return2tos

	movea.l	actScreenAdr,a0
	tst.l	a0
	beq.s	.do
	movea.l	(a0),a1
	jsr	(a1)
.do:	addq.l	#1,frmcnt
	bsr.l	handleDemoEvents
	bra.s	mainloop

	ENDC

;======= SCREENS ========

	INCLUDE	KALEIDO.SO
	TEXT
	INCLUDE	DSPBILIN.SO
	TEXT
	INCLUDE	DSPRAD.SO
	TEXT
	INCLUDE	CONTOURD.SO	NOFADE_T.SO
	TEXT
	INCLUDE	GRIDSPEC.SO
	TEXT
;	INCLUDE	POSTER.SO
;	TEXT
;	INCLUDE	FLIES.SO
;	TEXT
	INCLUDE	FAST.SO
	TEXT
	INCLUDE	SPIRAL4.SO
	TEXT
	INCLUDE	SHOWPIC.SO
	TEXT

;======= EXITTING CODE ========

return2tos:
	IFEQ	testmode

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

setTime:move.l	$04BA.w,startTime
	rts

getTime:move.l	$04BA.w,d0
	sub.l	startTime,d0
	rts

setVoid:
; End pre-set resolution. (required for vga100 on some monitors).
	move.w	monitormode,d0
	cmpi.w	#vga100,d0
	bne.s	.check_rgb50
	bsr.l	vga100_8bit_320_200
	bra.s	.end_vset
.check_rgb50:
	cmpi.w	#rgb50,d0
	bne.s	.check_vga60
	bsr.l	rgb50_8bit_320_200
	bra.s	.end_vset
.check_vga60:
	cmpi.w	#vga60,d0
	bne.s	.end_vset
	bsr.l	vga60_8bit_320_200
;	bra.s	.end_vset
.end_vset:
; Black out palette..
	lea	$FFFF9800.w,a0
	clr.l	d0
	clr.b	d1
.loop:	move.l	d0,(a0)+
	addq.b	#1,d1
	bne.s	.loop
	rts

		RSRESET
Option.XPOS:	RS.B	1
Option.YPOS:	RS.B	1
Option.CHAR:	RS.B	1

Keycode.ESCAPE:	=	27		; escape
Keycode.RGB_50:	=	"1"
Keycode.VGA_100:=	"2"
Keycode.VGA_60:	=	"3"
Keycode.LOAD:	=	"l"

; OUTPUT:
; d0.w:	0=Run demo, -1=Exit demo
getSettings:
	bsr	paintSelector

.repaint:
	tst.w	detail
	bne	.heavy
	pea	.light_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	bra.s	.end_detail
.heavy:	pea	.heavy_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
.end_detail:

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
	cmpi.b	#Keycode.LOAD,d0
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

.light_txt:
	DC.B	27,89,32+3,32+23,"X"
	DC.B	27,89,32+4,32+23," "
	DC.B	27,89,32+10,32+0
	DC.B	0
.heavy_txt:
	DC.B	27,89,32+3,32+23," "
	DC.B	27,89,32+4,32+23,"X"
	DC.B	27,89,32+10,32+0
	DC.B	0

paintSelector:
	pea	selector_txt
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

; Initializes a part's screens.
; OUTPUT:
; d0.l: =0: success, <0: error
initScreens:
	lea	screenTable+4,a0		; a0: first object-pointer

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
countSubFx:
	lea	screenTable+4,a0
	lea	subEffectTable+1,a1

.countloop:
	movea.l	(a0)+,a3
	tst.l	a3
	beq.s	.endcounting
	adda.w	#16,a3				; Skip private subrouts!
	moveq	#-1,d1

.incountloop:
	addq.w	#1,d1
	tst.l	(a3)+
	bne.s	.incountloop

	move.b	d1,(a1)+
	bra.s	.countloop

.endcounting:
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
	beq	return2tos			; end command -> quit

	btst	#7,d0				; test intern indicator
	bne.s	.intern

; Activate new effect.
	lea	screenTable,a1
	andi.w	#$007F,d0
	cmp.w	screenCount,d0
	bgt.s	.end				; fx-index >= #fx, error
	move.w	d0,actScreenNum			; Set fx-number.
	move.l	(a1,d0.w*4),a0			; a0: fx-base
	move.l	a0,actScreenAdr			; Set new fx-base.
	move.l	frmcnt,lastframecount		; Store time of this fx-change.
	movea.l	actScreenAdr,a0			; a0: new fx
	movea.l	8(a0),a0
	jsr	(a0)				; Perform runtime initialisation.
	bsr	setTime				; Set start time for this fx.
	bra.s	.loop

; Call a routine in the current effect.
.intern:andi.w	#$007F,d0			; Mask out indicator, d0.w=fx index
	move.w	actScreenNum,d1
	cmp.b	(subEffectTable,d1.w),d0	; #fx-routs<subfx?
	bge.s	.end				; fx-rout-index >= #fx-routs, error
	movea.l	actScreenAdr,a0
	movea.l	16(a0,d0.w*4),a0
	jsr	(a0)				; Call fx-subroutine.

	bra.s	.loop

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

;; Decrunch the file using atomik. If not packed nothing happens.
;	lea	mod,a0
;	bsr.l	depack

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

screenTable:
	DC.L	0				; dummy (required)
	DC.L	Grid.table			; 01
	DC.L	Bilerp.table			; 02
	DC.L	XFade.table			; 03
	DC.L	Kaleido.table			; 04
	DC.L	Spiral.table			; 05
	DC.L	Fast.table			; 06
	DC.L	Radial.table			; 07
	DC.L	Showpic.table			; 08
	DC.L	0				; terminator (required)

	IFEQ	MOD_FROM_FILE
mod:	;INCBIN	BBS-IN~1.MOD
	INCBIN	EVENTS.MOD
	ENDC

modname_txt:
	DC.B	"EVENTS.MOD",0

selector_txt:
	DC.B	27,72
	DC.B	"|-[ OUT ]----------------------|",$a,$d
	DC.B	"|------------------------------|",$a,$d
	DC.B	"|                              |",$a,$d
	DC.B	"| 1    rgb50    load: [X]light |",$a,$d
	DC.B	"| 2    vga100   -     [ ]heavy |",$a,$d
	DC.B	"| 3    vga60                   |",$a,$d
	DC.B	"| esc  exit                    |",$a,$d
	DC.B	"|                              |",$a,$d
	DC.B	"|------------------------------|",$a,$d
	DC.B	"|___________[ lineout 2003/4 ]_|",$a,$d
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
subEffectTable:
	DS.B	128					; sub-effect counttable
partInfoTable:
	DS.L	2*3					; 3 parts (screentbl ptr, counttable ptr)

; Counter and timer shit
frmcnt:	DS.L	1					; #frames animated
lastframecount:
	DS.L	1					; #frames animated when current screen started
startTime:
	DS.L	1

; Key vars.
keycode:DS.W	1

; Scr-stuff
resRout:DS.L	1
scr:	DS.L	3

	IFNE	MOD_FROM_FILE
mod:	ds.b	512*1024				; Make sure the module is not bigger than this!
	ENDC

empty:	ds.b	64000					; lameness!
