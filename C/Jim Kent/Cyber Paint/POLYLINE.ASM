
	dseg
	public _brush_ix
	public _aline

	cseg
	public _brush_polyline
	;:ts=12
XMIN	equ 0
YMIN	equ 0
XMAX	equ 320
YMAX	equ 200

	; polyline(points, count)
	public _polyline
	public _thin_polyline
_polyline
	tst.w	_brush_ix
	beq	_thin_polyline
	jmp	_brush_polyline
_thin_polyline
	movem.l	a2/a3/a4/d3/d4/d5/d6/d7,-(sp)
	move.l	36(sp),a3
	move.w	40(sp),d7
	move.l	_aline,a4
	adda	#38,a4	;point at line coordinate bits of aline
	subq.w	#1,d7	;one less line than # of vertices ... 
	bra plinez
plineloop	
	;first grab the endpoints into registers
	move.w	(a3)+,d3
	move.w	(a3)+,d4
	move.w	(a3),d5
	move.w	2(a3),d6
	bsr clipline
plinez 	dbra	d7,plineloop
	movem.l	(sp)+,a2/a3/a4/d3/d4/d5/d6/d7
	rts


clipline
	; make life a little simpler by forcing d3 < d5 (x0 < x1)
	cmp.w	d5,d3
	ble	noswapx
	exg	d5,d3
	exg	d6,d4
noswapx
	cmp.w	#XMIN,d3
	bge	nolxclip
	cmp.w	#XMIN,d5
	blt	clipout

	move.w	d6,d0
	sub.w	d4,d0
	bvs	clipout	; if HUGE abort
	move.w	#XMIN,d1
	sub.w	d3,d1
	bvs	clipout	; if HUGE abort
	muls	d1,d0
	move.w	d5,d1
	sub.w	d3,d1
	bvs	clipout	; if HUGE abort
	divs	d1,d0
	add.w	d0,d4
	move.w	#XMIN,d3
nolxclip
	cmp.w	#XMAX,d5
	blt	noxclip
	cmp.w	#XMAX,d3
	bge	clipout

	move.w	d6,d0
	sub.w	d4,d0
	bvs	clipout	; if HUGE abort
	move.w	#XMAX-1,d1
	sub.w	d5,d1
	bvs	clipout	; if HUGE abort
	muls	d1,d0
	move.w	d5,d1
	sub.w	d3,d1
	bvs	clipout	; if HUGE abort
	divs	d1,d0
	add.w	d0,d6
	move.w	#XMAX-1,d5
noxclip
	; make life a little simpler by forcing d4 < d6 (y0 < y1)
	cmp.w	d6,d4
	ble	noswapy
	exg	d5,d3
	exg	d6,d4
noswapy
	cmp.w	#YMIN,d4
	bge	nolyclip
	cmp.w	#YMIN,d6
	blt	clipout

	move.w	d5,d0
	sub.w	d3,d0
	bvs	clipout	; if HUGE abort
	move.w	#YMIN,d1
	sub.w	d4,d1
	bvs	clipout	; if HUGE abort
	muls	d1,d0
	move.w	d6,d1
	sub.w	d4,d1
	bvs	clipout	; if HUGE abort
	divs	d1,d0
	add.w	d0,d3
	move.w	#YMIN,d4
nolyclip
	cmp.w	#YMAX,d6
	blt	noyclip
	cmp.w	#YMAX,d4
	bge	clipout

	move.w	d5,d0
	sub.w	d3,d0
	bvs	clipout	; if HUGE abort
	move.w	#YMAX-1,d1
	sub.w	d6,d1
	bvs	clipout	; if HUGE abort
	muls	d1,d0
	move.w	d6,d1
	sub.w	d4,d1
	bvs	clipout	; if HUGE abort
	divs	d1,d0
	add.w	d0,d5
	move.w	#YMAX-1,d6

noyclip

	move.w	d3,(a4)+
	move.w	d4,(a4)+
	move.w	d5,(a4)+
	move.w	d6,(a4)+
	sub.w	#8,a4
	dc.w $a003
clipout	rts

