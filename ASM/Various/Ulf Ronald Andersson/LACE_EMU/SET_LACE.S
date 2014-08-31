;----------------------------------------------------------------------------
;File name:	SET_LACE.S		Revision date:	1998.12.12
;Creator:	Ulf Ronald Andersson	Creation date:	1990.12.07
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	SHAREWARE		(NB: commercial sales forbidden!)
;Project:	LaceScan
;File purpose:	Source for ACC/PRG Set_Lace
;----------------------------------------------------------------------------
; Shareware:	Rights to distribution and use released under the 10
;		conditions given in RELEASE.DOC, without which file
;		distribution of other package parts is criminal.
;----------------------------------------------------------------------------
;;;huge_program		= 1	;uncomment if TEXT+DATA sections are > 32KB
;;;keep_windows		= 1	;uncomment to keep ACC vwk in main eventloop
;;;exec_timeout		= 25	;uncomment to enable timer in main eventloop
exec_message		= 1	;uncomment for messages in main eventloop
;----------------------------------------------------------------------------
	include	RA_JAR.I
	include	RA_XB.I
	include	RA_SIM.I
	include	RA_AV.I
	include	RA_APP.I
	include	L_STRUCT.I
	include	FINDLACE.I
;----------------------------------------------------------------------------
	output	.APP
;----------------------------------------------------------------------------
M_YEAR	=	1998
M_MONTH	=	12
M_DAY	=	12
;
M_TITLE		MACRO
		dc.b	'Set_Lace'
		ENDM
M_VERSION	MACRO
		dc.b	'3.6'
		ENDM
M_AUTHOR	MACRO
		dc.b	'Ronald Andersson'
		ENDM
;----------------------------------------------------------------------------
MAX_VA_ARGLEN	=	512
;----------------------------------------------------------------------------
	SECTION	data
;----------------------------------------------------------------------------
	_uniref	aes_data
	_uniref	vdi_data
	make	SIM_links
;----------------------------------------------------------------------------
	section	TEXT
;----------------------------------------------------------------------------
start_1:
	start_app
;----------------------------------------------------------------------------
	ifeq	huge_program
	SECTION	DATA
	endc
;----------------------------------------------------------------------------
acc_name:	dc.b	'  '
		M_TITLE
		dc.b	' '
		M_VERSION
		dc.b	' ',NUL
		EVEN
;--------
id_app_name_s:	dc.b	'SET_LACE',NUL
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
	lea	VA_arg_s,a0
	clr.b	(a0)
	move.l	a0,VA_arg_p
	tst	d7
	bpl.s	gem_init
tos_init:
	rts
;
gem_init:
	lea	tree_1+t1_max*24+8(pc),a0
	or	#LASTOB,(a0)
	move	#t1_max,d4	;Convert main dialog coordinates.
	move.l	#tree_1,addrin-rz(a6)
	bsr	obj_fix
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
exec_TOS:
exec_err:
	moveq	#-1,d0
	rts
;-------------------------------------
exec_single_APP:
exec_single_ACC:
exec_multi_APP:
exec_multi_ACC:
	bsr	find_emu
	move	#ARROW,intin-rz(a6)
	sub_aes	#graf_mouse
	move.l	#4,intin		;rq work size of desktop
	sub_aes	#wind_get		;using aes wind_get
	lea	intout+2(pc),a0
	lea	intin(pc),a1
	clr	(a1)+			;rq no gadgets
	move.l	(a0)+,(a1)+		;rq max x,y
	move.l	(a0)+,(a1)+		;rq max w,h
	sub_aes	#wind_create
	move	d0,w_hand
	bmi	exec_err
	move.l	#tree_1,addrin-rz(a6)
	bsr	f_center
	lea	fcx(pc),a0
	lea	intin(pc),a1
	move	w_hand(pc),(a1)+	;rq set_lace window
	move.l	(a0)+,(a1)+		;rq x,y
	move.l	(a0)+,(a1)+		;rq w,h
	sub_aes	#wind_open		;aes wind_open
	move	#0,intin-rz(a6)		;Prepare to display dialog.
	bsr	f_dial
	clr	monocolor-rz(a6)
waitdraw:
;
infomono:
	tst	no_emu_f-rz(a6)
	sne	d0
	bne.s	.done_emu
	moveq	#-1,d0			;request speed (to test ability)
	move.l	emu_command_p(pc),a0
	jsr	(a0)
	tst	d0
	smi	d0			;MI means no emulator active
