;----------------------------------------------------------------------------
;File name:	RA_AV.I				Revision date:	1998.10.16
;Creator:	Ulf Ronald Andersson		Creation date:	1991.02.02
;Released as:	FREEWARE			Commercial sales forbidden !
;----------------------------------------------------------------------------
;File purpose:	Symbol & Macro library for application message protocols
;
;	AV - protocol	App - serVer (originally Acc-Venus (Gemini))
;	MP - protocol	Module player (originally for Paula)
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_AV_defined
RA_AV_defined	set	1
;----------------------------------------------------------------------------
;	Library macros:
;
;AV_set_partner name_p	d0 = app_id of AV partner or -1 if none available
;AV_send msg,args...	d0 = 0 normally, but -1 on appl_write failure
;
;VA_set_partner name_p	d0 = app_id of VA partner, or -1 if not available
;VA_send msg,args...	d0 = 0 normally, but -1 on appl_write failure
;
;MP_set_partner	name_p	d0 = app_id of MP partner, or -1 if not available
;MP_send msg,args...	d0 = 0 normally, but -1 on appl_write failure
;
;For AV_set_partner and VA_set_partner, a name_p of -1 causes a search for
;a standard AVSERVER, using four different methods.
;
;For MP_set_partner, a name_p of -1 causes a search for
;a standard MPSERVER, using three different methods.
;----------------------------------------------------------------------------
;	Defined variables:
;
;AV_sender_id	1 W  = app id of AV sender (set = global[2] by AV_set_partner)
;AV_partner_id	1 W  = app id of AV partner (filled by AV_set_partner)
;AV_message	8 W  used by AV_send
;
;VA_sender_id	1 W  = app id of VA sender (set = global[2] by VA_set_partner)
;VA_partner_id	1 W  = app id of VA partner (filled by VA_set_partner)
;VA_message	8 W  used by VA_send
;
;MP_sender_id	1 W  = app id of MP sender (set = global[2] by MP_set_partner)
;MP_partner_id	1 W  = app id of MP partner (filled by MP_set_partner)
;MP_message	8 W  used by MP_send
;----------------------------------------------------------------------------
;NB: You must include the following line somewhere after the macro calls
;
;	"make	AV_links"
;
;NB: That will cause the needed routines to be included at that point.
;NB: You may do this several times (after further calls), and at each
;NB: point only the 'newly' referenced routines will be added to the code.
;NB: A dummy reference macro exists, so routines can be added to code even
;NB: without calling them.  The macro is '_uniref', used as below:
;
;	"_uniref AV_set_server"
;----------------------------------------------------------------------------
	include	RA_GEM.I
;----------------------------------------------------------------------------
;	The link macro
;
AV_links	MACRO
	_unidef	AV_set_partner
	_unidef	AV_send
	_unidef	VA_set_partner
	_unidef	VA_send
	_unidef	MP_set_partner
	_unidef	MP_send
	GEM_links
	ENDM	;AV_links
