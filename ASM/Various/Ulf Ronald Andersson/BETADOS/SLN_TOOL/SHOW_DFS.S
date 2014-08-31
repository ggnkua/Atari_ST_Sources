;----------------------------------------------------------------------------
;File name:	SHOW_DFS.S			Revision date:	1998.05.07
;Creator:	Ulf Ronald Andersson		Creation date:	1998.03.13
;(c)1998 by:	Ulf Ronald Andersson		All rights reserved
;----------------------------------------------------------------------------
	include	RA_ARG.I
	include	RA_APP.I
	include	RA_SIM.I
	include	RA_AV.I
;----------------------------------------------------------------------------
	output	.APP
;----------------------------------------------------------------------------
MAX_VA_ARGLEN	equ	512
;
;
;Add application dependent assemblytime constants/variables above
;----------------------------------------------------------------------------
;;;huge_program		set 1	;uncomment if TEXT+DATA sections are > 32KB
;;;keep_windows		set 1	;uncomment to keep ACC vwk in main eventloop
;;;exec_timeout		set 100	;uncomment to enable timer in main eventloop
;;;exec_message		set 1	;uncomment for messages in main eventloop
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	start_app
;----------------------------------------------------------------------------
;
	IFEQ	huge_program
	SECTION	DATA
	ENDC
;
;Edit the string below, to match the accessory title you want in ACC mode
;
acc_name:
	dc.b	'  Show_DFS',NUL	;for ACC menu registration
	dc.b	NUL
	even
;
;Also edit the string below, to match the application name, without
;file extension, padded to 8 bytes.  Normally this will be overwritten
;by runtime info from 'shel_read' during init, but do it just in case...
;
id_app_name_s:
	dc.b	'SHOW_DFS',NUL
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
		ds.b	4096
mystack:	ds.l	1		;top of subroutine stack
;
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
init_app:
	start_arg
	rts
;----------------------------------------------------------------------------
exec_app:
	tst	d7
	bmi.s	.exec_tos_prg
	tst.l	d7
	bmi.s	.exec_gem_acc
	nop
.exec_gem_acc:
.exec_gem_prg:
.exec_tos_prg:
	clr.l	dfs_handle
	gemdos		Pdomain,#-1
	move		d0,entry_Pdomain
	gemdos		Pdomain,#1
;
	tst	d7
	bmi	.done_shel_read			;skip shel_read for TOS/TTP
	gem_aes	shel_read,shr_path_s(pc),shr_tail_s(pc)
	lea	shr_path_s(pc),a1	;a1 -> string
	lea	shr_path_lim_s(pc),a0	;a0 -> string in alert
	moveq	#4,d2			;d2 = line counter
	bsr	limit_lines
	sim_aes	form_alert,#1,shr_path_al_s(pc)
	lea	shr_tail_s(pc),a1	;a1 -> string
	lea	shr_tail_lim_s(pc),a0	;a0 -> string in alert
	moveq	#4,d2			;d2 = line counter
	bsr	limit_lines
	sim_aes	form_alert,#1,shr_tail_al_s(pc)
.done_shel_read:
;
	gemdos	Dgetdrv
	lea	Init_drive_num_s(pc),a0
	moveq	#4,d1
	moveq	#'0',d2
	bsr	conv2hexasc
	gemdos	Dgetpath,Init_path_s(pc),#0
	lea	Init_path_s(pc),a1	;a1 -> string
	lea	Init_path_lim_s(pc),a0	;a0 -> string in alert
	moveq	#4,d2			;d2 = line counter
	bsr	limit_lines
	sim_aes	form_alert,#1,Init_path_al_s(pc)
;
.what_dfs_q_loop:
	tst.l	dfs_handle
	beq.s	.done_close_1
	gemdos	Dclosedir,dfs_handle(pc)
	clr.l	dfs_handle
.done_close_1:
	move.l	kbshift_p(pc),a0
	move.b	(a0),d0
	and	#$0F,d0
	cmp	#$0E,d0
	beq	.exit_show_dfs
	sim_aes	form_alert,#2,what_dfs_q_al_s(pc)
	move.l	kbshift_p(pc),a0
	move.b	(a0),d1
	move.b	d1,kbshifts
	btst	#3,d1
	bne	.exit_show_dfs
	subq	#2,d0
	beq.s	.show_dfs_new
	btst	#2,d1
	beq.s	.dont_quad
	asl	#2,d0
.dont_quad:
	btst	#1,d1
	beq.s	.dont_doub
	asl	#1,d0
.dont_doub:
	move.b	dfs_drive_char(pc),d1
	add.b	d1,d0
	cmp.b	#'A',d0
	bhs.s	.done_lo_test
	moveq	#'Z',d0
.done_lo_test:
	cmp.b	#'Z',d0
	bls.s	.done_hi_test
	moveq	#'A',d0
