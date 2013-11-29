*=======================================================*
*	Process things: updated 12/06/97		*
*=======================================================*

*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
spritenm_name		rs.l	1
spritenm_n		rs.w	1
spritenm_ne		rs.w	1
spritenm_e		rs.w	1
spritenm_se		rs.w	1
spritenm_s		rs.w	1
spritenm_sw		rs.w	1
spritenm_w		rs.w	1
spritenm_nw		rs.w	1
spritenm_slen		rs.b	0

*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
thingtype_code		rs.l	1
thingtype_name		rs.l	1
thingtype_slen		rs.b	0

*-------------------------------------------------------*
*	Sector thing structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
st_prev			rs.l	1		; previous thing
st_next			rs.l	1		; next thing
st_thing_ptr		rs.l	1		; thing element
st_slen			rs.b	0

*-------------------------------------------------------*
*	Sector thing list structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
stl_list		rs.l	1
stl_pass		rs.l	1
stl_slen		rs.b	0

*-------------------------------------------------------*
*	Unprocessed-span structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
ups_prev		rs.l	1	; previous span
ups_next		rs.l	1	; next span
ups_slot		rs.l	1	; used slot
ups_i1			rs.w	1	; screen i1
ups_i2			rs.w	1	; screen i2
ups_slen		rs.b	0

*-------------------------------------------------------*
*	Unprocessed-thing structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
upt_prev		rs.l	1		; previous thing
upt_next		rs.l	1		; next thing
upt_slot		rs.l	1		; used slot
upt_i1			rs.l	1		; screen i1
upt_i2			rs.l	1		; screen i2
upt_y1			rs.l	1		; screen y1
upt_y2			rs.l	1		; screen y2
upt_x			rs.l	1		; world x
upt_y			rs.l	1		; world y
upt_z			rs.l	1		; world z
upt_id			rs.l	1		; patch id
upt_width		rs.l	1		; patch width
upt_height		rs.l	1		; patch height
upt_thing_ptr		rs.l	1		; thing element
upt_light		rs.l	1		; thing light
upt_spans		rs.l	1		; number of spans
upt_spanlink		rs.b	ups_slen	; dummy span link
upt_slen		rs.b	0

*-------------------------------------------------------*
process_things:
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
*	Process entire list				*
*-------------------------------------------------------*
.next_thing:
*-------------------------------------------------------*
	move.l		d1,a0
*-------------------------------------------------------*
*	Find thing element				*
*-------------------------------------------------------*
	move.l		st_thing_ptr(a0),a1
*-------------------------------------------------------*
*	Ignore previously processed things		*
*-------------------------------------------------------*
	btst		#7,Thing_attr(a1)
	bne		.ignore_thing
*-------------------------------------------------------*
*	Find free slot in unprocessed-thing table	*
*-------------------------------------------------------*
	move.l		gbl_upt_free(a6),d0
	beq		.last_thing
	lea		upt_freetable,a3
	move.l		-4(a3,d0.l*4),a3
*-------------------------------------------------------*
*	Store pointer to thing element			*
*-------------------------------------------------------*
	move.l		a1,upt_thing_ptr(a3)
*-------------------------------------------------------*
*	Find patch-id					*
*-------------------------------------------------------*
	move.w		Thing_type(a1),d0
	lea		spritename_list,a5
	mulu.w		#spritenm_slen,d0
	add.l		d0,a5
	clr.l		d0
	move.w		Thing_angle(a1),d0
	swap		d0
	move.w		pangle,d1
	divu.w		#360,d0
	sub.w		d0,d1
	add.w		#$8000+($10000/16),d1
	moveq		#13,d2
	lsr.w		d2,d1
	move.w		spritenm_n(a5,d1.w*2),d0
	move.w		d0,upt_id(a3)
	bclr		#14,d0
*-------------------------------------------------------*
*	Find patch size					*
*-------------------------------------------------------*
	move.l		graphics_array,a5
	move.l		(a5,d0.w*4),a5
	move.w		tex_height(a5),upt_height(a3)
	move.w		tex_width(a5),upt_width(a3)
*-------------------------------------------------------*
*	Load thing coordinates for 'ProjectSprite'	*
*-------------------------------------------------------*
	move.w		Thing_x(a1),d1
	lea		DSPHostStat.w,a4
	move.w		Thing_y(a1),d2
	lea		DSPHost16.w,a5
	move.w		upt_width(a3),d3
	moveq		#projectsprite_command,d0
	dspwaitwrite.0	(a4)
	move.b		d0,1(a5)
	dspwaitwrite.0	(a4)
	move.w		d1,(a5)		; x
	dspwaitwrite.1	(a4)
	move.w		d2,(a5)		; y
	dspwaitwrite.1	(a4)
	move.w		d3,(a5)		; d
*-------------------------------------------------------*
*	Store light level				*
*-------------------------------------------------------*
	move.l		gbl_sector_light(a6),upt_light(a3)
*-------------------------------------------------------*
*	Read conclusion from 'ProjectSprite'		*
*-------------------------------------------------------*
	lea		DSPHost32.w,a5
	dspwaitread.0	(a4)
	tst.b		3(a5)
	beq		.ignore_thing
