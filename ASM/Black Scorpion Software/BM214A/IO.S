*=======================================================*
*	IO routines: latest update 25/03/96		*
*=======================================================*
*	Handle all WAD related processes		*
*=======================================================*

	include		include\wad_tab.s
	
*-------------------------------------------------------*
parse_cli:
*-------------------------------------------------------*
	moveq		#0,d0
*-------------------------------------------------------*
	ifnd		test
*-------------------------------------------------------*
	move.l		cli,a4
	move.b		(a4)+,d0
	beq		safe_quit
*-------------------------------------------------------*
	elseif
*-------------------------------------------------------*
	lea		default_path,a4
	move.b		#255,d0
*-------------------------------------------------------*
	endc
*-------------------------------------------------------*	
	lea		cli_space,a5
	clr.b		(a4,d0.l)
.all:	move.b		(a4)+,(a5)+
	bne.s		.all
*-------------------------------------------------------*
	lea		levelmarker,a0
	move.l		#-1,(a0)
*-------------------------------------------------------*
*	Parse new CLI					*
*-------------------------------------------------------*
	bsr		parse_new_cli
*-------------------------------------------------------*
	tst.b		iwad_path
	bne.s		.not_old_cli
*-------------------------------------------------------*
*	Parse old CLI if new format not detected	*
*-------------------------------------------------------*
	bsr		parse_old_cli
*-------------------------------------------------------*
.not_old_cli:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
parse_new_cli:
*-------------------------------------------------------*
	lea		cli_space,a5
*-------------------------------------------------------*
*	Check for last character			*
*-------------------------------------------------------*
.nwad:	move.b		(a5)+,d1
	beq		.adon
	fixcase		d1
*-------------------------------------------------------*
*	Check for option				*
*-------------------------------------------------------*
	cmp.b		#'-',d1
	bne		.odon
*-------------------------------------------------------*
*	Check for new IWAD path				* 
*-------------------------------------------------------*
	lea		ascii_iwad_switch,a0
	bsr		check_switch
	tst.l		d0
	bmi.s		.niwad
	lea		iwad_path,a1
	move.w		#255,d7
	bsr		load_parameter
	bra.s		.odon
*-------------------------------------------------------*
*	Check for new PWAD path				* 
*-------------------------------------------------------*
.niwad:	lea		ascii_pwad_switch,a0
	bsr		check_switch
	tst.l		d0
	bmi.s		.npwad
	lea		pwad_path,a1
	move.w		#255,d7
	bsr		load_parameter
	bra.s		.odon
*-------------------------------------------------------*
*	Check for 'warp' level select			*
*-------------------------------------------------------*
.npwad:	lea		ascii_warp_switch,a0
	bsr		check_switch
	tst.l		d0
	bmi.s		.odon
	lea		levelmarker,a1
	moveq		#8,d7
	bsr		load_parameter
*-------------------------------------------------------*
*	Continue until CLI exhausted			*
*-------------------------------------------------------*
.odon:	bra		.nwad
*-------------------------------------------------------*
.adon:	rts

*-------------------------------------------------------*
load_parameter:
*-------------------------------------------------------*
	move.l		a5,a2
	bsr		skip_padding
*-------------------------------------------------------*
.next:	move.b		(a2)+,d1
	beq.s		.done
*-------------------------------------------------------*
	fixcase		d1
	cmp.b		#'.',d1
	blo.s		.done
	cmp.b		#'z',d1
	bhi.s		.done
	move.b		d1,(a1)+
	bra.s		.next
*-------------------------------------------------------*
.done:	clr.b		(a1)
	rts
	
*-------------------------------------------------------*
skip_padding:
*-------------------------------------------------------*
.next:	move.b		(a2)+,d1
	beq.s		.err
	fixcase		d1
	cmp.b		#'.',d1
	blo.s		.next
	cmp.b		#'z',d1
	bhi.s		.next
.err:	subq.l		#1,a2
	rts

*-------------------------------------------------------*
check_switch:
*-------------------------------------------------------*
	move.l		a5,a4
*-------------------------------------------------------*
.next:	move.b		(a0),d0
	move.b		(a4),d4
	fixcase		d0
	fixcase		d4
	cmp.b		#'.',d0
	blo.s		.done
	cmp.b		#'z',d0
	bhi.s		.done
	cmp.b		#'.',d4
	blo.s		.done
	cmp.b		#'z',d4
	bhi.s		.done
*-------------------------------------------------------*
	cmp.b		d0,d4
	bne.s		.err
*-------------------------------------------------------*
	addq.l		#1,a0
	addq.l		#1,a4
	bra.s		.next
*-------------------------------------------------------*
.err:	moveq		#-1,d0
	bra.s		.exit
*-------------------------------------------------------*
.done:	move.l		a4,a5
	moveq		#0,d0
.exit:	rts
	
*-------------------------------------------------------*
parse_old_cli:
*-------------------------------------------------------*
	lea		cli_space,a5
*-------------------------------------------------------*
*	Parse options					*
*-------------------------------------------------------*
.load:	lea		iwad_path,a0
	lea		levelmarker,a2
*-------------------------------------------------------*
*	Check for last character			*
*-------------------------------------------------------*
.nwad:	move.b		(a5)+,d1
	beq.s		.adon
	fixcase		d1
	cmp.b		#' ',d1
	beq.s		.nlwad
	move.b		d1,(a0)+
	bra.s		.nwad
