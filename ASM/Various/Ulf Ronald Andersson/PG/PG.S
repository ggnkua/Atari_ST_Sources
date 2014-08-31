;----------------------------------------------------------------------------
;File name:	PG.S			Revision date:	1994.12.30
;Disassembler:	Ulf Ronald Andersson	Disassembled:	1994.12.30
;----------------------------------------------------------------------------
	include	URAn_DOS.S
	include	URAn_LA.S
	include	URAn_XB.S
;----------------------------------------------------------------------------
max_saved	=	16
;----------------------------------------------------------------------------
	SECTION	text
;----------------------------------------------------------------------------
fix_vectors	MACRO
		move.l	#nu_resvector+12,(resvector).w
		move.l	#$31415926,(resvalid).w
		movem.l	d0/a0,-(sp)
		clr.l	d0
		move.b	(hw_vr),d0
		and	#$F0,d0
		lsl	#2,d0
		move	d0,a0
		move.l	#nu_ringer+12,14*4(a0)
		bclr	#6,(hw_ddr).w
		bclr	#6,(hw_aer).w
		bclr	#6,(hw_isra).w
		bset	#6,(hw_iera).w
		bset	#6,(hw_imra).w
		movem.l	(sp)+,d0/a0
		ENDM
;----------------------------------------------------------------------------
begin:
	lea	loc_stack_end,sp
	gemdos	super,!
	move.l	d0,iz_entry_ssp
	_a_init
	_a_hide_c
	move.l	(phystop).w,d0
	move.l	d0,iz_entry_phystop
	sub.l	#32000,d0
	move.l	d0,max_user_screen_p
	clr	now_saved
	clr	max_saved_f
	fix_vectors
	gemdos	cconws,prog_title_s
.l0000:
	gemdos	crawcin
	cmp.b	#'a',d0
	blt.s	.gotcha
	cmp.b	#'z',d0
	bgt.s	.gotcha
	and	#$5F,d0
.gotcha:
	cmp.b	#'I',d0		;Interrupt toggle command ?
	bne.s	.l0001
	bchg	#0,l0088
	clr.l	d0
	move.b	l0088,d0
	lsl.l	#2,d0
	lea	on_off_s_t,a1
	movea.l	0(a1,d0.w),a0
	gemdos	cconws,(a0)
	bra.s	.l0000
;
.l0001:
	cmp.b	#'B',d0	;#'0'	;Boot command ?
	beq.s	l0003
	tst.b	l0088
	bne.s	l0002
	bsr	iz_nu_vectors
l0002:
	_a_show_c
	gemdos	super|_ind,iz_entry_ssp
	gemdos	ptermres,#$100+(bss_end-begin),!
;
;
l0003:
	tst.b	l0088
	bne.s	l0004
	bsr.s	iz_nu_vectors
l0004:
	gemdos	cconws,boot_prompt_s
	gemdos	crawcin
	gemdos	cconws,clear_screen_s
	xbios	floprd,boot_sector_bf,!,!,#1,!,!,#1
	lea	boot_sector_bf,a0
	move.w	#$ff,d1
	move.w	#$1234,d0
l0005:
	sub.w	(a0)+,d0
	dbra	d1,l0005
	tst.w	d0
	bne.s	l0006
	bsr	boot_sector_bf
	bra.s	l0007
;
l0006:
	gemdos	cconws,boot_missing_s
	gemdos	crawcin
l0007:
	bra	l0002
;
;----------------------------------------------------------------------------
;
iz_nu_vectors:
	move	sr,-(sp)
	move	#$2700,sr
	tst.b	(iv_time_a).w
	bne.s	.l0009
	move.l	(iv_time_a).w,nu_iv_time_a+8
	move.l	#nu_iv_time_a+12,(iv_time_a).w
	bra.s	.l000a
;
.l0009:
	xbios	xbtimer,#0,#7,#$fa,nu_xbtime_a+12	;init timer A
.l000a:
	move	(sp)+,sr
	bsr	iz_nu_time_b
	bsr	iz_nu_time_c
	bsr	iz_nu_time_d
	bsr	iz_nu_system
	bsr	iz_nu_hdv_bpb
	bsr	iz_nu_hdv_mediach
	bsr	iz_nu_hdv_rw
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	nu_xbtime_a,'PGRA'
	fix_vectors
	bclr	#5,(hw_isra).w
	rte
