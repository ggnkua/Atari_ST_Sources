
*-----------------------------------------------------------------------*
*	Sliding block memory management	module				*
*-----------------------------------------------------------------------*

altram_bit	=	14

*-----------------------------------------------------------------------*
Init_Blocklists:
*-----------------------------------------------------------------------*
	move.l		STRAM_START,d0
	add.l		STRAM_LENGTH,d0
	move.l		d0,STRAM_END
	move.l		STRAM_START,a0
	move.l		#blockterm,block_slot(a0)
	move.l		a0,STRAM_ADDR
	move.w		#max_blocks,STRAM_MAXBLOCKS
	move.l		#handlebuffer1,STRAM_HANDLES
	clr.w		STRAM_BLOCKCOUNT
*-----------------------------------------------------------------------*
	tst.b		VRAM
	beq.s		.no
*-----------------------------------------------------------------------*
	move.l		VRAM_START,d0
	add.l		VRAM_LENGTH,d0
	move.l		d0,VRAM_END
	move.l		VRAM_START,a0
	move.l		#blockterm,block_slot(a0)
	move.l		a0,VRAM_ADDR
	move.w		#max_blocks,VRAM_MAXBLOCKS
	move.l		#handlebuffer2,VRAM_HANDLES
	clr.w		VRAM_BLOCKCOUNT
*-----------------------------------------------------------------------*
.no	rts	

*-----------------------------------------------------------------------*
Find_block:
*-----------------------------------------------------------------------*
*	d0		block handle					*
*	a0		returned address				*
*-----------------------------------------------------------------------*
	bclr		#altram_bit,d0
	beq.s		.sram
*-----------------------------------------------------------------------*
	cmp.w		VRAM_MAXBLOCKS,d0			; range check
	bge.s		.error_range
	move.l		([VRAM_HANDLES.l],d0.w*4),d0
	bra.s		.gotb
*-----------------------------------------------------------------------*
.sram	cmp.w		STRAM_MAXBLOCKS,d0			; range check
	bge.s		.error_range
	move.l		([STRAM_HANDLES.l],d0.w*4),d0
.gotb:	beq.s		.error_pointer
*-----------------------------------------------------------------------*
	lea		(block_head.w,d0.l),a0
	bra.s		.exit
*-----------------------------------------------------------------------*
*	Various errors							*	
*-----------------------------------------------------------------------*
.error_range:
*-----------------------------------------------------------------------*
	lea		WIN_FBR_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_pointer:
*-----------------------------------------------------------------------*
	lea		WIN_FBP_Alert,a0
	jsr		DO_ALERT
*-----------------------------------------------------------------------*
*	General error							*
*-----------------------------------------------------------------------*
.err	moveq		#-1,d0
	bra.s		.rts
*-----------------------------------------------------------------------*
*	No errors							*
*-----------------------------------------------------------------------*
.exit	moveq		#0,d0
*-----------------------------------------------------------------------*
.rts	rts

*-----------------------------------------------------------------------*
Add_fastonly:
*-----------------------------------------------------------------------*
	move.b		fastmemonly_code,d1
	bra.s		Add_block
*-----------------------------------------------------------------------*
Add_fast:
*-----------------------------------------------------------------------*
	move.b		fastmempref_code,d1
	bra.s		Add_block
*-----------------------------------------------------------------------*
Add_virtual:
*-----------------------------------------------------------------------*
	move.b		virtmempref_code,d1
	bra.s		Add_block
*-----------------------------------------------------------------------*
Add_normal:
*-----------------------------------------------------------------------*
	moveq		#STRAM_only,d1
*-----------------------------------------------------------------------*
Add_block:
*-----------------------------------------------------------------------*
*	d0		bytes to grab					*
*	d1		type of ram					*
*-----------------------------------------------------------------------*
	addq.l		#4-1,d0
	and.l		#-4,d0
*-----------------------------------------------------------------------*
	tst.b		VRAM
	beq.s		Add_STRAM_only
	extb.l		d1
	beq.s		Add_STRAM_only
	subq.l		#1,d1
	beq.s		Add_VRAM_only
	subq.l		#1,d1
	beq.s		Add_STRAM_pref

