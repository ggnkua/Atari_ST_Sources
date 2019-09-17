
;        -------------- Calamus User Sub-Routines -----------

;This group of sub-routines will be used by the programmer to make,
;display or modify the Calamus font images

;Show a Calamus char on screen
;ENTRY d0=x co-ord
;      d1=y co-ord
;      d2=char code (0-255, codes 0-31 ignored)
;      a0=address of ca_table (list of chr addresses)
;      Clipping rectangle defined or clipping off
;EXIT  Char blitted to screen (if valid) Z=0 (bne)
;      No action if code invalid, Z=1 (beq)

show_char	movem.l	d0-d3/a0-a2,-(sp)
	clr	d3	clr exit flag
	sub	#32,d2	ignore code 0-31
	bmi	show_char1	bra if error
	cmp	#255-32,d2	ignore if > 255
	bgt	show_char1
	lsl	#2,d2	d2*4
	add	d2,a0	locate table entry
	tst.l	(a0)	chk if valid chr ?
	beq	show_char1	obviously not

	move.l	(a0),a0	set a0 to image data

show_char2	move	4(a0),ptsin	set source x1 co-ord
	clr	ptsin+2	set source y1 co-ord
	move	6(a0),ptsin+4	set source x2 co-ord
	move	2(a0),ptsin+6	set source y2 co-ord
	sub	#1,ptsin+6
	
	move	d0,ptsin+8	set dest x1 co-ord
	move	d1,ptsin+10	set dest y1 co-ord
	add	6(a0),d0	add right_offset
	sub	4(a0),d0	sub left_offset
	add	#2,d0
	move	d0,ptsin+12	set dest x2 co-ord
	add	2(a0),d1	add height
	sub	#1,d1
	move	d1,ptsin+14	set dest y2 co-ord
	
	move	(a0),d0	calc width (words)
	lsr	#1,d0
	move	d0,srce_mfdb+8	and copy to mfdb

	move	2(a0),srce_mfdb+6

	move	6(a0),d0	calc width (pix)
	sub	4(a0),d0	sub left offset
	move	d0,srce_mfdb+4	copy width to mfdb
	
	add	#8,a0	access data
	move.l	a0,srce_mfdb	source=RAM image
	
	clr.l	dest_mfdb	dest=screen
	clr	srce_mfdb+10
	move	#1,srce_mfdb+12
	vrt_cpyfm	#2,#srce_mfdb,#dest_mfdb,#1,#0
	move	#1,d3	set exit flag
show_char1	tst	d3	set/reset Z flag
	movem.l	(sp)+,d0-d3/a0-a2
	rts

;Blit Calamus char to screen
;ENTRY d0=x co-ord
;      d1=y co-ord
;      a0=address of chr image data
;      Clipping rectangle defined or clipping off
;EXIT  Char blitted to screen

blit_char	movem.l	d0-d3/a0-a2,-(sp)
	bra	show_char2	use 'show_char' S/R

;Copy font bit image to screen (160 pixels wide * 16 pixels high)
;ENTRY a0 points at buffer that holds font data
;      d0=x co-ord of top left corner
;      d1=y co-ord of top left corner
;EXIT  font bit image displayed (edge on byte boundary)

show_image	movem.l	d0-d3/a0-a2,-(sp)

	add	#$90,a0	locate bit image data
	move	(a0)+,d2	fetch width in pixels
	move	(a0)+,d3	fetch height

	clr.l	dest_mfdb	dest=screen
	move.l	a0,srce_mfdb	set source RAM
	move	d2,srce_mfdb+4
	move	d3,srce_mfdb+6
	lsr	#4,d2
	move	d2,srce_mfdb+8
	move	#0,srce_mfdb+10
	move	#1,srce_mfdb+12
	clr.l	srce_mfdb+14
	clr	srce_mfdb+18
	
	clr	ptsin	set source x1
	clr	ptsin+2	set source y1
	move	srce_mfdb+4,ptsin+4	set source x2
	sub	#1,ptsin+4
	move	srce_mfdb+6,ptsin+6	set source y2
	sub	#1,ptsin+6
	move	d0,ptsin+8	set dest x1
	
	move	d1,ptsin+10	set dest y1
	
	move	ptsin+8,d0
	add	srce_mfdb+4,d0
	sub	#1,d0
	move	d0,ptsin+12	set dest x2
	
	move	ptsin+10,d1
	add	srce_mfdb+6,d1
	sub	#1,d1
	move	d1,ptsin+14	set dest y2
	
	vrt_cpyfm	#1,#srce_mfdb,#dest_mfdb,#1,#0
	
	movem.l	(sp)+,d0-d3/a0-a2
	rts

;Generate bit images of complete char set in RAM
;ENTRY (chr_addr) = start address of cleared bit image RAM buffer
;      a0=start address of Calamus font data
;      a5=address of chr address table (224 longwords)
;      (max_ram)=address of end of bit image RAM
;      (font_size)=scaling divide value
;EXIT  d0=0 OK
;      d0=1 invalid Calamus font file
;      d0=2 insufficient image RAM
;      d0=3 sort RAM error
;      (chr_addr) holds address of last byte+1
;      (t_edge) holds top edge offset
;      (font_height)=height of tallest chr (in pixels)
;      (max_width)=width of widest chr (in pixels)
;      (base_line)=No of pixels from top of chr to baseline
;      (chr_count)=No of chrs actually used

