*                        //---------<<<==>>>---------\\
*            /|--.      //:      DEMO-OS v1.6        :\\      .--|\
*            \|--'      \\: 24-03-1999 by EarX<=>fUn ://      '--|/
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

******** ASM OPTIONS AND PATHS ********

	COMMENT	HEAD=%111
;	OPT	D-

******** INCLUDES ********

	bra	START

* Library-includes go in here..
	INCLUDE	MKSIN3.I
	TEXT
archivemode:	EQU	1
	INCLUDE	INCLOAD.I
	TEXT
	INCLUDE	VIDEO_ST.I
	TEXT
	INCLUDE	SOUNDSYS.I
	TEXT
	INCLUDE	D:\CODING\DEVPAC3\INCDIR\AESLIB.S
	TEXT
	INCLUDE	D:\CODING\DEVPAC3\INCDIR\VDILIB.S
	TEXT

******** GLOBAL EQUATES ********

demoos:		EQU	1			* Indicates demo-os is active
testmode:	EQU	0			* debug mode
triggermode:	EQU	1			* 0=manual effect-trigger, 1=event-table trigger

* screendimentions
scrxbytes:	EQU	640
scrxbytes4b:	EQU	160
scrlines:	EQU	200
maxscrsize:	EQU	scrxbytes*scrlines
* monitormode-equates
autodetect:	EQU	0
rgb50:		EQU	1			* RGB/TV, 50Hz
vga60:		EQU	2			* VGA, 60, noniterlaced
vga100:		EQU	3			* VGA, 100Hz, interlaced
* monitormode selector ( =autodetect ) or force mode ( >0 )
monitorequ:	EQU	autodetect

longeven:	MACRO
		IFGT	*&3
		DS.B	4-(*&3)
		ENDC
		ENDM

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
	bra.s	.endct2check
.ct2found:
	move.w	#1,centurbofound
.endct2check:

;	lea	dspos_p56,a0
;	move.l	#(enddspos-dspos_p56)/3,d0
;	bsr	INIT_DSPDEMOSYSTEM

	IFNE	monitorequ-autodetect
	move.w	#monitorequ,monitormode
	ELSE
	bsr	GET_SETTINGS
	move.w	d0,d0
	bmi	E_EXIT
	ENDC

	IFEQ	testmode

* Wait for keyboard to end last packet.
;.keyflush:
;	btst.b	#0,$fffffc00.w
;	beq.s	.keyflush
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
	ENDC					* IFEQ testmode

	lea	event_tbl,a0
	bsr.l	INIT_DEMOPARTS
	move.w	d0,objectcount

	IFNE	triggermode

	lea	alivemod_txt,a1
	bsr	LOAD_INCFILE
	move.l	a0,alivemodadr

	tst.w	surround
	beq.s	.no_surround
	bset	#0,dspmod32_player+dspmod32_flags		* toggle surround on/off
.no_surround:
	tst.w	interpolation
	beq.s	.no_interpolation
	bset	#1,dspmod32_player+dspmod32_flags
.no_interpolation:

	bsr	dspmod32_start
	movea.l	alivemodadr,a0
	bsr	dspmod32_play_module
	lea	vbl_msx,a0
	bsr	install_dspmod32irq

	lea	event_tbl,a0
	move.w	objectcount,d0
	jsr	CHECK_DEMOEVENTS

	move.l	$4ba.w,starttime

mainloopcycle:
	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	movea.l	actpartadr,a0
	tst.l	a0
	beq.s	.do
	movea.l	(a0),a1
	jsr	(a1)
	;movea.l	scr+8,a0
	;move.l	$4ba.w,d0
	;sub.l	starttime,d0
.do:	lea	event_tbl,a0
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
* Begin with water stuff (slow droplets)
	DC.L	0
	DC.W	water2code+2
	DC.L	0
	DC.W	water2code
	DC.L	0
	DC.W	water2code+4
	DC.L	100
	DC.W	water2code+10
	DC.L	700
	DC.W	water2code+4
	DC.L	850
	DC.W	water2code+10
	DC.L	1300
	DC.W	water2code+4
	DC.L	1600
	DC.W	water2code+10
	DC.L	1950
	DC.W	water2code+5
	DC.L	2300
	DC.W	water2code+10
* And now go dizzy, you pisser! =)
	DC.L	2600
	DC.W	water2code+9
	DC.L	2600
	DC.W	water2code+5
	DC.L	2900
	DC.W	water2code+10
	DC.L	3350
	DC.W	water2code+5
	DC.L	3650
	DC.W	water2code+10
	DC.L	4000
	DC.W	water2code+5
	DC.L	4300
	DC.W	water2code+10
	DC.L	4650
	DC.W	water2code+5
	DC.L	4950
	DC.W	water2code+10
	DC.L	5300
	DC.W	water2code+6
* >SNAP< onto the lame rumpamapping.
* wire 1
	DC.L	6000
	DC.W	dummycode
	DC.L	6000
	DC.W	wire3dcode+2
	DC.L	6000
	DC.W	wire3dcode
	DC.L	6084
	DC.W	bumpmapcode+2
	DC.L	6084
	DC.W	bumpmapcode
	DC.L	6168
* wire 2
	DC.W	dummycode
	DC.L	6168
	DC.W	wire3dcode+4
	DC.L	6168
	DC.W	wire3dcode+2
	DC.L	6168
	DC.W	wire3dcode
	DC.L	6252
	DC.W	bumpmapcode+2
	DC.L	6252
	DC.W	bumpmapcode
* wire 3
	DC.L	6336
	DC.W	dummycode
	DC.L	6336
	DC.W	wire3dcode+5
	DC.L	6336
	DC.W	wire3dcode+2
	DC.L	6336
	DC.W	wire3dcode
	DC.L	6420
	DC.W	bumpmapcode+2
	DC.L	6420
	DC.W	bumpmapcode
