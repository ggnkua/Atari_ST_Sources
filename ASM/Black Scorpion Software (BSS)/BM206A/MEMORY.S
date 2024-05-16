*=======================================================*
*	Memory module: latest update 25/03/96		*
*=======================================================*
*	Dynamic triple-linked block manager		*
*=======================================================*
*	Auto-defrag on block deallocation		*
*=======================================================*

malloc_limit		=	32
chunk_limit		=	2048

			rsreset
malloc_base		rs.l	1
malloc_size		rs.l	1
malloc_slen		rs.b	0

			rsreset
chunk_base		rs.l	1
chunk_blocks		rs.w	1
chunk_slot		rs.l	1
chunk_lf		rs.b	1
chunk_rf		rs.b	1
chunk_ln		rs.l	1
chunk_rn		rs.l	1
chunk_slen		rs.b	0

cf_used_bit		=	0
cf_break_bit		=	5
cf_used			=	1<<cf_used_bit
cf_break		=	1<<cf_break_bit

block_bits		=	12
block_size		=	1<<block_bits

*-------------------------------------------------------*
init_block_manager:
*-------------------------------------------------------*
	bsr		claim_memory
	bsr		create_chunklist
	rts

*-------------------------------------------------------*
allocate_chunk:
*-------------------------------------------------------*
	add.l		#block_size-1,d0
	lsr.l		#block_bits-8,d0
	lsr.l		#8,d0
*-------------------------------------------------------*
allocate_blocks:
*-------------------------------------------------------*
	movem.l		d1-d3/d5-d6/a0-a6,-(sp)
*-------------------------------------------------------*
	cmp.w		#chunk_limit,used_chunks
	beq		.alloc_fail
*-------------------------------------------------------*
*	Find suitable block to claim / split		*
*-------------------------------------------------------*
	lea		free_array,a6
	move.w		free_chunks,d6
	lea		(a6,d6.w*4),a6
	bra.s		.loop_start
*-------------------------------------------------------*
.size_loop:
*-------------------------------------------------------*
	move.l		-(a6),a4
	cmp.w		chunk_blocks(a4),d0
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
	move.w		free_chunks,d5
	subq.w		#1,d5
	move.w		d5,free_chunks
*-------------------------------------------------------*
*	Seal gap in list using last entry		*
*-------------------------------------------------------*
	lea		free_array,a3
	move.l		(a3,d5.w*4),a2
	clr.l		(a3,d5.w*4)
	bra		.skip_split
*-------------------------------------------------------*
.split_chunk:
*-------------------------------------------------------*
	cmp.w		#chunk_limit,chunk_count
	beq		.alloc_fail
*-------------------------------------------------------*
*	Shrink original chunk to required size		*
*-------------------------------------------------------*
	move.w		chunk_blocks(a4),d1
	move.w		d0,chunk_blocks(a4)
	sub.w		d0,d1
*-------------------------------------------------------*
*	Calculate new chunk's base address		*
*-------------------------------------------------------*
	ext.l		d0
	moveq		#block_bits,d2
	lsl.l		d2,d0
	add.l		chunk_base(a4),d0
*-------------------------------------------------------*
*	Create new chunk				*
*-------------------------------------------------------*
	move.w		chunk_count,d2
	addq.w		#1,chunk_count
	lea		chunk_array,a2	
	mulu.w		#chunk_slen,d2
	add.l		d2,a2
	move.l		d0,chunk_base(a2)
	move.w		d1,chunk_blocks(a2)
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
	move.b		#0,chunk_lf(a2)
	move.b		#0,chunk_rf(a4)
*-------------------------------------------------------*
.skip_split:
*-------------------------------------------------------*
*	Replace gap in free array & relocate		*
*-------------------------------------------------------*
	move.l		a2,(a6)
	move.l		a6,chunk_slot(a2)
