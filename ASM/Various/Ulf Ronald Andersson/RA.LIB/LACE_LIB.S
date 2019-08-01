;----------------------------------------------------------------------------
;File name:	LACE_LIB.S			Revised:	1998.08.17
;Author:	Ulf Ronald Andersson		Created:	1992.02.08
;Purpose:	LaceScan screen driver support
;----------------------------------------------------------------------------
;Remarks:
;	The subroutines here are identical to some in LaceScan version 3.1,
;	and may only be used in supervisor mode.
;----------------------------------------------------------------------------
;	The following subroutines are defined
;
;block_ikbd		disable communication with IKBD processor
;release_ikbd		re_enable communication with IKBD processor
;small_lace_supx	disables overscan mode using KB_ACIA RTS
;large_lace_supx	enables overscan mode using KB_ACIA RTS
;test_size_supx		flags HI in overscan mode and sets lacesize_f=(00:normal  FF:overscan)
;sync_lace_supx		resynchronizes overscan mode and sets lacesize_f like above
;sync_fall_supx		awaits V_sync and sets lacesize_f like above
;----------------------------------------------------------------------------
;	The following variables are defined (using _unilab to avoid doubles)
;
;lacesize_f	word	flags overscan mode in high byte (low byte unused)
;lacebase_pg	word	screen_base_address/256 from hardware
;
;	The following variable is required to be set up by main program
;
;VDO_rez_mask	word	3 on ST/STE system, 7 on TT
;
;	The main program must also provide two routines as specified below
;
;set_rez_sub:	this must setup hardware according to a normal 'getrez' code
;get_rez_sub:	this must 'decode' hard rez into a normal 'getrez' code
;
;The 'getrez' code is passed in d0 into set_rez_sub and out of get_rez_sub.
;The purpose of this is to allow future compatibility beyond ST/STE/TT...
;----------------------------------------------------------------------------
	ifnd	LACE_LIB_defined
LACE_LIB_defined	set	1
;
	include	RA_SYS.I
;----------------------------------------------------------------------------
block_ikbd:
	move	SR,-(sp)
	or	#$0700,SR	;disable interrupts
.wait_loop_1:
	btst	#1,(hw_KB_cont).w
	beq.s	.wait_loop_1
	move.b	#19,(hw_KB_data).w
.wait_loop_2:
	btst	#1,(hw_KB_cont).w
	beq.s	.wait_loop_2
	move	(sp)+,SR	;re_enable interrupts
	rts
;------------------------------------
release_ikbd:
	move	SR,-(sp)
	or	#$0700,SR	;disable interrupts
.wait_loop_1:
	btst	#1,(hw_KB_cont).w
	beq.s	.wait_loop_1
	move.b	#17,(hw_KB_data).w
.wait_loop_2:
	btst	#1,(hw_KB_cont).w
	beq.s	.wait_loop_2
	move	(sp)+,SR	;re_enable interrupts
	rts
;------------------------------------
test_size_supx:
	bsr.s	sync_fall_supx
	bsr.s	sync_fall_supx
	shi	lacesize_f
	rts
;------------------------------------
small_lace_supx:
	move.b	#$96,(hw_KB_cont).w
	rts
;------------------------------------
large_lace_supx:
	move.b	#$D6,(hw_KB_cont).w
	rts
;------------------------------------
sync_lace_supx:
	bsr.s	sync_fall_supx
	bsr.s	sync_force_supx
	shi	lacesize_f
	rts
;------------------------------------
sync_fall_supx:				;affects no registers except CCR
	movem.l	d0-d2/a0,-(sp)
	suba.l	a0,a0
	move	SR,d2
	bsr	sub_sync_supx		;get initial value
	bsr	sub_sync_supx		;await initial change
.retry_lp:				;loop: retry until valid hw_vpos fall
	movep	hw_vbase2(a0),d0
	move	d0,lacebase_pg
	clr.l	d1
