
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
pov_edge_prev		rs.l	1
pov_edge_next		rs.l	1
pov_edge_p1		rs.w	1
pov_edge_p2		rs.w	1
pov_edge_sectorptr	rs.l	1
pov_edge_slen		rs.b	0

*-------------------------------------------------------*
output_mesh:
*-------------------------------------------------------*
	clr.w		pov_used_edges
	move.l		#mesh_buffer,mesh_buffer_ptr
*-------------------------------------------------------*
	lea		pov_sector_pointers,a0
	move.w		NumSectors,d0
	bra.s		.go0
.loop0:	clr.l		pov_edge_next(a0)
.go0:	dbra		d0,.loop0
*-------------------------------------------------------*
	move.w		NumSSectors,d0
	bra.s		.go1
.loop1:	push.w		d0
	bsr		output_segs
	pop.w		d0
.go1:	dbra		d0,.loop1
*-------------------------------------------------------*
	move.w		NumSectors,d0
	bra.s		.go2
.loop2:	push.w		d0
	mulu.w		#sector_len,d0
	add.l		Sector_Array,d0
	move.l		d0,a0
	pop.w		d0
	move.w		sector_floorht(a0),d1
	move.w		sector_ceilht(a0),d2
	neg.w		d1
	neg.w		d2
	cmp.w		d1,d2
	bpl.s		.go2
	move.w		d1,pov_wall_z1
	move.w		d2,pov_wall_z2
	push.w		d0
	bsr		generate_flats
	bsr		output_flats
	pop.w		d0
.go2:	dbra		d0,.loop2
	rts

*-------------------------------------------------------*
pov_remove_edge:
*-------------------------------------------------------*
	move.l		pov_edge_prev(a1),a2
	move.l		pov_edge_next(a1),a3
	tst.l		a3
	beq.s		.skn
	move.l		a2,pov_edge_prev(a3)
.skn:	move.l		a3,pov_edge_next(a2)
	rts

*-------------------------------------------------------*
generate_flats:
*-------------------------------------------------------*
	move.l		#flat_buffer,flats
	clr.w		pov_vtx_count
*-------------------------------------------------------*
	lea		pov_sector_pointers,a0
	mulu.w		#pov_edge_slen,d0
	add.l		d0,a0
*-------------------------------------------------------*
.begin_subpoly:
*-------------------------------------------------------*
*	Check for early termination			*
*-------------------------------------------------------*
	move.l		pov_edge_next(a0),d1
	beq		.end_subpoly
	move.l		d1,a1
*-------------------------------------------------------*
*	Read first edge from list			*
*-------------------------------------------------------*
	move.w		pov_edge_p1(a1),pov_tri_p1
	move.w		pov_edge_p2(a1),pov_tri_p2
	bsr		pov_remove_edge
*-------------------------------------------------------*
*	Set up start point				*
*-------------------------------------------------------*
	move.w		pov_tri_p1,pov_tri_ps
*-------------------------------------------------------*
*	Set up vertex count for this subpoly		*
*-------------------------------------------------------*
	move.l		flats,a6
	move.l		a6,pov_sub_size_ptr
	clr.w		(a6)+
	move.l		a6,flats
*-------------------------------------------------------*
*	Store first vertex				*
*-------------------------------------------------------*
	move.w		pov_tri_ps,d0
	bsr		store_flat_vertex
*-------------------------------------------------------*
.next_edge:
*-------------------------------------------------------*
*	Check for early termination			*
*-------------------------------------------------------*
	move.l		pov_edge_next(a0),d1
	beq.s		.end_open_subpoly
*-------------------------------------------------------*
*	Search for next adjacent edge to this edge	*
*-------------------------------------------------------*
	move.w		pov_tri_p2,d7
.find:	move.l		d1,a1
	cmp.w		pov_edge_p1(a1),d7
	beq.s		.found_adjacent
	move.l		pov_edge_next(a1),d1
	bne.s		.find
*-------------------------------------------------------*
*	Close the shape and move on			*
*-------------------------------------------------------*
	move.w		pov_tri_ps,d0
	bsr		store_flat_vertex
*-------------------------------------------------------*
	bra.s		.begin_subpoly
*-------------------------------------------------------*
.found_adjacent:
*-------------------------------------------------------*
*	Remove adjacent from sector			*
*-------------------------------------------------------*
	move.w		pov_edge_p1(a1),pov_tri_p1
	move.w		pov_edge_p2(a1),pov_tri_p2
	bsr		pov_remove_edge
*-------------------------------------------------------*
*	Store vertex for output				*
*-------------------------------------------------------*
	move.w		pov_tri_p1,d0
	bsr		store_flat_vertex
