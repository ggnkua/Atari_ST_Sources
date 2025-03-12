*=======================================================*
*	Display-engine: latest update 25/03/96		*
*=======================================================*
*	Call all display modules in correct order	*
*=======================================================*

*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
display_engine:
*-------------------------------------------------------*
	moveq		#0,d1
	move.w		width,d1
	move.l		#256<<4,d0
	swap		d0
	divu.l		d1,d0
	neg.l		d0
	move.l		d0,skyx

	move.w		fheight,d1
	mulu.w		#128,d1
	moveq		#0,d0
	move.w		sys_default_height,d0
	divu.l		d0,d1
;	divu.l		#default_height,d1

;	move.l		#128,d1

	move.l		#128,d0
	swap		d0
	divu.l		d1,d0
	move.l		d0,skyy

	moveq		#0,d0
	move.w		pangle,d0
	add.w		#$10000/8,d0
	lsl.l		#8,d0
	lsl.l		#2+4,d0
	move.l		d0,xoff
*-------------------------------------------------------*
*	Calculate window base-address (centering)	*
*-------------------------------------------------------*
	jsr		centre_screen

*-------------------------------------------------------*
*	Reset wall & floor buffers for this frame	*
*-------------------------------------------------------*
	move.l		#transparent_space,transparent_array
	clr.w		transparent_count
	move.l		#zone_space,zone_ptr
	clr.b		zone_space
	bsr		init_wall_lists
*-------------------------------------------------------*
*	Init display variables for this frame		*
*-------------------------------------------------------*
	bsr		update_display_struct
*-------------------------------------------------------*
*	Transfer frame-critical details to DSP		*
*-------------------------------------------------------*
	lea		display_struct,a6
	move.l		sinpangle,d1
	move.l		cospangle,d2
	lsl.l		#8-2,d1
	lsl.l		#8-2,d2
	lea		DSPHostStat.w,a2
	lea		DSPHost16.w,a0
	moveq		#newscene_command,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a0)
	dspwaitwrite.0	(a2)
	move.w		display_px(a6),(a0)
	dspwaitwrite.0	(a2)
	move.w		display_py(a6),(a0)
	dspwaitwrite.0	(a2)
	move.w		pangle,(a0)
	lea		DSPHost32.w,a0
	dspwaitwrite.0	(a2)
	move.l		d1,(a0)
	dspwaitwrite.0	(a2)
	move.l		d2,(a0)
*-------------------------------------------------------*
*	Init lighting effects for this frame		*	
*-------------------------------------------------------*	
	bsr		set_lighting
*-------------------------------------------------------*
*	Clearscreen for resizing window & debugging	*
*-------------------------------------------------------*
	ifd		frsb

	tst.b		refresh
	beq.s		.no
	move.b		#1,refresh
	move.l		ScreenLog,a0
	bsr		clearscreen
	move.b		#1,refresh
	move.l		ScreenPhy,a0
	bsr		clearscreen
	clr.b		refresh
.no:
	elseif

	move.l		ScreenLog,a0
	bsr		clearscreen

	endc
*-------------------------------------------------------*
*	Descend BSP tree & build scenery		*
*-------------------------------------------------------*
	bsr		descend_bsp
*-------------------------------------------------------*
*	Render floors & ceilings			*
*-------------------------------------------------------*
	bsr		render_flats
*-------------------------------------------------------*
*	Render transparet wall & sprite segments	*
*-------------------------------------------------------*
	bsr		render_transparent

;	bsr		render_walls

*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
toggle_h_detail:
*-------------------------------------------------------*	
	not.b		halfrows
	bsr		select_window
	rts

*-------------------------------------------------------*
toggle_v_detail:
*-------------------------------------------------------*
	tst.b		halflines
	bne.s		.normal_detail
*-------------------------------------------------------*
*	Switch to low detail, if dline mode is free	*
*-------------------------------------------------------*
.low_detail:
*-------------------------------------------------------*
*	Check interlace first - this looks better	*
*-------------------------------------------------------*
	tst.b		ilace_active
	beq.s		.noil
*-------------------------------------------------------*
*	Interlace is on - so turn it off!		*
*-------------------------------------------------------*
	sf		ilace_active
	st		halflines
	bra.s		.done
*-------------------------------------------------------*
*	Can't turn off ilace, so try dline		*
*-------------------------------------------------------*
.noil:	tst.b		dline_active
	bne.s		.err
*-------------------------------------------------------*
*	Low detail is available, so go for it!		*
*-------------------------------------------------------*
	st		dline_active
	st		halflines
	bra.s		.done
*-------------------------------------------------------*
*	Switch to normal detail mode			*
*-------------------------------------------------------*
.normal_detail:
*-------------------------------------------------------*
*	Check dline first - this looks better		*
*-------------------------------------------------------*
	tst.b		dline_active
	beq.s		.nodl
*-------------------------------------------------------*
*	dline used - so turn it off			*
*-------------------------------------------------------*
	sf		dline_active
	sf		halflines
	bra.s		.done
