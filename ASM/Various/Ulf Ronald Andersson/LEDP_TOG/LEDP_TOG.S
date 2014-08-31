;----------------------------------------------------------------------------
;File name:	LEDP_TOG.S		Revision date:	1996.08.05
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.24
;(c)1995 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
	output	.GTP
;
	include	LEDPANEL.SH
;
	include	URAn_JAR.S
;
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;
	include	URAn_APP.S
	include	URAn_SIM.S
;
;----------------------------------------------------------------------------
;
init_app:
	include	URAN_ARG.S
	tst	d7
	bmi.s	.TOS_init
	lea	menu1,a2
	move	rsc_obs,d2
.obfix_loop:
	gem_aes	rsrc_obfix,d2,(a2)
	dbra	d2,.obfix_loop
	nop
.TOS_init:
	rts
;
exec_app:
	move.l	arg_ptr(pc),a4	;a4 = arg_ptr
	move	arg_cnt(pc),d4	;d4 = arg_cnt
;
	movem.l	d2-d7/a0-a6,-(sp)
	gemdos	Super,!
	move.l	d0,-(sp)
	moveq	#1,d7			;1 = argument test
	clr	set_flags
	cmp	#2,d4
	bhi	.test_error
	blo.s	.skip_arg
;
	move	d4,d5
	subq	#1,d5			;prep for dbra
	clr	d3
	move.l	a4,a0
	lea	string_p_t(pc),a2
.loop_1:
	move.l	a0,(a2)+		;store a string ptr (2 times)
	moveq	#127-1,d1
.loop_2:
	move.b	(a0)+,d0
	cmp.b	#' ',d0
	dbls	d1,.loop_2
	clr.b	-1(a0)
	addq	#1,d3
	dbra	d5,.loop_1
;
;Here string_p_t holds pointers to program name and all args
;
	move.l	prim_arg_s(pc),a0
	tst.b	1(a0)
	bne.s	.test_error
	cmp.b	#'0',(a0)
	seq	set_flags+0
	beq.s	.good_arg
	cmp.b	#'1',(a0)
	seq	set_flags+1
	bne.s	.test_error
.skip_arg:
.good_arg:
	moveq	#2,d7			;2 = cookie test
	eval_cookie	#LEDP_MAGIC
	bmi.s	.test_error
	moveq	#3,d7			;3 = header test
	btst	#0,d0
	bne.s	.test_error
	move.l	d0,a0
	cmp.l	#LEDP_MAGIC,lp_magic(a0)
	bne.s	.test_error
.try_clr_flag:
	tst.b	set_flags+0
	beq.s	.try_set_flag
.clr_flag:
	move	#$0000,lp_active(a0)
	bra.s	.test_ok
;
.try_set_flag:
	tst.b	set_flags+1
	beq.s	.toggle_flag
.set_flag:
	move	#$8001,lp_active(a0)
	bra.s	.test_ok
;
.toggle_flag:
	tst	lp_active(a0)
	bne.s	.clr_flag
	bra.s	.set_flag
;
.test_ok:
	clr.l	d0
	bra.s	.test_exit
;
.test_error:
	moveq	#-1,d0
.test_exit:
	move.l	d0,d6
	gemdos	Super,()
	move.l	d6,d0
	move.l	d7,d1
	movem.l	(sp)+,d2-d7/a0-a6
	tst.l	d0
	bpl	main_exit_ok
	move	d1,d5			;d5 = error activity code
	move.l	d0,d4			;d4 = system error code
	move	d5,d2			;d2 = activity code
	subq	#1,d2			;d2 = activity index
	asl	#2,d2			;d2 = index to long
	lea	activity_al_t(pc),a2
	move.l	(a2,d2),a2
	sim_aes	form_alert,#1,(a2)
	cmp	#1,d0
	bne.s	show_info
main_exit_d4:
	move.l	d4,d0
	bra	main_exit_d0
;
show_info:
	lea	info_al_c_t(pc),a3	;a3 -> alert_control table
	move.l	(a3)+,a4		;a4 -> alert_string table
	clr	d3			;d3 = initial control index
info_loop:
	mulu	#6,d3
	move	(a3,d3),d2		;d2 =  alert index
	asl	#2,d2
	move.l	(a4,d2),a2		;a2 -> alert_string
	sim_aes	form_alert,#1,(a2)
	subq	#1,d0
	beq.s	main_exit_d4
	add	d0,d0
	add	d0,d3
	move	(a3,d3),d3		;d3 = next control index
	bra.s	info_loop
