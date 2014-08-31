;----------------------------------------------------------------------------
;File name:	PLAY_RND.S			Revision date:	1998.11.20
;Creator:	Ulf Ronald Andersson		Creation date:	1996.02.19
;(c)1996 by:	Ulf Ronald Andersson		All rights reserved
;----------------------------------------------------------------------------
;;;huge_program		= 1	;uncomment if TEXT+DATA sections are > 32KB
;;;keep_windows		= 1	;uncomment to keep ACC vwk in main eventloop
exec_timeout		= 200	;uncomment to enable timer in main eventloop
exec_message		= 1	;uncomment for messages in main eventloop
;----------------------------------------------------------------------------
MAX_VA_ARGLEN	equ	512
;----------------------------------------------------------------------------
	output	.APP
;----------------------------------------------------------------------------
	include	RA_ARG.I
	include	RA_APP.I
	include	RA_SIM.I
	include	RA_AV.I
	include	RA_XB.I
	include	RA_JAR.I
	include Mod_Cook.I
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	start_app
;----------------------------------------------------------------------------
	ifeq	huge_program
	SECTION	DATA
	endc
;----------------------------------------------------------------------------
acc_name:	dc.b	'  Play random MOD',NUL	;for ACC menu registration
id_app_name_s:	dc.b	'PLAY_RND',NUL
		EVEN
;----------------------------------------------------------------------------
	ifeq	huge_program
	SECTION	BSS
	endc
;----------------------------------------------------------------------------
message:	ds.w	8		;evnt_mesag message pipe
intin:		ds.w	30		;30 words or more for AES/VDI
intout:		ds.w	45		;45 words or more for AES/VDI
ptsin:		ds.w	30		;30 words or more for VDI
ptsout:		ds.w	12		;12 words or more for VDI output coordinates
		ds.l	1024		;subroutine stack >= 1024 longs
mystack:	ds.l	1		;top of subroutine stack
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;Start of:	init_app
;----------------------------------------------------------------------------
init_app:
	start_arg
	move.l	#empty_string_s,VA_arg_p
	cmp	#2,arg_cnt
	blo.s	.done_arg
	move.l	arg_ptr,a0
	strpass	a0
	move.l	a0,VA_arg_p
.done_arg:
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	_frclock,d0
	add.l	_vbclock,d0
	eor.l	d0,rand_32_seed
	move	(_bootdev).w,d0
	add.b	d0,auto_inf_s
	eval_cookie	#DspT_s_c
	move.l	d0,mod_cookie_p-rz(a6)
	gemdos	Super,()
;
	tst.l	d7
	bmi.s	exec_app
	rts
;----------------------------------------------------------------------------
;End of:	init_app
;----------------------------------------------------------------------------
;Start of:	exec_app
;----------------------------------------------------------------------------
exec_app:
	clr	d0			;preclear low word of d0
	tst.w	d7			;MI/PL == TOS/GEM
	bmi.s	.TOS_checked		;go keep d0 bit_3 cleared for TOS/TTP program
	bset	#3,d0			;set d0 bit_3 for GEM program
.TOS_checked:
	cmp	#1,global+2		;EQ/NE == Single/Multi-tasking AES
	beq.s	.MULTI_checked		;go keep d0 bit_2 cleared for singletasking
	bset	#2,d0			;set d0 bit_2 for multitasking
.MULTI_checked:
	tst.l	d7			;MI/PL == ACC/nonACC
	bpl.s	.ACC_checked		;go keep d0 bit_1 cleared for nonACC
	bset	#1,d0			;set d0 bit_1 for ACC
.ACC_checked:
	move	exec_ref(pc,d0),d0	;fetch a word offset to selected exec code
	jmp	exec_ref(pc,d0)	;jump to selected exec code
;-------------------------------------
exec_ref:
	dc.w	exec_TOS-exec_ref,exec_TOS-exec_ref
	dc.w	exec_TOS-exec_ref,exec_TOS-exec_ref
	dc.w	exec_single_APP-exec_ref,exec_single_ACC-exec_ref
	dc.w	exec_multi_APP-exec_ref,exec_multi_ACC-exec_ref
;-------------------------------------
exec_multi_APP:
	btst	#7,revise_type_f	;been here before ?
	bne.s	repeat_multi_APP	;then behave like an ACC this time