*-------------------------------------------------------*
*	dline not used - must resort to interlace	*
*-------------------------------------------------------*
.nodl:	st		ilace_active
	sf		halflines
*-------------------------------------------------------*
.done:	bsr		select_window
.err:	rts

*-------------------------------------------------------*
*	Init wall edgebuffer lists for next frame	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
init_wall_lists:
*-------------------------------------------------------*
	lea		maxy,a0
	lea		miny,a1
	move.w		height,d1
	moveq		#0,d2
	moveq		#-1,d3
	move.w		width,d0
	subq.w		#1,d0
	lea		occlusion_list,a2
.for_i:	move.w		d1,(a0)+
	move.w		d2,(a1)+
	move.b		d3,(a2)+
	dbra		d0,.for_i
	clr.w		wallruncount
	lea		display_struct,a6
	move.w		width,display_columns(a6)
	rts

*-------------------------------------------------------*
*	Set up general (engine) structures & tables	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
init_displaystruct:
*-------------------------------------------------------*
	lea		display_struct,a6
*-------------------------------------------------------*
*	Initialise pointers to WAD room data		*
*-------------------------------------------------------*
	move.l		Seg_Array,display_segs(a6)
	move.l		Sector_Array,display_sectors(a6)
	move.l		SSector_Array,display_ssectors(a6)
	move.l		Side_Array,display_sidedefs(a6)
	move.l		Line_Array,display_linedefs(a6)
	move.l		Vertex_Array,display_vertices(a6)
	move.l		Node_Array,display_nodes(a6)
	move.w		#42,display_ph(a6)
	rts

*-------------------------------------------------------*
*	Update general (engine) display structure	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
update_display_struct:
*-------------------------------------------------------*
	lea		display_struct,a6
*-------------------------------------------------------*
*	Set up player position and angle		*
*-------------------------------------------------------*
	move.l		sinpangle,d3
	move.l		cospangle,d4
	asr.l		#2,d3
	asr.l		#2,d4
	move.w		d3,display_sina(a6)
	move.w		d4,display_cosa(a6)
	move.w		px,display_px(a6)
	move.w		py,display_py(a6)
*-------------------------------------------------------*
*	Calculate base address of octant routine	*
*-------------------------------------------------------*
	st		display_firstssec(a6)
*-------------------------------------------------------*
	rts
	
*-------------------------------------------------------*
*	Select new display window size			*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
select_window:
*-------------------------------------------------------*
	pushall
	moveq		#10,d1
	move.w		window_size,d2
	cmp.w		#256,d2
	bpl.s		.ok1
	move.w		#256,d2
.ok1	cmp.w		#1<<10,d2
	bmi.s		.ok2
	move.w		#1<<10,d2
.ok2:	move.w		d2,window_size
*-------------------------------------------------------*
*	Recalculate window size				*
*-------------------------------------------------------*
	move.w		d2,d3
	move.w		d2,d4
	move.w		d2,d5
	mulu.w		viewport_width,d3
	mulu.w		viewport_height,d4
	mulu.w		sys_expanded_height,d5
;	mulu.w		#expanded_height,d5
	lsr.l		d1,d3
	lsr.l		d1,d4
	lsr.l		d1,d5
	tst.b		halfrows
	beq.s		.nhr1
	lsr.w		d3
.nhr1:	tst.b		halflines
	beq.s		.nhl1
	lsr.w		d4
	lsr.w		d5
.nhl1:	move.w		d3,width
	move.w		d4,height
	move.w		d5,fheight
*-------------------------------------------------------*
*	Recalculate aspect ratio			*
*-------------------------------------------------------*
	move.w		d3,d5
	move.w		d4,d6
	ext.l		d6
	move.w		viewport_width,d0
	mulu.w		aspect_ratio,d0
	mulu.l		d0,d6
	move.w		sys_default_width,d0
;	move.w		#default_width,d0
	mulu.w		viewport_height,d0
	divu.l		d0,d6
	move.w		d6,rheight
*-------------------------------------------------------*
*	Recalculate texture ratio (1:1 or 2:1 or 1:2)	*
*-------------------------------------------------------*
	lsr.w		d5
	move.w		d5,d0
	tst.b		halfrows
	beq.s		.nhr2
	lsl.w		d0
.nhr2:	tst.b		halflines
	beq.s		.nhl2
	lsr.w		d0
.nhl2:	move.w		d5,hscale
	mulu.w		aspect_ratio,d0
	divu.w		sys_base_aspect,d0
;	divu.w		#base_aspect,d0
	move.w		d0,vscale
*-------------------------------------------------------*
*	Update global display structure			*
*-------------------------------------------------------*
	lea		display_struct,a6
	move.w		width,d1
	move.w		d1,display_width(a6)
	lsr.w		d1
	move.w		d1,display_hwid(a6)
	move.w		height,d1
	move.w		d1,display_height(a6)
	lsr.w		d1
	move.w		d1,display_hhig(a6)
	move.w		rheight,display_rheight(a6)
	move.w		hscale,display_hscale(a6)
	move.w		vscale,display_vscale(a6)
