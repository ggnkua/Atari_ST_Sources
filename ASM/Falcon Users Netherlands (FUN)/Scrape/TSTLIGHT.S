;                      [=/\===/\===/\===/\===/\===/\=]
;                     /:   fx tester skeleton v3.0   :\
;                     \:     (c) earx 05-01-2003     :/
;                      [=\/===\/===\/===\/===\/===\/=]

;= global constants ========================================================

objectmode:	=	0			; demo-os inclusion mode (dummy)
* monitormode-equ's
autodetect:	=	0
rgb50:		=	1			; RGB/TV, 50Hz
vga100:		=	2			; VGA, 100Hz, interlaced
vga60:		=	3			; VGA, 60Hz, noninterlaced
* screendimension-equ's
scrxbytes:	=	640			; number of bytes per scanline
scrlines:	=	200			; number of scanlines
maxscrsize:	=	scrxbytes*scrlines	; max. size of screen

monitorequ:	=	autodetect		; current monitormode

		RSRESET
Fx.MAINLOOP:	RS.L	1
Fx.INIT:	RS.L	1
Fx.INIT_RT:	RS.L	1
Fx.DEINIT_RT:	RS.L	1
Fx.SIZE:	RS.B	0

;= asm options =============================================================

	COMMENT	HEAD=%111
	IFEQ	testmode
	OPT	P=68030
	OPT	D-
	ENDC

;= libraries ===============================================================

	bra	START

;	INCLUDE	SYS.I
;	TEXT
;	INCLUDE	MEM.I
;	TEXT
	INCLUDE	SCRLIGHT.I
	TEXT
	INCLUDE	MTHLIGHT.I
	TEXT
;	INCLUDE	DSP_FIX.S
;	TEXT

;= initialisation code =====================================================

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
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

* mxalloc - Reserve stram ONLY for screens.
	clr.w	-(sp)				* ST-RAM only!
	move.l	#maxscrsize*4+256,-(sp)		* size of screens..
	move.w	#$44,-(sp)			* Code $44: Mxalloc()
	trap	#1
	addq	#8,sp
	tst.l	d0				* Check if there is ST-RAM enough.
	bgt.s	.ramok
* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1

* Initialize screenaddresses..
.ramok:	lea	scr,a0
	move.l	#maxscrsize,d1
	addq.l	#3,d0				* / long even
	andi.b	#%11111100,d0			* \ address..
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+

* Check if the demo-object table has all necessary entries..
	movea.l	fxAdr,a0
	moveq	#Fx.SIZE/4-1,d7
.chklp:	tst.l	(a0)+
	beq.l	EXIT				* On premature NULL > go out!
	dbra	d7,.chklp

; Calculate sine table.
	lea	sine_tbl,a0
	Init_SineTable

; Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	#ustk,sp			* Install own stack..

	IFEQ	testmode

* Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr

* Falcon check..
	movea.l	$05A0.w,a0
	tst.l	a0
	beq.l	EXIT
.fndmch:
	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found:	cmpi.w	#3,4(a0)
	bne.l	EXIT

; it's a falcon allright..
	move.l	$05A0.w,a0
.fndcpu:cmpi.l	#"_CPU",(a0)
	addq	#8,a0
	bne.s	.cpu_initialised
	cmpi.w	#40,-2(a0)
	blt.s	.its_a_030

; disable 040/060 caches!
	st	ct60
	ifd	SLOW_CT60
	clr.w	-(sp)
	move.w	#5,-(sp)
	move.w	#160,-(sp)
	trap	#14
	addq	#6,sp
	endc
.its_a_030:

.cpu_initialised:

; Set monitormode..
	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	move.w	$FFFF8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	beq.l	EXIT				* Arg! mono monitor!
	btst	#0,d0
	beq.s	.vga
	move.w	#rgb50,monitormode
	bra.s	.endmonitorcheck
.vga:	move.w	#vga100,monitormode
	;move.w	#vga60,monitormode
.endmonitorcheck:
	ENDC

; Install own vbl-routine..
.installvbl:
	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w
; Save falcon-pallette..
	bsr	SAVE_FALCPAL
; Save resolution..
	bsr	SAVE_FV

	ENDC

; Init libs.
;	bsr	System.init
;	bsr	Mem.init

; Initialize fx.
	movea.l	fxAdr,a0
	movea.l	Fx.INIT(a0),a0
	jsr	(a0)
	tst.l	d0
	bmi.l	EXIT

;	bsr	Mem.take

	movea.l	fxAdr,a0
	adda.w	#Fx.DEINIT_RT,a0
	moveq	#-1,d0
.countloop:
	addq.b	#1,d0
	tst.l	(a0)+
	bne.s	.countloop
	move.b	d0,subeffectsnum

	move.l	$04BA.w,starttime
	IFEQ	testmode
	clr.l	$FFFF9800.w
	ENDC

	clr.l	d0
	move.l	d0,frmcnt
	move.l	d0,lastframecount

; Initialise realtime stuff.
	movea.l	fxAdr,a0
	movea.l	Fx.INIT_RT(a0),a0
	jsr	(a0)
	bsr	setTime

triggerloopcycle:
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.w	.oldkey(pc),d0
	seq.b	d1
	move.w	d0,.oldkey
	cmpi.b	#$39,d0
	beq.l	return2tos
	cmpi.w	#.subeffects-.key2object_tbl,d0
	bhs.s	.do_subeffect
.do_old:movea.l	fxAdr,a0
	movea.l	(a0),a0
	jsr	(a0)				; Jump to fx-mainloop.
	addq.l	#1,frmcnt
	bra.s	triggerloopcycle
