******** ASM OPTIONS AND PATHS ********

;	opt	d-

******** INCLUDES ********

	include	MKSIN3.I

	text

******** GLOBAL CONSTANTS ********

scrxbytes4b	equ	160
scrlines	equ	200

******** INITIALISING ********

START	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr

	move.l	#scrbuf,d0
	addq.l	#4,d0
	andi.b	#%11111100,d0
	lea	scr,a0
	move.l	d0,(a0)+
	add.l	#320*200*2,d0
	move.l	d0,(a0)+
	add.l	#320*200*2,d0
	move.l	d0,(a0)+

	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w

	bsr	SAVE_FALCPAL
	bsr	SAVEFV

	lea	r322045_fv(pc),a0
	bsr	SETFV

	bsr	INIT_FUNLOGOS

	move.w	#-1500,funkubz
	lea	$ffff9800.w,a0
	clr.l	7*4(a0)
	clr.l	8*4(a0)
	clr.l	15*4(a0)

******** MAIN LOOP ********

mainloop
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

;	not.l	$ffff9800.w

	cmpi.w	#-220,funkubz
	bmi.s	.clr
	bsr	FADEIN_FUNLOGOS
	bsr	ADD_LOGOSTOMESH

.clr	move.l	scr,a0
	bsr	CLEAR_32204BSCREEN

	lea	kubus_rot,a2
	addq.w	#8,(a2)
	subi.w	#11,2(a2)
	lea	kubus_ini,a1
	bsr	ROTATE_PIECE
	moveq	#0,d0
	moveq	#0,d1
	lea	funkubz,a0
	move.w	(a0),d2
	cmpi.w	#-220,d2
	bge.s	.skpadd
	addq.w	#6,d2
	move.w	d2,(a0)
.skpadd	bsr	POSITION_PIECE
	bsr	PERSPECTIVATE_PIECE
	bsr	ADD_TO_POLYMESH
	bsr	ZSORT_POLYMESH
	bsr	PLOT_POLYMESH

;	not.l	$ffff9800.w

	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466

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

	bra	mainloop

******** REINITIALISING ********

OUT	bsr	RESTOREFV
	bsr	RESTORE_FALCPAL

EXIT	move.l	oldvbl,$70.w

	move.l	oldscr,d7
	swap	d7
	move.b	d7,$ffff8201.w
	rol.l	#8,d7
	move.b	d7,$ffff8203.w
	rol.l	#8,d7
	andi.b	#%11111100,d7
	move.b	d7,$ffff820d.w

	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINES ********

SAVEFV	lea	fvbuf,a1
	move.l	#'FVD2',(a1)+	4 bytes header
	move.b	$ffff8006.w,(a1)+	monitor type
	move.b	$ffff820a.w,(a1)+	sync
	move.l	$ffff820e.w,(a1)+	offset & vwrap
	move.w	$ffff8266.w,(a1)+	spshift
	move.l	#$ff8282,a0	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a0
	bne	.loop1
	move.l	#$ff82a2,a0	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a0
	bne	.loop2
	move	$ffff82c2.w,(a1)+	video control
	move	$ffff82c0.w,(a1)+	video clock
	move.b	$ffff8260.w,(a1)+	shifter resolution
	move.b	$ffff820a.w,(a1)+	video sync mode
	rts

RESTOREFV
	move.l	#fvbuf,a0
	bsr	SETFV
	rts

SETFV	cmp.l	#'FVD2',(a0)+	4 bytes header
	bne	.error

.ready	addq.l	#2,a0
	move.l	$70.w,-(sp)
	move	sr,-(sp)
	move.l	#.vbl,$70.w
	move	#$2300,sr

	move.l	$466.w,d0