initial_multi_APP:
	bset	#7,revise_type_f	;tell main loop to behave like ACC
;;;	bra	exit_app_ok		;exit to main event loop
;-------------------------------------
repeat_multi_APP:
exec_single_ACC:
exec_multi_ACC:
exec_single_APP:
exec_TOS:
	move.l	mod_cookie_p(pc),d0
	ble	exit_exec_err
	move.l	d0,a5			;a5 -> mod server cookie
	tas	inited_f
	bmi.s	done_init_modes
	moveq	#2,d0
	jsr_mod	a5,set_boost
	moveq	#1,d0
	jsr_mod	a5,set_timer
done_init_modes:
;
	move.l	VA_arg_p(pc),a0
	tst.b	(a0)
	beq.s	.no_arg
	lea	main_path_s(pc),a1
	strcpy	a0,a1			;copy first argument
	lea	main_path_s(pc),a0
	cmp.b	#'0',(a0)
	blo.s	.special_arg
	bsr	fix_path		;a0 -> full path
.loop_1:
	move.l	a0,a2	;possible end of pure path in main_path_s
.loop_2:
	move.b	(a0)+,d0
	beq.s	.end_path
	cmp.b	#'\',d0
	bne.s	.loop_2
	bra.s	.loop_1
;
.end_path:
	move.l	a2,purename_p-rz(a6)
.no_arg:
.special_arg:
	jsr_mod	a5,dump			;turn off old music, if any
	move.l	VA_arg_p(pc),a3
	lea	main_path_s(pc),a0	;\
	lea	load_path_s(pc),a1	; > copy main_path_s to load_path_s
	strcpy	a0,a1			;/
	cmp.b	#'0',(a3)
	bhs.s	exec_path_arg
	tst.b	(a3)
	beq	exec_default
exec_special_arg:
	bra	exit_exec_err
;
exec_default:
	bsr	validate_inf		;validate path info for random search
	lea	main_path_s(pc),a0	;\
	lea	load_path_s(pc),a1	; > copy main_path_s to load_path_s
	strcpy	a0,a1			;/
exec_random_mod:
	bsr	select_random_mod
	tst.l	d0
	bmi	exit_exec_app
	bra.s	exec_some_mod
;
exec_path_arg:
	move.l	purename_p(pc),d0
	ble	exec_random_mod
	move.l	d0,a3
	tst.b	(a3)
	beq	exec_random_mod
exec_some_mod:
	lea	load_path_s(pc),a0	;\/ load a MOD file
	jsr_mod	a5,load			;/\ using load_path_s
	tst.l	d0			;success ?
	bmi	exit_exec_app		;on error, goto exit_exec_app
	move.l	a0,module_p-rz(a6)	;store -> loaded module
	moveq	#2,d0
	jsr_mod	a5,set_boost
	moveq	#1,d0
	jsr_mod	a5,set_timer		;use timer A for Music
	move.l	module_p(pc),a0		;choose loaded Module
	move.l	mod_free(a5),a1		;release buffer at dump
	jsr_mod	a5,start		;start Music
	bra	exit_exec_app		;exit program
;
exit_exec_err:		;jump here to exit with error code -1
	moveq		#-1,d0
exit_terminate:		;jump here to exit with error code in d0
	bclr		#7,revise_type_f
	bra.s		exit_exec_app
;-------------------------------------
exit_exec_ok:
	clr.l	d0
exit_exec_app:
	rts
;----------------------------------------------------------------------------
;End of:	exec_app
;----------------------------------------------------------------------------
;Start of:	exec_timer
;----------------------------------------------------------------------------
;
	ifd	exec_timeout	;cond:	ifd exec_timeout
exec_timer:
	move.l	mod_cookie_p(pc),d0
	ble.s	exit_exec_timer
	move.l	d0,a5			;a5 -> mod server cookie
	jsr_mod	a5,test_end
	bne	.get_new_random_module
.not_song_end:
	move.l	kbshift_p(pc),a0
	move.b	(a0),d0
	and	#$0F,d0
	cmp	#$0F,d0
	bne.s	.done_turnoff
	jsr_mod	a5,dump
