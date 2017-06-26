*                      [=/\===/\===/\===/\===/\===/\=]
*                     /: ST FX testing skeleton v1.1 :\
*                     \: 01-06-1999 by |EarX|->fUn<- :/
*                      [=\/===\/===\/===\/===\/===\/=]

******** ASM OPTIONS ********

	COMMENT	HEAD=%001
	OPT	P=68000
	OPT	O-
;	OPT	D-

******** LIBRARIES ********

	bra	START

	INCLUDE	MKSINST.I
	TEXT
;	INCLUDE	INCLOAD.I
;	TEXT

******** GLOBAL CONSTANTS ********

objectmode:	=	0			* demo-os inclusion mode (dummy)
testmode:	=	0			* handy debug mode

* computertype equates
st:		=	0
falcon:		=	1
* monitormode-equates for falcon
autodetect:	=	0
rgb50:		=	1			* RGB/TV, 50Hz
vga100:		=	2			* VGA, 100Hz, interlaced
vga60:		=	3			* VGA, 60Hz, noninterlaced
* screendimension-equates
scrxbytes:	=	320/2			* number of bytes per scanline
scrlines:	=	200			* number of scanlines
maxscrsize:	=	scrxbytes*scrlines	* max. size of screen

monitorequ:	=	autodetect		* current monitormode

longeven:	MACRO
		IFGT	*&3
		DS.B	4-(*&3)
		ENDC
		ENDM

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
.ramok:	lea	scr,a0
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

* Check if the demo-object table has all necessary entries..
	lea	demoobj_tbl,a0
	moveq	#3-1,d7
.chklp:	tst.l	(a0)+
	beq	N_EXIT				* On premature NULL > go out!
	dbra	d7,.chklp

	IFEQ	testmode
	bsr	SAVE_SYSTEMVARS
* Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr
* Falcon check..
	move.l	$05a0.w,a0
	cmpa.l	#0,a0
	beq	.st

; Check out if it's an ST or better (STe, Falcon, TT).
.fndvdo:cmpi.l	#"_VDO",(a0)
	addq	#8,a0
	bne.s	.fndvdo
	tst.w	4(a0)
	beq.s	.st
	st	enhanced
	cmpi.w	#3,4(a0)
	bne.s	.no_falcon

; Set monitormode for Falcon.
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
.vga:	move.w	#vga100,monitormode	;move.w	#vga60,monitormode
.endmonitorcheck:
	ENDC
* Install own vbl-routine..

* Computer is a Falcon.
.installvbl:
* Save resolution..
	bsr	SAVE_FV
	move.w	#falcon,computer
	bra.s	.falc

.no_falcon:

* Computer is an ST.
.st:	move.w	#st,computer
	move.b	$ffff8260.w,oldstres

.falc:	move	#$2700,sr
	move.l	#NEWVBL,$70.w
	move.l	#NEWTIMERC,$114.w
	move.l	#NEW118,$118.w
	bclr	#5,$fffffa07.w			* Disable timer A!!
	bclr	#5,$fffffa09.w			* Disable timer C!!
	bclr	#4,$fffffa09.w			* Disable timer D!!
	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa15.w
	move.b	#%01000000,$fffffa09.w
	move.b	#%01000000,$fffffa17.w
	bclr	#3,$fffffa17.w			* Set hardware end of interrupt for easier & faster interrupts.
	move	#$2300,sr
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savepal_tbl

; set st low resolution..
	lea	$FFFF8240.w,a0
	clr.l	d0
	REPT	8
	move.l	d0,(a0)+
	ENDR
	bsr	set_stlow
	ENDC

	movea.l	demoobj_tbl+4,a0
	jsr	(a0)				* Initialize demo-fx.
;	movea.l	demoobj_tbl+8,a0
;	jsr	(a0)				* Set resolution for demo-fx.

	IFEQ	testmode
	move.l	$4ba.w,starttime
	ENDC
	clr.l	frmcnt
	clr.l	lastfrmcnt

singlefxloop:
	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	movea.l	demoobj_tbl,a0
	jsr	(a0)				* Jump to demo-fx main.
	addq.l	#1,frmcnt