.wait	cmp.l	$466.w,d0
	beq	.wait
	
	move.l	(a0)+,$ffff820e.w	offset & vwrap
	move.w	(a0)+,$ffff8266.w	spshift
	move.l	#$ff8282,a1	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a1
	bne	.loop1
	move.l	#$ff82a2,a1	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a1
	bne	.loop2
	move	(a0)+,$ffff82c2.w	video control
	move	(a0)+,$ffff82c0.w	video clock
	addq.l	#1,a0
	move.b	(a0)+,$ffff820a.w	video sync mode
	move	(sp)+,sr
	move.l	(sp)+,$70.w
	moveq	#0,d0
	rts
.error	moveq	#-1,d0
	rts
.wrongmon
	moveq	#-2,d0
	rts
.sm124	cmp.b	#0,(a0)
	bne	.wrongmon
	bra	.ready
.vga	cmp.b	#2,(a0)
	bne	.wrongmon
	bra	.ready
.vbl	addq.l	#1,$466.w
	rte

SAVE_FALCPAL
	lea	falcsave_pal,a0
	lea	$ffff9800.w,a1
	moveq	#128-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

RESTORE_FALCPAL
	lea	falcsave_pal,a1
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

INIT_FUNLOGOS
	lea	funlogos_pi1+2,a1
	lea	$ffff9800.w,a0
	lea	funlogos_pal,a2
	moveq	#16-1,d7
.pallop	move.w	(a1)+,d0
	moveq	#0,d3
	move.w	d0,d1
	move.w	d0,d2
	andi.w	#$0700,d0
	andi.w	#$0070,d1
	andi.w	#$0007,d2
	lsl.w	#5,d0
	add.w	d1,d1
	lsl.w	#5,d2
	or.w	d0,d3
	or.w	d1,d3
	swap	d3
	or.w	d2,d3
	move.l	d3,(a0)+
	move.l	d3,(a2)+
	dbra	d7,.pallop

	move.l	a1,a6

	lea	96(a1),a1
	lea	bonus_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop1
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop1

	lea	wingleader_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop2
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop2

	lea	thematch_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop3
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop3

	lea	otm_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop4
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop4

	lea	earx_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop5
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop5
	rts

* Routine that clears a 320*200 4bitplane screen
* INPUT: a0: screenaddress
CLEAR_32204BSCREEN
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6

	move	#152,d0
	add.l	#32000,a0
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

FADEIN_FUNLOGOS
	lea	funlogos_pal,a1
	lea	$ffff9800.w,a0
	lea	7*4(a1),a1
	lea	7*4(a0),a0
	move.l	(a1)+,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	(a0),d3
	move.b	d3,d5
	swap	d3
	move.b	d3,d4
	lsr.w	#8,d3
	cmp.b	d0,d3
	beq.s	.noadd1
	addq.b	#4,d3
.noadd1	cmp.b	d1,d4
	beq.s	.noadd2
	addq.b	#4,d4
.noadd2	cmp.b	d2,d5
	beq.s	.noadd3
	addq.b	#4,d5
.noadd3	lsl.w	#8,d3
	move.b	d4,d3
	swap	d3
	move.b	d5,d3
	move.l	d3,(a0)+
	move.l	(a1)+,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	(a0),d3
	move.b	d3,d5
	swap	d3
	move.b	d3,d4
	lsr.w	#8,d3
	cmp.b	d0,d3
	beq.s	.noadd4
	addq.b	#4,d3
.noadd4	cmp.b	d1,d4
	beq.s	.noadd5
	addq.b	#4,d4
.noadd5	cmp.b	d2,d5
	beq.s	.noadd6
	addq.b	#4,d5
.noadd6	lsl.w	#8,d3
	move.b	d4,d3
	swap	d3
	move.b	d5,d3
	move.l	d3,(a0)+
	lea	6*4(a0),a0
	lea	6*4(a1),a1
	move.l	(a1)+,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	(a0),d3
	move.b	d3,d5
	swap	d3
	move.b	d3,d4
	lsr.w	#8,d3
	cmp.b	d0,d3
	beq.s	.noadd7
	addq.b	#4,d3
.noadd7	cmp.b	d1,d4
	beq.s	.noadd8
	addq.b	#4,d4
.noadd8	cmp.b	d2,d5
	beq.s	.noadd9
	addq.b	#4,d5
