* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 perspect.s				  *
* A perspective view of an ST monolith                            *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

*	SECTION TEXT
	opt	d+
	bra	main
	include	systm_01.s	housekeeping file
	include	core_02.s	core subroutines

main	bsr	find_phys	set
	bsr	wrt_phys_tbl	up 
	lea	phys_tbl_y,a0	screen
	move.l	a0,screen	routines
	bsr	hline_lu
	bsr	hide_mse
* Transfer the data. First the edge numbers and colours
	move.w	my_npoly,d7	no. of polygons?
	beq	term		if none, quit
	move.w	d7,npoly	or becomes 
	subq.w	#1,d7		the counter
	move.w	d7,d0		save it
	lea	my_nedges,a0	source
	lea	snedges,a1	destination
	lea	my_colour,a2	source
	lea	col_lst,a3	destination
loop0	move.w	(a0)+,(a1)+	transfer edge nos.
	move.w	(a2)+,(a3)+	transfer colours
	dbra	d0,loop0	

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

* Calculate the perspective view and draw it	
	bsr	perspective
	bsr	polydraw

* Test for a key press to finish
loop4	bsr	scan_keys	test for a key press to quit
	tst	d0
	bne	term

	bra	loop4		keep testing
term	move.w	#$4c,-(sp)	terminate - return to calling program
	trap	#1

*	SECTION DATA
	include	data_01.s
	include	data_02.s
*	SECTION BSS
	include	bss_02.s

	END
