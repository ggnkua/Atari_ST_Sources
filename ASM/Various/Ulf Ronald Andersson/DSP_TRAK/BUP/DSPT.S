;----------------------------------------------------------------------------
;File name:	DspT.S				Revision date:	1998.03.06
;Created by:	Ulf Ronald Andersson		Creation date:	1997.02.12
;Purpose:	Music module server		Version:	1.3
;----------------------------------------------------------------------------
	output	.PRG
;----------------------------------------------------------------------------
extra_ram	=	0
;----------------------------------------------------------------------------
	section	BSS
init_bss_beg:
	section	DATA
init_data_beg:
	Section	TEXT
init_code_beg:
resident_RAM_beg:	=	init_code_beg-$100
;
rz:
start:
	bra	init_prog
;----------------------------------------------------------------------------
	include	RA_SYS.I
	include	RA_TOS.I
	include	RA_JAR.I
	include	RA_XB.I
	include	XB_subs.S
	include	Mod_Cook.I
;----------------------------------------------------------------------------
;long	_mod_calc(rawmod *module_p)
;long	_mod_s_calc(rawmod *module_p)
;
_mod_calc:
_mod_s_calc:
	cmp.l	#$1000,a0		;Too low ptr ?
	ble.s	.error
	bra	calc_module
;
.error:
	moveq	#E_IMBA,d0
	rts
;
;Ends:	_mod_s_calc
;Ends:	_mod_calc
;----------------------------------------------------------------------------
;mod	*_mod_alloc(long size)
;mod	*_mod_s_alloc(long size)
;
_mod_alloc:
_mod_s_alloc:
	movem.l	d1-d3/a1-a5,-(sp)
	addq.l	#3,d0
	and.l	#-4,d0			;force size to long boundary
	move.l	d0,-(sp)		;push unpadded size
	add.l	#12,d0			;reserve space for DspT header
	add.l	#extra_ram,d0		;add some extra for luck...  ;-)
	move.l	d0,-(sp)		;push offset to workspace end
;
	movea.l	currbp_p_p(pc),a5	;a5 -> -> active process basepage
	movea.l	(a5),a4			;a4 -> active process basepage_p
	move.l	basepage_p(pc),(a5)	;activate own process basepage_p
	move.l	d0,d3			;d3 =  wanted_RAM size
;
	gemdos	Malloc,?		;d0 = free RAM size
	sub.l	#32,d0			;reserve 32 bytes free at top
	ble.s	.test_1
	sub.l	d3,d0			;d0 = unwanted_RAM size
	ble.s	.test_1
	gemdos	Malloc,d0		;allocate unwanted_RAM
	tst.l	d0
	ble.s	.test_1
	move.l	d0,a3			;a3 -> unwanted_RAM
	gemdos	Malloc,d3		;allocate wanted_RAM
	exg	d0,a3			;a3 -> wanted_RAM  d0 -> unwanted_RAM
	gemdos	Mfree|_ind,d0		;release unwanted_RAM
	move.l	a3,d0			;d0 -> wanted_RAM
.test_1:
	move.l	a4,(a5)			;restore -> active process basepage
	movem.l	(sp)+,a0-a1		;a0 = workspace offset  a1 = module size
	exg	a0,a1			;a0 = unpadded size  a1 = workspace offset
	tst.l	d0			;allocation error ?
	ble.s	.error			;exit on error
;
	move.l	d0,a2			;a2 -> new RAM block
	add.l	a2,a1			;a1 -> workspace reference address
	move.l	#DspT_s_c,(a2)+		;store server id in header
	movem.l	a0-a1,(a2)		;store unpadded size and work_p in header
	addq	#8,a2			;a2 -> Module data area
	move.l	a2,d0			;d0 -> Module data area
	bra.s	.exit
;
.error:
	moveq	#E_NSMEM,d0
.exit:
	movem.l	(sp)+,d1-d3/a1-a5
	move.l	d0,a0			;a0 -> Module data area
	rts
