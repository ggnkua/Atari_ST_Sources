*                       /----------<<<==>>>----------\    =>
*                <=    / |     ST DEMO-OS v1.0      | \            =>
*      <=              \ | 03-02-1999 by EarX<=>fUn | /       =>
*             <=        \----------<<<==>>>----------/  =>

******** ASM OPTIONS AND PATHS ********

	OPT	P=68000
	OPT	D-

******** INCLUDES ********

	bra	START

* Library-includes go in here..
	INCLUDE	MKSINST.I
	TEXT
;archivemode:	EQU	1
;	INCLUDE	INCLOAD.I
	TEXT

******** GLOBAL EQUS ********

triggermode:	EQU	1			* 0=manual effect-trigger, 1=event-table trigger
testmode:	EQU	0			* debug mode
objectmode:	EQU	1			* Must always be 1!

* computertype equates
st:		EQU	0
falcon:		EQU	1

scrxbytes:	EQU	160
scrlines:	EQU	200
maxscrsize:	EQU	scrxbytes*scrlines
* monitormode-equ's
autodetect:	EQU	0
rgb50:		EQU	1			* RGB/TV, 50Hz
vga60:		EQU	2			* VGA, 60Hz, noniterlaced
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
* Reserve RAM for screens.
	move.l	#maxscrsize*3+256,-(sp)		* size of screens..
	move.w	#$48,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d0
	bgt.s	.ramok
