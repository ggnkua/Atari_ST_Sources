
	public _sin_tab


	;	rot_points(theta, source, dest, count)
	;		returns source point rotated byt theta in dest
	public	_rot_points
firstp	set	4+4*4
theta	set firstp
source	set	firstp+2
dest	set firstp+6
count	set firstp+10
_rot_points
	movem.l	d3/d4/d5/d6,-(sp)
	move.w	theta(sp),d0
	and.w	#$3ff,d0	; mod theta by two-pi = 1024
	move.l	#_sin_tab,a0	; load up sine table

	move.l	#quadtable,a1	; and jump to routine to get sine, cos for quadrant
	move.w	d0,d1
	and.w	#$300,d1
	lsr.w	#6,d1
	move.l	0(a1,d1.w),a1
	jsr		(a1)			; sine now in d0, cos in d1

	move.l	source(sp),a0
	move.l	dest(sp),a1
	move.w	count(sp),d2
	bra		zrp_loop
rp_loop
	move.w	(a0)+,d3
	move.w	(a0)+,d4

	move.w	d3,d5
	muls	d1,d5
	asl.l	#2,d5
	swap	d5 
	move.w	d4,d6
	muls	d0,d6
	asl.l	#2,d6
	swap	d6
	add.w	d5,d6
	move.w	d6,(a1)+	; d->x = itmult(x,co) + itmult(y,si)

	muls	d1,d4
	asl.l	#2,d4
	swap	d4
	neg.w	d3
	muls	d0,d3
	asl.l	#2,d3
	swap	d3
	add.w	d4,d3
	move.w	d3,(a1)+ 	; d->y = itmult(y,co) + itmult(x,-si)

zrp_loop	dbra	d2,rp_loop
	movem.l	(sp)+,d3/d4/d5/d6
	rts

	;	isin(theta)
	;		returns scaled integer sine of theta
	public _isin
_isin
	bsr isincos
	rts

	public _icos
_icos
	bsr isincos
	move.w d1,d0
	rts


isincos
	move.w	8(sp),d0
	and.w	#$3ff,d0	; mod theta by two-pi = 1024
	move.l	#_sin_tab,a0	; load up sine table

	move.l	#quadtable,a1	; and jump to routine to get sine, cos for quadrant
	move.w	d0,d1
	and.w	#$300,d1
	lsr.w	#6,d1
	move.l	0(a1,d1.w),a1
	jsr		(a1)
	rts


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
	add.w	d1,d1
	move.w	0(a0,d1.w),d1	;got cosine
	add.w	d0,d0
	move.w	0(a0,d0.w),d0	;got sine
	rts

quad2
	move.w	d0,d1
	neg.w	d0
	add.w	#512,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0	;got sine
	sub.w	#256,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1	
	neg.w	d1	; got cosine
	rts

quad3
	move.w #3*256,d1
	sub.w	d0,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1	
	neg.w	d1	; got cosine
	sub.w	#512,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0	
	neg.w	d0	; got sine
	rts

quad4
	move.w	d0,d1
	sub.w	#3*256,d1
	add.w	d1,d1
	move.w	0(a0,d1.w),d1	; got cosine
	neg.w	d0
	add.w	#1024,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	neg.w	d0	;got sine
	rts

	dseg
quadtable	dc.l	quad1,quad2,quad3,quad4
