;----------------------------------------------------------------------------
;File name:	RA_STUFF.S			Revision date:	1999.10.07
;Creator:	Ulf Ronald Andersson		Creation date:	1999.10.04
;(c)1999 by:	Ulf Ronald Andersson		All rights reserved
;Feedback to:	dlanor@oden.se			Released as FREEWARE
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_JAR.I
	include	RA_LA.I
	include	RA_XB.I
	include	RA_RAM.I
	include	RA_SIM.I
	include	RA_XGEM.I
	include	RA_APP.I
	include	RA_ARG.I
;-------------------------------------
	include	sting\TRANSPRT.I
	include	sting\LAYER.I
;----------------------------------------------------------------------------
	output	.ACC
;----------------------------------------------------------------------------
M_YEAR	=	1999
M_MONTH	=	10
M_DAY	=	07
;
M_TITLE		MACRO
		dc.b	'RA_Stuff'
		ENDM
M_VERSION	MACRO
		dc.b	'01.00'
		ENDM
M_AUTHOR	MACRO
		dc.b	'Ronald Andersson'
		ENDM
M_APP_NAME	MACRO
		dc.b	'RA_STUFF'
		ENDM
;----------------------------------------------------------------------------
XB_cpu_mode	set	1	;never test mode or call Super in XB-macros
RAM_chunk	=	32000
MAX_VA_ARGLEN	equ	512
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
text_start:
basepage	=	(text_start-$100)
;----------------------------------------------------------------------------
my_LongJump:
start:
	jmp	(start_1).l		;long jump
;----------------------------------------------------------------------------
	illegal				;mark code/data transition
	dc.l	prog_name_s
	dc.l	prog_version_s
	dc.l	prog_author_s
	dc.w	((M_YEAR-1980)<<9)|(M_MONTH<<5)|M_DAY	;uint16	LAYER_date
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
prog_name_s:
	M_TITLE
	dc.b	NUL
prog_version_s:
	M_VERSION
	dc.b	NUL
prog_author_s:
	M_AUTHOR
	dc.b	NUL
acc_name:
	dc.b	'  '
	M_TITLE
	dc.b	' ACCs',NUL
id_app_name_s:
	M_APP_NAME
	dc.b	NUL
	EVEN
;-------------------------------------
XGEM_wanted_p:		dc.l	nu_XGEM_2
XGEM_linked_p:		dc.l	-1
XGEM_1_fix_p:		dc.l	try_XGEM_1
XGEM_call_f:		ds.b	1
XGEM_1_removed_f:	ds.b	1
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
message:		ds.w	8		;evnt_mesag message pipe
intin:			ds.w	30		;30 words or more for AES/VDI
intout:			ds.w	45		;45 words or more for AES/VDI
ptsin:			ds.w	30		;30 words or more for VDI
ptsout:			ds.w	12		;12 words or more for VDI output coordinates
			ds.l	1024		;subroutine stack >= 100 longs
mystack:		ds.l	1		;top of subroutine stack
;----------------------------------------------------------------------------
new_currbp_p:		ds.l	1
old_currbp_p:		ds.l	1
framesize:		ds.w	1
longframe_f:		ds.w	1
bootdev:		ds.w	1
old_tail_ix:		ds.w	1
hotkey_code:		ds.l	1
hotkey_flag:		ds.l	1
;-------------------------------------
VA_START_f:		ds.w	1
VA_START_cmd_p:		ds.l	1
VA_protostatus:		ds.l	1
VA_arg_p:		ds.l	1
VA_arg_s:		ds.b	MAX_VA_ARGLEN
			even
;-------------------------------------
ACC_count:		ds.w	1
ACC_loc_t_p:		ds.l	1	
;-------------------------------------
vector_err_f:		ds.l	1
;-------------------------------------
XGEM_regs:		ds.l	16
XGEM_tick:		ds.l	1
AY_tick:		ds.l	1
sim_AY_f:		ds.w	1
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
start_1:	start_app
;----------------------------------------------------------------------------
;Start of:	init_app
;----------------------------------------------------------------------------
init_app:
	start_arg
;-------
	xbios		Supexec,init_revision(pc)
