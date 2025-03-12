* EARchaeopteryx presents:  <.....>
*              <huHUhu> 'TWO BLOBS DOOOOIIIING IT' <HUhuHU>
* <HuHUhuHUhuhuHU COOL!>

* Atari Falcon only. RGB/TV/VGA
* NO CLIPPING!!!

******** ASM OPTIONS ********

;	OPT	D-

******** LIBRARY SHIT ********

	INCLUDE	MKSIN3.I

	text

******** GLOBAL CONSTANTS ********

* Radius of a blob-element. Must be > 0 and < 64. Or else it's
* assembler-error or runtime-error city!
blobradi	equ	54
blobrad		equ	blobradi/4*4
* Number of blobs to calculate/display. Can NOT be 0 or lower!!
numblobs	equ	4

scrxbytes	equ	640
scrlines	equ	100
maxscrsize	equ	scrxbytes*scrlines

clearscreen	equ	0

******** INITIALISING ********

START	move.l	4(sp),a5		* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$1000,d0
	add.l	#$100,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1		* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

* mxalloc - Reserve stram ONLY for screens.
	move.w	#0,-(sp)
	move.l	#maxscrsize*3+256,-(sp)	* size of screens..
	move.w	#$44,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			* Check if there is ST-RAM enough.
	bgt.s	.ramok

* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1

* Initialize screenaddresses..
.ramok	lea	scr,a0
	addq.l	#4,d0			* / long even
	andi.b	#%11111100,d0		* \ address..
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	move.l	#ustk,sp

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr

	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w

	bsr	SAVE_FV

	move.b	$ffff8006.w,d0		check da monitor-type
	andi.b	#%11000000,d0
	tst.b	d0
	beq	EXIT
	btst	#6,d0
	bne.s	.rgb

	lea	fv_vga(pc),a0
	bsr	CHANGE_FVFAST
	bra.s	.on

.rgb	lea	fv_rgb(pc),a0
	bsr	CHANGE_FVFAST

.on	bsr	INIT_SHADETAB

	bsr	PRECALC_BLOBBUFFERS

	move.l	$4ba.w,starttime

	not.l	$ffff9800.w

******** MAIN LOOP ********

mainloop
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	bsr	CALC_BLOBTRAJECTS
	bsr	PLOT_SLOW4BLOBS
;	bsr	PLOT_OPT4BLOBS
	bsr	SHOW_VBLUSE

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

	bra.s	mainloop

******** REINITIALISING ********

OUT	lea	save_fv(pc),a0
	bsr.s	CHANGE_FVFAST

EXIT	not.l	$ffff9800.w

	move.l	oldvbl,$70.w

	move.l	oldscr,d7
	swap	d7
	move.b	d7,$ffff8201.w
	rol.l	#8,d7
	move.b	d7,$ffff8203.w
	rol.l	#8,d7
	andi.b	#%11111100,d7
	move.b	d7,$ffff820d.w

	bsr	DISPLAY_FRMSPERSEC

	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINES ********

* Saves the current falcon resolution to an internal buffer.
SAVE_FV	lea	save_fv+6(pc),a1
	move.l	$ffff820e.w,(a1)+	* offset & vwrap
	move.w	$ffff8266.w,(a1)+	* spshift
	lea	$ffff8282.w,a0		* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a0
	bne.s	.loop1
	lea	$ffff82a2.w,a0		* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a0
	bne.s	.loop2
	move.w	$ffff82c2.w,(a1)+	* video control
	move.w	$ffff82c0.w,(a1)+	* video clock
	move.b	$ffff8260.w,(a1)+	* shifter resolution
	move.b	$ffff820a.w,(a1)+	* video sync mode
	rts

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST
	addq	#6,a0			* Skip header + monitortype
	move.l	a0,a6
	move	sr,-(sp)
	move	#$2300,sr

	move.l	(a0)+,$ffff820e.w	* offset & vwrap
	move.w	(a0)+,$ffff8266.w	* spshift
	lea	$ffff8282.w,a1		* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1		* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w	* video control
	move.w	(a0)+,$ffff82c0.w	* video clock
	cmpi.w	#$50,6(a6)		* ST resolution?
	blt.s	.stres
	addq	#1,a0			* st res
	bra.s	.fres