*-------------------------------------------------------*
*	Repeat until edges close into polygon		*
*-------------------------------------------------------*
	move.w		pov_tri_p2,d0
	cmp.w		pov_tri_ps,d0
	bne.s		.next_edge
*-------------------------------------------------------*
*	Close polygon					*
*-------------------------------------------------------*
	move.w		pov_tri_ps,d0
	bsr		store_flat_vertex
*-------------------------------------------------------*
*	Begin again					*
*-------------------------------------------------------*
	bra		.begin_subpoly
*-------------------------------------------------------*
*	Close the shape and finish			*
*-------------------------------------------------------*
.end_open_subpoly:
*-------------------------------------------------------*
	move.w		pov_tri_ps,d0
	bsr		store_flat_vertex
*-------------------------------------------------------*
.end_subpoly:
*-------------------------------------------------------*
*	Indicate end of sub-poly			*
*-------------------------------------------------------*
	move.l		flats,a6
	move.w		#-1,(a6)+
	move.l		a6,flats
	rts

*-------------------------------------------------------*
store_flat_vertex:
*-------------------------------------------------------*
	move.l		flats,a6
	move.w		d0,(a6)+
	move.l		a6,flats
	move.l		pov_sub_size_ptr,a6
	addq.w		#1,(a6)
	addq.w		#1,pov_vtx_count
	rts

*-------------------------------------------------------*
*	d0		SSector number			*
*-------------------------------------------------------*
output_segs:
*-------------------------------------------------------*
	lea		display_struct,a6
	clr.l		gbl_player_height(a6)
*-------------------------------------------------------*
*	Locate [segs] for this [ssector]		*
*-------------------------------------------------------*
	move.l		gbl_ssectors_ptr(a6),a0
	move.w		ssec_first(a0,d0.w*4),d4
	move.w		ssec_segments(a0,d0.w*4),d3
*-------------------------------------------------------*
*	Locate [linedef] & [sidedef] for first [seg]	*
*-------------------------------------------------------*
	move.l		gbl_segs_ptr(a6),a2
	move.w		d4,d2
	mulu.w		#seg_len,d2
	add.l		d2,a2
	move.w		seg_linedef(a2),d5
	move.w		seg_sidedef(a2),d2
*-------------------------------------------------------*
*	Locate right [sidedef] for this [linedef]	*
*-------------------------------------------------------*
	move.l		gbl_linedefs_ptr(a6),a0
	mulu.w		#linedef_len,d5
	add.l		d5,a0
	move.w		linedef_right(a0,d2.w*2),d1 
*-------------------------------------------------------*
*	Locate [sector] for this [sidedef]		*
*-------------------------------------------------------*
	move.l		gbl_sidedefs_ptr(a6),a0
	mulu.w		#sidedef_len,d1
	add.l		d1,a0
	move.w		sidedef_sector(a0),d0
	move.w		d0,pov_sector_code

;	bne.s		.xxx
;	illegal
;.xxx:

*-------------------------------------------------------*
*	Set up floor & ceiling heights for this sector	*
*-------------------------------------------------------*
	move.l		gbl_sectors_ptr(a6),a0
	move.w		d0,d1
	mulu.w		#sector_len,d1
	add.l		d1,a0
	move.l		a0,gbl_newsector_ptr(a6)
*-------------------------------------------------------*
*	Set up wall 
*-------------------------------------------------------*
	move.w		sector_floorht(a0),gbl_floor_height(a6)
	move.w		sector_ceilht(a0),gbl_ceiling_height(a6)
*-------------------------------------------------------*
*	Set up segment-heap for loop			*
*-------------------------------------------------------*
.skip:	move.l		d4,d2
	move.w		d2,gbl_seg_start(a6)
	move.w		d3,gbl_seg_number(a6)
	beq		.end_segment
*-------------------------------------------------------*
.segment_loop:
*-------------------------------------------------------*
	pea		(a2)
*-------------------------------------------------------*
	move.w		gbl_seg_start(a6),d0
	move.l		gbl_segs_ptr(a6),a5
	mulu.w		#seg_len,d0
	add.l		d0,a5
*-------------------------------------------------------*
*	Locate segment vertices				*
*-------------------------------------------------------*
	move.l		gbl_vertices_ptr(a6),a0
	move.l		a0,a1
	moveq		#0,d0
	move.w		seg_from(a5),d0
	moveq		#0,d1
	move.w		seg_to(a5),d1 
*-------------------------------------------------------*
	move.w		d0,point1
	move.w		d1,point2
	bsr		link_sector_edge
*-------------------------------------------------------*
	lsl.l		#2,d0
	lsl.l		#2,d1
	add.l		d0,a0			; a+(d*4)
	add.l		d1,a1			; a+(d*4)
