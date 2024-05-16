*                        //----------<<==>>----------\\
*                       //:        demosys 2.0       :\\
*                       \\:    07-08-2001 by earx    ://
*                        \\----------<<==>>----------//
*
*                                falcon030 only

******** GLOBAL EQUATES ********

MOD_ON:		=	1

testmode:	=	0			* debug mode
demoos:		=	1			* Indicates demo-os is active
triggermode:	=	1			* 0=manual effect-trigger, 1=event-table trigger

MAX_SCREENSIZE:	=	320*200*2

* monitormode-equates
autodetect:	=	0
rgb50:		=	1			* RGB/TV, 50Hz
vga60:		=	2			* VGA, 60, noniterlaced
vga100:		=	3			* VGA, 100Hz, interlaced
* monitormode selector ( =autodetect ) or force mode ( >0 )
monitorequ:	=	autodetect

longeven:	MACRO
		IFGT	*&3
		DS.B	4-(*&3)
		ENDC
		ENDM

******** ASM OPTIONS AND PATHS ********

	COMMENT	HEAD=%111
	IFEQ	testmode
	OPT	D-
	ENDC

******** INCLUDES ********

	bra	START

	IFEQ	testmode
	INCLUDE	FSCR.I
	TEXT
	ENDC
	INCLUDE	FIMATH.I
	TEXT
	INCLUDE	EXAPLAY.I

******** INITIALISING ********

START:	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

* mxalloc - Reserve stram ONLY for screens.
	move.w	#0,-(sp)
	move.l	#MAX_SCREENSIZE*4+256,-(sp)	* size of screens..
	move.w	#$44,-(sp)
	trap	#1
	addq	#8,sp
	tst.l	d0				* Check if there is ST-RAM enough.
	bgt.s	.ramok
* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1

* Initialize screenaddresses..
.ramok	lea	scr,a0
	addi.l	#15,d0				* / long even
	andi.b	#%11110000,d0			* \ address..
	move.l	d0,(a0)+
	addi.l	#MAX_SCREENSIZE,d0
	move.l	d0,(a0)+
	addi.l	#MAX_SCREENSIZE,d0
	move.l	d0,(a0)+
	addi.l	#MAX_SCREENSIZE,d0
	move.l	d0,(a0)+

	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	bsr	GET_SETTINGS
; TODO: we have to wait till a key is released, but how??
	tst.w	d0
	bmi	E_EXIT
	ENDC

* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,oldsp
	move.l	#ustk,sp			* Install own stack..

* Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr

* Falcon check..
	move.l	$5a0.w,a0
	tst.l	a0
	beq	E_EXIT
.fndmch	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found	cmpi.w	#3,4(a0)
	bne	E_EXIT

	IFEQ	testmode

* Wait for keyboard to end last packet.

	move.b	$0484.w,old484
	clr.b	$0484.w
* Save falcon-pallette..
	bsr.l	SAVE_FALCPAL
* Save resolution..
	bsr.l	SAVE_FV
* Install own vbl-routine..
	move	#$2700,sr
	move.l	$0070.w,oldvbl
	move.l	#NEWVBL,$70.w
	move	#$2300,sr
	ENDC					* IFEQ testmode

	bsr.l	INIT_DEMOPARTS

; Initialize mod-player.
	bsr.l	ExaPlay.init
	IFNE	MOD_ON
	lea	module,a0
	move.l	#ExaPlay.bin+ExaPlay.MIX,vbl_msx
	bsr.l	ExaPlay.play
	tst.w	d0
	bmi	OUT
	ENDC

	clr.l	d0
	move.l	d0,frmcnt
	move.l	d0,lastframecount

	bsr.l	COUNT_FXSUBROUTS

	IFNE	triggermode

	move.l	$4ba.w,starttime

mainloopcycle:
	move.b	$FFFFFC02.w,keycode

	cmpi.b	#$39,keycode
	beq	OUT
	movea.l	actpartadr,a0
	tst.l	a0
	beq.s	.do
	movea.l	(a0),a1
	jsr	(a1)
.do:	addq.l	#1,frmcnt
	bsr.l	DO_DEMOEVENTS
	bra.s	mainloopcycle

	ELSE

