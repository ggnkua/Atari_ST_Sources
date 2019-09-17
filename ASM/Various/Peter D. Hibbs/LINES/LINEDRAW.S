;Draw line, mode 1 (no clipping)
;ENTRY d0=x co-ord of 1st point x1
;      d1=y co-ord of 1st point y1
;      d2=x co-ord of 2nd point x2
;      d3=y co-ord of 2nd point y2
;      (colour)=colour index (0-15)
;      (screen)=screen address
;EXIT  Line drawn, no regs changed

line1	movem.l	d0-d7/a0-a1,-(sp)
	bclr	#31,d0	clr flag
	move.l	#1,a0	calc dx (end-start)
	move	d2,d4	and x step value
	sub	d0,d4
	bpl	line1_1
	neg	d4	make positive
	move.l	#-1,a0	neg x step

line1_1	move.l	#1,a1	calc dy (end-start)
	move	d3,d5	and y step value
	sub	d1,d5
	bpl	line1_2
	neg	d5	make positive
	move.l	#-1,a1	neg y step

line1_2	cmp	d5,d4	angle pos or neg
	bpl	line1_8	yes
	exg	d4,d5	no so swap dx & dy
	bset	#31,d0	set flag
line1_8	lsl	#1,d5	calc error1

	move	d5,d6	calc initial decision value
	sub	d4,d6
	
 	lsl	#1,d4	calc error2
	move	d5,d7
	sub	d4,d7
	exg	d4,d7

line1_3	bsr	draw_pix	plot d0/d1
	cmp	d1,d3
	bne	line1_6
	cmp	d0,d2	check end of line
	beq	line1_4
line1_6	tst	d6	chk decision + or -
	bpl	line1_5
	add	d5,d6	update decision
	btst	#31,d0	pos/neg slope
	bne	line1_7
	add	a0,d0	step x
	bra	line1_3

line1_5	add	d4,d6	update decision
	add	a0,d0	step x
line1_7	add	a1,d1	step y
	bra	line1_3
	
line1_4	movem.l	(sp)+,d0-d7/a0-a1
	rts

;Draw line, mode 2 (no clipping)
;ENTRY d0=x co-ord of 1st point x1
;      d1=y co-ord of 1st point y1
;      d2=x co-ord of 2nd point x2
;      d3=y co-ord of 2nd point y2
;      (colour)=colour index (0-15)
;      (screen)=screen address
;EXIT  Line drawn, no regs changed

line2	movem.l	d0-d6/a0-a1,-(sp)
	clr	d6
	move	#1,a0
	move	#1,a1
	move	d2,d4
	sub	d0,d4
	bpl	line2_1
	neg	d4
	move	#-1,a0
line2_1	move	d3,d5
	sub	d1,d5
	bpl	line2_2
	neg	d5
	move	#-1,a1
line2_2	tst	d5
	bne	line2_3
	move	#-1,d6
line2_3	bsr	draw_pix
	cmp	d0,d2
	bne	line2_4
	cmp	d1,d3
	beq	line2_6
line2_4	tst	d6
	bmi	line2_5
	add	a1,d1
	sub	d4,d6
	bra	line2_3
	
line2_5	add	a0,d0
	add	d5,d6
	bra	line2_3
	
line2_6	movem.l	(sp)+,d0-d6/a0-a1
	rts

;Draw one pixel on screen
;ENTRY d0=x co-ord
;      d1=y co-ord
;      (colour)=colour index (0-15)
;      (screen)=screen address
;EXIT  Pixel plotted, no regs changed

draw_pix	movem.l	d0-d3/a0,-(sp)
	move.l	screen,a0	fetch screen start addr
	mulu	#160,d1	multiply screen with (bytes) by y co-ord
	add	d1,a0	calc screen addr for pixel
	move	d0,d1
	lsr	#4,d0
	lsl	#3,d0	low rez=*8, med rez=*4
	add	d0,a0
	not	d1
	and	#$f,d1	calc pixel offset
	move	colour,d0	fetch colour index
	clr	d2
	bset	d1,d2
	move	d2,d3
	not	d3
	move	#4-1,d1	4 planes for low rez
draw_pixl1	lsr	#1,d0	
	bcs	draw_pixl3
	and	d3,(a0)+	write 0 to screen
draw_pixl2	dbra	d1,draw_pixl1	repeat for each plane
	movem.l	(sp)+,d0-d3/a0
	rts

draw_pixl3	or	d2,(a0)+	write 1 to screen
	bra	draw_pixl2
