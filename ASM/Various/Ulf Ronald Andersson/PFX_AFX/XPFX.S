;----------------------------------------------------------------------------
;File name:	xPFX.S			Revised:	1996.08.05
;Revised by:	Ulf Ronald Andersson	Revision date:	1992.08.21
;Release:	2.1.L			Release date:	beta
;----------------------------------------------------------------------------
;
	include	URAn_APP.S
	include URAn_SIM.S
;
;----------------------------------------------------------------------------
;
init_app:
	include	URAn_ARG.S
	tst	tos_flag
	bmi.s	.no_gem_init
	bsr	main_obfix
.no_gem_init:
	rts
;
;----------------------------------------------------------------------------
;
exec_app:
	moveq	#0,d0
	bsr	turn_AFX
	move	#4,newdef_obj
	bios	Kbshift,?
	move	d0,kbshift_f
	move	#NORMAL,d1
	and	#$0F,d0
	cmp	#1,d0		;R_shift = AFX pack all
	beq.s	.got_afx_all
	cmp	#8,d0		;ALT key = AFX pack all
	bne.s	.not_afx_all
.got_afx_all:
	or	#SELECTED,d1
.not_afx_all:
	move	d1,all_afx_status
	move	#1,d1
	cmp	#2,d0		;L_shift = Unpack files
	beq.s	.got_unpack
	cmp	#4,d0		;CTL key = Unpack files
	bne.s	.not_unpack
.got_unpack:
	move	#2,d1
.not_unpack:
	move	d1,argwrk_obj	;1=pack  2=unpack
	tst	d0
	beq.s	.keep_default
	move	d1,newdef_obj
.keep_default:
	move	arg_cnt(pc),d0
	subq	#1,d0
	move	d0,parm_cnt
	beq.s	.no_parms
	bsr	workparms
	bra	exit_xpfx
;
.no_parms:
	tst	tos_flag
	bpl.s	.no_parms_gem
.no_parms_tos:
	gemdos	Cconws,tos_usage_s(pc)
	bra.s	exit_xpfx
;
.no_parms_gem:	
	clr.b	fsel_path
	bsr	LE1E
	move.l	sp,norm_sp
	clr.l	addrin
	clr	intin
	move.l	#$4E010101,d0	;graf_mouse
	bsr	call_aes
	bsr	create_box
	move.l	sp,main_sp
	lea	main_loop(pc),a0
	move.l	a0,main_link
main_loop:
	move.l	main_sp(pc),sp
	lea	main_form(pc),a6
	move	default_obj(pc),d0
	mulu	#24,d0
	and	#-1-DEFAULT,8(a6,d0)
	move	newdef_obj(pc),d0
	mulu	#24,d0
	or	#DEFAULT,8(a6,d0)
	move	newdef_obj(pc),default_obj
	move.l	norm_sp(pc),sp	reinit_sp
	bsr	fix_afx_info
	bsr	use_form_a6
	bsr.s	main_commands
	tst.l	d0
	bpl.s	main_loop
	clr.l	d0
exit_xpfx:
	move.l	AFX_state(pc),d0
	bsr	turn_AFX
	clr.l	d0
	rts
;
;----------------------------------------------------------------------------
;
main_commands:
	cmp	#1,d0
	beq.s	main_pack
	cmp	#2,d0
	beq.s	main_unpack
	cmp	#5,d0
	beq.s	main_info
	cmp	#4,d0
	beq.s	main_exit
	cmp	#12,d0
	beq.s	main_afx_info
	clr.l	d0
	rts
;
main_pack:
	move	d0,newdef_obj
	bsr	main_pack_sub
	clr.l	d0
	rts
;
main_unpack:
	move	d0,newdef_obj
	bsr	main_unpack_sub
	clr.l	d0
	rts
;
main_info:
	lea	info1_form(pc),a6
	bsr	use_form_a6
	lea	info2_form(pc),a6
	bsr	use_form_a6
	clr.l	d0
	rts
;
main_exit:
	bsr	close_box
	bsr	delete_box
	moveq	#-1,d0
	rts
;
;
main_afx_info:
	move	AFX_flag(pc),d0
	bpl.s	.change_lock_old
	move.l	AFX_lock,d1
	move.l	AFX_ptr(pc),a0
	sf	-4(a0)
	move.l	-4(a0),AFX_lock
	moveq	#3,d0
	tst.l	d1
	bne.s	.lock_changed
.change_lock_old:
	move.b	AFX_state+3,d0
	addq.b	#1,d0
	and.b	#3,d0
	cmp.b	#2,d0
	bne.s	.lock_changed
	move.b	#3,d0
.lock_changed:
	move.l	d0,AFX_state
.main_afx_exit:
	clr.l	d0
	rts
;
;----------------------------------------------------------------------------
;
star_star_s:	dc.b	'*.*',NUL
		even
parm_cnt:	ds.w	1
parm_ptr:	ds.l	1
parm_ix:	ds.w	1
path_lev:	ds.w	1
nonparm_dta_p:	ds.l	1
pathdta_t:	ds.b	8*dta_size
;
;
workparms:
	move.l	sp,main_sp
	lea	work_error(pc),a0
	move.l	a0,main_link
	gemdos	Fgetdta
	move.l	d0,nonparm_dta_p
	move.l	arg_ptr,a0
.loop_1:
	tst.b	(a0)+
	bne.s	.loop_1
	move.l	a0,parm_ptr
	clr	parm_ix
parms_lp:
	move.l	parm_ptr,a0
	lea	parm_path,a1
	bsr	strcpy_a0_a1
	move.l	a0,parm_ptr
	clr	path_lev
parm_lp:
	move	path_lev,d0
	mulu	#dta_size,d0
	lea	pathdta_t,a0
	lea	(a0,d0),a3
	gemdos	Fsetdta,(a3)
	lea	parm_path,a0
	bsr	lastslash_a0
	beq	next_parm
	tst.b	(a1)
	beq.s	try_dir
	move	#$20,d3
	bsr	scanwild_a0
	bne.s	try_files
	gemdos	Fsfirst,parm_path,#$10
	move	#$20,d3
	tst.l	d0
	bmi.s	try_files
	btst	#4,dta_fattr(a3)
	beq.s	try_files
	lea	parm_path,a1
.loop:
	tst.b	(a1)+
	bne.s	.loop
	subq	#1,a1
	move.b	#'\',(a1)+
try_dir:
	lea	star_star_s,a0
	bsr	strcpy_a0_a1
	move	#$10,d3
try_files:
	gemdos	Fsfirst,parm_path,d3
fileparm_lp:
	tst.l	d0
	bmi.s	prev_lev
	btst	#4,dta_fattr(a3)
	beq	work_file
	cmp.b	#'.',dta_fname(a3)
	beq	next_file
	lea	parm_path,a0
	bsr	pad_filename
	ble	next_file
	move.b	#'\',-1(a1)
	clr.b	(a1)
	addq	#1,path_lev
	cmp	#8,path_lev
	blo	parm_lp
prev_lev:
	move	path_lev,d0
	beq	next_parm
	lea	parm_path,a0
	bsr	lastslash_a0
	beq	next_parm
	clr.b	-(a1)
	bsr	lastslash_a0
	beq	next_parm
	clr.b	(a1)
	subq	#1,path_lev
	lea	star_star_s,a0
	bsr	strcpy_a0_a1
	move	#$30,d1
	move	path_lev,d0
	mulu	#dta_size,d0
	lea	pathdta_t,a0
	lea	(a0,d0),a3
	gemdos	Fsetdta,(a3)
	gemdos	Fsnext
	bra	fileparm_lp
;
work_file:
	bsr	cpy_parmpath
	lea	fsel_path(pc),a0
	bsr.s	pad_filename
	ble.s	next_file
	gemdos	Fsetdta|_ind,nonparm_dta_p(pc)
	movem.l	d3-d7/a3-a6,-(sp)
	lea	main_pack_sub(pc),a0
	cmp	#1,argwrk_obj
	beq.s	.do_it
	lea	main_unpack_sub(pc),a0
.do_it:
	jsr	(a0)
	movem.l	(sp)+,d3-d7/a3-a6
	gemdos	Fsetdta,(a3)
next_file:
	gemdos	Fsnext
	bra	fileparm_lp
;
next_parm:
	addq	#1,parm_ix
	move	parm_ix,d0
	cmp	parm_cnt,d0
	blo	parms_lp
	gemdos	Fsetdta|_ind,nonparm_dta_p(pc)
	clr.l	d0
	rts
;
;
work_error:
	move.l	main_sp(pc),sp
	moveq	#-1,d0
	rts
;
;
pad_filename:
	bsr.s	lastslash_a0
	move.l	a1,-(sp)
	lea	dta_fname(a3),a0
.loop:	move.b	(a0)+,(a1)+
	beq.s	.exit
	cmp.b	#' ',-1(a1)
	bne.s	.loop
	subq	#1,a1
	bra.s	.loop
;
.exit:
	move.l	a1,d0
	sub.l	(sp)+,d0
	subq	#2,d0
	rts
;
;
cpy_parmpath:
	lea	parm_path,a0
	lea	fsel_path,a1
strcpy_a0_a1:
	move.b	(a0)+,(a1)+
	bne.s	strcpy_a0_a1
	rts
;
;
lastslash_a0:
	moveq	#1,d0
	movem.l	d0/a0,-(sp)
.loop:
	move.b	(a0)+,d0
	beq.s	.exit
	cmp.b	#'\',d0
	bne.s	.loop
	move.l	a0,(sp)
	bra.s	.loop
;
.exit:
	movem.l	(sp)+,d0/a0
	move.l	d0,a1
	subq.l	#1,d0
	rts
;
;
scanwild_a0:
	clr.l	-(sp)
.loop:
	move.b	(a0)+,d0
	beq.s	.exit
	cmp.b	#'*',d0
	beq.s	.set
	cmp.b	#'?',d0
	bne.s	.loop
.set:
	move.l	#-1,(sp)
	bra.s	.loop
;
.exit:
	move.l	(sp)+,d0
	rts