make_char_set	move	#1,d0	error code=1 not a CFN file	
	move.l	a0,a3	copy to a3

	cmp.l	#'CALA',(a3)	check if 1st 10 chrs
	bne	make_char_set1	= 'CALAMUSCFN'
	cmp.l	#'MUSC',4(a3)
	bne	make_char_set1	abort if error
	cmp	#'FN',8(a3)
	bne	make_char_set1	abort if error
	clr	max_width

	clr	d7	init chr count	

	add	#$2b4,a3	a3=section 0004+4
	move	-2(a3),d1	fetch max No of chrs
	move	d1,d6	d6=No of usable chrs
	lsl	#4,d1	*16
	
	add	d1,a3	a3=section 0005
	add	#8,a3	a3=start of chr offsets

	bsr	calc_top	calc top offset & height, etc

make_char_set2	move	d7,d0	fetch current chr
	lsl	#2,d0	d0*4 (lword sizes)

	clr.l	(a5)	clr addr store
	cmp.l	#-2,0(a3,d0)	is it used ?
	beq	make_char_set3	apparently not !

	move.l	chr_addr,(a5)	store chr addr

	move	#2,d0	set image RAM error
	move	char_width,d1	calc RAM reqd for
	mulu	font_height,d1	next chr in d1
	
	move.l	chr_addr,a1	chk for overflow
	add.l	d1,a1	calc next addr
	add	#4*2,a1	plus header
	cmp.l	max_ram,a1	is a1>max_ram ?
	bgt	make_char_set1	abort if no more RAM
	
	bsr	make_image	generate image in RAM
	tst	d0	chk for error
	bne	make_char_set1	abort if so
	
	add.l	d1,chr_addr	update addr store
	
make_char_set3	add	#4,a5	next table addr
	add	#1,d7	inc chr count
	cmp	d6,d7	all done ?
	bne	make_char_set2	repeat if not

	clr.l	d0	d0=0 no error
make_char_set1	rts

;Generates a bit image in RAM for current char
;ENTRY a0=start address of font data
;      d7=chr code 0-224 (i.e. ASCII code minus 32) 
;      (font_size) holds scaling factor
;      (chr_addr) holds start address of cleared bit image RAM
;      (char_width) holds width of chr in bytes       }
;      (font_height) holds font height in scan lines  }set by calc_top
;      (t_edge)=y offset value for all chrs           }
;      (max_width)=current max chr width
;EXIT  Bit image of chr generated at (chr_addr...)
;      (chr_addr) holds last RAM address+1
;      (max_width)=new max chr width (if different)
;      d0=0 OK
;      d0=1 if chr not valid
;      d0=2 RAM error
;      d0=3 Sort error

make_image	movem.l	d1-d7/a0-a4,-(sp)

	move	#1,d0	  error code (no chr)
	add	#$2b4,a0	  locate section 0004+4
	move	-2(a0),d1	  fetch No of chrs
	lsl	#4,d1	  d1*16
	add	d1,a0	  a0=section 0005
	add	#8,a0	  a0=offset table
	move.l	a0,a3	  copy a0 to a3	

	lsl	#2,d7	  d7*4
	cmp.l	#-2,0(a0,d7)	  check if valid chr
	beq	make_image5	  & exit if not (d0=1)
	
	move	-2(a3),d1	  fetch No of chrs
	lsl	#2,d1	  d1*4
	add	d1,a3	  a0=section 0006
	add	#6,a3	  a0=start of chr data
	add.l	0(a0,d7),a3	  locate chr data
	
	move.l	chr_addr,a0	  store header values
	move	char_width,(a0)+  store width (bytes)
	move	font_height,(a0)+ store height (lines)
	move.l	a0,a4	  a4=left offset addr
	move	#16320,(a0)+	  preset left offset to max
	move	#0,(a0)+	  preset right offset to min
	move.l	a0,chr_addr	  update addr

	move.l	#up_list,up_pointer	locate up list
	move.l	#up_list,first_up
	move.l	#down_list,down_pointer	locate down list
	move.l	#down_list,first_down
	clr	up_down	reset flag
	
make_image1	cmp	#15,(a3)	check if end
	beq	make_image2	and exit

	tst	(a3)	check if new path
	bne	make_image3	no

	add	#2,a3	skip ident code
	move	(a3)+,d6	fetch x co-ord
	and.l	#$ffff,d6
	divu	font_size,d6	scale down
	move	(a3)+,d7	fetch y co-ord
	sub	t_edge,d7	sub y offset
	and.l	#$ffff,d7
	divu	font_size,d7	scale down
	move	#-1,last_y
	
	bsr	end_poly	check end of polyline
	bra	make_image1	loop
	