;	cmpi.l	#700,frmcnt
;	bne.s	singlefxloop
;	movea.l	demoobj_tbl+12,a0
;	jsr	(a0)
	bra.s	singlefxloop

******** BEGIN OF DEMO-EFFECT OBJECT ********

* Include demo-object in here..
demoobj_tbl:
;	INCLUDE	SCAPGOA2.SO
;	INCLUDE	ST_TOWER.SO
;	INCLUDE	STATOWER.SO
;	INCLUDE	STTOWERV.SO
;	INCLUDE	DUNGEON.SO
;	INCLUDE	DUNGEON2.SO
;	INCLUDE	DUNGEON3.SO
	INCLUDE	DUNGEON4.SO
;	INCLUDE	REFLECT.SO
;	INCLUDE	PODPIC.SO

******** RESTORING CODE ********

	TEXT

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

EXIT:	bsr	RESTORE_SYSTEMVARS

	move.l	oldscr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	;bsr	DISPLAY_FRMSPERSEC
	ENDC

N_EXIT:	clr.w	-(sp)
	trap	#1

******** SUBROUTINE CODE ********

set_stlow:
	cmpi.w	#falcon,computer
	beq.s	.falc
	clr.b	$ffff8260.w
	rts

.falc:	move.w	monitormode,d0
	cmpi.w	#vga60,d0
	beq.s	.vga
	cmpi.w	#vga100,d0
	beq.s	.vga
	cmpi.w	#rgb50,d0
	beq.s	.rgb50
* Unknown monitormode..
	rts
.vga:	MOVE.L	#$170012,$FFFF8282.W
	MOVE.L	#$1020E,$FFFF8286.W
	MOVE.L	#$D0012,$FFFF828A.W
	MOVE.L	#$41903B9,$FFFF82A2.W
	MOVE.L	#$61008D,$FFFF82A6.W
	MOVE.L	#$3AD0415,$FFFF82AA.W
	MOVE.W	#$200,$FFFF820A.W
	MOVE.W	#$186,$FFFF82C0.W
	CLR.W	$FFFF8266.W
	MOVE.B	#$0,$FFFF8260.W
	MOVE.W	#$5,$FFFF82C2.W
	MOVE.W	#$50,$FFFF8210.W
;	lea	stlowvga_fv,a0
;	bsr	CHANGE_FVFAST

	rts

.rgb50:	MOVE.L   #$003E0032,$FFFF8282.W
        MOVE.L   #$0009023F,$FFFF8286.W
        MOVE.L   #$001C0035,$FFFF828A.W
        MOVE.L   #$02710265,$FFFF82A2.W
        MOVE.L   #$001F006F,$FFFF82A6.W
        MOVE.L   #$01FF026B,$FFFF82AA.W
        MOVE.W   #$0200,$FFFF820A.W
        MOVE.W   #$0081,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.B   #$00,$FFFF8260.W
        MOVE.W   #$0000,$FFFF82C2.W
        MOVE.W   #$0050,$FFFF8210.W
	rts

* Saves the current falcon resolution to an internal buffer.
SAVE_FV:lea	save_fv+6,a1
	move.l	$ffff820e.w,(a1)+		* offset & vwrap
	move.w	$ffff8266.w,(a1)+		* spshift
	lea	$ffff8282.w,a0			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a0
	bne.s	.loop1
	lea	$ffff82a2.w,a0			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a0
	bne.s	.loop2
	move.w	$ffff82c2.w,(a1)+		* video control
	move.w	$ffff82c0.w,(a1)+		* video clock
	move.b	$ffff8260.w,(a1)+		* shifter resolution
	move.b	$ffff820a.w,(a1)+		* video sync mode
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
	move.w	(a0)+,$ffff82c0.w		* video clock
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.stres
	addq	#1,a0				* st res
	bra.s	.fres
.stres:	move.b	(a0)+,$ffff8260.w		* st res
.fres:	move.b	(a0)+,$ffff820a.w		* video sync mode
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

	IFNE	1

