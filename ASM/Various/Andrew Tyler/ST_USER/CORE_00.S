* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*			core_00.s                                 *
*                  All the subroutines                            *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

poly_fil:
* This fills a polygon.
* It consists of 2 parts: 
* part 1 - the the x-coordinates of all boundary points are entered in xbuf
* part 2 - the holine routine fills the polygon from the values in xbuf

* PART 1. Fill the buffer.
* Regs:
* a3: pointer to crds_in - coords. list (x1,y1,x2,y2,....x1,y1)
* a2: pointer to xbuf
* d0(x1),d1(y1),d2(x2),d3(y2),d4(vertex no)/(decision ver.,
* d5(lowest y),d6(highest y)/(the increment),d7(edge counter)
* polygon vertices are ordered anticlockwise

* Initialise all variables
filxbuf:
	move.w	no_in,d7	no. edges in polygon
	beq	fil_end		quit if none to do
	lea	crds_in,a3	pointer to the coords. of vertices
	subq.w	#1,d7		the counter
	move.w	#199,d5		initial minimum y
	clr.w	d6		initial maximum y		
filbuf1	lea	xbuf,a2		init. buffer pointer
	addq.w	#2,a2		point to ascending side (low word)
	move.w	(a3)+,d0	next x1 
	move.w	(a3)+,d1	next y1
	move.w	(a3)+,d2	next x2
	move.w	(a3)+,d3	next y2
	subq.w	#4,a3		point back to x2
* Find the lowest and highest y values: the filled range of xbuf 
	cmp.w	d5,d1		test(y1-miny)
	bge	filbuf3		minimum y unchanged
	move.w	d1,d5		minimum y is y1
filbuf3	cmp.w	d1,d6		test(maxy-y1)
	bge	filbuf5		unchanged
	move.w	d1,d6		maximum y is y1

filbuf5	exg	d5,a5		save minimum y
	exg	d6,a6		save maximum y
	clr.w	d4		init. decision var
	moveq	#1,d6		init. increment

* All lines fall into two catagories: [slope]<1, [slope]>1.
* The only difference is whether x and y are increasing or decreasing.
* See if line is ascending (slope > 0) or descending (slope < 0).
	cmp.w	d1,d3		(y2-y1)=dy
	beq	y_limits	ignore horizontals altogether
	bgt	ascend		slope > 0
* It must be decending. Direct output to LHS of buffer. a2 must 
* be reduced and we have to reverse the order of the vertices.
	exg	d0,d2		exchange x1 and x2
	exg	d1,d3		exchange y1 and y2
	subq.w	#2,a2		point to left hand buffer
ascend	sub.w	d1,d3		now dy is +ve
* Set up y1 as index to buffer
	lsl.w	#2,d1
	add.w	d1,a2
* Check the sign of the slope
	sub.w	d0,d2		(x2-x1)=dx
	beq	vertical	if it's vertical its a special case
	bgt	pos_slope	the slope is positive 
* It must have a negative slope but we deal with this by making the
* increment negative
	neg.w	d6		increment is decrement
	neg.w	d2		and dx is positive
* now decide whether the slope is high (>1) or low (<1)
pos_slope:
	cmp.w	d2,d3		test(dy-dx)
	bgt	hislope		slope is >1
* The slope is less than 1 so we want to increment x every time and then
* check whether to also increment y. If so this value of x must be saved.
* dx is the counter. Initial error D1=2dy-dx
* If last D -ve, then x=x=inc, don't record x, D=D+err1
* If last D +ve, then x=x+inc,y=y+inc, record this x, D=D+err2
* err1=2dy; err2=2dy-2dx 
* dx in d2, dy in d3, incx in d6, x in d0
	move.w	d2,d5
	subq.w	#1,d5		dx-1 is the counter
	add.w	d3,d3		2dy=err1
	move.w	d3,d4		2dy
	neg.w	d2		-dx
	add.w	d2,d4		2dy-dx = D1
	add.w	d4,d2		2dy-2dx=err2
	move.w	d0,(a2)		save first x
inc_x	add.w	d6,d0		x=x+incx
	tst.w	d4		what is the decision?
	bmi	no_stk		don't inc y, don't record x
	add.w	#4,a2		inc y so record x; find next buffer place
	move.w	d0,(a2)		save this x
	add.w	d2,d4		update decision	D=D+err2
	bra.s	next_x		next one
no_stk	add.w	d3,d4		D=D+err1
next_x	dbra	d5,inc_x	increment x again
	bra	y_limits
                                                                                                            
* The slope is >1 so change the roles of dx and dy
* This time we must increment y each time and record the value of x after 
* having done so.
* Init error D1 = 2dx-dy
* If last D -ve, then y=y+inc, D=D+err1, record x
* If last D +ve, then x=x+inc, y=y+inc, D=D+err2, record x
* err1=2dx, err2=2(dx-dy)
* dx in d2, dy in d3, inc in d6, x in d0
hislope	move.w	d3,d5
	subq.w	#1,d5	dy-1 is counter 
	add.w	d2,d2	2dx=err1
	move.w	d2,d4	2dx
	neg.w	d3	-dy
	add.w	d3,d4	2dx-dy=D1
	add.w	d4,d3	2dx-2dy=err2
	move.w	d0,(a2)	save 1st x
inc_y	addq.w	#4,a2	next place in buffer (equivalent to incrementing y)
	tst.w	d4	what is the decision?	
	bmi	same_x	don't inc x
	add.w	d6,d0	inc x
	add.w	d3,d4	D=D+err2
	bra.s	next_y
same_x	add.w	d2,d4	D=D+err1
next_y	move.w	d0,(a2)	save the x value
	dbra	d5,inc_y
	bra	y_limits
* the special case of a vertical line. x is constant. dy is the counter
vertical:
	move.w	d0,(a2)		save next x
	addq.w	#4,a2		next place in buffer
	dbra	d3,vertical		for all y

* Restore the y limits
y_limits:
	exg	d5,a5
	exg	d6,a6

next_line:
	dbra	d7,filbuf1	do all lines in this polygon
next_poly:
	
* This part ends with minimum y in d5 and maximum y in d6 

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* PART 2
* set up the pointer
	lea	xbuf,a1		base address
	sub.w	d5,d6		no. lines to do-1
	move.w	d6,d7		is the counter
	beq	fil_end		quit if all sides are horizontal
	move.w	d5,d3		minimum y is the start
	lsl.w	#2,d5		4*minimum y = offset into xbuf
	add.w	d5,a1		for the address to start
	move.w	colour,d4	the colour
	move.l	LineA_base,a0	Line A vars. structure
	clr.w	fg_bp1(a0)	reset
	clr.w	fg_bp2(a0)	colours
	clr.w	fg_bp3(a0)
	clr.w	fg_bp4(a0)
	lsr	#1,d4		colour plane 0?
	bcc	plne_1
	move.w	#1,fg_bp1(a0)
plne_1	lsr	#1,d4		colour plane 1?
	bcc	plne_2
	move.w	#1,fg_bp2(a0)
plne_2	lsr	#1,d4		colour plane 2?
	bcc	plne_3
	move.w	#1,fg_bp3(a0)
plne_3	lsr	#1,d4		colour plane 3?
	bcc	pln_out
	move.w	#1,fg_bp4(a0)
pln_out clr.w	wrt_mod(a0)	overwrite
	lea	fill,a2
	move.l	a2,patptr(a0)	Here is the fill pattern
	move.w	#0,patmsk(a0)	consisting of 1 line
	move.w	#0,multifil(a0)	on all colour planes
	subq	#1,d3		reduce initial y
	move.w	d3,y1(a0)	initial y-1
poly2	addq	#1,y1(a0)	next y
	move.w	(a1)+,d2	next x1
	move.w	(a1)+,d1	next x2
	cmp.w	d2,d1		x2-x1
	ble	poly4		x1 must be =< x2
	move.w	d2,x1(a0)	x1
	move.w	d1,x2(a0)	x2
	movem.l	d0-d7/a0-a6,-(sp)	save the registers
	dc.w	hline			Line A $a004
	movem.l	(sp)+,d0-d7/a0-a6	restore the registers
poly4	dbra	d7,poly2	repeat for all y values
fil_end	rts

* Get the address of the Line A variables structure
init_LineA:
	dc.w	init
	move.l	a0,LineA_base
	rts
