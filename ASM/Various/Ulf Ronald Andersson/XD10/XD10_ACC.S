;----------------------------------------------------------------------------
; File name:	XD10_ACC.S		Revision date:	1996.03.04
; Created by:	URAn of Munin		Creation date:	1991.07.01
; (c)1991 by:	Ulf Ronald Andersson	All rights reserved
; Released as:	FREEWARE		NB: commercial sales forbidden
; Version:	1.3
; File purpose:	Source for program (ACC/PRG/TOS) XD10
; Prog purpose: Control floppy clock and step rates
;----------------------------------------------------------------------------
	include	URAn_APP.S
	include	URAn_SIM.S
	include	URAn_XB.S
;----------------------------------------------------------------------------
	section	data
	_uniref	aes_data
	_uniref	vdi_data
	make	SIM_links
;----------------------------------------------------------------------------
	section	text
;----------------------------------------------------------------------------
init_app:
	rts
;
	XB_define	dummy_XB,'XD10'
exec_app:
	XB_check	dummy_XB(pc),(hdv_bpb).w
	bmi	XD_absent
	clr	XD_select-rz(a6)
	move	#3,XD_rate-rz(a6)
	move.b	#'N',s_logic-rz(a6)
.logic_lp1:
	lea	s_posi(pc),a0
	cmp.b	#'N',s_logic-rz(a6)
	beq.s	.logic_set
	lea	s_nega(pc),a0
.logic_set:
	lea	s_logic(pc),a1
.logic_lp2:
	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	.logic_lp2		;loop back for entire string
	cmp.b	#'N',s_logic-rz(a6)
	seq	d0
	and	#1,d0
	move	d0,XD_logic-rz(a6)
	sim_aes	form_alert,#1,want_XD_alert(pc)
	move	intout(pc),want_XD_flg-rz(a6)
	cmpi	#2,want_XD_flg-rz(a6)
	blo.s	send_XD_cmd
	bhi.s	.logic_lp1		;loop back to reprocess same alert
	sim_aes	form_alert,#1,choose_XD_alert(pc)
	move	intout(pc),XD_select-rz(a6)
	sim_aes	form_alert,#2,choose_XD_rate(pc)
	mulu	#3,d0
	move	d0,XD_rate-rz(a6)
	cmp	#9,d0
	blo.s	store_rate
	addq	#3,d0
store_rate:
	move	d0,XD_rate-rz(a6)
send_XD_cmd:
	bsr	control_send
	clr	XD_logic-rz(a6)
	move	#8,XD_select-rz(a6)
	sim_aes	form_alert,#1,want_defrate(pc)
	move	#3,XD_rate-rz(a6)
	cmp	#2,d0
	blo.s	control_exit
	beq.s	send_DEF_cmd
	sim_aes	form_alert,#1,make_defrate(pc)
	move	#2,XD_rate-rz(a6)
	subq	#1,d0
	beq.s	send_DEF_cmd
	mulu	#6,d0
	move	d0,XD_rate-rz(a6)
send_DEF_cmd:
	bsr.s	control_send
control_exit:
	rts
;
XD_absent:
	sim_aes	form_alert,#1,XD_absent_alert(pc)
	rts
;
;
control_send:
	XB_check	dummy_XB,(hdv_bpb).w
	bmi.s	XD_absent
	move.l	d0,XD_link-rz(a6)
	gemdos	Super,!
	move.l	d0,-(sp)
	move	XD_logic(pc),d0
	asl	#2,d0
	or	XD_select(pc),d0
	mulu	#100,d0
	add	XD_rate,d0
	move.l	XD_link(pc),a0
	move.l	(a0),a0
	move.l	-16(a0),a0
	move	d0,-(sp)
	jsr	(a0)
	addq	#2,sp
	gemdos	Super,()
	rts
;
;
;----------------------------------------------------------------------------
;
	make	SIM_links
;
;----------------------------------------------------------------------------
;
	section	data
;
;
want_XD_alert:
	dc.b	'[2]'
	dc.b	'[  XD10  Version 1.3'
	dc.b	'| --------------------------  '
	dc.b	'|  Shall any drive now use'
	dc.b	'|  extra Density (10 MHz) ?'
	dc.b	'|  (PSG A6 '
s_logic:
	dc.b	           'Positive logic)]'
	dc.b	'[No|Yes|New Logic]',NUL
s_posi:	dc.b	'Posi',NUL
s_nega:	dc.b	'Nega',NUL
choose_XD_alert:
	dc.b	'[1]'
	dc.b	'[  eXtra Density interface.'
	dc.b	'| --------------------------  '
	dc.b	'| Please click the  button,'
	dc.b	'| showing the  drive/drives'
	dc.b	'| you want to use with XD10.]'
	dc.b	'[ Drive A |Drive B|Both]',NUL
choose_XD_rate:
	dc.b	'[1]'
	dc.b	'[  By: Ulf Ronald Andersson'
	dc.b	'| --------------------------  '
	dc.b	'| Please click the  button,'
	dc.b	'| showing the step rate you'
	dc.b	'| need for the  XD  drives.]'
	dc.b	'[  2.4 ms |4.8ms|9.6ms]',NUL
want_defrate:
	dc.b	'[2]'
	dc.b	'[  XD10 runs as ACC/PRG/TOS'
	dc.b	'| --------------------------  '
	dc.b	'| Do you wish to change the'
	dc.b	'| step rate  for the drives'
	dc.b	'| that use normal density ?]'
	dc.b	'[Exit|3 ms|  Other  ]',NUL
make_defrate:
	dc.b	'[1]'
	dc.b	'[   ½1993  U. R. Andersson'
	dc.b	'| --------------------------  '
	dc.b	'| Please click the  button,'
	dc.b	'| showing the step rate you'
	dc.b	'| need for  normal  drives.]'
	dc.b	'[2 ms|6 ms|  12 ms  ]',NUL
XD_absent_alert:
	dc.b	'[3]'
	dc.b	'[ System lacks  XD10 in the '
	dc.b	'| XBRA chains. You have not'
	dc.b	'| booted  XD10_nnn.PRG,  or'
	dc.b	'| some obsolete program has'
	dc.b	'| ruined the  XBRA chains !]'
	dc.b	'[Exit]',NUL
;
;
acc_name:
	dc.b	'  Select XD 10 MHz ',NUL
;
;----------------------------------------------------------------------------
;
	section	bss
;
XD_link:	ds.l	1	;(->xx->XD10_hdv_bpb)-16 -> XD10_cmdsub
want_XD_flg:	ds.b	2
XD_logic:	ds.b	2
XD_select:	ds.b	2
XD_rate:	ds.b	2
;
message:	ds.b	16
intin:		ds.w	30
ptsin:		ds.w	30
intout:		ds.w	45
ptsout:		ds.w	12
		ds.l	100
mystack:	ds.l	1
;
bss_end:
;----------------------------------------------------------------------------
	end	;of file:	XD10_ACC.S