*-------------------------------------------------------*
*	Set up wall coordinates				*
*-------------------------------------------------------*
	move.w		(a0)+,pov_wall_x1
	move.w		(a0)+,pov_wall_y1
	move.w		(a1)+,pov_wall_x2
	move.w		(a1)+,pov_wall_y2
*-------------------------------------------------------*
*	Set up wall length & offset			*
*-------------------------------------------------------*
	move.l		seg_length(a5),gbl_seg_umag(a6)
	move.w		seg_distance(a5),gbl_seg_uoff(a6)
*-------------------------------------------------------*
*	Look up linedef for this seg			*
*-------------------------------------------------------*
	move.w		seg_linedef(a5),d1
	move.l		gbl_linedefs_ptr(a6),a0
	mulu.w		#linedef_len,d1
	add.l		d1,a0
*-------------------------------------------------------*
*	Determine one or two-sided linedef		*
*-------------------------------------------------------*
	move.w		linedef_attrib(a0),d0
	or.w		#$100,linedef_attrib(a0)
	move.b		d0,gbl_line_flags(a6)
	and.b		#attrib_twosided,d0
	move.b		d0,gbl_line_2side(a6)
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
	move.l		gbl_sidedefs_ptr(a6),a3
	mulu.w		#sidedef_len,d5
	move.l		a3,a4
	add.l		d5,a3
	move.l		a3,gbl_seg_sidedef(a6)
*-------------------------------------------------------*
*	Locate [sector] on opposite side of [linedef]	*
*-------------------------------------------------------*
	tst.b		gbl_line_2side(a6)
	beq.s		.nts
	mulu.w		#sidedef_len,d6
	add.l		d6,a4
	move.w		sidedef_sector(a4),d6		; a+(d*30)
	move.l		gbl_sectors_ptr(a6),a4
	mulu.w		#sector_len,d6
	add.l		d6,a4
.nts:	move.l		a4,gbl_seg_adj_sec(a6)
*-------------------------------------------------------*
	clr.l		gbl_seg_texheight(a6)
	clr.w		gbl_seg_u_index(a6)
	clr.w		gbl_seg_v_index(a6)
*-------------------------------------------------------*
	move.l		gbl_seg_sidedef(a6),a3
	move.l		gbl_seg_adj_sec(a6),a4
	move.b		#0,gbl_seg_opaque(a6)
*-------------------------------------------------------*
*	If wall is one-sided, it must be solid		*
*-------------------------------------------------------*
	tst.b		gbl_line_2side(a6)
	beq		.sector_wall

*-------------------------------------------------------*
*	Check for lower wall texture			*
*-------------------------------------------------------*
.lower_texture:
*-------------------------------------------------------*
	move.l		gbl_newsector_ptr(a6),a5
	move.w		sidedef_ltns(a3),d0
*-------------------------------------------------------*
*	Calculate heights of adjacent floors		*
*-------------------------------------------------------*
	move.w		sector_ceilht(a5),d3		; our ceiling
	move.w		sector_floorht(a4),d1		; adjacent floor
	move.w		sector_floorht(a5),d2 		; our floor
*-------------------------------------------------------*
*	Ensure AF is clipped to OC		 	*
*-------------------------------------------------------*
	cmp.w		d3,d1
	ble.s		.clip_af_2_oc
	move.w		d3,d1
*-------------------------------------------------------*
.clip_af_2_oc:
*-------------------------------------------------------*
*	Missing texture cannot be rendered if OF < AF	*
*-------------------------------------------------------*
	cmp.w		#texcode_none,d0
	bne.s		.lower_valid
	cmp.w		d1,d2
	bge.s		.lower_valid
*-------------------------------------------------------*
*	Close missing texture by fixing adjacent	*
*-------------------------------------------------------*
	move.w		d2,d1
*-------------------------------------------------------*
.lower_valid:
*-------------------------------------------------------*
*	Force render if adjacent flats differ		*
*-------------------------------------------------------*
	move.w		sector_ftns(a5),d3
	cmp.w		sector_ftns(a4),d3
	bne.s		.add_lower
*-------------------------------------------------------*
*	If both flats are sky texture, don't render	*
*-------------------------------------------------------*
;	cmp.w		sky_index,d3
;	beq		.ignore_lower
*-------------------------------------------------------*
*	Texture *must* be rendered if OF <> AF		*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bne.s		.add_lower
*-------------------------------------------------------*
*	Adjoining sectors match in texture and height	* 
*-------------------------------------------------------*
.lower_match:
*-------------------------------------------------------*
*	Force wall if lighting methods differ		*
*-------------------------------------------------------*
	move.w		sector_special(a4),d3
	cmp.w		sector_special(a5),d3
	bne.s		.add_lower
*-------------------------------------------------------*
*	Ignore render wall if light levels match	*
*-------------------------------------------------------*
	move.w		sector_light(a4),d3
	cmp.w		sector_light(a5),d3
	beq		.ignore_lower
