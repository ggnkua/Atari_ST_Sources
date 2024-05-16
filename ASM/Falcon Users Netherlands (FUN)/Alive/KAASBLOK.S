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

	text

******** GLOBAL CONSTANTS ********

testmode	equ	0			* handy debug mode

scrxbytes	equ	640			* number of bytes per scanline
scrlines	equ	200			* number of scanlines
maxscrsize	equ	scrxbytes*scrlines	* max. size of screen

tmaptest	equ	0

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
.rgb	lea	r3220t5_fv,a0
	bsr	CHANGE_FVFAST
.on	move.l	$4ba.w,starttime

	not.l	$ffff9800.w
	ENDC

	movea.l	scr,a0
	bsr	PLOT_TEXTCUBELOGO
	movea.l	scr+4,a0
	bsr	PLOT_TEXTCUBELOGO
	movea.l	scr+8,a0
	bsr	PLOT_TEXTCUBELOGO

******** MAIN LOOP CODE ********

MAINLOOP
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	move.l	scr,a0
	bsr	CLEAR_SCREEN

	IFEQ	tmaptest
	lea	kaasblok_ini,a1
	lea	rot_tbl,a2
	addi.w	#10,(a2)
	addi.w	#14,2(a2)
	bsr	ROTATE_PIECE
	move.w	#0,d0
	move.w	#0,d1
	move.w	#-300,d2
	bsr	POSITION_PIECE
	bsr	PERSPECT_PIECE
	lea	piece_tbl,a1
	bsr	PLOT_TXTOBJECT
	ENDC

	IFNE	tmaptest
;	addq.w	#8,rot

	lea	txtpoly_dat,a1
	lea	newpoly_dat,a0
	bsr	ROTATE_POLY
	lea	newpoly_dat,a0
	bsr	PERSPECT_POLY
	lea	newpoly_dat,a1
	bsr	PLOT_TTXTPOLY
	ENDC

;	not.l	$ffff9800.w

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

* INPUT: a0: screenaddress
CLEAR_SCREEN:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	move.w	#180-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#640*189+460,a0
.loop	REPT	5
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d4,-(a0)
	lea	-360(a0),a0
	dbra	d7,.loop
	rts

* This routine is just a easy to calculate sinus-matrix thingy
* rotates around the z-axis and then around the y-axis.
* makes a rotated copy of the original...
* INPUT: a1: address of source objectbuffer
*        a2: address of rotation-array
ROTATE_PIECE
* Get sine-values..
	lea	sine_tbl,a0
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a0,d0,d1,d2
	add.l	d1,d1
	add.l	d2,d2
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a0,d0,d3,d4
	add.l	d3,d3
	add.l	d4,d4
	lea	piece_tbl,a0
	move.l	a0,a6
	addq	#4,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	movea.w	d7,a5
	move.l	a1,a2
* Calculate the x-coordinates..
.xloop	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	addq	#2,a1
	move.w	(a1)+,d5
	ext.l	d5
	muls.l	d3,d5
	sub.l	d5,d0
	swap	d0
	move.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.xloop
* Calculate the y-coordinates..
	lea	6+2(a6),a0			* Get address of first y-coord
	move.l	d3,a3				* Backup
	move.l	d4,a4				* Backup
	muls.l	d1,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d1,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.yloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d2,d6
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.yloop
* Calculate the z-coordinates..
	lea	6+4(a6),a0			* Get address of first z-coord
	move.l	a3,d3
	move.l	a4,d4
	muls.l	d2,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d2,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.zloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d1,d6
	sub.l	d6,d5
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.zloop
	move.l	a1,(a6)				* Store address of object-polydata
	rts

POSITION_PIECE
	lea	piece_tbl+4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

.2loop	add.w	d0,(a0)+
	add.w	d1,(a0)+
	add.w	d2,(a0)+
	dbra	d7,.2loop
	rts

PERSPECT_PIECE
	lea	piece_tbl+4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

	move.l	#scrxbytes/4,d3
	move.l	#scrlines/2,d4
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			d0.w: scale factor

	movem.w	(a0),d1-d2
	asl.l	#8,d1
	muls.w	#310,d2			;	asl.l	#8,d2
	divs.w	d0,d1			scale x-coordinate
	add.w	d3,d1			center x-coordinate
	move.w	d1,(a0)+
	divs.w	d0,d2			scale y-coordinate
	add.w	d4,d2			center y-coordinate
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
	rts