;
main_exit_ok:
	tst	d7
	bmi	.exit_TOS
	gem_aes	wind_get,!,#5
	move	intout+2(pc),wx
	move	intout+4(pc),wy
	move	intout+6(pc),ww
	move	intout+8(pc),wh
	gem_aes	form_dial,#0,!,!,!,!,wx,wy,ww,wh
	gem_aes	menu_bar,#1,menu1
	gem_aes	menu_bar,!,menu1
	gem_aes	form_dial,#3,!,!,!,!,wx,wy,ww,wh
.exit_TOS:
	clr.l	d0
main_exit_d0:
	rts
;
;----------------------------------------------------------------------------
;
	make	JAR_links
	make	SIM_links
;
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
;
	include	ledpmenu.s
;
;----------------------------------------------------------------------------
;
acc_name:	dc.b	'  Toggle LEDPANEL',NUL
;
info_0_al_s:
	dc.b	'[1]['
	dc.b	' ____ LEDP_TOG __ V_1.0 ____ |'
	dc.b	' Created by URAn: 1995.06.27 |'
	dc.b	' Released as:     FREEWARE   |'
	dc.b	' --------------------------- |'
	dc.b	' (c)1995 U. Ronald Andersson ]'
	dc.b	'[  Exit!  |  Smail  |   BBS   ]',NUL
;
info_1_al_s:
	dc.b	'[1]['
	dc.b	' -------- LEDP_TOG --------- |'
	dc.b	'    Ulf Ronald Andersson     |'
	dc.b	'        H”ders V„g 7         |'
	dc.b	'     S-145 70  Norsborg      |'
	dc.b	' --------- Sweden ---------- ]'
	dc.b	'[  Exit!  |  Email  |   (C)   ]',NUL
;
info_2_al_s:
	dc.b	'[1]['
	dc.b	' -------- LEDP_TOG --------- |'
	dc.b	' You can contact me by local |'
	dc.b	' E- mail in  DataLine BBS to |'
	dc.b	'     "Ronald Andersson"      |'
	dc.b	' --------------------------- ]'
	dc.b	'[  Exit!  |   BBS   |  Smail  ]',NUL
;
info_3_al_s:
	dc.b	'[1]['
	dc.b	' -------- LEDP_TOG --------- |'
	dc.b	' DataLine BBS = 08-778 28 86 |'
	dc.b	' for Swedish calls.   Adjust |'
	dc.b	' as usual for foreign calls. |'
	dc.b	' --------------------------- ]'
	dc.b	'[  Exit!  |   (C)   |  Email  ]',NUL
;
args_err_al_s:
	dc.b	'[3]['
	dc.b	' ________ LEDP_TOG _________ |'
	dc.b	' Only 1 argument allowed:    |'
	dc.b	' "0"=>turn_off  "1"=>turn_on |'
	dc.b	' No argument =>toggle on/off |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit | Info ]',NUL
;
cookie_err_al_s:
	dc.b	'[3]['
	dc.b	' ________ LEDP_TOG _________ |'
	dc.b	' Sorry!, I tried to find the |'
	dc.b	' "LEDP"  cookie  in the jar, |'
	dc.b	' but it seems to be missing. |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit | Info ]',NUL
;
header_err_al_s:
	dc.b	'[3]['
	dc.b	' ________ LEDP_TOG _________ |'
	dc.b	' Sorry!,  I found the "LEDP" |'
	dc.b	' cookie,   but its structure |'
	dc.b	' is wrong for LEDPANEL.      |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit | Info ]',NUL
;
Info_al_c_t:
	dc.l	Info_al_s_t
	dc.w	0,1,3
	dc.w	1,2,0
	dc.w	2,3,1
	dc.w	3,0,2
;
Info_al_s_t:
	dc.l	info_0_al_s
	dc.l	info_1_al_s
	dc.l	info_2_al_s
	dc.l	info_3_al_s
;
activity_al_t:
	dc.l	args_err_al_s
	dc.l	cookie_err_al_s
	dc.l	header_err_al_s
;
;
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
;
string_p_t:
prog_name_s_p:	ds.l	1
prim_arg_s:	ds.l	1
set_flags:	ds.w	1
;
;----------------------------------------------------------------------------
;
intin:		ds.w	30
intout:		ds.w	45
ptsin:		ds.w	30
ptsout:		ds.w	12
message:	ds.b	16
		ds.l	$100
mystack:	ds.l	4
;
wx:	ds.w	1
wy:	ds.w	1
ww	ds.w	1
wh:	ds.w	1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LEDP_TOG.S
;----------------------------------------------------------------------------
