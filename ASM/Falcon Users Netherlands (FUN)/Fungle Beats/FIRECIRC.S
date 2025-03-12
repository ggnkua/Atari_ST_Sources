* 1998 EarX/fUn:
*  fucking fired up pleasueres
*   320*200 RGB Tru3<olor -> falcon only!

******** GLOBAL CONSTANTS ********

scrxbytes	equ	320*2
scrlines	equ	200

******** ASM OPTIONS ********

;	opt	d-

******** INITIALISING ********

	clr.l	-(sp)
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
	lea	scr(pc),a0
	move.l	d0,(a0)+
	add.l	#320*scrlines*2,d0
	move.l	d0,(a0)+
	add.l	#320*scrlines*2,d0
	move.l	d0,(a0)+

	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w

	bsr	SAVEFV

	lea	fv_rgb,a0
	bsr	SETFV

	bsr	INIT_FIRECIRC
	move.l	#flowtable,a1
	move.l	#truepal,a0
	bsr	MAKE_COLORFLOW

	move.l	$466.w,old466

	not.l	$ffff9800.w

******** MAIN LOOP ********

mainloop
	cmpi.b	#$39,$fffffc02.w
	beq	OUT

	addq.l	#1,frmcnt

	bsr	PLOT_FIRECIRC
	bsr	SHOW_VBLUSE

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

	bra.s	mainloop

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
	move.b	d7,$ffff820d.w

	bsr	DISPLAY_FRMSPERSEC

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

MAKE_COLORFLOW
	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#1,d6
	lsl.w	d0,d6
	move.w	d7,d5
	mulu.w	d6,d5
	move.w	d5,(a0)+
	subq.w	#1,d6
	move.w	d6,d5
	subq.w	#1,d7

.biglop	move.l	(a1)+,d1
	move.l	(a1),d2
	moveq.l	#0,d3
	move.l	d3,d4
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
	move.l	a0,a6
