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

******** ASM OPTIONS ********

;	OPT	D-

******** LIBRARIES ********

	INCLUDE	MKSIN3.I

	TEXT

******** GLOBAL CONSTANTS ********

testmode	equ	0			* handy debug mode

* Radius of a blob-element. Must be > 0 and < 64. Or else it's
* assembler-error or runtime-error city!
blobradi	equ	54
blobrad		equ	blobradi/4*4
* Number of blobs to calculate/display. Can NOT be 0 or lower!!
numblobs	equ	4

scrxbytes	equ	640
scrlines	equ	100
maxscrsize	equ	scrxbytes*scrlines

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
.rgb	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST

.on	bsr	INIT_SHADETAB
	bsr	PRECALC_BLOBBUFFERS

	move.l	$4ba.w,starttime
	not.l	$ffff9800.w
	ENDC

******** MAIN LOOP CODE ********

MAINLOOP
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	bsr	CALC_BLOBTRAJECTS
	bsr	PLOT_SLOW4BLOBS

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

OUT
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

* Clears 320*100 words.
* INPUT: a0: startaddress of buffer to be cleared.
CLEAR_SCR3210T
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
	sub.l	starttime,d0
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
	bsr	CLEAR_SCR3210T

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

	bra	PLOT_HEIGHTFIELD

	lea	blobbasin_buf,a1
	lea	colorflow_tbl,a2
	lea	sine_tbl,a0
	moveq	#0,d0
	move.w	$4bc.w,d0
	sub.w	starttime+2,d0
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
	lea	blobbasin_buf+160,a1
	lea	colorflow_tbl,a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#scrlines-1,d7
.yloop	move.w	#(scrxbytes/16)-1,d6
.xloop	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.l	(a2,d0.l*2),(a0)+
	move.l	(a2,d1.l*2),(a0)+
	move.l	(a2,d2.l*2),(a0)+
	move.l	(a2,d3.l*2),(a0)+
	dbra	d6,.xloop
	lea	320(a1),a1
	dbra	d7,.yloop
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

******** INTERRUPT ROUTINE CODE ********

NEWVBL	addq.l	#1,$466.w
	rte

******** GLOBAL DATA + INCLUDES ********

v3220t5_fv
	incbin	c:\coding\falclib2\falclib5\vgatrue2.fv
r3210t5_fv
	incbin	R3210W.fv
	EVEN

sine_tbl
	INCLUDE	SINUS.S

* AES parameter block
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

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

*blob shit!
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

*scr-stuff
scr	ds.l	3