;----------------------------------------------------------------------------
*	Created by TT-Digger vv6.1
*	Thu Sep 09 16:43:16 1999
*
*	TTD_6.1
*
*	TEXT	$000510 bytes, segment starts at L000+$0
*	DATA	$000564 bytes, segment starts at CLS_s
*	BSS	$0001FA bytes, segment starts at UA74
*	SYMBOLS	$000000 bytes
*	FLAG	$0000
;----------------------------------------------------------------------------
	output	.TOS
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
start:
	movea.l	$0004(sp),a6		;a6 -> basepage
	lea 	loc_stk_top(pc),sp	;sp -> local stack top
	lea	bss_end(pc),a1		;a1 -> BSS end
	sub.l	a6,a1			;a1 = needed RAM size
	gemdos	Mshrink,!,(a6),a1
	lea 	CLS_s(pc),a0
	bsr.w	Cconws_sub
	lea 	title_mess_s(pc),a0
	bsr.w	show_string_CRLF
	pea 	loc_DTA.l
	move 	#$001A,-(sp)	; Fsetdta
	trap	#1		; Gemdos
	addq.l	#6,sp
main_loop:
	lea 	DEFAULT1_RUN_s(pc),a0
	bsr.w	Fsfirst_sub
	beq.s	main_loop_2
	lea 	DEFAULT1_RUN_s(pc),a0
	bsr.w	Cconws_sub
	lea 	not_found_s(pc),a0
	move 	#$0002,d0
	bra.w	show_mess_exit
;-------------------------------------
main_loop_2:
	moveq	#0,d0			;open for read only
	lea 	DEFAULT1_RUN_s(pc),a0
	bsr.w	Fopen_sub
	gemdos	Malloc,?
	divu	#$0400,d0
	swap	d0
	sub 	d0,d0
	swap	d0
	move.l	#$20203030,d1
	lea 	RAM_info_s(pc),a1
	lea 	$0005(a1),a0
	bsr.w	conv_word_to_asc
	bsr.w	show_string_CRLF
	move.l	loc_DTA+dta_fsize(pc),d7	;d7 = file size
	move.l	d7,-(sp)
	move 	#$0048,-(sp)		; Malloc
	trap	#1			; Gemdos
	addq.l	#6,sp
	movea.l	d0,a0			;a0 -> allocated buffer
	move.l	d0,file_buffer_p.l
	move.l	d7,d0
	bsr.w	Fread_sub		;read file
	bsr.w	Fclose_sub		;close file
	movea.l	file_buffer_p(pc),a0	;a0 -> file buffer
	movea.l	a0,a1			;a1 -> file buffer
	adda.l	d7,a1			;a1 -> file end
	moveq	#$14,d7			;d7 = 20 as max menu entry count
	lea 	menu_entry_spt(pc),a5
	lea 	pathname_spt(pc),a6
	moveq	#3-1,d1			;\
	lea 	item_T_s(pc),a3		; > Search for title header
	bsr.s	find_substr		;/
	bcc.s	bad_structure_exit	;if not found, go report error
;---'#T '
	move.l	a0,menu_title_p.l
	moveq	#2-1,d1			;\
	lea 	CRLF_s(pc),a3		; > Search for CRLF
	bsr.s	find_substr		;/
	bcc.s	bad_structure_exit	;if not found, go report error
menu_loop:
	clr.b	-$0001(a0)		;\/ Force termination
	clr.b	-$0002(a0)		;/\ replacing CRLF
	moveq	#3-1,d1			;\
	lea 	item_E_s(pc),a3		; > Search for entry header
	bsr.s	find_substr		;/
	bcc.s	display_full_menu	;if not found, assume menu complete
	dbf	d7,register_entry	;if found, go register entry
;---Too many entries !
bad_structure_exit:
	lea 	DEFAULT1_RUN_s(pc),a0
	bsr.w	Cconws_sub
	lea 	bad_structure_s(pc),a0
	move 	#$0002,d0
	bra.w	show_mess_exit