* wire 4
	DC.L	6504
	DC.W	dummycode
	DC.L	6504
	DC.W	wire3dcode+6
	DC.L	6504
	DC.W	wire3dcode+2
	DC.L	6504
	DC.W	wire3dcode
	DC.L	6588
	DC.W	bumpmapcode+2
	DC.L	6588
	DC.W	bumpmapcode
	DC.L	6672
	DC.W	dummycode
	DC.L	6672
	DC.W	wire3dcode+3
	DC.L	6672
	DC.W	wire3dcode+2
	DC.L	6672
	DC.W	wire3dcode
	DC.L	6756
	DC.W	bumpmapcode+2
	DC.L	6756
	DC.W	bumpmapcode
	DC.L	6840
	DC.W	dummycode
	DC.L	6840
	DC.W	wire3dcode+4
	DC.L	6840
	DC.W	wire3dcode+2
	DC.L	6840
	DC.W	wire3dcode
	DC.L	6924
	DC.W	bumpmapcode+2
	DC.L	6924
	DC.W	bumpmapcode
	DC.L	7008
	DC.W	dummycode
	DC.L	7008
	DC.W	wire3dcode+5
	DC.L	7008
	DC.W	wire3dcode+2
	DC.L	7008
	DC.W	wire3dcode
	DC.L	7092
	DC.W	bumpmapcode+2
	DC.L	7092
	DC.W	bumpmapcode
	DC.L	7176
	DC.W	dummycode
	DC.L	7176
	DC.W	wire3dcode+6
	DC.L	7176
	DC.W	wire3dcode+2
	DC.L	7176
	DC.W	wire3dcode
	DC.L	7260
	DC.W	bumpmapcode+2
	DC.L	7260
	DC.W	bumpmapcode
	DC.L	7344
	DC.W	dummycode
	DC.L	7344
	DC.W	wire3dcode+3
	DC.L	7344
	DC.W	wire3dcode+2
	DC.L	7344
	DC.W	wire3dcode
	DC.L	7428
	DC.W	bumpmapcode+2
	DC.L	7428
	DC.W	bumpmapcode
	DC.L	7512
	DC.W	dummycode
	DC.L	7512
	DC.W	wire3dcode+4
	DC.L	7512
	DC.W	wire3dcode+2
	DC.L	7512
	DC.W	wire3dcode
	DC.L	7596
	DC.W	bumpmapcode+2
	DC.L	7596
	DC.W	bumpmapcode
	DC.L	7680
	DC.W	dummycode
	DC.L	7680
	DC.W	wire3dcode+5
	DC.L	7680
	DC.W	wire3dcode+2
	DC.L	7680
	DC.W	wire3dcode
	DC.L	7764
	DC.W	bumpmapcode+2
	DC.L	7764
	DC.W	bumpmapcode
	DC.L	7848
	DC.W	dummycode
	DC.L	7848
	DC.W	wire3dcode+6
	DC.L	7848
	DC.W	wire3dcode+2
	DC.L	7848
	DC.W	wire3dcode
	DC.L	7932
	DC.W	bumpmapcode+2
	DC.L	7932
	DC.W	bumpmapcode
	DC.L	8016
	DC.W	dummycode
	DC.L	8016
	DC.W	wire3dcode+3
	DC.L	8016
	DC.W	wire3dcode+2
	DC.L	8016
	DC.W	wire3dcode
	DC.L	8100
	DC.W	bumpmapcode+2
	DC.L	8100
	DC.W	bumpmapcode
	DC.L	8184
	DC.W	dummycode
	DC.L	8184
	DC.W	wire3dcode+4
	DC.L	8184
	DC.W	wire3dcode+2
	DC.L	8184
	DC.W	wire3dcode
	DC.L	8268
	DC.W	bumpmapcode+2
	DC.L	8268
	DC.W	bumpmapcode
	DC.L	8352
	DC.W	dummycode
	DC.L	8352
	DC.W	wire3dcode+5
	DC.L	8352
	DC.W	wire3dcode+2
	DC.L	8352
	DC.W	wire3dcode
	DC.L	8436
	DC.W	bumpmapcode+2
	DC.L	8436
	DC.W	bumpmapcode
	DC.L	8520
	DC.W	dummycode
	DC.L	8520
	DC.W	wire3dcode+6
	DC.L	8520
	DC.W	wire3dcode+2
	DC.L	8520
	DC.W	wire3dcode
	DC.L	8604
	DC.W	bumpmapcode+2
	DC.L	8604
	DC.W	bumpmapcode
	DC.L	8688
	DC.W	dummycode
	DC.L	8688
	DC.W	wire3dcode+3
	DC.L	8688
	DC.W	wire3dcode+2
	DC.L	8688
	DC.W	wire3dcode
	DC.L	8772
	DC.W	bumpmapcode+2
	DC.L	8772
	DC.W	bumpmapcode
	DC.L	8856
	DC.W	dummycode
	DC.L	8856
	DC.W	wire3dcode+4
	DC.L	8856
	DC.W	wire3dcode+2
	DC.L	8856
	DC.W	wire3dcode
	DC.L	8940
	DC.W	bumpmapcode+2
	DC.L	8940
	DC.W	bumpmapcode
	DC.L	9032
	DC.W	dummycode
	DC.L	9032
	DC.W	wire3dcode+5
	DC.L	9032
	DC.W	wire3dcode+2
	DC.L	9032
	DC.W	wire3dcode
	DC.L	9108
	DC.W	bumpmapcode+2
	DC.L	9108
	DC.W	bumpmapcode
	DC.L	9192
	DC.W	dummycode
	DC.L	9192
	DC.W	wire3dcode+6
	DC.L	9192
	DC.W	wire3dcode+2
	DC.L	9192
	DC.W	wire3dcode
	DC.L	9276
	DC.W	bumpmapcode+2
	DC.L	9276
	DC.W	bumpmapcode
	DC.L	9360
	DC.W	dummycode
	DC.L	9360
	DC.W	wire3dcode+3
	DC.L	9360
	DC.W	wire3dcode+2
	DC.L	9360
	DC.W	wire3dcode
	DC.L	9444
	DC.W	bumpmapcode+2
	DC.L	9444
	DC.W	bumpmapcode
	DC.L	9528
	DC.W	dummycode
	DC.L	9528
	DC.W	wire3dcode+4
	DC.L	9528
	DC.W	wire3dcode+2
	DC.L	9528
	DC.W	wire3dcode
	DC.L	9612
	DC.W	bumpmapcode+2
	DC.L	9612
	DC.W	bumpmapcode
	DC.L	9696
	DC.W	dummycode
	DC.L	9696
	DC.W	wire3dcode+5
	DC.L	9696
	DC.W	wire3dcode+2
	DC.L	9696
	DC.W	wire3dcode
	DC.L	9780
	DC.W	bumpmapcode+2
	DC.L	9780
	DC.W	bumpmapcode
	DC.L	9846
	DC.W	dummycode
	DC.L	9846
	DC.W	wire3dcode+6
	DC.L	9846
	DC.W	wire3dcode+2
	DC.L	9846
	DC.W	wire3dcode
	DC.L	9948
	DC.W	bumpmapcode+2
	DC.L	9948
	DC.W	bumpmapcode
	DC.L	10032
	DC.W	dummycode
	DC.L	10032
	DC.W	wire3dcode+3
	DC.L	10032
	DC.W	wire3dcode+2
	DC.L	10032
	DC.W	wire3dcode
	DC.L	10116
	DC.W	bumpmapcode+2
	DC.L	10116
	DC.W	bumpmapcode
	DC.L	10200
	DC.W	dummycode
	DC.L	10200
	DC.W	wire3dcode+4
	DC.L	10200
	DC.W	wire3dcode+2
	DC.L	10200
	DC.W	wire3dcode
	DC.L	10284
	DC.W	bumpmapcode+2
	DC.L	10284
	DC.W	bumpmapcode
	DC.L	10368
	DC.W	dummycode
	DC.L	10368
	DC.W	wire3dcode+5
	DC.L	10368
	DC.W	wire3dcode+2
	DC.L	10368
	DC.W	wire3dcode
	DC.L	10452
	DC.W	bumpmapcode+2
	DC.L	10452
	DC.W	bumpmapcode
	DC.L	10536
	DC.W	dummycode
	DC.L	10536
	DC.W	wire3dcode+6
	DC.L	10536
	DC.W	wire3dcode+2
	DC.L	10536
	DC.W	wire3dcode
	DC.L	10620
	DC.W	bumpmapcode+2
	DC.L	10620
	DC.W	bumpmapcode