*-------------------------------------------------------*
*	Object is at least partially visible so far	*
*-------------------------------------------------------*
	dspwaitread.1	(a4)
	move.l		(a5),d2		; i1
	dspwaitread.1	(a4)
	move.l		(a5),d1		; i2
	dspwaitread.1	(a4)
	move.l		(a5),d3		; z
*-------------------------------------------------------*
*	Store new thing-i1 & thing-i2 & z		*
*-------------------------------------------------------*
	lsl.l		#8,d2
	move.l		d2,upt_i1(a3)	
	swap		d2
	lsl.l		#8,d1
	move.l		d1,upt_i2(a3)	
	swap		d1
	lsl.l		#8,d3
	move.l		d3,upt_z(a3)
*-------------------------------------------------------*
*	Begin with a single span			*
*-------------------------------------------------------*
	move.l		#1,upt_spans(a3)
*-------------------------------------------------------*
*	Add thing to unprocessed-thing list		*
*-------------------------------------------------------*
	lea		upt_start,a5
*-------------------------------------------------------*
*	Find sorted location in [upt-list]		*
*-------------------------------------------------------*
.upt_search:
*-------------------------------------------------------*
	move.l		upt_next(a5),a5
	cmp.l		upt_z(a5),d3
	bgt.s		.upt_search
*-------------------------------------------------------*
.found_slot:
*-------------------------------------------------------*
*	Link unprocessed thing into new slot		*
*-------------------------------------------------------*
	move.l		upt_prev(a5),a4
	move.l		a3,upt_next(a4)
	move.l		a3,upt_prev(a5)
	move.l		a4,upt_prev(a3)
	move.l		a5,upt_next(a3)
*-------------------------------------------------------*
*	Find free slot in unprocessed-span table	*
*-------------------------------------------------------*
	move.l		gbl_ups_free(a6),d0
	beq		.last_thing
	lea		ups_freetable,a2
	move.l		-4(a2,d0.l*4),a2
*-------------------------------------------------------*
*	Create new span					*
*-------------------------------------------------------*
	move.w		d2,ups_i1(a2)
	move.w		d1,ups_i2(a2)
*-------------------------------------------------------*
*	Find thing-y1 & thing-y2			*
*-------------------------------------------------------*
	move.l		gbl_player_height(a6),d0
	move.w		gbl_floor_height(a6),d4
	swap		d4
	clr.w		d4
	move.l		d0,d2
	sub.l		d4,d2
	move.l		d2,d1
	sub.l		upt_height(a3),d1
	move.l		d1,upt_y1(a3)
	move.l		d2,upt_y2(a3)
*-------------------------------------------------------*
*	Link new span list to dummy span element	*
*-------------------------------------------------------*
	lea		upt_spanlink(a3),a4
	clr.l		ups_slot(a4)
	move.l		a2,ups_prev(a4)
	move.l		a2,ups_next(a4)
	move.l		a4,ups_prev(a2)
	move.l		a4,ups_next(a2)
*-------------------------------------------------------*
*	Allocate thing as used & create backlink	*
*-------------------------------------------------------*
	move.l		gbl_upt_used(a6),d0
	lea		upt_usedtable,a4
	lea		(a4,d0.l*4),a4
	move.l		a4,upt_slot(a3)
	addq.l		#1,d0
	move.l		a3,(a4)
	move.l		d0,gbl_upt_used(a6)
	subq.l		#1,gbl_upt_free(a6)
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
*	Indicate thing was processed on this frame	*
*-------------------------------------------------------*
	bset		#7,Thing_attr(a1)
*-------------------------------------------------------*
.ignore_thing:
*-------------------------------------------------------*
	move.l		st_next(a0),d1
	bne		.next_thing
*-------------------------------------------------------*
.last_thing:
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
add_sprite_segment:
*-------------------------------------------------------*
*	Store pointers					*
*-------------------------------------------------------*
	movem.l		a3-a4,-(sp)
*-------------------------------------------------------*
*	Host port registers				*
*-------------------------------------------------------*
	lea		DSPHostStat.w,a4
	lea		DSPHost32.w,a5
*-------------------------------------------------------*
*	Calculate z-span				*
*-------------------------------------------------------*
	move.l		gbl_seg_z1(a6),d1
	move.l		d1,d2
	sub.l		#16384<<16,d1
	move.l		d1,gbl_seg_pz1(a6)
	move.l		d2,gbl_seg_pz2(a6)
*-------------------------------------------------------*
	tst.b		gbl_spr_reflect(a6)
	beq.s		.no_reflect
	exg.l		d1,d2
*-------------------------------------------------------*
.no_reflect:
*-------------------------------------------------------*
	move.l		d2,gbl_seg_rz1(a6)
	move.l		d1,gbl_seg_rz2(a6)
*-------------------------------------------------------*
	move.w		#linear_command,gbl_seg_mode(a6)
*-------------------------------------------------------*
	move.l		gbl_seg_pz1(a6),gbl_seg_t2(a6)
	move.l		gbl_seg_pz2(a6),gbl_seg_t1(a6)
