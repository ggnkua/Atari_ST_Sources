;----------------------------------------------------------------------------
; File name:	RA_RAM.I			Revision date:	1998.09.11
; Authors:	Ulf Ronald Andersson		Creation date:	1997.10.04
;(c)1997 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sale forbidden)
;----------------------------------------------------------------------------
; Purpose:	Defines RAM allocation routines
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_RAM_defined
RA_RAM_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I
	include	RA_TOS.I
;----------------------------------------------------------------------------
;Library macros:
;
;BASEPG	*RAM_own(int16	flag);			setup RAM_add ownership
;RAMH	*RAM_add(long room);			allocate system RAM block
;RAMH	*RAM_set(char *block, long room);	setup existing RAM block
;char	*R_alloc(long size);			allocate block internally
;void	R_free(char *block);			release block internally
;long	R_getfree(int16 flag);			find max block(1) or total(0) free
;char	*R_realloc(void *block, long size);	reallocate, preserving data
;----------------------------------------------------------------------------
;NB: You must include the following line somewhere after the macro calls
;
;	"make	RAM_links"
;
;NB: That will cause the needed routines to be included at that point.
;NB: You may do this several times (after further calls), and at each
;NB: point only the 'newly' referenced routines will be added to the code.
;NB: A dummy reference macro exists, so routines can be added to code even
;NB: without calling them.  The macro is '_uniref', used as below:
;
;	"_uniref R_alloc"
;----------------------------------------------------------------------------
RAM_links	MACRO
	_unidef	RAM_own
	_unidef	RAM_add
	_unidef	RAM_set
	_unidef	R_getfree
	_unidef	R_realloc
	_unidef	R_alloc
	_unidef	R_free
	_unidef	RAM_root
	ENDM	;RAM_links
;----------------------------------------------------------------------------
;	The RAM header structure and associated constants
;
	struct	RAMH
	struc_p	RAMH_next	;-> next free block, or (RAMH *) RAMH_magic
	long	RAMH_size	;block size
	d_alias	RAMH_data	;data base of block
	d_end	RAMH
;
RAMH_magic	=	'RAMH'
RAMH_round	=	7
RAMH_mask	=	-8
;
;----------------------------------------------------------------------------
;BASEPG	*RAM_own(int16	flag);	0==ignore |n|=>level(n) <0 => Super shift
;
RAM_own	MACRO	flag
	PUREC_func	RAM_own,1,1,\1
	ENDM
;------------------------------------
RAM_own_code	MACRO
RAM_own:
	move	d0,RAM_flag
	bpl.s	.keep_mode_1
	move.l	a2,-(sp)
	gemdos	Super,0.w
	move.l	d0,d2
.keep_mode_1:
	suba.l	a0,a0
	move	RAM_flag(pc),d0
	beq.s	.have_owner
	bpl.s	.keep_sign
	neg	d0
.keep_sign:
	subq	#1,d0			;prep for dbra
	move.l	(_sysbase).w,a1
	move.l	os_selfbeg_p(a1),a1
	move.l	os_currbp_p_p(a1),a1
	move.l	a1,RAM_currbp_p_p
	move.l	(a1),a0			;a0 -> active basepage
	bra.s	.count_level
;
.find_owner_lp:
	move.l	bp_parent_p(a0),d1	;d1 -> parent of current bp
	ble.s	.have_owner
	move.l	d1,a1			;a1 -> parent of current bp
	cmp.l	(a1),a1			;valid selfbeg_p in parent ?
	bne.s	.have_owner		;if not, there is no parent !
	move.l	a1,a0			;current = parent
.count_level:
	dbra	d0,.find_owner_lp	;loop back for correct generation
.have_owner:
	move.l	a0,RAM_owner
	tst	RAM_flag
	bpl.s	.keep_mode_2
	gemdos	Super|_ind,d2
	move.l	(sp)+,a2
.keep_mode_2:
	move.l	RAM_owner(pc),a0
	move.l	a0,d0
	rts
;
RAM_flag:
	dc.w	0
RAM_owner:
	dc.l	0
RAM_currbp_p_p:
	dc.l	0
RAM_latebp_p:
	dc.l	0
;
	ENDM	;RAM_own_code