.lop1	swap	d3
	move.b	d3,3(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop1
	move.w	d5,d6
	move.l	a6,a0
	moveq	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop2	swap	d3
	move.b	d3,1(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop2
	move.l	a6,a0
	move.w	d5,d6
	moveq.l	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	rol.l	#8,d1
	rol.l	#8,d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop3	swap	d3
	move.b	d3,(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop3
	move.w	d5,d6
	dbra	d7,.biglop

	move.l	#truepal,a1
	move.l	#realpal,a0
	move.w	(a1)+,d7

.loop	moveq	#0,d0
	move.b	(a1)+,d0
	andi.b	#%11111000,d0
	lsl.w	#8,d0
	moveq	#0,d1
	move.b	(a1)+,d1
	andi.b	#%11111100,d1
	lsl.w	#3,d1
	moveq	#0,d2
	addq.l	#1,a1
	move.b	(a1)+,d2
	lsr.w	#3,d2
	or.w	d2,d0
	or.w	d1,d0
	move.w	d0,(a0)+
	dbra	d7,.loop

	lea	realpal,a1
	lea	fire_pal+2,a0
	move.w	#256-1,d7
.bcplop	move.w	#256-1,d6
.icplop	move.w	(a1)+,(a0)
	addq	#4,a0
	dbra	d6,.icplop
	lea	-256*2(a1),a1
	dbra	d7,.bcplop

	lea	realpal,a1
	lea	fire_pal,a0
	move.w	#256-1,d7
.bcplp2	move.w	(a1)+,d0
	move.w	#256-1,d6
.icplp2	move.w	d0,(a0)
	addq	#4,a0
	dbra	d6,.icplp2	
	dbra	d7,.bcplp2
	rts

INIT_FIRECIRC
	move.l	$4ba.w,d0
	move.l	d0,d1
	swap	d1
	sub.l	d0,d1
	or.l	$466.w,d1
	move.l	d1,random
	rts

firelines	equ	35

PLOT_FIRECIRC
	lea	firebuf+320,a1
	lea	fire_pal,a4
	lea	-320(a1),a2
	lea	320(a1),a3
	move.l	scr(pc),a0
	adda.l	#scrxbytes*(scrlines-firelines-1),a0
	move.w	#firelines-1,d7

	move.l	#%11111100111111001111110011111100,d5
.biglop	moveq	#80-1,d6
.lp	move.l	(a3)+,d1
	add.l	d1,d1
	add.l	(a2)+,d1
	add.l	-3(a3),d1
	and.l	d5,d1
	lsr.l	#2,d1
	move.l	d1,(a1)+
	move.l	d1,d2
	swap	d2
	move.l	(a4,d2.w*4),(a0)+
	move.l	(a4,d1.w*4),(a0)+
	dbra	d6,.lp
	dbra	d7,.biglop

* Calculate new baseline of fire..
	moveq	#80-1,d7
	move.l	random,d3

.intlop	move.l	d3,d0
	move.l	d0,d1
	mulu.w	d1,d1
	sub.l	d0,d1
	swap	d0
	eor.l	d0,d1
	move.l	d1,d3
	move.l	d1,(a1)+
	dbra	d7,.intlop

	move.l	d3,random
	rts

PLOT_FIRECIRC2
	lea	firebuf+((320+1)*firelines),a1
	lea	fire_pal,a4
	lea	-320(a1),a2
	move.l	a2,a6
	lea	320(a1),a3
	move.l	scr(pc),a0
	adda.l	#scrxbytes*(scrlines-1),a0
	move.w	#firelines-1,d7

	move.l	#%11111100111111001111110011111100,d5
.biglop	moveq	#80-1,d6
.lp	move.l	(a3)+,d1
	add.l	d1,d1
	add.l	(a2)+,d1
	add.l	-3(a3),d1
	and.l	d5,d1
	lsr.l	#2,d1
	move.l	d1,(a1)+
	move.l	d1,d2
	swap	d2
	move.l	(a4,d2.w*4),(a0)+
	move.l	(a4,d1.w*4),(a0)+
	dbra	d6,.lp
	lea	-scrxbytes*2(a0),a0
	lea	-320*2(a3),a3
	lea	-320*2(a1),a1
	lea	-320*2(a2),a2
	dbra	d7,.biglop

* Calculate new baseline of fire..
	moveq	#80-1,d7
	move.l	random,d3

.intlop	move.l	d3,d0
	move.l	d0,d1
	mulu.w	d1,d1
	sub.l	d0,d1
	swap	d0
	eor.l	d0,d1
	move.l	d1,d3
	move.l	d1,(a6)+
	dbra	d7,.intlop

	move.l	d3,random
	rts

SHOW_VBLUSE
	move.l	scr,a0
	move.l	.old466(pc),d0
	move.l	$466.w,d1
	move.l	d1,.old466
	sub.l	d0,d1
	beq.s	.end
	cmpi.w	#scrlines-2,d1
	bhs.s	.end
	subq.w	#1,d1
.loop	move.w	#$ffff,(a0)
	lea	scrxbytes*2(a0),a0
	dbra	d1,.loop
.end	clr.w	(a0)
	rts

.old466	ds.l	1

DISPLAY_FRMSPERSEC
	pea	.text_txt(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	frmcnt,d1
	moveq	#0,d2
	move.l	$466.w,d0
	sub.l	old466,d0
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

	dc.w	0			* for putting the sections on long edge

fv_rgb	incbin	d:\coding\falclib2\falclib5\r3220_t5.fv

*fire-stuff

flowtable
	dc.w	16
	dc.w	4
	dc.l	$00000000	;dc.l	$00000000
	dc.l	$3f000000	;dc.l	$003f0000
	dc.l	$7f000000	;dc.l	$007f0000
	dc.l	$ff1f0000	;dc.l	$3fdf0000
	dc.l	$ff3f0000	;dc.l	$7fff0000
	dc.l	$ff7f0000	;dc.l	$dfff0000
	dc.l	$ffbf0000	;dc.l	$ffff0000
	dc.l	$ffff0000	;dc.l	$ffff003f
	dc.l	$ffff0000	;dc.l	$ffff007f
	dc.l	$ffff003f	;dc.l	$ffff00bf
	dc.l	$ffff007f	;dc.l	$ffff00ff
	dc.l	$ffff00bf	;dc.l	$ffff00ff
	dc.l	$ffff00ff	;dc.l	$ffff00ff
	dc.l	$ffff00ff	;dc.l	$ffff00ff
	dc.l	$ffff00ff	;dc.l	$ffff00ff
	dc.l	$ffff00ff	;dc.l	$ffff00ff
	dc.l	$ffff00ff	;dc.l	$ffff00ff

******** RESERVES ********

	bss
	even

*init-data

oldsp	ds.l	1
oldscr	ds.l	1
oldvbl	ds.l	1
fvbuf	ds.w	24

*scr-stuff

scr	ds.l	3
	ds.l	1
scrbuf	ds.w	320*scrlines
	ds.w	320*scrlines
	ds.w	320*scrlines

*general timers

old4ba	ds.l	1
old466	ds.l	1
frmcnt	ds.l	1

*random stuff

random	ds.l	1

*fire-stuff

realpal	ds.w	256
fire_pal
	ds.l	256*256				* Optimised lookup table!
truepal	ds.l	256+1
firebuf	ds.b	320*scrlines			* put on LONG EDGE for optimal results!