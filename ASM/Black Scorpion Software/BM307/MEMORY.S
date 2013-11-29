*=======================================================*
*	Memory module: updated 12/06/97			*
*=======================================================*

none			=	-1

os_st_reserve		=	16*1024
os_tt_reserve		=	16*1024
shard_size		=	4096

malloc_limit		=	16
chunk_limit		=	8192

			rsreset
malloc_base		rs.l	1
malloc_size		rs.l	1
malloc_slen		rs.b	0

			rsreset
chunk_base		rs.l	1
chunk_size		rs.l	1
chunk_slot		rs.l	1
chunk_lf		rs.b	1
chunk_rf		rs.b	1
chunk_flags		rs.w	1
chunk_ln		rs.l	1
chunk_rn		rs.l	1
chunk_slen		rs.b	0

			rsreset
used_chunks		rs.w	1
free_chunks		rs.w	1
total_chunks		rs.w	1
system_chunks		rs.w	1
used_array		rs.l	1
free_array		rs.l	1
chunk_array		rs.l	1
system_array		rs.l	1
dummy_lslot		rs.l	1
dummy_rslot		rs.l	1
dummy_lchunk		rs.b	chunk_slen
dummy_rchunk		rs.b	chunk_slen
pool_slen		rs.b	0

cf_used_bit		=	0
cf_break_bit		=	5
cf_used			=	1<<cf_used_bit
cf_break		=	1<<cf_break_bit

block_hashbits		=	12

*-------------------------------------------------------*
init_block_manager:
*-------------------------------------------------------*
	Mxalloc		#os_st_reserve,#STRAM_only
	move.l		d0,os_st_reserve_ptr
	Mxalloc		#os_tt_reserve,#VRAM_only
	move.l		d0,os_tt_reserve_ptr
*-------------------------------------------------------*
*	Initialise STRAM memory pool			*
*-------------------------------------------------------*
	lea		st_memory_pool,a6
	move.l		#st_used_array_space,used_array(a6)
	move.l		#st_free_array_space,free_array(a6)
	move.l		#st_chunk_array_space,chunk_array(a6)
	move.l		#st_system_array_space,system_array(a6)
	clr.w		used_chunks(a6)
	clr.w		free_chunks(a6)
	clr.w		total_chunks(a6)
	clr.w		system_chunks(a6)
	move.w		#STRAM_only,ram_type
	bsr		claim_memory
	bsr		join_mallocs
	bsr		init_chunks
*-------------------------------------------------------*
*	Initialise TTRAM memory pool			*
*-------------------------------------------------------*
	lea		tt_memory_pool,a6
	move.l		#tt_used_array_space,used_array(a6)
	move.l		#tt_free_array_space,free_array(a6)
	move.l		#tt_chunk_array_space,chunk_array(a6)
	move.l		#tt_system_array_space,system_array(a6)
	clr.w		used_chunks(a6)
	clr.w		free_chunks(a6)
	clr.w		total_chunks(a6)
	clr.w		system_chunks(a6)
	move.w		#VRAM_only,ram_type
	bsr		claim_memory
	bsr		join_mallocs
	bsr		init_chunks
*-------------------------------------------------------*
	Mfree		os_st_reserve_ptr
	move.l		os_tt_reserve_ptr,d0
	ble.s		.done
	Mfree		d0
*-------------------------------------------------------*
.done:	rts

*-------------------------------------------------------*
find_largest_block:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
*-------------------------------------------------------*
	moveq		#0,d0
	and.w		#4-1,d1
	jmp		([.type.w,pc,d1.w*4])
*-------------------------------------------------------*
.type:	dc.l		.stram_only
	dc.l		.ttram_only
	dc.l		.stram_preferred
	dc.l		.ttram_preferred
*-------------------------------------------------------*
.ttram_preferred:
.stram_preferred:
*-------------------------------------------------------*
	lea		tt_memory_pool,a6
	bsr		internal_find_largest
*-------------------------------------------------------*
.stram_only:
*-------------------------------------------------------*
	lea		st_memory_pool,a6
	bsr		internal_find_largest
	bra.s		.allocate_done
*-------------------------------------------------------*
.ttram_only:
*-------------------------------------------------------*
	lea		tt_memory_pool,a6
	bsr		internal_find_largest
*-------------------------------------------------------*
.allocate_done:
*-------------------------------------------------------*
	movem.l		(sp)+,d1-a6
	rts

