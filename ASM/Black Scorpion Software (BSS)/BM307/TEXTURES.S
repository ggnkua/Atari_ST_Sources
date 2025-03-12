*=======================================================*
*	Texture module: updated 12/06/97		*
*=======================================================*

patchbuffer_size	=	256*1024		; space for all patches in texture

upper_sky_lum		=	180
lower_sky_lum		=	180

texcode_none		=	-1
texcode_sky		=	-2
texcode_qalpha		=	-3

*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
patch_width		rs.w	1
patch_height		rs.w	1
patch_slen		rs.b	0

*-------------------------------------------------------*
*	Texture structure				*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
tex_name		rs.b	8
tex_index		rs.w	1
tex_width		rs.w	1
tex_height		rs.w	1
tex_patches		rs.w	1
tex_special		rs.l	1
tex_len			rs.b	0

*-------------------------------------------------------*
*	Texture patch sub-structure			*
*-------------------------------------------------------*
			rsreset
*-------------------------------------------------------*
texp_xoff		rs.w	1
texp_yoff		rs.w	1
texp_index		rs.w	1
texp_len		rs.b	0

*-------------------------------------------------------*
*	Read & convert texture resource directories	*
*-------------------------------------------------------*
init_textures:
*-------------------------------------------------------*
*	Set up list & resource pointers			*
*-------------------------------------------------------*
	move.l		#graphics_space,graphics_array
	move.l		#graphics_space,floating_array
	move.l		#texture_space,texture_array
	move.l		#pnamelist_space,pnamelist_array
	move.l		#sprite_space,sprite_array
	clr.w		graphics_count
	clr.w		flat_count
	clr.w		texture_count
	sf		textures_present
*-------------------------------------------------------*
*	Remove unwanted sidedef textures from sky	*
*-------------------------------------------------------*
;	bsr		fix_sky_textures
*-------------------------------------------------------*
*	Patch alpha textures				*
*-------------------------------------------------------*
	bsr		patch_alpha_textures
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
	bra		.go
*-------------------------------------------------------*
*	Build hash table for textures			*
*-------------------------------------------------------*
.cont:	bsr		build_texture_hash
*-------------------------------------------------------*
*	Find sky textures				*
*-------------------------------------------------------*
	lea		ascii_sky1,a0
	bsr		find_texture_index
	move.w		d0,sky1_index
	bmi.s		.n1
	move.w		d0,current_sky
.n1:	lea		ascii_sky2,a0
	bsr		find_texture_index
	move.w		d0,sky2_index
	bmi.s		.n2
	move.w		d0,current_sky
.n2:	lea		ascii_sky3,a0
	bsr		find_texture_index
	move.w		d0,sky3_index
	bmi.s		.n3
	move.w		d0,current_sky
.n3:	lea		ascii_sky4,a0
	bsr		find_texture_index
	move.w		d0,sky4_index
	bmi.s		.n4
	move.w		d0,current_sky
.n4:	lea		ascii_warp,a0
	bsr		find_texture_index
	move.w		d0,warp_index
	lea		ascii_warp2,a0
	bsr		find_texture_index
	tst.w		d0
	bmi.s		.n5
	move.w		d0,warp_index
*-------------------------------------------------------*
*	Find sky texture from levelmarker		*
*-------------------------------------------------------*
.n5:	lea		levelmarker,a0
	moveq		#0,d0
	cmp.l		#-1,(a0)
	beq.s		.gotsk	
	cmp.w		#'ma',(a0)
	beq.s		.mapxx
.exmy:	move.b		1(a0),d0
	sub.b		#'1',d0
	bra.s		.gotsk
.mapxx:	move.b		3(a0),d0
	sub.b		#'0',d0	
	cmp.b		#3,d0
	blo.s		.gotsk
	clr.l		d0
.gotsk:	and.w		#$ff,d0
*-------------------------------------------------------*
*	Look up sky index				*
*-------------------------------------------------------*
	lea		skies,a1
	move.w		(a1,d0.w*2),d0
	bmi.s		.go
	move.w		d0,current_sky
