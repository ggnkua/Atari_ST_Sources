;----------------------------------------------------------------------------
;File name:	ModYield.S			Revised:	1999.10.10
;Revised by:	Ulf Ronald Andersson		Revision date:	1998.01.16
;----------------------------------------------------------------------------
	include	RA_JAR.I
	include	RA_XGEM.I
	include	RA_LA.I
	include	RA_DSPT.I
;----------------------------------------------------------------------------
normal_BIOS	=	0	;1=normal  0=reentrant use (protected)
normal_XBIOS	=	0	;1=normal  0=reentrant use (protected)
;----------------------------------------------------------------------------
	section	TEXT
;----------------------------------------------------------------------------
;	Here follows resident start_up code
;	Which can be overlayed with data after boot
;----------------------------------------------------------------------------
rz:	;relative reference zero point
BASEPAGE	=	rz-$100
start:
	bra	install
;----------------------------------------------------------------------------
;	End of resident start_up code
;----------------------------------------------------------------------------
;Start of:	BIOS functions with XBRA
;----------------------------------------------------------------------------
	XGEM_BIOS_define	nu_BIOS,'ModY'
	XB_gonext_a0		nu_BIOS(pc)	;use older bios dispatcher
;----------------------------------------------------------------------------
patch_XGEM_sub:				;uses d0/a0/a1
	XGEM_patch	XGEM_linked_p,XGEM_wanted_p
	rts
;----------------------------------------------------------------------------
;End of:	BIOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	XGEM functions with XBRA
;----------------------------------------------------------------------------
	XGEM_define	init_XGEM,'ModY'
	move.l	#nu_XGEM,XGEM_wanted_p
	XB_gonext_a0	init_XGEM(pc)
;-------------------------------------
	XGEM_define	nu_XGEM,'ModY'
	tst	work_mod_f
	beq.s	use_old_xgem
	cmp	#$C8,d0
	beq.s	.try_mod_cmd
	cmp	#$73,d0
	bne.s	use_old_xgem
.try_mod_cmd:
	tas	xgem_call_f
	bmi.s	use_old_xgem
	movem.l	d0-d3/a1-a3,xgem_regs		;protect entry d1-d3/a1-a3
	move	(sp),d0				;d0 = copy of frame SR
	bset	#13,d0				;enforce super bit in d0
	move	sr,take_cm_entry_sr		;int_mask for entry/exit
	move	d0,take_cm_work_sr		;int_mask for DSP work
	bsr	ModYield_sub			;call Mod_Yield subroutine
	movem.l	xgem_regs(pc),d0-d3/a1-a3	;restore entry d1-d3/a1-a3
	clr	work_mod_f			;clear load_mod_f and dump_mod_f
	sf	xgem_call_f
use_old_xgem:
	XB_gonext_a0	nu_XGEM(pc)
;----------------------------------------------------------------------------
;End of:	XGEMDOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	System timer function with XBRA		(iv_time_c)
;-----------------------------------------------------------------------------
	XB_define	my_time_c_XB,'ModY'
	subq	#1,time_count
	bne	use_old_time_c
	movem.l	d0/a0,time_regs		;save d0/a0
	move	#200/8,time_count	;read commands 8 times per second
	move.l	DspT_cookie_p(pc),d0	;is DspT cookie known ?
	ble.s	done_loop_cmds		;if not, loop cmds are done
	DspT	s,test_end		;test if old module ended
	beq.s	done_loop_cmds		;keep flags if not module end
	move.l	(_hz_200).w,sys_tick	;copy system tick
	st	dump_mod_f		;set dump flag
	st	load_mod_f		;set load flag
done_loop_cmds:
	move.l	kbshift_p(pc),a0	;a0 -> kbshift byte
	move.b	(a0),d0			;d0 =  kbshift byte
	and	#$0F,d0			;mask command keys
	bne.s	.some_command		;go decode command if present
	sf	debounce_f		;clear debounce flag
	bra.s	goto_old_time_c			;done if no command
;-------
.some_command:
	tas	debounce_f		;debounce in progress ?
	bmi.s	goto_old_time_c		;done if undebounced
	cmp	kbsh_code(pc),d0	;load command ?
	beq.s	.load_command		;go flag on load_command
	cmp	#$0f,d0			;dump command ?
	bne.s	goto_old_time_c		;done if no legal command
	sf	load_mod_f		;user dump overrides auto load
	bra.s	.dump_command		;go flag dump_command
