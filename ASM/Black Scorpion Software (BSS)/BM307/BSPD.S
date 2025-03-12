*=======================================================*
*	BSP-descent: updated 12/06/97			*
*=======================================================*

attrib_upperunpeg	=	3
attrib_lowerunpeg	=	4

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Descend Binary Space Partitioning Tree		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	txtlong
*-------------------------------------------------------*
descend_bsp:
*-------------------------------------------------------*
	lea		display_struct,a6
*-------------------------------------------------------*
	addq.l		#1,gbl_bsp_pass(a6)
*-------------------------------------------------------*
*	Place start & terminator on heap and descend	*
*-------------------------------------------------------*
	move.l		sp,bsp_return
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
	tst.w		gbl_free_columns(a6)
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
*-------------------------------------------------------*
*	Set up floor & ceiling heights for this sector	*
*-------------------------------------------------------*
	move.l		gbl_sectors_ptr(a6),a0
	move.w		d0,d1
	mulu.w		#sector_len,d1
	add.l		d1,a0
	move.l		a0,gbl_newsector_ptr(a6)
*-------------------------------------------------------*
	move.w		sector_floorht(a0),gbl_floor_height(a6)
	move.w		sector_ceilht(a0),gbl_ceiling_height(a6)
	move.w		sector_ftns(a0),gbl_floor_tex(a6)
	move.w		sector_ctns(a0),gbl_ceiling_tex(a6)
*-------------------------------------------------------*
*	Set up segment-heap for loop			*
*-------------------------------------------------------*
.skip:	move.l		d4,d2
	move.w		d2,gbl_seg_start(a6)
	move.w		d3,gbl_seg_number(a6)
	beq		end_segment
*-------------------------------------------------------*
*	Process simple lighting effects (temporary!)	*
*-------------------------------------------------------*
	bsr		process_lighting
*-------------------------------------------------------*
	ifd		sprites
*-------------------------------------------------------*
*	Look up thing-list for this sector		*
*-------------------------------------------------------*
	move.l		stlists_ptr,a0
	lea		(a0,d0.w*8),a0
	move.l		stl_list(a0),d1
	beq.s		.no_things
*-------------------------------------------------------*
*	Sector contains things				*
*-------------------------------------------------------*
	move.l		gbl_bsp_pass(a6),d2
	cmp.l		stl_pass(a0),d2
	beq.s		.no_things
	move.l		d2,stl_pass(a0)
*-------------------------------------------------------*
*	First hit - process sprites in this sector	*
*-------------------------------------------------------*
	bsr		process_things
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*
.no_things:
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
	move.l		gbl_vertices_ptr(a6),a0
	clr.l		d0
	move.w		linedef_from(a2),d0
	clr.l		d1
	move.w		linedef_to(a2),d1
	clr.l		d5
	move.w		vtx_x(a0,d0.l*4),d5
	clr.l		d6
	move.w		vtx_x(a0,d1.l*4),d6
	move.w		vtx_y(a0,d0.l*4),d0
	sub.w		d5,d6			; x2-x1
	move.w		d5,gbl_seg_sx1(a6)
	move.w		vtx_y(a0,d1.l*4),d1
	swap		d5
	sub.l		gbl_player_x(a6),d5	; x1-px
	sub.w		d0,d1			; y2-y1
	move.w		d0,gbl_seg_sy1(a6)
	swap		d0
	sub.l		gbl_player_y(a6),d0	; y1-py
	swap		d6
	swap		d1
	move.l		d6,gbl_seg_sdx(a6)
	muls.l		d6,d6:d0		; (x2-x1)*(y1-py)
	move.l		d1,gbl_seg_sdy(a6)
	muls.l		d5,d5:d1		; (y2-y1)*(x1-px)
	cmp.l		d6,d5
	bpl		invisible
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Segment is visible				*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
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
	moveq		#projectwall_command,d0
	dspwaitwrite.0	(a2)
	move.b		d0,1(a3)
	dspwaitwrite.0	(a2)
	move.w		(a0)+,(a3)
	dspwaitwrite.1	(a2)
	move.w		(a0)+,(a3)
	dspwaitwrite.1	(a2)
	move.w		(a1)+,(a3)
	dspwaitwrite.1	(a2)
	move.w		(a1)+,(a3)
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
*	Validate projected wall				*
*-------------------------------------------------------*
	lea		DSPHostStat.w,a2
	lea		DSPHost32.w,a4
	dspwaitread.0	(a2)
	tst.b		3(a4)
	beq		end_segment