*-------------------------------------------------------*
internal_find_largest:
*-------------------------------------------------------*
	move.l		free_array(a6),a1
	move.w		free_chunks(a6),d6
	lea		(a1,d6.w*4),a1
	bra.s		.loop_start
*-------------------------------------------------------*
.size_loop:
*-------------------------------------------------------*
	move.l		-(a1),a4
	cmp.l		chunk_size(a4),d0
	bpl.s		.loop_start
*-------------------------------------------------------*
*	Block is larger - record size			*
*-------------------------------------------------------*
	move.l		chunk_size(a4),d0
*-------------------------------------------------------*
.loop_start:
*-------------------------------------------------------*
	dbra		d6,.size_loop
	rts

*-------------------------------------------------------*
allocate_chunk:
*-------------------------------------------------------*
;	cmp.l		#-1,d0
;	beq		find_largest_block
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
	move.l		d0,-(sp)
*-------------------------------------------------------*
	and.w		#4-1,d1
	jmp		([.type.w,pc,d1.w*4])
*-------------------------------------------------------*
.type:	dc.l		.stram_only
	dc.l		.ttram_only
	dc.l		.stram_preferred
	dc.l		.ttram_preferred
*-------------------------------------------------------*
.stram_only:
*-------------------------------------------------------*
	lea		st_memory_pool,a6
	bsr		internal_allocate
	bra.s		.allocate_done
*-------------------------------------------------------*
.ttram_only:
*-------------------------------------------------------*
	lea		tt_memory_pool,a6
	bsr		internal_allocate
	bra.s		.allocate_done
*-------------------------------------------------------*
.stram_preferred:
*-------------------------------------------------------*
	lea		st_memory_pool,a6
	bsr		internal_allocate
	tst.l		d0
	bne.s		.allocate_done
	move.l		(sp),d0
	lea		tt_memory_pool,a6
	bsr		internal_allocate
	bra.s		.allocate_done
*-------------------------------------------------------*
.ttram_preferred:
*-------------------------------------------------------*
	lea		tt_memory_pool,a6
	bsr		internal_allocate
	tst.l		d0
	bne.s		.allocate_done
	move.l		(sp),d0
	lea		st_memory_pool,a6
	bsr		internal_allocate
*-------------------------------------------------------*
.allocate_done:
*-------------------------------------------------------*
	addq.l		#4,sp
	movem.l		(sp)+,d1-a6
	rts

*-------------------------------------------------------*
internal_allocate:
*-------------------------------------------------------*
*	Check limit					*
*-------------------------------------------------------*
	cmp.w		#chunk_limit,used_chunks(a6)
	beq		.alloc_fail
*-------------------------------------------------------*
*	Round up block length to 4 bytes		*
*-------------------------------------------------------*

	addq.l		#8,d0
	addq.l		#8-1,d0
	and.w		#-16,d0

;	addq.l		#4-1,d0
;	and.b		#-4,d0

*-------------------------------------------------------*
*	Find suitable block to claim / split		*
*-------------------------------------------------------*
	move.l		free_array(a6),a1
	move.w		free_chunks(a6),d6
	lea		(a1,d6.w*4),a1
	bra.s		.loop_start
*-------------------------------------------------------*
.size_loop:
*-------------------------------------------------------*
	move.l		-(a1),a4
	cmp.l		chunk_size(a4),d0
	ble.s		.alloc_chunk
*-------------------------------------------------------*
.loop_start:
*-------------------------------------------------------*
	dbra		d6,.size_loop
*-------------------------------------------------------*
.alloc_fail:
*-------------------------------------------------------*
	moveq		#0,d0
	bra		.exit
*-------------------------------------------------------*
.alloc_chunk:
*-------------------------------------------------------*
	bmi.s		.split_chunk
*-------------------------------------------------------*
.keep_chunk:
*-------------------------------------------------------*
*	Allocate entire chunk as used			*
*-------------------------------------------------------*
	move.l		chunk_size(a4),d0
*-------------------------------------------------------*
	move.w		free_chunks(a6),d5
	subq.w		#1,d5
	move.w		d5,free_chunks(a6)
*-------------------------------------------------------*
*	Seal gap in list using last entry		*
*-------------------------------------------------------*
	move.l		free_array(a6),a3
	move.l		(a3,d5.w*4),a2
	clr.l		(a3,d5.w*4)
	bra		.skip_split
