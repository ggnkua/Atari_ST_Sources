*=======================================================*
*	Graphics cache module: latest update 25/03/96	*
*=======================================================*
*	Page unavailable graphics resources into RAM	*
*=======================================================*

			rsreset
cache_lt		rs.l	1
cache_rt		rs.l	1
cache_base		rs.l	1
cache_entry		rs.w	1
cache_type		rs.w	1
cache_slen		rs.b	0

			rsreset
crout_alloc		rs.l	1
crout_load		rs.l	1
crout_slen		rs.b	0

			rsreset
ctype_raw		rs.b	1
ctype_texture		rs.b	1

*-------------------------------------------------------*
*	Make graphics available for rendering		*
*-------------------------------------------------------*
cache_resource:
*-------------------------------------------------------*
	lea		cache_slots,a0
	lsl.l		#4,d0
	add.l		d0,a0
	move.l		cache_base(a0),d0
	beq.s		cache_load
*-------------------------------------------------------*
*	Bring resource to front of priority chain	*
*-------------------------------------------------------*
.cache_hit:
*-------------------------------------------------------*
*	Unlink cache slot				*
*-------------------------------------------------------*
	move.l		cache_lt(a0),a1
	move.l		cache_rt(a0),a2
	move.l		a2,cache_rt(a1)
	move.l		a1,cache_lt(a2)
*-------------------------------------------------------*
*	Re-link cache slot at start of chain		*
*-------------------------------------------------------*
	lea		left_cacheslot(pc),a1
	move.l		cache_rt(a1),a2
	move.l		a0,cache_rt(a1)
	move.l		a0,cache_lt(a2)
	move.l		a1,cache_lt(a0)
	move.l		a2,cache_rt(a0)
*-------------------------------------------------------*
.echo_hit:
*-------------------------------------------------------*
	rts
	
*-------------------------------------------------------*
*	Texture is not available - load it from disk	*
*-------------------------------------------------------*
cache_load:
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
.cache_alloc:
*-------------------------------------------------------*
*	Determine method for preparing graphics		*
*-------------------------------------------------------*
	move.l		graphics_array,a4
	move.w		cache_entry(a0),d0
	move.l		(a4,d0.w*4),a4
	move.w		cache_type(a0),d0
	lea		cache_routines(pc),a1
	move.l		crout_alloc(a1,d0.w*8),a1
	jsr		(a1)
	move.l		d0,cache_base(a0)
	bne.s		.space_allocated
*-------------------------------------------------------*
*	Deallocate lowest priority slot & retry		*
*-------------------------------------------------------*
.cache_full:
*-------------------------------------------------------*
*	Deallocate memory for resouce			*
*-------------------------------------------------------*
	lea		right_cacheslot(pc),a3
	move.l		cache_lt(a3),a3
	moveq		#0,d1
	move.l		cache_base(a3),d0
	move.l		d1,cache_base(a3)
	bsr		deallocate_chunk
*-------------------------------------------------------*
*	Unlink cache slot				*
*-------------------------------------------------------*
	move.l		cache_lt(a3),a1
	move.l		cache_rt(a3),a2
	move.l		a2,cache_rt(a1)
	move.l		a1,cache_lt(a2)
	bra.s		.cache_alloc
*-------------------------------------------------------*
.space_allocated
*-------------------------------------------------------*
*	Sufficient space allocated for texture		*
*-------------------------------------------------------*
*	Link into list of allocated slots		*
*-------------------------------------------------------*
	lea		left_cacheslot(pc),a1
	move.l		cache_rt(a1),a2
	move.l		a0,cache_rt(a1)
	move.l		a0,cache_lt(a2)
	move.l		a1,cache_lt(a0)
	move.l		a2,cache_rt(a0)
*-------------------------------------------------------*
*	Read data into allocated space			*
*-------------------------------------------------------*
	move.w		cache_type(a0),d0
	lea		cache_routines(pc),a1
	move.l		crout_load(a1,d0.w*8),a1
	jsr		(a1)
	popall
	move.l		cache_base(a0),d0
	rts

*-------------------------------------------------------*
init_cache:
*-------------------------------------------------------*
	lea		cache_slots,a1
	move.w		#max_graphics-1,d0
	moveq		#0,d1