*-------------------------------------------------------*
*	Update addwall structure			*
*-------------------------------------------------------*
;	lea		addwall_struct,a6
	move.w		width,d1
	move.w		d1,addwall_width(a6)
	lsr.w		d1
	move.w		d1,addwall_hwid(a6)
	move.w		height,d1
	move.w		d1,addwall_height(a6)
	lsr.w		d1
	move.w		d1,addwall_hhig(a6)
	move.w		rheight,addwall_rheight(a6)
	move.w		hscale,addwall_hscale(a6)
	move.w		vscale,addwall_vscale(a6)
*-------------------------------------------------------*
*	3 CLS calls required to wipe log, phys & bak	*
*-------------------------------------------------------*
	move.b		clearcount,refresh
*-------------------------------------------------------*
*	Recalculate video display height		*
*-------------------------------------------------------*
	move.b		#1,adjust
*-------------------------------------------------------*
*	Resize DSP rendering zone			*
*-------------------------------------------------------*
	bsr		dsp_resizewindow
*-------------------------------------------------------*
	bsr		adjust_map
*-------------------------------------------------------*
	popall
	rts

*-------------------------------------------------------*
configure_viewport:
*-------------------------------------------------------*
*	Base image size on screen size			*
*-------------------------------------------------------*
	move.w		screen_w,d1
	move.w		screen_h,d2
*-------------------------------------------------------*
*	Keep size within programmed limits		*
*-------------------------------------------------------*
	cmp.w		#max_xres,d1
	bmi.s		.xok
	move.w		#max_xres,d1
.xok:	cmp.w		#max_yres,d2
	bmi.s		.yok
	move.w		#max_yres,d2
*-------------------------------------------------------*
*	Set up physical image width			*
*-------------------------------------------------------*
.yok:	move.w		d1,sys_default_width
*-------------------------------------------------------*
*	Set up expanded (fullscreen) image height	*
*-------------------------------------------------------*
	move.w		d2,sys_expanded_height
*-------------------------------------------------------*
*	Set up default image height			*
*-------------------------------------------------------*
	mulu.w		#168,d2				; (arbitrary) 8:5 down-sizing calculation...
	divu.w		#200,d2				; this can be replaced!
	move.w		d2,sys_default_height
*-------------------------------------------------------*
*	Set virtual (reference) ratio			*
*-------------------------------------------------------*
	move.w		sys_default_width,d0
	mulu.w		#200,d0
	divu.w		#320,d0
	move.w		d0,sys_base_aspect
*-------------------------------------------------------*
*	Set physical ratios for VGA & RGB		*
*-------------------------------------------------------*
	move.w		sys_expanded_height,d0
	move.w		d0,sys_vga_aspect
	move.w		sys_default_height,d0
	move.w		d0,sys_rgb_aspect
*-------------------------------------------------------*
*	Low-level viewport variables			*
*-------------------------------------------------------*
	move.w		sys_default_width,viewport_width
	move.w		sys_default_height,viewport_height
	move.w		sys_vga_aspect,aspect_ratio
	rts

*-------------------------------------------------------*
*	Command DSP to resize internal structures	*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
dsp_resizewindow:
*-------------------------------------------------------*
	lea		DSPHostStat.w,a2
	lea		DSPHost16.w,a0
	moveq		#resize_command,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a0)
	dspwaitwrite.0	(a2)
	move.w		width,(a0)
	dspwaitwrite.0	(a2)
	move.w		height,(a0)
	dspwaitwrite.0	(a2)
	move.w		rheight,(a0)
	dspwaitwrite.0	(a2)
	move.w		hscale,(a0)
	dspwaitwrite.0	(a2)
	move.w		vscale,(a0)
*-------------------------------------------------------*
*	Clear structures with dummy new_ssector		*
*-------------------------------------------------------*
	moveq		#newssector_command,d0
	dspwaitwrite.0	(a2)
	move.w		d0,(a0)
	rts
		
*-------------------------------------------------------*
*	Doom engine subroutines				*
*-------------------------------------------------------*

	include		bspd.s
	include		shards.s
	include		render.s
	include		lighting.s
	include		timing.s
	include		tables.s

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

viewport_width:		dc.w	0			; window width
viewport_height:	dc.w	0			; window height
aspect_ratio:		dc.w	0			; vertical aspect
	
*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

display_struct:		ds.b	display_len		; general display structure

window_size:		ds.w	1			; window size % factor
width:			ds.w	1			; current render-width
height:			ds.w	1			; current render-height
fheight:		ds.w	1			; relative maximum height
rheight:		ds.w	1			; [relative] aspect ratio height
hscale:			ds.w	1			; horizontal x-scaling factor
vscale:			ds.w	1			; vertical x-scaling factor

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