;
.load_command:
	move.l	(_hz_200).w,sys_tick	;copy system tick
	st	load_mod_f		;set load flag
.dump_command:
	st	dump_mod_f		;set dump flag
goto_old_time_c:
	movem.l	time_regs(pc),d0/a0	;restore entry d0/a0
use_old_time_c:
	XB_gonext_d	my_time_c_XB(pc)
;----------------------------------------------------------------------------
;End of:	System timer function with XBRA		(iv_time_c)
;----------------------------------------------------------------------------
ModYield_sub:
	move	take_cm_work_sr(pc),sr	;enable interrupts
;-------
	move.l	DspT_cookie_p(pc),d0
	bgt	have_cookie
	DspT_s_init
	tst.l	d0
	ble	ModYield_exit
	tas	inited_f
	bne.s	MY_sub_keep_settings
	DspT	s,set_boost,#2
	DspT	s,set_timer,#1
MY_sub_keep_settings:
	DspT	s,get_funcp,#1,#DspT_fn_free
	move.l	d0,DspT_free_p
have_cookie:
	bsr	validate_inf
	move.b	dump_mod_f(pc),d0
	beq.s	done_dump
	DspT	s,dump
done_dump:
	move.b	load_mod_f(pc),d0
	beq.s	ModYield_exit
.get_new_random_module:
	bsr	validate_inf
	bsr	select_random_mod
	tst.l	d0
	bmi.s	ModYield_exit
	DspT	s,load,load_path_s(pc)
	tst.l	d0
	bmi.s	ModYield_exit
	move.l	a0,module_p
;-------
	DspT.i	s,start,(),DspT_free_p(pc)	;start Music, with DspT_free as dump method
ModYield_exit:
	move	take_cm_entry_sr(pc),sr		;restore entry int_mask
	rts
;----------------------------------------------------------------------------
;End of:	ModYield subroutine
;----------------------------------------------------------------------------
	include	Path_Lib.S
;----------------------------------------------------------------------------
random_word:
	rand_32
	clr.l	d1
	bsr	crc16_add_long
	move.l	sys_tick(pc),d0
	bsr	crc16_add_long
	move.l	d1,d0
	rts
;----------------------------------------------------------------------------
select_random_mod:
	movem.l	d1-d4/a0-a3,-(sp)
	gemdos	Fgetdta			;d0 -> entry DTA
	move.l	d0,-(sp)		;push -> entry DTA
	gemdos	Fsetdta,local_dta(pc)	;set local DTA
;-------
	moveq	#-1,d4			;d4 = preliminary failure flag
	tst.b	valid_inf_f
	beq	.exit
;-------
	lea	main_path_s(pc),a0
	lea	load_path_s(pc),a1
	strcpy	a0,a1
;-------
	lea	load_path_s(pc),a0	;A0 -> load_path_s
	bsr	count_files		;d0 = cnt of MOD files found
	move.l	d0,d2			;d2 = cnt of MOD files found
	bne	.have_files		;if any MODs found, goto .have_files
	bsr	count_folds		;d0 = cnt of folders found
	move.l	d0,d2			;d2 = cnt of folders found
	beq	.exit			;if none, exit with failure
.have_folds:
	bsr	random_word		;d0 = rnd(1<<16)
	mulu	d2,d0
	clr	d0
	swap	d0			;d0 = rnd(d2)
	move.l	d0,d3			;d3 = rnd(d2)
	clr.l	d4			;d4 = 0, folder index
;-------
	lea	load_path_s(pc),a0
	lea	star_pt_star_s(pc),a1
	bsr	new_name
;-------
	gemdos	Fsfirst,load_path_s(pc),#$10	;Find first folder
	bra.s	.loop_1_test
;-------
.loop_1:
	gemdos	Fsnext		;Find next folder