.init:	move.w		d1,cache_entry(a1)
	addq.w		#1,d1
	lea		cache_slen(a1),a1
.go:	dbra		d0,.init
	rts

*-------------------------------------------------------*
cache_routines:
*-------------------------------------------------------*
	dc.l		alloc_flat,load_flat
	dc.l		alloc_texture,load_texture

*-------------------------------------------------------*
alloc_flat:
*-------------------------------------------------------*
	move.l		wd_size(a4),d0
	bsr		allocate_chunk
	rts

*-------------------------------------------------------*
alloc_texture:
*-------------------------------------------------------*
	move.w		cache_entry(a0),d0
	move.l		graphics_array,a1
	move.l		(a1,d0.w*4),a1
	move.w		tex_width(a1),d0
	mulu.w		tex_height(a1),d0
	bsr		allocate_chunk
	tst.l		d0
	beq.s		.err
*-------------------------------------------------------*
*	Clear out texture				*
*-------------------------------------------------------*
	push.l		d0
	move.w		tex_width(a1),d1
	mulu.w		tex_height(a1),d1
	lsr.l		#2,d1
	subq.w		#1,d1
	move.l		d0,a1
	moveq		#0,d0
.clr:	move.l		d0,(a1)+
	dbra		d1,.clr
	pop.l		d0
.err:	rts

*-------------------------------------------------------*
load_flat:
*-------------------------------------------------------*
	move.l		cache_base(a0),a5
*-------------------------------------------------------*
*	Patch sky flat					*
*-------------------------------------------------------*
	cmp.l		#'F_SK',wd_name(a4)
	bne.s		.load
	cmp.w		#'Y1',wd_name+4(a4)
	bne.s		.load
	move.w		#(64*64)-1,d0
	move.b		#sky_colour,d1
.clr:	move.b		d1,(a5)+
	dbra		d0,.clr
	bra.s		.done
*-------------------------------------------------------*
*	Load flat from wad				*
*-------------------------------------------------------*
.load:	Fseek		wd_offset(a4),wad_handle,#0
	Fread		wad_handle,wd_size(a4),a5
.done:	rts

*-------------------------------------------------------*
load_texture:
*-------------------------------------------------------*
	move.l		cache_base(a0),texture_ptr
	move.w		cache_entry(a0),d0
	pushall
	bsr		render_texture
	popall
	rts

*-------------------------------------------------------*
thrash_level:
*-------------------------------------------------------*
	Cconws		#ascii_loadflats
	bsr		thrash_flats
	Cconws		#ascii_loadwalls
	bsr		thrash_textures
	rts

*-------------------------------------------------------*
thrash_flats:
*-------------------------------------------------------*
	move.l		Sector_Array,a3
	move.w		NumSectors,d7
	bra.s		.segs
.seg:	move.w		sector_ctns(a3),d0
	bsr		thrash_resource
	move.w		sector_ftns(a3),d0
	bsr		thrash_resource
	lea		sector_len(a3),a3
.segs:	dbra		d7,.seg
	rts

*-------------------------------------------------------*
thrash_textures:		
*-------------------------------------------------------*
	move.l		Side_Array,a3
	move.w		NumSides,d7
	bra.s		.segs
.seg:	move.w		sidedef_utns(a3),d0
	bsr		thrash_resource
	move.w		sidedef_ltns(a3),d0
	bsr		thrash_resource
	move.w		sidedef_mtns(a3),d0
	bsr		thrash_resource
	lea		sidedef_len(a3),a3
.segs:	dbra		d7,.seg
	rts
	
*-------------------------------------------------------*
thrash_resource:
*-------------------------------------------------------*
	swap		d0
	clr.w		d0
	swap		d0
	tst.w		d0
	bmi.s		.err
	pushall
	bsr		cache_resource
	popall
.err:	rts
	
*-------------------------------------------------------*
left_cacheslot:
*-------------------------------------------------------*
	dc.l		left_cacheslot
	dc.l		right_cacheslot
	dc.l		0
	dc.w		0
	dc.w		0

*-------------------------------------------------------*
right_cacheslot:
*-------------------------------------------------------*
	dc.l		left_cacheslot
	dc.l		right_cacheslot
	dc.l		0
	dc.w		0
	dc.w		0

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

cache_slots:		ds.b	cache_slen*max_graphics

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
