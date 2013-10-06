*                      ===============================
*                      |  FX testing skeleton v1.0   |
*                      | 13-06-1998 by |EarX|->fUn<- |
*                      ===============================
*
* v1.0: * 3 screens
*       * st-compatible res-switcher
*       * TT-RAM aware
*       * frames/sec counter
*
* v1.1: * Frames/sec counter now displays dialog-box + is vbl-independent.
*       * Falcon check.

******** ASM OPTIONS ********

;	OPT	D-

******** >> GO << ********

	bra	START

******** MACROS AND LIBRARIES ********

;	INCLUDE	IO.S
;	INCLUDE	ALLOC.S
	INCLUDE	MKSIN3.I

	text

******** GLOBAL CONSTANTS ********

scrxbytes	equ	640
scrlines	equ	100
maxscrsize	equ	scrxbytes*scrlines

******** INITIALISING CODE ********

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

	lea	v3220t5_fv(pc),a0
	bsr	CHANGE_FVFAST
	bra.s	.on

.rgb	lea	r3210w_fv(pc),a0
	bsr	CHANGE_FVFAST

.on	bsr	INIT_INTERGFX

	move.l	$4ba.w,starttime
	not.l	$ffff9800.w

******** MAIN LOOP CODE ********

MAINLOOP
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	bsr	PLOT_INTERGFX

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

	bra.s	MAINLOOP

******** RESTORING CODE ********

OUT	not.l	$ffff9800.w

	bsr	DEINIT_INTERGFX

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

E_EXIT	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINE CODE ********

* Saves the current falcon resolution to an internal buffer.
SAVE_FV	lea	save_fv+6,a1
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

* INPUT: a0: Table address (65536 words!)
*        d0.w: Fade strength
CALC_TWINPIXCOLORS
	movea.l	(A0)+,A1
	move.w	(A0),D0
	move.w	D0,D1
	lsl.w	#6,D1
	moveq	#0,D2
	move.w	D1,D2
	lsl.w	#5,D2
	moveq	#0,D3
.l0:	move.l	D3,D4
	sub.l	D2,D4
	bpl.s	.w0
	moveq	#0,D4
.w0:	and.w	#%1111100000000000,D4
	move.w	D3,D5
	and.w	#%11111111111,D5
	sub.w	D1,D5
	bmi.s	.w1
	and.w	#%11111100000,D5
	add.w	D5,D4
.w1:	move.w	D3,D5
	and.w	#%11111,D5
	sub.w	D0,D5
	bmi.s	.w2
	add.w	D5,D4
.w2:	move.w	D4,(A1)+
	addq.w	#1,D3
	bcc.s	.l0
	rts

* INPUT: d2.l: spline_y
*        d3.w: spline_x
gen_rotdist:
.w4	swap	d2
	moveq	#0,D1
	move.w	d3,d1
	move.l	#10<<16<<4,D0
	ext.l	D1
	bmi.s	gen_rotdist_m
	cmpi.w	#0100,d1
	ble.s	.w0
	move.w	#$0100,D1
.w0:	lsl.l	#8,d1
	lsl.l	#3,d1
	lea	rotdist,A0
	lea	tan_tbl,A1
	moveq	#scrlines-1,D3
.l0:	move.l	D2,D4
	move.l	D0,D5
	swap	D5
	divu.w	2(A1,D5.w*4),D4
	move.w	D4,(A0)+
	add.l	D1,D0
	dbra	D3,.l0
	rts

gen_rotdist_m:
	neg.l	D1
	cmpi.w	#$0100,d1
	ble.s	.w1
	move.w	#$0100,d1
.w1:	lsl.l	#8,d1
	lsl.l	#3,d1
	lea	rotdist,a0
	lea	tan_tbl,A1
	moveq	#scrlines-1,D3
.l1:	move.l	D2,D4
	move.l	D0,D5
	swap	D5
	divu.w	2(A1,D5.w*4),D4
	move.w	d4,(a0)+
	add.l	D1,D0
	dbra	d3,.l1
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; a0.l  Zeiger auf Spline-Block
; d0.l  t (0-$ffff)
; Rckgabe: d1.w
spline:	move.l	d2,-(sp)
	move.l	(a0),d1
	muls.l	d0,d2:d1
	move.w	d2,d1
	swap	d1
	add.l	4(a0),d1
	muls.l	d0,d2:d1
	move.w	d2,d1
	swap	d1
	add.l	8(a0),d1
	muls.l	d0,d2:d1
	move.w	d2,d1
	swap	d1
	add.l	12(a0),d1
	swap	d1
	move.l	(sp)+,d2
	rts

INIT_INTERGFX
	rts

DEINIT_INTERGFX
	rts
	
PLOT_INTERGFX
	addi.l	#$300,.spline_timer
	tst.w	.spline_timer(pc)
	beq.s	.ws0
	clr.w	.spline_timer
	subq.w	#1,.spline_counter
	bpl.s	.ws1
	move.w	.spline_anz_pts(pc),.spline_counter
	subq.w	#1,.spline_counter
	lea	.spline_pts(pc),a0
	bra.s	.ws2
.ws1:	move.l	.spline_adr(pc),a0
	lea	32(a0),a0
.ws2:	move.l	a0,.spline_adr
.ws0	move.l	.spline_adr(pc),a0
	moveq	#0,d0
	move.w	.spline_timer+2(pc),d0
	bsr	spline
	neg.w	d1
	asr.w	#1,d1
	move.w	d1,.spline_x
	lea	16(a0),a0
	bsr	spline
	neg.w	d1
	asr.w	#1,d1
	move.w	d1,.spline_y

	addi.l	#$500,.mspline_timer
	tst.w	.mspline_timer(pc)
	beq.s	.wms0
	clr.w	.mspline_timer
	subq.w	#1,.mspline_counter
	bpl.s	.wms1
	move.w	.mspline_anz_pts(pc),.mspline_counter
	subq.w	#1,.mspline_counter
	lea	.mspline_pts(pc),a0
	bra.s	.wms2