* Beat gets a fill-in..
	DC.L	10650
	DC.W	dummycode
	DC.L	10650
	DC.W	wire3dcode+2
	DC.L	10650
	DC.W	wire3dcode
	DC.L	10700
	DC.W	bumpmapcode+2
	DC.L	10700
	DC.W	bumpmapcode
	DC.L	10750
	DC.W	dummycode
	DC.L	10750
	DC.W	wire3dcode+2
	DC.L	10750
	DC.W	wire3dcode
	DC.L	10800
	DC.W	bumpmapcode+2
	DC.L	10800
	DC.W	bumpmapcode
	DC.L	11000
	DC.W	dummycode
	DC.L	11000
	DC.W	wire3dcode+2
	DC.L	11000
	DC.W	wire3dcode
	DC.L	11050
	DC.W	bumpmapcode+2
	DC.L	11050
	DC.W	bumpmapcode
	DC.L	11100
	DC.W	dummycode
	DC.L	11100
	DC.W	wire3dcode+2
	DC.L	11100
	DC.W	wire3dcode
	DC.L	11150
	DC.W	bumpmapcode+2
	DC.L	11150
	DC.W	bumpmapcode
* Kaas uit het puistje. Kom hier!
	DC.L	11350
	DC.W	tunnelcode+3
	DC.L	11350
	DC.W	dummycode
	DC.L	11350
	DC.W	kaasblokcode+2
	DC.L	11350
	DC.W	kaasblokcode+4
	DC.L	11350
	DC.W	kaasblokcode
* Let the cute logo come up.
	DC.L	12350
	DC.W	kaasblokcode+6
	DC.L	12600
	DC.W	kaasblokcode+5
* Kaas + borrel.
	DC.L	13350
	DC.W	kaasblokcode+3
* Do the rotofeedback thing... Looks like shit.. But what d'ya want..
	DC.L	13900
	DC.W	rotofadecode+2
	DC.L	13900
	DC.W	rotofadecode
	DC.L	16400
	DC.W	rotofadecode+4
* Let's get to the tunnel (just when you thought it couldn't get any more boring)
* Maybe do some syncing to the beat here.
	DC.L	16800
	DC.W	dummycode
	DC.L	16800
	DC.W	tunnelcode
	DC.L	16800
	DC.W	tunnelcode+2
* TRIDI STuffs. Lame old torus first.
	DC.L	22000
	DC.W	dummycode+2
	DC.L	22000
	DC.W	dummycode
	DC.L	22000
	DC.W	envmapcode+2
	DC.L	22000
	DC.W	envmapcode
* Change object to the spikes..
	DC.L	24000
	DC.W	envmapcode+4
* Switch the rotofading on and off..
	DC.L	24800
	DC.W	rotofadecode+3
	DC.L	24800
	DC.W	rotofadecode+2
	DC.L	24800
	DC.W	rotofadecode
	DC.L	24884
	DC.W	dummycode
	DC.L	24884
	DC.W	envmapcode+2
	DC.L	24884
	DC.W	envmapcode
	DC.L	24968
	DC.W	rotofadecode+2
	DC.L	24968
	DC.W	rotofadecode
	DC.L	25052
	DC.W	dummycode
	DC.L	25052
	DC.W	envmapcode+2
	DC.L	25052
	DC.W	envmapcode
	DC.L	25136
	DC.W	rotofadecode+2
	DC.L	25136
	DC.W	rotofadecode
	DC.L	25220
	DC.W	dummycode
	DC.L	25220
	DC.W	envmapcode+2
	DC.L	25220
	DC.W	envmapcode
	DC.L	25304
	DC.W	rotofadecode+2
	DC.L	25304
	DC.W	rotofadecode
