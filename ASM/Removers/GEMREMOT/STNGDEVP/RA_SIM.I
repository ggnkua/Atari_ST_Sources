;----------------------------------------------------------------------------
;File name:	RA_SIM.I			Revision date:	1998.09.08
;Creator:	Ulf Ronald Andersson		Creation date:	1992.11.30
;Released as:	FREEWARE			Commercial sales forbidden !
;----------------------------------------------------------------------------
;Purpose:	Macro library for GEM function simulation in TOS programs
;		by use of VT52 escape sequences for simple display of the
;		dialog boxes.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_SIM_defined
RA_SIM_defined	set	1
;----------------------------------------------------------------------------
;	Library macros:
;sim_aes	func,arg,arg,arg...
;
;NB:	Use "make SIM_links" to include all referred code.
;	This replaces "make GEM_links" normally used with RA_GEM.I .
;	At present only the following functions are simulated:
;	evnt_keybd
;	form_alert
;----------------------------------------------------------------------------
;Remarks:
;
;Required variables:
;
;tos_flag	.W $ffff for TOS program, otherwise application id
;
;NB:	This can be defined by including RA_APP.I
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_GEM.I
;----------------------------------------------------------------------------
SIM_links	macro
		_unidef	sim_aes,sim_evnt_keybd,sim_form_alert
		GEM_links
		endm	;SIM_links
;------------------------------------
sim_aes	macro	op,v1,v2,v3,v4,v5,v6,v7,v8,v9,va
	_uniref	sub_aes
	_uniref	sim_aes
	_uniref	sim_\1
	__inaes	\1,\2,\3,\4,\5,\6,\7,\8,\9,\a,\b
	pea	sim_\1_code
	move.l	#\1,d0
	bsr	sim_aes_code
	endm	;sim_aes
;------------------------------------
sim_aes_code	macro
		movem.l	(sp)+,d1/a0
		move.l	d1,-(sp)
		tst	tos_flag
		bpl	sub_aes_code
		jsr	(a0)
		move.l	intout,d0
		swap	d0
		move.l	addrout,d1
		rts
		endm	;sim_aes_code
;------------------------------------
sim_evnt_keybd_code	macro
	gemdos	Crawcin
	lsl	#8,d0
	lsr.l	#8,d0
	move	d0,intout
	rts
	endm	;sim_evnt_keybd_code
;------------------------------------
sim_form_alert_code	macro
	movem.l	d2-d5/a1/a3,-(sp)
	clr	d3
	gemdos	Cconws,.begform_s(pc)
	move.l	addrin,a3
	move.b	(a3)+,d0
	beq	.done_disp
	move.b	(a3)+,d0
	beq	.done_disp
	ext	d0
	sub	#'0',d0
	cmp	#3,d0
	bhi.s	.no_head
	add	d0,d0
	add	d0,d0
	move.l	.hs_tb(pc,d0),d0
	move	#'  ',d1
	lea	.textbuff,a0
	move	d1,(a0)+
	move.l	d0,(a0)+
	move	d1,(a0)+
	bra.s	.loop_1
;
.hs_tb:
.hs0_s:	dc.l	'    '
.hs1_s:	dc.l	'!!!!'
.hs2_s:	dc.l	'????'
.hs3_s:	dc.l	'STOP'
;
.loop_1:
	move.b	(a3)+,d0
	beq.s	.done_disp
.no_head:
	cmp.b	#'[',d0
	bne.s	.loop_1
.loop_2:
	st	d4
	lea	.textbuff+8(pc),a0
	moveq	#30-1,d5
.loop_3:
	move.b	(a3)+,d0
	move.b	d0,(a0)+
	beq.s	.end_lines
	cmp.b	#']',d0
	beq.s	.end_lines
	cmp.b	#'|',d0
	dbeq	d5,.loop_3
	beq.s	.end_lines
	clr	d4
.end_lines:
	clr.b	-1(a0)
	bsr	.disptext
	subq	#1,a3
	tst	d4
	beq.s	.loop_2
	move.b	(a3)+,d0
	beq.s	.done_disp
	cmp.b	#']',d0
	bne.s	.loop_2
.loop_4:
	move.b	(a3)+,d0
	beq.s	.done_disp
	cmp.b	#'[',d0
	bne.s	.loop_4
	addq	#1,a3
.done_disp:
	subq	#1,a3
	bsr	.crlf_sub
	lea	.textbuff+2(pc),a0
.loop_5:
	addq	#1,d3
	move	d3,d4
	add	#'0',d4
	move.b	d4,(a0)+
	move.b	#'<',d4
	cmp	intin,d3
	bne.s	.non_def_1
	move.b	#'[',d4
.non_def_1:
	move.b	d4,(a0)+
	moveq	#10-1,d5
.loop_6:
	move.b	(a3)+,d0
	move.b	d0,(a0)+
	beq.s	.end_butts
	cmp.b	#']',d0
	beq.s	.end_butts
	cmp.b	#'|',d0
	dbeq	d5,.loop_6
	beq.s	.end_butts
.loop_7:
	move.b	(a3)+,d0
	beq.s	.end_butts
	cmp.b	#']',d0
	beq.s	.end_butts
	cmp.b	#'|',d0
	bne.s	.loop_7
.end_butts:
	addq.b	#2,d4
	move.b	d4,-1(a0)
	move.b	#' ',(a0)+
	cmp	#3,d3
	bhs.s	.done_butts
	subq	#1,a3
	move.b	(a3)+,d0
	beq.s	.done_butts
	cmp.b	#']',d0
	bne.s	.loop_5
.done_butts:
	clr.b	-1(a0)
	bsr	.disptext
	gemdos	Cconws,.endform_s(pc)
.wait_key:
	gemdos	Crawcin
	ext	d0
	cmp	#CR,d0
	bne.s	.non_def_2
	move	intin,d0
	bne.s	.done_keys
.non_def_2:
	sub	#'0',d0
	ble.s	.wait_key
	cmp	d3,d0
	bhi.s	.wait_key
.done_keys:
	move	d0,intout
	movem.l	(sp)+,d2-d5/a1/a3
	rts
;
.disptext:
	gemdos	Cconws,.textbuff(pc)
.crlf_sub:
	gemdos	Cconws,.crlf_s(pc)
	move.l	.hs0_s(pc),.textbuff+2
	rts
;
.textbuff:	dc.b	'  !!!!  '
		ds.b	40
.begform_s:	dc.b	ESC,'E',LF,LF,LF,ESC,'j',NUL
.endform_s:	dc.b	ESC,'k',NUL
.crlf_s:	dc.b	CR,LF,NUL
;
	even
;
	endm	;sim_form_alert_code
;----------------------------------------------------------------------------
	endc	;RA_SIM_defined
;----------------------------------------------------------------------------
;End of file:	RA_SIM.I
;----------------------------------------------------------------------------