make_image3	cmp	#1,(a3)	check if straight line
	bne	make_image4	no
	move	d6,poly_table	store start x co-ord
	move	d7,poly_table+2	store start y co-ord
	add	#2,a3	skip straight line code
	move	(a3)+,d6	fetch end x co-ord
	and.l	#$ffff,d6
	divu	font_size,d6	scale down
	move	(a3)+,d7	fetch end y co-ord
	sub	t_edge,d7	sub y offset
	and.l	#$ffff,d7
	divu	font_size,d7	scale down
	move	d6,poly_table+4	store end x co-ord
	move	d7,poly_table+6	store end y co-ord
	move	#2,d0	2 points
	bsr	poly_line	draw line
	bra	make_image1	loop

make_image4	add	#2,a3	skip bezier line code
	move	d6,bez_in	store start x co-ord
	move	d7,bez_in+2	store start y co-ord

	move	(a3)+,d6	fetch control x co-ord
	and.l	#$ffff,d6
	divu	font_size,d6	scale down
	move	d6,bez_in+4	store control point x1
	
	move	(a3)+,d7	fetch control y co-ord
	sub	t_edge,d7	sub y offset
	and.l	#$ffff,d7
	divu	font_size,d7	scale down
	move	d7,bez_in+6	store control point y1
	
	move	(a3)+,d6	fetch control x co-ord
	and.l	#$ffff,d6
	divu	font_size,d6	scale down
	move	d6,bez_in+8	store control point x2
	
	move	(a3)+,d7	fetch control y co-ord
	sub	t_edge,d7	sub y offset
	and.l	#$ffff,d7
	divu	font_size,d7	scale down
	move	d7,bez_in+10	store control point y2
	
	move	(a3)+,d6	fetch end x co-ord
	and.l	#$ffff,d6
	divu	font_size,d6	scale down
	move	d6,bez_in+12	store end x co-ord

	move	(a3)+,d7	fetch end y co-ord
	sub	t_edge,d7	sub y offset
	and.l	#$ffff,d7
	divu	font_size,d7	scale down
	move	d7,bez_in+14	store end y co-ord

	bsr	draw_bezier	draw bezier curve
	bra	make_image1	loop
	
make_image2	bsr	end_poly
	lea	up_list,a0	sort up list
	bsr	sort_list
	lea	down_list,a0	sort down list
	bsr	sort_list	

	bsr	fill_char	fill in char
	bne	make_image5	abort if error
	move	2(a4),d0	fetch right edge
	sub	(a4),d0	calc diff
	add	#1,d0	d0=width
	cmp	max_width,d0	d0>max ?
	blt	make_image6
	move	d0,max_width	update max value
	
make_image6	clr	d0	no errors
make_image5	movem.l	(sp)+,d1-d7/a0-a4
	rts

;Calculate max chr height, chr width, top edge offset and baseline for all chars
;ENTRY a0=start of font data
;      (font_size)=scale divide value
;EXIT  (t_edge)=value to subtract from y co-ords
;      (font_height)=height of char in scanlines
;      (char_width)=width of all chrs (bytes)
;      (base_line)=distance from top of chr image to base line (in pix)
;      (chr_count)=Number of actual chrs used

calc_top	movem.l	d1-d6/a0,-(sp)

	clr	chr_count	init chr counter
	move.l	#16320,d0	calc chr width
	divu	font_size,d0	
	lsr	#3,d0	div by 8
	bclr	#0,d0	make even no of bytes
	add	#2,d0	and correct
	move	d0,char_width	set width in bytes

	move	$1e0(a0),d4	fetch base line offset

	add	#$2b4,a0	a0=section 0004+4
	move	-2(a0),d1	fetch max No of chrs
	move	d1,d6	d6=No of usable chrs
	lsl	#4,d1	*16
	add	d1,a0	a0=section 0005
	add	#8,a0	a0=start of chr offsets

	move	#16320,t_edge	preset min y value
	clr	d0	preset max y value
	clr	d2	preset chr counter
calc_top4	move	d2,d3	fetch current chr
	move	-2(a0),d1	fetch No of chrs
	lsl	#2,d1	d1*4
	lsl	#2,d3	d3*4 (lword sizes)
	move.l	0(a0,d3),d3	d3=offset or -2

	cmp.l	#-2,d3	is it used ?
	beq	calc_top5	apparently not !

	add	#1,chr_count	inc chr counter
	move.l	a0,-(sp)	save a0
	add	d1,a0	a0=section 0006
	add	#6,a0	a0=chr total size value
	add.l	d3,a0	a0=start of reqd data
	
calc_top1	cmp	#15,(a0)	check if end
	beq	calc_top2	and exit

	cmp	#2,(a0)	check if bezier curve
	beq	calc_top3	yes

	add	#4,a0	straight line, skip ident & x co-ord
	move	(a0)+,d3	fetch y co-ord
	cmp	t_edge,d3
	bgt	calc_top9
	move	d3,t_edge
calc_top9	cmp	d0,d3
	blt	calc_top1
	move	d3,d0
	bra	calc_top1	loop
	
calc_top3	add	#4,a0	skip bez code & x co-ord
	move	(a0)+,d3	fetch control c1y co-ord
	cmp	t_edge,d3
	bgt	calc_top6
	move	d3,t_edge
