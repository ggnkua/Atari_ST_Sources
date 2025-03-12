*                      [=/\===/\===/\===/\===/\===/\=]
*                     /:  FX testing skeleton v2.0   :\
*                     \: 03-05-1999 by |EarX|->fUn<- :/
*                      [=\/===\/===\/===\/===\/===\/=]
*
* v1.0: * 3 screens
*       * ST-resolution compatible res-switcher
*       * TT-RAM aware
*       * frames/sec. counter
*
* v1.1: * Frames/sec counter now displays dialog-box + is vbl-independent.
*       * Falcon check
*
* v1.2: * Handy debug mode
*
* v1.3: * Fixed res-changer
*       * Now uses INIT and MAINLOOP parts (subroutines).
*
* v1.4: * Extra SET_RES subroutine added.
*
* v1.5: * Can now include object-files (*.SO).
*       * Everything is now called from a object-table (demoobj_tbl).
*
* v1.6: * Demo-objects can use linkloading library now.
*       * Transparant fixes for centurbo VIDEL clock.
*       * Can use DSPMOD 3.2 now.
*
* v2.0: * Complete revision of libraries.
*       * Now does framecounting itself instead of in effectroutine.
*       * No resswitching is done here anymore.
*       * Now expects a resultcode from the INIT routine.
*       * Minor optimisations.

******** ASM OPTIONS ********

	COMMENT	HEAD=%111
;	OPT	D-

******** GLOBAL CONSTANTS ********

testmode:	=	0			* handy debug mode
objectmode:	=	0			* demo-os inclusion mode (dummy)
* monitormode-equ's
autodetect:	=	0
rgb50:		=	1			* RGB/TV, 50Hz
vga100:		=	2			* VGA, 100Hz, interlaced
vga60:		=	3			* VGA, 60Hz, noninterlaced
* screendimension-equ's
scrxbytes:	=	640			* number of bytes per scanline
scrlines:	=	200			* number of scanlines
maxscrsize:	=	scrxbytes*scrlines	* max. size of screen

monitorequ:	=	autodetect		* current monitormode

longeven:	MACRO
		IFGT	*&3
		DS.B	4-(*&3)
		ENDC
		ENDM

******** LIBRARIES ********

	bra	START

	IFEQ	testmode
	INCLUDE	FSCR.I
	TEXT
	ENDC
	INCLUDE	FIMATH.I
	TEXT
archivemode:	=	0
	INCLUDE	INCLOAD.I
	TEXT
	INCLUDE	SOUNDSYS.I
	TEXT

******** INITIALISING CODE ********

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
	move.w	#0,-(sp)			* ST-RAM only!
	move.l	#maxscrsize*4+256,-(sp)		* size of screens..
	move.w	#$44,-(sp)			* Code $44: Mxalloc()
	trap	#1
	addq	#8,sp
	move.l	d0,d0				* Check if there is ST-RAM enough.
	bgt.s	.ramok
* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1
* Initialize screenaddresses..
.ramok:	lea	scr,a0
	addq.l	#4,d0				* / long even
	andi.b	#%11111100,d0			* \ address..
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+

* Check if the demo-object table has all necessary entries..
	lea	demoobj_tbl,a0
	moveq	#3-1,d7
.chklp:	tst.l	(a0)+
	beq	EXIT				* On premature NULL > go out!
	dbra	d7,.chklp
* Set supervisormode and save old stackpointer..
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
	move.l	$05a0.w,a0
	tst.l	a0
	beq	EXIT
.fndmch:
	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found:	cmpi.w	#3,4(a0)
	bne	EXIT
* Centurbo check..
	move.l	$05a0.w,a0
.fndct2:
	move.l	(a0),d0
	beq.s	.noct2
	cmpi.l	#"_CT2",d0
	beq.s	.ct2found
	addq	#8,a0
	bra.s	.fndct2
.noct2:	clr.w	centurbofound
	bra.w	.endct2check
.ct2found:
	move.w	#1,centurbofound