*-------------------------------------------------------*
.nlwad:	move.b		(a5)+,d1
	beq.s		.done
	fixcase		d1
	move.b		d1,(a2)+
	bra.s		.nlwad
.done:	clr.b		(a2)
*-------------------------------------------------------*
*	Terminate IWAD path string			*
*-------------------------------------------------------*
.adon:	clr.b		(a0)
	rts

*-------------------------------------------------------*
*	Read details from IWAD				*
*-------------------------------------------------------*
parse_iwad:
*-------------------------------------------------------*
	Cconws		#ascii_startup
	bsr		open_wad
	tst.w		d0
	bmi		err_openwad
.wad_check:
	lea		wad_header,a5
	Fread		wad_handle,#wh_len,a5
	move.l		wh_sig(a5),d0
	cmp.l		#'IWAD',d0
	bne		err_badwad
.sig_valid:
	move.l		d0,wad_signature
	Cconws		#ascii_format1
	Cconws		#wad_signature
	imov.l		wh_entries(a5),d1
	move.l		d1,wad_entries
	tst.l		d1
	beq		err_badwad
	imov.l		wh_directory(a5),wad_diroffset
	Cconws		#ascii_entries
	move.l		wad_entries,d0
	moveq		#0,d1
	bsr		output_decimal
	Fseek		wad_diroffset,wad_handle,#0
	bsr		wad_readall
	rts	

*-------------------------------------------------------*
*	Read details from PWAD				*
*-------------------------------------------------------*
parse_pwad:
*-------------------------------------------------------*
	tst.b		pwad_path
	beq		.no_pwad
*-------------------------------------------------------*
	bsr		open_pwad
	tst.w		d0
	bmi		err_openwad
.wad_check:
	lea		pwad_header,a5
	Fread		pwad_handle,#wh_len,a5
	move.l		wh_sig(a5),d0
	cmp.l		#'PWAD',d0
	bne		err_badpwad
.sig_valid:
	move.l		d0,pwad_signature
	Cconws		#ascii_format2
	Cconws		#pwad_signature
	imov.l		wh_entries(a5),d1
	move.l		d1,pwad_entries
	tst.l		d1
	beq		err_badpwad
	imov.l		wh_directory(a5),pwad_diroffset
	Cconws		#ascii_entries
	move.l		pwad_entries,d0
	moveq		#0,d1
	bsr		output_decimal
	Fseek		pwad_diroffset,pwad_handle,#0
	bsr		pwad_readall
*-------------------------------------------------------*
.no_pwad:
*-------------------------------------------------------*
	rts	

*-------------------------------------------------------*
*	Integrate PWAD directory into main		*
*-------------------------------------------------------*
integrate_wads:
*-------------------------------------------------------*
	tst.b		pwad_path
	beq		.no_pwad
*-------------------------------------------------------*
*	Build quick-search hastable for IWAD		*
*-------------------------------------------------------*
	bsr		build_directory_hash
	Cconws		#ascii_integrate
*-------------------------------------------------------*
*	Integrate each new entry into main		*
*-------------------------------------------------------*
	move.l		pwad_directory,a3
	move.l		pwad_entries,d7
	bra		.go
*-------------------------------------------------------*
.all:	lea		wd_name(a3),a0	
	bsr		locate_entry
	tst.l		d0
	beq.s		.append_entry
*-------------------------------------------------------*
.patch_entry:
*-------------------------------------------------------*
*	Patch entry over main directory			*
*-------------------------------------------------------*
	move.l		d0,a4
	moveq		#0,d6
	bra.s		.check_type
*-------------------------------------------------------*
.append_entry:
*-------------------------------------------------------*
*	Append entry to main directory			*
*-------------------------------------------------------*
	move.l		all_directory,a4
	move.l		wad_entries,d1
	mulu.l		#wd_len,d1
	add.l		d1,a4
	moveq		#1,d6
*-------------------------------------------------------*
*	Check entry size (could be a whole group)	*
*-------------------------------------------------------*
.check_type:
*-------------------------------------------------------*
	lea		wd_name(a3),a0	
*-------------------------------------------------------*
*	Check for Doom level marker			*
*-------------------------------------------------------*
	lea		ascii_mask_exmx,a1
	bsr		strcmp_8_wild
	tst.w		d0
	bne.s		.level_group
*-------------------------------------------------------*
*	Check for Doom II level marker			*
*-------------------------------------------------------*
	lea		ascii_mask_mapxx,a1
	bsr		strcmp_8_wild
	tst.w		d0
	bne.s		.level_group
*-------------------------------------------------------*
*	Entry is a singular element			*
*-------------------------------------------------------*
.single_entry:
*-------------------------------------------------------*
	move.l		a4,a2
	move.l		a3,a0
	moveq		#(wd_len/4)-1,d0
.copy:	move.l		(a0)+,(a2)+
	dbra		d0,.copy
*-------------------------------------------------------*
*	Mark entry as PWAD resource			*
*-------------------------------------------------------*
	bset		#7,wd_offset(a4)
*-------------------------------------------------------*
*	Advance to next entry				*
*-------------------------------------------------------*
	add.l		d6,all_entries
	lea		wd_len(a3),a3
