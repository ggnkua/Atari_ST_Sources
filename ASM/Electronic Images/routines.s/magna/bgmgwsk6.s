		opt	o+,w-
;
; Resolved the crappy Y mag bit for FULL...
; Now I only have to clear the (proper) 2 lines...  But phew!  The overflow
; check kicks in at line 200 so check that bit...
;
; Well, that's OK now!  I sped up the main expander a bit!
;
; *blush* Martin spotted a really shite thingie...  Oops!  8 cycles faster
; per byte *blush*.
;
; This one about 15% faster, but the magnify pixel tables are 4 times
; bigger (160 bytes instead of 40, making the table 64K big instead of
; 16K for 400 sizes).  Also, D1 needs not to be cleared, saving 4 cycles.
;
; Well, raise my rent!  With one extra word of memory I replaced the left
; shift 8 by a memory write/read...  Knocked off about 5 scanlines!
;
;

timing	equ	1		; Timing bar.

bufwd	equ	80
bufhg	equ	8
bufsize	equ	bufwd*bufhg

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                adda.l  #6,SP
                move.l  D0,oldsp        * Set supervisor mode

		move.w	#37,-(sp)
		trap	#14
		addq.w	#2,sp
		clr.b	$ffff8260.w


************* Generate byte > magnified byte table (65536 bytes!).


		lea	bytebuff,a0		; Start of table!
		move.w	#256-1,d0		; Counter of master byte.

		moveq	#0,d1			; Start count at 0.

nextbyte:
		moveq	#0,d4			; Pixel byte =0.

		move.w	#256-1,d6		; 256 times too!

nextpix:	moveq	#0,d7			; Clear destination byte.
		move.w	#%10000000,d5		; Mask.

val1		set	7
val2		set	%10000000		
		rept	8
		btst	#val1,d1		; Check first bit.		
		dc.w	$670e			; Zero... No move.
; Ok...  A 1...  Get pixel and move.
		move.b	d5,d2			; Restore mask.
		lsr.b	#1,d5			; And move mask on...
		and.b	d4,d2			; And get bit.
		dc.w	$6710			; No bit set...  Skip.
		or.b	#val2,d7		; Bit set... Do it!
		dc.w	$600a			; Next bit...
; A 0...  Get pixel and NO MOVE.
		move.b	d5,d2			; Restore mask.
		and.b	d4,d2			; And get bit.
		dc.w	$6704			; No bit set...  Skip.		
		or.b	#val2,d7		; Bit set...  Do it!
val1		set	val1-1
val2		set	val2/2
		endr

;  O.K.  Here we have D7 as the 'magnified' byte.
		move.b	d7,(a0)+		; Store the byte.

		addq.w	#1,d4			; Increment pixel value.
		dbra	d6,nextpix

		addq.w	#7,$ffff8240.w

		addq.w	#1,d1			; Increment master byte.
		dbra	d0,nextbyte		; And no next set.

		move.l	a0,magdat
		

********** Generate mangify data...

		move.w	#400-1,d5	; 400 Sizes.

		lea	pixoffs(pc),a1
		lea	tabx256(pc),a2

dosizetab:
                move.l  #320,D0         * Top
mod1:           move.l  #320,D1         * / bottom.

; Oo-er!  We need precision to 1/65536, as 1/256 is crap!
		move.l	d0,d2
		divu	d1,d2
		move.w	d2,d0
		swap	d0
		clr.w	d2
		divu	d1,d2
		move.w	d2,d0

                move.w  D0,D1
                swap    D0
                moveq   #0,D2

                move.w  #0,D3           ; Start X
		
;> A0 has start addr of mag table already...

		move.w	#20-1,d6	; 320 bits here.

genmags: 	
		clr.l	(a0)
		clr.l	4(a0)
val		set	%1000000000000000
		rept	16
		add.w   D1,D2
		dc.w	$6204		; BHI.S
		or.w	#val,(a0)