.done_emu:
	ext	d0
	move	d0,nonoflag-rz(a6)
	not	d0
	and	#HIDETREE,d0
	move	d0,tree_1+t1_noemu_text*24+8-rz(a6)
	tst	no_emu_f-rz(a6)
	lea	not_active_s(pc),a0
	beq.s	.set_nono
	lea	no_emu_s(pc),a0
.set_nono:
	move.l	a0,tree_1+t1_noemu_text*24+12-rz(a6)
	move	nonoflag(pc),d0
	and	#HIDETREE,d0
	move	d0,tree_1+t1_emu_group*24+8-rz(a6)
	move	no_emu_f(pc),d0
	and	#HIDETREE,d0
	move	d0,tree_1+t1_load_emu_group*24+8-rz(a6)
	move	no_lace_f(pc),d0
	and	#HIDETREE,d0
	move	d0,tree_1+t1_loadlace_group*24+8-rz(a6)
	tst	nonoflag-rz(a6)
	bne.s	.gotcha
	moveq	#9,d0			;request filter type
	move.l	emu_command_p(pc),a0
	jsr	(a0)
	move	d0,emu_filt_ix-rz(a6)
	lea	typenums-rz(a6),a0
	move	#10,d1
	bsr	conv2dig
	moveq	#-1,d0			;request filter speed
	move.l	emu_command_p(pc),a0
	jsr	(a0)
	move	d0,emu_speed-rz(a6)
	lea	speednums(pc),a0
	move	#10,d1
	bsr	conv3dig
.gotcha:
	move	monocolor(pc),d0
	and	#$0f,d0
	move	d0,monocolor-rz(a6)
	bsr	convhdig0
	move.b	d0,colornums-rz(a6)
	xbios	Setcolor,monocolor(pc),#-1
	move	d0,monorgbmix-rz(a6)
	lea	rgbmixnums(pc),a0
	move	#16,d1
	bsr	conv3dig
;
	_a_init
	move.l	a0,a3
	lea	rez_num_s(pc),a0
	move	la_v_rez_hz(a3),d0
	bsr	conv_4nl_dec
	bsr	bl_x_bl_add
	move	la_v_rez_vt(a3),d0
	bsr	conv_4nl_dec
	bsr	bl_x_bl_add
	move	la_planes(a3),d0
	bsr	conv_4nl_dec
;
	gemdos	Malloc,#-1
	lsr.l	#8,d0
	lsr.l	#2,d0
	move.b	#'K',freeram_unit_s
	cmp.l	#9999,d0
	ble.s	.got_freeram
	lsr.l	#8,d0
	lsr.l	#2,d0
	move.b	#'M',freeram_unit_s
.got_freeram:	
	lea	freeram_num_s(pc),a0
	bsr	conv4dec
	bsr	obj_offset
	move.l	#tree_1,addrin-rz(a6)
	move.w	#t1_treeroot,intin-rz(a6)	;start object
	move.w	#3,intin+2-rz(a6)		;max draw levels
	bsr	obj_draw			;Redraw dialog box
	move.l	#tree_1,addrin-rz(a6)
;
	bsr	formdo			;await user event
;
	move	d0,d1
	mulu	#24,d1
	lea	tree_1(pc),a0
	and	#(-1-SELECTED),10(a0,d1)
;
	cmp	#t1_dec_filt,d0
	beq	dec_filt
	cmp	#t1_inc_filt,d0
	beq	inc_filt
	cmp	#t1_dec_speed,d0
	beq	dec_speed
	cmp	#t1_inc_speed,d0
	beq	inc_speed
	cmp	#t1_dec_color,d0
	beq	dec_color
	cmp	#t1_inc_color,d0
	beq	inc_color
	cmp	#t1_dec_rgb,d0
	beq	dec_rgbmix
	cmp	#t1_inc_rgb,d0
	beq	inc_rgbmix
	cmp	#t1_emu_fsel,d0			;"Load Emu .inf" ?
	beq.s	load_emu_inf
	cmp	#t1_info_butt,d0		;"Info" button ?
	beq	info_show
	cmp	#t1_exit_butt,d0		;"Exit" button ?
	beq.s	exitacc
	bra	waitdraw	;Non valid input, return.
;-------------------------------------
exitacc:
	bsr	obj_offset
	move	#3,intin-rz(a6)
	bsr	f_dial
	move	w_hand(pc),intin
	sub_aes	#wind_close
	move	w_hand(pc),intin
	sub_aes	#wind_delete
	bra	exit_app_ok
