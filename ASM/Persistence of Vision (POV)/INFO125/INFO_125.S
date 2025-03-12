*******************
*                 *
* P.O.V. Info 125 *
*                 *
*******************

***********
* Options *
***********

;	OPT	l-		; Produce executable.
	OPT	c+		; Case sensitivity on.
	OPT	d-		; Debug off.
	OPT	m-		; Don't expand macros in a listing.
	OPT	o+		; All optimisations on.
	OPT	ow+		; All optimisation warnings on.
	OPT	ow2-		; Don't report zero offset opts.
	OPT	ow3-		; Don't report long to word opts.
	OPT	p-		; Not position-independent code.
	OPT	s-		; No symbol table in a listing.
	OPT	t+		; Type checking on.
	OPT	w+		; Warnings on.
	OPT	x-		; Extended debug off.


	include	"SYSTEMEQ.S"

***********
* Equates *
***********

TAB	equ	9
LF	equ	10
CR	equ	13
ESC	equ	27
BS	equ	127

SCR_BASE	equ	$44e
MAX_LINES	equ	8000
MAX_FIND_LEN	equ	(80-11)


**********
* Macros *
**********

MoveCursorTo	MACRO
	move.w	\1,d0
	move.w	\2,d1
	bsr	calc_cursor_addr
	ENDM


KeyRoutEntry	MACRO
	dc.w	\1
	dc.l	\2
	ENDM


	SECTION	TEXT

*************
*	    *
* Main code *
*	    *
*************

start
	lea	clock,a0
.clear
	clr.w	(a0)+
	cmp.l	#finish,a0
	blt.s	.clear

	bsr	super_mode
	bsr	disable_mj
	bsr	wait_kbd
	bsr	get_res
	bsr	med_res
	bsr	save_palette
	bsr	set_palette
	bsr	start_tune
	bsr	setup
	bsr	set_sky

	move.l	SCR_BASE,cur_addr
	bsr	process_text
	bsr	show_title
	bsr	redraw_screen

.loop
	bsr	process_key
	tst.b	finished
	beq.s	.loop

	bsr	shutdown
	bsr	stop_tune
	bsr	restore_palette
	bsr	old_res
	bsr	enable_mj
	bsr	user_mode
.flush
	move.w	#11,-(sp)
	trap	#1
	addq.w	#2,sp
	tst.l	d0
	beq.s	.exit
	move.w	#7,-(sp)
	trap	#1
	addq.w	#2,sp
	bra.s	.flush
.exit
	clr.w	-(sp)
	trap	#1


************
*	   *
* Routines *
*	   *
************

wait_kbd
	move.w	#-1,-(sp)
	move.w	#11,-(sp)
	trap	#13
	addq.w	#4,sp
	and.b	#$f,d0
	bne.s	wait_kbd
	rts


setup
	move.w	sr,-(sp)
	or.w	#$700,sr

	lea	vector_bak,a0
	move.l	VBL_ISR,(a0)+
	move.l	KBD_ISR,(a0)+
	move.l	TimerB_ISR,(a0)+

	lea	mfp_bak,a0
	move.b	IERA,(a0)+
	move.b	IERB,(a0)+
	move.b	IMRA,(a0)+
	move.b	IMRB,(a0)+
	move.b	VR,(a0)+
	move.b	TBCR,(a0)+
	move.b	TBDR,(a0)+

	move.l	#new_vbl,VBL_ISR
	move.l	#new_kbd,KBD_ISR
	move.l	#raster,TimerB_ISR

	clr.b	TBCR
	move.b	#$01,IERA
	move.b	#$01,IMRA
	move.b	#$40,IERB
	move.b	#$40,IMRB
	bclr.b	#3,VR

	move.w	(sp)+,sr
	rts


shutdown
	move.w	sr,-(sp)
	or.w	#$700,sr

	lea	vector_bak,a0
	move.l	(a0)+,VBL_ISR
	move.l	(a0)+,KBD_ISR
	move.l	(a0)+,TimerB_ISR

	lea	mfp_bak,a0
	move.b	(a0)+,IERA
	move.b	(a0)+,IERB
	move.b	(a0)+,IMRA
	move.b	(a0)+,IMRB
	move.b	(a0)+,VR
	move.b	(a0)+,TBCR
	move.b	(a0)+,TBDR

	move.w	(sp)+,sr
	rts


vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


get_res
	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	d0,res_bak
	rts

med_res
	move.w	#1,-(sp)
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts

