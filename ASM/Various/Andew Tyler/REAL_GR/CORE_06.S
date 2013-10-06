* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 core_06.s                                    *
* 		Subroutines for Chapter 11                            *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include	core_05.s

dircosines:
*  Find the direction cosines for the transform from the world frame
* to the view frame. These are components of the view frame base
* vectors in the world frame. To avoid accumulating errors they
* are regenerated and normalised to a magnitude of 2^14.
	lea	iv,a0	here 	
	lea	jv,a1	they 	
	lea	kv,a2	are  	
* First kv is normalised
	move.w	(a2),d0
	move.w	2(a2),d1
	move.w	4(a2),d2
	bsr	nrm_vec		normalise it
	move.w	d0,(a2)		the
	move.w	d1,2(a2)	new	
	move.w	d2,4(a2)	components
* Second vj is calculated from the cross product of vk
* and vi using the subroutine AxB: requires A pointer in a2
* B pointer in a0
	bsr	AxB
	move.w	d0,(a1)		regenerated
	move.w	d1,2(a1)	components
	move.w	d2,4(a1)	
* Finally the cross product of kv and jv is used for iv
	lea	jv,a2	
	lea	kv,a0
	bsr	AxB
	lea	iv,a1
	move.w	d0,(a1)		regenerated iv
	move.w	d1,2(a1)			
	move.w	d2,4(a1)			

* The components uf the view frame base vectors in the world frame
* are the elements of the transform matrix required for the world-
* to-view transform. 
	lea	w_vmatx,a0	pointer to the w-to-v matrix
	lea	iv,a1		here are
	lea	jv,a2		the view base
	lea	kv,a3		vectors
	move.w	(a1)+,(a0)+	and 
	move.w	(a1)+,(a0)+	here
	move.w	(a1)+,(a0)+	are 
	move.w	(a2)+,(a0)+	the
	move.w	(a2)+,(a0)+	matrix
	move.w	(a2)+,(a0)+	elements
	move.w	(a3)+,(a0)+	of the
	move.w	(a3)+,(a0)+	view
	move.w	(a3)+,(a0)+	transform
	rts	

AxB:
* calculate the vector product AxB: pointer to A in a2, pointer to B
* in a0. Returns x-cmpt in d0, y-cmpt in d1, z-cmpt in d2.
* first component
	move.w	2(a2),d0	Ay
	muls	4(a0),d0	Bz*Ay
	move.w	4(a2),d1	Az
	muls	2(a0),d1	By*Az
	sub.l	d1,d0		Bz*Ay-By*Ax
* second component
	move.w	4(a2),d1	Az
	muls	(a0),d1		Bx*Az
	move.w	(a2),d2		Ax
	muls	4(a0),d2	Bz*Ax
	sub.l	d2,d1		Bx*Az-Bz*Ax
* third component
	move.w	(a2),d2		Ax
	muls	2(a0),d2	By*Ax
	move.w	2(a2),d3	Ay
	muls	(a0),d3		Bx*Ay
	sub.l	d3,d2		By*Ax-Bx*Ay
* reduce them to < word size by dividing by 2^14
	move	#14,d7
	lsr.l	d7,d0
	lsr.l	d7,d1
	lsr.l	d7,d2
* normalise them
	bsr	nrm_vec
	rts			back to caller

* Do a rotation of the view frame about one of the view frame axes 
* in the world frame. The direction cosines for the axis are
* the base vector components.
rot_vx:
* A rotation about the view frame x-axis, vx
	lea	iv,a0		the axis of rotation
	move.w	vxangle,d1	the angle to rotate
	bsr	v_rot_matx	construct the rotation matrix
* only jv and kv are affected
	lea	jv,a0		transform this first
	bsr	rot_view
	lea	kv,a0		transform this second
	bsr	rot_view
	rts
rot_vy:
* A rotation about the view frame y-axis, vy
	lea	jv,a0
	move.w	vyangle,d1
	bsr	v_rot_matx	
* only iv and kv are affected
	lea	iv,a0
	bsr	rot_view
	lea	kv,a0
	bsr	rot_view
	rts
rot_vz:
* A rotation about the view frame z-axis, vz
	lea	kv,a0
	move.w	vzangle,d1
	bsr	v_rot_matx
