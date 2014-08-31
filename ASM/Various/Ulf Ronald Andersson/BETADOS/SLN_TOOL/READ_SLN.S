;----------------------------------------------------------------------------
;File name:	READ_SLN.S			Revision date:	1999.12.27
;Creator:	Ulf Ronald Andersson		Creation date:	1998.05.07
;(c)1996 by:	Ulf Ronald Andersson		All rights reserved
;----------------------------------------------------------------------------
	include	RA_ARG.I
	include	RA_APP.I
	include	RA_SIM.I
	include	RA_AV.I
;----------------------------------------------------------------------------
	output	.GTP
;----------------------------------------------------------------------------
MAX_VA_ARGLEN	=	512
;
link_bf_sz	=	256
;----------------------------------------------------------------------------
;;;huge_program		set 1	;uncomment if TEXT+DATA sections are > 32KB
;;;keep_windows		set 1	;uncomment to keep ACC vwk in main eventloop
;;;exec_timeout		set 100	;uncomment to enable timer in main eventloop
exec_message		set 1	;uncomment for messages in main eventloop
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	start_app
;----------------------------------------------------------------------------
	IFEQ	huge_program
	SECTION	DATA
	ENDC
;
;Edit the string below, to match the accessory title you want in ACC mode
;
acc_name:
	dc.b	'  Read_SLN',NUL	;for ACC menu registration
	dc.b	NUL
	even
;
;Also edit the string below, to match the application name, without
;file extension, padded to 8 bytes.  Normally this will be overwritten
;by runtime info from 'shel_read' during init, but do it just in case...
;
id_app_name_s:
	dc.b	'READ_SLN',NUL
	even
;
;----------------------------------------------------------------------------
;
	IFEQ	huge_program
	SECTION	BSS
	ENDC
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
;
;----------------------------------------------------------------------------
;Start of:	init_app
;----------------------------------------------------------------------------
init_app:
	start_arg
;
; Here URAn_ARG.S defines two variables
;
;arg_cnt	== number of strings on command line
;arg_ptr	-> NUL_separated argument strings + final NUL
;
;NB:	Both of the above include a dummy program name (first string==NUL).
;-------
	clr.l		VA_arg_p
	cmp		#2,arg_cnt
	blo.s		.done_arg
	move.l		arg_ptr,a0
	str_pass	a0
	move.l		a0,VA_arg_p
.done_arg:
;
;
;Add application dependent init above
;
	rts
;----------------------------------------------------------------------------
;End of:	init_app
;----------------------------------------------------------------------------
;Start of:	exec_app
;----------------------------------------------------------------------------
exec_app:
	cmp		#2,arg_cnt
	bne		exit_exec_err
	gemdos		Pdomain,#-1
	move		d0,entry_Pdomain
	gemdos		Pdomain,#1
	move.l		VA_arg_p(pc),a3
	move.l		a3,a0
	tst.b		(a0)
	beq.s		.done_unslash
.pass_arg_lp:
	tst.b		(a0)+
	bne.s		.pass_arg_lp
	cmp.b		#'\',-2(a0)
	bne.s		.done_unslash
	clr.b		-2(a0)
.done_unslash:
	lea		link_bf(pc),a4
	move		#-1,link_type
	move.l		#-1,link_size
	move.l		#-1,file_size
	gemdos		Freadlink,#link_bf_sz,(a4),(a3)
	move.l		d0,d3
	bsr		get_Fsfirst_data
	move.l		d0,link_size
	tst.l		d3
	bpl.s		.symlink_ok
	cmp.l		#E_INVFN,d3
	bne.s		.symlink_error
	tst.l		d0
	bmi.s		.find_error
	gemdos		Fopen,(a3),#0
	move.l		d0,d5
	bmi.s		.open_error
	gemdos		Fread,d5,#link_bf_sz,(a4)
	move.l		d0,d3
	gemdos		Fclose,d5
	tst.l		d3
	bmi.s		.read_error
	move.l		d3,file_size
	clr.l		d0
	move		(a4)+,d0
	move.l		d0,link_size
	lea		NonLink_s(pc),a0
	bra.s		.display_results
