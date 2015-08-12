*
*
*   Rotate 90 degrees clockwise a large rectangular page-size form in place
*   where the DST form width is less than the SRC form
*
*   Programmer: Dave Staugas
*         Date: 9-June-89
*
*
*   Paper size data:					Timings (secs):
*					Temp buf size:   5k  10k  20k  40k
*	 Port_width   Land_width   Rectangle excess  d2= 1    2    4    8
*	 ----------   ----------   ----------------
*  Letter  300		398	   98			 56   35   25   20
*  Legal   300		510	   210			123   71   45   32
*  A4	   292		424	   132			 72   43   29   22
*  B5	   252		366	   114			 47   30   20   16
*
*
	.globl	roto
	.globl	recrot
*
*
*   Entry:
*
*   a0   -> base address of landscape form to rotate
*   a1   -> temp buffer allocated in multiples of (16 * DST form-width)
*   d0.w =  SRC form-width in bytes (must be even)
*   d1.w =  DST form-width in bytes (must be even)
*   d2.w =  # of (16 * DST form-width) multiples that can be used in temp buffer
*
*   Exit:
*
*   all registers preserved, rectangular form is rotated in place
*        90 degrees clockwise with new (DST) form-width
*
recrot:
	movem.l	a0-a6/d0-d7,-(sp)
*
*  Test code
	move.l	a0,lasrbaz
	move.w	d0,lasrwid
	move.w	d1,lasrht
*  End test code
*
testpt0:
*
*  1st rotate largest chunk (a square) in place
*
	move.w	d1,d4		;do a square rotate 1st
	bsr	roto		;rotate the biggest chunk in place
*
*  Now rotate-copy d2.w vertical columns of tiles to temp buffer
*
	move.l	a1,a5		;save temp buf ptr in a5
	lea	(a0,d1.w),a2	;a2-> SRC top tile of column just rite of square
	lea	-2(a1,d1.w),a3	;a3-> DST top/rightmost tile of temp buf
schlp:
	move.w	d0,d7		;d0 = SRC wrap
	lsl.w	#4,d7		;d7 = SRC tile wrap
*
	move.w	d1,d6		;d1 = DST wrap
	lsl.w	#4,d6		;d6 = DST tile wrap
*
	move.l	a2,a4		;save a2 for later
	move.w	d1,d4		;DST width
	lsr.w	#1,d4
	subq.w	#1,d4		;d4 = # of tiles in column (-1)
	subq.w	#1,d2		;d2 = # of columns (-1)
buflp0:
	movem.l	a2-a3/d2/d4/d6,-(sp)
buflp:
	move.l	a2,a1
	move.l	a3,a6
	bsr	rot2tile
	adda.w	d7,a2
	subq.l	#2,a3	
	dbra	d4,buflp

	movem.l	(sp)+,a2-a3/d2/d4/d6
	addq.l	#2,a2
	adda.w	d6,a3
	dbra	d2,buflp0
*
	move.l	8(sp),d2	;restore buffer size multiple
	add.w	d2,d2		;  in words
*
*   buffer is full, now scrunch the big form (decrease SRC width by d2*2 bytes)
*
	move.l	a4,a3		;1st DST column just right of big square
	lea	(a3,d2.w),a2	;1st SRC column just right of copied columns
	move.w	d1,d4
	lsl.w	#3,d4		;DST width *8 is # of rows
	move.w	d4,d7
	subq.w	#2,d7
