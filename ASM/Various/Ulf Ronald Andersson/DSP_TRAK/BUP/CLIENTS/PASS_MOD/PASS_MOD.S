;----------------------------------------------------------------------------
;File name:	PASS_MOD.S			Revision date:	1997.12.20
;Creator:	Ulf Ronald Andersson		Creation date:	1996.02.19
;(c)1996 by:	Ulf Ronald Andersson		All rights reserved
;----------------------------------------------------------------------------
;
;;;huge_program		= 1	;uncomment if TEXT+DATA sections are > 32KB
;;;keep_windows		= 1	;uncomment to keep ACC vwk in main eventloop
;;;exec_timeout		= 100	;uncomment to enable timer in main eventloop
;;;exec_message		= 1	;uncomment for messages in main eventloop
;
;----------------------------------------------------------------------------
;
	output	.APP
;
	include	URAn_DOS.S
	include	URAn_SIM.S
	include	URAn_LA.S
	include	URAn_AV.S
	include	URAn_XB.S
	include	Mod_Cook.S
	include	URAn_JAR.S
;
;----------------------------------------------------------------------------
;
	SECTION	TEXT
;
	include	URAn_APP.S
;
;----------------------------------------------------------------------------
;
	ifnd	huge_program
	SECTION	DATA
	endc
;
acc_name:	dc.b	'  Acc name',NUL	;for ACC menu registration
		dc.b	NUL
;
;----------------------------------------------------------------------------
;
	ifnd	huge_program
	SECTION	BSS
	endc
;
message:	ds.w	8		;evnt_mesag message pipe
intin:		ds.w	30		;30 words or more for AES/VDI
intout:		ds.w	45		;45 words or more for AES/VDI
ptsin:		ds.w	30		;30 words or more for VDI
ptsout:		ds.w	12		;12 words or more for VDI output coordinates
		ds.l	200		;subroutine stack >= 100 longs
mystack:	ds.l	1		;top of subroutine stack
;
;----------------------------------------------------------------------------
;
	SECTION	TEXT
;
;----------------------------------------------------------------------------
;	Constants, Variables, and Usage of the URAn_APP.S library
;
;rz		'relative zero' for internal references
;basepage_p	-> program's base page
;tsr_size	.L size of BASEPAGE+TEXT+DATA+BSS  (only TOS/TTP may TSR)
;progtype	.L indicates program type:
;  ...			$0000.$FFFF == TOS/TTP/boot_PRG
;  ...			$0000.ap_id == APP/GTP/non_boot_PRG
;  ...			$FFFF.ap_id == ACC
;acc_flag	is the high word of 'progtype'
;tos_flag	is the low word of 'progtype'
;bootflag	.W $FFFF == PRG booted from AUTO (also sets 'tos_flag')
;menu_id	.W menu id for an ACC, otherwise null
;g_handle	.W workstation handle for ACC/APP/GTP/non_boot_PRG
;vwk_handle	.W virtual workstation handle
;contrl		12 words for AES/VDI control data
;
;wk_x_rez \
;wk_y_rez  \/ from
;wk_pix_w  /\ opnvwk
;wk_pix_h /
;
;MiNT_p		.L NULL or -> MiNT structure
;MagX_p		.L NULL or -> MagX structure
;nAES_p		.L NULL or -> nAES structure
;Gnva_p		.L NULL or -> Gnva structure
;
;line_a_base_p	.L -> line_a variable base
;kbshift_p	.L -> kbshift byte of OS
;currbp_p_p	.L -> OS var -> current basepage
;
;NB: if symbol 'huge_program' is defined, above data is in TEXT section (else in BSS)
;NB: defining 'huge_program' also makes function calls use 'jsr' (instead of bsr)
;
;Required user routines:
;
;init_app	called for ACC/APP/GTP/non_boot_PRG to init application,
;		but doesn't need appl_init, graf_handle, or v_opnvwk,
;		nor does an ACC need menu_register.
;		Suitable use is for initialization of object trees.
;NB:  for ACC	menu_register is called between init_app and exec_app
;
;exec_app	called to execute the main application regardless of type,
;		but doesn't need v_clsvwk, or appl_exit, or ACC appl_mesag.
;		This call will be repeated for a reactivated ACC.
;		Non_acc programs should have exit code in d0 at RTS.
;		(See details at 'Exit codes:' below)
;
;	At entry to either of these two routines:
;
;		d6.W	== bootflag	\
;		d7.L	== progtype	 > See descriptions above.
;		a6.L	== rz		/
;
;Optional user routines:
;
;exec_timer	Called for ACC that has a defined constant 'exec_timeout',
;		whenever evnt_multi produces such a timer event.
;		The constant is placed as long at 'main_timeout', and may
;		there be dynamically adjusted by the program.
;
;exec_mesag	Called for ACC that has a defined constant 'exec_message',
;		whenever evnt_multi/evnt_mesag produces messages that are
;		not AC_OPEN  (such as VA_START).
;
;		If the constant 'keep_windows' is also set, the workstation
;		will not be closed at each return (you must obey AC_CLOSE).
;		This places a word == $FF00 at 'keep_wind_f', and if the top
;		byte is cleared the workstation closure is enabled again.
;
;NB:	Top bit of the word 'revise_type_f' is used for 3 purposes:
;   1:	Let ACC start 'exec_app' directly without awaiting event.
;   2:	Let APP delay 'exec_app' until an event occurs.
;   3:	Let APP loop back for more events after 'exec_app'
;The flag must be set by 'init_app' in the first two cases, and in case 3
;should be set/cleared in 'exec_app' to decide whether to exit program.
;
;Exit codes:	At exit from exec_app, d0 has the following effects
;		when the program was not started as accessory.
;
; negative	=> Pterm(d0)			=> error code exit
; 0		=> Pterm(d0)			=> error free exit
; 0x0000ADD0	=> Ptermres(tsr_size,0)		=> error free resident exit
; 0x0000ADD1	=> Ptermres(d1,0)		=> error free resident exit
; 0x0000ADD2	=> Ptermres(d1,d2)		=> error code resident exit
;
;----------------------------------------------------------------------------
;Start of:	init_app
;----------------------------------------------------------------------------
;
init_app:
	include	URAn_ARG.S
	gemdos	Super,!
	move.l	d0,-(sp)
	eval_cookie	#DspT_s_c
	move.l	d0,mod_cookie_p-rz(a6)
	ble.s	.done_cookie
	move.l	d0,a0
	lea	loc_mod_cookie(pc),a1
	move.l	#mod_size-1,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