;----------------------------------------------------------------------------
;RAMH	*RAM_add(long room);
;
RAM_add	MACRO	room
	PUREC_func	RAM_add,1,2,\1
	ENDM
;------------------------------------
RAM_add_code	MACRO
RAM_add:
	addq.l	#RAMH_round,d0		;prep to round up in aligning size
	and.l	#RAMH_mask,d0		;\ return NULL on NULL or negative size
	ble.s	.error			;/ else align the size to sizeof(RAMH)
	cmp.l	#sizeof_RAMH,d0		;\ return NULL on useless size
	ble.s	.error			;/
	movem.l	d0/a2,-(sp)		;protect regs 'room', and a2
	move	RAM_flag(pc),d1
	beq.s	.allocate
	bpl.s	.keep_mode_1
	move.l	a3,-(sp)
	move.l	d0,a3			;a3 = room
	gemdos	Super,0.w
	exg	d0,a3			;a3 = old_SSP  d0 = room
.keep_mode_1:
	move.l	RAM_currbp_p_p(pc),a0
	move.l	(a0),RAM_latebp_p
	move.l	RAM_owner(pc),(a0)
.allocate:
	gemdos Malloc,d0		;call TOS to allocate a RAM block
	move	RAM_flag(pc),d1
	beq.s	.allocated
	move.l	RAM_currbp_p_p(pc),a0
	move.l	RAM_latebp_p(pc),(a0)
	tst	d1
	bpl.s	.keep_mode_2
	exg	d0,a3			;d0 = old_SSP  a3 = result
	gemdos	Super|_ind,d0
	move.l	a3,d0			;d0 = result
	move.l	(sp)+,a3
.keep_mode_2:
.allocated:
	movem.l	(sp)+,d1/a2		;restore regs, but now with d1 as 'room'
	move.l	d0,d2			;\ return NULL on allocation failure
	ble.s	.error			;/
	RAM_set.i	d2,d1		;Call RAM_set to initialize block
	rts				;return RAM_set result to caller
;
.error:
	suba.l	a0,a0			;\/ return( NULL )
	move.l	a0,d0
	rts				;/\
	ENDM	;RAM_add_code
;----------------------------------------------------------------------------
;RAMH	*RAM_set(char *block, long room);
;
RAM_set	MACRO	block,room
	PUREC_func.\0	RAM_set,2,$B,\1,\2
	ENDM
;------------------------------------
RAM_set_code	MACRO
RAM_set:
	move.l	a0,d1			;\ return NULL on NULL or negative base
	ble.s	.error			;/
	btst	#0,d1			;\ return NULL on odd base
	bne.s	.error			;/
	and.l	#RAMH_mask,d0		;\ return NULL on NULL or negative size
	ble.s	.error			;/ else align the size to sizeof(RAMH)
	cmp.l	#sizeof_RAMH,d0		;\ return NULL on useless size
	ble.s	.error			;/
	move.l	#RAMH_magic,(a0)	;block->next = (RAMH *) RAMH_magic
	move.l	d0,RAMH_size(a0)	;block->size = room
	move.l	a0,-(sp)		;protect 'block' pointer
	R_free	RAMH_data(a0)		;release new allocation block
	move.l	(sp)+,a0		;restore 'block' pointer
	move.l	a0,d0
	rts				;and return it to caller
;
.error:
	suba.l	a0,a0			;\/ return( NULL )
	move.l	a0,d0
	rts				;/\
	ENDM	;RAM_set_code
;
;----------------------------------------------------------------------------
;void	R_free(char *block);
;
R_free	MACRO	block
	PUREC_func.\0	R_free,1,3,\1
	ENDM
;------------------------------------
R_free_code	MACRO
	_uniref	RAM_root		;declare internal use of code_RAM_root
R_free:
	subq	#sizeof_RAMH,a0		;back 'block' to presumed RAMH start
	move.l	a0,d0			;Check base address
	ble.s	.exit			;exit on NULL or negative block base
	btst	#0,d0			;\ exit on odd block base
	bne.s	.exit			;/
	cmpi.l	#RAMH_magic,(a0)	;\ exit on error
	bne.s	.exit			;/ in block header
;
	move.l	a2,-(sp)		;protect a2  (used as 'walk')
	lea	RAM_root_block(pc),a2	;walk = &RAM_root_block
