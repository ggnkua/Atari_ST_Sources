*=======================================================*
*	Texture module: latest update 25/03/96		*
*=======================================================*
*	Process, reformat, build & manage textures	*
*=======================================================*

max_hash	=	4096		; maximum number of hash entries
max_textures	=	512		; maximum number of textures in WAD
max_graphics	=	2048		; maximum number of textures in WAD

max_patches	=	72		; maximum patches per texture

sky_colour	=	216		; hack for sky colour
;sky_colour	=	211		; hack for sky colour
upper_sky_lum	=	180
upper_sky_dist	=	-64
lower_sky_lum	=	180
lower_sky_dist	=	64

*-------------------------------------------------------*
*	Read & convert texture resource directories	*
*-------------------------------------------------------*
init_textures:
*-------------------------------------------------------*
*	Set up list & resource pointers			*
*-------------------------------------------------------*
	move.l		#hash_space,hash_array
	move.l		#graphics_space,graphics_array
	move.l		#graphics_space,floating_array
	move.l		#texture_space,texture_array
	move.l		#pnamelist_space,pnamelist_array
	clr.w		graphics_count
	clr.w		flat_count
	clr.w		texture_count
	sf		textures_present
*-------------------------------------------------------*
*	Remove unwanted sidedef textures from sky	*
*-------------------------------------------------------*
	bsr		fix_sky_textures
*-------------------------------------------------------*
*	Replace flat texture references with indexes	*
*-------------------------------------------------------*
	move.l		floating_array,flatlist_array
	bsr		replace_flats
*-------------------------------------------------------*
*	Read texture directory structures		*
*-------------------------------------------------------*
	move.l		floating_array,texturelist_array
	bsr		read_pnames
	Cconws		#ascii_readtex1
	lea		ascii_texture1,a0
	bsr		add_textures
	Cconws		#ascii_readtex2
	lea		ascii_texture2,a0
	bsr		add_textures
	tst.b		textures_present
	bne		.cont
	Cconws		#ascii_err_notex
	bra.s		.go
*-------------------------------------------------------*
*	Build hash table for textures			*
*-------------------------------------------------------*
.cont:	bsr		build_texture_hash
*-------------------------------------------------------*
*	Replace wall texture references with indexes	*
*-------------------------------------------------------*
.go:	bsr		replace_textures
*-------------------------------------------------------*
	bsr		organise_patches
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Create tracking list for patches		*
*-------------------------------------------------------*
organise_patches:
*-------------------------------------------------------*
	bsr		build_patch_hash
	Cconws		#ascii_locatepatch
	move.l		pname_ptr,a3
	move.l		pnamelist_array,a6
	move.w		pname_count,d7
	bra.s		.go
.all:	move.l		a3,a0
	bsr		locate_patch
;	tst.l		d0
;	bne.s		.cont
;	bsr		entry_missing_w
.cont:	move.l		d0,(a6)+
	addq.l		#8,a3
.go:	dbra		d7,.all
	rts

*-------------------------------------------------------*
*	Track down one patch in WAD			*
*-------------------------------------------------------*
locate_patch:	
*-------------------------------------------------------*
	move.l		a0,a1
	bsr		hash_name
	move.l		hash_array,a2
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	move.l		(a2,d1.w*4),d5
	beq.s		.err
	move.l		d5,a1
	lea		wd_name(a1),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.cont
	move.l		d5,d0
	bra.s		.exit
.cont:	addq.w		#1,d1
	dbra		d4,.find
.err:	moveq		#0,d0
.exit:	rts
	
*-------------------------------------------------------*
*	Create hashtable to reduce search overheads	*
*-------------------------------------------------------*
build_patch_hash:
*-------------------------------------------------------*
*	Create hashtable for all valid entries		*
*-------------------------------------------------------*
.cont:	bsr		empty_hash
	move.l		wad_directory,a0
	move.l		wad_entries,d7
	move.l		hash_array,a2
	bra.s		.go
*-------------------------------------------------------*
*	Generate hash index for entry			*
*-------------------------------------------------------*
.all:	lea		wd_name(a0),a1
	bsr		hash_name
*-------------------------------------------------------*
*	Store reference in hash table			*
*-------------------------------------------------------*
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	tst.l		(a2,d1.w*4)
	beq.s		.slot
	addq.w		#1,d1
	dbra		d4,.find