*-------------------------------------------------------*
	moveq		#0,d6
	move.w		gbl_half_height(a6),d6	; (h/2)
	moveq		#0,d0
	move.w		gbl_v_scale(a6),d0	; vscale
	swap		d0
	swap		d6	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Vertical (y) perspective projection		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	y' = y * ( (w/2) / z ) + (h/2)			*
*-------------------------------------------------------*
	move.l		gbl_seg_y1(a6),d1
	move.l		d0,d2
	muls.l		d1,d7:d2
	divs.l		gbl_seg_z1(a6),d7:d2
	add.l		d6,d2
	move.l		d0,d5
	muls.l		d1,d7:d5
	divs.l		gbl_seg_z2(a6),d7:d5
	move.l		gbl_seg_y2(a6),d1
	add.l		d6,d5
	move.l		d0,d3
	muls.l		d1,d7:d3
	divs.l		gbl_seg_z1(a6),d7:d3
	add.l		d6,d3
	move.l		d0,d4
	muls.l		d1,d7:d4
	divs.l		gbl_seg_z2(a6),d7:d4
	add.l		d6,d4
*-------------------------------------------------------*
*	Calculate dy1 & dy2 gradients			*	
*-------------------------------------------------------*
	move.l		gbl_seg_i2(a6),d0
	sub.l		gbl_seg_i1(a6),d0
	sub.l		d2,d5
	swap		d5
	move.w		d5,d6
	ext.l		d6
	clr.w		d5
	divs.l		d0,d6:d5	; dy1 = (ry1-ly1) / (x2-x1)
	move.l		d4,d1
	sub.l		d3,d1
	swap		d1
	move.w		d1,d6
	ext.l		d6
	clr.w		d1
	divs.l		d0,d6:d1	; dy2 = (ry2-ly2) / (x2-x1)
*-------------------------------------------------------*
*	Calculate dz gradient				*
*-------------------------------------------------------*
	move.l		gbl_seg_t2(a6),d4
	sub.l		gbl_seg_t1(a6),d4
	swap		d4
	move.w		d4,d6
	clr.w		d4
	ext.l		d6
	divs.l		d0,d6:d4
	move.l		d4,gbl_seg_ti(a6)
*-------------------------------------------------------*
	move.l		gbl_seg_i1(a6),d7
*-------------------------------------------------------*
*	Find screen i1 (d7)				*
*-------------------------------------------------------*
	move.l		d7,d6
	cmp.l		gbl_spr_sx1(a6),d6
	bpl.s		.noc
	move.l		gbl_spr_sx1(a6),d7
.noc:	clr.w		d7
*-------------------------------------------------------*
	swap		d7
	move.l		d7,a3
	swap		d7
*-------------------------------------------------------*
*	Find (screen i1 - real i1) (a2)			*
*-------------------------------------------------------*
	sub.l		#$ffff,d6
	sub.l		d7,d6
	move.l		d6,a2	
*-------------------------------------------------------*
*	Calculate new clipped y1 & y2			*
*-------------------------------------------------------*
	move.l		a2,d6
	muls.l		d5,d7:d6
	move.w		d7,d6
	swap		d6
	sub.l		d6,d2		; y1 = y1 - (x1*dy1)
	move.l		a2,d6
	muls.l		d1,d7:d6
	move.w		d7,d6
	swap		d6
	sub.l		d6,d3		; y2 = y2 - (x1*dy2)
*-------------------------------------------------------*
*	Calculate new clipped z1			*
*-------------------------------------------------------*
	move.l		gbl_seg_t2(a6),d6
	sub.l		gbl_seg_t1(a6),d6	; (t2-t1)
	move.l		a2,d0
	muls.l		d0,d7:d6		; (t2-t1) * x1
	move.l		gbl_seg_i2(a6),d0
	sub.l		gbl_seg_i1(a6),d0	; (x2-x1)
	divs.l		d0,d7:d6		; (x1*dz) = ((t2-t1) * x1) / (x2-x1)
	move.l		gbl_seg_t1(a6),d0
	sub.l		d6,d0			; z1 = z1 - (x1*dz)
	move.l		d0,gbl_seg_t1(a6)
*-------------------------------------------------------*
	move.l		a3,d7
*-------------------------------------------------------*
*	Load results into local loop registers		*	
*-------------------------------------------------------*
	move.l		d2,gbl_seg_y1a(a6)
	move.l		d3,gbl_seg_y2a(a6)
	move.l		d5,gbl_seg_y1i(a6)
	move.l		d1,gbl_seg_y2i(a6)
*-------------------------------------------------------*
*	Calculate t-factor				*
*-------------------------------------------------------*
	move.l		gbl_spr_umag(a6),d6
	move.l		gbl_seg_rz2(a6),d1
	sub.l		gbl_seg_rz1(a6),d1
	move.l		gbl_seg_pz2(a6),d0
	sub.l		gbl_seg_rz1(a6),d0
	muls.l		d6,d2:d0
	divs.l		d1,d2:d0
	move.l		d0,gbl_seg_tu2(a6)
	move.l		gbl_seg_pz1(a6),d0
	sub.l		gbl_seg_rz1(a6),d0
	muls.l		d6,d2:d0
	divs.l		d1,d2:d0
	move.l		d0,gbl_seg_tu1(a6)