;----------------------------------------------------------------------------
;	AV_PROTOKOLL flag bits and flag words
;
;	message[3]
;
b_VA_SETSTATUS		= 0
b_VA_START		= 1
b_AV_STARTED_A		= 2
b_VA_FONTCHANGED	= 3
b_VA_quoting		= 4
b_VA_PATHUPDATE		= 5
;
w_VA_SETSTATUS		= 1<<0
w_VA_START		= 1<<1
w_AV_STARTED_A		= 1<<2
w_VA_FONTCHANGED	= 1<<3
w_VA_quoting		= 1<<4
w_VA_PATHUPDATE		= 1<<5
;----------------------------------------------------------------------------
;	AV_PROTOSTATUS flag bits and flag words
;
;	message[3]
;
b_AV_SENDKEY		=  0
b_AV_ASKFILEFONT	=  1
b_AV_console		=  2
b_AV_ASKOBJECT		=  3
b_AV_OPENWIND		=  4
b_AV_STARTPROG		=  5
b_AV_accwind		=  6
b_AV_status		=  7
b_AV_COPYDRAGGED	=  8
b_AV_updwhatdrag	=  9
b_AV_EXIT		= 10
b_AV_XWIND		= 11
b_AV_FONTCHANGED	= 12
b_AV_STARTED_V		= 13
b_AV_quoting		= 14
b_AV_FILEINFO		= 15
;
w_AV_SENDKEY		=  1<<0
w_AV_ASKFILEFONT	=  1<<1
w_AV_console		=  1<<2
w_AV_ASKOBJECT		=  1<<3
w_AV_OPENWIND		=  1<<4
w_AV_STARTPROG		=  1<<5
w_AV_accwind		=  1<<6
w_AV_status		=  1<<7
w_AV_COPYDRAGGED	=  1<<8
w_AV_updwhatdrag	=  1<<9
w_AV_EXIT		= 1<<10
w_AV_XWIND		= 1<<11
w_AV_FONTCHANGED	= 1<<12
w_AV_STARTED_V		= 1<<13
w_AV_quoting		= 1<<14
w_AV_FILEINFO		= 1<<15
;
;	message[4]
;
b_AV_COPYFILE	= 16
b_AV_DELFILE	= 17
b_AV_VIEW	= 18
b_AV_SETWINDPOS	= 19
;
w_AV_COPYFILE	= 1<<16
w_AV_DELFILE	= 1<<17
w_AV_VIEW	= 1<<18
w_AV_SETWINDPOS	= 1<<19
;----------------------------------------------------------------------------
;	Message codes
;------------------------------------
;	Mandatory
;
AV_PROTOKOLL		= $4700		;(flags, res1, res2, acc_name_p)
__AV_PROTOKOLL		= $00002603
VA_PROTOSTATUS		= $4701		(flags, res1, res2, acc_name_p)
__VA_PROTOSTATUS	= $00002603
;------------------------------------
;	needs b_AV_EXIT on Venus
;
AV_EXIT			= $4736		;(acc_app_id)
__AV_EXIT		= $00000003
;------------------------------------
;	needs b_AV_SENDKEY on Venus
;
AV_SENDKEY		= $4710		;(kbshift,scan_asc)
__AV_SENDKEY		= $00000403
;------------------------------------
;	needs b_AV_STARTPROG on Venus
;
AV_STARTPROG		= $4722		;(path_fname_p, cmd_line_p, call_shake)
__AV_STARTPROG		= $00072523
VA_PROGSTART		= $4723 	;(start_f, ret_code, dummy1, dummy2, call_shake)
__VA_PROGSTART		= $00070403
;------------------------------------
;	needs b_VA_START in Acc
;
VA_START		= $4711		;(cmd_line_p)  cmd_line_p may be NULL
__VA_START		= $00000023
;------------------------------------
;	needs both b_AV_STARTED_V on venus, and b_AV_STARTED_A in Acc
;
AV_STARTED		= $4738		;(cmd_line_p)  cmd_line_p identical to that in VA_START
__AV_STARTED		= $00000023
;------------------------------------
;	needs b_AV_accwind on Venus
;
AV_ACCWINDOPEN		= $4724		;(wind_h)
__AV_ACCWINDOPEN	= $00000003
VA_DRAGACCWIND		= $4725 	;(wind_h, x, y, cmd_line_p)
__VA_DRAGACCWIND	= $26050403
AV_ACCWINDCLOSED	= $4726		;(wind_h)
__AV_ACCWINDCLOSED	= $00000003
;------------------------------------
;	needs b_AV_COPYDRAGGED on Venus
;
AV_COPYDRAGGED		= $4728		;(kbshift, destpath_p)
__AV_COPYDRAGGED	= $00002403
VA_COPYCOMPLETE		= $4729		;(change_f)
__VA_COPYCOMPLETE	= $00000003
;------------------------------------
;	needs b_AV_ASKFILEFONT on Venus
;
AV_ASKFILEFONT		= $4712		;()
__AV_ASKFILEFONT	= $00000000
VA_FILEFONT		= $4713		;(font_id, font_points)
__VA_FILEFONT		= $00000403
;------------------------------------
;	needs b_AV_OPENWIND on Venus
;
AV_OPENWIND		= $4720		;(windpath_p, wildcard_p)
__AV_OPENWIND		= $00002523
VA_WINDOPEN		= $4721 	;(opened_f)
__VA_WINDOPEN		= $00000003
;------------------------------------
;	needs b_AV_XWIND on Venus
;
AV_XWIND		= $4740		;(windpath_p, wildcard_p, x_f)
__AV_XWIND		= $00072523
VA_XOPEN		= $4741 	;(opened_f)
__VA_XOPEN		= $00000003
;------------------------------------
;	needs b_AV_ASKOBJECT on Venus
;
AV_ASKOBJECT		= $4716		;()
__AV_ASKOBJECT		= $00000000
VA_OBJECT		= $4717 	;(->cmd_line_p)
__VA_OBJECT		= $00000023
;------------------------------------
;	needs b_AV_updwhatdrag on Venus
;
AV_WHATIZIT		= $4732		;(X, Y)
__AV_WHATIZIT		= $00000403
VA_THATIZIT		= $4733 	;(owner_id, type, obj_name_p)
__VA_THATIZIT		= $00250403
AV_PATHUPDATE		= $4730 	;(updpath_p) NB: asolute path!
__AV_PATHUPDATE		= $00000023
AV_DRAGONWINDOW		= $4734		;(x,y,kbshift,cmd_line_p)
__AV_DRAGONWINDOW	= $26050403
VA_DRAGCOMPLETE		= $4735		;(change_f)
__VA_DRAGCOMPLETE	= $00000003
VA_FONTCHANGED		= $4739		;(filefont_id,filefont_pts,con_font_id,con_font_pts)
__VA_FONTCHANGED	= $06050403
;------------------------------------
;	needs b_AV_console on Venus
;
AV_OPENCONSOLE		= $4718		;()
__AV_OPENCONSOLE	= $00000000
VA_CONSOLEOPEN		= $4719		;(opened_f)
__VA_CONSOLEOPEN	= $00000003
AV_ASKCONFONT		= $4714		;()
__AV_ASKCONFONT		= $00000000
VA_CONFONT		= $4715		;(font_id,font_pts)
__VA_CONFONT		= $00000403
;------------------------------------
;	needs b_AV_status on Venus
;
AV_GETSTATUS		= $4703		;()
__AV_GETSTATUS		= $00000000
AV_STATUS		= $4704		;(status_s_p)
__AV_STATUS		= $00000023
;------------------------------------
;	needs b_VA_SETSTATUS in Acc
;
VA_SETSTATUS		= $4705 	;(status_s_p)
__VA_SETSTATUS		= $00000023
;----------------------------------------------------------------------------
;	need THING (or other server made late 1995 or later)
;
AV_VIEW			= $4751		;(pathfname_p)
__AV_VIEW		= $00000023
AV_VIEWED		= $4752		;(OK_f)
__AV_VIEWED		= $00000003
AV_FILEINFO		= $4753 	;(cmd_line_p)
__AV_FILEINFO		= $00000023
VA_FILECHANGED		= $4754		;(cmd_line_p) same as in AV_FILEINFO, but names may have changed
__VA_FILECHANGED	= $00000023
AV_COPYFILE		= $4755 	;(cmd_line_p, destpath_p, opmode_f) b0=move b1=rename b2=overwrite
__AV_COPYFILE		= $00072523
VA_FILECOPIED		= $4756		;(OK_f)
__VA_FILECOPIED		= $00000003
AV_DELFILE		= $4757		;(cmd_line_p)
__AV_DELFILE		= $00000023
VA_FILEDELETED		= $4758 	;(OK_f)
__VA_FILEDELETED	= $00000003
AV_SETWINDPOS		= $4759		;(x,y,w,h)
__AV_SETWINDPOS		= $06050403
VA_PATHUPDATE		= $4760		;(changed_path_p)  NB: assume subfolders need rereading
__VA_PATHUPDATE		= $00000023
;----------------------------------------------------------------------------
;	MP-protocol messages
;----------------------------------------------------------------------------
MP_ACK			= $4800		;Paula says OK to last command
__MP_ACK		= $00000000
MP_NAK			= $4801		;Paula says NO to last command
__MP_NAK		= $00000000
;The two above have msg[7] = Paula version : V2.4 => $0204
;----------------------------------------------------------------------------
MP_START		= $4802		;Arguments like VA_START => reply ACK/NAK
__MP_START		= $00000023
;Reply ACK means the command string may be reused
;----------------------------------------------------------------------------
;The two below release module RAM
MP_STOP			= $4803		;=> reply ACK
__MP_STOP		= $00000000
MP_SHUTDOWN		= $4804		;=> reply ACK
__MP_SHUTDOWN		= $00000000
;----------------------------------------------------------------------------
;Start of:	Macro definitions
;----------------------------------------------------------------------------
;int16	AV_set_partner(char *name);
;
AV_set_partner	MACRO	name
	_uniref		AV_set_partner
	PUREC_func.\0	AV_set_partner,1,3,\1
	ENDM		;AV_set_partner