.loop_1_test:
	tst.l	d0		;success ?
	bmi	.exit		;exit when no more found
	cmp.b	#$10,local_dta+dta_fattr	;non-folder name ?
	bne.s	.loop_1				;loop back to find only folder names
	cmp.b	#'.',local_dta+dta_fname	;'dummy' folder name ?
	beq.s	.loop_1				;loop back to find real folder names
	cmp.l	d3,d4		;is this the one we want ?
	beq.s	.found_fold	;goto found_fold when folder found
	addq.l	#1,d4		;step folder counter
	bra.s	.loop_1		;loop back to pass more folders
;-------
.found_fold:
	lea	load_path_s(pc),a0		;a0 -> load_path_s
	lea	local_dta+dta_fname(pc),a1	;a1 -> real folder name in DTA
	bsr	new_name			;replace wild foldname with real foldname
	strpass	a0				;a0 -> beyond load_path_s string
	move.b	#'\',-1(a0)			;replace terminator with backslash
	clr.b	(a0)				;and reterminate string
	bsr	count_files		;d0 = cnt of MOD files found
	move.l	d0,d2			;d2 = cnt of MOD files found
	beq.s	.exit			;exit on failure
.have_files:
	st	autoload_iz_f
	bsr	random_word		;d0 = rnd(1<<16)
	mulu	d2,d0
	clr	d0
	swap	d0			;d0 = rnd(d2)
	move.l	d0,d3			;d3 = rnd(d2)
	clr.l	d4			;d4 = 0, file index
;-------
	lea	main_path_s(pc),a0
	bsr	fix_path
	lea	auto_path_s(pc),a1
	strcpy	a0,a1
;-------
	lea	load_path_s(pc),a0	;a0 -> load_path_s
	lea	modfile_mask_s(pc),a1	;a1 -> wildcard "*.?OD"
	bsr	new_name		;add search mask to load_path_s
.loop_2:
	gemdos	Fsfirst,load_path_s(pc),#1	;Find first MOD file
	tst.l	d0				;success ?
	bmi.s	.exit				;exit on failure
.loop_3:
	cmp.l	d3,d4		;is this the one we want ?
	beq.s	.done_seek	;goto done_seek at final success
	addq.l	#1,d4		;step file counter
	gemdos	Fsnext		;Find next MOD file
	tst.l	d0		;success ?
	bpl.s	.loop_3		;loop back to pass more files
;-------
;Ooops, getting here is abnormal.  Files were deleted while searching !
;-------
	bra.s	.loop_2		;We fix this by looping at end of dir (wrap)
;-------
.done_seek:
	addq	#1,d4
	lea	local_dta+dta_fname(pc),a0	;\
	lea	main_fname_s(pc),a1		; > copy real filename
	strcpy	a0,a1				;/
.exit:
	lea	load_path_s(pc),a0	;a0 -> load_path_s,  with wildcard
	lea	main_fname_s(pc),a1	;a1 -> pure filename of MOD file
	bsr	new_name		;replace wildcard with MOD filename
;-------
	gemdos	Fsetdta,()		;revive entry DTA
	move.l	d4,d0			;d0 = d4, error_flag/file_index
	movem.l	(sp)+,d1-d4/a0-a3	;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
count_files:
	movem.l	d1-d3/a0-a3,-(sp)
	gemdos	Fgetdta
	move.l	d0,-(sp)
;-------
	gemdos	Fsetdta,local_dta(pc)
	clr.l	d3
	tst.b	valid_inf_f
	beq.s	.exit
;-------
	lea	load_path_s(pc),a0
	lea	modfile_mask_s(pc),a1
	bsr	new_name
;-------
	gemdos	Fsfirst,load_path_s(pc),!
	tst.l	d0
	bmi.s	.exit
.loop_2:
	addq.l	#1,d3
	gemdos	Fsnext
	tst.l	d0
	bpl.s	.loop_2
.exit:
	lea	load_path_s(pc),a0
	bsr	cut_name
;-------
	gemdos	Fsetdta,()
	move.l	d3,d0
	movem.l	(sp)+,d1-d3/a0-a3
	rts
;----------------------------------------------------------------------------
count_folds:
	movem.l	d1-d3/a0-a3,-(sp)
	gemdos	Fgetdta
	move.l	d0,-(sp)
;-------
	gemdos	Fsetdta,local_dta(pc)
	clr.l	d3
	tst.b	valid_inf_f
	beq.s	.exit
;-------
	lea	load_path_s(pc),a0
	lea	star_pt_star_s(pc),a1
	bsr	new_name