.wms1:	move.l	.mspline_adr(pc),a0
	lea	32(a0),a0
.wms2:	move.l	a0,.mspline_adr
.wms0	move.l	.mspline_adr(pc),a0
	moveq	#0,d0
	move.w	.mspline_timer+2(pc),d0
	bsr	spline
	neg.w	d1
	move.w	d1,.mspline_x
	lea	16(a0),a0
	bsr	spline
	neg.w	d1
	move.w	d1,.mspline_y

	move.w	.wi(pc),d0
	Do_SinModulo	d0
	moveq	#0,d2
	move.w	(sine_tbl.w,pc,d0.w*4),d2
	addi.w	#$8000,d2
	ror.l	#8,d2
	ror.l	#3,d2
	addq.w	#1,d2
	move.w	.spline_x(pc),d3
;	moveq	#10,d2
;	moveq	#30,d3
	bsr	gen_rotdist

	lea	sine_tbl(pc),a0
	move.w	.wi(pc),d0
	add.w	d0,d0
	Do_SinModulo	d0
	Get_SinCos	a0,d0,d0,d2
	move.w	d0,.si
	move.w	d2,.co
	lea	gfx_pic+128*1024,a0
	movea.l scr,A1
	lea	rotdist,a4
	moveq	#0,d5				* / for 
	movea.l	#$80000007,a6			* \ distorsion
	move.w	#-scrlines/2,.ypos

.rotator_next_y:
	move.w	(a4)+,d6
;¯xstart%=(-50*faktor%) DIV 256
	moveq	#-80,D3
	muls.w	D6,D3
	asr.l	#8,D3
;¯ystart%=(y%*faktor%) DIV 256
	move.w	.ypos(pc),D4
;	addi.w	#70-20,D4
	add.w	.mspline_x(pc),d4
	muls.w	D6,D4
	asr.l	#8,D4
;¯xpos%=xstart%*si%+ystart%*co%
;¯ypos%=ystart%*si%-xstart%*co%
	move.l	D3,D0
	move.l	D4,D1
	muls.w	.si(pc),D0
	muls.w	.co(pc),D4
	add.l	D4,D0
	muls.w	.si(pc),D1
	muls.w	.co(pc),D3
	sub.l	D3,D1
;¯xofs%=(si%*faktor%) DIV 256
	move.w	.si(pc),D2
	muls.w	D6,D2
	eor.w	D2,d2
	swap	D2
;¯yofs%=-(co%*faktor%) DIV 256
	move.w	.co(pc),D3
	muls.w	D6,D3
	asr.l	#8,D3
	neg.l	D3
	lsr.l	#8,D0
	swap	D1
	swap	D3
	move.l	D1,D7
	eor.w	d7,d7
	add.l	D7,D0
	move.l	D3,D7
	eor.w	d7,d7
	add.l	D7,D2
	moveq	#(scrxbytes/2)/20-1,D7
.rotator_next_x:
;¯WORD{scrcntr%+(ypos% DIV 65536)*640+(xpos% DIV 65536)*2}=-1
* d0 xpos  yn|00|xv|xn
* d1 ypos  00|00|00|yv
* d2 xofs  yn|00|xv|xn
* d3 yofs  00|00|00|yv
	REPT	10
	move.w	D0,D4
	move.b	D1,D4
	move.l	0(a0,d4.w*4),(a1)+
	add.l	d2,d0
	addx.b	d3,d1
	ENDR
* Distort it up!! 
	add.l	a6,d2
	addx.b	d5,d3
	dbra	D7,.rotator_next_x

	addq.w	#1,.ypos
	cmpi.w	#scrlines/2,.ypos
	bne	.rotator_next_y
* Increase or decrease rotation.
	move.w	$4bc.w,d0
	sub.w	starttime+2,d0
	move.w	d0,.wi
	rts

.wi	ds.w	1
.si	ds.w	1
.co	ds.w	1
.ypos	ds.w	1

.spline_x	ds.w	1
.spline_y	ds.w	1
.spline_timer	dc.l	$10000
.spline_adr	dc.l	.spline_pts-32
.spline_counter	dc.w	0
.spline_pts=*+2
.spline_anz_pts	incbin	rspline1.dat

.mspline_x	ds.w	1
.mspline_y	ds.w	1
.mspline_timer	dc.l	$10000
.mspline_adr	dc.l	.mspline_pts-32
.mspline_counter
		dc.w	0
.mspline_pts=*+2
.mspline_anz_pts
		incbin	rspline2.dat

		DATA

	DC.W	0				* long-even address!
gfx_pic:	INCBIN	PLASMAD.RAW
tan_tbl:	INCBIN	TAN.BIN
		EVEN

		BSS

helltab:	DS.L	1
rotdist:	DS.W	scrlines
orig_gfx:	DS.L	1
tan:		DS.L	1

		TEXT

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

******** INTERRUPT ROUTINE CODE ********

NEWVBL	addq.l	#1,$466.w
	rte

******** GLOBAL DATA + INCLUDES ********

v3220t5_fv
;	incbin	c:\coding\falclib2\falclib5\vgatrue2.fv
r3210w_fv
	incbin	r3210w.fv
	even

* AES parameter block
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

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

*counter/timer shit
frmcnt	ds.l	1
starttime
	ds.l	1

*scr-stuff
scr	ds.l	3