;----------------------------------------------------------------------------
;File name:	DEMO_APP.S			Revision date:	1998.09.24
;Revised by:	Ronald Andersson		Revision start:	1998.09.14
;----------------------------------------------------------------------------
;;;huge_program		= 1	;uncomment if TEXT+DATA sections are > 32KB
;;;keep_windows		= 1	;uncomment to keep ACC vwk in main eventloop
;;;exec_timeout		= 1000	;uncomment to enable timer in main eventloop
exec_message		= 1	;uncomment for messages in main eventloop
;----------------------------------------------------------------------------
	include	RA_ARG.I
	include	RA_APP.I
	include	RA_SLB.I
	include	RA_AV.I
;----------------------------------------------------------------------------
	output	.ttp
;----------------------------------------------------------------------------
MAX_VA_ARGLEN	equ	512
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	start_app
;----------------------------------------------------------------------------
	IFEQ	huge_program
	DATA
	ENDC
;
acc_name:
	dc.b	'  SLB Demo APP',NUL	;for ACC menu registration
	dc.b	NUL
	even
;
id_app_name_s:
	dc.b	'DEMO_APP',NUL
	even
;----------------------------------------------------------------------------
	IFEQ	huge_program
	SECTION	BSS
	ENDC
;----------------------------------------------------------------------------
message:	ds.w	8		;evnt_mesag message pipe
intin:		ds.w	30		;30 words or more for AES/VDI
intout:		ds.w	45		;45 words or more for AES/VDI
ptsin:		ds.w	30		;30 words or more for VDI
ptsout:		ds.w	12		;12 words or more for VDI output coordinates
		ds.l	1000		;subroutine stack >= 100 longs
mystack:	ds.l	1		;top of subroutine stack
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	SLB_lib	demo_slb
	SLB_fun	test_1st_fun,3,$1B	;implemented function 0
	SLB_fun	test_2nd_fun,4,$DB	;unimplemented function 1
	SLB_fun	test_3rd_fun,5,$3DB	;implemented function 2
;
;NB:	The SLB 'demo_slb.slb' only implements 2 functions, but allows 3
;	to be called.  It is legal for SLBs to have 'holes' in the function
;	tables, and this test program verifies that this works correctly.
;	The result is that the call to function #1 has no effect at all,
;	when the SLB support drivers function correctly.
;----------------------------------------------------------------------------
init_app:
	start_arg
;-------
;The macro 'start_arg' defines two variables:
;arg_cnt	== number of strings on command line
;arg_ptr	-> NUL_separated argument strings + final NUL
;Both of the above include a dummy program name (first string==NUL).
;-------
	clr.l		VA_arg_p
	cmp		#2,arg_cnt
	blo.s		.done_arg
	move.l		arg_ptr,a0
	str_pass	a0
	move.l		a0,VA_arg_p
.done_arg:
	rts
;----------------------------------------------------------------------------
exec_app:
	lv_init	a6
	move.l	VA_arg_p(pc),a0
	SLB_beg	demo_slb,(a0),!
	move.l	d0,d3
	bpl.s	.opened_ok
	gemdos	Cconws,failure_s
	move.l	d3,d0
	bra.s	exit_exec_app
;
.opened_ok:
	SLB_exe	test_1st_fun,!
	SLB_exe	test_2nd_fun,#2,Test_s(pc)
	SLB_exe	test_3rd_fun,#4,Test_s(pc),Test_s(pc)
	SLB_end	demo_slb
	moveq	#E_OK,d0
exit_exec_app:
	lv_exit	a6
	rts
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
	bra.s		exit_exec_app
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
;	Library function code will be expanded here
;
	make	AV_links
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
failure_s:
	dc.b	'demo_app: could not open demo_slb.slb !',CR,LF,NUL
Test_s:
	dc.b	'Testing SLB calls'
point_path_s:
	dc.b	'.',NUL
	EVEN
;----------------------------------------------------------------------------
VA_START_f:	ds.w	1
VA_START_cmd_p:	ds.l	1
VA_protostatus:	ds.l	1
VA_arg_p:	ds.l	1
VA_arg_s:	ds.b	MAX_VA_ARGLEN
		even
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	DEMO_APP.S
;----------------------------------------------------------------------------
