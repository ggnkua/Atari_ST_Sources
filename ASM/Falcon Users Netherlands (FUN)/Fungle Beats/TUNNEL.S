	INCLUDE	MKSIN3.I

	TEXT

******* INITIALISING ********

	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr

	move.l	#scrbuf,scr
	move.l	#scrbuf2,scr2
	move.l	#scrbuf3,scr3

	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w

	bsr	SAVEFV

	move.b	$ffff8006.w,d0		check da monitor-type
	andi.b	#%11000000,d0
	tst.b	d0
	beq	EXIT
	btst	#6,d0
	bne.s	rgb

	move.l	#fv_vga,a0
	bsr	SETFV
	bra.s	on

rgb	move.l	#fv_rgb,a0
	bsr	SETFV

on	bsr	INIT_TUNNEL

	not.l	$ffff9800.w

******** MAIN LOOP ********

mainloop
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	moveq	#0,d0
	moveq	#0,d1
	move.w	$4bc.w,d1
	andi.w	#64-1,d1
	move.w	$4bc.w,d2
	Do_SinModulo	d2
	Get_Sin	sine_tbl,d2,d0
	asr.w	#8,d0
	andi.w	#64-1,d0
	add.l	d0,d0
	lsl.l	#7,d1
	add.l	d0,d1
	lea	(tunnel_pic,d1.l*4),a2
	bsr	PLOT_TUNNEL

	move.l	scr,d0
	move.l	scr2,d1
	move.l	scr3,scr
	move.l	d0,scr2
	move.l	d1,scr3

	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	andi.b	#%11111100,d0
	move.b	d0,$ffff820d.w

	bra	mainloop

******** REINITIALISING ********

OUT	bsr	RESTOREFV

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

INIT_TUNNEL
	move.l	#tunnel_tbl,a0
	rts

* INPUT: a1: address of tunnel-offset-table
*        a2: address of tunnel picture
PLOT_TUNNEL
	movea.l	scr,a0
	lea	(a0),a3
	adda.l	#640*100,a3
	moveq	#50-1,d7

.lp	moveq	#40-1,d6
.inlop	movem.w	(a1)+,d0-d3
	move.l	(a2,d0.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	move.l	(a2,d1.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	move.l	(a2,d2.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	move.l	(a2,d3.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	dbra	d6,.inlop
	dbra	d7,.lp
	rts

******** INTERRUPTS ********

NEWVBL	addq.l	#1,$466.w
	rte

******** DATA + RESERVES ********

fv_vga	incbin	c:\coding\falclib2\falclib5\vgatrue2.fv
fv_rgb	INCBIN	R3210W.FV

tunnel_tbl:
	INCBIN	TUNNEL.DAT

tunnel_pic:
	INCBIN	256128.RAW

sine_tbl:
	INCLUDE	SINUS.S

******** RESERVES ********

	bss
	even

*init-data
oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
fvbuf	ds.w	24

*general timers
old4ba	ds.l	1
old466	ds.l	1
frmcnt	ds.l	1

*scr-stuff
scr	ds.l	1
scr2	ds.l	1
scr3	ds.l	1
	ds.w	1
scrbuf	ds.w	320*200
scrbuf2	ds.w	320*200
scrbuf3	ds.w	320*200