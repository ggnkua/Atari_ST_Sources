;----------------------------------------------------------------------------
;File name:	BT_PATCH.S			Revision date:	1997.10.26
;Created by:	Ulf Ronald Andersson		Creation date:	1996.06.24
;Copyright:	(C)1996 Ulf Ronald Andersson	Version:	2.0
;----------------------------------------------------------------------------
	output	.PRG
;
	include	URAn_SYS.S
	include	URAn_DOS.S
	include	URAn_JAR.S
;
;
	text
;
	opt	a+
	opt	o+
;----------------------------------------------------------------------------
MAX_menu	=	20
;----------------------------------------------------------------------------
start:
	move.l	4(sp),a5		;a5->BP
	lea	loc_stack_top(pc),sp
	move.l	bp_bss_beg_p(a5),a0
	add.l	bp_bss_len(a5),a0
	sub.l	a5,a0			;a0 = total size of program
	gemdos	Mshrink,!,(a5),a0	;returns RAM to OS
	xbios	Supexec,pre_main
	bsr.s	main
	tst.l	d0
	bpl.s	.exit_program
	lea	main_error_s(pc),a0
	bsr	show_error
.exit_program:
	clr.l	d0
	gemdos	Pterm,d0
;----------------------------------------------------------------------------
pre_main:
	move	(_bootdev).w,d0
	add	#'A',d0
	move.b	d0,BT_last_inf_s
	move.b	d0,norm_name_s
	move.b	d0,boot_prg_s
	move.b	d0,boot_prx_s
	move.b	d0,x_auto_bt_magic_inf_s
	move.b	d0,x_auto_bt_menu_inf_s
	eval_cookie	#'MagX'
	spl	MagX_f
	rts
;----------------------------------------------------------------------------
main:
	gemdos	Fopen,x_auto_bt_menu_inf_s(pc),!
	move.l	d0,d4
	bmi.s	.menu_inf_absent
	gemdos	Fread,d4,#4096,bt_menu_inf
	exg	d0,d4
	gemdos	Fclose,d0
	move.l	d4,d0
	bgt.s	.have_menu_inf
.menu_inf_absent:
	rts
;
.have_menu_inf:
	move.l	d0,d4			;d4 =  menu inf file length
	lea	bt_menu_inf(pc),a4	;a4 -> menu inf file
	lea	bootprog_s(pc),a0
	bsr	pass_name
	bmi	.menu_inf_absent
	lea	bootprog_s(pc),a0
	lea	boot_prg_s(pc),a1
	bsr	str_cat
	lea	prg_suffix_s(pc),a0
	bsr	str_cat
	lea	bootprog_s(pc),a0
	lea	boot_prx_s(pc),a1
	bsr	str_cat
	lea	prx_suffix_s(pc),a0
	bsr	str_cat
;
	lea	coll_fold_s(pc),a0
	bsr	pass_name
	bmi	.menu_inf_absent
	lea	coll_fold_s(pc),a0
	lea	norm_name_s(pc),a1
	bsr	str_cat
;
	lea	norm_name_s(pc),a0
	lea	new_foldname_s(pc),a1
	bsr	str_cat
;
	lea	boot_fold_s(pc),a0
	bsr	pass_name
	bmi	.menu_inf_absent
	lea	boot_fold_s(pc),a0
	lea	norm_name_s(pc),a1
	bsr	str_cat
;
	lea	norm_name_s(pc),a0
	lea	path_BT_patch_inf_s(pc),a1
	bsr	str_cat
	lea	BT_patch_inf_s(pc),a0
	bsr	str_cat
;
.get_menu_loop:
	bsr	get_menu_entry
	bpl.s	.get_menu_loop
.menu_complete:
;
	bios	Kbshift,?
	and	#$02,d0		;left shift present ?
	beq	main_exit	;if not, exit!
;
	bsr	hide_root_accs
;
	tst	MagX_f
	beq.s	.no_magx_active
	lea	refuse_s(pc),a0
	bsr	show_error
	bra	main_exit
;
.no_magx_active:
	lea	BT_last_inf_s(pc),a0
	lea	BT_lastused_s(pc),a1
	move.l	#127,d0
	bsr	load_file
	bmi	main_exit