old_res
	move.w	res_bak,-(sp)
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


save_palette
	movem.l	Palette0,d0-d7
	movem.l	d0-d7,old_pal
	rts

set_palette
	movem.l	new_pal,d0-d1
	movem.l	d0-d1,Palette0
	rts

restore_palette
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,Palette0
	rts


disable_mj
	pea	mj_off
	move.w	#1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.w	#8,sp
	rts

enable_mj
	pea	mj_on
	move.w	#1,-(sp)
	move.w	#25,-(sp)
	trap	#14
	addq.w	#8,sp
	rts


super_mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,save_stk
	rts

user_mode
	move.l	save_stk,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	rts


new_vbl
	clr.w	vsync_flag

	clr.b	TBCR
	move.b	#8,TBDR
	move.l	#raster,TimerB_ISR
	move.b	#8,TBCR

	bsr	tune+8
	rte


raster
	move.w	#$000,Palette2
	clr.b	TBCR
	move.b	#1,TBDR
	move.b	#8,TBCR
	move.w	#$000,Palette0
	move.l	#(*+10),TimerB_ISR
	rte

	REPT	(192-1)
	move.w	#$000,Palette2
	move.l	#(*+10),TimerB_ISR
	rte
	ENDR

	clr.b	TBCR
	rte


set_sky
	lea	sky_cols(pc),a0
	lea	raster(pc),a1
	move.w	#Palette2,d0
	move.w	#192-1,d1
.loop
	cmp.w	(a1)+,d0
	bne.s	.loop
	move.w	(a0)+,-4(a1)
	dbf	d1,.loop
	rts


***************
* Subroutines *
***************

*****************
*		*
* Find routines *
*		*
*****************

find
	MoveCursorTo	#0,#11		; Show message box.
	lea	find_box_line1,a6
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	find_box_line2,a6
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	find_box_line3,a6
	bsr	special_line

	bsr.s	input_find_text
	tst.b	find_string		; Anything typed for search string?
	beq.s	.no_string		; No!
	bsr	do_search
	tst.b	found			; Found string?
	bne.s	.found			; Yes!
	MoveCursorTo	#0,#12		; No, show 'Not found!' message
	lea	not_found_mess,a6	; and sound a beep!
	bsr	special_line
	bsr	wait_for_key
.found
	bsr	redraw_screen
	rts
.no_string
	bsr	redraw_screen
	rts


input_find_text
	clr.b	key_val			; Clear key 'buffer'.
	lea	find_string,a6
	moveq	#0,d7			; Input character counter.
	MoveCursorTo	#9,#12		; Show previous search string.
	move.l	a6,a5
.old_string
	move.b	(a5)+,d0		; Get char.
	beq.s	.show_cursor		; If null then were at the end!
	bsr	special_char		; Show char.
	addq.w	#1,d7			; Increment char counter.
	bra.s	.old_string
.show_cursor
	move.w	d7,d0			; Show cursor.
	add.w	#9,d0
	MoveCursorTo	d0,#12
	move.w	#174,d0
	bsr	special_char
	move.w	d7,d0
	add.w	#9,d0
	MoveCursorTo	d0,#12
.loop
	bsr	wait_for_key
	bsr	convert_to_ascii
	cmp.b	#CR,d0			; Return key?
	beq.s	.done			; Yes!
	cmp.b	#BS,d0			; Backspace?
	beq.s	.remove_char		; Yes!
	cmp.b	#' ',d0			; Is key a printable character?
	blt.s	.loop			; No!
	cmp.b	#'~',d0
	bgt.s	.loop			; No!
.char
	cmp.w	#MAX_FIND_LEN,d7	; Yes, is string full?
	bge.s	.full			; Yes!
	move.b	d0,(a6,d7)		; Store char.
	bsr	special_char		; Show it.
	addq.w	#1,d7			; Increment counter.
	bra.s	.show_cursor
.full
	bra.s	.loop
.remove_char
	tst.w	d7			; Is string empty?
	beq.s	.loop			; Yes!
	move.w	d7,d0			; No, overwrite last char
	add.w	#9,d0			; with a space.
	MoveCursorTo	d0,#12
	moveq	#' ',d0
	bsr	special_char
	subq.w	#1,d7			; Decrement counter.
	bra.s	.show_cursor
.done
	move.w	d7,d0			; Remove cursor.
	add.w	#9,d0
	MoveCursorTo	d0,#12
	moveq	#' ',d0
	bsr	special_char
	clr.b	(a6,d7)			; Terminate string.
	rts


