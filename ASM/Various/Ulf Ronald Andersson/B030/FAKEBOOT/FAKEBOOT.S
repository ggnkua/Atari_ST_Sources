;----------------------------------------------------------------------------
;File name:	FAKEBOOT.S			Revision date:	2000.05.27
;Created by:	Ulf Ronald Andersson		Creation date:	1997.09.10
;----------------------------------------------------------------------------
	output	.TOS
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
MAX_MENU_ENTRIES	= 40
MAX_e_bufpos		= 256
;----------------------------------------------------------------------------
DEBUG_PATCH	= 0
;----------------------------------------------------------------------------
display	MACRO	string
	IFNC	"(a0)","\1"
	lea	\1,a0
	ENDC
	bsr	e_conws
	ENDM
;-------------------------------------
dc_rb	MACRO	max,len,buf
	dc.w	\1,\2
	dc.l	\3
	ENDM
;-------------------------------------
dc_ob	MACRO	next,X,Y,rb,type,flags,state
	dc.l	\1,\5,((\6)<<16)|(\7),\4,((\2)<<16)|(\3),0
	ENDM
;-------------------------------------
def_bit	MACRO	bitnum,name
\2_b	= \1
\2	= (1<<(\1))
	ENDM
;----------------------------------------------------------------------------
;	Object type codes
;-------------------------------------
G_BUTTON	= $1A
G_STRING	= $1C
G_TITLE		= $20
X_BUTTON	= $581A		;Button for normal program
X_STRING	= $581C		;String for menu titles
Y_BUTTON	= $591A		;Button for uncachable program
;----------------------------------------------------------------------------
;	Object flags bits
;-------------------------------------
	def_bit	00,SELECTABLE
	def_bit	01,DEFAULT
	def_bit	02,EXIT
	def_bit	03,EDITABLE
	def_bit	04,RBUTTON
	def_bit 05,LASTOB
	def_bit	06,TOUCHEXIT
	def_bit	07,HIDETREE
	def_bit	08,INDIRECT
	def_bit	14,CACHABLE
;-------------------------------------
NONE	=	0
;----------------------------------------------------------------------------
;	Object state bits
;-------------------------------------
	def_bit	00,SELECTED
	def_bit	01,CROSSED
	def_bit	02,CHECKED
	def_bit	03,DISABLED
	def_bit	04,OUTLINED
	def_bit	05,SHADOWED
;-------------------------------------
NORMAL	=	0
;----------------------------------------------------------------------------
		RSRESET
rb_max		rs.w	1
rb_len		rs.w	1
rb_buf		rs.l	1
sizeof_rb	rs.w	0
;----------------------------------------------------------------------------
		RSRESET
ob_next		rs.w	1		;\/ here used as ob_next ptr
ob_head		rs.w	1		;/
ob_tail		rs.w	1		;here unused
ob_type		rs.w	1		;object type
ob_flags	rs.w	1		;abilities of this object
ob_state	rs.w	1		;current state of object
ob_spec		rs.l	1		;-> main data block of object
ob_xy		rs.l	0		;alias for the two below
ob_x		rs.w	1		;\/ X and Y coordinates
ob_y		rs.w	1		;/
ob_data		rs.l	0		;alias for the two below
ob_w		rs.w	1		;\/ here used as ptr to extra data
ob_h		rs.w	1		;/ for objects that need such
sizeof_ob	rs.w	0
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
code_beg:
	move.l	4(sp),a5		;a5 -> basepage
	lea	loc_stk_top(pc),sp	;sp -> loc_stk_top
	lea	bss_end(pc),a6
	move.l	a6,d5
	sub.l	a5,d5			;d5 = needed block size
	gemdos	Mshrink,!,(a5),d5	;Mshrink program RAM block
	move.l	d5,prog_size		;store prog_size
	move.l	d0,d3
	bpl.s	.shrunk_ok
	lea	bss_end(pc),a1
	sub.l	a5,a1
	gemdos	Mshrink,!,(a5),a1
.shrunk_ok:
	bsr	e_init
	bsr	e_hide_curse
	display	title_mess_s(pc)
	IFNE	DEBUG_PATCH
	ELSE
	move.l	d3,d0			;test Mshrink success
	bmi.s	failed_shrink
	ENDC
	gemdos	Super,!
	move.l	d0,-(sp)
	move	(_bootdev).w,loc_bootdev
	cmp	#2,loc_bootdev
	bhs.s	.hd_boot
	bsr	fix_ram_sub
.hd_boot:
	gemdos	Super,()
	bsr	make_menu
	tst.l	d0
	bmi.s	failed_SET
	bsr	do_menu
	tst.l	d0
	ble.s	done_response
	subq	#1,d0
	bsr.s	do_response
done_response:
	gemdos	Mfree,(a6)
failed_SET:
	cmp	#2,loc_bootdev
	bhs.s	.hd_boot
	gemdos	Ptermres,prog_size(pc),d0
;-------
.hd_boot:
	gemdos	Pterm,d0
;-------
failed_shrink:
	gemdos	Pterm,#-1
;----------------------------------------------------------------------------
do_response:
	mulu	#(sizeof_ob+sizeof_rb),d0
	lea	menu_entry_t(pc),a0
	lea	cachable_head_s(pc),a1
	cmp	#Y_BUTTON,ob_type(a0,d0)
	bne.s	.have_head_s
	lea	uncachable_head_s(pc),a1
.have_head_s:
	move.l	ob_data(a0,d0),a3	;a3 -> entry response string
	move.l	a3,a4
.strlen_lp:
	tst.b	(a4)+
	bne.s	.strlen_lp
	subq	#1,a4
	sub.l	a3,a4			;a4 = string length excl terminator
	lea	FAKEBOOT_INF_s(pc),a5
	gemdos	Fcreate,(a5),!
	move	d0,d7
	bmi.s	.exit
	gemdos	Fwrite,d7,#4,(a1)	;write 4-char header '#E1 ' or '#E0 '
	gemdos	Fwrite,d7,a4,(a3)
	move.l	d0,d3
	gemdos	Fclose,d7
	move.l	d3,d0
	bmi.s	.exit
	moveq	#E_OK,d0
.exit:
	rts
;----------------------------------------------------------------------------
do_menu:
	move.l	abort_sp(pc),-(sp)
	move.l	sp,abort_sp
;-------
	lea	menu_1(pc),a0
	move.l	a0,e_curr_fm
	bsr	e_select_def
	move	d0,e_curr_ob
do_menu_loop:
	move.l	e_curr_fm(pc),a0
	moveq	#-1,d0
	bsr	e_draw_ob
	gemdos	Crawcin
	bsr.s	do_menu_cmd
	bra.s	do_menu_loop
