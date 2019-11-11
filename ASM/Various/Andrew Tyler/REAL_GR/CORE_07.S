* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 core_07.s				*
*		Subroutines for Chapter 12			*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	include	core_06.s

scne_drw:
* Draw the scene of several primitives
	bsr	patch_ext	select the local scene
	bsr	sight_tst	select only visible ones
	bsr	vis_srt		sort them in depth order
	bsr	drw_it		draw them in depth order
	rts	

patch_ext:
* Extract the tile patch. Put the 16 tiles in a list at patch_lst
	move.w	oposx,d0	observer x position
	move.w	oposy,d1	y 
	move.w	oposz,d2	z
* Find position in world. Keep to range 4096
	andi.w	#$fff,d0	range x
	andi.w	#$fff,d1	range y
	andi.w	#$fff,d2	range z
	move.w	d0,oposx	restore x 
	move.w	d1,oposy	y 
	move.w	d2,oposz	z
	move.w	d1,d3
	move.w	d2,d4
* find coords of patch centre = local world origin
	lsr.w	#8,d1		/256
	move.w	d1,Ty		y coord. in 16*16 layout
	lsr.w	#8,d2		/256
	move.w	d2,Tz		z coord
* coords of view frame referenced to this origin
	lsl.w	#8,d1		Ty*256
	lsl.w	#8,d2		Tz*256
	sub.w	d1,d3		oposy-Ty*256 = Ovy
	move.w	d3,Ovy
	sub.w	d2,d4		oposz-Tz*256 = Ovz
	move.w	d4,Ovz
	move.w	oposx,Ovx	Ovx (the height is universal)
 
* Fetch the attributes of the 16 surrounding tiles from the map
* and calculate their world coords., storing the data in a record
* with the format:
* word 1:	high byte = graphics attributes
*		low byte  = clear
* word 2:	Voz tile centre z in view frame coords
* word 3:	tile y in local world coords  
* word 4:	ditto z
* Ty and Tz are the patch centre coords. = local world origin
	move.w	Ty,d0		Ty
	move.w	Tz,d1		Tz
* A 4*4 patch of tiles centred on the Ty,Tz are retrieved
	move.w	#-2,d5		z offset of start tile
	lea	map_base,a0	pointer to map of 16*16=256 tiles
	lea	patch_lst,a1	the local list of 4*4
	move.w	#3,d7		4 z values
tile_lp1:
	move.w	#-2,d4		reset start yoffset
	move.w	#3,d6		4 y values
	move.w	d1,d3		origin Tz
	add.w	d5,d3		+ offset = next z
	andi.w	#$f,d3		stay in range 0-15		
	lsl.w	#4,d3		*16
tile_lp2:
	move	d0,d2		origin Ty
	add.w	d4,d2		+ offset = next y
	andi.w	#$f,d2		stay in range 0-15
	add.w	d3,d2		16*z+y = tile address in map
	move.b	0(a0,d2.w),d2	fetch attribute in low byte
	swap	d2		of high word
	clr.w	d2		0 for low word
	lsl.l	#8,d2		everything into high word		
	move.l	d2,(a1)+	store the 1st half of the record
* Calculate the tile local coords.: Ooy and Ooz
* Local coords are (offset*256)
	movem.l	d4/d5,-(sp)	stack offsets
	lsl	#8,d4		yoffset*256
	swap	d4		in high word
	lsl	#8,d5		zoffset*256
	move.w	d5,d4		in low word 
	move.l	d4,(a1)+	store second half of record
	movem.l	(sp)+,d4/d5	restore offsets
	addq	#1,d4		next y offset
	dbra	d6,tile_lp2	for all the tiles in this row
	addi.w	#1,d5		next z offset
	dbra	d7,tile_lp1	for all rows
	rts
sight_tst:
* Discard all tiles which are out of sight
	lea	patch_lst,a0	pointer to source list
	lea	vis_lst,a1	pointer to list of visible tiles
	lea	vis_cnt,a2	pointer to count of visible tiles
	clr.w	(a2)		set count to zero
	move.w	#15,d7		16 tiles in a patch
	clr.w	Oox		all tiles are on ground
sight_tst1:
	move.w	4(a0),d0
	addi.w	#128,d0
	move.w	d0,Ooy		tile
	move.w	6(a0),d0
	addi.w	#128,d0
	move.w	d0,Ooz		centres
	movem.l	d7/a0-a2,-(sp)
	bsr	testview	is this tile within the field of view?	
	movem.l	(sp)+,d7/a0-a2
	tst.b	viewflag	visible?
	beq	nxt_tile	no
	addq.w	#1,(a2)		yes, increment visible count
	move.w	Voz,2(a0)	save the depth for sorting
	move.l	(a0),(a1)+	transfer 1st half to visible list
	move.l	4(a0),(a1)+	transfer 2nd half of record