*-------------------------------------------------------*
*	Clip wall against right edge			*
*-------------------------------------------------------*
	move.w		gbl_seg_i2(a6),d6
	move.w		gbl_spr_sx2(a6),d0
	cmp.w		d0,d6
	bmi.s		.x2in
	move.w		d0,d6
.x2in:	move.w		d6,gbl_seg_clip_i2(a6)
*-------------------------------------------------------*
*	Ignore degenerate walls				*
*-------------------------------------------------------*
	cmp.w		d7,d6
	ble		.skip
*-------------------------------------------------------*
	lea		DSPHost16.w,a2
	lea		load_real,a3
*-------------------------------------------------------*
*	Load wall command				*
*-------------------------------------------------------*
	move.w		gbl_seg_mode(a6),d0
	dspwaitwrite.0	(a4)
	move.w		d0,(a2)
*-------------------------------------------------------*
*	Load wall type					*
*-------------------------------------------------------*
	move.b		gbl_seg_type(a6),d0
	dspwaitwrite.0	(a4)
	move.b		d0,1(a2)
*-------------------------------------------------------*
*	Load y-increments and accumulators (16.16)	*
*-------------------------------------------------------*
	move.l		gbl_seg_y1a(a6),d0
	jsr		(a3)
	move.l		gbl_seg_y1i(a6),d0
	jsr		(a3)
	move.l		gbl_seg_y2a(a6),d0
	jsr		(a3)
	move.l		gbl_seg_y2i(a6),d0
	jsr		(a3)
*-------------------------------------------------------*
*	Load wall t-factor & increment (16.16)		*
*-------------------------------------------------------*
	move.l		gbl_seg_t1(a6),d0
	jsr		(a3)
	move.l		gbl_seg_ti(a6),d0
	jsr		(a3)
*-------------------------------------------------------*
*	Load wall pz1 & pz2 (16.8)			*
*-------------------------------------------------------*
	move.l		gbl_seg_pz2(a6),d1
	move.l		gbl_seg_pz1(a6),d2
	asr.l		#8,d1
	dspwaitwrite.0	(a4)
	move.l		d1,(a5)
	asr.l		#8,d2
	dspwaitwrite.0	(a4)
	move.l		d2,(a5)
*-------------------------------------------------------*
*	Retrieve texture size from wall_id		*
*-------------------------------------------------------*
	move.w		#512,d1
	move.w		#512,d2
	move.w		gbl_seg_tex(a6),d0
	bmi.s		.err
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_height(a0),d2
*-------------------------------------------------------*
*	Load texture width & height (16)		*
*-------------------------------------------------------*
.err:	dspwaitwrite.0	(a4)
	move.w		d1,(a2)
	dspwaitwrite.0	(a4)
	move.w		d2,(a2)
*-------------------------------------------------------*
*	Load wall u-magnitude (16.8)			*
*-------------------------------------------------------*
	move.l		gbl_seg_tu2(a6),d0
	sub.l		gbl_seg_tu1(a6),d0
	asr.l		#8,d0
	dspwaitwrite.0	(a4)
	move.l		d0,(a5)
*-------------------------------------------------------*
*	Load wall u-offset (16.8)			*
*-------------------------------------------------------*
	move.l		gbl_seg_tu1(a6),d0
	sub.l		gbl_spr_umag(a6),d0
	sub.l		gbl_seg_u_index(a6),d0
	asr.l		#8,d0
	dspwaitwrite.0	(a4)
	move.l		d0,(a5)
*-------------------------------------------------------*
*	Load wall v-magnitude (16)			*
*-------------------------------------------------------*
	move.w		gbl_seg_y2(a6),d0
	sub.w		gbl_seg_y1(a6),d0
	dspwaitwrite.1	(a4)
	move.w		d0,(a2)
*-------------------------------------------------------*
*	Load wall v-offset (16)				*
*-------------------------------------------------------*
	move.w		gbl_seg_v_index(a6),d0
	dspwaitwrite.0	(a4)
	move.w		d0,(a2)
*-------------------------------------------------------*
*	Load wall ci1					*	
*-------------------------------------------------------*
	dspwaitwrite.0	(a4)
	move.w		d7,(a2)
*-------------------------------------------------------*
*	Load wall ci2					*	
*-------------------------------------------------------*
	dspwaitwrite.0	(a4)
	move.w		d6,(a2)
*-------------------------------------------------------*
*	Load occluded column running total 		*
*-------------------------------------------------------*
	move.w		gbl_free_columns(a6),d0
	dspwaitwrite.0	(a4)
	move.w		d0,(a2)
*-------------------------------------------------------*
*	Render wall					*
*-------------------------------------------------------*
	jsr		render_wall
*-------------------------------------------------------*
*	Recover occluded column running total		*
*-------------------------------------------------------*
	lea		display_struct,a6
	dspread.w	gbl_free_columns(a6)