*-----------------------------------------------------------------------*
Add_VRAM_pref:
*-----------------------------------------------------------------------*
	move.l		VRAM_ADDR,d1
	add.l		d0,d1
	add.l		#(block_head+4),d1
	cmp.l		VRAM_END,d1
	ble.s		Add_VRAM_only
	bra.s		Add_STRAM_only

*-----------------------------------------------------------------------*
Add_STRAM_pref:
*-----------------------------------------------------------------------*
	move.l		STRAM_ADDR,d1
	add.l		d0,d1
	add.l		#(block_head+4),d1
	cmp.l		STRAM_END,d1
	ble.s		Add_STRAM_only
	bra.s		Add_VRAM_only

*-----------------------------------------------------------------------*
Add_STRAM_only:
*-----------------------------------------------------------------------*
	bsr		Get_STRAM_data		
	bsr.s		Add_ram_block
	rts

*-----------------------------------------------------------------------*
Add_VRAM_only:
*-----------------------------------------------------------------------*
	bsr		Get_VRAM_data		
*-----------------------------------------------------------------------*
	bsr.s		Add_ram_block
	tst.l		d0
	bmi.s		.error
*-----------------------------------------------------------------------*
	bset		#altram_bit,d0
*-----------------------------------------------------------------------*
.error:	rts

*-----------------------------------------------------------------------*
Add_ram_block:
*-----------------------------------------------------------------------*
	st		HOLD_STATS
*-----------------------------------------------------------------------*
	move.l		([RAM_ADDR.l]),d1
	add.l		d0,d1
	add.l		#(block_head+4),d1
	cmp.l		RAM_END,d1
	bgt.s		.error_ram
*-----------------------------------------------------------------------*
	move.l		RAM_HANDLES,a6
	clr.l		d1
	move.w		RAM_MAXBLOCKS,d2
	bra.s		.looks
.lookl:	tst.l		(a6)+
	beq.s		.use
	addq.l		#1,d1
.looks:	dbra		d2,.lookl
	bra.s		.error_rsc
.use:	subq.l		#4,a6
*-----------------------------------------------------------------------*
	move.l		([RAM_ADDR.l]),a5		; get address of next space
	move.l		a5,(a6)				; store the address in slot #n
	move.l		a6,block_slot(a5)		; store slot address in block
	move.l		d0,block_size(a5)		; now store block size
	addq.l		#block_head,a5
	move.l		a5,a0
	add.l		d0,a5
	move.l		#blockterm,block_slot(a5)	; terminate blocks
	move.l		a5,([RAM_ADDR.l])		; and skip to new block address.
	addq.w		#1,([RAM_BLOCKCOUNT.l])		; increment block counter.
	move.l		d1,d0
	bra.s		.exit
*-----------------------------------------------------------------------*
*	Various errors							*	
*-----------------------------------------------------------------------*
.error_ram:
*-----------------------------------------------------------------------*
	tst.b		lock_errors
	bne.s		.err
*-----------------------------------------------------------------------*
	lea		WIN_RAM_Alert,a0		; memory full
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_rsc:
*-----------------------------------------------------------------------*
	lea		WIN_BAF_Alert,a0		; blocks are all used
	jsr		DO_ALERT
*-----------------------------------------------------------------------*
*	An error occurred						*	
*-----------------------------------------------------------------------*
.err:	moveq		#-1,d0
*-----------------------------------------------------------------------*
*	No errors							*	
*-----------------------------------------------------------------------*
.exit:	sf		HOLD_STATS
*-----------------------------------------------------------------------*
	rts
	
*-----------------------------------------------------------------------*
Remove_block:
*-----------------------------------------------------------------------*
*	d0.w		block handle					*
*-----------------------------------------------------------------------*
	bsr		Get_memory_data
*-----------------------------------------------------------------------*
	st		HOLD_STATS
*-----------------------------------------------------------------------*
	movem.l		d1-a6,-(sp)
*-----------------------------------------------------------------------*
*	Range check on handle						*
*-----------------------------------------------------------------------*
	cmp.w		RAM_MAXBLOCKS,d0		; range check
	bge.s		.error_range
