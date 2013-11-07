*=======================================================*
*	Shards: latest update 25/03/96			*
*=======================================================*
*	Interface with DSP to retrieve floors & walls	*
*=======================================================*

*-------------------------------------------------------*
*	WARNING:					*
*-------------------------------------------------------*
*	This is the least finished module of the 3D	*
*	core, and the most volatile beside the DSP	*
*	module itself. Altering it could be a very	*
*	bad idea. Please wait until I have finished	*
*	writing it!					*
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
	move.w		peg,d0
	add.w		sidedef_yoff(a3),d0
	add.w		d0,d0
	move.w		d0,voff

	move.w		sidedef_xoff(a3),d0
	add.w		x_offset,d0
	move.w		d0,uoff
*-------------------------------------------------------*
	pea		(a3)
	pea		(a4)
*-------------------------------------------------------*



	lea		DSPHostStat.w,a4
	lea		DSPHost32.w,a5
*-------------------------------------------------------*
	move.l		addwall_z1(a6),d1
	move.l		addwall_z2(a6),d2
	move.l		d1,addwall_pz1(a6)
	move.l		d2,addwall_pz2(a6)

	sub.l		d1,d2
	bpl.s		.ak1
	neg.l		d2
.ak1:	lsr.l		#7,d1
	cmp.l		d1,d2
	bpl.s		.ak2

	move.l		addwall_pz2(a6),d1
	move.l		d1,addwall_pz2(a6)
	move.l		d1,addwall_rz1(a6)
	add.l		#2000<<16,d1
	move.l		d1,addwall_pz1(a6)
	move.l		d1,addwall_rz2(a6)

	dspwrite.b	#linear_command,(a4)
	bra.s		.lin
	
.ak2:	dspwrite.b	#perspected_command,(a4)
.lin:	move.l		addwall_pz1(a6),addwall_t2(a6)
	move.l		addwall_pz2(a6),addwall_t1(a6)

*-------------------------------------------------------*
	moveq		#0,d6
	move.w		addwall_hhig(a6),d6	; (h/2)
	moveq		#0,d0
	move.w		addwall_vscale(a6),d0	; vscale
	swap		d0
	swap		d6	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	Vertical (y) perspective projection		*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*	y' = y * ( (w/2) / z ) + (h/2)			*
*-------------------------------------------------------*
	move.l		addwall_y1(a6),d1
	move.l		d0,d2
	muls.l		d1,d7:d2
	divs.l		addwall_z1(a6),d7:d2
	add.l		d6,d2
	move.l		d0,d5
	muls.l		d1,d7:d5
	divs.l		addwall_z2(a6),d7:d5
	move.l		addwall_y2(a6),d1
	add.l		d6,d5
	move.l		d0,d3
	muls.l		d1,d7:d3
	divs.l		addwall_z1(a6),d7:d3
	add.l		d6,d3
	move.l		d0,d4
	muls.l		d1,d7:d4
	divs.l		addwall_z2(a6),d7:d4
	add.l		d6,d4
*-------------------------------------------------------*
*	Calculate dy1 & dy2 gradients			*	
*-------------------------------------------------------*
	move.l		addwall_i2(a6),d0
	sub.l		addwall_i1(a6),d0
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
	move.l		addwall_t2(a6),d4
	sub.l		addwall_t1(a6),d4
	swap		d4
	move.w		d4,d6
	clr.w		d4
	ext.l		d6
	divs.l		d0,d6:d4
	move.l		d4,addwall_ti(a6)
*-------------------------------------------------------*
*	Clip wall against left edge			*	
*-------------------------------------------------------*
	move.l		addwall_i1(a6),d7
	move.l		d7,d6
	swap		d6
	ext.l		d6
	bpl.s		.ok1
	moveq		#0,d6