;-------------------------------------
register_entry:
	move.l	a0,(a5)+		;(a5)+ -> menu entry string
	moveq	#2-1,d1			;\
	lea 	CRLF_s(pc),a3		; > Search for CRLF
	bsr.s	find_substr		;/
	bcc.s	bad_structure_exit	;if not found, go report error
	clr.b	-$0001(a0)		;\/ Force termination
	clr.b	-$0002(a0)		;/\ replacing CRLF
	move.l	a0,(a6)+		;(a6)+ -> program pathname
	bsr.s	find_substr
	bcc.s	bad_structure_exit
	bra.s	menu_loop
;----------------------------------------------------------------------------
find_substr:
	move 	d1,d0
	movea.l	a3,a2
L154:
	cmpa.l	a1,a0			;a0 < a1 ?
	bcc.s	.exit			;else break loop to .exit with carry clear
	cmpm.b	(a2)+,(a0)+		;(a0)+ == (a2)+ ?
	dbne	d0,L154			;loop back until not equal, or d1 chars checked
	bne.s	find_substr
	move	d0,ccr			;set all CCR bits (!?!) if strings matched
.exit:
	rts				;return CS for match, CC for failure
;----------------------------------------------------------------------------
display_full_menu:
	moveq	#$14,d0			;d0 = 20 as max menu entry count
	sub 	d7,d0			;d0 = number of entries registered
	beq.s	set_timeout		;zero timeout if no entries exist
	moveq	#10,d0			;else use a 10 second timeout
set_timeout:
	move.b	d0,timeout_delay.l
	st	response_var.l		;response_var = -1
L178:					;loop start to clear unused pointers
	clr.l	(a5)+
	clr.l	(a6)+
	dbf	d7,L178			;loop back to clear unused pointers
	movea.l	menu_title_p(pc),a0
	bsr.w	Cconws_sub		;display menu title
	lea 	prompt_s(pc),a0
	bsr.w	Cconws_sub
	lea 	menu_entry_spt(pc),a6
	lea 	funkey_s(pc),a5
	move.l	#$66313A20,(a5)		;funkey_s = "f1: "
	clr.b	$0004(a5)
display_menu_loop:
	move.l	(a6)+,d7		;d7 -> menu entry string
	beq.s	L1DA
	bsr.w	CRLF_sub
	movea.l	a5,a0
	bsr.w	Cconws_sub		;display funkey_s
	addq 	#1,(a5)			;\
	cmpi.b	#$3A,$0001(a5)		; \
	bne.s	L1C8			;  \
	move.b	#$30,$0001(a5)		;   \/ increment funkey
L1C8:					;   /\ designation in string
	cmpi 	#'f1',(a5)		;  /
	bne.s	L1D2			; /
	move.b	#$46,(a5)		;/
L1D2:
	movea.l	d7,a0
	bsr.w	Cconws_sub		;display menu entry string
	bra.s	display_menu_loop
;-------------------------------------
L1DA:
	lea 	update_loc_tick(pc),a0
	bsr.w	Supexec_sub
	move.l	loc_tick(pc),d0
	move.l	d0,start_tick.l		;restart timeout
response_loop:
	lea 	update_loc_tick(pc),a0
	bsr.w	Supexec_sub
	move.l	loc_tick(pc),d0
	sub.l	start_tick(pc),d0
	divu	#200,d0			;d0 = seconds from timeout start
	tst.b	response_var.l		;test user response
	bpl.s	no_timeout		;if user has responded, go skip timeout
	cmp.b	timeout_delay(pc),d0	;timeout if time >= timeout_delay
	bhs.w	normal_exit		;when that happens, go exit program
	lea 	prompthead_1_s(pc),a0
	move.b	timeout_delay(pc),d1
	addi.b	#$30,d1
	sub.b	d0,d1			;d1 = remaining time +$30
	cmp.b	countdown_c-prompthead_1_s(a0),d1
	beq.s	no_timeout
	move.b	d1,countdown_c-prompthead_1_s(a0)
	bsr.w	Cconws_sub