.stres	move.b	(a0)+,$ffff8260.w	* st res
.fres	move.b	(a0)+,$ffff820a.w	* video sync mode
	move	(sp)+,sr
	rts

* Routine that creates a simple color-flow and puts it in a table.
INIT_SHADETAB
	move.w	#%0000000000000001,d0
	move.w	#%0000000000000000,d1
	lea	colorflow_tbl,a0
	moveq	#32-1,d7
.lp	move.w	#128-1,d6
.inlp	move.w	d1,(a0)+
	dbra	d6,.inlp
	add.w	d0,d1
	dbra	d7,.lp

	move.w	#%0000000000011111,d1
	moveq	#32-1,d7
.lp2	move.w	#128-1,d6
.inlp2	move.w	d1,(a0)+
	dbra	d6,.inlp2
	subi.w	#%0000000000000001,d1
	addi.w	#%0000000000100000,d1
	dbra	d7,.lp2

	move.w	#%0000001111100000,d0
	moveq	#32-1,d7
.lp3	move.w	#128-1,d6
.inlp3	move.w	d0,(a0)+
	dbra	d6,.inlp3
	addi.w	#%0000000000100000,d0
	dbra	d7,.lp3

	move.w	#%0000011111100000,d0
	moveq	#32-1,d7
.lp4	move.w	#128-1,d6
.inlp4	move.w	d0,(a0)+
	dbra	d6,.inlp4
	addi.w	#%0000100000000000,d0
	dbra	d7,.lp4

	move.w	#%1111111111100000,d0
	moveq	#32-1,d7
.lp5	move.w	#128-1,d6
.inlp5	move.w	d0,(a0)+
	dbra	d6,.inlp5
	subi.w	#%0000000000100000,d0
	dbra	d7,.lp5

	move.w	#%1111110000000000,d0
	moveq	#32-1,d7
.lp6	move.w	#128-1,d6
.inlp6	move.w	d0,(a0)+
	dbra	d6,.inlp6
	addi.w	#%0000000000000001,d0
	dbra	d7,.lp6

	move.w	#%1111110000011111,d0
	moveq	#32-1,d7
.lp7	move.w	#256-1,d6
.inlp7	move.w	d0,(a0)+
	dbra	d6,.inlp7
	addi.w	#%0000000000100000,d0
	dbra	d7,.lp7

	moveq	#$ffffffff,d0
	move.w	#(8192+16384)-1,d7
.lp8	move.w	d0,(a0)+
	dbra	d7,.lp8

	rts

* Routine that precalculates the plottable picture of a blob-element and
* also the density-buffer for an element.
PRECALC_BLOBBUFFERS
* Calculate the density buffer..
	lea	blobdens_tbl+(blobrad*2*blobrad*2*2),a0
	moveq	#(blobrad*2)-1,d7

.yloop	moveq	#(blobrad*2)-1,d6
.xloop	move.w	d6,d0
	move.w	d7,d1
	subi.w	#blobrad,d0
	subi.w	#blobrad,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmpi.l	#blobrad*blobrad,d1
	blt.s	.in
	move.l	#$ffff,d0
	bra.s	.calc
.in	moveq	#0,d0
	divu.l	#(blobrad*blobrad),d1:d0
	eor.w	d0,d0
	swap	d0
.calc	move.l	#$ffff,d2
	sub.l	d0,d2
	mulu.w	d2,d2
	swap	d2
;	mulu.w	d2,d2
;	eor.w	d2,d2
;	swap	d2
	andi.l	#$ffff,d2
	divu.w	#numblobs,d2
	move.w	d2,-(a0)
	dbra	d6,.xloop
	dbra	d7,.yloop

* Calculate the highcolor-buffer out of the density-buffer.
	move.w	#(blobrad*2)-1,d7
	lea	blobdens_tbl,a1
	lea	colorflow_tbl,a2
	lea	blob_pic,a0
	moveq	#0,d1