;------------------------------------
AV_set_partner_code	MACRO
	movem.l		d1-d2/a0-a2,-(sp)
	move		global+4,AV_sender_id
	move.l		a0,addrin			;check for special app name
	bmi.s		.seek_partner
	sub_aes		#appl_find
	move		intout,AV_partner_id
	bra		.done
;
.seek_partner:
	move.l		#.pad8_AVSERVER_s,addrin	;check for app named "AVSERVER"
	sub_aes		#appl_find
	move		intout,AV_partner_id
	bpl		.done
	move.l		#.AVSERVER_eq_s,addrin+4	;check environment for 'AVSERVER='
	move.l		#.AVSERVER_name_p,addrin
	sub_aes		#shel_envrn
	move		#-1,AV_partner_id
	tst		intout
	beq.s		.not_env_partner
	lea		.AVSERVER_name_s,a1
	move.l		.AVSERVER_name_p,a0
	moveq		#' ',d1
	moveq		#8-1,d2
.pad_8_loop:
	move.b		(a0)+,(a1)+
	bne.s		.next_char
	subq		#1,a0
	move.b		d1,-1(a1)
.next_char:
	dbra		d2,.pad_8_loop
	move.l		#.AVSERVER_name_s,addrin
	sub_aes		#appl_find
	move		intout,AV_partner_id
	bpl.s		.done