;-------
	clr.l		VA_arg_p
	rts
;----------------------------------------------------------------------------
;End of:	init_app
;----------------------------------------------------------------------------
;Start of:	exec_app
;----------------------------------------------------------------------------
exec_app:
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
	IFNE	exec_timeout	;cond:	ifne exec_timeout
exec_timer:
exit_exec_timer:
	clr.l		d0
	rts
	ENDC			;ends:	ifne exec_timeout
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
;
	AV_send		PROTOKOLL,#w_VA_START+w_AV_STARTED_A,id_app_name_s
;
	clr.b	VA_arg_s		;prep empty local string
	lea	VA_arg_s(pc),a2		;a2 -> local argument area
	move.l	a2,VA_arg_p		;prep a pointer for future
	move.l	VA_START_cmd_p(pc),a0	;a0 -> argument on Venus
	move.l	a0,d0			;test -> argument on Venus
	ble.s	.send_AV_STARTED	;if NULL, go send reply now
	move.l		a0,a1			;a1 -> argument on Venus
	str_pass	a1
	sub.l		VA_START_cmd_p(pc),a1
	move.l		a1,d1			;d1 = length of argument
	move		#MAX_VA_ARGLEN,d0
	cmp.l		d0,d1			;argument too long ?
	blo.s		.length_ok
	move.l		d0,d1			;limit argument length
.length_ok:
	move.b		-1(a0,d1.w),d0		;save byte at termination point
	clr.b		-1(a0,d1.w)		;enforce limited termination
	move.l		a0,a1			;a1 -> argument on Venus
	lea		VA_arg_s(pc),a2		;a2 -> local argument area
	move.l		a2,VA_arg_p		;prep a pointer for future
	str_copy	a1,a2			;make a local copy of argument
	move.b		d0,-1(a0,d1.w)		;repair original copy
.send_AV_STARTED:
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
;Add client/server dependent message event work here
;
exit_exec_mesag:
	rts
	ENDC		exec_message
;----------------------------------------------------------------------------
;End of:	exec_mesag
;----------------------------------------------------------------------------
;Start of:	GEMDOS functions with XBRA
;----------------------------------------------------------------------------
	XB_define	nu_GEMDOS,'Stuf'
	Pass_Frame	a0
;-------
	cmp	#Mfree&$FF,(A0)		;is this an Mfree call ?
	beq.s	.try_Mfree_self		;if so, go see if it concerns us
	XB_gonext_a0	nu_GEMDOS(pc)	;else let old gemdos work as usual
;-------
.try_Mfree_self:
	move.l	2(a0),d0		;d0 -> area to be released
	cmp.l	#basepage,d0		;is release area RA_STUFF codespace ?
	beq.s	nu_Mfree_stuffer	;If so, go release all its ACCs first
;-------
use_old_gemdos:
	XB_gonext_a0	nu_GEMDOS(pc)	;else let old gemdos work as usual
;-------------------------------------
nu_Mfree_stuffer:
	bsr	remove_vectors		;unlink RA_STUFF system vectors
	tst	ACC_count
	ble.s	use_old_gemdos
	movem.l	d0-d3/a0-a3,-(sp)
	move.l	ACC_loc_t_p(pc),a3
	move	ACC_count(pc),d3
	subq	#1,d3
.free_ACC_loop:
	move.l	(a3),a0
	move.l	bp_environ_p(a0),d0
	beq.s	.done_environment
	move.l	d0,-(sp)		;push -> environment of the ACC to be removed
	move	#Mfree&$FF,-(sp)	;push gemdos opcode Mfree
	tst	(_longframe).w		;\
	beq.s	.CPU_adapted_1		; \
	clr	-(sp)			;  \/ Push a simulated
.CPU_adapted_1:				;  /\ exception stack frame
	pea	.post_environment	; /
	move	sr,-(sp)		;/
;-------
	XB_gonext_a0	nu_GEMDOS(pc)	;let old gemdos Mfree an ACC environment
;-------------------------------------
.post_environment:
	addq	#6,sp			;remove simulated arguments
