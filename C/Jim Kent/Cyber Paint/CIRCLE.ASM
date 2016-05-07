
	public _plot_nobrush

	;circle(x, y, rad, color)
	;	draw a circle of radius rad about center x,y in color
	public _circle

param1	equ	5*2+4+6	; offset on stack to first parameter after register saved
x	equ	param1
y	equ  param1+2
rad equ	param1+4
color equ param1+6
_circle
	movem.w	d3/d4/d5/d6/d7,-(sp)
	subq.l	#6,sp	; make room for parameters to plot

	move.w	color(sp),4(sp)	; set up color parameter for plot
	move.w	x(sp),d6	; save center xy
	move.w	y(sp),d7
	move.w	rad(sp),d4	; xoffset starts out radius
	bne		nontrivc	; it's not zero radius...do a circle
	move.w	d6,(sp)
	move.w	d7,2(sp)
	jsr		_plot_nobrush		; else just plot one point... 
	bra		endcloop
nontrivc
	move.w	#0,d5		; yoffset starts out zero
	move.w	d4,d3
	neg.w	d3
	asr.w	#1,d3		; d3 = error = -rad/2
cloop
	tst.w	d4
	bmi		endcloop

	;	plot 1st quadrant
	move.w	d6,d0
	add.w	d4,d0
	move.w	d0,(sp)	; x coordinate for plot
	move.w	d7,d0
	add.w	d5,d0
	move.w	d0,2(sp) ; y coordinate for plot
	jsr		_plot_nobrush

	;	plot 2nd quadrant
	move.w	d6,d0
	sub.w	d4,d0
	move.w	d0,(sp)	; x coordinate for plot
	move.w	d7,d0
	add.w	d5,d0
	move.w	d0,2(sp) ; y coordinate for plot
	jsr		_plot_nobrush

	;	plot 3rd quadrant
	move.w	d6,d0
	sub.w	d4,d0
	move.w	d0,(sp)	; x coordinate for plot
	move.w	d7,d0
	sub.w	d5,d0
	move.w	d0,2(sp) ; y coordinate for plot
	jsr		_plot_nobrush

	;	plot 4th quadrant
	move.w	d6,d0
	add.w	d4,d0
	move.w	d0,(sp)	; x coordinate for plot
	move.w	d7,d0
	sub.w	d5,d0
	move.w	d0,2(sp) ; y coordinate for plot
	jsr		_plot_nobrush

	; now do stuff to figure out where next 4 plots will be
	tst.w	d3		; check sign of error term
	bpl		stepx
	addq.w	#1,d5	; increment y offset
	add.w	d5,d3	; update error term
	bra 	cloop
stepx	subq.w	#1,d4
	sub.w	d4,d3
	bra		cloop

endcloop
	addq.l	#6,sp	; clean off plot parameters
	movem.w	(sp)+,d3/d4/d5/d6/d7
	rts