*-------------------------------------------------------*
*	Restore pointers				*
*-------------------------------------------------------*
.skip:	movem.l		(sp)+,a3-a4
*-------------------------------------------------------*
	rts

*=======================================================*
*	Determine player SSector			*
*=======================================================*
find_sector:
*-------------------------------------------------------*
*	Place start & terminator on heap and descend	*
*-------------------------------------------------------*
	move.w		NumNodes,d0
	subq.w		#1,d0
	bmi		.ssector_node
	bra.s		.dividing_node
*-------------------------------------------------------*
*	Thread returns here when tree is exhausted	*
*-------------------------------------------------------*
.finish_tree:
*-------------------------------------------------------*
	rts

*=======================================================*
*	[node] /= [sector] -> descend again		*
*=======================================================*
.dividing_node:
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
	sub.l		d6,d0			; (x2-px)
	add.w		d3,d1			; y2 = (y1+dy)
	swap		d1
	sub.l		d7,d1			; (xy-py)
	swap		d2
	swap		d3
	muls.l		d2,d2:d1		; (y2-py) * dx
	muls.l		d3,d3:d0		; (x2-px) * dy
	cmp.l		d3,d2 
	bmi.s		.node_leftside
*-------------------------------------------------------*
*	Viewer is on right side of node divider		*
*-------------------------------------------------------*
.node_rightside:
*-------------------------------------------------------*
	move.w		node_right(a1),d0
	bmi.s		.ssector_node
	bra.s		.dividing_node
*-------------------------------------------------------*
*	Viewer is on left side of node divider		*
*-------------------------------------------------------*
.node_leftside:
*-------------------------------------------------------*
	move.w		node_left(a1),d0
	bmi.s		.ssector_node
	bra.s		.dividing_node

*=======================================================*
*	[node] = [sector] -> draw this node		*
*=======================================================*
.ssector_node:
*-------------------------------------------------------*
	move.l		gbl_ssectors_ptr(a6),a0
*-------------------------------------------------------*
*	Locate [ssector] base				*
*-------------------------------------------------------*
	and.w		#$7fff,d0
;	beq.s		.finish_tree
	lea		(a0,d0.w*4),a1
*-------------------------------------------------------*
*	Locate [segs] for this [ssector]		*
*-------------------------------------------------------*
	move.w		ssec_first(a1),d4
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
	move.w		sidedef_sector(a0,d1.l),d1	
*-------------------------------------------------------*
*	Find [sector] base				*
*-------------------------------------------------------*
	move.l		gbl_sectors_ptr(a6),a0
	move.w		d1,d2
	mulu.w		#sector_len,d2
	add.l		d2,a0
	bra		.finish_tree

*-------------------------------------------------------*
*	Flush remaining things from unprocessed list	*
*-------------------------------------------------------*
unprocess_things:
*-------------------------------------------------------*
	lea		upt_start,a3
	move.l		upt_next(a3),d0
*-------------------------------------------------------*
.next_thing:
*-------------------------------------------------------*
	move.l		d0,a3
*-------------------------------------------------------*
*	Stop if this object is a terminator		*
*-------------------------------------------------------*
	move.l		upt_next(a3),d0
	beq.s		.stop_processing
*-------------------------------------------------------*
*	Clear 'thing processed' indicator		*
*-------------------------------------------------------*
	move.l		upt_thing_ptr(a3),a1
	bclr		#7,Thing_attr(a1)
	bra.s		.next_thing
*-------------------------------------------------------*
.stop_processing:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
init_thing_lists:
*-------------------------------------------------------*
	lea		display_struct,a6
	clr.l		d0
*-------------------------------------------------------*
*	Create dummy 'unprocessed-thing' objects	*
*-------------------------------------------------------*
	lea		upt_start,a1
	lea		upt_end,a2
	move.l		a2,upt_next(a1)
	move.l		a1,upt_prev(a2)
*-------------------------------------------------------*
*	Terminate dummy objects with null links		*
*-------------------------------------------------------*
	move.l		d0,upt_prev(a1)
	move.l		d0,upt_next(a2)
*-------------------------------------------------------*
*	Store min-z & max-z in two dummy objects 	*
*-------------------------------------------------------*
	move.l		#$80000000,upt_z(a1)
	move.l		#$7fffffff,upt_z(a2)
*-------------------------------------------------------*
*	Initialise used & free tables for things	*
*-------------------------------------------------------*
	move.l		#0,gbl_upt_used(a6)
	move.l		#max_upt,gbl_upt_free(a6)
	lea		upt_freetable,a0
	lea		upt_usedtable,a1
	lea		upt_space,a2
	move.l		#upt_slen,d1
	move.l		#max_upt,d0
	bsr		initialise_freetable
*-------------------------------------------------------*
*	Initialise used & free tables for spans		*
*-------------------------------------------------------*
	move.l		#0,gbl_ups_used(a6)
	move.l		#max_ups,gbl_ups_free(a6)
	lea		ups_freetable,a0
	lea		ups_usedtable,a1
	lea		ups_space,a2
	move.l		#ups_slen,d1
	move.l		#max_ups,d0
	bsr		initialise_freetable
	rts

