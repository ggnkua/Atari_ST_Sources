;	:ts=10


	;add_sysources(thread, segment)
	;	add the source y position to segment  
	public _add_sysources
firstp	set	5*4+4
thread	set	firstp
segment	set	firstp+4
_add_sysources
	movem.l	d3/d4/d5/d6/d7,-(sp)
	move.l	thread(sp),a0
	move.l	segment(sp),a1
	move.w	(a0)+,d2	;get count of elt's in thread

hloop	
	subq.w	#1,d2
	beq	zadd_sources	; here there's nothing but horizontals.
	move.w	6(a0),d0
	cmp.w	2(a0),d0
	bne	past_hor
	adda.w	#4,a0
	bra 	hloop
past_hor
	move.w	18(a0),(a1)	; set y of first point
	add.w	#12,a1		; go to next segment
	bra 	zlineloop

lineloop
	move.w	6(a0),d0
	sub.w	2(a0),d0		; set up dest height in d0
	beq	nextsource 	; skip to next line if it's horizontal

	move.w	18(a0),d1	; get y0 of source
	move.w	d1,d4

calcdy
	move.w	#1,d6	; what to add to position when stepping y
	sub.w	22(a0),d1	; and subtract y1 of source
	bmi	init_errors ; d1 gets -|y1-y0| and adjust step y if positive
	neg.w	d1
	neg.w	d6
init_errors
	move.w	d0,d5	;    set up count register
	addq.w	#1,d0	;    since missing first sample

	move.w	d0,d3	; see if # of samples to take greater than dy
	add.w	d1,d3
	bpl	moresamples
	move.w	#1,d3
	subq.w	#1,d0
	addq.w	#1,d1
	bra	pasterrs
moresamples
	move.w	d1,d3
	asr.w	#1,d3
	add.w	d0,d3	;    yerr = -dy/2 + samples
pasterrs

	subq.w	#1,d1	;    line between 0 and 2 has 3 pixels...
	bra	zinnerlp
innerlp
	add.w	d1,d3
	bgt	znexty
nexty	add.w	d6,d4
	add.w	d0,d3
	ble	nexty
znexty
moveit
	move.w	d4,(a1)	; store y position in output array
	add.w	#12,a1	; total of 12 bytes in each element of segment
zinnerlp dbra	d5,innerlp


nextsource adda.w	#4,a0
zlineloop	dbra	d2,lineloop

zadd_sources
	movem.l	(sp)+,d3/d4/d5/d6/d7
	rts