* INPUT: a0: address of destination texturepolygon
*        a1: address of source texturepolygon
ROTATE_POLY
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	move.l	(a1)+,(a0)+
	subq.w	#1,d7

	move.w	rot,d0
	Do_SinModulo	d0
	Get_SinCos	sine_tbl,d0,d3,d4

.loop	move.w	(a1)+,d0
	move.w	(a1)+,d1

	move.w	d0,d5
	move.w	d1,d6
	neg.w	d5
	muls.w	d4,d0
	muls.w	d3,d1
	add.l	d0,d1
	add.l	d1,d1
	muls.w	d3,d5
	muls.w	d4,d6
	add.l	d5,d6
	add.l	d6,d6
	swap	d1
	swap	d6
	
	move.w	d1,(a0)+
	move.w	d6,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	dbra	d7,.loop
	rts

* INPUT: a0: address of source texturepolygon
PERSPECT_POLY
	move.w	(a0)+,d7
	addq	#4,a0
	subq.w	#1,d7

	move.w	#scrxbytes/4,d0
	move.w	#scrlines/2,d1
.loop	add.w	d0,(a0)+
	add.w	d1,(a0)+
	addq	#3*2,a0
	dbra	d7,.loop
	rts

* Routine uses backface culling.
* INPUT: a1: address of piece_table containing object
PLOT_TXTOBJECT
	move.l	(a1)+,a0
	lea	.poly_dat,a2
	move.w	(a0)+,d7
	addq	#2,a1
	subq.w	#1,d7

.loop	lea	(a2),a3
* Fetch all points.
	move.w	(a0)+,d6
	move.w	d6,(a3)+
	move.l	(a0)+,(a3)+
	subq.w	#1,d6

.plop	move.w	(a0)+,d0
	mulu.w	#6,d0
	lea	(a1,d0.l),a4
	move.l	(a4)+,(a3)+
	move.w	(a4)+,(a3)+
	move.l	(a0)+,(a3)+
	dbra	d6,.plop

	lea	6(a2),a4
	move.w	(a4),d0
	move.w	10(a4),d1
	move.w	22(a4),d2
	move.w	12(a4),d3
	move.w	2(a4),d4
	move.w	20(a4),d5
	
* d0 = x1 d1 =x2 d2=y3 d3=y2 d4=y1 d5=x3 (allemaal words)
	sub.w	d1,d0
	sub.w	d3,d2
	sub.w	d3,d4
	sub.w	d1,d5
	muls.w	d0,d2
	muls.w	d4,d5
	cmp.w	d5,d2
	bmi.s	.dbra

	movem.l	d7-a2,-(sp)
	lea	(a2),a1
	bsr	PLOT_TTXTPOLY	
	movem.l	(sp)+,d7-a2

.dbra	dbra	d7,.loop
	rts

	bss

.poly_dat
	ds.l	50

	text

* Routine that plots a lineair mapped polygon to the screen.
* NO CLIPPING and far from optimised.
* INPUT: a1: startaddress of texturepolygon datastructure.
PLOT_TTXTPOLY
* I: Transform poly table into a script table.
*    - Find point with lowest y-value.
*    - Cycle clock- and anticlock-wise through the polygon to find the
*      next points and put the slopes of the new lines in the script along
*      with the y-length of each linepart.
*    - If necessary, swap the slopes so you always have the left side in
*      the first longword and the right side in the second longword.
* II: Fill the edge table according to the script table.
* III: Put the poly on screen according to the edge table.
* PART I:
* Find point with lowest y-value.
	move.w	(a1)+,d7
	subq.w	#1,d7
	move.l	(a1)+,-(sp)
	move.w	d7,d6
	move.l	a1,a6
	move.l	a1,a5
	move.w	2(a1),d0
	lea	10(a1),a1
	subq.w	#1,d7
	moveq	#0,d1
.fndlop	cmp.w	2(a1),d0
	blt.s	.skip
	bne.s	.noadd
	addq.w	#1,d1
.noadd	move.w	2(a1),d0
	move.l	a1,a5
.skip	lea	10(a1),a1
	dbra	d7,.fndlop
	cmpi.b	#3,d1
	blt.s	.polyok
	addq	#4,sp				* Pop backup shit off!
	rts