no_timeout:
	gemdos	Crawio,#$00FF
	swap	d0		;d0 = ascii.scancode
	beq.s	response_loop
	lea 	pathname_spt(pc),a6
stop_timeout:
	tst.b	response_var.l
	bpl.s	test_commands
	sf	response_var.l
	move	d0,-(sp)			;push scancode
	lea 	prompthead_2_s(pc),a0
	bsr.w	Cconws_sub
	move	(sp)+,d0			;pull scancode
test_commands:
	cmp.b	#$61,d0				;scancode for 'Undo' ?
	beq.w	normal_exit
	cmp.b	#$3B,d0				;scancode for 'f1' ?
	blo.w	response_loop			;if lower than funkeys, goto response_loop
	cmp.b	#$44,d0				;scancode for 'f10' ?
	bhi.s	L2A4				;if higher than f10, goto L2A4
	sub.b	#$3B,d0				;convert f1..f10 to index 0..9
	bra.s	L2B8				;goto L2B8

L2A4:
	cmp.b	#$54,d0				;scancode for 'F1' ?
	blo.w	response_loop			;if lower than F1, goto response_loop
	cmp.b	#$5D,d0				;scancode for 'F10'
	bhi.w	response_loop			;if higher than F10 goto response_loop
	sub.b	#$4A,d0				;convert F1..F10 to index 10..19
L2B8:
	ext 	d0				;d0 = word(index)
	asl 	#2,d0				;d0 = index*4
	move.l	$00(a6,d0),d0			;d0 -> pathname of entry
	beq.w	response_loop
	movea.l	d0,a0				;a0 -> pathname of entry
	bsr.w	get_set_drive_path		;ready to access program
	bmi.w	response_loop			;unless path doesn't exist !
	gemdos	Mfree|_ind,file_buffer_p(pc)	;release file buffer
	move.l	filename_p(pc),a0
L2E2:
	tst.b	(a0)+
	bne.s	L2E2
	subq.l	#1,a0
	moveq	#-1-$20,d3
L2EA:
	move.b	-(a0),d0
	and.b	d3,d0
	move.b	-(a0),d1
	and.b	d3,d1
	move.b	-(a0),d2
	and.b	d3,d2
	move.b	-(a0),d3
	cmp.b	#'X',d0
	beq.s	L304
	cmp.b	#'N',d0
	bne.s	run_program
L304:
	cmp.b	#'U',d1
	bne.s	run_program
	cmp.b	#'R',d2
	bne.s	run_program
	cmp.b	#'.',d3
	bne.s	run_program
	move.l	filename_p(pc),a0
	lea 	DEFAULT1_RUN_s(pc),a1
L322:
	move.b	(a0)+,(a1)+
	bne.s	L322
	lea 	CLS_s(pc),a0
	bsr.w	Cconws_sub
	lea 	title_mess_s(pc),a0
	bsr.w	show_string_CRLF
	bra.w	main_loop
;-------------------------------------
run_program:
	lea 	CLS_s(pc),a0
	bsr.w	Cconws_sub
	gemdos	Pexec,!,pathname_s(pc),NUL_s(pc),!
	move.l	d0,d7
	lea 	CLS_s(pc),a0
	bsr.s	Cconws_sub
	move.l	d7,d0
	bpl.s	L376
	bsr.w	show_mess_if_err
	bra.s	L3C0
;-------------------------------------
L376:
	lea 	title_mess_s(pc),a0
	tst 	d7
	beq.s	L3BE
	lea 	TERM_s(pc),a0
	bsr.s	Cconws_sub
	lea 	title_mess_s(pc),a0
	cmp 	#$0002,d7
	bne.s	L39A
	lea 	Bad_parameters_s(pc),a0
L39A:
	cmp 	#$0001,d7
	bne.s	L3A6
	lea 	sys_errors_s_t(pc),a0
