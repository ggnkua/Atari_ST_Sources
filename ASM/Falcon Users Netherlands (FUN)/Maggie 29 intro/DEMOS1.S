*                        //---------<<<==>>>---------\\
*            /|--.      //:      DEMO-OS v2.0        :\\      .--|\
*            \|--'      \\: 19-07-1999 by EarX<=>fUn ://      '--|/
*              atari     \\---------<<<==>>>---------//      fo3o
*
* ATARI Falcon only.
*
* v1.0: * VBL-independent timing system.
*       * Supports TT-ram.
*       * Initializes all found demo-objects automatically.
*
* v1.1: * Keypad triggermode added.
*       * Debug mode added.
*       * Bugfix in eventhandler done.
*
* v1.2: * Checks for faulty eventtable.
*
* v1.3: * Improved screenswitch. 
*       * Linkloader added.
*
* v1.4: * monitormode detect added.
*       * CenTurbo2 check made for correct VIDEL modes.
*
* v1.5: * GEM videomode and detaillevel selector added.
*       * Subeffect triggerkeys added.
*
* v1.6: * Uses new videolibrary.
*       * Uses sucky DSPmod 3.2 (no other alternative)
*       * Can use fourth screen (for interlacing).
*
* v2.0: * Complete revision of libraries.
*       * Now does framecounting itself instead of in effectroutine.
*       * No resswitching is done here anymore.
*       * Now expects a resultcode from the INIT routine.
*       * Minor optimisations.

******** ASM OPTIONS AND PATHS ********

	COMMENT	HEAD=%111
	OUTPUT	D:\MAGGIE29\INTRO.TOS
;	OPT	D-

******** GLOBAL EQUATES ********

demoos:		=	1			* Indicates demo-os is active
testmode:	=	0			* debug mode
triggermode:	=	1			* 0=manual effect-trigger, 1=event-table trigger

* screendimentions
scrxbytes:	=	640
scrxbytes4b:	=	160
scrlines:	=	200
maxscrsize:	=	scrxbytes*scrlines
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

******** INCLUDES ********

	bra	START

	IFEQ	testmode
	INCLUDE	FSCR.I
	TEXT
	ENDC
	INCLUDE	FIMATH.I
	TEXT
	INCLUDE	SOUNDSYS.I
	TEXT

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

	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	bsr	GET_SETTINGS
	move.w	d0,d0
	bmi	E_EXIT
	ENDC

* mxalloc - Reserve stram ONLY for screens.
	move.w	#0,-(sp)
	move.l	#maxscrsize*4+256,-(sp)		* size of screens..
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
	move.l	d0,bigscradr
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
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
.keyflush:
	btst.b	#0,$fffffc00.w
	beq.s	.keyflush
* Save falcon-pallette..
	bsr.l	SAVE_FALCPAL
* Save resolution..
	bsr.l	SAVE_FV
* Install own vbl-routine..
	move	#$2700,sr
	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w
	move.l	$118.w,old118
	move.l	#NEW118,$118.w
	bclr	#3,$fffffa17.w			* hardware end-of-interrupt
	move	#$2300,sr

	move.w	$468.w,d0
.waitvbl:
	cmp.w	$468.w,d0
	beq.s	.waitvbl
	lea	$ffff9800.w,a0
	move.w	#256-1,d7
.clearpal_loop:
	clr.l	(a0)+
	dbra	d7,.clearpal_loop
	ENDC					* IFEQ testmode

	lea	event_tbl,a0
	bsr.l	INIT_DEMOPARTS
	move.w	d0,objectcount

	IFEQ	testmode
	bsr	dspmod32_start
	lea	module,a0
	bsr	dspmod32_play_module
	lea	vbl_msx,a0
	bsr	install_dspmod32irq
	ENDC

	IFNE	triggermode

	lea	event_tbl,a0
	move.w	objectcount,d0
	jsr	CHECK_DEMOEVENTS

	move.l	$4ba.w,starttime
	moveq	#0,d0
	move.l	d0,frmcnt
	move.l	d0,lastframecount

mainloopcycle:
	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	movea.l	actpartadr,a0
	tst.l	a0
	beq.s	.do
	movea.l	(a0),a1
	jsr	(a1)
.do:	addq.l	#1,frmcnt
	lea	event_tbl,a0
	jsr	DO_DEMOEVENTS
	bra.s	mainloopcycle

	ELSE

	lea	event_tbl,a0
	lea	subeffect_tbl,a1
	move.w	objectcount,d0
	bsr.l	CHECK_DEMOEVENTS

triggerloopcycle:
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
	movea.l	event_tbl,a0
	movea.l	(a0,d0.l*4),a0
	cmpa.l	actpartadr,a0
	beq.s	.do_old
	move.w	d0,.actpart			* / Kick in new
	move.l	a0,actpartadr			* \ object.
	movea.l	8(a0),a0			*
	jsr	(a0)				* Jump to res-setter.
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

event_tbl:
	DC.L	eventpart_tbl
	DC.W	(.end-.start)/6
	DC.W	0