* Now kick in the spikes + halo! (holy spikes? That IS a bad joke)
* (infact I wonder if that classifies as a joke at all =))
	DC.L	25388
	DC.W	dummycode
	DC.L	25388
	DC.W	envmapcode+6
	DC.L	25388
	DC.W	envmapcode+2
	DC.L	25388
	DC.W	envmapcode
	DC.L	25472
	DC.W	rotofadecode+2
	DC.L	25472
	DC.W	rotofadecode
	DC.L	24556
	DC.W	dummycode
	DC.L	24556
	DC.W	envmapcode+2
	DC.L	24556
	DC.W	envmapcode
	DC.L	24640
	DC.W	rotofadecode+2
	DC.L	24640
	DC.W	rotofadecode
	DC.L	25724
	DC.W	dummycode
	DC.L	25724
	DC.W	envmapcode+2
	DC.L	25724
	DC.W	envmapcode
	DC.L	25808
	DC.W	rotofadecode+2
	DC.L	25808
	DC.W	rotofadecode
	DC.L	25892
	DC.W	dummycode
	DC.L	25892
	DC.W	envmapcode+2
	DC.L	25892
	DC.W	envmapcode
	DC.L	25976
	DC.W	rotofadecode+2
	DC.L	25976
	DC.W	rotofadecode
	DC.L	26060
	DC.W	dummycode
	DC.L	26060
	DC.W	envmapcode+2
	DC.L	26060
	DC.W	envmapcode

	DC.L	26144
	DC.W	rotofadecode+2
	DC.L	26144
	DC.W	rotofadecode
	DC.L	26228
	DC.W	dummycode
	DC.L	26228
	DC.W	envmapcode+2
	DC.L	26228
	DC.W	envmapcode
	DC.L	26312
	DC.W	rotofadecode+2
	DC.L	26312
	DC.W	rotofadecode
	DC.L	26396
	DC.W	dummycode
	DC.L	26396
	DC.W	envmapcode+2
	DC.L	26396
	DC.W	envmapcode
	DC.L	26480
	DC.W	rotofadecode+2
	DC.L	26480
	DC.W	rotofadecode
	DC.L	26564
	DC.W	dummycode
	DC.L	26564
	DC.W	envmapcode+2
	DC.L	26564
	DC.W	envmapcode
	DC.L	26648
	DC.W	rotofadecode+2
	DC.L	26648
	DC.W	rotofadecode

	DC.L	26816
	DC.W	dummycode
	DC.L	26816
	DC.W	envmapcode+2
	DC.L	26816
	DC.W	envmapcode
	DC.L	26900
	DC.W	rotofadecode+2
	DC.L	26900
	DC.W	rotofadecode
	DC.L	26984
	DC.W	dummycode
	DC.L	26984
	DC.W	envmapcode+2
	DC.L	26984
	DC.W	envmapcode
	DC.L	27068
	DC.W	rotofadecode+2
	DC.L	27068
	DC.W	rotofadecode
	DC.L	27152
	DC.W	dummycode
	DC.L	27152
	DC.W	envmapcode+2
	DC.L	27152
	DC.W	envmapcode
	DC.L	27236
	DC.W	rotofadecode+2
	DC.L	27236
	DC.W	rotofadecode

* Switch back to the torus.
	DC.L	27320
	DC.W	dummycode
	DC.L	27320
	DC.W	envmapcode+3
	DC.L	27320
	DC.W	envmapcode+2
	DC.L	27320
	DC.W	envmapcode
	DC.L	27404
	DC.W	rotofadecode+2
	DC.L	27404
	DC.W	rotofadecode
	DC.L	27488
	DC.W	dummycode
	DC.L	27488
	DC.W	envmapcode+2
	DC.L	27488
	DC.W	envmapcode
	DC.L	27572
	DC.W	rotofadecode+2
	DC.L	27572
	DC.W	rotofadecode
	DC.L	27656
	DC.W	dummycode
	DC.L	27656
	DC.W	envmapcode+2
	DC.L	27656
	DC.W	envmapcode
	DC.L	27740
	DC.W	rotofadecode+2
	DC.L	27740
	DC.W	rotofadecode

	DC.L	27824
	DC.W	dummycode
	DC.L	27824
	DC.W	envmapcode+2
	DC.L	27824
	DC.W	envmapcode
	DC.L	27908
	DC.W	rotofadecode+2
	DC.L	27908
	DC.W	rotofadecode
	DC.L	27992
	DC.W	dummycode
	DC.L	27992
	DC.W	envmapcode+2
	DC.L	27992
	DC.W	envmapcode
	DC.L	28076
	DC.W	rotofadecode+2
	DC.L	28076
	DC.W	rotofadecode
	DC.L	28160
	DC.W	dummycode
	DC.L	28160
	DC.W	envmapcode+2
	DC.L	28160
	DC.W	envmapcode
	DC.L	28244
	DC.W	rotofadecode+2
	DC.L	28244
	DC.W	rotofadecode
	DC.L	28500
	DC.W	dummycode
	DC.L	28500
	DC.W	envmapcode+9
	DC.L	28500
	DC.W	envmapcode+2
	DC.L	28500
	DC.W	envmapcode
	DC.L	28800
	DC.W	rotofadecode+2
	DC.L	28800
	DC.W	rotofadecode
	DC.L	29300
	DC.W	dummycode
	DC.L	29300
	DC.W	envmapcode+10
	DC.L	29300
	DC.W	envmapcode+2
	DC.L	29300
	DC.W	envmapcode
* Move onto the next one with a flare or whatever,.
	DC.L	32000
	DC.W	dummycode
	DC.L	32000
	DC.W	flarecode+3
	DC.L	32000
	DC.W	flarecode+2
	DC.L	32000
	DC.W	flarecode
* Again a more easy-listening part.. Time for one of those near-death-experience tunnels ;)
	DC.L	32800
	DC.W	dummycode
	DC.L	32800
	DC.W	raytuncode+2
	DC.L	32800
	DC.W	raytuncode
	DC.L	33600
	DC.W	raytuncode+4