;
;Ends:	_mod_s_alloc
;Ends:	_mod_alloc
;----------------------------------------------------------------------------
;long	_mod_free(mod *module_p)
;long	_mod_s_free(mod *module_p)
;
_mod_free:
_mod_s_free:
	moveq	#E_IMBA,d0
	cmp.l	#$1000,a0
	ble.s	.exit
	cmp.l	#DspT_s_c,-12(a0)
	bne.s	.exit
	movem.l	d1-d2/a0-a3,-(sp)
	movea.l	currbp_p_p(pc),a3	;a3 -> -> active process basepage
	move.l	(a3),-(sp)		;push -> active process basepage
	move.l	basepage_p(pc),(a3)	;activate own process basepage
	gemdos	Mfree,-12(a0)		;release module RAM block
	move.l	(sp)+,(a3)		;restore active process basepage
	movem.l	(sp)+,d1-d2/a0-a3
.exit:
	rts
;
;Ends:	_mod_s_free
;Ends:	_mod_free
;----------------------------------------------------------------------------
;mod	*_mod_copy_start(long size, rawmod *mod_p, void (*dumpfunc_p)())
;
_mod_copy_start:
	movem.l	d0/a0-a1,-(sp)
	bsr	_mod_dump		;dump previous module
	bsr	_mod_calc		;calculate RAM need
	tst.l	d0
	ble.s	.exit
	bsr	_mod_alloc		;allocate RAM block for module plus workspace
	tst.l	d0
	ble.s	.exit
	move.l	a0,module_p		;store new module address in module_p
	move.l	a1,dumpfunc_p		;store users dumpfunc pointer in dumpfunc_p
	move.l	a0,a1			;a1 -> module space in new RAM block
	movem.l	(sp),d0/a0		;d0 = raw module size,  a0 -> raw module
.loop:
	move.l	(a0)+,(a1)+		;copy raw module longword to new RAM block
	subq.l	#4,d0
	bgt.s	.loop			;loop back to copy entire module
	move.l	module_p(pc),a0
	move.l	dumpfunc_p(pc),a1
	bsr	_mod_start_raw
.exit:
	addq	#8,sp			;erase entry d0/a0 from stack
	move.l	(sp)+,a1		;pull entry a1
	move.l	d0,a0
	rts
;
;Ends:	_mod_copy_start
;----------------------------------------------------------------------------
;mod	*_mod_s_copy_start(long size, rawmod *mod_p, void (*dumpfunc_p)())
;
_mod_s_copy_start:
	movem.l	d0/a0-a1,-(sp)
	bsr	_mod_s_dump		;dump previous module
	bsr	_mod_s_calc		;calculate RAM need
	tst.l	d0
	ble.s	.exit
	bsr	_mod_s_alloc		;allocate RAM block for module plus workspace
	tst.l	d0
	ble.s	.exit
	move.l	a0,module_p		;store new module address in module_p
	move.l	a1,dumpfunc_p		;store users dumpfunc pointer in dumpfunc_p
	move.l	a0,a1			;a1 -> module space in new RAM block
	movem.l	(sp),d0/a0		;d0 = raw module size,  a0 -> raw module
.loop:
	move.l	(a0)+,(a1)+		;copy raw module longword to new RAM block
	subq.l	#4,d0
	bgt.s	.loop			;loop back to copy entire module
	move.l	module_p(pc),a0
	move.l	dumpfunc_p(pc),a1
	bsr	_mod_s_start_raw
.exit:
	addq	#8,sp			;erase entry d0/a0 from stack
	move.l	(sp)+,a1		;pull entry a1
	move.l	d0,a0
	rts
;
;Ends:	_mod_s_copy_start
;----------------------------------------------------------------------------
;mod	*_mod_load(char *filepath_p)
;mod	*_mod_s_load(char *filepath_p)
;
_mod_load:
_mod_s_load:
	movem.l	d1-d5/a1-a4,-(sp)
	move.l	a0,a3			;a3 -> filepath
;
	gemdos	Fgetdta
	move.l	d0,-(sp)
	gemdos	Fsetdta,local_dta(pc)
;
	gemdos	Fsfirst,(a3),!
	tst.l	d0
	bmi	.exit_error
	move.l	dta_fsize+local_dta(pc),d0
	move.l	d0,d5			;d5 = filesize
	gemdos	Malloc,d0		;allocate Module file buffer
	tst.l	d0
	bmi	.exit_error
	move.l	d0,a4			;a4 -> Module file buffer
	gemdos	Fopen,(a3),!		;open Module file
	move.l	d0,d3
	bmi.s	.file_error
	gemdos	Fread,d3,d5,(a4)	;read Module file
	move.l	d0,d4
	gemdos	Fclose,d3		;close Module file
	move.l	d4,d0
	ble.s	.file_error
	cmp.l	d4,d5
	beq.s	.read_ok
