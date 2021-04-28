* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*			core_02.s                                   *
*                Program core for Part 3                            *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*			perspective
* A subroutine which uses the perspective transform matrix at
* persmatx to transform a set of viewframe coords at vcoordsx,
* vcoordsy and vcoordsz into screen coords at pcoordsx and pcoordsy
* by matrix mutiplication.
* Regs:
*	a0: pointer to view frame x-coords list vcoordsx
*	a1:	ditto	                   y	vcoordsy
*	a2:	ditto                      z	vcoordsz
*	a4: pointer to screen x-coords list	scoordsx
*	a5: pointer to screen y-coords list	scoordsy
* Just to be tricky we use the link instruction to open a frame on the
* stack to temporarily store the results of the calculation.

perspective:
	move.w	vncoords,d7	any points to do?
	beq	prs_end		if none, quit
	subq.w	#1,d7		otherwise this is the count	
	lea	vcoordsx,a0	the
	lea	vcoordsy,a1	source
	lea	vcoordsz,a2	coords.
	lea	scoordsx,a4	the
	lea	scoordsy,a5	destination.
	link	a6,#-32		open a frame with space for 16 words
prs_crd:
* set up the perspective matrix pointer to transform the next vertex
	moveq	#3,d6		4 rows in the transform matrix M
	lea	persmatx,a3	init matrix pointer
prs_elmnt:
* calculate the next column vector element i 
	move.w	(a0),d0		next view frame coord xv
	move.w	(a1),d1		next                  yv
	move.w	(a2),d2		next                  zv
	muls	(a3)+,d0	the matrix products 	xv*Mi1
	muls	(a3)+,d1				yv*Mi2
	muls	(a3)+,d2				zv*Mi3
	add.l	d1,d0		a long word product		
	add.l	d2,d0

	move.w	#1,d1		and the extra homogeneous term
	muls	(a3)+,d1
	add.l	d1,d0		the new element
	
	move.l	d0,-(a6)	save it
	
	dbf	d6,prs_elmnt	repeat for 4 elements

	move.l	(a6)+,d3	restore 4th
	bne	prs_ok
	addq	#1,d3		avoid divide by zero
prs_ok	addq.l	#4,a6		point to 2nd
	move.l	(a6)+,d4	restore 2nd
	divs	d3,d4		next Yv=yv/(zv/d+1)result in lw
	add.w	#160,d4		centre at bottom, middle of screen
	move.w	d4,(a4)+	becomes next xs

	move.l	(a6)+,d4	restore 1st
	divs	d3,d4		next Xv=xv/(zv/d+1)
	sub.w	#199,d4		Xv-199
	neg.w	d4		199-Xv=next 
	move.w	d4,(a5)+	ys

	addq.l	#2,a0		point to next xv
	addq.l	#2,a1				yv
	addq.l	#2,a2				zv

	dbf	d7,prs_crd	repeat for all coords
	unlk	a6		close frame
prs_end	rts			and quit
	
	
polydraw:
* This draws the visible surfaces of a polyhedron.
* It follows the perspective transform and first converts coords
* from the form of two arrays accessed from an edge list to the
* actual sequence of coord. pairs (x1,y1,x2,y2...x1,y1) needed for
* windowing and all that follows.
* Input: scoordsx pointer to list of x coords
*	 scoordsy   "                y  
*        sedglst - the list of edge connections (1,2,3,4,..1)
*        snedges - the number of edges in each polygon
*	 npoly	 - number of polygons
*	 col_lst - list of colours (colour > $f means hidden) 
* init. all addresses
	move.w	npoly,d7	number to do
	beq	polydraw5	there are none
	subq	#1,d7		the polygon counter
*Set up the pointers 
	lea	scoordsx,a0	list (x1,x2,....xn)
	lea	scoordsy,a1	list (y1,y2,....yn)
	lea	sedglst,a2	list (1,2,3......1)
	lea	snedges,a3	list (n1,n2,......)
	lea	col_lst,a4	list (c1,c2.....cn)
* start the loop
polydraw2:
	move.w	(a4)+,d0	colour of next polygon
	cmp.w	#$f,d0		is it visible?
	ble	polydraw3	yes
* it's hidden - update the pointers
	move.w	(a3)+,d0	no. edges in next poly
	addq.w	#1,d0		last vertex repeated
	add	d0,d0		2 bytes/word
	adda.w	d0,a2		update edge list pointer
	bra	polydraw4	go on
polydraw3:
	move.w	d0,colour	the current colour
	move.w	(a3)+,d0	no edges in next polygon
	beq	polydraw3	none to do
	move.w	d0,no_in	clip this number of edges
	lea	crds_in,a5	from this list
* set up the coords for this polygon for clip and all that follows
polydraw1:
	move.w	(a2)+,d1	next vertex no
	lsl	#1,d1		for index
	move.w	0(a0,d1.w),(a5)+	next x
	move.w	0(a1,d1.w),(a5)+	next y
	dbf	d0,polydraw1	one more coord than the count
	movem.l	d7/a0-a4,-(sp)	save these 	
	bsr	clip		window it
	bsr	poly_fil	draw the filled polygon
	movem.l	(sp)+,d7/a0-a4	restore
polydraw4:
	dbra	d7,polydraw2	for all the polygons
polydraw5:
	rts			all done


	include	core_01.s	all the previous subroutines
