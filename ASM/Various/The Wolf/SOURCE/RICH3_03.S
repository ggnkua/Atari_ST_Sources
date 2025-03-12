*  MENU1_06.S  Hopefully soon-to-be 16*16 scroller + mad max tunes...
*  For Rich...  The Wolf, 13/8/92, 12:23am...
*  RICH3_01.S - Yippie!  Yippie!  Yippie!  It works!!!  It works!!!
*  Yahoooo!  Wahaaay!!!!   Brilliant!!!!   Absolutely bloody amazing!!!
*  (and it's only 4:54am...  Ugh!  What the hell am I doing still up?
*  why did I decide to write a 16*16 scroller tonight???  (I could have
*  just slightly altered the routine I used for 32*32 scrolltexts, but
*  it goes WAY too fast with a small font... Be Grateful, be VERY Grateful!)

*  I've only commented the lines you may want/need to change (music routines
*  + program filenames etc.  Enjoy!)

*  Radically altered proggy, RICH1_03.S, stardate 13/8/92,2:28pm (I decided
*  to take the day of work...)  Fader added, all minor gripes fixed, if you
*  don't like it, go flush your head down the toilet until you reconsider...

*  I'm off to visit some Uni mates, and I'm gonna get COMPLEEEETELY out of
*  my head....  (I need to - some parts of this code were a real bitch to
*  "mate" with each other...)

*  Stardate 4:30pm, Sunday 23rd August.  Bloody stupid bug fixed (It's all
*  the packers fault for not clearing the BSS section...).  Currently
*  contemplating a complete re-write to shrink the code... (but it's only
*  24K when packed....  Whine whine!)

*  Proggy finished.  It's still big, but i'm not going to shrink the
*  bastard unless someones life depends on it...  I've disabled the mouse
*  and joystick and added a mono message - what more do you want?  Blood???
*  The Wolf 23/8/92, 8:39pm

	movea.l	4(a7),a3
	move.l	#mystack,a7
	move.l	a3,basepage
	move.l	$C(a3),d0
	add.l	$14(a3),d0
	add.l	$1C(a3),d0
	addi.l	#$100,d0
	bsr.s	m_shrink
	bsr.s	s_super	

	bsr	code

	move.l	#tinystack,a7
	move.l	basepage,a3
	move.l	#tinystack,d0
	sub.l	a3,d0
	bsr.s	m_shrink
	pea	envirom(pc)
	pea	command(pc)
	pea	filename(pc)
	move.w	#0,-(a7)
	move.w	#$4B,-(a7)
	trap	#1
	lea	16(a7),a7
	tst.w	resetflag
	bne	p_term
	move.l	$4F2,a7
	jmp	(a7)
p_term	bsr.s	s_super
	clr.w	-(a7)
	trap	#1

s_super	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	lea	6(a7),a7
	rts
m_shrink	move.l	d0,-(a7)
	move.l	a3,-(a7)
	clr.w	-(a7)
	move.w	#$4A,-(a7)
	trap	#1
	lea	12(a7),a7
	rts

basepage	ds.l	1
envirom	dc.b	0,0
command	ds.b	80
filename	ds.b	80
resetflag	dc.w	1
	ds.l	20
tinystack	ds.w	1

******************************************************************************

code	move.w	#4,-(a7)
	trap	#14
	lea	2(a7),a7
	move.w	d0,res
	subi.b	#2,d0
	bne	.colour
	bra	mono
.colour	
.kbdwait1	btst.b	#1,$FFFFFC00
	beq.s	.kbdwait1
	move.b	#$12,$FFFFFC02
.kbdwait2	btst.b	#1,$FFFFFC00
	beq.s	.kbdwait2
	move.b	#$1A,$FFFFFC02
	move.l	$70,-(sp)
	movem.l	$FFFF8240,d0-d7
	movem.l	d0-d7,oldpal
	jsr	fadeout
	move.l	$44E.W,old_scr
	clr.b	$FFFF8260.W
	move.l	#piccy+128,d0
	clr.b	d0
	move.l	d0,phys
	addi.l	#32256,d0
	move.l	d0,logic
	bsr	flipscr
	move.l	phys,a1
	lea	piccy+128,a0
	move.w	#8000-1,d7
.picin1	move.l	(a0)+,(a1)+
	dbra	d7,.picin1
	move.l	phys,a0
	move.l	logic,a1
	move.w	#8000-1,d7
.picin2	move.l	(a0)+,(a1)+
	dbra	d7,.picin2
	lea	scratch,a0
	move	#64-1,d0