;
;
	XB_define	nu_iv_time_a,'PGRA'
	fix_vectors
	XB_gonext_d	nu_iv_time_a(pc)
;
;----------------------------------------------------------------------------
;
iz_nu_time_b:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(iv_time_b).w,nu_time_b+8
	move.l	#nu_time_b+12,(iv_time_b).w
	move	(sp)+,sr
	rts
;
;
	XB_define	nu_time_b,'PGRA'
	fix_vectors
	XB_gonext_d	nu_time_b(pc)
;
;----------------------------------------------------------------------------
;
iz_nu_time_c:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(iv_time_c).w,nu_time_c+8
	move.l	#nu_time_c+12,(iv_time_c).w
	move	(sp)+,sr
	rts
;
;
	XB_define	nu_time_c,'PGRA'
	fix_vectors
	XB_gonext_d	nu_time_c(pc)
;
;----------------------------------------------------------------------------
;
iz_nu_time_d:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(iv_time_d).w,nu_time_d+8
	move.l	#nu_time_d+12,(iv_time_d).w
	move	(sp)+,sr
	rts
;
;
	XB_define	nu_time_d,'PGRA'
	fix_vectors
	XB_gonext_d	nu_time_d(pc)
;
;----------------------------------------------------------------------------
;URAn:	Original 'PG' never used nu_gemdos, nu_bios or nu_xbios.
;URAn:	This was partly due to a 'double init' error in this routine,
;URAn:	but also due to an error in each of those routines, which attempted
;URAn:	to use the 'BTST' operation on 16 bit memory words.
;URAn:	Motorola states this to be possible in erroneous 68000 user manuals,
;URAn:	but actually bit operations on RAM data always access single bytes.
;URAn:	These routines also had to be altered to test 'longframe', or they
;URAn:	would fail to work properly on newer machines.
;URAn:	I have also added XBRA protocol to the vector stealing code.
;
iz_nu_system:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(ev_gemdos).w,nu_gemdos+8
	move.l	#nu_gemdos+12,(ev_gemdos).w
	move.l	(ev_bios).w,nu_bios+8
	move.l	#nu_bios+12,(ev_bios).w
	move.l	(ev_xbios).w,nu_xbios+8
	move.l	#nu_xbios+12,(ev_xbios).w
	move	(sp)+,sr
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	nu_gemdos,'PGRA'
	fix_vectors
	XB_gonext_d	nu_gemdos(pc)
;
	XB_define	nu_bios,'PGRA'
	fix_vectors
	XB_gonext_d	nu_bios(pc)
;
	XB_define	nu_xbios,'PGRA'
	fix_vectors
	XB_gonext_d	nu_xbios(pc)
;
;
;----------------------------------------------------------------------------
;
iz_nu_hdv_bpb:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(hdv_bpb).w,nu_hdv_bpb+8
	move.l	#nu_hdv_bpb+12,(hdv_bpb).w
	move	(sp)+,sr
	rts
;
;
iz_nu_hdv_rw:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(hdv_rw).w,nu_hdv_rw+8
	move.l	#nu_hdv_rw+12,(hdv_rw).w
	move	(sp)+,sr
	rts
;
;
iz_nu_hdv_mediach:
	move	sr,-(sp)
	move	#$2700,sr
	move.l	(hdv_mediach).w,nu_hdv_mediach+8
	move.l	#nu_hdv_mediach+12,(hdv_mediach).w
	move	(sp)+,sr
	rts
;
;
	XB_define	nu_hdv_bpb,'PGRA'
	fix_vectors
	XB_gonext_d	nu_hdv_bpb(pc)
;
	XB_define	nu_hdv_rw,'PGRA'
	fix_vectors
	XB_gonext_d	nu_hdv_rw(pc)
;
	XB_define	nu_hdv_mediach,'PGRA'
	fix_vectors
	XB_gonext_d	nu_hdv_mediach(pc)
