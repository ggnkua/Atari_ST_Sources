* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 core_05.s                                  *
* 		Subroutines for Part 6                              *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	include	core_04.s		previous subroutines
	include core_03.s

* A set of subroutines for transforming world coords. including
* rotations of about the x, y and z axes, and a shear.

* The matrix for the rotations is constructed.
* First convert rotation angles to sin & cos and store for rot. matrix
wtranv_1:
	bsr	view_trig	find the sines and cosines
* Construct the transform matrix wtranv remember, all elements end up *2^14
	lea	stheta,a0	sin theta
	lea	ctheta,a1	cos theta 
	lea	sphi,a2		sin phi
	lea	cphi,a3		cos phi
	lea	sgamma,a4	sin gamma
	lea	cgamma,a5	cos gamma
	lea	w_vmatx,a6	the matrix
* do element WM11
	move.w	(a3),d0		cphi		
	muls	(a5),d0		cphi x cgamma
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,(a6)+	WM11	
* do WM12
	move.w	(a1),d0		ctheta
	muls	(a4),d0		ctheta x sgamma
	move.w	(a0),d1		stheta
	muls	(a2),d1		stheta x sphi
	lsl.l	#2,d1
	swap	d1
	muls	(a5),d1		stheta x sphi x cgamma
	add.l	d0,d1	stheta x sphi x cgamma + ctheta x sgamma
	lsl.l	#2,d1
	swap	d1
	move.w	d1,(a6)+
* do WM13
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
* do WM21	
	move.w	(a3),d0		cphi
	muls	(a4),d0		ctheta x sgamma
	lsl.l	#2,d0
	swap	d0		/2^14
	neg	d0
	move.w	d0,(a6)+		
* do WM22
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
* do WM23
	move.w	(a0),d0		stheta
	muls	(a5),d0		stheta x cgamma
	move.w	(a1),d1		ctheta
	muls	(a2),d1		ctheta x sphi
	lsl.l	#2,d1
	swap	d1
	muls	(a4),d1		ctheta x sphi x sgamma
	add.l	d0,d1
	lsl.l	#2,d1
	swap	d1
	move.w	d1,(a6)+		" +stheta x cgamma
* do WM31
	move.w	(a2),(a6)+
* do WM32
	move.w	(a3),d0		cphi
	muls	(a0),d0		cphi*stheta
	lsl.l	#2,d0
	swap	d0		/2^14
	neg	d0		-
	move.w	d0,(a6)+
* d0 WM33
	move.w	(a1),d0		ctheta
	muls	(a3),d0		ctheta x cphi
	lsl.l	#2,d0
	swap	d0
	move.w	d0,(a6)+
	rts
* PART 2
* Now the world coords are transformed to view coords
* Remember matrix elements are *2^14 and must be corrected at the end
wtranv_2:
	move.w	wncoords,d7	the number
	ext.l	d7		any to do ?
	beq	wtranv3		if not quit
	subq.w	#1,d7		or this is the count

	lea	wcoordsx,a0	the
	lea	wcoordsy,a1	source
	lea	wcoordsz,a2	coords.
	lea	vcoordsx,a3	the
	lea	vcoordsy,a4	destination
	lea	vcoordsz,a5
	exg	a3,d3		save this address-short of regs.
	link	a6,#-6		3 words to store
wtranv1:
	moveq.l	#2,d6		3 rows in the matrix
	lea	w_vmatx,a3	init matx pointer
* calculate the next wx, wy and wz
wtranv2:
	move.w	(a0),d0		wx
	move.w	(a1),d1		wy
	move.w	(a2),d2		wz

	sub.w	#50,d0		wx-50
	sub.w	#50,d1		wy-50
	sub.w	#50,d2		wz-50

	muls	(a3)+,d0	wx*Mi1
	muls	(a3)+,d1	wy*Mi2
	muls	(a3)+,d2	wz*Mi3

	add.l	d1,d0
	add.l	d2,d0		wx*Mi1+wy*Mi2+wz*Mi3
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,-(a6)	save it
	dbf	d6,wtranv2	repeat for 3 elements
	
	move.w	(a6)+,d0	off my stack
	add.w	Ovz,d0
	move.w	d0,(a5)+	becomes vz
	move.w	(a6)+,(a4)+		
	exg	a3,d3		restore address vx, save matx pointr
	move.w	(a6)+,d0	
	add.w	#100,d0
	move.w	d0,(a3)+	becomes vx
	exg	a3,d3		save address vx, restore matx pointr
	addq.l	#2,a0		point to next wx
	addq.l	#2,a1			      wy
 	addq.l	#2,a2			      wz

	dbf	d7,wtranv1	repeat for all ocoords
	unlk	a6		close frame
wtranv3	rts			and quit
* Calculate the sines and cosines of view angles
view_trig:
	move.w	vtheta,d1	theta
	bsr	sincos
	move.w	d2,stheta	sine
	move.w	d3,ctheta	cosine
	move.w	vphi,d1		phi
	bsr	sincos
	move.w	d2,sphi
	move.w	d3,cphi
	move.w	vgamma,d1	gamma
	bsr	sincos
	move.w	d2,sgamma
	move.w	d3,cgamma
	rts