.cnvlp	move.w	#(blobrad*2)-1,d6
.cxloop	move.w	(a1)+,d1
	move.w	(a2,d1.l*2),(a0)+
	dbra	d6,.cxloop
	dbra	d7,.cnvlp
	rts

* Update the circular-movement of the blobs and the plane they are in.
CALC_BLOBTRAJECTS
	lea	blobpos_tbl,a0
	lea	sine_tbl(pc),a1
	move.l	$4ba.w,d0
	sub.l	starttime(pc),d0
	asr.l	#1,d0
* Blob 1..
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#2,d1
	asr.w	#1,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 2..
	mulu.w	#5,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#1,d1
	asr.w	#1,d2
	move.w	d1,d6
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 3..
	neg.w	d0
	addi.w	#500,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#1,d1
	asr.w	#2,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 4..
	addi.w	#700,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#1,d1
	asr.w	#1,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+

	lea	blobpos_tbl,a0
	lea	4*4(a0),a1
	lea	(a0),a6
	REPT	6
	movem.w	(a0)+,d0-d1
	addi.w	#(scrlines/2)-blobrad,d0
	addi.w	#(scrxbytes/4)-blobrad,d1
	move.w	d1,(a1)+
	move.w	d0,(a1)+
	ENDR
	REPT	4
	addi.w	#(scrxbytes/4)-blobrad,(a6)+
	addi.w	#(scrlines/2)-blobrad,(a6)+
	ENDR
	rts

PLOT_SLOW4BLOBS
	lea	blobbasin_buf,a0
	bsr	CLEAR_SCREEN

	lea	blobpos_tbl,a5
	moveq	#numblobs-1,d7

.biglop	swap	d7
	lea	blobdens_tbl,a1
	lea	blobbasin_buf,a0
	movem.w	(a5)+,d0-d1
	muls.w	#640,d1
	add.l	d0,d0
	add.l	d1,a0
	add.l	d0,a0
	lea	(a0),a2
	adda.l	#((blobrad*2)-1)*640,a2
	lea	blobrad*4(a0),a3
	lea	blobrad*4(a2),a4
	move.w	#blobrad-1,d7
.loop1	moveq	#(blobrad/4)-1,d6
.iloop1	movem.l	(a1)+,d0-d3
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	add.l	d2,(a0)+
	add.l	d3,(a0)+
	add.l	d0,(a2)+
	add.l	d1,(a2)+
	add.l	d2,(a2)+
	add.l	d3,(a2)+
	dbra	d6,.iloop1
	lea	640-(blobrad*4)(a0),a0
	lea	-640-(blobrad*4)(a2),a2
	dbra	d7,.loop1
	swap	d7
	dbra	d7,.biglop

;	bra	PLOT_HEIGHTFIELD

	lea	blobbasin_buf,a1
	lea	colorflow_tbl,a2
	lea	sine_tbl,a0
	moveq	#0,d0
	move.w	$4bc.w,d0
	sub.w	starttime+2(pc),d0
	move.w	d0,d1
	lsl.w	#2,d0
	Do_SinModulo	d0
	lsr.w	#1,d0
	Get_Sin		a0,d0,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	addi.w	#$0040,d0
	mulu.w	#3,d1
	lsr.l	#1,d1
	Do_SinModulo	d1
	Get_SinCos	a0,d1,d6,d7
	asr.w	#8,d6
	asr.w	#1,d6	
	asr.w	#8,d7
	asr.w	#3,d7
	move.l	d0,d1
	neg.l	d1
	addi.l	#$00e0,d1
	move.l	#$0100,d0			* Voor 2*2 pix testen..
	move.l	#$0100,d1
	bra	PLOT_SCALEHEIGHTFIELD

PLOT_HEIGHTFIELD
	move.l	scr,a0
	lea	blobbasin_buf,a1
	lea	colorflow_tbl,a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	#(maxscrsize/8)-1,d7
.pllop	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.w	(a2,d0.l*2),(a0)+
	move.w	(a2,d1.l*2),(a0)+
	move.w	(a2,d2.l*2),(a0)+
	move.w	(a2,d3.l*2),(a0)+
	dbra	d7,.pllop
	rts