*-------------------------------------------------------*
*	Find sky wrap size				*
*-------------------------------------------------------*
.go:	move.w		current_sky,d0
	lea		graphics_space,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),d0
	lsl.w		#4,d0
	subq.w		#1,d0
	and.w		#%0111111111110000,d0
	move.w		d0,sky_width
*-------------------------------------------------------*
*	Replace wall texture references with indexes	*
*-------------------------------------------------------*
	bsr		replace_textures
*-------------------------------------------------------*
	bsr		organise_patches
*-------------------------------------------------------*
*	Log all sprites					*
*-------------------------------------------------------*
	bsr		build_sprite_hash
*-------------------------------------------------------*
	lea		ascii_sprite,a0
	bsr		find_sprite_index
	move.w		d0,sprite_index
	rts

*-------------------------------------------------------*
*	Create tracking list for patches		*
*-------------------------------------------------------*
organise_patches:
*-------------------------------------------------------*
	bsr		build_directory_hash
	Cconws		#ascii_locatepatch
	move.l		pname_ptr,a3
	move.l		pnamelist_array,a6
	move.w		pname_count,d7
	bra.s		.go
.all:	move.l		a3,a0
	bsr		locate_entry
.cont:	move.l		d0,(a6)+
	addq.l		#8,a3
.go:	dbra		d7,.all
	rts

*-------------------------------------------------------*
*	Create hashtable to reduce search overheads	*
*-------------------------------------------------------*
build_flat_hash:
*-------------------------------------------------------*
	st		flats_present
*-------------------------------------------------------*
	bsr		empty_hash
*-------------------------------------------------------*
*	Log everything between 'f_start' & 'f_end'	*
*-------------------------------------------------------*
	lea		ascii_fstart,a0
	lea		ascii_fend,a1
	bsr		log_flats
*-------------------------------------------------------*
	tst.w		d0
	bne.s		.exit
	Cconws		#ascii_err_noflats
	sf		flats_present
*-------------------------------------------------------*
.exit:	rts

*-------------------------------------------------------*
log_flats:
*-------------------------------------------------------*
	push.l		a1
	bsr		place_marker
	pop.l		a1
	tst.w		d0
	beq		.exit
	move.l		wad_mdirectory,flat_start
	move.l		a1,a0
	push.l		all_directory
	push.l		all_entries	
	move.l		wad_mdirectory,all_directory
	move.l		wad_mentries,all_entries	
	bsr		place_marker
	pop.l		all_entries
	pop.l		all_directory
	move.l		wad_mdirectory,flat_end
	tst.w		d0
	beq		.exit
*-------------------------------------------------------*
	move.l		flat_end,d7
	move.l		flat_start,a0
	add.l		#wd_len,a0
	sub.l		a0,d7
	divu.l		#wd_len,d7
	move.l		hash_array,a2
	move.l		floating_array,a3
	bra		.go
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
*-------------------------------------------------------*
	moveq		#1,d0
.exit:	rts

*-------------------------------------------------------*
log_sprites:
*-------------------------------------------------------*
	clr.l		spritename_count
*-------------------------------------------------------*
	push.l		a1
	bsr		place_marker
	pop.l		a1
	tst.w		d0
	beq		.exit
	move.l		wad_mdirectory,sprite_start
	move.l		a1,a0
	push.l		all_directory
	push.l		all_entries	
	move.l		wad_mdirectory,all_directory
	move.l		wad_mentries,all_entries	
	bsr		place_marker
	pop.l		all_entries
	pop.l		all_directory
	move.l		wad_mdirectory,sprite_end
	tst.w		d0
	beq		.exit
*-------------------------------------------------------*
	move.l		sprite_end,d7
	move.l		sprite_start,a0
	add.l		#wd_len,a0
	sub.l		a0,d7
	divu.l		#wd_len,d7
	move.l		hash_array,a2
	move.l		floating_array,a3
	move.l		sprite_array,a4
	bra		.go