.ok1:	move.l		d6,a3

	swap		d6
	sub.l		d6,d7	
	move.l		d7,a2

	move.l		a2,d6
	clr.w		d6
	muls.l		d5,d7:d6
	move.w		d7,d6
	swap		d6
	sub.l		d6,d2		; y1 = y1 - (x1*dy1)

	move.l		a2,d6
	clr.w		d6
	muls.l		d1,d7:d6
	move.w		d7,d6
	swap		d6
	sub.l		d6,d3		; y2 = y2 - (x1*dy2)

	move.l		addwall_t2(a6),d6
	sub.l		addwall_t1(a6),d6	; (t2-t1)
	move.l		a2,d0
	muls.l		d0,d7:d6		; (t2-t1) * x1
	move.l		addwall_i2(a6),d0
	sub.l		addwall_i1(a6),d0	; (x2-x1)
	divs.l		d0,d7:d6		; (x1*dz) = ((t2-t1) * x1) / (x2-x1)
	move.l		addwall_t1(a6),d0
	sub.l		d6,d0			; z1 = z1 - (x1*dz)
	move.l		d0,addwall_t1(a6)
	move.l		a3,d7

*-------------------------------------------------------*
*	Load results into local loop registers		*	
*-------------------------------------------------------*
	move.l		d2,addwall_y1a(a6)
	move.l		d3,addwall_y2a(a6)
	move.l		d5,addwall_y1i(a6)
	move.l		d1,addwall_y2i(a6)
*-------------------------------------------------------*

	move.l		umag,d6

	move.l		addwall_rz2(a6),d1
	sub.l		addwall_rz1(a6),d1

	move.l		addwall_pz2(a6),d0
	sub.l		addwall_rz1(a6),d0

	
	muls.l		d6,d2:d0

	divs.l		d1,d2:d0
	move.l		d0,addwall_tu2(a6)

	move.l		addwall_pz1(a6),d0
	sub.l		addwall_rz1(a6),d0

	muls.l		d6,d2:d0

	divs.l		d1,d2:d0
	move.l		d0,addwall_tu1(a6)

*-------------------------------------------------------*
*	Clip wall against right edge			*
*-------------------------------------------------------*
	move.w		addwall_i2(a6),d6
	move.w		addwall_width(a6),d0
	cmp.w		d0,d6
	bmi.s		.x2in
	move.w		d0,d6
.x2in:	move.w		d6,addwall_ci2(a6)
*-------------------------------------------------------*

;	cmp.b		#UPPER_TYPE,addwall_type(a6)
;	beq.s		.upper
;	cmp.b		#LOWER_TYPE,addwall_type(a6)
;	beq.s		.lower
;.wall:	moveq		#wall_command,d0
;	bra.s		.go
;.upper:	moveq		#upper_command,d0
;	bra.s		.go
;.lower:	moveq		#lower_command,d0
;.go:	dspwrite.b	d0,(a4)

	dspwrite.b	addwall_type(a6)

xxx:	lea		DSPHostStat.w,a2

	dspwrite.r	addwall_y1a(a6),(a4)
	dspwrite.r	addwall_y1i(a6),(a4)
	dspwrite.r	addwall_y2a(a6),(a4)
	dspwrite.r	addwall_y2i(a6),(a4)
	dspwrite.r	addwall_t1(a6),(a4)
	dspwrite.r	addwall_ti(a6),(a4)
	dspwrite.r	addwall_pz2(a6),(a4)
	dspwrite.r	addwall_pz1(a6),(a4)


	moveq		#0,d1
	moveq		#0,d2
	move.w		wall_id,d0
	bmi.s		.err
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),d1
	move.w		tex_height(a0),d2
.err:
	dspwrite.l	d1,(a4)
	dspwrite.l	d2,(a4)

	move.l		addwall_tu2(a6),d0
	sub.l		addwall_tu1(a6),d0
	asr.l		#8,d0
	dspwrite.l	d0,(a4)			; umag

	move.l		addwall_tu1(a6),d0

	move.l		umag,d6
	sub.l		d6,d0

	moveq		#0,d6
	move.w		uoff,d6
	swap		d6
	sub.l		d6,d0
	asr.l		#8,d0

	dspwrite.l	d0,(a4)			; uclip

	move.l		addwall_y2(a6),d0
	sub.l		addwall_y1(a6),d0
	swap		d0
	ext.l		d0
	dspwrite.l	d0,(a4)			; vmag

	moveq		#0,d0
	move.w		voff,d0
	dspwrite.l	d0,(a4)
	
	moveq		#0,d0
	dspwrite.l	d7,(a4)
	move.w		addwall_ci2(a6),d0
	dspwrite.l	d0,(a4)

	move.b		addwall_opaque(a6),d0
	dspwrite.l	d0,(a4)

	move.w		display_columns(a6),d0
	dspwrite.l	d0,(a4)