*-------------------------------------------------------*
*	Hash chunk address				*
*-------------------------------------------------------*
	move.l		chunk_base(a4),d0
	move.l		d0,d2
	moveq		#block_bits,d3
	lsr.l		d3,d2
	lea		used_array,a2
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
*	Double-link chunk with hashed slot		* 
*-------------------------------------------------------*
	lea		(a2,d2.w*4),a3
	move.l		a4,(a3)
	move.l		a3,chunk_slot(a4)
	addq.w		#1,used_chunks
*-------------------------------------------------------*
*	Flag chunk as 'used' to neighbours		*
*-------------------------------------------------------*
	move.l		chunk_ln(a4),a3
	move.l		chunk_rn(a4),a5
	moveq		#cf_used,d2
	or.b		d2,chunk_rf(a3)
	or.b		d2,chunk_lf(a5)
*-------------------------------------------------------*
.exit:	movem.l		(sp)+,d1-d3/d5-d6/a0-a6
	rts

*-------------------------------------------------------*
deallocate_chunk:
*-------------------------------------------------------*
	movem.l		d1-a6,-(sp)
*-------------------------------------------------------*
*	Hash chunk address				*
*-------------------------------------------------------*
	move.l		d0,d2
	moveq		#block_bits,d3
	lsr.l		d3,d2
	lea		used_array,a2
*-------------------------------------------------------*
*	Search for free hash slot			*
*-------------------------------------------------------*
.search_slot:
*-------------------------------------------------------*
	and.w		#chunk_limit-1,d2
	move.l		(a2,d2.w*4),d3
	beq.s		.fail_dealloc
*-------------------------------------------------------*
.check_handle:
*-------------------------------------------------------*
	move.l		d3,a3
	cmp.l		chunk_base(a3),d0
	beq.s		.found_slot
*-------------------------------------------------------*
.advance_check:
*-------------------------------------------------------*
	addq.w		#1,d2
	bra.s		.search_slot
*-------------------------------------------------------*
.fail_dealloc:
*-------------------------------------------------------*
	moveq		#-1,d0
	bra		.exit
*-------------------------------------------------------*
.found_slot:
*-------------------------------------------------------*
*	Deallocate chunk from 'used' array		*
*-------------------------------------------------------*
	subq.w		#1,used_chunks
	move.l		chunk_slot(a3),a2
	clr.l		(a2)
*-------------------------------------------------------*
*	Determine defrag rules for neighbours		*
*-------------------------------------------------------*
	move.l		chunk_ln(a3),a2
	move.l		chunk_rn(a3),a4
	tst.b		chunk_lf(a3)
	beq		.join_part
	tst.b		chunk_rf(a3)
	beq		.join_right
*-------------------------------------------------------*
.no_join:
*-------------------------------------------------------*
*	No join possible - flag as free to neighbours	*
*-------------------------------------------------------*
	bclr		#cf_used_bit,chunk_rf(a2)	
	bclr		#cf_used_bit,chunk_lf(a4)	
*-------------------------------------------------------*
*	Append chunk to 'free' array			*
*-------------------------------------------------------*
	move.w		free_chunks,d0
	lea		free_array,a0
	lea		(a0,d0.w*4),a5
	move.l		a3,(a5)
	move.l		a5,chunk_slot(a3)
	addq.w		#1,d0
	move.w		d0,free_chunks
	bra		.join_done
*-------------------------------------------------------*
.join_right:
*-------------------------------------------------------*
*	Expand right neighbour to fill space		*
*-------------------------------------------------------*
	move.w		chunk_blocks(a3),d0
	add.w		d0,chunk_blocks(a4)
	move.l		chunk_base(a3),chunk_base(a4)
*-------------------------------------------------------*
*	Unlink chunk from chain				*
*-------------------------------------------------------*
	bsr		unlink_chunk
	bra.s		.join_done
*-------------------------------------------------------*
.join_left:
*-------------------------------------------------------*
*	Expand left neighbour to fill space		*
*-------------------------------------------------------*
	move.w		chunk_blocks(a3),d0
	add.w		d0,chunk_blocks(a2)
*-------------------------------------------------------*
*	Unlink chunk from chain				*
*-------------------------------------------------------*
	bsr		unlink_chunk
	bra.s		.join_done
