* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*			core_03.s                                 *
* 		Subroutines for Part 4                            *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include	core_02.s		all the previous subroutines

sincos:
* The sine and cosine of an angle are found.
* The sintable covers the positive quadrant 0 to 90 degrees
* and can be used to generate any sine or cosine in the range 0 to 360 
* Entry: angle in degrees in d1
* Returns: sine in d2, cosine in d3
	lea	sintable,a5	pointer to the table base
	cmp	#360,d1		test(angle-360)
	bmi	less360		it's < 360
	sub	#360,d1		make it less than 360 degrees
less360	cmp	#270,d1		test(angle-270)
	bmi	less270		it's < 270
	bsr	over270		angle is over or equal to 270
	rts
less270	cmp	#180,d1		test(angle-180)
	bmi	less180		it's < 180
	bsr	over180		angle is over or equal to 180
	rts
less180	cmp	#90,d1		test(angle-90)
	bmi	less90		it's < 90
	bsr	over90		angle is over or equal to 90
	rts
less90	add	d1,d1		*2 for offset into table for sine
	move.w	0(a5,d1.w),d2	the sine
	subi	#180,d1		cos(angle) = sin(90-angle)
	neg	d1		offset into table for cosine
	move.w	0(a5,d1.w),d3	the cosine
	rts
over270	subi	#360,d1
	neg	d1		360 - angle
	add	d1,d1		*2 for offset
	move.w	0(a5,d1.w),d2
	neg	d2		the sine
	subi	#180,d1
	neg	d1		offset for cosine
	move.w	0(a5,d1.w),d3
	rts
over180	subi	#180,d1		angle-180
	add	d1,d1		*2 for offset
	move.w	0(a5,d1.w),d2
	neg	d2		the sine
	subi	#180,d1
	neg	d1		offset for cosine
	move.w	0(a5,d1.w),d3	
	neg.w	d3		the cosine
	rts
over90	subi	#180,d1		angle-180
	neg	d1
	add	d1,d1		*2 for offset
	move.w	0(a5,d1.w),d2	the sine
	subi	#180,d1
	neg	d1		offset for cosine
	move.w	0(a5,d1.w),d3
	neg	d3		the cosine
	rts


otranw:
* This is the subroutine for transforming object coords to world coords.
* It includes rotations determined by otheta, ophi and ogamma about the
* world axes wx,wy and wz and a displacement of Oox, Ooy and Ooz relative
* to the world origin.
* PART 1.
* The matrix for the rotations is constructed.
* Convert object rotation angles to sin & cos and store for rot. matrix
	move.w	otheta,d1	 theta
	bsr	sincos
	move.w	d2,stheta	store for matrix
	move.w	d3,ctheta
	move.w	ophi,d1		 phi
	bsr	sincos
	move.w	d2,sphi
	move.w	d3,cphi
	move.w	ogamma,d1	 gamma
	bsr	sincos
	move.w	d2,sgamma
	move.w	d3,cgamma

* Construct the transform matrix otranw remember, all elements end up *2^14
	lea	stheta,a0	sin theta
	lea	ctheta,a1	cos theta 
	lea	sphi,a2		sin phi
	lea	cphi,a3		cos phi
	lea	sgamma,a4	sin gamma
	lea	cgamma,a5	cos gamma
	lea	o_wmatx,a6	the matrix
* do element OM11
	move.w	(a3),d0		cphi		
	muls	(a5),d0		cphi x cgamma
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,(a6)+	OM11	
* do OM12
	move.w	(a3),d0		cphi
	muls	(a4),d0		cphi x sgamma
	neg.l	d0		 _  "
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,(a6)+	OM12	
* do OM13
	move.w	(a2),(a6)+	sphi