triggerloopcycle:
	move.b	$FFFFFC02.w,keycode

	addq.l	#1,frmcnt
	addq.w	#1,.cyclecount
	moveq	#0,d0
	move.b	keycode,d0
	cmp.w	.oldkey(pc),d0
	seq.b	d1
	move.w	d0,.oldkey
	cmpi.b	#$39,d0
	beq	OUT
	cmpi.w	#.subeffects-.key2object_tbl,d0
	bhs.s	.do_subeffect
	move.b	(.key2object_tbl.w,pc,d0.l),d0
	beq.s	.do_old
	cmp.w	objectcount,d0
	bhi.s	.do_old
	lea	eventpart_tbl,a0
	movea.l	(a0,d0.l*4),a0
	cmpa.l	actpartadr,a0
	beq.s	.do_old
	move.l	frmcnt,lastframecount
	move.w	d0,.actpart			* / Kick in new
	move.l	a0,actpartadr			* \ object.
.do_old:
	movea.l	actpartadr,a0
	tst.l	a0
	beq.s	triggerloopcycle
	movea.l	(a0),a0
	jsr	(a0)				* Jump to fx-mainloop.
	bra.s	triggerloopcycle
.do_subeffect:
	move.b	(.key2object_tbl.w,pc,d0.l),d0
	beq.s	.do_old
	move.b	d1,d1
	bne.s	.do_old
	movea.l	actpartadr,a0
	tst.l	a0
	beq	triggerloopcycle
	move.w	.actpart(pc),d1
	cmp.b	(subeffect_tbl,d1.w),d0
	bhs.s	.do_old
	movea.l	8(a0,d0.l*4),a0
	jsr	(a0)
	bra.s	.do_old

.actpart:
	DC.W	0
.oldkey:
	DC.W	0
.cyclecount:
	DC.W	0

.key2object_tbl:
	DC.B	0,0
	DC.B	$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c
	DC.B	0,0,0
	DC.B	$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b
	DC.B	0,0
	DC.B	$1e,$1f,$20,$21,$22,$23,$24,$25,$26,$27,$28
	DC.B	0,0,0
	DC.B	$2c,$2d,$2e,$2f,$30,$31,$32,$33,$34,$35
	DS.B	19
.subeffects:
	DC.B	8				* numpad "-": $4a
	DS.B	3
	DC.B	12				* numpad "+": $4e
	DS.B	$14
	DC.B	1				* numpad "(": $63
	DC.B	2				* numpad ")": $64
	DC.B	3				* numpad "/": $65
	DC.B	4				* numpad "*": $66
	DC.B	5				* numpad "7": $67
	DC.B	6				* numpad "8": $68
	DC.B	7				* numpad "9": $69
	DC.B	9				* numpad "4": $6a
	DC.B	10				* numpad "5": $6b
	DC.B	11				* numpad "6": $6c
	DC.B	13				* numpad "1": $6d
	DC.B	14				* numpad "2": $6e
	DC.B	15				* numpad "3": $6f
	DC.B	16				* numpad "0": $70
	DC.B	17				* numpad ".": $71
	DC.B	18				* numpad "ENTER": $72
	DS.B	$8e
	EVEN

	ENDC

******** PART CODE ********

FRACTAL_CODE:	=	1<<8
ROTOZOOM_CODE:	=	2<<8
XZOOM_CODE:	=	3<<8

eventpart_tbl:
	DC.L	0				; dummy (needed!)
	DC.L	Fractal.table
	DC.L	RotoZoomer.table
	DC.L	XZoom.table
	DC.L	Greets.table
	DC.L	0

* Included effect-objects:
	INCLUDE	FRACTAL.SO
	TEXT
	INCLUDE	ROTOZOOM.SO
	TEXT
	INCLUDE	XZOOM.SO
	TEXT
	INCLUDE	GREETSLO.SO
	TEXT

******** EXITTING CODE ********

OUT:
	IFEQ	testmode

	IFNE	MOD_ON
	move.l	#rts,vbl_msx
	bsr.l	ExaPlay.stop
	ENDC

	lea	save_fv,a0
	bsr.l	CHANGE_FVFAST
	bsr.l	RESTORE_FALCPAL

	move.w	sr,d0
	move.w	#$2700,sr
	move.l	oldvbl,$70.w
	move.w	d0,sr

	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	move.b	old484,$0484.w

	ENDC					* IFEQ testmode

E_EXIT:	clr.w	-(sp)
	trap	#1

******** DEMO-OS SUBROUTINES ********

flushIkbd:
.flush_more:
	btst.b	#0,$fffffc00.w		; ! Keyboard flush ...
	bne.s	.flush_more
	rts

clearKeyboard:
.again:	move.w	#2,-(sp)				;bconstat()
	move.w	#1,-(sp)
	trap	#13
	addq	#4,sp
	tst.w	d0
	beq.s	.ok
	move.w	#2,-(sp)				;bconin()
	move.w	#2,-(sp)
	trap	#13
	addq	#4,sp
	bra.s	.again