;
;
;----------------------------------------------------------------------------
;
;
main_pack_sub:
	lea	sel_pack_s(pc),a0
	move.l	a0,prompt_p
	bsr	main_fselect_sub
	clr.l	fsize_to_pack
	clr.l	L3150
	clr.l	L27BE
	clr.l	L27C2
	clr.l	L27C6
	clr.l	L27AE
	clr.l	L27B6
	clr.l	L27B2
	move.l	#'-lz5',pack_method
	lea	str_buff(pc),a1
	move.l	a0,-(sp)
	bsr	strcpy_a0_a1
	move.l	(sp)+,a0
	lea	no_inspec_s(pc),a1
	tst.b	(a0)
	beq	err_alert_a1
	lea	file_not_found_s(pc),a1
	bsr	safe_fsfirst
	bne	err_alert_a1
	move.l	d2,d0			;d0 = size of found file
	cmp.l	#1024,d0		;more than one cluster ?
	bgt.s	.try_pack		;only pack files > 1 cluster
	rts
;
.try_pack:
	move.l	d0,orig_size
	move.l	d0,fsize_to_pack
	move.l	a0,-(sp)
	lea	pack_orig_size(pc),a0
	move.l	d2,d0
	bsr	safe_movel_d0_ia0
	bsr	L420
	move.l	d0,L27B2
	clr.l	L27BE
	bsr	safe_malloc_d0
	lea	no_memory_s(pc),a1
	tst.l	d0
	bmi	err_alert_a1
	move.l	d0,L27B6
	move.l	d0,L27AE
	move.l	d0,L2E62
	move.l	(sp)+,a0
	bsr	fopen_input_a0
	move.l	L27B6(pc),a0
	move.l	L27B2(pc),d0
	move.l	a0,L3150
	move.l	d0,L314C
	bsr	safe_fread_d7_d0_a0
	bsr	safe_fclose_d7
	move.l	L27B6(pc),a0
	tst	fastload_f
	beq.s	.L1C0
	bset	#0,ph_flag+3(a0)
.L1C0:
	move.l	ph_textlen(a0),d0
	add.l	ph_datalen(a0),d0
	add.l	ph_bss_len(a0),d0	;d0 = total ST RAM reserved for possible program
	move.l	d0,LA3AE
	cmpi.l	#'-afx',2(a0)
	bne.s	.try_pfx
	cmpi.b	#'-',6(a0)
	bne.s	.try_pfx
.pre_packed:
	tst	parm_cnt
	bne	no_write_2
	lea	already_packed_s(pc),a1
	bra	err_alert_a1
;
.try_pfx:
	lea	30(a0),a0
	lea	pfx_head_s(pc),a2
.L1DE:
	tst.b	(a2)
	beq.s	.pre_packed
	cmpm.b	(a0)+,(a2)+
	beq.s	.L1DE
	moveq	#-1,d0
	bsr	safe_malloc_d0
	sub.l	#$4E20,d0
	bsr	safe_malloc_d0
	move.l	d0,a6
	move.l	d0,L27C6
	move.l	d0,L2E66
	move.l	d0,a0
	move.l	d0,a3
	move.l	L3150(pc),a2
	tst	all_afx_status
	bne.s	.pack_all_afx
	bsr	test_proghead
	beq.s	.pack_program
	lea	data_pack_s(pc),a4
.pack_some_afx:
	move.l	#'-afx',pack_method
	bsr	L3EC
	bra.s	.pack_common
;
.pack_all_afx:
	lea	all_afx_pack_s(pc),a4
	bra.s	.pack_some_afx
;
.pack_program:
	move.l	#'-lz5',pack_method
	lea	prog_pack_s(pc),a4
	bsr	L3EC
	lea	PFX_11_code(pc),a1
	lea	PFX_11_end(pc),a2
.L262:
	move.b	(a1)+,(a0)+
	cmp.l	a1,a2
	bne.s	.L262
.pack_common:
	lea	pack_header(pc),a1
	lea	pack_header_end(pc),a2
	move.l	a0,a4
.L272:
	move.b	(a1)+,(a0)+
	cmp.l	a1,a2
	bne.s	.L272
	bsr	pad_name_header
	move.l	a0,L2E5A
	addq.l	#2,a0
	move.l	a0,-(sp)
	move.l	a0,L27C2
	bsr	L72A
	moveq	#100,d0
	moveq	#100,d1
	bsr	show_pack_form
	move.l	L27C2(pc),d0
	move	d0,d3
	addq.l	#1,d0
	and.b	#$FE,d0
	move.l	d0,a0
	sub.l	(sp)+,d0
	cmpi.l	#'-afx',pack_method
	beq.s	.L2C8
	clr.l	(a0)+
	move.l	a0,d1
	sub.l	a3,d1
	sub.l	#$24C,d1
	move.l	d1,ph_datalen(a3)
.L2C8:
	move.l	L27BE(pc),d0
	lea	7(a4),a0
	bsr	safe_movel_d0_ia0
	cmpi.l	#'-afx',pack_method
	beq.s	.write_data_pack
.write_prog_pack:
	move.l	ph_textlen(a3),d0
	add.l	ph_datalen(a3),d0
	move.l	(LA3AE).l,d1
	sub.l	d0,d1
	move.l	d1,ph_bss_len(a3)
	add.l	#32,d0			;d0 = packed size
	bra.s	.write_common
;
.write_data_pack:
	move.l	L27BE(pc),d0
	clr.l	d1
	move.b	(a3),d1
	add.l	d1,d0
	addq.l	#2,d0			;d0 = packed size

.write_common:
	bsr	undial_p_form
;
	move.l	orig_size(pc),d1	;d1 = size before packing
	lea	too_long_pack_s(pc),a1
	subq.l	#1,d1			;\
	and	#-$400,d1		; > Demand cluster savings
	addq.l	#1,d1			;/
	cmp.l	d1,d0
	blt.s	.write_packed
	tst	parm_cnt
	beq	err_alert_a1
	bra.s	no_write
;
.write_packed:
	move.l	d0,dest_size
	bsr.s	show_size_ask_save
	bne.s	no_write
	bsr.s	write_dest_fsel
	move	L3076(pc),d1
	move.l	L2E5A(pc),a1
	move.b	d1,(a1)
	lsr.w	#8,d1
	move.b	d1,1(a1)
	move.l	a4,a1
	bsr	L402
	bsr	safe_fcreate_a0_0
	move.l	a3,a0
write_end:
	bsr	safe_fwrite_d7_d0_a0
	bsr	safe_fclose_d7
no_write:
	move.l	L2E66(pc),a0
	bsr	safe_mfree_a0
no_write_2:
	move.l	L2E62(pc),a0
	bsr	safe_mfree_a0
	rts
;
show_size_ask_save:
	tst	parm_cnt
	bne.s	.always_ok
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	orig_size(pc),d0
	lea	orig_size_num_s(pc),a0
	bsr	ultoa
	move.l	dest_size(pc),d0
	lea	dest_size_num_s(pc),a0
	bsr	ultoa
	lea	packed_form(pc),a6
	bsr	use_form_a6
	cmp	#6,d0		;object 6: 'OK' ?
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
.always_ok:
	cmp	d0,d0
	rts
;
;
write_dest_fsel:
	movem.l	d0-d7/a1-a6,-(sp)
	lea	sel_dest_s(pc),a0
	move.l	a0,prompt_p
	bsr	main_fselect_sub
	lea	no_outspec_s(pc),a1
	tst.b	(a0)
	beq	err_alert_a1
	cmpi.b	#$D,(a0)
	beq	err_alert_a1
	movem.l	(sp)+,d0-d7/a1-a6
	rts
;
;
test_proghead:
	movem.l	d0-d1/a0,-(sp)
	move.l	fsize_to_pack(pc),d0
	cmp.l	#ph_textbeg+2,d0
	blt.s	.non_prog			;program must have header + code
	cmpi.b	#$60,(a2)
	bne.s	.non_prog			;header must start with 'BRA.S'
	clr.l	d0
	move.b	1(a2),d0
	beq.s	.non_prog			;so 'BRA.L' is also illegal
	bmi.s	.non_prog			;the destination must be forward
	btst	#0,d0
	bne.s	.non_prog			;the destination must be even
	sub.b	#ph_textbeg-2,d0
	blt.s	.non_prog			;the destination must be beyond header
	cmp.l	ph_textlen(a2),d0
	blt.s	.test_more
	moveq	#-1,d0
	bra.s	.non_prog			;the destination must be within code
;
.test_more:	;Here the header branch has been verified and accepted	
	move.l	ph_textlen(a2),d0
	add.l	ph_datalen(a2),d0
	bcs.s	.non_prog
	add.l	ph_bss_len(a2),d0
	bcs.s	.non_prog
	add.l	ph_symblen(a2),d0
	bcs.s	.non_prog
	and.l	#$FF000000,d0
	bne.s	.non_prog		;total storage must be less than 16 MByte
;If all the above requirements are filled, the file is assumed to be a program
	clr.l	d0			;flag EQ
	movem.l	(sp)+,d0-d1/a0
	rts
;
.non_prog:
	moveq	#-1,d0			;flag NE
	movem.l	(sp)+,d0-d1/a0
	rts
;
;
L3EC:
	movem.l	d0/a0,-(sp)
	lea	file_pack_s(pc),a0
L3F4:
	move.b	(a4)+,d0
	beq.s	L3FC
	move.b	d0,(a0)+
	bra.s	L3F4
;
L3FC:
	movem.l	(sp)+,d0/a0
	rts
;
;
L402:
	movem.l	d0-d1/a0-a1,-(sp)
	clr.l	d0
	clr.l	d1
	move.b	(a1)+,d1
	move.l	a1,a0
	clr.b	(a0)+
	subq	#1,d1
L412:
	add.b	(a0)+,d0
	dbra	d1,L412
	move.b	d0,(a1)
	movem.l	(sp)+,d0-d1/a0-a1
	rts
;
;
L420:
	movem.l	d0-d1/a0,-(sp)
	lea	pack_header(pc),a0
	move	L316C(pc),d0
	move.b	d0,17(a0)
	lsr.w	#8,d0
	move.b	d0,18(a0)
	move	L316A(pc),d0
	move.b	d0,15(a0)
	lsr.w	#8,d0
	move.b	d0,16(a0)
	move.b	L3169(pc),d0
	move.b	d0,L2E4B
	movem.l	(sp)+,d0-d1/a0
	rts
;
;
pad_name_header:
	movem.l	d0-d1/a1-a3,-(sp)
	lea	str_buff(pc),a1
	move.l	a1,a2
.pad_lp1:
	tst.b	(a1)+
	bne.s	.pad_lp1
	moveq	#'\',d0
	moveq	#':',d1
.pad_lp2:
	cmp.b	-(a1),d0
	beq.s	.pad_ex2
	cmp.b	(a1),d1
	beq.s	.pad_ex2
	cmp.l	a2,a1
	bhs.s	.pad_lp2