;-------
do_menu_exit:
	move.l	abort_sp(pc),sp
	move.l	(sp)+,abort_sp
	rts
;----------------------------------------------------------------------------
do_menu_cmd:
	move.l	d0,d1
	swap	d1
	cmp.b	#$01,d1				;scancode Escape ?
	beq.s	do_menu_Escape
	cmp.b	#$1C,d1				;scancode Return ?
	beq.s	do_menu_Return
	cmp.b	#$72,d1				;scancode Enter ?
	beq.s	do_menu_Enter
	cmp.b	#$0F,d1				;scancode Tab ?
	beq.s	do_menu_Tab
	cmp.b	#$4B,d1				;scancode curse_L ?
	beq.s	do_menu_curse_L
	cmp.b	#$4D,d1				;scancode curse_R ?
	beq.s	do_menu_curse_R
	cmp.b	#$48,d1				;scancode curse_U ?
	beq.s	do_menu_curse_U
	cmp.b	#$50,d1				;scancode curse_D ?
	beq.s	do_menu_curse_D
	cmp.b	#$73,d1				;scancode curse_cL ?
	beq.s	do_menu_curse_cL
	cmp.b	#$74,d1				;scancode curse_cR ?
	beq.s	do_menu_curse_cR
do_menu_Tab:
do_menu_Escape:
	rts
;-------------------------------------
do_menu_Return:
do_menu_Enter:
	move	e_curr_ob(pc),d0
	bra	do_menu_exit
;-------------------------------------
do_menu_curse_U:
	bsr.s	do_menu_curse_L
	bra.s	do_menu_curse_L
;-------------------------------------
do_menu_curse_D:
	bsr.s	do_menu_curse_R
	bra.s	do_menu_curse_R
;-------------------------------------
do_menu_curse_cR:
	move	e_curr_ob(pc),d0
	move.l	e_curr_fm(pc),a0
	bsr	e_deselect_obj
	clr	e_curr_ob
do_menu_curse_L:
	move	e_curr_ob(pc),d0
	move.l	e_curr_fm(pc),a0
	bsr	e_select_prev
	move	d0,e_curr_ob
	rts
;-------------------------------------
do_menu_curse_cL:
	move	e_curr_ob(pc),d0
	move.l	e_curr_fm(pc),a0
	bsr	e_deselect_obj
	clr	e_curr_ob
do_menu_curse_R:
	move	e_curr_ob(pc),d0
	move.l	e_curr_fm(pc),a0
	bsr	e_select_next
	move	d0,e_curr_ob
	rts
;----------------------------------------------------------------------------
make_menu:
	gemdos	Fopen,FAKEBOOT_SET_s(pc),!	;open our SET file
	move	d0,d7				;d7 = handle
	bpl.s	.have_SET_handle
	gemdos	Fopen,AUTO_FAKEBOOT_SET_s(pc),!	;retry in AUTO folder
	move	d0,d7				;d7 = handle
	bmi.s	.Fopen_failure			;exit on error
.have_SET_handle:
	gemdos	Fseek,!,d7,#2			;find EOF
	move.l	d0,d6				;d6 = file length
	bmi.s	.Fseek_failure			;unless it is negative
	move.l	d6,d0
	add.l	#4,d0				;d0 = file length + 4
	gemdos	Malloc,d0			;allocate a file buffer
	move.l	d0,a6				;a6 -> file buffer
	tst.l	d0				;but it must be positive
	bmi.s	.Malloc_failure
	gemdos	Fseek,!,d7,!			;find file start again
	tst.l	d0
	bmi.s	.ReadSeek_failure
	gemdos	Fread,d7,d6,(a6)		;read the entire file
	cmp.l	d0,d6
	bne.s	.Fread_failure
	gemdos	Fclose,d7			;close the file
	clr.b	(a6,d6.l)			;terminate file string
	bra.s	analyze_FAKEBOOT_SET		;go analyze the SET file
;-------------------------------------
.Fread_failure:
.ReadSeek_failure:
	gemdos	Mfree,(a6)
.Malloc_failure:
.Fseek_failure
	gemdos	Fclose,d7
.Fopen_failure:
.Mshrink_failure:
.text_failure:
	gemdos	Pterm,#-1
;----------------------------------------------------------------------------
analyze_FAKEBOOT_SET:
	move.l	abort_sp(pc),-(sp)
	move.l	sp,abort_sp
	clr.l	d3			;d3 = 4-char shift_reg
	clr	d4			;d4 = zero menu entry count
	clr.l	d5			;d5 = file_pos zero
	lea	menu_entry_t(pc),a4	;a4 -> menu entry table (title = first entry)
	lea	sizeof_ob(a4),a3	;a3 -> ob_spec of title
	lea	def_menu_title_s(pc),a0	;a0 -> default title string
	move.l	a0,a1			;a1 -> default title string
.def_menu_loop:
	tst.b	(a1)+			;pass string (a1)+
	bne.s	.def_menu_loop
	sub.l	a0,a1			;a1 = string length
	move	a1,rb_max(a3)
	move	a1,rb_len(a3)
	move.l	a0,rb_buf(a3)
	move.l	a3,ob_spec(a4)
	clr.l	ob_next(a4)
	move.l	#3,ob_xy(a4)
	move	#X_STRING,ob_type(a4)
	clr	ob_state(a4)
	clr	ob_flags(a4)
	clr.l	ob_data(a4)
	add	#sizeof_ob+sizeof_rb,a4	;step to next struct pair
.main_loop:
	tst.b	(a6,d5.l)		;test next character
	bne.s	.no_terminator
.exit:
	move.l	abort_sp(pc),sp
	move.l	(sp)+,abort_sp
	moveq	#E_OK,d0		;accept error_free SET
	rts				;return
;-------
.no_terminator:
	bsr	skip_space
	cmp.b	#';',d3
	bne.s	.no_comment
	bsr	get_line_end		;pass comment line
	bra.s	.main_loop		;loop back for more lines
;-------
.no_comment:
	cmp.b	#'#',d3
	bne	abort_analysis
	bsr	get_char
	cmp.b	#'T',d3
	bne.s	.no_T_dirc
	bsr	take_space
	lea	-1(a6,d5.l),a1		;a1 -> new title string
	move.l	a1,menu_title_p
	bsr	get_line_end		;pass title string
	lea	-2(a6,d5),a2		;a2 -> end of menu entry string
	clr.b	(a2)			;terminate title string
	sub.l	a1,a2			;a2 = string length
	lea	menu_entry_t(pc),a0	;a0 -> title entry
	move	a2,sizeof_ob+rb_max(a0)
	move	a2,sizeof_ob+rb_len(a0)
	move.l	a1,sizeof_ob+rb_buf(a0)
	bra.s	.main_loop		;loop back for more lines