*-------------------------------------------------------*
.all:
*-------------------------------------------------------*
*	Generate hash index for entry			*
*-------------------------------------------------------*
	lea		wd_name(a0),a1
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
*	Store type in cache slot			*
*-------------------------------------------------------*
	move.w		graphics_count,d4
	lea		cache_slots,a1
	mulu.w		#cache_slen,d4
	move.w		#ctype_sprite,cache_type(a1,d4.l)
*-------------------------------------------------------*
	movem.l		wd_name(a0),d1-d2
	movem.l		d1-d2,tex_name(a4)
	move.w		graphics_count,tex_index(a4)
	move.l		a0,tex_special(a4)
*-------------------------------------------------------*
	pushall
*-------------------------------------------------------*
	lea		patchbuffer_space,a1
	moveq		#4,d1
	jsr		read_resource
*-------------------------------------------------------*
	popall
*-------------------------------------------------------*
	lea		patchbuffer_space,a1
	imov.w		(a1)+,tex_width(a4)
	imov.w		(a1)+,tex_height(a4)
*-------------------------------------------------------*
*	Store index & directory in reference list	*
*-------------------------------------------------------*
	move.l		a4,(a3)+
*-------------------------------------------------------*
	addq.w		#1,sprite_count
	addq.w		#1,graphics_count
*-------------------------------------------------------*
*	Assign frame to established sprite type		*
*-------------------------------------------------------*
	jsr		assign_spritename
*-------------------------------------------------------*
	lea		tex_len(a4),a4
*-------------------------------------------------------*
.next:	lea		wd_len(a0),a0
.go:	dbra		d7,.all
	move.l		a3,floating_array
*-------------------------------------------------------*
	moveq		#1,d0
.exit:	rts

*-------------------------------------------------------*
*	Create hashtable to reduce search overheads	*
*-------------------------------------------------------*
build_sprite_hash:
*-------------------------------------------------------*
	Cconws		#ascii_logsprites
*-------------------------------------------------------*
	st		sprites_present
*-------------------------------------------------------*
	bsr		empty_hash
*-------------------------------------------------------*
*	Log everything between 's_start' & 's_end'	*
*-------------------------------------------------------*
	lea		ascii_sstart,a0
	lea		ascii_send,a1
	bsr		log_sprites
*-------------------------------------------------------*
	tst.w		d0
	bne.s		.exit
	Cconws		#ascii_err_nosprites
	sf		sprites_present
*-------------------------------------------------------*
.exit:	rts


*-------------------------------------------------------*
*	Remove upper / lower names from sky linedefs	*
*-------------------------------------------------------*
fix_sky_textures:
*-------------------------------------------------------*
	Cconws		#ascii_fixsky
*-------------------------------------------------------*
	move.l		Line_Array,a2
	move.l		Side_Array,a6
	move.w		NumLines,d7
	bra		.lines
*-------------------------------------------------------*
.line:	move.w		linedef_left(a2),d0
	bmi		.err
	mulu.w		#sidedef_len,d0
	lea		(a6,d0.l),a4			; left sidedef
	move.w		linedef_right(a2),d0
	bmi		.err
	mulu.w		#sidedef_len,d0
	lea		(a6,d0.l),a3			; right sidedef
*-------------------------------------------------------*
	push.l		a6
*-------------------------------------------------------*
	move.l		Sector_Array,a0
	move.w		sidedef_sector(a4),d0
	mulu.w		#sector_len,d0
	lea		(a0,d0.l),a6			; left sector
	move.w		sidedef_sector(a3),d0
	mulu.w		#sector_len,d0
	lea		(a0,d0.l),a5			; right sector
*-------------------------------------------------------*
	lea		ascii_sky,a0
	lea		sector_ctns(a5),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.no_upper_sky
	lea		sector_ctns(a6),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.no_upper_sky
*-------------------------------------------------------*
	lea		sidedef_utns(a4),a0
	bsr		sky_name
	lea		sidedef_utns(a3),a0
	bsr		sky_name