.pad_ex2:
	addq	#1,a1
	moveq	#0,d1
.L470:
	move.b	(a1)+,d0
	beq.s	L47A
	addq.b	#1,d1
	move.b	d0,(a0)+
	bra.s	.L470
;
L47A:
	move.b	d1,21(a4)
	add.b	#22,d1
	move.b	d1,(a4)
	movem.l	(sp)+,d0-d1/a1-a3
	rts
;
;
safe_movel_d0_ia0:
	movem.l	d0-d1/a0,-(sp)
	moveq	#3,d1
.L490:
	move.b	d0,(a0)+
	lsr.l	#8,d0
	dbra	d1,.L490
	movem.l	(sp)+,d0-d1/a0
	rts
;
;
err_alert_a1:
	bsr.s	show_alert_sub
free_work_go_main:
	move.l	L27AE(pc),a0
	bsr	safe_mfree_a0
	move.l	L27C6(pc),a0
	bsr	safe_mfree_a0
	bra.s	go_main_link
;
show_alert_a1:
	bsr.s	show_alert_sub
go_main_link:
	move.l	main_link(pc),-(sp)
	rts
;
;
show_alert_sub:
	lea	master_alert_s(pc),a0
	lea	str_buff(pc),a2
	move.l	a2,addrin
L4AC:
	move.b	(a0)+,d0
	beq.s	L4C2
	cmp.b	#'~',d0
	beq.s	L4BA
	move.b	d0,(a2)+
	bra.s	L4AC
;
L4BA:
	move.b	(a1)+,(a2)+
	bne.s	L4BA
	subq	#1,a2
	bra.s	L4AC
;
L4C2:
	sim_aes	form_alert,#1,str_buff(pc)
	rts
;
;
master_alert_s:
	dc.b	'[1][|~][Exit]',NUL
no_workst_s:
	dc.b	'No workstation available',NUL
no_inspec_s:
	dc.b	'No input file was specified',NUL
file_not_found_s:
	dc.b	'File was not found',NUL
no_memory_s:
	dc.b	'No memory for Program',NUL
no_outspec_s:
	dc.b	'No output file was specified',NUL
too_long_pack_s:
	dc.b	'Packed file became longer,|'
	dc.b	'so it will not be stored.',NUL
err_open_s:
	dc.b	'Error at Open',NUL
err_create_s:
	dc.b	'Error at Create',NUL
err_write_s:
	dc.b	'Error at Write',NUL
err_read_s:
	dc.b	'Error at Read',NUL
err_fsel_s:
	dc.b	'Error in file selection !',NUL
already_packed_s:
	dc.b	'File is already packed !  ',NUL
already_unpacked_s:
	dc.b	'File is already unpacked !',NUL
crlf_s:
	dc.b	CR,LF,NUL
	even
;
;
ultoa:
	movem.l	d0-d4/a0-a2,-(sp)
	clr	d4
	lea	.L662(pc),a1
	moveq	#9,d3
.L62E:
	moveq	#-1,d1
	move.l	(a1)+,d2
.L632:
	add	#1,d1
	sub.l	d2,d0
	bge.s	.L632
	add.l	d2,d0
	tst	d1
	bne.s	.L644
	tst	d4
	beq.s	.L64E
.L644:
	moveq	#1,d4
	add	#'0',d1
	move.b	d1,(a0)+
.L64E:
	dbra	d3,.L62E
	tst	d4
	bne.s	.L65A
	move.b	#'0',(a0)+
.L65A:
	clr.b	(a0)+
	movem.l	(sp)+,d0-d4/a0-a2
	rts
;
.L662:
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1
;
;
L72A:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	L884
	lea	L3186(pc),a2
L736:
	lea	L5188(pc),a3
L73A:
	lea	(L938C).l,a5
	move.l	L27B2(pc),d4
	lea	(LA39D).l,a4
L74A:
	clr.b	(a4)
	moveq	#1,d2
	moveq	#1,d7
	moveq	#0,d5
	move	#$FEE,d6
	lea	(L938C).l,a6
	move.l	a6,a0
	move	#$FED,d7
L762:
	move.b	#32,(a0)+
	dbra	d7,L762
	moveq	#0,d4
	lea	4078(a6),a0
L770:
	bsr	LC7A
	beq.s	L780
	move.b	d0,(a0)+
	addq	#1,d4
	cmp	#$12,d4
	blt.s	L770
L780:
	tst	d4
	beq	L87A
	move	#$FED,d6
	move	#$11,d7
L78E:
	bsr	L956
	subq	#1,d6
L794:
	dbra	d7,L78E
	move	#$FEE,d6
	bsr	LA0C
	moveq	#1,d7
L7A2:
	lea	L3182(pc),a0
	cmp	(a0),d4
	bgt.s	L7AC
	move	d4,(a0)
L7AC:
	cmpi	#2,(a0)
	bgt.s	L7C2
	move	#1,(a0)
	or.b	d7,(a4)
	move.b	0(a6,d6.w),0(a4,d2.w)
	addq	#1,d2
	bra.s	L7E0
;
L7C2:
	move	L3180(pc),d0
	move.b	d0,0(a4,d2.w)
	lsr.w	#4,d0
	and	#$F0,d0
	move	L3182(pc),d1
	sub	#3,d1
	or	d1,d0
	move.b	d0,1(a4,d2.w)
	addq	#2,d2
L7E0:
	add.b	d7,d7
	bne.s	L7F6
	moveq	#0,d1
	move	d2,d0
	move.l	a4,a0
	subq	#1,d0
	bsr	LC54
	clr.b	(a4)
	moveq	#1,d2
	moveq	#1,d7
L7F6:
	lea	L3184(pc),a0
	move	L3182(pc),(a0)
	moveq	#1,d1
L800:
	cmp	(a0),d1
	bgt.s	L83E
	bsr	LC7A
	beq.s	L880
	addq	#1,d1
	bsr	L8BC
	cmp	#$11,d5
	bge.s	L81E
	lea	4096(a6),a1
	move.b	d0,0(a1,d5.w)
L81E:
	move.b	d0,0(a6,d5.w)
	addq	#1,d5
	and	#$FFF,d5
	addq	#1,d6
	and	#$FFF,d6
	cmp	(a0),d1
	blt.s	L838
	bsr	LA0C
	bra.s	L800
L838:
	bsr	L956
	bra.s	L800
;
L83E:
	addq	#1,d1
	cmp	L3184(pc),d1
	bgt.s	L862
	bsr.s	L8BC
	addq	#1,d5
	and	#$FFF,d5
	addq	#1,d6
	and	#$FFF,d6
	move	d4,d0
	subq	#1,d4
	tst	d0
	beq.s	L83E
	bsr	LA0C
	bra.s	L83E
;
L862:
	cmpi	#1,d4
	bge	L7A2
	moveq	#0,d1
L86C:
	move.b	0(a4,d1.w),d0
	bsr	LC3A
	addq	#1,d1
	cmp	d2,d1
	blt.s	L86C
L87A:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
L880:
	subq	#1,d1
	bra.s	L83E
;
L884:
	move	#$1001,d0
	lea	L5188(pc),a0
	bra.s	L89A
L88E:
	move	d0,d1
	add	d1,d1
	move	#$2000,0(a0,d1.w)
	addq	#1,d0
L89A:
	cmp	#$1100,d0
	ble.s	L88E
	clr	d0
	bra.s	L8B4
;
L8A4:
	move	d0,d1
	add	d1,d1
	lea	8706(a0),a1
	move	#$2000,0(a1,d1.w)
	addq	#1,d0
L8B4:
	cmp	#$1000,d0
	blt.s	L8A4
	rts
;
L8BC:
	movem.l	d1-d3/d5-d7/a0-a1/a4-a6,-(sp)
	move	#$2000,d7
	lea	L738A(pc),a0
	add	d5,d5
	cmp	0(a0,d5.w),d7
	beq.s	L944
	cmp	0(a3,d5.w),d7
	beq.s	L950
	cmp	0(a2,d5.w),d7
	beq.s	L94A
	lea	0(a2,d5.w),a4
	lea	0(a3,d5.w),a5
	move	(a4),d1
	move	d1,d2
	cmp	0(a3,d2.w),d7
	beq.s	L916
L8EE:
	move	d2,d1
	move	0(a3,d2.w),d2
	cmp	d7,d2
	bne.s	L8EE
	move	d1,d2
	move	0(a0,d2.w),d3
	lea	0(a2,d2.w),a1
	move	(a1),0(a3,d3.w)
	move	(a1),d3
	move	0(a0,d2.w),0(a0,d3.w)
	move	(a4),d3
	move	d3,(a1)
	move	d1,0(a0,d3.w)
L916:
	move	(a5),d3
	move	d3,0(a3,d2.w)
	move	d1,0(a0,d3.w)
L920:
	move	0(a0,d5.w),0(a0,d1.w)
	lea	0(a0,d5.w),a5
	move	(a5),d3
	cmp	0(a3,d3.w),d5
	bne.s	L93E
	move	d1,0(a3,d3.w)
	move	d7,(a5)
	movem.l	(sp)+,d1-d3/d5-d7/a0-a1/a4-a6
	rts
;
L93E:
	move	d1,0(a2,d3.w)
	move	d7,(a5)
L944:
	movem.l	(sp)+,d1-d3/d5-d7/a0-a1/a4-a6
	rts
;
L94A:
	move	0(a3,d5.w),d1
	bra.s	L920
;
L950:
	move	0(a2,d5.w),d1
	bra.s	L920
;
L956:
	movem.l	d2-d3/d6-d7/a0-a1/a4/a6,-(sp)
	lea	0(a5,d6.w),a1
	add	d6,d6
	moveq	#0,d2
	move.b	(a1)+,d2
	add	#$1001,d2
	add	d2,d2
	move	#$2000,d7
	move	d7,0(a2,d6.w)
	move	d7,0(a3,d6.w)
	lea	L738A(pc),a4
L97A:
	move	d2,a6
	move	0(a3,d2.w),d2
	cmp	d2,d7
	bne.s	L9A4
	move	d6,0(a3,a6.w)
	move	a6,0(a4,d6.w)
	bra.s	L9FA
;
L98E:
	move	d6,0(a2,a6.w)
	move	a6,0(a4,d6.w)
	bra.s	L9FA
L998:
	bls.b	L97A
L99A:
	move	d2,a6
	move	0(a2,d2.w),d2
	cmp	d2,d7
	beq.s	L98E
