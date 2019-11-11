* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*			3D_03.s 				  *
*         A perspective view of an ST monolith                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*This is the file to assemble. It includes all the others

*	SECTION TEXT
	opt	d+		labels for debugging
	bra	main		don't execute the include
	include	core_02.s	core subroutines

main	bsr	init_LineA	fetch pointer to Line A parameters
	dc.w	$a00a		kill the mouse
* Transfer the data. First the edge numbers and colours
	move.w	my_npoly,d7	no. of polygons?
	beq	loop4		if none, quit
	move.w	d7,npoly	or becomes 
	subq.w	#1,d7		the counter
	move.w	d7,d0		save it
	lea	my_nedges,a0	source
	lea	snedges,a1	destination
	lea	my_colour,a2	source
	lea	col_lst,a3	destination
loop0	move.w	(a0)+,(a1)+	transfer edge nos.
	move.w	(a2)+,(a3)+	transfer colours
	dbra	d0,loop0	all of them

* Second the edge list and coordinates	
	move.w	d7,d0		restore count
	lea	my_nedges,a6
	clr	d1
	clr	d2
loop1	add.w	(a6),d1
	add.w	(a6)+,d2
	addq	#1,d2		last one repeated each time
	dbra	d0,loop1	= total no. of vertices

	subq	#1,d2		the counter
	lea	my_edglst,a0	source
	lea	sedglst,a1	destination
loop2	move.w	(a0)+,(a1)+	pass it
	dbra	d2,loop2
	move.w	d1,vncoords
	subq	#1,d1		the counter
	lea	vcoordsx,a1
	lea	my_datax,a0
	lea	vcoordsy,a3
	lea	my_datay,a2
	lea	vcoordsz,a5
	lea	my_dataz,a4
loop3	move.w	(a0)+,(a1)+
	move.w	(a2)+,(a3)+
	move.w	(a4)+,(a5)+
	dbra	d1,loop3
* The clip frame boundaries
	move.w	my_xmin,xmin	ready
	move.w	my_xmax,xmax	for
	move.w	my_ymin,ymin	clipping
	move.w	my_ymax,ymax

	bsr	perspective	calculate the perspective view
	bsr	polydraw	and draw it

* See if a key has been pressed to return to the desktop 
loop4	move.w	#2,-(sp)	has a key
	move.w	#1,-(sp)	been pressed?
	trap	#13		BIOS call CONIN - wait for it
	addq.l	#4,sp		tidy STACK
	tst	d0		character code 
	beq	loop4		no key was pressed
	move.w	#$4c,-(sp)	a key was pressed 
	trap	#1		GEMDOS call p_term - back to caller
	

*	SECTION DATA
	include data_00.s	all the data files
	include	data_01.s
	include	data_02.s
*	SECTION BSS
	include bss_01.s	all the variables
	include	bss_02.s

	END