* Emulated 16bit * 32bit multiply. Beware that the product must be below 2^32.
* INPUT: d0.w: number to multiply with
*        d1.l: number to multiply
* OUTPUT: d1.l: result of multiplication
Mulu_WordLong:	MACRO	word,long,tempLong
		move.l	\2,\3
		mulu.w	\1,\2
		swap	\3
		mulu.w	\1,\3
		swap	\3
		eor.w	\3,\3
		add.l	\3,\2
		ENDM

Divu_LongLong:	MACRO	long,resLong,tempLong,tempLong2,tempLong3
		cmp.l	\1,\2
		blt.s	\@is_null
		moveq	#-1,\3
		move.l	\1,\4
		moveq	#0,\5
\@loop1:	addq.w	#1,\3
		add.l	\1,\1
		cmp.l	\1,\2
		bhi.s	\@loop1
\@loop2:	lsr.l	#1,\1
		sub.l	\1,\2
		bmi.s	\@skip_set
		bset	\3,\5
\@skip_set:	dbra	\3,\@loop2
		bra.s	\@end
\@is_null:	moveq	#0,\5
\@end:		move.l	\5,\2
		ENDM

Divu_LongBig:	MACRO	long,bigHigh,bigLow
		
		ENDM

* Displays a dialogbox with average framerate.
DISPLAY_FRMSPERSEC:
	move.l	frmcnt,d1
	moveq	#0,d2
	move.l	$4ba.w,d0
	sub.l	starttime,d0
	Mulu_WordLong	#200,d1,d2	;mulu.l	#200,d1
	;Divu_LongBig	d0,d2,d1	;divu.l	d0,d2:d1
	swap	d2
	Divu_LongLong	d0,d2,d3,d4,d5	;divu.l	d0,d2	
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
.pre2	move.b	#".",(a0)+
	moveq	#5-1,d7
	;mulu.l	#$000186a0,d0:d2		
	move.w	d0,d2
	swap	d2
	move.l	d2,d0
.loop2	divu.w	#10,d0
	swap	d0
	addi.b	#"0",d0
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

	ENDC

******** INTERRUPT ROUTINE CODE ********

NEW118:
.keylop:
	tst.b	$fffffc02.w
	bclr    #6,$FFFFFA11.w			* isrb
	btst    #4,$FFFFFA01.w			* gpip
	beq.s   .keylop
	rte

NEWTIMERC:
	addq.l	#1,$4ba.w
	rte

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	movea.l	musicirq(pc),a0
	jsr	(a0)
	movea.l	pal_irq(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

musicirq:
	DC.L	dummy
pal_irq:
	DC.L	dummy
notimerb:
	move	#$2700,sr
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w
	move	#$2300,sr
	rts

dummy:	rts

******** GLOBAL DATA + INCLUDES ********

	DATA

* FV2 video binaries
stlowrgb_fv:
	INCBIN	STLOWRGB.FV
stlowvga_fv:
	INCBIN	STLOWVGA.FV

* AES parameter block
aespb:	DC.L	contrl,global,intin,intout,addrin,addrout

sine_tbl:
	INCBIN	SINUS.DAT

******** GLOBAL RESERVES ********

	BSS

	EVEN
*init-data
	DS.L	256
ustk:	DS.L	1
oldscr:	DS.L	1
oldstres:
	DS.W	1
savepal_tbl:
	DS.W	16
save_fv:
	DS.W	24
sys_var:
	DS.L	19

* VIDEL stats
computer:
	ds.w	1
enhanced:
	ds.w	1
monitormode:
	ds.w	1

*GEM-shit
contrl:	DS.W    12
intin:	DS.W    128
intout:	DS.W    128
global:	DS.W    16
addrin:	DS.W    128
addrout:
	DS.W    128

*counter/timer shit
frmcnt:	DS.L	1
lastfrmcnt:
	DS.L	1
starttime:
	DS.L	1

*scr-stuff
scr:	DS.L	3

*temporary shared buffer
temp_buf:
	DS.B	512*1024		; too much?