.clear	clr.l	(a0)+
	dbf	d0,.clear
delay1	move.w	#20,d0
.wait	move.w	#-1,$468.w
.vbl	tst.w	$468.w
	bne.s	.vbl
	dbra	d0,.wait

	move.w	#1,d0		Music player details
	jsr	music		(see "vbl" for actual player...)
	move.l	#vbl,$70

delay2	move.w	#20,d0
.wait	move.w	#-1,$468.w
.vbl	tst.w	$468.w
	bne.s	.vbl
	dbra	d0,.wait
	lea	font+4,a0
	jsr	fadeup

progloop	move.w	#-1,$468.w
.waitvbl	tst.w	$468.w
	bne.s	.waitvbl
	bsr	scroll
	bsr	flipscr
	bra	scankeys
donescan	bra.s	progloop

quit	lea	whitepal,a0
	jsr	fadeup
	move.l	(sp)+,$70
	move.l	#$08080000,$FF8800
	move.l	#$09090000,$FF8800
	move.l	#$0A0A0000,$FF8800
	move.w	res,-(a7)
	move.l	old_scr,-(a7)
	move.l	(a7),-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$FFFF8240
.kbdwait1	btst.b	#1,$FFFFFC00
	beq.s	.kbdwait1
	move.b	#$08,$FFFFFC02
	rts

mono	pea	monotext
	move.w	#9,-(a7)
	trap	#1
	lea	6(a7),a7
.waitspc	cmp.b	#$39,$FFFFFC02
	bne	.waitspc
	rts
monotext	dc.b	$1b,"Y",40,42,"Hi there!  Unfortunately this menu has no monochrome support"
	dc.b	$1b,"Y",41,42,"and you appear to be using a mono monitor so it's bye bye..."
	dc.b	$1b,"Y",44,61,"Hit space to quit.",0

******************************************************************************

flipscr	move.l	phys,d0
	move.l	logic,d1
	move.l	d1,phys
	move.l	d0,logic
	lsr.w	#8,d1
	move.l	d1,$FFFF8200.W
	move.l	d0,$44E.W
	rts

scroll	subq.w	#1,pix
	bne.s	.in_let
	moveq.w	#0,d0
	move.l	txt_pos(pc),a0
	move.b	(a0)+,d0
	bne.s	.notend
	lea	sc_txt(pc),a0
	move.b	(a0)+,d0
.notend	move.l	a0,txt_pos
	subi.w	#32,d0
	lsl.w	#2,d0
	lea	look_up(pc),a0
	lea	font+128,a1
	add.l	0(a0,d0),a1
	move.w	#4,pix
	moveq.w	#15,d1
	lea	scratch+8,a0
.copy	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	lea	8(a0),a0
	lea	152(a1),a1
	dbra	d1,.copy
.in_let	move.l	$44E.W,a0
	lea	152(a0),a1
	move.w	#1200,d0
.line	move.b	1(a0),(a0)+
	move.b	7(a0),(a0)+
	dbra	d0,.line
	moveq.w	#15,d1
	lea	scratch,a0
.l5	moveq	#3,d2
.l52	move.b	1(a0),d0
	lsl.w	#8,d0
	move.b	8(a0),d0
	lsl.l	#8,d0
	move.b	9(a0),d0
	lsl.l	#4,d0
	move.b	d0,9(a0)
	lsr.l	#8,d0
	move.b	d0,8(a0)
	lsr.w	#8,d0
	move.b	d0,1(a0)
	lea	2(a0),a0
	dbra	d2,.l52
	lea	8(a0),a0
	dbra	d1,.l5
	moveq.w	#15,d1
	lea	scratch,a0
.lt2scr	move.b	1(a0),1(a1)
	move.b	3(a0),3(a1)
	move.b	5(a0),5(a1)
	move.b	7(a0),7(a1)
	lea	16(a0),a0
	lea	160(a1),a1
	dbra	d1,.lt2scr
	rts

scankeys	move.b	$FFFFFC02.w,d0	d0=scan code
	tst.b	d0
	beq	donescan
	cmpi.b	#2,d0		scan code for key #1
	blt	donescan
	cmpi.b	#4,d0		scan code for last key in use (n+1)
	bgt	donescan
	subi.b	#2,d0
	andi.l	#$FF,d0
	lsl.l	#2,d0
	lea	prgtable,a0
	adda.l	d0,a0
	move.l	(a0),a0
	lea	filename(pc),a1
	move.w	#79,d1