*-------------------------------------------------------*
*	Read back projected wall coordinates		*
*-------------------------------------------------------*
	dspwaitread.0	(a2)
	move.l		(a4),d3
	dspwaitread.1	(a2)
	move.l		(a4),d4
	dspwaitread.1	(a2)
	move.l		(a4),d5
	dspwaitread.1	(a2)
	move.l		(a4),d6
	dspwaitread.1	(a2)
	move.l		(a4),d1
	dspwaitread.1	(a2)
	move.l		(a4),d2
*-------------------------------------------------------*
	clr.l		gbl_seg_texheight(a6)
	clr.w		gbl_seg_u_index(a6)
	clr.w		gbl_seg_v_index(a6)
*-------------------------------------------------------*
	ifd		sprites
*-------------------------------------------------------*
*	Access sprite list for this sector		*
*-------------------------------------------------------*
	lea		upt_start,a0
	move.l		upt_next(a0),a0
*-------------------------------------------------------*
*	Validate sprite list				*
*-------------------------------------------------------*
	tst.l		upt_next(a0)
	beq		.stop_sprite
*-------------------------------------------------------*
*	Draw any sprites covering this seg		*
*-------------------------------------------------------*
	movem.l		d1-d6,-(sp)
*-------------------------------------------------------*
	cmp.l		d4,d6
	bpl.s		.zmax
	move.l		d4,d6
.zmax:	lsl.l		#8,d6
	move.l		d6,gbl_spr_zmax(a6)
*-------------------------------------------------------*
	lsr.l		#8,d3
	lsr.l		#8,d5
	tst.w		d3
	bpl.s		.cwi1
	clr.w		d3
.cwi1:	move.w		d3,gbl_spr_wx1(a6)
	move.w		gbl_width(a6),d3
	cmp.w		d3,d5
	ble.s		.cwi2
	move.w		d3,d5
.cwi2	move.w		d5,gbl_spr_wx2(a6)
*-------------------------------------------------------*
.next_sprite:
*-------------------------------------------------------*
*	Stop processing when dummy link is reached	*
*-------------------------------------------------------*
	tst.l		upt_next(a0)
	beq		.last_sprite
*-------------------------------------------------------*
*	Begin processing spans for this sprite		*
*-------------------------------------------------------*
	move.l		upt_spanlink+ups_next(a0),a1
*-------------------------------------------------------*
.next_span:
*-------------------------------------------------------*
*	Stop processing when dummy link is reached	*
*-------------------------------------------------------*
	tst.l		ups_slot(a1)
	beq		.last_span
*-------------------------------------------------------*
*	Skip spans outside wall segment			*
*-------------------------------------------------------*
	move.w		gbl_spr_wx1(a6),d3
	move.w		gbl_spr_wx2(a6),d4
	cmp.w		ups_i2(a1),d3
	bpl		.skip_span
*-------------------------------------------------------*
*	Stop checking spans if past right edge		*
*-------------------------------------------------------*
	cmp.w		ups_i1(a1),d4
	ble		.last_span
*-------------------------------------------------------*
*	Clip span range to wall segment			*
*-------------------------------------------------------*
	cmp.w		ups_i1(a1),d3
	bpl.s		.c1
	move.w		ups_i1(a1),d3
.c1:	cmp.w		ups_i2(a1),d4
	ble.s		.c2
	move.w		ups_i2(a1),d4
.c2:	move.w		d3,gbl_spr_sx1(a6)
	move.w		d4,gbl_spr_sx2(a6)
*-------------------------------------------------------*
*	Discard sprites entirely beyond wall's max-z	*
*-------------------------------------------------------*
	move.l		upt_z(a0),d6
	cmp.l		gbl_spr_zmax(a6),d6
	bpl.s		.invisible_sprite