yyy:	pushall
*-------------------------------------------------------*
	bsr		render_wall
*-------------------------------------------------------*
	moveq		#0,d5
	move.w		d5,wallruncount
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	dspread.w	display_columns(a6)
*-------------------------------------------------------*
	pop.l		a4
	pop.l		a3
	rts

voff:			dc.w	0
uoff:			dc.w	0

umag:			ds.l	1
	
cz1:	ds.l		1
cz2:	ds.l		1
fz1:	ds.l		1
fz2:	ds.l		1

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
	move.w		sky_index,d5
	moveq		#getssector_command,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a1)
	move.w		display_ph(a6),d6
	sub.w		display_ch(a6),d6 
	cmp.w		display_ct(a6),d5
	bne.s		.no_upper_sky
	move.w		#upper_sky_dist,d6
.no_upper_sky:
	dspwaitwrite.0	(a2)
	move.w		d6,(a1)
	move.w		display_ph(a6),d7
	sub.w		display_fh(a6),d7 
	cmp.w		display_ft(a6),d5
	bne.s		.no_lower_sky
	move.w		#lower_sky_dist,d7
.no_lower_sky:
	dspwaitwrite.0	(a2)
	move.w		d7,(a1)
*-------------------------------------------------------*
*	Set up luminance, texture indexes & horizon	*	
*-------------------------------------------------------*
	move.w		#256-1,d4
	move.l		zone_ptr,a4
	move.w		display_ct(a6),d0
	bsr.s		stack_floor
	move.w		display_ft(a6),d0
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
	beq		null_zone
*-------------------------------------------------------*
	move.b		d7,(a4)+			; zone_lines
	subq.w		#1,d7
	move.b		d0,(a4)+			; zone_texture
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
	dspwaitread.2	(a2)
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
	move.l		transparent_array,a6
	lea		DSPHost16.w,a1
	lea		DSPHost32.w,a2
*-------------------------------------------------------*
*	Start column retrieval				*
*-------------------------------------------------------*
	moveq		#-1,d7
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i
	bmi		.dsp_done
*-------------------------------------------------------*
*	Retrieval loop					*
*-------------------------------------------------------*
.next:	move.w		d3,(a6)+
	dspwaitread.0	(a3)
	move.w		(a1),(a6)+			; j1j2
	dspwaitread.0	(a3)
	move.w		(a1),(a6)+			; lum
	dspwaitread.0	(a3)
	move.w		(a1),(a6)+			; u
	dspwaitread.0	(a3)
	move.l		(a2),(a6)+			; dv[i:f]
	dspwaitread.0	(a3)
	move.w		(a1),(a6)+			; v
	addq.l		#1,d7
	dspwaitread.0	(a3)
	move.w		(a1),d3				; i
	bpl.s		.next
*-------------------------------------------------------*
*	Store texture index				*
*-------------------------------------------------------*
	move.w		wall_id,(a6)+
*-------------------------------------------------------*
*	Store column count				*
*-------------------------------------------------------*
	move.w		d7,(a6)+
*-------------------------------------------------------*
*	Update array pointer & counter			*
*-------------------------------------------------------*
	move.l		a6,transparent_array
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
	bmi		.dsp_done
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
kickstart_doomcore:
*-------------------------------------------------------*
	jsr		IsDspDrv
	dspexec		DoomCore
	rts

*-------------------------------------------------------*
	include		include\dsplib.s
*-------------------------------------------------------*

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

DoomCore:		incbin	"doom.dsp'
DoomCore_e:

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

zone_ptr:		ds.l	1
transparent_array:	ds.l	1

maxy:			ds.w	320			; upper clipping buffer.
miny:			ds.w	320			; lower clipping buffer.
occlusion_list:		ds.b	320			; byte-per-column occlusion list.

;addwall_struct:		ds.b	addwall_len		; local variables for AddWall.

transparent_count:	ds.w	1
wallruncount:		ds.w	1			; counter for total wall runs.

dummy_zone:		ds.b	16
zone_space:		ds.b	256000

transparent_space:	ds.b	14*2048

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