* Show the envmap objects in wireframe..
	DC.L	35600
	DC.W	dummycode
	DC.L	35600
	DC.W	wire3dcode+2
	DC.L	35600
	DC.W	wire3dcode
	DC.L	35768
	DC.W	wire3dcode+3
	DC.L	35936
	DC.W	wire3dcode+4
	DC.L	36104
	DC.W	wire3dcode+5
	DC.L	36272
	DC.W	wire3dcode+3
	DC.L	36440
	DC.W	wire3dcode+4
	DC.L	36608
	DC.W	wire3dcode+5
	DC.L	36776
	DC.W	wire3dcode+3
	DC.L	36944
	DC.W	wire3dcode+4
	DC.L	37112
	DC.W	wire3dcode+5

* Environmentmapping STuffs. (spaced invader)
	DC.L	37280
	DC.W	dummycode
	DC.L	37280
	DC.W	envmapcode+7
	DC.L	37280
	DC.W	envmapcode+2
	DC.L	37280
	DC.W	envmapcode
	DC.L	37616
	DC.W	envmapcode+8
	DC.L	37884
	DC.W	envmapcode+7
	DC.L	37976
	DC.W	envmapcode+8
	DC.L	38168
	DC.W	envmapcode+7
	DC.L	38360
	DC.W	envmapcode+8
	DC.L	38552
	DC.W	envmapcode+7
	DC.L	38744
	DC.W	envmapcode+8
	DC.L	38936
	DC.W	envmapcode+7
	DC.L	39128
	DC.W	envmapcode+8
	DC.L	39320
	DC.W	envmapcode+7
	DC.L	39512
	DC.W	envmapcode+8
	DC.L	39704
	DC.W	envmapcode+7
	DC.L	39896
	DC.W	envmapcode+8
	DC.L	40088
	DC.W	envmapcode+7
	DC.L	40280
	DC.W	envmapcode+8
* Kick in the water to end the horror!
	DC.L	40400
	DC.W	water2code+11
	DC.L	40400
	DC.W	water2code
	DC.L	40400
	DC.W	water2code+2
	DC.L	42000
	DC.W	water2code+5
	DC.L	43000
	DC.W	water2code+4
	DC.L	43500
	DC.W	water2code+3
	DC.L	43700
	DC.W	water2code+10
* 44000: End of ALIVE part!
* Los Creditos! Begrepos?
	DC.L	44000
	DC.W	dummycode
	DC.L	44000
	DC.W	atariscnecode+2
	DC.L	44000
	DC.W	atariscnecode

* Die bitch!
	DC.L	51000
	DC.W	0
.end:

dummycode:	EQU	1<<8
flarecode:	EQU	2<<8
raytuncode:	EQU	3<<8
water2code:	EQU	4<<8
envmapcode:	EQU	5<<8
bumpmapcode:	EQU	6<<8
kaasblokcode:	EQU	7<<8
tunnelcode:	EQU	8<<8
wire3dcode:	EQU	9<<8
rotofadecode:	EQU	10<<8
atariscnecode:	EQU	11<<8
;relfxcode:	EQU	12<<8

eventpart_tbl:
	DC.L	OUT
	DC.L	dummy_tbl
	DC.L	lensflare_tbl
	DC.L	raytun_tbl
	DC.L	water2_tbl
	DC.L	envmap_tbl
	DC.L	bumpmap_tbl
	DC.L	kaasblok_tbl
	DC.L	tunnel_tbl
	DC.L	wire3d_tbl
	DC.L	rotofade_tbl
	DC.L	atariscne_tbl
	DC.L	0

* Included effect-objects:

	INCLUDE	DUMMY.SO
	INCLUDE	LENSFLAR.SO
	INCLUDE	RAYTUN2.SO
	INCLUDE	WATER2.SO
	INCLUDE	NENVMAP.SO
	INCLUDE	BUMPMAP.SO
	INCLUDE	KAASBLOK.SO
	INCLUDE	FADETUNL.SO
	INCLUDE	WIRE3D.SO
	INCLUDE	ROTOFADE.SO
	INCLUDE	ATARISCE.SO

******** EXITTING CODE ********

OUT:
	IFEQ	testmode

	move.l	#rts,vbl_msx
	jsr	dspmod32_stop

	bsr	RESTORE_FV
	bsr	RESTORE_FALCPAL

	move.l	old118,$118.w
	move.l	oldvbl,$70.w

	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	ENDC					* IFEQ testmode

E_EXIT:	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	clr.w	-(sp)
	trap	#1

******** DEMO-OS SUBROUTINES ********

	IFEQ	monitorequ-autodetect

demosetterbox:	EQU	0			* BOX in boom FUNDEMOSETTER
titelbox:	EQU	1
exitbutton:	EQU	3			* BUTTON in boom FUNDEMOSETTER
runbutton:	EQU	4			* BUTTON in boom FUNDEMOSETTER
videogroupbox:	EQU	5
videoselect:	EQU	6			* BUTTON in boom FUNDEMOSETTER
detailselect:	EQU	7			* BUTTON in boom FUNDEMOSETTER
audiogroupbox:	EQU	10
surroundbutton:	EQU	11
interpolbutton:	EQU	12

videomodes:	EQU	1			* Formulier/Dialoog
vdorgb50:	EQU	2			* STRING in boom VIDEOMODES
vdovga60:	EQU	3			* STRING in boom VIDEOMODES
vdovga100:	EQU	4			* STRING in boom VIDEOMODES
vdodefault:	EQU	vdorgb50

detaillevels:	EQU	2			* Formulier/Dialoog
detaillow:	EQU	2			* STRING in boom DETAILLEVELS
detailmid:	EQU	3			* STRING in boom DETAILLEVELS
detailhigh:	EQU	4			* STRING in boom DETAILLEVELS
detaildefault:	EQU	detaillow

* OUTPUT: d0.w:	0=Run demo
*               -1=Exit demo
GET_SETTINGS:
	bsr	INIT_DIALOG
	move.w	d0,d0
	bpl.s	.ok
	moveq	#-1,d0
	rts
.ok:

* graf_mouse
* Muis in z'n graf?? 8-)
* Kill the summsummbee and get a nice mousepointer again =)
	move.w	#0,int_in
	moveq	#78,d0
	bsr	CALL_AES

