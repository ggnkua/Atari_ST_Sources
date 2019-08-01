;----------------------------------------------------------------------------
;File name:	RA_APP.I		Revision date:	2000.11.09
;Creator:	Ulf Ronald Andersson	Creation date:	1992.11.30
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;File purpose:	Code library for general application header
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_APP_defined
RA_APP_defined	set	1
;----------------------------------------------------------------------------
	IFND	exec_timeout
exec_timeout	set	0
	ENDC
	IFND	exec_message
exec_message	set	0
	ENDC
	IFND	keep_windows
keep_windows	set	0
	ENDC
	IFND	huge_program
huge_program	set	0
	ENDC
	IFND	skip_vq_aes
skip_vq_aes	set	0
	ENDC
	IFND	skip_nametest
skip_nametest	set	0
	ENDC
;----------------------------------------------------------------------------
;Remarks:
;	This file should be included at the head of a program to make it
;	able to run as either ACC, APP, GTP, PRG, TOS, or TTP.
;	It defines a macro start_app, which you must use in the program
;       to initialize it.  It expects all registers to be as set up by
;	TOS at program entry, so it's usually best to call the 'start_app'
;	macro at the very start of the program code.
;
;Defined variables/arrays:
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
;app_id		alias tos_flag
;bootflag	.W $FFFF == PRG booted from AUTO (also sets 'tos_flag')
;menu_id	.W menu id for an ACC, otherwise null
;g_handle	.W workstation handle for ACC/APP/GTP/non_boot_PRG
;vwk_handle	.W virtual workstation handle
;contrl		12 words for AES/VDI control data
;
;MiNT_p		.L NULL or -> MiNT structure
;MagX_p		.L NULL or -> MagX structure
;nAES_p		.L NULL or -> nAES structure
;Gnva_p		.L NULL or -> Gnva structure
;STiK_p		.L NULL or -> STiK structure
;
;wk_x_rez \
;wk_y_rez  \/ from
;wk_pix_w  /\ opnvwk
;wk_pix_h /
;
;NB: rz and/or contrl will only be created if not already defined
;NB: if symbol 'huge_program' is defined, above data is in TEXT section (else in BSS)
;NB: defining 'huge_program' also makes internal calls use 'jsr' (instead of bsr)
;
;Required user arrays:
;
;id_app_name_s:	dc.b	'APPNAME ',NUL	;name in APPL_FIND format
;acc_name	dc.b	'  Acc name'	;for ACC menu registration
;message	ds.w	8		;evnt_mesag message pipe
;intin		ds.w	30		;30 words or more for AES/VDI
;intout		ds.w	45		;45 words or more for AES/VDI
;ptsin		ds.w	30		;30 words or more for VDI
;ptsout		ds.w	12		;12 words or more for VDI output coordinates
;		ds.l	100		;subroutine stack >= 100 longs
;mystack	ds.l	1		;top of subroutine stack
;
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
; 0x0000ADD0	=> Ptermres(d1,d2)		=> error code resident exit
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_LA.I
	include	RA_GEM.I
;----------------------------------------------------------------------------
start_app	MACRO	;NB: VERY long macro
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	_unilab	rz	;relative zero
	move.l	sp,a1
	lea	mystack(pc),sp
	move.l	a0,a5
	move.l	a0,d7		;is a0 nonzero ? (accessory)
	seq	menu_id		;generate non_matching menu_id for non_ACC
	sne	d7
	ext	d7
	ext.l	d7
	clr.l	d6
	lea	rz(pc),a6
	move	d7,progtype-rz(a6)
	bmi.s	.doacc_1
	move.l	4(a1),a5
	move.l	bp_textlen(a5),a0
	add.l	bp_datalen(a5),a0
	add.l	bp_bss_len(a5),a0
	lea	$100(a0),a0
	move.l	a0,tsr_size-rz(a6)
	gemdos	Mshrink,!,(a5),a0
.doacc_1:
	xbios	Supexec,OS_check_1(pc)
	move.l	a5,basepage_p-rz(a6)	;store basepage_p
	tst.l	d7
	bmi.s	.doacc_2		;skip APP/TOS tests for ACC
;
	IFEQ	skip_vq_aes
	tst.l	nAES_p
	bne.s	.no_vqaes_test		;skip vqaes_test under nAES
	moveq	#-1,d6
	vq_aes
	beq	.TOS_type		;assume TOS if AES disabled
	clr.l	d6
.no_vqaes_test:
	ENDC	;skip_vq_aes
;
.doacc_2:
	move	#-1,intout-rz(a6)
	sub_aes	#appl_init		;appl_init
	move	d0,d7
	move.l	d7,progtype-rz(a6)	;progtype = acc_flag.ap_id
	move	d7,ap_id-rz(a6)
;
	tst.l	d7
	bmi	.start_acc		;go init ACC