*-------------------------------------------------------*
initialise_freetable:
*-------------------------------------------------------*
	subq.l		#1,d0
.loop:	move.l		a2,(a0)+
	clr.l		(a1)+
	add.l		d1,a2
	dbra		d0,.loop
	rts

*-------------------------------------------------------*
*	Assign things to their bounding sectors		*
*-------------------------------------------------------*
assign_things:
*-------------------------------------------------------*
	Cconws		#ascii_assignthings
*-------------------------------------------------------*
*	Create space for [sector] -> [thing] lists	*
*-------------------------------------------------------*

	clr.l		d0
	move.l		d0,stelements_used

	move.w		NumThings,d0
	lsl.l		#2,d0
	move.l		d0,stelements_free

	mulu.w		#st_slen,d0

	clr.l		d1
	move.w		NumSectors,d1
	lsl.l		#3,d1
	add.l		d1,d0

	moveq		#VRAM_preferred,d1
	push.l		d0
	jsr		allocate_chunk
	pop.l		d5

	move.l		d0,stlists_ptr

	ble		err_assignthings

	clr.l		d1
	move.w		NumSectors,d1
	lsl.l		#3,d1
	add.l		d1,d0

	move.l		d0,stelements_ptr

*-------------------------------------------------------*
*	Initialise lists				*
*-------------------------------------------------------*
	move.l		stlists_ptr,a0
	move.l		d5,d0
	jsr		turbo_memclr
*-------------------------------------------------------*
*	Assign things to their bounding ssectors	*
*-------------------------------------------------------*
	lea		display_struct,a6
	move.l		Thing_Array,a0
	move.w		NumThings,d0
	bra.s		.thing_start
*-------------------------------------------------------*
.thing_loop:
*-------------------------------------------------------*
	push.w		d0
*-------------------------------------------------------*
	move.w		Thing_attr(a0),d1

;bit 0   the THING is present at skill 1 and 2
;bit 1   the THING is present at skill 3 (hurt me plenty)
;bit 2   the THING is present at skill 4 and 5 (ultra-violence, nightmare)
;bit 3   indicates a deaf guard.
;bit 4   means the THING only appears in multiplayer mode.

;	btst		#4,d1
;	bne.s		.skip

;	btst		#0,d1	; skill 1 & 2
;	bne.s		.go
;	btst		#1,d1	; skill 3 (default)
;	bne.s		.go
;	bra.s		.skip

.go:	move.w		Thing_type(a0),d1
	cmp.w		#$ffff,d1
	beq.s		.skip
*-------------------------------------------------------*
	move.w		Thing_x(a0),d6
	move.w		Thing_y(a0),d7
	bsr		assign_sprite
*-------------------------------------------------------*
.skip:	lea		Thing_len(a0),a0
*-------------------------------------------------------*
	pop.w		d0
*-------------------------------------------------------*
.thing_start:
*-------------------------------------------------------*
	dbra		d0,.thing_loop
	rts

*-------------------------------------------------------*
assign_sprite:
*-------------------------------------------------------*
	swap		d6
	clr.w		d6
	swap		d7
	clr.w		d7
	push.l		a0
	bsr		find_sector
	pop.l		a0
	tst.w		d0
	beq.s		.skip
	bsr		assign2sector
.skip:	rts

*-------------------------------------------------------*
*	Assign [thing] to [ssector]			*
*-------------------------------------------------------*
assign2sector:
*-------------------------------------------------------*
*	d0 ssector / d1 thing				*
*-------------------------------------------------------*
	move.l		stelements_ptr,a1
	move.l		stlists_ptr,a5
*-------------------------------------------------------*
	move.l		stelements_used,d2
	move.l		stelements_free,d3
	beq		.list_error
*-------------------------------------------------------*
*	Access first free [element] 
*-------------------------------------------------------*
	move.l		d2,d4
	mulu.w		#st_slen,d4
	move.l		a1,a2
	add.l		d4,a2	
*-------------------------------------------------------*
*	Access [thinglist] pointer			* 
*-------------------------------------------------------*
	lea		stl_list(a5,d1.w*8),a3
*-------------------------------------------------------*
*	Check for current [thinglist]			*
*-------------------------------------------------------*
	move.l		(a3),d4
	beq.s		.new_list
*-------------------------------------------------------*
*	List already present				*
*-------------------------------------------------------*
.old_list:
*-------------------------------------------------------*
	move.l		d4,a4
*-------------------------------------------------------*
*	Append new object to start of [thinglist]	*
*-------------------------------------------------------*
	move.l		st_prev(a4),st_prev(a2)
	move.l		a2,st_prev(a4)
	move.l		a4,st_next(a2)
	bra.s		.fix_list
*-------------------------------------------------------*
*	Begin new list					*
*-------------------------------------------------------*
.new_list:
*-------------------------------------------------------*
*	Create (flagged) back-link to [indexlist]	*
*-------------------------------------------------------*
	move.l		a3,d4
	neg.l		d4
	move.l		d4,st_prev(a2)
*-------------------------------------------------------*
*	Terminate list					*
*-------------------------------------------------------*
	clr.l		st_next(a2)
