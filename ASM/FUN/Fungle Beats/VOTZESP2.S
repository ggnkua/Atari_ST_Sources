*                      ===============================
*                      |  FX testing skeleton v1.2   |
*                      | 01-07-1998 by |EarX|->fUn<- |
*                      ===============================
*
* v1.0: * 3 screens
*       * ST-resolution compatible res-switcher
*       * TT-RAM aware
*       * frames/sec. counter
*
* v1.1: * Frames/sec counter now displays dialog-box + is vbl-independent
*       * Falcon check
*
* v1.2: * Handy bedug mode

* VOTZEL-SPAž ;-) by: EarX / fUn
* Guess this is the fastest voxel the falcon has ever seen..

******** ASM OPTIONS ********

;	OPT	D-

******** LIBRARIES ********

	bra	START

	INCLUDE	MKSIN3.I
	TEXT
	INCLUDE	IO.S
	TEXT

******** GLOBAL CONSTANTS ********

testmode	equ	0			* handy debug mode

scrxbytes	equ	640			* number of bytes per scanline
scrlines	equ	100			* number of scanlines
maxscrsize	equ	scrxbytes*scrlines	* max. size of screen

* Voxel controlling values
raylength	equ	64			* The bigger, the further the view stretches.
tunnelvision	equ	40			* The lower, the wider the view.

******** INITIALISING CODE ********

START	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$1000,d0
	add.l	#$100,d0
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
	move.l	#maxscrsize*3+256,-(sp)		* size of screens..
	move.w	#$44,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0				* Check if there is ST-RAM enough.
	bgt.s	.ramok
* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1
* Initialize screenaddresses..
.ramok	lea	scr,a0
	addq.l	#4,d0				* / long even
	andi.b	#%11111100,d0			* \ address..
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	move.l	#ustk,sp			* Install own stack..

	bsr	CALC_PERSPTABLES
	bsr	CALC_DISTTABLE

	IFEQ	testmode
* Save old screenaddress..
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
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
* Install own vbl-routine..
	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w
* Save resolution..
	bsr	SAVE_FV
* Check the monitor type and set resolution apropriately.
	move.b	$ffff8006.w,d0
	andi.b	#%11000000,d0
	tst.b	d0
	beq	EXIT
	btst	#6,d0
	bne.s	.rgb
	lea	v3220t5_fv,a0
	bsr	CHANGE_FVFAST
	bra.s	.on
.rgb	lea	r3220t5_fv,a0
	bsr	CHANGE_FVFAST
.on	move.l	$4ba.w,starttime

	not.l	$ffff9800.w
	ENDC

	move.w	#1000,trajectrec_tbl		* Set 1000 recorded events max!!

******** MAIN LOOP CODE ********

MAINLOOP
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	bsr	UPDATE_OBSERVER
	lea	color_pic,a1
	lea	height_pic,a2
	lea	cloud_pic,a3
	bsr	PLOT_VOXEL

	IFEQ	testmode
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	ENDC
	bra.s	MAINLOOP

******** RESTORING CODE ********

OUT	;bsr	SAVE_TRAJECTREC

	IFEQ	testmode
	not.l	$ffff9800.w

	lea	save_fv,a0
	bsr.s	CHANGE_FVFAST

EXIT	move.l	oldvbl,$70.w

	move.l	oldscr,d7
	swap	d7
	move.b	d7,$ffff8201.w
	rol.l	#8,d7
	move.b	d7,$ffff8203.w
	rol.l	#8,d7
	move.b	d7,$ffff820d.w

	bsr	DISPLAY_FRMSPERSEC
	ENDC

E_EXIT	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINE CODE ********

* Saves the current falcon resolution to an internal buffer.
SAVE_FV	lea	save_fv+6,a1
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
CHANGE_FVFAST
	addq	#6,a0				* Skip header + monitortype
	move.l	a0,a6
	move	sr,-(sp)
	move	#$2300,sr

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
.stres	move.b	(a0)+,$ffff8260.w		* st res
.fres	move.b	(a0)+,$ffff820a.w		* video sync mode
	move	(sp)+,sr
	rts

UPDATE_OBSERVER
	move.b	$fffffc02.w,d0
	bne.s	.go_on
	rts
.go_on:
.fwd:	cmpi.b	#$48,d0
	bne.s	.bwd
	addq.w	#1,.speed
	subq.w	#1,roll
	bra.s	.pos
.bwd:	cmpi.b	#$50,d0
	bne.s	.left
	subq.w	#1,.speed
	addq.w	#1,roll
	bra.s	.pos
.left:	cmpi.b	#$4b,d0
	bne.s	.right
	subi.w	#16,playerangle
	bra.s	.pos
.right:	cmpi.b	#$4d,d0
	bne.s	.up
	addi.w	#16,playerangle
	bra.s	.pos
.up:	cmpi.b	#$4e,d0
	bne.s	.down
	addi.w	#128,elevation
	bra.s	.pos