*-------------------------------------------------------*
	bra.s		.entry_done
*-------------------------------------------------------*
*	Entry is a group of elements			*
*-------------------------------------------------------*
.level_group:
*-------------------------------------------------------*
.element_loop:
*-------------------------------------------------------*
	move.l		a4,a2
	move.l		a3,a0
	moveq		#(wd_len/4)-1,d0
.copy1:	move.l		(a0)+,(a2)+
	dbra		d0,.copy1
*-------------------------------------------------------*
*	Mark entry as PWAD resource			*
*-------------------------------------------------------*
	bset		#7,wd_offset(a4)
*-------------------------------------------------------*
*	Advance to next entry				*
*-------------------------------------------------------*
	add.l		d6,all_entries
	lea		wd_len(a4),a4
	lea		wd_len(a3),a3
*-------------------------------------------------------*
*	Continue until entry not recognised		*
*-------------------------------------------------------*
	lea		level_fieldlist,a2
	lea		wd_name(a3),a0
.next:	move.l		0(a2),d0
	lea		8(a2),a2
	tst.l		d0
	ble.s		.entry_done
	move.l		d0,a1
	bsr		strcmp_8
	tst.w		d0
	beq.s		.next
*-------------------------------------------------------*
	bra.s		.element_loop
*-------------------------------------------------------*
.entry_done:
*-------------------------------------------------------*
.go:	dbra		d7,.all
*-------------------------------------------------------*
.no_pwad:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Create hashtable to reduce search overheads	*
*-------------------------------------------------------*
build_directory_hash:
*-------------------------------------------------------*
*	Create hashtable for all valid entries		*
*-------------------------------------------------------*
.cont:	bsr		empty_hash
	move.l		all_directory,a0
	move.l		all_entries,d7
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
*	Track down one entry in directory		*
*-------------------------------------------------------*
locate_entry:	
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
*	Read all IWAD directory entries			*
*-------------------------------------------------------*
wad_readall:
*-------------------------------------------------------*
	move.l		#max_wad_entries,d0
	mulu.l		#wd_len,d0
	move.l		d0,d7
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		err_memory
	move.l		d0,wad_directory
	Fread		wad_handle,d7,d0
.reformat_directory:
	move.l		wad_directory,a0
	move.l		wad_entries,d7
.reformat_next:
	imov.l		wd_offset(a0),wd_offset(a0)
	imov.l		wd_size(a0),wd_size(a0)
	lea		wd_len(a0),a0
	subq.l		#1,d7
	bne.s		.reformat_next
*-------------------------------------------------------*
*	Prepare to merge IWAD & PWAD directories	*
*-------------------------------------------------------*
	move.l		wad_entries,all_entries
	move.l		wad_directory,all_directory
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Read all PWAD directory entries			*
*-------------------------------------------------------*
pwad_readall:
*-------------------------------------------------------*
	move.l		pwad_entries,d0
	mulu.l		#wd_len,d0
	move.l		d0,d7
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		err_memory
	move.l		d0,pwad_directory
	Fread		pwad_handle,d7,d0
.reformat_directory:
	move.l		pwad_directory,a0
	move.l		pwad_entries,d7
.reformat_next:
	imov.l		wd_offset(a0),wd_offset(a0)
	imov.l		wd_size(a0),wd_size(a0)
	lea		wd_len(a0),a0
	subq.l		#1,d7
	bne.s		.reformat_next
	rts
	
*-------------------------------------------------------*
*	Load & format all level-critical information	*
*-------------------------------------------------------*
load_leveldata:
*-------------------------------------------------------*
	move.l		all_directory,wad_mdirectory
	move.l		all_entries,wad_mentries	
	lea		levelmarker,a0
	cmp.l		#-1,(a0)
	beq.s		.use_default
	bsr		place_marker
	tst.l		d0
	beq		err_missing
	push.l		a0
	move.l		a0,d7
	Cconws		#ascii_levelmark
	Cconws		d7
	Cconws		#ascii_newline
	pop.l		a0	
.use_default:
	bsr		init_fields
	move.l		wad_mentries,d7
	beq		err_fields
	cmp.l		#32,d7
	bmi.s		.clip_search
	moveq		#32,d7
.clip_search:
	move.l		wad_mdirectory,a1
	move.w		#field_count,fields_left
.next_entry:
	tst.w		fields_left
	beq.s		.fields_done
	lea		wd_name(a1),a0
	bsr		check_fields
	lea		wd_len(a1),a1
	subq.l		#1,d7
	bne.s		.next_entry
	tst.w		fields_left
	beq.s		.fields_done
	bra		err_fields
.fields_done:
	bsr		measure_linedefs
	Cconws		#ascii_parsingdone
	rts

*-------------------------------------------------------*
*	Calculate length of all walls for mapping	*	
*-------------------------------------------------------*
measure_linedefs:
*-------------------------------------------------------*
	move.l		Seg_Array,a0
	move.l		Vertex_Array,a1
	move.l		Line_Array,a2
	move.w		NumSegs,d0
	bra.s		.go