;
	tst	d7
	bmi	.TOS_type		;assume TOS if ap_id negative
;
	IFEQ	skip_nametest
	move.b	bp_arglen(a5),d0
	cmp.b	#$7F,d0
	blo.s	.try_shel_read		;skip ARGV test if none used
	move.l	bp_environ_p(a5),a0
	move.l	a0,d0
	beq.s	.try_shel_read		;skip ARGV test if no environment
.seek_argv:
	lea	argv_s(pc),a1
.test_argv_1:
	move.b	(a0)+,d0
	beq.s	.test_argv_3
	cmp.b	(a1)+,d0
	beq.s	.test_argv_1
.test_argv_2:
	tst.b	(a0)+			;passed current non_argv string ?
	bne.s	.test_argv_2
	bra.s	.test_argv_4
;
.test_argv_3:
	tst.b	(a1)			;Found ARGV=\0 ?
	beq.s	.seek_ext_argv
.test_argv_4:
	tst.b	(a0)			;test more environment strings ?
	bne.s	.seek_argv
	bra.s	.try_shel_read
;
.seek_ext_argv:
	bsr	seek_name
	move.b	d0,d3
	bne.s	.have_name
.try_shel_read:
	gemdos	Malloc,#$200
	tst.l	d0
	ble.s	.no_nametest
	move.l	d0,a4
	clr.b	(a4)
	gem_aes	shel_read,(a4),$100(a4)
	move.l	a4,a0
	bsr	seek_name
	move.b	d0,d3
	gemdos	Mfree,(a4)
.have_name:
	tst.b	d3
	beq.s	.unappl_TOS
	cmp.b	#'T',d3
	beq.s	.unappl_TOS
.no_nametest:
	ENDC	;skip_nametest
;
	bsr	.opnvwk_sub
	bgt.s	.good_app
	lea	vwk_fail_s(pc),a0
	move	a0,addrin-rz(a6)
	sub_aes	#form_alert
	bra.s	.unappl_TOS		;refuse ACC/APP if v_opnvwk failed
;
.clsvwk_TOS:
	sub_vdi	#v_clsvwk,vwk_handle(pc)
	clr	vwk_handle-rz(a6)
.unappl_TOS:
	sub_aes	#appl_exit
.TOS_type:
	move.l	#$ffff,d7
	move.l	d7,progtype-rz(a6)	;clear acc_flag, set tos_flag < 0
	move	d6,bootflag-rz(a6)
	bra.s	.init_app_1		;go start TOS/TTP program
;
.start_acc:
	bsr	.opnvwk_sub
	bgt.s	.register_acc
	illegal				;bomb rather than run without vwk
;
.register_acc:
	move	d7,intin-rz(a6)		;Register ACC in menu.
	move.l	#acc_name,addrin-rz(a6)
	sub_aes	#menu_register
	move	d0,menu_id-rz(a6)
	bra.s	.init_app_1
;
.good_app:
	cmp	#2,intout+80-rz(a6)	;mouse allowed ?
	blo.s	.clsvwk_TOS
.init_app_1:
	ifne	_deblev>=1
	bsr	.go_init_app
	elseif
	bsr	init_app
	endc
	lea	rz(pc),a6
	move	bootflag(pc),d6
	move.l	progtype(pc),d7		;d7 bit 31 flags ACC/APP
	move.l	revise_type_f,d0	;d0 bit 31 flags reversed ACC/APP roles
	eor.l	d7,d0
	bpl.s	.active			;do not wait for normal APP, or revised ACC
;
;------------------------------------
;	Main Accessory Event Loop
;
.acc_loop:
	tst	vwk_handle
	ble.s	.acc_wait
	tst.b	keep_wind_f
	bne.s	.acc_wait
	sub_vdi	#v_clsvwk,vwk_handle(pc)	;close vwk for ACC
	clr	vwk_handle-rz(a6)
.acc_wait:
	move.l	#message,addrin-rz(a6)	;Wait for a menu call.
;
	IFNE	exec_timeout		;cond:	IFNE exec_timeout
	move	#MU_MESAG|MU_TIMER,intin-rz(a6)
	move	main_timeout+2(pc),intin+28-rz(a6)
	move	main_timeout(pc),intin+30-rz(a6)
	sub_aes	#evnt_multi
	btst	#b_MU_MESAG,d0		;message_event ?
	bne.s	.do_message
	btst	#b_MU_TIMER,d0		;timer_event ?
	beq.s	.acc_wait		;oops, this shouldn't happen
	IFNE	_deblev>=1		;cond:	IFNE _deblev>>=1
	bsr.s	.go_exec_time
	ELSEIF				;else:
	bsr	exec_timer
	ENDC				;ends:	IFNE _deblev>=1
	bra.s	.acc_fix		;go fixup regs for next event
	ELSEIF				;else:
	sub_aes	#evnt_mesag
	ENDC				;ends:  IFNE exec_timeout