.down:	cmpi.b	#$4a,d0
	bne.s	.pos
	subi.w	#128,elevation
.pos:	move.w	.speed(pc),d3
	move.l	$4ba.w,d1
	move.l	d1,d2
	sub.l	.last4ba(pc),d1
	move.l	d2,.last4ba
	mulu.w	d1,d3
	lsr.w	#4,d3
	move.w	playerangle,d0
	Do_SinModulo	d0
	move.w	(xanglestep_tbl,d0.w*2),d1
	move.w	(yanglestep_tbl,d0.w*2),d2
	muls.w	d3,d1
	muls.w	d3,d2
	asr.w	#4,d1
	asr.w	#4,d2
	add.w	d1,playerx
	add.w	d2,playery
	rts

.speed	DC.W	0
.last4ba:
	DC.L	0

CALC_PERSPTABLES:
* Calculate conventional 1/Z-table first.
	lea	persp_tbl,a0
	move.l	#1024,d1
	moveq	#1,d7
	move.w	#raylength,d6
.loop	move.l	d1,d0
	divu.w	d7,d0
	move.w	d0,(a0)+
	addq.w	#1,d7
	cmp.w	d6,d7
	bls.s	.loop
* Then calculate precalced 2d-height for the 256 3d-heights at every Z
* point.
	lea	persp_tbl,a1
	lea	zheight_tbl,a0
	move.w	#raylength-1,d7
.loop2:	move.w	(a1)+,d0
	move.w	d0,d3
	moveq	#0,d2
.inloop2:
	move.w	d3,d0
	mulu.w	d2,d0
	lsr.l	#5,d0
	move.w	d0,(a0)+
	addq.w	#1,d2
	cmpi.w	#$0100,d2
	bne.s	.inloop2
	dbra	d7,.loop2
	rts

CALC_DISTTABLE:
	lea	xanglestep_tbl,a0
	lea	yanglestep_tbl,a1
	lea	sine_tbl,a2
	move.w	eyedistance,d2
	move.w	raydistance,d3
	move.w	#tunnelvision,d6
	move.w	#sintbllen-1,d7
.loop	movem.w	(a2)+,d0-d1			* Get next sin and cos.
	move.w	d0,d4
	move.w	d1,d5
	muls.w	d2,d4
	muls.w	d2,d5
	muls.w	d3,d0
	muls.w	d3,d1
	sub.l	d4,d0
	sub.l	d5,d1
	asr.l	#8,d0
	divs.w	d6,d0
	move.w	d0,(a1)+
	asr.l	#8,d1
	divs.w	d6,d1
	move.w	d1,(a0)+
	dbra	d7,.loop
	rts

* INPUT: a1: address of color-field
*        a2: address of height-field
*        a3: address of sky-picture
PLOT_VOXEL:
* Initialize drawing stuffs..
	lea	persp_tbl,a4
	lea	.persp_tbl(pc),a0
	move.w	#raylength,d7
	moveq	#12,d2
	move.w	roll,d3
	subq.w	#1,d7
	move.w	elevation,d1
.plop:	move.w	(a4)+,d0
	mulu.w	d1,d0
	lsr.l	d2,d0
	add.w	d3,d0
	move.w	d0,(a0)+
	dbra	d7,.plop

	movem.l	a1-a2,-(sp)
* Initialize angle of first ray..
	moveq	#0,d1
	move.w	playerangle,d1
	subi.w	#480,d1
	Do_SinModulo	d1
	move.w	d1,.rayangle
* Plot the sky..
	lsr.w	#2,d1
;	divu.w	#320,d1
;	swap	d1
	andi.w	#$00ff,d1
	lea	(a3,d1.w*2),a1
	movea.l	scr,a0
	move.w	d0,d7
	move.l	#((raylength-1)<<8)+50,d1	* Index to lowest 2d-height
	sub.w	(zheight_tbl,d1.l*2),d7
	cmpi.w	#scrlines-1,d7
	bls.s	.nchk
	moveq	#scrlines-1,d7
.nchk:	tst.w	d7
	bmi	.endsky