nxt_tile:
	addq	#8,a0		point to next record
	dbra	d7,sight_tst1	for all tiles
	rts

testview:
* Is the tile within the field of view?
* Test whether the primitive is visible.
* Tile centre (Oox,Ooy,Ooz) is transformed to view coords then tested.
* (remember matrix elements are *2^14 and must be corrected at the end)
	moveq.l	#2,d6		3 rows in the matrix
	lea	w_vmatx,a3	init matx pointer
	link	a6,#-6		3 words to store temporarily
	move.w	Oox,d3		Oox	the 
	move.w	Ooy,d4		Ooy	object centre
	move.w	Ooz,d5		Ooz
	sub.w	Ovx,d3		Oox-Ovx	relative to the view frame
	sub.w	Ovy,d4		Ooy-Ovy
	sub.w	Ovz,d5		Ooz-Ovz
tranv0	move	d3,d0		restore
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
	dbra	d6,tranv0	repeat for 3 elements
	
	move.w	(a6)+,d3	off my stack becomes Voz
	move.w	(a6)+,d2	becomes Voy (the centre in view frame)
	move.w	(a6)+,d1	becomes Vox
	move.w	d3,Voz
	move.w	d2,Voy
	move.w	d1,Vox
	unlk	a6		close frame
* Clip Ovz. To be visible, must have 50<Voz<2000
* This visibility test looks only at depth
	cmp.w	#50,d3		test(Voz-50)
	bmi	notvis		fail
	cmp.w	#2000,d3	test(Voz-2000)
	bpl	notvis		fail
	st	viewflag	it's visible, set the flag all 1's
	rts
* It's invisible, don't draw it
notvis	sf	viewflag	set the flag all 0's
	rts

vis_srt:
* Order the visible tiles in order of decreasing Voz. 
* Voz is the distance of the tile centre from the view frame
* origin. Largest Voz's should be drawn first.
	move.w	vis_cnt,d7	number to do
	beq	srt_quit	are any visible?
	subq	#1,d7		this number-1
	beq	srt_quit	but no need to sort only 1
	subq.w	#1,d7		1 sort per pair
* bubble sort the records
vis_srt1:
	lea	vis_lst+2,a0	pointer to the first record Voz
	movea.l	a0,a1		
	addq.l	#8,a1		pointer to second record Voz
	move	d7,d6		reset count
	clr.w	srt_flg	clear the flag
vis_srt2:
	cmpm.w	(a0)+,(a1)+	test(Voz2-Voz1) and advance pointer
	ble	no_swap		1st is farther
	move.l	-4(a0),d0	fetch 1st record
	move.l	(a0),d1	
	move.l	-4(a1),-4(a0)	make 
	move.l	(a1),(a0)	second first and
	move.l	d0,-4(a1)	first
	move.l	d1,(a1)		second
	st	srt_flg		set the flag
no_swap:
	addq.l	#6,a0		point to next record Voz
	addq.l	#6,a1		and the one following
	dbra	d6,vis_srt2	for all records.
	tst.w	srt_flg		Were any records swapped?
	beq	srt_quit	no
	bra	vis_srt1	yes, run through again
srt_quit:
	rts			sort is finished

drw_it:
* Draw the visible tiles
	move.w	vis_cnt,d7
	beq	drw_it_out
	subq.w	#1,d7
	lea	vis_lst,a0	pointer to list
drw_it1:
	movem.l	d7/a0,-(sp)
	bsr	set_prim	draw the next primitive
	movem.l	(sp)+,d7/a0
	addq.l	#8,a0		next record
	dbra	d7,drw_it1
drw_it_out:
	rts

set_prim:
* set up next primitive for drawing; enters with pointer to record in a0
* 1. First do the background
	move.l	a0,-(sp)	save pointer
	bsr	ldup_bkg	load background data as program data
	bsr	otranw		object-to-world
	bsr	w_tran_v	world-to-view
* It's always visible at constant illumination; pass colour directly
	movea.l	(sp)+,a0	restore pointer
	move.w	(a0),d0		first word of record
	move.l	a0,-(sp)	save pointer
	lsr.w	#8,d0		top byte
	lsr.w	#4,d0		top nibble is colour
	move.w	d0,col_lst	the final
	move.w	d0,col_lst+2	colours
	bsr	perspective
	bsr	scrn_adj	centre it
	bsr	polydraw	draw it