do_search
	clr.b	found			; Not found!
	lea	line_ptrs,a4
	move.w	top_line,d6		; Search from top screen line.
.start_line
	move.w	d6,d0			; Get current line's text
	lsl.w	#2,d0			; address from line
	move.l	(a4,d0),a6		; pointer table.
	move.l	a6,d0			; Is address valid?
	beq.s	.not_found		; No!
	move.l	a6,a3
.compare
	lea	find_string,a5
	move.l	a3,a6			; Address of next char in line.
.loop
	move.b	(a5)+,d1		; End of search string?
	beq.s	.found			; Yes, then found string!
	move.b	(a6)+,d0		; Get char from text.
	beq.s	.next_line		; Is it end of line?
	cmp.b	d1,d0			; Is it same as search char?
	beq.s	.loop			; Yes!
	cmp.b	#'a',d1			; If text char is lower case,
	blt.s	.next_char		; make it upper case.
	cmp.b	#'z',d1
	bgt.s	.next_char
	sub.b	#'a'-'A',d1
	cmp.b	d1,d0			; Is text char same as search char?
	beq.s	.loop			; Yes!
.next_char
	addq.w	#1,a3			; Move to next char in line.
	bra.s	.compare		; No!
.found
	st	found			; Found it!
	move.w	d6,top_line
.not_found
	rts
.next_line
	addq.w	#1,d6			; End of line reached,
	bra.s	.start_line		; increment line number.


********************************************
*					   *
* Move to different place in text routines *
*					   *
********************************************

top_of_text
	tst.w	top_line		; Is display already at
	beq.s	.end			; top of text?
	clr.w	top_line		; No, move it there!
	bsr	redraw_screen
.end
	rts


bot_of_text
	move.w	top_line,d0		; Is display already at
	cmp.w	max_lines,d0		; bottom of text?
	bge.s	.end			; Yes!
	move.w	max_lines,top_line	; No, move it there!
	bsr	redraw_screen
.end
	rts


page_up
	tst.w	top_line		; Is display already at
	beq.s	.end			; top of text?
	moveq	#22-1,d0		; No, move up 22 lines.
.loop
	tst.w	top_line		; Is display already at
	beq.s	.done			; top of text?
	subq.w	#1,top_line		; No, decrement top line.
	dbf	d0,.loop
.done
	bsr	redraw_screen
.end
	rts


page_down
	move.w	top_line,d0		; Is display already at
	cmp.w	max_lines,d0		; bottom of text?
	bge.s	.end			; Yes!
	moveq	#22-1,d1		; No, move it doen 22 lines.
.loop
	move.w	top_line,d0		; Is display already at
	cmp.w	max_lines,d0		; bottom of text?
	bge.s	.done			; Yes!
	addq.w	#1,top_line		; No, increment top line!
	dbf	d1,.loop
.done
	bsr.s	redraw_screen
.end
	rts


line_up
	tst.w	top_line		; Is display already
	beq.s	.end			; at top of text?
	subq.w	#1,top_line		; No, decrement top line.
	bsr	scroll_down
	MoveCursorTo	#0,#1		; Show new top line.
	move.w	top_line,cur_line
	bsr.s	draw_line
.end
	rts


line_down
	move.w	top_line,d0		; Is display already
	cmp.w	max_lines,d0		; at bottom of text?
	bge.s	.end			; Yes!
	addq.w	#1,top_line		; No, increment top line.
	bsr	scroll_up
	MoveCursorTo	#0,#23		; Display new bottom line.
	move.w	top_line,d0
	add.w	#22,d0
	move.w	d0,cur_line
	bsr.s	draw_line
.end
	rts


************************************
*				   *
* Direct access to screen routines *
*				   *
************************************

redraw_screen
	move.w	top_line,cur_line	; Text line number.
	moveq	#1,d7			; Screen line number.
.loop
	MoveCursorTo	#0,d7		; Show current line.
	bsr.s	draw_line
	addq.w	#1,cur_line		; Increment text line number.
	addq.w	#1,d7			; Increment screen line number.
	cmp.w	#24,d7			; At bottom of screen?
	blt.s	.loop			; No!
	rts				; Yes!


draw_line
	move.w	cur_line,d0
	lsl.w	#2,d0			; Get current line's text
	lea	line_ptrs,a6		; address from line
	move.l	(a6,d0),a6		; pointer table.
	move.l	a6,d0			; Is address valid?
	beq.s	.done			; No!