;
.symlink_ok:
	lea		(a4),a0
.loop_1:
	tst.b		(a0)+
	bne		.loop_1
	suba.l		a4,a0
	move.l		a0,link_size
	lea		Success_s(pc),a0
	bra.s		.display_results
;
.find_error:
	lea		FindErr_s(pc),a0
	bra.s		.display_results
;
.open_error:
	lea		OpenErr_s(pc),a0
	bra.s		.display_results
;
.read_error:
	lea		ReadErr_s(pc),a0
	bra.s		.display_results
;
.symlink_error:
	move.l		d3,link_size
	lea		ErrCode_s(pc),a0
.display_results:
	lea		result_s(pc),a1
.loop_2:
	move.b		(a0)+,d0
	beq.s		.exit_loop_2
	move.b		d0,(a1)+
	bra		.loop_2
.exit_loop_2:
;
	lea		link_type_num_s(pc),a0
	clr.l		d0
	move		link_type(pc),d0
	moveq		#4,d1
	moveq		#'0',d2
	bsr		conv2hexasc
;
	lea		file_size_num_s(pc),a0
	move.l		file_size(pc),d0
	moveq		#8,d1
	moveq		#'0',d2
	bsr		conv2hexasc
;
	lea		link_size_num_s(pc),a0
	move.l		link_size(pc),d0
	moveq		#8,d1
	moveq		#'0',d2
	bsr		conv2hexasc
;
	move.l		a4,a1			;a1 -> string
	lea		data_string_s(pc),a0	;a0 -> string in alert
	moveq		#2,d2			;d2 = line counter
	bsr		limit_lines
;
	sim_aes		form_alert,#1,read_sln_al_s(pc)
;
	gemdos		Pdomain,entry_Pdomain(pc)
	clr.l		d0
	bra.s		exit_terminate
;-------------------------------------
exec_APP_error:		;jump here to display alert (a3) and then exit
	sim_aes		form_alert,#1,(a3)	;NB: has simulation for TOS/TTP
exit_exec_err:		;jump here to exit with error code -1
	moveq		#-1,d0
exit_terminate:		;jump here to exit with error code in d0
	move.l		d0,d3
	bclr		#7,revise_type_f
;
;
;Add application dependent termination code above
;
	move.l		d3,d0
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
	IFNE		exec_timeout
exec_timer:
;
;
;Add application dependent timer event work above
;
exit_exec_timer:
	rts
	ENDC		exec_timeout
;----------------------------------------------------------------------------
;End of:	exec_timer
;----------------------------------------------------------------------------
;Start of:	exec_mesag
;----------------------------------------------------------------------------
	IFNE		exec_message
exec_mesag:
	cmp		#AC_CLOSE,message
	bne.s		.not_AC_CLOSE
	sf		keep_wind_f
	bra		exit_exec_mesag
;
.not_AC_CLOSE:
	cmp		#AP_TERM,message
	bne.s		.not_AP_TERM
	tst.l		d7
	bmi		exit_exec_mesag		;AP_TERM is not for ACCs
	clr.l		d0			;flag no error
	bra		exit_terminate
;
.not_AP_TERM:
	cmp		#VA_START,message
	bne		.not_VA_START
	st		VA_START_f
	move		message+2,AV_partner_id
	move.l		message+6,VA_START_cmd_p
	AV_send		PROTOKOLL,#w_VA_START+w_AV_STARTED_A,id_app_name_s
;
;Add ALL handling of the passed command line here, if you need to do some later
;you must copy it here, because the original may disappear after AV_STARTED.
;
;One way of doing this is included below, but may not always be appropriate,
;so feel free to invent your own methods...
;
	move.l		VA_START_cmd_p(pc),a0	;a0 -> argument on Venus
	move.l		a0,a1			;a1 -> argument on Venus
	str_pass	a1
	sub.l		VA_START_cmd_p(pc),a1
	move.l		a1,d1			;d1 = length of argument
	move		#MAX_VA_ARGLEN,d0
	cmp.l		d0,d1			;argument too long ?
	blo.s		.length_ok
	move.l		d0,d1			;limit argument length