L9A4:
	move.l	a1,a0
	lsr.w	#1,d2
	lea	1(a5,d2.w),a6
	add	d2,d2
	cmpm.b	(a0)+,(a6)+
	bne.s	L998
	cmpm.b	(a0)+,(a6)+
	bne.s	L998
	cmpm.b	(a0)+,(a6)+
	bne.s	L998
	moveq	#13,d3
L9BC:
	cmpm.b	(a0)+,(a6)+
	dbne	d3,L9BC
	beq.s	L9C8
	bhi.b	L99A
	bra.s	L97A
;
L9C8:
	move	0(a4,d2.w),0(a4,d6.w)
	move	0(a2,d2.w),d0
	move	d0,0(a2,d6.w)
	move	d6,0(a4,d0.w)
	move	0(a3,d2.w),d0
	move	d0,0(a3,d6.w)
	move	d6,0(a4,d0.w)
	lea	0(a4,d2.w),a6
	move	(a6),d0
	cmp	0(a3,d0.w),d2
	beq.s	LA00
	move	(a6),d3
	move	d6,0(a2,d3.w)
	move	d7,(a6)
L9FA:
	movem.l	(sp)+,d2-d3/d6-d7/a0-a1/a4/a6
	rts
;
LA00:
	move	d6,0(a3,d0.w)
	move	d7,(a6)
	movem.l	(sp)+,d2-d3/d6-d7/a0-a1/a4/a6
	rts
;
LA0C:
	movem.l	d0-d7/a0-a1/a4/a6,-(sp)
	moveq	#1,d1
	lea	0(a5,d6.w),a1
	add	d6,d6
	moveq	#0,d2
	move.b	(a1)+,d2
	add	#$1001,d2
	add	d2,d2
	move	#$2000,d7
	move	d7,0(a2,d6.w)
	move	d7,0(a3,d6.w)
	clr	L3182
	lea	L738A(pc),a4
LA38:
	tst.b	d1
	blt.s	LA5E
LA3C:
	move	d2,a6
	move	0(a3,d2.w),d2
	cmp	d2,d7
	bne.s	LA68
	move	d6,0(a3,a6.w)
	move	a6,0(a4,d6.w)
	bra	LADA
LA52:
	move	d6,0(a2,a6.w)
	move	a6,0(a4,d6.w)
	bra.s	LADA
LA5C:
	bls.b	LA3C
LA5E:
	move	d2,a6
	move	0(a2,d2.w),d2
	cmp	d2,d7
	beq.s	LA52
LA68:
	moveq	#0,d1
	move.l	a1,a0
	lsr.w	#1,d2
	lea	1(a5,d2.w),a6
	add	d2,d2
	cmpm.b	(a0)+,(a6)+
	bne.s	LA5C
	cmpm.b	(a0)+,(a6)+
	bne.s	LA5C
	moveq	#14,d5
LA7E:
	cmpm.b	(a0)+,(a6)+
	dbne	d5,LA7E
	shi	d1
	moveq	#17,d3
	sub	d5,d3
	lea	L3182(pc),a6
	cmp	(a6),d3
	ble.s	LA38
	move	d2,d4
	lsr.w	#1,d4
	move	d4,L3180
	move	d3,(a6)
	cmp	#$12,d3
	blt.s	LA38
	move	0(a4,d2.w),0(a4,d6.w)
	move	0(a2,d2.w),0(a2,d6.w)
	move	0(a3,d2.w),0(a3,d6.w)
	move	0(a2,d2.w),d4
	move	d6,0(a4,d4.w)
	move	0(a3,d2.w),d4
	move	d6,0(a4,d4.w)
	lea	0(a4,d2.w),a6
	move	(a6),d4
	cmp	0(a3,d4.w),d2
	beq.s	LAE0
	move	(a6),d3
	move	d6,0(a2,d3.w)
	move	d7,(a6)
LADA:
	movem.l	(sp)+,d0-d7/a0-a1/a4/a6
	rts
LAE0:
	move	d6,0(a3,d4.w)
	move	d7,(a6)
	movem.l	(sp)+,d0-d7/a0-a1/a4/a6
	rts
;
;
main_unpack_sub:
	lea	sel_unpack_s(pc),a0
	move.l	a0,prompt_p
	bsr	main_fselect_sub
	lea	no_inspec_s(pc),a1
	tst.b	(a0)
	beq	err_alert_a1
	lea	no_inspec_s(pc),a1
	bsr	safe_fsfirst
	bne	err_alert_a1
	move.l	d2,d0			;d0 = size of found file
	bgt.s	.try_unpack		;only unpack files with some data
	rts
;
.try_unpack:
	move.l	d0,orig_size
	bsr	safe_malloc_d0
	move.l	d0,L2E62
	move.l	d0,L27AE
	bsr	fopen_input_a0
	move.l	d0,a0
	bsr	safe_fread_d7_d0_a0
	bsr	safe_fclose_d7
	move.l	a0,-(sp)
	adda.l	2(a0),a0
	adda.l	#$1C,a0
	move.l	a0,a4
	move.l	(sp)+,a0
	cmpi.l	#'-afx',2(a0)
	bne.s	LB52
	cmpi.b	#'-',6(a0)
	bne.s	LB52
	move.l	a0,a4
	bra.s	LB6A
;
LB52:
	lea	30(a0),a0
	lea	pfx_head_s(pc),a2
LB5A:
	tst.b	(a2)
	beq.s	LB6A
	cmpm.b	(a0)+,(a2)+
	beq.s	LB5A
.pre_unpacked:
	tst	parm_cnt
	bne	no_write_2
	lea	already_unpacked_s(pc),a1
	bra	err_alert_a1
;
;
LB6A:
	moveq	#-1,d0
	bsr	safe_malloc_d0
	sub.l	#$4E20,d0
	bsr	safe_malloc_d0
	move.l	d0,L2E66
	move.l	d0,L27C6
	move.l	d0,a6
	movem.l	d0-d7/a0-a5,-(sp)
	bsr.s	LBCC
	movem.l	(sp)+,d0-d7/a0-a5
	add.l	#$FEE,d0
	move.l	a6,d1
	sub.l	d0,d1
	move.l	d1,dest_size
	bsr	show_size_ask_save
	bne	no_write
	bsr	write_dest_fsel
	bsr	safe_fcreate_a0_0
	move.l	d0,a0
	move.l	d1,d0
	move.l	d0,L2E72
	bra	write_end
;
;
LBCC:
	movep.w	14(a4),d4
	move.b	13(a4),d4
	swap	d4
	movep.w	12(a4),d4
	move.b	11(a4),d4
	moveq	#2,d0
	add.b	(a4),d0
	adda	d0,a4
	move	#$FED,d5
	move	d5,d0
	moveq	#32,d1
LBEC:
	move.b	d1,(a6)+
	dbra	d0,LBEC
	move.l	a6,a3
	moveq	#0,d7
LBF6:
	dbra	d7,LBFE
	move.b	(a4)+,d6
	moveq	#7,d7
LBFE:
	lsr.b	#1,d6
	bcc.s	LC0C
	move.b	(a4)+,(a6)+
	addq	#1,d5
	subq.l	#1,d4
	bgt.s	LBF6
	bra.s	LC38
LC0C:
	movep.w	1(a4),d0
	lsr.w	#4,d0
	move.b	(a4)+,d0
	sub	d5,d0
	neg	d0
	and	#$FFF,d0
	neg	d0
	lea	-1(a6,d0.w),a0
	moveq	#15,d1
	and.b	(a4)+,d1
	addq	#2,d1
	moveq	#1,d0
	add	d1,d0
LC2C:
	move.b	(a0)+,(a6)+
	dbra	d1,LC2C
	add.l	d0,d5
	sub.l	d0,d4
	bgt.s	LBF6
LC38:
	rts
;
LC3A:
	movem.l	a0-a1,-(sp)
	lea	L27BE(pc),a0
	addq.l	#1,(a0)
	move.l	4(a0),a1
	move.b	d0,(a1)+
	move.l	a1,4(a0)
	movem.l	(sp)+,a0-a1
	rts
;
LC54:
	movem.l	d0-d0/d2-d2/a0-a2,-(sp)
	move	d0,d2
	lea	L27BE(pc),a2
	add.l	d0,(a2)
	addq.l	#1,(a2)
	move	d0,d2
	move.l	4(a2),a1
LC68:
	move.b	(a0)+,d0
	move.b	d0,(a1)+
	dbra	d2,LC68
	move.l	a1,4(a2)
	movem.l	(sp)+,d0-d0/d2-d2/a0-a2
	rts
;
LC7A:
	movem.l	d1-d1/a0-a1,-(sp)
	lea	L27B2(pc),a0
	tst.l	(a0)
	beq.s	LCC6
	subq.l	#1,(a0)
	move.l	4(a0),a1
	moveq	#0,d0
	move.b	(a1)+,d0
	move.l	a1,4(a0)
	subq.l	#1,8(a0)
	bne.s	LCB8
	move.l	#$1000,8(a0)
	movem.l	d0-d1,-(sp)
	move.l	a1,d1
	sub.l	L3150(pc),d1
	move.l	fsize_to_pack(pc),d0
	bsr	show_pack_form
	movem.l	(sp)+,d0-d1
LCB8:
	bsr	LE4A
	move.b	#1,d1
	movem.l	(sp)+,d1-d1/a0-a1
	rts
;
LCC6:
	movem.l	(sp)+,d1-d1/a0-a1
	rts
;
;
safe_fsfirst:
	movem.l	d0-d1/a0-a5,-(sp)
	move	#$3F,-(sp)
	move.l	a0,-(sp)
	gemdos	Fgetdta
	move.l	d0,a5
	gemdos	Fsfirst,(),()
	tst.l	d0
	bmi.s	LD00
	move.l	dta_fsize(a5),d2
	move	dta_ftime(a5),d3
	move	dta_fdate(a5),d4
	clr.b	d0
	movem.l	(sp)+,d0-d1/a0-a5
	rts
;
LD00:
	move.b	#1,d0
	movem.l	(sp)+,d0-d1/a0-a5
	rts
;
;
safe_fcreate_a0_0:
	movem.l	d0-d4/a0-a4,-(sp)
	gemdos	Fcreate,(a0),!
	move.l	d0,d7
	lea	err_create_s(pc),a1
	tst.l	d0
	bmi	err_alert_a1
	gemdos	fdatime,datime_bf(pc),d7,#1
	movem.l	(sp)+,d0-d4/a0-a4
	rts