.loop:
* objc_draw
	lea	int_in,a0
	move.w	#0,(a0)+
	move.w	#5,(a0)+
	movem.l	dialogsize_tbl,d0-d1
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	treeadr,addr_in
	moveq	#42,d0
	bsr	CALL_AES

* form_do
	move.l	treeadr,addr_in
	move.w	#0,int_in
	moveq	#50,d0
	bsr	CALL_AES

	cmpi.w	#exitbutton,d0
	beq	.enddialog
	cmpi.w	#runbutton,d0
	beq	.enddialog
	cmpi.w	#videoselect,d0
	beq	.videopopup
	cmpi.w	#detailselect,d0
	beq	.detailpopup
	bra	.loop

.videopopup:
* objc_offset
	move.l	treeadr,addr_in
	move.w	#videoselect,int_in
	moveq	#44,d0
	bsr	CALL_AES
	move.l	int_out+2,d0
	movea.l	treeadr,a0
	movea.l	vdopopupadr,a1
	bsr	HANDLE_POPUP

	cmpi.w	#vdorgb50,d0
	bne.s	.vga60
	move.w	#rgb50,monitormode
	bra.s	.endrescodes
.vga60:	cmpi.w	#vdovga60,d0
	bne.s	.vga100
	move.w	#vga60,monitormode
	bra.s	.endrescodes
.vga100:
	cmpi.w	#vdovga100,d0
	bne.s	.next
	move.w	#vga100,monitormode
.next:
.endrescodes:
	movea.l	vdopopupadr,a0
	move.w	d0,d1
	mulu.w	#6*4,d1
	movea.l	12(a0,d1.l),a0
	movea.l	treeadr,a1
	lea	videoselect*24(a1),a1
	andi.w	#$fffe,10(a1)
	move.l	a0,12(a1)

	bra	.loop

.detailpopup:
* objc_offset
	move.l	treeadr,addr_in
	move.w	#detailselect,int_in
	moveq	#44,d0
	bsr	CALL_AES
	move.l	int_out+2,d0
	movea.l	treeadr,a0
	movea.l	detailpopupadr,a1
	bsr	HANDLE_POPUP

	move.w	d0,detaillev
	movea.l	detailpopupadr,a0
	move.w	d0,d1
	mulu.w	#6*4,d1
	movea.l	12(a0,d1.l),a0
	movea.l	treeadr,a1
	lea	detailselect*24(a1),a1
	andi.w	#$fffe,10(a1)
	move.l	a0,12(a1)

	bra	.loop

.enddialog:
	move.w	d0,-(sp)
	bsr	KILL_DIALOG
	move.w	(sp)+,d0

	cmpi.w	#exitbutton,d0
	beq.s	.exitcode

	movea.l	treeadr,a0
	move.w	surroundbutton*24+10(a0),d0
	andi.w	#$0001,d0
	move.w	d0,surround
	move.w	interpolbutton*24+10(a0),d0
	andi.w	#$0001,d0
	move.w	d0,interpolation

	moveq	#0,d0
	rts
.exitcode:
	moveq	#-1,d0
	rts

* OUTPUT: d0.w: 0=oki
*               -1=suxxy
INIT_DIALOG:
* rsrc_load
* HuhhUhU. You said "load" huhuh.. YEh!
	move.l	#rscfilename_txt,addr_in
	moveq	#110,d0
	bsr	CALL_AES
	move.w	d0,d0
	bne.s	.loaded
	moveq	#-1,d0
	rts
.loaded:	

* rsrc_gaddr
	clr.w	int_in
	move.w	#demosetterbox,int_in+2
	moveq	#112,d0
	bsr	CALL_AES
	move.l	addr_out,treeadr
	clr.w	int_in
	move.w	#videomodes,int_in+2
	moveq	#112,d0
	bsr	CALL_AES
	move.l	addr_out,vdopopupadr
	clr.w	int_in
	move.w	#detaillevels,int_in+2
	moveq	#112,d0
	bsr	CALL_AES
	move.l	addr_out,detailpopupadr

* Initialize default videosetting.
	movea.l	treeadr,a0
	movea.l	vdopopupadr,a1
	lea	vdodefault*24(a1),a1
	ori.w	#$0001,10(a1)
	move.l	12(a1),videoselect*24+12(a0)
	move.w	#vdodefault-1,monitormode
* Initialize default detaillevel.
	movea.l	treeadr,a0
	movea.l	detailpopupadr,a1
	lea	detaildefault*24(a1),a1
	ori.w	#$0001,10(a1)
	move.l	12(a1),detailselect*24+12(a0)
	move.w	#detaildefault,detaillev

* graf_handle
	moveq	#77,d0
	bsr	CALL_AES
	move.w	d0,current_handle

* v_opnvwk
	moveq	#100,d0
	bsr	CALL_VDI
	move.w	intout+13*2,d0
	beq.s	.endcolorchange
	cmpi.w	#4,d0
	bhi.s	.endcolorchange

* Reconfigure fill colors for 4 and 2 color modes.
	movea.l	treeadr,a0
	move.w	demosetterbox*24+14(a0),d0
	andi.w	#$ff8f,d0
	move.w	d0,demosetterbox*24+14(a0)
	move.w	videogroupbox*24+14(a0),d0
	andi.w	#$ff8f,d0
	move.w	d0,videogroupbox*24+14(a0)
	move.w	audiogroupbox*24+14(a0),d0
	andi.w	#$ff8f,d0
	move.w	d0,audiogroupbox*24+14(a0)
	movea.l	titelbox*24+12(a0),a1
	move.w	18(a1),d0
	andi.w	#$ff8f,d0
	move.w	d0,18(a1)
.endcolorchange:

* v_clsvwk
	moveq	#101,d0
	bsr	CALL_VDI

* form_center
	move.l	treeadr,addr_in
	moveq	#54,d0
	bsr	CALL_AES

* Resize a bit to fit in the outline as well.
	movem.l	int_out+2,d0-d1
	sub.l	#$00030003,d0
	add.l	#$00060006,d1
	movem.l	d0-d1,dialogsize_tbl

