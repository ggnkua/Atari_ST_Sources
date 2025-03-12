***********************************
*****			      *****
***** Adrenalin Doc Displayer *****
*****       Version 2.0       *****
*****        (C)  1992        *****
*****           by            *****
*****          Boris          *****
*****           of            *****
*****  Persistence Of Vision  *****
*****			      *****
***********************************

***********
* Options *
***********

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


***********
* Equates *
***********

BELL	equ	7
TAB	equ	9
LF	equ	10
CR	equ	13
ESC	equ	27
BS	equ	127

PALETTE0	equ	$ffff8240
GPIP		equ	$fffffa01
ISRB		equ	$fffffa11
KBD_DATA	equ	$fffffc02
KBD_ISR		equ	$118
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


*************
* Main code *
*************

	SECTION	TEXT

start
	lea	stack,sp		; Set stack pointer.

	lea	start_bss,a0		; Clear BSS section.
.clr_bss
	clr.w	(a0)+
	cmp.l	#end_bss,a0
	blt.s	.clr_bss

	bsr	super_mode

	bsr	init

;Music from Astaroth (vision factory on Amiga)
;	move.l	#1,d0		;tune number (there is only tune 1)
;	jsr	tune		;jump to tune to initialise
				;Tune by MAD MAX ripped by Mookie

;	move.l	#tune+8,$4da

	bsr	redraw_screen
.loop
	bsr	process_key
	tst.b	finished		; Finished?
	beq.s	.loop			; No!

;	bsr	isr_off			;turn the music OFF

	bsr	deinit
	bsr	user_mode

	clr.w	-(sp)			; Exit.
	trap	#1


***************
* Subroutines *
***************

**************************************************
*						 *
* Print all or block of text to parallel printer *
*						 *
**************************************************

print
	clr.b	key_val			; Clear key 'buffer'.
	moveq	#0,d5			; Start & end lines
	move.w	max_lines,d6		; for printing.
	tst.b	blk_defined		; Block defined?
	beq.s	.print_all		; No!

	move.w	start_blk_line,d5	; Start & end lines
	move.w	end_blk_line,d6		; for printing.

	MoveCursorTo	#0,#11		; Show message box.
	lea	print_blk_line1,a6
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	print_blk_line2,a6
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	print_blk_line3,a6
	bsr	special_line

.get_key1
	bsr	wait_for_key		; Respond to Y or N keys..
	bsr	convert_to_ascii
	cmp.b	#'y',d0
	beq.s	.print_it
	cmp.b	#'Y',d0
	beq.s	.print_it
	cmp.b	#'n',d0
	beq	.end
	cmp.b	#'N',d0
	beq	.end
	bra.s	.get_key1

.print_all
	MoveCursorTo	#0,#11		; Show message box.
	lea	print_all_line1,a6
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	print_all_line2,a6
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	print_all_line3,a6
	bsr	special_line

.get_key2
	bsr	wait_for_key		; Respond to Y or N keys.
	bsr	convert_to_ascii
	cmp.b	#'y',d0
	beq.s	.print_it
	cmp.b	#'Y',d0
	beq.s	.print_it
	cmp.b	#'n',d0
	beq.s	.end
	cmp.b	#'N',d0
	beq.s	.end
	bra.s	.get_key2

.print_it
	MoveCursorTo	#0,#12		; Show 'Printing...'.
	lea	printing_mess,a6
	bsr	special_line

	lea	line_ptrs,a4
.loop
	bsr.s	print_line
	addq.w	#1,d5			; Increment current line number.
	cmp.w	d6,d5			; Past last line to print?
	ble.s	.loop			; No!
.end
	bsr	redraw_screen
	rts


print_line
	move.w	d5,d0			; Get current line's text
	lsl.w	#2,d0			; address from the line
	move.l	(a4,d0),a6		; pointer table.
	move.l	a6,d0			; Is line pointer valid?
	beq.s	.end			; No!
.next
	moveq	#0,d0
	move.b	(a6)+,d0		; Get char from line's text.
	beq.s	.eol			; If null then end of line,
	bsr.s	.print_char		; else print it!
	bra.s	.next
