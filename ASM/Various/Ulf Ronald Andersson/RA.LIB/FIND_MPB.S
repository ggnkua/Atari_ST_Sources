;----------------------------------------------------------------------------
;File name:	FIND_MPB.S			Revision date:	1998.08.21
;Created by:	Ulf Ronald Andersson		Creation date:	1992.02.03
;----------------------------------------------------------------------------
;should be included in TEXT section of program,
;somewhere behind the entry routines.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	FIND_MPB_defined
FIND_MPB_defined	set	1
;----------------------------------------------------------------------------
	include	RA_SYS.I
;----------------------------------------------------------------------------
MPB_BLK_1_SIZE	=	$1230
;----------------------------------------------------------------------------
MPB_p:			dc.l	0
;----------------------------------------------------------------------------
;find_mpb(new_run_p) => a0 = d0 = -> MPB vector pair (or NULL)
;
find_mpb:
	move.l		MPB_p(pc),a0
	move.l		a0,d0
	bne		.exit_direct
;
	lv_init		a6
	movem.l		d1-d7/a1-a5,-(sp)
;
	lv_arg.l	MPB_new_run_p
;
	lv_var.l	MPB_run_p_p
	lv_var.l	MPB_old_run_p
	lv_var.l	MPB_blk_1_ptr
	lv_var.l	MPB_blk_2_ptr
	lv_var.l	MPB_blk_2_min
	lv_var.l	MPB_blk_2_max
	lv_var.l	MPB_pot_MD
	lv_var.l	MPB_pot_MPB
	lv_var.w	MPB_blk_2_free
	lv_var.w	MPB_themd_used
	lv_var.w	MPB_themd_free
;
	clr.l		MPB_blk_1_ptr(a6)
	clr.l		MPB_blk_2_ptr(a6)
;
	move.l		(_membot).w,a4		;a4 = start of main TPA
	move.l		(_memtop).w,d4		;d4 = limit of main TPA
	move.l		a4,a5			;a5 = a4 \/ In case of no
	move.l		d4,d5			;d5 = d4 /\ ALTernate RAM
	cmp.l		#$1357bd13,(ramvalid).w
	bne.s		.done_ALT_RAM
	move.l		(ramtop).w,d0		;d0 = end of ALT TPA (but possibly NULL)
	beq.s		.done_ALT_RAM
	move.l		#$01000000,a5		;a5 = start of ALT TPA
	move.l		(ramtop).w,d5		;d5 = end of ALT TPA
.done_ALT_RAM:
	move.l		(_sysbase).w,a0		;a0 -> active TOS header
	move.l		os_selfbeg_p(a0),a0	;a0 -> original TOS header
	cmpi.w		#$102,os_version(a0)
	blo.s		.old_tos_1
	move.l		os_currbp_p_p(a0),a1
	bra.s		.have_curr_bp_p_p
;
.old_tos_1:
	move.w		os_config(a0),d0
	asr.w		#1,d0
	subq.w		#4,d0
	bne.s		.old_tos_2
	move.l		#$873c,a1
	bra.s		.have_curr_bp_p_p
;
.old_tos_2:
	move.l		#$602c,a1
.have_curr_bp_p_p:
	move.l		a1,MPB_run_p_p(a6)	;store MPB_run_p_p
	move.l		(a1),MPB_old_run_p(a6)
	tst.l		MPB_new_run_p(a6)
	bne.s		.have_new_run_p
	move.l		(a1),MPB_new_run_p(a6)
.have_new_run_p:
;
	move.l		os_varend_p(a0),d3	;d3 = limit for MPB search
	move.l		#$800,a3		;a3 = OS area start for MD/MPB search
;
	move.l		MPB_run_p_p(a6),a0	;a0 -> run_p
	move.l		MPB_new_run_p(a6),(a0)	;patch run_p
	gemdos		Malloc,#MPB_BLK_1_SIZE
	move.l		MPB_run_p_p(a6),a0	;a0 -> run_p
	move.l		MPB_old_run_p(a6),(a0)	;restore run_p
	move.l		d0,MPB_blk_1_ptr(a6)
	ble		.exit
;
	move.l		MPB_run_p_p(a6),a0	;a0 -> run_p
	move.l		MPB_new_run_p(a6),(a0)	;patch run_p
	gemdos		Malloc,?
	move.l		d0,d7
	ble.s		.done_blk_2
	move.l		d7,MPB_blk_2_min(a6)
	move.l		d7,MPB_blk_2_max(a6)
	gemdos		Malloc,d7
	tst.l		d0
	bgt.s		.fix_blk_2
	sub.l		#16,d7
	move.l		d7,MPB_blk_2_min(a6)
	gemdos		Malloc,d7