* only iv and jv are affected
	lea	iv,a0
	bsr	rot_view
	lea	jv,a0
	bsr	rot_view
	rts

rot_view:
* Rotate a view frame base vector. The vector is pointed to by a0.
* Since it is a unit vector it is specified by three components
* which are the direction cosines (nx,ny,nz)
	moveq	#2,d6		3 rows in the transform matrix
	lea	vrot_matx,a3	init matrix pointer
	link	a6,#-6		3 words to store temporarily
rot_vw1	move.w	(a0),d0		nx component
	move.w	2(a0),d1	ny
	move.w	4(a0),d2	nz
	muls	(a3)+,d0	nx*Mi1
	muls	(a3)+,d1	ny*Mi2
	muls	(a3)+,d2	nz*Mi3
	add.l	d1,d0		add them
	add.l	d2,d0
	lsl.l	#2,d0		divide by 2^14
	swap	d0		the new component
	move.w	d0,-(a6)	save it
	dbra	d6,rot_vw1	repeat for three components
	move.w	(a6)+,4(a0)	off my stack into z
	move.w	(a6)+,2(a0)			y
	move.w	(a6)+,(a0)			x
	unlk	a6		release frame pointer
	rts

* Construct the rotation matrix for rotations about an arbitrary axis
* specified by a unit vector with components (direction cosines)
* (n1,n2,n3)
* Entry: pointer to direction cosines (n1,n2,n3), in a0, 
* angle of rotation in d0.w
v_rot_matx:
	lea	vrot_matx,a6	pointer to the rotation matrix
	bsr	sincos		find the rotation sine and cosine 
	move.w	d2,d6		sine delta
	move.w	d3,d7		cos delta

* elements M12 and M21
	move	#16384,d5
	move	d5,d0		1
	move.w	(a0),d1		n1
	muls	2(a0),d1	n1*n2
	lsl.l	#2,d1
	swap	d1
	sub.w	d7,d0		1-cosdelta
	move	d0,d4		save it
	muls	d1,d0		
	lsl.l	#2,d0
	swap	d0		n1*n2(1-cosdelta)
	move	d0,d2
	move.w	4(a0),d1	n3
	muls	d6,d1		n3*sindelta
	lsl.l	#2,d1
	swap	d1
	sub.w	d1,d0		n1*n2(1-cosdelta)-n3*sindelta
	move.w	d0,2(a6)	M12
	add.w	d1,d2		n1*n2(1-cosdelta)+n3*sindelta
	move.w	d2,6(a6)	M21
* elements M13 and M31
	move	d4,d0		1-cosdelta
	muls	(a0),d0		n1*(1-cosdelta)
	lsl.l	#2,d0
	swap 	d0
	muls	4(a0),d0	n1*n3(1-cosdelta)
	lsl.l	#2,d0
	swap	d0
	move	d0,d2
	move.w	2(a0),d1	n2
	muls	d6,d1		n2*sindelta
	lsl.l	#2,d1
	swap	d1
	add.w	d1,d0		n1*n3(1-cosdelta)+n2*sindelta
	move.w	d0,4(a6)	M13
	sub.w	d1,d2		n1*n3(1-cosdelta)-n2*sindelta
	move.w	d2,12(a6)	M31
* elements M23 and M32
	move	d4,d0		1-cosdelta
	muls	2(a0),d0	n2*(1-cosdelta)
	lsl.l	#2,d0
	swap	d0
	muls	4(a0),d0	n2*n3(1-cosdelta)
	lsl.l	#2,d0
	swap	d0
	move	d0,d2
	move.w	(a0),d1		n1
	muls	d6,d1		n1*sindelta
	lsl.l	#2,d1
	swap	d1
	sub.w	d1,d0		n2*n3(1-cosdelta)-n1*sindelta
	move.w	d0,10(a6)	M23
	add.w	d1,d2		n2*n3(1-cosdelta)+n1*sindelta
	move.w	d2,14(a6)	M32
* element M11
	move.w	(a0),d1		n1
	muls	d1,d1		n1*n1
	lsl.l	#2,d1
	swap	d1		/2^14
	move	d5,d2		1
	sub.w	d1,d2		1-n1*n1
	muls	d7,d2		(1-n1*n1)cosdelta	
	lsl.l	#2,d2
	swap	d2
	add.w	d2,d1		n1*n1 +(1-n1*n1)cosdelta
	move.w	d1,(a6)		M11