.noadd9	lsl.w	#8,d3
	move.b	d4,d3
	swap	d3
	move.b	d5,d3
	move.l	d3,(a0)+	
	rts

ADD_LOGOSTOMESH
	lea	sine_tbl,a0
	move.w	fasex,d0
	addq.w	#2,d0
	Do_SinModulo	d0
	move.w	d0,fasex
	Get_Sin	a0,d0,d0
	asr.w	#8,d0
	Do_SinModulo	d0
	Get_SinCos	a0,d0,d1,d2	* /
	add.l	d1,d1			* | d1.l:=sin(x)
	add.l	d2,d2			* \ d2.l:=cos(x)
	move.w	roty,d0
	addq.w	#7,d0
	Do_SinModulo	d0
	move.w	d0,roty
	Get_SinCos	a0,d0,d3,d4	* /
	add.l	d3,d3			* | d3.l:=sin(y)
	add.l	d4,d4			* \ d4.l:=cos(y)
* PX = X*cos(y)        + 0        - Z*sin(y)
* PY = X*sin(x)*sin(y) + Y*cos(x) + Z*sin(x)*cos(y)
* PZ = X*cos(x)*sin(y) - Y*sin(x) + Z*cos(x)*cos(y)
* PX = X*d4            + 0        - Z*d3
* PY = X*d1*d3         + Y*d2     + Z*d1*d4
* PZ = X*d2*d3         - Y*d1     + Z*d2*d4
	moveq	#5-1,d7
	lea	logos3d_pos,a1
	lea	bonus_pos,a0
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

	moveq	#5-1,d7
	move.l	d3,a3
	move.l	d4,a4
	muls.l	d1,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d1,d5:d4
	move.w	d5,d4
	swap	d4
	lea	logos3d_pos,a1
	lea	bonus_pos+2,a0
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
	move.l	a3,d3
	move.l	a4,d4

	muls.l	d2,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d2,d5:d4
	move.w	d5,d4
	swap	d4
	moveq	#5-1,d7
	lea	logos3d_pos,a1
	lea	bonus_pos+4,a0
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
* Position the logos in 3d space.
	moveq	#5-1,d7
	lea	bonus_pos+4,a0
	move.w	#-220,d0
.poslop	add.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.poslop
* Perspectivate the center-points of the logos.
	moveq	#5-1,d7
	lea	bonus_pos,a0
	move.l	#scrxbytes4b,d3
	move.l	#scrlines/2,d4
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			d0.w: scale factor
	movem.w	(a0),d1-d2
	asl.l	#8,d1
	asl.l	#8,d2
	divs.w	d0,d1			scale x-coordinate
	add.w	d3,d1			center x-coordinate
	move.w	d1,(a0)+
	divs.w	d0,d2			scale y-coordinate
	add.w	d4,d2			center y-coordinate
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
* Add the logos to the polymesh.
	lea	bonus_pos,a1
	move.l	#polymesh+2,a0
	move.l	(a0)+,d0
	add.l	d0,a0
	moveq	#5,d7
	add.w	d7,polymesh
	moveq	#0,d0
	subq.w	#1,d7
.backlp	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	d0,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	addq.w	#1,d0
	dbra	d7,.backlp
	move.l	a0,d0
	sub.l	#polymesh+6,d0
	move.l	#polymesh+2,a0
	move.l	d0,(a0)
	rts

* Routine that plots a 4 bitplane 96*16 sprite to screen.
* Shifting is done realtime. Onscreen detection implemented and vertical
* clipping too :) (no horizontal clipping :( )
* Optimised.. Where the mask is all 1's, the entire 16 pixel block is
* skipped :))))
* INPUT: a1: startaddress of sprite-data
*        d0.w: x-middle position of sprite
*        d1.w: y-middle position of sprite
PLOT_4B9616SPRITE
	subi.w	#48,d0
	cmpi.w	#(scrxbytes4b*2)-96,d0
	blo.s	.posx
	rts
