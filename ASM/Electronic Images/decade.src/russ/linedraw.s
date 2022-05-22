		opt	o+,ow-
;
; a little example using my line drawing routine
;
; it simple goes anti-clockwise round the edge of
; the screen and draws lines to the center
;
; by Russ 03/08/1990 :-)
;
; this first bit is simply an example of how to
; call the line drawing module
;
main		moveq	#-1,d0
		clr.w	-(sp)
		move.l	d0,-(sp)
		move.l	d0,-(sp)
		move.w	#5,-(sp)
		trap	#14			;change to low rez
		lea	12(sp),sp
;
		move.w	#2,-(sp)
		trap	#14			;physbase
		addq.w	#2,sp
		move.l	d0,logbase
;
mainloop	moveq	#0,d1
.botloop	move.w	col(pc),d0
		move.w	#199,d2
		move.w	#159,d3 		;to center
		move.w	#99,d4
		move.w	d1,-(sp)
		bsr	draw
		move.w	(sp)+,d1
		addq.w	#1,d1
		cmp.w	#319,d1
		ble.s	.botloop

		move.w	#199,d2
.rightloop	move.w	col(pc),d0
		move.w	#319,d1
		move.w	#159,d3
		move.w	#99,d4
		move.w	d2,-(sp)
		bsr	draw
		move.w	(sp)+,d2
		subq.w	#1,d2
		bge.s	.rightloop

		move.w	#319,d1
.toploop	move.w	col(pc),d0
		moveq	#0,d2
		move.w	#159,d3
		move.w	#99,d4
		move.w	d1,-(sp)
		bsr	draw
		move.w	(sp)+,d1
		subq.w	#1,d1
		bge.s	.toploop

		moveq	#0,d2
.leftloop	move.w	col(pc),d0
		moveq	#0,d1
		move.w	#159,d3
		move.w	#99,d4
		move.w	d2,-(sp)
		bsr	draw
		move.w	(sp)+,d2
		addq.w	#1,d2
		cmp.w	#199,d2
		ble.s	.leftloop

		subq.w	#8,col
		and.w	#31*8,col

		bra	mainloop

col		dc.w	31*8