* do OM21	
	move.w	(a1),d0		ctheta
	muls	(a4),d0		ctheta x sgamma
	move.w	(a0),d1		stheta
	muls	(a2),d1		stheta x sphi
	lsl.l	#2,d1
	swap	d1
	muls	(a5),d1		stheta x sphi x cgamma
	add.l	d1,d0	stheta x sphi x cgamma + ctheta x sgamma
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+		
* do OM22
	move.w	(a1),d0		ctheta
	muls	(a5),d0		ctheta x cgamma
	move.w	(a0),d1		stheta
	muls	(a2),d1		stheta x sphi
	lsl.l	#2,d1
	swap	d1
	muls	(a4),d1		stheta x sphi x sgamma
	sub.l	d1,d0	ctheta x cgamma - stheta x sphi x sgamma
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+
* do OM23
	move.w	(a0),d0		stheta
	muls	(a3),d0		stheta x cphi
	neg.l	d0		_ "
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+
* do OM31
	move.w	(a0),d0		stheta
	muls	(a4),d0		stheta x sgamma
	move.w	(a1),d1		ctheta
	muls	(a2),d1		ctheta x sphi
	lsl.l	#2,d1
	swap	d1
	muls	(a5),d1		ctheta x sphi x cgamma
	sub.l	d1,d0	stheta x sgamma - ctheta x sphi x cgamma
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+
* do OM32
	move.w	(a0),d0		stheta
	muls	(a5),d0		stheta x cgamma
	move.w	(a1),d1		ctheta
	muls	(a2),d1		ctheta x sphi
	lsl.l	#2,d1
	swap	d1
	muls	(a4),d1		ctheta x sphi x sgamma
	add.l	d1,d0
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+		" + stheta x cgamma
* d0 OM33
	move.w	(a1),d0		ctheta
	muls	(a3),d0		ctheta x cphi
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+
* PART 2
* now the object coords are transformed to world coords
* Remember matrix elements are *2^14 and must be corrected at the end
	move.w	oncoords,d7	the number
	ext.l	d7		any to do ?
	beq	otranw3		if not quit
	subq.w	#1,d7		or this is the count

	lea	ocoordsx,a0	the
	lea	ocoordsy,a1	source
	lea	ocoordsz,a2	coords.
	lea	wcoordsx,a3	the
	lea	wcoordsy,a4	destination
	lea	wcoordsz,a5
	exg	a3,d3		save this address-shortage of regs.
	link	a6,#-6		3 words to store
otranw1:
	moveq.l	#2,d6		3 rows in the matrix
	lea	o_wmatx,a3	init matx pointer
* calculate the next wx, wy and wz
otranw2:
	move.w	(a0),d0		 ox
	move.w	(a1),d1		 oy
	move.w	(a2),d2		 oz

	muls	(a3)+,d0	ox*Mi1
	muls	(a3)+,d1	oy*Mi2
	muls	(a3)+,d2	oz*Mi3

	add.l	d1,d0
	add.l	d2,d0
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,-(a6)	save it
	dbf	d6,otranw2	repeat for 3 elements
	
	move.w	(a6)+,d0	off my stack
	add.w	Ooz,d0		add the displacement
	move.w	d0,(a5)+	becomes wz
	move.w	(a6)+,d0		
	add.w	Ooy,d0
	move.w	d0,(a4)+	becomes wy
	exg	a3,d3		restore address wx, save matx pointr
	move.w	(a6)+,d0	
	add.w	Oox,d0
	move.w	d0,(a3)+	becomes wx
	exg	a3,d3		save address wx, restore matx pointr
	addq.l	#2,a0		point to next ox
	addq.l	#2,a1				oy
 	addq.l	#2,a2				oz

	dbf	d7,otranw1	repeat for all ocoords
	unlk	a6		close frame
otranw3	rts			and quit

scan_keys:
* See if a key has been pressed
scn_lp	move.w	#2,-(sp)	has a key
	move.w	#1,-(sp)	been pressed
	trap	#13		BIOS call CONSTAT - wait for it
	addq.l	#4,sp		tidy stack
	rts
hide_mse:
*exterminate the mouse
	dc.w	$a00a
	rts