.file_error:				;file error occurred
	gemdos	Mfree|_ind,(a4)		;release Module file buffer
	bra	.exit_error
;
.read_ok:
	move.l	a4,a0			;a0 -> loaded module
	bsr	_mod_s_calc		;calculate expanded module room
	tst.l	d0
	ble.s	.file_error		;exit on error
	bsr	_mod_s_alloc		;allocate expanded module room
	tst.l	d0
	ble.s	.file_error		;exit on error
	move.l	d0,a3			;a3 -> expanded module buffer
	move.l	d0,a1			;a1 -> expanded module buffer
	move.l	a4,a0			;a0 -> Module file buffer
	move.l	d5,d0			;d0 = filesize
.copy_loop:				;loop start to copy entire module
	move.l	(a0)+,(a1)+
	subq.l	#4,d0
	bgt.s	.copy_loop		;loop back to copy entire module
	gemdos	Mfree,(a4)		;release Module file buffer
	move.l	a3,d3			;d3 -> expanded module buffer
	bra.s	.exit
;
.exit_error:
	moveq	#E_ERROR,d3		;d3 = error code
.exit:
	gemdos	Fsetdta,()		;restore entry DTA
	move.l	d3,d0			;d0 = return value
	move.l	d3,a0			;a0 = return value
	movem.l	(sp)+,d1-d5/a1-a4	;restore entry registers
	rts
;
;Ends:	_mod_s_load
;Ends:	_mod_load
;----------------------------------------------------------------------------
;mod	*_mod_start(mod *module_p, void (*dumpfunc_p)())
;
_mod_start:
	bsr	_mod_dump
_mod_start_raw:
	movem.l	d1-d7/a0-a6,-(sp)
	moveq	#E_IMBA,d0
	cmp.l	#$1000,a0		;Too low ptr ?
	ble.s	.error
	cmp.l	#DspT_s_c,-12(a0)
	bne.s	.error
	move.l	a0,module_p
	move.l	a1,dumpfunc_p
	gemdos	Super,1.w
	move.l	d0,-(sp)
	bmi.s	.keep_super_1
	gemdos	Super,()
	move.l	d0,-(sp)
.keep_super_1:
	movea.l	module_p(pc),a0
	move.l	-4(a0),workspace_p
	bsr	Init_Module
	move.l	(sp)+,d0
	bmi.s	.keep_super_2
	gemdos	Super|_ind,d0
.keep_super_2:
	movem.l	(sp)+,d1-d7/a0-a6
	bra	_mod_play
;
.error:
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	d0,a0
	rts
;
;Ends:	_mod_start
;----------------------------------------------------------------------------
;mod	*_mod_s_start(mod *module_p, void (*dumpfunc_p)())
;
_mod_s_start:
	bsr	_mod_s_dump
_mod_s_start_raw:
	movem.l	d1-d7/a0-a6,-(sp)
	moveq	#E_IMBA,d0
	cmp.l	#$1000,a0		;Too low ptr ?
	ble.s	.error
	cmp.l	#DspT_s_c,-12(a0)
	bne.s	.error
	move.l	a0,module_p
	move.l	a1,dumpfunc_p
	move.l	-4(a0),workspace_p
	bsr	Init_Module
	movem.l	(sp)+,d1-d7/a0-a6
	bra	_mod_s_play
;
.error:
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	d0,a0
	rts
;
;Ends:	_mod_s_start
;----------------------------------------------------------------------------
;mod	*_mod_restart()
;
_mod_restart:
	move.l	module_p(pc),a0
	move.l	a0,d0
	ble.s	.exit
	bsr	_mod_stop
	movem.l	d1-d7/a0-a6,-(sp)
	bsr	Reinit_Module
	movem.l	(sp)+,d1-d7/a0-a6
	bra	_mod_play
;
.exit:
	rts