* 2. Second draw the object
	movea.l	(sp)+,a6	restore pointer
	bsr	ldup_obj	load object data as program data
	bsr	otranw		object-to-world
	bsr	w_tran_v	world-to-view
	bsr	illuminate	all
	bsr	perspective	the
	bsr	scrn_adj	rest
	bsr	polydraw
	rts

ldup_bkg:
* Load background data as program data. The background is a grid.
	move.w	#2,npoly	2 polygons (intersecting rectangles)
	move.l	#$40004,snedges	4 edges in each
	lea	sedglst,a2	edge list 0,1,2,3,0,4,5,6,7,4
	move.l	#1,(a2)+	edges 0,1
	move.l	#$20003,(a2)+	edges 2,3
	move.l	#$4,(a2)+	edges 0,4
	move.l	#$50006,(a2)+	edges 5,6
	move.l	#$70004,(a2)+	edges 7,4
* the background vertices define a cross
* all x coords are zero
	lea	ocoordsx,a2	vertex coords x =
	move.l	#0,(a2)+		0,0
	move.l	#0,(a2)+		0,0
	move.l	#0,(a2)+		0,0
	move.l	#0,(a2)			0,0
	lea	ocoordsy,a2		y =
	move.l	#$ff800080,(a2)+	-128,128
	move.l	#$80ff80,(a2)+		128,-128
	move.l	#$fffcfffc,(a2)+	-4,-4
	move.l	#$40004,(a2)		4,4
	lea	ocoordsz,a2		z =
	move.l	#$40004,(a2)+		4,4
	move.l	#$fffcfffc,(a2)+	-4,-4
	move.l	#$ff800080,(a2)+	-128,128
	move.l	#$80ff80,(a2)		128,-128
	move.w	#8,oncoords	the 
	move.w	#8,vncoords	counts
	move.w	#8,wncoords	are all the same
* the tile centre in the world frame is Oox=0 and the 
* contents of the third and fourth words of the record
	move.w	#0,Oox
	move.w	4(a0),Ooy	third word	
	addi.w	#128,Ooy
	move.w	6(a0),Ooz	fourth word
	addi.w	#128,Ooz
	clr.w	otheta		no
	clr.w	ophi		orientation
	clr.w	ogamma	
	rts			all done
* Load background data as program data
	move.w	#1,npoly	only one polygon
	move.w	#4,snedges	4 edges
	lea	sedglst,a2	edge list 0,1,2,3,0
	move.l	#1,(a2)+	edge 0,1
	move.l	#$20003,(a2)+	edge 2,3
	clr.w	(a2)+		edge 0	
* the background vertices are the corners of the tile
	lea	ocoordsx,a2	vertex coords x =
	move.w	#0,(a2)+		0,0
	move.w	#0,(a2)+		0,0
	move.w	#0,(a2)+
	move.w	#0,(a2)+
	lea	ocoordsy,a2	y =
	clr.l	(a2)+		0,0
	move.l	#$ff00ff,(a2)	255,255
	lea	ocoordsz,a2	z =
	move.l	#$ff,(a2)+	0,255
	move.l	#$ff0000,(a2)	255,0
	move.w	#4,oncoords	the 
	move.w	#4,vncoords	counts
	move.w	#4,wncoords	are all the same
* the tile centre in the world frame is Oox=0 and the 
* contents of the third and fourth words of the record
	move.w	#0,Oox
	move.w	4(a0),Ooy	third word	
	move.w	6(a0),Ooz	fourth word
	clr.w	otheta		no
	clr.w	ophi		orientation
	clr.w	ogamma	
	rts			all done

ldup_obj:
* Load object data as program data
* first find out what type it is; pointer to record in a6
	move.w	(a6),d0		top word
	lsr.w	#8,d0		top byte
	andi.w	#$f,d0		bottom nibble is type (call it n)
	lsl.w	#2,d0		*4 for offset
	lea	primitive,a5	pointer to vector table
	movea.l	0(a5,d0.w),a5	pointer to type n lists
	movea.l	4(a5),a2	pointer to npolyn
	move.w	(a2),d7		here it is
	move.w	d7,npoly
	subq.w	#1,d7		the count
	move	d7,d0		save it
	movea.l	8(a5),a0	pointer to nedgn (list edge numbers)
	movea.l	a0,a4		save it
	lea	snedges,a1	destination
	move.l	(a5),a2		pointer to intrinsic colours
	lea	srf_col,a3	destination
obj_lp1	move.w	(a0)+,(a1)+	transfer edge numbers
	move.w	(a2)+,(a3)+	transfer intrinsic colours
	dbra	d0,obj_lp1