;
;
safe_fwrite_d7_d0_a0:
	movem.l	d0-d4/a0-a4,-(sp)
	gemdos	Fwrite,d7,d0,(a0)
	lea	err_write_s(pc),a1
	tst.l	d0
	beq	err_alert_a1
	movem.l	(sp)+,d0-d4/a0-a4
	rts
;
;
safe_fopen_a0_d0:
	movem.l	d1-d4/a0-a4,-(sp)
	gemdos	Fopen,(a0),d0
	lea	err_open_s(pc),a1
	tst.l	d0
	bmi	err_alert_a1
	movem.l	(sp)+,d1-d4/a0-a4
	tst.l	d0
	rts
;
;
fopen_input_a0:
	movem.l	d0-d4/a0-a4,-(sp)
	clr	d0
	bsr.s	safe_fopen_a0_d0
	move.l	d0,d7
	gemdos	fdatime,datime_bf(pc),d7,!
	movem.l	(sp)+,d0-d4/a0-a4
	rts
;
;
safe_fread_d7_d0_a0:
	movem.l	d0-d4/a0-a4,-(sp)
	gemdos	Fread,d7,d0,(a0)
	lea	err_read_s(pc),a1
	tst.l	d0
	bmi	err_alert_a1
	movem.l	(sp)+,d0-d4/a0-a4
	rts
;
;
safe_fclose_d7:
	movem.l	d0-d4/a0-a4,-(sp)
	gemdos	Fclose,d7
	movem.l	(sp)+,d0-d4/a0-a4
	rts
;
;
safe_malloc_d0:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Malloc,d0
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
safe_mfree_a0:
	movem.l	d1-d2/a0-a2,-(sp)
	gemdos	Mfree,(a0)
	movem.l	(sp)+,d1-d2/a0-a2
	rts
;
;
main_fselect_OK:
	movem.l	a0/a1,-(sp)
	bsr	lastslash_a0
	lea	fsel_file(pc),a0
	exg	a0,a1
	bsr	strcpy_a0_a1
	movem.l	(sp)+,a0/a1
	moveq	#1,d0
	rts
;
;
main_fselect_sub:
	lea	fsel_path(pc),a0
	tst	parm_cnt
	bne.s	main_fselect_ok
	movem.l	d1-d7/a1-a6,-(sp)
	bsr	fselect_sub
	movem.l	(sp)+,d1-d7/a1-a6
	bne.s	main_fselect_OK
	tst	intout
	bne	free_work_go_main
	lea	err_fsel_s(pc),a1
	bra	err_alert_a1
;
;
LE1E:
	movem.l	d0-d2/a0,-(sp)
	clr	L3076
	lea	L2E76(pc),a0
	moveq	#0,d0
.LE2E:
	move	d0,d1
	moveq	#7,d2
.LE32:
	lsr.w	#1,d1
	bcc.s	.LE3A
	eori	#$A001,d1
.LE3A:
	dbra	d2,.LE32
	move	d1,(a0)+
	addq.b	#1,d0
	bne.s	.LE2E
	movem.l	(sp)+,d0-d2/a0
	rts
;
;
LE4A:
	movem.l	d0-d3/a0-a1,-(sp)
	move	d0,d3
	lea	L3076(pc),a0
	move	(a0),d1
	eor	d3,d1
	moveq	#0,d2
	move.b	d1,d2
	add	d2,d2
	lea	L2E76(pc),a1
	move	(a0),d0
	lsr.w	#8,d0
	move	0(a1,d2.w),d1
	eor	d0,d1
	move	d1,(a0)
	movem.l	(sp)+,d0-d3/a0-a1
	rts
;
;
show_pack_form:
	movem.l	d0-d7/a0-a6,-(sp)
	exg	d0,d1
	move.l	d0,d2
	move.l	d1,-(sp)
	move.l	#$64,d1
	bsr	calc_fsel
	move.l	d0,d2
	move.l	(sp)+,d1
	bsr	LF0A
	lea	L30F8(pc),a0
	move.l	d2,d0
	bsr	ultoa
.LE98:
	tst.b	(a0)+
	bne.s	.LE98
	subq	#1,a0
	move.b	#37,(a0)+
	clr.b	(a0)
	lea	L30F8(pc),a0
	lea	packed_num_s(pc),a1
.LEAC:
	move.b	(a0)+,(a1)+
	bne.s	.LEAC
	lea	packing_form(pc),a6
	move.l	L27BE(pc),d0
	move.l	#$64,d1
	bsr	calc_fsel
	move.l	d0,d2
	move.l	L27B6(pc),d1
	sub.l	L27AE(pc),d1
	bsr	LF0A
	move.l	d2,d0
	lea	L30F8(pc),a0
	bsr	ultoa
.LED8:
	tst.b	(a0)+
	bne.s	.LED8
	subq.l	#1,a0
	move.b	#37,(a0)+
	clr.b	(a0)
	lea	L30F8(pc),a0
	lea	packrate_num_s(pc),a1
.LEEC:
	move.b	(a0)+,(a1)+
	bne.s	.LEEC
	tst	tos_flag
	bmi.s	.tos_packing_disp
	bsr	safe_draw_form_a6
	move.l	a6,pack_form_p
.pack_displayed:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
.tos_packing_disp:
	gemdos	Cconws,homedown_s(pc)
	gemdos	Cconws,nospace_s-3(pc)
	gemdos	Cconws,file_pack_s(pc)
	gemdos	Cconws,crlf_s
	gemdos	Cconws,nospace_s(pc)
	gemdos	Cconws,crlf_s
	gemdos	Cconws,nospace_s-8(pc)
	gemdos	CConws,fsel_file(pc)
	gemdos	Cconws,crlf_s
	gemdos	Cconws,nospace_s(pc)
	gemdos	Cconws,crlf_s
	gemdos	Cconws,nospace_s-5(pc)
	gemdos	Cconws,packed_s(pc)
	gemdos	Cconout,#HT
	gemdos	Cconws,packed_num_s(pc)
	gemdos	Cconws,crlf_s
	gemdos	Cconws,nospace_s-5(pc)
	gemdos	Cconws,packrate_s(pc)
	gemdos	Cconout,#HT
	gemdos	Cconws,packrate_num_s(pc)
	gemdos	Cconws,crlf_s
	bra	.pack_displayed
;
;
LEFA:
	movem.l	d1-d2,-(sp)
	move.l	d0,d2
	bsr.s	LF0A
	move.l	d2,d0
	movem.l	(sp)+,d1-d2
	rts
;
;
LF0A:
	movem.l	d0/d3-d7,-(sp)
	clr.b	d6		;\
	btst	#31,d1		;|
	beq.s	.keep_sign_1	; > d6  = sign removed from d1 'X'
	move.b	#1,d6		;|
	neg.l	d1		;/
.keep_sign_1:
	btst	#31,d2		;\
	beq.s	.keep_sign_2	; > d6 ^= sign removed from d2 'Y'
	eori.b	#1,d6		;|
	neg.l	d2		;/
.keep_sign_2:
	tst.l	d1
	beq.s	.LF78
	exg	d1,d2
	clr	d4
	tst.l	d1
	bge.s	.LF38
	addq	#3,d4
	neg.l	d1
.LF38:
	tst.l	d2
	bge.s	.LF40
	addq	#1,d4
	neg.l	d2
.LF40:
	moveq	#1,d3
.LF42:
	cmp.l	d1,d2
	bhs.s	.LF4C
	add.l	d2,d2
	add.l	d3,d3
	bra.s	.LF42
;
.LF4C:
	moveq	#0,d0
.LF4E:
	cmp.l	d1,d2
	bhi.b	.LF56
	or.l	d3,d0
	sub.l	d2,d1
.LF56:
	lsr.l	#1,d2
	lsr.l	#1,d3
	bcc.s	.LF4E
	cmp	#3,d4
	blt.s	.LF64
	neg.l	d1
.LF64:
	lsr.l	#1,d4
	bcc.s	.LF6A
	neg.l	d0
.LF6A:
	move.l	d0,d2
	tst.b	d6
	beq.s	.keep_sign_3
	neg.l	d2
.keep_sign_3:
	movem.l	(sp)+,d0/d3-d7
	rts
;
;
.LF78:
	movem.l	(sp)+,d0/d3-d7
	rts
;
;
calc_fsel:			;calc's d0 = d0 * d1  calls fsel_input if > $FFFF
	movem.l	d2-d3,-(sp)
	move.l	d0,d2
	bsr.s	.LF8E
	move.l	d2,d0
	movem.l	(sp)+,d2-d3
	rts
;
.LF8E:
	movem.l	d1/d4-d6,-(sp)
	clr.b	d6		;\
	btst	#31,d1		;|
	beq.s	.keep_sign_1	; > d6  = sign removed from d1 'X'
	move.b	#1,d6		;|
	neg.l	d1		;/
.keep_sign_1:
	btst	#31,d2		;\
	beq.s	.keep_sign_2	; > d6 ^= sign removed from d2 'Y'
	eori.b	#1,d6		;|
	neg.l	d2		;/
.keep_sign_2:
	move.l	d2,d4		;d4 = Y
	mulu	d1,d2		;d2 = XL * YL
	move.l	d4,d5		;d5 = Y
	swap	d4
	mulu	d1,d4		;d4 = XL * YH
	swap	d4
	tst	d4		;tst (XL * YH)H
	bne.s	.calc_fsel_do_it
	add.l	d4,d2		;d2 = XL * YL + (XL * YH)<<16
	bcs.s	.calc_fsel_do_it
	move.l	d5,d4		;d4 = Y
	swap	d1
	mulu	d1,d4		;d4 = XH * YL
	swap	d4
	tst	d4		;tst (XH * YL)H
	bne.s	.calc_fsel_do_it
	add.l	d4,d2		;d2 = X * Y - (XH * YH)<<32
	bcs.s	.calc_fsel_do_it
	swap	d5
	mulu	d1,d5		;d5 = XH * YH
	bne.s	.calc_fsel_do_it
	tst.b	d6		;\
	beq.s	.keep_sign_3	; > give product combined factor sign
	neg.l	d2		;/
.keep_sign_3:
	movem.l	(sp)+,d1/d4-d6
	rts
;
.calc_fsel_do_it:
	movem.l	(sp)+,d1/d4-d6
fselect_sub:
	clr.l	addrin
	clr	intin
	move.l	#$4E010101,d0	;graf_mouse
	bsr	call_aes
	lea	fsel_path(pc),a1
	tst.b	(a1)
	beq.s	.use_curr_path
.L1008:
	move.l	a1,a2