.posx	subq.w	#8,d1
	cmpi.w	#scrlines-16,d1
	blo.s	.posy
	bpl.s	.high
	cmpi.w	#-16,d1
	bgt.s	.cliplow
	rts
.cliplow
	moveq	#16-1,d7
	add.w	d1,d7
	move.w	d0,d5
	andi.b	#$f0,d0
	sub.w	d0,d5
	lsr.w	#1,d0
	move.l	scr,a0
	add.w	d0,a0
	neg.w	d1
	lea	12*16(a1),a2
	mulu.w	#12,d1
	add.l	d1,a1
	lsl.l	#2,d1
	add.l	d1,a2
	bra.s	.yloop
.high	cmpi.w	#scrlines,d1
	blt.s	.highclip
	rts
.highclip
	move.w	#scrlines-1,d7
	sub.w	d1,d7
	move.l	scr,a0
	move.w	d0,d5
	andi.b	#$f0,d0
	sub.w	d0,d5
	lsr.w	#1,d0
	mulu.w	#scrxbytes4b,d1
	add.w	d0,a0
	add.l	d1,a0
	lea	12*16(a1),a2
	bra.s	.yloop
.posy	move.l	scr,a0
	move.w	d0,d5
	andi.b	#$f0,d0
	sub.w	d0,d5
	lsr.w	#1,d0
	mulu.w	#scrxbytes4b,d1
	add.w	d0,a0
	add.l	d1,a0
	lea	12*16(a1),a2
	moveq	#16-1,d7
.yloop	moveq	#6-1,d6
.blklop	moveq	#$ffffffff,d0
	move.w	(a1)+,d0
	cmpi.w	#$ffff,d0
	bne.s	.normal
	addq	#8,a2
	addq	#8,a0
	bra.s	.dbrad6
.normal	ror.l	d5,d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	swap	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	lea	-16(a0),a0
	REPT	4
	moveq	#0,d0
	move.w	(a2)+,d0
	ror.l	d5,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	ENDR
.dbrad6	dbra	d6,.blklop	
	lea	scrxbytes4b-48(a0),a0
	dbra	d7,.yloop
.rts	rts

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

PERSPECTIVATE_PIECE
	lea	piece_tbl+4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

	move.l	#scrxbytes4b,d3
	move.l	#scrlines/2,d4
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			d0.w: scale factor

	movem.w	(a0),d1-d2
	asl.l	#8,d1
	asl.l	#8,d2
	divs.w	d0,d1			scale x-coordinate
	add.w	d3,d1			center x-coordinate
	move.w	d1,(a0)+
	divs.w	d0,d2			scale y-coordinate
	add.w	d4,d2			center y-coordinate
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
	rts

ADD_TO_POLYMESH
	lea	piece_tbl,a1
* Put all visible objectpoly's in the polymesh.
	move.l	(a1)+,a2
	move.l	#polymesh,a0
	addq.l	#2,a0
	move.l	(a0)+,d0
	add.l	d0,a0
	addq.l	#2,a1
	move.w	(a2)+,d7
	subq.w	#1,d7
	bpl.s	.backlp
	rts

.backlp	move.l	(a2)+,d6
	move.l	d6,(a0)+
	move.w	(a2)+,(a0)+
	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),(a0)
	move.w	4(a1,d0.l),4(a0)
	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),6(a0)
	move.w	4(a1,d0.l),10(a0)
	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),12(a0)
	move.w	4(a1,d0.l),16(a0)
	move.w	(a0)+,d0
	move.w	(a0)+,d4
	addq.l	#2,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d3
	addq.l	#2,a0
	move.w	(a0)+,d5
	move.w	(a0)+,d2
	addq.l	#2,a0
* d0=x1 d1=x2 d2=y3 d3=y2 d4=y1 d5=x3 (allemaal words)
	sub.w	d1,d0
	sub.w	d3,d2
	sub.w	d3,d4
	sub.w	d1,d5
	muls.w	d0,d2
	muls.w	d4,d5
	cmp.w	d5,d2
	bpl.s	.okido
	lea	-24(a0),a0
	subq.w	#4,d6
	bmi.s	.eolp