;-------------------------------------
load_emu_inf:
	pea	prompt_emu_inf_s(pc)
	pea	emu_inf_name_s(pc)
	pea	star_inf_s(pc)
	pea	emu_inf_path_s(pc)
	clr.b	emu_inf_path_s		;use current path
	bsr	fselect_sub
	add	#16,sp
	tst.l	d0
	ble	waitdraw
	move.l	LPT_p(pc),a0
	move.l	lpt_emu_reload(a0),a0
	jsr	(a0)
	tst.l	d0
	bpl.s	.loaded_ok
	move	#1,intin-rz(a6)
	move.l	#emu_inf_err_al_s,addrin-rz(a6)
	sub_aes	#form_alert			;Show error message alert box.
.loaded_ok:
	bra	waitdraw
;-------------------------------------
find_emu:
	move	#-1,no_lace_f-rz(a6)
	move	#-1,no_emu_f-rz(a6)
	find_lace
	beq.s	.done_emu
;Here we know a compatible LaceScan version is present
	move.l	d0,a5
	move.l	a5,LPT_p-rz(a6)
	clr	no_lace_f-rz(a6)
	move.l	lpt_emu_command(a5),d0
	ble.s	.done_emu
;Here we know a compatible Lace_Emu version is present
	move.l	d0,emu_command_p-rz(a6)
	clr	no_emu_f-rz(a6)
.done_emu:
	rts
;-------------------------------------
bl_x_bl_add:
	move.b	#' ',(a0)+
	move.b	#'x',(a0)+
	move.b	#' ',(a0)+
	clr.b	(a0)
	rts
;-------------------------------------
conv_4nl_dec:
	move.l	a1,-(sp)
	bsr.s	conv4dec
	move.l	a0,a1
.loop_1:
	cmp.b	#' ',(a1)+
	beq.s	.loop_1
	subq	#1,a1
.loop_2:
	move.b	(a1)+,(a0)+
	bne.s	.loop_2
	move.l	(sp)+,a1
	subq	#1,a0
	rts
;-------------------------------------
conv4dec:
	movem.l	a0/a1,-(sp)
	move.l	#10<<16+4,d1
	bra.s	convxdig
;
;
conv4dig:
	movem.l	a0/a1,-(sp)
	swap	d1
	move	#4,d1
	bra.s	convxdig
;
conv3dig:
	movem.l	a0/a1,-(sp)
	swap	d1
	move	#3,d1
	bra.s	convxdig
;
conv2dig:
	movem.l	a0/a1,-(sp)
	swap	d1
	move	#2,d1
convxdig:
	move.l	a0,a1
	add	d1,a0
	clr.b	(a0)
	subq	#1,d1
	andi.l	#$FFFF,d0
convxdiglp1:
	swap	d1
	divu	d1,d0
	swap	d1
	swap	d0
	cmp	#10,d0
	blo.s	convxlodig
	addq	#7,d0
convxlodig:
	add	#'0',d0
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	dbeq	d1,convxdiglp1
	subq	#1,d1
	blt.s	convxdigexit
convxdiglp2:
	move.b	#' ',-(a0)
	dbra	d1,convxdiglp2
convxdigexit:
	swap	d1
	movem.l	(sp)+,a0/a1
	rts
;-------------------------------------
convhdig0:
	move	#16,d1
convdig0:
	swap	d0
convdig:
	clr	d0
	swap	d0
	divu	d1,d0
	swap	d0
	cmp	#10,d0
	blo.s	convlodig
	addq	#7,d0
convlodig:
	add	#'0',d0
	rts
;-------------------------------------
info_show:
	clr	d4
	lea	infotab(pc),a4
.info_showlp:
	cmp	#infomax,d4
	bls.s	.info_showok
	clr	d4
.info_showok:
	move	#1,intin-rz(a6)	;Show 'about' alert box.
	move.l	(a4,d4),addrin-rz(a6)
	sub_aes	#form_alert
	cmp	#3,d0		;"Ok" button ?
	beq	waitdraw	;If so, exit
	addq	#4,d4
	cmp	#1,d0		;"More" button ?
	beq.s	.info_showlp
	subq	#8,d4		;oh, it was "Back" button !
	bhs.s	.info_showlp
	moveq	#infomax,d4
	bra.s	.info_showlp
;-------------------------------------
dec_filt:
	moveq	#1,d0			;request lower filter
	bra.s	step_filt