.L100A:
	move.b	(a1)+,d0
	beq.s	.L1016
	cmp.b	#'\',d0
	bne.s	.L100A
	bra.s	.L1008
;
.L1016:
	move.b	#'*',(a2)+
	move.b	#'.',(a2)+
	move.b	#'*',(a2)+
	clr.b	(a2)
	bra.s	.use_fsel_path
;
.use_curr_path:
	bsr	getdrvpath_ia1
	lea	fsel_file(pc),a0
	clr.b	(a0)
.use_fsel_path:
	lea	addrin(pc),a0
	lea	fsel_path(pc),a1
	move.l	a1,(a0)+		;addrin[0] -> path buffer
	lea	fsel_file(pc),a1
	move.l	a1,(a0)+		;addrin[1] -> name buffer
	move.l	prompt_p(pc),(a0)+	;addrin[2] -> prompt string
	clr.l	prompt_p
	bsr.s	try_fsel_exinput	;call AES fsel_exinput or fsel_input
	move	#-1,curr_drive		;use default drive after errors
	tst	intout
	beq.s	.L106C
	lea	fsel_path(pc),a0
	clr	d0
	move.b	(a0)+,d0
	cmp	#'z',d0
	bgt.s	.no_upper
	cmp	#'a',d0
	blt.s	.no_upper
	bclr	#5,d0
.no_upper:
	cmp	#'Z',d0
	bgt.s	.no_drivespec
	sub	#'A',d0
	blt.s	.no_drivespec
	cmp.b	#':',(a0)
	beq.s	.have_drivespec
.no_drivespec:
	gemdos	Dgetdrv
.have_drivespec:
	move	d0,curr_drive		;use same drive after success
	tst	intout+2
	beq.s	.L106C
	lea	fsel_path(pc),a0
	lea	fsel_file(pc),a1
.L1050:
	move.l	a0,a2
.L1052:
	move.b	(a0)+,d0
	beq.s	.L1060
	cmp.b	#'\',d0
	bne.s	.L1052
	bra.s	.L1050
;
.L1060:
	move.b	(a1)+,(a2)+
	bne.s	.L1060
	lea	fsel_path(pc),a0
	move.b	#1,d0
.L106C:
	rts
;
;
try_fsel_exinput:
	move.l	addrin+2*4,d0
	ble.s	.use_fileselector
	move.l	#$5A000202,d1	;AES fsel_input
	move.l	#'FSEL',d0
	bsr.s	seek_cookie_d0
	bpl.s	.use_new_selector
	bsr.s	what_TOS_version
	cmp	#$0104,d0
	blt.s	.use_fileselector
.use_new_selector:
	move.l	#$5B000203,d1	;AES fsel_exinput
.use_fileselector:
	move.l	d1,d0
	bsr	call_aes
	rts
;
;
what_TOS_version:
	movem.l	d1-d7/a0-a6,-(sp)
	gemdos	super|_ind,#1
	move.l	d0,d7
	bmi.s	.sup_seek_1
	gemdos	super,!
	move.l	d0,d7
.sup_seek_1:
	move.l	(_sysbase).w,a0
	move.l	os_version(a0),d0
	bra.s	super_return
;
;
seek_cookie_d0:
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,d3
	gemdos	super|_ind,#1
	move.l	d0,d7
	bmi.s	.sup_seek_1
	gemdos	super,!
	move.l	d0,d7
.sup_seek_1:
	moveq	#-34,d0		;prep 'path not found' error
	move.l	(_cookies).w,d1
	beq.s	super_return
	move.l	d1,a0
	moveq	#-33,d0		;prep 'file not found' error
.seek_cookie_loop:
	tst.l	(a0)
	beq.s	super_return
	cmp.l	(a0),d3
	beq.s	.seek_cookie_found
	addq.l	#8,a0
	bra.s	.seek_cookie_loop
;
.seek_cookie_found:
	move.l	a0,d0
super_return:
	exg	d0,d7
	tst.l	d0
	bmi.s	.keep_super
	gemdos	Super|_ind,d0
.keep_super:
	move.l	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;
call_aes:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	contrl(pc),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr	(a0)
	movep.l	d0,-7(a0)
	cmpi.b	#$70,-7(a0)
	bne.s	L10E2
	move.b	#1,1(a0)
L10E2:
	lea	aes_pb(pc),a0
	move.l	a0,d1
	move	#$C8,d0			;aes code
	trap	#2			;xgemdos
	moveq	#0,d0
	move	intout(pc),d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;
call_vdi:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	contrl+2(pc),a0
	clr	(a0)+
	clr.l	(a0)+
	clr	(a0)
	move.l	d0,-(sp)
	tst.b	(sp)
	addq.l	#4,sp
	bne.s	.L112E
	move.b	d0,-7(a0)
	bra.s	.L1144
;
.L112E:
	move.b	d0,-5(a0)		;sptsin
	lsr.w	#8,d0
	move	d0,2(a0)		;ext opcode
	swap	d0
	move.b	d0,-1(a0)		;sintin
	lsr.w	#8,d0
	move	d0,-8(a0)		;opcode
.L1144:
	move	g_handle(pc),4(a0)	;handle
	lea	vdi_pb(pc),a0
	move.l	a0,d1
	moveq	#$73,d0			;vdi code
	trap	#2			;xgemdos
	moveq	#0,d0
	move	intout(pc),d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;
;
getdrvpath_ia1:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a1,-(sp)
	move	curr_drive,d0
	bmi.s	.get_drive
	gemdos	Mediach,d0
	tst.l	d0
	bne.s	.get_drive
	move	curr_drive(pc),d0
	bra.s	.put_drive
;
.get_drive:
	gemdos	Dgetdrv
.put_drive:
	move.b	d0,curr_drive
	add	#'A',d0
	move.l	(sp),a1
	move.b	d0,(a1)+
	move.b	#':',(a1)+
	sub	#'A',d0
.get_path:
	addq	#1,d0
	gemdos	Dgetpath,(a1),d0
	move.l	(sp)+,a0
.pass_str:
	tst.b	(a0)+
	bne.s	.pass_str
	subq	#1,a0
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
form_beg:
main_form:
;obj 0
	dc.w	-1,1,(mainf_end-main_form)/24-1
	dc.w	G_BOX,NONE,OUTLINED
	dc.w	2,$1012
main_box:
	dc.w	10,2,43,15
;obj 1
	dc.w	2,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	pack_s
	dc.w	2,9,16,1
;obj 2
	dc.w	3,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	unpack_s
	dc.w	2,11,16,1
;obj 3
	dc.w	4,-1,-1
	dc.w	G_BUTTON,SELECTABLE
fastload_f:
	dc.w	NORMAL
	dc.l	fastload_s
	dc.w	25,11,16,1
;obj 4
	dc.w	5,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	exit_s
	dc.w	2,13,16,1
;obj 5
	dc.w	6,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	info_s
	dc.w	25,9,16,1
;obj 6
	dc.w	$B,7,$A
	dc.w	G_BOX,NONE,NORMAL
	dc.w	$FF,$1033
	dc.w	2,1,39,5
;obj 7
	dc.w	8,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	PFX_AFX_version_s
	dc.w	6,0,26,1
;obj 8
	dc.w	9,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	pfx_packer_s
	dc.w	1,4,38,1
;obj 9
	dc.w	$A,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	pfx_unpack_s
	dc.w	1,2,36,1
;obj 10
	dc.w	6,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	afx_unpack_s
	dc.w	1,3,37,1
;obj 11
	dc.w	12,-1,-1
	dc.w	G_BUTTON,SELECTABLE
all_afx_status:
	dc.w	NORMAL
	dc.l	all_afx_s
	dc.w	25,13,16,1
;obj 12
	dc.w	13,-1,-1
	dc.w	G_STRING
afx_info_flags:
	dc.w	SELECTABLE|EXIT,NORMAL
	dc.l	URAn_afx_info_s
	dc.w	9,2,20,1
;obj 13
	dc.w	0,-1,-1
	dc.w	G_STRING,LASTOB,NORMAL
	dc.l	URAn_debug_s
	dc.w	3,7,10,1
mainf_end:
;
info1_form:
;obj 0
	dc.w	-1,1,(info1_end-info1_form)/24-1
	dc.w	G_BOX,NONE,OUTLINED
	dc.w	2,$1100
	dc.w	4,0,$44,$12
;obj 1
	dc.w	2,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L1_s
	dc.w	$11,1,$27,$1
;obj 2
	dc.w	3,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L2_s
	dc.w	1,3,$3E,$1
;obj 3
	dc.w	4,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L3_s
	dc.w	1,4,$3F,$1
;obj 4
	dc.w	5,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L4_s
	dc.w	1,5,$3F,$1
;obj 5
	dc.w	6,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L5_s
	dc.w	1,6,$41,$1
;obj 6
	dc.w	7,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	info1_more_s
	dc.w	1,$10,$40,$1
;obj 7
	dc.w	8,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L6_s
	dc.w	1,7,$3E,$1
;obj 8
	dc.w	9,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L7_s
	dc.w	1,8,$40,$1
;obj 9
	dc.w	$A,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L8_s
	dc.w	1,9,$40,$1
;obj 10
	dc.w	$B,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L9_s
	dc.w	1,11,65,1
;obj 11
	dc.w	$C,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L10_s
	dc.w	1,$C,$3C,$1
;obj 12
	dc.w	$D,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info1_L11_s
	dc.w	1,$D,$3C,$1
;obj 13
	dc.w	0,-1,-1
	dc.w	G_STRING,LASTOB,NORMAL
	dc.l	info1_L12_s
	dc.w	1,$E,$40,$1
info1_end:
;
info2_form:
;obj 0
	dc.w	-1,1,(info2_end-info2_form)/24-1
	dc.w	G_BOX,NONE,OUTLINED
	dc.w	2,$1100
big_box:
	dc.w	3,3,71,18
;obj 1
	dc.w	13,2,12
	dc.w	G_BOX,NONE,OUTLINED
	dc.w	0,$1101
	dc.w	2,11,67,4
;obj 2
	dc.w	3,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L1_s
	dc.w	2,0,14,1
;obj 3
	dc.w	4,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L2_s
	dc.w	2,1,12,1
;obj 4
	dc.w	5,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L3_s
	dc.w	2,3,20,1
;obj 5
	dc.w	6,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L4_s
	dc.w	2,2,15,1
;obj 6
	dc.w	7,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L5_s
	dc.w	27,0,6,1
;obj 7
	dc.w	8,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L6_s
	dc.w	35,0,9,1