.ok:	rts

		RSRESET
Option.XPOS:	RS.B	1
Option.YPOS:	RS.B	1
Option.CHAR:	RS.B	1

Keycode.ESCAPE:	=	27		; escape
Keycode.RGB_50:	=	"1"
Keycode.VGA_100:=	"2"
Keycode.VGA_60:	=	"3"

; OUTPUT:
; d0.w:	0=Run demo, -1=Exit demo
GET_SETTINGS:
	bsr	paintSelector

.repaint:

; Read a key from the console into d0.
.get_newkey:
	move.w	#8,-(sp)
	trap	#1
	addq	#2,sp
* d0.b: result keycode

	cmpi.b	#Keycode.ESCAPE,d0
	beq.s	.exit
	cmpi.b	#Keycode.RGB_50,d0
	beq.s	.set_rgb50
	cmpi.b	#Keycode.VGA_100,d0
	beq.s	.set_vga100
	cmpi.b	#Keycode.VGA_60,d0
	beq.s	.set_vga60
	bra.s	.get_newkey

.set_rgb50:
	move.w	#rgb50,monitormode
	bra.s	.proceed
.set_vga100:
	move.w	#vga100,monitormode
	bra.s	.proceed
.set_vga60:
	move.w	#vga60,monitormode

.proceed:
	moveq	#0,d0
	rts
.exit:	moveq	#-1,d0
	rts

paintSelector:
	pea	selector_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp
	rts

INIT_DEMOPARTS:
	lea	Demo.palette,a1
	lea	Demo.strPal,a0
	move.l	#60<<16/320,d0
	clr.l	d1
	move.w	#320-1,d7
.stretch_loop:
	move.l	d1,d2
	swap	d2
	move.w	(a1,d2.w*2),(a0)+
	add.l	d0,d1
	dbra	d7,.stretch_loop

	IFEQ	testmode

	move.w	$0468.w,d0
.ck466:	cmp.w	$0468.w,d0
	beq.s	.ck466
	move.w	monitormode,d0
	cmpi.w	#vga60,d0
	beq.s	.vga60
	cmpi.w	#vga100,d0
	beq.s	.vga100
	cmpi.w	#rgb50,d0
	beq.s	.rgb50
* Unknown monitormode..
	bra	.endresset
.vga60:	bsr.l	vga60_16bit_320_200
	bra.s	.endresset
.vga100:
	bsr.l	vga100_16bit_320_200
	bra.s	.endresset
.rgb50:	bsr.l	rgb50_16bit_320_200
.endresset:

* Kick in new screen..
	move.l	scr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

* Make pallette black..
	moveq	#256/2-1,d7
	moveq	#0,d0
	lea	$ffff9800.w,a0
.clearloop:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d7,.clearloop

	ENDC

; Paint background..
	movea.l	scr,a0
	move.w	#320*200/20-1,d7
	clr.l	d0
.backloop:
	REPT	10
	move.l	d0,(a0)+
	ENDR
	dbra	d7,.backloop

	lea	eventpart_tbl,a0		; a0: address of part-table
	addq	#4,a0				; a0: address of first object-pointer

	movea.l	a0,a6
	moveq	#-1,d0
.countloop:
	addq.w	#1,d0
	tst.l	(a6)+
	bne.s	.countloop
	move.w	d0,objectcount
	beq	.rts

	move.l	#320<<7,d1
	divu.w	d0,d1
	move.w	d1,.barwidth

	moveq	#0,d0				* d0.w: objectcounter

	move.w	$468.w,.old468

	move.l	#.vbl,vbl_gfx

.loop:	cmpi.b	#$39,keycode
	beq	OUT

	movea.l	(a0)+,a1
	tst.l	a1
	beq.s	.rts
	move.l	4(a1),a1
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	jsr	(a1)				* Jump to init-subroutine.

	move.l	.progress(pc),d0
	moveq	#0,d1
	move.w	.barwidth(pc),d1
	add.l	d1,d0
	move.l	d0,.progress

	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	addq.w	#1,d0
	bra	.loop
.rts:

	IFEQ	testmode

.wait:	move.l	.old_progress(pc),d1
	cmp.l	.progress(pc),d1
	blt.s	.wait

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)

	move.w	.old468(pc),d1
.waitvbl:
	cmp.w	$0468.w,d1
	beq.s	.waitvbl
	move.l	#rts,vbl_gfx

	ENDC

	rts