.eol
	moveq	#CR,d0			; Move print head to next line.
	bsr.s	.print_char
	moveq	#LF,d0
	bsr.s	.print_char
.end
	rts
.print_char
	move.w	d0,-(sp)		; Push char on stack.
	move.w	#0,-(sp)		; Device. (0 = parallel)
	move.w	#3,-(sp)		; Bconout.
	trap	#13			; BIOS call.
	addq.w	#6,sp			; Tidy stack.
	rts


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
	bsr	sound_bell
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
	bsr	sound_bell
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


******************
*		 *
* Block routines *
*		 *
******************

calc_block
	move.w	start_blk_line,d0	; Is end of block line
	cmp.w	end_blk_line,d0		; after start of block line?
	bgt.s	.cancel			; No!
	st	blk_defined		; Yes, block defined.
	bra	redraw_screen
.cancel
	clr.b	blk_defined		; No block defined.
	bra	redraw_screen


cancel_block
	clr.w	start_blk_line		; Set start line to top of text.
	move.w	#-1,end_blk_line	; Set end line to before it.
	clr.b	blk_defined		; No block defined.
	bra	redraw_screen


set_start_blk
	move.w	top_line,start_blk_line
	bra.s	calc_block


set_end_blk
	move.w	top_line,end_blk_line
	bra.s	calc_block


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
	moveq	#23-1,d0		; No, move up 22 lines.
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
	moveq	#23-1,d1		; No, move it doen 22 lines.
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
	clr.b	cur_inverse		; Text inversion off.
	move.w	cur_line,d0
	tst.b	blk_defined		; Block defined?
	beq.s	.no_block		; No!
	cmp.w	start_blk_line,d0	; Yes, is current line
	blt.s	.no_block		; within the block?
	cmp.w	end_blk_line,d0
	bgt.s	.no_block
	st	cur_inverse		; Yes, text inversion on!
.no_block
	lsl.w	#2,d0			; Get current line's text
	lea	line_ptrs,a6		; address from line
	move.l	(a6,d0),a6		; pointer table.
	move.l	a6,d0			; Is address valid?
	beq.s	.done			; No!
.loop
	move.b	(a6)+,d0		; Get char.
	beq.s	.done			; If null then end of line.
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
	tst.b	cur_inverse		; Is text inverted?
	bne.s	.inverted		; Yes!
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
.inverted
OFF	set	0
	REPT	8			; Char is 8 lines high.
	move.b	(a0)+,d0		; Get pixel line definition.
	not.b	d0			; Invert definition.
	movep.w	d0,OFF(a1)		; Blast it onto 2 plane screen.
OFF	set	OFF+160
	ENDR
	bra.s	.cont


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

sound_bell
	move.w	#BELL,-(sp)
	move.w	#2,-(sp)		; C_conout.
	trap	#1			; GEMDOS call.
	addq.w	#4,sp			; Tidy stack.
	rts


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

init
	bsr	disable_mj
	bsr	get_res
	bsr	med_res
	bsr	save_palette
	bsr	set_palette
	bsr	kbd_init
	move.l	SCR_BASE,cur_addr
	bsr.s	show_title
	bsr	process_text
	bsr	cancel_block
	rts


deinit
	bsr	kbd_deinit
	bsr	restore_palette
	bsr	old_res
	bsr	enable_mj
	rts


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

********************
*		   *
* Show Help Screen *
*                  *
********************