.not_env_partner:
	move.l		#.pad8_THING_s,addrin		;check for app named "THING  "
	sub_aes		#appl_find
	move		intout,AV_partner_id
	bpl.s		.done
	move.l		#.pad8_GEMINI_s,addrin		;check for app named "GEMINI  "
	sub_aes		#appl_find
	move		intout,AV_partner_id
.done:
	movem.l		(sp)+,d1-d2/a0-a2
	move		AV_partner_id,d0		;d0 = app_id of AVSERVER or -1  (flagged)
	rts
;
.pad8_THING_s:
	dc.b		'THING   ',NUL
.pad8_GEMINI_s:
	dc.b		'GEMINI  ',NUL
.pad8_AVSERVER_s:
	dc.b		'AVSERVER',NUL
.AVSERVER_eq_s:
	dc.b		'AVSERVER=',NUL
.AVSERVER_name_s:
	ds.b		9
	even
.AVSERVER_name_p:
	dc.l		0
	ENDM		;AV_set_partner_code
;------------------------------------
AV_send	MACRO	AV_msg,arg1,arg2,arg3,arg4,arg5
	_uniref		AV_send
__AV_flag		set	__AV_\1
	IFC		'','\1'	;AV_msg
	FAIL		AV_send used without any message code
	MEXIT
	ENDC
	IFNC		'','\6'	;arg5
	FAIL		AV_send used with more than 5 arguments
	FAIL		acceptable args = '\1,\2,\3,\4,\5'
	FAIL		incorrect arg = '\6'
	ENDC
	jsr		AV_preclear
	move		#(AV_\1)&$FFFF,AV_message
	IFNC		'','\2'	;arg1
	__AV_arg.\0	0,\2	;arg1
	IFNC		'','\3'	;arg2
	__AV_arg.\0	1,\3	;arg2
	IFNC		'','\4'	;arg3
	__AV_arg.\0	2,\4	;arg3
	IFNC		'','\5'	;arg4
	__AV_arg.\0	3,\5	;arg4
	ENDC		;arg4
	ENDC		;arg3
	ENDC		;arg2
	ENDC		;arg1
	jsr		AV_send_code
	ENDM	;AV_send
;------------------------------------
AV_send_code	MACRO
	movem.l		d1-d2/a0-a2,-(sp)
	move		AV_partner_id(pc),d0
	bpl.s		.send_it_1
	AV_set_partner	-1.w
	bmi.s		.error
.send_it_1:
	move		AV_sender_id(pc),d0
	bpl.s		.send_it_2
	move		global+4,AV_sender_id