;
;Ends:	_mod_restart
;----------------------------------------------------------------------------
;mod	*_mod_s_restart()
;
_mod_s_restart:
	move.l	module_p(pc),a0
	move.l	a0,d0
	ble.s	.exit
	bsr	_mod_s_stop
	movem.l	d1-d7/a0-a6,-(sp)
	bsr	Reinit_Module
	movem.l	(sp)+,d1-d7/a0-a6
	bra	_mod_s_play
;
.exit:
	rts
;
;Ends:	_mod_s_restart
;----------------------------------------------------------------------------
;mod	*_mod_play()
;
_mod_play:
	moveq	#E_ERROR,d0
	tst.b	music_on_f
	bne	.exit_direct
	tst.l	module_p
	ble	.exit_direct
	movem.l	d1-d7/a0-a6,-(sp)
	gemdos	Super,1.w
	move.l	d0,-(sp)
	bmi.s	.keep_super_1
	gemdos	Super,()
	move.l	d0,-(sp)
.keep_super_1:
;
	bsr	Init_Sound
	bmi.s	.error
;
	move	sr,d6			;save interrupt mask in d6
	or	#$0700,sr		;disable interrupt mask
	st	music_on_f
	tst.b	timer_a_f
	beq.s	.no_timer
	clr.b	$fffffa19.w		;Stop timer A
	lea	(iv_time_a).w,a0
	lea	nu_time_a(pc),a1
	bsr	retop_XB_name
	bset.b	#5,$fffffa07.w		;Enable timer A interrupt
	bset.b	#5,$fffffa13.w		;Unmask timer A interrupt
	move.b	#192,$fffffa1f.w
	move.b	#5,$fffffa19.w		;Start timer A
	bra.s	.done
;
.no_timer:
	lea	(ev_VBI).w,a0
	lea	nu_vbl(pc),a1
	bsr	retop_XB_name
.done:
	move	d6,sr			;restore interrupt mask
	move.l	module_p(pc),d7
	bra.s	.exit
;
.error:
	moveq	#E_ERROR,d7
.exit:
	move.l	(sp)+,d0
	bmi.s	.keep_super_2
	gemdos	Super|_ind,d0
.keep_super_2:
	move.l	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
.exit_direct:
	move.l	d0,a0
	rts
;
;Ends	_mod_play
;----------------------------------------------------------------------------
;mod	*_mod_s_play()
;
_mod_s_play:
	moveq	#E_ERROR,d0
	tst.b	music_on_f
	bne	.exit_direct
	tst.l	module_p
	ble	.exit_direct
	movem.l	d1-d7/a0-a6,-(sp)
;
	bsr	Init_Sound
	bmi.s	.error
;
	move	sr,d6			;save interrupt mask in d6
	or	#$0700,sr		;disable interrupt mask
	st	music_on_f
	tst.b	timer_a_f
	beq.s	.no_timer
	clr.b	$fffffa19.w		;Stop timer A
	lea	(iv_time_a).w,a0
	lea	nu_time_a(pc),a1
	bsr	retop_XB_name
	bset.b	#5,$fffffa07.w		;Enable timer A interrupt
	bset.b	#5,$fffffa13.w		;Unmask timer A interrupt
	move.b	#192,$fffffa1f.w
	move.b	#5,$fffffa19.w		;Start timer A
	bra.s	.done
;
.no_timer:
	lea	(ev_VBI).w,a0
	lea	nu_vbl(pc),a1
	bsr	retop_XB_name
.done:
	move	d6,sr			;restore interrupt mask
	move.l	module_p(pc),d7
	bra.s	.exit
;
.error:
	moveq	#E_ERROR,d7
.exit:
	move.l	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
.exit_direct:
	move.l	d0,a0
	rts
;
;Ends	_mod_s_play
;----------------------------------------------------------------------------
;void	_mod_stop()
;
_mod_stop:
	tst.b	music_on_f
	beq.s	.no_music
	sf	music_on_f
	movem.l	d0-d7/a0-a6,-(sp)
	gemdos	Super,1.w
	move.l	d0,-(sp)
	bmi.s	.keep_super_1
	gemdos	Super,()
	move.l	d0,-(sp)
.keep_super_1:
	move	sr,-(sp)
	or	#$0700,sr
	tst.b	timer_a_f
	beq.s	.skip_it
	clr.b	$fffffa19.w		;Stop timer A
	bclr.b	#5,$fffffa07.w		;Disable Timer A interrupt
	bclr.b	#5,$fffffa13.w		;Mask Timer A interrupt