.lp:	moveq		#0,d1
	move.w		seg_from(a0),d1
	moveq		#0,d2
	move.w		seg_to(a0),d2
	move.w		vtx_x(a1,d1.l*4),d3
	move.w		vtx_y(a1,d1.l*4),d4
	move.w		vtx_x(a1,d2.l*4),d5
	move.w		vtx_y(a1,d2.l*4),d6
	sub.w		d3,d5
	sub.w		d4,d6
	muls.w		d5,d5
	muls.w		d6,d6
	add.l		d5,d6
	bsr		square_root
	move.l		d7,seg_length(a0)		; temporarily use BAM field for length
	lea		seg_len(a0),a0
.go:	dbra		d0,.lp
	rts

*-------------------------------------------------------*
*	Simple subdivisional 16.16 sqrt routine		*
*-------------------------------------------------------*
square_root:
*-------------------------------------------------------*
	tst.l		d6
	bpl.s		.pos
	neg.l		d6
.pos:	move.l		#1<<(32-1),d7
	move.l		#1<<(32-2),d5
.loop:	move.l		d7,d3
	mulu.l		d3,d4:d3
	cmp.l		d6,d4
	bgt.s		.sub
	blt.s		.add
.done:	rts
.add:	add.l		d5,d7
	lsr.l		d5
	bne.s		.loop
	bra.s		.done
.sub:	sub.l		d5,d7
	lsr.l		d5
	bne.s		.loop
	bra.s		.done

*-------------------------------------------------------*
*	Set up all leveldata search fields		*
*-------------------------------------------------------*
init_fields:
*-------------------------------------------------------*
	lea		level_fieldlist,a0
	lea		level_fields,a1
	moveq		#field_count-1,d2
.next:	move.l		field_ascii(a0),(a1)+
	lea		field_len(a0),a0
	dbra		d2,.next
	move.l		#-1,(a1)
	rts

*-------------------------------------------------------*
*	Hunt down and load each level resource		*
*-------------------------------------------------------*
check_fields:
*-------------------------------------------------------*
	lea		level_fields,a6
	lea		level_fieldlist-field_len,a5
.next:	lea		field_len(a5),a5
	move.l		(a6)+,d0
	bmi		.check_done
	beq.s		.next
	move.l		d0,a2
	move.l		a0,a3
.cmpl:	move.b		(a2)+,d2
	beq.s		.same
	fixcase		d2
	move.b		(a3)+,d3
	fixcase		d3
	cmp.b		d2,d3
	beq.s		.cmpl
.diff:	bra.s		.next
.same:	pushall
	move.l		a1,a4
	move.l		d0,d7
	Cconws		#ascii_reading
	Cconws		d7
	Cconws		#ascii_wipe
	move.l		wd_size(a4),d0
	addq.l		#3,d0
	and.b		#-4,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		.err_memory
	move.l		d0,field_ptr
*-------------------------------------------------------*
*	Read from IWAD or PWAD depending on flag	*
*-------------------------------------------------------*
	move.l		wd_offset(a4),d0
	bclr		#31,d0
	bne.s		.pwad
.iwad:	Fseek		d0,wad_handle,#0
	Fread		wad_handle,wd_size(a4),field_ptr
	bra.s		.rdon
.pwad:	Fseek		d0,pwad_handle,#0
	Fread		pwad_handle,wd_size(a4),field_ptr
*-------------------------------------------------------*
.rdon:	tst.l		d0
	bmi		.err_truncated		
	move.l		field_module(a5),a2
	move.l		wd_size(a4),d0
	jsr		(a2)
	move.l		field_ptr,d0
	bsr		deallocate_chunk
	popall
	subq.w		#1,fields_left
	clr.l		-4(a6)
.check_done:
	rts
.err_memory:
	popall
	bra		err_memory
.err_truncated:
	popall
	bra		err_truncated
	
*-------------------------------------------------------*
*	Place search-marker in WAD directory		*
*-------------------------------------------------------*
place_marker:
*-------------------------------------------------------*
	move.l		a0,wad_searchfield
	move.l		all_directory,a1
	move.l		all_entries,d1
.search_next:
	lea		wd_name(a1),a2
	move.l		a0,a3
	moveq		#8-1,d4
.search_look:
	move.b		(a3)+,d2
	beq.s		.search_stop
	fixcase		d2
	move.b		(a2)+,d3
	fixcase		d3
	cmp.b		d2,d3	
	bne.s		.search_diff
	dbra		d4,.search_look
	bra.s		.search_over
.search_diff:	
	lea		wd_len(a1),a1
	subq.l		#1,d1
	bne.s		.search_next
.search_fail:
	moveq		#0,d0
	bra.s		.search_exit
.search_stop:
	tst.b		(a2)+
	bne.s		.search_diff
.search_over:
	move.l		a1,wad_mdirectory
	move.l		d1,wad_mentries
	moveq		#1,d0
.search_exit:
	rts

*-------------------------------------------------------*
*	Find & load any resource from WAD		*
*-------------------------------------------------------*
load_resource:
*-------------------------------------------------------*
	move.l		a0,wad_searchfield
	move.l		all_directory,a1
	move.l		all_entries,d1
.search_next:
	lea		wd_name(a1),a2
	move.l		a0,a3
	moveq		#8-1,d4
.search_look:
	move.b		(a3)+,d2
	beq.s		.search_stop
	fixcase		d2
	move.b		(a2)+,d3
	fixcase		d3
	cmp.b		d2,d3	
	bne.s		.search_diff
	dbra		d4,.search_look
	bra.s		.search_over