calc_top6	cmp	d0,d3
	blt	calc_top10
	move	d3,d0
calc_top10	add	#2,a0	skip c2x co-ord
	move	(a0)+,d3	fetch control c2y co-ord
	cmp	t_edge,d3
	bgt	calc_top8
	move	d3,t_edge
calc_top8	cmp	d0,d3
	blt	calc_top11
	move	d3,d0
calc_top11	add	#2,a0	skip x4 co-ord
	move	(a0)+,d3	fetch control y4 co-ord
	cmp	t_edge,d3
	bgt	calc_top12
	move	d3,t_edge
calc_top12	cmp	d0,d3
	blt	calc_top1
	move	d3,d0
	bra	calc_top1	loop
	
calc_top2	move.l	(sp)+,a0	restore a0
calc_top5	add	#1,d2
	cmp	d6,d2	all done
	bne	calc_top4
	
	move	t_edge,d3	add 1 line to top edge
	sub	font_size,d3
	move	d3,t_edge
	sub	t_edge,d0
	add	#1,d0	add 1 more pixel
	and.l	#$ffff,d0
	divu	font_size,d0	scale down
	add	#2,d0	
	move	d0,font_height	set height (pixels)

	sub	t_edge,d4	calc baseline
	divu	font_size,d4	scale down
	move	d4,base_line	& save

	movem.l	(sp)+,d1-d6/a0
	rts

;Copies bit pattern to specified character
;ENTRY a0=address of chr data bit image
;      a1=address of 2*16 byte pattern data
;EXIT  chr bit image modified with pattern

pattern	movem.l	d0-d4/a0-a2,-(sp)
	move	(a0)+,d1	fetch width
	move	(a0)+,d2	fetch height
	add	#4,a0	skip offsets
	move.l	a1,a2	save addr
	clr	d4	reset row count
	sub	#1,d2	correct for dbra

	lsr	#1,d1	conv width to words
	sub	#1,d1	correct for dbra
pattern1	move	d1,d3	fetch width count
	move	(a2),d0	fetch pattern
pattern2	and	d0,(a0)+	copy to dest
	dbra	d3,pattern2	repeat for whole line
	
	add	#2,a2	next pattern row
	add	#1,d4	inc row count
	cmp	#16,d4	last row ?
	bne	pattern3	yep
	clr	d4	reset count
	move.l	a1,a2	reset addr
pattern3	dbra	d2,pattern1	repeat all rows
	movem.l	(sp)+,d0-d4/a0-a2
	rts

;Generates an outline of chr in chr data
;ENTRY a0=address character image data
;      a1=address of a temporary buffer
;EXIT  (temporary buffer...) holds outline image of chr

outline	movem.l	d0-d7/a0-a6,-(sp)
	
	move.l	a1,a3	copy temp buffer to a3
	move	(a0),(a3)	& copy header to buffer
	move	2(a0),2(a3)
	move	4(a0),4(a3)
	move	6(a0),6(a3)
	addq	#8,a3	set a3 to start of data
	
	move	(a0)+,d4	fetch width in bytes to d4
	move	d4,d5	& save in d5
	lsl	#3,d4	conv to pixels
	sub	#1,d4	correct for dbra
	move	(a0)+,d7	fetch height
	sub	#1,d7	correct for dbra
	
	add	#4,a0	skip offsets
	move.l	a0,a4	a4=y-width
	add	d5,a0	a0 -> x,y
	move.l	a0,a5
	add	d5,a5	a5=y+width
	
	move.l	a0,a1	a1 -> x-1,y
	move.l	a1,a2	a2 -> x+1,y
	add	d5,a3	a3 -> destination x,y 
	moveq	#7,d0	d0 -> left pixel position
	moveq	#6,d1	d1 -> middle pixel position
	moveq	#5,d2	d2 -> right pixel position

outline1	move	d4,d6	set d6 to width
outline2	tst.b	(a0)	all 0s ?
	beq	outline8	yep so skip bit tests
	btst	d1,(a0)	test x,y
	beq	outline4
	btst	d0,(a1)	test x-1,y
	beq	outline3
	btst	d2,(a2)	test x+1,y
	beq	outline3
	btst	d1,(a4)	test x,y-1
	beq	outline3
	btst	d1,(a5)	test x,y+1
	bne	outline4
outline3	bset	d1,(a3)	plot point
outline4	subq	#1,d0	move bit position right (left pixel)
	bpl	outline5	branch if still 0-7
	moveq	#7,d0	otherwise reset bit position
	addq.l	#1,a1	and increase to next screen location
outline5	subq	#1,d1	move bit position right (middle pixel)
	bpl	outline6
	moveq	#7,d1
	addq	#1,a0	inc screen positions and
	addq	#1,a4	inc y-width
	addq	#1,a5	inc y+width
	addq	#1,a3	also inc destination address
outline6	subq	#1,d2	move bit position right (right pixel)
	bpl	outline7
	moveq	#7,d2
	addq	#1,a2	increase screen position
outline7	dbra	d6,outline2
	dbra	d7,outline1

	movem.l	(sp)+,d0-d7/a0-a6
	rts