.mflp	addq.l	#2,a2
	dbra	d6,.mflp
	bra.s	.eolp
.okido	addq.w	#1,polymesh
	subq.w	#4,d6
	bmi.s	.eolp
.mvlp	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),(a0)+
	move.w	4(a1,d0.l),(a0)+
	dbra	d6,.mvlp
.eolp	dbra	d7,.backlp
	move.l	a0,d0
	sub.l	#polymesh+6,d0
	move.l	#polymesh+2,a0
	move.l	d0,(a0)
	rts

ZSORT_POLYMESH
* stap1 : polymesh -> rij met per entry offset en afstand.
* stap2 : rij sorteren
* stap3 : gesorteerde rij -> nieuwe polymesh (polymesh2)
* stap 1
	move.l	#polymesh,a0
	move.l	#sorter_tbl,a1
	move.w	(a0)+,d7
	move.w	d7,(a1)+
	subq.w	#1,d7
	bgt.s	.1_g
	move.l	a0,a1
	move.l	#polymesh2,a0
	move.w	-2(a1),(a0)+
	beq.s	.rts
	addq	#4,a1
	move.l	(a1)+,d7
	move.l	d7,(a0)+
	move.w	(a1)+,(a0)+
	subq.w	#1,d7
.cplp	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	dbra	d7,.cplp
.rts	rts
.1_g	addq.l	#4,a0
	moveq	#0,d1
	clr.w	(a1)+
.midlop	move.w	2(a0),d0
	addq	#6,a0
	move.w	d0,d6
	mulu.w	#6,d0
	addq.w	#6,d0
	add.w	d0,d1
	move.w	d6,d5
	subq.w	#1,d6
	moveq	#0,d0
.aflp	addq.l	#4,a0
	add.w	(a0)+,d0
	dbra	d6,.aflp
	ext.l	d0
	divs.w	d5,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbra	d7,.midlop
* stap 2
	move.l	#sorter_tbl,a1
	move.w	(a1)+,d7
	move.l	a1,a0
	subq.w	#1,d7
	move.l	a1,a3
	move.w	d7,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a3
	addq.l	#4,a3
	move.l	a3,a2
	subq.w	#1,d7
	move.w	d7,d6
	moveq	#0,d5
.sortlp	move.l	(a1)+,d0
	cmp.w	2(a1),d0
	ble.s	.rlp
	bset	#0,d5
	move.l	(a1),-4(a1)
	move.l	d0,(a1)
.rlp	move.l	-(a3),d0
	cmp.w	6(a3),d0
	ble.s	.rlp2
	bset	#0,d5
	move.l	4(a3),(a3)
	move.l	d0,4(a3)
.rlp2	dbra	d7,.sortlp
	btst	#0,d5
	beq.s	.rbld
	moveq	#0,d5
	move.w	d6,d7
	move.l	a0,a1
	move.l	a2,a3
	bra.s	.sortlp
* stap 3
.rbld	move.l	#sorter_tbl,a1
	move.l	#polymesh+6,a2
	move.l	#polymesh2,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
.rclp	move.w	(a1)+,d0
	lea	(a2,d0.w),a3
	move.l	(a3)+,d0
	move.w	d0,d6
	move.l	d0,(a0)+
	move.w	(a3)+,(a0)+
	subq.w	#1,d6
.mlp	move.l	(a3)+,(a0)+
	move.w	(a3)+,(a0)+
	dbra	d6,.mlp
	addq.l	#2,a1
	dbra	d7,.rclp	
	rts

PLOT_POLYMESH
	move.l	#polymesh2,a1
	move.w	(a1)+,d7
	subq.w	#1,d7
	bmi.s	.end
.biglop	movem.l	d7/a1,-(sp)
	tst.w	(a1)
	bne.s	.poly
	move.w	4(a1),d2
	mulu.w	#(12*16)+(48*16),d2
	movem.w	6(a1),d0-d1
	lea	bonus_spr,a1
	add.l	d2,a1
	bsr	PLOT_4B9616SPRITE
	bra.s	.endplt