.send_it_2:
	lea		AV_message(pc),a0
	clr		4(a0)
	move		AV_sender_id(pc),2(a0)
	gem_aes		appl_write,AV_partner_id(pc),#16,AV_message(pc)
	moveq		#E_ACCDN,d0
	tst		intout
	beq.s		.exit
	clr.l		d0
.exit:
	movem.l		(sp)+,d1-d2/a0-a2
	tst		d0
	rts
;
.error:
	moveq		#E_INVFN,d0
	bra.s		.exit
;
AV_preclear:
	clr.l		AV_message
	clr.l		AV_message+4
	clr.l		AV_message+8
	clr.l		AV_message+12
	rts
;
AV_message:
	ds.w		8
AV_sender_id:
	dc.w		-1
AV_partner_id:
	dc.w		-1
	ENDM	;AV_send_code
;------------------------------------
VA_set_partner	MACRO	name
	_uniref		VA_set_partner
	PUREC_func.\0	VA_set_partner,1,3,\1
	ENDM	;VA_set_partner
;------------------------------------
VA_set_partner_code	MACRO
	movem.l		d1-d2/a0-a2,-(sp)
	move		global+4,VA_sender_id
	move.l		a0,addrin
	bmi.s		.seek_partner
	sub_aes		#appl_find
	move		intout,VA_partner_id
	bra		.done
;
.seek_partner:
	move.l		#.pad8_AVSERVER_s,addrin	;check for app named "AVSERVER"
	sub_aes		#appl_find
	move		intout,VA_partner_id
	bpl		.done
	move.l		#.AVSERVER_eq_s,addrin+4	;check environment for 'AVSERVER='
	move.l		#.AVSERVER_name_p,addrin
	sub_aes		#shel_envrn
	move		#-1,VA_partner_id
	tst		intout
	beq.s		.not_env_partner
	lea		.AVSERVER_name_s,a1
	move.l		.AVSERVER_name_p,a0
	moveq		#' ',d1
	moveq		#8-1,d2
.pad_8_loop:
	move.b		(a0)+,(a1)+
	bne.s		.next_char
	subq		#1,a0
	move.b		d1,-1(a1)
.next_char:
	dbra		d2,.pad_8_loop
	move.l		#.AVSERVER_name_s,addrin
	sub_aes		#appl_find
	move		intout,VA_partner_id
	bpl.s		.done
.not_env_partner:
	move.l		#.pad8_THING_s,addrin		;check for app named "THING  "
	sub_aes		#appl_find
	move		intout,VA_partner_id
	bpl.s		.done
	move.l		#.pad8_GEMINI_s,addrin		;check for app named "GEMINI  "
	sub_aes		#appl_find
	move		intout,VA_partner_id
.done:
	movem.l		(sp)+,d1-d2/a0-a2
	move		VA_partner_id,d0		;d0 = app_id of VA partner or -1  (flagged)
	rts
;
.pad8_THING_s:
	dc.b		'THING   ',NUL
.pad8_GEMINI_s:
	dc.b		'GEMINI  ',NUL
.pad8_AVSERVER_s:
	dc.b		'AVSERVER',NUL
.AVSERVER_eq_s:
	dc.b		'AVSERVER=',NUL
.AVSERVER_name_s:
	ds.b		9
	even
.AVSERVER_name_p:
	dc.l		0
	ENDM	;VA_set_partner_code
;------------------------------------
VA_send	MACRO	VA_msg,arg1,arg2,arg3,arg4,arg5
	_uniref		VA_send
__VA_flag		=	__VA_\1
	IFC		'','\1'	;VA_msg
	FAIL		VA_send used without any message code
	MEXIT
	ENDC
	IFNC		'','\6'	;arg5
	FAIL		VA_send used with more than 5 arguments
	FAIL		acceptable args = '\1,\2,\3,\4,\5'
	FAIL		incorrect arg = '\6'
	ENDC
	jsr		VA_preclear
	move		#(VA_\1)&$FFFF,VA_message
	IFNC		'','\2'	;arg1
	__VA_arg.\0	0,\2	;arg1
	IFNC		'','\3'	;arg2
	__VA_arg.\0	1,\3	;arg2
	IFNC		'','\4'	;arg3
	__VA_arg.\0	2,\4	;arg3
	IFNC		'','\5'	;arg4
	__VA_arg.\0	3,\5	;arg4
	ENDC		;arg4
	ENDC		;arg3
	ENDC		;arg2
	ENDC		;arg1
	jsr		VA_send_code
	ENDM	;VA_send