;
inc_filt:
	moveq	#2,d0			;request higher filter
step_filt:
	move.l	emu_command_p(pc),a0
	jsr	(a0)			;returns active filter
	bra	waitdraw
;-------------------------------------
dec_color:
	subq	#1,monocolor-rz(a6)
	bra	waitdraw
;
;
inc_color:
	addq	#1,monocolor-rz(a6)
	bra	waitdraw
;-------------------------------------
;entry:	d0 = signed value,  d1 = digit base
;exit:	d0 = scaled value
;	affects d0 & CCR
scale_step:
	movem.l	d0-d2,-(sp)
	bios	Kbshift,?
	move.l	4(sp),d2	;d2 = digit base
	moveq	#1,d1		;d1 = scale multiplier
	and	#$0f,d0		;any/none special keys
	beq.s	scale_step_1	;keep multiplier if no specials
	mulu	d2,d1		;Multiply by digit base for any special
	cmp	#4,d0		;<Ctl> or <Alt> included
	blo.s	scale_step_1	;keep new multiplier if no <Alt> or <Ctl>
	mulu	d2,d1		;Multiply again for <Ctl> or <Alt>
scale_step_1:
	move	d1,d2		;d2 = final scale multiplier
	movem.l	(sp)+,d0-d1
	muls	d2,d0		;use multiplier on signed value
	move.l	(sp)+,d2
	rts
;-------------------------------------
dec_speed:
	moveq	#-1,d0
	bra.s	step_speed
;
inc_speed:
	moveq	#1,d0
step_speed:
	moveq	#10,d1
	bsr	scale_step
	move	emu_speed(pc),d3
	add	d0,d3
	cmp	#10,d3
	bge.s	.step_speed_1
	moveq	#10,d3			;limit to 10, to avoid command error
.step_speed_1:
	cmp	#999,d3			;limit to 3 digits
	bls.s	.step_speed_2
	moveq	#10,d3
.step_speed_2:
	move	d3,d0			;request speed d3
	move.l	emu_command_p(pc),a0
	jsr	(a0)
	bra	waitdraw
;-------------------------------------
dec_rgbmix:
	moveq	#-1,d0
	bra.s	steprgbmix
;
inc_rgbmix:
	moveq	#1,d0
steprgbmix:
	moveq	#16,d1
	bsr	scale_step
	move	monorgbmix(pc),d3
	add	d0,d3
	and	#$0FFF,d3
	xbios	Setcolor,monocolor(pc),d3
	bra	waitdraw
;-------------------------------------
exit_terminate:		;jump here to exit with error code in d0
	bclr	#7,revise_type_f
	bra.s	exit_app_app
;-------------------------------------
exit_app_ok:
	clr.l	d0
exit_app_app:
	rts
;----------------------------------------------------------------------------
;End of:	exec_app
;----------------------------------------------------------------------------
;Start of:	exec_mesag
;----------------------------------------------------------------------------
	ifd	exec_message	;cond:	ifd exec_message
exec_mesag:
	cmp	#AC_CLOSE,message
	bne.s	.not_AC_CLOSE
	sf	keep_wind_f
	bra	exit_mesag
;
.not_AC_CLOSE:
	cmp	#AP_TERM,message
	bne.s	.not_AP_TERM
	tst.l	d7
	bmi	exit_mesag		;AP_TERM is not for ACCs
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
	clr.b	VA_arg_s		;prep empty local string
	lea	VA_arg_s(pc),a2		;a2 -> local argument area
	move.l	a2,VA_arg_p		;prep a pointer for future
	move.l	VA_START_cmd_p(pc),a0	;a0 -> argument on Venus
	move.l	a0,d0			;test -> argument on Venus
	ble.s	.send_AV_STARTED	;if NULL, go send reply now
	move.l	a0,a1			;a1 -> argument on Venus
	strpass	a1			;a1 -> argument end on Venus
	sub.l	VA_START_cmd_p(pc),a1	;a1 = argument length
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
.send_AV_STARTED:
	AV_send	STARTED|_ind,VA_START_cmd_p(pc)
	bra	exec_app
;
.not_VA_START:
	cmp	#VA_PROTOSTATUS,message
	bne.s	.not_VA_PROTOSTATUS
	move	message+8,VA_protostatus
	move	message+6,VA_protostatus+2
	bra	exit_mesag
;
.not_VA_PROTOSTATUS:
exec_mesag_extend:
exit_mesag:
	rts
	endc			;ends:	ifd exec_message
