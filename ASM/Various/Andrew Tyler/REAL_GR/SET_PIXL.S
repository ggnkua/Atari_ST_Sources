* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 set_pixl.s	                          *
*                                                                 *
* A program to set a pixel in low resolution using a low          * 
* resolution screen driver. The Operating System is used to find  *
* the address of the physical screen. Also a look-up table is     *
* constructed to quickly find screen row adreses from y coords.   *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	opt	d+		write in labels for debugging  

*	SECTION TEXT
	bra	main		don't try to execute the include
	include	systm_00.s	include the file of subroutines

* Here is the main program
main:				
	bsr	find_phys	locate the physical screen address
	bsr	wrt_phys_tbl	construct the row address look-up
	move	#160,d0		plot the pixel at x=160	
	move	#100,d1		and y=100
	moveq	#1,d2		with colour red	
	bsr	set_pix		plot a point
	bra	main		avoid being covered by the mouse

set_pix:
* The subroutine to plot a pixel at x,y in low resolution
* Entry: x=d0.w,y=d1.w,colour=d2.w. Corrupted: d0,d1,d2,d3,d4,d7,a0.
	lea	phys_tbl_y,a0	the screen base address is here
	lsl	#2,d1		4*y is the row offset
	movea.l	0(a0,d1.w),a0	to this row address
	move	d0,d5		save x
	andi	#$fff0,d5	go in steps of 4 words
	lsr.w	#1,d5		to the first word in the group
	adda.w	d5,a0		at this address
	and	#$000f,d0	this is the pixel number in the word
	subi	#15,d0
	neg	d0		this is the bit
	clr	d1
	bset	d0,d1		this is the mask
	move	d1,d3
	not	d3		and its complement
	move	#4-1,d7		the counter for the 4 colour planes
* Use the colour nibble to set the four colour planes
next_plane:
	lsr	#1,d2		is this bit set?
	bcc	clear_bit	no
	or.w	d1,(a0)+	it is, so set the plane
	dbra	d7,next_plane	for all planes
	rts
clear_bit:
	and.w	d3,(a0)+	the bit is zero so clear the plane
	dbra	d7,next_plane	for all planes
	rts

*	SECTION BSS
* Where uninitialised data (that calculated by the program) is stored
phys_screen	ds.l	1	the address of the physical screen
phys_tbl_y	ds.l	200	pointers to the rows in low resolution
hln_tbl		ds.w	256	(not used just yet)
	END