* form_dial: FDM_START
	lea	int_in,a0
	move.w	#0,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	moveq	#51,d0
	bsr	CALL_AES

	moveq	#0,d0
	rts

KILL_DIALOG:
* form_dial: FDM_FINISH
	lea	int_in,a0
	move.w	#3,(a0)+
	movem.l	dialogsize_tbl,d0-d1
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	moveq	#51,d0
	bsr	CALL_AES

* rsrc_free
	moveq	#111,d0
	bsr	CALL_AES
	rts

* INPUT: d0.l: x and y position
*        a1: address of childtree
* OUTPUT: d0.w: objecthandle of selection
HANDLE_POPUP:
	move.l	a1,-(sp)

	move.l	d0,16(a1)
	subi.l	#$00010001,d0
	move.l	20(a1),d1
	addi.l	#$00040004,d1

* objc_draw
	lea	int_in,a0
	move.w	#0,(a0)+
	move.w	#5,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	a1,addr_in
	moveq	#42,d0
	bsr	CALL_AES

	move.l	(sp)+,a1

* form_do
	move.l	a1,addr_in
	move.w	#0,int_in
	moveq	#50,d0
	bsr	CALL_AES
	rts

	ENDC					* IFEQ monitorequ-autodetect

SAVE_FV:
	lea	fvbuf,a1
	move.l	#'FVD2',(a1)+			* 4 bytes header
	move.b	$ffff8006.w,(a1)+		* monitor type
	move.b	$ffff820a.w,(a1)+		* sync
	move.l	$ffff820e.w,(a1)+		* offset & vwrap
	move.w	$ffff8266.w,(a1)+		* spshift
	lea	$ffff8282.w,a0			* horizontal control registers
.loop1:	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a0
	bne.s	.loop1
	lea	$ffff82a2.w,a0			* vertical control registers
.loop2:	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a0
	bne.s	.loop2
	move	$ffff82c2.w,(a1)+		* video control
	move	$ffff82c0.w,(a1)+		* video clock
	move.b	$ffff8260.w,(a1)+		* shifter resolution
	move.b	$ffff820a.w,(a1)+		* video sync mode
	rts

RESTORE_FV:
	lea	fvbuf,a0
	bsr	CHANGE_FVFAST
	rts

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
	addq	#6,a0				* Skip header + monitortype
	lea	(a0),a6

	move.l	(a0)+,$ffff820e.w		* offset & vwrap
	move.w	(a0)+,$ffff8266.w		* spshift
	lea	$ffff8282.w,a1			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w		* video control
	move.w	monitormode,d0
	cmpi.w	#vga60,d0
	beq.s	.normalclock
	cmpi.w	#vga100,d0
	beq.s	.normalclock
	tst.w	centurbofound
	bne.s	.extclock
.normalclock:
	move.w	(a0)+,$ffff82c0.w		* video clock
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.stres
	addq	#1,a0				* st res
	bra.s	.fres
.stres:	move.b	(a0)+,$ffff8260.w		* st res
.fres:	move.b	(a0)+,$ffff820a.w		* video sync mode
	rts