.skip_it:
	lea	(iv_time_a).w,a0
	lea	nu_time_a(pc),a1
	bsr	remove_XB_name
	lea	(ev_VBI).w,a0
	lea	nu_vbl(pc),a1
	bsr	remove_XB_name
;
	move	(sp)+,sr
	bsr	Stop_Sound
	move.l	(sp)+,d0
	bmi.s	.keep_super_2
	gemdos	Super|_ind,d0
.keep_super_2:
	movem.l	(sp)+,d0-d7/a0-a6
.no_music:
	rts
;
;Ends:	_mod_stop
;----------------------------------------------------------------------------
;void	_mod_s_stop()
;
_mod_s_stop:
	tst.b	music_on_f
	beq.s	.no_music
	sf	music_on_f
	movem.l	d0-d7/a0-a6,-(sp)
	move	sr,-(sp)
	or	#$0700,sr
	tst.b	timer_a_f
	beq.s	.skip_it
	clr.b	$fffffa19.w		;Stop timer A
	bclr.b	#5,$fffffa07.w		;Disable Timer A interrupt
	bclr.b	#5,$fffffa13.w		;Mask Timer A interrupt
.skip_it:
	lea	(iv_time_a).w,a0
	lea	nu_time_a(pc),a1
	bsr	remove_XB_name
	lea	(ev_VBI).w,a0
	lea	nu_vbl(pc),a1
	bsr	remove_XB_name
;
	move	(sp)+,sr
	bsr	Stop_Sound
	movem.l	(sp)+,d0-d7/a0-a6
.no_music:
	rts
;
;Ends:	_mod_s_stop
;----------------------------------------------------------------------------
;void	_mod_dump()
;
_mod_dump:
	bsr	_mod_stop
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	module_p(pc),d0
	ble.s	.no_module
	move.l	d0,a0
	move.l	dumpfunc_p(pc),d0
	ble.s	.no_dumpfunc
	move.l	d0,a1
	jsr	(a1)
	move.l	#E_ACCDN,dumpfunc_p
.no_dumpfunc:
	move.l	#E_ACCDN,module_p
.no_module:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;Ends:	_mod_dump
;----------------------------------------------------------------------------
;void	_mod_s_dump()
;
_mod_s_dump:
	bsr	_mod_s_stop
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	module_p(pc),d0
	ble.s	.no_module
	move.l	d0,a0
	move.l	dumpfunc_p(pc),d0
	ble.s	.no_dumpfunc
	move.l	d0,a1
	jsr	(a1)
	move.l	#E_ACCDN,dumpfunc_p
.no_dumpfunc:
	move.l	#E_ACCDN,module_p
.no_module:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;Ends:	_mod_s_dump
;----------------------------------------------------------------------------
;long	_mod_test_end()
;long	_mod_s_test_end()
;
_mod_test_end:
_mod_s_test_end:
	move.b	song_looped_f(pc),d0
	ext.w	d0
	ext.l	d0
	rts
;
;Ends:	_mod_s_test_end
;Ends:	_mod_test_end
;----------------------------------------------------------------------------
;long	_mod_set_timer(short new_timer_f)
;
_mod_set_timer:
	move.b	timer_a_f(pc),-(sp)	;push original timer_a_f
	tst.b	d0
	bmi.s	.exit			;negative arg = inquiry
	tst.b	d0
	sne	d0
	move.b	music_on_f(pc),-(sp)	;push music_on_f
	move.b	d0,-(sp)		;push new timer_a_f value
	bsr	_mod_stop		;stop music
	move.b	(sp)+,timer_a_f		;store new timer_a_f
	tst.b	(sp)+			;test original music_on_f
	beq.s	.exit			;exit if music was off
	bsr	_mod_play		;play music
.exit:
	move.b	(sp)+,d0		;d0 = original timer_a_f
	and.l	#1,d0
	rts