.done_turnoff:
	cmp	kbsh_code(pc),d0
	bne.s	.not_key_command
.get_new_random_module:
	clr.b	VA_arg_s		;prevent reload of older module
	bra	exec_app		;and then go load a random module
;
.not_key_command:
exit_exec_timer:
	rts
	endc			;ends:	ifd exec_timeout
;
;----------------------------------------------------------------------------
;End of:	exec_timer
;----------------------------------------------------------------------------
;Start of:	exec_mesag
;----------------------------------------------------------------------------
;
	ifd	exec_message	;cond:	ifd exec_message
exec_mesag:
	cmp	#AC_CLOSE,message
	bne.s	.not_AC_CLOSE
	sf	keep_wind_f
	bra	exit_exec_mesag
;
.not_AC_CLOSE:
	cmp	#AP_TERM,message
	bne.s	.not_AP_TERM
	tst.l	d7
	bmi	exit_exec_mesag		;AP_TERM is not for ACCs
	clr.l	d0			;flag no error
	bra	exit_terminate
;
.not_AP_TERM:
	cmp	#VA_START,message
	bne	.not_VA_START
	st	VA_START_f
	move	message+2,AV_partner_id
	move.l	message+6,VA_START_cmd_p
;
	AV_send	PROTOKOLL,#w_VA_START+w_AV_STARTED_A,id_app_name_s
;
	move.l	VA_START_cmd_p(pc),a0	;a0 -> argument on Venus
	move.l	a0,a1			;a1 -> argument on Venus
	strpass	a1
	sub.l	VA_START_cmd_p(pc),a1
	move.l	a1,d1			;d1 = length of argument
	move	#MAX_VA_ARGLEN,d0
	cmp.l	d0,d1			;argument too long ?
	blo.s	.length_ok
	move.l	d0,d1			;limit argument length
.length_ok:
	move.b	-1(a0,d1.w),d0		;save byte at termination point
	clr.b	-1(a0,d1.w)		;enforce limited termination
	move.l	a0,a1			;a1 -> argument on Venus
	lea	VA_arg_s(pc),a2		;a2 -> local argument area
	move.l	a2,VA_arg_p		;prep a pointer for future
	strcpy	a1,a2			;make a local copy of argument
	move.b	d0,-1(a0,d1.w)		;repair original copy
;
	AV_send	STARTED|_ind,VA_START_cmd_p(pc)
	bra	exec_app
;
.not_VA_START:
	cmp	#VA_PROTOSTATUS,message
	bne.s	.not_VA_PROTOSTATUS
	move	message+8,VA_protostatus
	move	message+6,VA_protostatus+2
	bra	exit_exec_mesag
;
.not_VA_PROTOSTATUS:
exec_mesag_extend:
exit_exec_mesag:
	rts
	endc			;ends:	ifd exec_message
;----------------------------------------------------------------------------
;End of:	exec_mesag
;----------------------------------------------------------------------------
	include	Path_Lib.S
;----------------------------------------------------------------------------
	rand_32
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
	lea	load_path_s(pc),a0	;A0 -> load_path_s
	bsr	fix_path		;ensure full path in load_path_s
	bsr	count_files		;d0 = cnt of MOD files found
	move.l	d0,d2			;d2 = cnt of MOD files found
	bne	.have_files		;if any MODs found, goto .have_files
	bsr	count_folds		;d0 = cnt of folders found
	move.l	d0,d2			;d2 = cnt of folders found
	beq	.exit			;if none, exit with failure
.have_folds:
	rand_32				;d0 = rnd(1<<32)
	clr	d0
	swap	d0
	divu	d2,d0			;d0 = rnd(1<<16) / fold_count
	clr	d0
	swap	d0
	move.l	d0,d3			;d3 = rnd(1<<16) % fold_count
	clr.l	d4			;d4 = 0, folder index
;
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
	bsr	cut_name			;remove wildcard folder name
	strpass	a0				;a0 -> beyond load_path_s string
	subq	#1,a0				;a0 -> load_path_s string terminator
	lea	local_dta+dta_fname(pc),a1	;a1 -> real folder name in DTA
	strcpy	a1,a0				;copy real folder name
	move.b	#'\',-1(a0)			;replace terminator with backslash
	clr.b	(a0)				;and reterminate string
	bsr	count_files		;d0 = cnt of MOD files found
	move.l	d0,d2			;d2 = cnt of MOD files found
	beq.s	.exit			;exit on failure