.start:
	DC.L	0
	DC.W	2<<8+6
	DC.L	0
	DC.W	2<<8
	DC.L	4400
	DC.W	1<<8
	DC.L	5400
	DC.W	1<<8+4
	DC.L	6400
	DC.W	1<<8+5
	DC.L	7400
	DC.W	2<<8+3
	DC.L	7400
	DC.W	2<<8+7
	DC.L	7400
	DC.W	2<<8
	DC.L	9000
	DC.W	2<<8+5
	DC.L	10000
	DC.W	2<<8+4
	DC.L	10000
	DC.W	2<<8+7
	DC.L	12200
	DC.W	2<<8+8
	DC.L	13400
	DC.W	4<<8
	DC.L	13400
	DC.W	4<<8+3
	DC.L	16400
	DC.W	3<<8
	DC.L	19000
	DC.W	3<<8+3
	DC.L	29000
	DC.W	3<<8+4
	DC.L	39000
	DC.W	3<<8+3
	DC.L	49000
	DC.W	3<<8+4
	DC.L	59000
	DC.W	3<<8+3
	DC.L	69000
	DC.W	3<<8+4
	DC.L	1000000
	DC.W	0
.end:

eventpart_tbl:
	DC.L	OUT
	DC.L	textFXTable
	DC.L	kerstboomFXTable
	DC.L	fireworxFXTable
	DC.L	kransFXTable
	DC.L	0

* Included effect-objects:
	INCLUDE	TEXT.SO
	INCLUDE	KERSTBAL.SO
	INCLUDE	EARXWOR2.SO
	INCLUDE	KRANS.SO

******** EXITTING CODE ********

OUT:
	IFEQ	testmode

	move.l	#rts,vbl_msx
	bsr.l	dspmod32_stop

	bsr.l	RESTORE_FALCPAL
	lea	save_fv,a0
	bsr.l	CHANGE_FVFAST

	move.l	old118,$118.w
	move.l	oldvbl,$70.w

	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	ENDC					* IFEQ testmode

E_EXIT:	clr.w	-(sp)
	trap	#1

******** DEMO-OS SUBROUTINES ********

* Get videosettings from console.
GET_SETTINGS:

	IFEQ	testmode

	pea	.videomode_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

.getkeyloop:
* Get a character from the console.
	move.w	#1,-(sp)
	trap	#1
	addq	#2,sp

.test_1:
	cmpi.b	#"1",d0
	bne.s	.test_2
	move.w	#rgb50,monitormode
	bra.s	.end
.test_2:
	cmpi.b	#"2",d0
	bne.s	.test_3
	move.w	#vga60,monitormode
	bra.s	.end
.test_3:
	cmpi.b	#"3",d0
	bne.s	.getkeyloop
	move.w	#vga100,monitormode

.end:
	ENDC

	moveq	#0,d0
	rts

.videomode_txt:
	DC.B	27,69
	DC.B	"Please select videomode:",$a,$d
	DC.B	$a
	DC.B	"[1] RGB 50Hz",$a,$d
	DC.B	"[2] VGA 60Hz",$a,$d
	DC.B	"[3] VGA 100Hz",$a,$d
	DC.B	0
	EVEN

* INPUT: a0: address of eventtable
INIT_DEMOPARTS:
	movea.l	(a0),a0				* a0: address of part-table
	addq	#4,a0				* a0: address of first object-pointer

	movea.l	a0,a6
	moveq	#-1,d0
.countloop:
	addq.w	#1,d0
	tst.l	(a6)+
	bne.s	.countloop
	move.w	d0,.objectcount
	beq	.rts

	moveq	#0,d0				* d0.w: objectcounter

.loop:	cmpi.b	#$39,keycode
	beq	OUT

	movea.l	(a0)+,a1
	tst.l	a1
	beq.s	.rts
	move.l	4(a1),a1
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	jsr	(a1)				* Jump to init-subroutine.
	tst.l	d0
	bmi	OUT

	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	addq.w	#1,d0
	bra	.loop

.rts:	rts

.objectcount:
	DC.W	0

* INPUT: a0: address of eventtable
DO_DEMOEVENTS:
	move.l	(a0)+,a1
	lea	2(a0),a6
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmp.w	d0,d1
	beq	OUT
	mulu.w	#6,d1
	adda.l	d1,a0
	move.l	(a0)+,d0
	move.l	$4ba.w,d1
	sub.l	starttime,d1
	cmp.l	d0,d1
	blt.s	.rts
	move.w	(a0)+,d1
	beq	OUT
	move.w	d1,d0
	lsr.w	#8,d0
	andi.w	#$00ff,d1
	bne.s	.intern
	move.l	frmcnt,lastframecount
	move.l	(a1,d0.w*4),actpartadr
	bra.s	.out
.intern	move.l	(a1,d0.w*4),a0
	move.l	(a0,d1.w*4),a0
	move.l	a6,-(sp)
	jsr	(a0)
	movea.l	(sp)+,a6