;
.do_message:
	lea	message(pc),a0
	move	(a0),d0
	cmp	#AC_OPEN,d0
	IFNE	exec_message		;cond:	IFNE exec_message
	beq.s	.do_AC_OPEN
	IFNE	_deblev>=1		;cond:	IFNE _deblev>>=1
	bsr.s	.go_exec_mess
	ELSEIF				;else:
	bsr	exec_mesag
	ENDC				;ends:	IFNE _deblev>=1
	bra.s	.acc_fix
	ELSEIF				;else:
	bne.s	.acc_wait		;Not a call we know, carry on waiting.
	ENDC				;ends:	IFNE exec_message
.do_AC_OPEN:
	move	8(a0),d0
	cmp	menu_id(pc),d0
	bne.s	.acc_wait		;Not a call for us, carry on waiting.
	bsr	.opnvwk_sub		;reopen vwk for ACC
	ble.s	.acc_wait		;back to waiting loop if no vwk free
.active:				;time to go to work
	ifne	_deblev>=1
	bsr.s	.go_exec_app
	elseif
	bsr	exec_app
	endc
.acc_fix:
	lea	rz(pc),a6
	move	bootflag(pc),d6
	move.l	progtype(pc),d7
	bmi	.acc_loop		;if .ACC, return to desktop by evnt_mesag
	tst	revise_type_f
	bmi	.acc_loop		;if type revised use eventloop for APP too
;
.exit_nonacc:
	move.l	d0,d6			;d6  = err_code / null
	move.l	d1,d4
	move.l	d2,d5
	tst	vwk_handle-rz(a6)
	beq.s	.skip_close
	sub_vdi	#v_clsvwk,vwk_handle(pc)
	clr	vwk_handle-rz(a6)
.skip_close:
	tst	d7
	bmi.s	.TOS_exit
	sub_aes	#appl_exit
.TOS_exit:
	clr.l	d0
	move	d6,d0
	cmp.l	d6,d0
	bne.s	.main_term
	sub	#$ADD0,d0
	blo.s	.main_term
	cmp	#1,d0
	bgt.s	.main_tsr_2
	beq.s	.main_tsr_1
.main_tsr_0:
	move.l	tsr_size(pc),d4
.main_tsr_1:
	clr.l	d5
.main_tsr_2:
	gemdos	Ptermres,d4,d5
;
.main_term:
	tst.l	d6
	ble.s	.terminate
	clr.l	d6
.terminate:
	gemdos	Pterm,d6
;
;
.opnvwk_sub:
	tst	vwk_handle-rz(a6)
	bgt.s	.done_opnvwk
	sub_aes	#graf_handle
	move	d0,g_handle-rz(a6)
	lea	intin(pc),a0
	moveq	#11-1,d0
.work_in_lp:
	move	#1,(a0)+
	dbra	d0,.work_in_lp
	addq	#1,-(a0)
	sub_vdi	#v_opnvwk,g_handle(pc)
	lea	intout(pc),a0
	lea	wk_x_rez(pc),a1
	move	(a0)+,(a1)
	addq	#1,(a1)+
	move	(a0)+,(a1)
	addq	#1,(a1)+
	addq	#2,a0
	move	(a0)+,(a1)+
	move	(a0)+,(a1)+
	move	contrl+12(pc),vwk_handle-rz(a6)
.done_opnvwk:
	tst	vwk_handle-rz(a6)
	rts
;
;
	ifne	_deblev>=1
.go_init_app:
	move.l	#'Init',d0
	bsr	init_app
	rts
	endc
;
	ifne	_deblev>=1
.go_exec_app:
	move.l	#'Exec',d0
	bsr	exec_app
	rts
	endc
;
	ifne	_deblev>=1
.go_exec_time:
	move.l	#'Time',d0
	bsr	exec_timer
	rts
	endc
;
	ifne	_deblev>=1
.go_exec_mess:
	move.l	#'Mess',d0
	bsr	exec_mesag
	rts
	endc
;----------------------------------------------------------------------------
OS_check_1:
	move	sr,-(sp)		;push entry int_mask
	ori	#$0700,sr		;disable interrupts
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
;-------
.done_cookies:
	move	(sp),sr			;revive entry int_mask
;-------
	_a_init
	move.l	d0,line_a_base_p
;-------
	xbios	Iorec,#1
	move.l	d0,kb_iorec_p