.have_files:
	st	autoload_iz_f
	rand_32				;d0 = rnd(1<<32)
	clr	d0
	swap	d0
	divu	d2,d0			;d0 = rnd(1<<16) / file_count
	clr	d0
	swap	d0
	move.l	d0,d3			;d3 = rnd(1<<16) % file_count
	clr.l	d4			;d4 = 0, file index
;
	lea	main_path_s(pc),a0
	bsr	fix_path
	lea	auto_path_s(pc),a1
	strcpy	a0,a1
;
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
;
.done_seek:
	addq	#1,d4
	lea	local_dta+dta_fname(pc),a0	;\
	lea	main_fname_s(pc),a1		; > copy real filename
	strcpy	a0,a1				;/
.exit:
	lea	load_path_s(pc),a0	;a0 -> load_path_s,  with wildcard
	bsr	cut_name		;remove wildcard from load_path_s
	lea	main_fname_s(pc),a1	;a1 -> pure filename of MOD file
	bsr	new_name		;add MOD filename to load_path_s
;
	gemdos	Fsetdta,()		;revive entry DTA
	move.l	d4,d0			;d0 = d4, error_flag/file_index
	movem.l	(sp)+,d1-d4/a0-a3	;pull some registers
	rts				;return to caller
;----------------------------------------------------------------------------
count_files:
	movem.l	d1-d3/a0-a3,-(sp)
	gemdos	Fgetdta
	move.l	d0,-(sp)
;
	gemdos	Fsetdta,local_dta(pc)
	clr.l	d3
	tst.b	valid_inf_f
	beq.s	.exit
;
	lea	load_path_s(pc),a0
	lea	modfile_mask_s(pc),a1
	bsr	new_name
;
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
;
	gemdos	Fsetdta,()
	move.l	d3,d0
	movem.l	(sp)+,d1-d3/a0-a3
	rts
;----------------------------------------------------------------------------
count_folds:
	movem.l	d1-d3/a0-a3,-(sp)
	gemdos	Fgetdta
	move.l	d0,-(sp)
;
	gemdos	Fsetdta,local_dta(pc)
	clr.l	d3
	tst.b	valid_inf_f
	beq.s	.exit
;
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
	gemdos	Fread,d3,#1,auto_step_c(pc)
	cmp.l	#1,d0
	bne	.invalid_read
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
;
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
	make	AV_links
	make	SIM_links
	make	JAR_links
;----------------------------------------------------------------------------
text_limit:	section	DATA
;----------------------------------------------------------------------------
;Enter program constant definitions below:
;
empty_string_s:	dc.w	0
kbsh_code:	dc.w	-1
inited_f:	dc.w	0
valid_inf_f:	dc.w	0
autoload_iz_f:	dc.w	0
auto_inf_s:	dc.b	'A:\AUTO_MOD.INF',NUL
auto_step_c:	dc.b	'5'
modfile_mask_s:	dc.b	'*.?OD',NUL
star_pt_star_s:	dc.b	'*.*',NUL
auto_fname_len	= *-modfile_mask_s
	even
;----------------------------------------------------------------------------
data_limit:	SECTION	BSS
;----------------------------------------------------------------------------
;Enter program variable definitions below:
;
VA_START_f:	ds.w	1
VA_START_cmd_p:	ds.l	1
VA_protostatus:	ds.l	1
VA_arg_p:	ds.l	1
VA_arg_s:	ds.b	MAX_VA_ARGLEN
		even
;
auto_path_s:	ds.l	128/4
file_size:	ds.l	1
main_path_s:	ds.l	128/4
load_path_s:	ds.l	128/4
purename_p:	ds.l	128/4
module_p:	ds.l	1
mod_cookie_p:	ds.l	1
auto_dta:	ds.l	44/4
local_dta:	ds.l	44/4
main_fname_s:	ds.l	16/4
;----------------------------------------------------------------------------
bss_limit:	END
;----------------------------------------------------------------------------
;End of file:	PLAY_RND.S
;----------------------------------------------------------------------------