;-------
.no_T_dirc:
	clr	ob_flags(a4)
	cmp.b	#'e',d3			;entry uncachable ?
	beq.s	.program_entry
	or	#CACHABLE,ob_flags(a4)
	cmp.b	#'E',d3			;Entry cachable ?
	bne	abort_analysis
.program_entry:
	bsr	take_space
	cmp	#MAX_MENU_ENTRIES,d4	;check entry count
	bhs	abort_analysis
	lea	-1(a6,d5.l),a1		;a1 -> new menu entry
	bsr	get_line_end		;pass menu entry string
	lea	-2(a6,d5),a2		;a2 -> end of menu entry string
	clr.b	(a2)			;terminate menu entry string
	sub.l	a1,a2			;a2 = string length
	lea	sizeof_ob(a4),a3	;a3 -> rb struct of entry
	move	a2,rb_max(a3)
	move	a2,rb_len(a3)
	move.l	a1,rb_buf(a3)		;store -> menu entry
	move.l	a3,ob_spec(a4)
	lea	(a6,d5.l),a1		;a1 -> new entry response string
	move.l	a1,ob_data(a4)		;store -> response string
	bsr.s	get_line_end		;pass response string
	clr.b	-2(a6,d5)		;terminate response string
	move	#X_BUTTON,ob_type(a4)
	btst	#CACHABLE_b-8,ob_flags(a4)
	bne.s	.have_XY_button
	move	#Y_BUTTON,ob_type(a4)
.have_XY_button:
	clr	ob_state(a4)
	or	#SELECTABLE|EXIT,ob_flags(a4)
	move	d4,d0			;d0 = entry index
	bne.s	.late_XY_BUTTON
	or	#DEFAULT,ob_flags(a4)
.late_XY_BUTTON:
	and	#1,d0
	mulu	#20,d0			;d0 = X = 20*odd(index)
	swap	d0
	move	d4,d0			;d0 = X.index
	lsr	#1,d0			;d0 = X.Y
	addq	#5,d0
	move.l	d0,ob_xy(a4)
	move.l	a4,ob_next-(sizeof_ob+sizeof_rb)(a4)	;link to preceding structs
	add	#sizeof_ob+sizeof_rb,a4	;step to next struct pair
	addq	#1,d4			;increment entry count
	bra	.main_loop		;loop back for more lines
;----------------------------------------------------------------------------
take_space:
	bsr.s	get_char
	cmp.b	#' ',d3
	beq.s	skip_space
	cmp.b	#HT,d3
	bne.s	abort_analysis
skip_space:
	bsr.s	get_char
	cmp.b	#' ',d3
	beq.s	skip_space
	cmp.b	#HT,d3
	beq.s	skip_space
	rts
;-------------------------------------
get_line_end:
	bsr.s	get_char
	cmp	#CR<<8|LF,d3
	bne.s	get_line_end
	rts
;-------------------------------------
get_4_char:
	bsr.s	get_char
get_3_char:
	bsr.s	get_char
get_2_char:
	bsr	get_char
get_char:
	lsl.l	#8,d3
	cmp.l	d6,d5			;file_pos < file_len ?
	bhs.s	abort_analysis		;else we must abort here
	addq.l	#1,d5
	move.b	-1(a6,d5.l),d3
	rts
;-------
abort_analysis:
	move.l	abort_sp(pc),sp
	move.l	(sp)+,abort_sp
	gemdos	Mfree,(a6)
	moveq	#E_ERROR,d0
	rts
;----------------------------------------------------------------------------
set_rez_d0:
	xbios	Setscreen,?,?,d0
	xbios	Vsync
	xbios	Vsync
	rts
;----------------------------------------------------------------------------
;Start of:	vt52 emulator
;----------------------------------------------------------------------------
dc_wref	MACRO	destlist
	dc.w	\1-.ref
	IFNC	"\2",""
	dc.w	\2-.ref
	IFNC	"\3",""
	dc.w	\3-.ref
	IFNC	"\4",""
	dc.w	\4-.ref
	IFNC	"\5",""
	dc.w	\5-.ref
	IFNC	"\6",""
	dc.w	\6-.ref
	IFNC	"\7",""
	dc.w	\7-.ref
	IFNC	"\8",""
	dc.w	\8-.ref
	IFNC	"\9",""
	dc.w	\9-.ref
	IFNC	"\a",""
	dc.w	\a-.ref
	IFNC	"\b",""
	dc.w	\b-.ref
	IFNC	"\c",""
	dc.w	\c-.ref
	IFNC	"\d",""
	dc.w	\d-.ref
	IFNC	"\e",""
	dc.w	\e-.ref
	IFNC	"\f",""
	dc.w	\f-.ref
	IFNC	"\g",""
	dc.w	\g-.ref
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	ENDM
;----------------------------------------------------------------------------
e_init:
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	move.l	#e_NRM_handler,e_conout_p
	move.l	#e_buffer_1,e_buffer_p
	clr	e_bufpos
	lea	spaces_128(pc),a0
	move	#' ',d0
	move	#128-1,d2
.loop_1:
	move.b	d0,(a0)+
	dbra	d2,.loop_1
	clr	(a0)			;terminate space buffer
	movem.l	(sp)+,d0-d2/a0-a2	;pull entry d0-d2/a0-a2
	rts				;return with all regs intact
;----------------------------------------------------------------------------
e_select_def:
	movem.l	d1-d2/a0-a2,-(sp)	;push entry d1-d2/a0-a2
	moveq	#E_ERROR,d0			;d0 = E_ERROR
	clr	d1
.loop:
	btst	#DEFAULT_b,1+ob_flags(a0)
	bne.s	.found
	move.l	ob_next(a0),d2
	ble.s	.exit
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop
;-------
.found:
	bset	#SELECTED_b,1+ob_state(a0)
	move	d1,d0				;d0 = object id
.exit:
	movem.l	(sp)+,d1-d2/a0-a2	;pull entry d1-d2/a0-a2
	rts
;----------------------------------------------------------------------------
e_select_obj:
	movem.l	d1-d2/a0-a2,-(sp)	;push entry d1-d2/a0-a2
	clr	d1
.loop:
	cmp	d0,d1
	beq.s	.found
	move.l	ob_next(a0),d2
	ble.s	.error
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop
;-------
.error:
	moveq	#E_ERROR,d0
	bra.s	.exit
;-------
.found:
	bset	#SELECTED_b,1+ob_state(a0)
.exit:
	movem.l	(sp)+,d1-d2/a0-a2	;pull entry d1-d2/a0-a2
	rts
