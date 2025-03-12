*=======================================================*
*	Shard manager: updated 12/06/97			*
*=======================================================*

*-------------------------------------------------------*
*	Wall-run ministructure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
wall_i:			rs.w	1
wall_j1:		rs.b	1
wall_j2:		rs.b	1
wall_u:			rs.w	1
wall_dv:		rs.b	3
wall_lum:		rs.b	1
wall_v:			rs.w	1
wall_len:		rs.b	0

*-------------------------------------------------------*
*	Floor-run ministructure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
flat_lum:		rs.w	1
flat_x2:		rs.w	1
flat_len:		rs.b	0

*-------------------------------------------------------*
*	Special constants				*
*-------------------------------------------------------*

sz1		=	64		; sample z1
sz2		=	128		; sample z2

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Generate a new wall, floor & ceiling chunk	*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	txtlong
*-------------------------------------------------------*
add_wall_segment:
*-------------------------------------------------------*
*	Calculate u-offset				*
*-------------------------------------------------------*
	move.w		sidedef_xoff(a3),d6
	add.w		gbl_seg_uoff(a6),d6
	move.w		d6,gbl_seg_u_index(a6)
*-------------------------------------------------------*
*	Calculate v-offset				*
*-------------------------------------------------------*
	add.w		gbl_seg_unpeg(a6),d7
	move.w		d7,gbl_seg_v_index(a6)
*-------------------------------------------------------*
*	Store pointers					*
*-------------------------------------------------------*
	movem.l		a3-a4,-(sp)
*-------------------------------------------------------*
*	Set up light level for this wall		*
*-------------------------------------------------------*
;	move.l		gbl_sector_light(a6),d0
;	bsr		new_light_level
*-------------------------------------------------------*
*	Host port registers				*
*-------------------------------------------------------*
	lea		DSPHostStat.w,a4
	lea		DSPHost32.w,a5
*-------------------------------------------------------*
*	Calculate z-span				*
*-------------------------------------------------------*
	move.l		gbl_seg_z1(a6),d1
	move.l		gbl_seg_z2(a6),d2
	move.l		d1,gbl_seg_pz1(a6)
	move.l		d2,gbl_seg_pz2(a6)
*-------------------------------------------------------*
	sub.l		d1,d2
	bpl.s		.ak1
	neg.l		d2
.ak1:	add.l		gbl_seg_pz2(a6),d1
	lsr.l		#1,d1
	lsr.l		#7,d1
	cmp.l		d1,d2
	bpl.s		.perspected_wall
*-------------------------------------------------------*
	move.l		gbl_seg_pz1(a6),d1
	move.l		d1,gbl_seg_pz2(a6)
	move.l		d1,gbl_seg_rz1(a6)
	add.l		#16384<<16,d1
	move.l		d1,gbl_seg_pz1(a6)
	move.l		d1,gbl_seg_rz2(a6)
*-------------------------------------------------------*
	move.w		#linear_command,gbl_seg_mode(a6)
	bra.s		.linear_wall
*-------------------------------------------------------*
.perspected_wall:
*-------------------------------------------------------*
	move.w		#perspected_command,gbl_seg_mode(a6)
*-------------------------------------------------------*
.linear_wall:
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
	bpl.s		.noc
	moveq		#0,d7
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
	move.l		gbl_seg_umag(a6),d6
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
	move.w		gbl_width(a6),d0
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
	moveq		#0,d1
	moveq		#0,d2
	move.w		gbl_seg_tex(a6),d0
	bmi.s		.err
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),d1
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
	sub.l		gbl_seg_umag(a6),d0
	sub.l		gbl_seg_u_index(a6),d0
	asr.l		#8,d0
	dspwaitwrite.1	(a4)
	move.l		d0,(a5)
*-------------------------------------------------------*
*	Load wall v-magnitude (16)			*
*-------------------------------------------------------*
	move.w		gbl_seg_y2(a6),d0
	sub.w		gbl_seg_y1(a6),d0
	dspwaitwrite.0	(a4)
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

*-------------------------------------------------------*
*	Load 16.16 realnumber into DSP as 24.24		*
*-------------------------------------------------------*
load_real:
*-------------------------------------------------------*
	dspwaitwrite.0	(a4)
	move.w		d0,(a2)
	swap		d0
	dspwaitwrite.1	(a4)
	move.w		d0,(a2)
	rts

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
get_ssector:
*-------------------------------------------------------*
	push.l		a6
*-------------------------------------------------------*
	lea		DSPHost16.w,a1
	lea		DSPHost32.w,a5
	lea		DSPHostStat.w,a2
*-------------------------------------------------------*
*	Load floor & ceiling heights			*
*-------------------------------------------------------*
	move.l		gbl_player_height(a6),d5
	moveq		#getssector_command,d6
	dspwaitwrite.0	(a2)
	move.b		d6,1(a1)
	moveq		#0,d6
	sub.w		gbl_ceiling_height(a6),d6 
	swap		d6
	add.l		d5,d6
	asr.l		#8,d6
	dspwaitwrite.1	(a2)
	move.l		d6,(a5)
	moveq		#0,d7
	sub.w		gbl_floor_height(a6),d7 
	swap		d7
	add.l		d5,d7
	asr.l		#8,d7
	dspwaitwrite.1	(a2)
	move.l		d7,(a5)