*-------------------------------------------------------*
*	Lower texture visible, so it must be valid	*
*-------------------------------------------------------*
.add_lower:
*-------------------------------------------------------*
*	Adjust for player's vertical position		*
*-------------------------------------------------------*
	move.l		gbl_player_height(a6),d3
	swap		d1
	clr.w		d1
	neg.l		d1
	add.l		d3,d1
	swap		d2
	clr.w		d2
	neg.l		d2
	add.l		d3,d2
*-------------------------------------------------------*
*	Ignore floor if higher than player's view	*
*-------------------------------------------------------*
	cmp.l		d2,d1
	blt.s		.clip
	move.l		d2,d1
	ble.s		.ignore_lower
*-------------------------------------------------------*
*	Load wall structure				*
*-------------------------------------------------------*
.clip:	move.w		d0,gbl_seg_tex(a6)
	move.l		d1,gbl_seg_y1(a6)
	move.l		d2,gbl_seg_y2(a6)
*-------------------------------------------------------*
*	Calculate texture pegging			*
*-------------------------------------------------------*
	moveq		#0,d1
	btst		#attrib_lowerunpeg,gbl_line_flags(a6)
	beq.s		.lower_pegged
	move.w		gbl_ceiling_height(a6),d1
	sub.w		sector_floorht(a4),d1	; peg = oc-af
*-------------------------------------------------------*
.lower_pegged:
*-------------------------------------------------------*
	move.w		d1,gbl_seg_unpeg(a6)
*-------------------------------------------------------*
*	Add lower wall to rendering buffer		*
*-------------------------------------------------------*
	move.b		#lower_command,gbl_seg_type(a6)
	move.w		sidedef_yoff(a3),d7
	bsr		output_seg
*-------------------------------------------------------*
.ignore_lower:
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Check for upper wall texture			*
*-------------------------------------------------------*
.upper_texture:
*-------------------------------------------------------*
	move.l		gbl_newsector_ptr(a6),a5
	move.w		sidedef_utns(a3),d0
*-------------------------------------------------------*
*	Calculate heights of adjacent floors		*
*-------------------------------------------------------*
	move.w		sector_floorht(a5),d3		; our floor
	move.w		sector_ceilht(a4),d1		; adjacent ceiling
	move.w		sector_ceilht(a5),d2 		; our ceiling
*-------------------------------------------------------*
*	Ensure AC is clipped to OF		 	*
*-------------------------------------------------------*
	cmp.w		d3,d1
	bge.s		.clip_ac_2_of
	move.w		d3,d1
*-------------------------------------------------------*
.clip_ac_2_of:
*-------------------------------------------------------*
*	Missing texture cannot be rendered if OC > AC	*
*-------------------------------------------------------*
	cmp.w		#texcode_none,d0
	bne.s		.upper_valid
	cmp.w		d1,d2
	ble.s		.upper_valid
*-------------------------------------------------------*
*	Close missing texture by fixing adjacent	*
*-------------------------------------------------------*
	move.w		d2,d1
*-------------------------------------------------------*
.upper_valid:
*-------------------------------------------------------*
*	Force render if adjacent flats differ		*
*-------------------------------------------------------*
	move.w		sector_ctns(a5),d3
	cmp.w		sector_ctns(a4),d3
	bne.s		.add_upper
*-------------------------------------------------------*
*	If both flats are sky texture, don't render	*
*-------------------------------------------------------*
	cmp.w		sky_index,d3
	beq		.ignore_upper
*-------------------------------------------------------*
*	Texture *must* be rendered if OC <> AC		*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bne.s		.add_upper
*-------------------------------------------------------*
*	Adjoining sectors match in texture and height	* 
*-------------------------------------------------------*
.upper_match:
*-------------------------------------------------------*
*	Force wall if lighting methods differ		*
*-------------------------------------------------------*
	move.w		sector_special(a4),d3
	cmp.w		sector_special(a5),d3
	bne.s		.add_upper
*-------------------------------------------------------*
*	Ignore render wall if light levels match	*
*-------------------------------------------------------*
	move.w		sector_light(a4),d3
	cmp.w		sector_light(a5),d3
	beq		.ignore_upper
*-------------------------------------------------------*
*	Upper texture visible, so it must be valid	*
*-------------------------------------------------------*
.add_upper:
*-------------------------------------------------------*
*	Adjust for player's vertical position		*
*-------------------------------------------------------*
	move.l		gbl_player_height(a6),d3
	swap		d1
	clr.w		d1
	neg.l		d1
	add.l		d3,d1
	swap		d2
	clr.w		d2
	neg.l		d2
	add.l		d3,d2