val		set	val/2
		endr
		moveq	#0,d4
		moveq	#0,d7
		move.b	(a0),d4
		move.b	1(a0),d7
		add.w	d4,d4
		add.w	d7,d7
		move.w	(a1,d4.w),(a0)+
		move.w	(a2,d4.w),(a0)+
		move.w	(a1,d7.w),(a0)+
		move.w	(a2,d7.w),(a0)+
                addx.w  D0,D3
		dbra	d6,genmags

		add.l	#10,mod1+2
		dbra	d5,dosizetab

*************

		move.l	a0,buff
		moveq	#0,d1
		move.w	#640-1,d0
wipesc:		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		dbra	d0,wipesc

		addq.w	#4,a0
		move.l	a0,d0
		add.l	#256,d0
		clr.b	d0
		move.l	d0,scrnpos
		add.l	#32000,d0
		move.l	d0,scrn2
		
		move.l	scrnpos(pc),a0
		move.w	#3999,d0
cls:		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		dbra	d0,cls


		move.w	#$2700,sr
		move.l	$70.w,oldvbl
		move.l	#vbl,$70.w
		move.b	$fffffa07.w,sa1
		move.b	$fffffa09.w,sa2
		clr.b	$fffffa07.w
		clr.b	$fffffa09.w

		moveq	#1,d0
		bsr	mus

		move.w	#$2300,sr
		

                clr.w   $FFFF8240.w
		move.w	#$736,$ffff8242.w

*       move.w  #37,-(sp)
*       trap    #14
*       addq.l  #2,sp
*       move.b  #0,$ffff8260.w       * Low resolution


key:

		move.b	lcount(pc),d0
sync:		cmp.b	lcount(pc),d0
		beq.s	sync

		ifne	timing
                move.w  #$007,$FFFF8240.w
		endc

	movem.l	d0-d5/a0-a1,-(sp)
	
	move.l	textptr,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	tst.b	(a1)
	bne.s	notwrap1
	lea	text,a1
notwrap1:
	move.l	a1,textptr

	move.w	scrlcnt,d4

**
********* Check for flag signal.
	cmpi.b	#1,3(a1)
	bne.s	nosets
	move.w	#1,on
nosets:
**

	move.b	(a1),d0
	cmpi.b	#32,d0
	bgt.s	nozr
	moveq	#' ',d1
nozr:	move.b	1(a1),d1
	cmpi.b	#32,d1
	bgt.s	nozr1
	moveq	#' ',d1
nozr1:	move.b	2(a1),d2
	cmpi.b	#32,d2
	bgt.s	nozr2
	moveq	#' ',d2
nozr2:	move.b	3(a1),d3
	cmpi.b	#32,d3
	bgt.s	nozr3
	moveq	#' ',d3
nozr3:

	sub.b	#32,d0
	lsl.w	#3,d0

	sub.b	#32,d1
	lsl.w	#3,d1
	
	sub.b	#32,d2
	lsl.w	#3,d2
	
	sub.b	#32,d3
	lsl.w	#3,d3


	move.l	buff(pc),a0
	add.w	buffptr,a0
	add.w	whichbuf,a0
	lea	font,a1
	lea	(a1,d1.w),a4
	lea	(a1,d0.w),a3
	lea	(a1,d3.w),a2
	lea	(a1,d2.w),a1

	rept	8
	move.b	(a1)+,d5
	lsl.w	#8,d5
	move.b	(a2)+,d5
	swap	d5
	move.b	(a3)+,d5
	lsl.w	#8,d5
	move.b	(a4)+,d5
	rol.l	d4,d5
	move.w	d5,(a0)
	move.w	d5,(bufwd/2)(a0)
	lea	bufwd(a0),a0
	endr

	move.l	buff(pc),a1
	add.w	whichbuf,a1
	add.w	cbuff,a1

**********

; > A1 contains source data address (see 3 lines above!).

		lea	pixoffs(pc),a2
		lea	bytebuff,a3
		move.l	a3,usp
		lea	shifty(pc),a4
		lea	xoffs,a5
		lea	buffer2,a6
		moveq	#7,d2		; Shift.

		moveq	#0,d3		; For pixel data.
		moveq	#0,d4		; For pixel offset.

		move.w	#8,cpcount
		move.w	#%0000000011111111,d7	; Mask for nabbing byte.

		moveq	#0,d1		; Make sure top word D1 clear.