.loop:
	move.l	a2,a1			;prev = walk
	move.l	(a1),a2			;walk = prev->next
	move.l	a2,d0			;d0 = not at end of chain yet ?
	beq.s	.skip_merge_walk	;go insert block at end of chain
	cmpa.l	a2,a0			;\/ loop until
	bhs.s	.loop			;/\ block < walk
.try_merge_walk:
	move.l	a0,d1			;\
	add.l	RAMH_size(a0),d1	; \/ merge block to walk if walk ==
	cmp.l	a2,d1			; /\ (RAMH *)((void *)block+block->size)
	bne.s	.skip_merge_walk	;/
.merge_walk:
	move.l	(a2),(a0)		;block->next = walk->next
	move.l	RAMH_size(a2),d1	;\/ block->size += walk->size
	add.l	d1,RAMH_size(a0)	;/\
	bra.s	.done_link_walk		;go to end of 'walk' link handling
;
.skip_merge_walk:
	move.l	a2,(a0)			;block->next = walk
.done_link_walk:
	move.l	(sp)+,a2		;restore a2  (trashes walk)
.try_merge_prev:
	move.l	a1,d1			;\
	add.l	RAMH_size(a1),d1	; \/ merge prev to block if block ==
	cmp.l	a0,d1			; /\ (RAMH *)((void *)prev + prev->size)
	bne.s	.skip_merge_prev	;/
.merge_prev:
	move.l	(a0),(a1)		;prev->next = block->next
	move.l	RAMH_size(a0),d1	;\/ prev->size += block->size
	add.l	d1,RAMH_size(a1)	;/\
	bra.s	.done_link_prev		;go to end of 'prev' link handling
;
.skip_merge_prev:
	move.l	a0,(a1)			;prev->next = block
.done_link_prev:
.exit:
	rts				;return
	ENDM	;R_free_code
;
;----------------------------------------------------------------------------
;long	R_getfree(int16 flag);
;
R_getfree	MACRO	flag
	PUREC_func	R_getfree,1,1,\1
	ENDM
;------------------------------------
R_getfree_code	MACRO
	_uniref	RAM_root		;declare internal use of code_RAM_root
R_getfree:
	move	d0,a1			;save flag in a1
	clr.l	d1			;largest = 0
	clr.l	d2			;total = 0
	lea	RAM_root_block(pc),a0	;walk = &RAM_root_block
.loop:
	move.l	(a0),a0			;walk = walk->next
	move.l	a0,d0			;\ break loop at end of chain
	beq.s	.done_loop		;/
	move.l	RAMH_size(a0),d0	;\ temp = walk->size - sizeof(RAMH)
	subq.l	#sizeof_RAMH,d0		;/
	cmp.l	d0,d1			;\
	bge.s	.done_largest		; > if(largest < temp) largest = temp
	move.l	d0,d1			;/
.done_largest:
	add.l	d0,d2			;total += temp
	bra	.loop
;
.done_loop:
	move.l	d2,d0			;result = total
	move	a1,d2			;test flag stored in a1 above
	beq.s	.exit			;if (!flag)  return total
	move.l	d1,d0			;else return largest
.exit:
	rts
	ENDM	;R_getfree_code
;
;----------------------------------------------------------------------------
;char	*R_alloc(long size);
;
R_alloc	MACRO	size
	PUREC_func	R_alloc,1,2,\1
	ENDM
;------------------------------------
R_alloc_code	MACRO
	_uniref	RAM_root		;declare internal use of code_RAM_root
R_alloc:
	addq.l	#sizeof_RAMH,d0		;reserve header size
	addq.l	#RAMH_round,d0		;\/ round up to nearest
	and.l	#RAMH_mask,d0		;/\ multiple of header size
	ble.s	.error			;exit on zero or erroneous size request
	lea	RAM_root_block(pc),a0	;walk = &RAM_root_block
.loop:
	move.l	a0,a1			;prev = walk
	move.l	(a1),a0			;walk = prev->next
	move.l	a0,d1			;d0 = not at end of chain yet ?
	beq.s	.done_a0		;exit at end of chain
	cmp.l	RAMH_size(a0),d0	;\/ loop until a sufficiently
	bhi.s	.loop			;/\ large block is found
	beq.s	.extract		;go extract block if size precise