*-----------------------------------------------------------------------*
*	Get address of block to kill					*
*-----------------------------------------------------------------------*
	lea		([RAM_HANDLES.l],d0.w*4),a0
	move.l		(a0),d0				; address of actual block
	beq.s		.error_pointer			; if zero, block does not exist
	clr.l		(a0)
	move.l		d0,a6				; block address here
	move.l		block_size(a6),d2		; size of block to remove
	addq.l		#block_head,d2			; plus size of header
*-----------------------------------------------------------------------*
*	Get address of next block					*
*-----------------------------------------------------------------------*
	move.l		a6,a2				; current block address
	add.l		d2,a2				; next block address
	move.l		a2,a3				; keep copy of next block
*-----------------------------------------------------------------------*
*	Drop blocks downwards						*
*-----------------------------------------------------------------------*
.next:	move.l		block_slot(a2),a4		; get slot pointer
	cmp.l		#blockterm,a4
	beq.s		.done				; if last block, stop block-sliding
	sub.l		d2,(a4)				; re-point slot to new block position
	move.l		block_size(a2),d0
	beq.s		.error_zero
	addq.l		#block_head,a2			; skip header
	add.l		d0,a2				; skip to next block
	bra.s		.next				; repeat until done
*-----------------------------------------------------------------------*
.done:	move.l		a2,d0
	sub.l		a3,d0				; block_end-block_start = size
	move.l		a3,a0				; block source (next)
	sub.l		d2,a3
	move.l		a3,a1				; block destination (next-drop)
	jsr		memcpy
	add.l		d0,a1
	move.l		#blockterm,block_slot(a1)
	move.l		a1,([RAM_ADDR.l])
	subq.w		#1,([RAM_BLOCKCOUNT.l])		; decrement number of blocks
	bra.s		.exit
*-----------------------------------------------------------------------*
*	Various errors							*	
*-----------------------------------------------------------------------*
.error_range:
*-----------------------------------------------------------------------*
	lea		WIN_DBR_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_pointer:
*-----------------------------------------------------------------------*
	lea		WIN_DBP_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_zero:
*-----------------------------------------------------------------------*
	lea		WIN_DBZ_Alert,a0
	jsr		DO_ALERT
*-----------------------------------------------------------------------*
*	An error occurred						*	
*-----------------------------------------------------------------------*
.err:	moveq		#-1,d0
	bra.s		.rts
*-----------------------------------------------------------------------*
*	No errors							*
*-----------------------------------------------------------------------*
.exit:	moveq		#0,d0
*-----------------------------------------------------------------------*
.rts:	movem.l		(sp)+,d1-a6
*-----------------------------------------------------------------------*
	sf		HOLD_STATS
*-----------------------------------------------------------------------*
	rts

*-----------------------------------------------------------------------*
Resize_block:
*-----------------------------------------------------------------------*
*	d0.w		block handle					*
*	d1.l		new size					*
*-----------------------------------------------------------------------*
	bsr		Get_memory_data
*-----------------------------------------------------------------------*
	st		HOLD_STATS
*-----------------------------------------------------------------------*
*	Range check on handle						*
*-----------------------------------------------------------------------*
	cmp.w		RAM_MAXBLOCKS,d0	; range check
	bge		.error_range
*-----------------------------------------------------------------------*
*	Get address of block to kill					*
*-----------------------------------------------------------------------*
	addq.l		#4-1,d1
	and.l		#-4,d1
*-----------------------------------------------------------------------*
	move.l		RAM_HANDLES,a0
	move.l		(a0,d0.w*4),d0		; address of actual block
	beq		.error_pointer		; if zero, block does not exist
	move.l		d0,a6			; block address here
	move.l		block_size(a6),d2	; old size
	sub.l		d2,d1			; get size difference
	beq		.exit			; if same, don't bother.
	bpl.s		.grow			; if larger, grow block.