rows:
		move.l	magdat(pc),a0
		adda.l	magoff(pc),a0
		moveq	#0,d0		; X coordinate.

		add.w	(a0)+,d0	; Add X coordinate.
		move.w	(a0)+,d1	; Get D1 X 256.
		move.l	usp,a3		; Restore A3.
		adda.l	d1,a3		; Add to buffer address.
		move.b	(a1),d3		; Nab pixel data.
		move.b	(a3,d3.w),(a6)+	; > Converted byte.


		move.b	(a5,d0.w),d4	; Chunk pixel offset.
		move.w	d0,d6		; Pixel offset.
		and.w	d2,d6		; Shift offset (use D2 shift!).

		add.w	(a0)+,d0	; Add X offset.
		move.w	(a0)+,d1	; Get D1 X 256.
		move.l	usp,a3		; Restore A3.
		adda.l	d1,a3		; Add to buffer address.
		move.b	1(a1,d4.w),(a4)	; Nab pixel data.
		move.w	(a4),d3		; To top word.
		move.b	(a1,d4.w),d3	; Bottom word.
		rol.w	d6,d3		; Access byte.
		and.w	d7,d3		; Mask it out.
		move.b	(a3,d3.w),(a6)+	; > Converted byte.

		rept	19
		
		move.b	(a5,d0.w),d4	; Chunk pixel offset.
		move.w	d0,d6		; Pixel offset.
		and.w	d2,d6		; Shift offset (use D2 shift!).

		add.w	(a0)+,d0	; Add X offset.
		move.w	(a0)+,d1	; Get D1 X 256.
		move.l	usp,a3		; Restore A3.
		adda.l	d1,a3		; Add to buffer address.
		move.b	1(a1,d4.w),(a4)	; Nab pixel data.
		move.w	(a4),d3		; To top word.
		move.b	(a1,d4.w),d3	; Bottom word.
		rol.w	d6,d3		; Access byte.
		and.w	d7,d3		; Mask it out.
		move.b	(a3,d3.w),(a6)+	; > Converted byte.


		move.b	(a5,d0.w),d4	; Chunk pixel offset.
		move.w	d0,d6		; Pixel offset.
		and.w	d2,d6		; Shift offset (use D2 shift!).

		add.w	(a0)+,d0	; Add X offset.
		move.w	(a0)+,d1	; Get D1 X 256.
		move.l	usp,a3		; Restore A3.
		adda.l	d1,a3		; Add to buffer address.
		move.b	1(a1,d4.w),(a4)	; Nab pixel data.
		move.w	(a4),d3		; To top word.
		move.b	(a1,d4.w),d3	; Bottom word.
		rol.w	d6,d3		; Access byte.
		and.w	d7,d3		; Mask it out.
		move.b	(a3,d3.w),(a6)+	; > Converted byte.
		endr

		lea	bufwd(a1),a1

		subq.w	#1,cpcount
		bne	rows



	move.w	whichbuf(pc),d0
	add.w	#bufsize,d0
	cmpi.w	#bufsize*16,d0
	blt.s	nobro
	clr.w	d0
nobro:	move.w	d0,whichbuf

	move.l	textptr(pc),a1
	move.w	scrlcnt(pc),d4
	addq.w	#1,d4
	cmpi.w	#16,d4
	blt.s	nonchar
	clr.w	d4
	addq.w	#2,a1

	addq.w	#2,cbuff
	move.w	buffptr(pc),d0
	addq.w	#2,d0
	cmpi.w	#bufwd/2,d0
	blt.s	nobr
	clr.w	d0
	move.w	#2,cbuff
nobr:	move.w	d0,buffptr