.copyprg	move.b	(a0)+,(a1)+
	dbra	d1,.copyprg
	lea	comtable,a0
	adda.l	d0,a0
	move.l	(a0),a0
	lea	command(pc),a1
	move.w	#79,d1
.copycom	move.b	(a0)+,(a1)+
	dbra	d1,.copycom
	lsr.l	#1,d0
	lea	restable,a0
	adda.l	d0,a0
	move.w	(a0),resetflag
	bra	quit

fadeout	move.w	#1,d0
.wait	move.w	#-1,$468.w
.vbl	tst.w	$468.w
	bne.s	.vbl
	dbra	d0,.wait
	clr.b	d3
	move.w	#15,d0
	lea	$FF8240,a0
.col_loop	move.w	(a0)+,d1
	andi.w	#$777,d1
	beq	.nextcol
	move.b	#1,d3
	move.w	d1,d2
	andi.w	#$007,d2
	beq	.green
	subi.w	#$1,d1
.green	move.w	d1,d2
	andi.w	#$070,d2
	beq	.red
	subi.w	#$10,d1
.red	move.w	d1,d2
	andi.w	#$700,d2
	beq	.nextcol
	subi.w	#$100,d1
.nextcol	move.w	d1,-2(a0)
	dbra	d0,.col_loop
	tst.b	d3
	bne	fadeout
	rts

fadeup	move.w	#3,d0
.wait	move.w	#-1,$468.w
.vbl	tst.w	$468.w
	bne.s	.vbl
	dbra	d0,.wait
	lea	$FFFF8240,a1
	move.l	a0,a2
	clr.b	d3
	move.w	#15,d0
.col_loop	move.w	(a1)+,d1
	move.w	(a2)+,d4
	andi.w	#$777,d1
	andi.w	#$777,d4
	cmp.w	d1,d4
	beq.s	.nextcol
	move.b	#1,d3
	move.w	d1,d2
	move.w	d4,d5
	andi.w	#$007,d2
	andi.w	#$007,d5
	cmp.w	d2,d5
	beq.s	.green
	addi.w	#$1,d1
.green	move.w	d1,d2
	move.w	d4,d5
	andi.w	#$070,d2
	andi.w	#$070,d5
	cmp.w	d2,d5
	beq.s	.red
	addi.w	#$10,d1
.red	move.w	d1,d2
	andi.w	#$700,d2
	andi.w	#$700,d4
	cmp.w	d2,d4
	beq.s	.nextcol
	addi.w	#$100,d1
.nextcol	move.w	d1,-2(a1)
	dbra	d0,.col_loop
	tst.b	d3
	bne	fadeup
	rts

count	add.w	#1,$468.w
	rte

vbl	add.w	#1,$468.w
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	music+8		Make sure this is correct...
	movem.l	(a7)+,d0-d7/a0-a6
	rte

music	incbin	sheep.bin	The music file...

******************************************************************************

	SECTION DATA
whitepal	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777
txt_pos	dc.l	sc_txt
pix	dc.w	1
sc_txt	incbin	scroller.txt
	dc.b	0
	even
look_up	dc.l $0000,$0008,$0010,$0018,$0020,$0028,$0030,$0038,$0040,$0048
	dc.l $0050,$0058,$0060,$0068,$0070,$0078,$0080,$0088,$0090,$0098
	dc.l $0A00,$0A08,$0A10,$0A18,$0A20,$0A28,$0A30,$0A38,$0A40,$0A48
	dc.l $0A50,$0A58,$0A60,$0A68,$0A70,$0A78,$0A80,$0A88,$0A90,$0A98
	dc.l $1400,$1408,$1410,$1418,$1420,$1428,$1430,$1438,$1440,$1448
	dc.l $1450,$1458,$1460,$1468,$1470,$1478,$1480,$1488,$1490,$1498
font	incbin	16_16_03.neo
prgtable	dc.l	prg1,prg2,prg3
comtable	dc.l	com,com,com
restable	dc.w	1,1,1			(0=reset, 1=pterm)
prg	dc.b	0			(quits to desktop)
com	dc.b	0			(normal command line)
prg1	dc.b	"A:\PROGS\PROG1.PRG",0
prg2	dc.b	"A:\PROGS\PROG2.PRG",0
prg3	dc.b	"A:\PROGS\PROG3.PRG",0
	even
	ds.b	128
piccy	incbin	towerpd.neo

	SECTION BSS
	ds.b	32512
oldpal	ds.w	16
res	ds.w	1
phys	ds.l	1
logic	ds.l	1
old_scr	ds.l	1
scratch	ds.b	256
	ds.l	100
mystack	ds.w	1