* calculate the total number of edges 
	move.w	d7,d0		restore count
	clr	d1
	clr	d2
obj_lp2	add.w	(a4)+,d2	number of edges
	addq	#1,d2		and with last repeated
	dbra	d0,obj_lp2
*move the edge list
	subq	#1,d2		this is the counter
	movea.l	12(a5),a0	edglstn, the source
	lea	sedglst,a1	destination
obj_lp3	move.w	(a0)+,(a1)+	pass it
	dbra	d2,obj_lp3
* and the coordinates list
	movea.l	28(a5),a0	pointer to no. vertices
	move.w	(a0),d1		no. vertices
	move.w	d1,oncoords	same
	move.w	d1,vncoords	for	
	move.w	d1,wncoords	all frames
	subq	#1,d1		the counter
	movea.l	16(a5),a0	pointer object x
	lea	ocoordsx,a1
	movea.l	20(a5),a2	object y
	lea	ocoordsy,a3
	movea.l	24(a5),a4	object z
	movea.l	a5,a6
	lea	ocoordsz,a5
obj_lp4	move.w	(a0)+,(a1)+
	move.w	(a2)+,(a3)+
	move.w	(a4)+,(a5)+
	dbra	d1,obj_lp4
* increment the rotation angle
	bsr	next_rot
	addi.w	#128,Ooy
	addi.w	#128,Ooz
	rts

* Increment the rotation of the object
next_rot:
	movea.l	32(a6),a0	pointer to angle and flag
	move.l	(a0),d0		top word is flag, bottom is angle
	move.l	d0,d1
	andi.l	#$ffff,d0	the angle
	addi.w	#2,d0		increment it
	cmp	#360,d0
	blt	obj_lp5
	subi	#360,d0
obj_lp5	move.w	d0,2(a0)	next angle
* see what angles to rotate
	swap	d1
	andi.w	#$f,d1		the flag is in the low nibble
* flags are set: bit 0 = x rot, bit 1 = y rot, bit 2 = z rot
	lsl.w	#2,d1		offset
	lea	rot_vec,a0	pointer to jump table
	move.l	0(a0,d1.w),a0	the jump vector
	jmp	(a0)		here goes
rot_vec:
	dc.l	no_rot,rotx,roty,rotxy,rotz,rotxz,rotyz,rotxyz
no_rot	rts			no rotation
rotx	move.w	d0,otheta	rotate about x axis
	rts
roty	move.w	d0,ophi			y
	rts
rotxy	move.w	d0,otheta		x and y
	move.w	d0,ophi
	rts
rotz	move.w	d0,ogamma		z
	rts
rotxz	move.w	d0,otheta		x and z
	move.w	d0,ogamma
	rts
rotyz	move.w	d0,ophi			y and z
	move.w	d0,ogamma
	rts
rotxyz	move.w	d0,otheta		x, y and z
	move.w	d0,ophi
	move.w	d0,ogamma
	rts

joy_read:
* Rotate the view point about an axis
* Read the joystick and update the variables accordingly
* The data packet containing the FIRE bit (7) and the position
* bits (0-2) is saved in the variable joy_data	
	clr.w	joy_data	
	move.w	#10,d6
joy_more:
	bsr	rd_joy		read joystick
	dbf	d6,joy_more	give it time to think
	move.w	joy_data,d0	here's the result
	move	d0,d1		save it
	andi.w	#$f0,d0		fire pressed  ?
	bne	jy_press_fire 	yes
	andi.w	#$f,d1		what direction is the stick?
	bne	joy_dr		
	rts			nothing doing
joy_dr	lea	jump_joy,a0	base address
	lsl.w	#2,d1		offset into jump table
	move.l	0(a0,d1.w),a0	the jump address
	jmp	(a0)		go for it	
jump_joy:
	dc.l	0,up_jy,down_jy,0,left_jy,up_left_jy,down_left_jy
	dc.l	0,right_jy,up_right_jy,down_right_jy
up_jy	bsr	rot_down	rotate view frame down about vy axis
	rts
down_jy	bsr	rot_up		rotate up about vy axis
	rts
left_jy	bsr	rot_left	rotate left about vx axis
	rts
right_jy:
	bsr	rot_right	rotate right about vx axis
	rts
up_left_jy	rts		do nothing for now
down_left_jy	rts
up_right_jy	rts
down_right_jy	rts
jy_press_fire:
	move.w	#1,fire
	rts

in_key:
* Read the keyboard to set view frame speed
	bsr	scan_keys	was a key pressed?
	cmp.w	#-1,d0
	beq	ky_read	yes
	rts			no
