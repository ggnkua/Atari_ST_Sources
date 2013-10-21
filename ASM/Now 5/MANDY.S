	list	+
* turbo mandelbrot demo by jmp 20/5/90
* Brought to you by Stormlord of NOW 5
	list	-

	opt	x+

_res	equ	0
_reloc	equ	0
_tosoff	equ	0
_frames	equ	1

	section data

indics_ptr dc.l 0
indics_ptr2 dc.l 0

	section text

	include	\john_m_p\envdemo.s

_auto	dc.w	0
_fast	dc.w	0

start	move.l	#the_palette,log_epl
	jsr	flip
.loop	move.l	physbase,a0
	bsr	cls
	bsr	generate_mandelbrot
.wait	bsr	get_key
	beq.s	.wait
	cmp.w	#' ',d0
	bne.s	.loop
	rts

the_palette
	dc.w	$000,$777,$004,$007
	dc.w	$047,$077,$074,$070
	dc.w	$470,$770,$740,$700
	dc.w	$704,$707,$747,$777
	dc.w	0

epl_irq0
	jmp	en_syncirq

	section	text

size	equ	128		size of viewing area
size_b	equ	7		bit shift equivalent

origx	equ	(320-size)/2	screen origin
origy	equ	(200-size)/2

xmin	dc.w	-288		zoom area
xmax	dc.w	96
ymin	dc.w	-192
ymax	dc.w	192

max_colour equ	15

xstep	dc.w	0	scaled x,y steps
ystep	dc.w	0

generate_mandelbrot
	move.w	xmax,d0		xstep=(xmax-xmin)/size
	sub.w	xmin,d0
	asr.w	#size_b,d0
	move.w	d0,xstep
	move.w	ymax,d0		ystep=(ymax-ymin)/size
	sub.w	ymin,d0
	asr.w	#size_b,d0
	move.w	d0,ystep
	moveq	#0,d7		for q=0 to size-1
	move.w	ymin,a1		n=ymin
.row	moveq	#0,d6			for p=0 to size-1
	move.w	xmin,a0			m=xmin
.column	clr.w	d5			i=0
	clr.w	d0			x=0
	clr.w	d1			y=0
.repeat	move.w	d0,d2			repeat
	muls	d2,d2				w=x*x
	move.w	d1,d3				z=y*y
	muls	d3,d3
	move.l	d2,d4
	add.l	d3,d4				r=w+z
	muls	d0,d1
	asr.l	#size_b-1,d1			y'=2*x*y/size+n
	add.w	a1,d1
	move.l	d2,d0				x'=(w-z)/size+m
	sub.l	d3,d0
	asr.l	#size_b,d0
	add.w	a0,d0
	addq.w	#1,d5
	cmp.l	#4*size*size,d4			until r>=4*size*size
	bcc.s	.until
	cmp.w	#max_colour,d5			   or i=max_colour
	bne.s	.repeat
.until	move.w	d6,d0			plot(origx+p,origy+q) in colour i
	add.w	#origx,d0
	move.w	d7,d1
	add.w	#origy,d1
	moveq	#0,d2
	move.b	colour_list(pc,d5.w),d2
	bsr	plot_point
	add.w	xstep,a0		m=m+xstep
	addq.w	#1,d6			next p
	cmp.w	#size,d6
	bne.s	.column
	add.w	ystep,a1		n=n+ystep
	addq.w	#1,d7			next q
	cmp.w	#size,d7
	bne.s	.row
	rts

colour_list
	dc.b	0,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0
	even

* entry	d0=x,d1=y,d2=colour 0..15
* exit	d6-d7/a0-a1 preserved

plot_point
	move.l	physbase,a6
	mulu	#160,d1
	move.w	d0,d3
	lsr.w	#1,d0
	and.w	#~7,d0
	add.w	d0,d1
	add.w	d1,a6
	not.w	d3
	and.w	#15,d3
	clr.w	d0
	bset	d3,d0
.p0	lsr.b	#1,d2
	bcc.s	.p1
	or.w	d0,(a6)
.p1	lsr.b	#1,d2
	bcc.s	.p2
	or.w	d0,2(a6)
.p2	lsr.b	#1,d2
	bcc.s	.p3
	or.w	d0,4(a6)
.p3	lsr.b	#1,d2
	bcc.s	.done
	or.w	d0,6(a6)
.done	rts