;------------------------------------
VA_send_code	MACRO
	movem.l		d1-d2/a0-a2,-(sp)
	move		VA_partner_id(pc),d0
	bpl.s		.send_it_1
	VA_set_partner	-1.w
	bmi.s		.error
.send_it_1:
	move		VA_sender_id(pc),d0
	bpl.s		.send_it_2
	move		global+4,VA_sender_id
.send_it_2:
	lea		VA_message(pc),a0
	clr		4(a0)
	move		VA_sender_id(pc),2(a0)
	gem_aes		appl_write,VA_partner_id,#16,VA_message(pc)
	moveq		#E_ACCDN,d0
	tst		intout
	beq.s		.exit
	clr.l		d0
.exit:
	movem.l		(sp)+,d1-d2/a0-a2
	tst		d0
	rts
;
.error:
	moveq		#E_INVFN,d0
	bra.s		.exit
;
VA_preclear:
	clr.l		VA_message
	clr.l		VA_message+4
	clr.l		VA_message+8
	clr.l		VA_message+12
	rts
;
VA_message:
	ds.w		8
VA_sender_id:
	dc.w		-1
VA_partner_id:
	dc.w		-1
	ENDM	;VA_send_code
;------------------------------------
__AV_arg	MACRO	argnum,argval
__AV_type		set	(__AV_flag>>(8*\1+4))&3
__AV_pos		set	((__AV_flag>>(8*\1))&7)*2
	IFNE		(__AV_type=0)
	move		\2,AV_message+__AV_pos
	MEXIT
	ENDC		;type=0
	IFNE		(__AV_type=1)
	move.l		\2,AV_message+__AV_pos
	MEXIT
	ENDC		;type=1
	IFNE		(__AV_type=2)
	IFC		'\0','i'
	move.l		\2,AV_message+__AV_pos
	ELSEIF
	pea		\2
	move.l		(sp)+,AV_message+__AV_pos
	ENDC		;mode
	ENDC		;type=2
	ENDM	;__AV_arg
;------------------------------------
__VA_arg	MACRO	argnum,argval
__VA_type		set	(__VA_flag>>(8*\1+4))&3
__VA_pos		set	((__VA_flag>>(8*\1))&7)*2
	IFNE		(__VA_type=0)
	move		\2,VA_message+__VA_pos
	MEXIT
	ENDC		;type=0
	IFNE		(__VA_type=1)
	move.l		\2,VA_message+__VA_pos
	MEXIT
	ENDC		;type=1
	IFNE		(__VA_type=2)
	IFC		'\0','i'
	move.l		\2,VA_message+__VA_pos
	ELSEIF
	pea		\2
	move.l		(sp)+,VA_message+__VA_pos
	ENDC		;mode
	ENDC		;type=2
	ENDM	;__VA_arg
;------------------------------------
MP_set_partner	MACRO	name
	_uniref		MP_set_partner
	PUREC_func.\0	MP_set_partner,1,3,\1
	ENDM	;MP_set_partner
;------------------------------------
MP_set_partner_code	MACRO
	movem.l		d1-d2/a0-a2,-(sp)
	move		global+4,MP_sender_id
	move.l		a0,addrin
	bmi.s		.seek_partner
	sub_aes		#appl_find
	move		intout,MP_partner_id
	bra		.done
;
.seek_partner:
	move.l		#.pad8_MPSERVER_s,addrin	;check for app named "MPSERVER"
	sub_aes		#appl_find
	move		intout,MP_partner_id
	bpl		.done
	move.l		#.MPSERVER_eq_s,addrin+4	;check environment for 'MPSERVER='
	move.l		#.MPSERVER_name_p,addrin
	sub_aes		#shel_envrn
	move		#-1,MP_partner_id
	tst		intout
	beq.s		.not_env_partner
	lea		.MPSERVER_name_s,a1
	move.l		.MPSERVER_name_p,a0
	moveq		#' ',d1
	moveq		#8-1,d2
.pad_8_loop:
	move.b		(a0)+,(a1)+
	bne.s		.next_char
	subq		#1,a0
	move.b		d1,-1(a1)
.next_char:
	dbra		d2,.pad_8_loop
	move.l		#.MPSERVER_name_s,addrin
	sub_aes		#appl_find
	move		intout,MP_partner_id
	bpl.s		.done