.split:
	move.l	a2,-(sp)		;protect a2  (used for 'new')
	lea	(a0,d0.l),a2		;new = (RAMH *)((char *)walk + size)
	move.l	(a0),(a2)		;new->next = walk->next
	move.l	RAMH_size(a0),d1	;\
	sub.l	d0,d1			; > new->size = walk->size - size
	move.l	d1,RAMH_size(a2)	;/
	move.l	d0,RAMH_size(a0)	;walk->size = size
	move.l	a2,(a1)			;prev->next = new
	move.l	(sp)+,a2		;restore a2  (trashes 'new')
	bra.s	.adjust			;adjust allocated block info
;
.extract:
	move.l	(a0),(a1)		;prev->next = walk->next
.adjust:
	move.l	#RAMH_magic,(a0)	;walk->next = (RAMH *) RAMH_magic
	addq	#8,a0			;walk = &walk->data[0]
.done_a0:
	move.l	a0,d0
	rts				;return( walk )
;
.error:
	suba.l	a0,a0			;\/ return( NULL )
	move.l	a0,d0
	rts				;/\
	ENDM	;R_alloc_code
;----------------------------------------------------------------------------
;char	*R_realloc(void *block, long size);
;
R_realloc	MACRO	block,size
	PUREC_func.\0	R_realloc,2,$B,\1,\2
	ENDM
;------------------------------------
R_realloc_code	MACRO
	_uniref	RAM_root		;declare internal use of code_RAM_root
R_realloc:
	move.l	a0,d1			;\ skip base tests if block == NULL
	beq.s	.test_size		;/ 
	subq	#sizeof_RAMH,a0		;back 'block' to presumed RAMH start
	move.l	a0,d0			;Check base address
	ble	.base_error		;return NULL on NULL or negative base
	btst	#0,d0			;\ return NULL on odd base
	bne	.base_error		;/
	cmpi.l	#RAMH_magic,(a0)	;\ return NULL on error
	bne	.base_error		;/ in block header
;
.test_size:
	addq.l	#RAMH_round,d0		;prep to round up in aligning size
	and.l	#RAMH_mask,d0		;align the size to sizeof(RAMH)
	ble	.size_error		;release block on zero or negative size
	tst.l	d1			;was original 'block' NULL
	bne.s	.not_CLR_alloc		;if not, go try normal reallocation
.CLR_alloc:			;here we allocate a new cleared block
	move.l	d0,-(sp)		;protect 'size'
	R_alloc	d0		;call R_alloc(size) to allocate a block
	move.l	d0,a0			;use a0 as 'block'
	move.l	(sp)+,d0		;restore 'size'
	move.l	a0,d1			;test new 'block'
	ble.s	.base_error		;return NULL if allocation failed
	move.l	a0,a1			;temp = &block->data[0]
	lsr.l	#3,d0			;convert 'size' to RAMH units
.CLR_loop:
	clr.l	(a1)+			;\ clear one RAMH sized data unit
	clr.l	(a1)+			;/
	subq.l	#1,d0			;decrement count
	bgt.s	.CLR_loop		;loop back to clear all data units
	bra.s	.return_a0		;return 'block' to caller
;
.not_CLR_alloc:
	move.l	d0,d1			;\ full_size = size + sizeof(RAMH)
	addq.l	#sizeof_RAMH,d1		;/
	cmp.l	RAMH_size(a0),d1	;\ if( full_size > block->size )
	bhi.s	.GROW_realloc		;/   goto .GROW_realloc
	beq.s	.adjust_block		;but if equal just return &work->data[0]
.SHRINK_realloc:		;here we shrink a block and release its tail end
	lea	sizeof_RAMH(a0,d0.l),a1	;new = (RAMH *) &block->data[size]
	move.l	#RAMH_magic,(a1)	;new->next = (RAMH *) RAMH_magic
	move.l	RAMH_size(a0),d2	;\
	sub.l	d1,d2			; > new->size = block->size - full_size
	move.l	d2,RAMH_size(a1)	;/
	move.l	d1,RAMH_size(a0)	;block->size = full_size
	move.l	a0,-(sp)		;protect 'block'
	R_free	RAMH_data(a1)		;RAMfree( new )  to release tail block
	move.l	(sp)+,a0		;restore 'block'
	bra.s	.adjust_block		;go return &work->data[0]