*-------------------------------------------------------*
.fix_list:
*-------------------------------------------------------*
*	Create link to new [thinglist]			*
*-------------------------------------------------------*
	move.l		a2,(a3)
*-------------------------------------------------------*
*	Create link to [thing]				*
*-------------------------------------------------------*
	move.l		a0,st_thing_ptr(a2)
*-------------------------------------------------------*
*	Update free/used counters			*
*-------------------------------------------------------*
	addq.l		#1,d2
	subq.l		#1,d3
*-------------------------------------------------------*
.tidy_lists:
*-------------------------------------------------------*
	move.l		d2,stelements_used
	move.l		d3,stelements_free
*-------------------------------------------------------*
.list_error:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
assign_thingnames:
*-------------------------------------------------------*
	move.l		Thing_Array,a0
	move.w		NumThings,d0
	bra.s		.start
*-------------------------------------------------------*
.loop:	move.w		Thing_type(a0),d2
*-------------------------------------------------------*
	lea		thing_types,a2
*-------------------------------------------------------*
.look:	move.l		thingtype_code(a2),d1
	cmp.l		#-1,d1
	beq.s		.stop
	cmp.w		d2,d1
	beq.s		.found_thing
	lea		thingtype_slen(a2),a2
	bra.s		.look
*-------------------------------------------------------*
.found_thing:
*-------------------------------------------------------*
	move.l		thingtype_name(a2),d2
	lea		spritename_list,a1
	move.l		spritename_count,d3
	moveq		#0,d4
	bra.s		.slook
*-------------------------------------------------------*
.look2:	cmp.l		spritenm_name(a1),d2
	beq.s		.found_name
	addq.l		#1,d4
	lea		spritenm_slen(a1),a1
.slook:	dbra		d3,.look2
	bra.s		.stop
*-------------------------------------------------------*
.found_name:
*-------------------------------------------------------*
	move.w		d4,Thing_type(a0)
	bra.s		.cont
*-------------------------------------------------------*
.stop:	move.w		#-1,Thing_type(a0)
*-------------------------------------------------------*
.cont:	lea		Thing_len(a0),a0	
*-------------------------------------------------------*
.start:	dbra		d0,.loop
	rts

*-------------------------------------------------------*
assign_spritename:
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
*	Search for matching prefix			*
*-------------------------------------------------------*
	move.l		tex_name(a4),d0
	lea		spritename_list,a1
	move.l		spritename_count,d1
	bra.s		.start
.look:	cmp.l		spritenm_name(a1),d0
	beq.s		.found_name
	lea		spritenm_slen(a1),a1
.start:	dbra		d1,.look
*-------------------------------------------------------*
*	Sprite must be new - record name		*
*-------------------------------------------------------*
	move.l		d0,spritenm_name(a1)
	addq.l		#1,spritename_count
*-------------------------------------------------------*
.found_name:
*-------------------------------------------------------*
*	Decode extension #1				*
*-------------------------------------------------------*
	move.w		tex_name+4(a4),d0
	bsr		frame_extension
*-------------------------------------------------------*
*	Decode extension #2				*
*-------------------------------------------------------*
	move.w		tex_name+6(a4),d0
	bsr		frame_extension
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
frame_extension:
*-------------------------------------------------------*
	move.w		d0,d1
	lsr.w		#8,d1
	fixcase		d1
*-------------------------------------------------------*
*	Skip everything except first frame		*
*-------------------------------------------------------*
	cmp.b		#'a',d1
	bne.s		.skip_frame
*-------------------------------------------------------*
*	Decode direction field				*
*-------------------------------------------------------*
	fixcase		d0
	and.w		#$ff,d0
*-------------------------------------------------------*
	cmp.b		#'0',d0
	blo.s		.skip_frame
	beq.s		.all_frames
	cmp.b		#'8',d0
	bhi.s		.skip_frame
*-------------------------------------------------------*
.single_frame:
*-------------------------------------------------------*
	move.w		tex_index(a4),d1
	sub.w		#'1',d0
	cmp.w		#5,d0
	blo.s		.no_reflect
	cmp.w		#7,d0
	bhi.s		.no_reflect
	bset		#14,d1
.no_reflect:
	move.w		d1,spritenm_n(a1,d0.w*2)
	bra.s		.skip_frame	
*-------------------------------------------------------*
.all_frames:
*-------------------------------------------------------*
	move.w		tex_index(a4),d0
	move.w		d0,spritenm_n(a1)
	move.w		d0,spritenm_ne(a1)
	move.w		d0,spritenm_e(a1)
	move.w		d0,spritenm_se(a1)
	move.w		d0,spritenm_s(a1)
	move.w		d0,spritenm_sw(a1)
	move.w		d0,spritenm_w(a1)
	move.w		d0,spritenm_nw(a1)
*-------------------------------------------------------*
.skip_frame:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