*-------------------------------------------------------*
.join_part:
*-------------------------------------------------------*
	tst.b		chunk_rf(a3)
	bne.s		.join_left
*-------------------------------------------------------*
.join_both:
*-------------------------------------------------------*
*	Expand left neighbour to fill space		*
*-------------------------------------------------------*
	move.w		chunk_blocks(a3),d0
	add.w		chunk_blocks(a4),d0
	add.w		d0,chunk_blocks(a2)
*-------------------------------------------------------*
*	Unlink this chunk from chain			*
*-------------------------------------------------------*
	move.l		chunk_slot(a4),a0		
	bsr		unlink_chunk
	move.l		(a0),a3
*-------------------------------------------------------*
*	Deallocate right neighbour from 'free' array	*
*-------------------------------------------------------*
	move.w		free_chunks,d0
	subq.w		#1,d0
	move.w		d0,free_chunks
	lea		free_array,a4
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
.join_done:
*-------------------------------------------------------*
*	Deallocation was successful			*
*-------------------------------------------------------*
	moveq		#0,d0
*-------------------------------------------------------*
.exit:	movem.l		(sp)+,d1-a6
	rts

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
	move.w		chunk_count,d1
	lea		chunk_array,a1
	subq.w		#1,d1
	move.w		d1,chunk_count
	mulu.w		#chunk_slen,d1
	add.l		d1,a1
	move.l		a3,a5
	moveq		#0,d7
	moveq		#(chunk_slen/4)-1,d1
.seal:	move.l		(a1),(a5)+
	move.l		d7,(a1)+
	dbra		d1,.seal
	cmp.l		a1,a5
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
	lea		malloc_record,a6	
	moveq		#malloc_limit-1,d7
	moveq		#0,d5
*-------------------------------------------------------*
.claim_memory:
*-------------------------------------------------------*
*	Check for fast memory				*
*-------------------------------------------------------*
	move.w		#VRAM_only,-(sp)
	pea		-1.w
	move.w		#68,-(sp)
	trap		#1
	addq.l		#8,sp
	move.w		#STRAM_only,ram_type
	tst.l		d0
	beq.s		.stram
	move.w		#VRAM_only,ram_type
*-------------------------------------------------------*
*	Claim loop					*
*-------------------------------------------------------*
.stram:	move.w		ram_type,-(sp)
	pea		-1.w
	move.w		#68,-(sp)
	trap		#1
	addq.l		#8,sp
	tst.l		d0
	beq.s		.memory_exhausted
	move.l		d0,d6
	move.w		ram_type,-(sp)
	push.l		d0
	move.w		#68,-(sp)
	trap		#1
	addq.l		#8,sp
	move.l		d0,(a6)+
	move.l		d6,(a6)+
	addq.l		#1,d5
	dbra		d7,.claim_memory
*-------------------------------------------------------*
.memory_exhausted:
*-------------------------------------------------------*
	move.w		d5,malloc_count
	rts	

*-------------------------------------------------------*
create_chunklist:
*-------------------------------------------------------*
	bsr		join_mallocs
	bsr		init_chunks
	rts

*-------------------------------------------------------*
init_chunks:
*-------------------------------------------------------*
	moveq		#malloc_base,d0
	bsr		sort_mallocs
*-------------------------------------------------------*
	clr.w		free_chunks
	clr.w		used_chunks
	lea		free_array,a4
	lea		chunk_array,a0
	move.l		a0,a1
	moveq		#0,d6
*-------------------------------------------------------*
	lea		malloc_record,a6
	move.w		malloc_count,d7
	subq.w		#1,d7
	move.l		a6,a5
*-------------------------------------------------------*
.loop:	move.l		malloc_base(a5),d0
	move.l		malloc_size(a5),d1
	add.l		d0,d1
	addq.l		#4-1,d0
	addq.l		#4-1,d1
	and.b		#-4,d0
	and.b		#-4,d1
	sub.l		d0,d1
	moveq		#block_bits,d2
	lsr.l		d2,d1
	beq.s		.cull
	move.l		a4,chunk_slot(a0)