;
;----------------------------------------------------------------------------
	XB_define	nu_ringer,'PGRA'
	movem.l	d0-d7/a0-a6,-(sp)
	move	sr,-(sp)
	or	#$0700,sr
	lea	(hw_vbase2).w,a0
	clr.l	d0
	movep	0(a0),d0
	lsl.l	#8,d0
	move.l	d0,a0		;a0 -> hard screen to be saved
	move	#20-1,d0
.debounce_1:
	btst	#6,(hw_gpip).w
	dbne	d0,.debounce_1	;loop until 1 read, or until 0 read 20 times
	bne.s	.exit		;exit if 1 read
	bsr.s	save_screen
	move	(sp),sr		;restore status, but keep it stacked
.debounce_2:
	move	#500-1,d0
.debounce_3:
	btst	#6,(hw_gpip).w
	dbeq	d0,.debounce_3
	beq.s	.debounce_2	;loop until 1 read 500 times in a row
.exit:
	move	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#6,(hw_isra).w
	rte
;----------------------------------------------------------------------------
save_screen:
	clr.l	d0
	move	now_saved(pc),d0
	cmp	#max_saved,d0
	blo.s	.found_index
	st	max_saved_f
	clr	d0
.found_index:
	move	d0,now_saved
	swap	d0
	lsr.l	#1,d0			;d0 = index*$8000
	lea	saved_screens_t,a1
	add.l	d0,a1			;a1 -> area for picture
	move	#32000/2-1,d0
.copy_screen_lp:
	move.w	(a0)+,(a1)+
	dbra	d0,.copy_screen_lp
	lea	(hw_pal).w,a0
	moveq	#16-1,d0
.copy_pal_lp:
	move.w	(a0)+,(a1)+
	dbra	d0,.copy_pal_lp
	lea	grabber_id,a0
	moveq	#16-1,d0
.copy_id_lp:
	move.b	(a0)+,(a1)+
	dbra	d0,.copy_id_lp
	move.l	#'PGRA',(a1)+
	move.l	iz_entry_phystop(pc),(a1)+
	addq	#1,now_saved
	rts
;----------------------------------------------------------------------------
	dc.l	saved_screens_t
	dc.l	now_saved
	dc.l	max_saved_f
	dc.w	max_saved
	XB_define	nu_resvector,'PGRA'
	lea	loc_stack_end(pc),sp
	lea	(hw_vbase2).w,a0
	clr.l	d0
	movep	0(a0),d0
	lsl.l	#8,d0
	move.l	d0,reset_hw_vbase
	move.b	(hw_rez).w,d0
	and	#1,d0
	move	d0,reset_hw_rez
	move.b	(hw_syn).w,d0
	and	#3,d0
	move	d0,reset_hw_syn
	movem.l	(hw_pal).w,d0-d7
	movem.l	d0-d7,reset_hw_pal
	clr.b	(hw_rez).w
	move.b	#2,(hw_syn).w
	lea	loc_stack_end,sp
	move.l	(ev_vbi).w,grab_vbi+8
	move.l	#grab_vbi+12,(ev_vbi).w
	move.b	#$1a,(hw_kbdata).w	;ikbd joystick reports off
	clr.l	d0
	move.l	#raw_screen_bf,d0
	andi.l	#-$100,d0
	move.l	d0,local_screen_p
	lsr.l	#8,d0
	lea	(hw_vbase2).w,a0
	movep.w	d0,0(a0)
	move.b	#$12,(hw_kbdata).w	;ikbd mouse reports off
	move.l	#$7d00,grab_step_size
	move.l	(_v_bas_ad).w,grab_screen_p
	movea.l	grab_screen_p,a0
	movea.l	local_screen_p(pc),a1
	move.l	#$3e7f,d0
.l0023:
	move.w	(a0)+,(a1)+
	dbra	d0,.l0023
	move.b	#-1,l0080
	move	#$2300,sr
	bsr	l006c
	clr.b	(hw_rez).w
	move.b	#2,(hw_syn).w