.out	addq.w	#1,(a6)
.rts	rts

actpartadr:
	DS.L	1

* INPUT: a0: address of eventtable
*        a1: address of subeffectcountertable
*        d0.w: objectcount
CHECK_DEMOEVENTS:
	addq	#1,a1
	move.l	(a0),a2
	addq	#4,a2
.countloop:
	movea.l	(a2)+,a3
	tst.l	a3
	beq.s	.endcounting
	lea	3*4(a3),a3
	moveq	#0,d1
.incountloop:
	addq.w	#1,d1
	tst.l	(a3)+
	bne.s	.incountloop
	move.b	d1,(a1)+
	bra.s	.countloop
.endcounting:

	IFNE	triggermode

	move.l	(a0)+,a1
	move.l	(a1),a1				* a1: address of outaddress
	move.w	(a0),d7				* d7.w: number of events
	addq	#4,a0	
	subq.w	#1,d7
	bmi.s	.rts
.loop:	addq	#4,a0
	move.w	(a0)+,d1
	lsr.w	#8,d1
	cmp.w	d0,d1
	ble.s	.ok
	jmp	(a1)
.ok:	dbra	d7,.loop
.rts:
	ENDC

	rts

******** INTERRUPTS ********

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	movea.l	vbl_gfx(pc),a0
	jsr	(a0)
	movea.l	vbl_msx(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_gfx:
	DC.L	rts
vbl_msx:
	DC.L	rts

rts:	rts

NEW118:
	move.w	d0,-(sp)
;	move.l	a0,-(sp)
.over_again
	move.b	$fffffc02.w,d0
	tst.w	.msepck
	bne.s	.get_mouse
	cmpi.b	#$f8,d0
	blt.s	.no_mouse
	cmpi.b	#$fb,d0
	ble	.mouse_comming		;	ble.s	.mouse_comming
.no_mouse
;	lea	spckey_tbl,a0
;	cmpi.b	#$1d,d0
;	beq.s	.control_press
;	cmpi.b	#$36,d0
;	beq.s	.shift_press
;	cmpi.b	#$2a,d0
;	beq.s	.shift_press
;	cmpi.b	#$38,d0
;	beq.s	.alt_press
;	cmpi.b	#$3a,d0
;	beq.s	.caps_press
;	cmpi.b	#$9d,d0
;	beq.s	.control_press
;	cmpi.b	#$b6,d0
;	beq.s	.shift_release
;	cmpi.b	#$aa,d0
;	beq.s	.shift_release
;	cmpi.b	#$b8,d0
;	beq.s	.alt_press
	move.b	d0,keycode
	bra.s	.exit
;.shift_press
;	addq.w	#1,shiftkey		;(a0)
;	bra.s	.exit
;.shift_release
;	subq.w	#1,shiftkey		;(a0)
;	bra.s	.exit
;.control_press
;	tst.b	d0
;	sgt	controlkey		;2(a0)
;	bra.s	.exit
;.alt_press
;	tst.b	d0
;	sgt	altkey			;4(a0)
;	bra.s	.exit
;.caps_press
;	tst.w	capskey
;	seq	capskey			;6(a0)
;	bra.s	.exit
.get_mouse
	ext.w	d0
	cmpi.w	#1,.msepck
	beq.s	.gtmse1
	tst.b	mse_tbl+4
	bne.s	.spck1
	add.w	d0,mse_tbl
.spck1	subq.w	#1,.msepck
	bra.s	.exit
.gtmse1	tst.b	mse_tbl+4
	bne.s	.spck2
	add.w	d0,mse_tbl+2
.spck2	clr.w	.msepck
	bra.s	.exit
.mouse_comming
	move.w	#2,.msepck
	andi.b	#%00000011,d0
	move.b	d0,mse_tbl+4
.exit	btst.b	#4,$fffffa01.w
	beq	.over_again		;	beq.s	.over_again
;	move.l	(sp)+,a0
	move.w	(sp)+,d0
	rte

.msepck	dc.w	0

******** DATA + INCBINS ********

	DATA

sine_tbl:
	INCBIN	SINUS.DAT

module:
	INCBIN	KERST4.MOD
	;INCBIN	KERST3.MOD
	;INCBIN	E:\MOD\STRANGEL.MOD
	EVEN

******** RESERVES ********

	BSS

	EVEN

* Init-data
	DS.L	256
ustk:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1
old118:	DS.L	1

* Stats shit
monitormode:
	DS.W	1
detaillev:
	DS.W	1
surround:
	DS.W	1
interpolation:
	DS.W	1
centurbofound:
	DS.W	1

* Object handling
objectcount:
	DS.W	1
subeffect_tbl:
	DS.B	128

* Timer STuffs
frmcnt:	DS.L	1
lastframecount:
	DS.L	1
starttime:
	DS.L	1

* Keyboard + mouse STuffs.
mse_tbl	ds.w	5
keycode	ds.w	1

* Scr-stuff
bigscradr:
	DS.L	1
scr:	DS.L	4