;----------------------------------------------------------------------------
e_deselect_obj:
	movem.l	d1-d2/a0-a2,-(sp)	;push entry d1-d2/a0-a2
	clr	d1
.loop:
	cmp	d0,d1
	beq.s	.found
	move.l	ob_next(a0),d2
	ble.s	.error
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop
;-------
.error:
	moveq	#E_ERROR,d0
	bra.s	.exit
;-------
.found:
	bclr	#SELECTED_b,1+ob_state(a0)
.exit:
	movem.l	(sp)+,d1-d2/a0-a2	;pull entry d1-d2/a0-a2
	rts
;----------------------------------------------------------------------------
e_select_next:
	movem.l	d1-d2/a0-a2,-(sp)		;push entry d1-d2/a0-a2
	move.l	a0,a1
	clr	d1
.loop_1:
	cmp	d0,d1
	beq.s	.found_1
	move.l	ob_next(a0),d2
	ble.s	.research
.next_1:
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop_1
;-------
.found_1:
	bclr	#SELECTED_b,1+ob_state(a0)
	bra.s	.test_next_2
;-------
.loop_2:
	btst	#SELECTABLE_b,1+ob_flags(a0)
	bne.s	.found_2
.test_next_2:
	move.l	ob_next(a0),d2
	ble.s	.research
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop_2
;-------
.research:
	move.l	a1,a0
	clr	d1
.loop_3:
	btst	#SELECTABLE_b,1+ob_flags(a0)
	bne.s	.found_3
	move.l	ob_next(a0),d2
	ble.s	.error
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop_3
;-------
.error:
	moveq	#E_ERROR,d0
	bra.s	.exit
;-------
.found_2:
.found_3:
	bset	#SELECTED_b,1+ob_state(a0)
	move	d1,d0				;d0 = object id
.exit:
	movem.l	(sp)+,d1-d2/a0-a2		;pull entry d1-d2/a0-a2
	rts
;----------------------------------------------------------------------------
e_select_prev:
	movem.l	d1-d3/a0-a2,-(sp)		;push entry d1-d3/a0-a2
	moveq	#E_ERROR,d3			;d3 = E_ERROR
	move.l	a0,a1
	clr	d1
.loop_1:
	cmp	d0,d1
	beq.s	.found_1
	btst	#SELECTABLE_b,1+ob_flags(a0)
	beq.s	.not_selected_1
	move.l	a0,a2
	move	d1,d3
.not_selected_1:
	move.l	ob_next(a0),d2
	ble.s	.test_prev
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop_1
;-------
.found_1:
	bclr	#SELECTED_b,1+ob_state(a0)
	tst	d3
	bpl.s	.found_prev
	bra.s	.test_next_2
;-------
.loop_2:
	btst	#SELECTABLE_b,1+ob_flags(a0)
	beq.s	.not_selected_2
	move.l	a0,a2
	move	d1,d3
.not_selected_2:
.test_next_2:
	move.l	ob_next(a0),d2
	ble.s	.test_prev
	move.l	d2,a0
	addq	#1,d1
	bra.s	.loop_2
;-------
.test_prev:
	move	d3,d1
	bmi.s	.exit
.found_prev:
	bset	#SELECTED_b,1+ob_state(a2)
.exit:
	move	d3,d0				;d0 = E_ERROR or object_id
	movem.l	(sp)+,d1-d3/a0-a2		;pull entry d1-d3/a0-a2
	rts
;----------------------------------------------------------------------------
e_link_ob:			;a0 -> ob_1  a1 -> ob_2  =>  d0 -> final ob
	movem.l	a0/a1,-(sp)
	cmp.l	a1,a0
	beq.s	.exit		;exit if objects are identical
.loop_1:
	move.l	ob_next(a0),d0
	ble.s	.link
	cmp.l	a1,d0
	beq.s	.linked
	move.l	d0,a0
	bra.s	.loop_1
;-------
.link:
	move.l	a1,ob_next(a0)	;link ob_2 into ob_1
.linked:
	move.l	a1,a0			;a0 -> ob_2 (now in ob_1 list)
	move.l	(sp),a1			;a1 -> ob_1
.loop_2:
	move.l	ob_next(a0),d0
	ble.s	.exit
	cmp.l	a1,d0
	beq.s	.unlink_circle
	move.l	d0,a0
	bra.s	.loop_2
;
.unlink_circle:
	clr.l	ob_next(a0)
.exit:
	move.l	a0,d0
	movem.l	(sp)+,a0/a1
	rts
;----------------------------------------------------------------------------
e_unlk_ob:			;a0 -> ob_1  a1 -> ob_2  =>  d0 -> final ob
	movem.l	a0/a1,-(sp)
.loop_1:
	move.l	ob_next(a0),d0
	ble.s	.last
	cmp.l	a1,d0
	beq.s	.unlk
	move.l	d0,a0
	bra.s	.loop_1
;-------
.unlk:
	clr.l	ob_next(a0)
.last:
	move.l	a0,d0
	movem.l	(sp)+,a0/a1
	rts
;----------------------------------------------------------------------------
e_last_ob:			;a0 -> ob  =>  d0 -> final ob
	move.l	a0,-(sp)
.loop:
	move.l	ob_next(a0),d0
	ble.s	.exit
	move.l	d0,a0
	bra.s	.loop
;-------
.exit:
	move.l	a0,d0
	move.l	(sp)+,a0
	rts
;----------------------------------------------------------------------------
e_draw_ob:
	movem.l	d1-d7/a0-a6,-(sp)	;push entry registers
	move	d0,d5			;d5 = max_objects to be drawn
	beq	.exit
	subq	#1,d5			;d5 = dbra count for objects
	move.l	e_pos_ix(pc),-(sp)	;push entry cursor position
	move.l	a0,a6			;a6 -> first object
.draw_loop:
	movem	ob_xy(a6),d6/d7
	move	d6,d0			;d0 = d6 = base column position
	move	d7,d1			;d1 = d7 = base row position
	bsr	e_goto_XY
	btst	#SELECTED_b,1+ob_state(a6)
	beq.s	.done_select_1
	bsr	e_inverse_on
.done_select_1:
	move.l	ob_spec(a6),a4		;a4 -> String or ReadBuffer struct
	move	ob_type(a6),d0
	and	#$FF00,d0
	cmp	#$5800,d0
	beq.s	.draw_rb_object
	cmp	#$5900,d0
	beq.s	.draw_rb_object
	display	(a4)
	bra.s	.padded
;-------------------------------------
.draw_rb_object:
	movem.l	rb_max(a4),d3/a3	;d3/a3 = rb_max.rb_len,rb_buf
	move	d3,d4			;d4 = rb_len
	swap	d3			;d3 = rb_max
	moveq	#$7F,d0
	cmp	d0,d3
	bls.s	.keep_rb_max
	move	d0,d3
