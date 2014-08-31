;----------------------------------------------------------------------------
;File name:	SHOW_ENV.S			Revision date:	1995.10.06
;Creator:	Ulf Ronald Andersson		Creation date:	1992.10.03
;(c)1993 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
	output	.PRG
;
;----------------------------------------------------------------------------
;
	include	URAn_APP.S
	include	URAn_SIM.S
	include	URAn_ENV.S
	include	URAn_BPP.S
;
;----------------------------------------------------------------------------
;
	SECTION	text
;
init_app:
	include	URAn_ARG.S
	rts
;
;----------------------------------------------------------------------------
;
exec_app:
	tst	d7
	bmi.s	.exec_tos_prg
	tst.l	d7
	bmi.s	.exec_gem_acc
	nop
.exec_gem_acc:
.exec_gem_prg:
.exec_tos_prg:
	move.l	basepage_p(pc),a0	;a0 -> own basepage
	move.l	bp_environ_p(a0),a1	;a1 -> own environment
	move.l	a1,cur_env_p
.get_parent_1
	move.l	bp_parent_p(a0),a1	;a1 -> parents basepage
	cmp.l	a0,a1
	beq.s	.get_parent_2
	move.l	a1,d0
	bgt.s	.parent_ok
.get_parent_2:
	get_os_bp_p_p			;d0 -> -> running basepage
	move.l	d0,a1			;a1 -> -> running basepage
	move.l	(a1),a1			;a1 -> running basepage
	cmp.l	a0,a1
	beq.s	.parent_ok
	move.l	a1,d0
	bgt.s	.parent_2_ok
	move.l	a0,a1
.parent_2_ok:
	move.l	a1,a0
.parent_ok:
	move.l	bp_environ_p(a1),a1	;a1 -> parent environment
	move.l	a1,par_env_p
	old_env_base
	move.l	d0,a0			;a0 -> basepage of old environment
	lea	bp_environ_p(a0),a1	;a1 -> env ptr in parents basepage
	move.l	a1,old_env_p_p		;store -> -> old environment
	move.l	(a1),a1			;a1 -> old environment
	move.l	a1,old_env_p		;store -> old environment
;
.what_env_q_loop:
	sim_aes	form_alert,#2,what_env_q_al_s(pc)
	subq	#1,d0
	and	#3,d0
	asl	#2,d0
	lea	show_env_p_t(pc),a0
	move.l	(a0,d0),a0		;a0 -> environment to show
	move.l	a0,show_env_p
	move.l	a0,string_p
	clr.l	string_num
;
.show_env_loop:
	lea	string_num_s(pc),a0
	move.l	string_num(pc),d0
	moveq	#4,d1
	moveq	#' ',d2
	bsr	convert
;
	move.l	string_p(pc),a1		;a1 -> string in environment
	lea	env_string_s(pc),a0	;a0 -> string in alert
	clr	d3			;d3 = progress flag
	moveq	#3-1,d2			;d2 = line counter
.string_lp_1:
	moveq	#29-1,d1		;d1 = char counter for 29 visible
.string_lp_2:
	moveq	#'"',d0			;pad a "quote" at start
	tst	d3
	bmi.s	.fill_it		;go pad spaces after end
	beq.s	.beg_pad		;go pad starting quote
	move.b	(a1)+,d0		;d0 = char from environment string
	beq.s	.end_pad		;go pad ending quote
	cmp.b	#' ',d0
	bhi.s	.pad_it			;go pad non-NUL character
	moveq	#'.',d0			;pad ctrl-char to '.'
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
	moveq	#'"',d0			;pad a "quote" at end
.pad_it:
	move.b	d0,(a0)+		;store alert character at (a0)+
	dbra	d1,.string_lp_2
	addq	#1,a0			;step a0 past space & newline
	dbra	d2,.string_lp_1
;
	tst	d3			;did we pass string end ?
	bmi.s	.keep_next		;if so, go store the pointer
.pass_it:
	tst.b	(a1)+
	bne.s	.pass_it
.keep_next:
	move.l	a1,string_p		;store -> next string
	addq.l	#1,string_num		;increment to next string number
	sim_aes	form_alert,#2,show_env_al_s(pc)
	cmp	#2,d0
	bhi	.what_env_q_loop
	beq	.show_env_loop
.exit:
	clr.l	d0			;normal rv = no error
	rts
;
;----------------------------------------------------------------------------
;	convert(ULONG number,int digits,char pad_char,char *dest_p)
;
;Entry:	a0 -> destination
;  "	d0 =  number to convert
;  "	d1 =  max number of digits allowed
;  "	d2 =  pad character
;
convert:
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
;
;----------------------------------------------------------------------------
;
	make	SIM_links
	make	ENV_links
	make	BPP_links
;
;----------------------------------------------------------------------------
;
	SECTION	data
;
;----------------------------------------------------------------------------
;
what_env_q_al_s:
	dc.b	'[2]['
	dc.b	'_________ SHOW_ENV __________|'
	dc.b	'Please  choose  which  of the|'
	dc.b	'available  environments  you |'
	dc.b	'wish  SHOW_ENV  to  display. |'
	dc.b	'-----------------------------]'
	dc.b	'[ Current | Parents | Systems ]'
	dc.b	NUL
	even
;
show_env_al_s:
	dc.b	'[1]['
	dc.b	'_________ SHOW_ENV __________|'
	dc.b	'Environment  string  #'
string_num_s:
	dc.b			      '0000:  |'
env_string_s:
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             ]'
	dc.b	'[  Exit  |  Next  |  Back  ]'
	dc.b	NUL
	even
;
acc_name:
	dc.b	'  Show Environment',NUL
	even
;
;----------------------------------------------------------------------------
;
	SECTION	bss
;
;----------------------------------------------------------------------------
;
show_env_p_t:	;table of environment pointers
cur_env_p:	ds.l	1	;-> current environment
par_env_p:	ds.l	1	;-> parents environment
old_env_p:	ds.l	1	;-> oldest environment
show_env_p:	ds.l	1	;-> environment to be shown
;
string_p:	ds.l	1	;current string pointer
string_num:	ds.l	1	;current string number
;
old_env_p_p:	ds.l	1	;-> environment ptr in parents basepage
;
intin:		ds.w	30
intout:		ds.w	45
ptsin:		ds.w	30
ptsout:		ds.w	12
message:	ds.b	16
		ds.l	$100
mystack:	ds.l	4
;
;----------------------------------------------------------------------------
;End of file:	SHOW_ENV.S
;----------------------------------------------------------------------------