.cplop:	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*2(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*3(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*4(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*5(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*6(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*7(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*8(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*9(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*10(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*11(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*12(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,48*13(a0)
	lea	scrxbytes(a0),a0
	lea	-(320-256)*2(a1),a1
	dbra	d7,.cplop
.endsky:
	movem.l	(sp)+,a1-a2
* Draw the Voxel itself.
	movea.l	scr,a0
	adda.l	#scrxbytes*(scrlines-1),a0
	move.w	#scrxbytes/4-1,d7
	lea	(a0),a6
	moveq	#0,d5
	move.w	.rayangle(pc),d0

.xloop:
	move.w	playerx,d1
	move.w	playery,d2
	move.w	(xanglestep_tbl,d0.w*2),.gxstep
	move.w	(yanglestep_tbl,d0.w*2),.gystep
;	move.w	d7,d6
;	subi.w	#160,d6
;	muls.w	tiltx,d6
;	move.w	d6,.tiltfactor
	move.w	#scrlines,d0			* topmountain:=scrlines
	lea	zheight_tbl,a3
	lea	.persp_tbl(pc),a4
	move.w	#raylength-1,d6			* Number of steps in ray..

.rayloop:
	move.w	d2,d5
	move.w	d1,d4
	ror.w	#8,d4
	move.b	d4,d5				* d5.l: position in map
	moveq	#0,d4
	move.b	(a2,d5.l),d4			* d4.l: height
	move.w	(a4)+,d3
	move.w	(a3,d4.l*2),d4			* Optimised multiply and shift.
	lea	$100*2(a3),a3			* Move to next multiply-table.
	sub.w	d4,d3				* Get onscreen height of current point.
;	add.w	.tiltfactor(pc),d3
.cmp:	move.w	d0,d4
	sub.w	d3,d4
	ble.s	.endl
	move.l	(a1,d5.l*4),a5			* a5.l: color
	subq.w	#1,d4
	tst.w	d3				* / For clipping off
	bmi.s	.rest				* \ the mountains.
.pixlp:	move.l	a5,(a0)
	lea	-scrxbytes(a0),a0		* Go up one screenline.
	dbra	d4,.pixlp
	move.w	d3,d0				* topmountain:=newpos
.endl:	add.w	.gxstep(pc),d1			* / Move to next map-
	add.w	.gystep(pc),d2			* \ position in ray.
	dbra	d6,.rayloop
	bra.s	.nxt

.rest:	subq.w	#1,d0
	bmi.s	.nxt
.pixlp2:
	move.l	a5,(a0)
	lea	-scrxbytes(a0),a0		* Go up one screenline.
	dbra	d0,.pixlp2

* Increase angle..
.nxt:	move.w	.rayangle(pc),d0
	addq.w	#6,d0
	Do_SinModulo	d0
	move.w	d0,.rayangle
* Kick in next vertical screenline and loop..
	addq	#4,a6
	lea	(a6),a0
	dbra	d7,.xloop
	rts

.rayangle:
	ds.w	1				* Angle of current ray
.gxstep:
	ds.w	1
.gystep:
	ds.w	1				* Fixed point step value of ray
.tiltfactor:
	ds.w	1
.persp_tbl:
	ds.w	raylength
.sky_tbl
	ds.w	1
	ds.w	320

DISPLAY_FRMSPERSEC
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

.temp_txt
	ds.b	256
.alertpre_txt
	dc.b	"[1][ Average framerate: | ][ OK ]",0
	even

.alert_tbl
	dc.w	$0034,$0001,$0001,$0001,$0000

SAVE_TRAJECTREC:
	lea	trajectrec_tbl,a1
	lea	trajectfilename_txt,a0
	move.w	2(a1),d0
	mulu.w	#6,d0
	addq.l	#4,d0
	bsr	save
	rts

******** INTERRUPT ROUTINE CODE ********

NEWVBL	addq.l	#1,$466.w
	rte

******** GLOBAL DATA + INCLUDES ********

v3220t5_fv
;	incbin	vgatrue2.fv
r3220t5_fv
	INCBIN	R3210W.fv

sine_tbl:
	INCLUDE	SINUS.S

* AES parameter block
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

* General graphics info
	DS.W	1
height_pic:
	INCBIN	HEIGHT.PC8			* Ground_image
color_pic:
	INCBIN	GROUNDD.RAW			* Color_image
cloud_pic:
	INCBIN	CLOUD.RAW			* Background clouds bitmap

* View Variables
playerx:
	ds.w	1				* Viewer's coordinates
playery:
	ds.w	1
playerangle:
	ds.w	1				* Viewer's direction
elevation:
	dc.w	16000
raydistance:
	dc.w	64				* Length of rays
cloudx: dc.w	0				* Cloud position
eyedistance:
	dc.w	1				* Changes perspective
tiltx:	dc.w	0				* Amount of tilt
roll:	dc.w	50

trajectfilename_txt:
	DC.B	"C:\FUNGLE\TRAJECT.DAT",0

******** GLOBAL RESERVES ********

	bss
	even

*init-data
	ds.l	256
ustk	ds.l	1
oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
save_fv	ds.w	24

*GEM-shit
contrl	ds.w    12
intin	ds.w    128
intout	ds.w    128
global	ds.w    16
addrin	ds.w    128
addrout	ds.w    128

*counter/timer shit
frmcnt	ds.l	1
starttime
	ds.l	1

* Heightfield tables
persp_tbl:
	ds.w	raylength
zheight_tbl:
	ds.w	raylength*$100
xanglestep_tbl:
	ds.w	sintbllen
yanglestep_tbl:
	ds.w	sintbllen

trajectrec_tbl:
	ds.w	1				* number of entries
	ds.w	1				* current entry
	REPT	1000
	ds.l	1				* timepoint
	ds.w	1				* keycode
	ENDR

*scr-stuff
scr	ds.l	3