help
	bsr	wait_for_key		; wait for key 
	MoveCursorTo	#0,#0
	lea	line1,a6
	bsr	special_line
	MoveCursorTo	#0,#1
	lea	line2,a6
	bsr	special_line
	MoveCursorTo	#0,#2
	lea	line3,a6
	bsr	special_line
	MoveCursorTo	#0,#3
	lea	line4,a6
	bsr	special_line
	MoveCursorTo	#0,#4
	lea	line5,a6
	bsr	special_line
	MoveCursorTo	#0,#5
	lea	line6,a6
	bsr	special_line
	MoveCursorTo	#0,#6
	lea	line7,a6
	bsr	special_line
	MoveCursorTo	#0,#7
	lea	line8,a6
	bsr	special_line
	MoveCursorTo	#0,#8
	lea	line9,a6
	bsr	special_line
	MoveCursorTo	#0,#9
	lea	line10,a6
	bsr	special_line
	MoveCursorTo	#0,#10
	lea	line11,a6
	bsr	special_line
	MoveCursorTo	#0,#11
	lea	line12,a6
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	line13,a6
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	line14,a6
	bsr	special_line
	MoveCursorTo	#0,#14
	lea	line15,a6
	bsr	special_line
	MoveCursorTo	#0,#15
	lea	line16,a6
	bsr	special_line
	MoveCursorTo	#0,#16
	lea	line17,a6
	bsr	special_line
	MoveCursorTo	#0,#17
	lea	line18,a6
	bsr	special_line
	MoveCursorTo	#0,#18
	lea	line19,a6
	bsr	special_line
	MoveCursorTo	#0,#19
	lea	line20,a6
	bsr	special_line
	MoveCursorTo	#0,#20
	lea	line21,a6
	bsr	special_line
	MoveCursorTo	#0,#21
	lea	line22,a6
	bsr	special_line
	MoveCursorTo	#0,#22
	lea	line23,a6
	bsr	special_line
	MoveCursorTo	#0,#23
	lea	line24,a6
	bsr	special_line
	MoveCursorTo	#0,#24
	lea	line25,a6
	bsr	special_line
	bsr	wait_for_key
	bsr	show_title
	bsr	redraw_screen
	rts

*******************************
*			      *
* Keyboard interrupt routines *
*			      *
*******************************

kbd_init
	move.l	KBD_ISR,kbd_bak
	move.l	#new_kbd,KBD_ISR
	rts


kbd_deinit
	move.l	kbd_bak,KBD_ISR
	rts


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
	bclr.b	#6,ISRB
	move.l	(sp)+,d0
	rte


********************
*		   *
* Palette routines *
*		   *
********************

save_palette
	lea	PALETTE0,a0
	lea	old_pal,a1
	moveq	#4-1,d0
.loop
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts


set_palette
	lea	new_pal,a0
	lea	PALETTE0,a1
	moveq	#4-1,d0
.loop
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts


restore_palette
	lea	old_pal,a0
	lea	PALETTE0,a1
	moveq	#4-1,d0
.loop
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts


*******************************
*			      *
* Wait for the vertical blank *
*			      *
*******************************

vsync
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts


*********************************
*				*
* Routines to change resolution *
*				*
*********************************

get_res
	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	d0,res_bak
	rts


med_res
	bsr.s	vsync
	move.w	#1,-(sp)
	move.l	SCR_BASE,-(sp)
	move.l	SCR_BASE,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


old_res
	bsr.s	vsync
	move.w	res_bak,-(sp)
	move.l	SCR_BASE,-(sp)
	move.l	SCR_BASE,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.w	#12,sp
	rts


******************************
*			     *
* Disable & enable the mouse *
*			     *
******************************

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


*****************
*		*
* Set cpu modes *
*		*
*****************

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


********************
* Initialised data *
********************

	SECTION	DATA

isr_off:
	moveq.l	#0,d0
;	jsr	tune
	clr.l	$4da
	rts

mj_off		dc.b	$12,$1a		; Mouse & joystick off.
mj_on		dc.b	$14,$08		; Joystick & mouse on.

new_pal		dc.w	$007,$000,$666,$700

font		incbin	"ST.SET"	; 8*8 character set (256 chars).

header_text
	dc.b	'      Adrenalin Doc Displayer  Version 2.0  '
	dc.b	189			; Copyright symbol.
	dc.b	' 1992 P.O.V.  Coded by Boris'
	dc.b	0
	even

footer_text
	dc.b	'      Use Cursor Keys To Scroll Up and Down. Press HELP'
	dc.b	' For More Options.'
	dc.b	0
	even

line1
	dc.b	''
	dc.b	0
	even

line2
	dc.b	''
	dc.b	0
	even

line3
	dc.b	''
	dc.b	0
	even

