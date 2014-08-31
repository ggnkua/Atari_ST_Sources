;----------------------------------------------------------------------------
;File name:	REP_FSTR.S		Revision date:	1995.08.16
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.24
;Version:	1.2
;(c)1995 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;
	output	.GTP
;
BUF_SIZE	= $4000
;
;----------------------------------------------------------------------------
;
start:
	include	URAn_APP.S
	include	URAn_SIM.S
;
;----------------------------------------------------------------------------
;
init_app:
	include	URAN_ARG.S
	rts
;
exec_app:
	move.l	arg_ptr(pc),a4	;a4 = arg_ptr
	move	arg_cnt(pc),d4	;d4 = arg_cnt
	cmp	#5,d4
	bne	arg_error_exit
;
	move	d4,d5
	subq	#1,d5			;prep for dbra
	clr	d3
	move.l	a4,a0
	lea	string_p_t(pc),a2
.loop_1:
	move.l	a0,(a2)+		;store a string ptr (5 times)
	moveq	#127-1,d1
.loop_2:
	move.b	(a0)+,d0
	cmp.b	#' ',d0
	dbls	d1,.loop_2
	clr.b	-1(a0)
	addq	#1,d3
	dbra	d5,.loop_1
;
	move.l	original_s(pc),a0
	bsr	strlen
	move.l	d0,d3
	move.l	replacement_s(pc),a0
	bsr	strlen
	cmp.l	d0,d3			;strings of same size ?
	bne	arg_error_exit
	cmp	#2,d3			;strings longer than 2 char's ?
	bgt.s	.strings_ok
	sim_aes	form_alert,#1,shorts_al_s(pc)
	cmp	#2,d0
	bne	main_exit_ok
.strings_ok:
	move.l	d3,string_len		;store string length
;
	bsr	rep_fstr
;
	tst.l	d0
	bpl	main_exit_ok
prog_error_exit:
	move	d1,d5			;d5 = error activity code
	move.l	d0,d4			;d4 = system error code
	lea	error_code_s(pc),a0
	bsr	conv_long
	sim_aes	form_alert,#1,error_al_s(pc)
	cmp	#2,d0
	bne.s	.skip_err_info
.give_err_info:
	move	d5,d2			;d2 = activity code
	subq	#1,d2			;d2 = activity index
	asl	#2,d2			;d2 = index to long
	lea	activity_al_t(pc),a2
	move.l	(a2,d2),a2
	sim_aes	form_alert,#1,(a2)
.skip_err_info:
	move.l	d4,d0
	bra.s	main_exit_d0
;
arg_error_exit:
	clr	d3
	moveq	#5,d4
	lea	info_al_t(pc),a3
info_loop:
	tst	d3
	bpl.s	.not_neg
	move	d4,d3
.not_neg:
	cmp	d4,d3
	bls.s	.show_alert
	clr	d3
.show_alert:
	move	d3,d2
	asl	#2,d2
	move.l	(a3,d2),a2
	sim_aes	form_alert,#1,(a2)
	addq	#1,d3
	cmp	#2,d0
	beq.s	info_loop
	subq	#2,d3
	cmp	#3,d0
	beq.s	info_loop
gen_error_exit:
	moveq	#-1,d0
	bra.s	main_exit_d0
;
main_exit_ok:
	clr.l	d0
main_exit_d0:
	rts
;
;----------------------------------------------------------------------------
;
rep_fstr:
	movem.l	d2-d7/a0-a6,-(sp)
;
.open_source:
	moveq	#1,d7		;open source = 1
	gemdos	Fopen|_ind,source_file_s,!
	move.l	d0,d5		;d5 = source file handle
	bmi	.exit
;
.open_dest:
	moveq	#2,d7		;open dest = 2
	gemdos	Fopen|_ind,dest_file_s,!
	move.l	d0,d6
	bmi.s	.no_dest_open
	gemdos	Fclose,d6