;
;Ends	_mod_set_timer
;----------------------------------------------------------------------------
;long	_mod_s_set_timer(short new_timer_f)
;
_mod_s_set_timer:
	move.b	timer_a_f(pc),-(sp)	;push original timer_a_f
	tst.b	d0
	bmi.s	.exit			;negative arg = inquiry
	tst.b	d0
	sne	d0
	move.b	music_on_f(pc),-(sp)	;push music_on_f
	move.b	d0,-(sp)		;push new timer_a_f value
	bsr	_mod_s_stop		;stop music
	move.b	(sp)+,timer_a_f		;store new timer_a_f
	tst.b	(sp)+			;test original music_on_f
	beq.s	.exit			;exit if music was off
	bsr	_mod_s_play		;play music
.exit:
	move.b	(sp)+,d0		;d0 = original timer_a_f
	and.l	#1,d0
	rts
;
;Ends	_mod_s_set_timer
;----------------------------------------------------------------------------
;short	_mod_set_boost(short new_boost)
;short	_mod_s_set_boost(short new_boost)
;
_mod_set_boost:
_mod_s_set_boost:
	move	volume_boost(pc),d1
	tst	d0
	bmi.s	.keep_boost
	and	#3,d0
	move	d0,volume_boost
.keep_boost:
	clr.l	d0
	move	d1,d0
	rts
;
;Ends:	_mod_s_set_boost
;Ends:	_mod_set_boost
;----------------------------------------------------------------------------
;short	_mod_set_stop(short new_mode_f)
;short	_mod_s_set_stop(short new_mode_f)
;
_mod_set_stop:
_mod_s_set_stop:
	move	endmode_f(pc),d1
	tst	d0
	bmi.s	.keep_stop
	move	d0,endmode_f
.keep_stop:
	clr.l	d0
	move	d1,d0
	rts
;
;Ends:	_mod_s_set_stop
;Ends:	_mod_set_stop
;----------------------------------------------------------------------------
;short	_mod_set_order(short new_order)
;short	_mod_s_set_order(short new_order)
;
_mod_set_order:
_mod_s_set_order:
	move	sample_order(pc),d1
	tst	d0
	bmi.s	.keep_order
	and	#3,d0
	move	d0,sample_order
	lea	Voice_Order_tpt(pc),a0
	move.l	(a0,d0.w*4),Voice_Order_p
.keep_order
	clr.l	d0
	move	d1,d0
	rts
;
;Ends:	_mod_s_set_order
;Ends:	_mod_set_order
;----------------------------------------------------------------------------
;
	XB_define	nu_vbl,DspT_s_c
	btst	#2,(sp)				;interrupted level >= 4 ?
	bne.s	.use_old_vbi			;if so, no chance this time
	tas	interrupt_block_f		;TAS reentrancy block flag
	bmi.s	.use_old_vbi
	push_ex	.post_vbi			;push new exception frame
.use_old_vbi:
	XB_gonext_d	nu_vbl(pc)		;use older vbi routines
;
.post_vbi:
	or	#$0700,SR
	move	(sp),internal_stack_top		;copy interrupted SR
	move.l	sp,external_stack_p		;save entry stack pointer
	lea	internal_stack_top(pc),sp	;activate internal stack
	bset	#5,(sp)				;enforce super in SR copy
	btst	#1,(sp)				;mask level >= 2 ?
	bne.s	.keep_it			;if so, keep it
	bset	#0,(sp)				;else enforce level 1
.keep_it:
	move	(sp)+,SR			;pull interrupt mask lower
	bsr	tracker_68K			;call sound_track routines
	or	#$0700,SR			;Disable interrupts
	move.l	external_stack_p(pc),sp		;restore entry stack
	bclr	#7,interrupt_block_f		;clear reentrancy block flag
	rte					;return from exception
;
;----------------------------------------------------------------------------
;
	XB_define	nu_time_a,DspT_s_c
	bclr.b	#5,$fffffa0f.w			; … Cause du mode SEI
	move.b	#192,$fffffa1f.w
	move.b	#5,$fffffa19.w
;
	btst	#2,(sp)				;interrupted level >= 4 ?
	bne.s	.exit_direct			;if so, skip it for now.
	tas	interrupt_block_f		;TAS reentrancy block flag
	bmi.s	.exit_direct
;
	or	#$0700,SR			;Disable interrupts
	move.l	sp,external_stack_p		;save entry stack pointer
	lea	internal_stack_top(pc),sp		;activate internal stack
	and	#$FBFF,SR			;Set interrupt mask = 3
	bsr	tracker_68K			;call sound_track routines
	or	#$0700,SR			;Disable interrupts
	move.l	external_stack_p(pc),sp		;restore entry stack
	bclr	#7,interrupt_block_f		;clear reentrancy block flag