.keep_rb_max:
	cmp	d0,d4
	bls.s	.keep_rb_len
	move	d0,d4
.keep_rb_len:
	tst	d4			;rb_len non_zero ?
	ble.s	.displayed
	clr.b	(a3,d4)			;terminate buffer string
	display	(a3)			;display string
.displayed:
	move	d3,d0			;d0 = rb_max
	sub	d4,d0			;d0 = rb_max-rb_len
	ble.s	.padded
	lea	spaces_end(pc),a0
	sub	d0,a0
	display	(a0)			;display spaces to pad field to max
.padded:
	btst	#SELECTED_b,1+ob_state(a6)
	beq.s	.done_select_2
	bsr	e_inverse_off
.done_select_2:
	move.l	ob_next(a6),a6	;a6 -> next object
	move.l	a6,d0			;test pointer
	dble	d5,.draw_loop
	move.l	(sp)+,e_pos_ix		;pull entry cursor position
	bsr	e_revive_XY
.exit:
	moveq	#E_OK,d0
	movem.l	(sp)+,d1-d7/a0-a6	;pull entry registers
	rts				;return d0 = error_flag
;----------------------------------------------------------------------------
e_input_ob:
	move.l	ob_xy(a0),e_pos_ix
	bsr	e_revive_XY
	move.l	ob_spec(a0),a0
e_conrs:
	movem.l	d1-d7/a0-a6,-(sp)	;push entry registers
	move.l	a0,a4			;a4 -> ReadBuffer struct
	movem	e_pos_ix(pc),d6/d7	;d6/d7 = start cursor pos
	movem.l	rb_max(a4),d3/a3	;d3/a3 = rb_max.rb_len,rb_buf
	move	d3,d4			;d4 = rb_len
	swap	d3			;d3 = rb_max
	moveq	#$7F,d0
	cmp	d0,d3
	bls.s	.keep_rb_max
	move	d0,d3
.keep_rb_max:
	cmp	d0,d4
	bls.s	.keep_rb_len
	move	d0,d4
.keep_rb_len:
	move	d6,d5			;d5 = d6 = column position
.main_loop:
	move	d6,d0			;d0 = d6 = base column position
	move	d7,d1			;d1 = d7 = base row position
	bsr	e_goto_XY	
	tst	d4			;rb_len non_zero ?
	beq.s	.displayed
	clr.b	(a3,d4)			;terminate buffer string
	display	(a3)			;display string
.displayed:
	move	d3,d0			;d0 = rb_max
	sub	d4,d0			;d0 = rb_max-rb_len
	ble.s	.padded
	lea	spaces_end(pc),a0
	sub	d0,a0
	display	(a0)			;display spaces to pad field to max
.padded:
.reposition_loop:
	move	d5,d0			;d0 = d5 = current column position
	move	d7,d1			;d1 = d7 = base row position
	bsr	e_goto_XY		;set cursor to current position
.input_loop:
	bsr	e_show_curse		;show cursor
	gemdos	Crawcin			;read raw character without echo
	bsr	e_hide_curse		;hide cursor
	move.l	d0,d1			;d1 = d0 = scancode.ascii
	swap	d1			;d1 = ascii.scancode
	cmp.b	#$53,d1			;Scancode Delete ?
	beq.s	.got_DEL
	cmp.b	#1,d1			;scancode Escape ?
	bne.s	.not_ESC
.got_ESC:
	clr	d4			;zero rb_len
	clr	d5			;zero position
	bra	.main_loop		;loop back
;-------------------------------------
.got_DEL:
	xbios	Kbshift,?
	and	#3,d0
	beq.s	.normal_DEL
.shift_DEL:
	move	d5,d4			;rb_len = position
	bra	.main_loop		;loop back
;-------
.normal_DEL:
	move	d4,d1			;d1 = rb_len
	sub	d5,d1			;d1 = rb_len-pos  == affected char count
	bls.s	.input_loop		;outside string DEL is meaningless
	lea	(a3,d5),a1		;a1 -> destination for changes
	subq	#1,d1			;d1 = moved char count
	ble.s	.DEL_moved
	lea	1(a1),a0		;a0 = source for move
	subq	#1,d1			;d1 = dbra count for move
.DEL_loop:
	move.b	(a0)+,(a1)+
	dbra	d1,.DEL_loop
.DEL_moved:
	subq	#1,d4			;decrement rb_len
	bra	.main_loop		;loop back
;-------------------------------------
.not_ESC:
	cmp.b	#$0E,d1			;scancode backspace ?
	bne.s	.not_backspace
.got_backspace:
	xbios	Kbshift,?
	and	#3,d0
	beq.s	.normal_BSP
.shift_BSP:
	tst	d5
	ble.s	.input_loop
	move	d4,d1			;d1 = rb_len
	sub	d5,d1			;d1 = rb_len-pos  == moved char count
	bls.s	.got_ESC		;right of string BSP deletes all
	move	d1,d4
	lea	(a3),a1
	lea	(a3,d5),a0
.BSP_loop:
	move.b	(a0)+,(a1)+
	dbra	d1,.BSP_loop
	clr	d5
	bra	.main_loop		;loop back
;-------
.normal_BSP:
	subq	#1,d5			;decrement position
	bhs.s	.got_DEL		;go delete char at backed position
	addq	#1,d5
	bra	.input_loop
;-------------------------------------
.not_backspace:
	cmp.b	#$4B,d1			;scancode curse_L ?
	bne.s	.not_curse_L
.curse_L:
	tst	d5			;position at base ?
	beq	.input_loop		;then no movement left is allowed
	xbios	Kbshift,?
	and	#3,d0
	beq.s	.normal_curse_L
.shift_curse_L:
	clr	d5
	bra	.reposition_loop
;-------
.normal_curse_L:
	subq	#1,d5			;decrement position
	bra	.reposition_loop	;loop_back
;-------------------------------------
.not_curse_L:
	cmp.b	#$4D,d1			;scancode curse_R ?
	bne.s	.not_curse_R
.curse_R:
	cmp	d4,d5			;position at rb_len ?
	bhs	.input_loop		;then no movement right is allowed
	xbios	Kbshift,?
	and	#3,d0
	beq.s	.normal_curse_R
.shift_curse_R:
	move	d4,d5
	bra	.reposition_loop
;-------
.normal_curse_R:
	addq	#1,d5			;increment position
	bra	.reposition_loop	;loop_back