;
.reprompt:
	gemdos	Cconws,prompt_1_s(pc)
	clr.l	d0
	move	menu_count(pc),d0
	subq.l	#1,d0
	beq	main_exit
	move	d0,d3
	lea	menu_ptr_t(pc),a3
.menu_disp_loop:
	gemdos	Cconws,indent_s(pc)
	move.l	(a3)+,a0
	addq	#4,a3
	gemdos	Cconws,(a0)
	gemdos	Cconws,crlf_s(pc)
	dbra	d3,.menu_disp_loop
	gemdos	Cconws,prompt_2_s(pc)
;
	gemdos	Crawcin
	move	menu_count(pc),d3
	subq	#1,d3
	lea	menu_ptr_t(pc),a3
.menu_test_lp:
	move.l	(a3)+,a0
	addq	#4,a3
	cmp.b	(a0),d0
	dbeq	d3,.menu_test_lp
	bne.s	.reprompt
	subq	#4,a3
	move.l	(a3),a0
	lea	new_foldname_s(pc),a1
	bsr	str_cat
;
	lea	BT_lastused_s(pc),a0
.loop_1:
	move.b	(a0)+,d0
	beq.s	.exit_1
	cmp.b	#CR,d0
	beq.s	.exit_1
	cmp.b	#LF,d0
	bne.s	.loop_1
.exit_1:
	clr.b	-1(a0)
	gemdos Frename,!,norm_name_s(pc),BT_lastused_s(pc)
	tst.l	d0
	bmi	main_exit
;
	gemdos Frename,!,new_foldname_s(pc),norm_name_s(pc)
	tst.l	d0
	bmi	main_exit
;
	lea	BT_last_inf_s(pc),a0
	lea	new_foldname_s(pc),a1
	move.l	#128,d0
	bsr	save_file
	tst.l	d0
	bmi	main_exit
;
	gemdos	Fsetdta,loc_dta(pc)
	gemdos	Fsfirst,path_BT_patch_inf_s(pc),!
	tst.l	d0
	bmi	main_exit
	move.l	dta_fsize+loc_dta(pc),d0
	beq	main_exit
	move.l	d0,d3
	addq	#4,d0				;request 4 bytes more than file size
	gemdos	Malloc,d0			;allocate file buffer
	move.l	d0,batch_p
	bmi	main_exit
	move.l	d0,a1
	lea	path_BT_patch_inf_s(pc),a0
	move.l	d3,d0
	bsr	load_file
	cmp.l	d0,d3
	bne	.batch_exit
	move.l	batch_p(pc),a4			;a4 -> batch file data
	clr.b	(a4,d3.l)			;NUL-terminate batch data
	clr	d3
.batch_loop:
	move.b	(a4)+,d0
	beq	.batch_exit
	cmp.b	#'a',d0
	blo.s	.keep_asc_1
	cmp.b	#'z',d0
	bhi.s	.keep_asc_1
	and.b	#$DF,d0
.keep_asc_1:
	cmp.b	#' ',d0
	beq.s	.batch_loop
	cmp.b	#HT,d0
	beq.s	.batch_loop
	cmp.b	#CR,d0
	beq.s	.batch_loop
	cmp.b	#LF,d0
	beq.s	.batch_loop
	cmp.b	#';',d0
	bne.s	.not_remark
.got_remark:
	move.b	(a4)+,d0
	beq	.batch_exit
	cmp.b	#'a',d0
	blo.s	.keep_asc_2
	cmp.b	#'z',d0
	bhi.s	.keep_asc_2
	and.b	#$DF,d0
.keep_asc_2:
	cmp.b	#CR,d0
	beq.s	.batch_loop
	cmp.b	#LF,d0
	beq.s	.batch_loop
	bra.s	.got_remark
;
.not_remark:
	asl	#8,d0
	move.b	(a4)+,d0
	beq	.batch_exit
	cmp.b	#'a',d0
	blo.s	.keep_asc_3
	cmp.b	#'z',d0
	bhi.s	.keep_asc_3
	and.b	#$DF,d0
.keep_asc_3:
	cmp	#'MV',d0
	bne.s	.not_move