*-----------------------------------------------------------------------*
*	Drop blocks downwards						*
*-----------------------------------------------------------------------*
.shrn:	addq.l		#block_head,d2		; skip past header
	move.l		a6,a2			; current block address
	add.l		d2,a2			; next block address
	move.l		a2,a3			; keep copy of next block
*-----------------------------------------------------------------------*
.next:	move.l		block_slot(a2),a4	; get slot pointer
	cmp.l		#blockterm,a4
	beq.s		.done			; if last block, stop block-sliding
	add.l		d1,(a4)			; re-point slot to new block position
	move.l		block_size(a2),d0
	beq		.error_zero
	addq.l		#block_head,a2		; skip header
	add.l		d0,a2			; skip to next block
	bra.s		.next			; repeat until done
*-----------------------------------------------------------------------*
.done:	move.l		a2,d0
	sub.l		a3,d0			; block_end-block_start = size
	move.l		a3,a0			; block source (next)
	add.l		d1,a3
	move.l		a3,a1			; block destination (next-drop)
	jsr		memcpy
	add.l		d0,a1
	add.l		d1,block_size(a6)
	move.l		#blockterm,block_slot(a1)
	move.l		a1,([RAM_ADDR.l])
	bra		.exit
*-----------------------------------------------------------------------*
*	Shift blocks upwards						*
*-----------------------------------------------------------------------*
.grow:	move.l		([RAM_ADDR.l]),d0
	add.l		d1,d0
	add.l		#(block_head+4),d0	; range check for memory
	cmp.l		RAM_END,d0		; if new size is bigger than
	bgt.s		.error_ram		; free ram, then quit.
*-----------------------------------------------------------------------*
*	Enough memory for expansion					*
*-----------------------------------------------------------------------*
	add.l		#block_head,d2		; skip past header
	move.l		a6,a2			; current block address
	add.l		d2,a2			; next block address
	move.l		a2,a3			; keep copy of next block
*-----------------------------------------------------------------------*
.nxt2:	move.l		block_slot(a2),a4	; get slot pointer
	cmp.l		#blockterm,a4
	beq.s		.don2			; if last block, stop block-sliding
	add.l		d1,(a4)			; re-point slot to new block position
	move.l		block_size(a2),d0
	beq.s		.error_zero
	addq.l		#block_head,a2		; skip header
	add.l		d0,a2			; skip to next block
	bra.s		.nxt2			; repeat until done
*-----------------------------------------------------------------------*
.don2:	move.l		a2,d0
	sub.l		a3,d0			; block_end-block_start = size
	move.l		a3,a0			; block source (next)
	add.l		d1,a3
	move.l		a3,a1			; block destination (next+grow)
	jsr		memcpy
	add.l		d0,a1
	add.l		d1,block_size(a6)
	move.l		#blockterm,block_slot(a1)
	move.l		a1,([RAM_ADDR.l])
	bra.s		.exit
*-----------------------------------------------------------------------*
*	Various errors							*	
*-----------------------------------------------------------------------*
.error_range:
*-----------------------------------------------------------------------*
	lea		WIN_RBR_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_pointer:
*-----------------------------------------------------------------------*
	lea		WIN_RBP_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_ram:
*-----------------------------------------------------------------------*
	lea		WIN_RAM_Alert,a0
	jsr		DO_ALERT
	bra.s		.err
*-----------------------------------------------------------------------*
.error_zero:
*-----------------------------------------------------------------------*
	lea		WIN_RBZ_Alert,a0
	jsr		DO_ALERT
*-----------------------------------------------------------------------*
*	An error occurred						*	
*-----------------------------------------------------------------------*
.err:	moveq		#-1,d0
	bra.s		.rts
*-----------------------------------------------------------------------*
*	No errors occurred						*	
*-----------------------------------------------------------------------*
.exit:	moveq		#0,d0
*-----------------------------------------------------------------------*
.rts:	sf		HOLD_STATS
*-----------------------------------------------------------------------*
	rts

*-----------------------------------------------------------------------*
Translate_block:							*
*-----------------------------------------------------------------------*
*	d0.w	=	handle in					*
*	d1.l	=	new size in					*
*-----------------------------------------------------------------------*
*	d0.w	=	handle / error					*
*-----------------------------------------------------------------------*
	move.w		d0,blkhandle