*-------------------------------------------------------*
.split_chunk:
*-------------------------------------------------------*
*	Eliminate unwanted shards			*
*-------------------------------------------------------*
	move.l		chunk_size(a4),d5
	sub.l		d0,d5
	cmp.l		#shard_size,d5
	bmi.s		.keep_chunk
*-------------------------------------------------------*
	cmp.w		#chunk_limit,total_chunks(a6)
	beq		.alloc_fail
*-------------------------------------------------------*
*	Shrink original chunk to required size		*
*-------------------------------------------------------*
;	move.l		d0,grabbed
	move.l		chunk_size(a4),d1
	move.l		d0,chunk_size(a4)
	sub.l		d0,d1
*-------------------------------------------------------*
*	Calculate new chunk's base address		*
*-------------------------------------------------------*
	add.l		chunk_base(a4),d0
*-------------------------------------------------------*
*	Create new chunk				*
*-------------------------------------------------------*
	move.w		total_chunks(a6),d2
	addq.w		#1,total_chunks(a6)
	move.l		chunk_array(a6),a2	
	mulu.w		#chunk_slen,d2
	add.l		d2,a2
	move.l		d0,chunk_base(a2)
	move.l		d1,chunk_size(a2)
*-------------------------------------------------------*
*	Break links & insert new (free) chunk		*
*-------------------------------------------------------*
	move.l		chunk_rn(a4),a5
	move.l		a4,chunk_ln(a2)
	move.l		a5,chunk_rn(a2)
	move.l		a2,chunk_rn(a4)	
	move.l		a2,chunk_ln(a5)	
*-------------------------------------------------------*
*	Maintain chunk flags				*
*-------------------------------------------------------*
	move.b		chunk_rf(a4),chunk_rf(a2)
	moveq		#0,d0
	move.b		d0,chunk_lf(a2)
	move.b		d0,chunk_rf(a4)
*-------------------------------------------------------*
.skip_split:
*-------------------------------------------------------*
*	Replace gap in free array & relocate		*
*-------------------------------------------------------*
	move.l		a2,(a1)
	move.l		a1,chunk_slot(a2)
*-------------------------------------------------------*
*	Generate hash index for chunk address		*
*-------------------------------------------------------*
	move.l		chunk_base(a4),d0
	move.l		used_array(a6),a2
	bsr		hash_address	
*-------------------------------------------------------*
*	Double-link chunk with hashed slot		* 
*-------------------------------------------------------*
	lea		(a2,d2.w*4),a3
	move.l		a4,(a3)
	move.l		a3,chunk_slot(a4)
	addq.w		#1,used_chunks(a6)
*-------------------------------------------------------*
*	Flag chunk as 'used' to neighbours		*
*-------------------------------------------------------*
	move.l		chunk_ln(a4),a3
	move.l		chunk_rn(a4),a5
	moveq		#cf_used,d2
	or.b		d2,chunk_rf(a3)
	or.b		d2,chunk_lf(a5)
*-------------------------------------------------------*
.exit:	rts

*-------------------------------------------------------*
hash_address:
*-------------------------------------------------------*
*	Hash chunk address				*
*-------------------------------------------------------*
	move.l		d0,d2
	moveq		#block_hashbits,d3
	lsr.l		d3,d2
*-------------------------------------------------------*
*	Search for free hash slot			*
*-------------------------------------------------------*
.search_slot:
*-------------------------------------------------------*
	and.w		#chunk_limit-1,d2
	tst.l		(a2,d2.w*4)
	beq.s		.free_slot
	addq.w		#1,d2
	bra.s		.search_slot
*-------------------------------------------------------*
.free_slot:
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
deallocate_chunk:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
*-------------------------------------------------------*
	push.l		d0
	lea		tt_memory_pool,a6
	bsr		internal_deallocate
	pop.l		d1
	tst.l		d0
	beq.s		.deallocate_done
	move.l		d1,d0
	lea		st_memory_pool,a6
	bsr		internal_deallocate
*-------------------------------------------------------*
.deallocate_done
*-------------------------------------------------------*
	movem.l		(sp)+,d1-a6
*-------------------------------------------------------*
	rts
	
*-------------------------------------------------------*
internal_deallocate:
*-------------------------------------------------------*
*	Hash chunk address				*
*-------------------------------------------------------*
	move.l		d0,d2
	moveq		#block_hashbits,d3
	lsr.l		d3,d2
	move.l		used_array(a6),a2