*-------------------------------------------------------*
*	Clip upper wall to positive height		*
*-------------------------------------------------------*
	cmp.l		d2,d1
	bgt.s		.clip2
	move.l		d2,d1
*-------------------------------------------------------*
*	Ignore ceiling if lower than player's view	*
*-------------------------------------------------------*
	bge.s		.ignore_upper
*-------------------------------------------------------*
*	Load wall structure				*
*-------------------------------------------------------*
.clip2:	move.w		d0,gbl_seg_tex(a6)
	move.l		d2,gbl_seg_y1(a6)
	move.l		d1,gbl_seg_y2(a6)
*-------------------------------------------------------*
*	Calculate texture pegging			*
*-------------------------------------------------------*
	moveq		#0,d1
	btst		#attrib_upperunpeg,gbl_line_flags(a6)
	bne.s		.upper_unpegged
	tst.w		d0
	bmi.s		.upper_unpegged
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_height(a0),d1
	sub.w		sector_ceilht(a5),d1
	add.w		sector_ceilht(a4),d1	; peg = th-oc+ac
*-------------------------------------------------------*
.upper_unpegged:
*-------------------------------------------------------*
	move.w		d1,gbl_seg_unpeg(a6)
*-------------------------------------------------------*
*	Add upper wall to rendering buffer		*
*-------------------------------------------------------*
	move.b		#upper_command,gbl_seg_type(a6)
	move.w		sidedef_yoff(a3),d7
	bsr		output_seg
*-------------------------------------------------------*
.ignore_upper:
*-------------------------------------------------------*

*-------------------------------------------------------*
.sector_join:	
*-------------------------------------------------------*
*	Check for normal texture			*
*-------------------------------------------------------*
	move.w		sidedef_mtns(a3),d2
	bmi		.sector_window
*-------------------------------------------------------*
*	Normal texture is valid				*
*-------------------------------------------------------*
	move.w		d2,gbl_seg_tex(a6)
*-------------------------------------------------------*
*	Determine texture height			*
*-------------------------------------------------------*
	move.l		graphics_array,a0
	move.l		(a0,d2.w*4),a0
	move.w		tex_height(a0),gbl_seg_texheight(a6)
*-------------------------------------------------------*
*	Texture is transparent				*
*-------------------------------------------------------*
	move.b		#trans_command,gbl_seg_type(a6)
	move.b		#1,gbl_seg_opaque(a6)
*-------------------------------------------------------*
*	Reset pegging and y-offset fields		*
*-------------------------------------------------------*
	moveq		#0,d7
	clr.w		gbl_seg_unpeg(a6)
*-------------------------------------------------------*
*	Determine player height				*
*-------------------------------------------------------*
	move.l		gbl_player_height(a6),d0
*-------------------------------------------------------*
*	Determine transparent texture position		*
*-------------------------------------------------------*
	btst		#4,gbl_line_flags(a6)
	bne.s		.t_bottom_up

*-------------------------------------------------------*
.t_top_down:
*-------------------------------------------------------*
	move.w		sector_ceilht(a4),d1
	move.w		gbl_ceiling_height(a6),d3
	cmp.w		d1,d3
	ble.s		.cins
	move.w		d1,d3
.cins:	add.w		sidedef_yoff(a3),d3
	swap		d3
	clr.w		d3
*-------------------------------------------------------*
	move.l		d0,d1
	sub.l		d3,d1
	move.l		d1,d2
	add.l		gbl_seg_texheight(a6),d2
*-------------------------------------------------------*
*	Allow skip if ceiling = floor			*
*-------------------------------------------------------*
	cmp.l		d1,d2
	beq		.sector_window
*-------------------------------------------------------*
	move.l		d1,gbl_seg_y1(a6)
	move.l		d2,gbl_seg_y2(a6)
	bsr		output_seg
*-------------------------------------------------------*
	bra		.sector_window

*-------------------------------------------------------*
.t_bottom_up:
*-------------------------------------------------------*
	move.w		sector_floorht(a4),d1
	move.w		gbl_floor_height(a6),d3
	cmp.w		d1,d3
	bpl.s		.fins
	move.w		d1,d3
.fins:	add.w		sidedef_yoff(a3),d3
	swap		d3
	clr.w		d3
*-------------------------------------------------------*
	move.l		d0,d2
	sub.l		d3,d2
	move.l		d2,d1
	sub.l		gbl_seg_texheight(a6),d1
*-------------------------------------------------------*
*	Allow skip if ceiling = floor			*
*-------------------------------------------------------*
	cmp.l		d1,d2
	beq		.sector_window
*-------------------------------------------------------*
	move.l		d1,gbl_seg_y1(a6)
	move.l		d2,gbl_seg_y2(a6)
	bsr		output_seg