.loop
	move.b	(a6)+,d0		; Get char.
	beq.s	.done			; If null then end of line.
	cmp.b	#TAB,d0
	bne.s	.not_tab
	move.w	cur_xpos,d1
	addq.w	#8,d1
	and.w	#$fff8,d1
	sub.w	cur_xpos,d1
	subq.w	#1,d1
.tabs
	moveq	#' ',d0
	bsr.s	text_char		; Show char.
	dbf	d1,.tabs
.not_tab
	bsr.s	text_char		; Show char.
	bra.s	.loop
.done
	cmp.w	#80,cur_xpos		; Cursor past end of line?
	bge.s	.end			; Yes!
	moveq	#' ',d0			; No, show a space.
	bsr.s	text_char
	bra.s	.done
.end
	rts


text_char
	and.w	#$ff,d0			; Only chars 0 to 255.
	lsl.w	#3,d0			; Get char pixel definition
	lea	font,a0			; in font table.
	add.w	d0,a0
	move.l	cur_addr,a1		; Get cursor screen address.
	moveq	#0,d0
OFF	set	0
	REPT	8			; Char is 8 lines high.
	move.b	(a0)+,d0		; Get pixel line definition.
	movep.w	d0,OFF(a1)		; Blast it onto 2 plane screen.
OFF	set	OFF+160
	ENDR
.cont
	addq.w	#1,a1			; Increment cursor screen
	move.w	a1,d0			; address - is it into
	and.w	#1,d0			; next 16 pixel column?
	bne.s	.no_bump		; No!
	addq.w	#2,a1			; Yes, fix address!
.no_bump
	move.l	a1,cur_addr		; Store cursor screen address.
	addq.w	#1,cur_xpos		; Increment cursor X position.
	rts


special_line
	move.b	(a6)+,d0		; Get char.
	beq.s	.done			; If null then end of line.
	bsr.s	special_char		; Show char.
	bra.s	special_line
.done
	cmp.w	#80,cur_xpos		; Cursor past end of line?
	bge.s	.end			; Yes!
	moveq	#' ',d0			; No, show a space.
	bsr.s	special_char
	bra.s	.done
.end
	rts


special_char
	and.w	#$ff,d0			; Only chars 0 to 255.
	lsl.w	#3,d0			; Get char pixel definition
	lea	font,a0			; in font table.
	add.w	d0,a0
	move.l	cur_addr,a1		; Get cursor screen address.
	moveq	#-1,d0			; Ensure correct colour
OFF	set	0			; data on screen.
	REPT	8			; Char is 8 lines high.
	move.b	(a0)+,d0		; Get pixel line definition.
	movep.w	d0,OFF(a1)		; Blast it onto 2 plane screen.
OFF	set	OFF+160
	ENDR
	addq.w	#1,a1			; Increment cursor screen
	move.w	a1,d0			; address - is it into
	and.w	#1,d0			; next 16 pixel column?
	bne.s	.no_bump		; No!
	addq.w	#2,a1			; Yes, fix address!
.no_bump
	move.l	a1,cur_addr		; Store cursor screen address.
	addq.w	#1,cur_xpos		; Increment cursor X position.
	rts


calc_cursor_addr
	move.w	d0,cur_xpos
	move.w	d1,cur_ypos
	move.l	SCR_BASE,a0		; Get screen start address.
	mulu	#(160*8),d1		; Calc line offset.
	add.w	d1,a0
	move.w	d0,d1			; Calc X screen offset.
	and.w	#$fffe,d1
	add.w	d1,d1
	add.w	d1,a0
	and.w	#1,d0
	add.w	d0,a0
	move.l	a0,cur_addr
	rts


**************************
*			 *
* Miscellaneous routines *
*			 *
**************************

quit
	st	finished
	rts


*********************
*		    *
* Keyboard routines *
*		    *
*********************

wait_for_key
	btst.b	#7,key_val		; Scan key pressed?
	bne.s	wait_for_key		; No!
	bset.b	#7,key_val		; Yes, no repeat.
	rts


convert_to_ascii
	move.b	key_val,d0		; Get keyboard scan code.
	and.w	#$7f,d0			; Mask off top bit.
	move.b	key_shift,d1		; Get alt, ctrl & shft keys status.
	and.b	#%00000011,d1		; Either shift key held?
	beq.s	.unshifted		; No!
	or.b	#%10000000,d0		; Yes, use 'shifted' table.