*-------------------------------------------------------*
*	Search hash table until none left		*
*-------------------------------------------------------*
search_slot:
*-------------------------------------------------------*
	and.w		#chunk_limit-1,d2
	move.l		(a2,d2.w*4),d3
	beq.s		fail_dealloc
*-------------------------------------------------------*
check_handle:
*-------------------------------------------------------*
	move.l		d3,a3
	cmp.l		chunk_base(a3),d0
	beq.s		found_slot
*-------------------------------------------------------*
advance_check:
*-------------------------------------------------------*
	addq.w		#1,d2
	bra.s		search_slot
*-------------------------------------------------------*
fail_dealloc:
*-------------------------------------------------------*
	moveq		#-1,d0
	bra		exit
*-------------------------------------------------------*
found_slot:
*-------------------------------------------------------*
*	Destroy hash entry				*
*-------------------------------------------------------*
	clr.l		(a2,d2.w*4)
	bra		repair_start
*-------------------------------------------------------*
*	Repair hashtable / re-hash siblings		*
*-------------------------------------------------------*
repair_next:
*-------------------------------------------------------*
	and.w		#chunk_limit-1,d2
	move.l		(a2,d2.w*4),d3
	beq.s		repair_done
*-------------------------------------------------------*
repair_found:
*-------------------------------------------------------*
	move.l		d3,a5
*-------------------------------------------------------*
*	Destroy entry					*
*-------------------------------------------------------*
	clr.l		(a2,d2.w*4)
*-------------------------------------------------------*
*	Re-hash entry					*
*-------------------------------------------------------*
	push.l		d2
	move.l		chunk_base(a5),d0
	bsr		hash_address
	lea		(a2,d2.w*4),a4
	move.l		a5,(a4)
	move.l		a4,chunk_slot(a5)
	pop.l		d2
*-------------------------------------------------------*
repair_start:
*-------------------------------------------------------*
	addq.w		#1,d2
	bra.s		repair_next
*-------------------------------------------------------*
repair_done:
*-------------------------------------------------------*
	move.l		chunk_size(a3),d3
*-------------------------------------------------------*
*	Deallocate chunk from 'used' array		*
*-------------------------------------------------------*
	subq.w		#1,used_chunks(a6)
	move.l		chunk_slot(a3),a2
	clr.l		(a2)
*-------------------------------------------------------*
*	Determine defrag rules for neighbours		*
*-------------------------------------------------------*
	move.l		chunk_ln(a3),a2
	move.l		chunk_rn(a3),a4
	tst.b		chunk_lf(a3)
	beq		join_part
	tst.b		chunk_rf(a3)
	beq		join_right
*-------------------------------------------------------*
no_join:
*-------------------------------------------------------*
*	No join possible - flag as free to neighbours	*
*-------------------------------------------------------*
	bclr		#cf_used_bit,chunk_rf(a2)	
	bclr		#cf_used_bit,chunk_lf(a4)	
*-------------------------------------------------------*
*	Append chunk to 'free' array			*
*-------------------------------------------------------*
	move.w		free_chunks(a6),d0
	move.l		free_array(a6),a0
	lea		(a0,d0.w*4),a5
	move.l		a3,(a5)
	move.l		a5,chunk_slot(a3)
	addq.w		#1,d0
	move.w		d0,free_chunks(a6)
	bra		join_done
*-------------------------------------------------------*
join_right:
*-------------------------------------------------------*
*	Expand right neighbour to fill space		*
*-------------------------------------------------------*
	move.l		chunk_size(a3),d0
	add.l		d0,chunk_size(a4)
	move.l		chunk_base(a3),chunk_base(a4)
*-------------------------------------------------------*
*	Unlink chunk from chain				*
*-------------------------------------------------------*
	bsr		unlink_chunk
	bra.s		join_done
*-------------------------------------------------------*
join_left:
*-------------------------------------------------------*
*	Expand left neighbour to fill space		*
*-------------------------------------------------------*
	move.l		chunk_size(a3),d0
	add.l		d0,chunk_size(a2)
*-------------------------------------------------------*
*	Unlink chunk from chain				*
*-------------------------------------------------------*
	bsr		unlink_chunk
	bra.s		join_done
*-------------------------------------------------------*
join_part:
*-------------------------------------------------------*
	tst.b		chunk_rf(a3)
	bne.s		join_left