*element M22	
	move.w	2(a0),d1		n2
	muls	d1,d1		n2*n2
	lsl.l	#2,d1
	swap	d1		/2^14
	move	d5,d2		1
	sub.w	d1,d2		1-n2*n2
	muls	d7,d2		(1-n2*n2)cosdelta	
	lsl.l	#2,d2
	swap	d2
	add.w	d2,d1		n2*n2 +(1-n2*n2)cosdelta
	move.w	d1,8(a6)	M22
*element M33
	move.w	4(a0),d1		n3
	muls	d1,d1		n3*n3
	lsl.l	#2,d1
	swap	d1		/2^14
	move	d5,d2
	sub.w	d1,d2		1-n3*n3
	muls	d7,d2		(1-n3*n3)cosdelta	
	lsl.l	#2,d2
	swap	d2
	add.w	d2,d1		n3*n3 +(1-n3*n3)cosdelta
	move.w	d1,16(a6)	M33
	rts	

* The the world coords are transformed to view coords
* Remember matrix elements are *2^14 and must be corrected at the end
w_tran_v:
	move.w	wncoords,d7	the number
	ext.l	d7		any to do ?
	beq	w_tranv3		if not quit
	subq.w	#1,d7		or this is the count

	lea	wcoordsx,a0	the
	lea	wcoordsy,a1	source
	lea	wcoordsz,a2	coords.
	lea	vcoordsx,a3	the
	lea	vcoordsy,a4	destination
	lea	vcoordsz,a5
	exg	a3,d3		save this address-short of regs.
	link	a6,#-6		3 words to store
w_tranv1:
	moveq.l	#2,d6		3 rows in the matrix
	lea	w_vmatx,a3	init matx pointer
* calculate the next vx, vy and vz
w_tranv2:
	move.w	(a0),d0		wx
	move.w	(a1),d1		wy
	move.w	(a2),d2		wz
	
	sub.w	Ovx,d0		wx-Ovx
	sub.w	Ovy,d1		wy-Ovy
	sub.w	Ovz,d2		wz-Ovz

	muls	(a3)+,d0	wx*Mi1
	muls	(a3)+,d1	wy*Mi2
	muls	(a3)+,d2	wz*Mi3

	add.l	d1,d0
	add.l	d2,d0		wx*Mi1+wy*Mi2+wz*Mi3
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,-(a6)	save it
	dbra	d6,w_tranv2	repeat for 3 elements

	
	move.w	(a6)+,(a5)+	off my stack becomes vz
	move.w	(a6)+,(a4)+	becomes vy		
	exg	a3,d3		restore address vx, save matx pointr
	move.w	(a6)+,(a3)+	becomes vx
	exg	a3,d3		save address vx, restore matx pointr
	addq.l	#2,a0		point to next wx
	addq.l	#2,a1			      wy
 	addq.l	#2,a2			      wz

	dbf	d7,w_tranv1	repeat for all ocoords
	unlk	a6		close frame
w_tranv3:
	rts			and quit

in_joy:
* Read the joystick and update the variables accordingly
* The data packet containing the FIRE bit (7) and the position
* bits (0-2) is saved in the variable joy_data	
	clr.w	joy_data	
	move.w	#10,d6
more_joy:
	bsr	rd_joy		read joystick
	dbf	d6,more_joy	give it time to think
	move.w	joy_data,d0	here's the result
	move	d0,d1		save it
	andi.w	#$f0,d0		fire pressed  ?
	bne	jy_fire_press 	yes
	andi.w	#$f,d1		what direction is the stick?
	bne	dir_joy		
	rts			nothing doing
dir_joy	lea	table_jump,a0	base address
	lsl.w	#2,d1		offset into jump table
	move.l	0(a0,d1.w),a0	the jump address
	jmp	(a0)		go for it	
table_jump:
	dc.l	0,jy_up,jy_down,0,jy_left,jy_up_left,jy_down_left
	dc.l	0,jy_right,jy_up_right,jy_down_right
jy_up	move.w	#350,vyangle	rotate up
	bsr	rot_vy		about vy axis
	rts
jy_down	move.w	#10,vyangle	rotate down
	bsr	rot_vy		about vy axis
	rts