*-------------------------------------------------------*
*	Discard sprites on wrong side of wall		*
*-------------------------------------------------------*
	move.l		upt_thing_ptr(a0),a2
	move.w		gbl_seg_sx1(a6),d1
	sub.w		Thing_x(a2),d1
	move.w		gbl_seg_sy1(a6),d2
	sub.w		Thing_y(a2),d2
	muls.w		gbl_seg_sdy(a6),d1
	muls.w		gbl_seg_sdx(a6),d2
	cmp.l		d2,d1
	bmi.s		.visible_span
*-------------------------------------------------------*
.invisible_sprite:
*-------------------------------------------------------*
*	Cull invisible spans behind solid walls		*
*-------------------------------------------------------*
	tst.b		gbl_line_2side(a6)
	beq		.invisible_span
	bra		.last_span
*-------------------------------------------------------*
.visible_span:
*-------------------------------------------------------*
	push.l		a1
	push.l		a0
*-------------------------------------------------------*
*	Load sprite (clipped) i1 & i2			*
*-------------------------------------------------------*
	move.l		upt_i1(a0),gbl_seg_i1(a6)
	move.l		upt_i2(a0),gbl_seg_i2(a6)
*-------------------------------------------------------*
*	Load sprite z's					*
*-------------------------------------------------------*
	move.l		upt_z(a0),d3
	move.l		d3,gbl_seg_rz2(a6)
	move.l		d3,gbl_seg_rz1(a6)
	move.l		d3,gbl_seg_z1(a6)
	move.l		d3,gbl_seg_z2(a6)
*-------------------------------------------------------*
*	Determine texture height			*
*-------------------------------------------------------*
	move.l		upt_width(a0),gbl_spr_umag(a6)
	move.w		upt_id(a0),d0
	bclr		#14,d0
	sne		gbl_spr_reflect(a6)
	move.w		d0,gbl_seg_tex(a6)
*-------------------------------------------------------*
*	Texture is transparent				*
*-------------------------------------------------------*
	move.b		#trans_command,gbl_seg_type(a6)
	move.b		#1,gbl_seg_opaque(a6)
*-------------------------------------------------------*
*	Determine height				*
*-------------------------------------------------------*
	move.l		upt_y1(a0),gbl_seg_y1(a6)
	move.l		upt_y2(a0),gbl_seg_y2(a6)
*-------------------------------------------------------*
*	Set up light level for this span		*
*-------------------------------------------------------*
	move.l		upt_light(a0),d0
	bsr		new_light_level
*-------------------------------------------------------*
*	Render span					*
*-------------------------------------------------------*
	bsr		add_sprite_segment
*-------------------------------------------------------*
	pop.l		a0
	pop.l		a1
*-------------------------------------------------------*
.invisible_span:
*-------------------------------------------------------*
*	Advance to next span before updating links	*
*-------------------------------------------------------*
	move.l		ups_next(a1),d7
*-------------------------------------------------------*
*	Add span right-remainder to span list		*
*-------------------------------------------------------*
	move.w		gbl_spr_sx2(a6),d1
	move.w		ups_i2(a1),d2
	cmp.w		d1,d2
	beq.s		.no_right_remainder
	bsr		add_span_fragment
*-------------------------------------------------------*
.no_right_remainder:
*-------------------------------------------------------*
*	Add span left-remainder to span list		*
*-------------------------------------------------------*
	move.w		ups_i1(a1),d1
	move.w		gbl_spr_sx1(a6),d2
	cmp.w		d1,d2
	beq.s		.no_left_remainder
	bsr		add_span_fragment
*-------------------------------------------------------*
.no_left_remainder:
*-------------------------------------------------------*
*	Remove span from linked list			*
*-------------------------------------------------------*
	move.l		ups_prev(a1),a2
	move.l		ups_next(a1),a3
	move.l		a3,ups_next(a2)
	move.l		a2,ups_prev(a3)