.poly	bsr	PLOT_GLENZPOLYGON4B
.endplt	movem.l	(sp)+,d7/a1
	move.l	(a1)+,d6
	subq.w	#1,d6
	addq	#2,a1
.addlp	addq	#6,a1
	dbra	d6,.addlp
	dbra	d7,.biglop
* Make it clear that the polymesh can be used anew.
.end	clr.w	polymesh
	clr.l	polymesh+2
	rts

PLOT_POLYGONPOINTS4B
	move.l	scr,a0
	move.l	a0,a6

	move.l	(a1)+,d7
	subq.w	#1,d7
	addq.l	#2,a1
.lp	move.l	a6,a0
	movem.w	(a1)+,d0-d1
	tst.w	d0
	bmi.s	.dbra
	tst.w	d1
	bmi.s	.dbra
	move.l	d0,d2
	andi.b	#$f0,d0
	sub.w	d0,d2
	sub.b	#16,d2
	neg.b	d2
	moveq	#0,d3
	bset	d2,d3
	lsr.w	#1,d0
	mulu.w	#scrxbytes4b,d1
	add.l	d0,a0
	add.l	d1,a0
	or.w	d3,(a0)+
	or.w	d3,(a0)+
	or.w	d3,(a0)+
	or.w	d3,(a0)+
.dbra	addq.l	#2,a1
	dbra	d7,.lp
	rts

PLOT_GLENZPOLYGON4B
	move.l	(a1)+,d7
	subq.w	#1,d7
	move.w	(a1)+,-(sp)
	move.w	d7,d6
	move.l	a1,a6
	move.l	a1,a5
	move.w	2(a1),d0
	lea	6(a1),a1
	subq.w	#1,d7
	moveq	#0,d1
.fndlop	cmp.w	2(a1),d0
	blt.s	.skip
	bne.s	.nocnt
	addq.w	#1,d1
.nocnt	move.w	2(a1),d0
	move.l	a1,a5
.skip	lea	6(a1),a1
	dbra	d7,.fndlop
	cmpi.b	#3,d1
	blt.s	.wrong
	addq	#2,sp
	rts
.wrong	move.l	scr,a0
	move.w	d0,d4
	mulu.w	#scrxbytes4b,d0
	add.l	d0,a0
	move.w	(a5),-(sp)
	move.l	a0,-(sp)
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
	bgt.s	.scriptend
	moveq	#0,d0
	move.w	(a3),d0
	sub.w	(a5),d0
	swap	d0
	moveq	#0,d1
	move.w	2(a3),d1
	sub.w	2(a5),d1
	bne.s	.diva
	move.l	d0,(a0)+
	moveq	#0,d0
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	move.l	a3,a5
	bra.s	.eol
.diva	divs.l	d1,d0
	move.l	d0,(a0)+
	moveq	#0,d0
	move.w	(a4),d0
	sub.w	(a6),d0
	swap	d0
	moveq	#0,d1
	move.w	2(a4),d1
	sub.w	2(a6),d1
	bne.s	.divc
	move.l	d0,(a0)+
	moveq	#0,d0
	move.l	d0,-8(a0)
	move.w	d0,(a0)+
	move.l	a4,a6
	bra.s	.eol
.divc	divs.l	d1,d0
	move.l	d0,(a0)+
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
	cmp.l	4(a0),d0
	blt.s	.endswap
	subq.w	#1,d5
.swaplp	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	lea	10(a0),a0
	dbra	d5,.swaplp
.endswap
* PART II:
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(sp)+,d0
	swap	d0
	move.l	d0,d1
	lea	txtpolyscript_buf,a1
	move.w	(a1)+,d7
	move.l	a0,a6
	subq.w	#1,d7
	bmi	.rts
	moveq	#$ffffffff,d5
	move.l	d5,a5
	lea	polyedges_tbl,a2
	move.w	(sp)+,d5
	beq.s	.entryloop
	cmpi.w	#1,d5
	beq	.entryloop2
	bne	.entryloop3