outline8	add	#1,a0	inc all pointers
	add	#1,a4	if source byte = 0
	add	#1,a5
	add	#1,a3
	add	#1,a2
	add	#1,a1
	bra	outline7	and loop

;Calculate the x co-ord of next chr for kerning format
;ENTRY d0=x co-ord of last chr displayed
;      d4=x left limit of last chr displayed
;      d5=x left limit of next chr to be displayed
;      d6=ident of last chr displayed (0-224)
;      d7=ident of next chr to be displayed
;      a0=address of font buffer
;      (font_size)=divide factor for current font
;      (gap)=gap between chrs in pixels
;EXIT  d0=x co-ord of next chr to be displayed

calc_kern	movem.l	d1-d7/a0-a3,-(sp)

	add	#$2b4,a0	locate kerning tables
	lsl	#4,d6	d6*16
	move.l	a0,a1	copy to a1
	add	d6,a1	locate last chr kern data
	add	#8,a1	locate right side table
	
	lsl	#4,d7	d7*16
	add	d7,a0	locate next chr kern data
	
	move	#8-1,d7	8 iterations
	clr	d2	preset max value

calc_kern1	move.b	(a1),d3	fetch 1st chr value
	move.b	(a0),d6	fetch 2nd chr value
	and.l	#$ff,d3	clr high bytes
	and.l	#$ff,d6
	sub	d6,d3	calc difference
	bmi	calc_kern2	skip if negative
	cmp	d2,d3	compare with max
	ble	calc_kern2	skip if d3<=d2
	move	d3,d2	update max value
	move.l	a0,a2	save 2nd chr posn
	move.l	a1,a3	save 1st chr posn
calc_kern2	add	#1,a0	inc pointers
	add	#1,a1
	dbra	d7,calc_kern1	repeat for all values
	
	move.b	(a2),d3	fetch 2nd chr kern value
	and.l	#$ff,d3	mask high bits
	lsl	#6,d3	d3*64
	divu	font_size,d3	scale down
	
	move.b	(a3),d6	fetch 1st chr kern value
	and.l	#$ff,d6	mask high bits
	lsl	#6,d6	d6*64
	divu	font_size,d6	scale down
	
	sub	d4,d6	calc 1st chr diff
	sub	d5,d3	calc 2nd chr diff
	add	d6,d0	add diff to x co-ord
	sub	d3,d0	sub diff from x co-ord
	add	gap,d0	& add in gap value
	
	movem.l	(sp)+,d1-d7/a0-a3
	rts

;Clear chr image output buffer
;ENTRY (font_height)=height in scan lines
;      (char_width)=width in bytes
;      a1=start address of buffer
;EXIT  Buffer stores cleared to 0

clr_buffer	movem.l	d0/a1,-(sp)
	move	char_width,d0	fetch cell width
	mulu	font_height,d0	times cell height
	add	#8,d0	allow for header data
	lsr	#2,d0	divide by 4 for longs
clr_buffer1	clr.l	(a1)+	clr RAM
	dbra	d0,clr_buffer1	and repeat
	movem.l	(sp)+,d0/a1
	rts

;-------------------- Calamus internal sub-routines --------------

;This group of sub-routines are called by the main sub-routines and should 
;not normally need to be accessed by the programmer

;Check both ends of polyline for similar direction
;ENTRY (up_down)=0, =1 if current up, =2 if current down
;      (up_pointer) holds current up position
;      (down_pointer) holds current down position
;      (first_up) holds address of 1st entry in up list
;      (first_down) holds address of 1st entry in down list
;EXIT  last entry in up or down list erased if y co-ords same
;      (first_up) and (first_down) updated

end_poly	cmp	#1,up_down	chk direction
	beq	end_poly2
	move.l	down_pointer,a0	fetc pointer
	cmp.l	#down_list,a0
	beq	end_poly3	abort if no co-ord stored yet
	move.l	first_down,a1	fetch first down co-ord addr
	sub	#4,a0	chk prev
	move	(a0),d0	is first y co-ord
	cmp	(a1),d0	same as last ?
	bne	end_poly1	bra if not
	move.l	#-1,(a0)	mark end
	move.l	a0,down_pointer	update pointer
	bra	end_poly1
	
end_poly2	move.l	up_pointer,a0
	cmp.l	#up_list,a0
	beq	end_poly3
	move.l	first_up,a1
	sub	#4,a0
	move	(a0),d0
	cmp	(a1),d0
	bne	end_poly1
	move.l	#-1,(a0)
	move.l	a0,up_pointer
end_poly1	move.l	up_pointer,first_up
	move.l	down_pointer,first_down
end_poly3	rts

;Fill in character
;ENTRY (up_list..) holds up co-ords
;      (down_list) holds down co-ords
;      (chr_addr) holds address of 1st word
;      (char_width) holds chr width in bytes
;EXIT  character filled in
;      d0=0 if OK, else =3 if sorting error

fill_char	movem.l	d1-d2/a0-a2,-(sp)
	move	#3,d2	error code 3 (sort)
	lea	up_list,a1
	lea	down_list,a2