;
	gemdos	Fsfirst,load_path_s(pc),#$10
	bra.s	.loop_2_test
;-------
.loop_2:
	gemdos	Fsnext
.loop_2_test:
	tst.l	d0				;anything found ?
	bmi.s	.exit				;exit when no more found
	cmp.b	#$10,local_dta+dta_fattr	;non-folder name ?
	bne.s	.loop_2				;loop back to find only folder names
	cmp.b	#'.',local_dta+dta_fname	;'dummy' folder name ?
	beq.s	.loop_2				;loop back to find real folder names
	addq.l	#1,d3				;count each real name
	bra.s	.loop_2				;loop back to find all folder names
;
.exit:
	lea	load_path_s(pc),a0
	bsr	cut_name
;
	gemdos	Fsetdta,()
	move.l	d3,d0
	movem.l	(sp)+,d1-d3/a0-a3
	rts
;----------------------------------------------------------------------------
validate_inf:
	movem.l	d0-d3/a0-a3,-(sp)
	tst.b	valid_inf_f
	bne	.use_auto_path
	gemdos	Fopen,auto_inf_s(pc),!
	move	d0,d3
	bmi	.exit
.Fread_char:
	gemdos	Fread,d3,#1,auto_step_c(pc)
	cmp.l	#1,d0
	bne.s	.invalid_read
	clr	d0
	move.b	auto_step_c(pc),d0
	cmp.b	#'a',d0
	blo.s	.done_case
	sub.b	#$20,d0
.done_case:
	sub.b	#'0',d0
	blo.s	.invalid_read
	cmp.b	#9,d0
	bls.s	.have_char
	add.b	#'0'+10-'A',d0
	cmp.b	#10,d0
	blo.s	.invalid_read
	cmp.b	#15,d0
	bhi.s	.invalid_read
	bne.s	.have_char
	st	load_mod_f
	st	dump_mod_f
	bra.s	.Fread_char
;-------
.have_char:
	move	d0,kbsh_code
	gemdos	Fread,d3,#127,auto_path_s(pc)
	bra.s	.done_read
;
.invalid_read:
	moveq	#E_ERROR,d0
.done_read:
	exg	d0,d3
	gemdos	Fclose,d0
	tst.l	d3
	bmi	.exit
.use_auto_path:
	sf	valid_inf_f
	lea	auto_path_s(pc),a0
	moveq	#127-1,d1
.loop:
	move.b	(a0)+,d0
	cmp.b	#' ',d0
	dbls	d1,.loop
	subq	#1,a0
	cmp.b	#'\',-1(a0)
	beq.s	.have_slash
	move.b	#'\',(a0)+
.have_slash:
	clr.b	(a0)
;
	lea	auto_path_s(pc),a0
	bsr	fix_path
	bsr	cut_name
	lea	main_path_s(pc),a1
	lea	load_path_s(pc),a2
.loop_2:
	move.b	(a0),(a1)+
	move.b	(a0)+,(a2)+
	bne.s	.loop_2
;
	gemdos	Fgetdta
	move.l	d0,-(sp)
	gemdos	Fsetdta,local_dta(pc)
;
	lea	load_path_s(pc),a0
	lea	modfile_mask_s(pc),a1
	bsr	new_name
	gemdos	Fsfirst,load_path_s(pc),#1
	tst.l	d0
	bpl.s	.set_flag
.try_deep_fold:
	lea	load_path_s(pc),a0
	lea	star_pt_star_s(pc),a1
	bsr	new_name
	gemdos	Fsfirst,load_path_s(pc),#$10
	bra.s	.loop_3_test
;-------
.loop_3:
	gemdos	Fsnext
.loop_3_test:
	tst.l	d0				;anything found ?
	bmi.s	.keep_flag
	cmp.b	#$10,local_dta+dta_fattr	;non-folder name ?
	bne.s	.loop_3				;loop back to find only folder names
	cmp.b	#'.',local_dta+dta_fname	;'dummy' folder name ?
	beq.s	.loop_3				;loop back to find real folder name
	lea	load_path_s(pc),a0		;a0 -> load_path_s
	bsr	cut_name			;remove wildcard folder name
	strpass	a0				;a0 -> beyond load_path_s string
	subq	#1,a0				;a0 -> load_path_s string terminator
	lea	local_dta+dta_fname(pc),a1	;a1 -> real folder name in DTA
	strcpy	a1,a0				;copy real folder name
	move.b	#'\',-1(a0)			;replace terminator with backslash
	clr.b	(a0)				;and reterminate string