.unshifted
	lea	key_to_ascii,a0
	move.b	(a0,d0),d0		; Get corresponding ascii key.
	rts


process_key
	move.b	key_shift,d0		; Get alt, ctrl & shfts
	and.w	#$f,d0			; and keyboard scan code.
	lsl.w	#8,d0
	move.b	key_val,d0		; Key pressed?
	bmi.s	.end			; No!
	lea	key_routines,a0
.loop
	move.w	(a0)+,d1		; Get scan code.
	beq.s	.end			; If null then end of list.
	move.l	(a0)+,a1		; Get routine address.
	cmp.w	d1,d0			; Scan codes same?
	bne.s	.loop			; No!
	jmp	(a1)			; Yes, jump to routine!
.end
	rts


***************************************************
*						  *
* Convert raw ascii text to fast access structure *
*						  *
***************************************************

process_text
	lea	text,a0			; ASCII text.
	lea	line_ptrs,a1		; List of addresses of
					; start of lines.
	clr.w	max_lines
.line
	move.l	a0,(a1)+		; Store address of
					; start of line.
	addq.w	#1,max_lines
.loop
	move.b	(a0)+,d0		; Get char from ascii text.
	beq.s	.done			; If null then end of text.
	cmp.b	#CR,d0			; If end of line values then
	bne.s	.loop			; zero them and advance to
	clr.b	-1(a0)			; next line.
	cmp.b	#LF,(a0)
	bne.s	.skip
	addq.w	#1,a0
.skip
	bra.s	.line
.done
	rts


**************************
*			 *
* Scroll screen routines *
*			 *
**************************

scroll_up
	move.l	SCR_BASE,a0		; Start of screen.
	lea	(160*8)(a0),a0		; Skip top line.
	lea	(160*8)(a0),a1		; First line to be scrolled up.
	moveq	#22-1,d0
.line
OFF	set	0			; Fast move character screen.
	REPT	26
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,OFF(a0)
OFF	set	OFF+(4*12)
	ENDR
	movem.l	(a1)+,d1-d7/a2
	movem.l	d1-d7/a2,OFF(a0)
	lea	(160*8)(a0),a0
	dbf	d0,.line
	rts


scroll_down
	move.l	SCR_BASE,a0		; Start of screen.
	lea	(160*8*22)(a0),a0	; First line to be scrolled from.
	lea	(160*8)(a0),a1		; First line to be scrolled to.
	moveq	#22-1,d0
.line
OFF	set	0			; Fast move character line.
	REPT	26
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,OFF(a1)
OFF	set	OFF+(4*12)
	ENDR
	movem.l	(a0)+,d1-d7/a2
	movem.l	d1-d7/a2,OFF(a1)
	lea	-(160*8*2)(a0),a0
	lea	-(160*8)(a1),a1
	dbf	d0,.line
	rts


*****************************
*			    *
* Setup & shutdown routines *
*			    *
*****************************


********************************
*			       *
* Show top & bottom text lines *
*			       *
********************************

show_title
	MoveCursorTo	#0,#0		; Show top text line.
	lea	header_text,a6
	bsr	special_line
	MoveCursorTo	#0,#24		; Show bottom text line.
	lea	footer_text,a6
	bsr	special_line
	rts


start_tune
	moveq	#1,d0
	bra	tune


stop_tune
	bsr	tune+4
	lea	PSGreg,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	rts


*******************************
*			      *
* Keyboard interrupt routines *
*			      *
*******************************

new_kbd
	move.l	d0,-(sp)
.again
	move.b	KBD_DATA,d0
.l_shft_m
	cmp.b	#$2a,d0			; Left shift (make)?
	bne.s	.l_shft_b
	or.b	#%00000001,key_shift
.l_shft_b
	cmp.b	#$aa,d0			; Left shift (break)?
	bne.s	.r_shft_m
	and.b	#%11111110,key_shift
.r_shft_m
	cmp.b	#$36,d0			; Right shift (make)?
	bne.s	.r_shft_b
	or.b	#%00000010,key_shift
.r_shft_b
	cmp.b	#$b6,d0			; Right shift (break)?
	bne.s	.ctrl_m
	and.b	#%11111101,key_shift
.ctrl_m
	cmp.b	#$1d,d0			; Control (make)?
	bne.s	.ctrl_b
	or.b	#%00000100,key_shift