.length_ok:
	move.b		(a0,d1.w),d0		;save byte at termination point
	clr.b		(a0,d1.w)		;enforce limited termination
	move.l		a0,a1			;a1 -> argument on Venus
	lea		VA_arg_s(pc),a2		;a2 -> local argument area
	move.l		a2,VA_arg_p		;prep a pointer for future
	str_copy	a1,a2			;make a local copy of argument
	move.b		d0,(a0,d1.w)		;repair original copy
;
;The message sent below is needed to let Venus release argument space
;
	AV_send.i	STARTED,VA_START_cmd_p
	bra		exec_app
;
.not_VA_START:
	cmp		#VA_PROTOSTATUS,message
	bne.s		.not_VA_PROTOSTATUS
	move		message+8,VA_protostatus
	move		message+6,VA_protostatus+2
	bra		exit_exec_mesag
;
.not_VA_PROTOSTATUS:
exec_mesag_extend:
;
;
;Add application dependent message event work above
;
exit_exec_mesag:
	rts
	ENDC		exec_message
;----------------------------------------------------------------------------
;End of:	exec_mesag
;----------------------------------------------------------------------------
;Start of:	subroutines
;----------------------------------------------------------------------------
get_Fsfirst_data:
	gemdos		Fsetdta,local_dta(pc)
	move		#0,link_type
	gemdos		Fsfirst,(a3),#$FF
	tst.l		d0
	bmi.s		.exit
	move.b		dta_fattr+local_dta(pc),link_type+1
	move.l		dta_fsize+local_dta(pc),file_size
	tst.l		d0
.exit:
	rts
;----------------------------------------------------------------------------
limit_lines:
	subq	#1,d2
	clr	d3			;d3 = progress flag
.string_lp_1:
	moveq	#29-1,d1		;d1 = char counter for 29 visible
.string_lp_2:
	moveq	#'"',d0			;pad a "quote" at start
	tst	d3
	bmi.s	.fill_it		;go pad spaces after end
	beq.s	.beg_pad		;go pad starting quote
	move.b	(a1)+,d0		;d0 = char from string
	beq.s	.end_pad		;go pad ending quote
	cmp.b	#' ',d0
	bhs.s	.pad_it			;go pad non-NUL character
	moveq	#'!',d0			;pad ctrl-char to '!'
	bra.s	.pad_it
;
.fill_it:
	moveq	#' ',d0			;pad spaces after end
	bra.s	.pad_it
;
.end_pad:
	moveq	#-2,d3
.beg_pad:
	addq	#1,d3
	moveq	#'"',d0			;pad a "quote" at beginning and end
.pad_it:
	move.b	d0,(a0)+		;store alert character at (a0)+
	dbra	d1,.string_lp_2
	addq	#1,a0			;step a0 past newline
	dbra	d2,.string_lp_1
	rts
;
;----------------------------------------------------------------------------
;	conv2decasc(ULONG number,int digits,char pad_char,char *dest_p)
;
;Entry:	a0 -> destination
;  "	d0 =  number to convert
;  "	d1 =  max number of digits allowed
;  "	d2 =  pad character
;
conv2decasc:
	movem.l	d1/d3-d5,-(sp)
	subq	#1,d1
	moveq	#'0',d3		;ensure digit pad for zero
.loop:
	move.b	d3,d4		;assume value needs padding
	tst.l	d0		;then check if it does
	beq.s	.next		;and if so, go pad it
	clr.l	d5
	swap	d0
	move	d0,d5		;d5 = high word of d0
	divu	#10,d5		;d5 /= 10
	move	d5,d0		;
	swap	d0		;high word of d0 = quotient
	clr	d5
	move	d0,d5		;d5 = remainder from above <<16 + low word of d0
	divu	#10,d5
	move	d5,d0		;d0 is now full ULONG quotient
	swap	d5
	move	d5,d4		;d4 = remainder
	add	#'0',d4		;d4 = ascii char for this digit