ky_read:
	bsr	read_key	which key?
	tst.w	d0		f keys have $0 in the low word
	beq	ky_rpt		only interested if f keys
	rts			something else
ky_rpt	swap	d0		the code
	subi.w	#$3b,d0		f1 is 3b : set it to zero for offset
	andi.w	#7,d0		first 7 f keys
	lea	ky_jump,a0	jump table
	lsl.w	#2,d0		key code is offset
	movea.l	0(a0,d0.w),a0	to the routine address
	jmp	(a0)		go for it
ky_jump:
* The jump table for f keys
	dc.l	f1f,f2f,f3f,f4f,f5f,f6f,f7f
f1f	bsr	roll_left	roll to the left
	rts
f2f	bsr	roll_right	roll to the right
	rts
f3f	move.w	#-2,speed	reverse speed 2
	rts
f4f	move.w	#2,speed	forward speed 2	
	rts
f5f	move.w	#3,speed	forward speed 3
	rts
f6f	move.w	#0,speed	stop
	rts
f7f	bsr	reset_scrn	reset screen
	move.w	#$4c,-(sp)	pterm
	trap	#1		quit altogether- return to caller

rot_down:
* Rotate down about the yv axis. Multiply the "down" control matrix
* by the view transform matrix.
	lea	rot_y_neg,a0	pointer to the control matrix
	bsr	ctrl_view	multiply and set base vectors
	rts

rot_up:
* Rotate up about the yv axis. Multiply the "up " control
* matrix by the view transform matrix.
	lea	rot_y_pos,a0	
	bsr	ctrl_view
	rts

rot_left:
* Rotate left about the xv axis . Multiply the "left" control 
* matrix by the view transform matrix.
	lea	rot_x_pos,a0
	bsr	ctrl_view
	rts

rot_right:
* Rotate right about the xv axis. Multiply the "right" control
* matrix by the view transform matrix.
	lea	rot_x_neg,a0
	bsr	ctrl_view
	rts

roll_left:
* Rotate left about the zv axis. Multiply the "roll-left"
* control matrix by the view transform matrix.
	lea	rot_z_neg,a0
	bsr	ctrl_view
	rts

roll_right:
* Rotate right about the zv axis. Multiply the "roll-right"
* control matrix by the view transform matrix.
	lea	rot_z_pos,a0
	bsr	ctrl_view
	rts

ctrl_view:
* Multiply the control matrix pointed to by a0 by the view matrix
* to calculate the new elements of the view base vectors.
*1. base vector iv
	lea	w_vmatx,a1	pointer to view matrix
	lea	iv,a2		pointer view frame base vector iv
	move.w	#2,d6		3 elements to iv
	movea.l	a1,a3		set view pointer
iv_loop	move.w	(a3),d1		next view element
	move.w	6(a3),d2	"
	move.w	12(a3),d3	"
	muls	(a0),d1
	muls	2(a0),d2
	muls	4(a0),d3
	add.l	d2,d1
	add.l	d3,d1
	lsl.l	#2,d1		/		
	swap	d1		2^14
	move.w	d1,(a2)+	next element in base vector
	addq.l	#2,a3		next column in view matrix		
	dbra	d6,iv_loop	for all elements in this base vector

*2. No need to do the base vector jv; it is calculated from the other two.

*3. base vector kv
	lea	kv,a2		pointer view frame base vector kv
	move.w	#2,d6		3 elements to kv
	movea.l	a1,a3		reset view pointer
kv_loop	move.w	(a3),d1		next view element
	move.w	6(a3),d2	"
	move.w	12(a3),d3	"
	muls	12(a0),d1
	muls	14(a0),d2
	muls	16(a0),d3
	add.l	d2,d1
	add.l	d3,d1
	lsl.l	#2,d1		/		
	swap	d1		2^14
	move.w	d1,(a2)+	next element in base vector
	addq.l	#2,a3		next column in view matrix		
	dbra	d6,kv_loop	for all elements in this base vector
	rts			all done

* Set the velocity components
adj_vel:
	lea	kv,a0
	move.w	#14,d7		ready to divide by 2^14
	move.w	speed,d0
	lsl.w	#4,d0		scale it
	move	d0,d1
	move	d0,d2
	muls	(a0),d0		v*VZx
	lsr.l	d7,d0		/2^14
	add.w	d0,oposx	xw speed component
	bpl	adj1
	clr.w	oposx		oposx must be >0
adj1	muls	2(a0),d1	v*VZy
	lsr.l	d7,d1		
	add.w	d1,oposy	yw speed component
	muls	4(a0),d2	v*VZz
	lsr.l	d7,d2
	add.w	d2,oposz	zw speed component
	rts