;----------------------------------------------------------------------------
;End of:	exec_mesag
;----------------------------------------------------------------------------
;	*******************************
;	* Operating system functions. *
;	*******************************
;
obj_draw:
	move.l	fcx+0(pc),intin+4-rz(a6)	;form X,Y
	move.l	fcx+4(pc),intin+8-rz(a6)	;form W,H
	sub_aes	#objc_draw
	rts
;----------------------------------------------------------------------------
obj_fix:
	move	d4,intin-rz(a6)	;Repeat for objects 0..d4 in tree.
	sub_aes	#rsrc_obfix
	dbra	d4,obj_fix
	rts
;----------------------------------------------------------------------------
obj_offset:
	clr	intin-rz(a6)
	move.l	#tree_1,addrin-rz(a6)
	sub_aes	#objc_offset
	move.l	intout+2(pc),fcx+0-rz(a6)	;form X,Y
	rts
;----------------------------------------------------------------------------
formdo:
	clr	intin-rz(a6)
	sub_aes	#form_do
	rts
;----------------------------------------------------------------------------
f_center:
	sub_aes	#form_center
	move.l	intout+2(pc),fcx+0-rz(a6)	;form X,Y
	move.l	intout+6(pc),fcx+4-rz(a6)	;form W,H
	rts
;----------------------------------------------------------------------------
f_dial:
	lea	intin+2(pc),a0
	clr.l	(a0)+		;origo X,Y
	clr.l	(a0)+		;origo W,H
	move.l	fcx+0(pc),(a0)+	;form X,Y
	move.l	fcx+4(pc),(a0)+	;form W,H
	sub_aes	#form_dial
	rts
;----------------------------------------------------------------------------
;	File select subroutine
;
;arg1 -> path string, possibly with unwanted filename attached
;arg2 -> file mask, null => "*.*"
;arg3 -> initial file name
;arg4 -> prompt string
;
;returns d0 -> path string (arg1) with selected filename, or null on CANCEL
;-------------------------------------
fselect_sub:
	link	a6,#0
	movem.l	d1-d2/a0-a2,-(sp)
	clr.l	addrin
	clr	intin
	move.l	#$4E010101,d0	;graf_mouse
	bsr	call_aes
	move.l	8(a6),a1
	tst.b	(a1)
	bne.s	.restart_name_1
	bsr	getdrvpath_ia1
.restart_name_1:
	move.l	a1,a2		;a2 -> prel name_start
.test_name_1:
	move.b	(a1)+,d0
	beq.s	.have_name_1
	cmp.b	#'\',d0
	bne.s	.test_name_1
	bra.s	.restart_name_1
;
.stars_s:
	dc.b	'*.*',NUL		;NB: 4 bytes
;
.have_name_1:
	move.l	12(a6),a1
	bgt.s	.make_mask
	lea	.stars_s(pc),a1
.make_mask:
	move.b	(a1)+,(a2)+
	bne.s	.make_mask
	clr.b	(a2)
	lea	addrin(pc),a0
	move.l	8(a6),(a0)+		;addrin[0] -> path buffer
	move.l	16(a6),(a0)+		;addrin[1] -> name buffer
	move.l	20(a6),(a0)+		;addrin[2] -> prompt string
	bsr.s	try_fsel_exinput	;call AES fsel_exinput or fsel_input
	clr.l	d0
	tst	intout
	beq.s	.exit			;exit on error
	tst	intout+2
	beq.s	.exit			;exit on [CANCEL] button
	move.l	8(a6),a0
.restart_name_2:
	move.l	a0,a2		;a2 -> prel name_start after path
.test_name_2:
	move.b	(a0)+,d0
	beq.s	.have_name_2
	cmp.b	#'\',d0
	bne.s	.test_name_2
	bra.s	.restart_name_2
;
.have_name_2:
	move.l	16(a6),a1	;a1 -> file name
.copy_name:
	move.b	(a1)+,(a2)+
	bne.s	.copy_name
	move.l	8(a6),d0	;return path with name
.exit:
	movem.l	d1-d2/a0-a2,-(sp)
	unlk	a6
	rts
;-------------------------------------
try_fsel_exinput:
	move.l	addrin+2*4,d0
	ble.s	.use_fileselector
	move.l	#$5A000202,d1	;AES fsel_input
	move.l	#'FSEL',d0
	bsr.s	seek_cookie_d0
	bpl.s	.use_new_selector
	bsr.s	what_TOS_version
	cmp	#$0104,d0
	blt.s	.use_fileselector