.done_environment:
	move.l	(a3),-(sp)		;push -> basepage of the ACC to be removed
	move	#Mfree&$FF,-(sp)	;push gemdos opcode Mfree
	tst	(_longframe).w		;\
	beq.s	.CPU_adapted_2		; \
	clr	-(sp)			;  \/ Push a simulated
.CPU_adapted_2:				;  /\ exception stack frame
	pea	.post_basepage		; /
	move	sr,-(sp)		;/
;-------
	XB_gonext_a0	nu_GEMDOS(pc)	;let old gemdos Mfree an ACC codespace
;-------------------------------------
.post_basepage:
	addq	#6,sp			;remove simulated arguments
.done_basepage:
	addq	#8,a3			;a3 -> -> basepage of next ACC to remove
	dbra	d3,.free_ACC_loop
	movem.l	(sp)+,d0-d3/a0-a3
;-------
	XB_gonext_a0	nu_GEMDOS(pc)	;let old gemdos Mfree RA_STUFF codespace
;----------------------------------------------------------------------------
;End of:	GEMDOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	BIOS functions with XBRA
;----------------------------------------------------------------------------
	XGEM_BIOS_define	nu_BIOS,'NetD'
	XB_gonext_a0		nu_BIOS(pc)	;use older bios dispatcher
;----------------------------------------------------------------------------
patch_XGEM_sub:				;uses d0/a0/a1
	tst.l	nAES_p			;Running under nAES ?
	bgt.s	.try_remove_XGEM_1	;then try removing nu_XGEM_1
	tst.l	Gnva_p			;Running under GENEVA ?
	ble.s	.done_remove_XGEM_1	;else keep nu_XGEM_1
.try_remove_XGEM_1:
	tst.b	XGEM_1_removed_f	;nu_XGEM_1 already removed ?
	bne.s	.done_remove_XGEM_1	;don't try it twice
.remove_XGEM_1:
	lea	(ev_xgem).w,a0		;a0 -> ev_xgem
	lea	nu_XGEM_1(pc),a1	;a1 -> nu_XGEM_1
	bsr	remove_XB_code		;remove nu_XGEM_1 from XBRA chain
	blt.s	.done_remove_XGEM_1	;skip flagging removal on failure
	st	XGEM_1_removed_f	;flag removal for nu_XGEM_2
.done_remove_XGEM_1:
	move.l	nu_XGEM_1+xb_next(pc),XGEM_1_fix_p
	XGEM_patch	XGEM_linked_p,XGEM_wanted_p
	rts
;----------------------------------------------------------------------------
;End of:	BIOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	XGEM functions with XBRA
;----------------------------------------------------------------------------
	XB_define	nu_XGEM_1,'NetD'
	move.l	XGEM_1_fix_p(pc),a0
	jmp	(a0)
;-------
try_XGEM_1:
	cmp	#$73,d0				;XGEM opcode for VDI ?
	bne.s	go_old_XGEM_1			;if not, goto old routines
	movea.l	d1,a0				;a0 -> external VDIPB
	movea.l	(a0),a0				;a0 -> external contrl
	cmp	#1,(a0)				;opcode = v_opnwk ?
	beq.s	XGEM_1_v_opnwk
go_old_XGEM_1:
	XB_gonext_a0	nu_XGEM_1(pc)
;-------------------------------------
XGEM_1_v_opnwk:					;open physical workstation
	move.l	d1,a0				;a0 -> external VDIPB
	movea.l	4(a0),a0			;a0 -> external intin
	cmp	#10,(a0)			;screen device ?  (<11)
	bgt.s	go_old_XGEM_1			;if not, goto old routines
	push_ex	XGEM_1_end_opnwk(pc)		;push exception frame
	bra.s	go_old_XGEM_1			;goto old routines
;-------------------------------------
;Above, older XGEM routines are _called_ by simulating an exception frame,
;so when they are finished we return to 'end_opnwk' below.
;CPU state is still super, and original entry frame is on stack.
;-------------------------------------
XGEM_1_end_opnwk:
	movem.l	d0-d2/a0-a2,-(sp)	;push d0-d2/a0-a2