line4
	dc.b	'                     ADRENALIN DOC DISPLAYER HELP SCREEN'
	dc.b	0
	even

line5
	dc.b	''
	dc.b	0
	even

line6
	dc.b	'                    CODING BY:-  BORIS AND MOOKIE  '
	dc.b	189		;copyright symbol
	dc.b	' 1992'
	dc.b	0
	even

line7
	dc.b	''
	dc.b	0
	even

line8
	dc.b	'                 UP ARROW           - MOVE UP A LINE'
	dc.b	0
	even

line9
	dc.b	'                 DOWN ARROW         - MOVE DOWN A LINE'
	dc.b	0
	even

line10
	dc.b	'                 SHIFT + UP ARROW   - UP ONE PAGE'
	dc.b	0
	even

line11
	dc.b	'                 SHIFT + DOWN ARROW - DOWN ONE PAGE'		
	dc.b	0
	even

line12
	dc.b	'                 CTRL + UP ARROW    - TOP OF TEXT'		
	dc.b	0
	even

line13
	dc.b	'                 CTRL + DOWN ARROW  - BOTTOM OF TEXT'
	dc.b	0
	even

line14 
	dc.b	'                 F1                 - START OF BLOCK'	
	dc.b	0
	even

line15
	dc.b	'                 F2                 - END OF BLOCK'		
	dc.b	0
	even

line16
	dc.b	'                 F3                 - CANCEL BLOCK'	
	dc.b	0
	even

line17
	dc.b	'                 ALT + F            - FIND A WORD'		
	dc.b	0
	even

line18
	dc.b	'                 ALT + P            - PRINT'
	dc.b	0
	even

line19
	dc.b	'                 HELP               - THIS HELP SCREEN'
	dc.b	0
	even

line20
	dc.b	'                 ESC                - QUIT THE DOC DISPLAYER'		
	dc.b	0
	even

line21
	dc.b	''	
	dc.b	0
	even

line22
	dc.b	'                           PRESS A KEY TO EXIT !!'
	dc.b	0
	even

line23
	dc.b	''		
	dc.b	0
	even

line24
	dc.b	''		
	dc.b	0
	even

line25
	dc.b	''		; Nothing to display at bottom of screen.
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

print_blk_line1		dc.b	0
print_blk_line2
	dcb.b	22,' '
	dc.b	'Output block to parallel printer?'
print_blk_line3		dc.b	0
	even

print_all_line1		dc.b	0
print_all_line2
	dcb.b	23,' '
	dc.b	'Output all to parallel printer?'
print_all_line3		dc.b	0
	even

printing_mess
	dcb.b	34,' '
	dc.b	'Printing...',0
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
	KeyRoutEntry	$003b,set_start_blk	; F1.
	KeyRoutEntry	$003c,set_end_blk	; F2.
	KeyRoutEntry	$003d,cancel_block	; F3.
	KeyRoutEntry	$0821,find		; Alternate & 'f'.
	KeyRoutEntry	$0819,print		; Alternate & 'p'.
	KeyRoutEntry	$0062,help		; Help
	KeyRoutEntry	$0001,quit		; Escape.
	dc.w	0

text
	incbin	"INSTRUX.501"		; Put your own file here.
	dc.b	0
	even

;tune:	incbin	"vision.mus"
;	even

**********************
* Uninitialised data *
**********************

	SECTION	BSS

start_bss

finished	ds.b	1
key_shift	ds.b	1
key_val		ds.b	1
cur_inverse	ds.b	1
blk_defined	ds.b	1
found		ds.b	1
	even

start_blk_line	ds.w	1
end_blk_line	ds.w	1

cur_xpos	ds.w	1
cur_ypos	ds.w	1
cur_addr	ds.l	1

max_lines	ds.w	1
cur_line	ds.w	1
top_line	ds.w	1

find_string
	ds.b	(MAX_FIND_LEN+1)
	even

kbd_bak		ds.l	1

res_bak		ds.w	1

old_pal		ds.w	4

save_stk	ds.l	1

		ds.l	128		; Stack space.
stack		ds.l	1

line_ptrs	ds.l	MAX_LINES

end_bss		even
