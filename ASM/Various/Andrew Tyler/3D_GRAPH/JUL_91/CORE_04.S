* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*			core_04.s                                   *
*                  Subroutines for Part 5                           *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

illuminate:
* New subroutines:
* calc_nrm - calculate the polygon normal unit vectors
* calc_ill - calculate the level of illumination 0 - 7
* vis_ill  - convert this to a palette colour
* transfer - move my data to program data
* Calculate the normal unit vectors. All components are *2^14 for accuracy
calc_nrm:
	move.w	npoly,d7	any to do?
	beq	nrm_out		quit if none
	subq	#1,d7		ready to loop
	lea	vcoordsx,a0	coords
	lea	vcoordsy,a1
	lea	vcoordsz,a2
	lea	sedglst,a3	connections
	lea	snedges,a4	no. edges per poly
	lea	snormlst,a5	surface normals pointer
	lea	sarealst,a6	surface area pointer
* Calculate the surface normal unit vectors
next_nrm:
	move.l	a5,-(sp)	save pointer to normals list
	move.l	a6,-(sp)	save pointer to surface areas
	move.w	(a3),a5	first vertex of the next surface
	move.w	2(a3),a6	second vertex
	add	a5,a5		*2 for offset
	add	a6,a6		ditto
	move.w	0(a0,a6.w),d1	x2
	sub.w	0(a0,a5.w),d1	x2-x1 = A12x
	move.w	0(a1,a6.w),d2	y2
	sub.w	0(a1,a5.w),d2	y2-y1 = A12y
	move.w	0(a2,a6.w),d3	z2
	sub.w	0(a2,a5.w),d3	z2-z1 = A12z
	move	a6,a5
	move.w	4(a3),a6	third vertex
	add	a6,a6		*2 for offset
	move.w	0(a0,a6.w),d4	x3
	sub.w	0(a0,a5.w),d4	x3-x2 = A23x
	move.w	0(a1,a6.w),d5	y3
	sub.w	0(a1,a5.w),d5	y3-y2 = A23y
	move.w	0(a2,a6.w),d6	z3
	sub.w	0(a2,a5.w),d6	z3-z2 = A23z

	movea.w	d2,a5		save
	muls	d6,d2	 		
	movea.w	d3,a6		save
	muls	d5,d3		ditto
	sub.l	d2,d3		Bx 
	move.l	d3,-(sp)	save it on stack
	move.w	a5,d2		restore
	move.w	a6,d3		restore
	movea.w	d3,a5		save
	muls	d4,d3
	movea.w	d1,a6		save
	muls	d6,d1
	sub.l	d3,d1		By		
	move.l	d1,-(sp)	save it
	move.w	a6,d1		restore
* last component, no need to save values
	muls	d5,d1		
	muls	d4,d2
	sub.l	d1,d2		Bz
	move.l	d2,-(sp)	save it

	movem.l	(sp)+,d4-d6	Bx in d6, By in d5 and Bz in d4
nrm_cmpt:
	move.w	#14,d1
*now scale up the components by 2^14 for accuracy
	asl.l	d1,d4		* 2^14
	asl.l	d1,d5
	asl.l	d1,d6
* divide by the rectangle areas
	move.l	(sp)+,a6	restore pointer to surface areas
	divs	(a6),d6		nx
	divs	(a6),d5		ny
	divs	(a6)+,d4	nz	
	move.l	(sp)+,a5	restore pointer to normals list
	move.w	d6,(a5)+	save nx
	move.w	d5,(a5)+	save ny
	move.w	d4,(a5)+	save nz
	
	move.w	(a4)+,d0	number of vertices in this surface
	addq	#1,d0		the edge list always repeats the first
	add	d0,d0		*2 for offset
	adda.w	d0,a3		adjust edge list pointer to next surface
	dbra	d7,next_nrm	do all the surfaces (polygons)
nrm_out:	

vis_ill:
* Find the visibility and level of illumination of a surface by taking
* the scalar product of the surface unit normal vector with the
* line of sight vector from the viewpoint and with illumination vector
* respectively.
	move.w	npoly,d7
	subq	#1,d7
	lea	vcoordsx,a0
	lea	vcoordsy,a1
	lea	vcoordsz,a2
	lea	snedges,a3
	lea	sedglst,a4
	lea	snormlst,a5	surface unit normals list
	lea	slumlst,a6	surface illumination and visibility list
	move.w	ill_vecx,d0	illumination vector x-component
	move.w	ill_vecy,d1	ditto	y
	move.w	ill_vecz,d2	ditto	z
* The line-of-sight vector is taken between the first vertex on the 
* surface and the view point.
next_ill:
	move.w	(a4),d6		1st point on next surface
	add	d6,d6		offset
	move.w	0(a0,d6.w),d3	is the line-of sight x-cmpt., xls
	move.w	0(a1,d6.w),d4	yls
	move.w	0(a2,d6.w),d5	z
	sub.w	vwpointz,d5	zls :view point lies along -zv axis
	muls	(a5),d3		nx*sx
	muls	2(a5),d4	ny*sy
	muls	4(a5),d5	nz*sz
	add.l	d4,d3
	add.l	d5,d3		scalar product
	bmi	visible		is negative if surface visible