*-------------------------------------------------------*
.no_upper_sky:
*-------------------------------------------------------*
	lea		ascii_sky,a0
	lea		sector_ftns(a5),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.no_lower_sky
	lea		sector_ftns(a6),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.no_lower_sky
*-------------------------------------------------------*
	lea		sidedef_ltns(a4),a0
	bsr		sky_name
	lea		sidedef_ltns(a3),a0
	bsr		sky_name
*-------------------------------------------------------*
.no_lower_sky:
*-------------------------------------------------------*
	pop.l		a6
*-------------------------------------------------------*
.err:	lea		linedef_len(a2),a2
.lines:	dbra		d7,.line
	rts


*-------------------------------------------------------*
*	Patch quick-alpha textures			*
*-------------------------------------------------------*
patch_alpha_textures:
*-------------------------------------------------------*
	Cconws		#ascii_patchalpha
	move.l		Side_Array,a3
	move.w		NumSides,d7
	bra.s		.segs
.seg:
;	lea		sidedef_utns(a3),a1
;	bsr		alpha_check
;	lea		sidedef_ltns(a3),a1
;	bsr		alpha_check
	lea		sidedef_mtns(a3),a1
	bsr		alpha_check
	lea		sidedef_len(a3),a3
.segs:	dbra		d7,.seg
	rts

*-------------------------------------------------------*
alpha_check:
*-------------------------------------------------------*
	lea		ascii_qalpha,a0
	bsr		strcmp_8
	tst.w		d0
	beq.s		.not_alpha
*-------------------------------------------------------*
*	Alpha texture detected				*
*-------------------------------------------------------*
	move.w		#'~q',(a1)+
	clr.w		(a1)+
	clr.l		(a1)+
*-------------------------------------------------------*
.not_alpha:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Trash texture name				*
*-------------------------------------------------------*
sky_name:
*-------------------------------------------------------*
	move.w		#'~s',(a0)+
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
	bsr		replace_flatname
	lea		sector_ftns(a3),a0
	bsr		replace_flatname
	lea		sector_len(a3),a3
.segs:	dbra		d7,.seg
*-------------------------------------------------------*
*	Find water, slime, waste and lava textures	*
*-------------------------------------------------------*
	lea		ascii_blood,a0
	bsr		find_flat_index
	move.w		d0,blood_index
	lea		ascii_water,a0
	bsr		find_flat_index
	move.w		d0,water_index
	lea		ascii_lava,a0
	bsr		find_flat_index
	move.w		d0,lava_index
	lea		ascii_waste,a0
	bsr		find_flat_index
	move.w		d0,waste_index
	lea		ascii_slime,a0
	bsr		find_flat_index
	move.w		d0,slime_index
	rts

*-------------------------------------------------------*
*	Replace flat name with quick-index		*
*-------------------------------------------------------*
find_flat_index:
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
	move.w		d5,d0
	bra.s		.done
.cont:	addq.w		#1,d1
	dbra		d4,.find
.err:	moveq		#-1,d0
	bra.s		.done
.none:	moveq		#-1,d0
.done:	rts

*-------------------------------------------------------*
find_sprite_index:
*-------------------------------------------------------*
	move.l		a0,a1
	bsr		hash_name
	move.l		hash_array,a2
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	move.l		(a2,d1.w*4),d5
	beq.s		.err
	move.l		d5,a4
	move.l		(a4),a1
	move.l		tex_special(a1),a1
	lea		wd_name(a1),a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.cont
	sub.l		graphics_array,d5
	lsr.l		#2,d5
	move.w		d5,d0
	bra.s		.done
.cont:	addq.w		#1,d1
	dbra		d4,.find
.err:	moveq		#-1,d0
	bra.s		.done
.none:	moveq		#-1,d0
.done:	rts


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
	beq		.err1
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
	move.l		resource_ptr,d0
	jsr		deallocate_chunk
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
*	Find texture index using hashtable		*
*-------------------------------------------------------*
find_texture_index:
*-------------------------------------------------------*
	move.l		a0,a1
	bsr		hash_name
	move.l		hash_array,a2
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	move.l		(a2,d1.w*4),d0
	beq.s		.none
	move.l		d0,a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.cont
	move.w		tex_index(a1),d0
	bra.s		.done