.search_diff:	
	lea		wd_len(a1),a1
	subq.l		#1,d1
	bne.s		.search_next
.search_fail:
	moveq		#0,d0
	bra		.search_exit
.search_stop:
	tst.b		(a2)+
	bne.s		.search_diff
.search_over:
	move.l		a1,wad_mdirectory
	move.l		wd_size(a1),d6
	move.l		d6,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble.s		.search_fail
	move.l		d0,a6
	move.l		a1,a4
	pushall
*-------------------------------------------------------*
*	Read from IWAD or PWAD depending on flag	*
*-------------------------------------------------------*
	move.l		wd_offset(a4),d0
	bclr		#31,d0
	bne.s		.pwad
.iwad:	Fseek		d0,wad_handle,#0
	Fread		wad_handle,wd_size(a4),a6
	bra.s		.rdon
.pwad:	Fseek		d0,pwad_handle,#0
	Fread		pwad_handle,wd_size(a4),a6
*-------------------------------------------------------*
.rdon	popall
	moveq		#1,d0
.search_exit:
	rts

*-------------------------------------------------------*
*	Direct-access version of load_resource		*
*-------------------------------------------------------*
read_resource:
*-------------------------------------------------------*
	pushall
	move.l		a0,a4
	move.l		a1,a6
	move.l		wd_size(a4),d6
*-------------------------------------------------------*
*	Read from IWAD or PWAD depending on flag	*
*-------------------------------------------------------*
	move.l		wd_offset(a4),d0
	bclr		#31,d0
	bne.s		.pwad
.iwad:	Fseek		d0,wad_handle,#0
	Fread		wad_handle,wd_size(a4),a6
	bra.s		.rdon
.pwad:	Fseek		d0,pwad_handle,#0
	Fread		pwad_handle,wd_size(a4),a6
*-------------------------------------------------------*
.rdon:	popall
	rts

*-------------------------------------------------------*
*	Open IWAD file for work				*
*-------------------------------------------------------*
open_wad:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
	tst.w		wad_handle
	bne.s		.open
	Fopen		#iwad_path,#0
	tst.w		d0
	bmi.s		.open
	move.w		d0,wad_handle
.open:	movem.l		(sp)+,d1-a6
	rts

*-------------------------------------------------------*
*	Open PWAD file for work				*
*-------------------------------------------------------*
open_pwad:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
	tst.w		pwad_handle
	bne.s		.open
	Fopen		#pwad_path,#0
	tst.w		d0
	bmi.s		.open
	move.w		d0,pwad_handle
.open:	movem.l		(sp)+,d1-a6
	rts
	
*-------------------------------------------------------*
*	Close IWAD if already open			*
*-------------------------------------------------------*
close_wad:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
	tst.w		wad_handle
	beq.s		.ic
	Fclose		wad_handle
	clr.w		wad_handle
.ic	movem.l		(sp)+,d1-a6
	rts

*-------------------------------------------------------*
*	Close PWAD if already open			*
*-------------------------------------------------------*
close_pwad:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
	tst.w		pwad_handle
	beq.s		.pc
	Fclose		pwad_handle
	clr.w		pwad_handle
.pc:	movem.l		(sp)+,d1-a6
	rts

*-------------------------------------------------------*
*	Print decimal number to TOS console		*
*-------------------------------------------------------*
output_decimal:
*-------------------------------------------------------*
	lea		stringspace,a0
	moveq		#'0',d2
	moveq		#10,d3
.build:	moveq		#0,d5
	divu.l		d3,d5:d0
	add.w		d2,d5
	move.b		d5,-(a0)
	subq.l		#1,d1
	bgt.s		.build
	tst.l		d0
	bne.s		.build
	Cconws		a0
	rts

*-------------------------------------------------------*
*	Load & reformat 'things'			*
*-------------------------------------------------------*
things_module:
*-------------------------------------------------------*
	divu.l		#Thing_len,d0
	move.w		d0,NumThings
	move.w		d0,d7
	mulu.w		#Thing_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Thing_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_thing	
.thing_loop:
	imov.w		Thing_type(a0),d1
	cmp.w		#1,d1
	bne.s		.no_player
	bsr		.setup_player
.no_player:
	moveq		#(Thing_len/2)-1,d6
.ilp:	imov.w		(a0)+,(a1)+
	dbra		d6,.ilp
.next_thing:
	dbra		d7,.thing_loop
	rts

.setup_player:
	imov.w		Thing_x(a0),px
	imov.w		Thing_y(a0),py
	imov.w		Thing_angle(a0),d1
	swap		d1
	clr.w		d1
	divu.w		#360,d1
	move.w		d1,pangle
	rts

*-------------------------------------------------------*
*	Load & reformat 'linedefs'			*
*-------------------------------------------------------*
linedefs_module:
	divu.l		#Line_len,d0
	move.w		d0,NumLines
	move.w		d0,d7
	mulu.w		#Line_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Line_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_line
.line_loop:
	moveq		#(Line_len/2)-1,d6
.ilp:	imov.w		(a0)+,(a1)+
	dbra		d6,.ilp
.next_line:
	dbra		d7,.line_loop
	rts
	
