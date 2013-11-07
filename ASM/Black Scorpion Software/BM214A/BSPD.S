*=======================================================*
*	BSP-Descent: latest update 25/03/96		*
*=======================================================*
*	Descend BSP tree, generating sectors & walls.	*
*=======================================================*

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Descend Binary Space Partitioning Tree		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	txtlong
*-------------------------------------------------------*
descend_bsp:
*-------------------------------------------------------*
*	Place start & terminator on heap and descend	*
*-------------------------------------------------------*
	move.l		sp,bsp_return
	lea		display_struct,a6
	move.w		NumNodes,d0
	push.w		#terminator
	subq.w		#1,d0
	push.w		d0
	bra		next_node
*-------------------------------------------------------*
*	Thread returns here when tree is exhausted	*
*-------------------------------------------------------*
finish_tree:
*-------------------------------------------------------*
	move.l		bsp_return,sp
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	[node] = [sector] -> draw this node		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	txtlong
*-------------------------------------------------------*
ssector_node:
*-------------------------------------------------------*
*	Stop drawing when [width] columns are filled	*
*-------------------------------------------------------*
	tst.w		display_columns(a6)
	beq.s		finish_tree
*-------------------------------------------------------*
*	Stop drawing when last node has been popped	*
*-------------------------------------------------------*
	not.w		d0
	beq.s		finish_tree
	eor.w		#$7FFF,d0

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Render ssector into run-buffer			*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
build_ssector:
*-------------------------------------------------------*
*	Locate [segs] for this [ssector]		*
*-------------------------------------------------------*
	move.l		display_ssectors(a6),a0
	move.w		ssec_first(a0,d0.w*4),d4
	move.w		ssec_segments(a0,d0.w*4),d3
*-------------------------------------------------------*
*	Locate [linedef] & [sidedef] for first [seg]	*
*-------------------------------------------------------*
	move.l		display_segs(a6),a2
	move.w		d4,d2
	mulu.w		#seg_len,d2
	add.l		d2,a2
	move.w		seg_linedef(a2),d0
	move.w		seg_sidedef(a2),d2
*-------------------------------------------------------*
*	Locate right [sidedef] for this [linedef]	*
*-------------------------------------------------------*
	move.l		display_linedefs(a6),a0
	mulu.w		#linedef_len,d0
	add.l		d0,a0
	move.w		linedef_right(a0,d2.w*2),d1 
*-------------------------------------------------------*
*	Locate [sector] for this [sidedef]		*
*-------------------------------------------------------*
	move.l		display_sidedefs(a6),a0
	mulu.w		#sidedef_len,d1
	add.l		d1,a0
	move.w		sidedef_sector(a0),d1	
*-------------------------------------------------------*
*	Set up floor & ceiling heights for this sector	*
*-------------------------------------------------------*
	move.l		display_sectors(a6),a0
	mulu.w		#sector_len,d1
	add.l		d1,a0
	move.l		a0,display_sectorptr(a6)
*-------------------------------------------------------*
	move.w		sector_floorht(a0),display_fh(a6)
	move.w		sector_ceilht(a0),display_ch(a6)
	move.w		sector_ftns(a0),display_ft(a6)
	move.w		sector_ctns(a0),display_ct(a6)
*-------------------------------------------------------*
*	Are we in this sector?				*
*-------------------------------------------------------*
	tst.b		display_firstssec(a6)
	beq.s		.skip
	clr.b		display_firstssec(a6)
*-------------------------------------------------------*
*	Set viewcone to (sector_height+player_height)	*
*-------------------------------------------------------*
	move.w		display_fh(a6),d0
	add.w		#player_height,d0
	add.w		pho,d0
	move.w		d0,display_ph(a6)
*-------------------------------------------------------*
*	Set up segment-heap for loop			*
*-------------------------------------------------------*
.skip:	move.l		d4,d2
	move.w		d2,display_segbase(a6)
	move.w		d3,display_segnum(a6)
	ble		next_node