.cont:	addq.w		#1,d1
	dbra		d4,.find
.none:	moveq		#-1,d0
.done:	rts

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
	beq.s		no_texture
*-------------------------------------------------------*
	cmp.b		#'~',(a0)
	beq.s		special_texture
*-------------------------------------------------------*
normal_texture:
*-------------------------------------------------------*
	move.l		a0,a1
	bsr		hash_name
	move.l		hash_array,a2
	move.w		#max_hash-1,d4
.find:	and.w		#max_hash-1,d1
	move.l		(a2,d1.w*4),d0
	beq.s		missing_texture
	move.l		d0,a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.cont
	move.w		tex_index(a1),(a0)+
	bra.s		texture_done
.cont:	addq.w		#1,d1
	dbra		d4,.find
*-------------------------------------------------------*
missing_texture:
*-------------------------------------------------------*
	move.w		#texcode_none,(a0)+
;	clr.w		(a0)+
	bra.s		texture_done
*-------------------------------------------------------*
special_texture:
*-------------------------------------------------------*
	cmp.w		#'~s',(a0)
	beq.s		.sky
	cmp.w		#'~q',(a0)
	beq.s		.qal
	bra		missing_texture
*-------------------------------------------------------*
*	Sky texture					*
*-------------------------------------------------------*
.sky:	move.w		#texcode_sky,(a0)+
	bra.s		texture_done
*-------------------------------------------------------*
*	Quick-alpha texture				*
*-------------------------------------------------------*
.qal:	move.w		#texcode_qalpha,(a0)+
	bra.s		texture_done
*-------------------------------------------------------*
no_texture:
*-------------------------------------------------------*
	move.w		#texcode_none,(a0)+
*-------------------------------------------------------*
texture_done:
*-------------------------------------------------------*
	clr.w		(a0)+
	clr.l		(a0)+
	rts

*-------------------------------------------------------*
*	Wipe hashtable					*
*-------------------------------------------------------*
empty_hash:
*-------------------------------------------------------*
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
*	Draw composite texture to the screen		*
*-------------------------------------------------------*
render_texture:
*-------------------------------------------------------*
	bsr		clear_patchtags
	bsr		load_patches
	bsr		add_patches
	rts
	
*-------------------------------------------------------*
*	Load all unique patches into temp buffer	*
*-------------------------------------------------------*
load_patches:
*-------------------------------------------------------*
	pushall
	move.l		#patchbuffer_space,patchbuffer_ptr
;	move.l		texturelist_array,a0
	move.l		graphics_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),patch_xclip
	move.w		tex_height(a0),patch_yclip
	move.w		tex_patches(a0),d6
	lea		tex_len(a0),a0
	bra.s		.go
.all:	move.w		texp_index(a0),d0
	lea		patch_taglist,a1
	move.w		patch_tags,d1
	bra.s		.tgo
.tlp:	cmp.w		(a1),d0
	beq.s		.old
	addq.l		#6,a1
.tgo:	dbra		d1,.tlp
	addq.w		#1,patch_tags
	move.w		d0,(a1)+
	move.l		patchbuffer_ptr,(a1)+
	pushall
	move.l		pnamelist_array,a2
	move.l		(a2,d0.w*4),d1
	beq		.skip
	move.l		d1,a0
	move.l		patchbuffer_ptr,a1
	move.l		wd_size(a0),d1
	add.l		d1,patchbuffer_ptr
	bsr		read_resource
.skip:	popall
.old:	lea		texp_len(a0),a0
.go:	dbra		d6,.all
	popall
	rts

*-------------------------------------------------------*
*	Prepare to load unique patches using tags	*
*-------------------------------------------------------*
clear_patchtags:
*-------------------------------------------------------*
	clr.w		patch_tags
	move.w		#max_patches,d1
	lea		patch_taglist,a1
	bra.s		.fgo