;-------
	eval_cookie	#'MiNT'
	move.l		d0,MiNT_p
	sgt		sim_AY_f
	eval_cookie	#'Gnva'
	move.l		d0,Gnva_p
	sle		d0
	and.b		d0,sim_AY_f
	eval_cookie	#'nAES'
	move.l		d0,nAES_p
	sle		d0
	and.b		d0,sim_AY_f
;-------
	lea	(ev_bios).w,a0
	lea	nu_BIOS(pc),a1
	bsr	retop_XB_code		;retop nu_BIOS XBRA entry
;-------
	bsr	patch_XGEM_sub
;-------
	movem.l	(sp)+,d0-d2/a0-a2	;pull d0-d2/a0-a2
	rte
;----------------------------------------------------------------------------
	XGEM_define	nu_XGEM_2,'NetD'
	cmp	#$C9,d0
	beq.s	.new_appl_yield
	cmp	#$C8,d0
;;;	beq.s	.try_NetD_work
;;;	cmp	#$73,d0
	bne.s	.use_old_xgem
.try_NetD_work:
	move.l	(_hz_200).w,a0			;get current tick to a0
	cmpa.l	XGEM_tick(pc),a0		;check if same as last time
	beq.s	.use_old_xgem			;avoid wasting time too often
;-------
	tas	XGEM_call_f
	bmi.s	.use_old_xgem
	movem.l	d0-d3/a1-a4,XGEM_regs		;protect entry d0-d3/a1-a4
;;;	bsr	NetD_work_sub			;call NetD_work_sub
	move.l	(_hz_200).w,XGEM_tick		;remember current tick
	movem.l	XGEM_regs(pc),d0-d3/a1-a4	;restore entry d0-d3/a1-a4
	sf	XGEM_call_f
.use_old_xgem:
	XB_gonext_a0	nu_XGEM_2(pc)
;-------------------------------------
.new_appl_yield:
	move.l	(_hz_200).w,a0			;get current tick to a0
	cmpa.l	AY_tick(pc),a0			;check if same as last AY_tick
	beq.s	.AY_exit_direct			;avoid wasting time too often
	cmpa.l	XGEM_tick(pc),a0		;check if same as last XGEM_tick
	beq.s	.perform_AY			;avoid wasting time too often
;-------
	tas	XGEM_call_f
	bmi.s	.perform_AY
	movem.l	d0-d3/a1-a4,XGEM_regs		;protect entry d0-d3/a1-a4
;;;	bsr	NetD_work_sub			;call NetD_work_sub
	move.l	(_hz_200).w,XGEM_tick		;remember current tick
	movem.l	XGEM_regs(pc),d0-d3/a1-a4	;restore entry d0-d3/a1-a4
	sf	XGEM_call_f
.perform_AY:
	move.l	(_hz_200).w,AY_tick		;remember current tick
	tst.b	sim_AY_f			;MiNT without Gnva or nAES ?
	beq.s	.use_old_xgem			;if not, we use real _appl_yield
.simulate_AY:				;for MiNT we simulate _appl_yield
	movem.l	d0-d2/a1-a2,-(sp)
	gemdos	Syield				;use Syield
	movem.l	(sp)+,d0-d2/a1-a2
.AY_exit_direct:
	rte					;exit from exception
;----------------------------------------------------------------------------
;End of:	XGEMDOS functions with XBRA
;----------------------------------------------------------------------------
;Start of:	Diverse subroutines
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'install_vectors'
;----------------------------------------------------------------------------
install_vectors:
	movem.l	d0/a0-a1,-(sp)
;-------
	lea	(ev_xgem).w,a0
	lea	nu_XGEM_1(pc),a1
	XB_init
	or.l	d0,vector_err_f
;-------
	lea	(ev_gemdos).w,a0
	lea	nu_GEMDOS(pc),a1
	XB_init
	or.l	d0,vector_err_f
;-------
	lea	(ev_bios).w,a0
	lea	nu_BIOS(pc),a1
	XB_init
	or.l	d0,vector_err_f
;-------
	movem.l	(sp)+,d0/a0-a1
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'install_vectors'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'remove_vectors'
;----------------------------------------------------------------------------
remove_vectors:
	movem.l	d0/a0-a1,-(sp)