grab_cmd_loop:
	bsr	l006c
	clr.l	d0
	move.b	(hw_kbdata).w,d0
	cmp.l	d0,d1
	beq.s	grab_cmd_loop
	cmp.b	#2,d0		;scan '1' ?
	beq	cmd_1_xxx
	cmp.b	#3,d0		;scan '2' ?
	beq	cmd_2_xxx
	cmp.b	#4,d0		;scan '3' ?
	beq	cmd_3_xxx
	cmp.b	#5,d0		;scan '4' ?
	beq	cmd_4_xxx
	cmp.b	#$70,d0		;scan num '0' ?
	beq	cmd_num_0_xxx
	cmp.b	#$6d,d0		;scan num '1' ?
	beq	cmd_num_1_xxx
	cmp.b	#$6e,d0		;scan num '2' ?
	beq	cmd_num_2_xxx
	cmp.b	#$6f,d0		;scan num '3' ?
	beq	cmd_num_3_xxx
	cmp.b	#$48,d0		;scan Up-arrow ?
	beq	cmd_up_arrow_xxx
	cmp.b	#$50,d0		;scan Dn-arrow ?
	beq	cmd_dn_arrow_xxx
	cmp.b	#$21,d0		;scan 'F' ?
	beq	cmd_F_xxx
	cmp.b	#$13,d0		;scan 'R' ?
	beq	cmd_R_xxx
	cmp.b	#$71,d0		;scan num '.' ?
	beq	cmd_num_point_xxx
	cmp.b	#$38,d0		;scan Alternate ?
	beq	cmd_Alternate_xxx
	cmp.b	#$2a,d0		;scan L-Shift ?
	beq	cmd_lt_shift_xxx
	cmp.b	#$3b,d0		;scan F1 ?
	beq	cmd_F1_xxx
	cmp.b	#$30,d0		;scan 'B' ?
	beq	cmd_B_xxx
	cmp.b	#$3c,d0		;scan F2 ?
	beq	cmd_F2_xxx
	cmp.b	#$3d,d0		;scan F3 ?
	beq	cmd_F3_xxx
	cmp.b	#$3e,d0		;scan F4 ?
	beq	cmd_F4_xxx
	cmp.b	#$3f,d0		;scan F5 ?
	beq	cmd_F5_xxx
	cmp.b	#$40,d0		;scan F6 ?
	beq	cmd_F6_xxx
	cmp.b	#$41,d0		;scan F7 ?
	beq	cmd_F7_xxx
	cmp.b	#$42,d0		;scan F8 ?
	beq	cmd_F8_xxx
	cmp.b	#$23,d0		;scan H ?
	beq	cmd_H_xxx
	move.l	d0,d1
	cmp.b	#$39,d0		;scan ' ' ?
	bne	grab_cmd_loop
cmd_space_xxx:
	move.l	local_screen_p(pc),a0
	bsr	save_screen
;
	clr.l	d0
	move	now_saved(pc),d0
	tst.b	max_saved_f
	beq.s	.found_count
	moveq	#max_saved,d0
.found_count:
	swap	d0
	lsr.l	#1,d0			;d0.l = total byte count for saved pictures
	move.l	iz_entry_phystop(pc),a1
	sub.l	d0,a1			;a1 -> protection area for pictures
	move.l	a1,(phystop).w
	move.l	a1,(_memtop).w
	lea	saved_screens_t,a0	;a0 -> temporary area for pictures
	subq.l	#8,d0			;reduce move by 8 bytes for safety
	add.l	d0,a0			;a0 -> beyond first source byte
	add.l	d0,a1			;a1 -> beyond first byte destination
	lsr	#2,d0			;d0.l = longword count for saved pictures
protect_save_lp:
	move.l	-(a0),-(a1)		;this move allows region overlap !!!
	subq.l	#1,d0
	bne.s	protect_save_lp
	clr.l	(resvalid).w
	jmp	(a6)			;let system complete _soft_ reset
;
cmd_up_arrow_xxx:
	move.l	d0,d1
	move.l	grab_screen_p(pc),d0
	add.l	grab_step_size(pc),d0
	cmp.l	max_user_screen_p(pc),d0
	bhs.s	keep_grab
	bra.s	step_grab
;
cmd_dn_arrow_xxx:
	move.l	d0,d1
	move.l	grab_screen_p(pc),d0
	sub.l	grab_step_size(pc),d0
	bmi.s	keep_grab
step_grab:
	move.l	d0,grab_screen_p
keep_grab:
	tst.b	l0081
	beq	cmd_B_xxx
	bra	l0042