.slot:	move.l		a0,(a2,d1.w*4)
*-------------------------------------------------------*
	lea		wd_len(a0),a0
.go:	dbra		d7,.all
.exit:	rts

*-------------------------------------------------------*
*	Create hashtable to reduce search overheads	*
*-------------------------------------------------------*
build_flat_hash:
*-------------------------------------------------------*
*	Track down 'f_start' & 'f_end' markers		*
*-------------------------------------------------------*
	st		flats_present
	lea		ascii_fstart,a0
	bsr		place_marker
	move.l		wad_mdirectory,flat_start
	tst.w		d0
	beq.s		.err
	lea		ascii_fend,a0
	push.l		wad_directory
	push.l		wad_entries	
	move.l		wad_mdirectory,wad_directory
	move.l		wad_mentries,wad_entries	
	bsr		place_marker
	pop.l		wad_entries
	pop.l		wad_directory
	move.l		wad_mdirectory,flat_end
	tst.w		d0
	bne.s		.cont
.err:	Cconws		#ascii_err_noflats
	sf		flats_present
	bra		.exit
*-------------------------------------------------------*
*	Create hashtable for all valid entries		*
*-------------------------------------------------------*
.cont:	bsr		empty_hash
	move.l		flat_end,d7
	move.l		flat_start,a0
	sub.l		a0,d7
	divu.l		#wd_len,d7
	move.l		hash_array,a2
	move.l		floating_array,a3
	bra.s		.go
*-------------------------------------------------------*
.all:
*-------------------------------------------------------*
	movem.l		d1-d7/a0-a6,-(sp)
	lea		wd_name(a0),a1
	lea		ascii_sky,a0
	bsr		strcmp_8
	movem.l		(sp)+,d1-d7/a0-a6
	tst.w		d0
	beq.s		.nsky
*-------------------------------------------------------*
*	Keep track of sky index				*
*-------------------------------------------------------*
	move.l		a3,d0
	sub.l		graphics_array,d0
	lsr.l		#2,d0
	move.w		d0,sky_index
*-------------------------------------------------------*
*	Generate hash index for entry			*
*-------------------------------------------------------*
.nsky:	lea		wd_name(a0),a1
	bsr		hash_name
*-------------------------------------------------------*
*	Store reference in hash table			*
*-------------------------------------------------------*
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	tst.l		(a2,d1.w*4)
	beq.s		.slot
	addq.w		#1,d1
	dbra		d4,.find
.slot:	move.l		a3,(a2,d1.w*4)
*-------------------------------------------------------*
*	Store index & directory in reference list	*
*-------------------------------------------------------*
	move.l		a0,(a3)+
*-------------------------------------------------------*
*	Store type in cache slot			*
*-------------------------------------------------------*
	move.w		graphics_count,d4
	lea		cache_slots,a1
	mulu.w		#cache_slen,d4
	move.w		#ctype_raw,cache_type(a1,d4.l)
	addq.w		#1,flat_count
	addq.w		#1,graphics_count
*-------------------------------------------------------*
.next:	lea		wd_len(a0),a0
.go:	dbra		d7,.all
	move.l		a3,floating_array
.exit:	rts

*-------------------------------------------------------*
*	Remove upper / lower names from sky linedefs	*
*-------------------------------------------------------*
fix_sky_textures:
*-------------------------------------------------------*
	Cconws		#ascii_fixsky
	move.l		Line_Array,a2
	move.l		Sector_Array,a4
	move.l		Side_Array,a6
	move.w		NumLines,d7
	bra		.lines
.line:	move.w		linedef_left(a2),d0
	bpl.s		.ok1
	move.w		linedef_right(a2),d0
	bmi		.err
.ok1:	mulu.w		#sidedef_len,d0
	lea		(a6,d0.l),a1			; left sidedef
	move.w		linedef_right(a2),d0
	bpl.s		.ok2
	move.w		linedef_left(a2),d0