*-------------------------------------------------------*
join_both:
*-------------------------------------------------------*
*	Expand left neighbour to fill space		*
*-------------------------------------------------------*
	move.l		chunk_size(a3),d0
	add.l		chunk_size(a4),d0
	add.l		d0,chunk_size(a2)
*-------------------------------------------------------*
*	Unlink this chunk from chain			*
*-------------------------------------------------------*
	move.l		chunk_slot(a4),a0		
	bsr		unlink_chunk
	move.l		(a0),a3
*-------------------------------------------------------*
*	Deallocate right neighbour from 'free' array	*
*-------------------------------------------------------*
	move.w		free_chunks(a6),d0
	subq.w		#1,d0
	move.w		d0,free_chunks(a6)
	move.l		free_array(a6),a4
	move.l		(a4,d0.w*4),a2
	clr.l		(a4,d0.w*4)
*-------------------------------------------------------*
*	Seal hole & relocate				*
*-------------------------------------------------------*
	move.l		a2,(a0)
	move.l		a0,chunk_slot(a2)
*-------------------------------------------------------*
*	Unlink right neighbour from chain		*
*-------------------------------------------------------*
	move.l		chunk_ln(a3),a2
	move.l		chunk_rn(a3),a4
	bsr		unlink_chunk
*-------------------------------------------------------*
join_done:
*-------------------------------------------------------*
*	Deallocation was successful			*
*-------------------------------------------------------*
	moveq		#0,d0
*-------------------------------------------------------*
exit:	rts

*-------------------------------------------------------*
unlink_chunk:
*-------------------------------------------------------*
*	Maintain neighbour flags			*
*-------------------------------------------------------*
	move.b		chunk_lf(a3),d1
	move.b		chunk_rf(a3),d2
	move.b		d1,d0
	or.b		d2,d0
	and.b		#cf_break,d0
	or.b		d0,d1	
	move.b		d1,chunk_lf(a4)
	or.b		d0,d2	
	move.b		d2,chunk_rf(a2)
*-------------------------------------------------------*
*	Unlink this chunk from chain			*
*-------------------------------------------------------*
	move.l		a4,chunk_rn(a2)
	move.l		a2,chunk_ln(a4)
*-------------------------------------------------------*
*	Remove chunk from chunk array & seal gap	*
*-------------------------------------------------------*
	move.w		total_chunks(a6),d1
	move.l		chunk_array(a6),a2
	subq.w		#1,d1
	move.w		d1,total_chunks(a6)
	mulu.w		#chunk_slen,d1
	add.l		d1,a2
	move.l		a3,a5
	moveq		#0,d7
	moveq		#(chunk_slen/4)-1,d1
.seal:	move.l		(a2),(a5)+
	move.l		d7,(a2)+
	dbra		d1,.seal
	cmp.l		a2,a5
	beq.s		.done
*-------------------------------------------------------*
*	Relocate seal					*
*-------------------------------------------------------*
	move.l		chunk_ln(a3),a2
	move.l		chunk_rn(a3),a4
	move.l		a3,chunk_rn(a2)
	move.l		a3,chunk_ln(a4)
	move.l		chunk_slot(a3),a2
	move.l		a3,(a2)
.done:	rts

*-------------------------------------------------------*
claim_memory:
*-------------------------------------------------------*
	move.l		system_array(a6),a5	
	moveq		#malloc_limit-1,d7
	moveq		#0,d5
*-------------------------------------------------------*
*	Claim loop					*
*-------------------------------------------------------*
.claim_memory:
*-------------------------------------------------------*
*	Find largest free block				*
*-------------------------------------------------------*
	Mxalloc		#-1,ram_type
	tst.l		d0
	ble.s		.memory_exhausted
	move.l		d0,d6
*-------------------------------------------------------*
*	Attempt to claim that block			*
*-------------------------------------------------------*
	Mxalloc		d0,ram_type
	tst.l		d0
	ble.s		.err
*-------------------------------------------------------*
*	Store block if claim was successful		*
*-------------------------------------------------------*
	move.l		d0,(a5)+
	move.l		d6,(a5)+
	addq.l		#1,d5
*-------------------------------------------------------*
.err:	dbra		d7,.claim_memory
*-------------------------------------------------------*
.memory_exhausted:
*-------------------------------------------------------*
	move.w		d5,system_chunks(a6)
	rts	

*-------------------------------------------------------*
init_chunks:
*-------------------------------------------------------*
	moveq		#malloc_base,d0
	bsr		sort_mallocs
