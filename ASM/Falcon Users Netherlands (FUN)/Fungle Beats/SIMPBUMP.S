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

******** GLOBAL CONSTANTS ********

scrxbytes	equ	640
scrlines	equ	200
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
.ramok	lea	scr(pc),a0
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

.rgb	lea	r3220t5_fv(pc),a0
	bsr	CHANGE_FVFAST

.on	move.l	$4ba.w,starttime

	not.l	$ffff9800.w

******** MAIN LOOP CODE ********

MAINLOOP
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	bsr	PLOT_BUMP

	lea	scr(pc),a0
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

	lea	save_fv(pc),a0
	bsr.s	CHANGE_FVFAST

EXIT	move.l	oldvbl(pc),$70.w

	move.l	oldscr(pc),d7
	swap	d7
	move.b	d7,$ffff8201.w
	rol.l	#8,d7
	move.b	d7,$ffff8203.w
	rol.l	#8,d7
	move.b	d7,$ffff820d.w

	bsr	DISPLAY_FRMSPERSEC

E_EXIT	move.l	oldsp(pc),-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINE CODE ********

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

* Routine that loads a given file from disk to a buffer.
* INPUT: a0: startaddress of buffer to load to
*        a1: startaddress of nullterminated name
* OUTPUT: d0.b: pos=successful
*               neg=error, not done
LOAD_FILE
	movem.l	a0-a1,-(sp)
	move.w	#0,-(sp)			Fopen
	move.l	a1,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	movem.l	(sp)+,a0-a1
	move.w	d0,filhndl
	bpl.s	.read
	rts
.read	move.l	a0,-(sp)			Fread
	move.l	#-1,-(sp)
	move.w	filhndl,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bpl.s	.close
	rts
.close	move.l	d0,-(sp)
	move.w	filhndl,-(sp)			Fclose
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d0
	rts

PLOT_BUMPMAP
	move.l	scr,a0
	rts

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

******** INTERRUPT ROUTINE CODE ********

NEWVBL	addq.l	#1,$466.w
	rte

******** GLOBAL DATA + INCLUDES ********

v3220t5_fv
	incbin	c:\coding\falclib2\falclib5\vgatrue2.fv
r3220t5_fv
	incbin	c:\coding\falclib2\falclib5\r3220_t5.fv

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