*-------------------------------------------------------*
*	Return span to freetable			*
*-------------------------------------------------------*
	lea		ups_freetable,a4
	move.l		gbl_ups_free(a6),d0
	lea		(a4,d0.l*4),a4
	addq.l		#1,d0
	move.l		a1,(a4)
	move.l		d0,gbl_ups_free(a6)
	subq.l		#1,gbl_ups_used(a6)
*-------------------------------------------------------*
*	Find last used span				*
*-------------------------------------------------------*
	lea		ups_usedtable,a4
	move.l		gbl_ups_used(a6),d0
	lea		(a4,d0.l*4),a4
*-------------------------------------------------------*
*	Skip patching stage if this is last span	*
*-------------------------------------------------------*
	move.l		ups_slot(a1),a2
	cmp.l		a2,a4
	beq.s		.span_done
*-------------------------------------------------------*
*	Otherwise, relocate slot to patch hole		* 
*-------------------------------------------------------*
	move.l		(a4),a3
	move.l		a3,(a2)
*-------------------------------------------------------*
*	Fix backlink to relocated span slot		*
*-------------------------------------------------------*
	move.l		a2,ups_slot(a3)
*-------------------------------------------------------*
.span_done:
*-------------------------------------------------------*
*	Restore running pointer				*
*-------------------------------------------------------*
	move.l		d7,a1
*-------------------------------------------------------*
*	Decrement span count for this sprite		*
*-------------------------------------------------------*
	subq.l		#1,upt_spans(a0)
*-------------------------------------------------------*
*	If spans remain, continue processing		*
*-------------------------------------------------------*
	bne		.next_span
*-------------------------------------------------------*
*	Otherwise, remove sprite from [upt-list]	*
*-------------------------------------------------------*
	move.l		upt_thing_ptr(a0),a1
	bclr		#7,Thing_attr(a1)
*-------------------------------------------------------*
*	Unlink thing from list				*
*-------------------------------------------------------*
	move.l		upt_prev(a0),a2
	move.l		upt_next(a0),a3
	move.l		a2,upt_prev(a3)
	move.l		a3,upt_next(a2)
*-------------------------------------------------------*
*	Return thing to freetable			*
*-------------------------------------------------------*
	lea		upt_freetable,a4
	move.l		gbl_upt_free(a6),d0
	lea		(a4,d0.l*4),a4
	addq.l		#1,d0
	move.l		a0,(a4)
	move.l		d0,gbl_upt_free(a6)
	subq.l		#1,gbl_upt_used(a6)
*-------------------------------------------------------*
*	Find last used span				*
*-------------------------------------------------------*
	lea		upt_usedtable,a4
	move.l		gbl_upt_used(a6),d0
	lea		(a4,d0.l*4),a4
*-------------------------------------------------------*
*	Skip patching stage if this is last span	*
*-------------------------------------------------------*
	move.l		upt_slot(a0),a2
	cmp.l		a2,a4
	beq.s		.thing_done
*-------------------------------------------------------*
*	Otherwise, relocate slot to patch hole		* 
*-------------------------------------------------------*
	move.l		(a4),a3
	move.l		a3,(a2)
*-------------------------------------------------------*
*	Fix backlink to relocated span slot		*
*-------------------------------------------------------*
	move.l		a2,upt_slot(a3)
*-------------------------------------------------------*
.thing_done:
*-------------------------------------------------------*
	bra.s		.last_span
*-------------------------------------------------------*
.skip_span:
*-------------------------------------------------------*
*	Advance span					*
*-------------------------------------------------------*
	move.l		ups_next(a1),a1
	bra		.next_span
*-------------------------------------------------------*
*	Stop processing this sprite
*-------------------------------------------------------*
.last_span:
*-------------------------------------------------------*
	move.l		upt_next(a0),a0
	bra		.next_sprite
*-------------------------------------------------------*
.last_sprite:
*-------------------------------------------------------*
	movem.l		(sp)+,d1-d6
