		text
;=========================================================================
;	;A0 = address of root tree
;	;D0 = Page Size
; This routine uses bintohex and bintodec

dump_mmu_tree:	movem.l	d0-a6,-(sp)

		move.l	a0,.root_table
		move.w	d0,.page_size
		clr.l	valid_rootd
		clr.l	valid_pointerd
		clr.l	valid_paged

		pea	.dump_it
		move.w	#38,-(sp)
		trap	#14
		addq.l	#6,sp

		lea	number(pc),a0
		move.l	valid_rootd,d0
		bsr	bintodec
		lea	valid_rootd_m(pc),a6
		bsr	print_a0

		move.l	valid_pointerd(pc),d0
		lea	valid_pntrd_m(pc),a6
		bsr	bintodec
		bsr	print_a0

		move.l	valid_paged(pc),d0
		lea	valid_paged_m(pc),a6
		bsr	bintodec
		bsr	print_a0

		movem.l	(sp)+,d0-a6
		rts

		bss
.root_table:	ds.l 1
.page_size:	ds.w 1
		text

;---  Dump Routine starts here ---
; Constant registers..
;	D5 = Page size.

.dump_it:	move.l	.root_table,a2
		moveq	#0,d5
		move.w	.page_size,d5
		clr.l	la
		moveq	#127,d3			;Number of root level descriptors

.test:		move.l	(a2)+,d0

		move.b	d0,d7
		and.b	#2,d7
		beq.s	.no_pointer

		move.l	d0,d7

		and.l	#msk_pnttab_addr,d0
		lea	prnt_root(pc),a6
		lea	number(pc),a0
		bsr	bintohex
		bsr	print_a0_nc

		btst	#d_used,d7
		beq.s	.not_used
		lea	used_m(pc),a6
		bsr	print_a6
.not_used:	btst	#d_writeprotect,d7
		beq.s	.no_wp
		lea	wp_m(pc),a0
		bsr	print_a6

.no_wp:		lea	null(pc),a6
		move.l	a6,a0
		bsr	print_a0

		move.l	d0,a3
		bsr	print_pointer_table
		addq.l	#1,valid_rootd
		dbra	d3,.test
		bra.s	.exit

.no_pointer:	lea	prnt_root(pc),a6
		lea	invalid_m(pc),a0
		bsr	print_a0
		lea	number(pc),a0
		add.l	#1<<25,la
		dbra	d3,.test

.exit:		rts

	;Table to print in A3
print_pointer_table:
		movem.l	d0-a6,-(sp)

		moveq	#127,d3

.prnt_pt:	move.l	(a3)+,d0
		move.b	d0,d7
		and.b	#2,d7
		beq.s	.no_page

		move.l	d0,d7

		cmp.w	#8192,d5
		beq.s	.8k_page		
.4k_page:	and.l	#msk_4kpt_addr,d0
		bra.s	.ok
.8k_page:	and.l	#msk_8kpt_addr,d0

.ok:		lea	number(pc),a0
		lea	prnt_point(pc),a6
		bsr	bintohex
		bsr	print_a0_nc

		btst	#d_used,d7
		beq.s	.not_used
		lea	used_m(pc),a6
		bsr	print_a6
.not_used:	btst	#d_writeprotect,d7
		beq.s	.no_wp
		lea	wp_m(pc),a0
		bsr	print_a6

.no_wp:		lea	null(pc),a6
		move.l	a6,a0
		bsr	print_a0

		move.l	d0,a4
		bsr	print_page_table
		addq.l	#1,valid_pointerd
		dbra	d3,.prnt_pt
		bra.s	.exit

.no_page:	lea	prnt_point(pc),a6
		lea	invalid_m(pc),a0
		bsr	print_a0
		add.l	#1<<18,la
		dbra	d3,.prnt_pt

.exit:		movem.l	(sp)+,d0-a6
		rts

	;A4 = table
print_page_table:
		movem.l	d0-a6,-(sp)

		cmp.w	#8192,d5
		beq.s	.8kp

.4kp:		moveq	#63,d3
		move.l	#msk_4kpd_paddr,d4
		bra.s	.prnt_pt

.8kp:		moveq	#31,d3
		move.l	#msk_8kpd_paddr,d4

.prnt_pt:
		move.l	(a4)+,d0
		move.l	d0,d7
		and.b	#3,d7
		beq	.no_page

		cmp.b	#2,d7
		bne.s	.not_indir
		move.l	d0,d7
		and.l	#-4,d0
		lea	number(pc),a0
		lea	indirect_m(pc),a6
		bsr	print_a0_nc
		move.l	d0,a0
		move.l	(a0),d0
		move.b	d0,d7
		and.b	#3,d7
		beq	.no_page