* Ongeoptimaliseerde scaler voor een heightfield (bijvoorbeeld voor blob-
* basin).
* INPUT: d0.l: 8.8 X-scalefactor
*        d1.l: 8.8 Y-scalefactor
*        d6.w: x-offset from center
*        d7.w: y-offset from center
*        a1: address of heightfield (word-entries)
*        a2: address of colortable (65536 highcolor words)
PLOT_SCALEHEIGHTFIELD
	move.l	#640,d5				* d5=offset to next line
	move.w	d0,d2
	mulu.w	#scrxbytes,d2
	lsr.l	#8,d2
	move.l	d5,d4
	sub.l	d2,d4
	lsr.l	#2,d4
	add.w	d6,d4
	add.l	d4,d4
	add.l	d4,a1
	moveq	#0,d3
	move.w	d1,d2
	move.w	#scrlines,d3
	mulu.w	d3,d2
	lsr.l	#8,d2
	sub.l	d2,d3
	lsr.l	#1,d3
	add.w	d7,d3
	mulu.w	#scrxbytes,d3
	add.l	d3,a1
        ror.l   #8,d0                           * d0=xx0000XX
	add.w	d1,d1
	ror.l	#8,d1				* d1=yy0000YY
        move.l  scr,a0
        move.w  #scrlines-2,d7

	move.w  #(scrxbytes/16)-1,d6
	moveq	#0,d3
	moveq	#0,d4
        add.l   d0,d3
.pxloop	REPT	4
	move.w  (a1,d3.w*2),d4
        move.l  (a2,d4.l*2),(a0)+
        addx.l  d0,d3
	ENDR
        dbra    d6,.pxloop

.yloop	add.l	d1,d2
	bcc.s	.copy
	lea	640(a1),a1
	move.w  #(scrxbytes/16)-1,d6
	moveq	#0,d3
	moveq	#0,d4
        add.l   d0,d3
.xloop	REPT	4
	move.w  (a1,d3.w*2),d4
        move.l  (a2,d4.l*2),(a0)+
        addx.l  d0,d3
	ENDR
	dbra    d6,.xloop
	bra	.dbra
.copy	lea	-scrxbytes(a0),a0
.coplop	REPT	20
	movem.l	(a0)+,d3-d6/a3-a6
	movem.l	d3-d6/a3-a6,scrxbytes-(8*4)(a0)
	ENDR
	lea	scrxbytes(a0),a0
.dbra	dbra    d7,.yloop
        rts

PLOT_OPT4BLOBS
	IFEQ	clearscreen
	move.l	scr,a0
	bsr	CLEAR_SCREEN
	ENDC

	lea	blobpos_tbl,a0
	moveq	#0,d7

.loop	movem.w	(a0)+,d0-d1			* Get coords and goto next pos.
	move.l	a0,-(sp)			* Save next coord-address.
	move.w	d7,vnum				* Save counter.
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#blobrad*2,d2
	addi.w	#blobrad*2,d3
	movem.w	d0-d3,-(sp)			* Push X1, Y1, X2, Y2
	bsr.s	REC_WINDOW
	addq	#8,sp
	move.w	vnum(pc),d7			* Restore counter.
	move.l	(sp)+,a0			* Restore address.
	addq.w	#1,d7
	cmpi.w	#numblobs,d7
	bne.s	.loop
	rts

vnum	ds.w	1

	RSRESET
* Format of local stackrecord:
	rs.w	1
i	rs.w	1
flag	rs.w	1
ex1	rs.w	1
ey1	rs.w	1
ex2	rs.w	1
ey2	rs.w	1
* Format of pushed stackrecord:
	rs.w	3
x1	rs.w	1
y1	rs.w	1
x2	rs.w	1
y2	rs.w	1

REC_WINDOW
	link	a0,#-6*2			* Make stackrecord.
	move.w	#numblobs-1,-i(a0)		* i:=Number of blobs-1
	clr.w	-flag(a0)			* Flag:=false;
	move.w	-i(a0),d7