.entryloop
	move.l	(a1)+,a3
	move.l	(a1)+,a4
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.lineloop
	add.l	a3,d0
	add.l	a4,d1
	bra.s	.d7dbf
.lineloop
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	andi.b	#$f0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	add.w	d2,d2
	andi.b	#$f0,d3
	sub.w	d2,d4
	sub.w	d3,d5
	cmp.w	d2,d3
	bne.s	.toobad
	move.w	(a2,d4.w*2),d4
	and.w	32(a2,d5.w*2),d4
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	bra.s	.yehyeh
.toobad	move.w	(a2,d4.w*2),d4
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	sub.w	d2,d3
	asr.w	#4,d3
	subq.w	#2,d3
	bmi.s	.ahyeh
.blklop	move.l	a5,(a0)+
	clr.l	(a0)+
	dbra	d3,.blklop
.ahyeh	move.w	32(a2,d5.w*2),d5
	or.w	d5,(a0)+
	or.w	d5,(a0)+
	not.w	d5
	and.w	d5,(a0)+
	and.w	d5,(a0)+
.yehyeh	swap	d0
	swap	d1
	add.l	a3,d0
	add.l	a4,d1
	lea	scrxbytes4b(a6),a6
	move.l	a6,a0
	dbra	d6,.lineloop
.d7dbf	dbra	d7,.entryloop
	bra	.rts

.entryloop2
	move.l	(a1)+,a3
	move.l	(a1)+,a4
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.lineloop2
	add.l	a3,d0
	add.l	a4,d1
	bra.s	.d7dbf2
.lineloop2
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	andi.b	#$f0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	add.w	d2,d2
	andi.b	#$f0,d3
	sub.w	d2,d4
	sub.w	d3,d5
	cmp.w	d2,d3
	bne.s	.toobad2
	move.w	(a2,d4.w*2),d4
	and.w	32(a2,d5.w*2),d4
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	bra.s	.yehyeh2
.toobad2
	move.w	(a2,d4.w*2),d4
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	sub.w	d2,d3
	asr.w	#4,d3
	subq.w	#2,d3
	bmi.s	.ahyeh2
.blklop2
	move.w	a5,(a0)+
	clr.l	(a0)+
	clr.w	(a0)+
	dbra	d3,.blklop2
.ahyeh2	move.w	32(a2,d5.w*2),d5
	or.w	d5,(a0)+
	not.w	d5
	and.w	d5,(a0)+
	and.w	d5,(a0)+
	and.w	d5,(a0)+
.yehyeh2
	swap	d0
	swap	d1
	add.l	a3,d0
	add.l	a4,d1
	lea	scrxbytes4b(a6),a6
	move.l	a6,a0
	dbra	d6,.lineloop2
.d7dbf2	dbra	d7,.entryloop2
	bra	.rts

.entryloop3
	move.l	(a1)+,a3
	move.l	(a1)+,a4
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.lineloop3
	add.l	a3,d0
	add.l	a4,d1
	bra	.d7dbf3
.lineloop3
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	andi.b	#$f0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	add.w	d2,d2
	andi.b	#$f0,d3
	sub.w	d2,d4
	sub.w	d3,d5
	cmp.w	d2,d3
	bne.s	.toobad3
	move.w	(a2,d4.w*2),d4
	and.w	32(a2,d5.w*2),d4
	or.w	d4,4(a0)
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	addq	#2,a0
	and.w	d4,(a0)+
	bra.s	.yehyeh3
.toobad3
	move.w	(a2,d4.w*2),d4
	or.w	d4,4(a0)
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	addq	#2,a0
	and.w	d4,(a0)+
	sub.w	d2,d3
	asr.w	#4,d3
	subq.w	#2,d3
	bmi.s	.ahyeh3
.blklop3
	clr.l	(a0)+
	move.w	a5,(a0)+
	clr.w	(a0)+
	dbra	d3,.blklop3