.flp:	move.w		#terminator,(a1)+
	addq.l		#4,a1
.fgo:	dbra		d1,.flp
	rts
	
*-------------------------------------------------------*
*	Build texture up from patches			*
*-------------------------------------------------------*
add_patches:
*-------------------------------------------------------*
	pushall
	move.l		graphics_array,a0
;	move.l		texturelist_array,a0
	move.l		(a0,d0.w*4),a0
	move.w		tex_width(a0),patch_xclip
	move.w		tex_height(a0),patch_yclip
	move.w		tex_patches(a0),d6
	lea		tex_len(a0),a0
	bra.s		.go
.all:	move.w		texp_xoff(a0),patch_xoff
	move.w		texp_yoff(a0),patch_yoff
	move.w		texp_index(a0),patch_index
	push.w		d6
	push.l		a0
	bsr		render_patch_tex
	pop.l		a0
	pop.w		d6
	lea		texp_len(a0),a0
.go:	dbra		d6,.all
	popall
	rts

*-------------------------------------------------------*
*	Draw one patch as a section of a texture	*
*-------------------------------------------------------*
render_patch:
*-------------------------------------------------------*
	move.w		patch_index,d0
	move.w		patch_tags,d1
	lea		patch_taglist,a1
	bra.s		.fgo
.flp:	cmp.w		(a1),d0
	beq.s		.got
	addq.l		#6,a1
.fgo:	dbra		d1,.flp
	bra		.err
.got:	addq.l		#2,a1
	move.l		(a1)+,a0
	move.l		ScreenPhy,a3
	lea		colourtables+(63*512),a5
	move.l		a0,a1
	imov.w		(a0)+,d6			; width
	imov.w		(a0)+,d7			; height
	imov.w		(a0)+,d0			; xoff
	imov.w		(a0)+,d1			; yoff
	move.w		patch_yclip,d5
	move.w		patch_yoff,d1
	move.w		patch_xoff,d0
	bpl.s		.xok
	add.w		d0,d6
	ble		.err
	neg.w		d0
	lea		(a0,d0.w*4),a0
	moveq		#0,d0
.xok:	lea		(a3,d0.w*2),a3
	add.w		d6,d0
	sub.w		patch_xclip,d0
	ble.s		.go
	sub.w		d0,d6
	ble		.err
	bra.s		.go
.col:	imov.l		(a0)+,a2
	add.l		a1,a2				; post data
.next:	moveq		#0,d0
	move.b		(a2)+,d0
	cmp.b		#255,d0
	beq.s		.stop
	move.w		d1,d2				; base y-offset
	add.w		d0,d2				; post y-offset
	move.w		d2,d3
	muls.w		bytewidth,d3
	lea		(a3,d3.l),a4
	moveq		#0,d0
	move.b		(a2)+,d0			; post length
	moveq		#0,d3
	addq.l		#1,a2
	bra.s		.vgo
.vert:	move.b		(a2)+,d3
	tst.w		d2
	bmi.s		.skip
	cmp.w		d5,d2
	bpl.s		.skip
	move.w		(a5,d3.w*2),(a4)
.skip:	addq.w		#1,d2
	add.w		bytewidth,a4
.vgo:	dbra		d0,.vert
	addq.l		#1,a2
	bra.s		.next
.stop:	addq.l		#2,a3
.go:	dbra		d6,.col
.err:	rts

*-------------------------------------------------------*
*	Draw one patch as a section of a texture	*
*-------------------------------------------------------*
render_patch_tex:
*-------------------------------------------------------*
	move.w		patch_index,d0
	move.w		patch_tags,d1
	lea		patch_taglist,a1
	bra.s		.fgo
.flp:	cmp.w		(a1),d0
	beq.s		.got
	addq.l		#6,a1
.fgo:	dbra		d1,.flp
	bra		patch_error
.got:	addq.l		#2,a1
	move.l		(a1)+,a0