.do_subeffect:
	move.b	(.key2object_tbl.w,pc,d0.l),d0
	beq.s	.do_old
	tst.b	d1
	bne.s	.do_old
	movea.l	fxAdr,a0
	cmp.b	subeffectsnum,d0
	bhs.s	.do_old
	subq.b	#1,d0
	movea.l	Fx.SIZE(a0,d0.l*4),a0
	jsr	(a0)
	bra.s	.do_old

.oldkey:DC.W	0

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

;= restoring code ==========================================================

	TEXT

return2tos:
	IFEQ	testmode

; Hey, don't forget to deinitialize the effect!
	movea.l	fxAdr,a0
	movea.l	Fx.DEINIT_RT(a0),a0
	jsr	(a0)

	move.l	oldvbl,$70.w

	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	lea	save_fv,a0
	bsr.l	CHANGE_FVFAST
	bsr.l	RESTORE_FALCPAL

;	bsr.l	DISPLAY_FRMSPERSEC

;	bsr.l	dsp_load_bootstrap
	ENDC

; enable 040/060 caches!
	ifd	SLOW_CT60
	tst.w	ct60
	beq.s	.ct60_stuff_done
	move.w	#1,-(sp)
	move.w	#5,-(sp)
	move.w	#160,-(sp)
	trap	#14
	addq	#6,sp
	endc
.ct60_stuff_done:

EXIT:	clr.w	-(sp)
	trap	#1

;= subroutines =============================================================

	ifne	0

; INPUT:
; d0.w= size in dspwords
; a0: p56 program
Dsp.loadProgram:
	clr.w	-(sp)
	clr.l	d1
	move.w	d0,d1
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move	#$6D,-(sp)	; Dsp_ExecProg
	trap	#14
	lea	12(sp),sp
	rts

* Displays a dialogbox with average framerate.
DISPLAY_FRMSPERSEC:
	move.l	frmcnt,d1
	clr.l	d2
	move.l	$04BA.w,d0
	sub.l	starttime,d0
	mulu.l	#200,d1
	divu.l	d0,d2:d1
	swap	d2
	divu.l	d0,d2
	move.l	d1,d0
	moveq	#-1,d7
.loop1	divu.w	#10,d0
	swap	d0
	addi.b	#'0',d0
	move.b	d0,-(sp)
	clr.w	d0
	swap	d0
	addq.w	#1,d7
	tst.w	d0
	bne.s	.loop1

	lea	.alertpre_txt(pc),a1
	lea	.temp_txt(pc),a0
	lea	(a1),a6
.bloop1	move.b	(a1),(a0)+
	cmpi.b	#"]",(a1)+
	bne.s	.bloop1
.bloop2	move.b	(a1),(a0)+
	cmpi.b	#"]",(a1)+
	bne.s	.bloop2
	subq	#1,a0
	subq	#1,a1

.plop1	move.b	(sp)+,(a0)+
	dbra	d7,.plop1
.pre2	move.b	#'.',(a0)+
	moveq	#5-1,d7
	mulu.l	#$000186a0,d0:d2		
	move.w	d0,d2
	swap	d2
	move.l	d2,d0
.loop2	divu.w	#10,d0
	swap	d0
	addi.b	#'0',d0
	move.b	d0,-(sp)
	clr.w	d0
	swap	d0
	dbra	d7,.loop2
	moveq	#5-1,d7
.plop2	move.b	(sp)+,(a0)+
	dbra	d7,.plop2

	move.l	#" fps",(a0)+
	move.b	#".",(a0)+

.0loop	move.b	(a1)+,(a0)+
	bne.s	.0loop
 
	move.w	#1,intin
	move.l	#.temp_txt,addrin
	move.l	#.alert_tbl,aespb
	move.l	#aespb,d1
	clr.l	d0
	move.b	#$c8,d0
	trap	#2
	rts

.temp_txt:
	DS.B	256
.alertpre_txt:
	DC.B	"[1][ Average framerate: | ][ OK ]",0
	EVEN

.alert_tbl:
	DC.W	$0034,$0001,$0001,$0001,$0000

	endc

setTime:move.l	$04BA.w,startTime
	rts

getTime:move.l	$04BA.w,d0
	sub.l	startTime,d0
	rts

;= interrupts ==============================================================

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	bsr.l	Screen.update
	move.l	vbl_gfx(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_gfx:
	DC.L	rts

rts:	rts

;= global data =============================================================

	DATA

	ifne	0

* AES parameter block
aespb:	DC.L	contrl,global,intin,intout,addrin,addrout

	endc

;= global reserves =========================================================

	BSS

	EVEN
; Init data
	DS.L	256
ustk:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1

; fx
fxAdr:	DS.L	1

; Falcon system stats
monitormode:
	DS.W	1
detail:	DS.W	1
ct60:	ds.w	1

; Math
sine_tbl:
	DS.L	sintbllen

; GEM-shit
contrl:	DS.W    12
intin:	DS.W    128
intout:	DS.W    128
global:	DS.W    16
addrin:	DS.W    128
addrout:DS.W    128

; Counter and timer shit
frmcnt:	DS.L	1
lastframecount:
	DS.L	1
starttime:
	DS.L	1
subeffectsnum:
	DS.W	1
old468:	DS.W	1
startTime:
	DS.L	1

; Screen stuffs
resRout:DS.L	1
scr:	DS.L	4

empty:	ds.b	64000				; lameness!