*-------------------------------------------------------*
*	Process simple lighting effects (temporary!)	*
*-------------------------------------------------------*
	bsr		process_lighting
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Render segments surrounding this ssector	*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
segment_loop:
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Hidden surface removal stage #1			*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Is viewer on left or right side of this line?	*
*-------------------------------------------------------*
*	((y2-y1)*(x1-Px))) => (((x2-x1)*(y1-Py)) ?	*
*-------------------------------------------------------*
	move.l		display_vertices(a6),a0
	moveq		#0,d0
	moveq		#0,d1
	move.w		linedef_from(a2),d0
	move.w		linedef_to(a2),d1
	move.w		vtx_x(a0,d0.l*4),d5
	move.w		vtx_x(a0,d1.l*4),d6
	move.w		vtx_y(a0,d0.l*4),d0
	move.w		vtx_y(a0,d1.l*4),d1
	sub.w		d5,d6			; x2-x1
	sub.w		d0,d1			; y2-y1
	sub.w		display_px(a6),d5	; x1-px
	sub.w		display_py(a6),d0	; y1-py
	muls.w		d6,d0			; (x2-x1)*(y1-Py)
	muls.w		d5,d1			; (x1-px)*(y2-y1)
	cmp.l		d0,d1
	bpl		invisible
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Segment is visible				*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	pea		(a2)
*-------------------------------------------------------*
	move.w		display_segbase(a6),d0
	move.l		display_segs(a6),a5
	mulu.w		#seg_len,d0
	add.l		d0,a5
*-------------------------------------------------------*
*	Locate segment vertices				*
*-------------------------------------------------------*
	move.l		seg_length(a5),umag
	move.w		seg_distance(a5),x_offset
	move.l		display_vertices(a6),a0
	moveq		#0,d0
	move.w		seg_from(a5),d0
	move.l		a0,a1
	moveq		#0,d1
	move.w		seg_to(a5),d1 
	lsl.l		#2,d0
	lsl.l		#2,d1
	add.l		d0,a0			; a+(d*4)
	add.l		d1,a1			; a+(d*4)
*-------------------------------------------------------*
*	Fetch X1,Y1 / X2,Y2 & centre around viewpoint	*
*-------------------------------------------------------*
	lea		DSPHostStat.w,a2
	lea		DSPHost16.w,a3
	dspwaitwrite.0	(a2)
	move.w		#projectwall_command,(a3)
	dspwaitwrite.0	(a2)
	move.w		(a0)+,(a3)
	dspwaitwrite.0	(a2)
	move.w		(a0)+,(a3)
	dspwaitwrite.0	(a2)
	move.w		(a1)+,(a3)
	dspwaitwrite.0	(a2)
	move.w		(a1)+,(a3)
	lea		DSPHost32.w,a4
	dspwaitread.0	(a2)
	tst.w		(a3)
	beq		end_segment
	dspwaitread.0	(a2)
	move.l		(a4),d3
	lsl.l		#8,d3
	dspwaitread.0	(a2)
	move.l		(a4),d4
	lsl.l		#8,d4
	dspwaitread.0	(a2)
	move.l		(a4),d5
	lsl.l		#8,d5
	dspwaitread.0	(a2)
	move.l		(a4),d6
	lsl.l		#8,d6
	dspwaitread.0	(a2)
	move.l		(a4),d1
	lsl.l		#8,d1
	dspwaitread.0	(a2)
	move.l		(a4),d2
	lsl.l		#8,d2
*-------------------------------------------------------*
*	Write coordinates into addwall struct		*
*-------------------------------------------------------*
.draw:	move.l		d1,addwall_rz2(a6)
	move.l		d2,addwall_rz1(a6)
	move.l		d3,addwall_i1(a6)
	move.l		d4,addwall_z1(a6)
	move.l		d5,addwall_i2(a6)
	move.l		d6,addwall_z2(a6)
*-------------------------------------------------------*
*	Look up linedef for this seg			*
*-------------------------------------------------------*
	move.w		seg_linedef(a5),d1
	move.l		display_linedefs(a6),a0
	mulu.w		#linedef_len,d1
	add.l		d1,a0
*-------------------------------------------------------*
*	Determine one or two-sided linedef		*
*-------------------------------------------------------*
	move.w		linedef_attrib(a0),d0
	or.w		#$100,linedef_attrib(a0)
	move.b		d0,linedef_flags
	and.b		#attrib_twosided,d0
	move.b		d0,twosided_flag
*-------------------------------------------------------*
*	Determine which sidedef is facing us		*
*-------------------------------------------------------*
	move.w		seg_sidedef(a5),d0
	move.w		linedef_right(a0,d0.w*2),d5	; visible sidedef
	bchg		#0,d0
	move.w		linedef_right(a0,d0.w*2),d6	; invisible sidedef
*-------------------------------------------------------*
*	Look up sidedef for visible side of linedef	*
*-------------------------------------------------------*
	move.l		display_sidedefs(a6),a3
	mulu.w		#sidedef_len,d5
	move.l		a3,a4
	add.l		d5,a3
*-------------------------------------------------------*
*	Locate [sector] on opposite side of [linedef]	*
*-------------------------------------------------------*
	tst.b		twosided_flag
	beq.s		.nts
	mulu.w		#sidedef_len,d6
	add.l		d6,a4
	move.w		sidedef_sector(a4),d6		; a+(d*30)
	move.l		display_sectors(a6),a4
	mulu.w		#sector_len,d6
	add.l		d6,a4
.nts:	move.b		#0,addwall_opaque(a6)
	tst.b		twosided_flag
	beq		sector_wall

*-------------------------------------------------------*
*	Check for lower wall texture			*
*-------------------------------------------------------*
lower_texture:
*-------------------------------------------------------*
	move.l		display_sectorptr(a6),a5
	move.w		sidedef_ltns(a3),d0
*-------------------------------------------------------*
*	Determine wall height				*
*-------------------------------------------------------*
	move.w		sector_floorht(a4),d1
	cmp.w		sector_ceilht(a5),d1
	bmi.s		.clip
	move.w		sector_ceilht(a5),d1
.clip:	move.w		sector_floorht(a5),d2 
	neg.w		d1
	add.w		display_ph(a6),d1
	neg.w		d2
	add.w		display_ph(a6),d2
*-------------------------------------------------------*
*	Render if (y2-y1) <= 0				*
*-------------------------------------------------------*
	cmp.w		d1,d2
	ble.s		optimise_lower
*-------------------------------------------------------*
*	Render if texture valid
*-------------------------------------------------------*
	cmp.w		#texcode_none,d0
	beq.s		ignore_lower
*-------------------------------------------------------*
*	Optimise for identical opposing sectors		*
*-------------------------------------------------------*
optimise_lower:
*-------------------------------------------------------*
*	Force wall if textures differ			*
*-------------------------------------------------------*
	move.w		sector_ftns(a4),d3
	cmp.w		sector_ftns(a5),d3
	bne.s		add_lower
*-------------------------------------------------------*
*	Allow skip if both textures are sky		*
*-------------------------------------------------------*
	cmp.w		sky_index,d3
	beq		ignore_lower
*-------------------------------------------------------*
*	Force wall if floor heights differ		*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bne.s		add_lower
*-------------------------------------------------------*
*	Force wall if lighting methods differ		*
*-------------------------------------------------------*
	move.w		sector_special(a4),d3
	cmp.w		sector_special(a5),d3
	bne.s		add_lower
*-------------------------------------------------------*
*	Force wall if light levels differ		*
*-------------------------------------------------------*
	move.w		sector_light(a4),d3
	cmp.w		sector_light(a5),d3
	beq.s		ignore_lower
*-------------------------------------------------------*
*	Lower wall segment passed all tests		*
*-------------------------------------------------------*
add_lower:
*-------------------------------------------------------*
*	Load wall structure				*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bpl.s		.clip
	move.w		d2,d1
	ble.s		ignore_lower
.clip:	move.w		d1,addwall_y1(a6)
	move.w		d2,addwall_y2(a6)
	move.w		d0,wall_id
*-------------------------------------------------------*
*	Calculate texture pegging			*
*-------------------------------------------------------*
	moveq		#0,d1
	btst		#4,linedef_flags
	beq.s		.np
	move.w		display_ch(a6),d1
	sub.w		sector_floorht(a4),d1
.np:	move.w		d1,peg
*-------------------------------------------------------*
*	Add lower wall to rendering buffer		*
*-------------------------------------------------------*
	move.b		#lower_command,addwall_type(a6)
	bsr		add_wall_segment 
*-------------------------------------------------------*
*	Early abort check				*
*-------------------------------------------------------*
	tst.w		display_columns(a6)
	beq		end_segment		 
*-------------------------------------------------------*
ignore_lower:
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Check for upper wall texture			*
*-------------------------------------------------------*
upper_texture:
*-------------------------------------------------------*
	move.l		display_sectorptr(a6),a5
	move.w		sidedef_utns(a3),d0
*-------------------------------------------------------*
*	Determine wall height				*
*-------------------------------------------------------*
	move.w		sector_ceilht(a4),d2
	cmp.w		sector_floorht(a5),d2
	bpl.s		.clip
	move.w		sector_floorht(a5),d2
.clip:	move.w		sector_ceilht(a5),d1 
	neg.w		d1
	add.w		display_ph(a6),d1
	neg.w		d2
	add.w		display_ph(a6),d2
*-------------------------------------------------------*
*	Render if (y2-y1) <= 0				*
*-------------------------------------------------------*
	cmp.w		d1,d2
	ble.s		optimise_upper
*-------------------------------------------------------*
*	Render if texture valid
*-------------------------------------------------------*
	cmp.w		#texcode_none,d0
	beq		ignore_upper
*-------------------------------------------------------*
*	Optimise for identical opposing sectors		*
*-------------------------------------------------------*
optimise_upper:
*-------------------------------------------------------*
*	Force wall if textures differ			*
*-------------------------------------------------------*
	move.w		sector_ctns(a4),d3
	cmp.w		sector_ctns(a5),d3
	bne.s		add_upper
*-------------------------------------------------------*
*	Allow skip if both textures are sky		*
*-------------------------------------------------------*
	cmp.w		sky_index,d3
	beq		ignore_upper
*-------------------------------------------------------*
*	Force wall if floor heights differ		*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bne.s		add_upper
*-------------------------------------------------------*
*	Force wall if lighting methods differ		*
*-------------------------------------------------------*
	move.w		sector_special(a4),d3
	cmp.w		sector_special(a5),d3
	bne.s		add_upper
*-------------------------------------------------------*
*	Force wall if light levels differ		*
*-------------------------------------------------------*
	move.w		sector_light(a4),d3
	cmp.w		sector_light(a5),d3
	beq.s		ignore_upper
*-------------------------------------------------------*
*	Upper wall segment passed all tests		*
*-------------------------------------------------------*
add_upper:
*-------------------------------------------------------*
*	Load wall structure				*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bpl.s		.clip
	move.w		d1,d2
	bpl.s		ignore_upper
.clip:	move.w		d1,addwall_y1(a6)
	move.w		d2,addwall_y2(a6)
	move.w		d0,wall_id
*-------------------------------------------------------*
*	Calculate texture pegging			*
*-------------------------------------------------------*
	moveq		#0,d1
	btst		#3,linedef_flags
	bne.s		.np
	tst.w		d0
	bmi.s		.np
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_height(a0),d1
	add.w		sector_ceilht(a4),d1
	sub.w		sector_ceilht(a5),d1
.np:	move.w		d1,peg
*-------------------------------------------------------*
*	Add upper wall to rendering buffer		*
*-------------------------------------------------------*
	move.b		#upper_command,addwall_type(a6)
	bsr		add_wall_segment 
*-------------------------------------------------------*
*	Early abort check				*
*-------------------------------------------------------*
	tst.w		display_columns(a6)
	beq		end_segment		 
*-------------------------------------------------------*
ignore_upper:
*-------------------------------------------------------*

*-------------------------------------------------------*
sector_wall:	
*-------------------------------------------------------*
*	Check for normal texture			*
*-------------------------------------------------------*
	move.w		sidedef_mtns(a3),d2
	move.w		d2,wall_id
	cmp.w		#texcode_none,d2
	beq		sector_window
*-------------------------------------------------------*
*	Determine texture height for vertical pegging	*
*-------------------------------------------------------*
	clr.w		peg
	clr.w		th
	tst.w		d2
	bmi.s		.notex
	move.l		graphics_array,a0
	move.l		(a0,d2.w*4),a0
	move.w		tex_height(a0),th
*-------------------------------------------------------*
*	Determine texture type (2 sided = transparent)	*
*-------------------------------------------------------*
.notex:	tst.b		twosided_flag
	beq.s		.solid_wall
*-------------------------------------------------------*
*	Wall is 'transparent' middle texture		*
*-------------------------------------------------------*
.transparent_wall:
*-------------------------------------------------------*
	move.b		#trans_command,addwall_type(a6)
	move.b		#1,addwall_opaque(a6)
*-------------------------------------------------------*
*	Unmapped transparents treated as solid		*
*-------------------------------------------------------*
	tst.w		d2
	bmi.s		.normal_height	
*-------------------------------------------------------*
*	Determine transparent texture base		*
*-------------------------------------------------------*
	move.w		display_ph(a6),d0
	btst		#4,linedef_flags
	bne.s		.lower_unpegged
*-------------------------------------------------------*
	move.w		display_ch(a6),d3
	move.w		d0,d1
	cmp.w		sector_ceilht(a4),d3
	bmi.s		.cins
	move.w		sector_ceilht(a4),d3
.cins:	sub.w		d3,d1
	move.w		d1,d2
	add.w		th,d2
	bra.s		.add_wall
*-------------------------------------------------------*
.lower_unpegged:
*-------------------------------------------------------*
	move.w		display_fh(a6),d4
	move.w		d0,d2
	cmp.w		sector_floorht(a4),d4
	bpl.s		.fins
	move.w		sector_floorht(a4),d4
.fins:	sub.w		d4,d2
	move.w		d2,d1
	sub.w		th,d1
	bra.s		.add_wall
*-------------------------------------------------------*
*	Wall is 'solid' middle texture			*
*-------------------------------------------------------*
.solid_wall:
*-------------------------------------------------------*
	move.b		#wall_command,addwall_type(a6)
	move.b		#0,addwall_opaque(a6)
*-------------------------------------------------------*
*	Calculate vertical pegging index		*
*-------------------------------------------------------*
	btst		#4,linedef_flags
	beq.s		.normal_height
	move.w		th,d0
	add.w		display_fh(a6),d0
	sub.w		display_ch(a6),d0
	move.w		d0,peg	
*-------------------------------------------------------*
*	Caclulate wall base & top edge			*
*-------------------------------------------------------*
.normal_height:
*-------------------------------------------------------*
	move.w		display_ph(a6),d0
	move.w		d0,d1
	sub.w		display_ch(a6),d1
	move.w		d0,d2
	sub.w		display_fh(a6),d2
*-------------------------------------------------------*
*	Add middle wall to rendering list		*
*-------------------------------------------------------*
.add_wall:
*-------------------------------------------------------*
*	Force wall if opaque				*
*-------------------------------------------------------*
	tst.b		addwall_opaque(a6)
	beq.s		.go
*-------------------------------------------------------*
*	Allow skip if ceiling = floor			*
*-------------------------------------------------------*
	cmp.w		d1,d2
	beq.s		sector_window
*-------------------------------------------------------*
.go:	move.w		d1,addwall_y1(a6)
	move.w		d2,addwall_y2(a6)
	bsr		add_wall_segment
*-------------------------------------------------------*
sector_window:
*-------------------------------------------------------*

*-------------------------------------------------------*
end_segment:
*-------------------------------------------------------*
	pop.l		a2
*-------------------------------------------------------*
*	Proceed to next segment				*
*-------------------------------------------------------*
invisible:
*-------------------------------------------------------*
	lea		seg_len(a2),a2
	addq.w		#1,display_segbase(a6)
	subq.w		#1,display_segnum(a6)
	beq.s		end_ssector
	tst.w		display_columns(a6)
	bne		segment_loop
*-------------------------------------------------------*
end_ssector:
*-------------------------------------------------------*
	bsr		get_ssector
*-------------------------------------------------------*
*	Fetch next node from heap and descend again	*
*-------------------------------------------------------*
next_node:
*-------------------------------------------------------*
	move.w		(sp)+,d0
	bmi		ssector_node

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	[node] /= [sector] -> descend again		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
dividing_node:
*-------------------------------------------------------*
	move.l		display_nodes(a6),a1
	mulu.w		#node_len,d0
	add.l		d0,a1
*-------------------------------------------------------*
*	Inverse descent rules for left side of tree	*
*-------------------------------------------------------*
*	(dy*(x1-Px))) => ((dx*(y1-Py)) ?		*
*-------------------------------------------------------*
	move.w		node_dx(a1),d2
	move.w		node_x(a1),d0
	move.w		node_dy(a1),d3
	move.w		node_y(a1),d1
	add.w		d2,d0			; x2 = (x1+dx)
	sub.w		display_px(a6),d0	; (x2-px)
	add.w		d3,d1			; y2 = (y1+dy)
	sub.w		display_py(a6),d1	; (xy-py)
	muls.w		d2,d1			; (y2-py) * dx
	muls.w		d3,d0			; (x2-px) * dy
	cmp.l		d0,d1 
	bmi.s		node_leftside
*-------------------------------------------------------*
*	Viewer is on right side of node divider		*
*-------------------------------------------------------*
node_rightside:
*-------------------------------------------------------*
	lea		node_lvtx(a1),a0
	bsr.s		nodeincone
	beq.s		.noln
	move.w		node_left(a1),-(sp)
.noln:	lea		node_rvtx(a1),a0
	bsr.s		nodeincone
	beq.s		next_node
	move.w		node_right(a1),-(sp) 
	bra.s		next_node
*-------------------------------------------------------*
*	Viewer is on left side of node divider		*
*-------------------------------------------------------*
node_leftside:
*-------------------------------------------------------*
	lea		node_rvtx(a1),a0
	bsr.s		nodeincone
	beq.s		.noln
	move.w		node_right(a1),-(sp) 
.noln:	lea		node_lvtx(a1),a0
	bsr.s		nodeincone
	beq.s		next_node
	move.w		node_left(a1),-(sp)
	bra.s		next_node

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Determine visibility of a child node.		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Only exposed nodes are dealt with.		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*-------------------------------------------------------*
*	Check #1 -> Octal node elimination		* 
*-------------------------------------------------------*
*	All nodes are checked against the 3 octal	*
*	segments immediately in front of viewcone.	*
*	Nodes from 5 of all 8 octants are discarded.	*
*-------------------------------------------------------*
*	Check #2 -> Canonical volume intersection	* 
*-------------------------------------------------------*
*	The remaining nodes are fully intersected	*
*	with the projected canonical view volume.	*
*	Any nodes outside the viewcone are discarded.	*
*-------------------------------------------------------*
*	Check #3 -> Occlusion check			* 
*-------------------------------------------------------*
*	Any nodes remaining in view are checked		*
*	against the occlusion table. Any nodes		*
*	completely occluded by walls are discarded.	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
*	This function is now completely DSP based	*
*-------------------------------------------------------*
nodeincone:
*-------------------------------------------------------*
	lea		DSPHostStat.w,a2
	lea		DSPHost16.w,a3
	move.l		a0,a4
	moveq		#nodeincone_command,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a3)
	move.w		(a4)+,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a3)
	move.w		(a4)+,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a3)
	move.w		(a4)+,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a3)
	move.w		(a4)+,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a3)
	dspwaitread.0	(a2)
	tst.w		(a3)
	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

bsp_return:		ds.l	1		; BSP stack base

wall_id:		ds.w	1
x_offset:		ds.w	1
peg:			ds.w	1
th:			ds.w	1

linedef_flags:		ds.b	1
twosided_flag:		ds.b	1		; transparent wall flag

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