.sync_fall_lp:				;  loop: await hw_vpos fall
	bsr.s	sub_sync_supx		;    await hw_vpos change
	bhs.s	.sync_fall_lp		;  loop] until hw_vpos fall
	move	d2,SR			;  reenable interrupts
	movep	hw_vbase2(a0),d0
	cmp	lacebase_pg,d0
	bne.s	.retry_lp		;loop] retry if hw_vbase invalid (changed)
;
	cmp	#7,VDO_rez_mask
	beq.s	.exit
	cmp	#48*Kb/256,d1
.exit:
	movem.l	(sp)+,d0-d2/a0
	rts	;Exits at fall of hw_vpos with  HI = large screen,  LS = small screen
;------------------------------------
sync_force_supx:			;affects no registers except CCR
	movem.l	d0-d3/a0,-(sp)
	move	SR,d2
	suba.l	a0,a0
	bsr.s	sub_sync_supx		;get initial value
	bsr.s	sub_sync_supx		;await initial change
.retry_lp:				;loop: retry until valid hw_vpos fall
	movep	hw_vbase2(a0),d0
	move	d0,lacebase_pg
	clr.l	d1
.sync_force_lp:				;  loop: await hw_vpos fall
	bsr.s	sub_sync_supx		;    await hw_vpos change
	bhs.s	.sync_force_lp		;  loop] until hw_vpos fall
	bsr	get_rez_sub		;\
	move	d0,d3			; \
	and	#2,d0			;  \
	eor	#2,d0			;   > Double (read + write) should
	bsr	set_rez_sub		;  /  force the shifter to sync
	move	d3,d0			; /
	bsr	set_rez_sub		;/
	move	d2,SR			;  reenable interrupts
	movep	hw_vbase2(a0),d0
	cmp	lacebase_pg,d0
	bne.s	.retry_lp		;loop] retry if hw_vbase invalid (changed)
;
	cmp	#7,VDO_rez_mask
	beq.s	.exit
	cmp	#48*Kb/256,d1
.exit:
	movem.l	(sp)+,d0-d3/a0
	rts	;Exits at fall of hw_vpos with  HI = large screen,  LS = small screen
;------------------------------------
sub_sync_supx:	;entry d1==last_valid_read<<16  d2==SR  a0==NULL
.sub_sync_lp_1:			;loop:
	move	d2,SR		;  enable interrupts
	nop			;  allow interrupt
	or	#$0700,SR	;  disable interrupts
.sub_sync_lp_2:			;  loop:
	movep	hw_vpos2(a0),d0	;    d0 = vpos/256
	movep	hw_vpos2(a0),d1	;    d1 = vpos/256
	cmp	d0,d1		;    valid vpos ?
	bne.s	.sub_sync_lp_2	;  loop] until valid vpos read
	movep	hw_vbase2(a0),d0
	sub	d0,d1		;  d1 = current page number
	move	d1,d0		;  d0 = d1 = page number from vbase
	swap	d1		;  d1.w = previous page number
	cmp	d1,d0		;  flag  LO = fall,  HI = rise
	beq.s	.sub_sync_lp_1	;loop] until new page  (d0 != d1)
	rts	;flags LO after Vsync   d1 = (d0=last_page)<<16 + prev_page
;
;NB: Exit is made with disabled interrupts, each caller must itself reenable
;----------------------------------------------------------------------------
	_unilab	lacesize_f	;define here ONLY if not done previously
	ifne	_uni_flag
	ds.w	1		;00xx = small screen   FFxx = large screen
	endc
	_unilab	lacebase_pg	;define here ONLY if not done previously
	ifne	_uni_flag
	ds.w	1		;page number (corresponding to hw_vbase...)
	endc
;----------------------------------------------------------------------------
	endc	;LACE_LIB_defined
;----------------------------------------------------------------------------
;End of file:	LACE_LIB.S
;----------------------------------------------------------------------------