nonchar:move.w	d4,scrlcnt

	move.l	a1,textptr
	
	movem.l	(sp)+,d0-d5/a0-a1


                move.l  #8,D0         * Top
                move.l  destsize(pc),D1         * / bottom.
		subq.l	#1,d1

; Oo-er!  We need precision to 1/65536, as 1/256 is crap!
		move.l	d0,d2
		divu	d1,d2
		move.w	d2,d0
		swap	d0
		clr	d2
		divu	d1,d2
		move.w	d2,d0

                move.w  D0,D1
                swap    D0
		move.w	d1,d2
		neg.w	d2

                move.w  #0,D3           ; Start X
		
;> A0 has start addr of mag table already...

		lea	ybuff,a0
		move.l	destsize(pc),d6	; 320 bits here.
		cmpi.l	#200,d6
		ble.s	yok
		move.w	#200,d6
yok:		subq.w	#1,d6

bigy:		add.w   D1,D2
                addx.w  D0,D3
		move.w	d3,(a0)+
		dbra	d6,bigy
		move.w	#-9999,(a0)+


		lea	buffer2,a0
		move.l	scrnpos(pc),a1
*		lea	2(a1),a1

		move.w	#200,d0
		lea	ybuff,a2

nxts:		clr.w	cpcount
		move.w	(a2)+,d1
		bmi	uh_oh
samen:		cmp.w	(a2),d1
		bne.s	endsize
		addq.w	#1,cpcount
		addq.w	#2,a2
		bra.s	samen
		
endsize:	move.w	cpcount(pc),d1
		add.w	d1,d1
		add.w	d1,d1
		lea	sizerouts(pc),a3
		move.l	(a3,d1.w),a3
		jsr	(a3)
		tst.w	d0
		bmi.s	uh_oh
		bra.s	nxts

		ifne	timing
		move.w	#$700,$ffff8240.w
		endc

uh_oh:
		moveq	#0,d0
scoff		set	0
		rept	40
		move.w	d0,scoff(a1)
scoff		set	scoff+8
		endr




* Well...  Just to flash aboot!
		tst.w	on
		beq	nofuck

******
***  Test code to try out the different mags.
		tst.w	flag
		bne.s	down
		move.l	magoff(pc),d0
		add.l	#160,d0
		cmpi.l	#160*400,d0
		blt.s	magok
		move.w	#1,flag
		bra.s	donehere
magok:		move.l	d0,magoff
		bra.s	donehere

down:		move.l	magoff(pc),d0
		sub.l	#160,d0
		cmpi.l	#-160,d0
		bgt.s	magok2
		clr.w	flag
		bra.s	donehere
magok2:		move.l	d0,magoff

donehere:


***  Test code to try out the y mags.
		tst.w	flag2
		bne.s	down2
		move.l	destsize(pc),d0
		addq.l	#1,d0
		cmpi.l	#257,d0
		blt.s	magokx
		move.w	#1,flag2
		bra.s	donehere2
magokx:		move.l	d0,destsize
		bra.s	donehere2

down2:		move.l	destsize(pc),d0
		subq.l	#1,d0
		cmpi.l	#7,d0
		bgt.s	magokx2
		clr.w	flag2
		bra.s	donehere2
magokx2:	move.l	d0,destsize

donehere2:
*****
nofuck:
		move.b	scrnpos+1(pc),$ffff8201.w
		move.b	scrnpos+2(pc),$ffff8203.w
		move.l	scrnpos(pc),d0
		move.l	scrn2(pc),scrnpos
		move.l	d0,scrn2

		ifne	timing
		clr.w	$ffff8240.w
		endc

		cmpi.b	#57,$fffffc02.w
		bne	key


out:            move.w  #$0777,$FFFF8240.w
                move.w  #$00,$FFFF8246.w

		move.w	#$2700,sr
		moveq	#0,d0
		bsr	mus
		move.l	oldvbl(pc),$70.w
		move.b	sa1(pc),$fffffa07.w
		move.b	sa2(pc),$fffffa09.w
		move.w	#$2300,sr

