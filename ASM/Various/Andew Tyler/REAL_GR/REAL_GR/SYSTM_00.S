* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 systm_00.s                                 *
* Calls to the operating system and frequently used subroutines.    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
find_phys:
* A call to the operating System to find the physical screen address
	move.w	#2,-(sp)	xbios _physbase
	trap	#14		xbios call
	addq	#2,sp		tidy stack
* the base address is returned in d0 and saved 
	move.l	d0,phys_screen	
	rts
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
wrt_phys_tbl:
* Write a look-up table of the addresses of the start of physical each
* screen row in low resolution. The product 4*y is an offset to row y.
	move.l	phys_screen,d0	where screen location is kept
	move	#200-1,d1	200 rows
	lea	phys_tbl_y,a0	where the table is
luloop	move.l	d0,(a0)+	the next row in the table
	add	#160,d0		there are 160 bytes/row
	dbra	d1,luloop	for all rows
	rts
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
hline_lu:
* Set up a look-up table for low resolution horizontal line drawing.
* Each mask in the table is the word to set between pixel a and b.
	lea	hln_tbl,a0	pointer to the table base
	move.w	#16-1,d1	16 rows, d1 is the counter
hloop2	clr.w	d0		new row
	move.w	#16-1,d2	16 columns, d2 is the counter
	bset	d1,d0		set the 1st column bit
hloop3	move.w	d0,(a0)+	next column
	move.w	d0,d3	
	lsr.w	#1,d3	shift
	or.w	d3,d0	add back
	dbra	d2,hloop3	complete this row
	dbra	d1,hloop2	for all rows
	rts