*-------------------------------------------------------*
.stop_sprite:
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*
*	Write coordinates into addwall struct		*
*-------------------------------------------------------*
	lsl.l		#8,d1
	move.l		d1,gbl_seg_rz2(a6)
	lsl.l		#8,d2
	move.l		d2,gbl_seg_rz1(a6)
	lsl.l		#8,d3
	move.l		d3,gbl_seg_i1(a6)
	lsl.l		#8,d4
	move.l		d4,gbl_seg_z1(a6)
	lsl.l		#8,d5
	move.l		d5,gbl_seg_i2(a6)
	lsl.l		#8,d6
	move.l		d6,gbl_seg_z2(a6)
*-------------------------------------------------------*

	move.l		gbl_seg_sidedef(a6),a3
	move.l		gbl_seg_adj_sec(a6),a4

	move.b		#0,gbl_seg_opaque(a6)

*-------------------------------------------------------*
*	Set light level for segment			*
*-------------------------------------------------------*
	move.l		gbl_sector_light(a6),d0
	bsr		new_light_level
*-------------------------------------------------------*
*	If wall is one-sided, it must be solid		*
*-------------------------------------------------------*
	tst.b		gbl_line_2side(a6)
	beq		sector_wall

*-------------------------------------------------------*
*	Check for lower wall texture			*
*-------------------------------------------------------*
lower_texture:
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
	bne.s		add_lower
*-------------------------------------------------------*
*	If both flats are sky texture, don't render	*
*-------------------------------------------------------*
;	cmp.w		sky_index,d3
;	beq		ignore_lower
*-------------------------------------------------------*
*	Texture *must* be rendered if OF <> AF		*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bne.s		add_lower
*-------------------------------------------------------*
*	Adjoining sectors match in texture and height	* 
*-------------------------------------------------------*
.lower_match:
*-------------------------------------------------------*
*	Force wall if lighting methods differ		*
*-------------------------------------------------------*
	move.w		sector_special(a4),d3
	cmp.w		sector_special(a5),d3
	bne.s		add_lower
*-------------------------------------------------------*
*	Ignore render wall if light levels match	*
*-------------------------------------------------------*
	move.w		sector_light(a4),d3
	cmp.w		sector_light(a5),d3
	beq		ignore_lower
*-------------------------------------------------------*
*	Lower texture visible, so it must be valid	*
*-------------------------------------------------------*
add_lower:
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
	ble.s		ignore_lower
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
	bsr		add_wall_segment 
*-------------------------------------------------------*
*	Early abort check				*
*-------------------------------------------------------*
	tst.w		gbl_free_columns(a6)
	beq		end_segment		 
*-------------------------------------------------------*
ignore_lower:
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Check for upper wall texture			*
*-------------------------------------------------------*
upper_texture:
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
	bne.s		add_upper
*-------------------------------------------------------*
*	If both flats are sky texture, don't render	*
*-------------------------------------------------------*
	cmp.w		sky_index,d3
	beq		ignore_upper
*-------------------------------------------------------*
*	Texture *must* be rendered if OC <> AC		*
*-------------------------------------------------------*
	cmp.w		d1,d2
	bne.s		add_upper
*-------------------------------------------------------*
*	Adjoining sectors match in texture and height	* 
*-------------------------------------------------------*
.upper_match:
*-------------------------------------------------------*
*	Force wall if lighting methods differ		*
*-------------------------------------------------------*
	move.w		sector_special(a4),d3
	cmp.w		sector_special(a5),d3
	bne.s		add_upper
*-------------------------------------------------------*
*	Ignore render wall if light levels match	*
*-------------------------------------------------------*
	move.w		sector_light(a4),d3
	cmp.w		sector_light(a5),d3
	beq		ignore_upper
*-------------------------------------------------------*
*	Upper texture visible, so it must be valid	*
*-------------------------------------------------------*
add_upper:
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
	bgt.s		.clip
	move.l		d2,d1
*-------------------------------------------------------*
*	Ignore ceiling if lower than player's view	*
*-------------------------------------------------------*
	bge.s		ignore_upper
*-------------------------------------------------------*
*	Load wall structure				*
*-------------------------------------------------------*
.clip:	move.w		d0,gbl_seg_tex(a6)
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
	bsr		add_wall_segment 
*-------------------------------------------------------*
*	Early abort check				*
*-------------------------------------------------------*
	tst.w		gbl_free_columns(a6)
	beq		end_segment		 