.next:
	move.b	d4,(a0,d1)	;store one ascii character
	move.b	d2,d3		;later pads use given char
	dbra	d1,.loop	;loop back for entire character field
	movem.l	(sp)+,d1/d3-d5
	rts
;----------------------------------------------------------------------------
;	conv2hexasc(ULONG number,int digits,char pad_char,char *dest_p)
;
;Entry:	a0 -> destination
;  "	d0 =  number to convert
;  "	d1 =  max number of digits allowed
;  "	d2 =  pad character
;
conv2hexasc:
	movem.l	d1/d3-d5,-(sp)
	subq	#1,d1
	moveq	#'0',d3		;digit pad for leading zeroes
.loop:
	move.b	d3,d4		;assume value needs padding
	tst.l	d0		;then check if it does
	beq.s	.next		;and if so, go pad it
	clr.l	d5
	swap	d0
	move	d0,d5		;d5 = high word of d0
	divu	#16,d5		;d5 /= 10
	move	d5,d0		;
	swap	d0		;high word of d0 = quotient
	clr	d5
	move	d0,d5		;d5 = remainder from above <<16 + low word of d0
	divu	#16,d5
	move	d5,d0		;d0 is now full ULONG quotient
	swap	d5
	move	d5,d4		;d4 = remainder
	add	#'0',d4		;d4 = ascii char for this digit
	cmp.b	#'9',d4
	bls.s	.next
	addq.b	#'A'-('9'+1),d4	;conver high hex digits to range A..F
.next:
	move.b	d4,(a0,d1)	;store one ascii character
	move.b	d2,d3		;later pads use given char
	dbra	d1,.loop	;loop back for entire character field
	movem.l	(sp)+,d1/d3-d5
	rts
;----------------------------------------------------------------------------
;End of:	subroutines
;----------------------------------------------------------------------------
;	Library function code will be expanded here
;
	make	SIM_links
	make	AV_links
;----------------------------------------------------------------------------
text_limit:
	SECTION	DATA
;----------------------------------------------------------------------------
read_sln_al_s:
	dc.b	'[1]['
	dc.b	'______ READ_SLN '
result_s:
	dc.b                    'Success _____|'
	dc.b	'link:    filesize=$'
file_size_num_s:
	dc.b			   '00000000  |'
	dc.b	'Attr=$'
link_type_num_s:
	dc.b	      '0000   spec=$'
link_size_num_s:
	dc.b			   '00000000  |'
data_string_s:
	dc.b	'                             |'
	dc.b	'                             ]'
	dc.b	'[  Exit  ]'
	dc.b	NUL
	even
;
Success_s:	dc.b	'Success',NUL
NonLink_s:	dc.b	'NonLink',NUL
ErrCode_s:	dc.b	'ErrCode',NUL
FindErr_s:	dc.b	'FindErr',NUL
OpenErr_s:	dc.b	'OpenErr',NUL
ReadErr_s:	dc.b	'ReadErr',NUL
;----------------------------------------------------------------------------
data_limit:
	SECTION	BSS
;----------------------------------------------------------------------------
entry_Pdomain:	ds.w	1
VA_START_f:	ds.w	1
VA_START_cmd_p:	ds.l	1
VA_protostatus:	ds.l	1
VA_arg_p:	ds.l	1
VA_arg_s:	ds.b	MAX_VA_ARGLEN
		even
;
link_bf:	ds.b	link_bf_sz
local_dta:	ds.b	sizeof_dta_struct
link_type:	ds.w	1
link_size:	ds.l	1
file_size:	ds.l	1
;----------------------------------------------------------------------------
bss_limit:
	END
;----------------------------------------------------------------------------
;End of file:	READ_SLN.S
;----------------------------------------------------------------------------
