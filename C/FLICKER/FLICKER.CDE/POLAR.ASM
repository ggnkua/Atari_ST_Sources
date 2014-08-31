
	public _sin_tab



	;	polar(theta, rad, xybuf)
	;		returns cartesian equivalent to theta, rad in xybuf	
	public _polar

_polar
	move.w	4(sp),d0
	and.w	#$3ff,d0	; mod theta by two-pi = 1024
	move.l	#_sin_tab,a0	; load up sine table

	move.l	#quadtable,a1	; and jump to routine to get sine, cos for quadrant
	move.w	d0,d1
	and.w	#$300,d1
	lsr.w	#6,d1
	move.l	0(a1,d1.w),a1
	jsr		(a1)

	muls	6(sp),d0
	asl.l #2,d0
	swap d0 
	muls	6(sp),d1
	asl.l #2,d1
	swap d1 
	move.l	8(sp),a0
	move.w	d1,(a0)+
	move.w	d0,(a0)
	rts

quad1
	move.w	#256,d1
	sub.w	d0,d1
	asl.w	#1,d1
	move.w	0(a0,d1.w),d1	;got cosine
	asl.w	#1,d0
	move.w	0(a0,d0.w),d0	;got sine
	rts

quad2
	move.w	d0,d1
	neg.w	d0
	add.w	#512,d0
	asl.w	#1,d0
	move.w	0(a0,d0.w),d0	;got sine
	sub.w	#256,d1
	asl.w	#1,d1
	move.w	0(a0,d1.w),d1	
	neg.w	d1	; got cosine
	rts

quad3
	move.w #3*256,d1
	sub.w	d0,d1
	asl.w	#1,d1
	move.w	0(a0,d1.w),d1	
	neg.w	d1	; got cosine
	sub.w	#512,d0
	asl.w	#1,d0
	move.w	0(a0,d0.w),d0	
	neg.w	d0	; got sine
	rts

quad4
	move.w	d0,d1
	sub.w	#3*256,d1
	asl.w	#1,d1
	move.w	0(a0,d1.w),d1	; got cosine
	neg.w	d0
	add.w	#1024,d0
	asl.w	#1,d0
	move.w	0(a0,d0.w),d0
	neg.w	d0	;got sine
	rts

	dseg
quadtable	dc.l	quad1,quad2,quad3,quad4