L3A6:
	cmp 	#-$0001,d7
	bne.s	L3B2
	lea 	Process_crashed_s(pc),a0
L3B2:
	cmp 	#-$0020,d7
	bne.s	L3BE
	lea 	Process_terminated_s(pc),a0
L3BE:
	bsr.s	show_string_CRLF
L3C0:
	bra.w	main_loop_2
;-------------------------------------
normal_exit:
	lea 	CLS_s(pc),a0
	bsr.s	Cconws_sub
	clr 	-(sp)
	trap	#1			; Gemdos
;----------------------------------------------------------------------------
show_string_CRLF:
	bsr.s	Cconws_sub
CRLF_sub:
	lea 	endline_s(pc),a0
Cconws_sub:
	move.l	a0,-(sp)
	move 	#$0009,-(sp)		; Cconws
	trap	#1			; Gemdos
	addq.l	#6,sp
	rts
;----------------------------------------------------------------------------
Hit_any_key_sub:
	lea 	Hit_any_key_CRLF_s(pc),a0
	bsr.s	show_string_CRLF
	move 	#$0007,-(sp)		; Crawcin
	trap	#1			; Gemdos
	addq.l	#2,sp
	rts
;-------------------------------------
show_mess_exit:
	move 	d0,-(sp)
	bsr.s	show_string_CRLF
	bsr.s	Hit_any_key_sub
	move 	#$004C,-(sp)		; Pterm
	trap	#1			; Gemdos
Supexec_sub:
	move.l	a0,-(sp)
	move 	#$0026,-(sp)		; Supexec
	trap	#14			; Xbios
	addq.l	#6,sp
	rts
;----------------------------------------------------------------------------
Hit_any_key_CRLF_s:
	dc.b	'Hit any key.',$00
endline_s:
	dc.b	ESC,'K'
CRLF_s:
	dc.b	$0D,$0A
NUL_s:
	dc.b	$00
	EVEN
;----------------------------------------------------------------------------
Fsfirst_sub:
	clr 	-(sp)
	pea 	(a0)
	move 	#$004E,-(sp)		; Fsfirst
	trap	#1			; Gemdos
	addq.l	#8,sp
L436:
	move 	d0,d0
	rts
;----------------------------------------------------------------------------
Fsnext_sub:
	move 	#$004F,-(sp)		; Fsnext
	trap	#1			; Gemdos
	addq.l	#2,sp
	bra.s	L436
;----------------------------------------------------------------------------
Fopen_sub:
	move 	d0,-(sp)
	pea 	(a0)
	move 	#$003D,-(sp)		; Fopen
	trap	#1			; Gemdos
	addq.l	#8,sp
	move 	d0,file_handle.l
	rts
;----------------------------------------------------------------------------
Fclose_sub:
	move 	file_handle(pc),-(sp)
	move 	#$003E,-(sp)		; Fclose
	trap	#1			; Gemdos
	addq.l	#4,sp
	rts
;----------------------------------------------------------------------------
Fread_sub:
	pea 	(a0)
	move.l	d0,-(sp)
	move 	file_handle(pc),-(sp)
	move 	#$003F,-(sp)	; Fread
	trap	#1		; Gemdos
	lea 	$000C(sp),sp
	rts
;----------------------------------------------------------------------------
Fseek_sub:
	move 	d0,-(sp)
	move 	file_handle(pc),-(sp)
	move.l	d1,-(sp)
	move 	#$0042,-(sp)	; Fseek
	trap	#1		; Gemdos
	lea 	$000A(sp),sp
	rts
;----------------------------------------------------------------------------
get_set_drive_path:
	movem.l	a3/a4,-(sp)		;push entry a3/a4
.skip_space:
	move.b	(a0)+,d0
	beq.s	.bad_path
	cmp.b	#' ',d0
	beq.s	.skip_space
	cmp.b	#HT,d0
	beq.s	.skip_space
	lea 	pathname_s(pc),a3	;a3 -> pathname_s (destination)
	move.b	d0,(a3)+		;store drive letter
	move.b	(a0)+,d0
	beq.s	.bad_path
	cmp.b	#':',d0
	bne.s	.bad_path
	move.b	d0,(a3)+		;store drive letter separator
	move.b	(a0)+,d0
	beq.s	.bad_path
	cmp.b	#'\',d0
	beq.s	.set_path_border