angle_update:
*Check the limits
	move.w	vtheta_inc,d0
	bmi	vth_neg
	beq	chk_phi
	subq.w	#1,vtheta_inc
	cmp.w	#25,vtheta_inc
	ble	chk_phi
	move.w	#25,vtheta_inc
	bra	chk_phi
vth_neg	addq.w	#1,vtheta_inc
	cmp.w	#-25,vtheta_inc
	bge	chk_phi
	move.w	#-25,vtheta_inc
chk_phi	move.w	vphi_inc,d0
	bmi	vph_neg
	beq	chk_out
	subq.w	#1,vphi_inc
	cmp.w	#25,vphi_inc
	ble	chk_out
	move.w	#25,vphi_inc
	bra	chk_out
vph_neg	addq.w	#1,vphi_inc
	cmp.w	#-25,vphi_inc
	bge	chk_out
	move.w	#-25,vphi_inc
chk_out	


* update vtheta
	move.w	vtheta,d0	the previous angle
	add.w	vtheta_inc,d0	increase it by the increment
	bgt	thta_1		check it  
	add	#360,d0		lies 
	bra	thta_2		between zero
thta_1	cmp.w	#360,d0		and 360 degrees
	blt	thta_2
	sub	#360,d0
thta_2:
	move.w	d0,vtheta	becomes the current angle
* update vphi
	move.w	vphi,d0		similarly for vphi
	add.w	vphi_inc,d0
	bgt	phi_1
	add	#360,d0
	bra	phi_2
phi_1	cmp.w	#360,d0
	blt	phi_2
	sub	#360,d0
phi_2:
	move.w	d0,vphi
	rts	

key_in:
* Read the keyboard
	bsr	scan_keys	was a key pressed?
	cmp.w	#-1,d0
	beq	key_read	yes
	rts			no
key_read:
	bsr	read_key	which key?
	tst.w	d0		f keys have $0 in the low word
	beq	key_rpt		only interested if f keys
	rts			something else
key_rpt	swap	d0		the code
	sub	#$3b,d0		f1 is 3b : set it to zero for offset
	and	#7,d0		first 7 f keys
	lea	key_jump,a0	jump table
	lsl.w	#2,d0		key code is offset
	move.l	0(a0,d0.w),a0	to the routine address
	jmp	(a0)		go for it
key_jump:
* The jump table for f keys
	dc.l	f1,f2,f3,f4,f5,f6,f7
f1	move.w	#-1,speed	reverse
	rts
f2	move.w	#1,speed	forward 
	rts
f3	addq.w	#2,vtheta_inc	rotate left
	rts
f4	addq.w	#2,vphi_inc	rotate down
	rts
f5	bchg.b	#0,shearflg	toggle shear flag
	rts
f6	move.w	#0,speed	stop
	rts
f7	bsr	rstr_scrn
	move.w	#$4c,-(sp)	pterm
	trap	#1		quit altogether- return to caller

*Concatenate the shear with the rotation
shear	btst.b	#0,shearflg	set for shear
	beq	shr_out		no
	lea	shearmtx,a0	set
	lea	w_vmatx,a1	pointers
	bsr	concat		and concatenate
shr_out	rts

concat:
* Concatenate (multiply) the two 3x3 matrices pointed to by a0 and a1.
* The order is (a1)x(a0) with the result sent to temporary store at (a2).
* (a0) is in column order and (a1) and (a2) are in row order,
* of word length elements. Finally (a2) is transferred to (a1) 
	lea	tempmatx,a2	temporary store
	move.w	#2,d7		3 rows in a1	
conc1	move.w	#2,d6		3 columns in a0 (shear)
	movea.l	a0,a3		reset shear pointer
conc2	move.w	(a1),d1		next rot. element
	ext.l	d1
	lsr.l	#1,d1		/2
	move.w	2(a1),d2
	ext.l	d2
	lsr.l	#1,d2
	move.w	4(a1),d3
	ext.l	d3
	lsr.l	#1,d3
	muls	(a3)+,d1
	muls	(a3)+,d2
	muls	(a3)+,d3
	add.w	d2,d1
	add.w	d3,d1
	move.w	d1,(a2)+	next product element
	dbra	d6,conc2	for all elements in this row
	addq.w	#6,a1		pointer to next row
	dbra	d7,conc1	for all rows
* transfer the result back to the rotation matrix
	lea	tempmatx,a0	temp. store of product
	lea	w_vmatx,a1	becomes new transform
	move.w	#8,d7		9-1 elements in 3x3 matx
conloop	move.w	(a0)+,(a1)+	next element
	dbra	d7,conloop	for all elements
	rts
* Set the velocity components
speed_adj:
	move.w	speed,d0
	lsl.w	#3,d0		scale it
	move.w	Ovz,d1		
	cmp.w	#10,Ovz		musn't come any closer
	bgt	adj_out
	move.w	#10,Ovz
adj_out	add.w	d0,Ovz		zw speed component
	rts
