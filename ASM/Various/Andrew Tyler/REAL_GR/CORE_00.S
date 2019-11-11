* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991  core_00.s                               *
* Program core. Important subroutines for Chapter 4.              *
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
	move.w	#399,d5		initial minimum y
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
	beq	poly3		quit if all sides are horizontal
	move.w	d5,d3		minimum y is the start
	lsl.w	#2,d5		4*minimum y = offset into xbuf
	add.w	d5,a1		for the address to start
	move.w	colour,d4	the colour
	subq	#1,d3		reduce initial y
poly2	addq	#1,d3		next y
	move.w	(a1)+,d2	next x1
	move.w	(a1)+,d1	next x2
	sub.w	d2,d1		x2-x1
	bmi	poly4
	addq	#1,d1		N = no to do in this line
	move.l	screen,a4	where the screen table starts
	movem.l	d0-d7/a0-a6,-(sp)	save the registers
	bsr	holine			draw the line
	movem.l	(sp)+,d0-d7/a0-a6	restore the registers
poly4	dbra	d7,poly2	repeat for all y values
poly3	rts

*HOLINE. A horizontal line is drawn from left to right. 
* passes: x1=d2.w, y1=d3.w, N=d1.w, colour=d4.w, screen y table:a4.l
* First find the address of the word at which the line starts.
holine	lea	hln_tbl,a3	pointer to mask table
	lsl.w	#2,d3		there are y long words before the 		
	movea.l	0(a4,d3.w),a4	current row address in the table
	move	d2,d5		save x1
	andi	#$fff0,d5	go in steps of 8 bytes	
	lsr.w	#1,d5		to point to plane #1 word
	adda.w	d5,a4		at this address
	andi	#$000f,d2	which pixel from the left?
	move	d2,d0		save it
* does the entire line lie within one word?
	subi	#16,d0
	neg	d0		are there more pixels to the word end
	cmp	d1,d0		than we have to draw? 
	bmi	long_line	no, so it's a long line
* The line is entirely within one word. Get the mask and draw it.
	move	d1,d0
	bsr	draw_it
	rts			and that's all.
* Complete the 1st word in a long line
long_line:
	sub	d0,d1		number left
	bsr	draw_it
* Now fill all the solid words.
	clr	d0
	not	d0
	move	d1,d2		save number of pixels left to do
	lsr	#4,d2		how many are whole words?
	beq	last_word	none are
* a long stretch of filled words - no need to read the table	
	subq	#1,d2		this many full words but one
	move	d0,d3		which are all 1's
	not	d3		or all 0's, depending on the colour
	moveq	#4-1,d5		4 colour planes
	move	d4,d6
	subq	#2,a4
inc_plane:
	addq	#2,a4		offset for next plane
	movea.l	a4,a5		save the address
	move	d2,d7		initialise the word count
	lsr.w	#1,d6		next colour bit
	bcc	clr_word
set_word:
	or.w	d0,(a5)
	adda	#8,a5		next word in this plane
	dbra	d7,set_word	
	bra	new_plane
clr_word:
	and	d3,(a5)
	adda	#8,a5		next word in this plane
	dbra	d7,clr_word
new_plane:
	dbra	d5,inc_plane	for all the colour planes
	subq	#6,a5		pointer to next plane 1
	movea.l	a5,a4		update pointer
* it only remains to do the last word. It will start at pixel 0
last_word:
	andi	#$f,d1		low nibble
	cmpi.w	#0,d1		any to do ?
	beq	holine_end	no - finished.
* In finding the mask,the row offset is zero this time.
	clr	d2		1st pixel at extreme left
	move	d1,d0	
	bsr	draw_it
holine_end:
	rts			completely finished			
* Draw in a section of a word which starts at pixel a and ends at pixel b
draw_it
	lsl	#5,d2		the mask row offset=a*32
	move	d0,d5		plus
	subq	#1,d5		column 
	lsl	#1,d5		offset of (15-b)*2 gives
	add	d5,d2		the total offset
	move.w	0(a3,d2.w),d0	to fetch the mask
	move	d0,d3		and
	not	d3		its 1's compliment
	moveq	#3,d5		4-1 colour planes
	move	d4,d6		save colour
next_plane:
	lsr	#1,d6		is this colour bit set?
	bcc	not_set		no 
	or.w	d0,(a4)+	yes, also set the bits
	dbf	d5,next_plane
	rts			
not_set	and.w	d3,(a4)+	clear the bits
	dbf	d5,next_plane
fil_end	rts			finished