.use_new_selector:
	move.l	#$5B000203,d1	;AES fsel_exinput
.use_fileselector:
	move.l	d1,d0
	bsr	call_aes
	rts
;-------------------------------------
what_TOS_version:
	movem.l	d1-d7/a0-a6,-(sp)
	gemdos	Super|_ind,#1
	move.l	d0,d7
	bmi.s	.sup_seek_1
	gemdos	Super,!
	move.l	d0,d7
.sup_seek_1:
	move.l	(_sysbase).w,a0
	move.l	os_version(a0),d0
	bra.s	super_return
;-------------------------------------
seek_cookie_d0:
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,d3
	gemdos	Super|_ind,#1
	move.l	d0,d7
	bmi.s	.sup_seek_1
	gemdos	Super,!
	move.l	d0,d7
.sup_seek_1:
	moveq	#-34,d0		;prep 'path not found' error
	move.l	(_cookies).w,d1
	beq.s	super_return
	move.l	d1,a0
	moveq	#-33,d0		;prep 'file not found' error
.seek_cookie_loop:
	tst.l	(a0)
	beq.s	super_return
	cmp.l	(a0),d3
	beq.s	.seek_cookie_found
	addq.l	#8,a0
	bra.s	.seek_cookie_loop
;
.seek_cookie_found:
	move.l	a0,d0
super_return:
	exg	d0,d7
	tst.l	d0
	bmi.s	.keep_super
	gemdos	Super|_ind,d0
.keep_super:
	move.l	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;-------------------------------------
call_aes:
	movem.l	d1-d7/a0-a6,-(sp)
	lea	contrl(pc),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr	(a0)
	movep.l	d0,-7(a0)
	cmpi.b	#$70,-7(a0)
	bne.s	.done_saddrout
	move.b	#1,1(a0)
.done_saddrout:
	lea	aes_pb(pc),a0
	move.l	a0,d1
	move	#$C8,d0			;aes code
	trap	#2			;xgemdos
	moveq	#0,d0
	move	intout(pc),d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;-------------------------------------
getdrvpath_ia1:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a1,-(sp)
	gemdos	Dgetdrv
	add	#'A',d0
	move.l	(sp),a1
	move.b	d0,(a1)+
	move.b	#':',(a1)+
	sub	#'A',d0
.get_path:
	addq	#1,d0
	gemdos	Dgetpath,(a1),d0
	move.l	(sp)+,a0
.pass_str:
	tst.b	(a0)+
	bne.s	.pass_str
	subq	#1,a0
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;----------------------------------------------------------------------------
	make	SIM_links,JAR_links,AV_links
;----------------------------------------------------------------------------
	section	data
;----------------------------------------------------------------------------
emu_inf_err_al_s:
	dc.b	"[0]["
	dc.b	"An error occurred while I was|"
	dc.b	"trying to  load  the Lace_Emu|"
	dc.b	"INF/DEF file.]"
	dc.b	"[ Ooops ]",0
	even
;
infoalert0:
	dc.b	"[0]["
	dc.b	"Set_Lace is part of LaceScan |"
	dc.b	"(c)1998  Ulf Ronald Andersson|"
	dc.b	"Released as  SHAREWARE  under|"
	dc.b	"10 conditions  (LaceScan.Hyp)|"
	dc.b	"Set_Lace runs as PRG or ACC.]"
	dc.b	"[ More | Back | Exit ]",0
	even
;
infoalert1:
	dc.b	"[0]["
	dc.b	"To protect users,  I forbid  |"
	dc.b	"all distribution of LaceScan|"
	dc.b	"programs  without  including|"
	dc.b	"a LaceScan.Hyp file.  Please|"
	dc.b	"respect  this  requirement.]"
	dc.b	"[ More | Back | Exit ]",0
	even
;
infoalert2:
	dc.b	"[0]["
	dc.b	"For bug reports, questions & |"
	dc.b	"registrations my address is:|"
	dc.b	"    Ulf Ronald Andersson|"
	dc.b	"        H”ders v„g 7|"
	dc.b	"     S-145 70  Norsborg]"
	dc.b	"[ More | Back | Exit ]",0
	even