*-------------------------------------------------------*
	bra		.sector_window

*-------------------------------------------------------*
.sector_wall:	
*-------------------------------------------------------*
*	Find normal texture				*
*-------------------------------------------------------*
	move.w		sidedef_mtns(a3),d2
	move.w		d2,gbl_seg_tex(a6)
	bmi.s		.notex
*-------------------------------------------------------*
*	Texture is valid - determine texture height	*
*-------------------------------------------------------*
	move.l		graphics_array,a0
	move.l		(a0,d2.w*4),a0
	move.w		tex_height(a0),gbl_seg_texheight(a6)
*-------------------------------------------------------*
*	Texture is solid				*
*-------------------------------------------------------*
.notex:	move.b		#wall_command,gbl_seg_type(a6)
	move.b		#0,gbl_seg_opaque(a6)
*-------------------------------------------------------*
*	Set up y-offset					*
*-------------------------------------------------------*
	move.w		sidedef_yoff(a3),d7
*-------------------------------------------------------*
*	Initial pegging offset is zero			*
*-------------------------------------------------------*
	moveq		#0,d1
*-------------------------------------------------------*
*	Calculate vertical pegging index		*
*-------------------------------------------------------*
	btst		#attrib_lowerunpeg,gbl_line_flags(a6)
	beq.s		.no_pegging
	move.w		gbl_seg_texheight(a6),d1
	add.w		gbl_floor_height(a6),d1
	sub.w		gbl_ceiling_height(a6),d1
*-------------------------------------------------------*
.no_pegging:
*-------------------------------------------------------*
	move.w		d1,gbl_seg_unpeg(a6)	
*-------------------------------------------------------*
*	Determine player height				*
*-------------------------------------------------------*
	move.l		gbl_player_height(a6),d0
*-------------------------------------------------------*
*	Caclulate wall base & top edge			*
*-------------------------------------------------------*
	clr.l		d1
	sub.w		gbl_ceiling_height(a6),d1
	clr.l		d2
	sub.w		gbl_floor_height(a6),d2
	swap		d1
	add.l		d0,d1
	swap		d2
	add.l		d0,d2
*-------------------------------------------------------*
*	Add middle wall to rendering list		*
*-------------------------------------------------------*
.add_wall:
*-------------------------------------------------------*
	move.l		d1,gbl_seg_y1(a6)
	move.l		d2,gbl_seg_y2(a6)
	bsr		output_seg
*-------------------------------------------------------*
.sector_window:
*-------------------------------------------------------*

*-------------------------------------------------------*
.end_segment:
*-------------------------------------------------------*
	pop.l		a2
*-------------------------------------------------------*
*	Proceed to next segment				*
*-------------------------------------------------------*
.invisible:
*-------------------------------------------------------*
	lea		seg_len(a2),a2
	addq.w		#1,gbl_seg_start(a6)
	subq.w		#1,gbl_seg_number(a6)
	bne		.segment_loop
*-------------------------------------------------------*
.end_ssector:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
output_flats:
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
	move.l		mesh_buffer_ptr,a2
*-------------------------------------------------------*
	move.w		pov_wall_z1,pov_wall_z
	bsr		output_polygon
	move.w		pov_wall_z2,pov_wall_z
	bsr		output_polygon
*-------------------------------------------------------*
	move.l		a2,mesh_buffer_ptr
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
output_seg:
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
	move.l		mesh_buffer_ptr,a2