.ok2:	mulu.w		#sidedef_len,d0
	lea		(a6,d0.l),a3			; right sidedef
	push.l		a6
	move.w		sidedef_sector(a1),d0
	mulu.w		#sector_len,d0
	lea		(a4,d0.l),a6			; left sector
	move.w		sidedef_sector(a3),d0
	mulu.w		#sector_len,d0
	lea		(a4,d0.l),a5			; right sector
	cmp.l		#'F_SK',sector_ctns+0(a6)
	bne.s		.skc
	cmp.w		#'Y1',sector_ctns+4(a6)
	bne.s		.skc
	cmp.l		#'F_SK',sector_ctns+0(a5)
	bne.s		.skc
	cmp.w		#'Y1',sector_ctns+4(a5)
	bne.s		.skc
	lea		sidedef_utns(a1),a0
	bsr		clear_name
	lea		sidedef_utns(a3),a0
	bsr		clear_name
.skc:	cmp.l		#'F_SK',sector_ftns+0(a6)
	bne.s		.skf
	cmp.w		#'Y1',sector_ftns+4(a6)
	bne.s		.skf
	cmp.l		#'F_SK',sector_ftns+0(a5)
	bne.s		.skf
	cmp.w		#'Y1',sector_ftns+4(a5)
	bne.s		.skf
	lea		sidedef_ltns(a1),a0
	bsr		clear_name
	lea		sidedef_ltns(a3),a0
	bsr		clear_name
.skf:	pop.l		a6
.err:	lea		linedef_len(a2),a2
.lines:	dbra		d7,.line
	rts

*-------------------------------------------------------*
*	Trash texture name				*
*-------------------------------------------------------*
clear_name:
*-------------------------------------------------------*
	move.b		#'~',(a0)+
	clr.b		(a0)+
	clr.w		(a0)+
	clr.l		(a0)+
	rts

*-------------------------------------------------------*
*	Replace flat names with quick-index values	*
*-------------------------------------------------------*
replace_flats:
*-------------------------------------------------------*
	bsr		build_flat_hash
	Cconws		#ascii_replaceflat
	move.l		Sector_Array,a3
	move.w		NumSectors,d7
	bra.s		.segs
.seg:	lea		sector_ctns(a3),a0
	bsr.s		replace_flatname
	lea		sector_ftns(a3),a0
	bsr.s		replace_flatname
	lea		sector_len(a3),a3
.segs:	dbra		d7,.seg
	rts

*-------------------------------------------------------*
*	Replace flat name with quick-index		*
*-------------------------------------------------------*
replace_flatname:
*-------------------------------------------------------*
	cmp.b		#'-',(a0)
	beq.s		.none
	move.l		a0,a1
	bsr		hash_name
	move.l		hash_array,a2
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	move.l		(a2,d1.w*4),d5
	beq.s		.err
	move.l		d5,a4
	move.l		(a4),a1
	lea		wd_name(a1),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.cont
	sub.l		graphics_array,d5
	lsr.l		#2,d5
	move.w		d5,(a0)+
	bra.s		.done
.cont:	addq.w		#1,d1
	dbra		d4,.find
.err:	clr.w		(a0)+
	bra.s		.done
.none:	move.w		#-1,(a0)+
.done:	clr.w		(a0)+
	clr.l		(a0)+
	rts

*-------------------------------------------------------*
*	Load PNAME resource from WAD			*
*-------------------------------------------------------*
read_pnames:
*-------------------------------------------------------*
	Cconws		#ascii_readpnames
	lea		ascii_pnames,a0
	bsr		load_resource
	tst.l		d0
	beq		err_missing
	imov.l		(a6)+,d0
	move.w		d0,pname_count
	move.l		a6,pname_ptr
	rts

*-------------------------------------------------------*
*	Process texture directory			*
*-------------------------------------------------------*
add_textures:
*-------------------------------------------------------*
	bsr		load_resource
	tst.l		d0
	beq.s		.err1
	move.l		a6,resource_ptr
	move.l		texture_array,a4
	move.l		floating_array,a5
	imov.l		(a6)+,d6
	bra.s		.texs
.tex:	imov.l		(a6)+,a0
	add.l		resource_ptr,a0
	bsr		store_texturedef	
	addq.w		#1,graphics_count
	addq.w		#1,texture_count
.texs:	dbra		d6,.tex
	move.l		a5,floating_array
	move.l		a4,texture_array
	Mfree		resource_ptr
	st		textures_present
.err1:	rts

