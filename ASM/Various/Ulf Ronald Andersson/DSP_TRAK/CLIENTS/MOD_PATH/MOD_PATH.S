;----------------------------------------------------------------------------
;File name:	MOD_PATH.S			Revision date:	1999.19.20
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
	output	.APP
;
	include	RA_TOS.I
	include	RA_SIM.I
	include	RA_LA.I
	include	RA_AV.I
	include	RA_XB.I
	include	RA_DspT.I
	include	RA_JAR.I
	include	RA_ARG.I
	include	RA_APP.I
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	start_app
;----------------------------------------------------------------------------
	ifnd	huge_program
	SECTION	DATA
	endc
;-------------------------------------
acc_name:	dc.b	'  Acc name',NUL	;for ACC menu registration
		dc.b	NUL
id_app_name_s:	dc.b	'MOD_PATH',NUL
		EVEN
;----------------------------------------------------------------------------
	ifnd	huge_program
	SECTION	BSS
	endc
;-------------------------------------
message:	ds.w	8		;evnt_mesag message pipe
intin:		ds.w	30		;30 words or more for AES/VDI
intout:		ds.w	45		;45 words or more for AES/VDI
ptsin:		ds.w	30		;30 words or more for VDI
ptsout:		ds.w	12		;12 words or more for VDI output coordinates
		ds.l	200		;subroutine stack >= 100 longs
mystack:	ds.l	1		;top of subroutine stack
;----------------------------------------------------------------------------
	SECTION	TEXT
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
;----------------------------------------------------------------------------
;Start of:	init_app
;----------------------------------------------------------------------------
init_app:
	rts
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
exec_app:
	lea	mod_path_s(pc),a4
	clr.b	(a4)
	DspT_u_init
	DspT	u,get_mod_path,mod_path_s(pc)	;get a copy of last path
	lea	mod_path_al_tail_s(pc),a2	;a2->tail definition for alert
	lea	mod_path_al_head_s(pc),a1	;a1->head definition for alert
	lea	mod_path_s(pc),a0		;a0->text for quote lines
	move	#1,d1				;def_button = 1
	move	#3,d0				;max_lines = 3
	bsr	quote_alert			;build and use the alert
exit_exec_app:
	clr.l	d0
	rts
;----------------------------------------------------------------------------
;End of:	exec_app
;----------------------------------------------------------------------------
;Start of:	exec_timer
;----------------------------------------------------------------------------
	ifd	exec_timeout	;cond:	ifd exec_timeout
exec_timer:
exit_exec_timer:
	rts
	endc			;ends:	ifd exec_timeout
;----------------------------------------------------------------------------
;End of:	exec_timer
;----------------------------------------------------------------------------
;Start of:	exec_mesag
;----------------------------------------------------------------------------
	ifd	exec_message	;cond:	ifd exec_message
exec_mesag:
	cmp	#AC_CLOSE,message
	beq	exec_mesag_AC_CLOSE
	bra	exit_exec_mesag
;-------
exec_mesag_AC_CLOSE:
	sf	keep_wind_f
exit_exec_mesag:
	rts
	endc			;ends:	ifd exec_message
;----------------------------------------------------------------------------
;End of:	exec_mesag
;----------------------------------------------------------------------------
	include	Path_Lib.S
;----------------------------------------------------------------------------
quote_alert:	;a0->quote a1->head a2->tail d0=max_lines d1=def_button
	movem.l	d1-d2/a0-a3,-(sp)
	lea	alert_buffer(pc),a3
.loop_0:
	move.b	(a1)+,(a3)+	;copy a header char
	bne.s	.loop_0
	subq	#1,a3		;a3->quote body start
	move	d0,d1
	subq	#1,d1		;d1 is dbra count for max lines
	blt.s	.done_lines	;go terminate if no lines allowed
.loop_1:
	move.b	#'"',(a3)+
	moveq	#27-1,d2	;d2 is dbra count for max 27 char/line
.loop_2:
	move.b	(a0)+,d0
	beq.s	.patch_1
	cmp.b	#' ',d0
	blo.s	.mask_char
	cmp.b	#'[',d0
	beq.s	.mask_char
	cmp.b	#'|',d0
	beq.s	.mask_char
	cmp.b	#']',d0
	bne.s	.masked_char
.mask_char:
	move.b	#'.',d0
.masked_char:
	move.b	d0,(a3)+
	dbra	d2,.loop_2
	move.b	#'"',(a3)+
	move.b	#'|',(a3)+
	dbra	d1,.loop_1
	bra.s	.patch_2
;-------
.patch_1:
	move.b	#'"',(a3)+
	bra.s	.done_lines
;-------
.patch_2:
	subq	#1,a1
.done_lines:
.tail_loop:
	move.b	(a2)+,(a3)+
	bne.s	.tail_loop
	clr.b	(a3)
	move.l	(sp),d1
	sim_aes	form_alert,d1,alert_buffer(pc)
	movem.l	(sp)+,d1-d2/a0-a3
	rts		;d0 = button returned
;----------------------------------------------------------------------------
	make	AV_links
	make	SIM_links
	make	JAR_links
;----------------------------------------------------------------------------
text_limit:	section	DATA
;----------------------------------------------------------------------------
mod_path_al_head_s:
	dc.b	'[0]['
	dc.b	'Latest DspT module load path:|'
	dc.b	'-----------------------------|'
	dc.b	NUL
;-------------------------------------
mod_path_al_tail_s:
	dc.b	'][ Ok ]',NUL
;-------------------------------------
	EVEN
;----------------------------------------------------------------------------
data_limit:	SECTION	BSS
;----------------------------------------------------------------------------
;Enter program variable definitions below:
;
alert_buffer:	ds.l	256/4
mod_path_s:	ds.l	128/4
purename_p:	ds.l	128/4
;----------------------------------------------------------------------------
bss_limit:	END
;----------------------------------------------------------------------------
;End of file:	MOD_PATH.S
;----------------------------------------------------------------------------