.got_move:
	bsr	get_names
	bmi	.batch_exit
	gemdos	Frename,!,source_name_s(pc),dest_name_s(pc)
;NB: intentional avoidance of error test, to let batches pass irrelevance
	bra	.batch_loop
;
.not_move:
	cmp	#'CP',d0
	bne.s	.not_copy
	bsr	get_names
	bmi	.batch_exit
;
	gemdos	Fsfirst,source_name_s(pc),!
	tst.l	d0
	bmi	.batch_exit
	move.l	dta_fsize+loc_dta(pc),d0
	beq.s	.batch_exit
	move.l	d0,copybuff_len
	addq	#4,d0				;request 4 bytes more than file size
	gemdos	Malloc,d0			;allocate file buffer
	move.l	d0,copybuff_p
	bmi.s	.batch_exit
	move.l	d0,a1
	lea	source_name_s(pc),a0
	move.l	copybuff_len(pc),d0
	bsr	load_file
	bmi.s	.copy_error
	cmp.l	copybuff_len(pc),d0
	bne.s	.copy_error
	lea	dest_name_s(pc),a0
	move.l	copybuff_p(pc),a1
	move.l	copybuff_len(pc),d0
	bsr	save_file
	bmi.s	.copy_error
	gemdos	Mfree|_ind,copybuff_p(pc)	;release copy buffer
	bra	.batch_loop
;
.not_copy:
	move	d0,badcmd_s
	lea	batch_error_s(pc),a0
	bsr	show_error
	clr.l	d0
	bra.s	.batch_exit
;
;
.copy_error:
	gemdos	Mfree|_ind,copybuff_p(pc)	;release copy buffer
	lea	copy_error_s(pc),a0
	bsr	show_error
	clr.l	d0
.batch_exit:
	ext	d0
	ext.l	d0
	move.l	d0,d3
	gemdos	Mfree|_ind,batch_p(pc)		;release file buffer
	move.l	d3,d0
main_exit:
	tst.l	d0
	bmi.s	.enable_BOOTPROG
	tst	MagX_f
	beq.s	.enable_BOOTPROG
	gemdos	Fopen,x_auto_bt_magic_inf_s(pc),!
	move.l	d0,d4
	bmi.s	.enable_BOOTPROG
	gemdos	Fread,d4,#1,bt_magic_inf
	exg	d0,d4
	gemdos	Fclose,d0
	cmp.l	#1,d4
	bne.s	.enable_BOOTPROG
	cmp.b	#'0',bt_magic_inf
	bne.s	.disable_BOOTPROG
.enable_BOOTPROG:
	moveq	#1,d0
	bra.s	.switch_BOOTPROG_d0
;
.disable_BOOTPROG:
	moveq	#0,d0
.switch_BOOTPROG_d0:
	lea	boot_prx_s(pc),a0
	lea	boot_prg_s(pc),a1
	tst	d0
	bne.s	.use_d0_state
	exg	a0,a1
.use_d0_state:
	gemdos	Frename,!,(a0),(a1)
	move.l	d3,d0
	rts
;----------------------------------------------------------------------------
get_names:
.get_sep_1:
	move.b	(a4)+,d0
	beq	.failed
	cmp.b	#'a',d0
	blo.s	.keep_asc_4
	cmp.b	#'z',d0
	bhi.s	.keep_asc_4
	and.b	#$DF,d0
.keep_asc_4:
	cmp.b	#CR,d0
	beq	.failed
	cmp.b	#LF,d0
	beq	.failed
	cmp.b	#' ',d0
	beq.s	.get_name_1
	cmp.b	#HT,d0
	bne	.failed
.get_name_1:
.pass_sep_1:
	move.b	(a4)+,d0
	beq	.failed
	cmp.b	#'a',d0
	blo.s	.keep_asc_5
	cmp.b	#'z',d0
	bhi.s	.keep_asc_5
	and.b	#$DF,d0
.keep_asc_5:
	cmp.b	#CR,d0
	beq	.failed
	cmp.b	#LF,d0
	beq	.failed
	cmp.b	#' ',d0
	beq.s	.pass_sep_1
	cmp.b	#HT,d0
	beq.s	.pass_sep_1
	lea	source_name_s(pc),a0	;a0 -> source string area