;
cmd_Alternate_xxx:
	move.l	d0,d1
	bsr	l006c
	bchg	#0,(hw_rez).w
	bra	grab_cmd_loop
;
cmd_lt_shift_xxx:
	move.l	d0,d1
	bsr	l006c
	bchg	#1,(hw_syn).w
	bra	grab_cmd_loop
;
cmd_1_xxx:
	move.l	d0,d1
	bchg	#0,l0080
	bra	cmd_B_xxx
;
cmd_2_xxx:
	move.l	d0,d1
	bchg	#1,l0080
	bra	cmd_B_xxx
;
cmd_3_xxx:
	move.l	d0,d1
	bchg	#2,l0080
	bra	cmd_B_xxx
;
cmd_4_xxx:
	move.l	d0,d1
	bchg	#3,l0080
	bra	cmd_B_xxx
;
cmd_num_0_xxx:
	move.l	d0,d1
	bchg	#0,l0082
	bchg	#0,l0081
	bra.s	cmd_F_xxx
;
cmd_num_1_xxx:
	move.l	d0,d1
	bchg	#1,l0082
	bchg	#0,l0081
	bra.s	cmd_F_xxx
;
cmd_num_2_xxx:
	move.l	d0,d1
	bchg	#2,l0082
	bchg	#0,l0081
	bra.s	cmd_F_xxx
;
cmd_num_3_xxx:
	move.l	d0,d1
	bchg	#3,l0082
	bchg	#0,l0081
	bra.s	cmd_F_xxx
;
cmd_num_point_xxx:
	move.l	d0,d1
	bchg	#0,l0083
	bchg	#0,l0081
	nop
cmd_F_xxx:
	move.l	d0,d1
	bchg	#0,l0081
	tst.b	l0081
	beq	cmd_B_xxx
	bra	l0042
;
cmd_F1_xxx:
	move.l	d0,d1
	move.l	#2,grab_step_size
	bra	grab_cmd_loop
;
cmd_F2_xxx:
	move.l	d0,d1
	move.l	#8,grab_step_size
	bra	grab_cmd_loop
;
cmd_F3_xxx:
	move.l	d0,d1
	move.l	#160/4,grab_step_size
	bra	grab_cmd_loop
;
cmd_F4_xxx:
	move.l	d0,d1
	move.l	#160,grab_step_size
	bra	grab_cmd_loop
;
cmd_F5_xxx:
	move.l	d0,d1
	move.l	#256,grab_step_size
	bra	grab_cmd_loop
;
cmd_F6_xxx:
	move.l	d0,d1
	move.l	#8*160,grab_step_size
	bra	grab_cmd_loop
;
cmd_F7_xxx:
	move.l	d0,d1
	move.l	#96*160,grab_step_size
	bra	grab_cmd_loop
;
cmd_F8_xxx:
	move.l	d0,d1
	move.l	#200*160,grab_step_size
	bra	grab_cmd_loop
;
l0041:
	bra	grab_cmd_loop
;
l0042:
	movea.l	grab_screen_p,a1
	movea.l	local_screen_p,a0
	move.l	#$3e7f,d0
l0043:
	clr.w	(a0)+
	dbra	d0,l0043
	tst.b	l0083
	bne	l004f
	movea.l	local_screen_p,a0
	moveq	#5,d2
l0044:
	moveq	#9,d3
l0045:
	moveq	#$1f,d0
l0046:
	btst	#0,l0082
	bne.s	l0047
	move.w	(a1)+,(a0)
l0047:
	btst	#1,l0082
	bne.s	l0048
	move.w	(a1)+,2(a0)
l0048:
	btst	#2,l0082
	bne.s	l0049
	move.w	(a1)+,4(a0)
l0049:
	btst	#3,l0082
	bne.s	l004a
	move.w	(a1)+,6(a0)
l004a:
	btst	#0,l0082
	bne.s	l004b
	move.w	(a1)+,8(a0)
l004b:
	btst	#1,l0082
	bne.s	l004c
	move.w	(a1)+,10(a0)
l004c:
	btst	#2,l0082
	bne.s	l004d
	move.w	(a1)+,12(a0)
l004d:
	btst	#3,l0082
	bne.s	l004e
	move.w	(a1)+,14(a0)