;-------
	move.l	#$602C,currbp_p_p	;Some old TOS had this (but maybe not all)
	xbios	Keytbl,?,?,?
	move.l	d0,keytbl_ptp
	move.l	d0,a0
	lea	-1(a0),a0	;NB: this assumes Kbshift stored at Keytbl-1
	move.l	a0,kbshift_p	;NB: So all early TOS have Kbshift data at Keytbl-1 !!!
	move.l	(_sysbase).w,a1
	move.l	os_selfbeg_p(a1),a0
	move	os_version(a0),d0
	cmp	#$104,d0			;Modern or Ancient TOS ?
	blo.s	.done_sys_fix			;For ancient TOS, old methods
	move.l	os_kbshift_p(a0),kbshift_p	;\/ For modern TOS, get the
	move.l	os_currbp_p_p(a0),currbp_p_p	;/\ vectors from TOS header
;-------
.done_sys_fix:
	move	(sp)+,sr		;pull entry int_mask
	rts
;----------------------------------------------------------------------------
seek_name:
	clr.l	d2
	move.b	(a0),d2
	beq.s	.name_tested
	moveq	#'T',d2
.seek_name_loop:
	move.l	a0,a1
.find_name:
	move.b	(a0)+,d0
	beq.s	.name_found
	cmp.b	#'\\',d0
	beq.s	.seek_name_loop
	bra.s	.find_name
;
.name_found:
	lea	id_app_name_s,a0
	moveq	#8-1,d1
.name_loop:
	move.b	(a1)+,d0
	beq.s	.back_pad_name
	cmp.b	#'.',d0
	beq.s	.back_pad_name
	move.b	d0,(a0)+
	dbra	d1,.name_loop
	bra.s	.find_ext
;
.back_pad_name:
	subq	#1,a1
.pad_name_loop:
	move.b	#' ',(a0)+
	dbra	d1,.pad_name_loop
.find_ext:
	move.b	(a1)+,d0
	beq.s	.name_tested
	cmp.b	#'.',d0
	bne.s	.find_ext
	move.b	(a1)+,d2
.name_tested:
	move	d2,d0
	rts
;----------------------------------------------------------------------------
	IFEQ	huge_program
	SECTION	DATA
	ENDC
;----------------------------------------------------------------------------
vwk_fail_s:
	dc.b	'[1]'
	dc.b	'[No workstation available]'
	dc.b	'[Exit]',NUL
;
argv_s:
	dc.b	'ARGV=',NUL
	EVEN
;
	IFNE	exec_timeout
	EVEN
main_timeout:	dc.l	exec_timeout
	ENDC	;exec_timeout
;
	IFNE	keep_windows
keep_wind_f:	dc.w	$FF00
	elseif
keep_wind_f:	dc.w	$0000
	ENDC
;
OS_check_1_t:
	dc.l	'MiNT',MiNT_p
	dc.l	'MagX',MagX_p
	dc.l	'nAES',nAES_p
	dc.l	'Gnva',Gnva_p
	dc.l	'STiK',STiK_p
	dc.l	'Stuf',Stuf_p
	dc.l	NUL
;
;----------------------------------------------------------------------------
	IFEQ	huge_program
	SECTION	BSS
	ENDC
;----------------------------------------------------------------------------
tsr_size:	ds.l	1
basepage_p:	ds.l	1
progtype:	ds.l	1	;hi.w=acc_flag  lo.w=tos_flag == app_id
acc_flag:	= progtype
tos_flag:	= progtype+2
app_id:		= tos_flag
bootflag:	ds.w	1
menu_id:	ds.w	1
g_handle:	ds.w	1
vwk_handle:	ds.w	1
revise_type_f:	ds.w	1	;top bit flags ACC behaves more like APP et vv.
;
wk_x_rez:	ds.w	1	;horizontal resolution
wk_y_rez:	ds.w	1	;vertical resolution
wk_pix_w:	ds.w	1	;pixel width
wk_pix_h:	ds.w	1	;pixel height
;
MiNT_p:		ds.l	1	;NULL or -> MiNT structure
MagX_p:		ds.l	1	;NULL or -> MagX structure
nAES_p:		ds.l	1	;NULL or -> nAES structure
Gnva_p:		ds.l	1	;NULL or -> Gnva structure
STiK_p:		ds.l	1	;NULL or -> STiK structure
Stuf_p:		ds.l	1	;NULL or -> Stuf structure
;
line_a_base_p:	ds.l	1	;-> line_a variable base
kb_iorec_p:	ds.l	1	;-> keyboard Iorec structure
keytbl_ptp:	ds.l	1	;-> keyboard table pointer table
kbshift_p:	ds.l	1	;-> kbshift byte of OS
currbp_p_p:	ds.l	1	;-> OS var -> current basepage
;
	_unilab	contrl
	IFNE	_uni_flag
	ds.w	12
	ENDC
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	make	GEM_links
;----------------------------------------------------------------------------
	ENDM	;start_app	NB: This ends a VERY long macro
;----------------------------------------------------------------------------
	endc	;RA_APP_defined
;----------------------------------------------------------------------------
;End of file:	RA_APP.I
;----------------------------------------------------------------------------