.get_loop_1:
	move.b	d0,(a0)+		;copy source string
	move.b	(a4)+,d0
	beq	.failed
	cmp.b	#'a',d0
	blo.s	.keep_asc_6
	cmp.b	#'z',d0
	bhi.s	.keep_asc_6
	and.b	#$DF,d0
.keep_asc_6:
	cmp.b	#CR,d0
	beq.s	.failed
	cmp.b	#LF,d0
	beq.s	.failed
	cmp.b	#' ',d0
	beq.s	.get_name_2
	cmp.b	#HT,d0
	bne.s	.get_loop_1
.get_name_2:
	clr.b	(a0)			;terminate source string
.pass_sep_2:
	move.b	(a4)+,d0
	beq.s	.failed
	cmp.b	#'a',d0
	blo.s	.keep_asc_7
	cmp.b	#'z',d0
	bhi.s	.keep_asc_7
	and.b	#$DF,d0
.keep_asc_7:
	cmp.b	#CR,d0
	beq.s	.failed
	cmp.b	#LF,d0
	beq.s	.failed
	cmp.b	#' ',d0
	beq.s	.pass_sep_2
	cmp.b	#HT,d0
	beq.s	.pass_sep_2
	lea	dest_name_s(pc),a0	;a0 -> dest string area
.get_loop_2:
	move.b	d0,(a0)+		;copy dest string
	move.b	(a4)+,d0
	beq.s	.got_name_2
	cmp.b	#'a',d0
	blo.s	.keep_asc_8
	cmp.b	#'z',d0
	bhi.s	.keep_asc_8
	and.b	#$DF,d0
.keep_asc_8:
	cmp.b	#CR,d0
	beq.s	.got_name_2
	cmp.b	#LF,d0
	beq.s	.got_name_2
	cmp.b	#' ',d0
	beq.s	.got_name_2
	cmp.b	#HT,d0
	bne.s	.get_loop_2
.got_name_2:
	clr.b	(a0)			;terminate dest string
	subq	#1,a4			;a4 -> command terminator
	rts
;
.failed:
	subq	#1,a4
	moveq	#-1,d0
	rts
;----------------------------------------------------------------------------
load_file:
	movem.l	d3/a3,-(sp)
	move.l	a1,a3
	move.l	d0,d3
	gemdos	Fopen,(a0),!
	tst.l	d0
	bmi.s	.open_error
	exg	d0,d3
	gemdos	Fread,d3,d0,(a3)
	exg	d0,d3
	gemdos	Fclose,d0
	move.l	d3,d0
.open_error:
	movem.l	(sp)+,d3/a3
	tst.l	d0
	rts
;----------------------------------------------------------------------------
save_file:
	movem.l	d3/a3-a4,-(sp)
	move.l	a1,a3
	move.l	d0,d3
	move.l	a0,a4
	gemdos	Fdelete,(a4)
	gemdos	Fcreate,(a4),!
	tst.l	d0
	bmi.s	.open_error
	exg	d0,d3
	gemdos	Fwrite,d3,d0,(a3)
	exg	d0,d3
	gemdos	Fclose,d0
	move.l	d3,d0
.open_error:
	movem.l	(sp)+,d3/a3-a4
	tst.l	d0
	rts
;----------------------------------------------------------------------------
show_error:
	move.l	d0,-(sp)		;push entry error flag
	move.l	a0,-(sp)		;push variable error string ptr
.wait_exit:
	gemdos	Cconws,errorhead_s(pc)
	gemdos	Cconws|_ind,(sp)	;show variable error string
	gemdos	Cconws,errortail_s(pc)
	gemdos	Crawcin
	cmp.b	#CR,d0
	bne.s	.wait_exit
	move.l	(sp)+,a0		;pull variable error string ptr
	move.l	(sp)+,d0		;pull entry error flag
	rts
;----------------------------------------------------------------------------
hide_root_accs:
	gemdos	Fgetdta
	move.l	d0,old_dta_p
	gemdos	Fsetdta,loc_dta(pc)
	gemdos	Dgetdrv
	add.b	d0,root_accs_s
	add.b	d0,old_path_s
	add.b	d0,new_path_s
	gemdos	Fsfirst,root_accs_s(pc),#$26
	tst.l	d0
	bmi.s	.done