flush:		btst.b	#0,$fffffc00.w
		beq.s	fl_done
		move.b	$fffffc02.w,d0
		bra.s	flush
fl_done:

                move.l  oldsp(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                adda.l  #6,SP

                clr.w   -(SP)
                trap    #1


vbl:		addq.b	#1,lcount
		movem.l	d0-d7/a0-a6,-(sp)
		bsr	mus+6
		movem.l	(sp)+,d0-d7/a0-a6
		rte


mus:		incbin	arse.czi


overflow:	
*		eor.w	#$070,$ffff8240.w
		rts


sizerouts:	dc.l	size1
		dc.l	size2
		dc.l	size3
		dc.l	size4
		dc.l	size5
		dc.l	size6
		dc.l	size7
		dc.l	size8
		dc.l	size9
		dc.l	size10
		dc.l	size11
		dc.l	size12
		dc.l	size13
		dc.l	size14
		dc.l	size15
		dc.l	size16
		dc.l	size17
		dc.l	size18
		dc.l	size19
		dc.l	size20
		dc.l	size21
		dc.l	size22
		dc.l	size23
		dc.l	size24
		dc.l	size25
		dc.l	size26
		dc.l	size27
		dc.l	size28
		dc.l	size29
		dc.l	size30
		dc.l	size31
		dc.l	size32

on:		ds.w	1

oldsp:          DS.L 1
scrnpos:        DS.L 1
scrn2:		ds.l 1
oldvbl:		ds.l 1

buff:		ds.l 1

lcount:		ds.w 1

shifty:		dc.w 0

sa1:		ds.b 1
sa2:		ds.b 1
		even

cpcount:	ds.w 1

destsize:	dc.l 8	; Destination Y height for scroll.

flag:		ds.w 1
flag2:		ds.w 1

magoff:		dc.l 0

magdat:		ds.l 1

ptab:		dc.w	%1000000000000000
		dc.w	%100000000000000
		dc.w	%10000000000000
		dc.w	%1000000000000
		dc.w	%100000000000
		dc.w	%10000000000
		dc.w	%1000000000
		dc.w	%100000000
		dc.w	%10000000
		dc.w	%1000000
		dc.w	%100000
		dc.w	%10000
		dc.w	%1000
		dc.w	%100
		dc.w	%10
		dc.w	%1

pixoffs:	incbin	pixoffs.dat

xoffs:		
xoff		set	0
		rept	40
		dc.b	xoff
		dc.b	xoff
		dc.b	xoff
		dc.b	xoff
		dc.b	xoff
		dc.b	xoff
		dc.b	xoff
		dc.b	xoff
xoff		set	xoff+1
		endr

		even

tabx256:	
val		set	0
		rept	256
		dc.w	val*256
val		set	val+1
		endr

		even
	
cbuff:	dc.w	0
whichbuf:
	dc.w	0

buffptr:dc.w	(bufwd/2)+2
scrlcnt:dc.w	0

textptr:dc.l	text
text:	dc.b	'    Huh?  Izzat all?  Hah!  What a load of pitt bull shite!   Well, fuck you!',1
	dc.b	'Wahoo!!  BOINGG!  Resize,resize!  *barf* *agg*   There ye go!  Finally removed all errors, and I''m STILL not sure why it misses (powers to) Y sizes...  Hmm...  It could be some shite with the overflows to a nth of the power since no '
	dc.b	'roundup...  Ahh fuck it!  Who''s gonna notice!  So NEway go on and admire THE fastest floating-point sizer routine/technique ANYWHERE...  Five hard day''s work (mine!)...  Agg loop, I''ll put the rest of the comments in the source...  '
	dc.l	0

	even

******* Line copy routines...
size1:		
xoff		set	0
		rept	20
		move.w	(a0)+,xoff(a1)
xoff		set	xoff+8
		endr
		lea	160(a1),a1
		rts

		include	ysizert4.s
*******

font:	incbin	cmpfnt8.dat

ybuff:	ds.w	204

buffer2:	
	ds.b	320

bytebuff:	ds.l 1

                END