l004e:
	adda.l	#$a0,a0
	dbra	d0,l0046
	suba.l	#$1400,a0
	adda.l	#$10,a0
	dbra	d3,l0045
	suba.l	#$a0,a0
	adda.l	#$1400,a0
	dbra	d2,l0044
	bra	l0041
;
l004f:
	movea.l	local_screen_p,a0
	moveq	#$b,d2
l0050:
	moveq	#$13,d3
l0051:
	moveq	#$f,d0
l0052:
	btst	#0,l0082
	bne.s	l0053
	move.w	(a1)+,(a0)
l0053:
	btst	#1,l0082
	bne.s	l0054
	move.w	(a1)+,2(a0)
l0054:
	btst	#2,l0082
	bne.s	l0055
	move.w	(a1)+,4(a0)
l0055:
	btst	#3,l0082
	bne.s	l0056
	move.w	(a1)+,6(a0)
l0056:
	adda.l	#$a0,a0
	dbra	d0,l0052
	suba.l	#$a00,a0
	addq.l	#8,a0
	dbra	d3,l0051
	suba.l	#$a0,a0
	adda.l	#$a00,a0
	dbra	d2,l0050
	bra	l0041
;
cmd_H_xxx:
	bsr	l006c
	move.b	reset_hw_rez+1(pc),(hw_rez).w
	move.b	reset_hw_syn+1(pc),(hw_syn).w
	move.l	reset_hw_vbase(pc),d0
	move.l	d0,grab_screen_p
	movem.l	reset_hw_pal(pc),d0/d2-d7/a0
	movem.l	d0/d2-d7/a0,(hw_pal).w
	bra.s	cmd_B_xxx
;
cmd_R_xxx:
	move.l	d0,d1
	move.b	#$f,l0080
	clr.b	l0081
	move.l	(_v_bas_ad).w,grab_screen_p
cmd_B_xxx:
	clr.l	d0
	movea.l	grab_screen_p,a0
	movea.l	local_screen_p,a1
	move.l	#$f9f,d0
l0059:
	btst	#0,l0080
	beq.s	l005a
	move.w	(a0),(a1)
	bra.s	l005b
;
l005a:
	clr.w	(a1)
l005b:
	btst	#1,l0080
	beq.s	l005c
	move.w	2(a0),2(a1)
	bra.s	l005d
;
l005c:
	clr.w	2(a1)
l005d:
	btst	#2,l0080
	beq.s	l005e
	move.w	4(a0),4(a1)
	bra.s	l005f
;
l005e:
	clr.w	4(a1)
l005f:
	btst	#3,l0080
	beq.s	l0060
	move.w	6(a0),6(a1)
	bra.s	l0061
;
l0060:
	clr.w	6(a1)
l0061:
	addq.l	#8,a0
	addq.l	#8,a1
	dbra	d0,l0059
	bra	grab_cmd_loop
;
clear_psg:
	move.l	#$0003400,(hw_psgsel).w
	move.l	#$1000000,(hw_psgsel).w
	move.l	#$2000000,(hw_psgsel).w
	move.l	#$3000000,(hw_psgsel).w
	move.l	#$4000000,(hw_psgsel).w
	move.l	#$5000000,(hw_psgsel).w
	move.l	#$6000000,(hw_psgsel).w
	move.l	#$700be00,(hw_psgsel).w	;BUG !!! makes port A = inputs
	move.l	#$8001000,(hw_psgsel).w
	move.l	#$9000000,(hw_psgsel).w
	move.l	#$a000000,(hw_psgsel).w
	move.l	#$b000000,(hw_psgsel).w
	move.l	#$c001600,(hw_psgsel).w
	move.l	#$d000900,(hw_psgsel).w
	rts
;
;
	btst	#1,l0080
	bne.s	.l0064
	movea.l	local_screen_p,a0
	move.l	#$f9f,d0
.l0063:
	clr.w	(a0)
	addq.l	#8,a0
	dbra	d0,.l0063
.l0064:
	btst	#1,l0080
	bne.s	.l0066
	movea.l	local_screen_p,a0
	addq.l	#2,a0
	move.l	#$f9f,d0
.l0065:
	clr.w	(a0)
	addq.l	#8,a0
	dbra	d0,.l0065