*-------------------------------------------------------*
*	Transfer texture definition to new array	*
*-------------------------------------------------------*
store_texturedef:
*-------------------------------------------------------*
*	Store type in cache slot			*
*-------------------------------------------------------*
	move.w		graphics_count,d0
	lea		cache_slots,a1
	mulu.w		#cache_slen,d0
	move.w		#ctype_texture,cache_type(a1,d0.l)
*-------------------------------------------------------*
*	Record this texture in graphics array		*
*-------------------------------------------------------*
	move.l		a4,(a5)+
*-------------------------------------------------------*
*	Create texture definition			*
*-------------------------------------------------------*
	movem.l		wt_name(a0),d0/d1
	movem.l		d0/d1,tex_name(a4)
	move.w		graphics_count,tex_index(a4)
	imov.w		wt_width(a0),tex_width(a4)
	imov.w		wt_height(a0),tex_height(a4)
	imov.w		wt_patches(a0),d1
	move.w		d1,tex_patches(a4)
	lea		wt_len(a0),a0
	lea		tex_len(a4),a4
	bra.s		.copys
.copy:	imov.w		wtp_xoff(a0),texp_xoff(a4)
	imov.w		wtp_yoff(a0),texp_yoff(a4)
	imov.w		wtp_index(a0),texp_index(a4)
	lea		wtp_len(a0),a0
	lea		texp_len(a4),a4
.copys:	dbra		d1,.copy
	rts

*-------------------------------------------------------*
*	Create hashtable to reduce search overheads	*
*-------------------------------------------------------*
build_texture_hash:
*-------------------------------------------------------*
	move.l		#texture_space,texture_array
	bsr		empty_hash
	move.l		hash_array,a2
	move.l		texturelist_array,a0
	move.w		texture_count,d7
	bra.s		.hashs
.next:	move.l		(a0)+,a1
	move.l		a1,a3
	bsr.s		hash_name
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	tst.l		(a2,d1.w*4)
	beq.s		.slot
	addq.w		#1,d1
	dbra		d4,.find
.slot:	move.l		a3,(a2,d1.w*4)
.hashs:	dbra		d7,.next
	rts

*-------------------------------------------------------*
*	Generate hash index for 8-character name	*
*-------------------------------------------------------*
hash_name:
*-------------------------------------------------------*
	moveq		#0,d1
	moveq		#1,d3
	moveq		#8-1,d2
.all:	moveq		#0,d0
	move.b		(a1)+,d0
	beq.s		.hash
	fixcase		d0
	sub.w		#'0',d0
	muls.w		d3,d0
	add.l		d0,d1
	addq.w		#8,d3
	dbra		d2,.all
.hash:	and.w		#max_hash-1,d1
	rts
	
*-------------------------------------------------------*
*	Replace texture names with quick-index values	*
*-------------------------------------------------------*
replace_textures:		
*-------------------------------------------------------*
	Cconws		#ascii_replacetex
	move.l		Side_Array,a3
	move.w		NumSides,d7
	bra.s		.segs
.seg:	lea		sidedef_utns(a3),a0
	bsr.s		replace_texname
	lea		sidedef_ltns(a3),a0
	bsr.s		replace_texname
	lea		sidedef_mtns(a3),a0
	bsr.s		replace_texname
	lea		sidedef_len(a3),a3
.segs:	dbra		d7,.seg
	rts

*-------------------------------------------------------*
*	Replace texture name with quick-index		*
*-------------------------------------------------------*
replace_texname:
*-------------------------------------------------------*
	cmp.b		#'-',(a0)
	beq.s		.none
	cmp.b		#'~',(a0)
	beq.s		.sky
	move.l		a0,a1
	bsr		hash_name
	move.l		hash_array,a2
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	move.l		(a2,d1.w*4),d0
	beq.s		.err
	move.l		d0,a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.cont
	move.w		tex_index(a1),(a0)+
	bra.s		.done
.cont:	addq.w		#1,d1
	dbra		d4,.find
.err:	clr.w		(a0)+
	bra.s		.done
.sky:	move.w		#-2,(a0)+
	bra.s		.done
.none:	move.w		#-1,(a0)+
.done:	clr.w		(a0)+
	clr.l		(a0)+
	rts