*-----------------------------------------------------------------------*
	btst		#altram_bit,d0
	beq.s		Resize_STRAM
	bra.s		Resize_VRAM
	
*-----------------------------------------------------------------------*
Block_fits:
*-----------------------------------------------------------------------*
	push.w		d0
	jsr		Resize_block
	clr.l		d1
	pop.w		d1
*-----------------------------------------------------------------------*
	tst.l		d0
	bmi.s		.error
*-----------------------------------------------------------------------*
	move.l		d1,d0
*-----------------------------------------------------------------------*
.error:
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
Block_translated:
*-----------------------------------------------------------------------*
	rts

*-----------------------------------------------------------------------*
Resize_STRAM:
*-----------------------------------------------------------------------*
	move.l		STRAM_HANDLES,a0
	move.l		d1,d2
	addq.l		#4-1,d2
	and.l		#-4,d2
	sub.l		(block_size.w,[a0,d0.w*4]),d2
	beq.s		Block_translated
	bmi.s		Block_fits
*-----------------------------------------------------------------------*
*	Make sure block fits after expansion				*
*-----------------------------------------------------------------------*
	move.l		STRAM_ADDR,d3
	add.l		d2,d3
	add.l		#(block_head+4),d3
	cmp.l		STRAM_END,d3
	ble.s		Block_fits
*-----------------------------------------------------------------------*
*	Block doesn't fit - move it into alternate zone			*
*-----------------------------------------------------------------------*
	move.l		d1,d0
	moveq		#VRAM_only,d1
	jsr		Add_block
	tst.l		d0
	bmi.s		Block_translated
*-----------------------------------------------------------------------*
*	Transfer worked - remove old block				*
*-----------------------------------------------------------------------*
	push.w		d0
	move.w		blkhandle,d0
	jsr		Remove_block
	pop.w		d0
	bra.s		Block_translated
	
*-----------------------------------------------------------------------*
Resize_VRAM:
*-----------------------------------------------------------------------*
	move.w		d0,blkhandle
*-----------------------------------------------------------------------*
	move.l		VRAM_HANDLES,a0
	move.l		d1,d2
	addq.l		#4-1,d2
	and.l		#-4,d2
	move.w		d0,d4
	bclr		#altram_bit,d4
	sub.l		(block_size.w,[a0,d4.w*4]),d2
	beq.s		Block_translated
	bmi		Block_fits
*-----------------------------------------------------------------------*
*	Make sure block fits after expansion				*
*-----------------------------------------------------------------------*
	move.l		VRAM_ADDR,d3
	add.l		d2,d3
	add.l		#(block_head+4),d3
	cmp.l		VRAM_END,d3
	ble		Block_fits
*-----------------------------------------------------------------------*
*	Block doesn't fit - move it into alternate zone			*
*-----------------------------------------------------------------------*
	move.l		d1,d0
	moveq		#STRAM_only,d1
	jsr		Add_block
	tst.l		d0
	bmi		Block_translated
*-----------------------------------------------------------------------*
*	Transfer worked - remove old block				*
*-----------------------------------------------------------------------*
	push.l		d0
	move.w		blkhandle,d0
	jsr		Remove_block
	pop.l		d0
	bra		Block_translated

*-----------------------------------------------------------------------*
*	Select STRAM / VRAM variables					*
*-----------------------------------------------------------------------*
Get_memory_data:
*-----------------------------------------------------------------------*
	bclr		#altram_bit,d0
	beq.s		Get_STRAM_data

*-----------------------------------------------------------------------*
Get_VRAM_data:
*-----------------------------------------------------------------------*
	move.l		#VRAM_ADDR,RAM_ADDR	
	move.l		#VRAM_BLOCKCOUNT,RAM_BLOCKCOUNT	
	move.l		VRAM_START,RAM_START
	move.l		VRAM_END,RAM_END
	move.l		VRAM_HANDLES,RAM_HANDLES
	move.w		VRAM_MAXBLOCKS,RAM_MAXBLOCKS
	rts