.polyok	move.l	scr,a0
	move.w	d0,d4
	mulu.w	#scrxbytes,d0
	add.l	d0,a0
	move.w	(a5),d0
	add.w	d0,d0
	add.w	d0,a0
	move.l	a0,-(sp)		Push start screenaddress on stack
	move.l	6(a5),-(sp)		Push start texturepos. on stack
* Fill the scripttable entries.
	moveq	#0,d5
	move.l	a6,a1
	move.l	a5,a6
	lea	txtpolyscript_buf+2,a0
	move.w	d6,d7
.makescriptloop
	bsr	.getnextpointaclock
	bsr	.getnextpointclock
	move.w	2(a5),d0
	cmp.w	2(a3),d0
	bgt	.scriptend
	move.w	2(a6),d0
	cmp.w	2(a4),d0
	bgt	.scriptend
	moveq	#0,d0
	move.w	(a3),d0
	sub.w	(a5),d0
	swap	d0
	moveq	#0,d1
	move.w	2(a3),d1
	sub.w	2(a5),d1
	bne.s	.diva
* If the aclock-edge has dy=0 then make a special scriptentry.
	move.l	d0,(a0)+		store l-polyedge increment
	move.w	6(a3),d0
	sub.w	6(a5),d0
	swap	d0
	sub.w	d0,d0
	move.l	d0,(a0)+		store l texture x increment
	move.w	8(a3),d0
	sub.w	8(a5),d0
	swap	d0
	sub.w	d0,d0
	move.l	d0,(a0)+		store l texture y increment
	moveq	#0,d0
	move.l	d0,(a0)+		store r-polyedge increment (=0.0)
	move.l	d0,(a0)+		store r texture x increment (=0.0)
	move.l	d0,(a0)+		store r texture y increment (=0.0)
	move.w	d0,(a0)+		store dy (=0)
	move.l	a3,a5
	bra	.eol
.diva	divs.l	d1,d0			l polyedge increment in d0.l
	move.w	6(a3),d2
	sub.w	6(a5),d2
	swap	d2
	sub.w	d2,d2
	divs.l	d1,d2			l texture x-increment in d2.l
.nodiv	move.w	8(a3),d3
	sub.w	8(a5),d3
	swap	d3
	sub.w	d3,d3
	divs.l	d1,d3			l texture y-increment in d3.l
.nodiv2	move.l	d0,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	moveq	#0,d0
	move.w	(a4),d0
	sub.w	(a6),d0
	swap	d0
	moveq	#0,d1
	move.w	2(a4),d1
	sub.w	2(a6),d1
	bne.s	.divc
* If the clock-edge has dy=0 then make a special scriptentry.
	move.l	d0,(a0)+		store r polyedge increment
	move.w	6(a4),d0
	sub.w	6(a6),d0
	swap	d0
	sub.w	d0,d0
	move.l	d0,(a0)+		store r texture x increment
	move.w	8(a4),d0
	move.w	8(a6),d0
	swap	d0
	sub.w	d0,d0
	move.l	d0,(a0)+		store r texture y increment
	moveq	#0,d0
	move.l	d0,-24(a0)		store l polyedge increment (=0.0)
	move.l	d0,-20(a0)		store l texture x increment (=0.0)
	move.l	d0,-16(a0)		store l texture y increment (=0.0)
	move.w	d0,(a0)+		store dy (=0)
	move.l	a4,a6
	bra.s	.eol
.divc	divs.l	d1,d0			r polyedge increment in d0.l
	move.w	6(a4),d2
	sub.w	6(a6),d2
	swap	d2
	sub.w	d2,d2
	divs.l	d1,d2			r texture x-increment in d2.l
.nodiv3	move.w	8(a4),d3
	sub.w	8(a6),d3
	swap	d3
	sub.w	d3,d3
	divs.l	d1,d3			r texture y-increment in d3.l
.nodiv4	move.l	d0,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	move.w	2(a3),d0
	cmp.w	2(a4),d0
	bpl.s	.else
	move.w	d0,d1
	sub.w	d4,d0
	move.w	d0,(a0)+
	move.w	d1,d4
	move.l	a3,a5
	bra.s	.eol
.else	move.w	2(a4),d2
	move.w	d2,d1
	sub.w	d4,d2
	move.w	d2,(a0)+
	move.w	d1,d4
	move.l	a4,a6
	cmp.w	d0,d1
	bne.s	.eol
	move.l	a3,a5
.eol	addq.w	#1,d5
	bra	.makescriptloop