;-------------------------------------
.not_curse_R:
	cmp.b	#$48,d1			;scancode curse_U ?
	beq.s	.end_conrs
	cmp.b	#$50,d1			;scancode curse_D ?
	beq.s	.end_conrs
	cmp.b	#$1C,d1			;scancode Return ?
	beq.s	.end_conrs
	cmp.b	#$72,d1			;scancode Enter ?
	beq.s	.end_conrs
	cmp.b	#$0F,d1			;scancode Tab ?
	beq.s	.end_conrs
.unknown_CTL:
	tst	d0			;is the ascii code NUL
	beq	.input_loop		;then go get another key
.normal_char:
	cmp	d3,d5			;at rb_max ?
	blo.s	.not_atmax		;else go deal with insertion
	move.b	d0,-1(a3,d5)		;overwrite last char
	bra	.main_loop		;loop back
;-------
.not_atmax:
	cmp	d3,d4
	blo.s	.not_inmax
	move	d3,d4
	subq	#1,d4
.not_inmax:
	lea	1(a3,d4),a1		;a1 -> beyond destination for changes
	move	d4,d1			;d1 = rb_len
	sub	d5,d1			;d1 = rb_len-pos  == moved char count
	bls.s	.norm_moved		;outside string no move is needed
	lea	-1(a1),a0		;a0 -> source for move
	subq	#1,d1			;d1 = dbra count for move
.norm_loop:
	move.b	-(a0),-(a1)
	dbra	d1,.norm_loop
.norm_moved:
	move.b	d0,-(a1)		;store new char in buffer
	addq	#1,d4			;increment rb_len
	addq	#1,d5			;increment position
	bra	.main_loop
;-------------------------------------
.end_conrs:
	move	d4,rb_len(a4)		;store resulting rb_len
	move	d4,d0			;d0 = resulting rb_len
	movem.l	(sp)+,d1-d7/a0-a6	;pull entry registers
	rts				;return d0 = terminating scancode.ascii
;----------------------------------------------------------------------------
e_conws:
	movem.l	d0/a3,-(sp)		;push entry d0/a3
	move.l	a0,a3			;a3 -> string
	bra.s	.next_char		;jump into the loop
;-------
.loop:
	bsr.s	e_conout		;output the character
.next_char:
	move.b	(a3)+,d0		;d0 = next ascii
	bne.s	.loop			;loop until terminator reached
	movem.l	(sp)+,d0/a3		;pull entry d0/a3
	rts				;return
;----------------------------------------------------------------------------
e_conout:
	move.l	e_conout_p(pc),-(sp)	;push -> current emulation handler
	rts				;goto current emulation handler
;----------------------------------------------------------------------------
e_NRM_handler:
	movem.l	d3/a3/a4,-(sp)		;push entry d3/a3/a4  (a3 as dummy)
	move	d0,d3			;d3 = ascii code
	add	d3,d3			;d3 = CTL index
	move	e_NRM_vt52_t(pc,d3),d3	;d3 = offset to CTL code
	lea	e_NRM_vt52_t(pc,d3),a3	;a3 -> CTL code
	move.l	a3,2*4(sp)		;replace stacked dummy with -> CTL code
	movem.l	(sp)+,d3/a3		;pull entry d3/a3
	rts				;goto CTL code
;-------------------------------------
e_NRM:
	movem.l	d1/a0,-(sp)		;push entry d1/a0
	move.l	e_buffer_p(pc),a0	;a0 -> buffer
	move	e_bufpos(pc),d1		;d1 = position
	cmp	#MAX_e_bufpos,d1
	blo.s	.have_bufpos
	bsr.s	e_flush			;flush buffer
	move	e_bufpos(pc),d1		;d1 = zero position
.have_bufpos:
	move.b	d0,(a0,d1)		;store ascii in buffer
	addq	#1,d1
	move	d1,e_bufpos		;update position
	movem.l	(sp)+,d1/a0		;pull entry d1/a0
e_NOP:
	rts				;return
;-------------------------------------
e_flush:
	tst	e_bufpos		;test character count
	beq.s	.exit_direct		;exit if buffer empty
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	move	e_bufpos(pc),d2		;d2 = character count
	move.l	e_buffer_p(pc),a2	;a2 -> buffer
	clr.b	(a2,d2)			;terminate buffer string
	gemdos	Cconws,(a2)		;display buffer string
	clr	e_bufpos		;clear character count
	movem.l	(sp)+,d0-d2/a0-a2	;pull entry d0-d2/a0-a2
.exit_direct:
	rts				;return
;-------------------------------------
e_NRM_vt52_t:
.ref:
	dcb.w	$08-$00,e_NRM-.ref		;^@..^G normal
	dc_wref	e_BS,e_HT,e_LF,e_VT,e_FF,e_CR	;^H..^M control
	dcb.w	$1B-$0E,e_NRM-.ref		;$0E..$1A normal
	dc_wref	e_ESC				;$1B escape
	dcb.w	$7F-$1C,e_NRM-.ref		;$1C..$7E normal
	dc_wref	e_DEL				;$7F control
	dcb.w	$100-$80,e_NRM-.ref		;$80..$FF normal
;----------------------------------------------------------------------------
e_ESC_handler:
	move.l	#e_NRM_handler,e_conout_p	;prep NRM handling
	movem.l	d3/a3/a4,-(sp)		;push entry d3/a3/a4  (a3 as dummy)
	move	d0,d3			;d3 = ascii code
	add	d3,d3			;d3 = ESC index
	move	e_ESC_vt52_t(pc,d3),d3	;d3 = offset to ESC code
	lea	e_ESC_vt52_t(pc,d3),a3	;a3 -> ESC code
	move.l	a3,2*4(sp)		;replace stacked dummy with -> ESC code
	movem.l	(sp)+,d3/a3		;pull entry d3/a3
	rts				;goto ESC code
;-------------------------------------
e_ESC_vt52_t:
.ref:
	dcb.w	$40-$00,e_NOP-.ref				;$00..$3F undefined
	dc_wref	e_NOP,e_curse_U,e_curse_D,e_curse_R		;@ABC
	dc_wref	e_curse_L,e_clr_screen,e_NOP,e_NOP		;DEFG
	dc_wref	e_home_curse,e_move_up,e_clr_EOS,e_clr_EOL	;HIJK
	dc_wref	e_insert_line,e_erase_line,e_NOP,e_NOP		;LMNO
	dcb.w	'Y'-'P',e_NOP-.ref				;P..X undefined
	dc_wref	e_goto_XY_1					;Y
	dcb.w	'b'-'Z',e_NOP-.ref				;Z..a undefined
	dc_wref	e_set_fg_col_1,e_set_bg_col_1,e_clr_BOS		;bcd
	dc_wref	e_show_curse,e_hide_curse,e_NOP,e_NOP		;efgh
	dc_wref	e_NOP,e_push_curse,e_pull_curse,e_cut_left	;ijkl
	dc_wref	e_NOP,e_NOP,e_clr_BOL				;mno
	dc_wref	e_inverse_on,e_inverse_off			;pq
	dcb.w	'v'-'r',e_NOP-.ref				;rstu undefined
	dc_wref	e_set_wrapmode,e_set_lockmode			;vw
	dcb.w	$100-$78,e_NOP-.ref				;x..$FF undefined