*-------------------------------------------------------*
render_patch_direct:
*-------------------------------------------------------*
	move.l		texture_ptr,a3
	move.l		a0,a1
	imov.w		(a0)+,d6			; width
	imov.w		(a0)+,d7			; height
	imov.w		(a0)+,d0			; xoff
	imov.w		(a0)+,d1			; yoff
	move.w		black,d7
	move.w		patch_yclip,d5
	move.w		patch_yoff,d1
	move.w		patch_xoff,d0
	bpl.s		.xok
	add.w		d0,d6
	ble		patch_error
	neg.w		d0
	lea		(a0,d0.w*4),a0
	moveq		#0,d0
.xok:	move.w		d0,d3
	mulu.w		patch_yclip,d3
	add.l		d3,a3
	add.w		d6,d0
	sub.w		patch_xclip,d0
	ble.s		.go
	sub.w		d0,d6
	ble		patch_error
	bra.s		.go
.col:	imov.l		(a0)+,a2
	add.l		a1,a2				; post data
.next:	moveq		#0,d0
	move.b		(a2)+,d0
	cmp.b		#255,d0
	beq.s		.stop
	move.w		d1,d2				; base y-offset
	add.w		d0,d2				; post y-offset
	move.w		d2,d3
	lea		(a3,d3.w),a4
	moveq		#0,d0
	move.b		(a2)+,d0			; post length
	moveq		#0,d3
	addq.l		#1,a2
	bra.s		.vgo
.vert:	tst.w		d2
	bmi.s		.skip
	cmp.w		d5,d2
	bpl.s		.skip
	move.b		(a2),d3
	bne.s		.nz
	move.b		d7,d3
.nz:	move.b		d3,(a4)
.skip:	addq.l		#1,a2
	addq.w		#1,d2
	addq.l		#1,a4
.vgo:	dbra		d0,.vert
	addq.l		#1,a2
	bra.s		.next
.stop:	add.w		patch_yclip,a3
.go:	dbra		d6,.col
*-------------------------------------------------------*
patch_error:
*-------------------------------------------------------*
	rts

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
sprite_array:		ds.l	1
flat_start:		ds.l	1
flat_end:		ds.l	1
patch_start:		ds.l	1
patch_end:		ds.l	1
sprite_start:		ds.l	1
sprite_end:		ds.l	1
resource_ptr:		ds.l	1
pname_ptr:		ds.l	1

patchbuffer_ptr:	ds.l	1
	
texture_ptr:		ds.l	1

patch_xclip:		ds.w	1			; patch dimensions & clipping rectangle
patch_yclip:		ds.w	1
patch_xoff:		ds.w	1
patch_yoff:		ds.w	1
patch_index:		ds.w	1
patch_tags:		ds.w	1

graphics_count:		ds.w	1
flat_count:		ds.w	1
texture_count:		ds.w	1			
pname_count:		ds.w	1			; misc array sizes
sprite_count:		ds.w	1			; misc array sizes

flat_index:		ds.w	1			; misc flat index variables
sky_index:		ds.w	1
current_sky:		ds.w	1
warp_index:		ds.w	1
sprite_index:		ds.w	1

skies:
sky1_index:		ds.w	1
sky2_index:		ds.w	1
sky3_index:		ds.w	1
sky4_index:		ds.w	1

water_index:		ds.w	1
slime_index:		ds.w	1
waste_index:		ds.w	1
lava_index:		ds.w	1
blood_index:		ds.w	1

textures_present:	ds.b	1			; flags for missing resources
flats_present:		ds.b	1
patches_present:	ds.b	1
sprites_present:	ds.b	1
			even

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

hash_space:		ds.l	max_hash		; space for texture arrays
graphics_space:		ds.l	max_graphics		; quicksearch hashtable
pnamelist_space:	ds.l	max_pnames		; space for pnames

sprite_space:		ds.b	max_sprites*tex_len

texture_space:		ds.b	(tex_len+(texp_len*4))*max_textures

patch_taglist:		ds.b	(2+4)*max_patches	; space for list of unique patch tags

patchbuffer_space:	ds.b	patchbuffer_size	; space for all patches in texture

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