.loop_1:
	lea	dta_fname+loc_dta(pc),a0
	lea	old_name_s(pc),a1
	lea	new_name_s(pc),a2
.loop_2:
	move.b	(a0),(a1)+			;copy name to old_name_s
	move.b	(a0)+,(a2)+			;copy name to new_name_s
	bne.s	.loop_2
	move.b	#'X',-2(a2)			;change new_name_s .ACX
	gemdos	Frename,!,old_path_s(pc),new_path_s(pc)
	tst.l	d0
	bmi.s	.exit
	gemdos	Fsnext
	tst.l	d0
	bpl.s	.loop_1
.done:
	clr.l	d0
.exit:
	rts
;----------------------------------------------------------------------------
pass_name:
	clr.b	(a0)
	moveq	#8-1,d1
	bsr.s	skip_white
	bmi.s	pass_error
.loop:
	move.b	d0,(a0)+
	clr.b	(a0)
	bsr.s	pass_char
	bmi.s	pass_error
	cmp.b	#' ',d0
	dbls	d1,.loop
	bhi.s	pass_error
	tst.l	d0		;flag positive
	rts
;----------------------------------------------------------------------------
pass_char:
	clr.l	d0
	subq	#1,d4
	bmi.s	pass_error
	move.b	(a4)+,d0
	beq.s	pass_error
	tst.l	d0		;flag positive
	rts
;----------------------------------------------------------------------------
skip_line:
	clr.l	d0
	subq	#1,d4
	bmi.s	pass_error
	move.b	(a4)+,d0
	beq.s	pass_error
	cmp.b	#CR,d0
	beq.s	skip_white
	cmp.b	#LF,d0
	bne.s	skip_line
skip_white:
	clr.l	d0
	subq	#1,d4
	bmi.s	pass_error
	move.b	(a4)+,d0
	beq.s	pass_error
	cmp.b	#' ',d0
	bls.s	skip_white
	cmp.b	#';',d0
	beq.s	skip_line
	tst.l	d0		;flag positive
	rts
;
pass_error:
	moveq	#-1,d0		;flag negative
	rts
;----------------------------------------------------------------------------
get_menu_entry:
	move	menu_count(pc),d3
	cmp	#MAX_menu,d3
	bhs.s	pass_error
	asl	#3,d3
	lea	menu_ptr_t(pc),a3
	lea	(a3,d3),a3		;a3 -> free entry in menu_ptr_t
	move.l	menu_ram_p(pc),a0	;a0 -> RAM for next menu string
;
	move.l	a0,(a3)			;store a0 as future menu string
	bsr	skip_white
	bmi.s	pass_error
	cmp.b	#'$',d0			;$= is prefix for menu strings
	bne.s	pass_error
	bsr.s	pass_eq_string
	bmi.s	pass_error
;
	move.l	a0,4(a3)		;store a0 as future choice string
	bsr	skip_white
	bmi.s	pass_error
	cmp.b	#'&',d0			;&= is prefix for choice strings
	bne.s	pass_error
	bsr.s	pass_eq_string
	bmi.s	pass_error
;
	move.l	a0,menu_ram_p		;store a0 for use with next entry
	addq	#1,menu_count		;increment menu entry count
	tst.l	d0			;flag positive
	rts
;----------------------------------------------------------------------------
pass_eq_string:
	bsr	pass_char
	bmi.s	pass_error
	cmp.b	#'=',d0
	bne	pass_error
pass_string:
	bsr	skip_white
	bmi.s	pass_error
	cmp.b	#'"',d0
	beq.s	.set_str
	cmp.b	#"'",d0
	bne.s	pass_error
.set_str:
	move	d0,d3
	bsr	pass_char
	bmi	pass_error
	cmp.b	d3,d0
	beq	pass_error
.loop:
	move.b	d0,(a0)+
	clr.b	(a0)
	bsr	pass_char
	bmi	pass_error
	cmp.b	d3,d0
	bne.s	.loop
	addq	#1,a0
	tst.l	d0			;flag positive
	rts
;----------------------------------------------------------------------------
str_cat:
	movem.l	a0/a1,-(sp)