.fix_blk_2:
	move.l		d0,d7
	ble.s		.done_blk_2
	gemdos		Mfree|_ind,d7
	move.l		d7,d0
.done_blk_2:
	move.l		MPB_run_p_p(a6),a0	;a0 -> run_p
	move.l		MPB_old_run_p(a6),(a0)	;restore run_p
	move.l		d0,MPB_blk_2_ptr(a6)
	ble		.exit_release
;
	lea.l		-2(a3),a1		;a1 -> failed MD dummy below OS area
	move.l		a1,MPB_pot_MD(a6)	;store this as start value
.find_used_MD_lp1:
	move.l		MPB_blk_1_ptr(a6),a2	;a2 -> blk_1
	move.l		#MPB_BLK_1_SIZE,d2	;d2 = blk_1 size
	move.l		MPB_pot_MD(a6),a1	;a1 -> last failed MD
	clr		MPB_themd_used(a6)
.find_used_MD_lp2:
	addq		#2,a1			;a1 -> next pot MD
	lea		15(a1),a0		;a0 -> last byte of pot MD
	cmpa.l		d4,a0			;MD end > main TPA end ?
	bhs		.exit_release		;exit if a1 outside legal areas
	cmpa.l		a4,a1			;MD inside main TPA ?
	bhs.s		.pot_used_MD_ok		;go keep MD if in main TPA
	cmpa.l		(end_os).w,a0		;MD inside OS RAM ?
	blo.s		.pot_used_MD_ok		;go keep MD if in OS RAM
	lea.l		(a4),a1			;a1 -> main TPA start
.pot_used_MD_ok:
	move.l		4(a1),d0		;d0 = data ptr
	bclr		#0,d0			;some ptrs are masked in bit 0 !
	cmpa.l		d0,a2			;does data ptr point at our blk_1
	bne.s		.find_used_MD_lp2	;loop until valid pointer to blk_1
	move.l		8(a1),d0		;d0 = size field of pot MD
	cmp.l		d2,d0			;check size against minimum
	bne.s		.find_used_MD_lp2	;loop if size wrong
	move.l		12(a1),d0		;d0 = owner pid field of pot MD
	cmp.l		MPB_new_run_p(a6),d0	;correct owner ?
	bne.s		.find_used_MD_lp2	;loop on wrong owner
	move.l		(a1),d0			;d0 = link field of pot MD
	beq.s		.have_pot_MD		;zero link is valid => MD valid
	btst		#0,d0			;odd link ?
	bne.s		.find_used_MD_lp2	;loop until even link in pot MD
	cmp.l		#(themd),d0		;check for (themd)
	beq.s		.have_pot_MD		;(themd) is valid
	cmp.l		d4,d0			;link > main TPA end ?
	bhs.s		.find_used_MD_lp2	;loop if link too high
	cmp.l		a4,d0			;link in main TPA area ?
	bhs.s		.have_pot_MD		;main TPA links are valid
	cmp.l		(end_os).w,d0		;link > OS RAM end ?
	bhs.s		.find_used_MD_lp2	;loop if link too high
	cmp.l		a3,d0			;link > OS variable start ?
	blo.s		.find_used_MD_lp2	;loop if link too low
.have_pot_MD:
	move.l		a1,MPB_pot_MD(a6)	;save -> new pot MD for long_term ref
	move		#1000-1,d7		;max 1000 loops
.test_used_MD_lp:
	move.l		(a1)+,a0		;a0 = link ptr
	move.l		(a1)+,d0		;d0 = data ptr
	move.l		d0,d6			;save for later
	bclr		#0,d0			;special fix for ALT TPA mapping
	move.l		d0,d1
	add.l		(a1)+,d1		;d1 -> data end
	bcs		.find_used_MD_lp1	;scrap MD on overflow block
	btst		#0,d1			;was the size odd ?
	bne		.find_used_MD_lp1	;scrap MD on odd data size
	subq.l		#1,d1			;d1 -> last data byte
	cmp.l		d5,d1			;block > ALT TPA end ?
	bhs		.find_used_MD_lp1	;scrap MD if block too high
	cmp.l		a5,d0			;block in ALT TPA ?
	bhs.s		.used_block_ok		;ALT TPA blocks are valid
	btst		#0,d6			;odd ptr ?
	bne		.find_used_MD_lp1	;scrap MD on odd ptr outside ALT TPA
	cmp.l		d4,d1			;block > main TPA end
	bhs		.find_used_MD_lp1	;scrap MD on block between valid TPAs
	cmp.l		a4,d0			;block in main TPA area
	bhs.s		.used_block_ok		;main TPA blocks are valid
	cmp.l		(end_os).w,d1		;block > OS area end ?
	bhs		.find_used_MD_lp1	;scrap MD on block between OS and TPA area
	cmp.l		a3,d0			;block in OS area ?
	blo		.find_used_MD_lp1	;scrap MD on block below OS area