*-------------------------------------------------------*
*	Load & reformat 'sidedefs'			*
*-------------------------------------------------------*
sidedefs_module:
*-------------------------------------------------------*
	divu.l		#Side_len,d0
	move.w		d0,NumSides
	move.w		d0,d7
	mulu.w		#Side_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Side_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_side
.side_loop:
	imov.w		(a0)+,(a1)+
	imov.w		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	imov.w		(a0)+,(a1)+
.next_side:
	dbra		d7,.side_loop
	rts

*-------------------------------------------------------*
*	Load & reformat 'vertexes'			*
*-------------------------------------------------------*
vertexes_module:
*-------------------------------------------------------*
	divu.l		#Vertex_len,d0
	move.w		d0,NumVertices
	move.w		d0,d7
	mulu.w		#Vertex_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Vertex_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_vertex
.vertex_loop:
	moveq		#(Vertex_len/2)-1,d6
.ilp:	imov.w		(a0)+,(a1)+
	dbra		d6,.ilp
.next_vertex:
	dbra		d7,.vertex_loop
	rts

*-------------------------------------------------------*
*	Load & reformat 'segs'				*
*-------------------------------------------------------*
segs_module:
*-------------------------------------------------------*
	divu.l		#Seg_len,d0
	move.w		d0,NumSegs
	move.w		d0,d7
	mulu.w		#seg_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Seg_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_seg
.seg_loop:
	moveq		#(Seg_len/2)-1,d6
.ilp:	imov.w		(a0)+,(a1)+
	dbra		d6,.ilp
	addq.l		#4,a1
.next_seg:
	dbra		d7,.seg_loop
	rts

*-------------------------------------------------------*
*	Load & reformat 'ssectors'			*
*-------------------------------------------------------*
ssectors_module:
*-------------------------------------------------------*
	divu.l		#Ssect_len,d0
	move.w		d0,NumSSectors
	move.w		d0,d7
	mulu.w		#Ssect_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,SSector_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_ssector
.ssector_loop:
	moveq		#(Ssect_len/2)-1,d6
.ilp:	imov.w		(a0)+,(a1)+
	dbra		d6,.ilp
.next_ssector:
	dbra		d7,.ssector_loop
	rts

*-------------------------------------------------------*
*	Load & reformat 'nodes'				*
*-------------------------------------------------------*
nodes_module:
*-------------------------------------------------------*
	divu.l		#Node_len,d0
	move.w		d0,NumNodes
	move.w		d0,d7
	mulu.w		#Node_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Node_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_node
.node_loop:
	moveq		#(Node_len/2)-1,d6
.ilp:	imov.w		(a0)+,(a1)+
	dbra		d6,.ilp
.next_node:
	dbra		d7,.node_loop
.err:	rts

*-------------------------------------------------------*
*	Load & reformat 'sectors'			*
*-------------------------------------------------------*
sectors_module:
*-------------------------------------------------------*
	divu.l		#Sector_len,d0
	move.w		d0,NumSectors
	move.w		d0,d7
	mulu.w		#Sector_len,d0
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	tst.l		d0
	ble		error_alloc
	move.l		d0,Sector_Array
	move.l		d0,a1
	move.l		field_ptr,a0
	bra.s		.next_sector
.sector_loop:
	imov.w		(a0)+,(a1)+
	imov.w		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	imov.w		(a0)+,(a1)+
	imov.w		(a0)+,(a1)+
	imov.w		(a0)+,(a1)+
.next_sector:
	dbra		d7,.sector_loop
	rts

*-------------------------------------------------------*
*	Load & reformat 'reject'			*
*-------------------------------------------------------*
reject_module:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
*	Load & reformat 'blockmap'			*
*-------------------------------------------------------*
blockmap_module:
*-------------------------------------------------------*
	rts

error_alloc:
	Cconws		#ascii_err_pnodes
	bra		err_closewad

*-------------------------------------------------------*
*	Modified strcmp for texture name-searching	*
*-------------------------------------------------------*
strcmp_8:
*-------------------------------------------------------*
	push.l		a0
	push.l		a1
	moveq		#8-1,d2
	moveq		#0,d0
.loop:	swap		d2
	move.b		(a0)+,d3
	beq.s		.term
	fixcase		d3
	move.b		(a1)+,d2
	fixcase		d2
	cmp.b		d2,d3
	bne.s		.diff
	swap		d2
	dbra		d2,.loop
	bra.s		.same
.term:	tst.b		(a1)+
	bne.s		.diff
.same:	moveq		#1,d0
.diff:	pop.l		a1
	pop.l		a0
	rts

*-------------------------------------------------------*
*	Modified strcmp for texture name-searching	*
*-------------------------------------------------------*
strcmp_8_wild:
*-------------------------------------------------------*
	push.l		a0
	push.l		a1
	moveq		#8-1,d2
	moveq		#0,d0
.loop:	swap		d2
	move.b		(a0)+,d3
	beq.s		.term
	cmp.b		#'?',d3
	beq.s		.same
	fixcase		d3
	move.b		(a1)+,d2
	cmp.b		#'?',d2
	beq.s		.same
	fixcase		d2
	cmp.b		d2,d3
	bne.s		.diff
	swap		d2
	dbra		d2,.loop
	bra.s		.same
.term:	tst.b		(a1)+
	bne.s		.diff
.same:	moveq		#1,d0
.diff:	pop.l		a1
	pop.l		a0
	rts