;
	lea	load_path_s(pc),a0
	lea	modfile_mask_s(pc),a1
	bsr	new_name
	gemdos	Fsfirst,load_path_s(pc),#1
	tst.l	d0
	bmi.s	.keep_flag
.set_flag:
	st	valid_inf_f
.keep_flag:
	gemdos	Fsetdta,()
.exit:
	movem.l	(sp)+,d0-d3/a0-a3
	rts
;----------------------------------------------------------------------------
crc16_add_long:
	swap	d0		;2
	bsr.s	crc16_add_word	;2
crc16_add_swap_word:
	swap	d0		;2
crc16_add_word:
	ror.w	#8,d0		;2
	bsr.s	crc16_add_byte	;2
crc16_add_ror_byte:
	ror.w	#8,d0		;2
crc16_add_byte:
	move.l	d0,-(sp)	;2
	rol.w	#8,d1		;2
	eor.b	d0,d1		;2
	move.b	d1,d0		;2
	lsr.b	#4,d0		;2
	eor.b	d0,d1		;2
	move.b	d1,d0		;2
	lsl.w	#7,d0		;2
	eor.b	d1,d0		;2
	lsl.w	#5,d0		;2
	eor.w	d0,d1		;2
	move.l	(sp)+,d0	;2
	rts			;2
;-------------------------------------
;Byte count for crc16_add_*	;38
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
	include	XB_SUBS.S
;----------------------------------------------------------------------------
;
basepage_p:	ds.l	1
currbp_p_p:	ds.l	1
kbshift_p:	ds.l	1
line_a_base_p:	ds.l	1
;
MiNT_p		ds.l	1
MagX_p		ds.l	1
nAES_p		ds.l	1
Gnva_p		ds.l	1
;
XGEM_linked_p:	dc.l	-1
XGEM_wanted_p:	dc.l	init_XGEM
DspT_free_p:	dc.l	-1
;
sys_tick:	ds.l	1
;
empty_string_s:	dc.w	0
kbsh_code:	dc.w	-1
inited_f:	dc.w	0
valid_inf_f:	dc.w	0
autoload_iz_f:	dc.w	0
auto_inf_s:	dc.b	'A:\AUTO_MOD.INF',NUL
auto_step_c:	dc.b	'6'
modfile_mask_s:	dc.b	'*.MOD',NUL
star_pt_star_s:	dc.b	'*.*',NUL
	even
;
auto_path_s:	ds.b	128
main_path_s:	ds.b	128
load_path_s:	ds.l	128/4
purename_p:	ds.b	128
module_p:	ds.L	1
local_dta:	ds.b	44
main_fname_s:	ds.b	16
;
xgem_regs:	ds.l	16
time_regs:	ds.l	16
;
take_cm_entry_sr:	ds.w	1
take_cm_work_sr:	ds.w	1
;
blocking_f:		;long for the four byte flags below
xgem_call_f:	ds.b	1
		ds.b	1	;one unassigned flag
		ds.w	1	;two unassigned flags
;
work_mod_f:
dump_mod_f:	ds.b	1
load_mod_f:	ds.b	1
;
debounce_f:	dc.w	0
time_count:	dc.w	0
;
intern_USP:	dc.l	local_USP_top
intern_SSP:	dc.l	local_SSP_top
intern_savptr:	dc.l	local_savptr_top
;
extern_USP:	ds.l	1
extern_SSP:	ds.l	1
extern_savptr:	ds.l	1
;
local_USP_stack:
	ds.b	2048
local_USP_top:
;
local_SSP_stack:
	ds.b	2048
local_SSP_top:
;
local_savptr_stack:
	ds.b	2048
local_savptr_top:
;
	ds.b	16