;obj 8
	dc.w	9,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L7_s
	dc.w	45,0,16,1
;obj 9
	dc.w	10,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L8_s
	dc.w	35,1,9,1
;obj 10
	dc.w	11,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L9_s
	dc.w	45,1,19,1
;obj 11
	dc.w	12,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L10_s
	dc.w	27,3,25,1
;obj 12
	dc.w	1,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L11_s
	dc.w	27,2,40,1
;obj 13
	dc.w	14,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L12_s
	dc.w	5,1,65,1
;obj 14
	dc.w	15,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L13_s
	dc.w	5,2,59,1
;obj 15
	dc.w	16,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L14_s
	dc.w	5,3,65,1
;obj 16
	dc.w	17,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L15_s
	dc.w	5,4,63,1
;obj 17
	dc.w	18,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L16_s
	dc.w	5,8,65,1
;obj 18
	dc.w	19,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L17_s
	dc.w	5,9,19,1
;obj 19
	dc.w	20,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	info2_L18_s
	dc.w	5,6,62,1
;obj 20
	dc.w	0,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT|LASTOB,NORMAL
	dc.l	info2_back_s
	dc.w	2,16,67,1
info2_end:
;
packing_form:
;obj 0
	dc.w	-1,1,6
	dc.w	G_BOX,NONE,OUTLINED
	dc.w	2,$1100
	dc.w	10,2,27,8
;obj 1
	dc.w	2,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	file_pack_s
	dc.w	3,1,22,1
;obj 2
	dc.w	3,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	fsel_file
	dc.w	8,3,12,1
;obj 3
	dc.w	4,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	packed_s
	dc.w	5,5,6,1
;obj 4
	dc.w	5,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	packed_num_s
	dc.w	17,5,4,1
;obj 5
	dc.w	6,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	packrate_s
	dc.w	5,6,8,$1
;obj 6
	dc.w	0,-1,-1
	dc.w	G_STRING,LASTOB,NORMAL
	dc.l	packrate_num_s
	dc.w	17,6,4,1
;
packed_form:
;obj 0
	dc.w	-1,1,6
	dc.w	G_BOX,NONE,OUTLINED
	dc.w	2,$1100
	dc.w	11,1,33,8
;obj 1
	dc.w	2,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	orig_size_s
	dc.w	2,2,13,1
;obj 2
	dc.w	3,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	orig_size_num_s
	dc.w	19,2,9,1
;obj 3
	dc.w	4,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	dest_size_s
	dc.w	2,4,16,1
;obj 4
	dc.w	5,-1,-1
	dc.w	G_STRING,NONE,NORMAL
	dc.l	dest_size_num_s
	dc.w	19,4,9,1
;obj 5
	dc.w	6,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	packed_cancel_s
	dc.w	5,6,8,1
;
;obj 6
	dc.w	0,-1,-1
	dc.w	G_BUTTON,SELECTABLE|EXIT|DEFAULT|LASTOB,NORMAL
	dc.l	packed_ok_s
	dc.w	19,6,8,1
;
form_end:
	dc.l	NUL,NUL
;
;
pack_s:
	dc.b	'Pack',NUL
unpack_s:
	dc.b	'Unpack',NUL
fastload_s:
	dc.b	'Fastload',NUL
exit_s:
	dc.b	'Exit',NUL
info_s:
	dc.b	'Info',NUL
PFX_AFX_version_s:
	dc.b	'PFX/AFX-Packer Version 2.1.L',NUL
URAn_afx_info_s:
	dc.b	'  '
afx_cur_x:
	dc.b	   'xAFX mode is '
afx_cur_s:
	dc.b		         'PASSive.',NUL
afx_pass_s:
	dc.b	'PASSive.',NUL
afx_pack_s:
	dc.b	'PACKer.',NUL
afx_fast_s:
	dc.b	'FAST.',NUL
afx_show_s:
	dc.b	'SHOW.',NUL
afx_abs_s:
	dc.b	'absent.',NUL
pfx_unpack_s:
	dc.b	'PFX-Unpacker (C) 1991 Markus Fritze',NUL
afx_unpack_s:
	dc.b	'AFX-Unpacker (C) 1991 Thomas Quester',NUL
pfx_packer_s:
	dc.b	'Packer       (C) 1991 Thomas Quester ',NUL
all_afx_s:
	dc.b	'AFX pack all',NUL
URAn_debug_s:
	dc.b	'Debugged 1995.08 by Ronald Andersson',NUL
;
info1_L1_s:
	dc.b	'This program is not Public-Domain !',NUL
info1_L2_s:
	dc.b	'The reason behind PFX/AFX is that we all have programs and files',NUL
info1_L3_s:
	dc.b	'which are a bit wasteful in  file space,  and thus also somewhat',NUL
info1_L4_s:
	dc.b	'slower to load than we need.  "xPFX" adds an unpacker to each of',NUL
info1_L5_s:
	dc.b	'the packed programs, making unpacking  automatic  and invisible.',NUL
info1_L6_s:
	dc.b	'To use packed data files,  install  "xAFX"  in your auto-folder.',NUL
info1_L7_s:
	dc.b	'When booted, this causes reading of packed  data files to access',NUL
info1_L8_s:
	dc.b	'the transparently  unpacked  data (incl unpacked filesize info).',NUL
info1_L9_s:
	dc.b	"PFXPAK's virus immunizer used illegal AES calls in TOS programs,",NUL
info1_L10_s:
	dc.b	'and is replaced by the  option  to pack  programs  as AFX files.',NUL
info1_L11_s:
	dc.b	'There is now  very  little difference in the use of packed files',NUL
info1_L12_s:
	dc.b	'as compared to unpacked. ( Even Calamus runs when AFX-packed ! )',NUL
info1_more_s:
	dc.b	'more',NUL
;
info2_L12_s:
	dc.b	'The registered version of the PFX packer is more convenient:',NUL
info2_L13_s:
	dc.b	'With this,  all  files / or programs  that fit the specified',NUL
info2_L14_s:
	dc.b	'selection criteria  can be packed  through a single command,',NUL
info2_L15_s:
	dc.b	'e.g.:  All fonts and pictures and TOS-programs on a disk.',NUL
info2_L18_s:
	dc.b	'(R.Andersson:  "But I have not debugged that version, so...?")',NUL
info2_L16_s:
	dc.b	'The registered version is available from the author for 20 DM.',NUL
info2_L17_s:
	dc.b	'AFX costs 10 DM extra.',NUL
info2_L1_s:
	dc.b	'Thomas Quester',NUL
info2_L2_s:
	dc.b	'Lampenland 9',NUL
info2_L3_s:
	dc.b	'Tel. (040) 720 54 31',NUL
info2_L4_s:
	dc.b	'2050 Hamburg 80',NUL
info2_L5_s:
	dc.b	'Email:',NUL
info2_L6_s:
	dc.b	'Zerberus:',NUL
info2_L7_s:
	dc.b	'T.Quester@datahh',NUL
info2_L8_s:
	dc.b	'Mausnetz:',NUL
info2_L9_s:
	dc.b	'Thomas Quester @ HH',NUL
info2_L10_s:
	dc.b	'either by voice or Email.',NUL
info2_L11_s:
	dc.b	'You may also order the program by phone',NUL
info2_back_s:
	dc.b	'Back',NUL
;
file_pack_s:
	dc.b	'Packing program to -lz5',NUL
prog_pack_s:
	dc.b	'Packing program to -lz5',NUL
data_pack_s:
	dc.b	'Packing data to -afx   ',NUL
all_afx_pack_s:
	dc.b	'Packing file to -afx   ',NUL
packed_s:
	dc.b	'Packed',NUL
packed_num_s:
	dc.b	'100%',NUL
packrate_s:
	dc.b	'Packrate',NUL
packrate_num_s:
	dc.b	'100%',NUL
orig_size_s:
	dc.b	'Original size',NUL
orig_size_num_s:
	dc.b	'1.000.000',NUL
	dc.b	0,0,0,0
dest_size_s:
	dc.b	'Destination size',NUL
dest_size_num_s:
	dc.b	'1.000.000',NUL
	dc.b	0,0,0,0
packed_ok_s:
	dc.b	'OK',NUL
packed_cancel_s:
	dc.b	'Cancel',NUL
sel_pack_s:
	dc.b	'Select a file to pack',NUL
sel_unpack_s:
	dc.b	'Select a file to unpack',NUL
sel_dest_s:
	dc.b	'Select destination file',NUL
	even
;
;
main_obfix:
	lea	main_form(pc),a0
	moveq	#(form_end-form_beg)/24-1,d1
.L1FEA:
	move	d1,intin
	move.l	a0,addrin
	move.l	#$72010101,d0	;rsrc_obfix
	bsr	call_aes
	dbra	d1,.L1FEA
	rts
;
;
safe_draw_form_a6:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.s	draw_form_a6
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;
draw_form_a6:
drz:
	lea	drz(pc),a5
	lea	intin-drz(a5),a0
	clr	(a0)+
	move	d0,(a0)+
	move.l	a6,addrin-drz(a5)
	move.l	#$36000501,d0	;form_center
	bsr	call_aes
	lea	intin-drz(a5),a0
	lea	intout-drz(a5),a1
	movem	2(a1),d1-d4
	tst.l	pack_form_p
	bgt.s	.done_dial
	movem	d1-d4,10(a0)
	clr.l	2(a0)
	clr.l	6(a0)
	clr	(a0)
	move.l	#$33090100,d0	;form_dial(0,...
	bsr	call_aes
.done_dial:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	#$7B000000,d0	;v_hide_c is legal method in all TOS
	bsr	call_vdi
	movem.l	(sp)+,d0-d2/a0-a2
	lea	intin-drz(a5),a0
	clr	(a0)+
	move	#$63,(a0)+
	movem	d1-d4,(a0)
	move.l	#$2A060101,d0	;objc_draw
	move.l	a6,addrin-drz(a5)
	bsr	call_aes
	movem.l	d0-d2/a0-a2,-(sp)
	move	#1,intin
	move.l	#$7A010000,d0	;v_show_c is legal method in all TOS
	bsr	call_vdi
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;
;
undial_p_form:
	tst	tos_flag
	bmi.s	.done_undial
	tst.l	pack_form_p
	ble.s	.done_undial
	movem.l	d0-d7/a0-a6,-(sp)
	lea	drz(pc),a5
	lea	intin-drz(a5),a0
	clr	(a0)+
	move	d0,(a0)+
	move.l	pack_form_p(pc),addrin-drz(a5)
	clr.l	pack_form_p
	move.l	#$36000501,d0	;form_center
	bsr	call_aes
	lea	intin-drz(a5),a0
	lea	intout-drz(a5),a1
	move.l	2(a1),10(a0)
	move.l	6(a1),14(a0)
	move	2(a1),d1
	move	4(a1),d2
	move	6(a1),d3
	move	8(a1),d4
	clr.l	2(a0)
	clr.l	6(a0)
	move	#3,(a0)
	move.l	#$33090100,d0	;form_dial(3,...
	bsr	call_aes
	movem.l	(sp)+,d0-d7/a0-a6
