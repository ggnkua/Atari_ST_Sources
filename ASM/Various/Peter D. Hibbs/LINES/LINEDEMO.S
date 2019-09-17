;Low Rez line drawing demo program.
;Draws a coloured line between two
;randomly selected points on screen
;each time a key is pressed. Press
;ESCAPE to exit program. Each time
;a line is drawn the line draw mode
;is toggled between mode 1 and 2 and
;the next colour index is used.


	ttl	'LINE DRAWING DEMO PROGRAM.  P D Hibbs  Jan 96'

	include	tosmacro.s	  TOS macros (Ictari 9)
	
;The program

start	move.l	4(sp),a3	base page
	move.l	#stack,sp	move SP
	move.l	12(a3),d0	text len
	add.l	20(a3),d0	data len
	add.l	28(a3),d0	BSS len
	add.l	#256,d0	basepage

	move.l	d0,-(sp)	shrink memory
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	bsr	main	run main program

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm


;----- Main program sub-routine -------

main	logbase		fetch screen addr
	move.l	d0,screen	& save in (screen)

	setpalette	#palette	set palette colours
	
	c_conout	#27	clr screen
	c_conout	#'E'

main2	add	#1,colour	inc colour code

	bsr	rnd_scale	generate random co-ords
	dc.l	1,199
	move	d0,d1	point y1
	
	bsr	rnd_scale	generate random co-ords
	dc.l	1,319
	move	d0,d2	point x2
	
	bsr	rnd_scale	generate random co-ords
	dc.l	1,199
	move	d0,d3	point y2
	
	bsr	rnd_scale	generate random co-ords
	dc.l	1,199	point x1

	bchg	#0,flag	toggle flag
	beq	main1	skip if 0
	bsr	line1	use line mode 1
	
main3	bconin	#2	chk keybrd
	cmp	#27,d0
	bne	main2	repeat if not ESCape
	rts

main1	bsr	line2	use line mode 2
	bra	main3
	
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
	move.l	screen,a0
	mulu	#160,d1	
	add	d1,a0
	move	d0,d1
	lsr	#4,d0
	lsl	#3,d0	low=3
	add	d0,a0
	not	d1
	and	#$f,d1
	move	colour,d0
	clr	d2
	bset	d1,d2
	move	d2,d3
	not	d3
	move	#4-1,d1
draw_pixl1	lsr	#1,d0
	bcs	draw_pixl3
	and	d3,(a0)+
draw_pixl2	dbra	d1,draw_pixl1
	movem.l	(sp)+,d0-d3/a0
	rts

draw_pixl3	or	d2,(a0)+
	bra	draw_pixl2
	
;  ------ Library Routines --------

;Return random number within specified range
;ENTRY Inline data specify range (lowest - highest)
;EXIT  d0.w=16 bit value in specified range

rnd_scale	movem.l	a0/d1-d4,-(sp)	save registers

	move.l	20(sp),a0	# fetch return address
	move.l	(a0)+,d0	# copy low limit to d0
	move.l	(a0)+,d1	# copy high limit to d1
	
	move	d0,d2	copy d0 to d2
	sub	d0,d1	calculate difference
	addq	#1,d1	correct d1
	move	d1,d3	and copy to d3
	move	#17,d4	calculate number of bits
rnd_scale1	subq	#1,d4	dec d4
	lsl	#1,d3	shift high bit to Cy
	bcc	rnd_scale1	jump if bit=0

	clr.l	d0	* generate 16 bit random No
	move	seed,d0	* fetch last seed
	mulu	#58653,d0	* multiply by 58653
	add	#13849,d0	* add 13849
	move	d0,seed	* restore seed

	lsr	d4,d0	shift right d4 times
	mulu	d1,d0	multiply by high limit
	neg	d4
	add	#16,d4	calculate shift value
	lsr.l	d4,d0	shift right d4 times
	add	d2,d0	add difference
	
	move.l	a0,20(sp)	# restore return address

	movem.l	(sp)+,a0/d1-d4	restore registers
	rts		return
		
	SECTION	data	global constants

palette	dc.w	$0000,$0700,$0730,$0750,$0770,$0470,$0070,$0075
	dc.w	$0077,$0057,$0027,$0007,$0507,$0707,$0704,$0777

	SECTION	bss

screen	ds.l	1	screen address
colour	ds.w	1	pixel colour
seed	ds.w	1	random seed
flag	ds.b	1	toggle flag
dummy 	ds.b	1	not used

	ds.l	100	stack space (400 bytes)
stack	ds.w	1	(stacks go backwards)