*-----------------------------------------------------------------------*
Get_STRAM_data:
*-----------------------------------------------------------------------*
	move.l		#STRAM_ADDR,RAM_ADDR	
	move.l		#STRAM_BLOCKCOUNT,RAM_BLOCKCOUNT	
	move.l		STRAM_START,RAM_START
	move.l		STRAM_END,RAM_END
	move.l		STRAM_HANDLES,RAM_HANDLES
	move.w		STRAM_MAXBLOCKS,RAM_MAXBLOCKS
	rts

*-----------------------------------------------------------------------*
*	Second level memory management routines				*
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
MALLOCATE_fastonly:
*-----------------------------------------------------------------------*
	move.b		fastmemonly_code,d1
	bra.s		MALLOCATE

*-----------------------------------------------------------------------*
MALLOCATE_fast:
*-----------------------------------------------------------------------*
	move.b		fastmempref_code,d1
	bra.s		MALLOCATE

*-----------------------------------------------------------------------*
MALLOCATE_virtual:
*-----------------------------------------------------------------------*
	move.b		virtmempref_code,d1
	bra.s		MALLOCATE
	
*-----------------------------------------------------------------------*
MALLOCATE_normal:
*-----------------------------------------------------------------------*
	moveq		#STRAM_only,d1

*-----------------------------------------------------------------------*
MALLOCATE:
*-----------------------------------------------------------------------*
	extb.l		d1
	jsr		Add_block
	tst.l		d0
	bmi.s		.rts
*-----------------------------------------------------------------------*
	move.l		BLOCKTRACK_PTR,a1
	move.w		d0,(a1)+
	move.l		a1,BLOCKTRACK_PTR
	addq.w		#1,BLOCKTRACK_COUNT
*-----------------------------------------------------------------------*
.rts:	rts

*-----------------------------------------------------------------------*
MRELEASE:
*-----------------------------------------------------------------------*
	tst.w		BLOCKTRACK_COUNT
	beq.s		.rts
	move.l		BLOCKTRACK_PTR,a0
*-----------------------------------------------------------------------*
.next:	move.w		-(a0),d0
	pushall
	jsr		Remove_block
	popall
	subq		#1,BLOCKTRACK_COUNT
	bne.s		.next
*-----------------------------------------------------------------------*
	move.l		a0,BLOCKTRACK_PTR
*-----------------------------------------------------------------------*
.rts:	rts

*-----------------------------------------------------------------------*
*	Block memory transfer primitives				*
*-----------------------------------------------------------------------*

*-------------------------------------------------------*
memcpy:
*-------------------------------------------------------*
memcpy_a0_a1_d0:
*-------------------------------------------------------*
	addq.b		#1,BUSY
*-------------------------------------------------------*
	movem.l		d0-d1/a0-a1,-(sp)	
*-------------------------------------------------------*
	tst.l		d0
	ble		.copy_complete
*-------------------------------------------------------*
	cmp.l		a0,a1
	bhi		.down_copy
*-------------------------------------------------------*
	beq		.copy_complete
*-------------------------------------------------------*
.up_copy:
*-------------------------------------------------------*
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_cliplong_up
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong_up:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.pre_up_0
	move.b		(a0)+,(a1)+
.pre_up_0:
	lsr.l		d1
	bcc.s		.pre_up_1
	move.w		(a0)+,(a1)+
.pre_up_1:
	dbra		d1,.pre_up_loop
	bra.s		.pre_up_done
.pre_up_loop:
	move.l		(a0)+,(a1)+
	dbra		d1,.pre_up_loop
.pre_up_done:
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	move.l		d0,d1
	and.w		#-16,d1
	beq.s		.up_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.up_transfer:
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	subq.l		#1,d1
	bne.s		.up_transfer
.up_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	dbra		d1,.post_up_loop
	bra.s		.post_up_done
.post_up_loop:
	move.l		(a0)+,(a1)+
	dbra		d1,.post_up_loop
.post_up_done:
	bclr		#1,d0
	beq.s		.post_up_1
	move.w		(a0)+,(a1)+