.not_indir:	move.l	d0,d7
		and.l	d4,d0

		lea	number(pc),a0
		move.l	d0,d6
		lea	p_log_addr,a6
		move.l	la,d0
		bsr	bintohex
		bsr	print_a0_nc

		move.l	d6,d0
		lea	p_phys_addr,a6
		bsr	bintohex
		bsr	print_a0_nc

		move.l	d7,d0
		lsr.w	#d_cache_pos-2,d0
		and.l	#%1100,d0
		lea	cachmode(pc),a6
		move.l	(a6,d0.l),a6
		bsr	print_a6

		btst	#d_used,d7
		beq.s	.not_used
		lea	used_m(pc),a6
		bsr	print_a6
.not_used:	btst	#d_writeprotect,d7
		beq.s	.no_wp
		lea	wp_m(pc),a6
		bsr	print_a6
.no_wp:		btst	#d_modified,d7
		beq.s	.no_mod
		lea	modified_m(pc),a6
		bsr	print_a6
.no_mod:	btst	#d_super,d7
		beq.s	.no_super
		lea	super_m(pc),a6
		bsr	print_a6
.no_super:	btst	#d_global,d7
		beq.s	.no_glob
		lea	global_m(pc),a6
		bsr	print_a6

.no_glob:	lea	null(pc),a0
		move.l	a0,a6
		bsr	print_a0

		add.l	d5,la
		addq.l	#1,valid_paged
		dbra	d3,.prnt_pt
		bra.s	.exit

.no_page:	lea	invalid_m(pc),a0
		lea	p_pagtab(pc),a6
		bsr	print_a0
		add.l	d5,la
		dbra	d3,.prnt_pt

.exit:		movem.l	(sp)+,d0-a6
		rts


;------------------------------------------------------------
print_a0:	movem.l	d0-a6,-(sp)

		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp),d0-a6

		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		pea	crlf
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

	;	subq.w	#1,count
	;	bne.s	.exit

	;	move.w	#7,-(sp)
	;	trap	#1
	;	addq.l	#2,sp

	;	move.w	counts,count

.exit:		movem.l	(sp)+,d0-a6
		rts

print_a0_nc:	movem.l	d0-a6,-(sp)

		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp),d0-a6
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

	;	pea	crlf
	;	move.w	#9,-(sp)
	;	trap	#1
	;	addq.l	#6,sp

	;	subq.w	#1,count
	;	bne.s	.exit

	;	move.w	#7,-(sp)
	;	trap	#1
	;	addq.l	#2,sp
		
	;	move.w	counts,count

.exit:		movem.l	(sp)+,d0-a6
		rts

print_a6:	movem.l	d0-a6,-(sp)

		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp)+,d0-a6
		rts

		data

prnt_root:	dc.b "Root table --> ",0
prnt_point:	dc.b "   Pointer table --> ",0
prnt_page:	dc.b "      Page table -----> ",0

indirect_m:	dc.b " INDIRECT ",0

p_phys_addr:	dc.b " Physical -> ",0
p_log_addr:	dc.b "      page table - Logical -> ",0
p_pagtab:	dc.b "      page table - ",0
pstart_tree:	dc.b 13,10," Start address of tree   ------------> ",0
pend_tree:	dc.b " End address of tree ----------------> ",0
psize_tree:	dc.b " Number of bytes taken by the tree --> ",0

valid_rootd_m:	dc.b 13,10," Valid root level descriptors .. -> ",0
valid_pntrd_m:	dc.b " Valid pointer level descriptors -> ",0
valid_paged_m:	dc.b " Valid page level descriptors .  -> ",0

null:		dc.b 0

invalid_m:	dc.b "INVALID ",0
used_m:		dc.b ", Used",0
wp_m:		dc.b ", Writeprotect",0

modified_m:	dc.b ", Modified",0
super_m:	dc.b ", Super",0
global_m:	dc.b ", Global",0

cm_wt_m:	dc.b ", WriteTrhough",0
cm_cp_m:	dc.b ", CopyBack",0
cm_p_m:		dc.b ", Precise",0
cm_i_m:		dc.b ", Imprecise",0

crlf:		dc.b 13,10,0
number:		ds.b 100


	even
valid_rootd:	dc.l 0
valid_pointerd:	dc.l 0
valid_paged:	dc.l 0

cachmode:	dc.l cm_wt_m,cm_cp_m,cm_p_m,cm_i_m
la:		dc.l 0

count:		dc.w 20
counts:		dc.w 20