.bad_path:
.bad_file:
	moveq	#-1,d0			;flag generic error
	movem.l	(sp)+,a3/a4		;pull entry a3/a4
	rts
;-------------------------------------
.loop_1:
	move.b	(a0)+,d0
	beq.s	.path_complete
	cmp.b	#'\',d0
	bne.s	.normal_char
.set_path_border:
	move.l	a3,a4			;a4 = a3 -> possible final backslash
.normal_char:
	move.b	d0,(a3)+		;store character
	bra.s	.loop_1			;loop back for more
;-------------------------------------
.path_complete:	
	clr.b	(a3)+			;terminate pathname_s
	move.l	a3,filename_p		;store ptr to pure filename
	lea 	pathname_s(pc),a3	;a3 -> pathname_s (destination)
	move.b	(a3),d0			;d0 = drive letter
	andi 	#$00DF,d0
	subi 	#$0041,d0		;d0 = drive code
	gemdos	Dsetdrv,d0		;set active drive
	clr.b	(a4)			;force termination at final slash
	gemdos	Dsetpath,(a3)		;set active path
	move.b	#'\',(a4)		;restore full pathname_s
	move.l	a3,a0			;a0 -> pathname_s
	clr	d0			;openmode = read_only
	bsr	Fopen_sub		;open file
	bmi.s	.bad_file		;exit on error
	bsr	Fclose_sub		;close file
	clr.l	d0			;flag no error
	movem.l	(sp)+,a3/a4		;pull entry a3/a4
	rts				;return
;----------------------------------------------------------------------------
conv_word_to_asc:
	cmpa.l	a1,a0
	beq.s	L504
	divu	#$000A,d0
	swap	d0
	add 	d1,d0
	move.b	d0,-(a0)
	sub 	d0,d0
	swap	d0
	bne.s	conv_word_to_asc
	swap	d1
L4FA:
	cmpa.l	a1,a0
	beq.s	L502
	move.b	d1,-(a0)
	bra.s	L4FA
;-------------------------------------
L502:
	moveq	#$01,d0
L504:
	rts
;----------------------------------------------------------------------------
update_loc_tick:
	move.l	_hz_200.w,loc_tick.l
	rts
;----------------------------------------------------------------------------
;;;patch	DATA
;----------------------------------------------------------------------------
CLS_s:
	dc.b	$1B,'E',NUL
title_mess_s:
	dc.b	$1B,'p ProRunner v1.2 ',$1B
	dc.b	'q / Gwile',NUL
RAM_info_s:
	dc.b	'----- kBytes free to run...',NUL
	EVEN
	dc.b	NUL
prompthead_1_s:
	dc.b	$1B,'H',$0A,$0A,$0A
	dc.b	'Spacebar stops timeout:'
countdown_c:
	dc.b	' ',NUL
prompthead_2_s:
	dc.b	$1B,'H',$0A,$0A,$0A
	dc.b	'Function keys select programs.',NUL
prompt_s:
	dc.b	$0D,$0A,$0A
	dc.b	'(f0==f10  F0==F10  Fx==shift-fx)',NUL
bad_structure_s:
	dc.b	': bad structure.',$00
not_found_s:
	dc.b	' not found.',$00
DEFAULT1_RUN_s:
	dc.b	'DEFAULT1.RUN',$00
TERM_s:
	dc.b	'TERM: ',$00
Bad_parameters_s:
	dc.b	'Bad parameters.',$00
Process_crashed_s:
	dc.b	'Process crashed.',$00
Process_terminated_s:
	dc.b	'Process terminated by CTRL-C.',$00
	dc.b	'UNKNOWN Error !',$00