.post_up_1:
	bclr		#0,d0
	beq.s		.post_up_0
	move.b		(a0)+,(a1)+
.post_up_0:
*-------------------------------------------------------*
	bra		.copy_complete
*-------------------------------------------------------*
.down_copy:
*-------------------------------------------------------*
	add.l		d0,a0
	add.l		d0,a1
*-------------------------------------------------------*
	move.l		a0,d1
	and.l		#16-1,d1
	sub.l		d1,d0
	bpl.s		.no_cliplong_down
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong_down:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.pre_down_0
	move.b		-(a0),-(a1)
.pre_down_0:
	lsr.l		d1
	bcc.s		.pre_down_1
	move.w		-(a0),-(a1)
.pre_down_1:
	dbra		d1,.pre_down_loop
	bra.s		.pre_down_done
.pre_down_loop:
	move.l		-(a0),-(a1)
	dbra		d1,.pre_down_loop
.pre_down_done:
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	move.l		d0,d1
	and.w		#-16,d1
	beq.s		.down_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.down_transfer:
	move.l		-(a0),-(a1)
	move.l		-(a0),-(a1)
	move.l		-(a0),-(a1)
	move.l		-(a0),-(a1)
	subq.l		#1,d1
	bne.s		.down_transfer
.down_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	dbra		d1,.post_down_loop
	bra.s		.post_down_done
.post_down_loop:
	move.l		-(a0),-(a1)
	dbra		d1,.post_down_loop
.post_down_done:
	bclr		#1,d0
	beq.s		.post_down_1
	move.w		-(a0),-(a1)
.post_down_1:
	bclr		#0,d0
	beq.s		.post_down_0
	move.b		-(a0),-(a1)
.post_down_0:
*-------------------------------------------------------*
.copy_complete:
*-------------------------------------------------------*
	movem.l		(sp)+,d0-d1/a0-a1
*-------------------------------------------------------*
	subq.b		#1,BUSY
*-------------------------------------------------------*
	rts


*-------------------------------------------------------*
memclr:
*-------------------------------------------------------*
	clr.l		d1
*-------------------------------------------------------*
memset_a0_d0_d1:
*-------------------------------------------------------*
	addq.b		#1,BUSY
*-------------------------------------------------------*
	movem.l		d0-d2/a0,-(sp)
*-------------------------------------------------------*
	move.l		d1,d2
*-------------------------------------------------------*
.long_fill:
*-------------------------------------------------------*
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_cliplong
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.prelong_0
	move.b		d2,(a0)+
.prelong_0:
	lsr.l		d1
	bcc.s		.prelong_start
	move.w		d2,(a0)+
	bra.s		.prelong_start
.prelong_loop:
	move.l		d2,(a0)+
.prelong_start:
	dbra		d1,.prelong_loop
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	moveq		#-16,d1
	and.l		d0,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.long_transfer:
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	subq.l		#1,d1
	bne.s		.long_transfer
.long_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	bra.s		.postlong_start
.postlong_loop:
	move.l		d2,(a0)+
.postlong_start:
	dbra		d1,.postlong_loop
.postlong_done:
	bclr		#1,d0
	beq.s		.postlong_1
	move.w		d2,(a0)+
.postlong_1:
	bclr		#0,d0
	beq.s		.postlong_0
	move.b		d2,(a0)+
.postlong_0:
*-------------------------------------------------------*
	movem.l		(sp)+,d0-d2/a0
*-------------------------------------------------------*
	subq.b		#1,BUSY
*-------------------------------------------------------*
	rts

*-----------------------------------------------------------------------*
			data
*-----------------------------------------------------------------------*

fastmemonly_code:		dc.b	VRAM_preferred
fastmempref_code:		dc.b	VRAM_preferred
virtmempref_code:		dc.b	VRAM_preferred
				even
				
*-----------------------------------------------------------------------*
			bss
*-----------------------------------------------------------------------*

STRAM_USED:		ds.l	1
STRAM_FREE:		ds.l	1
VRAM_USED:		ds.l	1
VRAM_FREE:		ds.l	1

*-----------------------------------------------------------------------*
			text
*-----------------------------------------------------------------------*