;----------------------------------------------------------------------------
e_BS:
	move	#BS,-(sp)
	subq	#1,e_col_ix
	bra.s	e_CTL_common
;-------------------------------------
e_HT:
	move	#HT,-(sp)
	addq	#8,e_col_ix
	and	#-8,e_col_ix
	bra.s	e_CTL_common
;-------------------------------------
e_LF:
	move	#LF,-(sp)
	addq	#1,e_row_ix
	bra.s	e_CTL_common
;-------------------------------------
e_VT:
	bra.s	e_curse_U
;-------------------------------------
e_FF:
	bra	e_clr_screen
;-------------------------------------
e_CR:
	move	#CR,-(sp)
	clr	e_col_ix
	bra.s	e_CTL_common
;-------------------------------------
e_DEL:
	move	#$7F,-(sp)
e_CTL_common:
	bsr	e_flush			;flush buffered string (if any)
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	gemdos	Cconout,6*4(sp)		;output CTL code (from stack)
	move	e_col_ix(pc),d0
	bpl.s	.keep_col
	clr	e_col_ix		;adjust column index
.keep_col:
	move	e_row_ix(pc),d0
	bpl.s	.keep_row
	clr	e_row_ix		;adjust row index
.keep_row:
	movem.l	(sp)+,d0-d2/a0-a2	;pull entry d0-d2/a0-a2
	addq	#2,sp			;pop CTL code off stack
	rts				;return with all regs intact
;-------------------------------------
e_ESC:
	move.l	#e_ESC_handler,e_conout_p	;prep ESC handling
	rts				;return with all regs intact
;----------------------------------------------------------------------------
e_curse_U:
	move.b	#'A',-(sp)
	subq	#1,e_row_ix
	bra	e_ESC_1_common
;-------
e_curse_D:
	move.b	#'B',-(sp)
	addq	#1,e_row_ix
	bra	e_ESC_1_common
;-------
e_curse_R:
	move.b	#'C',-(sp)
	addq	#1,e_col_ix
	bra	e_ESC_1_common
;-------
e_curse_L:
	move.b	#'D',-(sp)
	subq	#1,e_col_ix
	bra	e_ESC_1_common
;-------
e_clr_screen:
	move.b	#'E',-(sp)
	clr.l	e_pos_ix
	bra	e_ESC_1_common
;-------
e_home_curse:
	move.b	#'H',-(sp)
	clr.l	e_pos_ix
	bra	e_ESC_1_common
;-------
e_move_up:
	move.b	#'I',-(sp)
	subq	#1,e_row_ix
	bra	e_ESC_1_common
;-------
e_clr_EOS:
	move.b	#'J',-(sp)
	bra	e_ESC_1_common
;-------
e_clr_EOL:
	move.b	#'K',-(sp)
	bra	e_ESC_1_common
;-------
e_insert_line:
	move.b	#'L',-(sp)
	bra.s	e_ESC_1_common
;-------
e_erase_line:
	move.b	#'M',-(sp)
	bra.s	e_ESC_1_common
;-------
e_clr_BOS:
	move.b	#'d',-(sp)
	bra.s	e_ESC_1_common
;-------
e_show_curse:
	move.b	#'e',-(sp)
	bra.s	e_ESC_1_common
;-------
e_hide_curse:
	move.b	#'f',-(sp)
	bra.s	e_ESC_1_common
;-------
e_push_curse:
	move.b	#'j',-(sp)
	move.l	e_pos_ix(pc),e_push_pos_ix
	bra.s	e_ESC_1_common
;-------
e_pull_curse:
	move.b	#'k',-(sp)
	move.l	e_push_pos_ix(pc),e_pos_ix
	bra.s	e_ESC_1_common
;-------
e_cut_left:
	move.b	#'l',-(sp)
	clr	e_col_ix
	bra.s	e_ESC_1_common
;-------
e_clr_BOL:
	move.b	#'o',-(sp)
	bra.s	e_ESC_1_common
;-------
e_inverse_on:
	move.b	#'p',-(sp)
	bset	#7,e_mode
	bra.s	e_ESC_1_common
;-------
e_inverse_off:
	move.b	#'q',-(sp)
	bclr	#7,e_mode
	bra.s	e_ESC_1_common
;-------
e_set_wrapmode:
	move.b	#'v',-(sp)
	bset	#7,e_mode+1
	bra.s	e_ESC_1_common
;-------
e_set_lockmode:
	move.b	#'w',-(sp)
	bclr	#7,e_mode+1
e_ESC_1_common:
	move.b	(sp)+,ESC_1_cmd_char	;store ascii after ESC char in ESC_1_s
	bsr	e_flush			;flush buffered string (if any)
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	gemdos	Cconws,ESC_1_s(pc)	;output escape sequence
	move	e_col_ix(pc),d0
	bpl.s	.keep_col
	clr	e_col_ix
.keep_col:
	move	e_row_ix(pc),d0
	bpl.s	.keep_row
	clr	e_row_ix
.keep_row:
	movem.l	(sp)+,d0-d2/a0-a2	;pull entry d0-d2/a0-a2
	rts				;return with all regs intact
;-------------------------------------
e_set_fg_col_1:
	move.l	#e_set_fg_col_2,e_conout_p	;prep fg_color handling
	rts
;-------------------------------------
e_set_fg_col_2:
	move.l	#e_NRM_handler,e_conout_p	;prep NRM handling
e_set_fg_color:				;d0 == foreground colour [0..15]
	move.b	#'b',ESC_2_cmd_char	;store ascii after ESC char in ESC_2_s
	move.b	d0,e_fg_color
	bra.s	e_ESC_2_common
;-------------------------------------
e_set_bg_col_1:
	move.l	#e_set_bg_col_2,e_conout_p	;prep bg_color handling
	rts				;return
;-------------------------------------
e_set_bg_col_2:
	move.l	#e_NRM_handler,e_conout_p	;prep NRM handling
e_set_bg_color:				;d0 == background colour [0..15]
	move.b	#'c',ESC_2_cmd_char	;store ascii after ESC char in ESC_2_s
	move.b	d0,e_bg_color