*-------------------------------------------------------*
*	Miscellaneous error trapping units		*
*-------------------------------------------------------*
*	Can be replaced with generalised error handler	*
*	at some later stage to reduce complexity.	*
*-------------------------------------------------------*

*-------------------------------------------------------*
err_fields:
*-------------------------------------------------------*
	Cconws		#ascii_newline
	lea		level_fields,a6
	move.w		#field_count-1,d6
.loop:	move.l		(a6)+,d7
	beq.s		.next
	move.l		d7,a0
	bsr		entry_missing_e
.next:	dbra		d6,.loop
	bra		err_closewad

*-------------------------------------------------------*
err_missing:
*-------------------------------------------------------*
	Cconws		#ascii_newline
	move.l		wad_searchfield,a0
	bsr		entry_missing_e
	bra		err_closewad

*-------------------------------------------------------*
err_truncated:
*-------------------------------------------------------*
	Cconws		#ascii_newline
	move.l		wad_searchfield,a0
	bsr		entry_truncated
	bra		err_closewad

*-------------------------------------------------------*
err_memory:
*-------------------------------------------------------*
	Cconws		#ascii_err_memory
	bra		err_closewad

*-------------------------------------------------------*
err_badwad:
*-------------------------------------------------------*
	Cconws		#ascii_err_badwad
	bra		err_closewad

*-------------------------------------------------------*
err_badpwad:
*-------------------------------------------------------*
	Cconws		#ascii_err_badpwad
	bra		err_closewad

*-------------------------------------------------------*
err_openwad:
*-------------------------------------------------------*
	Cconws		#ascii_err_openwad
	bra		err_closewad

*-------------------------------------------------------*
err_closewad:
*-------------------------------------------------------*
	bsr		close_wad
	bsr		close_pwad
	Crawcin
	jmp		safe_quit

*-------------------------------------------------------*
entry_missing_w:
*-------------------------------------------------------*
	pushall
	lea		string_space,a1
	move.l		a1,a6
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.b		(a1)
	Cconws		#ascii_err_missing1w
	Cconws		a6
	Cconws		#ascii_err_missing2w
	popall
	rts

*-------------------------------------------------------*
entry_missing_e:
*-------------------------------------------------------*
	pushall
	lea		string_space,a1
	move.l		a1,a6
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.b		(a1)
	Cconws		#ascii_err_missing1e
	Cconws		a6
	Cconws		#ascii_err_missing2e
	popall
	rts

*-------------------------------------------------------*
entry_truncated:
*-------------------------------------------------------*
	pushall
	lea		string_space,a1
	move.l		a1,a6
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	clr.b		(a1)
	Cconws		#ascii_err_trunc1
	Cconws		a6
	Cconws		#ascii_err_trunc2
	popall
	rts

check_limits:
	move.w		num_required,d1
	cmp.w		num_reserved,d1
	bgt.s		.err
	rts
.err:	Cconws		#ascii_limits1
	moveq		#0,d0
	move.w		num_reserved,d0
	moveq		#1,d1
	bsr		output_decimal
	Cconws		#ascii_limits2
	moveq		#0,d0
	move.w		num_required,d0
	moveq		#1,d1
	bsr		output_decimal
	bra		err_closewad

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

level_fieldlist:	dc.l	ascii_things,things_module	; list of leveldata resources
			dc.l	ascii_nodes,nodes_module
			dc.l	ascii_sectors,sectors_module
			dc.l	ascii_ssectors,ssectors_module
			dc.l	ascii_segs,segs_module
			dc.l	ascii_linedefs,linedefs_module
			dc.l	ascii_sidedefs,sidedefs_module
			dc.l	ascii_vertexes,vertexes_module
			dc.l	ascii_reject,reject_module
			dc.l	ascii_blockmap,blockmap_module
			dc.l	terminator

wad_signature:		ds.l	1				; IWAD signature
			dc.b	0
pwad_signature:		ds.l	1				; PWAD signature
			dc.b	0

*-------------------------------------------------------*
*	General ASCII messages follow...		*
*-------------------------------------------------------*

ascii_mask_exmx:	dc.b	'e?m?',0
ascii_mask_mapxx:	dc.b	'map??',0

ascii_texture1:		dc.b	'texture1',0		; WAD search details
ascii_texture2:		dc.b	'texture2',0
ascii_pnames:		dc.b	'pnames',0
ascii_sky:		dc.b	'f_sky1',0
ascii_fstart:		dc.b	'f_start',0
ascii_fend:		dc.b	'f_end',0
ascii_pstart:		dc.b	'p_start',0
ascii_pend:		dc.b	'p_end',0
ascii_qalpha:		dc.b	'sky1',0

ascii_sky1:		dc.b	'sky1',0
ascii_sky2:		dc.b	'sky2',0
ascii_sky3:		dc.b	'sky3',0
ascii_sky4:		dc.b	'sky4',0

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
ascii_patchalpha:	dc.b	13,10
			dc.b	' Patching quick-alpha textures...',0
ascii_locatepatch:	dc.b	13,10
			dc.b	' Organising patches...',0
ascii_replacedone:	dc.b	13,10
			dc.b	13,10
			dc.b	' Finished processing textures.',0
ascii_integrate:	dc.b	13,10
			dc.b	' Integrating PWAD...'
			dc.b	13,10,13,10,0