*-------------------------------------------------------*
*	Wipe hashtable					*
*-------------------------------------------------------*
empty_hash:
*-------------------------------------------------------*
	Cconws		#ascii_hashtex
	move.l		hash_array,a0
	moveq		#0,d1
	move.w		#max_hash-1,d0
.clr:	move.l		d1,(a0)+
	dbra		d0,.clr
	rts

*-------------------------------------------------------*
*	Simple mainloop for texture browser		*
*-------------------------------------------------------*
texture_loop:	
*-------------------------------------------------------*
	push.w		window_size
	move.w		#window_max,window_size
	bsr		select_window
	bsr		adjust_scanlines

	moveq		#0,d0
	lea		key_buffer,a6
	bra		.tok
.loop:
	ifd		debuggable
	pushall
	bsr		read_key
	popall
	endc
	tst.b		right_key(a6)
	beq.s		.n1
	addq.w		#1,d0
	cmp.w		texture_count,d0
	bmi.s		.tok
	move.w		texture_count,d0
	subq.w		#1,d0
.tok:	pushall
	move.b		#1,refresh
	move.l		ScreenPhy,a0
	bsr		clearscreen
	popall
	bsr		render_texture
.n1:	tst.b		left_key(a6)
	beq.s		.n2
	subq.w		#1,d0
	bpl.s		.ok1
	moveq		#0,d0
.ok1:	pushall
	move.b		#1,refresh
	move.l		ScreenPhy,a0
	bsr		clearscreen
	popall
	bsr		render_texture
.n2:	tst.b		text_key(a6)
	beq		.loop
	pop.w		window_size
	bsr		select_window
	rts

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

ascii_texture1:		dc.b	'texture1',0		; WAD search details
ascii_texture2:		dc.b	'texture2',0
ascii_pnames:		dc.b	'pnames',0
ascii_sky:		dc.b	'f_sky1',0
ascii_fstart:		dc.b	'f_start',0
ascii_fend:		dc.b	'f_end',0
ascii_pstart:		dc.b	'p_start',0
ascii_pend:		dc.b	'p_end',0

ascii_loadflats:	dc.b	13,10
			dc.b	' Preloading floor & ceiling textures...',0
ascii_loadwalls:	dc.b	13,10
			dc.b	' Preloading wall textures...',0
ascii_readpnames:	dc.b	13,10
			dc.b	' Reading [pnames] directory...',0
ascii_readtex1:		dc.b	13,10
			dc.b	' Reading [texture1] directory...',0
ascii_readtex2:		dc.b	13,10
			dc.b	' Reading [texture2] directory...',0
ascii_hashtex:		dc.b	13,10
			dc.b	' Generating hashtable...',0
ascii_replacetex:	dc.b	13,10
			dc.b	' Replacing textures...',0
ascii_replaceflat:	dc.b	13,10
			dc.b	' Replacing flats...',0
ascii_fixsky:		dc.b	13,10
			dc.b	' Validating sky sidedefs...',0
ascii_locatepatch:	dc.b	13,10
			dc.b	' Organising patches...',0
ascii_replacedone:	dc.b	13,10
			dc.b	13,10
			dc.b	' Finished processing textures.',0

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

hash_array:		ds.l	1			; misc texture pointers

graphics_array:		ds.l	1
floating_array:		ds.l	1
flatlist_array:		ds.l	1
texturelist_array:	ds.l	1
pnamelist_array:	ds.l	1
texture_array:		ds.l	1
flat_start:		ds.l	1
flat_end:		ds.l	1
patch_start:		ds.l	1
patch_end:		ds.l	1
resource_ptr:		ds.l	1
pname_ptr:		ds.l	1

hash_space:		ds.l	max_hash		; space for texture arrays
graphics_space:		ds.l	max_graphics		; and quicksearch hashtable
pnamelist_space:	ds.l	max_textures

texture_space:		ds.b	(tex_len+(texp_len*4))*max_textures

graphics_count:		ds.w	1
flat_count:		ds.w	1
texture_count:		ds.w	1			
pname_count:		ds.w	1			; misc array sizes

flat_index:		ds.w	1			; misc flat index variables
sky_index:		ds.w	1

textures_present:	ds.b	1			; flags for missing resources
flats_present:		ds.b	1
patches_present:	ds.b	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