e_ESC_2_common:
	bsr	e_flush			;flush buffered string (if any)
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	and.b	#$0F,d0			;limit to colour code 0..15
	add.b	#'0',d0			;offset colour code to visible char
	move.b	d0,ESC_2_color_char	;store as colour code in ESC_2_s
	gemdos	Cconws,ESC_2_s(pc)	;output escape sequence
	movem.l	(sp)+,d0-d2/a0-a2	;pull entry d0-d2/a0-a2
	rts				;return with all regs intact
;-------------------------------------
e_goto_XY_1:
	move.l	#e_goto_XY_2,e_conout_p	;prep goto_XY row handling
	rts				;return
;-------------------------------------
e_goto_XY_2:
	move.l	#e_goto_XY_3,e_conout_p	;prep goto_XY column handling
	sub.b	#' ',d0			;convert ascii to position code
	and	#$FF,d0
	move	d0,e_row_ix		;store as new row index
	rts				;return
;-------------------------------------
e_goto_XY_3:
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	move.l	#e_NRM_handler,e_conout_p	;prep NRM handling
	sub.b	#' ',d0			;convert ascii to position code
	and	#$FF,d0
	move	d0,e_col_ix		;store as new column index
	movem	e_pos_ix(pc),d0/d1
	bra.s	e_goto_XY_common
;-------------------------------------
e_goto_XY:				;d0 == column  d1 == row
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	movem	d0/d1,e_pos_ix
e_goto_XY_common:
	bsr	e_flush			;flush buffer contents (if any)
	add.b	#' ',d0			;offset X position code to visible char
	move.b	d0,ESC_Y_column_char	;store as column char in ESC_Y_s
	add.b	#' ',d1			;offset Y position code to visible char
	move.b	d1,ESC_Y_row_char	;store as row char in ESC_Y_s
	gemdos	Cconws,ESC_Y_s(pc)	;output escape Y sequence
	movem.l	(sp)+,d0-d2/a0-a2	;pull entry d0-d2/a0-a2
	rts				;return with all regs intact
;-------------------------------------
e_revive_XY:
	movem.l	d0-d2/a0-a2,-(sp)	;push entry d0-d2/a0-a2
	movem	e_pos_ix(pc),d0/d1
	bra.s	e_goto_XY_common
;----------------------------------------------------------------------------
;End of:	vt52 emulator
;----------------------------------------------------------------------------
;Start of:	fix_ram		subroutine for game boot conditions
;----------------------------------------------------------------------------
fix_ram_sub:
	move.l	a6,a4
	sub.l	#512*Kb,a4		;a4 -> FIX_RAM
	lea	FAL_GAME_bin(pc),a0	;a0 -> FAL_GAME program file
	lea	-ph_textbeg(a4),a1	;a1 -> place to load program
	move	#FAL_GAME_size,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	lea	(a4),a0			;a0 -> textbeg
	lea	-ph_textbeg(a4),a1	;a1 -> program header
	bsr.s	relocate		;relocate program
	jmp	(a4)			;jump to program
;----------------------------------------------------------------------------
	include	bs_comp\RELOCATE.S
;----------------------------------------------------------------------------
FAL_GAME_bin:
	incbin	FAL_GAME.BIN
FAL_GAME_end:
FAL_GAME_size	=	FAL_GAME_end-FAL_GAME_bin
;----------------------------------------------------------------------------
;End of:	fix_ram		subroutine for game boot conditions
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
loc_bootdev:
	dc.w	2
;-------------------------------------
AUTO_FAKEBOOT_SET_s:
	dc.b	'AUTO\'
FAKEBOOT_SET_s:
	dc.b	'FAKEBOOT.SET',NUL
FAKEBOOT_INF_s:
	dc.b	'FAKEBOOT.INF',NUL
;-------------------------------------
;Start of data for vt52 emulator
;-------------------------------------
ESC_1_s:
	dc.b	ESC
ESC_1_cmd_char:
	dc.b	'A',NUL
ESC_2_s:
	dc.b	ESC
ESC_2_cmd_char:
	dc.b	'b'
ESC_2_color_char:
	dc.b	'0',NUL
ESC_Y_s:
	dc.b	ESC,'Y'
ESC_Y_row_char:
	dc.b	' '
ESC_Y_column_char:
	dc.b	' ',NUL
;-------------------------------------
;End of data for vt52 emulator
;-------------------------------------
cachable_head_s:
	dc.b	'#E1 ',NUL
uncachable_head_s:
	dc.b	'#E0 ',NUL
;-------------------------------------
title_mess_s:
	dc.b	ESC,'q',ESC,'E----',ESC,'p'
	dc.b	 ' FAKEBOOT 1.00 by U.R.Andersson ',ESC,'q----',CR,LF
	dc.b	CR,LF,NUL
.end:
title_mess_len	= .end-title_mess_s
;-------------------------------------
def_menu_title_s:
	dc.b	'Standard FakeBoot menu:  ',NUL
	EVEN
;-------------------------------------
spaces_128_rb:
	dc_rb	128,128,spaces_128
;-------------------------------------
menu_1:
	dc_ob	menu_entry_t,0,0,title_mess_s,G_STRING,NONE,NORMAL
;-------------------------------------
	EVEN
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
prog_size:	ds.l	1
;-------------------------------------
;Start of space for vt52 emulator
;-------------------------------------
;VT52 emulation state is defined by 24 bytes (6 longs) below
;
e_mode:		ds.w	1			;b15 == inverse,  b7 == wrap
e_colors:	;two bytes below as one word
e_fg_color:	ds.b	1
e_bg_color:	ds.b	1
e_pos_ix:	;two words below as one long
e_col_ix:	ds.w	1
e_row_ix:	ds.w	1
e_push_pos_ix:	ds.l	1
e_conout_p:	ds.l	1
e_buffer_p:	ds.l	1
e_bufpos:	ds.w	1
e_status:	ds.w	1
;-------------------------------------
e_curr_ob:	ds.w	1
e_curr_fm:	ds.l	1
;-------------------------------------
e_buffer_1:	ds.b	((MAX_e_bufpos+3)&-2)
spaces_128:	ds.b	128
spaces_end:	ds.w	1
;-------------------------------------
;End of space for vt52 emulator
;-------------------------------------
input_buf_1:	ds.b	130
abort_sp:	ds.l	1
menu_title_p:	ds.l	1			;-> title string defined by SET
menu_entry_cnt:	ds.w	1			;count of entries defined by SET
menu_entry_t:	ds.b	(MAX_MENU_ENTRIES+1)*(sizeof_ob+sizeof_rb)
;-------------------------------------
loc_stack:	ds.l	2048
loc_stk_top:	ds.l	4
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	FAKEBOOT.S
;----------------------------------------------------------------------------