.done_cookie:
      	gemdos	Super,()
;
	tst.l	mod_cookie_p-rz(a6)
	ble.s	.do_rts
	lea	mainpath_s(pc),a1
	clr.b	(a1)
	cmp	#2,arg_cnt
	blt.s	.no_arg
	move.l	arg_ptr(pc),a0
	strpass	a0			;pass dummy filename
	strcpy	a0,a1			;copy first argument
	lea	mainpath_s(pc),a0
	cmp.b	#'0',(a0)
	blo.s	.special_arg
	bsr	fix_path		;a0 -> full path
.loop_1:
	move.l	a0,a2	;possible end of pure path in mainpath_s
.loop_2:
	move.b	(a0)+,d0
	beq.s	.end_path
	cmp.b	#'\',d0
	bne.s	.loop_2
	bra.s	.loop_1
;
.end_path:
	move.l	a2,purename_p-rz(a6)
	clr.l	d0
.do_rts:
	move.l	d0,init_err_code
	rts
;
.no_arg:
	clr.b	mainpath_s-rz(a6)
.special_arg:
	rts
;
;----------------------------------------------------------------------------
;End of:	init_app
;----------------------------------------------------------------------------
;	URAn_ARG.S defines two variables
;
;arg_cnt	== number of strings on command line
;arg_ptr	-> NUL_separated argument strings + final NUL
;
;NB:	Both of the above include a dummy program name (first string==NUL).
;----------------------------------------------------------------------------
;Start of:	exec_app
;----------------------------------------------------------------------------
;
exec_app:
	move.l	init_err_code(pc),d0
	bmi.s	exit_exec_app
	moveq	#E_ERROR,d0
	tst.l	d7
	bmi.s	exit_exec_app
	move.l	mod_cookie_p(pc),d0
	bmi.s	exit_exec_app
	move.l	d0,a5			;a5 -> mod server cookie
	jsr_mod	a5,dump			;turn off old music, if any
	lea	mainpath_s(pc),a4
	move.b	(a4),d4
	cmp.b	#'A',(a4)
	bhs.s	exec_path_arg
exec_special_arg:
	tst.b	d4
	beq	exec_default
exit_exec_app:
	clr.l	d0
	rts
;
exec_path_arg:
	move.l	purename_p(pc),a3
	tst.b	(a3)
	beq	exec_random_mod
	move.l	a4,a0
	jsr_mod	a5,load
	tst.l	d0
	bmi	exit_exec_app
	move.l	mod_free(a5),a1		;release buffer at dump
	jsr_mod	a5,start		;start Music
	bra	exit_exec_app		;exit program
;
exec_default:
;;;	patch
exec_random_mod:
;;;	patch
	bra	exit_exec_app
;
;----------------------------------------------------------------------------
;End of:	exec_app
;----------------------------------------------------------------------------
;Start of:	exec_timer
;----------------------------------------------------------------------------
;
	ifd	exec_timeout	;cond:	ifd exec_timeout
exec_timer:
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
	beq	exec_mesag_AC_CLOSE
;
	bra	exit_exec_mesag
;
exec_mesag_AC_CLOSE:
	sf	keep_wind_f
exit_exec_mesag:
	rts
	endc			;ends:	ifd exec_message
;
;----------------------------------------------------------------------------
;End of:	exec_mesag
;----------------------------------------------------------------------------
;
	include	Path_Lib.S
;
;----------------------------------------------------------------------------
;
	make	AV_links
	make	SIM_links
	make	JAR_links
;
;----------------------------------------------------------------------------
;
text_limit:	section	DATA
;
;----------------------------------------------------------------------------
;Enter program constant definitions below:
;
;
;----------------------------------------------------------------------------
;
data_limit:	SECTION	BSS
;
;----------------------------------------------------------------------------
;Enter program variable definitions below:
;
init_err_code:	ds.l	1
file_size:	ds.l	1
mainpath_s:	ds.l	128/4
purename_p:	ds.l	128/4
mod_cookie_p:	ds.l	1
loc_mod_cookie:	ds.l	mod_size/4
	ds.b	mod_size
;
;----------------------------------------------------------------------------
bss_limit:	END
;----------------------------------------------------------------------------
;End of file:	PASS_MOD.S
;----------------------------------------------------------------------------