;
.exit_direct:
	rte					;return from exception
;
;----------------------------------------------------------------------------
;
	Include	'TRACKER.S'
;
;----------------------------------------------------------------------------
;	Resident cookie jar routines & data
;
	_uniref	reset_old_jar
	make	JAR_links
;
	make_DspT_cookie
;
;----------------------------------------------------------------------------
;
music_on_f:	dc.b	0
timer_a_f:	dc.b	0
		even
;
currbp_p_p:	dc.l	0
basepage_p:	dc.l	0
module_p:	dc.l	0
dumpfunc_p:	dc.l	0
workspace_p:	dc.l	0
;
interrupt_block_f:	dc.w	0
;
local_dta	ds.b	dta_size
;
external_stack_p:	ds.l	1
internal_stack_beg:	ds.l	1024	;4096 bytes internal stack
internal_stack_top:	ds.l	4	;small safety
;
;----------------------------------------------------------------------------
;NB:	All code beyond this point is overwritten after initialization
;----------------------------------------------------------------------------
;
resident_RAM_end:
resident_RAM_size	=	resident_RAM_end-resident_RAM_beg
;
;----------------------------------------------------------------------------
;
init_prog:
	move.l	a0,d0
	beq.s	non_ACC
	gemdos	Cconws,must_be_non_ACC_s
	gemdos	Pterm0
;
;------------------------------------
;
non_ACC:
	move.l	4(sp),a5			;a5 -> basepage
	move.l	a5,basepage_p
	lea	init_stack_top(pc),sp		;sp -> local initialization stack
	gemdos	Mshrink,!,(a5),#init_RAM_size
	gemdos	Super,!
	move.l	d0,-(sp)
	lea	DspT_cookie(pc),a0
	make_cookie	#DspT_s_c,a0
	bpl.s	cookie_ok
	gemdos	Super,()
	gemdos	Cconws,cookie_exists_s(pc)
	gemdos	Pterm0
;
;------------------------------------
;
cookie_ok:
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	os_currbp_p_p(a0),currbp_p_p
	gemdos	Super,()
	gemdos	Cconws,success_s(pc)
	gemdos	Ptermres,#resident_RAM_size,!
;
;----------------------------------------------------------------------------
;
	make	JAR_links
;
;----------------------------------------------------------------------------
;
	SECTION	DATA
;
;----------------------------------------------------------------------------
;
must_be_non_ACC_s:
	dc.b	BEL,CR,LF
	dc.b	' '
	dc.l	DspT_s_c
	dc.b	' is a TSR *NOT* an ACC !!!',BEL,CR,LF
	dc.b	'I recommend a RESET now.',BEL,CR,LF
	dc.b	BEL,CR,LF,NUL
	even
;
cookie_exists_s
	dc.b	BEL,CR,LF
	dc.b	"The cookie "
	dc.l	DspT_s_c
	dc.b	" already existed.",BEL,CR,LF
	dc.b	"so it was not installed again.",BEL,CR,LF
	dc.b	BEL,CR,LF,NUL
	even
;
success_s:
	dc.b	ESC,'q',CR,LF
	dc.b	ESC,'p',' DspT MOD-player server  Version: 1.3 ',ESC,'q',CR,LF
	dc.b	CR,LF,NUL

;
;----------------------------------------------------------------------------
;
	SECTION	BSS
;
;----------------------------------------------------------------------------
;
init_stack_beg:
	ds.b	4*1024
init_stack_top:
;
;----------------------------------------------------------------------------
;
	section	DATA
init_data_end:
init_data_size	=	init_data_end-init_data_beg
	section	BSS
init_bss_end:
init_bss_size	=	init_bss_end-init_bss_beg
	SECTION	TEXT
init_code_end:
init_code_size	=	init_code_end-init_code_beg
init_RAM_size	=	init_code_size+init_data_size+init_bss_size+$100
;
;----------------------------------------------------------------------------
;
	END
;
;----------------------------------------------------------------------------
;End of file:	DspT.S
;----------------------------------------------------------------------------