* Not enough RAM free :(
	clr.w	-(sp)
	trap	#1
* Initialize screenaddresses..
.ramok	lea	scr,a0
	addi.l	#$000000ff,d0
	sub.b	d0,d0
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

	IFEQ	testmode

* Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr
* Falcon check..
	move.l	$05a0.w,a0
	cmpa.l	#0,a0
	beq	.st
.fndmch:
	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found:	cmpi.w	#3,4(a0)
	bne	.st
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
	beq	N_EXIT				* Arg! mono monitor!
	btst	#0,d0
	beq.s	.vga
	move.w	#rgb50,monitormode
	bra.s	.endmonitorcheck
.vga:	move.w	#vga60,monitormode
.endmonitorcheck:
	ENDC
* Save resolution..
	bsr	SAVE_FV
* Computer is a Falcon.
	move.w	#falcon,computer
	bra.s	.falc

* Computer is an ST.
.st:	move.w	#st,computer
	move.b	$ffff8260.w,oldstres

.falc:	bsr	SAVE_SYSTEMVARS

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal_tbl

* Install own vbl-routine..
	move	#$2700,sr
	move.l	#NEWVBL,$70.w
	move.l	#NEW118,$118.w
	bclr	#3,$fffffa17.w			* Set hardware end of interrupt for easier & faster interrupts.
	move	#$2300,sr

	lea	song_spl,a0
	lea	song_pat,a1
	jsr	amsidplay_bin			* Relocate amshit player and play
	move.l	#amsidplay_bin+4,music_irq

	ENDC					* IFEQ testmode

	lea	event_tbl,a0
	bsr	INIT_DEMOPARTS
	move.w	d0,objectcount

	lea	event_tbl,a0
	lea	subeffect_tbl,a1
	move.w	objectcount,d0
	bsr	CHECK_DEMOEVENTS

	IFNE	triggermode

	move.l	$466.w,starttime

mainloopcycle:
	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	move.l	actpartadr,d0
	beq.s	.do
	movea.l	d0,a0
	move.l	(a0),a1
	jsr	(a1)
.do:	lea	event_tbl,a0
	bsr	DO_DEMOEVENTS
	bra.s	mainloopcycle

	ELSE

triggerloopcycle:
	addq.w	#1,.cyclecount
	moveq	#0,d0
	move.b	$fffffc02.w,d0
	cmp.w	.oldkey(pc),d0
	seq.b	d1
	move.w	d0,.oldkey
	cmpi.b	#$39,d0
	beq	OUT
	cmpi.w	#.subeffects-.key2object_tbl,d0
	bhs.s	.do_subeffect
	lea	.key2object_tbl,a0
	move.b	(a0,d0.l),d0
	beq.s	.do_old
	cmp.w	objectcount,d0
	bhi.s	.do_old
	movea.l	event_tbl,a0
	lsl.l	#2,d0
	movea.l	(a0,d0.l),a0
	cmpa.l	actpartadr,a0
	beq.s	.do_old
	move.w	d0,.actpart			* / Kick in new
	move.l	a0,actpartadr			* \ object.
	movea.l	8(a0),a0			*
	jsr	(a0)				* Jump to res-setter.
.do_old:
	move.l	actpartadr,d0
	beq.s	triggerloopcycle
	move.l	d0,a0
	movea.l	(a0),a0
	jsr	(a0)				* Jump to fx-mainloop.
	bra.s	triggerloopcycle
.do_subeffect:
	lea	.key2object_tbl,a0
	move.b	(a0,d0.l),d0
	beq.s	.do_old
	move.b	d1,d1
	bne.s	.do_old
	move.l	actpartadr,d2
	beq	triggerloopcycle
	movea.l	d2,a0
	move.w	.actpart(pc),d1
	lea	subeffect_tbl,a1
	cmp.b	(a1,d1.w),d0
	bhs.s	.do_old
	lsl.l	#2,d0
	movea.l	8(a0,d0.l),a0
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
	DC.W	towercode+2
	DC.L	0
	DC.W	towercode
	DC.L	0
	DC.W	towercode+13
	DC.L	450
	DC.W	towercode+14
	DC.L	450
	DC.W	towercode+4
	DC.L	450
	DC.W	towercode+9
	DC.L	510
	DC.W	towercode+11
	DC.L	616
	DC.W	towercode+10
	DC.L	750
	DC.W	towercode+5
	DC.L	750
	DC.W	towercode+9
	DC.L	916
	DC.W	towercode+10
	DC.L	1050
	DC.W	towercode+6
	DC.L	1050
	DC.W	towercode+9
	DC.L	1216
	DC.W	towercode+10
	DC.L	1350
	DC.W	towercode+7
	DC.L	1350
	DC.W	towercode+9
	DC.L	1516
	DC.W	towercode+10
	DC.L	1650
	DC.W	towercode+8
	DC.L	1650
	DC.W	towercode+9
	DC.L	2016
	DC.W	towercode+10
	DC.L	2050
	DC.W	towercode+3
	DC.L	2250
	DC.W	towercode+12
	DC.L	2700
	DC.W	dungeoncode+2
	DC.L	2700
	DC.W	dungeoncode
	DC.L	10000
	DC.W	0
.end:

towercode:	EQU	1<<8
dungeoncode:	EQU	2<<8

eventpart_tbl:
	DC.L	OUT
	DC.L	tower_tbl
	DC.L	dungeon_tbl
	DC.L	0

* Included objects::

	INCLUDE	ST_TOWER.SO STTOWERV.SO
	INCLUDE	DUNGEON.SO

******** EXITTING CODE ********

OUT:
	IFEQ	testmode

	movem.l	savepal_tbl,d0-d7
	movem.l	d0-d7,$ffff8240.w

	cmpi.w	#falcon,computer
	beq.s	.falc

	move.b	oldstres,$ffff8260.w
	bra.s	EXIT
	
.falc:	lea	save_fv,a0
	bsr	CHANGE_FVFAST

EXIT:	jsr	amsidplay_bin+8

	bsr	RESTORE_SYSTEMVARS

	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	ENDC

N_EXIT:	clr.w	-(sp)
	trap	#1

******** DEMO-OS SUBROUTINES ********

SAVE_FV:
	lea	save_fv,a1
	move.l	#'FVD2',(a1)+			* 4 bytes header
	move.b	$ffff8006.w,(a1)+		* monitor type
	move.b	$ffff820a.w,(a1)+		* sync
	move.l	$ffff820e.w,(a1)+		* offset & vwrap
	move.w	$ffff8266.w,(a1)+		* spshift
	move.l	#$ff8282,a0			* horizontal control registers
.loop1:	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a0
	bne	.loop1
	move.l	#$ff82a2,a0			* vertical control registers
.loop2:	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a0
	bne	.loop2
	move	$ffff82c2.w,(a1)+		* video control
	move	$ffff82c0.w,(a1)+		* video clock
	move.b	$ffff8260.w,(a1)+		* shifter resolution
	move.b	$ffff820a.w,(a1)+		* video sync mode
	rts

RESTORE_FV:
	lea	save_fv,a0
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
	tst.w	centurbofound
	bne.s	.extclock
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

SAVE_SYSTEMVARS:
* Save loads of interrupt crap.
	move    #$2700,SR
	lea     sys_var,a0
	move.l  $0070.w,(a0)+
	move.l  $0068.w,(a0)+
	move.l  $0110.w,(a0)+
	move.l	$0114.w,(a0)+
	move.l	$0118.w,(a0)+
	move.l  $0120.w,(a0)+
	move.l	$0134.w,(a0)+
	lea     $fffffa00.w,a1
	move.b	$01(a1),(a0)+
	move.b	$03(a1),(a0)+
	move.b	$05(a1),(a0)+
	move.b  $07(a1),(A0)+
	move.b  $09(a1),(A0)+
	move.b	$0b(a1),(a0)+
	move.b	$0d(a1),(a0)+
	move.b	$0f(a1),(a0)+
	move.b  $11(a1),(A0)+
	move.b  $13(a1),(A0)+
	move.b  $15(a1),(A0)+
	move.b  $17(a1),(A0)+
	move.b	$19(a1),(a0)+
	move.b  $1B(a1),(A0)+
	move.b	$1d(a1),(a0)+
	move.b	$1f(a1),(a0)+
	move.b  $21(a1),(A0)+
	move.b  $23(a1),(A0)+
	move.b  $25(a1),(A0)+
	move.b  $0484.w,(A0)+
	move	#$2300,sr
	rts

RESTORE_SYSTEMVARS:
	move    #$2700,sr
	clr.b   $fffffa1b.w     ;Timer B stoppen
        lea     sys_var,a0
	move.l  (a0)+,$0070.w
	move.l  (a0)+,$0068.w
	move.l  (a0)+,$0110.w
	move.l	(a0)+,$0114.w
	move.l	(a0)+,$0118.w
	move.l  (a0)+,$0120.w
	move.l	(a0)+,$0134.w
	lea     $fffffa00.w,A1
	move.b	(a0)+,$01(a1)
	move.b	(a0)+,$03(a1)
	move.b	(a0)+,$05(a1)
	move.b  (A0)+,$07(A1)
	move.b  (A0)+,$09(A1)
	move.b	(a0)+,$0b(a1)
	move.b	(a0)+,$0d(a1)
	move.b	(a0)+,$0f(a1)
	move.b  (a0)+,$11(A1)
	move.b  (a0)+,$13(A1)
	move.b  (a0)+,$15(A1)
	move.b  (a0)+,$17(A1)
	move.l	a0,a2
	clr.b	$19(a1)
	clr.b	$1b(a1)
	clr.b	$1d(a1)
	addq	#3,a0
	move.b	(a0)+,d0 $1f(a1)
	move.b  (A0)+,d0 $21(A1)
	move.b  (A0)+,d0 $23(A1)
	move.b  (A0)+,d0 $25(A1)
	move.b	(a2)+,$19(a1)
	move.b	(a2)+,$1B(A1)
	move.b	(a2)+,$1d(a1)
	move.b  (a0)+,$0484.w
	move    #$2300,SR
	rts

CLEAR_STSCREEN:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	movea.l	d1,a1
	movea.l	d1,a2
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	movea.l	d1,a6

	move.w	#153-1,d0
	lea	32000(a0),a0
.cl2	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	dbra	d0,.cl2
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d5,-(a0)
	rts

* INPUT: a0: address of eventtable
INIT_DEMOPARTS:
	moveq	#0,d0				* d0.w: objectcounter
	movea.l	(a0),a0				* a0: address of part-table
	addq	#4,a0				* a0: address of first object-pointer

.loop:	move.l	(a0)+,d1
	beq.s	.rts
	movea.l	d1,a1
	move.l	4(a1),a1
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	jsr	(a1)				* Jump to init-subroutine.
	movea.l	(sp)+,a0
	move.w	(sp)+,d0
	addq.w	#1,d0
	bra	.loop

.rts:	rts

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
	move.l	$466.w,d1
	sub.l	starttime,d1
	cmp.l	d0,d1
	blt.s	.rts
	move.w	(a0)+,d1
	beq	OUT
	move.w	d1,d0
	lsr.w	#8,d0
	andi.w	#$00ff,d1
	bne.s	.intern
	lsl.w	#2,d0
	move.l	(a1,d0.w),actpartadr
	bra.s	.out
.intern	lsl.w	#2,d0
	move.l	(a1,d0.w),a0
	lsl.w	#2,d1
	move.l	(a0,d1.w),a0
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
	movea.l	a1,a4
	clr.b	(a1)+
	move.l	(a0),a2
	addq	#4,a2
.countloop:
	move.l	(a2)+,d2
	beq.s	.endcounting
	movea.l	d2,a3
	lea	3*4(a3),a3
	moveq	#0,d1
.incountloop:
	addq.w	#1,d1
	tst.l	(a3)+
	bne.s	.incountloop
	move.b	d1,(a1)+
	bra.s	.countloop
.endcounting:

	move.l	(a0)+,a1
	move.l	(a1),a1				* a1: address of outaddress
	move.w	(a0),d7				* d7.w: number of events
	addq	#4,a0
	subq.w	#1,d7
	bmi.s	.rts
.loop:	addq	#4,a0
	move.w	(a0)+,d1
	move.b	d1,d2
	lsr.w	#8,d1
	cmp.w	d0,d1
	ble.s	.ok
	jmp	(a1)
.ok:	subq.b	#1,d2
	cmp.b	(a4,d1.w),d2
	ble.s	.ok2
	jmp	(a1)
.ok2:	dbra	d7,.loop
.rts	rts

******** INTERRUPTS ********

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	movea.l	music_irq(pc),a0
	jsr	(a0)
	movea.l	pal_irq(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

music_irq:
	DC.L	dummy
pal_irq:
	DC.L	notimerb

dummy:	rts
notimerb:
	move	#$2700,sr
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move	#$2300,sr
	rts

NEW118:
.keylop:
	tst.b	$fffffc02.w
	bclr    #6,$FFFFFA11.w			* isrb
	btst    #4,$FFFFFA01.w			* gpip
	beq.s   .keylop
	rte

******** DATA + INCBINS ********

	DATA

	EVEN

* FV2 video binaries
stlowrgb_fv:
	INCBIN	STLOWRGB.FV
stlowvga_fv:
	INCBIN	STLOWVGA.FV

sine_tbl:
	INCBIN	SINUS.DAT

song_pat:
	INCBIN	ALTAIR_4.TRI
	EVEN
song_spl:
	INCBIN	ALTAIR_4.TVS
	EVEN
amsidplay_bin:
	INCBIN	AMSID3D3.BIN

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
oldstres:
	DS.W	1
savepal_tbl:
	DS.W	16
save_fv:
	DS.W	24
sys_var:
	DS.L	19

* VIDEL mode shit
computer:
	DS.W	1
monitormode:
	DS.W	1
centurbofound:
	DS.W	1

* Object handling
objectcount:
	DS.W	1
subeffect_tbl:
	DS.B	128

* Timer stuffs
starttime:
	DS.L	1

* Scr-stuff
scr:	DS.L	3

* Temporary shared buffer
temp_buf:
	DS.L	1<<17