* Special shit for external clock. %-( Dumb CenTurbo shit!
.extclock:
	move.w	(a0)+,d0
	btst	#2,d0				* Test which clock is attached.
	seq.b	d1
	move.w	d0,$ffff82c0.w
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.xstres
	addq	#1,a0				* st res
	bra.s	.xfres
.xstres:
	move.b	(a0)+,$ffff8260.w		* st res
.xfres:	move.b	(a0)+,d0
	tst.b	d1
	beq.s	.25mhz
	bset	#0,d0				* Set external sync.
.25mhz:	move.b	d0,$ffff820a.w			* video sync mode
	rts

* INPUT: d0.l: size of P56 binary data in 24bit words
*        a0: address of P56 binary data
INIT_DSPDEMOSYSTEM:
;	move.w	#0,-(sp)
;	move.l	d0,-(sp)
;	pea	(a0)
;	move.w	#$6D,-(sp)
;	trap	#14				* xbios 109
;	lea	12(sp),sp
	rts

* PRE: INIT_DSPDEMOSYSTEM has been called.
* INPUT: d0.l: size of P56 binary data in 24bit words
*        a0: address of P56 binary data
* OUTPUT: d0.l: 0= all clear
*               -1= error
INSTALL_DSPOBJECT:
	lea	$ffffa202.w,a1
	lea	2(a1),a2

.wait:	btst	#1,(a1)
	beq.s	.wait
	move.l	#" OBJ",(a2)

.wait2:	btst	#0,(a1)
	beq.s	.wait2
	move.l	(a2),d1

	ext.l	d1
	bmi.s	.error

.wait3:	btst	#1,(a1)
	beq.s	.wait3
	move.l	d0,(a2)

	subq.w	#1,d0
	bmi.s	.error
.loop:
.wait4:	btst	#1,(a1)
	beq.s	.wait4
	move.w	(a0)+,d1
	lsl.l	#8,d1
	move.b	(a0)+,d1
	move.l	d1,(a2)
	dbra	d0,.loop

.success:
	moveq	#0,d0
	rts

.error:	moveq	#-1,d0
	rts

* PRE: INIT_DSPDEMOSYSTEM has been called.
* INPUT: d0.l: number of 24bit words
*        a0: address of buffer
UPLOAD_DSPXMEM:

	rts

* PRE: INIT_DSPDEMOSYSTEM has been called.
* INPUT: d0.l: number of 24bit words
*        a0: address of buffer
UPLOAD_DSPYMEM:

	rts

* INPUT: a0: screenaddress
CLEAR_320200TSCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#123-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*200*2,a0
.loop	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	rts

* INPUT: a0: screenaddress
CLEAR_320100TSCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*100*2,a0
.loop:	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

* INPUT: a0: screenaddress
CLEAR_3202008SCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*100*2,a0
.loop:
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

COPY_PIC3202008:
	moveq	#100-1,d7
.loop:	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,144(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,192(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,240(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,288(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,336(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,384(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,432(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,480(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,528(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,576(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,624(a0)
	lea	640(a0),a0
	dbra	d7,.loop
	rts

SAVE_FALCPAL:
	lea	falcsave_pal,a0
	lea	$ffff9800.w,a1
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

RESTORE_FALCPAL:
	lea	falcsave_pal,a1
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

* INPUT: a0: address of eventtable
INIT_DEMOPARTS:
	move.l	a0,-(sp)

	lea	wheelanim_txt,a1
	jsr	LOAD_INCFILE
	move.l	a0,wheelanimadr

	lea	funinduload_txt,a1
	jsr	LOAD_INCFILE
	move.l	a0,earxloadadr

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
.vga60:	jsr	vga60_16bit_320_200
	bra.s	.endresset
.vga100:
	jsr	vga100_16bit_320_200
	bra.s	.endresset
.rgb50:	jsr	rgb50_16bit_320_200
.endresset:

* Kick in new screen..
	move.l	scr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

* Make pallette black.. (Black is beautiful my dear Sandra.)
	moveq	#256/2-1,d7
	moveq	#0,d0
	lea	$ffff9800.w,a0
.clearloop:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d7,.clearloop

	ENDC

	movea.l	earxloadadr,a1
	movea.l	scr,a0
	IFEQ	1
	move.w	#((320*200)>>5)-1,d7
	moveq	#$ffffffff,d1
	moveq	#$00000000,d2
.chunkloop:
	move.l	(a1)+,d0
	moveq	#1<<5-1,d6
.pixloop:
	btst	d6,d0
	beq.s	.noplot
	move.w	d1,(a0)+
	bra.s	.endpixloop
.noplot:
	move.w	d2,(a0)+
.endpixloop:
	dbra	d6,.pixloop
	dbra	d7,.chunkloop
	ELSE
	move.w	#200-1,d7
.yloop:
	REPT	160
	move.l	(a1)+,(a0)+
	ENDR
	dbra	d7,.yloop
	ENDC

	movea.l	(sp)+,a0

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

	move.l	#320<<8,d1
	divu.w	d0,d1
	move.w	d1,.barwidth

	moveq	#0,d0				* d0.w: objectcounter

	move.w	$468.w,.old468
	move.l	#PLOT_WHEELGFX,vbl_gfx

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
	movea.l	scr,a0
	lea	640(a0),a1
	lea	(199*640.l,a0),a2
	lea	(200*640.l,a0),a3
	moveq	#0,d1
	move.w	.barwidth(pc),d1
	add.l	d1,d0
	move.l	d0,.progress
	lsr.l	#8,d0
	subq.w	#1,d0
	move.w	#$f800,d1
.progressbarpixloop:
	move.w	d1,(a0)+
	move.w	d1,(a1)+
	move.w	d1,-(a2)
	move.w	d1,-(a3)
	dbra	d0,.progressbarpixloop

	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	addq.w	#1,d0
	bra	.loop

.rts:
	move.w	d0,-(sp)
	lea	wheelanim_txt,a1
	jsr	UNLOAD_INCFILE
	lea	funinduload_txt,a1
	jsr	UNLOAD_INCFILE
	move.w	(sp)+,d0

	move.w	.old468(pc),d1
.waitvbl:
	cmp.w	$468.w,d1
	beq.s	.waitvbl
	move.l	#rts,vbl_gfx
	rts

.old468:
	DC.W	0
.objectcount:
	DC.W	0
.progress:
	DC.L	0
.barwidth:
	DC.W	0

PLOT_WHEELGFX:
	moveq	#0,d0
	move.w	wheelframe,d0
	addq.w	#1,d0
	move.w	d0,wheelframe
	cmpi.w	#vga100,monitormode
	bne.s	.plot
	lsr.w	#1,d0
.plot:	lsr.w	#1,d0
	divu.w	#6,d0
	swap	d0
	mulu.w	#83*75*2,d0
	movea.l	wheelanimadr,a1
	adda.l	d0,a1
	movea.l	scr,a0
	adda.l	#(320*24+196)*2,a0

	moveq	#75-1,d7
.yloop:	REPT	83/2
	move.l	(a1)+,(a0)+
	ENDR
	move.w	(a1)+,(a0)+
	lea	(320-83)*2(a0),a0
	dbra	d7,.yloop
	rts

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

r3210t5_fv:
	INCBIN	R3210W.FV
r3220t5_fv:
	INCBIN	R3220W.FV
r322045_fv:
	INCBIN	R3220_45.FV
r3224t5_fv:
	INCBIN	R3224_T5.FV
r322485_fv:
	INCBIN	R3224_85.FV
v3220t5_fv:
	INCBIN	V3220_T5.FV

sine_tbl:
	INCBIN	SINUS.DAT

dspos_p56:
;	INCBIN	DSPOS.P56
enddspos:

* Stuff for GEM settings dialog.
rscfilename_txt:
	DC.B	"SETTINGS.RSC",0

* Stuff for loader screen.
wheelanim_txt:
	DC.B	"WHEEL.RAW",0
funinduload_txt:
	DC.B	"FUNINDU3.RAW",0
earxload_txt:
	DC.B	"EARXLOAD.RAW",0

* STuff for MODs
alivemod_txt:
	DC.B	"HEREWEGO.MOD",0
kickingmod_txt:
	DC.B	"EARX.MOD",0

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
old118:	DS.L	1
fvbuf:	DS.W	24
falcsave_pal:
	DS.L	256

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
starttime:
	DS.L	1

* Keyboard + mouse STuffs.
mse_tbl	ds.w	5
keycode	ds.w	1

* Scr-stuff
scr:	DS.L	4

* Stuff for GEM settings dialog.
treeadr:
	DS.L	1
vdopopupadr:
	DS.L	1
detailpopupadr:
	DS.L	1
dialogsize_tbl:
	DS.L	2

* STuff for mods
alivemodadr:
	DS.L	1
kickingmodadr:
	DS.L	1

* Stuff for loader screen.
wheelanimadr:
	DS.L	1
earxloadadr:
	DS.L	1
wheelframe:
	DS.W	1

* shared buffer
temp_buf:
	DS.L	512*256