*-------------------------------------------------------*
*	Create synthetic chunk for terminating lists	*
*-------------------------------------------------------*
	lea		dummy_lchunk(a6),a1
	lea		dummy_lslot(a6),a2
	lea		dummy_rchunk(a6),a3
	lea		dummy_rslot(a6),a4
*-------------------------------------------------------*
*	Double-link chunk with slot			*
*-------------------------------------------------------*
	move.l		a1,(a2)
	move.l		a2,chunk_slot(a1)
	move.l		a3,(a4)
	move.l		a4,chunk_slot(a3)
*-------------------------------------------------------*
	clr.l		chunk_base(a1)
	clr.l		chunk_size(a1)
	move.b		#cf_break,chunk_lf(a1)
	move.b		#cf_break,chunk_rf(a1)
	clr.w		chunk_flags(a1)
	move.l		#none,chunk_ln(a1)
	move.l		a3,chunk_rn(a1)
*-------------------------------------------------------*
	clr.l		chunk_base(a3)
	clr.l		chunk_size(a3)
	move.b		#cf_break,chunk_lf(a3)
	move.b		#cf_break,chunk_rf(a3)
	clr.w		chunk_flags(a3)
	move.l		a1,chunk_ln(a3)
	move.l		#none,chunk_rn(a3)
*-------------------------------------------------------*
	move.l		free_array(a6),a4
	move.l		chunk_array(a6),a0
	move.l		system_array(a6),a5
	move.l		a0,a1
*-------------------------------------------------------*
	moveq		#0,d6
	move.w		system_chunks(a6),d7
	bra.s		.loops
*-------------------------------------------------------*
.loop:	move.l		malloc_base(a5),d0
	move.l		malloc_size(a5),d1
	add.l		d0,d1

	add.l		#16-1,d0
	add.l		#16-1,d1
	and.w		#-16,d0
	and.w		#-16,d1

;	addq.l		#4-1,d0
;	addq.l		#4-1,d1
;	and.b		#-4,d0
;	and.b		#-4,d1

	sub.l		d0,d1
	cmp.l		#65536,d1
	bmi.s		.cull
*-------------------------------------------------------*
*	Increment free ram counter			*
*-------------------------------------------------------*
;	add.l		d1,freeram
*-------------------------------------------------------*
*	Create chunk & link to neighbours		*
*-------------------------------------------------------*
	move.l		d0,chunk_base(a0)
	move.l		d1,chunk_size(a0)
	move.b		#cf_break,chunk_lf(a0)
	move.b		#cf_break,chunk_rf(a0)
	move.w		d6,d0
	subq.w		#1,d0
	mulu.w		#chunk_slen,d0
	add.l		a1,d0
	move.l		d0,chunk_ln(a0)
	move.w		d6,d0
	addq.w		#1,d0
	mulu.w		#chunk_slen,d0
	add.l		a1,d0
	move.l		d0,chunk_rn(a0)
*-------------------------------------------------------*
*	Store back-link & increment free count		*
*-------------------------------------------------------*
	move.l		a4,chunk_slot(a0)
	move.l		a0,(a4)+
*-------------------------------------------------------*
*	Advance to next chunk				*
*-------------------------------------------------------*
	lea		chunk_slen(a0),a0
	addq.w		#1,d6
*-------------------------------------------------------*
.cull:	lea		malloc_slen(a5),a5
*-------------------------------------------------------*
.loops:	dbra		d7,.loop
*-------------------------------------------------------*
	move.w		d6,free_chunks(a6)
	move.w		d6,total_chunks(a6)
	beq.s		.err
*-------------------------------------------------------*
*	Link in synthetic [terminator] chunks		*
*-------------------------------------------------------*
	move.l		chunk_array(a6),a0
	move.l		a0,a1
	move.w		free_chunks(a6),d0
	subq.w		#1,d0
	mulu.w		#chunk_slen,d0
	add.l		d0,a1
	lea		dummy_lchunk(a6),a2
	lea		dummy_rchunk(a6),a3
	move.l		a2,chunk_ln(a0)
	move.l		a0,chunk_rn(a2)
	move.l		a3,chunk_rn(a1)
	move.l		a1,chunk_ln(a3)
.err:	rts

*-------------------------------------------------------*
sort_mallocs:
*-------------------------------------------------------*
	move.l		system_array(a6),a3
	move.w		system_chunks(a6),d6