*
	sub.w	d2,d0		;new SRC width (it's shrinking)
	move.w	d0,d4
	lsr.w	#2,d4		;get # of long words in SRC row
	bcc.s	elong		;br if integral # of longwords
*
*   else, do one short word 1st..
*
rwlp0:
	move.w	d4,d5
	move.w	(a2)+,(a3)+
	bra.s	rwlp1i
rwlp1:
	move.l	(a2)+,(a3)+
rwlp1i:
	dbra	d5,rwlp1
	adda.w	d2,a2
	dbra	d7,rwlp0
	bra.s	rwdone
elong:	
	move.w	d4,d5
	bra.s	rwlp2i
rwlp2:
	move.l	(a2)+,(a3)+
rwlp2i:
	dbra	d5,rwlp2
	adda.w	d2,a2
	dbra	d7,elong
rwdone:
	move.w	d0,d7
	sub.w	d1,d7
	lsr.w	#1,d7
	bra	rwlp5i			;gotta get special case
rwlp5:
	move.w	(a2)+,(a3)+		;copied for inner column difference
rwlp5i:
	dbra	d7,rwlp5
*
*
	move.w	d1,d6		;d1 = DST wrap
	lsl.w	#4,d6		;d6 = DST tile wrap
*
scrnchlp:
	lea	(a0,d0.w),a2	;a2-> SRC top tile column at far right 
	lea	-2(a3,d1.w),a3	;a3-> DST rightmost tile of space just freed
*
* 
	move.w	d0,d7		;d0 = SRC wrap
	lsl.w	#4,d7		;d7 = tile wrap
*
	sub.w	d2,d0		;new SRC width (it's shrinking)
	cmp.w	d1,d0		;did we go too far?
	bpl.s	.10		;br if ok
*
	move.w	d1,d3
	sub.w	d0,d3		;d3 = # of word-columns not to do
	sub.w	d3,d2		;d2 = # of word-columns to do
	add.w	d3,d0
	lsr.w	#1,d3		;d2 = # of columns not done this trip
	mulu	d6,d3
	add.l	d3,a3		;adjust DST ptr
.10:
	add.w	d2,d0
	suba.w	d2,a2		;adjust SRC ptr
*
	move.l	a2,a4		;save a2 for later
	move.w	d1,d4		;DST width
	lsr.w	#1,d4
	subq.w	#1,d4		;d4 = # of tiles in column (-1)
	move.w	d2,-(sp)
	lsr.w	#1,d2
	subq.w	#1,d2		;d2 = # of columns (-1)
bufloop0:
	movem.l	a2-a3/d2/d4/d6,-(sp)
bufloop:
	move.l	a2,a1
	move.l	a3,a6
	bsr	rot2tile
	adda.w	d7,a2
	subq.l	#2,a3	
	dbra	d4,bufloop
*
	movem.l	(sp)+,a2-a3/d2/d4/d6
	addq.l	#2,a2
	adda.w	d6,a3
	dbra	d2,bufloop0
*
	move.w	(sp)+,d2
*
*   now scrunch the big form (decrease SRC width by d2 bytes)
*
	sub.w	d2,d0
	move.l	a4,a3		;1st DST to holding buffer
	lea	(a3,d2.w),a2	;1st SRC column just right of big square
	move.w	d1,d4
	lsl.w	#3,d4		;DST width *8 is # of rows
	move.w	d4,d7
	subq.w	#2,d7
*
	move.w	d0,d4
	lsr.w	#2,d4		;get # of long words in SRC row
	bcc.s	evnlong		;br if integral # of longwords
*
*   else, do one short word 1st..
*
rowlp0:
	move.w	d4,d5
	move.w	(a2)+,(a3)+
	bra.s	rowlp1i
rowlp1:
	move.l	(a2)+,(a3)+
rowlp1i:
	dbra	d5,rowlp1
	adda.w	d2,a2
	dbra	d7,rowlp0
	bra.s	rowdone
evnlong:	
	move.w	d4,d5
	bra.s	rowlp2i
rowlp2:
	move.l	(a2)+,(a3)+
rowlp2i:
	dbra	d5,rowlp2
	adda.w	d2,a2
	dbra	d7,evnlong
rowdone:
	cmp.w	d0,d1			;have we become DST form-width?
	bne	scrnchlp		;iterate until we are DST
*
*   Now copy buffer to last freed area
*
*	a3-> DST tile area just freed
*
	move.l	a5,a2		;get buffer copied back in
*
	lsl.w	#3,d0		;DST wrap *8 is # of words in buffer
	mulu	8+2(sp),d0
	bra.s	bufini
bufinlp:
	move.w	(a2)+,(a3)+
bufini:
	dbra	d0,bufinlp
*
*   test code
	move.w	lasrwid,d1
	move.w	lasrht,d2
	move.w	d2,lasrwid
	move.w	d1,lasrht
*
*   end test
*
testpt1:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*   Rotate 90 degrees clockwise a large square page-size form in place
*
*   Programmer: Dave Staugas
*         Date: 5-June-89
*
*   Entry:
*
*   a0   -> base address of square form to rotate
*   d0.w =  form-width in bytes (must be even)
*   d4.w =  # of bytes on a side of the square (also must be even)
*
*   Exit:
*
*  all regs preserved, square form is rotated in place 90 degrees clockwise
*
roto:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	d0,d7		;copy form-width to d7
	lsl.w	#4,d7		;x16 for offset in form for 1 tile down
*
	lsr.w	#1,d4		;d4 = # tiles on a side
*
*   a2 -> top/left tile address
*
*   d0 = form-wrap
*   d4 = # of tiles on a side
*   d7 = offset in form for 1 tile down
*
rotlp0:
	move.l	a0,a2		;a2 -> top/left tile
	move.w	d4,d3
	subq.w	#1,d3
	mulu	d7,d3
	lea	(a2,d3.l),a4	;a4 -> bot/left tile
	add.w	d4,d4
	lea	-2(a2,d4.w),a3	;a3 -> top/right tile
	lea	-2(a4,d4.w),a5	;a5 -> bot/right tile
	lsr.w	#1,d4
rotlp1:
	move.l	a2,a1		;top/left is SRC
	moveq	#2,d1		;DST form wrap (just 16 byte buffer)
	lea	tilebuf,a6
	bsr	rot2tile	;rotate top/left to buffer
*
	move.l	a4,a1		;bot/left is SRC
	move.w	d0,d1		;DST form wrap is same as SRC
	move.l	a2,a6		;top/left is DST
	bsr	rot2tile	;rotate bot/left to top/left tile
*	
	move.l	a5,a1		;bot/right is SRC
	move.l	a4,a6		;bot/left is DST
	bsr	rot2tile	;rotate bot/right to bot/left tile
*
	move.l	a3,a1		;top/right is SRC
	move.l	a5,a6		;bot/right is DST
	bsr	rot2tile	;rotate top/right to bot/right
*
	lea	tilebuf,a1
	move.l	a3,a6
	moveq	#15,d5
coploop:
	move.w	(a1)+,(a6)
	adda.w	d0,a6
	dbra	d5,coploop	;copy rotated tile buffer to top/left
*
	adda.w	d7,a2		;move top/left down 1 tile
	suba.w	d7,a5		;move bot/right up 1 tile
	addq.l	#2,a4		;move bot/left right 1 tile
	subq.l	#2,a3		;move top/right left 1 tile
	cmp.l	a0,a3		;does top/right equal base?
	bne	rotlp1		;iterate until it does
*
	lea	2(a0,d7.w),a0	;now put base down 1 tile & left 1 tile
	subq.l	#2,d4		;next # of tiles on a side
	beq.s	rotdone		;br if none left
	cmpi.w	#1,d4		;check for odd case
	bne	rotlp0
*
	move.l	a0,a1
	move.l	a0,a6
	bsr	rot2tile
*
rotdone:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
*
*	
******************************************
*
*   Rotate a 16x16 pixel tile clockwise 90 degrees and copy to another tile
*
*
*   d0 = SRC form-wrap
*   d1 = DST form-wrap
*
*   a1 -> top/left of SRC tile
*   a6 -> top/left of DST tile
*  
rot2tile:
	movem.l	a0/a2-a5/d0-d1/d4/d7,-(sp)
*
*  pack 16 words of tile into 4 data & 4 address registers..
*
	move.w	(a1),d2
	adda.w	d0,a1
	move.w	(a1),d3
	adda.w	d0,a1
	move.w	(a1),d4
	adda.w	d0,a1
	move.w	(a1),d5
	adda.w	d0,a1
*
	swap	d2
	swap	d3
	swap	d4
	swap	d5
*
	move.w	(a1),d2
	adda.w	d0,a1
	move.w	(a1),d3
	adda.w	d0,a1
	move.w	(a1),d4
	adda.w	d0,a1
	move.w	(a1),d5
	adda.w	d0,a1
*
	exg	d2,a2
	exg	d3,a3
	exg	d4,a4
	exg	d5,a5
*
	move.w	(a1),d2
	adda.w	d0,a1
	move.w	(a1),d3
	adda.w	d0,a1
	move.w	(a1),d4
	adda.w	d0,a1
	move.w	(a1),d5
	adda.w	d0,a1
*
	swap	d2
	swap	d3
	swap	d4
	swap	d5
*
	move.w	(a1),d2
	adda.w	d0,a1
	move.w	(a1),d3
	adda.w	d0,a1
	move.w	(a1),d4
	adda.w	d0,a1
	move.w	(a1),d5
*
*   Got all 16 words of tile in registers, now rotate..
*
	moveq	#3,d0		;iterate 4 times
rotlp2:
	swap	d1		;DST form-width to high word
	swap	d0		;get d0.w ready to receive bits
	add.w	d5,d5
	addx.w	d1,d1
	add.w	d5,d5
	addx.w	d0,d0
	add.w	d5,d5
	addx.w	d6,d6
	add.w	d5,d5
	addx.w	d7,d7

	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d6,d6
	add.w	d4,d4
	addx.w	d7,d7

	add.w	d3,d3
	addx.w	d1,d1
	add.w	d3,d3
	addx.w	d0,d0
	add.w	d3,d3
	addx.w	d6,d6
	add.w	d3,d3
	addx.w	d7,d7

	add.w	d2,d2
	addx.w	d1,d1
	add.w	d2,d2
	addx.w	d0,d0
	add.w	d2,d2
	addx.w	d6,d6
	add.w	d2,d2
	addx.w	d7,d7
*
	swap	d2
	swap	d3
	swap	d4
	swap	d5
*
	add.w	d5,d5
	addx.w	d1,d1
	add.w	d5,d5
	addx.w	d0,d0
	add.w	d5,d5
	addx.w	d6,d6
	add.w	d5,d5
	addx.w	d7,d7

	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d6,d6
	add.w	d4,d4
	addx.w	d7,d7

	add.w	d3,d3
	addx.w	d1,d1
	add.w	d3,d3
	addx.w	d0,d0
	add.w	d3,d3
	addx.w	d6,d6
	add.w	d3,d3
	addx.w	d7,d7

	add.w	d2,d2
	addx.w	d1,d1
	add.w	d2,d2
	addx.w	d0,d0
	add.w	d2,d2
	addx.w	d6,d6
	add.w	d2,d2
	addx.w	d7,d7
*
	swap	d2
	swap	d3
	swap	d4
	swap	d5
*
	exg	d2,a2
	exg	d3,a3
	exg	d4,a4
	exg	d5,a5
*
*
	add.w	d5,d5
	addx.w	d1,d1
	add.w	d5,d5
	addx.w	d0,d0
	add.w	d5,d5
	addx.w	d6,d6
	add.w	d5,d5
	addx.w	d7,d7

	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d6,d6
	add.w	d4,d4
	addx.w	d7,d7

	add.w	d3,d3
	addx.w	d1,d1
	add.w	d3,d3
	addx.w	d0,d0
	add.w	d3,d3
	addx.w	d6,d6
	add.w	d3,d3
	addx.w	d7,d7

	add.w	d2,d2
	addx.w	d1,d1
	add.w	d2,d2
	addx.w	d0,d0
	add.w	d2,d2
	addx.w	d6,d6
	add.w	d2,d2
	addx.w	d7,d7
*
*
	swap	d2
	swap	d3
	swap	d4
	swap	d5
*

	add.w	d5,d5
	addx.w	d1,d1
	add.w	d5,d5
	addx.w	d0,d0
	add.w	d5,d5
	addx.w	d6,d6
	add.w	d5,d5
	addx.w	d7,d7

	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d6,d6
	add.w	d4,d4
	addx.w	d7,d7

	add.w	d3,d3
	addx.w	d1,d1
	add.w	d3,d3
	addx.w	d0,d0
	add.w	d3,d3
	addx.w	d6,d6
	add.w	d3,d3
	addx.w	d7,d7

	add.w	d2,d2
	addx.w	d1,d1
	add.w	d2,d2
	addx.w	d0,d0
	add.w	d2,d2
	addx.w	d6,d6
	add.w	d2,d2
	addx.w	d7,d7
*
	swap	d2
	swap	d3
	swap	d4
	swap	d5
*
	exg	d2,a2
	exg	d3,a3
	exg	d4,a4
	exg	d5,a5
*
	move.w	d1,(a6)
	swap	d1		;get DST form-width
	adda.w	d1,a6
	move.w	d0,(a6)
	swap	d0		;get loop count
	adda.w	d1,a6
	move.w	d6,(a6)
	adda.w	d1,a6
	move.w	d7,(a6)
	adda.w	d1,a6
*
	dbra	d0,rotlp2	;do all 16
*
	movem.l	(sp)+,a0/a2-a5/d0-d1/d4/d7
	rts
*
*
*
*
*  test code
*
view:
	movem.l	a0-a6/d0-d7,-(sp)
	moveq	#0,d1			;horz
	moveq	#0,d2			;vert
view0:
	move.l	lasrbaz,a0
	move.w	d2,d0
	mulu	lasrwid,d0
	add.l	d0,a0
	add.l	d1,a0
	lea	$c00000,a1
	move.w	lasrwid,d0
	sub.w	#160,d0

	move.w	lasrht,d4
	lsl.w	#3,d4
	move.w	#960,d5
	add.w	d2,d5
	cmp.w	d5,d4
	bcc.s	doview
	sub.w	d4,d5
	move.w	#960,d4
	sub.w	d5,d4
	bra.s	view1i
doview:
	move.w	#960,d4
	moveq	#0,d5
	bra.s	view1i
view1:
	move.w	#79,d3
view2:
	move.w	(a0)+,(a1)+
	dbra	d3,view2
	adda.w	d0,a0
view1i:
	dbra	d4,view1
*
	subq.w	#1,d5
	bmi.s	viewdon
	move.w	#79,d3
view3:
	move.w	#-1,(a1)+
	dbra	d3,view3
	bra.s	view4i
view4:
	move.w	#79,d3
view5:
	clr.w	(a1)+
	dbra	d3,view5
view4i:
	dbra	d5,view4
viewdon:
*
	movem.l	d1-d2,-(sp)
	move.w	#2,-(sp)	
	move.w	#2,-(sp)	
	trap	#13
	addq.l	#4,sp
	movem.l	(sp)+,d1-d2
	tst.w	d0
	bne.s	exit
	swap	d0
	cmpi.b	#$4d,d0		;rite
	bne.s	.10
	add.w	#80,d1
	bra	view0
.10:
	cmpi.b	#$4b,d0		;left
	bne.s	.20
	sub.w	#80,d1
	bpl	view0
	moveq	#0,d1
	bra	view0
.20:
	cmpi.b	#$50,d0		;down
	bne.s	.30
	add.w	#480,d2
	bra	view0
.30:
	cmpi.b	#$48,d0		;up
	bne.s	exit
	sub.w	#480,d2
	bpl	view0
	moveq	#0,d2
	bra	view0
*
exit:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
lasrbaz:
	.dc.l	$c00000
lasrwid:
	.dc.w	160
lasrht:
	.dc.w	50
*
*
	.bss
tilebuf:
	.ds.w	16