.done_hi_test:
	move.b	d0,dfs_drive_char
	bra	.what_dfs_q_loop
;
.show_dfs_new:
	tst.l	dfs_handle
	beq.s	.done_close_2
	gemdos	Dclosedir,dfs_handle(pc)
	clr.l	dfs_handle
.done_close_2:
	lea	dfs_main_path(pc),a0
	move.b	dfs_drive_char(pc),(a0)+
	move.b	#':',(a0)+
	move.b	#'\',(a0)+
	clr.b	(a0)
.show_dfs_first:
	lea	name_buf+4(pc),a1
	move.l	a1,string_p
	btst	#2,kbshifts
	beq.s	.done_break_1
	btst	#1,kbshifts
	beq.s	.done_break_1
	illegal
.done_break_1:
	btst	#0,kbshifts
	beq.s	.do_dfs_first
.do_get_path:
	moveq	#-1,d3
	lea	dfs_main_path(pc),a3
	lea	Dpathconf_t(pc),a4
.Dpathconf_lp_1:
	gemdos	Dpathconf,(a3),d3
	move.l	d0,(a4)+
	addq	#1,d3
	cmp	#8,d3
	bhi.s	.Dpathconf_bk_1
	cmp	Dpathconf_t+2(pc),d3
	bls	.Dpathconf_lp_1
.Dpathconf_bk_1:
	lea	Dpathconf_t(pc),a4
	lea	Dpathconf_spt(pc),a3
	moveq	#10-1,d3
.Dpathconf_lp_2:
	move.l	(a3)+,a0
	move.l	(a4)+,d0
	moveq	#8,d1
	moveq	#'0',d2
	bsr	conv2hexasc
	dbra	d3,.Dpathconf_lp_2
;
	move.l	kbshift_p(pc),a0
	move.b	(a0),d0
	and	#$0F,d0
	cmp	#$0E,d0
	beq	.exit_show_dfs
	sim_aes	form_alert,#1,Dpathconf_al_s(pc)
;
	bra	.what_dfs_q_loop
;
.do_dfs_first:
	gemdos	Dopendir,dfs_main_path(pc),#0
	move.l	d0,dfs_handle
	move.l	d0,dfs_status
	bmi.s	.dfs_first_done
.show_dfs_next:
	gemdos	Dxreaddir,#32,dfs_handle,name_buf,xattr_buf,xret
	move.l	d0,dfs_status
	bpl.s	.dfs_first_done
	clr.b	name_buf+4
.dfs_first_done:
	lea	name_buf+4(pc),a1
	move.l	a1,string_p
	clr.l	string_num
.show_dfs_have_data:
	lea	mode_num_s(pc),a0
	clr.l	d0
	move	xattr_buf+XATTR_mode(pc),d0
	moveq	#4,d1
	moveq	#'0',d2
	bsr	conv2hexasc
;
	lea	attr_num_s(pc),a0
	clr.l	d0
	move	xattr_buf+XATTR_attr(pc),d0
	moveq	#4,d1
	moveq	#'0',d2
	bsr	conv2hexasc
;
	lea	status_num_s(pc),a0
	move.l	dfs_status(pc),d0
	moveq	#8,d1
	moveq	#'0',d2
	bsr	conv2hexasc
;
	lea	index_num_s(pc),a0
	move.l	xattr_buf+XATTR_index(pc),d0
	moveq	#8,d1
	moveq	#' ',d2
	bsr	conv2hexasc
;
	move.l	string_p(pc),a1		;a1 -> string
	lea	dir_string_s(pc),a0	;a0 -> string in alert
	moveq	#2,d2			;d2 = line counter
	bsr	limit_lines
;
	addq.l	#1,string_num		;increment to next string number
;
	sim_aes	form_alert,#2,show_dfs_al_s(pc)
;
	move.l	kbshift_p(pc),a0
	move.b	(a0),d1
	move.b	d1,kbshifts
	btst	#3,d1
	bne	.what_dfs_q_loop		;Alt-click backs to entry dialog
	subq	#2,d0
	beq	.show_dfs_next
	blt	.what_dfs_q_loop		;backing at top backs to entry dialog
.go_sub_dir:
	move	xattr_buf+XATTR_mode(pc),d0
	and	#S_IFMT,d0
	cmp	#S_IFDIR,d0
	beq.s	.try_sub_dir
	cmp	#S_IFLNK,d0
	beq.s	.try_sub_dir
	beq	.what_dfs_q_loop		;trying to enter nondir backs to entry dialog
.try_sub_dir:
	lea	name_buf+4(pc),a1
	lea	dfs_main_path(pc),a0