.no_dest_open:
	tst.l	d6
	bmi.s	.create_dest
	sim_aes	form_alert,#1,dest_exists_al_s(pc)
	cmp	#2,d0
	bne	.exit_ok
.delete_dest:
	moveq	#3,d7		;delete dest = 3
	gemdos	Fdelete|_ind,dest_file_s
	tst.l	d0
	bmi	.exit
.create_dest:
	moveq	#4,d7		;create dest = 4
	gemdos	Fcreate|_ind,dest_file_s,!
	move.l	d0,d6		;d6 = destination file handle
	bmi	.exit
;
	clr	eof_flag
	move.l	original_s(pc),a6
.copy_loop:
;
.read_source:
	moveq	#5,d7		;read source = 5
	gemdos	Fread,d5,#BUF_SIZE,buffer
	move.l	d0,d4		;d4 = block size
	beq	.exit_ok
;
.scan_source:
	lea	buffer(pc),a5	;a5 -> source data
	move.b	(a6),d0		;d0 = first char of original string
	move	d4,d3
	subq	#1,d3		;d3 = dbra count for buffer block
.scan_loop:
	cmp.b	(a5)+,d0
	dbeq	d3,.scan_loop
	bne	.write_dest	;write to dest_file at once if no match
	move	string_len+2,d2
	subq	#1,d2		;d2 = length of untested string part
	ble	.single_match	;if none, go edit single character
	cmp	d2,d3		;is remainder of buffer enough for test ?
	bhs.s	.simple_match	;if so, go test string directly
;Here string crosses buffer limit, requiring some extra work
	subq	#1,a5		;a5 -> string start in buffer
	move.l	a5,d0
	sub.l	#buffer,d0	;d0 = size of buffer preceding string
	moveq	#6,d7		;write dest = 6
	gemdos	Fwrite,d6,d0,buffer(pc)	;write buffer before string
	tst.l	d0
	bmi	.exit
	lea	buffer(pc),a1	;a1 -> string part 1 destination
.move_loop:
	move.b	(a5)+,(a1)+	;move string to start of buffer
	dbra	d3,.move_loop	;repeat for entire string part 1
	moveq	#5,d7		;read source = 5
	gemdos	Fread,d5,#BUF_SIZE,(a1)
	tst.l	d0
	bmi.s	.exit
	seq	eof_flag
	beq.s	.write_dest	;go skip match at EOF
	add.l	d0,d4		;d4 = block size of string part 1 + Fread
	lea	buffer+1(pc),a5	;a5 -> untested source data
	move	d4,d3
	subq	#2,d3		;d3 = dbra count for untested buffer
	move.l	string_len(pc),d2
	subq	#1,d2		;d2 = length of untested string
;This leaves everything adapted to 'simple match', which we proceed with
.simple_match:
	move.l	a5,a4		;a4 -> byte after primary match in source
	subq	#1,d2		;d2 =  dbra count for untested string
	lea	1(a6),a0	;a0 -> untested string
.match_loop:			;loop start
	cmpm.b	(a0)+,(a4)+	;	compare a string byte with buffer
	dbne	d2,.match_loop	;repeat for entire string, or until mismatch
	beq.s	.replace_string
	dbra	d3,.scan_loop
	bra.s	.write_dest
;
.replace_string:
	move.l	replacement_s(pc),a0	;a0 -> replacement string
	subq	#1,a5			;a5 -> string destination
	move	string_len+2(pc),d2
	sub	d2,d3			;adjust countdown for buffer
	subq	#1,d2			;d2 =  dbra count for string
.replace_loop:
	move.b	(a0)+,(a5)+		;edit string in buffer
	dbra	d2,.replace_loop
	tst	d3			;buffer limit reached ?
	bpl	.scan_loop		;if not, go scan further
	bra.s	.write_dest		;go write completed buffer