;-------
	lea	(ev_bios).w,a0
	lea	nu_BIOS(pc),a1
	XB_kill_code
	or.l	d0,vector_err_f
;-------
	lea	(ev_gemdos).w,a0
	lea	nu_GEMDOS(pc),a1
	XB_kill_code
	or.l	d0,vector_err_f
;-------
	lea	(ev_xgem).w,a0
	lea	nu_XGEM_1(pc),a1
	XB_kill_code
	or.l	d0,vector_err_f
	st	XGEM_linked_p
;-------
	movem.l	(sp)+,d0/a0-a1
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'remove_vectors'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutines that patch basepage system for ACCs
;----------------------------------------------------------------------------
enter_system:
	move.l	Stuf_p(pc),new_currbp_p
	bgt.s	.have_stuff
	move.l	basepage_p(pc),new_currbp_p
.have_stuff:
	bra.s	patch_system
;-------------------------------------
exit_system:
	move.l	old_currbp_p(pc),new_currbp_p
patch_system:
	movem.l	a0-a2,-(sp)
;-------
	movea.l	currbp_p_p(pc),A0	;a0 -> system currbp_p -> current basepage
	movea.l	new_currbp_p(pc),A1
	movea.l	(A0),A2			;a2 -> current basepage
	move.l	A2,old_currbp_p		;store it for future restore
;-------
	move.l	bp_dta_p(A2),bp_dta_p(A1)
	move.l	$40(A2),$40(A1)
	move.l	$44(A2),$44(A1)
	move.l	$48(A2),$48(A1)
	move.l	$4C(A2),$4C(A1)
;-------
	move.l	A1,(A0)			;force system currbp_p = new_currbp_p
;-------
	movem.l	(sp)+,a0-a2
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutines that patch basepage system for ACCs
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'init_revision'
;----------------------------------------------------------------------------
init_revision:
	move	(_bootdev).w,bootdev
;-------
	move	sr,d0				;save interrupt mask
	or	#$0700,sr			;disable interrupts
	move.l	(ev_trap5).w,a0			;save trap 5 handler
	move.l	#frame_test,(ev_trap5).w	;patch new trap 5 handler
	move.l	sp,a1				;a1 = 'old_SP'
	trap	#5				;execute trap 5
	illegal		;if we ever come here, the CPU is very sick !!!
;-------------------------------------
frame_test:
	move.l	a0,(ev_trap5).w		;restore original trap 5 handler
	sub.l	sp,a1			;a1 = old_SSP - new_SSP  == framesize
	add.l	a1,sp			;sp = old_SSP
	move	a1,framesize		;init 'framesize'
	cmp	#6,a1
	sgt	longframe_f		;init 'longframe_f'
	move	d0,sr			;restore interrupt mask
	bsr	install_vectors
	rts				;exit to caller
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'init_revision'
;----------------------------------------------------------------------------
;Start of:	Supexec subroutine	'hotkey_test'
;----------------------------------------------------------------------------
hotkey_test:
	movem.l	d0-d4/a0-a3,-(sp)
	clr.l	d4
	move.l	hotkey_code(pc),d3	;d3 = hotkey argument
	move.l	keytbl_ptp,a3		;a3 -> -> Unshifted key table
	move	SR,-(sp)		;save status register (interrupt mask)
	move.l	kb_iorec_p(pc),a0	;a0 = address of iorec structure
	move	io_tail_ix(a0),d1	;tail index
	or	#$0700,SR		;disable interrupts
	move	io_tail_ix(a0),d1	;tail index
	move	d1,old_tail_ix		;save tail index at old_tail_ix
	cmp	io_head_ix(a0),d1
	beq.s	.return
	move.l	kbshift_p(pc),a1	;a1 = address of TOS kbshift variable
	move.b	(a1),d2			;get kbshifts (** TOS independent **)
	and	#$1F,d2			;d2 = masked special keys
	move.l	io_buffer_p(a0),a2	;a2 = address of io-buffer
	move.l	(a2,d1),d0		;get 1'st word for this key = key code.ascii
	and	#$7F,d0			;d0 = masked key code
	tst.l	d3
	bpl.s	.test_it		;use ascii test if d3 >= 0
	neg.l	d3
	swap	d0			;prep for key code test
