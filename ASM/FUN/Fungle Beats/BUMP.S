******** ASM OPTIONS ********

	COMMENT	HEAD=%111
;	OPT	D-

******** GLOBAL EQUS ********

scrxbytes	equ	640
scrlines	equ	200

******** INCLUDES ********

	INCLUDE	MKSIN3.I

	text

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

	bsr	SAVE_FV

	move.l	#r3220t5_fv,a0
	bsr	SET_FV

.on	lea	bumpfile_txt,a1
	lea	surface_buf,a0
	bsr	LOAD_FILE
	lea	lightmapfile_txt,a1
	lea	lightmap_buf,a0
	bsr	LOAD_FILE

	lea	surface_buf+788,a1
	lea	bumpmap_buf,a0
	bsr	INIT_BUMPMAP

	move.l	$466.w,old466
	not.l	$ffff9800.w

******** MAIN LOOP ********

MAINLOOP
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	lea	bumpmap_buf+(8*320*2)+64,a2
	lea	lightmap_buf+(28*256*2),a1
	lea	sine_tbl,a0
	move.w	angle,d0
	addi.w	#30,d0
	move.w	d0,angle
	Do_SinModulo	d0
	Get_SinCos	a0,d0,d1,d2
	move.l	d1,d3
	move.l	d2,d4
	asr.l	#8,d4
	asr.l	#2,d4
	asl.l	#4,d3
	eor.w	d3,d3
	swap	d3
	muls.w	#320,d3
	add.l	d3,d4
	add.l	d4,d4
	add.l	d4,a2
	asr.l	#8,d1
	eor.b	d2,d2
	add.l	d2,d1
	add.l	d1,d1
	add.l	d1,a1
	bsr	PLOT_BUMPMAP

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

	bra	MAINLOOP

******** REINITIALISING ********

OUT	bsr	RESTORE_FV

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

SAVE_FV	lea	fvbuf,a1
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

RESTORE_FV
	move.l	#fvbuf,a0
	bsr	SET_FV
	rts

SET_FV	cmp.l	#'FVD2',(a0)+	4 bytes header
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

CHANGE_FVFAST
	addq	#6,a0
	move	sr,-(sp)
	move	#$2300,sr

	move.l	(a0)+,$ffff820e.w	offset & vwrap
	move.w	(a0)+,$ffff8266.w	spshift
	lea	$ffff8282.w,a1		horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmp.l	#$ff8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1		vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmp.l	#$ff82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w	video control
	move.w	(a0)+,$ffff82c0.w	video clock
	addq	#1,a0
	move.b	(a0)+,$ffff820a.w	video sync mode
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

INIT_BUMPMAP
	move.w	#256-1,d7

.yloop	move.w	#320-1,d6
.xloop	move.b	(a1),d0
	sub.b	2(a1),d0
	bpl.s	.skip1
	neg.b	d0
.skip1	asr.b	#1,d0
	move.b	d0,(a0)+
	move.b	(a1),d0
	sub.b	640(a1),d0
	bpl.s	.skip2
	neg.b	d0
.skip2	asr.b	#1,d0
	move.b	d0,(a0)+
	addq	#1,a1
	dbra	d6,.xloop
	dbra	d7,.yloop
	rts

PLOT_BUMPMAP
	move.l	scr,a0
	lea	32*2(a0),a0
	moveq	#0,d0
	move.w	#200-1,d7
	moveq	#16,d5
	movea.w	#scrxbytes-(256*2),a6

.yloop	moveq	#32-1,d6
.xloop	movem.w	(a2)+,d0-d4/a3-a5
	move.w	(a1,d0.l*2),(a0)+
	move.w	2(a1,d1.l*2),(a0)+
	move.w	4(a1,d2.l*2),(a0)+
	move.w	6(a1,d3.l*2),(a0)+
	move.w	8(a1,d4.l*2),(a0)+
	move.w	10(a1,a3.l*2),(a0)+
	move.w	12(a1,a4.l*2),(a0)+
	move.w	14(a1,a5.l*2),(a0)+
	adda.l	d5,a1
	dbra	d6,.xloop
	adda.l	a6,a0
	adda.l	a6,a2
	dbra	d7,.yloop
	rts

SHOW_VBLUSE
	move.l	scr,a0
	move.l	.old466(pc),d0
	move.l	$466.w,d1
	move.l	d1,.old466
	sub.l	d0,d1
	beq.s	.rts
	cmpi.w	#scrlines-2,d1
	bhs.s	.rts
	subq.w	#1,d1

.loop	move.w	#$ffff,(a0)
	lea	scrxbytes*2(a0),a0
	dbra	d1,.loop
	clr.w	(a0)

.rts	rts

.old466	ds.l	1

DISPLAY_FRMSPERSEC
	pea	.text_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	frmcnt(pc),d1
	moveq	#0,d2
	move.l	$466.w,d0
	sub.l	old466(pc),d0
	mulu.l	#50,d1
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
	lea	.temp_txt(pc),a0
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
	clr.b	(a0)

	pea	.temp_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	pea	.return_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	rts

.text_txt
	dc.b	"Average frames/sec. : ",0
.return_txt
	dc.b	$d,$a,0
.temp_txt
	ds.b	16
	even

******** INTERRUPTS ********

NEWVBL	addq.l	#1,$466.w
	rte

******** DATA + RESERVES ********

v3220t5_fv
	incbin	..\demos1\v3220_t5.fv
r3220t5_fv
	incbin	r3220_t5.fv

sine_tbl
	INCLUDE	SINUS.S

bumpfile_txt
	dc.b	"d:\coding\fungle\f_bump.apx",0
lightmapfile_txt
	dc.b	"d:\coding\fungle\lamp.raw",0

******** RESERVES ********

	bss
	even

*init-data
oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
fvbuf	ds.w	24

old466	ds.l	1
frmcnt	ds.l	1

*file-stuff
filhndl	ds.w	1
filedata_buf
	ds.b	44

*bumpmap buffers
angle	ds.w	1
surface_buf
	ds.b	256*256+788
bumpmap_buf
	ds.w	256*256
	ds.w	256*256
lightmap_buf
	ds.w	256*256
	ds.w	256*256

*scr-stuff
scr	ds.l	1
	ds.l	1
	ds.l	1
scrbuf	ds.w	1
	ds.w	320*200
	ds.w	320*200
	ds.w	320*200