ascii_warp_switch:	dc.b	'w',0
ascii_iwad_switch:	dc.b	'i',0
ascii_pwad_switch:	dc.b	'p',0
	
ascii_signal:		dc.b	13,10,'signal',0
ascii_newline:		dc.b	13,10,0
ascii_startup:		dc.b	27,'E',27,'f',13,10
			dc.b	' Doom Environment Simulator v2.16alpha.',13,10,13,10
			dc.b	' DSP Doom engine by Doug Little.',13,10,0

ascii_format1:		dc.b	13,10
			dc.b	' IWAD check:	',0
ascii_format2:		dc.b	13,10
			dc.b	' PWAD check:	',0

ascii_levelmark:	dc.b	' Warp to:	',0
ascii_reading:		dc.b	13
			dc.b	' Reading:	',0
ascii_wipe:		dc.b	'        ',0

ascii_entries:		dc.b	13,10
			dc.b	' Directories:	',0

ascii_limits1:		dc.b	13,10
			dc.b	13,10
			dc.b	' Too many elements!',13,10
			dc.b	' Reserved: ',0
ascii_limits2:		dc.b	13,10,' Required: ',0

ascii_entriesdone:	dc.b	13,10,0

ascii_parsingdone:	dc.b	13,10
			dc.b	13,10
			dc.b	' Finished processing leveldata.',13,10,0 

ascii_err_missing1e:	dc.b	13,10
			dc.b	' Missing:	',0
ascii_err_missing2e:	dc.b	' -> [error]',0

ascii_err_missing1w:	dc.b	13,10
			dc.b	' Missing:	',0
ascii_err_missing2w:	dc.b	' -> [warning]',0

ascii_err_trunc1:	dc.b	13,10
			dc.b	' Truncated:	',0
ascii_err_trunc2:	dc.b	' -> [error]',0

ascii_err_notex:	dc.b	13,10
			dc.b	' WAD contains no [textures] -> [warning]',0
ascii_err_noflats:	dc.b	13,10
			dc.b	' WAD contains no [flats] -> [warning]',0
ascii_err_nopatches:	dc.b	13,10
			dc.b	' WAD contains no [patches] -> [warning]',0
ascii_err_pnodes:	dc.b	13,10
			dc.b	' Could not allocate space for [nodes] -> [error]',0
ascii_err_memory:	dc.b	13,10
			dc.b	' Could not allocate space for [arrays] -> [error]',0
ascii_err_openwad:	dc.b	13,10
			dc.b	' Could not find & open WAD file -> [error]',0
ascii_err_badwad:	dc.b	13,10
			dc.b	' The specified IWAD is not compatible -> [error]',0
ascii_err_badpwad:	dc.b	13,10
			dc.b	' The specified PWAD is not compatible -> [error]',0

*-------------------------------------------------------*
*	Leveldata search details			*
*-------------------------------------------------------*

ascii_things:		dc.b	'things',0
ascii_linedefs:		dc.b	'linedefs',0
ascii_sidedefs:		dc.b	'sidedefs',0
ascii_vertexes:		dc.b	'vertexes',0
ascii_segs:		dc.b	'segs',0
ascii_ssectors:		dc.b	'ssectors',0
ascii_nodes:		dc.b	'nodes',0
ascii_sectors:		dc.b	'sectors',0
ascii_reject:		dc.b	'reject',0
ascii_blockmap:		dc.b	'blockmap',0

ascii_colormap:		dc.b	'colormap',0
ascii_playpal:		dc.b	'playpal',0

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

wad_diroffset:		ds.l	1
pwad_diroffset:		ds.l	1

wad_directory:		ds.l	1
wad_entries:		ds.l	1

pwad_directory:		ds.l	1
pwad_entries:		ds.l	1

all_directory:		ds.l	1
all_entries:		ds.l	1

*-------------------------------------------------------*

wad_mentries:		ds.l	1		; wad search & retrieve variables
wad_mdirectory:		ds.l	1
wad_searchfield:	ds.l	1


field_ptr:		ds.l	1

Seg_Array		ds.l	1		; leveldata array pointers
Side_Array		ds.l	1
Line_Array		ds.l	1
Node_Array		ds.l	1
PNode_Array		ds.l	1
Sector_Array		ds.l	1
Vertex_Array		ds.l	1
SSector_Array		ds.l	1
Thing_Array		ds.l	1

colormap_ptr:		ds.l	1		; palette & colourmap pointers
playpal_ptr:		ds.l	1

level_fields:		ds.l	field_count+1	; space for level search information

switch_space:		ds.b	8+1
cli_space:		ds.b	255+1

wad_header:		ds.b	wh_len		; space for IWAD header
wad_handle:		ds.w	1		; IWAD handle

pwad_header:		ds.b	wh_len		; space for PWAD header
pwad_handle:		ds.w	1		; PWAD handle

fields_left:		ds.w	1		; leveldata field count

num_reserved:		ds.w	1
num_required:		ds.w	1

NumThings:		ds.w	1		; various array sizes
NumSegs:		ds.w	1
NumLines:		ds.w	1
NumSides:		ds.w	1
NumVertices:		ds.w	1
NumSSectors:		ds.w	1
NumNodes:		ds.w	1
NumSectors:		ds.w	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*

	