.scriptend
	lea	txtpolyscript_buf,a0
	move.w	d5,(a0)+
* If needed, swap the sides.
	move.l	(a0),d0
	cmp.l	12(a0),d0
	blt.s	.endswap
;	move.l	26(a0),d0
;	cmp.l	26+12(a0),d0
;	blt.s	.endswap
.doswap	subq.w	#1,d5
.swaplp	movem.l	(a0),d0-d4/d6
	movem.l	d3/d4/d6,(a0)
	movem.l	d0-d2,12(a0)
	lea	26(a0),a0
	dbra	d5,.swaplp
.endswap

* PART II:
* 1) Do left side of polygon.
	lea	txtpolyedge_tbl,a6
	clr.w	(a6)
	lea	2(a6),a0
	lea	txtpolyscript_buf,a1
	move.w	(a1)+,d7
	subq.w	#1,d7
	bpl.s	.dopt2
	lea	12(sp),sp		Adjust stack before RTS: some data was still pushed on it
	rts
.dopt2	moveq	#0,d0
	move.w	2(sp),d2		Pop y texturepos. of stack
	swap	d2
	sub.w	d2,d2
	move.w	(sp),d1			Pop x texturepos. of stack
	swap	d1
	sub.w	d1,d1
	movea.w	#12,a2
.entryloopl
	move.l	(a1)+,d3
	move.l	(a1)+,d4
	move.l	(a1)+,d5
	adda.l	a2,a1
	move.w	(a1)+,d6
	add.w	d6,(a6)
	subq.w	#1,d6
	bpl.s	.lineloopl
	add.l	d3,d0
	add.l	d4,d1
	add.l	d5,d2
	bra.s	.d7dbfl
.lineloopl
	swap	d0
	swap	d1
	swap	d2
	movem.w	d0-d2,(a0)
	adda.l	a2,a0
	swap	d0
	swap	d1
	swap	d2
	add.l	d3,d0
	add.l	d4,d1
	add.l	d5,d2
	dbra	d6,.lineloopl
.d7dbfl	dbra	d7,.entryloopl
* 2) Do right side of polygon.
	lea	txtpolyedge_tbl+2+6,a0
	lea	txtpolyscript_buf,a1
	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(sp)+,d1		Pop x texturepos. of stack
	swap	d1
	sub.w	d1,d1
	move.w	(sp)+,d2		Pop y texturepos. of stack
	swap	d2
	sub.w	d2,d2
.entryloopr
	adda.l	a2,a1
	move.l	(a1)+,d3
	move.l	(a1)+,d4
	move.l	(a1)+,d5
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.do_lineloopr
	add.l	d3,d0
	add.l	d4,d1
	add.l	d5,d2
	bra.s	.d7dbfr
.do_lineloopr:
.lineloopr:
	swap	d0
	swap	d1
	swap	d2
	movem.w	d0-d2,(a0)
	adda.l	a2,a0
	swap	d0
	swap	d1
	swap	d2
	add.l	d3,d0
	add.l	d4,d1
	add.l	d5,d2
	dbra	d6,.lineloopr
.d7dbfr	dbra	d7,.entryloopr
* PART III:
	move.l	(sp)+,a0
	move.l	(sp)+,a2
	addq	#4,a2
	move.l	a0,a6
	lea	txtpolyedge_tbl,a1
	move.w	(a1)+,d7
	lea	scrxbytes.w,a5
	subq.w	#1,d7
	bmi.s	.rts
.drawtxtlinelp
	movem.w	(a1)+,d0/d1/d2/d3/d4/d6
* d0.l: X1 (extend word) d1.l: TX1 (extend word) d2.l: TY1 (extend word)
* d3.l: X2 (extend word) d4.l: TX2 (extend word) d6.l: TY2 (extend word)
	lea	(a0,d0.l*2),a0
	sub.l	d1,d4
	sub.l	d2,d6
	lsl.w	#8,d2
	asl.l	#8,d4
	asl.l	#8,d6
	sub.w	d0,d3
	bmi.s	.rts
	beq.s	.1pix
	divs.w	d3,d4
	divs.w	d3,d6
.1pix	rol.l	#8,d6
	move.b	d4,d6
	rol.l	#8,d6
	eor.b	d6,d6
	swap	d6			* uu--VVvv
	lsr.w	#8,d4			* ------UU
	moveq	#0,d5