.l0066:
	btst	#2,l0080
	bne.s	.l0068
	movea.l	local_screen_p,a0
	addq.l	#4,a0
	move.l	#$f9f,d0
.l0067:
	clr.w	(a0)
	addq.l	#8,a0
	dbra	d0,.l0067
.l0068:
	btst	#3,l0080
	bne.s	.l006a
	movea.l	local_screen_p,a0
	addq.l	#6,a0
	move.l	#$f9f,d0
.l0069:
	clr.w	(a0)
	addq.l	#8,a0
	dbra	d0,.l0069
.l006a:
	rts
;
;----------------------------------------------------------------------------
;
	XB_define	grab_vbi,'PGRA'
	clr.w	l008c
	rte
;
;----------------------------------------------------------------------------
;
l006c:
	move	sr,-(sp)
	move.w	#-1,l008c
	move	#$2000,sr
.l006d:
	tst.w	l008c
	bne.s	.l006d
	move	(sp)+,sr
	rts
;
;
;----------------------------------------------------------------------------
	SECTION	data
;----------------------------------------------------------------------------
prog_title_s:
	dc.b	ESC,'E'
	dc.b	'******* Picture Grabber V. 1.123 *******',LF,CR
	dc.b	LF,CR
	dc.b	'             Public Domain!             ',LF,CR
	dc.b	LF,CR
	dc.b	'Written by:',HT,'Pontus Sk”ld',HT,' ',LF,CR
	dc.b	HT,HT,'PL 521',HT,HT,HT,' ',LF,CR
	dc.b	HT,HT,'770 73 G-berg',HT,HT,' ',LF,CR
	dc.b	HT,HT,'Sweden',HT,HT,HT,' ',LF,CR
	dc.b	LF,CR
	dc.b	' Press I to toggle interupts on / off...',LF,CR
	dc.b	' Press B to boot a disc...              ',LF,CR
	dc.b	' Press any other key to return to desk. ',LF,CR
	dc.b	LF,CR
	dc.b	' Interupts are now on!',LF,CR
	dc.b	LF,CR
	dc.b	' Read the doc file...',BEL
	dc.b	ESC,'YQ+','Well, press a key!'
	dc.b	NUL
;
grabber_id:
	dc.b	'Picture Grabber!'
;
;
boot_prompt_s:
	dc.b	ESC,'E'
	dc.b	'Please insert disc to boot from         ',LF,CR
	dc.b	'and bash any key ... '
	dc.b	NUL
;
clear_screen_s:
	dc.b	ESC,'E',NUL
;
boot_missing_s:
	dc.b	ESC,'E'
	dc.b	"This disc hasn't got an executeable",LF,CR
	dc.b	'bootsector !!! Boot Aborted !!!'
	dc.b	NUL
	EVEN
;
on_off_s_t:
	dc.l	on_s
	dc.l	off_s
;
on_s:
	dc.b	ESC,'Y-3','on! ',NUL
;
off_s:
	dc.b	ESC,'Y-3','off!',NUL
;----------------------------------------------------------------------------
	SECTION	bss
;----------------------------------------------------------------------------
iz_entry_ssp:
	ds.l	1
iz_entry_phystop:
	ds.l	1
reset_hw_vbase:
	ds.l	1
reset_hw_syn:
	ds.w	1
reset_hw_rez:
	ds.w	1
reset_hw_pal:
	ds.w	16
now_saved:
	ds.w	1
max_saved_f:
	ds.w	1
max_user_screen_p:
	ds.l	1
grab_screen_p:
	ds.l	1
local_screen_p:		;->base of screen buffer (in boot_sector_bf..raw_screen_bf)
	ds.l	1
grab_step_size:
	ds.l	1
l0080:
	ds.b	1
l0081:
	ds.b	1
l0082:
	ds.b	1
l0083:
	ds.b	1
l0088:
	ds.w	1
l008c:
	ds.w	1
loc_stack_beg:
	ds.b	200
loc_stack_end:
	ds.b	24
boot_sector_bf:		;boot sector buffer and first part of screen buffer
	ds.b	512
raw_screen_bf:		;main part of screen buffer
	ds.b	32256
;
saved_screens_t:
	ds.b	(max_saved*$8000)
;
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	PG.S
;----------------------------------------------------------------------------