;----------------------------------------------------------------------------
sys_errors_s_t:
	dc.b	'Generic error.',$00
	dc.b	'Drive not ready.',$00
	dc.b	'Unknown command.',$00
	dc.b	'CRC error.',$00
	dc.b	'Bad request.',$00
	dc.b	'Seek error.',$00
	dc.b	'Unknown media.',$00
	dc.b	'Sector not found.',$00
	dc.b	'Out of paper.',$00
	dc.b	'Write fault.',$00
	dc.b	'Read fault.',$00
	dc.b	'Device is write protected.',$00
	dc.b	'Media change detected.',$00
	dc.b	'Unknown device.',$00
	dc.b	'Bad sectors on format.',$00
	dc.b	'Insert other disk.',$00
	dc.b	'Invalid function.',$00
	dc.b	'File not found.',$00
	dc.b	'Path not found.',$00
	dc.b	'No more handles.',$00
	dc.b	'Access denied.',$00
	dc.b	'Invalid handle.',$00
	dc.b	'Insufficient memory.',$00
	dc.b	'Invalid memory block address.',$00
	dc.b	'Invalid drive specification.',$00
	dc.b	'Cross device rename.',$00
	dc.b	'No more files.',$00
	dc.b	'Record is already locked.',$00
	dc.b	'Invalid lock removal request.',$00
	dc.b	'Range error.',$00
	dc.b	'Internal error.',$00
	dc.b	'Invalid program load format.',$00
	dc.b	'Memory block growth failure.',$00
	dc.b	'Too many symbolic links.',$00
	dc.b	'Mount point crossed.',$00
;----------------------------------------------------------------------------
	dc.w	$0287,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$026E,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$0251,$0234,$0224
	dc.w	$0217,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$01F9,$01DF,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$01D0
	dc.w	$01BB,$019E,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$0180
	dc.w	$016B,$FFF0,$015B,$014C
	dc.w	$013B,$012B,$011B,$0109
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$FFF0,$FFF0
	dc.w	$FFF0,$FFF0,$00F6,$00DF
	dc.w	$00CF,$00B8,$FFF0,$009D
	dc.w	$0091,$0084,$0076,$0064
	dc.w	$0055,$0049,$003C,$0031
	dc.w	$0020,$000F,$0000
;----------------------------------------------------------------------------
show_mess_if_err:
	move 	d0,-(sp)
	beq.s	TA5A
	lea 	BIOS_s(pc),a0
	cmp 	#-$0020,d0
	bgt.s	TA44
	lea 	GEMDOS_s(pc),a0
TA44:
	bsr.w	Cconws_sub
	move 	(sp)+,d0
	add 	d0,d0
	lea 	sys_errors_s_t(pc),a0
	adda 	show_mess_if_err(pc,d0),a0
	bra.w	show_string_CRLF
;-------------------------------------
TA5A:
	move 	(sp)+,d0
	rts
;----------------------------------------------------------------------------
BIOS_s:
	dc.b	'BIOS: ',$00
GEMDOS_s:
	dc.b	'GEMDOS: ',$00
item_T_s:
	dc.b	'#T '
item_E_s:
	dc.b	'#E '
	EVEN
;----------------------------------------------------------------------------
	BSS
;----------------------------------------------------------------------------
timeout_delay:
	ds.b	1
response_var:
	ds.b	1
loc_tick:
	ds.l	1
start_tick:
	ds.l	1
pathname_spt:
	ds.l	21
menu_entry_spt:
	ds.l	21
menu_title_p:
	ds.l	1
file_buffer_p:
	ds.l	1
funkey_s:
	ds.l	1
	ds.b	1
pathname_s:
	ds.b	128
	EVEN
filename_p:
	ds.l	1
file_handle:
	ds.w	1
loc_DTA:
	ds.b	dta_size
loc_stack:
	ds.b	2048		;was originally 256 bytes
loc_stk_top:
bss_end:
;----------------------------------------------------------------------------
	end	
;----------------------------------------------------------------------------