.not_env_partner:
	move.l		#.pad8_PAULA_s,addrin		;check for app named "PAULA   "
	sub_aes		#appl_find
	move		intout,MP_partner_id
.done:
	movem.l		(sp)+,d1-d2/a0-a2
	move		MP_partner_id,d0		;d0 = app_id of MP partner or -1  (flagged)
	rts
;
.pad8_PAULA_s:
	dc.b		'PAULA   ',NUL
.pad8_MPSERVER_s:
	dc.b		'MPSERVER',NUL
.MPSERVER_eq_s:
	dc.b		'MPSERVER=',NUL
.MPSERVER_name_s:
	ds.b		9
	even
.MPSERVER_name_p:
	dc.l		0
	ENDM	;MP_set_partner_code
;------------------------------------
MP_send	MACRO	MP_msg,arg1,arg2,arg3,arg4,arg5
	_uniref		MP_send
__MP_flag		=	__MP_\1
	IFC		'','\1'	;MP_msg
	FAIL		MP_send used without any message code
	MEXIT
	ENDC
	IFNC		'','\6'	;arg5
	FAIL		MP_send used with more than 5 arguments
	FAIL		acceptable args = '\1,\2,\3,\4,\5'
	FAIL		incorrect arg = '\6'
	ENDC
	jsr		MP_preclear
	move		#(MP_\1)&$FFFF,MP_message
	IFNC		'','\2'	;arg1
	__MP_arg.\0	0,\2	;arg1
	IFNC		'','\3'	;arg2
	__MP_arg.\0	1,\3	;arg2
	IFNC		'','\4'	;arg3
	__MP_arg.\0	2,\4	;arg3
	IFNC		'','\5'	;arg4
	__MP_arg.\0	3,\5	;arg4
	ENDC		;arg4
	ENDC		;arg3
	ENDC		;arg2
	ENDC		;arg1
	jsr		MP_send_code
	ENDM	;MP_send
;------------------------------------
MP_send_code	MACRO
	movem.l		d1-d2/a0-a2,-(sp)
	move		MP_partner_id(pc),d0
	bpl.s		.send_it_1
	MP_set_partner	-1.w
	bmi.s		.error
.send_it_1:
	move		MP_sender_id(pc),d0
	bpl.s		.send_it_2
	move		global+4,MP_sender_id
.send_it_2:
	lea		MP_message(pc),a0
	clr		4(a0)
	move		MP_sender_id(pc),2(a0)
	gem_aes		appl_write,MP_partner_id,#16,MP_message(pc)
	moveq		#E_ACCDN,d0
	tst		intout
	beq.s		.exit
	clr.l		d0
.exit:
	movem.l		(sp)+,d1-d2/a0-a2
	tst		d0
	rts
;
.error:
	moveq		#E_INVFN,d0
	bra.s		.exit
;
MP_preclear:
	clr.l		MP_message
	clr.l		MP_message+4
	clr.l		MP_message+8
	clr		MP_message+12
	move		#$0204,message+14
	rts
;
MP_message:
	ds.w		8
MP_sender_id:
	dc.w		-1
MP_partner_id:
	dc.w		-1
	ENDM	;MP_send_code
;------------------------------------
__MP_arg	MACRO	argnum,argval
__MP_type		set	(__MP_flag>>(8*argnum+4)) & 3
__MP_pos		set	((__MP_flag>>(8*argnum)) & 7)*2
	IFNE		(__MP_type=0)
	move		argval,MP_message+__MP_pos
	MEXIT
	ENDC		;type=0
	IFNE		(__MP_type=1)
	move.l		argval,MP_message+__MP_pos
	MEXIT
	ENDC		;type=1
	IFNE		(__MP_type=2)
	IFNE		'\0'='i'
	move.l		argval,MP_message+__MP_pos
	ELSEIF
	pea		argval
	move.l		(sp)+,MP_message+__MP_pos
	ENDC		;mode
	ENDC		;type=2
	ENDM	;__MP_arg
;----------------------------------------------------------------------------
;End of:	Macro definitions
;----------------------------------------------------------------------------
	endc	;RA_AV_defined
;----------------------------------------------------------------------------
;End of file:	RA_AV.I
;----------------------------------------------------------------------------
