* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*			core_01.s				*              
* 		Program core for Part 2.			*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* A version of the Sutherland-Hodgman clipping algorithm.
* It goes round the polygon clipping it against one boundary at
* a time; it goes round four times in all.
* regs:
* a0(crds_in),a1(crds_out).a2(no_out),a3((saved) crds_out)
* d1(x1),d2(y1),d3(x2),d4(y2),d5(saved x2), d6(saved y2)
* d0(current limit)
clip:
* first clip against xmin
	bsr	clip_ld1		set up pointers
	tst.w	d7			any sides to clip?
	beq	clip_end		quit if none
* do 1st point as a special case
	move.w	(a0)+,d5	1st x
	move.w	(a0)+,d6	1st y
	move.w	xmin,d0		this limit
	cmp.w	d0,d5		test(x1-xmin)
	bge	xmin_save	inside limit
	bra	xmin_update	outside limit
* do successive vertices in turn
xmin_next:
	move.w	(a0)+,d3	x2
	move.w	(a0)+,d4	y2
	move	d3,d5		save x2
	move	d4,d6		save y2
* now test for position
	sub.w	d0,d3		x2-xmin
	bge	xmin_x2in	x2 is in
* x2 is outside, where is x1?
	sub.w	d0,d1		x1-xmin
	blt	xmin_update	both x2 and x1 are out
* x2 is out but x1 is in so find intersection,
* needs dx1(+ve) in d1, dx2(-ve) in d3, y1 in d2 and y2 in d4
* finds the y-intercept and save it
	bsr	y_intercept
* but because its out, don't save x2
	bra	xmin_update
xmin_x2in:
* x2 is in but where is x1?
	sub.w	d0,d1		x1-xmin
	bge	xmin_save	both x1 and x2 are in
* x2 is in but x1 is out so find intercept
* but must have the -ve one in d3, so switch
	exg	d1,d3
	exg	d2,d4
	bsr	y_intercept

xmin_save:
	move.w	d5,(a1)+	save x
	move.w	d6,(a1)+	save y
	addq.w	#1,(a2)		inc count 
xmin_update:
	move	d5,d1		x1:=x2
	move	d6,d2		y1:=y2
	dbf	d7,xmin_next
* the last point must be the same as the first
	movea.l	a3,a4		pointer to first x
	subq	#4,a1		point to last x
	cmpm.l	(a4)+,(a1)+	check 1st and last x and y
	beq	xmin_dec	already the same
	move.l	(a3),(a1)	move first to last
	bra	clip_xmax
xmin_dec:
	tst.w	(a2)		if count
	beq	clip_xmax	is not already zero
	subq.w	#1,(a2)		reduce it

clip_xmax:
* Now clip against xmax. Essentially the same as above except that
* the order of subtraction is reversed so that the same subroutine
* can be used to find the intercept.
	bsr	clip_ld2	set up pointers
	tst.w	d7		any to do?
	beq	clip_ymin	no
* do 1st point as a special case
	move.w	(a0)+,d5	1st x
	move.w	(a0)+,d6	1st y
	move.w	xmax,d0
	cmp.w	d5,d0		test(xmax-x1)
	bge	xmax_save	inside limit
	bra	xmax_update	outside limit
* do successive vertices in turn
xmax_next:
	move.w	(a0)+,d3	x2
	move.w	(a0)+,d4	y2
	move	d3,d5		save x2
	move	d4,d6		save y2
* now test for position
	sub.w	d0,d3
	neg.w	d3		xmax-x2		
	bge	xmax_x2in	x2 is in
* x2 is outside, where is x1?
	sub.w	d0,d1
	neg.w	d1		xmax-x1		
	blt	xmax_update	both x2 and x1 are out
* x2 is out but x1 is in so find intersection
* needs dx1(+ve) in d1, dx2(-ve) in d3, y1 in d2 and y2 in d4
* find the intercept and save it
	bsr	y_intercept
* but because its out, don't save x2
	bra	xmax_update
xmax_x2in:
* x2 is in but where is x1?
	sub.w	d0,d1			
	neg.w	d1		xmax-x1
	bge	xmax_save	both x1 and x2 are in
* x2 is in but x1 is out so find intercept
* but must have the -ve one in d3, so switch
	exg	d1,d3
	exg	d2,d4
	bsr	y_intercept

xmax_save:
	move.w	d5,(a1)+	save x
	move.w	d6,(a1)+	save y
	addq.w	#1,(a2)		inc count