.loop_1:
	tst.b	(a1)+
	bne.s	.loop_1
	subq	#1,a1
.loop_2:
	move.b	(a0)+,(a1)+
	bne.s	.loop_2
	movem.l	(sp)+,a0/a1
	rts
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
	data
;----------------------------------------------------------------------------
menu_ram_p:
	dc.l	menu_ram_t
prompt_1_s:
	dc.b	CR,LF
	dc.b	ESC,'p'
	dc.b	' BT_patch version 2.0  1997.10.26 ',ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	' Select setup group:',CR,LF
crlf_s:
	dc.b	CR,LF,NUL
	even
;
prompt_2_s:
	dc.b	CR,LF
	dc.b	'Press a key to choose!',CR,LF
	dc.b	CR,LF
	dc.b	NUL
	even
;
norm_name_s:
	dc.b	'A:\',NUL
	ds.b	124
backslash_s:
	dc.b	'\', NUL
BT_last_inf_s:
	dc.b	'A:\AUTO\BT_LAST.INF',NUL
BT_patch_inf_s:
	dc.b	'\BT_PATCH.INF',NUL
;
errorhead_s:
	dc.b	CR,LF
	dc.b	ESC,'p'
	dc.b	'  BT_patch version 2.0  1997.10.26  ',ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
main_error_s:
	dc.b	' Some error occurred in initializing',CR,LF
	dc.b	' your chosen system setup...!',CR,LF
	dc.b	NUL
;
refuse_s:
	dc.b	' Sorry, but system choice is not free !',CR,LF
	dc.b	' A MagiC version is running, and this',CR,LF
	dc.b	' requires a "cold" boot for changes.',CR,LF
	dc.b	NUL
;
	even
batch_error_s:
	dc.b	' Erroneous command "'
badcmd_s:
	dc.b	'xx" in batch file.',CR,LF
	dc.b	NUL
;
copy_error_s:
	dc.b	' An error occurred in a "cp" command.',CR,LF
	dc.b	NUL
;
errortail_s:
	dc.b	' Press [Return] to continue boot, or',CR,LF
	dc.b	' press RESET to abort boot process.',CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
root_accs_s:	dc.b	'A:\*.ACC',NUL
		even
old_path_s:	dc.b	'A:\'
old_name_s:	ds.b	14
		even
new_path_s:	dc.b	'A:\'
new_name_s:	ds.b	14
		even
;
boot_prg_s:	dc.b	'A:\AUTO\',NUL
		ds.b	14
		even
;
boot_prx_s:	dc.b	'A:\AUTO\',NUL
		ds.b	14
		even
;
prg_suffix_s:
		dc.b	'.PRG',NUL
		even
;
prx_suffix_s:
		dc.b	'.PRX',NUL
		even
;
indent_s:	dc.b	' ',NUL
;
bt_magic_inf:	dc.b	'0',NUL
;
x_auto_bt_menu_inf_s:	dc.b	'A:\AUTO\BT_MENU.INF',NUL
		even
x_auto_bt_magic_inf_s:	dc.b	'A:\AUTO\BT_MAGIC.INF',NUL
		even
;----------------------------------------------------------------------------
	bss
;----------------------------------------------------------------------------
MagX_f:
		ds.w	1
choice:
		ds.w	1
copybuff_len:
		ds.l	1
copybuff_p:
		ds.l	1
batch_p:
		ds.l	1
old_dta_p:
		ds.l	1
loc_dta:
		ds.b	dta_size
menu_count:
		ds.w	1
menu_ptr_t:
		ds.l	2*MAX_menu
menu_ram_t:
		ds.l	128*MAX_menu
;
source_name_s:
		ds.b	$80
dest_name_s:
		ds.b	$80
BT_lastused_s:
		ds.b	$80
new_foldname_s:
		ds.b	$80
;
bootprog_s:
		ds.b	10
coll_fold_s:
		ds.b	10
boot_fold_s:
		ds.b	10
path_BT_patch_inf_s:
		ds.b	128
bt_menu_inf:
		ds.b	4096+2
;
		ds.l	$100	;allow 256 longwords on minimum stack
loc_stack_top:
;----------------------------------------------------------------------------
;End of file:	BT_PATCH.S
;----------------------------------------------------------------------------