;
.single_match:
	move.l	replacement_s(pc),a0	;a0 -> replacement string
	move.b	(a0),-1(a5)		;edit byte in buffer
	dbra	d3,.scan_loop
	bra	.write_dest
;
.write_dest:
	moveq	#6,d7		;write dest = 6
	gemdos	Fwrite,d6,d4,buffer(pc)
	tst.l	d0
	bmi.s	.exit
	tst	eof_flag
	beq	.copy_loop
;
.exit_ok:
	clr.l	d0
.exit:
	move.l	d0,d4
	cmp	#4,d7
	bls.s	.dest_closed
	gemdos	Fclose,d6
.dest_closed:
	cmp	#1,d7
	bls.s	.source_closed
	gemdos	Fclose,d5
.source_closed:
	move.l	d7,d1
	move.l	d4,d0
	movem.l	(sp)+,d2-d7/a0-a6
	rts
;
;----------------------------------------------------------------------------
;
strlen:
	move.l	a0,-(sp)
.loop:
	tst.b	(a0)+
	bne.s	.loop
	subq	#1,a0
	move.l	a0,d0
	sub.l	(sp)+,d0
	rts
;
;----------------------------------------------------------------------------
;
conv_nybble:
	swap	d0
	rol.l	#8,d0
	rol.l	#4,d0
	bra.s	conv_leftnybble
;
conv_byte:
	swap	d0
	rol.l	#8,d0
	bra.s	conv_leftbyte
;
conv_word:
	swap	d0
	bra.s	conv_leftword
;
conv_long:
	bsr	conv_leftword
conv_leftword:
	bsr	conv_leftbyte
conv_leftbyte:
	move.l	d0,-(sp)
	move.l	(sp)+,d0
	bsr	conv_leftnybble
conv_leftnybble:
	rol.l	#4,d0
	move.l	d0,-(sp)
	and	#$0F,d0
	or	#'0',d0
	cmp	#'9',d0
	bls.s	.got_hex
	add	#('A'-('9'+1)),d0
.got_hex:
	move.b	d0,(a0)+
	move.l	(sp)+,d0
	rts
;
;----------------------------------------------------------------------------
;
	make	SIM_links
;
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
;
acc_name:	dc.b	'  REP_FSTR, no ACC',NUL
;
purpose_al_s:
	dc.b	'[3]['
	dc.b	'REP_FSTR will copy the source|'
	dc.b	'file to the destination file,|'
	dc.b	'replacing all instances of an|'
	dc.b	" 'original'  string with the |"
	dc.b	" 'replacement'  string.      ]"
	dc.b	'[  Exit!  |  Usage  |  Info   ]',NUL
;
usage_al_s:
	dc.b	'[3]['
	dc.b	' REP_FSTR needs 4 arguments: |'
	dc.b	'1 = Source file name         |'
	dc.b	'2 = Destination file name    |'
	dc.b	'3 = Original string   \/Same |'
	dc.b	'4 = Replacement string/\size ]'
	dc.b	'[  Exit!  |  Info   | Purpose ]',NUL
;
info_1_al_s:
	dc.b	'[1]['
	dc.b	' ____ REP_FSTR __ V_1.2 ____ |'
	dc.b	' Created by URAn: 1995.06.25 |'
	dc.b	' at request by: DataLine BBS |'
	dc.b	' --------------------------- |'
	dc.b	' (c)1995 U. Ronald Andersson ]'
	dc.b	'[  Exit!  |  Smail  |  Usage  ]',NUL
;
info_2_al_s:
	dc.b	'[1]['
	dc.b	' ------ REP_FSTR 1.2 ------- |'
	dc.b	'    Ulf Ronald Andersson     |'
	dc.b	'        H”ders V„g 7         |'
	dc.b	'     S-145 70  Norsborg      |'
	dc.b	' --------- Sweden ---------- ]'
	dc.b	'[  Exit!  |  Email  |  Info   ]',NUL