*-------------------------------------------------------*
*	Set up luminance, texture indexes & horizon	*	
*-------------------------------------------------------*
	move.w		#256-1,d4
	move.l		zone_ptr,a4

	move.w		gbl_ceiling_tex(a6),d0
	clr.w		d6
	bsr.s		stack_floor

	move.w		gbl_floor_tex(a6),d0
	move.w		height,d6
	bsr.s		stack_floor
*-------------------------------------------------------*
*	Terminate floor stack				*
*-------------------------------------------------------*
	move.l		a4,zone_ptr
	clr.b		(a4)
*-------------------------------------------------------*
	pop.l		a6
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Retrieve all scanlines for this ssector		*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
stack_floor:
*-------------------------------------------------------*
*	Create zone header (skip null zones)	 	*
*-------------------------------------------------------*
	dspwaitread.0	(a2)
	move.w		(a1),d1
	dspwaitread.0	(a2)
	move.w		(a1),d7
	beq.s		null_zone
*-------------------------------------------------------*
	move.b		d7,(a4)+			; zone_lines
	subq.w		#1,d7
	move.b		d0,(a4)+			; zone_texture
	sub.w		d6,d1
	move.w		d1,(a4)+			; zone_start
*-------------------------------------------------------*
.line_loop:
*-------------------------------------------------------*
*	Create line header (null lines must be added)	*
*-------------------------------------------------------*
	dspwaitread.0	(a2)
	move.w		(a1),d0
	move.w		d0,(a4)+			; line_runs
	subq.w		#1,d0
	bmi.s		.null_line
*-------------------------------------------------------*
	dspwaitread.1	(a2)
	move.w		(a1),d3
*-------------------------------------------------------*
.run_loop:
*-------------------------------------------------------*
	move.w		d3,(a4)+
	dspwaitread.0	(a2)
	move.w		(a1),(a4)+
*-------------------------------------------------------*
	dbra		d0,.run_loop
*-------------------------------------------------------*
.null_line:
*-------------------------------------------------------*
	dbra		d7,.line_loop	
*-------------------------------------------------------*
null_zone:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
stack_transparent:
*-------------------------------------------------------*
*	Check for bad wall texture			*
*-------------------------------------------------------*
	lea		DSPHostStat.w,a3
	move.l		transparent_array,a5
	lea		DSPHost16.w,a1
	lea		DSPHost32.w,a2
*-------------------------------------------------------*
*	Start column retrieval				*
*-------------------------------------------------------*
	moveq		#-1,d7
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i
	bmi.s		.dsp_done
*-------------------------------------------------------*
*	Retrieval loop					*
*-------------------------------------------------------*
.next:	move.w		d3,(a5)+
	dspwaitread.0	(a3)
	move.w		(a1),(a5)+			; j1j2
	dspwaitread.0	(a3)
	move.w		(a1),(a5)+			; lum
	dspwaitread.0	(a3)
	move.w		(a1),(a5)+			; u
	dspwaitread.0	(a3)
	move.l		(a2),(a5)+			; dv[i:f]
	dspwaitread.0	(a3)
	move.w		(a1),(a5)+			; v
	addq.l		#1,d7
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i
	bpl.s		.next
*-------------------------------------------------------*
*	Store texture index				*
*-------------------------------------------------------*
	move.w		gbl_seg_tex(a6),(a5)+
*-------------------------------------------------------*
*	Store column count				*
*-------------------------------------------------------*
	move.w		d7,(a5)+
*-------------------------------------------------------*
*	Update array pointer & counter			*
*-------------------------------------------------------*
	move.l		a5,transparent_array
	addq.w		#1,transparent_count
*-------------------------------------------------------*
*	All columns for this wall are complete		*
*-------------------------------------------------------*
.dsp_done:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
flush_badwall:
*-------------------------------------------------------*
*	Check for bad wall texture			*
*-------------------------------------------------------*
	lea		DSPHostStat.w,a3
	lea		DSPHost16.w,a1
	lea		DSPHost32.w,a2
*-------------------------------------------------------*
*	Start column retrieval				*
*-------------------------------------------------------*
	dspwaitread.0	(a3)
	tst.w		(a1)				; i
	bmi.s		.dsp_done
*-------------------------------------------------------*
*	Retrieval loop					*
*-------------------------------------------------------*
.next:	dspwaitread.0	(a3)
	tst.w		(a1)				; j1j2
	dspwaitread.0	(a3)
	tst.w		(a1)				; lum
	dspwaitread.0	(a3)
	tst.w		(a1)				; u
	dspwaitread.0	(a3)
	tst.l		(a2)				; dv[i:f]
	dspwaitread.0	(a3)
	tst		(a1)				; v
	dspwaitread.0	(a3)
	tst.w		(a1)				; i
	bpl.s		.next
*-------------------------------------------------------*
.dsp_done:
*-------------------------------------------------------*
	rts
	
*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

transparent_array:	ds.l	1
transparent_count:	ds.l	1

zone_ptr:		ds.l	1

transparent_space:	ds.b	12*4096

zone_space:		ds.b	256000

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