xmax_update:
	move	d5,d1		x1:=x2
	move	d6,d2		y1:=y2
	dbf	d7,xmax_next
* the last point must be the same as the first
	movea.l	a3,a4		pointer to first x
	subq	#4,a1		point to last x
	cmpm.l	(a4)+,(a1)+	check 1st and last x and y
	beq	xmax_dec	already the same
	move.l	(a3),(a1)	move first to last
	bra	clip_ymin
xmax_dec:
	tst.w	(a2)		if count
	beq	clip_ymin	is not already zero
	subq.w	#1,(a2)		reduce it

clip_ymin:
* clip against ymin
	bsr	clip_ld1	set up pointers
	tst.w	d7		any to do?
	beq	clip_ymax	no
* do 1st point as a special case
	move.w	(a0)+,d5	1st x
	move.w	(a0)+,d6	1st y
	move.w	ymin,d0		this limit
	cmp.w	d0,d6		test(y1-ymin)
	bge	ymin_save	inside limit
	bra	ymin_update	outside limit
* do successive vertices in turn
ymin_next:
	move.w	(a0)+,d3	x2
	move.w	(a0)+,d4	y2
	move	d3,d5		save x2
	move	d4,d6		save x1
* now test for position
	sub.w	d0,d4		y2-xmin
	bge	ymin_y2in	y2 is in
* y2 is outside, where is y1?
	sub.w	d0,d2		y1-xmin
	blt	ymin_update	both y2 and y1 are out
* y2 is out but y1 is in so find intersection
* needs x1 in d1, x2 in d3, dy1 in d2 and dy2 in d4
* find the intercept and save it
	bsr	x_intercept
* but because its out, don't save y2
	bra	ymin_update
ymin_y2in:
* y2 is in but where is y1?
	sub.w	d0,d2		y1-ymin
	bge	ymin_save	both y1 and y2 are in
* y2 is in but y1 is out so find intercept
* but must have the -ve one in d4, so switch
	exg	d1,d3
	exg	d2,d4
	bsr	x_intercept

ymin_save:
	move.w	d5,(a1)+	save x
	move.w	d6,(a1)+	save y
	addq.w	#1,(a2)		inc no
ymin_update:
	move	d5,d1		x1:=x2
	move	d6,d2		y1:=y2
	dbf	d7,ymin_next
* the last point must be the same as the first
	movea.l	a3,a4		pointer to first x
	subq	#4,a1		point to last x
	cmpm.l	(a4)+,(a1)+	check 1st and last x and y
	beq	ymin_dec	already the same
	move.l	(a3),(a1)	move first to last
	bra	clip_ymax
ymin_dec:
	tst.w	(a2)		if count
	beq	clip_ymax	is not already zero
	subq.w	#1,(a2)		reduce it

clip_ymax:
* Now clip against ymax. Essentially the same as above except
* the order of subtraction has been reversed so that the 
* same subroutine can be used.
	bsr	clip_ld2	set up pointers
	tst.w	d7		any to do?
	beq	clip_end	no
* do 1st point as a special case
	move.w	(a0)+,d5	1st x
	move.w	(a0)+,d6	1st y
	move.w	ymax,d0
	cmp.w	d6,d0		test(ymax-y1)
	bge	ymax_save	inside limit
	bra	ymax_update	outside limit
* do successive vertices in turn
ymax_next:
	move.w	(a0)+,d3	x2
	move.w	(a0)+,d4	y2
	move	d3,d5		save x2
	move	d4,d6		save y2
* now test for position
	sub.w	d0,d4
	neg.w	d4		ymax-y2		
	bge	ymax_y2in	y2 is in
* y2 is outside, where is y1?
	sub.w	d0,d2
	neg.w	d2		ymax-y1		
	blt	ymax_update	both x2 and x1 are out
* y2 is out but y1 is in so find intersection
* needs x1 in d1, x2 in d3, dy1(+ve) in d3 and dy2(-ve) in d4
* find the intercept and save it
	bsr	x_intercept
* but because its out, don't save y2
	bra	ymax_update
ymax_y2in:
* y2 is in but where is y1
	sub.w	d0,d2			
	neg.w	d2		ymax-y1
	bge	ymax_save	both y1 and y2 are in
* y2 is in but y1 is out so find intercept
* but must have the -ve one in d4, so switch
	exg	d1,d3
	exg	d2,d4
	bsr	x_intercept