loop	move.w	d7,-i(a0)
* Initialize window to compare with.
	movem.w	(blobpos_tbl,d7.w*4),d0-d1	* Get address of window to compare
	move.w	d0,-ex1(a0)
	move.w	d1,-ey1(a0)
	addi.w	#blobrad*2,d0
	addi.w	#blobrad*2,d1
	move.w	d0,-ex2(a0)
	move.w	d1,-ey2(a0)
* Get type of overlap in current window..
* IF ((ex2 > x1) and (ex2 < x2) and (ey2 > y1) and (ey2 < y2)) THEN
quadrant1
	move.w	-ex2(a0),d0
	cmp.w	x1(sp),d0
	ble	endcase
	cmp.w	x2(sp),d0
	bhs.s	quadrant2
	move.w	-ey2(a0),d0
	cmp.w	y1(sp),d0
	ble	endcase
	cmp.w	y2(sp),d0
	bhs	quadrant4
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, y1, ex2, ey2);
* RecWindow(ex2, y1, x2, ey2);
* RecWindow(x1, ey2, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q1_rw2
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex2(a0),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q1_rw2	move.w	-ex2(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	x1(sp),d0
	move.w	-ey2(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  IF ((ex1 > x1) and (ex1 < x2) and (ey2 > y1) and (ey2 < y2)) THEN
quadrant2
	move.w	-ex1(a0),d0
	cmp.w	x1(sp),d0
	ble	upper_half
	cmp.w	x2(sp),d0
	bhs	endcase
	move.w	-ey2(a0),d0
	cmp.w	y1(sp),d0
	ble	endcase
	cmp.w	y2(sp),d0
	bhs.s	quadrant3
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(ex1, y1, x2, ey2);
* RecWindow(x1, y1, ex1, ey2);
* RecWindow(x1, ey2, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q2_rw2
	move.w	-ex1(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q2_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex1(a0),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	x1(sp),d0
	move.w	-ey2(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
* IF ((ex1 > x1) and (ex1 < x2) and (ey1 > y1) and (ey1 < y2)) THEN
quadrant3
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	ble	left_half
	cmp.w	y2(sp),d0
	bhs	left_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(ex1, ey1, x2, y2);
* RecWindow(x1, y1, x2, ey1);
* RecWindow(x1, ey1, ex1, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q3_rw2
	move.w	-ex1(a0),d0
	move.w	-ey1(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q3_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey1(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	x1(sp),d0
	move.w	-ey1(a0),d1
	move.w	-ex1(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
* IF ((ex2 > x1) and (ex2 < x2) and (ey1 > y1) and (ey1 < y2)) THEN
quadrant4
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	ble	right_half
	cmp.w	y2(sp),d0
	bhs	right_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, ey1, ex2, y2);
* RecWindow(x1, y1, x2, ey1);
* RecWindow(ex2, ey1, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q4_rw2
	move.w	x1(sp),d0
	move.w	-ey1(a0),d1
	move.w	-ex2(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q4_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey1(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	-ex2(a0),d0
	move.w	-ey1(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  if ((ex1 > x1) and (ex1 < x2) and (ey1 < y1) and (ey2 > y2)) then
left_half
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	bhi	upper_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(ex1, y1, x2, y2);
* RecWindow(x1, y1, ex1, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.lh_rw2
	move.w	-ex1(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.lh_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex1(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  if ((ex2 > x1) and (ex2 < x2) and (ey1 < y1) and (ey2 > y2)) then
right_half
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	bhi.s	upper_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, y1, ex2, y2);
* RecWindow(ex2, y1, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.rh_rw2
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex2(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.rh_rw2	move.w	-ex2(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  if ((ex1 < x1) and (ex2 > x2) and (ey1 > y1) and (ey1 < y2)) then
upper_half
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	ble.s	lower_half
	cmp.w	y2(sp),d0
	bhs.s	lower_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, ey1, x2, y2);
* RecWindow(x1, y1, x2, ey1);
	cmp.w	vnum(pc),d0
	bhs.s	.uh_rw2
	move.w	x1(sp),d0
	move.w	-ey1(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.uh_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey1(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra.s	endfor
*  if ((ex1 < x1) and (ex2 > x2) and (ey2 > y1) and (ey2 < y2)) then
lower_half
	move.w	-ey2(a0),d0
	cmp.w	y1(sp),d0
	ble.s	no_overlap
	cmp.w	y2(sp),d0
	bhs.s	no_overlap
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, y1, x2, ey2);
* RecWindow(x1, ey2, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.dh_rw2
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.dh_rw2	move.w	x1(sp),d0
	move.w	-ey2(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra.s	endfor
no_overlap
;	nop
endcase
	move.w	-i(a0),d7
	dbra	d7,loop
endfor	tst.w	-flag(a0)
	beq.s	.plot_window
	unlk	a0
	rts

.plot_window
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	lea	blobpos_tbl,a1
	lea	.adr_tbl(pc),a2
	lea	blobdens_tbl,a3
	ext.l	d0
	ext.l	d1
	moveq	#0,d6
	moveq	#numblobs-1,d7
.findloop
	move.l	d0,d4
	move.l	d1,d5
	movem.w	(a1)+,d2-d3
	sub.w	d2,d4
	bmi.s	.nope
	sub.w	d3,d5
	bmi.s	.nope
	cmpi.w	#blobrad*2,d4
	bhs.s	.nope
	cmpi.w	#blobrad*2,d5
	bhs.s	.nope
	add.l	d4,d4
	mulu.w	#blobrad*4,d5
	add.l	d4,d5
	lea	(a3,d5.l),a4
	move.l	a4,(a2)+
	addq.w	#1,d6
.nope	dbra	d7,.findloop
	
	move.w	x1(sp),d0
	move.w	x2(sp),d1
	move.w	y1(sp),d2
	move.w	y2(sp),d3
	sub.w	d0,d1
	subq.w	#1,d1
	bmi.s	.unlk
	sub.w	d2,d3
	subq.w	#1,d3
	bmi.s	.unlk
	move.l	a0,-(sp)
	moveq	#blobrad*2,d7
	sub.w	d1,d7
	add.w	d7,d7
	subq.l	#2,d7
	move.l	scr,a0
	ext.l	d0
	mulu.w	#scrxbytes,d2
	add.l	d0,d0
	add.l	d2,a0
	add.l	d0,a0
	lea	(a0),a6
	move.w	d1,d0
	moveq	#0,d2
	cmpi.w	#1,d6
	beq.s	.plot1
	cmpi.w	#2,d6
	beq.s	.plot2
	cmpi.w	#3,d6
	beq	.plot3
	cmpi.w	#4,d6
	beq	.plot4
.endplot
	move.l	(sp)+,a0
.unlk	unlk	a0
	rts

.plot1	move.l	.adr_tbl(pc),d4
	sub.l	#blobdens_tbl,d4
	lea	(blob_pic,d4.l),a1
	addq.w	#1,d1
	move.w	d1,d2
	andi.b	#%11111100,d2
	sub.w	d2,d1
	lsr.w	#2,d2
	subq.w	#1,d2
	move.w	d2,d0
	subq.w	#1,d1
	move.w	d1,d4
.yloop	tst.w	d2
	bmi.s	.x1
.xloop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d2,.xloop
.x1	tst.w	d1
	bmi.s	.skip1
.x1loop	move.w	(a1)+,(a0)+
	dbra	d1,.x1loop
.skip1	move.w	d4,d1
	move.w	d0,d2
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a1
	dbra	d3,.yloop
	bra.s	.endplot

.plot2	lea	colorflow_tbl,a1
	lea	.adr_tbl(pc),a5
	move.l	(a5)+,a2
	move.l	(a5)+,a3
.yloop2
.xloop2	move.w	(a2)+,d2
	add.w	(a3)+,d2
	move.w	(a1,d2.l*2),(a0)+
	dbra	d1,.xloop2
	move.w	d0,d1
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a2
	adda.l	d7,a3
	dbra	d3,.yloop2
	bra.s	.endplot

.plot3	lea	colorflow_tbl,a1
	lea	.adr_tbl(pc),a5
	move.l	(a5)+,a2
	move.l	(a5)+,a3
	move.l	(a5)+,a4
	addq.w	#1,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	move.w	d1,d5
	move.w	d0,d1
	moveq	#0,d4
	andi.b	#%00000001,d5
.yloop3
.xloop3	tst.w	d0
	bmi.s	.x3
	move.w	(a2)+,d2
	move.w	(a2)+,d4
	add.w	(a3)+,d2
	add.w	(a3)+,d4
	add.w	(a4)+,d2
	add.w	(a4)+,d4
	move.w	(a1,d2.l*2),(a0)+
	move.w	(a1,d4.l*2),(a0)+
	dbra	d1,.xloop3
.x3	tst.b	d5
	bne.s	.skip3
	move.w	(a2)+,d2
	add.w	(a3)+,d2
	add.w	(a4)+,d2
	move.w	(a1,d2.l*2),(a0)+
.skip3	move.w	d0,d1
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a2
	adda.l	d7,a3
	adda.l	d7,a4
	dbra	d3,.yloop3
	bra	.endplot

.plot4	lea	colorflow_tbl,a1
	lea	.adr_tbl(pc),a5
	move.l	(a5)+,a2
	move.l	(a5)+,a3
	move.l	(a5)+,a4
	move.l	(a5)+,a5
.yloop4
.xloop4	move.w	(a2)+,d2
	add.w	(a3)+,d2
	add.w	(a4)+,d2
	add.w	(a5)+,d2
	move.w	(a1,d2.l*2),(a0)+
	dbra	d1,.xloop4
	move.w	d0,d1
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a2
	adda.l	d7,a3
	adda.l	d7,a4
	adda.l	d7,a5
	dbra	d3,.yloop4
	bra	.endplot

.adr_tbl
	ds.l	numblobs

* Clears 320*100 words.
* INPUT: a0: startaddress of buffer to be cleared.
CLEAR_SCREEN
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#61-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	add.l	#320*100*2,a0
.loop	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	REPT	10
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d6/a1-a3,-(a0)
	rts

SHOW_VBLUSE
	move.l	scr,a0
	IFNE	clearscreen
	moveq	#0,d0
	moveq	#20-1,d7
.cloop	move.w	d0,(a0)
	lea	scrxbytes(a0),a0
	dbra	d7,.cloop	
	ENDC

	move.l	scr,a0
	move.l	.old466(pc),d0
	move.l	$466.w,d1
	move.l	d1,.old466
	sub.l	d0,d1
	beq.s	.rts
	cmpi.w	#scrlines-2,d1
	bhs.s	.rts
	subq.w	#1,d1

.loop	not.w	(a0)
	lea	scrxbytes*2(a0),a0
	dbra	d1,.loop

.rts	rts

.old466	ds.l	1

DISPLAY_FRMSPERSEC
	move.l	frmcnt(pc),d1
	moveq	#0,d2
	move.l	$4ba.w,d0
	sub.l	starttime(pc),d0
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
	lea	.temp_txt,a0
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

******** INTERRUPTS ********

NEWVBL	addq.l	#1,$466.w
	rte

******** DATA + RESERVES ********

fv_vga	INCBIN	d:\coding\falclib2\falclib5\vgatrue2.fv
fv_rgb	INCBIN	R3210W.fv
	EVEN

sine_tbl	
	INCLUDE	SINUS.S

* some GEM functions
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

******** RESERVES ********

	bss
	even

*init-data
	ds.l	256
ustk	ds.l	1
oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
save_fv	ds.w	24

* GEM arrays
contrl	ds.w    12
intin	ds.w    128
intout	ds.w    128
global	ds.w    16
addrin	ds.w    128
addrout	ds.w    128

*timer-stuff
starttime
	ds.l	1
old466	ds.l	1
frmcnt	ds.l	1

*blob-stuff
colorflow_tbl
	ds.w	65536
blobpos_tbl
	ds.w	2*20			x,y
blob_pic
	ds.w	blobrad*2*blobrad*2
blobdens_tbl
	ds.w	blobrad*2*blobrad*2
	ds.w	320*200
blobbasin_buf
	ds.w	320*200
	ds.w	320*200

*scr-stuff
scr	ds.l	3