.go_sub_loop_1:
	tst.b	(a0)+
	bne	.go_sub_loop_1
	subq	#1,a0
	cmp.b	#'\',-1(a0)
	beq.s	.done_slash
	move.b	#'\',(a0)+
.done_slash:
.go_sub_loop_2:
	move.b	(a1)+,(a0)+
	bne	.go_sub_loop_2
	bra	.show_dfs_first
;
.exit_show_dfs:
	tst.l	dfs_handle
	beq.s	.done_close_3
	gemdos	Dclosedir,dfs_handle(pc)
	clr.l	dfs_handle
.done_close_3:
	gemdos	Pdomain,entry_Pdomain(pc)
	clr.l	d0			;normal rv = no error
	rts
;
;----------------------------------------------------------------------------
;
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
;
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
;
;----------------------------------------------------------------------------
;
	make	SIM_links
	make	AV_links
;
;----------------------------------------------------------------------------
text_limit:
	SECTION	DATA
;----------------------------------------------------------------------------
what_dfs_q_al_s:
	dc.b	'[2]['
	dc.b	'__________ SHOW_DFS _________|'
	dc.b	'Please  choose  which  of the|'
	dc.b	'available  file  systems  you|'
	dc.b	'wish  SHOW_DFS  to  display. |'
	dc.b	'(Alt-click to exit program.) ]'
	dc.b	'[  <---  |  '
dfs_drive_char:
	dc.b	'U:\   |  --->  ]'
	dc.b	NUL
	even
;
Dpathconf_al_s:
		dc.b	'[1]['
		dc.b	'count='
dpal_sn:	dc.b	      '00000000 files='
dpal_s0:	dc.b	                     '00000000|'
		dc.b	'links='
dpal_s1:	dc.b	      '00000000 p_len='
dpal_s2:	dc.b	                     '00000000|'
		dc.b	'n_len='
dpal_s3:	dc.b	      '00000000 w_len='
dpal_s4:	dc.b	                     '00000000|'
		dc.b	'abbrv='
dpal_s5:	dc.b	      '00000000 cases='
dpal_s6:	dc.b	                     '00000000|'
		dc.b	'modes='
dpal_s7:	dc.b	      '00000000 xattr='
dpal_s8:	dc.b	                     '00000000]'
		dc.b	'[  Next  ]'
		dc.b	NUL
		even
;
Dpathconf_spt:
	dc.l	dpal_sn,dpal_s0,dpal_s1,dpal_s2,dpal_s3
	dc.l	dpal_s4,dpal_s5,dpal_s6,dpal_s7,dpal_s8
;
Dpathconf_t:
	ds.l	10
;
shr_path_al_s:
	dc.b	'[1]['
	dc.b	'shel_read path string:       |'
shr_path_lim_s:
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             ]'
	dc.b	'[  Ok  ]'
	dc.b	NUL
	even
;
shr_tail_al_s:
	dc.b	'[1]['
	dc.b	'shel_read tail string:       |'
shr_tail_lim_s:
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             ]'
	dc.b	'[  Ok  ]'
	dc.b	NUL
	even
;
Init_path_al_s:
	dc.b	'[1]['
	dc.b	'Initial path of drive $'
Init_drive_num_s:
	dc.b                           '0000: |'
Init_path_lim_s:
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             |'
	dc.b	'                             ]'
	dc.b	'[  Ok  ]'
	dc.b	NUL
	even
;
show_dfs_al_s:
	dc.b	'[1]['
	dc.b	'__________ SHOW_DFS _________|'
	dc.b	'mode=$'
mode_num_s:
	dc.b	      '0000  state=$'
status_num_s:
	dc.b			   '00000000  |'
	dc.b	'attr=$'
attr_num_s:
	dc.b	      '0000  index=$'
index_num_s:
	dc.b			   '00000000  |'
dir_string_s:
	dc.b	'                             |'
	dc.b	'                             ]'
	dc.b	'[  Back  |  Next  |  Down  ]'
	dc.b	NUL
	even
;----------------------------------------------------------------------------
data_limit:
	SECTION	BSS
;----------------------------------------------------------------------------
shr_path_s:	ds.b	256
shr_tail_s:	ds.b	256
Init_path_s:	ds.b	256
inspect_path:	ds.b	256
dfs_main_path:	ds.b	256
dfs_handle:	ds.l	1
name_buf:	ds.b	32
;
entry_Pdomain:	ds.w	1
;
xattr_buf:	ds.b	sizeof_XATTR
xret:		ds.l	1
;
string_p:	ds.l	1	;current string pointer
string_num:	ds.l	1	;current string number
dfs_status:	ds.l	1
dfs_attr:	ds.w	1
;
kbshifts:	ds.w	1
;----------------------------------------------------------------------------
bss_limit:
	END
;----------------------------------------------------------------------------
;End of file:	SHOW_DFS.S
;----------------------------------------------------------------------------