.ctrl_b
	cmp.b	#$9d,d0			; Control (break)?
	bne.s	.alt_m
	and.b	#%11111011,key_shift
.alt_m
	cmp.b	#$38,d0			; Alternate (make)?
	bne.s	.alt_b
	or.b	#%00001000,key_shift
.alt_b
	cmp.b	#$b8,d0			; Alternate (break)?
	bne.s	.key
	and.b	#%11110111,key_shift
.key
	move.b	d0,key_val
	btst.b	#4,GPIP			; Another key in queue?
	beq	.again			; Yes!
	move.l	(sp)+,d0
	rte


********************
*		   *
* Palette routines *
*		   *
********************

*******************************
*			      *
* Wait for the vertical blank *
*			      *
*******************************

*********************************
*				*
* Routines to change resolution *
*				*
*********************************

******************************
*			     *
* Disable & enable the mouse *
*			     *
******************************

*****************
*		*
* Set cpu modes *
*		*
*****************

********************
*		   *
* Initialised data *
*		   *
********************

	SECTION	DATA

mj_off		dc.b	$12,$1a
mj_on		dc.b	$14,$08

new_pal		dc.w	$000, $006, $000, $fff

font		incbin	"ST.SET"

header_text
	dc.b	" Info 125 coded by Boris /"
	dc.b	" 'Pigs Might Fly' credits music - ripped by MUG U.K."
	dc.b	0
	even

footer_text
	dcb.b	29,' '
	dc.b	'"Persistence Of Vision"'
	dc.b	0
	even

find_box_line1		dc.b	0
find_box_line2		dc.b	'  Find ?'
find_box_line3		dc.b	0
	even

not_found_mess
	dcb.b	34,' '
	dc.b	'Not found!',0
	even

key_to_ascii
	dc.b	0,ESC,'1234567890-=',BS,TAB		; Unshifted.
	dc.b	'qwertyuiop[]',CR,0,'as'
	dc.b	'dfghjkl;''`',0,'#zxcv'
	dc.b	'bnm,./',0,0,0,' ',0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0
	dcb.b	16,0
	dc.b	'\',0,0,'()/*789456123'
	dc.b	'0.',CR,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.b	0,ESC,'!"œ$%^&*()_+',BS,TAB		; Shifted.
	dc.b	'QWERTYUIOP{}',CR,0,'AS'
	dc.b	'DFGHJKL:@_',0,'~ZXCV'
	dc.b	'BNM<>?',0,0,0,' ',0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,0,0,'-',0,0,0,'+',0
	dcb.b	16,0
	dc.b	'|',0,0,'()/*789456123'
	dc.b	'0.',CR,0,0,0,0,0,0,0,0,0,0,0,0,0

key_routines
	KeyRoutEntry	$0448,top_of_text	; Control & up arrow.
	KeyRoutEntry	$0450,bot_of_text	; Control & down arrow.
	KeyRoutEntry	$0248,page_up		; Left shift & up arrow.
	KeyRoutEntry	$0250,page_down		; Left shift & down arrow.
	KeyRoutEntry	$0148,page_up		; Right shift & up arrow.
	KeyRoutEntry	$0150,page_down		; Right shift & down arrow.
	KeyRoutEntry	$0048,line_up		; Up arrow.
	KeyRoutEntry	$0050,line_down		; Right arrow.
	KeyRoutEntry	$0821,find		; Alternate & 'f'.
	KeyRoutEntry	$0001,quit		; Escape.
	dc.w	0

sky_cols	incbin	"SKY.RGB"

tune
	incbin	"TSC_CRED.THK"
	even

text
	incbin	"DISKLIST"		; Put your own file here.
	dc.b	0
	even


**********************
*		     *
* Uninitialised data *
*		     *
**********************

	SECTION	BSS

clock		ds.w	1

vsync_flag	ds.w	1

res_bak		ds.w	1

old_pal		ds.w	16

vector_bak	ds.l	3
mfp_bak		ds.b	7
	even

save_stk	ds.l	1

finished	ds.b	1
key_shift	ds.b	1
key_val		ds.b	1
found		ds.b	1
	even

cur_xpos	ds.w	1
cur_ypos	ds.w	1
cur_addr	ds.l	1

max_lines	ds.w	1
cur_line	ds.w	1
top_line	ds.w	1

find_string
	ds.b	(MAX_FIND_LEN+1)
	even

line_ptrs	ds.l	MAX_LINES

finish	even