.vbl:	move.l	.old_progress(pc),d0
	cmp.l	.progress(pc),d0
	bge.s	.end_vbl

	movea.l	scr,a0
	adda.l	#320*2*99,a0
	lea	Demo.strPal,a1
	move.l	d0,d1
	lsr.l	#7,d1
	lea	(a0,d1.l*2),a0
	move.l	(a1,d1.l*2),(a0)
	move.l	(a1,d1.l*2),(320*2.w,a0)
	move.l	(a1,d1.l*2),(320*2*2.w,a0)
	addi.l	#$00000100,d0
	move.l	d0,.old_progress
	
.end_vbl:
	rts

.old468:
	DC.W	0
.progress:
	DC.L	0
.old_progress:
	DC.L	0
.barwidth:
	DC.W	0

; Processes one new event from the eventlist.
; PRE:
; - subeffects_tbl contains number of routs for each fx.
; - objectcount = number of fx in table
DO_DEMOEVENTS:

.loop:
; Get command from modplayer..
	bsr.l	ExaPlay.bin+ExaPlay.GET_SYNC

	cmpi.b	#255,d0
	beq.s	.end				; no new command -> do nothing

	tst.b	d0
	beq	OUT				; end command -> exit

	btst	#7,d0				; test intern indicator
	bne.s	.intern

; Activate new effect.
	lea	eventpart_tbl,a1
	andi.w	#$007F,d0
	cmp.w	objectcount,d0
	bgt.s	.end				; fx-index >= #fx, error
	move.w	d0,actpartnum			; set fx-number
	move.l	(a1,d0.w*4),actpartadr		; set new fx-base
	move.l	frmcnt,lastframecount		; Store time of this fx-change.

	bra.s	.loop

; Call a routine in the current effect.
.intern:andi.w	#$007F,d0			; mask out indicator, d0.w=fx index
	lea	subeffect_tbl,a2
	move.w	actpartnum,d1
	move.b	(a2,d1.w),d1			; d1.w=#fx-routs
	cmp.w	d1,d0
	bge.s	.end				; fx-rout-index >= #fx-routs, error
	movea.l	actpartadr,a0
	movea.l	(a0,d0.w*4),a0
	jsr	(a0)				; call fx-subroutine

	bra.s	.loop

.end:	rts

; Counts subroutines for every effect.
COUNT_FXSUBROUTS:
	lea	subeffect_tbl+1,a1
	lea	eventpart_tbl+4,a2
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

******** INTERRUPTS ********

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	move.l	vbl_gfx(pc),a0
	jsr	(a0)
	move.l	vbl_msx(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_gfx:
	DC.L	rts
vbl_msx:
	DC.L	rts

rts:	rts

******** DATA + INCBINS ********

	DATA

sine_tbl:
	INCBIN	SINUS.DAT

Demo.palette:
	dc.w	$07fc,$07f9,$07f6,$07f3,$07f0,$07ed,$07ea,$07e7,$07e4,$07e1
	dc.w	$1fe0,$37e0,$4fe0,$67e0,$7fe0,$97e0,$afe0,$c7e0,$dfe0,$f7e0
	dc.w	$ff20,$fe60,$fda0,$fce0,$fc20,$fb60,$faa0,$f9e0,$f920,$f860
	dc.w	$f803,$f806,$f809,$f80c,$f80f,$f812,$f815,$f818,$f81b,$f81e
	dc.w	$e01f,$c81f,$b01f,$981f,$801f,$681f,$501f,$381f,$201f,$081f
	dc.w	$00df,$019f,$025f,$031f,$03df,$049f,$055f,$061f,$06df,$079f

selector_txt:
	DC.B	27,72
	DC.B	"          select videomode:",$0A,$0D
	DC.B	"1: rgb50 2: vga100 3: vga60 esc: exit",$0A,$0D
	DC.B	0

	EVEN

module:	INCBIN	FUNNY2.RSP
	DS.B	100000

	EVEN

******** RESERVES ********

	BSS

	EVEN

* Init-data
	DS.L	256
ustk:	DS.L	1
oldsp:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1
old484:	DS.W	1
fvbuf:	DS.W	24

* Stats shit
monitormode:
	DS.W	1

* Waitscreen stuff.
Demo.strPal:
	DS.W	320

* Object handling
objectcount:
	DS.W	1
actpartnum:
	DS.W	1
subeffect_tbl:
	DS.B	128
actpartadr:
	DS.L	1

* Counter and timer shit
frmcnt:	DS.L	1
lastframecount:
	DS.L	1
starttime:
	DS.L	1

* Key vars.
keycode:DS.W	1

* Scr-stuff
scr:	DS.L	4