;
info_3_al_s:
	dc.b	'[1]['
	dc.b	' ------ REP_FSTR 1.2 ------- |'
	dc.b	' You can contact me by local |'
	dc.b	' E- mail in  DataLine BBS to |'
	dc.b	'     "Ronald Andersson"      |'
	dc.b	' --------------------------- ]'
	dc.b	'[  Exit!  |  Info   |  Email  ]',NUL
;
info_4_al_s:
	dc.b	'[1]['
	dc.b	' ____ REP_FSTR __ V_1.2 ____ |'
	dc.b	' Created by URAn: 1995.06.25 |'
	dc.b	' at request by: DataLine BBS |'
	dc.b	' --------------------------- |'
	dc.b	' (c)1995 U. Ronald Andersson ]'
	dc.b	'[  Exit!  | Purpose |  Email  ]',NUL
;
shorts_al_s:
	dc.b	'[2]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' The strings are very short  |'
	dc.b	' => high  risk  of  changing |'
	dc.b	' some unintended data bytes! |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit | Do It ]',NUL
;
dest_exists_al_s:
	dc.b	'[2]['
	dc.b	' ______ REP_FSTR _________ |'
	dc.b	' A file already exists, with |'
	dc.b	' the name of our destination |'
	dc.b	' --------------------------- |'
	dc.b	' Shall I delete it ...?      ]'
	dc.b	'[ Exit | Do It ]',NUL
;
error_al_s:
	dc.b	'[2]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' Some error has occurred in  |'
	dc.b	' the operation of  REP_FSTR  |'
	dc.b	' --------------------------- |'
	dc.b	' Error code = 0x'
error_code_s:
	dc.b			'00000000     ]'
	dc.b	'[ Exit | Info ]',NUL
;
activity_1_al_s:
	dc.b	'[1]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' An error occurred while the |'
	dc.b	' program  was  opening  the  |'
	dc.b	' source file.                |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit ]',NUL
;
activity_2_al_s:
	dc.b	'[1]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' An error occurred while the |'
	dc.b	' program  was  opening  the  |'
	dc.b	' destination file.           |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit ]',NUL
;
activity_3_al_s:
	dc.b	'[1]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' An error occurred while the |'
	dc.b	' program  was  deleting  old |'
	dc.b	' destination file.           |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit ]',NUL
;
activity_4_al_s:
	dc.b	'[1]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' An error occurred while the |'
	dc.b	' program  was  creating new  |'
	dc.b	' destination file.           |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit ]',NUL
;
activity_5_al_s:
	dc.b	'[1]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' An error occurred while the |'
	dc.b	' program  was  reading  the  |'
	dc.b	' source file.                |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit ]',NUL
;
activity_6_al_s:
	dc.b	'[1]['
	dc.b	' ______ REP_FSTR 1.2 _______ |'
	dc.b	' An error occurred while the |'
	dc.b	' program  was  writing  the  |'
	dc.b	' destination file.           |'
	dc.b	' --------------------------- ]'
	dc.b	'[ Exit ]',NUL
;
	even
;
Info_al_t:
	dc.l	usage_al_s
	dc.l	info_1_al_s
	dc.l	info_2_al_s
	dc.l	info_3_al_s
	dc.l	info_4_al_s
	dc.l	purpose_al_s

activity_al_t:
	dc.l	activity_1_al_s
	dc.l	activity_2_al_s
	dc.l	activity_3_al_s
	dc.l	activity_4_al_s
	dc.l	activity_5_al_s
	dc.l	activity_6_al_s
;
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
;
string_p_t:
prog_name_s_p:	ds.l	1
source_file_s:	ds.l	1
dest_file_s:	ds.l	1
original_s:	ds.l	1
replacement_s:	ds.l	1
;
string_len:	ds.l	1
;
eof_flag:	ds.w	1
;
buffer:		ds.b	BUF_SIZE+1024
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
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	REP_FSTR.S
;----------------------------------------------------------------------------