*-------------------------------------------------------*
ignore_upper:
*-------------------------------------------------------*

*-------------------------------------------------------*
sector_join:	
*-------------------------------------------------------*
*	Check for normal texture			*
*-------------------------------------------------------*
	move.w		sidedef_mtns(a3),d2
	bmi		sector_window
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
	beq		sector_window
*-------------------------------------------------------*
	move.l		d1,gbl_seg_y1(a6)
	move.l		d2,gbl_seg_y2(a6)
	bsr		add_wall_segment
*-------------------------------------------------------*
	bra		sector_window

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
	beq		sector_window
*-------------------------------------------------------*
	move.l		d1,gbl_seg_y1(a6)
	move.l		d2,gbl_seg_y2(a6)
	bsr		add_wall_segment
*-------------------------------------------------------*
	bra		sector_window

*-------------------------------------------------------*
sector_wall:	
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
	addq.w		#1,gbl_seg_start(a6)
	subq.w		#1,gbl_seg_number(a6)
	beq.s		end_ssector
	tst.w		gbl_free_columns(a6)
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
	move.l		gbl_nodes_ptr(a6),a1
	mulu.w		#node_len,d0
	add.l		d0,a1
*-------------------------------------------------------*
*	Inverse descent rules for left side of tree	*
*-------------------------------------------------------*
*	(dy*(x1-Px))) => ((dx*(y1-Py)) ?		*
*-------------------------------------------------------*
	clr.l		d2
	move.w		node_dx(a1),d2
	clr.l		d0
	move.w		node_x(a1),d0
	clr.l		d3
	move.w		node_dy(a1),d3
	clr.l		d1
	move.w		node_y(a1),d1
	add.w		d2,d0			; x2 = (x1+dx)
	swap		d0
	sub.l		gbl_player_x(a6),d0	; (x2-px)
	add.w		d3,d1			; y2 = (y1+dy)
	swap		d1
	sub.l		gbl_player_y(a6),d1	; (xy-py)
	swap		d2
	swap		d3
	muls.l		d2,d2:d1		; (y2-py) * dx
	muls.l		d3,d3:d0		; (x2-px) * dy
	cmp.l		d3,d2 
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
	dspwaitwrite.1	(a2)
	move.w		d0,(a3)
	move.w		(a4)+,d0
	dspwaitwrite.1	(a2)
	move.w		d0,(a3)
	move.w		(a4)+,d0
	dspwaitwrite.1	(a2)
	move.w		d0,(a3)
	dspwaitread.0	(a2)
	tst.w		(a3)
	rts

*-------------------------------------------------------*
add_span_fragment:
*-------------------------------------------------------*
*	Find free slot in unprocessed-span table	*
*-------------------------------------------------------*
	move.l		gbl_ups_free(a6),d0
	beq		.span_fault
	lea		ups_freetable,a2
	move.l		-4(a2,d0.l*4),a2
*-------------------------------------------------------*
*	Create new span					*
*-------------------------------------------------------*
	move.w		d1,ups_i1(a2)
	move.w		d2,ups_i2(a2)
*-------------------------------------------------------*
*	Link new span list to dummy span element	*
*-------------------------------------------------------*
	move.l		ups_next(a1),a3
	move.l		a2,ups_next(a1)
	move.l		a2,ups_prev(a3)
	move.l		a1,ups_prev(a2)
	move.l		a3,ups_next(a2)
*-------------------------------------------------------*
*	Allocate span as used & create backlink		*
*-------------------------------------------------------*
	move.l		gbl_ups_used(a6),d0
	lea		ups_usedtable,a4
	lea		(a4,d0.l*4),a4
	move.l		a4,ups_slot(a2)
	addq.l		#1,d0
	move.l		a2,(a4)
	move.l		d0,gbl_ups_used(a6)
	subq.l		#1,gbl_ups_free(a6)
*-------------------------------------------------------*
*	Increment spancount for this thing		*
*-------------------------------------------------------*
	addq.l		#1,upt_spans(a0)
*-------------------------------------------------------*
.span_fault:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

bsp_return:		ds.l	1		; BSP stack base

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