;
infoalert3:
	dc.b	"[0]["
	dc.b	"If you have difficulty using |"
	dc.b	"Set_Lace, read  LaceScan.Hyp|"
	dc.b	"for information on emulators|"
	dc.b	"and their operating modes.|"
	dc.b	"]"
	dc.b	"[ More | Back | Exit ]",0
	even
;
infoalert4:
	dc.b	"[0]["
	dc.b	"For emulator speed steps of  |"
	dc.b	"10 instead of 1, press shift|"
	dc.b	"key as you click the button.|"
	dc.b	"You won't pass safety limit.|"
	dc.b	"Most useful speeds = 20..100]"
	dc.b	"[ More | Back | Exit ]",0
	even
;
infoalert5:
	dc.b	"[0]["
	dc.b	"For each multi-digit button, |"
	dc.b	"<shift> will scale a step by|"
	dc.b	"1 digit, but <ctrl> or <alt>|"
	dc.b	"scale it by 2 digits.  XBIOS|"
	dc.b	"colour codes used,  not GEM.]"
	dc.b	"[ More | Back | Exit ]",0
	even
;
infoalert6:
	dc.b	"[0]["
	dc.b	"Alter digit 0 of colour 0 to |"
	dc.b	"invert mono screen.  Affects|"
	dc.b	"colours 0..3, so do it twice|"
	dc.b	"to recover from bad colours.|"
	dc.b	'New filter sets same colours]'
	dc.b	"[ More | Back | Exit ]",0
	even
;
infotab:
	dc.l	infoalert0,infoalert1,infoalert2,infoalert3
	dc.l	infoalert4,infoalert5,infoalert6
infoend:
;
infomax	=	infoend-infotab-4
;----------------------------------------------------------------------------
;	*********************************
;	* Data for the main dialog box. *
;	*********************************
;
fcx:	ds.w	4		;form center coordinates
;
tree_1:
	o_head	t1,treeroot,?,prog_title,max
	dc.w	G_BOX,NONE,OUTLINED
	dc.l	$21100,$000000,$22000F
;
	o_head	t1,prog_title,info_butt,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	deskstr,$010001,$000001
;
	o_head	t1,info_butt,emu_group,?,?
	dc.w	G_BUTTON,SELECTABLE|FL3DACT|EXIT,NORMAL
	dc.l	infostr,$190001,$060001
;
	o_head	t1,emu_group,resolution_text,filt_text,inc_speed
	dc.w	G_IBOX,NONE,NORMAL
	dc.l	0,$000003,$220003
;
;start of emu_group children
;
	o_head	t1,filt_text,dec_filt,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	typestr,$010000,$000001
;
	o_head	t1,dec_filt,filt_num,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	dec_char_s,$190000,$020001
;
	o_head	t1,filt_num,inc_filt,?,?
	dc.w	G_BUTTON,EXIT,NORMAL
	dc.l	typenums,$1b0000,$040001
;
	o_head	t1,inc_filt,speed_text,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	inc_char_s,$1f0000,$020001
;
	o_head	t1,speed_text,dec_speed,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	speedstr,$010002,$000001
;
	o_head	t1,dec_speed,speed_num,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	dec_char_s,$190002,$020001
;
	o_head	t1,speed_num,inc_speed,?,?
	dc.w	G_BUTTON,EXIT,NORMAL
	dc.l	speednums,$1b0002,$040001
;
	o_head	t1,inc_speed,emu_group,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	inc_char_s,$1f0002,$020001
;
;end of emu_group children
;
	o_head	t1,resolution_text,noemu_text,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	rez_txt_s,$010004,$000001
;
	o_head	t1,noemu_text,color_group,?,?
	dc.w	G_STRING,HIDETREE,NORMAL
	dc.l	not_active_s,$010005,$000001
;
	o_head	t1,color_group,load_emu_group,color_text,inc_rgb
	dc.w	G_IBOX,NONE,NORMAL
	dc.l	0,$000007,$220001
;
;start of color_group children
;
	o_head	t1,color_text,dec_color,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	colorstr,$010000,$000001
;
	o_head	t1,dec_color,color_num,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	dec_char_s,$080000,$020001
;
	o_head	t1,color_num,inc_color,?,?
	dc.w	G_BUTTON,EXIT,NORMAL
	dc.l	colornums,$0a0000,$040001
;
	o_head	t1,inc_color,rgb_text,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	inc_char_s,$0e0000,$020001
;
	o_head	t1,rgb_text,dec_rgb,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	rgbmixstr,$110000,$000001
;
	o_head	t1,dec_rgb,rgb_num,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	dec_char_s,$190000,$020001