;
.GROW_realloc:			;here we need growth, preferably without rebasing
	move.l	a0,a1			;\ test_base = (RAMH *)
	add.l	RAMH_size(a0),a1	;/   ((void *) block + block->size)
	move.l	d1,d2			;\ test_size = full_size - block->size
	sub.l	RAMH_size(a0),d2	;/
	movem.l	d3/a2/a3,-(sp)		;protect regs d3/a2/a3  (tmp, prev, walk)
	lea	RAM_root_block(pc),a3	;walk = &RAM_root_block
.GROW_loop:
	move.l	a3,a2			;prev = walk
	move.l	(a2),a3			;walk = prev->next
	move.l	a3,d3			;tmp = not at end of chain yet ?
	beq.s	.done_matching		;goto .done_matching at end of chain
	cmp.l	a3,a1			;\ loop back until walk == test_base
	bne.s	.GROW_loop		;/
	sub.l	RAMH_size(a3),d2	;d2 = negative excess, so >0 is failure
	bgt.s	.done_matching		;goto .done_matching at failure
	beq.s	.extract		;go extract block if size precise
.split:
	lea	(a0,d1.l),a1		;new =(RAMH *)((void *)block + full_size)
	move.l	(a3),(a1)		;new->next = walk->next
	move.l	d2,d3			;\
	neg.l	d3			; > new->size = - neg excess from above
	move.l	d3,RAMH_size(a1)	;/
	move.l	a1,(a2)			;prev->next = new
	move.l	d1,RAMH_size(a0)	;block->size = full_size
	bra.s	.done_matching
;
.extract:
	move.l	(a3),(a2)		;prev->next = walk->next
	move.l	d1,RAMH_size(a0)	;block->size = full_size
.done_matching:
	move.l	(sp)+,d3/a2/a3		;restore regs
	tst.l	d2
	ble.s	.adjust_block
.GROW_unmatched:
	move.l	a0,-(sp)		;protect 'block'  (RAMH base)
	R_alloc	d0		;a0 = new_block  (data base)
	move.l	(sp)+,a1		;restore a1 = block
	move.l	a0,d0			;\ go release original on
	ble.s	.grow_error		;/ failed allocation
	movem.l	a0/a1,-(sp)		;protect 'new_block'/'block'
	addq	#sizeof_RAMH,a1		;a1 = &block->data[0]
	move.l	RAMH_size(a1),d0	;d0 = size of old block incl RAMH
	lsr	#3,d0			;convert to RAMH size units
	subq	#1,d0			;reduce by 1 for the header
.copy_loop:
	move.l	(a1)+,(a0)+		;\ copy 1 RAMH unit of data
	move.l	(a1)+,(a0)+		;/
	subq.l	#1,d0			;decrement count
	bgt.s	.copy_loop		;loop back for all old data
	movem.l	(sp),a0/a1		;revive a0/a1 but keep them on stack too
	R_free	RAMH_data(a1)		;R_free( block )
	movem.l	(sp)+,a0/a1		;restore regs
	bra.s	.return_a0
;
.adjust_block:
	addq	#8,a0			;block = &walk->data[0]
.return_a0:
	move.l	a0,d0
	rts				;return( walk )
;
.grow_error:
	move.l		a1,a0		;prep to release original block
.size_error:
	R_free	RAMH_data(a0)		;release block
.base_error:
	suba.l	a0,a0			;\/ return( NULL )
	move.l	a0,d0
	rts				;/\
	ENDM	;R_realloc_code
;----------------------------------------------------------------------------
;RAMH	RAM_root_block = { NULL, sizeof(RAMH) };
;
RAM_root_code	MACRO
	dc.l	'DEAD'		;dummy to ensure RAM_root is never merged
RAM_root_block:
	dc.l	NULL		;initally NULL, later -> added RAM
	dc.l	sizeof_RAMH	;constant ensures RAM_root remains unallocated
	dc.l	'DEAD'		;dummy to ensure RAM_root is never merged
	ENDM	;RAM_root_code
;----------------------------------------------------------------------------
	endc	;RA_RAM_defined
;----------------------------------------------------------------------------
; End of file:	RA_RAM.I
;----------------------------------------------------------------------------