.test_it:
	cmp	d3,d0			;compare either ascii or key code values
	bne.s	.return
	swap	d3
	and	#$0F,d3
	and	#$0F,d2
	cmp	d3,d2
	seq	d4			;set d4 if specials also equal
.return:
	ext	d4
	ext.l	d4
	beq.s	.exit			;leave buffer as-is if hotkey not found
	subq	#4,d1
	bge.s	.tail_shrunk
	move	io_size_ix(a0),d1
	subq	#4,d1
.tail_shrunk:
	move	d1,io_tail_ix(a0)
	move	d1,old_tail_ix
;-------
.exit:
	move	(sp)+,sr		;restore interrupt mask
	move.l	d4,hotkey_flag
	movem.l	(sp)+,d0-d4/a0-a3
	rts
;----------------------------------------------------------------------------
;End of:	Supexec subroutine	'hotkey_test'
;----------------------------------------------------------------------------
;End of:	Diverse subroutines
;----------------------------------------------------------------------------
;Start of:	library code
;----------------------------------------------------------------------------
	include		XB_SUBS.S
	make		JAR_links
	_uniref		RAM_own
	_uniref		RAM_add
	make		RAM_links
;----------------------------------------------------------------------------
;End of:	library code
;----------------------------------------------------------------------------
;Start of:	STinG initialization code
;----------------------------------------------------------------------------
STinG_init:
	move.l		STiK_p(pc),d3			;d3 -> DRV_LIST structure
	ble.s		.STiK_not_found			;skip if no STiK cookie
;-------
	move.l		d3,a3				;a3 -> DRV_LIST structure
	lea		DRV_LIST_magic(a3),a0
	lea		STiKmagic_s(pc),a1
	moveq		#10-1,d0
.strcmp_loop:					;loop to test STiKmagic of DRV_LIST
	cmpm.b		(a0)+,(a1)+
	dbne		d0,.strcmp_loop		;loop back to test whole string
	bne.s		.STiK_not_valid			;skip if STiK invalid
;-------
	move.l		DRV_LIST_get_dftab(a3),a0	;a0 -> get_dftab function
	pea		TRANSPORT_DRIVER_s		;-(sp) = "TRANSPORT_TCPIP"
	jsr		(a0)				;call get_dftab
	addq		#4,sp
	move.l		d0,tpl				;store pointer in 'tpl'
	ble.s		.driver_not_valid
;-------
	move.l		DRV_LIST_get_dftab(a3),a0	;a0 -> get_dftab function
	pea		MODULE_DRIVER_s			;-(sp) = "MODULE_LAYER"
	jsr		(a0)				;call get_dftab
	addq		#4,sp
	move.l		d0,stx				;store pointer in 'stx'
	ble.s		.layer_not_valid
	moveq		#E_OK,d0	;error 0 == STinG found OK
	rts
;-------------------------------------
.STiK_not_found:
	moveq		#1,d0		;error 1 == STiK not found
	rts				;This means STiK/STinG not present
;-------------------------------------
.STiK_not_valid:
	moveq		#2,d0		;error 2 == STiK invalid
	rts				;This means system is crashed
;-------------------------------------
.driver_not_valid:
	moveq		#3,d0		;error 3 == TRANSPORT layer invalid
	rts				;This means system is crashed
;-------------------------------------
.layer_not_valid:
	moveq		#4,d0		;error 4 == MODULE layer invalid
	rts				;This means STinG not present
;-------------------------------------
	SECTION	DATA
;-------------------------------------
STinG_Load_s:
	dc.b	10,'STinG_Load',NUL
STiKmagic_s:
	dc.b	'STiKmagic',NUL
TRANSPORT_DRIVER_s:
	dc.b	'TRANSPORT_TCPIP',NUL
MODULE_DRIVER_s:
	dc.b	'MODULE_LAYER',NUL
	EVEN
;-------------------------------------
tpl:	dc.l	-1
stx:	dc.l	-1
;-------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;End of:	STinG initialization code
;----------------------------------------------------------------------------
		END
;----------------------------------------------------------------------------
;End of file:	RA_STUFF.S
;----------------------------------------------------------------------------