.endct2check:
* Set monitormode..
	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	move.w	$ffff8006.w,d0
	lsr.w	#8,d0
	lsr.w	#6,d0
	beq	EXIT				* Arg! mono monitor!
	btst	#0,d0
	beq.s	.vga
	move.w	#rgb50,monitormode
	bra.s	.endmonitorcheck
.vga:	move.w	#vga100,monitormode
	;move.w	#vga60,monitormode
.endmonitorcheck:
	ENDC
* Install own vbl-routine..
.installvbl:
	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w
* Save falcon-pallette..
	bsr	SAVE_FALCPAL
* Save resolution..
	bsr	SAVE_FV

	ENDC

	movea.l	demoobj_tbl+4,a0
	jsr	(a0)				* Initialize demo-fx.
	move.l	d0,d0
	bmi	EXIT

	IFEQ	testmode
	move.l	$4ba.w,starttime
	clr.l	$ffff9800.w

	ENDC

	lea	demoobj_tbl+8,a0
	moveq	#-1,d0
.countloop:
	addq.b	#1,d0
	tst.l	(a0)+
	bne.s	.countloop
	move.b	d0,subeffectsnum

	move.l	#1,lastframecount

triggerloopcycle:
	IFEQ	testmode
	addq.l	#1,frmcnt
	ENDC
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.w	.oldkey(pc),d0
	seq.b	d1
	move.w	d0,.oldkey
	cmpi.b	#$39,d0
	beq	OUT
	cmpi.w	#.subeffects-.key2object_tbl,d0
	bhs.s	.do_subeffect
.do_old:
	movea.l	demoobj_tbl,a0
	jsr	(a0)				* Jump to fx-mainloop.
	bra.s	triggerloopcycle
.do_subeffect:
	move.b	(.key2object_tbl.w,pc,d0.l),d0
	beq.s	.do_old
	move.b	d1,d1
	bne.s	.do_old
	lea	demoobj_tbl,a0
	cmp.b	subeffectsnum,d0
	bhs.s	.do_old
	movea.l	8(a0,d0.l*4),a0
	jsr	(a0)
	bra.s	.do_old

.oldkey:
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

******** BEGIN OF DEMO-EFFECT OBJECT ********

* Include demo-object in here..
demoobj_tbl:
	INCLUDE	MSX<>SLX.SO

******** RESTORING CODE ********

	TEXT

OUT:
	IFEQ	testmode

	move.l	#rts,vbl_msx
	bsr	dspmod32_stop

	move.l	oldvbl,$70.w

	bsr	RESTORE_FALCPAL
	lea	save_fv,a0
	bsr	CHANGE_FVFAST

	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	bsr	DISPLAY_FRMSPERSEC
	ENDC

EXIT:	clr.w	-(sp)
	trap	#1

******** SUBROUTINE CODE ********

* Displays a dialogbox with average framerate.
DISPLAY_FRMSPERSEC:
	move.l	frmcnt,d1
	moveq	#0,d2
	move.l	$4ba.w,d0
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
	eor.w	d0,d0
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
	eor.w	d0,d0
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
	moveq	#0,d0
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

******** INTERRUPT ROUTINE CODE ********

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

******** GLOBAL DATA + INCLUDES ********

	DATA

* AES parameter block
aespb:	DC.L	contrl,global,intin,intout,addrin,addrout

sine_tbl:
	INCBIN	SINUS.DAT

******** GLOBAL RESERVES ********

	BSS

	EVEN
* Init data
	DS.L	256
ustk:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1

* Falcon system stats

monitormode:
	DS.W	1
centurbofound:
	DS.W	1

* GEM-shit
contrl:	DS.W    12
intin:	DS.W    128
intout:	DS.W    128
global:	DS.W    16
addrin:	DS.W    128
addrout:
	DS.W    128

subeffectsnum:
	DS.W	1

* Counter and timer shit
frmcnt:	DS.L	1
lastframecount:
	DS.L	1
starttime:
	DS.L	1

* Screen stuffs
scr:	DS.L	4

* Shared buffer
temp_buf:
	DS.L	512*256