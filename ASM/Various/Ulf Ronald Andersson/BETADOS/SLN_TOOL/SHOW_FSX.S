;----------------------------------------------------------------------------
;File name:	SHOW_FSX.S			Revision date:	1998.05.07
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
	IFEQ	huge_program
	SECTION	DATA
	ENDC
;
;Edit the string below, to match the accessory title you want in ACC mode
;
acc_name:
	dc.b	'  Show_FSX',NUL	;for ACC menu registration
	dc.b	NUL
	even
;
;Also edit the string below, to match the application name, without
;file extension, padded to 8 bytes.  Normally this will be overwritten
;by runtime info from 'shel_read' during init, but do it just in case...
;
id_app_name_s:
	dc.b	'SHOW_FSX',NUL
	even
;----------------------------------------------------------------------------
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
	gemdos		Pdomain,#-1
	move		d0,entry_Pdomain
	gemdos		Pdomain,#1
	move		#$3F,Fsfirst_attr
.restart_loop:
	bsr		choose_Fsfirst_attr
.what_fs_q_loop:
	sim_aes	form_alert,#2,what_fs_q_al_s(pc)
	move.l	kbshift_p(pc),a0
	move.b	(a0),d1
	move.b	d1,kbshifts
	btst	#3,d1
	bne	.exit_show_fs
	subq	#2,d0
	beq.s	.show_fs_new
	btst	#2,d1
	beq.s	.dont_quad
	asl	#2,d0
.dont_quad:
	btst	#1,d1
	beq.s	.dont_doub
	asl	#1,d0
.dont_doub:
	move.b	fs_drive_char(pc),d1
	add.b	d1,d0
	cmp.b	#'A',d0
	bhs.s	.done_lo_test
	moveq	#'Z',d0
.done_lo_test:
	cmp.b	#'Z',d0
	bls.s	.done_hi_test
	moveq	#'A',d0
.done_hi_test:
	move.b	d0,fs_drive_char
	bra.s	.what_fs_q_loop
;
.show_fs_new:
	lea	fs_main_path(pc),a0
	move.b	fs_drive_char(pc),(a0)+
	move.b	#':',(a0)+
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	clr	dta_index
.show_fs_first:
	move	dta_index(pc),d0
	and	#$0F,d0
	mulu	#dta_size,d0
	lea	dta_arr(pc),a0
	lea	(a0,d0),a0
	move.l	a0,dta_p
	lea	dta_fname(a0),a1
	move.l	a1,string_p
	btst	#2,kbshifts
	beq.s	.done_break_1
	btst	#1,kbshifts
	beq.s	.done_break_1
	bsr	choose_Fsfirst_attr
.done_break_1:
	btst	#0,kbshifts
	beq.s	.do_fsfirst
.do_get_path:
	move.b	fs_main_path(pc),d0
	and	#$DF,d0
	sub	#'A'-1,d0
	gemdos	Dgetpath,inspect_path(pc),d0
	lea	inspect_path(pc),a0
	move.l	a0,string_p
	clr.l	string_num
	bra.s	.show_fs_have_data
;
.do_fsfirst:
	gemdos	Fsetdta|_ind,dta_p(pc)
	gemdos	Fsfirst,fs_main_path(pc),Fsfirst_attr(pc)
	move.l	d0,fs_status
	bpl.s	.fsfirst_ok
	move.l	dta_p(pc),a0
	clr.b	dta_fname(a0)
.fsfirst_ok:
	move.l	dta_p(pc),a0
	lea	dta_fname(a0),a1
	move.l	a1,string_p
	clr.l	string_num
	bra.s	.show_fs_have_data
;
.show_fs_next:
	btst	#2,kbshifts
	beq.s	.done_break_2
	btst	#1,kbshifts
	beq.s	.done_break_2
;;;	bsr	choose_Fsfirst_attr
.done_break_2:
	gemdos	Fsnext
	move.l	d0,fs_status
	bpl.s	.fsnext_ok
	move.l	dta_p(pc),a0
	clr.b	dta_fname(a0)
.fsnext_ok:
	move.l	dta_p(pc),a0
	lea	dta_fname(a0),a1
	move.l	a1,string_p
.show_fs_have_data:
	move.l	dta_p(pc),a0
	move.b	dta_fattr(a0),fs_attr
	lea	attr_num_s(pc),a0
	clr.l	d0
	move.b	fs_attr(pc),d0
	moveq	#2,d1
	moveq	#'0',d2
	bsr	conv2hexasc
;
	lea	status_num_s(pc),a0
	move.l	fs_status(pc),d0
	moveq	#4,d1
	moveq	#'0',d2
	bsr	conv2hexasc
;
	lea	string_num_s(pc),a0
	move.l	string_num(pc),d0
	moveq	#4,d1
	moveq	#' ',d2
	bsr	conv2decasc
;
	move.l	string_p(pc),a1		;a1 -> string in environment
	lea	dir_string_s(pc),a0	;a0 -> string in alert
	moveq	#2,d2			;d2 = line counter
	bsr	limit_lines