jy_left	move.w	#10,vxangle	rotate left
	bsr	rot_vx		about vx axis
	rts
jy_right:
	move.w	#350,vxangle	rotate right
	bsr	rot_vx		about vx axis
	rts
jy_up_left	rts		do nothing for now
jy_down_left	rts
jy_up_right	rts
jy_down_right	rts
jy_fire_press:
	move.w	#1,fire
	rts

* Set the velocity components
vel_adj:
	lea	kv,a0
	moveq.l	#14,d7		ready to divide by 2^14
	move.w	speed,d0
	lsl.w	#3,d0		scale it
	move	d0,d1
	move	d0,d2
	muls	(a0),d0		v*VZx
	lsr.l	d7,d0		/2^14
	add.w	d0,Ovx		xw speed component
	muls	2(a0),d1	v*VZy
	lsr.l	d7,d1		
	add.w	d1,Ovy		zw speed component
	muls	4(a0),d2	v*VZz
	lsr.l	d7,d2
	add.w	d2,Ovz
	rts

viewtest:
* Test whether the primitive is visible. See whether its centre
* (Oox,Ooy,Ooz) lies within the angle of visibility.	
* Oox, Ooy and Ooz are transformed to view coords then tested.
* Remember matrix elements are *2^14 and must be corrected at the end
	moveq.l	#2,d6		3 rows in the matrix
	lea	w_vmatx,a3	init matx pointer
	link	a6,#-6		3 words to store temporarily
	move.w	Oox,d3		Oox	the 
	addi.w	#50,d3
	move.w	Ooy,d4		Ooy	object centre
	addi.w	#50,d4
	move.w	Ooz,d5		Ooz
	addi.w	#50,d5
	sub.w	Ovx,d3		Oox-Ovx	relative to the view frame
	sub.w	Ovy,d4		Ooy-Ovy
	sub.w	Ovz,d5		Ooz-Ovz
tranOv	move	d3,d0		restore
	move	d4,d1
	move	d5,d2	
	muls	(a3)+,d0	*Mi1	
	muls	(a3)+,d1	*Mi2
	muls	(a3)+,d2	*Mi3
	add.l	d1,d0
	add.l	d2,d0		*Mi1+*Mi2+*Mi3
	lsl.l	#2,d0
	swap	d0		/2^14
	move.w	d0,-(a6)	save it
	dbra	d6,tranOv	repeat for 3 elements
	
	move.w	(a6)+,d3	off my stack becomes Voz
	move.w	(a6)+,d2	becomes Voy
	move.w	(a6)+,d1	becomes Vox
	move.w	d3,Voz
	move.w	d2,Voy
	move.w	d1,Vox
	unlk	a6		close frame
* Clip Ovz. For visibility must have 100<Voz<2000
	cmpi.w	#100,d3		test (Voz-100)
	bmi	invis		fail
	cmpi.w	#2000,d3	test(Voz-2000)
	bpl	invis		fail
* Is it within the allowed angle of view?
	addi.w	#100,d3		Voz+100
	add.w	d3,d3		*2
	add.w	d3,d3		*4
	add.w	d3,d3		*8
* first test horizontal position
	tst.w	d2		is Voy +ve or -ve?
	bpl	pos_y		it's +ve
	neg.w	d2		it's -ve so make it +ve for test
pos_y	cmp.w	d2,d3		Voy is +ve, test(8*(Voz+100)-Voy)
	bmi	invis		Voy too big
* second test vertical position
	tst.w	d1		Vox
	bpl	pos_x		it's +ve
	neg.w	d1		make it +ve
pos_x	cmp.w	d1,d3		test(8(Voz+100)-Vox)	
	bmi	invis		too high
* It is visible
	st	viewflag	set the flag all 1's
	rts
* It's invisible, don't draw it
invis	sf	viewflag	set the flag all 0's
	rts

scrn_adj:
* adjust screen coords so that view frame (0,0) is at the centre
	move.w	vncoords,d7	the number
	beq	adj_end		quit if none
	subq.w	#1,d7		count
	lea	scoordsy,a0	y coords pointer
adj_loop:
	subi.w	#100,(a0)+	adjust next ys
	dbra	d7,adj_loop	for all points
adj_end	rts
	