.done_undial:
	rts
;
;
use_form_a6:
	movem.l	d1-d5/a0-a1,-(sp)
	move.l	a6,a0
	bsr	make_box_a0
	bsr	draw_form_a6
	lea	intin-drz(a5),a0
	clr.l	(a0)
	move.l	#$32010101,d0	;form_do
	bsr	call_aes
	move	intout-drz(a5),d5
	lea	intin-drz(a5),a0
	move	#3,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move	d1,(a0)+
	move	d2,(a0)+
	move	d3,(a0)+
	move	d4,(a0)+
	move.l	#$33090100,d0	;form_dial(3...
	bsr	call_aes
	move	d5,d0
	mulu	#$18,d0
	move.l	a6,a0
	adda	d0,a0
	and	#-1-SELECTED,10(a0)
	move	d5,d0
	movem.l	(sp)+,d1-d5/a0-a1
	rts
;
;
create_box:
	move	#-1,windhand
	move	#-1,windopen
	move.l	#4,intin
	move.l	#$68020500,d0		;wind_get
	bsr	call_aes
	tst	intout
	beq.s	.no_wind
	clr	intin
	move.l	intout+2(pc),intin+2
	move.l	intout+6(pc),d0
	move.l	d0,intin+6
	lsr.l	#1,d0
	bclr	#15,d0
	add.l	intout+2(pc),d0
	move.l	d0,centcoor
	move.l	#$64050100,d0		;wind_create
	bsr	call_aes
	move	intout(pc),windhand
.no_wind:
	rts
;
;
make_box_a0:
	move	windopen(pc),intin
	bmi.s	open_box_a0
	move	#5,intin+2
	move.l	centcoor(pc),intin+4
	move.l	20(a0),d0
	move.l	d0,intin+8
	lsr.l	#1,d0
	bclr	#15,d0
	sub.l	d0,intin+4
	move.l	#$69060100,d0		;wind_set
	bsr	call_aes
	rts
;
open_box_a0:
	move	#-1,windopen
	move	windhand(pc),intin
	bmi.s	.no_wind
	move.l	centcoor(pc),intin+2
	move.l	20(a0),d0
	move.l	d0,intin+6
	lsr.l	#1,d0
	bclr	#15,d0
	sub.l	d0,intin+2
	move.l	#$65050100,d0		;wind_open
	bsr	call_aes
	tst	intout
	beq.s	.no_wind
	move	windhand(pc),windopen
.no_wind:
	rts
;
;
close_box:
	move	windopen(pc),intin
	bmi.s	.no_wind
	move.l	#$66010100,d0	;wind_close
	bsr	call_aes
	move	#-1,windopen
.no_wind:
	rts
;
;
delete_box:
	move	windhand(pc),intin
	bmi.s	.no_wind
	move.l	#$67010100,d0	;wind_delete
	bsr	call_aes
	move	#-1,windhand
.no_wind:
	rts
;
;
fix_afx_info:
	move	#NONE,d1
	move	afx_flag(pc),d0
	beq.s	.no_afx
	move	#SELECTABLE|EXIT,d1
.no_afx:
	move	d1,afx_info_flags
	move.b	#' ',d1
	tst	d0
	bpl.s	.no_nu_afx
	move.b	#'x',d1
.no_nu_afx:
	lea	afx_abs_s(pc),a0
	tst	d0
	beq.s	.show_afx
	lea	afx_pass_s(pc),a0
	tst.b	AFX_lock
	bne.s	.show_afx
	lea	afx_pack_s(pc),a0
	move.l	AFX_state,d0
	beq.s	.show_afx
	lea	afx_fast_s(pc),a0
	btst	#1,d0
	beq.s	.show_afx
	lea	afx_show_s(pc),a0
.show_afx:
	move.b	d1,afx_cur_x
	lea	afx_cur_s,a1
.show_afx_lp:
	move.b	(a0)+,(a1)+
	bne.s	.show_afx_lp
.fix_afx_exit:
	rts
;
;
turn_AFX:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	d0,d7
	gemdos	Super,!
	move.l	d0,-(sp)
	clr.l	AFX_lock		;assume AFX_lock absent
	clr	AFX_flag		
	move.l	#'AFX',d0		;old AFX cookie (starts with NUL)
	lea	AFX_ptr(pc),a0
	bsr.s	get_cookie_d0_ia0
	tst	d0
	sne	old_afx_f
	bne.s	.turn_it
	move.l	#'xAFX',d0		;new AFX cookie (starts with 'x')
	lea	AFX_ptr(pc),a0
	bsr.s	get_cookie_d0_ia0
	tst	d0
	sne	new_afx_f
	beq.s	.no_turn		;skip if no AFX cookie found
	move.l	AFX_ptr(pc),a4
	move.l	-4(a4),AFX_lock		;get AFX_lock only from xAFX
.turn_it:
	move.l	AFX_ptr(pc),a4
	cmpi.l	#'PARX',(a4)+
	bne.s	.no_turn
	move.l	8(a4),d0
	move.l	d0,AFX_state
	move.l	d7,8(a4)
	bra.s	.turn_exit
;
.no_turn:
	clr	AFX_flag
.turn_exit:
	gemdos	Super,()
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;
;
get_cookie_d0_ia0:
	move.l	a1,-(sp)
	bsr.s	seek_cookie
	tst.l	d0
	beq.s	.L224C
	move.l	d0,a1
	move.l	4(a1),(a0)
	move	#1,d0
.L224C:
	move.l	(sp)+,a1
	rts
;
;
seek_cookie:
	movem.l	d2/a0,-(sp)
	move.l	d0,d2
	move.l	$5A0.w,d0
	beq.s	.L2234
	move.l	d0,a0
	moveq	#0,d0
.L2226:
	tst.l	(a0)
	beq.s	.L2234
	cmp.l	(a0),d2
	beq.s	.L2232
	addq.l	#8,a0
	bra.s	.L2226
;
.L2232:
	move.l	a0,d0
.L2234:
	movem.l	(sp)+,d2/a0
	rts
;
;
	make	SIM_links
;
;	End of program TEXT segment
;----------------------------------------------------------------------------
;	Program DATA segment
;
	data
;
;
afx_flag:
new_afx_f:	dc.b	0
old_afx_f:	dc.b	0
AFX_lock:	dc.l	0
AFX_state:	dc.l	0
AFX_ptr:	dc.l	0
centcoor:	dc.l	0
windhand:	dc.w	-1
windopen:	dc.w	-1
datime_bf:	dc.l	0
prompt_p:	dc.l	0
orig_size:	dc.l	0
dest_size:	dc.l	0
default_obj:	dc.w	0
newdef_obj:	dc.w	0
argwrk_obj:	dc.w	0
curr_drive:	dc.w	-1
pack_form_p:	dc.l	0
;
;
L27AE:	dc.l	0
L27B2:	dc.l	$12BBE
L27B6:	dc.l	0
	dc.b	0,0,$10,0
L27BE:	dc.l	0
L27C2:	dc.l	0
L27C6:	dc.l	0
;
acc_name:
	dc.b	'  xPFX Packer ',0
	even
;
tos_usage_s:
	dc.b	CR,LF
	dc.b	'When xPFX is run as TOS or TTP program',CR,LF
	dc.b	'it needs files/folders as parameters.',CR,LF
	dc.b	CR,LF,NUL
	even
;
space_40_s:
	dc.b	'                                        '
nospace_s:
	dc.b	ESC,'K',NUL
	even
;
homedown_s:
	dc.b	ESC,'H',ESC,'K',LF,ESC,'K',NUL
	even
;
pfx_head_s:
	dc.b	"LArc's PFX",NUL
	even
;
;
PFX_21_code:
	incbin	REFS\PFX_21_O.B
PFX_21_end:
;
;
PFX_11_code:
	incbin	REFS\PFX_11_O.B
PFX_11_end:
;
;
pack_header:			;00
	dc.w	$1600
pack_method:			;02
	dc.b	'-lz5-'
	dc.b	$12,$34
	dc.b	$12,$34
pack_orig_size:			;11
	dc.b	'4V4V'
	dc.b	0,0,0,0
L2E4B:				;19

	dc.b	0,0,12
pack_header_end:		;22
	ds.b	12
;
;	End of program DATA segment
;----------------------------------------------------------------------------
;	Program BSS segment
;
	bss
main_sp:	ds.l	1
main_link:	ds.l	1
;
		ds.w	1
parm_path:	ds.b	256
		ds.w	1
fsel_path:	ds.b	256
fsel_file:	ds.b	128
;
intin:		ds.w	128
intout:		ds.w	128
ptsin:		ds.w	64
ptsout:		ds.w	64
message:	ds.b	16
		ds.l	$100
mystack:	ds.l	4
;
kbshift_f:	ds.w	1
;
;
L2E5A:		ds.b	4
L2E62:		ds.l	1
L2E66:		ds.l	1
norm_sp:	ds.l	1
		ds.l	1
L2E72:		ds.b	4
L2E76:		ds.b	512
L3076:		ds.b	2
str_buff:	ds.b	128
L30F8:		ds.b	80
fsize_to_pack:	ds.b	4
L314C:		ds.b	4
L3150:		ds.b	4
L3154:		;Unref
		ds.b	21
L3169:		ds.b	1
L316A:		ds.b	2
L316C:		ds.b	20
L3180:		ds.b	2
L3182:		ds.b	2
L3184:		ds.b	2
L3186:		ds.b	7028
L4CFA:		ds.b	1166
L5188:		ds.b	3438
L5EF6:		ds.b	2776
L69CE:		ds.b	2492
L738A:		ds.b	7411
L907D:		ds.b	783
L938C:		ds.b	4113
LA39D:		ds.b	17
LA3AE:		ds.b	4
;
;	End of program BSS segment
;----------------------------------------------------------------------------
;
bss_end:
	end
;----------------------------------------------------------------------------
;End of file:	xPFX.S
;----------------------------------------------------------------------------