fill_char1	move.l	chr_addr,a0
	
	move	(a1)+,d0
	cmp	(a2)+,d0
	bne	fill_char2	abort if y co-ords diff
	mulu	char_width,d0
	add	d0,a0	a0=line addr
	move	(a1)+,d0	get 1st x co-ord
	move	(a2)+,d1	get 2nd x co-ord
	bsr	line_fill	fill in line
	cmp	#-1,(a1)
	bne	fill_char1	end of list ?
	clr	d2	no errors
fill_char2	move	d2,d0	fetch error code
	tst	d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts

;Draw bezier curve
;ENTRY b_table holds lookup table
;      bez_in+0 = x co-ord of start point
;      bez_in+2 = y co-ord of start point
;      bez_in+4 = x co-ord of 1st ctrl point
;      bez_in+6 = y co-ord of 1st ctrl point
;      bez_in+8 = x co-ord of 2nd ctrl point
;      bez_in+10 = y co-ord of 2nd ctrl point
;      bez_in+12 = x co-ord of end point
;      bez_in+14 = y co-ord of end point
;EXIT  Bezier line drawn in RAM buffer

draw_bezier	movem.l	d0-d7/a0-a6,-(sp)
	lea	b_table,a6	locate bez look-up table
	lea	bez_in,a5	locate co-ords data
	lea	poly_table,a4	locate polyline buffer
	move	#12,d0	set 12 points

draw_bezier1	bsr	bez_calc
	add	#16,a6	next table entry
	move.l	d1,d7	fetch x co-ord sif value
	swap	d7	convert sif to int
	move	d7,(a4)+	and store in array
	move.l	d2,d7	fetch y co-ord sif value
	swap	d7	convert sif to int
	move	d7,(a4)+	and store in array
	sub	#1,d0	dec points counter
	bne	draw_bezier1	repeat till zero
	move	#12,d0	set No of points
	bsr	poly_line	and draw curve
	movem.l	(sp)+,d0-d7/a0-a6
	rts

bez_calc	movem.l	a5-a6/d0/d6/d7,-(sp)

	move.l	#0,d1	d1 = 0.0 (*x)
	move.l	#0,d2	d2 = 0.0 (*y)

	move	#4-1,d0
bez_calc1	move	(a5)+,d7	calc x co-ord
	and.l	#$ffff,d7
	swap	d7	conv to sif
	move.l	(a6),d6
	bsr	lmul_sr
	move.l	d1,d6
	bsr	ladd_sr
	move.l	d7,d1	save x value
	
	move	(a5)+,d7	calc y co-ord
	and.l	#$ffff,d7
	swap	d7
	move.l	(a6)+,d6
	bsr	lmul_sr
	move.l	d2,d6
	bsr	ladd_sr
	move.l	d7,d2	save y value
	dbra	d0,bez_calc1	repeat * 4

	movem.l	(sp)+,a5-a6/d0/d6/d7
	rts

b_table	incbin	L:\ROUTINES\BEZ_TAB.DAT

;Draw a polyline
;ENTRY (poly_table..) holds list of co-ords
;      d0=Number of points to connect
;EXIT  Line drawn in RAM

poly_line	movem.l	d0-d4/a0,-(sp)
	lea	poly_table,a0
	move	d0,d4
	sub	#2,d4
	
	move	(a0)+,d0	fetch 1st point
	move	(a0)+,d1
poly_line1	move	(a0)+,d2	fetch next point
	move	(a0)+,d3
	bsr	plot_line	draw straight line
	move	d2,d0	set start point
	move	d3,d1
	dbra	d4,poly_line1	repeat
	
	movem.l	(sp)+,d0-d4/a0
	rts

;Draw line in RAM (with no clipping)
;ENTRY d0=x co-ord of 1st point
;      d1=y co-ord of 1st point
;      d2=x co-ord of 2nd point
;      d3=y co-ord of 2nd point
;EXIT  line drawn

plot_line	movem.l	d0-d7/a0-a1,-(sp)

	clr	direct	clr direction
	cmp	d1,d3	horizontal line ?
	beq	plot_line9	looks like it
	move	#1,direct	set to up
	move	#1,up_down
	cmp	d1,d3
	blt	plot_line9	skip if d3<d1
	move	#2,direct	must be going down
	move	#2,up_down
	
plot_line9	bclr	#31,d0	clr flag
	move.l	#1,a0	calc dx (end-start)
	move	d2,d4	and x step value
	sub	d0,d4
	bpl	plot_line1
	neg	d4	make positive
	move.l	#-1,a0	neg x step
plot_line1	move.l	#1,a1	calc dy (end-start)
	move	d3,d5	and y step value
	sub	d1,d5
	bpl	plot_line2
	neg	d5	make positive
	move.l	#-1,a1	neg y step
plot_line2	cmp	d5,d4	angle pos or neg
	bpl	plot_line8	yes
	exg	d4,d5	no so swap dx & dy
	bset	#31,d0	set flag
plot_line8	lsl	#1,d5	calc error1
	move	d5,d6	calc initial decision value
	sub	d4,d6
 	lsl	#1,d4	calc error2
	move	d5,d7
	sub	d4,d7
	exg	d4,d7