*-------------------------------------------------------*
*	Abort sort if entries < 2			*
*-------------------------------------------------------*
	subq.w		#1,d6
	ble.s		.err
*-------------------------------------------------------*
	bra.s		.ogo
*-------------------------------------------------------*
.outer_loop:
*-------------------------------------------------------*
	move.l		a3,a5
	moveq		#0,d4
*-------------------------------------------------------*
*	Inner iterations = entries-1			*
*-------------------------------------------------------*
	move.w		d6,d5
	addq.w		#1,d5
	bra.s		.igo
*-------------------------------------------------------*
.inner_loop:
*-------------------------------------------------------*
	lea		malloc_slen(a5),a4
	move.l		(a5,d0.w),d1
	cmp.l		(a4,d0.w),d1
	ble.s		.no
	moveq		#1,d4
	move.l		malloc_base(a4),d1
	move.l		malloc_base(a5),d2
	move.l		d2,malloc_base(a4)
	move.l		d1,malloc_base(a5)
	move.l		malloc_size(a4),d1
	move.l		malloc_size(a5),d2
	move.l		d2,malloc_size(a4)
	move.l		d1,malloc_size(a5)
.no:	move.l		a4,a5
*-------------------------------------------------------*
.igo:	dbra		d5,.inner_loop
*-------------------------------------------------------*
	tst.l		d4
	beq.s		.err
*-------------------------------------------------------*
.ogo:	dbra		d6,.outer_loop
*-------------------------------------------------------*
.err:	rts

*-------------------------------------------------------*
join_mallocs:
*-------------------------------------------------------*	
	moveq		#malloc_base,d0
	bsr		sort_mallocs
*-------------------------------------------------------*
	move.l		system_array(a6),a3
	move.l		a3,a4
	moveq		#0,d2
*-------------------------------------------------------*
*	Iterations = (chunks-1)				*
*-------------------------------------------------------*
	move.w		system_chunks(a6),d6
	subq.w		#1,d6
	ble.s		.err
*-------------------------------------------------------*
*	Index for endmost chunk				*
*-------------------------------------------------------*
	move.w		d6,d7
*-------------------------------------------------------*
*	Start joining chunks				*
*-------------------------------------------------------*
	bra.s		.loops
*-------------------------------------------------------*
*	a4 = current chunk / a5 = next chunk		*
*-------------------------------------------------------*
.loop:	lea		malloc_slen(a4),a5
*-------------------------------------------------------*
*	Check adjacent chunks for contiguity		*
*-------------------------------------------------------*
	move.l		malloc_base(a4),d0
	move.l		malloc_size(a4),d1
	add.l		d1,d0
	cmp.l		malloc_base(a5),d0
	bne.s		.gap
*-------------------------------------------------------*
*	Expand current chunk into next			*
*-------------------------------------------------------*
	add.l		malloc_size(a5),d1
	move.l		d1,malloc_size(a4)
*-------------------------------------------------------*
*	Fill new gap with endmost chunk			*
*-------------------------------------------------------*
	move.l		malloc_base(a3,d7.w*malloc_slen),malloc_base(a5)
	move.l		malloc_size(a3,d7.w*malloc_slen),malloc_size(a5)
*-------------------------------------------------------*
*	Reduce chunk count by #1			*
*-------------------------------------------------------*
	subq.w		#1,system_chunks(a6)
*-------------------------------------------------------*
	bra		join_mallocs
*-------------------------------------------------------*
.gap:	move.l		a5,a4
.loops:	dbra		d6,.loop
*-------------------------------------------------------*
.err:	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

os_st_reserve_ptr:	ds.l	1
os_tt_reserve_ptr:	ds.l	1

ram_type:		ds.l	1

memory_handle:		ds.l	1

*-------------------------------------------------------*

st_memory_pool:		ds.b	pool_slen

st_used_array_space:	ds.l	chunk_limit
st_free_array_space:	ds.l	chunk_limit
st_chunk_array_space:	ds.b	chunk_slen*chunk_limit
st_system_array_space:	ds.b	malloc_slen*malloc_limit

*-------------------------------------------------------*

tt_memory_pool:		ds.b	pool_slen

tt_used_array_space:	ds.l	chunk_limit
tt_free_array_space:	ds.l	chunk_limit
tt_chunk_array_space:	ds.b	chunk_slen*chunk_limit
tt_system_array_space:	ds.b	malloc_slen*malloc_limit

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