;
;----------------------------------------------------------------------------
;	This is the end of all permanently resident code
;
resident_end:
resident_size	=	(resident_end-start)+$100
;
;----------------------------------------------------------------------------
;	Here are boot routines, not needed after boot
;
install:
	move.l	a0,d0
	bne	boot_error		;refuse to boot as ACC
	move.l	4(sp),basepage_p
	lea	loc_stack_top(pc),sp
	gemdos	Mshrink|_ind,!,basepage_p(pc),#initial_size	;return unneeded RAM
	xbios	Supexec,OS_check_1(pc)
	move.l	MagX_p(pc),d0
	bgt.s	.TOS_adapted
	move.l	#nu_XGEM,XGEM_wanted_p
.TOS_adapted:
	bsr	validate_inf
	move.l	#$91929394,blocking_f
	gemdos	Super,!
	move.l	d0,-(sp)
	DspT_s_init
	move.l	DspT_cookie_p(pc),d0
	ble.s	done_DspT_cookie
	DspT	s,set_boost,#2
	DspT	s,set_timer,#1
	DspT	s,get_funcp,#1,#DspT_fn_free
	move.l	d0,DspT_free_p
	tas	inited_f
done_DspT_cookie:
;-------
	lea	(ev_bios).w,a0
	lea	nu_BIOS(pc),a1
	bsr	retop_XB_name
;-------
	lea	(iv_time_c).w,a0
	lea	my_time_c_XB(pc),a1
	bsr	retop_XB_name
;-------
	move	#200,time_count
	gemdos	Super,()
	clr.l	blocking_f
	gemdos	Ptermres,#resident_size,!
;
boot_error:
	gemdos	Pterm,?
;
;----------------------------------------------------------------------------
;
OS_check_1:
	move	sr,-(sp)
	ori	#$0700,sr
	move.l	(_cookies).w,a0
.cook_loop_1:
	movem.l	(a0)+,d0/d1
	tst.l	d0
	beq.s	.done_cookies
	lea	OS_check_1_t(pc),a1
.cook_loop_2:
	movem.l	(a1)+,d2/a2
	tst.l	d2
	beq.s	.cook_loop_1
	cmp.l	d2,d0
	bne.s	.cook_loop_2
	move.l	d1,(a2)
	bra.s	.cook_loop_1
;
.done_cookies:
	move	(sp),sr
;
	_a_init
	move.l	d0,line_a_base_p
;
	move.l	#$602C,currbp_p_p	;Some old TOS had this (but maybe not all)
	xbios	Keytbl,?,?,?
	move.l	d0,a0
	lea	-1(a0),a0	;NB: this assumes Kbshift stored at Keytbl-1
	move.l	a0,kbshift_p	;NB: So all early TOS have Kbshift data at Keytbl-1 !!!
	move.l	(_sysbase).w,a1
	move.l	os_selfbeg_p(a1),a0
	move	os_version(a0),d0
	cmp	#$102,d0
	blo.s	.done_sys_fix
	move.l	os_kbshift_p(a0),kbshift_p
	move.l	os_currbp_p_p(a0),currbp_p_p
.done_sys_fix:
;
	clr.l	d1
	move.l	(_frclock).w,d0
	bsr	crc16_add_long
	move.l	(_hz_200).w,d0
	move.l	d0,sys_tick		;copy system tick
	bsr	crc16_add_word
	move	d1,d0
	swap	d1
	move	d0,d1
	move.l	(_vbclock).w,d0
	bsr	crc16_add_long
	move	(_hz_200+2).w,d0
	bsr	crc16_add_word
	move.l	d1,d0
	bclr	#31,d0
	tst.l	d0
	beq.s	.keep_seed
	move.l	d1,rand_32_seed
.keep_seed:
	move	(_bootdev).w,d0
	add.b	d0,auto_inf_s
	move	(sp)+,sr
	rts
;
OS_check_1_t:
	dc.l	'MiNT',MiNT_p
	dc.l	'MagX',MagX_p
	dc.l	'nAES',nAES_p
	dc.l	'Gnva',Gnva_p
	dc.l	NUL
;
initprog_end:
initprog_size	=	(initprog_end-start)+$100
;----------------------------------------------------------------------------
	BSS
;----------------------------------------------------------------------------
bss_start:
	ds.b	4*1024
loc_stack_top:
	ds.b	16
bss_end:
bss_size	=	bss_end-bss_start
initial_size	=	initprog_size+bss_size
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	ModYield.S
;----------------------------------------------------------------------------