*-------------------------------------------------------*
*	Create chunk & link to neighbours		*
*-------------------------------------------------------*
	move.l		d0,chunk_base(a0)
	move.w		d1,chunk_blocks(a0)
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
	move.l		a0,(a4)+
*-------------------------------------------------------*
*	Advance to next chunk				*
*-------------------------------------------------------*
	lea		chunk_slen(a0),a0
	addq.w		#1,d6
*-------------------------------------------------------*
.cull:	lea		malloc_slen(a5),a5
	dbra		d7,.loop
*-------------------------------------------------------*
	move.w		d6,free_chunks
	move.w		d6,chunk_count
*-------------------------------------------------------*
*	Link in synthetic [terminator] chunks		*
*-------------------------------------------------------*
	move.w		free_chunks,d0
	subq.w		#1,d0
	mulu.w		#chunk_slen,d0
	lea		chunk_array,a0
	add.l		d0,a1
	lea		dummy_chunk,a2
	move.l		a2,chunk_ln(a0)
	move.l		a2,chunk_rn(a1)
	move.l		a0,chunk_rn(a2)
	move.l		a1,chunk_ln(a2)
	rts

*-------------------------------------------------------*
join_mallocs:
*-------------------------------------------------------*
	moveq		#malloc_base,d0
	bsr		sort_mallocs
*-------------------------------------------------------*
	lea		malloc_record,a6
	move.l		a6,a4
	move.w		malloc_count,d6
	moveq		#0,d2
	subq.w		#1,d6
	move.w		d6,d7
	ble.s		.err
*-------------------------------------------------------*
.loop:	lea		malloc_slen(a4),a5
	move.l		malloc_base(a4),d0
	move.l		malloc_size(a4),d1
	add.l		d1,d0
	cmp.l		malloc_base(a5),d0
	bne.s		.gap
*-------------------------------------------------------*
	add.l		malloc_size(a5),d1
	move.l		d1,malloc_size(a4)
	move.l		malloc_base(a6,d7.w*malloc_slen),malloc_base(a5)
	move.l		malloc_size(a6,d7.w*malloc_slen),malloc_size(a5)
	move.l		d2,malloc_base(a6,d7.w*malloc_slen)
	move.l		d2,malloc_size(a6,d7.w*malloc_slen)
	subq.w		#1,malloc_count
*-------------------------------------------------------*
	bra		join_mallocs
*-------------------------------------------------------*
.gap:	move.l		a5,a4
	dbra		d6,.loop
*-------------------------------------------------------*
.err:	rts

*-------------------------------------------------------*
sort_mallocs:
*-------------------------------------------------------*
	lea		malloc_record,a6
	move.w		malloc_count,d6
	subq.w		#1,d6
	ble		.err
*-------------------------------------------------------*
.outer_loop:
*-------------------------------------------------------*
	move.l		a6,a5
	move.w		d6,d5
	moveq		#0,d4
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
	dbra		d6,.outer_loop
*-------------------------------------------------------*
.err:	rts

*-------------------------------------------------------*
			datlong
*-------------------------------------------------------*

*-------------------------------------------------------*
*	Synthetic chunk for terminating lists		*
*-------------------------------------------------------*
dummy_chunk:
*-------------------------------------------------------*
	dc.l		0
	dc.w		0
	dc.l		dummy_slot
	dc.b		cf_break
	dc.b		cf_break
	dc.l		dummy_chunk
	dc.l		dummy_chunk
	
dummy_slot:
	dc.l		dummy_chunk

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

ram_type:		ds.w	1

malloc_count:		ds.w	1			
malloc_record:		ds.b	malloc_slen*malloc_limit

used_chunks:		ds.w	1
free_chunks:		ds.w	1

chunk_count:		ds.w	1
chunk_array:		ds.b	chunk_slen*chunk_limit

free_array:		ds.l	chunk_limit
used_array:		ds.l	chunk_limit

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