.ahyeh3	move.w	32(a2,d5.w*2),d5
	or.w	d5,4(a0)
	not.w	d5
	and.w	d5,(a0)+
	and.w	d5,(a0)+
	addq	#2,a0
	and.w	d5,(a0)+
.yehyeh3
	swap	d0
	swap	d1
	add.l	a3,d0
	add.l	a4,d1
	lea	scrxbytes4b(a6),a6
	move.l	a6,a0
	dbra	d6,.lineloop3
.d7dbf3	dbra	d7,.entryloop3
.rts	rts

* Subroutine that finds the next texturepoly point in a texturepoly.
* Searches anti-clockwise.
* INPUT: a1: address of first texturepoly point
*        a5: address of actual texturepolypoint
*        d7: number of points in texturepoly
* OUTPUT: a3: address of found point
.getnextpointaclock
	lea	-6(a5),a3
	cmpa.l	a1,a3
	bpl.s	.ok
	move.w	d7,d0
	mulu.w	#6,d0
	lea	(a1,d0.l),a3
.ok	rts

* Subroutine that finds the next lowest texturepoly point in a texturepoly.
* Searches clockwise
* INPUT: a1: address of first texturepoly point
*        a6: address of current point
*        d7: number of points in texturepoly
* OUTPUT: a4: address of found point
.getnextpointclock
	lea	6(a6),a4
	move.l	a4,d0
	sub.l	a1,d0
	move.w	d7,d1
	mulu.w	#6,d1
	cmp.l	d0,d1
	bpl.s	.okido
	move.l	a1,a4
.okido	rts

******** INTERRUPTS ********

NEWVBL	addq.l	#1,$466.w
	rte

******** DATA + INCLUDES ********

r322045_fv
	incbin	c:\coding\falclib2\falclib5\r3220_45.fv

funlogos_pi1
	incbin	f:\pictures\fun_big2.pi1

logos3d_pos
	dc.w	0,0,170
	dc.w	161,0,53
	dc.w	100,0,-138
	dc.w	-100,0,-138
	dc.w	-162,0,53

kubus_ini
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
	dc.w	1,4,1
	dc.w	0,1,2,3
	dc.w	1,4,2
	dc.w	0,4,5,1
	dc.w	1,4,0
	dc.w	6,2,1,5
	dc.w	1,4,2
	dc.w	3,2,6,7
	dc.w	1,4,0
	dc.w	0,3,7,4
	dc.w	1,4,1
	dc.w	7,6,5,4

polyedges_tbl
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

sine_tbl
	INCLUDE	SINUS.S

******** RESERVES ********

	bss
	even

*init-data
oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
falcsave_pal
	ds.l	256
fvbuf	ds.w	24

*rotation crap
roty	ds.w	1
fasex	ds.w	1

*position of logos
bonus_pos
	ds.w	3
wingleader_pos
	ds.w	3
thematch_pos
	ds.w	3
otm_pos	ds.w	3
earx_pos
	ds.w	3

*logo-buffers
bonus_spr
	ds.w	6*16
	ds.w	24*16
wingleader_spr
	ds.w	6*16
	ds.w	24*16
thematch_spr
	ds.w	6*16
	ds.w	24*16
otm_spr	ds.w	6*16
	ds.w	24*16
earx_spr
	ds.w	6*16
	ds.w	24*16

funlogos_pal
	ds.l	16

kubus_rot
	ds.w	2
funkubz	ds.w	1

sin_x	ds.l	1
cos_x	ds.l	1
sin_y	ds.l	1
cos_y	ds.l	1
sin_z	ds.l	1
cos_z	ds.l	1

piece_tbl
	ds.l	100
sorter_tbl
	ds.w	1
	ds.l	2000
polymesh
	ds.w	10000
polymesh2
	ds.w	10000

txtpolyscript_buf
	ds.w	1
	ds.w	5*20			20 rc-changes max!

*scr-stuff
scr	ds.l	1
	ds.l	1
	ds.l	1
scrbuf	ds.w	1
	ds.w	320*200
	ds.w	320*200
	ds.w	320*200