*-------------------------------------------------------*
;	lea		ascii_pov_mesh,a1		; mesh {\n
;	bsr		strcopy_a1_a2
;	lea		ascii_pov_obracket,a1
;	bsr		strcopy_a1_a2
;	lea		ascii_pov_newline,a1
;	bsr		strcopy_a1_a2
*-------------------------------------------------------*
	move.w		gbl_seg_y1(a6),d1
	move.w		gbl_seg_y2(a6),d2
*-------------------------------------------------------*
	cmp.w		d2,d1
	bge.s		.skip
*-------------------------------------------------------*
	move.w		d1,pov_wall_z1
	move.w		d2,pov_wall_z2
*-------------------------------------------------------*
	bsr		output_wall
*-------------------------------------------------------*
.skip:
;	lea		ascii_pov_cbracket,a1
;	bsr		strcopy_a1_a2
;	lea		ascii_pov_newline,a1
;	bsr		strcopy_a1_a2
*-------------------------------------------------------*
	move.l		a2,mesh_buffer_ptr
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
output_wall:
*-------------------------------------------------------*
	move.w		pov_wall_x1,pov_tri_x1
	move.w		pov_wall_y1,pov_tri_y1
	move.w		pov_wall_z1,pov_tri_z1
	move.w		pov_wall_x2,pov_tri_x2
	move.w		pov_wall_y2,pov_tri_y2
	move.w		pov_wall_z1,pov_tri_z2
	move.w		pov_wall_x2,pov_tri_x3
	move.w		pov_wall_y2,pov_tri_y3
	move.w		pov_wall_z2,pov_tri_z3
	bsr		output_triangle
	move.w		pov_wall_x1,pov_tri_x1
	move.w		pov_wall_y1,pov_tri_y1
	move.w		pov_wall_z1,pov_tri_z1
	move.w		pov_wall_x2,pov_tri_x2
	move.w		pov_wall_y2,pov_tri_y2
	move.w		pov_wall_z2,pov_tri_z2
	move.w		pov_wall_x1,pov_tri_x3
	move.w		pov_wall_y1,pov_tri_y3
	move.w		pov_wall_z2,pov_tri_z3
	bsr		output_triangle
	rts

*-------------------------------------------------------*
output_polygon:
*-------------------------------------------------------*

	lea		ascii_pov_polygon,a1		; polygon {\n
	bsr		strcopy_a1_a2
	lea		ascii_pov_obracket,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2

*-------------------------------------------------------*
	move.w		pov_vtx_count,d0		; verts,\n
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
*-------------------------------------------------------*
	lea		flat_buffer,a6

.next:	move.w		(a6)+,d6
	beq.s		.next

	bmi.s		.stop

	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2

	subq.w		#1,d6

.all:	move.w		(a6)+,d0

	push.l		d6
	push.l		a6

	bsr		output_vertex

	pop.l		a6
	pop.l		d6

	tst.w		d6
	beq.s		.sks

	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2

.sks:	dbra		d6,.all

	bra.s		.next

*-------------------------------------------------------*
.stop:

	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_translate,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_ovector,a1
	bsr		strcopy_a1_a2
	move.w		#0,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		#0,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_wall_z,d0
	bsr		append_decimal
	lea		ascii_pov_cvector,a1
	bsr		strcopy_a1_a2	
	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_cbracket,a1		: }\n
	bsr		strcopy_a1_a2
	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2
	rts

*-------------------------------------------------------*
output_vertex:
*-------------------------------------------------------*
	move.l		Vertex_Array,a0
	lea		(a0,d0.w*4),a5
*-------------------------------------------------------*
	lea		ascii_pov_ovector,a1
	bsr		strcopy_a1_a2
	move.w		(a5)+,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		(a5)+,d0
	bsr		append_decimal
	lea		ascii_pov_cvector,a1
	bsr		strcopy_a1_a2
	rts

*-------------------------------------------------------*
output_triangle:
*-------------------------------------------------------*
	lea		ascii_pov_triangle,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_obracket,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_ovector,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_x1,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_y1,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_z1,d0
	bsr		append_decimal
	lea		ascii_pov_cvector,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_ovector,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_x2,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_y2,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_z2,d0
	bsr		append_decimal
	lea		ascii_pov_cvector,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_ovector,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_x3,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_y3,d0
	bsr		append_decimal
	lea		ascii_pov_separator,a1
	bsr		strcopy_a1_a2
	move.w		pov_tri_z3,d0
	bsr		append_decimal
	lea		ascii_pov_cvector,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_cbracket,a1
	bsr		strcopy_a1_a2
	lea		ascii_pov_newline,a1
	bsr		strcopy_a1_a2
	rts

*-------------------------------------------------------*
strcopy_a1_a2:
*-------------------------------------------------------*
.char:	move.b		(a1)+,(a2)+
	bne.s		.char
	subq.l		#1,a1
	subq.l		#1,a2
	rts

*-------------------------------------------------------*
*	Append decimal number to (a1)			*
*-------------------------------------------------------*
*	d0.i value / d1.i digits			*
*-------------------------------------------------------*
append_decimal:
*-------------------------------------------------------*
	ext.l		d0
	bpl.s		.pos
	move.b		#'-',(a2)+
	neg.l		d0
.pos:	moveq		#0,d1
	lea		asciistack,a1
	clr.b		-(a1)
	moveq		#'0',d2
	moveq		#10,d3
.build:	moveq		#0,d5
	divu.l		d3,d5:d0
	add.w		d2,d5
	move.b		d5,-(a1)
	subq.l		#1,d1
	bgt.s		.build
	tst.l		d0
	bne.s		.build
.copy:	move.b		(a1)+,(a2)+
	bne.s		.copy
	subq.l		#1,a2
	rts

*-------------------------------------------------------*
*	Link edge to sector for floor			*
*-------------------------------------------------------*
link_sector_edge:
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
*	Look up edges for this sector			*
*-------------------------------------------------------*
	lea		pov_sector_pointers,a0
	move.w		pov_sector_code,d0
	mulu.w		#pov_edge_slen,d0
	add.l		d0,a0
	move.l		pov_edge_next(a0),d1
	bne.s		.got_edges
*-------------------------------------------------------*
*	No edge list is available			*
*-------------------------------------------------------*
.no_edges:
*-------------------------------------------------------*
*	Clear extra fields				*
*-------------------------------------------------------*
	clr.l		pov_edge_prev(a0)
	clr.w		pov_edge_p1(a0)
	clr.w		pov_edge_p2(a0)
*-------------------------------------------------------*
*	Find slot for new edge				*
*-------------------------------------------------------*
	lea		pov_edge_buffer,a2
	move.w		pov_used_edges,d2
	move.w		d2,d3
	addq.w		#1,d3
	move.w		d3,pov_used_edges
	mulu.w		#pov_edge_slen,d2
	add.l		d2,a2
*-------------------------------------------------------*
*	Load point fields with edge data		*
*-------------------------------------------------------*
	move.w		point1,pov_edge_p1(a2)
	move.w		point2,pov_edge_p2(a2)
	move.l		gbl_newsector_ptr(a6),pov_edge_sectorptr(a2)
*-------------------------------------------------------*
*	Link edge into sector using new slot		*
*-------------------------------------------------------*
	move.l		a0,pov_edge_prev(a2)
	move.l		a2,pov_edge_next(a0)
*-------------------------------------------------------*
*	Last edge - no more links			*
*-------------------------------------------------------*
	clr.l		pov_edge_next(a2)
*-------------------------------------------------------*
	bra.s		.edge_done
*-------------------------------------------------------*
*	Found existing edge list			*
*-------------------------------------------------------*
.got_edges:
*-------------------------------------------------------*
	move.l		d1,a1
*-------------------------------------------------------*
*	Find slot for new edge				*
*-------------------------------------------------------*
	lea		pov_edge_buffer,a2
	move.w		pov_used_edges,d2
	move.w		d2,d3
	addq.w		#1,d3
	move.w		d3,pov_used_edges
	mulu.w		#pov_edge_slen,d2
	add.l		d2,a2
*-------------------------------------------------------*
*	Load point fields with edge data		*
*-------------------------------------------------------*
	move.w		point1,pov_edge_p1(a2)
	move.w		point2,pov_edge_p2(a2)
	move.l		gbl_newsector_ptr(a6),pov_edge_sectorptr(a2)
*-------------------------------------------------------*
*	Link edge into sector using new slot		*
*-------------------------------------------------------*
	move.l		a0,pov_edge_prev(a2)
	move.l		a1,pov_edge_next(a2)
	move.l		a2,pov_edge_next(a0)
	move.l		a2,pov_edge_prev(a1)
*-------------------------------------------------------*
.edge_done:
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	rts
	
*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

ascii_pov_triangle:	dc.b	'triangle ',0

ascii_pov_translate:	dc.b	'translate ',0

ascii_pov_mesh:		dc.b	'mesh ',0

ascii_pov_polygon:	dc.b	'polygon ',0

ascii_pov_obracket:	dc.b	'{ ',0

ascii_pov_ovector:	dc.b	'< ',0

ascii_pov_cbracket:	dc.b	' }',0

ascii_pov_cvector:	dc.b	' >',0

ascii_pov_separator:	dc.b	', ',0

ascii_pov_newline:	dc.b	13,10,0

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

mesh_buffer_ptr:	ds.l	1
flats:			ds.l	1

pov_wall_z:		ds.l	1
pov_sub_size_ptr:	ds.l	1
pov_tri_ps:		ds.l	1
pov_vtx_count:		ds.l	1
pov_sector_code:	ds.l	1

point1:			ds.l	1
point2:			ds.l	1

pov_wall_x1:		ds.l	1
pov_wall_y1:		ds.l	1
pov_wall_z1:		ds.l	1

pov_wall_x2:		ds.l	1
pov_wall_y2:		ds.l	1
pov_wall_z2:		ds.l	1

pov_tri_x1:		ds.l	1
pov_tri_y1:		ds.l	1
pov_tri_z1:		ds.l	1

pov_tri_x2:		ds.l	1
pov_tri_y2:		ds.l	1
pov_tri_z2:		ds.l	1

pov_tri_x3:		ds.l	1
pov_tri_y3:		ds.l	1
pov_tri_z3:		ds.l	1

pov_tri_p1:		ds.l	1
pov_tri_p2:		ds.l	1
pov_tri_p3:		ds.l	1

			ds.b	256
asciistack:		ds.l	1

pov_used_edges:		ds.l	1

pov_sector_pointers	ds.b	pov_edge_slen*2048

pov_edge_buffer:	ds.b	pov_edge_slen*16384

flat_buffer:		ds.w	4*1024

mesh_buffer:		ds.b	256*1024


*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