;
	addq.l	#1,string_num		;increment to next string number
;
	sim_aes	form_alert,#2,show_fs_al_s(pc)
;
	move.l	kbshift_p(pc),a0
	move.b	(a0),d1
	move.b	d1,kbshifts
	btst	#3,d1
	bne	.exit_show_fs		;Alt-click exits
	subq	#2,d0
	beq	.show_fs_next
	add	d0,dta_index
	blt	.restart_loop		;backing at top backs to entry dialog
	tst	d0
	bmi.s	.go_sup_dir
.go_sub_dir:
	move.l	dta_p(pc),a0
	btst	#4,dta_fattr(a0)	;directory ?
	beq	.restart_loop		;trying to enter nondir backs to entry dialog
	lea	dta_fname(a0),a1
	lea	fs_main_path+3(pc),a0
.go_sub_loop_1:
	cmp.b	#'*',(a0)+
	bne.s	.go_sub_loop_1
	subq	#1,a0
.go_sub_loop_2:
	move.b	(a1)+,(a0)+
	bne.s	.go_sub_loop_2
	subq	#1,a0
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	bra	.show_fs_first
;
.go_sup_dir:
	suba.l	a1,a1
	lea	fs_main_path(pc),a0
.go_sup_loop:
	move.b	(a0)+,d0
	beq.s	.know_sup
	cmp.b	#'\',d0
	bne.s	.go_sup_loop
	cmp.b	#'*',(a0)
	beq.s	.know_sup
	move.l	a0,a1
	bra.s	.go_sup_loop
;
.know_sup:
	move.l	a1,d0
	blt	.restart_loop		;backing at top backs to entry dialog
	move.b	#'*',(a1)+
	move.b	#'.',(a1)+
	move.b	#'*',(a1)+
	clr.b	(a1)
	bra	.show_fs_first
;
.exit_show_fs:
	gemdos	Pdomain,entry_Pdomain(pc)
	clr.l	d0			;normal rv = no error
	rts
;----------------------------------------------------------------------------
choose_Fsfirst_attr:
	lea	Fsfirst_attr_num_s(pc),a0
	clr.l	d0
	move	Fsfirst_attr(pc),d0
	moveq	#4,d1
	moveq	#'0',d2
	bsr	conv2hexasc
;
	sim_aes	form_alert,#2,Fsfirst_attr_al_s(pc)
;
	move.l	kbshift_p(pc),a0
	move.b	(a0),d1
	move.b	d1,kbshifts
	subq	#2,d0
	beq.s	.exit
	btst	#2,d1
	beq.s	.done_shift_8
	asl	#8,d0
.done_shift_8:
	btst	#1,d1
	beq.s	.done_shift_4
	asl	#4,d0
.done_shift_4:
	add	d0,Fsfirst_attr
	bra	choose_Fsfirst_attr
;
.exit:
	rts
;----------------------------------------------------------------------------
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
;----------------------------------------------------------------------------
	make	SIM_links
	make	AV_links
;----------------------------------------------------------------------------
text_limit:
	SECTION	DATA
;----------------------------------------------------------------------------
Fsfirst_attr_al_s:
	dc.b	'[2]['
	dc.b	'__________ SHOW_FS __________|'
	dc.b	'You may modify the attribute |'
	dc.b	'value used by Fsfirst/Fsnext.|'
	dc.b	'Shift and/or Control makes a |'
	dc.b	'click affect higher digits.  ]'
	dc.b	'[  Decr  | $'
Fsfirst_attr_num_s:
	dc.b	            '0000  |  Incr  ]'
	dc.b	NUL
	even
;
what_fs_q_al_s:
	dc.b	'[2]['
	dc.b	'__________ SHOW_FS __________|'
	dc.b	'Please  choose  which  of the|'
	dc.b	'available  file  systems  you|'
	dc.b	'wish  SHOW_FS  to  display.  |'
	dc.b	'(Alt-click to exit program.) ]'
	dc.b	'[  <---  |  '
fs_drive_char:
	dc.b	'U:\   |  --->  ]'
	dc.b	NUL
	even
;
show_fs_al_s:
	dc.b	'[1]['
	dc.b	'__________ SHOW_FS __________|'
	dc.b	'fattr = $'
attr_num_s:
	dc.b		 '00  status = $'
status_num_s:
	dc.b			       '0000  |'
	dc.b	'Dir entry string  #'
string_num_s:
	dc.b			   '0000:     |'
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
inspect_path:	ds.b	256
fs_main_path:	ds.b	256
dta_arr:	ds.b	16*dta_size
dta_index:	ds.w	1
dta_p:		ds.l	1
;
entry_Pdomain:	ds.w	1
;
string_p:	ds.l	1	;current string pointer
string_num:	ds.l	1	;current string number
fs_status:	ds.l	1
fs_attr:	ds.w	1
Fsfirst_attr:	ds.w	1
;
kbshifts:	ds.w	1
;----------------------------------------------------------------------------
bss_limit:
	END
;----------------------------------------------------------------------------
;End of file:	SHOW_FSX.S
;----------------------------------------------------------------------------