.used_block_ok:
	move.l		(a1)+,d0		;d0 = owner pid
	btst		#0,d0			;odd owner ?
	bne		.find_used_MD_lp1	;scrap MD on odd owner
	move.l		a0,d0			;d0 = link to next list level
	beq.s		.used_list_scanned	;if it is NULL this scan is completed
	move.l		d0,a1			;this will be list ptr at that level
	btst		#0,d0			;odd link ?
	bne		.find_used_MD_lp1	;scrap MD on odd link
	cmp.l		#(themd),d0		;check for (themd)
	bne.s		.not_used_themd		;it is okay not to find it here too
	addq		#1,MPB_themd_used(a6)	;increment usage count (only once on valid MPB)
	bra.s		.test_used_MD_next	;loop back to test next list entry
;
.not_used_themd:
	cmp.l		d4,d0			;link > main TPA end ?
	bhs		.find_used_MD_lp1	;scrap MPB if link to high
	cmp.l		a4,d0			;link in main TPA area ?
	bhs.s		.test_used_MD_next	;main TPA links are valid
	cmp.l		(end_os).w,d0		;link > OS RAM end ?
	bhs		.find_used_MD_lp1	;loop if link too high
	cmp.l		a3,d0			;link > OS variable start ?
	blo		.find_used_MD_lp1	;loop if link too low
.test_used_MD_next:
	dbra		d7,.test_used_MD_lp	;loop back for more tests unless too deep
	bra		.find_used_MD_lp1	;scrap MD on list depth overflow
;
.used_list_scanned:				;'used' list processing complete
	move.l		d3,a1
	lea		-6(a1),a1		;a1 -> failed MPB dummy at end of OS variables
	move.l		a1,MPB_pot_MPB(a6)	;store this as start value
.find_used_MPB_lp1:
	move.l		MPB_pot_MD(a6),a2	;a2 -> MD to seek
	move.l		MPB_pot_MPB(a6),a1	;a1 -> last failed MPB
	clr		MPB_blk_2_free(a6)
	clr		MPB_themd_free(a6)
.find_used_MPB_lp2:
	subq		#2,a1			;a1 -> next potential MPB
	cmpa.l		a3,a1			;MPB below OS variables ?
	blo		.find_used_MD_lp1	;loop back to get a valid MPB 
	cmp.l		4(a1),a2		;does 'used' list point at our MD
	bne.s		.find_used_MPB_lp2	;loop until valid pointer to MD
	move.l		(a1),d0			;d0 = free_list ptr of pot MPB
	beq.s		.find_used_MPB_lp2	;loop until free_list ptr exists
	btst		#0,d0			;odd list ptr
	bne.s		.find_used_MPB_lp2	;loop until free_list ptr is even
	cmp.l		#(themd),d0		;check for (themd)
	beq.s		.have_pot_MPB		;(themd) is valid
	cmp.l		d4,d0			;list ptr > main TPA end ?
	bhi.s		.find_used_MPB_lp2	;loop if list ptr too high
	cmp.l		a4,d0			;list ptr in main TPA area ?
	bhs.s		.have_pot_MPB		;main TPA list ptr is valid
	cmp.l		(end_os).w,d0		;list ptr > OS RAM end ?
	bhs.s		.find_used_MPB_lp2	;loop if list ptr too high
	cmp.l		a3,d0			;list ptr > OS variable start ?
	blo.s		.find_used_MPB_lp2	;loop if list ptr too low
.have_pot_MPB:
	move.l		a1,MPB_pot_MPB(a6)	;save -> new pot MPB for long_term ref
	move.l		(a1),a1			;a1 -> first MD in free_list
	move.l		MPB_blk_2_ptr(a6),a2	;a2 -> blk_2
	move.l		MPB_blk_2_min(a6),d2	;d2 =  min size
	move		#1000-1,d7		;max 1000 loops