plot_line3	bsr	draw_pix	plot d0/d1
	bsr	fill_list
	cmp	d1,d3
	bne	plot_line6
	cmp	d0,d2	check end of line
	beq	plot_line4
plot_line6	tst	d6	chk decision + or -
	bpl	plot_line5
	add	d5,d6	update decision
	btst	#31,d0	pos/neg slope
	bne	plot_line7
	add	a0,d0	step x
	bra	plot_line3

plot_line5	add	d4,d6	update decision
	add	a0,d0	step x
plot_line7	add	a1,d1	step y
	bra	plot_line3
	
plot_line4	movem.l	(sp)+,d0-d7/a0-a1
	rts

;Draw one pixel on screen/RAM (Hi Rez)
;ENTRY d0=x co-ord
;      d1=y co-ord
;      (chr_addr) holds address of 1st byte
;      (char_width) holds width of chr in bytes
;EXIT  pixel plotted

draw_pix	movem.l	d0-d1,-(sp)
	move.l	chr_addr,a2	fetch start addr (chr_addr) ???
	mulu	char_width,d1	n bytes/line
	add	d1,a2	a2=line addr
	move	d0,d1	
	lsr	#3,d0
	add	d0,a2
	not	d1
	bset	d1,(a2)	set pixel
	movem.l	(sp)+,d0-d1
	rts

;Generate list of points for filling
;ENTRY (direct)= 0-Horizontal, 1-Up, 2-Down
;      d0=x co-ord
;      d1=y co-ord
;      (down_pointer)=down list buffer address
;      (up_pointer)=up list buffer address
;EXIT  co-ords stored in up or down list

fill_list	movem.l	d2/a0,-(sp)
	move	direct,d2	fetch current direction
	beq	fill_list3	exit if horizontal line
	move.l	up_pointer,a0
	cmp	#1,direct	use up_list if 1
	beq	fill_list1
	move.l	down_pointer,a0	use down list if 2
fill_list1	move	d1,(a0)	save y co-ord
	move	d0,2(a0)	save x co-ord

	cmp	last_dir,d2	skip if last dir<>current
	bne	fill_list5
	cmp	last_y,d1	skip if last y co-ord
	beq	fill_list2	equals current co-ord
fill_list5	add	#4,a0	else inc pointer

fill_list2	move	d1,last_y	save last y co-ord
	move	d2,last_dir	and its direction
	move.l	#-1,(a0)	mark end with -1
	cmp	#1,d2
	beq	fill_list4
	move.l	a0,down_pointer	restore down pointer
fill_list3	movem.l	(sp)+,d2/a0
	rts

fill_list4	move.l	a0,up_pointer	restore up pointer
	bra	fill_list3
	
;Fill in horizontal line between two points & calc lowest/highest x co-ords
;ENTRY d0=start pixel
;      d1=end pixel
;      a0=start address of line (buffer must be all 0s)
;      a4=addr of left offset in bit image header
;EXIT  all pixels between d0-d1 set to 1
;      (a4)=lowest x co-ord value
;      2(a4)=highest x co-ord value

line_fill	movem.l	d0-d5/a0,-(sp)
	cmp	d0,d1	test start > end
	bgt	line_fill5	skip if d0<d1
	exg	d0,d1	else swap registers
line_fill5	cmp	(a4),d0	is left pix<last val
	bge	line_fill6
	move	d0,(a4)	update left pix val
line_fill6	cmp	2(a4),d1	is right pix<last
	blt	line_fill7
	move	d1,2(a4)	update right pix val
line_fill7	cmp	d0,d1	exit if start=end
	beq	line_fill3
	move	d1,d3	save end pix
	move	d0,d2	save start pix
	lsr	#4,d0	divide start pix by 16
	lsl	#1,d0	locate word boundary
	add	d0,a0	locate byte address
	move	#$ffff,d4	set all pixels
	and	#15,d2	clear b4-15
	lsr	d2,d4	shift in 0s
	lsr	#4,d1	divide end pix by 16
	lsl	#1,d1	locate word boundary
	not	d3	calc No of 0s in last byte
	and	#15,d3	clear b4-15
	move	#$ffff,d5	set all pixels
	lsl	d3,d5	shift 0s into LSB

	sub	d0,d1	calc diff
	beq	line_fill1	skip if 0

	or	d4,(a0)	copy left word to RAM
	add	#2,a0	locate next word
	sub	#2,d1	any intermediate bytes ?
	beq	line_fill4	apparently not
line_fill2	or	#$ffff,(a0)+	fill in intermediate bytes
	sub	#2,d1	dec count
	bne	line_fill2	d1*2 times
line_fill4	or	d5,(a0)	copy right word to RAM
line_fill3	movem.l	(sp)+,d0-d5/a0
	rts

line_fill1	and	d5,d4	combine first/last
	or	d4,(a0)	and copy to RAM
	bra	line_fill3	and exit
	
;Sort list into order (array of longwords terminated with -1)
;ENTRY a0=start of list to sort (end of list=-1)
;EXIT  data sorted