;
	o_head	t1,rgb_num,inc_rgb,?,?
	dc.w	G_BUTTON,EXIT,NORMAL
	dc.l	rgbmixnums,$1b0000,$040001
;
	o_head	t1,inc_rgb,color_group,?,?
	dc.w	G_BUTTON,SELECTABLE|EXIT,NORMAL
	dc.l	inc_char_s,$1f0000,$020001
;
;end of color_group children
;
	o_head	t1,load_emu_group,loadlace_group,load_emu_text,emu_fsel
	dc.w	G_IBOX,NONE,NORMAL
	dc.l	0,$000009,$220001
;
	o_head	t1,load_emu_text,emu_fsel,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	load_emu_s,$080000,$000001
;
	o_head	t1,emu_fsel,load_emu_group,?,?
	dc.w	G_BUTTON,SELECTABLE|FL3DACT|EXIT,NORMAL
	dc.l	fsel_s,$010000,$060001
;
	o_head	t1,loadlace_group,freeram_text,loadlace_text,lace_fsel
	dc.w	G_IBOX,NONE,NORMAL
	dc.l	0,$00000B,$220001
;
	o_head	t1,loadlace_text,lace_fsel,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	loadlace_s,$080000,$000001
;
	o_head	t1,lace_fsel,loadlace_group,?,?
	dc.w	G_BUTTON,SELECTABLE|FL3DACT|EXIT,DISABLED
	dc.l	fsel_s,$010000,$060001
;
	o_head	t1,freeram_text,exit_butt,?,?
	dc.w	G_STRING,NONE,NORMAL
	dc.l	freeram_txt_s,$01000D,$000001
;
	o_head	t1,exit_butt,treeroot,?,?
	dc.w	G_BUTTON,SELECTABLE|FL3DACT|EXIT|DEFAULT,NORMAL
	dc.l	exitstr,$1A000D,$060001
;
	o_name	t1,objects
t1_max	=	t1_objects-1
;
;
;	Dialog data
;
emu_filt_ix:	ds.w	1
emu_speed:	ds.w	1
monocolor:	ds.w	1
monorgbmix:	ds.w	1
;
;	* Text for dialog box.
;
deskstr:	M_TITLE
		dc.b	'  Version: '
		M_VERSION
		dc.b	NUL
;
infostr:	dc.b	'Info',0
typestr:	dc.b	'Emulation filter  type:',0
speedstr:	dc.b	'Emulation filter speed:',0
exitstr:	dc.b	'Exit',0
dec_char_s:	dc.b	'-',0
inc_char_s:	dc.b	'+',0
typenums:	dc.b	'03',0
speednums:	dc.b	'200',0
not_active_s:	dc.b	'Emulator is not active.',0
no_emu_s:	dc.b	'No compatible emulator.',0
colorstr:	dc.b	'Colour',0
rgbmixstr:	dc.b	'has RGB',0
colornums:	dc.b	'7',0
rgbmixnums:	dc.b	'777',0
rez_txt_s:	dc.b	'Rez = '		;NB: unterminated
rez_num_s:	dc.b	      '1280 x 960 x 1',NUL
		ds.b	8
freeram_txt_s:
freeram_unit_s:
		dc.b	'KB free RAM = '	;NB: unterminated
freeram_num_s:	dc.b	'4096',0
fsel_s:		dc.b	'Fsel',0
loadlace_s:	dc.b	'Reload LaceScan setup...',NUL
load_emu_s:	dc.b	'Reload Lace_Emu setup...',NUL
		even
xbralace_s:	dc.b	'XBRA','Lace',0
		even
prompt_emu_inf_s:
		dc.b	'Load emulator INF-file:',NUL
emu_inf_name_s:	dc.b	'LACE_EMU.INF',NUL
star_inf_s:	dc.b	'*.INF',NUL
emu_inf_path_s:	dcb.b	140,NUL
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
VA_START_f:		ds.w	1
VA_START_cmd_p:		ds.l	1
VA_protostatus:		ds.l	1
VA_arg_p:		ds.l	1
VA_arg_s:		ds.b	MAX_VA_ARGLEN
			EVEN
;-------
w_hand:		ds.w	1
nonoflag:	ds.w	1
no_emu_f:	ds.w	1
no_lace_f:	ds.w	1
emu_command_p:	ds.l	1
LPT_p:		ds.l	1
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	SET_LACE.S
;----------------------------------------------------------------------------