* It is hidden
	move.w	#$f0,(a6)+	set illumination for hidden and move on
ill_tidy:
	addq.w	#6,a5		update normals pointer
	move.w	(a3)+,d5	current no. edges
	addq	#1,d5		first vertex is repeated
	add	d5,d5		2 bytes/word
	adda.w	d5,a4		update edge list pointer
	dbra	d7,next_ill		for all surfaces
	bra	set_colr		go on to set the colours

* The surface is visible so find the illumination level.
* Remember all vectors are *2^14
visible:
	move.w	d0,d3		copy the illumination vector
	move.w	d1,d4
	move.w	d2,d5
	muls	(a5),d3		nx*illx
	muls	2(a5),d4	ny*illy
	muls	4(a5),d5	nz*illz
	add.l	d4,d3
	add.l	d5,d3		-2^28 < scalar product < +2^28
	add.l	#$11100000,d3	0 < scalar product < 2^29
	move.w	#25,d4
	lsr.l	d4,d3
	cmp.w	#$f,d3		keep in range 0 to $f
	ble	vis_1		correct
	move.w	#$f,d3		for
	bra	ill_save	errors
vis_1	cmp.w	#0,d3
	bge	ill_save
	clr	d3
ill_save:
	move.w	d3,(a6)+	save it
	bra	ill_tidy	next one

set_colr:
* The illumination level is combined with the intrinsic colour to produce
* the final displayed colour.
* Illkey is used to determine the number of shades per colour so that
* different lighting levels can be simulated:
* illkey = 2 gives 4 shades of 4 colours: 0, 1, 2, 3
* illkey = 1 gives 8 shades of 2 colours: 0, 1
* illkey = 0 gives 16 shades of 1 colour: 0 	
	move.w	npoly,d7
	subq.w	#1,d7		the counter
	move.w	illkey,d0	how many shades per colour
	lea	slumlst,a0	the levels of illumination
	lea	srf_col,a1	raw intrinsic colours: 0 or 0,1 or 0,1,2,3
	lea	col_lst,a2	final colours for display
	move.w	#4,d6
	sub.w	d0,d6		4-illkey
next_col:
	move.w	(a0)+,d1	next illumination
	cmp.w	#$f,d1		is it hidden?
	ble	set_col		no
	move.w	#$f0,(a2)+	it is, set flag
	addq.l	#2,a1		point to next intrinsic colour
	bra	set_next	and go on
set_col	lsr.w	d0,d1		divide by 0, 2, or 4
	move.w	(a1)+,d2	the intrinsic colour
	rol.b	d6,d2		0 or 0,8 or 0,4,8,12 = colour base 
	add.w	d1,d2		illumination + colour base
	bgt	pass_col
	move.w	#1,d2		avoid background
pass_col:
	move.w	d2,(a2)+	= final colour
set_next:
	dbra	d7,next_col	for all surfaces
	rts
* Set the colour palette
palette_set:
	pea	palette		here's my palette
	move.w	#6,-(sp)	setpalette function		
	trap	#14		xbios
	add.w	#6,sp		tidy
	rts
* Transfer my data to program data
transfer:
	move.w	my_npoly,d7	no. of polygons
	move.w	d7,npoly	pass it
	subq.w	#1,d7		the counter
	move.w	d7,d0		save it
	lea	my_nedges,a0	source
	lea	snedges,a1	destination
	lea	intr_col,a2	my intrinsic colours
	lea	srf_col,a3	program intrinsic colours
loop0	move.w	(a0)+,(a1)+	transfer edge nos.
	move.w	(a2)+,(a3)+	transfer intrinsic colours
	dbra	d0,loop0	
* Calculate the number of vertices altogether
	move.w	d7,d0		restore count
	lea	my_nedges,a6
	clr	d1
	clr	d2
loop1	add.w	(a6),d1		no more than this
	add.w	(a6)+,d2	total no. of vertices
	addq	#1,d2		and with last one repeated each time
	dbra	d0,loop1	
* Move the edge list
	subq	#1,d2		the counter
	lea	my_edglst,a0	source
	lea	sedglst,a1	destination
loop2	move.w	(a0)+,(a1)+	pass it
	dbra	d2,loop2
* and the coords list
 	move.w	d1,oncoords
	subq	#1,d1		the counter
	lea	ocoordsx,a1
	lea	my_datax,a0
	lea	ocoordsy,a3
	lea	my_datay,a2
	lea	ocoordsz,a5
	lea	my_dataz,a4
loop3	move.w	(a0)+,(a1)+
	move.w	(a2)+,(a3)+
	move.w	(a4)+,(a5)+
	dbra	d1,loop3
* and the window limits
	move.w	my_xmin,xmin	ready
	move.w	my_xmax,xmax	for
	move.w	my_ymin,ymin	clipping
	move.w	my_ymax,ymax
	rts

rstr_scrn:
* back to only one screenand reset the palette
	move.w	#-1,-(sp)
	move.l	screen2,-(sp)
	move.l	screen2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	pea	std_pal		here's the standard palette
	move.w	#6,-(sp)	setpalette
	trap	#14		xbios
	add.w	#6,sp		tidy
	rts

std_pal	dc.w	$777,$700,$070,$770,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