sort_list	movem.l	d0-d2/a0-a1,-(sp)
	move.l	a0,a1	save a0
	clr.l	d4	init d4, count No elements
sort_list4	cmp.l	#-1,(a1)	end of list ?
	beq	sort_list5	yes so exit
	add	#4,a1	next element
	add	#1,d4	inc count
	bra	sort_list4	loop
		
sort_list5	move.l	a0,a1	save start addr
sort_list0	lsr	#1,d4	halve gap
	move	d4,d3	calc offset value
	lsl	#2,d3	and store in d3
sort_list1	clr	d2	clr flag
	move.l	a1,a0	restore start addr
sort_list2	move.l	(a0),d0	fetch 1st data
	move.l	(a0,d3),d1	fetch 2nd data
	cmp.l	d0,d1	compare data
	ble	sort_list3	skip if d1<=d0
	move.l	d0,(a0,d3)	swap data
	move.l	d1,(a0)	positions
	move	#1,d2	and set flag
sort_list3	add	#4,a0	inc pointer
	cmp.l	#-1,(a0,d3)	end of list ?
	bne	sort_list2	no
	tst	d2	was there a swap
	bne	sort_list1	yes so repeat
	cmp	#1,d4	repeat until
	bne	sort_list0	gap=1
	movem.l	(sp)+,d0-d2/a0-a1
	rts

;     --------------------- SIF Routines -----------------------

;Sign-Integer-Fraction routines required by the Bezier curve routines
;as published in ICTARI Issue 14. As these are the same they can be
;omitted if these routines are being used elsewhere in the user program.

infinity	equ	$80000000

;SIF add S/R

ladd_sr	cmp.l	#infinity,d7
	beq	ladd_sr1
	cmp.l	#infinity,d6
	beq	ladd_sr2
	add.l	d6,d7
	bvc	ladd_sr1
ladd_sr2	move.l	#infinity,d7
ladd_sr1	rts

;SIF multiply S/R

lmul_sr	movem.l	d3-5,-(a7)	save registers
	clr.w	d3	clear sign
	tst.l	d7
	bpl	lmul_sr1
	neg.l	d7
	bmi	lmul_sr3	d7 = infinity
	eori.w	#1,d3	d7 negative
lmul_sr1	tst.l	d6
	bpl	lmul_sr2
	neg.l	d6
	bmi	lmul_sr3	d6 = infinity
	eori.w	#1,d3	d6 negative
lmul_sr2	move.l	d7,d5	copy num_2
	move.l	d7,d4	 and again
	mulu	d6,d7	frac_2 * frac_1
	addi.l	#$00008000,d7	roundoff result
	clr.w	d7	forget least signif word
	swap	d7	shift right 16 times
	swap	d5	access int_2
	mulu	d6,d5	int_2 * frac_1
	add.l	d5,d7	add to result
	swap	d6	access int_1
	move.l	d4,d5	copy num_2
	mulu	d6,d5	frac_2 * int_1
	add.l	d5,d7	add to result
	swap	d4	access int_2
	mulu	d6,d4	int_2 * int_1
	swap	d4	shift left 16 times
	tst.w	d4	word <> 0 means overflow
	bne	lmul_sr3
	add.l	d4,d7	result
	bmi	lmul_sr3	overflow if bit #31 set
	tst.w	d3	sign
	beq	lmul_sr4	= 0 positive result
	neg.l	d7	<> 0 negative
	bra	lmul_sr4

lmul_sr3	move.l	#infinity,d7
lmul_sr4	movem.l	(a7)+,d3-5	restore registers
	rts		and return

	section	DATA
	
;Typical bit patterns for the 'pattern' sub-routine

pattern_1	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa
	dc.w	$5555
	dc.w	$aaaa

pattern_2	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%0000000000000000
	dc.w	%1111111111111111

	section	BSS
	
;  --------------- Calamus Font Routine stores -------------

base_line	ds.w	1	base line offset
bez_in	ds.w	2*8	bezier input values
chr_addr	ds.l	1	address of current chr
char_width	ds.w	1	width of chr (bytes)
direct	ds.w	1	line direction
down_pointer	ds.l	1	addr of down pointer
first_down	ds.l	1	addr of first down point
first_up	ds.l	1	addr of first up point
font_height	ds.w	1	height of font in scanlines
font_size	ds.w	1	font size
font_width	ds.w	1	width of chr (pixels)
gap	ds.w	1	chr gap (pixels)
last_y	ds.w	1	last y co-ord
last_dir	ds.w	1	last direction used
max_ram	ds.l	1	address of last image RAM
max_width	ds.w	1	width of widest chr (pix)
chr_count	ds.w	1	No of used chrs in font
poly_table	ds.b	64	polyline table
t_edge	ds.w	1	top edge offset
up_down	ds.w	1	up/down flag
up_pointer	ds.l	1	addr of up pointer
srce_mfdb	ds.w	20	source MFDB
dest_mfdb	ds.w	20	destination MFDB

ca_table	ds.l	224	chr addr table ($20-$ff)
up_list	ds.b	50000	up list ??
down_list	ds.b	50000	down list ??
img_buff	ds.b	100000	bit images ??