.plotpixlp
	move.w	d2,d5
	move.b	d1,d5
	move.w	(a2,d5.l*2),(a0)+
	add.l	d6,d2
	addx.b	d4,d1
	dbra	d3,.plotpixlp
	adda.l	a5,a6
	movea.l	a6,a0
	dbra	d7,.drawtxtlinelp
.rts	rts

* Subroutine that finds the next texturepoly point in a texturepoly.
* Searches anti-clockwise.
* INPUT: a1: address of first texturepoly point
*        a5: address of actual texturepolypoint
*        d7: number of points in texturepoly
* OUTPUT: a3: address of found point
.getnextpointaclock
	lea	-10(a5),a3
	cmpa.l	a1,a3
	bpl.s	.ok
	move.w	d7,d0
	mulu.w	#10,d0
	lea	(a1,d0.l),a3
.ok	rts

* Subroutine that finds the next lowest texturepoly point in a texturepoly.
* Searches clockwise
* INPUT: a1: address of first texturepoly point
*        a6: address of current point
*        d7: number of points in texturepoly
* OUTPUT: a4: address of found point
.getnextpointclock
	lea	10(a6),a4
	move.l	a4,d0
	sub.l	a1,d0
	move.w	d7,d1
	mulu.w	#10,d1
	cmp.l	d0,d1
	bpl.s	.okido
	move.l	a1,a4
.okido	rts

* INPUT: a0: screenaddress
PLOT_TEXTCUBELOGO:
	lea	texturecubepic_dat,a1
	adda.l	#(scrxbytes*(200-86))+(scrxbytes-(45*4)),a0
	moveq	#86-1,d7

.yloop:	moveq	#45-1,d6
.xloop:	move.l	(a1)+,(a0)+
	dbra	d6,.xloop
	lea	scrxbytes-(45*4)(a0),a0
	dbra	d7,.yloop
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
;	incbin	c:\coding\falclib2\falclib5\vgatrue2.fv
r3220t5_fv
	incbin	r3220w.fv

* AES parameter block
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

kaasblok_ini
	dc.w	8
	dc.w	-90,-90,-90
	dc.w	90,-90,-90
	dc.w	90,90,-90
	dc.w	-90,90,-90
	dc.w	-90,-90,90
	dc.w	90,-90,90
	dc.w	90,90,90
	dc.w	-90,90,90

	dc.w	6

	dc.w	4
	dc.l	texture_rpc
	dc.w	0,255,0
	dc.w	1,255,255
	dc.w	2,0,255
	dc.w	3,0,0
	dc.w	4
	dc.l	texture_rpc
	dc.w	0,255,0
	dc.w	4,255,255
	dc.w	5,0,255
	dc.w	1,0,0
	dc.w	4
	dc.l	texture_rpc
	dc.w	6,127,0
	dc.w	2,127,127
	dc.w	1,0,127
	dc.w	5,0,0
	dc.w	4
	dc.l	texture_rpc
	dc.w	3,255,0
	dc.w	2,255,255
	dc.w	6,0,255
	dc.w	7,0,0
	dc.w	4
	dc.l	texture_rpc
	dc.w	0,63,0
	dc.w	3,63,63
	dc.w	7,0,63
	dc.w	4,0,0
	dc.w	4
	dc.l	texture_rpc
	dc.w	7,63,0
	dc.w	6,63,63
	dc.w	5,0,63
	dc.w	4,0,0

txtpoly_dat
	dc.w	4			number of points
	dc.l	texture_rpc		address of rpc-texture
	dc.w	-50,-50,0,255,0		x, y, z, x-txt, y-txt
	dc.w	50,-50,0,255,255
	dc.w	50,50,0,0,255
	dc.w	-50,50,0,0,0

texture_rpc
	dc.w	256,256
	INCBIN	KAAS3.RAW

texturecubepic_dat:
	INCBIN	TEXTCUBE.RAW

sine_tbl
	INCLUDE	SINUS.S

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

*testcrap
rot	ds.w	1

*3d tmap stuffs
rot_tbl	ds.w	3
newpoly_dat
	ds.l	50
txtpolyscript_buf
	ds.w	1
	ds.l	100
txtpolyedge_tbl
	ds.w	6*scrlines
	ds.w	1000
piece_tbl
	ds.w	500

*counter/timer shit
frmcnt	ds.l	1
starttime
	ds.l	1

*scr-stuff
scr	ds.l	3