thing_types:		dc.l	0001,'PLAY'
			dc.l	2014,'BON1'
			dc.l	3004,'POSS'
			dc.l	0084,'SSWV'
			dc.l	0009,'SPOS'
			dc.l	0065,'CPOS'
			dc.l	3001,'TROO'
			dc.l	3002,'SARG'
			dc.l	0058,'SARG'
			dc.l	3006,'SKUL'
			dc.l	3005,'HEAD'
			dc.l	0069,'BOS2'
			dc.l	3003,'BOSS'
			dc.l	0068,'BSPI'
			dc.l	0071,'PAIN'
			dc.l	0066,'SKEL'
			dc.l	0067,'FATT'
			dc.l	0064,'VILE'
			dc.l	0007,'SPID'
			dc.l	0016,'CYBR'
			dc.l	0088,'BBRN'
			dc.l	2005,'CSAW'
			dc.l	2001,'SHOT'
			dc.l	0082,'SGN2'
			dc.l	2002,'MGUN'
			dc.l	2003,'LAUN'
			dc.l	2004,'PLAS'
			dc.l	2006,'BFUG'
			dc.l	2007,'CLIP'
			dc.l	2008,'SHEL'
			dc.l	2010,'ROCK'
			dc.l	2047,'CELL'
			dc.l	2048,'AMMO'
			dc.l	2049,'SBOX'
			dc.l	2046,'BROK'
			dc.l	0017,'CELP'
			dc.l	0008,'BPAK'
			dc.l	2011,'STIM'
			dc.l	2012,'MEDI'
			dc.l	2014,'BON1'
			dc.l	2015,'BON2'
			dc.l	2018,'ARM1'
			dc.l	2019,'ARM2'
			dc.l	0083,'MEGA'
			dc.l	2013,'SOUL'
			dc.l	2022,'PINV'
			dc.l	2023,'PSTR'
			dc.l	2024,'PINS'
			dc.l	2025,'SUIT'
			dc.l	2026,'PMAP'
			dc.l	2045,'PVIS'
			dc.l	0005,'BKEY'
			dc.l	0040,'BSKU'
			dc.l	0013,'RKEY'
			dc.l	0038,'RSKU'
			dc.l	0006,'YKEY'
			dc.l	0039,'YSKU'
			dc.l	2035,'BAR1'
			dc.l	0072,'KEEN'
			dc.l	0048,'ELEC'
			dc.l	0030,'COL1'
			dc.l	0032,'COL3'
			dc.l	0031,'COL2'
			dc.l	0036,'COL5'
			dc.l	0033,'COL4'
			dc.l	0037,'COL6'
			dc.l	0047,'SMIT'
			dc.l	0043,'TRE1'
			dc.l	0054,'TRE2'
			dc.l	2028,'COLU'
			dc.l	0085,'TLMP'
			dc.l	0086,'TLP2'
			dc.l	0034,'CAND'
			dc.l	0035,'CBRA'
			dc.l	0044,'TBLU'
			dc.l	0045,'TGRE'
			dc.l	0046,'TRED'
			dc.l	0055,'SMBT'
			dc.l	0056,'SMGT'
			dc.l	0057,'SMRT'
			dc.l	0070,'FCAN'
			dc.l	0041,'CEYE'
			dc.l	0042,'FSKU'
			dc.l	0049,'GOR1'
			dc.l	0063,'GOR1'
			dc.l	0050,'GOR2'
			dc.l	0059,'GOR2'
			dc.l	0052,'GOR4'
			dc.l	0060,'GOR4'
			dc.l	0051,'GOR3'
			dc.l	0061,'GOR3'
			dc.l	0053,'GOR5'
			dc.l	0062,'GOR5'
			dc.l	0073,'HDB1'
			dc.l	0074,'HDB2'
			dc.l	0075,'HDB3'
			dc.l	0076,'HDB4'
			dc.l	0077,'HDB5'
			dc.l	0078,'HDB6'
			dc.l	0025,'POL1'
			dc.l	0026,'POL6'
			dc.l	0027,'POL4'
 			dc.l	0028,'POL2'
			dc.l	0029,'POL3'
			dc.l	0010,'POL5'
			dc.l	0012,'POL5'
			dc.l	0024,'POL5'
			dc.l	0079,'POB1'
			dc.l	0080,'POB2'
			dc.l	0081,'BRS1'
			dc.l	0015,'POL5'
			dc.l	0018,'POL5'
			dc.l	0019,'POL5'
			dc.l	0020,'POL5'
			dc.l	0021,'POL5'
			dc.l	0022,'POL5'
			dc.l	-1

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*


stlists_ptr:		ds.l	1
stelements_ptr:		ds.l	1
stelements_used:	ds.l	1
stelements_free:	ds.l	1

spritename_count:	ds.l	1

spritename_list:	ds.b	spritenm_slen*max_spritenames

upt_freetable:		ds.l	max_upt
upt_usedtable:		ds.l	max_upt
upt_start:		ds.b	upt_slen
upt_end:		ds.b	upt_slen
upt_space:		ds.b	upt_slen*max_upt

ups_freetable:		ds.l	max_ups
ups_usedtable:		ds.l	max_ups
ups_start:		ds.b	ups_slen
ups_end:		ds.b	ups_slen
ups_space:		ds.b	ups_slen*max_ups

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