ymax_save:
	move.w	d5,(a1)+	save x
	move.w	d6,(a1)+	save y
	addq.w	#1,(a2)		inc no
ymax_update:
	move	d5,d1		x1:=x2
	move	d6,d2		y1:=y2
	dbf	d7,ymax_next
* the last point must be the same as the first
	movea.l	a3,a4		pointer to first x
	subq	#4,a1		point to last x
	cmpm.l	(a4)+,(a1)+	check 1st and last x and y
	beq	ymax_dec	already the same
	move.l	(a3),(a1)	move first to last
	bra	clip_end
ymax_dec:
	tst.w	(a2)		if count
	beq	clip_end	is not alredy zero
	subq.w	#1,(a2)		reduce it
clip_end:
	rts

clip_ld1:
* first set up the pointers for the first and third passes
	lea 	crds_in,a0	pointer to vertex coords. before clip	
	lea	crds_out,a1	and after the this clip
	move.l	a1,a3		saved
	move.w	no_in,d7	this many sides before
	lea	no_out,a2	where the number after is stored
	clr.w	no_out
	rts

clip_ld2:
* set up the pointers for the second and fourth passes
* ensures the final output is at the same place as initial input
	lea	crds_out,a0	pointer to vertex coords before clip
	lea	crds_in,a1	and after this clip
	move.l	a1,a3		saved
	move.w	no_out,d7	this many sides before
	lea	no_in,a2	where the number after is stored
	clr.w	no_in
	rts


y_intercept:
* Find the y-intercept on the clipping boundary x = k  of the
* line joining p1(x1,y1) to p2(x2,y2).
* entry:
* d1: (x1-k) - a positive number
* d3: (x2-k) - a negative number
* d2: y1, d4: y2
	tst.w	d1		point on boundary 
	beq	yint_out	already saved
	tst.w	d3		point on boundary
	beq	yint_out	will be saved
	movem	d5/d6,-(sp)	save x2, y2
yint_in	move.w	d2,d6		y1
	add.w	d4,d6		y1+y2
	asr.w	#1,d6		(y1+y2)/2 = <y>, a possible intercept
	move	d1,d5		dx1
	add.w	d3,d5		dx1+dx2
	asr.w	#1,d5		()/2 = <dx>
	beq	yint_end	if <dx>/2=0, boundary reached
	bgt	yint_loop	if not loop again
	move	d5,d3		unless <dx> is -ve, and becomes new dx2
	move	d6,d4		and <y> is new y2
	bra	yint_in		and try again
yint_loop:
	move	d5,d1		<dx> is new dx1
	move	d6,d2		<y> is new y1
	bra	yint_in

yint_end:
	move.w	d0,(a1)+	store x boundary
	move.w	d6,(a1)+	and <y> as the coords of a new vertex
	addq.w	#1,(a2)		and increment the vertex count
	movem	(sp)+,d5/d6	restore regs
yint_out:
	rts	
	

x_intercept:
* Finds the x-intercept on the clipping boundary y = k of the
* line joining p1(x1,y1) to p2(x2,y2)
* entry:
* d1: x1, d3: x2
* d2: (y1-k) - a positive number
* d4: (y2-k) - a negative number
*
	tst.w	d2		point on boundary 
	beq	xint_out	already saved
	tst.w	d4		point on boundary
	beq	xint_out	wil be saved
	movem	d5/d6,-(sp)	save x2, y2
xint_in	move	d1,d5		x1
	add.w	d3,d5		x1+x2
	asr.w	#1,d5		()/2 = <x> a possible intercept
	move	d2,d6		dy1
	add.w	d4,d6		dy1+dy2
	asr.w	#1,d6		(dy1+dy2)/2 = <dy>
	beq	xint_end	if <dy> = 0, boundary reached
	bgt	xint_loop	if not loop again
	move	d6,d4		unless <dy> is -ve and becomes dy2 
	move	d5,d3		and <x> becomes x2
	bra	xint_in		and try again
xint_loop:
	move	d5,d1		<x> is new dx1
	move	d6,d2		and <dy> is new dy1
	bra	xint_in

xint_end:
	move.w	d5,(a1)+	store intercept <x>
	move.w	d0,(a1)+	and the boundary y as new vertex coords
	addq.w	#1,(a2)		and increment the vertex count
	movem	(sp)+,d5/d6	restore regs
xint_out	rts		next vertex	
* leaves with:
* a list of vertex coordinates at coords_in 
* the number of polygon sides at no_in.

	include	core_00.s	add on the previous core
