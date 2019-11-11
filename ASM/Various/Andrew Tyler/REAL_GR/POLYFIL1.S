* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 polyfil1.s                                 *          
* A program to fast fill a polygon. The start and end x coordinates *
* of each horizontal line are the high and low words stored at xbuf.*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
*	SECTION TEXT
	opt	d+		put in labels for debugging
	bra main		don't try to execute the include
	include	systm_00.s	the housekeeping file

main	bsr	find_phys	locate the physical screen
	bsr	wrt_phys_tbl	where the rows start
	bsr	hline_lu	the masks for filling words
	bsr	poly		set up the buffer and fill it
	bra	main		keep going to cover the mouse

* Fill the buffer from y=50 to y=150 with the values 16 and 256 to
* fill a rectangle between the limits x=16 to x=256 and y=50 to y=150.
poly	lea	xbuf,a0		point to start of buffer
	move.w	#50,d0		initial y=50
	lsl.w	#2,d0		*4 for the offset into the table
	adda.w	d0,a0		pointer to the initial long word
	move.l	#$00100100,d0	high word=16,low word=256
	move.w	#100-1,d7	fill 100 lines (up to y=150)
poly1	move.l	d0,(a0)+	fill the next long word
	dbra	d7,poly1	for all the y values
	lea	xbuf,a1		pointer to base address
	move.w	#50,d1		start at y=50 
	move	d1,d3		save it
	lsl.w	#2,d1		y*4 is the offset into the table	
	adda.w	d1,a1		here is the first line
	move.w	#100-1,d7	draw 100 lines (counter is 1 less)
	subq	#1,d3		reduce initial y
poly2	addq	#1,d3		next y
	move.w	(a1)+,d2	next x1
	move.w	(a1)+,d1	next x2
	sub	d2,d1		x2-x1
	addq	#1,d1		N= no to do
	moveq	#1,d4		system colour #1 - red
	lea	phys_tbl_y,a4	where the screen starts
	movem.l	d0-d7/a0-a6,-(sp)	save all registers (why not!)
	bsr	holine			draw the line
	movem.l	(sp)+,d0-d7/a0-a6	restore the registers
	dbra	d7,poly2	repeat for all y values
	rts

*HOLINE. A horizontal line is drawn from left to right. 
* passes: x1=d2.w, y1=d3.w, N=d1.w, colour=d4.w, phys-screen:a4.l
* First find the address of the word at which the line starts.
holine	lea	hln_tbl,a3	pointer to mask table
hline0	lsl.w	#2,d3		there are y long words before the 		
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
* complete 1st word in a long line
long_line:
	sub	d0,d1		number left
	bsr	draw_it
* Now fill all the solid words.
hline6	clr	d0
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
	moveq	#3,d5		(4-1) colour planes
	move	d4,d6		save colour
next_plane:
	lsr	#1,d6		is this colour bit set?
	bcc	not_set		no 
	or.w	d0,(a4)+	yes, also set the bits
	dbf	d5,next_plane
	rts			
not_set	and.w	d3,(a4)+	clear the bits
	dbf	d5,next_plane
	rts

*	SECTION BSS
xbuf	ds.l	400		the buffer of x word pairs
phys_screen	ds.l	1	the address of the physical screen
phys_tbl_y	ds.l	200	pointers to the row y's
hln_tbl		ds.w	256	the masks for filling words
	END