;--------------------------------------------------------------------------
;
; module:	draw.s
; programmer:	Russell Payne
; date: 	9th September 1989
;		1st January 1990
;
; version:	1.0 based on DDA algorithm
;		1.1 changed for octantal DDA
;		2.0 change to use Bresenham's algorithm
;		2.1 use self-mod-code for colours
;
;	mono-colour line drawing module
;	the start and end points of the line are plotted
;	 (some algorithms don't do that)
;	line clipping is done elsewhere
;	speed is approx 70000 pixels per second
;	based on a 50 pixel line drawn randomly
;	the first 16 colours overwrite the
;	last 16 are xor'ed
;
; uses registers
;
;	D0-D6 and A2 others remain unchanged
;
; note
;	there is *NO* optimization for vertical or horizontal lines
;
;--------------------------------------------------------------------------

dandor		macro
		ifeq	\1
		and.w	d2,(a2)+
		endc
		ifne	\1
		or.w	d1,(a2)+
		endc
		endm

dxor		macro
		ifeq	\1
		tst.w	(a2)+
		endc
		ifne	\1
		eor.w	d1,(a2)+
		endc
		endm

dcolrmac	macro
		dandor	\1
		dandor	\2
		dandor	\3
		dandor	\4
		endm

dxormac		macro
		dxor	\1
		dxor	\2
		dxor	\3
		dxor	\4
		endm

;
; code lookup table for colour
;
; 8 bytes per entry
;

draw_code_table dcolrmac 0,0,0,0
		dcolrmac 1,0,0,0
		dcolrmac 0,1,0,0
		dcolrmac 1,1,0,0
		dcolrmac 0,0,1,0
		dcolrmac 1,0,1,0
		dcolrmac 0,1,1,0
		dcolrmac 1,1,1,0
		dcolrmac 0,0,0,1
		dcolrmac 1,0,0,1
		dcolrmac 0,1,0,1
		dcolrmac 1,1,0,1
		dcolrmac 0,0,1,1
		dcolrmac 1,0,1,1
		dcolrmac 0,1,1,1
		dcolrmac 1,1,1,1
		dxormac 0,0,0,0
		dxormac 1,0,0,0
		dxormac 0,1,0,0
		dxormac 1,1,0,0
		dxormac 0,0,1,0
		dxormac 1,0,1,0
		dxormac 0,1,1,0
		dxormac 1,1,1,0
		dxormac 0,0,0,1
		dxormac 1,0,0,1
		dxormac 0,1,0,1
		dxormac 1,1,0,1
		dxormac 0,0,1,1
		dxormac 1,0,1,1
		dxormac 0,1,1,1
		dxormac 1,1,1,1

line_colour	dc.w	-1

;--------------------------------------------------------------------------
;
; line drawing routine
;
; d0 = colour (0-31) x8
;	0 = colour 0
;	8 = colour 1
;      16 = colour 2 ... etc
; d1 = x1 coord
; d2 = y1 coord
; d3 = x2 coord
; d4 = y2 coord
;
;--------------------------------------------------------------------------

draw		cmp.w	line_colour(pc),d0
		beq.s	fastdraw
		lea	draw_code_table(pc),a2
		move.w	d0,line_colour-draw_code_table(a2)
		add.w	d0,a2
		move.l	(a2)+,d0
		move.l	(a2)+,d5
		lea	draw(pc),a2
		move.l	d0,octant.2.loop-draw(a2)
		move.l	d0,octant.8.loop-draw(a2)
		move.l	d5,octant.2.loop+4-draw(a2)
		move.l	d5,octant.8.loop+4-draw(a2)
;
; now draw the line
;
; d1 = x1
; d2 = y1
; d3 = x2
; d4 = y2
;
; the line *MUST* be entirely on screen
;
fastdraw	move.w	d3,d5			;endx - startx
		sub.w	d1,d5			;
		bcc.s	left.2.right		;

		neg.w	d5			;abs(endx - startx)
		exg	d1,d3			;swap (p1 and p2)
		exg	d2,d4			;

left.2.right	move.w	d4,d6			;endy - starty
		sub.w	d2,d6			;
		bcc.s	upper.2.lower		;

		neg.w	d6			;abs(endy-starty)
		cmp.w	d6,d5			;dy>dx?
		bcc.s	octant.8		;

;
; octant 7
;

octant.7
		move.w	#-168,d0		;upwards
		bra.s	comm_1			;

;
; upper to lower
;

upper.2.lower
		cmp.w	d6,d5			;
		bcc.s	octant.1		;

;
; octant 2
;

octant.2
		move.w	#152,d0

comm_1		add.w	d2,d2
		lea	rowtable(pc),a2
		move.w	0(a2,d2.w),a2
		add.l	logbase(pc),a2
		moveq	#15,d3
		move.w	d1,d2
		and.w	d3,d1			;rotation
		sub.w	d1,d2
		lsr.w	#1,d2			;offset into line
		add.w	d2,a2

		eor.w	d3,d1
		moveq	#0,d2
		bset	d1,d2

		move.w	d2,d1			;d2 = pixel
		not.w	d2

		move.w	d5,d3
		move.w	d6,d4
		move.w	d4,d5			;count = dy
		move.w	d4,d6			;
		neg.w	d6			;err = -dy / 2
		asr.w	#1,d6			;

octant.2.loop
		or.w	d1,(a2)+		;plot point in colour 15
		or.w	d1,(a2)+		;
		or.w	d1,(a2)+		;
		or.w	d1,(a2)+		;
		add.w	d0,a2			;y = y +- 1
		add.w	d3,d6			;err = err + dx
		bpl.s	octant.2.deviate
		dbra	d5,octant.2.loop
		rts

octant.2.deviate
		sub.w	d4,d6			;err = err - dy
		ror.w	#1,d1			;x = x + 1
		ror.w	#1,d2			;
		bcc.s	octant.2.retry
		dbra	d5,octant.2.loop
		rts

octant.2.retry
		lea	8(a2),a2		;
		dbra	d5,octant.2.loop
		rts

;
; octant 1
;

octant.1
		move.w	#160,d0 		;down 1 line
		bra.s	comm_2			;

;
; octant 8
;

octant.8
		move.w	#-160,d0		;up 1 line

comm_2
		add.w	d2,d2
		lea	rowtable(pc),a2
		move.w	0(a2,d2.w),a2		 ;a2 points at screen
		add.l	logbase(pc),a2
		moveq	#15,d3
		move.w	d1,d2
		and.w	d3,d1			;rotation
		sub.w	d1,d2
		lsr.w	#1,d2			;offset into line
		add.w	d2,a2

		eor.w	d3,d1
		moveq	#0,d2
		bset	d1,d2

		move.w	d2,d1			;d2 = pixel
		not.w	d2

		move.w	d5,d3
		move.w	d6,d4
		move.w	d3,d5			;count = dy
		move.w	d3,d6			;
		neg.w	d6			;err = -dy / 2
		asr.w	#1,d6			;

octant.8.loop
		or.w	d1,(a2)+		;plot point in colour 15
		or.w	d1,(a2)+		;
		or.w	d1,(a2)+		;
		or.w	d1,(a2)+		;
		ror.w	#1,d1			;x = x + 1
		ror.w	#1,d2			;
		bcc.s	octant.8.retry
		lea	-8(a2),a2		;

octant.8.retry
		add.w	d4,d6			;err = err + dy
		bpl.s	octant.8.deviate
		dbra	d5,octant.8.loop
		rts

octant.8.deviate
		sub.w	d3,d6			;err = err - dy
		add.w	d0,a2			;y = y +- 1
		dbra	d5,octant.8.loop
		rts

;--------------------------------------------------------------------------
;
; row lookup table and variables
;
;--------------------------------------------------------------------------

rowtable
offset		set	0
		rept	200
		dc.w	offset
offset		set	offset+160
		endr

;
; pointer to screen address
;
logbase 	dc.l	$78000