.test_used_MPB_lp:
	move.l		(a1)+,a0		;a0 = link ptr
	move.l		(a1)+,d0		;d0 = data ptr
	bclr		#0,d0			;special fix for ALT TPA mapping
	move.l		d0,d1
	add.l		(a1)+,d1		;d1 -> data end
	bcs		.find_used_MPB_lp1	;scrap MPB on overflow block
	btst		#0,d1			;was the size odd ?
	bne		.find_used_MPB_lp1	;scrap MPB on odd data size
	subq.l		#1,d1			;d1 -> last data byte
	cmp.l		d5,d1			;block > ALT TPA end ?
	bhs		.find_used_MPB_lp1	;scrap MPB if block too high
	cmp.l		a5,d0			;block in ALT TPA ?
	bhs.s		.free_block_ok		;ALT TPA blocks are valid
	btst		#0,-5(a1)		;was data ptr odd ?
	bne		.find_used_MPB_lp1	;scrap MPB on odd ptr outside ALT TPA
	cmp.l		d4,d1			;block > main TPA end
	bhs		.find_used_MPB_lp1	;scrap MPB on block between valid TPAs
	cmp.l		a4,d0			;block in main TPA area
	bhs.s		.free_block_ok		;main TPA blocks are valid
	cmp.l		(end_os).w,d1		;block > OS area end ?
	bhs		.find_used_MPB_lp1	;scrap MPB on block between OS and TPA area
	cmp.l		a3,d0			;block in OS area ?
	blo		.find_used_MPB_lp1	;scrap MPB on block below OS area
.free_block_ok:
	cmp.l		a2,d0			;is this blk_2 ?
	bne.s		.done_free_block	;if not, that's okay too
	add.l		d2,d0
	subq.l		#1,d0			;d0 -> last requested byte of blk_2
	cmp.l		d0,d1			;free_merged size may be higher though
	blo		.find_used_MPB_lp1	;loop until block has sufficient size
	addq		#1,MPB_blk_2_free(a6)	;increment usage count (only once on valid MPB)
.done_free_block:
	move.l		(a1)+,d0		;d0 = owner pid
	btst		#0,d0			;odd owner ?
	bne		.find_used_MPB_lp1	;scrap MPB on odd owner
	move.l		a0,d0			;d0 = link to next list level
	beq.s		.free_list_scanned	;if it is NULL this scan is completed
	move.l		d0,a1			;this will be list ptr at that level
	btst		#0,d0			;odd link ?
	bne		.find_used_MPB_lp1	;scrap MPB on odd link
	cmp.l		#(themd),d0		;check for (themd)
	bne.s		.not_free_themd		;it is okay not to find it here too
	addq		#1,MPB_themd_free(a6)	;increment usage count (only once on valid MPB)
	bra.s		.test_used_MPB_next	;loop back to test next list entry
;
.not_free_themd:
	cmp.l		d4,d0			;link > main TPA end ?
	bhs		.find_used_MPB_lp1	;scrap MPB if link to high
	cmp.l		a4,d0			;link in main TPA area ?
	bhs.s		.test_used_MPB_next	;main TPA links are valid
	cmp.l		(end_os).w,d0		;link > OS RAM end ?
	bhs		.find_used_MPB_lp1	;loop if link too high
	cmp.l		a3,d0			;link > OS variable start ?
	blo		.find_used_MPB_lp1	;loop if link too low
.test_used_MPB_next:
	dbra		d7,.test_used_MPB_lp	;loop back for more tests unless too deep
	bra		.find_used_MPB_lp1	;scrap MPB on list depth overflow
;
.free_list_scanned:				;'used' list processing complete
	move		MPB_themd_used(a6),d0	;d0  = found themd refs in 'used' list
	add		MPB_themd_free(a6),d0	;d0 += found themd refs in 'free' list
	cmp		#1,d0			;total themd refs = 1 ?
	bne		.find_used_MPB_lp1	;scrap MPB on bad themd reference count
	cmp		#1,MPB_blk_2_free(a6)	;'used' blk_1 refs = 1 ?
	bne		.find_used_MPB_lp1	;scrap MPB on bad blk_1 reference count
.exit_ok:
	move.l		MPB_pot_MPB(a6),MPB_p
.exit_release:
	move.l		MPB_blk_1_ptr(a6),d0
	ble.s		.done_blk_1
	gemdos		Mfree|_ind,d0
.done_blk_1:
.exit:
	movem.l		(sp)+,d1-d7/a1-a5
	lv_exit		a6
	move.l		MPB_p,d0		;d0 = pointer/NULL flagged NE/EQ
	move.l		d0,a0			;return same value in a0
.exit_direct:
	rts
;------------------------------------
end_find_MPB:		;limit scope of assembly-time local variables
;----------------------------------------------------------------------------
	endc	;FIND_MPB_defined
;----------------------------------------------------------------------------
;	end of file:	FIND_MPB.S
;----------------------------------------------------------------------------
