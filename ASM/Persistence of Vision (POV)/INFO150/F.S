*************************************************************************
*		PERSISTENCE OF VISION DOC DISPLAYER WITH MOD		*
*		--------------------------------------------		*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
*									*
* Date:		December 1995						*
*									*
*									*
*************************************************************************
*
* STFM/STE/FALCON tracker doc displayer
*
*		If you use this code then give me credit.
*		Don't be a lamer and claim you wrote it.
*
* Credit is due to Whiz cat for the original mod code (STFM/STE)
* Whiz Cat code has been slightly modified by MSD
* Credit to Simplet / ABSTRACT for the Falcon 030 DSP mod
*
*  All code put together by MSD/POV
*
*
*

* Protracker replay code, slightly optimised by MSD/POV
MVOL_STE	EQU	$80
FREQ_STE	EQU	2		; 0=6.259, 1=12.517, 2=25.036
					; 3=50.072 (MegaSTe/TT)
	IFEQ FREQ_STE
PARTS_STE	EQU 5-1			; 6.259
LEN_STE	EQU 25
INC_STE	EQU $023BF313			; 3579546/6125*65536
	ELSEIF
	IFEQ FREQ_STE-1
PARTS_STE	EQU 5-1			; 12.517
LEN_STE	EQU 50
INC_STE	EQU $011DF989			; 3579546/12517*65536
	ELSEIF
	IFEQ FREQ_STE-2
PARTS_STE	EQU 5-1			; 25.035
LEN_STE	EQU 100
INC_STE	EQU $008EFB4E			; 3579546/25035*65536
	ELSEIF
	IFEQ FREQ_STE-3
PARTS_STE	EQU 5-1			; 50.072
LEN_STE	EQU 200
INC_STE	EQU $00477CEC			; 3579546/50072*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC


;****** STFM BITS ***********
* Uses registers D5-D7/A6.
MVOL	EQU	$60			; >= $40 ($60 recommended)
FREQ	EQU	1			; 0=6.144, 1=8.192, 2=12.288
					; 3=16.384
	IFEQ FREQ
A_DATA	EQU 40				; 6.144
D_DATA	EQU 164
PARTS	EQU 3-1
LEN	EQU 41
INC	EQU $02469BC0			; 3579546/6144*65536
	ELSEIF
	IFEQ FREQ-1
A_DATA	EQU 30				; 8.192
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 41
INC	EQU $01B4F4D0			; 3579546/8192*65536
	ELSEIF
	IFEQ FREQ-2
A_DATA	EQU 20				; 12.288
D_DATA	EQU 82
PARTS	EQU 6-1
LEN	EQU 41
INC	EQU $01234DE0			; 3579546/12288*65536
	ELSEIF
	IFEQ FREQ-3
A_DATA	EQU 15				; 16.384
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 82
INC	EQU $00DA7A68			; 3579546/16384*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC
;***********************************************************************
YES=1
yes=YES
NO=0
no=NO

FINAL=no	;YES to remove escape to assembler code
		;NO to keep it on


******* WIDGET DOWNLOAD DEVELOPMENT SWITCHES *********************************
DOWNLOAD	equ	no

	ifne	DOWNLOAD
	include	transmit.s
	org	$20000

Code_Start
Exec_Addr
	ENDC
************************************************************************


	ifeq	DOWNLOAD
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
	OPT	w-		; Warnings on.
	OPT	x-		; Extended debug off.
	endc

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



B_DATA		equ	3
TBCR		equ	$fffffa1b	;TimerB Control Register
TBDR		equ	$fffffa21	;TimerB Data Register

		jsr	clear_bss
		jsr	set_super
		jsr	test_4_ste
		jsr	test_4_falcon		;have we got a Falcon?
		jsr	get_screen_base
		jsr	get_old_palette
		jsr	get_original_rez
		tst.w	falcon_flag		;if not Falcon then do STFM/STE bits
		beq.s	not_falcon
		bsr	do_falcon_bits		;Falcon so go do extra bits
		bra.s	pre_main_loop
not_falcon	bsr	calc_my_screen		;calc our own screen address
		jsr	black_out
		move.l	screen_base,a0
		jsr	set_med_rez
		bsr	set_screen
		tst.w	ste_flag
		bne.s	init_ste
		jsr	set_new_palette
		jsr	muson_stfm			; Install music
		bra.s	pre_main_loop
init_ste	jsr	set_new_palette
		bsr	muson_ste
pre_main_loop
**** init doc
		move.w	#$2700,sr
		move.l	scr_now,cur_addr
		bsr	show_title
		bsr	process_text
		bsr	cancel_block
		bsr	redraw_screen
		move.w	#$2300,sr
**** end init doc

main_loop



	bsr	process_key
	tst.b	finished		; Finished?
	beq	main_loop		; No!



exit
		move.l	oldkbd,$118.w

		tst.w	falcon_flag
		bne.s	.shut_down_falcon

		tst.w	ste_flag
		bne.s	.shut_down_ste
		jsr	musoff_stfm	; Restore system completely
		move.w	original_rez,-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		bra	.co
.shut_down_ste
		bsr	musoff_ste
		move.w	original_rez,-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		bra.s	.co

.shut_down_falcon

*musoff_falcon
			jsr	Stop_Music_IT
			jsr	Stop_Music


		move	#$2700,sr
		clr.b	$FFFFFA1b.w		; Stop timer B
		move.l	old_timerb,$120.w
		move.l	oldvbl,$70.w
		move.l	oldkbd,$118.w

		lea	store,a0
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0),$fffffa13.w

		lea	yesmouse,a0
		jsr	send_2_ik
		move	#$2300,sr
		move.w	old_video,-(sp)
		move.w	#3,-(sp)
		move.l	screen_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp

.co
		jsr	set_old_palette

		ifeq	DOWNLOAD
		jsr	set_user
		endc

		ifne	DOWNLOAD
		move.l	4.w,-(sp)
		rts
		endc

		clr.w	-(sp)
		trap	#1


set_screen	move.l	scr_now,d4
		move.l	scr_xor,d3
		eor.l	d3,d4
		move.l	d4,scr_now
		lsr.l	#8,d4
		lea	$ffff8201.w,a5
		movep.w	d4,(a5)
		rts

calc_my_screen	move.l	#screens,d0		;calc our own screen
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor
		rts


do_falcon_bits
;get Falcon specific settings (yawn)
		move.w	#$ffff,-(sp)	;get_videomode
		move.w	#$58,-(sp)
		trap	#$e
		addq.w	#4,sp
		move.w	d0,old_video

		move.w	#1,d7		;new Falcon video mode	
		move.w	d7,-(sp)
		move.w	#$5b,-(sp)
		trap	#14
		addq.w	#4,sp
		move.l	d0,screen_bytes	;number of bytes used by screen mode

		move.l	#screens,d0	;calc my own screen area
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	screen_bytes,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		move.w	d7,d0
		or.w	#32,d0		;set for TV 50 Hz
		or.w	#%10001000,d0	;80 Columns
		move.w	d0,-(sp)	;falcon rez
		move.w	#3,-(sp)	;rez 3! (leave alone)
		move.l	scr_now,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#14,sp


		move.l	scr_now,a0
		move.l	screen_bytes,d0
		lsr.w	#2,d0
.clear		clr.l	(a0)+
		sub.l	#1,d0
		bne.s	.clear

;		clr.l	$ffff9800.w

;Word is made up like so :  X X X X X X X V S O P M 8 N N N
;	N  Bits per pixels :	4 -> 16 bits	65536 colours
;				3 -> 8  bits	256 colours
;				2 -> 4  bits	16 colours
;				1 -> 2  bits	1 colours
;				0 -> 1  bit     0 colours?????
;	8 Flag 80 columns  :	1 -> mode 80 columns
;				0 -> mode 40 columns
;	M Flag VGA         :	1 -> mode monitor VGA
;				0 -> mode TV/RGB
;	P Flag PAL         :	1 -> mode PAL
;				0 -> mode NTSC
;	O Flag Overscan    :	1 -> Overscan ON (not valid on VGA)
;				0 -> Overscan OFF
;   S ST compatibility flag:    1 -> Yes
;                               0 -> No
;       V Vertical flag    :    1 -> enable interlace mode on colour
;                                    monitor or double line mode on VGA
;
;       X Reserved         :    Reserved (set 0)


;		move.w	#$20,$ffff82aa.w	;overscan bottom by x number of lines

;		jsr	black_out

	move.w	#$2700,sr

		lea	store,a0
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)
		move	#$2700,sr
;		and.b	#$fe,$fffffa07.w
;		and.b	#$df,$fffffa09.w
		move.l	$120.w,old_timerb
		move.l	$70.w,oldvbl
		move.l	$118.w,oldkbd
;	move.l	#falcon_vbl,$70.w
		move.l	#new_kbd,$118.w
;	move.l	#timerb,$120.w
		bclr	#3,$fffffa17.w
;		or.b	#1,$fffffa07.w
;		or.b	#1,$fffffa13.w
;	move.b	#188,$fffffa21.w		;timer B data
;	move.b	#8,$fffffa1b.w		;ei timber B


muson_falcon

	jsr	set_new_palette
	move.w	#$2700,sr
		jsr	Init_Music
	bmi	exit
		jsr	Init_Music_IT

		move.w	#$2300,sr
		rts

process_key
	move.b	key_shift,d0		; Get alt, ctrl & shfts
	and.w	#$f,d0			; and keyboard scan code.
	lsl.w	#8,d0
	move.b	key_val,d0		; Key pressed?
	bmi.s	.end			; No!
	lea	key_routines,a0
.loop	move.w	(a0)+,d1		; Get scan code.
	beq.s	.end			; If null then end of list.
	move.l	(a0)+,a1		; Get routine address.
	cmp.w	d1,d0			; Scan codes same?
	bne.s	.loop			; No!
	jmp	(a1)			; Yes, jump to routine!
.end
	rts


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
	lea	print_blk_line1,a5
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	print_blk_line2,a5
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	print_blk_line3,a5
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
	lea	print_all_line1,a5
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	print_all_line2,a5
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	print_all_line3,a5
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
	lea	printing_mess,a5
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
	move.w	d2,d0			; Get current line's text
	lsl.w	#2,d0			; address from the line
	move.l	(a4,d0),a2		; pointer table.
	move.l	a2,d0			; Is line pointer valid?
	beq.s	.end			; No!
.next
	moveq	#0,d0
	move.b	(a2)+,d0		; Get char from line's text.
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
find	MoveCursorTo	#0,#11		; Show message box.
	lea	find_box_line1,a5
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	find_box_line2,a5
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	find_box_line3,a5
	bsr	special_line
	bsr.s	input_find_text
	tst.b	find_string		; Anything typed for search string?
	beq.s	.no_string		; No!

	bsr	do_search

	tst.b	found			; Found string?
	bne.s	.found			; Yes!
	MoveCursorTo	#0,#12		; No, show 'Not found!' message
	lea	not_found_mess,a5	; and sound a beep!
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
	lea	find_string,a4
	moveq	#0,d2			; Input character counter.
	MoveCursorTo	#9,#12		; Show previous search string.
	move.l	a4,a5
.old_string
	move.b	(a5)+,d0		; Get char.
	beq.s	.show_cursor		; If null then were at the end!
	bsr	special_char		; Show char.
	addq.w	#1,d2			; Increment char counter.
	bra.s	.old_string
.show_cursor
	move.w	d2,d0			; Show cursor.
	add.w	#9,d0
	MoveCursorTo	d0,#12
	move.w	#174,d0
	bsr	special_char
	move.w	d2,d0
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
	cmp.w	#MAX_FIND_LEN,d2	; Yes, is string full?
	bge.s	.full			; Yes!
	move.b	d0,(a4,d2)		; Store char.
	bsr	special_char		; Show it.
	addq.w	#1,d2			; Increment counter.
	bra.s	.show_cursor
.full
	bsr	sound_bell
	bra.s	.loop
.remove_char
	tst.w	d2			; Is string empty?
	beq.s	.loop			; Yes!
	move.w	d2,d0			; No, overwrite last char
	add.w	#9,d0			; with a space.
	MoveCursorTo	d0,#12
	moveq	#' ',d0
	bsr	special_char
	subq.w	#1,d2			; Decrement counter.
	bra	.show_cursor
.done
	move.w	d2,d0			; Remove cursor.
	add.w	#9,d0
	MoveCursorTo	d0,#12
	moveq	#' ',d0
	bsr	special_char
	clr.b	(a4,d2)			; Terminate string.
	rts

do_search
	clr.b	found			; Not found!
	lea	line_ptrs,a4
	move.w	top_line,d4		; Search from top screen line.
.start_line
	move.w	d4,d0			; Get current line's text
	lsl.w	#2,d0			; address from line
	move.l	(a4,d0),a2		; pointer table.
	move.l	a2,d0			; Is address valid?
	beq.s	.not_found		; No!
	move.l	a2,a3
.compare
	lea	find_string,a5
	move.l	a3,a2			; Address of next char in line.
.loop
	move.b	(a5)+,d1		; End of search string?
	beq.s	.found			; Yes, then found string!
	move.b	(a2)+,d0		; Get char from text.
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
	move.w	d4,top_line
.not_found
	rts
.next_line
	addq.w	#1,d4			; End of line reached,
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
	moveq	#23-1,d1		; No, move it down 22 lines.
.loop	move.w	top_line,d0		; Is display already at
	cmp.w	max_lines,d0		; bottom of text?
	bge.s	.done			; Yes!
	addq.w	#1,top_line		; No, increment top line!
	dbf	d1,.loop
.done	bsr.s	redraw_screen
.end	rts


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
	moveq	#1,d4			; Screen line number.
.loop	MoveCursorTo	#0,d4		; Show current line.
	bsr.s	draw_line
	addq.w	#1,cur_line		; Increment text line number.
	addq.w	#1,d4			; Increment screen line number.
	cmp.w	#24,d4			; At bottom of screen?
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
	lea	line_ptrs,a2		; address from line
	move.l	(a2,d0),a2		; pointer table.
	move.l	a2,d0			; Is address valid?
	beq.s	.done			; No!
.loop
	move.b	(a2)+,d0		; Get char.
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
	move.b	(a5)+,d0		; Get char.
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

;	move.l	SCR_BASE,a0		; Get screen start address.
	move.l	scr_now,a0

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



***************************************************
*						  *
* Convert raw ascii text to fast access structure *
*						  *
***************************************************

process_text
	lea	text_file,a0		; ASCII text.
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
	move.l	scr_now,a0		; Start of screen.
	lea	160*8(a0),a0		; Skip top line.
	lea	160*8(a0),a1		; First line to be scrolled up.
	moveq	#22-1,d0
.line	move.w	d0,-(sp)
OFF	set	0
	rept	(160*8)/36		;8 rows to move
	movem.l	(a1)+,d0-d4/a2-a5
	movem.l	d0-d4/a2-a5,OFF(a0)
OFF	set	OFF+36
	endr
	movem.l	(a1)+,d0-d4
	movem.l	d0-d4,OFF(a0)
	lea	8*160(a0),a0
	move.w	(sp)+,d0
	dbf	d0,.line
	rts



scroll_down
	move.l	scr_now,a0		; Start of screen.
	lea	160*8*22(a0),a0		; First line to be scrolled from.
	lea	160*8(a0),a1		; First line to be scrolled to.
	moveq	#22-1,d0
.line	move.w	d0,-(sp)
OFF	set	0			; Fast move character line.
	REPT	(160*8)/36
	movem.l	OFF(a0),d0-d4/a2-a5
	movem.l	d0-d4/a2-a5,OFF(a1)
OFF	set	OFF+36
	ENDR
	movem.l	OFF(a0),d0-d4
	movem.l	d0-d4,OFF(a1)
	lea	-160*8(a0),a0
	lea	-160*8(a1),a1
	move.w	(sp)+,d0
	dbf	d0,.line
	rts


show_title
	MoveCursorTo	#0,#0		; Show top text line.
	lea	header_text,a5
	bsr	special_line
	MoveCursorTo	#0,#24		; Show bottom text line.
	lea	footer_text,a5
	bsr	special_line
	rts

********************
*		   *
* Show Help Screen *
*                  *
********************

help
	bsr	wait_for_key		; wait for key 
	move.w	#$8246,tbstfm+2
	move.w	#$8246,tbste+2
	MoveCursorTo	#0,#0
	lea	line1,a5
	bsr	special_line
	MoveCursorTo	#0,#1
	lea	line2,a5
	bsr	special_line
	MoveCursorTo	#0,#2
	lea	line3,a5
	bsr	special_line
	MoveCursorTo	#0,#3
	lea	line4,a5
	bsr	special_line
	MoveCursorTo	#0,#4
	lea	line5,a5
	bsr	special_line
	MoveCursorTo	#0,#5
	lea	line6,a5
	bsr	special_line
	MoveCursorTo	#0,#6
	lea	line7,a5
	bsr	special_line
	MoveCursorTo	#0,#7
	lea	line8,a5
	bsr	special_line
	MoveCursorTo	#0,#8
	lea	line9,a5
	bsr	special_line
	MoveCursorTo	#0,#9
	lea	line10,a5
	bsr	special_line
	MoveCursorTo	#0,#10
	lea	line11,a5
	bsr	special_line
	MoveCursorTo	#0,#11
	lea	line12,a5
	bsr	special_line
	MoveCursorTo	#0,#12
	lea	line13,a5
	bsr	special_line
	MoveCursorTo	#0,#13
	lea	line14,a5
	bsr	special_line
	MoveCursorTo	#0,#14
	lea	line15,a5
	bsr	special_line
	MoveCursorTo	#0,#15
	lea	line16,a5
	bsr	special_line
	MoveCursorTo	#0,#16
	lea	line17,a5
	bsr	special_line
	MoveCursorTo	#0,#17
	lea	line18,a5
	bsr	special_line
	MoveCursorTo	#0,#18
	lea	line19,a5
	bsr	special_line
	MoveCursorTo	#0,#19
	lea	line20,a5
	bsr	special_line
	MoveCursorTo	#0,#20
	lea	line21,a5
	bsr	special_line
	MoveCursorTo	#0,#21
	lea	line22,a5
	bsr	special_line
	MoveCursorTo	#0,#22
	lea	line23,a5
	bsr	special_line
	MoveCursorTo	#0,#23
	lea	line24,a5
	bsr	special_line
	MoveCursorTo	#0,#24
	lea	line25,a5
	bsr	special_line
	bsr	wait_for_key
	move.w	#$8244,tbstfm+2
	move.w	#$8244,tbste+2
	jsr	set_new_palette
	bsr	show_title
	bsr	redraw_screen
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
	bclr.b	#6,ISRB
	move.l	(sp)+,d0
	rte




muson_ste
	bsr	vol_ste			; Calculate volume tables
	bsr	incrcal_ste		; Calculate tonetables

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	lea	nomouse,a0
	jsr	send_2_ik

	move	#$2700,sr
	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)

	clr.b	TBCR.w		;stop timerb
	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkbd
	move.l	$120.w,old_timerb
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#timerb_ste,$120.w
	bclr	#3,$fffffa17.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#B_DATA,TBDR.w	;timer B data
	move.b	#8,TBCR.w	;ei timber B

	bset	#5,$FFFFFA07.w	;start mod
	bset	#5,$FFFFFA13.w


;*****************************************************
;* Okay all you STE freaks here is the important bit...
;*
;* I've put loads of comments in to help you change the settings
;* The BASS and TREBLE bit has a FULL breakdown of what bits do what
;* so you have no excuse for not changing them.
;*
;* MAC SYS DATA 18/7/92
;*
;*****************************************************

		lea	setsam_dat(pc),a0
		move.w	#6-1,d0
mwwrite		move.w	#$07ff,$ffff8924.w	;MICROWIRE mask register
mwwrite2	cmp.w	#$07ff,$ffff8924.w	;wait for write state
		bne.s	mwwrite2
		move.w	(a0)+,$ffff8922.w	;MICROWIRE data register - make new values...
		dbf	d0,mwwrite
*------------------------------------------------------------------


		clr.b	$FFFFFA19.w		;stop timer A
		move.b	#1,$FFFFFA1F.w		;timer A data
		move.b	#8,$FFFFFA19.w		;start timer A

		move.l	$134.w,oldtima
		move.l	#stereo,$134.w

		move.b	#FREQ_STE,$FFFF8921.w	; Frequency

		lea	$ffff8907.w,a0

		move.l	#sample1_ste,d0
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)

		move.l	#sample1_ste+LEN_STE*2,d0
		move.b	d0,12(a0)
		lsr.w	#8,d0
		move.l	d0,7(a0)

		move.b	#3,$ffff8901.w		; Start DMA/repeat 4 ever

		move	#$2300,sr		; Start isr's
		rts


setsam_dat
;this is complex but I'll try to make it simple....
;
;
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;The VOLUME bit is already taken care of by the rest of the code
; but I've set it anyway... (MSD)
;
;Volume/Tone data values:
;
;Master Volume:      0 - 40 (0 = -80dB, 40 = 0dB)
;Left/Right Volume:  0 - 20 (0 = -80dB, 20 = 0dB)
;Treble/Bass:        0 - 12 (0 = -12dB, 6 = 0dB, 12 = +12dB)
;
;
;                     dd = always 10 cos that's the device output for GI tone chip
;                     ||xxx=master volume (%011 or can be left %101 or right %100)
;                     |||||yyyyyy=volume setting 000000 -80dB (sound off)
;                     |||||||||||                010100 -40dB
;                     |||||||||||                101???   0dB (??? doesn't matter but it don't seem to work if 000)
	dc.w	%0000010011101111		;master


;			   yyyyyy=volume setting 000000 -40dB
;			   ||||||                001010 -20dB
;			   ||||||                0101??   0dB (??? doesn't matter but it don't seem to work if 000)
	dc.w	%0000010101010111		;left
	dc.w	%0000010100010111		;right


;base + treble
;       zzzz
;	0000 -12 dB
;	0110   0 dB
;	1100 +12 dB
;                     xx = always 10 cos that's the device output for GI tone chip
;                     ||yyy = define BASS (001) or TREBLE (010)
;                     |||||@@=don't matter
;                     |||||||zzzz=+12,0,-12Db (see table above)
;                     |||||||||||
	dc.w	%0000010010001100	*treble  (+12 dB) 
	dc.w	%0000010001001100	*bass    (+12 dB)
	dc.w	%0000000000000010	*mixer	01=mix sound chip
					*       10=do not mix
					*       11=reserved


musoff_ste	
		move	#$2700,sr

		clr.b	$FFFFFA19.w	; Stop timer A
		clr.b	$FFFFFA1F.w	; timer A data
		clr.b	TBCR.w		; Stop timer B

		move.l	oldvbl,$70.w
		move.l	oldkbd,$118.w
		move.l	old_timerb,$120.w
		lea	store,a0
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0),$fffffa13.w

		move.l	oldtima,$134.w	; Restore everything

		clr.b	$FFFF8901.w		; Stop DMA
		bset	#3,$fffffa17.w
		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts


;--------------------------------------------------------- Volume table --
vol_ste	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL_STE,d2		; <---- Master volume
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts

vtab	DS.B 65*256
vtabend


incrcal_ste
	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC_STE,d2

recalc_ste
	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc_ste
	rts


;-------------------------------------------------------- DMA interrupt --
stereo	move	#$2500,sr
	bclr	#5,$FFFFFA0F.w
	movem.l	d0-a6,-(sp)

	move.l	samp1_ste(pc),d0
	move.l	samp2_ste(pc),samp1_ste
	move.l	d0,samp2_ste

	lea	$FFFF8907.w,a0

	move.l	samp1_ste(pc),d0
	move.b	d0,(a0)
	lsr.w	#8,d0
	move.l	d0,-5(a0)

	move.l	samp1_ste(pc),d0
	add.l	#LEN_STE*2,d0
	move.b	d0,12(a0)
	lsr.w	#8,d0
	move.l	d0,7(a0)

	subq.w	#1,count_ste
	bpl.s	.nomus

	move.w	#PARTS_STE,count_ste
	bsr	music

.nomus	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v1_ste	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d0
	move.w	wiz2frc(pc),d1

	move.w	aud2per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2

	movea.w	2(a5,d7.w),a4

	move.w	aud2vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz3lc(pc),a1

	move.w	wiz3pos(pc),d4
	move.w	wiz3frc(pc),d5

	move.w	aud3per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud3vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1_ste(pc),a6
	moveq	#0,d3

	REPT LEN_STE
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.w	d7,(a6)+
	ENDR

 	cmp.l	wiz2len(pc),d0
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d0

.ok2	move.w	d0,wiz2pos
	move.w	d1,wiz2frc

	cmp.l	wiz3len(pc),d4
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d4

.ok3	move.w	d4,wiz3pos
	move.w	d5,wiz3frc

	lea	itab(pc),a5
	lea	vtab(pc),a3
	moveq	#0,d0
	moveq	#0,d4

v2_ste	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d0
	move.w	wiz1frc(pc),d1

	move.w	aud1per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d2
	movea.w	2(a5,d7.w),a4

	move.w	aud1vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a2

	movea.l	wiz4lc(pc),a1

	move.w	wiz4pos(pc),d4
	move.w	wiz4frc(pc),d5

	move.w	aud4per(pc),d7
	add.w	d7,d7
	add.w	d7,d7
	move.w	0(a5,d7.w),d6
	movea.w	2(a5,d7.w),a5

	move.w	aud4vol(pc),d7
	asl.w	#8,d7
	lea	0(a3,d7.w),a3

	movea.l	samp1_ste(pc),a6
	moveq	#0,d3

	REPT LEN_STE
	add.w	a4,d1
	addx.w	d2,d0
	add.w	a5,d5
	addx.w	d6,d4
	move.b	0(a0,d0.l),d3
	move.b	0(a2,d3.w),d7
	move.b	0(a1,d4.l),d3
	add.b	0(a3,d3.w),d7
	move.b	d7,(a6)
	addq.w	#2,a6
	ENDR

	cmp.l	wiz1len(pc),d0
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d0

.ok1	move.w	d0,wiz1pos
	move.w	d1,wiz1frc

	cmp.l	wiz4len(pc),d4
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d4

.ok4	move.w	d4,wiz4pos
	move.w	d5,wiz4frc

	movem.l	(sp)+,d0-a6
	rte

;-------------------------------------------- Hardware-registers & data --
count_ste	DC.W PARTS_STE

wiz1lc	DC.L sample1_ste
wiz1len	DC.L 320
wiz1rpt	DC.W 320
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1_ste
wiz2len	DC.L 320
wiz2rpt	DC.W 320
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1_ste
wiz3len	DC.L 320
wiz3rpt	DC.W 320
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1_ste
wiz4len	DC.L 320
wiz4rpt	DC.W 320
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W	0
	DS.W	3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0
dummy	DC.L 0

samp1_ste	DC.L sample1_ste
samp2_ste	DC.L sample2_ste

sample1_ste	DS.W LEN_STE
sample2_ste	DS.W LEN_STE

;---------------------------------------------------- Interrupts on/off --
muson_stfm
	lea	nomouse,a0
	jsr	send_2_ik

	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
	bsr	clearym			; Clear soundchip registers

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp

	move	#$2700,sr

	lea	store,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)
	move.l	$fffffa06.w,s06		; Save MFP registers
	move.l	$fffffa12.w,s12
	move.b	$fffffa1d.w,s1d

	and.b	#$fe,$fffffa07.w
	and.b	#$df,$fffffa09.w
	move.l	$120.w,old_timerb
	move.l	$118.w,oldkbd
	move.l	$70.w,oldvbl
	move.l	#newvbl,$70.w
	move.l	#new_kbd,$118.w
	move.l	#timerb_stfm,$120.w
	bclr	#3,$fffffa17.w		; Autovectors

	move.b	#$21,$fffffa07.w	0 0 1 0 0 0 0 1
				;           |         +---- Timer B $120 ena
				;           +-------------- Timer A $134
	move.b	#%01010000,$fffffa09.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 ena
				;         +---------------- MC6850 $118 ena
	move.b	#%01010000,$fffffa15.w	0 1 0 1 0 0 0 0
				;         |   +------------ $110 mask
				;         +---------------- MC6850 $118 mask
	move.b	#$21,$fffffa13.w	0 0 1 0 0 0 0 1
				;           |         +---- Timer B $120 mask
				;           +-------------- Timer A $134 mask

	clr.b	$fffffa1d.w		;stop timer C & D
	clr.b	$fffffa19.w		;stop timer A
	clr.b	TBCR.w			;stop timer B
	move.b	#A_DATA,$FFFFFA1F.w	;set timer A data
	move.b	#B_DATA,TBDR.w	;timer B data
	move.b	#D_DATA,$FFFFFA25.w	;set timer D data
	move.b	#8,TBCR.w		;ei timber B

	move.b	#2,$FFFFFA19.w		;start timer A
	move.b	#6,$FFFFFA1D.w		;timer C & D control

	move.l	$110.w,oldtimd
	move.l	$134.w,oldtima
	move.l	#timerd,$110.w
	move.l	#playvec,$134.w

	lea	sample1(pc),a6
	move	#$2300,sr
	rts

newvbl		;move.w	pic+4,$ffff8242.w
		;move.l	pic+2,$ffff8240.w
;		clr.b	TBCR.w
		add.w	#2,colour_offset
		move.w	colour_offset,temp
;		move.b	#8,TBCR.w		;ei timer b
		rte

timerb_stfm	move.l	a0,-(sp)
		move.w	d0,-(sp)
		lea	colours,a0
		move.w	temp,d0
		and.w	#511,d0
		add.w	d0,a0
tbstfm		move.w	(a0),$ffff8244.w
		move.w	(sp)+,d0
		move.l	(sp)+,a0
		add.w	#2,temp
		rte

		rte

timerb_ste	move.l	a0,-(sp)
		move.w	d0,-(sp)
		lea	colours,a0
		move.w	temp,d0
		and.w	#511,d0
		add.w	d0,a0
tbste		move.w	(a0),$ffff8244.w
		move.w	(sp)+,d0
		move.l	(sp)+,a0
		add.w	#2,temp
		rte

musoff_stfm	move	#$2700,sr
		move.l	oldkbd,$118.w
		move.l	oldvbl,$70.w
		move.l	oldtimd,$110.w	; Restore vectors
		move.l	old_timerb,$120.w
		move.l	oldtima,$134.w

		move.l	s06,$FFFFFA06.w
		move.l	s12,$FFFFFA12.w
		move.b	s1d,$FFFFFA1D.w

		bset	#3,$FFFFFA17.w		; Softvectors

		lea	yesmouse,a0
		jsr	send_2_ik

		move	#$2300,sr
		rts



;-------------------------------------------- Clear soundchip registers --
clearym	move	#$2700,sr

	moveq	#$0A,d0
._1	move.b	d0,$FFFF8800.w
	clr.b	$FFFF8802.w
	dbra	d0,._1			; Clear soundchip registers
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#7,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w

	rts

;----------------------------------------------- Calculate volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	add.b	#$80,d2
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop
	rts



;-------------------------------------------- Calculate increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L	$30
stab	DS.L	$3A0-$30

;---------------------------------------------------- Samplecalculating --
timerd	;move.w	#$070,$ffff8240.w
	movea.l	samp1(pc),a6

	move	#$2300,sr
	movem.l	d0-d4/a0-a4,-(sp)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	move.l	samp2(pc),d0
	move.l	samp1(pc),samp2
	move.l	d0,samp1

	lea	itab(pc),a2
	lea	vtab(pc),a4
	moveq	#0,d1

v1	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d1
	move.w	wiz1frc(pc),d0

	move.w	aud1per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud1vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	move.w	d4,(a3)+
	ENDR

	cmp.l	wiz1len(pc),d1
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d1

.ok1	move.w	d1,wiz1pos
	move.w	d0,wiz1frc


v2	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d1
	move.w	wiz2frc(pc),d0

	move.w	aud2per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud2vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr	v234

	cmp.l	wiz2len(pc),d1
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d1

.ok2	move.w	d1,wiz2pos
	move.w	d0,wiz2frc


v3	movea.l	wiz3lc(pc),a0

	move.w	wiz3pos(pc),d1
	move.w	wiz3frc(pc),d0

	move.w	aud3per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud3vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz3len(pc),d1
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d1

.ok3	move.w	d1,wiz3pos
	move.w	d0,wiz3frc


v4	movea.l	wiz4lc(pc),a0

	move.w	wiz4pos(pc),d1
	move.w	wiz4frc(pc),d0

	move.w	aud4per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud4vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz4len(pc),d1
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d1

.ok4	move.w	d1,wiz4pos
	move.w	d0,wiz4frc

	movem.l	(sp)+,d0-d4/a0-a4
	rte

v234	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	add.w	d4,(a3)+
	ENDR

	rts

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

samp1	DC.L sample1
samp2	DC.L sample2

sample1	REPT	LEN
	DC.W	$200
	ENDR

sample2	REPT	LEN
	DC.W	$200
	ENDR

;--------------------------------------------------- Playback-interrupt --
playvec	move.w	(a6)+,d7
	lsl.w	#4,d7
	movem.l	snd_tab(pc,d7.w),d5-d7
	movem.l	d5-d7,$FFFF8800.w
	rte

;--------------------------------------------- Sound data for soundchip --
snd_tab	REPT 384
	DC.L $08000F00,$09000A00,$0A000000,0
	ENDR

	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000600,0
	DC.L $08000E00,$09000C00,$0A000300,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000700,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000700,$0A000900,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000700,$0A000500,0
	DC.L $08000E00,$09000700,$0A000400,0
	DC.L $08000E00,$09000700,$0A000300,0
	DC.L $08000E00,$09000600,$0A000400,0
	DC.L $08000E00,$09000600,$0A000300,0
	DC.L $08000E00,$09000500,$0A000400,0
	DC.L $08000E00,$09000500,$0A000200,0
	DC.L $08000E00,$09000400,$0A000200,0
	DC.L $08000E00,$09000300,$0A000200,0
	DC.L $08000E00,$09000000,$0A000000,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000A00,$0A000C00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000900,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000C00,$09000C00,$0A000700,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000500,0
	DC.L $08000D00,$09000A00,$0A000700,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000500,0
	DC.L $08000D00,$09000900,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000B00,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000900,$0A000500,0
	DC.L $08000D00,$09000900,$0A000400,0
	DC.L $08000D00,$09000800,$0A000600,0
	DC.L $08000C00,$09000B00,$0A000700,0
	DC.L $08000D00,$09000700,$0A000700,0
	DC.L $08000C00,$09000B00,$0A000600,0
	DC.L $08000B00,$09000B00,$0A000A00,0
	DC.L $08000800,$09000A00,$0A000C00,0
	DC.L $08000C00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000A00,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000000,0
	DC.L $08000D00,$09000600,$0A000400,0
	DC.L $08000D00,$09000500,$0A000500,0
	DC.L $08000C00,$09000900,$0A000900,0
	DC.L $08000D00,$09000500,$0A000400,0
	DC.L $08000B00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000400,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000A00,0
	DC.L $08000C00,$09000A00,$0A000500,0
	DC.L $08000C00,$09000900,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000800,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000900,$0A000700,0
	DC.L $08000B00,$09000B00,$0A000700,0
	DC.L $08000C00,$09000900,$0A000600,0
	DC.L $08000B00,$09000A00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000600,0
	DC.L $08000A00,$09000A00,$0A000A00,0
	DC.L $08000B00,$09000B00,$0A000500,0
	DC.L $08000B00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000700,$0A000700,0
	DC.L $08000C00,$09000800,$0A000400,0
	DC.L $08000C00,$09000700,$0A000600,0
	DC.L $08000B00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000900,0
	DC.L $08000C00,$09000600,$0A000600,0
	DC.L $08000C00,$09000700,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000500,0
	DC.L $08000B00,$09000900,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000000,0
	DC.L $08000B00,$09000900,$0A000700,0
	DC.L $08000B00,$09000800,$0A000800,0
	DC.L $08000A00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000700,0
	DC.L $08000C00,$09000100,$0A000100,0
	DC.L $08000A00,$09000A00,$0A000600,0
	DC.L $08000B00,$09000800,$0A000700,0
	DC.L $08000A00,$09000A00,$0A000500,0
	DC.L $08000A00,$09000900,$0A000800,0
	DC.L $08000A00,$09000A00,$0A000400,0
	DC.L $08000A00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000200,0
	DC.L $08000900,$09000900,$0A000900,0
	DC.L $08000A00,$09000800,$0A000800,0
	DC.L $08000B00,$09000800,$0A000100,0
	DC.L $08000A00,$09000900,$0A000600,0
	DC.L $08000B00,$09000700,$0A000400,0
	DC.L $08000A00,$09000900,$0A000500,0
	DC.L $08000900,$09000900,$0A000800,0
	DC.L $08000A00,$09000900,$0A000300,0
	DC.L $08000A00,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000700,0
	DC.L $08000A00,$09000900,$0A000000,0
	DC.L $08000900,$09000800,$0A000800,0
	DC.L $08000A00,$09000800,$0A000400,0
	DC.L $08000900,$09000900,$0A000600,0
	DC.L $08000A00,$09000800,$0A000100,0
	DC.L $08000900,$09000900,$0A000500,0
	DC.L $08000900,$09000800,$0A000700,0
	DC.L $08000800,$09000800,$0A000800,0
	DC.L $08000900,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000200,0
	DC.L $08000900,$09000700,$0A000700,0
	DC.L $08000900,$09000900,$0A000000,0
	DC.L $08000800,$09000800,$0A000700,0
	DC.L $08000900,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000600,0
	DC.L $08000900,$09000800,$0A000200,0
	DC.L $08000900,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000700,0
	DC.L $08000800,$09000800,$0A000400,0
	DC.L $08000800,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000200,0
	DC.L $08000700,$09000700,$0A000700,0
	DC.L $08000800,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000400,0
	DC.L $08000700,$09000700,$0A000600,0
	DC.L $08000800,$09000600,$0A000500,0
	DC.L $08000800,$09000600,$0A000400,0
	DC.L $08000700,$09000600,$0A000600,0
	DC.L $08000700,$09000700,$0A000400,0
	DC.L $08000800,$09000500,$0A000400,0
	DC.L $08000600,$09000600,$0A000600,0
	DC.L $08000700,$09000600,$0A000400,0
	DC.L $08000700,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000500,0
	DC.L $08000600,$09000600,$0A000400,0
	DC.L $08000600,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000200,0
	DC.L $08000600,$09000500,$0A000400,0
	DC.L $08000500,$09000500,$0A000500,0
	DC.L $08000600,$09000500,$0A000200,0
	DC.L $08000500,$09000500,$0A000400,0
	DC.L $08000500,$09000400,$0A000400,0
	DC.L $08000500,$09000500,$0A000200,0
	DC.L $08000400,$09000400,$0A000400,0
	DC.L $08000400,$09000400,$0A000300,0
	DC.L $08000400,$09000400,$0A000200,0
	DC.L $08000400,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000200,0
	DC.L $08000300,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000100,0
	DC.L $08000100,$09000100,$0A000100,0
	DC.L $08000200,$09000100,$0A000000,0
	DC.L $08000100,$09000100,$0A000000,0
	DC.L $08000100,$09000000,$0A000000,0
	DC.L $08000000,$09000000,$0A000000,0

	REPT 384
	DC.L $08000000,$09000000,$0A000000,0
	ENDR

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	mod_data,a1		; Module
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7
roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep


repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	move.w	#$700,$ffff8240.w
	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	mod_data,a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3a	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3a

	move.l	a2,end_of_samples	;
	rts

music	lea	mod_data,a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	mod_data+$043C,a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	moveq	#0,d3		;speed increase by MSD of POV

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	move.w	d3,wiz1pos	;;speed increase

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	move.w	d3,wiz2pos	;;speed increase

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	move.w	d3,wiz3pos	;;speed increase


wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	move.w	d3,wiz4pos	;;speed increase

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	mod_data+$03B6,d1
	bne.s	endr
	move.b	mod_data+$03B7,songpos
endr	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	3(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#2,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$F,d0
	mulu	d0,d2
	lsr.w	#6,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,6(a3)
	move.b	$1A(a4),d0
	lsr.w	#2,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#4,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W	6
counter	DC.W	0
songpos	DC.B	0
break	DC.B	0
pattpos	DC.W	0

dmacon		DC.W	0
samplestarts	DS.L	$1F

voice1	DS.W	10
	DC.W	1
	DS.W	3
voice2	DS.W	10
	DC.W	2
	DS.W	3
voice3	DS.W	10
	DC.W	4
	DS.W	3
voice4	DS.W	10
	DC.W	8
	DS.W	3

set_super
		ifeq	DOWNLOAD
		clr.l	-(sp)		;Set super stack equal
		move.w	#$20,-(sp)	; to user stack before call
		trap	#1
		addq.l	#6,sp		;correct stack
		move.l	d0,stack_save	;save old supervisor stack value
		endc
		rts

set_user	move.l	stack_save,-(sp)
		move.w	#$20,-(sp)
		trap	#1		;back to user
		addq.l	#6,sp		;correct stack
		rts

get_old_palette	lea	$ffff8240.w,a0
		lea	old_palette,a1
		movem.l	(a0),d0-d7
		movem.l	d0-d7,(a1)
		rts

set_new_palette	lea	pic+2,a0
		bra	set_pal
set_old_palette	lea	old_palette,a0
set_pal		lea	$ffff8240.w,a1
		REPT	8
		move.l 	(a0)+,(a1)+
		ENDR
		rts

get_screen_base	move.l	$44e.w,old_scr_base
		rts

set_org_rez	move.b	original_rez,$ffff8260.w
		bra.s	set_scr
set_med_rez	move.b	#1,$ffff8260.w
		bra.s	set_scr
set_low_rez	clr.b	$ffff8260.w
set_scr		move.l	a0,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a5
		movep.w	d0,(a5)
		rts


get_original_rez
		move.b	$ffff8260.w,original_rez
		rts


show_picture	lea	pic+34,a0
		move.l	screen_base,a1
		move.w	#32000/4-1,d0
.loop		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		rts


black_out	movem.l	black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

clear_bss	lea	bssstart,a0		;clear BSS 'cause most packers don't
.clear		clr.b	(a0)+
		cmp.l	#eobss,a0
		bne.s	.clear
		rts

send_2_ik	move.l	a0,-(sp)
		move.w	#2-1,-(sp)
		move.w	#$19,-(sp)
		trap	#14
		addq.l	#8,sp
		rts

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.
test_4_ste	move.w	#$2300,sr
		lea	$ffff8205.w,a5
		move.b	(a5),d7
		move.b	#'M',(a5)	;poke new value
		cmp.b	(a5),d7		;get value again, is it same?
		beq	.notSTE	;yes same so not ste
		move.b	d7,(a5)
		move.w	#-1,ste_flag
.notSTE		rts

test_4_falcon
*** Detect Falcon computer code...
***
*** Written by MAC SYS DATA of PERSISTENCE OF VISION
***
***

; Execute in Supervisor mode

	move.l	$5a0,a0
	cmp.l	#0,a0
	beq.s	.nocookiejar
	move.l	$14(a0),d0	;get video shifter type?
	tst.l	d0
	beq.s	.notdma
	cmp.l	#$30000,d0
	beq.s	.yesfalcon
.notdma
.nocookiejar
	rts
.yesfalcon
	move.w	#-1,falcon_flag
	rts






***********************************************************************
***********							*******
***********							*******
***********		   DSP SoundTracker Replay		*******
***********							*******
***********	   Runs with most 4/6/8 Voices .MOD		*******
***********							*******
***********		    by Simplet / ABSTRACT		*******
***********							*******
***********							*******
***********************************************************************

		RsReset

Amiga_Name		rs.b	22
Amiga_Length		rs.w	1	* Taille cod‚e en words
Amiga_Fine_Tune		rs.b	1	* de 0 … 15  =  0 … 7 et -8 … -1
Amiga_Volume		rs.b	1	* de 0 … 64
Amiga_Repeat_Start	rs.w	1
Amiga_Repeat_Length	rs.w	1

Amiga_Size		rs.b	1	* 30 octets


		RsReset

Voice_Sample_Start		rs.l	1
Voice_Sample_Offset		rs.l	1
Voice_Sample_Position		rs.l	1
Voice_Sample_Length		rs.l	1
Voice_Sample_Repeat_Length	rs.l	1
Voice_Sample_Volume		rs.w	1
Voice_Sample_Period		rs.w	1
Voice_Sample_Fine_Tune		rs.w	1

Voice_Start			rs.l	1
Voice_Length			rs.l	1
Voice_Repeat_Length		rs.l	1
Voice_Volume			rs.w	1
Voice_Period			rs.w	1
Voice_Wanted_Period		rs.w	1

Voice_Note			rs.w	1
Voice_Sample			rs.b	1
Voice_Command			rs.b	1
Voice_Parameters		rs.b	1

Voice_Tone_Port_Direction	rs.b	1
Voice_Tone_Port_Speed		rs.b	1
Voice_Glissando_Control		rs.b	1
Voice_Vibrato_Command		rs.b	1
Voice_Vibrato_Position		rs.b	1
Voice_Vibrato_Control		rs.b	1
Voice_Tremolo_Command		rs.b	1
Voice_Tremolo_Position		rs.b	1
Voice_Tremolo_Control		rs.b	1
Voice_Funk_Speed		rs.b	1
Voice_Funk_Offset		rs.b	1
Voice_Funk_Position		rs.l	1
Voice_Funk_Start		rs.l	1

Voice_Size			rs.b	1

***********************************************************************
***********			Initialisations			*******
***********************************************************************


Init_Music
		bsr	Init_Module
		bra	Init_Sound

Init_Music_IT
		clr.b	$fffffa19.w		; Coupe Timer
		move.l	#SndTrack_Timer,$134.w	; Installe Vecteur
		bset.b	#5,$fffffa07.w		; Autorise Timer
		bset.b	#5,$fffffa13.w		; D‚Maske Timer
		move.b	Simplet_IT_Timer_Data(pc),$fffffa1f.w
		move.b	Simplet_IT_Timer_Control(pc),$fffffa19.w
		rts

Stop_Music_IT
		clr.b	$fffffa19.w		; Coupe Timer
		bclr.b	#5,$fffffa07.w		; Autorise Timer
		bclr.b	#5,$fffffa13.w		; D‚Maske Timer
		rts

Stop_Music
		move.b	#$80+$28/2,$ffffa201.w	; Host User 1, vecteur $28
		rts

***********************************************************************
***********	   Interruptions du Replay Soundtracker		***********
***********************************************************************

SndTrack_Timer
		bclr.b	#5,$fffffa0f.w		; … Cause du mode SEI
		move.w	#$2300,sr		; Ne bloque pas tout le monde

		ror.w	SndTrack_Timer_Cmpt
		bcc.s	SndTrack_Timer_Ret

		move.b	Simplet_IT_Timer_Data(pc),$fffffa1f.w
		move.b	Simplet_IT_Timer_Control(pc),$fffffa19.w
		move.w	Simplet_IT_Sample_Length(pc),Code_Sample_Length
		bsr.s	SndTrack_IT

SndTrack_Timer_Ret
		rte

SndTrack_Timer_Cmpt
		dc.w		%0001000100010001


SndTrack_IT
		move.l	$ffff9800.w,-(sp)
		move.l	#$ff000000,$ffff9800.w

		movem.l	d0-d7/a0-a6,-(sp)

; Signale au DSP qu'on veut causer … la routine Soundtracker
		move.b	#$80+$26/2,$ffffa201.w	; Host User 0, vecteur $26

; Port Host
		lea.l	$ffffa204.w,a6

; On balance le nombre de samples … calculer (code automodifi‚)
SplLen	move.l	#984,(a6)

Code_Sample_Length	equ	SplLen+4


		moveq.l	#0,d7
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#2,d7
		lsr.w	d7
		move.l	d7,(a6)	; Nombre de paires de voies suppl‚mentaires

; Envoie les samples au DSP

		lea.l	Simplet_Voices(pc),a5		; Gauche
		bsr.s	Play_Voice
		lea.l	Voice_Size(a5),a5		; Droite
		bsr.s	Play_Voice

		subq.w	#1,d7

Play_All_Voices
		adda.w	Increment_Voice_1(pc),a5
		bsr.s	Play_Voice
		adda.w	Increment_Voice_2(pc),a5
		bsr.s	Play_Voice

		subq.w	#1,d7
		bmi.s	No_More_Voices

		adda.w	Increment_Voice_3(pc),a5
		bsr.s	Play_Voice
		adda.w	Increment_Voice_4(pc),a5
		bsr.s	Play_Voice

		subq.w	#1,d7
		bpl.s	Play_All_Voices


; S'occupe de la partition

No_More_Voices
		bsr		Simplet_Play_Patterns

		movem.l	(sp)+,d0-d7/a0-a6

		move.l	(sp)+,$ffff9800.w
		rts

; S'occupe d'une voie : envoie volume, fr‚quence et les samples

Play_Voice
; Envoie volume
		moveq.l	#0,d0
		move.w	Voice_Sample_Volume(a5),d0
		mulu.l	#$7fffff/64*2,d0
		moveq.l	#0,d1
		move.w	Simplet_Voices_Nb(pc),d1
		divu.l	d1,d0
		move.l	d0,(a6)

; Envoie fr‚quence relative
		move.l	#$800000/49169*428*8363,d0
		moveq.l	#0,d1
		move.w	Voice_Sample_Period(a5),d1
		divu.l	d1,d0
		move.l	d0,(a6)

; Explication du calcul :
; Fr‚quence de replay d'une note =
; Periode de la Note * Base du DO-2 / Periode du DO-2
; Nous on veut le rapport avec la fr‚quence de Replay donc / 49169
; et r‚sultat … virgule pr‚multipli‚ par $800000 pour le DSP

; Recoie longueur du sample … envoyer
WaitDSP		btst.b	#0,$ffffa202.w
		beq.s	WaitDSP
		move.l	(a6),d0

		movea.l	Voice_Sample_Start(a5),a0
		move.l	Voice_Sample_Position(a5),d2
		adda.l	d2,a0				; Adresse courante
		add.l	d0,d2				; Nouvelle position d'arriv‚e

		cmp.l	Voice_Sample_Length(a5),d2	; A-t'on d‚pass‚ la fin ?
		blt.s	No_Repeat					; Si Non pas de probleme

		sub.l	Voice_Sample_Repeat_Length(a5),d2	; Si Oui, boucle

No_Repeat	move.l	d2,Voice_Sample_Position(a5)	; Nouvelle position

		ext.l	d0
		divu.l	#6,d0			; Envoi par paquet de 6 un
		addq.w	#1,d0			; de + car on tombe pas pile
		move.l	d0,(a6)			; Nombre de paquets

		subq.w	#1,d0			; pour le dbra
		subq.l	#1,a0			; Cale les samples

Send_Samples
		move.l	(a0),(a6)
		move.l	3(a0),(a6)
		addq.l	#6,a0
		dbra	d0,Send_Samples
		rts

***********************************************************************
***********		   Initialisations Son et DSP		*******
***********************************************************************

Init_Sound
* Stoppe la lecture DMA au cas o—...
		clr.b	$ffff8901.w

* DAC sur piste 0 (quartet fort)
		move.b	#$0f,$ffff8920.w

* Source DSP-Xmit sur Horloge Interne 25.175 MHz, DSP connect‚ (Enable)
* Source DMA-Play sur Horloge Interne 25.175 MHz
		move.w	#%10010001,$ffff8930.w

* Destinations DAC, DMA-Record et External OutPut
* connect‚es … Source DSP-Xmit, Handshaking On
* Destination DSP-Rec connect‚e sur DMA-Play, DSP connect‚ (Enable)
		move.w	#%0010001000010011,$ffff8932.w

* Fr‚quence 49169 Hz
		move.b	#1,$ffff8935.w

* Seulement Matrice et pas le PSG-Yamaha
		move.b	#%10,$ffff8937.w

* Programme DSP
		move.w	#113,-(sp)		; DSP_RequestUniqueAbility
		trap	#14			; XBios
		addq.l	#2,sp

	move.w	#$2300,sr
		move.w	d0,-(sp)			; No Ability
		move.l	#(DSP_End-DSP_Code)/3,-(sp)	; Longueur en Mots DSP
		pea.l	DSP_Code(pc)			; Adresse du code binaire
		move.w	#109,-(sp)			; Dsp_ExecProg
		trap	#14				; XBios
		lea.l	12(sp),sp
	move.w	#$2700,sr


Connect	move.l	#87654321,$ffffa204.w
		moveq.l	#0,d0

Conct_Get	btst.b	#0,$ffffa202.w
		bne.s	DSP_Test
		addq.l	#1,d0
		cmp.l	#100000,d0
		beq.s	DSP_Error
		bra.s	Conct_Get

DSP_Test	move.l	$ffffa204.w,d0
		cmp.l	#12345678,d0
		beq.s	DSP_Ok

DSP_Error	moveq.l	#-1,d0
DSP_Ok	rts

***********************************************************************
***********		Initialisations du Module		*******
***********************************************************************

Init_Module
		lea	mod_data,a0

		lea.l	20+31*30+2(a0),a1		; Par d‚faut
		lea.l	4+128(a1),a2			; Type
		moveq.l	#31,d0				; 31 instruments
		moveq.l	#64,d2				; 64 lignes par pattern
		sf	Simplet_Old_Module

		move.b	#125,Simplet_Tempo		; Tempo par d‚faut
		move.b	#6,Simplet_Speed		; Vitesse par d‚faut
		move.b	#5,Simplet_IT_Timer_Control
		move.b	#192,Simplet_IT_Timer_Data
		move.w	#984,Simplet_IT_Sample_Length

		move.l	$438(a0),d3			; ModFile Chunk

; Formats 4 voies
		moveq.l	#4,d1

		cmp.l	#"M.K.",d3
		beq.s	Format_Ok
		cmp.l	#"M!K!",d3
		beq.s	Format_Ok
		cmp.l	#"M&K&",d3
		beq.s	Format_Ok
		cmp.l	#"FA04",d3
		beq.s	Format_Digital
		cmp.l	#"FLT4",d3
		beq.s	Format_Ok

; Formats 6 voies
		moveq.l	#6,d1

		cmp.l	#"FA06",d3
		beq.s	Format_Digital
		cmp.l	#"6CHN",d3
		beq.s	Format_Ok
		cmp.l	#"FLT6",d3
		beq.s	Format_Ok

; Formats 8 voies
		moveq.l	#8,d1

		cmp.l	#"FA08",d3
		beq.s	Format_Digital
		cmp.l	#"8CHN",d3
		beq.s	Format_Ok
		cmp.l	#"FLT8",d3
		beq.s	Format_Ok
		cmp.l	#"OCTA",d3
		beq.s	Format_Ok

; Si rien de sp‚cial alors c'est un ancien module 15 instruments
		lea.l	20+15*30+2(a0),a1
		lea.l	128(a1),a2
		moveq.l	#15,d0
		moveq.l	#4,d1
		st	Simplet_Old_Module
		bra.s	Format_Ok

Format_Digital
		move.w	(a2)+,d2
		addq.l	#2,a2

Format_Ok	move.l	a1,Simplet_Sequence_Adr	; Adresse de la s‚quence
		move.l	a2,Simplet_Patterns_Adr	; Adresse des patterns
		move.w	d0,Simplet_Samples_Nb	; Nombre d'instruments
		move.w	d1,Simplet_Voices_Nb	; Nombre de voies
		move.w	d2,Simplet_Pattern_Length

		lsl.w	#2,d1
		move.w	d1,Simplet_Line_Size	; Taille d'une 'ligne'
		mulu.w	d2,d1
		move.w	d1,Simplet_Pattern_Size	; Taille d'un pattern

		move.b	-2(a1),d0
		move.w	d0,Simplet_Song_Length	; Longueur du module
		move.b	-1(a1),d2
		cmp.b	d0,d2				; le Restart
		blo.s	Simplet_Restart_Ok		; est-il coh‚rent ?
		moveq.l	#0,d2				; si non, Restart = 0
Simplet_Restart_Ok
		move.w	d2,Simplet_Song_Restart

		subq.w	#1,d0				; Parcours la s‚quence
		moveq.l	#0,d1				; jusqu'… la derniŠre
Simplet_Sequence_Loop					; position
		move.b	(a1)+,d2				; No Pattern
		cmp.b	d1,d2				; Plus grand
		blo.s	Simplet_Seq_No_Max		; que le maximum ?
		move.b	d2,d1				; alors Nouveau maximum
Simplet_Seq_No_Max
		dbra	d0,Simplet_Sequence_Loop


		addq.w	#1,d1				; Nombre de patterns
		mulu.w	Simplet_Pattern_Size(pc),d1	; Taille totale

		move.l	Simplet_Patterns_Adr(pc),a1	; Adresse du d‚but
		lea.l	(a1,d1.l),a1			; Des samples

		lea.l	20(a0),a2			; Pointe sur Sample 1
		moveq.l	#0,d2
		move.w	Simplet_Samples_Nb(pc),d0
		subq.w	#1,d0

Simplet_Total_Length
		move.w	Amiga_Length(a2),d3		; Longueur
		ext.l	d3				; du sample
		add.l	d3,d3				; * 2 car stock‚ en words
		add.l	d3,d2				; Ajoute au total
		lea.l	Amiga_Size(a2),a2		; Instrument suivant
		dbra		d0,Simplet_Total_Length	; Calcule longueur totale


; Recopie les samples … la fin de la zone de travail temporaire
; pour justement pouvoir travailler dessus, les pr‚parer au bouclage
		lea.l	workspc,a2

		move.l	a1,a3
		add.l	d2,a1

Simplet_Move_Samples
		move.l	-(a1),-(a2)
		move.l	-(a1),-(a2)
		subq.l	#8,d2
		bpl.s	Simplet_Move_Samples


; Maintenant, on bosse sur les samples
		lea.l	20(a0),a0			; Pointe sur 1er Sample
		lea.l	Simplet_Samples_Adr(pc),a1	; Adresse des samples

		move.w	Simplet_Samples_Nb(pc),d0
		subq.w	#1,d0

Simplet_Next_Sample
		move.l	a3,(a1)+			; Note Adresse

		move.w	Amiga_Length(a0),d3		; Longueur Nulle ?
		beq		Simplet_NextSample	; Alors pas d'instrument

		move.w	Amiga_Repeat_Length(a0),d4	; Longueur de Boucle
		cmp.w	#1,d4				; sup‚rieure … 1 ?
		bhi.s	Simplet_Repeat_Length		; Alors il y a bouclage


Simplet_No_Repeat_Length
		move.w	d3,d1				; Longueur
		subq.w	#1,d1
Simplet_Copy_1
		move.w	(a2)+,(a3)+			; Recopie simplement
		dbra	d1,Simplet_Copy_1		; le sample

		move.w	#1400-1,d2
Simplet_Copy_2
		clr.w	(a3)+				; et met du vide aprŠs
		dbra	d2,Simplet_Copy_2		; car ne boucle pas

		move.w	#1400,d1			; Repeat Length pour
		bra.s	Simplet_Sample_Ok		; boucler dans le vide


Simplet_Repeat_Length
		tst.w	Amiga_Repeat_Start(a0)	; Y'a t'il un d‚but de boucle?
		bne.s	Simplet_Repeat_Start	; Oui


		move.l	a3,a4			; Note le d‚but du sample

		move.w	d3,d1			; Longueur
		subq.w	#1,d1
Simplet_Copy_3
		move.w	(a2)+,(a3)+		; Recopie le sample jusqu'…
		dbra	d1,Simplet_Copy_3	; La fin de la boucle
		bra.s	Simplet_No_Repeat_Start


Simplet_Repeat_Start
		move.w	Amiga_Repeat_Start(a0),d1	; On prend le sample
		move.w	d1,d3				; jusqu'au d‚but de la
		move.l	a2,a4				; boucle

		subq.w	#1,d1
Simplet_Copy_4
		move.w	(a4)+,(a3)+
		dbra	d1,Simplet_Copy_4

		add.w	Amiga_Length(a0),a2
		add.w	Amiga_Length(a0),a2

Simplet_No_Repeat_Start
		move.l	a3,a5
		moveq.l	#0,d1

Simplet_Too_Small
		move.l	a4,a6
		move.w	d4,d2
		subq.w	#1,d2

Simplet_Copy_5
		move.w	(a6)+,(a3)+
		addq.w	#2,d1
		dbra	d2,Simplet_Copy_5

		cmp.w	#1400,d1
		blo.s	Simplet_Too_Small

		move.w	#1400/2-1,d2
Simplet_Copy_6
		move.w	(a5)+,(a3)+
		dbra	d2,Simplet_Copy_6


Simplet_Sample_Ok
		lsl.w	d3
		move.w	d3,Amiga_Length(a0)
		move.w	d1,Amiga_Repeat_Length(a0)
		clr.w	Amiga_Repeat_Start(a0)

Simplet_NextSample
		lea.l	Amiga_Size(a0),a0
		dbra	d0,Simplet_Next_Sample


		move.b	Simplet_Speed(pc),Simplet_Counter
		move.w	#-1,Simplet_Pattern_Position
		clr.w	Simplet_Song_Position
		clr.w	Simplet_Pattern_Break_Position
		sf	Simplet_Pattern_Break_Flag
		sf	Simplet_Position_Jump_Flag
		sf	Simplet_Pattern_Loop_Flag
		clr.b	Simplet_Pattern_Delay_Time


		lea.l	workspc,a0
		move.l	#1000,d1
		move.l	#500,d2
		move.w	#2345,d4
		moveq.l	#0,d5

		lea.l	Simplet_Voices(pc),a6
		moveq.l	#8-1,d7

Init_A_Voice
		clr.l	Voice_Sample_Offset(a6)
		clr.l	Voice_Sample_Position(a6)
		move.l	a0,Voice_Sample_Start(a6)
		move.l	d1,Voice_Sample_Length(a6)
		move.l	d2,Voice_Sample_Repeat_Length(a6)
		move.w	d4,Voice_Sample_Period(a6)
		move.w	d5,Voice_Sample_Volume(a6)
		move.l	a0,Voice_Start(a6)
		move.l	d1,Voice_Length(a6)
		move.l	d2,Voice_Repeat_Length(a6)
		move.w	d4,Voice_Period(a6)
		move.w	d5,Voice_Volume(a6)
		move.l	a0,Voice_Funk_Start(a6)

		clr.l	Voice_Tone_Port_Direction(a6)
		clr.l	Voice_Vibrato_Position(a6)
		clr.b	Voice_Tremolo_Control(a6)
		clr.w	Voice_Funk_Speed(a6)
		clr.l	Voice_Funk_Position(a6)

		lea.l	Voice_Size(a6),a6
		dbra	d7,Init_A_Voice
		rts

***********************************************************************
***********		Remet les voies … z‚ro			*******
***********************************************************************

Clear_Voices
		lea.l	workspc,a0
		move.l	#1000,d1
		move.l	#500,d2
		move.w	#2345,d4
		moveq.l	#0,d5

		lea.l	Simplet_Voices(pc),a6
		moveq.l	#8-1,d7

Clear_A_Voice
		clr.l	Voice_Sample_Offset(a6)
		clr.l	Voice_Sample_Position(a6)
		move.l	a0,Voice_Sample_Start(a6)
		move.l	d1,Voice_Sample_Length(a6)
		move.l	d2,Voice_Sample_Repeat_Length(a6)
		move.w	d4,Voice_Sample_Period(a6)
		move.w	d5,Voice_Sample_Volume(a6)
		move.l	a0,Voice_Start(a6)
		move.l	d1,Voice_Length(a6)
		move.l	d2,Voice_Repeat_Length(a6)
		move.w	d4,Voice_Period(a6)
		move.w	d5,Voice_Volume(a6)

		lea.l	Voice_Size(a6),a6
		dbra	d7,Clear_A_Voice
		rts

***********************************************************************
***********		Gestion du Soundtrack			*******
***********************************************************************

Simplet_Play_Patterns
		addq.b	#1,Simplet_Counter
		move.b	Simplet_Counter(pc),d0
		cmp.b	Simplet_Speed(pc),d0
		blo	Simplet_No_New_Note

		clr.b	Simplet_Counter

		tst.b	Simplet_Pattern_Break_Flag(pc)
		bne.s	Simplet_New_Pattern

		tst.b	Simplet_Pattern_Delay_Time(pc)
		beq.s	Simplet_No_Delay

		subq.b	#1,Simplet_Pattern_Delay_Time
		bra	Simplet_No_New_Note

Simplet_No_Delay
		tst.b	Simplet_Pattern_Loop_Flag(pc)
		beq.s	Simplet_No_Pattern_Loop

		move.w	Simplet_Pattern_Loop_Position(pc),Simplet_Pattern_Position
		sf	Simplet_Pattern_Loop_Flag
		bra.s	Simplet_New_Notes

Simplet_No_Pattern_Loop
		tst.b	Simplet_Position_Jump_Flag(pc)
		beq.s	Simplet_New_Line

		move.w	Simplet_Position_Jump_Pos(pc),d0
		sf	Simplet_Position_Jump_Flag
		bra.s	Simplet_New_Position

Simplet_New_Line
		addq.w	#1,Simplet_Pattern_Position
		move.w	Simplet_Pattern_Position(pc),d0
		cmp.w	Simplet_Pattern_Length(pc),d0
		blo.s	Simplet_New_Notes

Simplet_New_Pattern
		move.w	Simplet_Song_Position(pc),d0
		addq.w	#1,d0

Simplet_New_Position
		move.w	Simplet_Pattern_Break_Position(pc),Simplet_Pattern_Position
		clr.w	Simplet_Pattern_Break_Position
		sf	Simplet_Pattern_Break_Flag

		cmp.w	Simplet_Song_Length(pc),d0
		blo.s	Simplet_No_Restart
		move.w	Simplet_Song_Restart(pc),d0
		bne.s	Simplet_No_Restart

		move.b	#125,Simplet_Tempo
		move.b	#6,Simplet_Speed
		move.b	#5,Simplet_IT_Timer_Control
		move.b	#192,Simplet_IT_Timer_Data
		move.w	#984,Simplet_IT_Sample_Length

Simplet_No_Restart
		move.w	d0,Simplet_Song_Position


Simplet_New_Notes
		lea.l	mod_data+20(pc),a5		; Pointe sur infos samples
		movea.l	Simplet_Sequence_Adr(pc),a0
		move.w	Simplet_Song_Position(pc),d1
		moveq.l	#0,d0
		move.b	(a0,d1.w),d0
		mulu.w	Simplet_Pattern_Size(pc),d0
		movea.l	Simplet_Patterns_Adr(pc),a4
		adda.l	d0,a4				; Pointe sur le Pattern
		move.w	Simplet_Pattern_Position(pc),d0
		mulu.w	Simplet_Line_Size(pc),d0
		adda.w	d0,a4				; Pointe sur la Bonne Ligne


		lea.l	Simplet_Voices(pc),a6
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#1,d7
Simplet_New_Notes_Loop
		bsr.s	Simplet_Play_Voice

		lea.l	Voice_Size(a6),a6
		dbra	d7,Simplet_New_Notes_Loop
		rts


Simplet_No_New_Note
		lea.l	Simplet_Voices(pc),a6
		move.w	Simplet_Voices_Nb(pc),d7
		subq.w	#1,d7
Simplet_No_New_Note_Loop
		bsr	Simplet_Check_Efx_2

		lea.l	Voice_Size(a6),a6
		dbra	d7,Simplet_No_New_Note_Loop
		rts


Simplet_Play_Voice
		move.w	(a4)+,d1
		move.b	(a4)+,d2
		move.b	(a4)+,Voice_Parameters(a6)

		move.w	d1,d0
		and.w	#$0fff,d0
		move.w	d0,Voice_Note(a6)
		and.w	#$f000,d1
		lsr.w	#8,d1
		move.b	d2,d0
		lsr.b	#4,d0
		add.b	d1,d0
		move.b	d0,Voice_Sample(a6)
		and.b	#$0f,d2
		move.b	d2,Voice_Command(a6)

		moveq.l	#0,d2
		move.b	Voice_Sample(a6),d2
		beq.s	Simplet_No_New_Sample

		subq.w	#1,d2
		lea.l	Simplet_Samples_Adr(pc),a1
		move.l	(a1,d2.w*4),Voice_Start(a6)
		clr.l	Voice_Sample_Offset(a6)
		mulu.w	#Amiga_Size,d2
		moveq.l	#0,d0
		move.w	Amiga_Length(a5,d2.w),d0
		move.l	d0,Voice_Length(a6)
		move.w	Amiga_Repeat_Length(a5,d2.w),d0
		move.l	d0,Voice_Repeat_Length(a6)
		moveq.l	#0,d0
		move.b	Amiga_Volume(a5,d2.w),d0
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Amiga_Fine_Tune(a5,d2.w),d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)

		move.w	Amiga_Repeat_Start(a5,d2.w),d0
		add.l	Voice_Start(a6),d0
		move.l	d0,Voice_Funk_Start(a6)

Simplet_No_New_Sample
		tst.w	Voice_Note(a6)
		beq	Simplet_Check_Efx_1

		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0e50,d0
		beq.s	Simplet_Do_Set_Fine_Tune

		move.b	Voice_Command(a6),d0
		subq.b	#3,d0				; 3 = Tone Portamento
		beq	Simplet_Set_Tone_Portamento
		subq.b	#2,d0				; 5 = Tone Porta + Vol Slide
		beq	Simplet_Set_Tone_Portamento
		subq.b	#4,d0				; 9 = Sample Offset
		bne.s	Simplet_Set_Period

		bsr	Simplet_Sample_Offset
		bra.s	Simplet_Set_Period

Simplet_Do_Set_Fine_Tune
		bsr	Simplet_Set_Fine_Tune

Simplet_Set_Period
		lea.l	Simplet_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr	Simplet_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),Voice_Period(a6)


		move.w	Voice_Command(a6),d0
		and.w	#$0ff0,d0
		cmp.w	#$0ed0,d0
		bne.s	Simplet_No_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		beq.s	Simplet_No_Note_Delay
		rts

Simplet_No_Note_Delay
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Length(a6),d0
		move.l	Voice_Repeat_Length(a6),d1
		add.l	d1,d0
		move.l	d0,Voice_Sample_Length(a6)
		move.l	d1,Voice_Sample_Repeat_Length(a6)


		btst.b	#2,Voice_Vibrato_Control(a6)
		bne.s	Simplet_Vibrato_No_Reset
		clr.b	Voice_Vibrato_Position(a6)
Simplet_Vibrato_No_Reset

		btst.b	#2,Voice_Tremolo_Control(a6)
		bne.s	Simplet_Tremolo_No_Reset
		clr.b	Voice_Tremolo_Position(a6)
Simplet_Tremolo_No_Reset


Simplet_Check_Efx_1
		bsr	Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp	([Jump_Table_1,d0.w*4])

Jump_Table_1
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Period_Nop
		dc.l	Simplet_Period_Nop,Simplet_Position_Jump
		dc.l	Simplet_Volume_Change,Simplet_Pattern_Break
		dc.l	Simplet_E_Commands_1,Simplet_Set_Speed

Simplet_E_Commands_1
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp	([Jump_Table_E1,d0.w*4])

Jump_Table_E1
		dc.l	Simplet_Return,Simplet_Fine_Portamento_Up
		dc.l	Simplet_Fine_Portamento_Down,Simplet_Set_Glissando_Control
		dc.l	Simplet_Set_Vibrato_Control,Simplet_Return
		dc.l	Simplet_Pattern_Loop,Simplet_Set_Tremolo_Control
		dc.l	Simplet_Return,Simplet_Retrig_Note
		dc.l	Simplet_Volume_Fine_Up,Simplet_Volume_Slide_Down
		dc.l	Simplet_Note_Cut,Simplet_Return
		dc.l	Simplet_Pattern_Delay,Simplet_Funk_It


Simplet_Check_Efx_2
		bsr	Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Command(a6),d0
		jmp	([Jump_Table_2,d0.w*4])

Jump_Table_2
		dc.l	Simplet_Arpeggio,Simplet_Portamento_Up
		dc.l	Simplet_Portamento_Down,Simplet_Tone_Portamento
		dc.l	Mt_Vibrato,Simplet_Tone_Portamento_Plus_Volume_Slide
		dc.l	Simplet_Vibrato_Plus_Volume_Slide,Mt_Tremolo
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Volume_Slide,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_E_Commands_2,Simplet_Return

Simplet_E_Commands_2
		move.b	Voice_Parameters(a6),d0
		and.w	#$f0,d0
		lsr.w	#4,d0
		jmp	([Jump_Table_E2,d0.w*4])

Jump_Table_E2
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Return,Simplet_Retrig_Note
		dc.l	Simplet_Return,Simplet_Return
		dc.l	Simplet_Note_Cut,Simplet_Note_Delay
		dc.l	Simplet_Return,Simplet_Return


Simplet_Find_Period
		cmp.w	12*2(a0),d0
		bhs.s	Simplet_Do_Find_Period
		lea.l	12*2(a0),a0
		cmp.w	12*2(a0),d0
		bhs.s	Simplet_Do_Find_Period
		lea.l	12*2(a0),a0

Simplet_Do_Find_Period
		moveq.l	#12-1,d3
Simplet_Find_Period_Loop
		cmp.w	(a0)+,d0
		dbhs	d3,Simplet_Find_Period_Loop
		blo.s	Simplet_Period_Found
		subq.l	#2,a0
Simplet_Period_Found
		rts


Simplet_Period_Nop
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)

Simplet_Return
		rts

Simplet_Arpeggio_Table
		dc.b	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
		dc.b	1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

Simplet_Arpeggio
		move.b	Voice_Parameters(a6),d1
		beq.s	Simplet_Period_Nop

		moveq.l	#0,d0
		move.b	Simplet_Counter(pc),d0
		move.b	Simplet_Arpeggio_Table(pc,d0.w),d0
		beq.s	Simplet_Period_Nop
		subq.b	#2,d0
		beq.s	Simplet_Arpeggio_2

Simplet_Arpeggio_1
		lsr.w	#4,d1
Simplet_Arpeggio_2
		and.w	#$f,d1

		lea.l	Simplet_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	Voice_Period(a6),d0
		bsr.s	Simplet_Find_Period
		move.w	(a0,d1.w*2),Voice_Sample_Period(a6)
		rts


Simplet_Portamento_Up
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

Simplet_Portamento_Up2
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#113,d0
		bhi.s	Simplet_Portamento_Up_Ok
		move.w	#113,Voice_Period(a6)

Simplet_Portamento_Up_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts

 
Simplet_Portamento_Down
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
Simplet_Portamento_Down2
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Period(a6),d0
		cmp.w	#856,d0
		blo.s	Simplet_Portamento_Down_Ok
		move.w	#856,Voice_Period(a6)

Simplet_Portamento_Down_Ok
		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		rts


Simplet_Set_Tone_Portamento
		lea.l	Simplet_Period_Table(pc),a0
		move.w	Voice_Note(a6),d0
		bsr	Simplet_Find_Period
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		move.w	(a0),d0

		move.w	d0,Voice_Wanted_Period(a6)
		move.w	Voice_Period(a6),d1
		sf	Voice_Tone_Port_Direction(a6)
		cmp.w	d1,d0
		beq.s	Simplet_Clear_Tone_Portamento
		bge	Simplet_Period_Nop
		st	Voice_Tone_Port_Direction(a6)
		rts

Simplet_Clear_Tone_Portamento
		clr.w	Voice_Wanted_Period(a6)
		rts

Simplet_Tone_Portamento
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_Tone_Portamento_No_Change
		move.b	d0,Voice_Tone_Port_Speed(a6)
		clr.b	Voice_Parameters(a6)

Simplet_Tone_Portamento_No_Change
		tst.w	Voice_Wanted_Period(a6)
		beq	Simplet_Period_Nop
		moveq.l	#0,d0
		move.b	Voice_Tone_Port_Speed(a6),d0
		tst.b	Voice_Tone_Port_Direction(a6)
		bne.s	Simplet_Tone_Portamento_Up

Simplet_Tone_Portamento_Down
		add.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		bgt.s	Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)
		bra.s	Simplet_Tone_Portamento_Set_Period

Simplet_Tone_Portamento_Up
		sub.w	d0,Voice_Period(a6)
		move.w	Voice_Wanted_Period(a6),d0
		cmp.w	Voice_Period(a6),d0
		blt.s	Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Wanted_Period(a6),Voice_Period(a6)
		clr.w	Voice_Wanted_Period(a6)


Simplet_Tone_Portamento_Set_Period
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Glissando_Control(a6)
		beq.s	Simplet_Glissando_Skip

		lea.l	Simplet_Period_Table(pc),a0
		adda.w	Voice_Sample_Fine_Tune(a6),a0
		bsr	Simplet_Find_Period
		move.w	(a0),d0

Simplet_Glissando_Skip
		move.w	d0,Voice_Sample_Period(a6)
		rts


Mt_Vibrato
		move.b	Voice_Parameters(a6),d0
		beq.s	Mt_Vibrato2
		move.b	Voice_Vibrato_Command(a6),d2
		and.b	#$0f,d0
		beq.s	Mt_VibSkip
		and.b	#$f0,d2
		or.b	d0,d2
Mt_VibSkip
		move.b	Voice_Parameters(a6),d0
		and.b	#$f0,d0
		beq.s	Mt_vibskip2
		and.b	#$0f,d2
		or.b	d0,d2
Mt_vibskip2
		move.b	d2,Voice_Vibrato_Command(a6)
Mt_Vibrato2
		move.b	Voice_Vibrato_Position(a6),d0
		lea.l	Simplet_Sinus_Table(pc),a3
		lsr.w	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Vibrato_Control(a6),d2
		and.b	#$3,d2
		beq.s	Mt_Vib_Sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	Mt_Vib_RampDown
		move.b	#255,d2
		bra.s	Mt_Vib_Set
Mt_Vib_RampDown
		tst.b	Voice_Vibrato_Position(a6)
		bpl.s	Mt_Vib_RampDown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	Mt_Vib_Set
Mt_Vib_RampDown2
		move.b	d0,d2
		bra.s	Mt_Vib_Set
Mt_Vib_Sine
		move.b	(a3,d0.w),d2
Mt_Vib_Set
		move.b	Voice_Vibrato_Command(a6),d0
		and.w	#15,d0
		mulu.w	d0,d2
		lsr.w	#7,d2
		move.w	Voice_Period(a6),d0
		tst.b	Voice_Vibrato_Position(a6)
		bmi.s	Mt_VibratoNeg
		add.w	d2,d0
		bra.s	Mt_Vibrato3
Mt_VibratoNeg
		sub.w	d2,d0
Mt_Vibrato3
		move.w	d0,Voice_Sample_Period(a6)
		move.b	Voice_Vibrato_Command(a6),d0
		lsr.w	#2,d0
		and.w	#$003c,d0
		add.b	d0,Voice_Vibrato_Position(a6)
		rts

Simplet_Tone_Portamento_Plus_Volume_Slide
		bsr	Simplet_Tone_Portamento_No_Change
		bra	Simplet_Volume_Slide


Simplet_Vibrato_Plus_Volume_Slide
		bsr.s	Mt_Vibrato2
		bra	Simplet_Volume_Slide

Mt_Tremolo
		move.b	Voice_Parameters(a6),d0
		beq.s	Mt_Tremolo2
		move.b	Voice_Tremolo_Command(a6),d2
		and.b	#$0f,d0
		beq.s	Mt_treskip
		and.b	#$f0,d2
		or.b	d0,d2
Mt_treskip
		move.b	Voice_Parameters(a6),d0
		and.b	#$f0,d0
		beq.s	Mt_treskip2
		and.b	#$0f,d2
		or.b	d0,d2
Mt_treskip2
		move.b	d2,Voice_Tremolo_Command(a6)
Mt_Tremolo2
		move.b	Voice_Tremolo_Position(a6),d0
		lea.l	Simplet_Sinus_Table(pc),a3
		lsr.w	#2,d0
		and.w	#$001f,d0
		moveq.l	#0,d2
		move.b	Voice_Tremolo_Control(a6),d2
		and.b	#$3,d2
		beq.s	Mt_tre_sine
		lsl.b	#3,d0
		cmp.b	#1,d2
		beq.s	Mt_tre_rampdown
		move.b	#255,d2
		bra.s	Mt_tre_set
Mt_tre_rampdown
		tst.b	Voice_Tremolo_Position(a6)
		bpl.s	Mt_tre_rampdown2
		move.b	#255,d2
		sub.b	d0,d2
		bra.s	Mt_tre_set
Mt_tre_rampdown2
		move.b	d0,d2
		bra.s	Mt_tre_set
Mt_tre_sine
		move.b	(a3,d0.w),d2
Mt_tre_set
		move.b	Voice_Tremolo_Command(a6),d0
		and.w	#15,d0
		mulu.w	d0,d2
		lsr.w	#6,d2
		moveq.l	#0,d0
		move.w	Voice_Volume(a6),d0
		tst.b	Voice_Tremolo_Position(a6)
		bmi.s	Mt_TremoloNeg
		add.w	d2,d0
		bra.s	Mt_Tremolo3
Mt_TremoloNeg
		sub.w	d2,d0
Mt_Tremolo3
		bpl.s	Mt_TremoloSkip
		clr.w	d0
Mt_TremoloSkip
		cmp.w	#$40,d0
		bls.s	Mt_TremoloOk
		move.w	#$40,d0
Mt_TremoloOk
		move.w	d0,Voice_Sample_Volume(a6)
		move.b	Voice_Tremolo_Command(a6),d0
		lsr.w	#2,d0
		and.w	#$003c,d0
		add.b	d0,Voice_Tremolo_Position(a6)
		bra	Simplet_Period_Nop


Simplet_Sample_Offset
		move.l	Voice_Sample_Offset(a6),d1
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_Sample_Offset_No_New

		lsl.w	#8,d0
		move.l	d0,d1
Simplet_Sample_Offset_No_New

		move.l	Voice_Sample_Offset(a6),d0
		add.l	d1,d0
		cmp.l	Voice_Length(a6),d0
		ble.s	Simplet_Sample_Offset_Ok
		move.l	Voice_Length(a6),d0
Simplet_Sample_Offset_Ok
		move.l	d0,Voice_Sample_Offset(a6)
		move.l	d0,Voice_Sample_Position(a6)
		rts


Simplet_Volume_Slide
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		lsr.w	#4,d0
		beq.s	Simplet_Volume_Slide_Down

Simplet_Volume_Slide_Up
		add.w	d0,Voice_Volume(a6)
		cmp.w	#$40,Voice_Volume(a6)
		ble.s	Simplet_Volume_Slide_Up_Ok
		move.w	#$40,Voice_Volume(a6)

Simplet_Volume_Slide_Up_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra	Simplet_Period_Nop


Simplet_Volume_Slide_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0

Simplet_Volume_Slide_Down2
		sub.w	d0,Voice_Volume(a6)
		bpl.s	Simplet_Volume_Slide_Down_Ok
		clr.w	Voice_Volume(a6)

Simplet_Volume_Slide_Down_Ok
		move.w	Voice_Volume(a6),Voice_Sample_Volume(a6)
		bra	Simplet_Period_Nop


Simplet_Position_Jump
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0

		move.w	d0,Simplet_Position_Jump_Pos
		st	Simplet_Position_Jump_Flag
		rts


Simplet_Volume_Change
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		cmp.b	#$40,d0
		ble.s	Simplet_Volume_Change_Ok
		moveq.l	#$40,d0

Simplet_Volume_Change_Ok
		move.w	d0,Voice_Volume(a6)
		move.w	d0,Voice_Sample_Volume(a6)
		rts


Simplet_Pattern_Break
		moveq.l	#0,d0

		tst.b	Simplet_Old_Module(pc)
		bne.s	Simplet_Pattern_Break_Ok

		move.b	Voice_Parameters(a6),d0

		move.w	d0,d2			; Codage en BCD
		lsr.w	#4,d0			; premier chiffre
		mulu.w	#10,d0			; les dizaines
		and.w	#$0f,d2			; deuxiŠme chiffre
		add.w	d2,d0			; les unit‚s

		cmp.w	Simplet_Pattern_Length(pc),d0
		blo.s	Simplet_Pattern_Break_Ok
		moveq.l	#0,d0
	
Simplet_Pattern_Break_Ok
		move.w	d0,Simplet_Pattern_Break_Position
		st	Simplet_Pattern_Break_Flag
		rts


Simplet_Set_Speed
		moveq.l	#0,d0
		move.b	Voice_Parameters(a6),d0
		beq.s	Simplet_End
		cmp.b	#32,d0
		bhi.s	Simplet_Set_Tempo
		move.b	d0,Simplet_Speed
Simplet_End
		rts

Simplet_Set_Tempo
		move.b	d0,Simplet_Tempo
		sub.b	#32,d0
		lea.l	Simplet_Tempo_Table(pc),a2
		move.w	(a2,d0.w*4),Simplet_IT_Sample_Length
		move.b	2(a2,d0.w*4),Simplet_IT_Timer_Control
		move.b	3(a2,d0.w*4),Simplet_IT_Timer_Data
		rts


Simplet_Fine_Portamento_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra	Simplet_Portamento_Up2
 
Simplet_Fine_Portamento_Down
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra	Simplet_Portamento_Down2


Simplet_Set_Glissando_Control
		move.b	Voice_Parameters(a6),Voice_Glissando_Control(a6)
		rts

Simplet_Set_Vibrato_Control
		move.b	Voice_Parameters(a6),Voice_Vibrato_Control(a6)
		rts

Simplet_Set_Fine_Tune
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		mulu.w	#12*3*2,d0
		move.w	d0,Voice_Sample_Fine_Tune(a6)
		rts

Simplet_Pattern_Loop
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	Simplet_Set_Loop_Position

		tst.w	Simplet_Pattern_Loop_Counter(pc)
		beq.s	Simplet_Set_Loop_Counter

		subq.w	#1,Simplet_Pattern_Loop_Counter
		beq	Simplet_Return

Simplet_Do_Loop	
		st	Simplet_Pattern_Loop_Flag
		rts
Simplet_Set_Loop_Counter
		move.w	d0,Simplet_Pattern_Loop_Counter
		bra.s	Simplet_Do_Loop
Simplet_Set_Loop_Position
		move.w	Simplet_Pattern_Position(pc),Simplet_Pattern_Loop_Position
		rts


Simplet_Set_Tremolo_Control
		move.b	Voice_Parameters(a6),Voice_Tremolo_Control(a6)
		rts


Simplet_Retrig_Note
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		beq.s	Simplet_No_Retrig_Note

		moveq.l	#0,d1
		move.b	Simplet_Counter(pc),d1
		bne.s	Simplet_Retrig_Note_Skip

		tst.w	Voice_Note(a6)
		bne.s	Simplet_No_Retrig_Note

Simplet_Retrig_Note_Skip
		divu.w	d0,d1
		swap.w	d1
		tst.w	d1
		bne.s	Simplet_No_Retrig_Note

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)

Simplet_No_Retrig_Note
		rts


Simplet_Volume_Fine_Up
		move.b	Voice_Parameters(a6),d0
		and.w	#$0f,d0
		bra	Simplet_Volume_Slide_Up


Simplet_Note_Cut
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	Simplet_Counter(pc),d0
		bne	Simplet_Return
		clr.w	Voice_Volume(a6)
		clr.w	Voice_Sample_Volume(a6)
		rts

Simplet_Note_Delay
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		cmp.b	Simplet_Counter(pc),d0
		bne	Simplet_Return
		tst.w	Voice_Note(a6)
		beq	Simplet_Return

		move.w	Voice_Period(a6),Voice_Sample_Period(a6)
		move.l	Voice_Start(a6),Voice_Sample_Start(a6)
		move.l	Voice_Sample_Offset(a6),Voice_Sample_Position(a6)
		move.l	Voice_Length(a6),d0
		move.l	Voice_Repeat_Length(a6),d1
		add.l	d1,d0
		move.l	d0,Voice_Sample_Length(a6)
		move.l	d1,Voice_Sample_Repeat_Length(a6)
		rts


Simplet_Pattern_Delay
		tst.b	Simplet_Pattern_Delay_Time(pc)
		bne	Simplet_Return
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,Simplet_Pattern_Delay_Time
		rts


Simplet_Funk_It
		move.b	Voice_Parameters(a6),d0
		and.b	#$0f,d0
		move.b	d0,Voice_Funk_Speed(a6)
		beq	Simplet_Return

Simplet_Funk_Update
		moveq.l	#0,d0
		move.b	Voice_Funk_Speed(a6),d0
		beq	Simplet_Return

		lea.l	Simplet_Funk_Table(pc),a0
		move.b	(a0,d0.w),d0
		add.b	d0,Voice_Funk_Offset(a6)
		btst.b	#7,Voice_Funk_Offset(a6)
		beq	Simplet_Return

		clr.b	Voice_Funk_Offset(a6)

		movea.l	Voice_Funk_Position(a6),a0
		addq.w	#1,a0
		cmpa.l	Voice_Repeat_Length(a6),a0
		blo.s	Simplet_Funk_Ok
		movea.w	#0,a0
Simplet_Funk_Ok
		move.l	a0,Voice_Funk_Position(a6)
		add.l	Voice_Funk_Start(a6),a0
		moveq.l	#-1,d0
		sub.b	(a0),d0
		move.b	d0,(a0)
		rts		


Simplet_Sinus_Table	
		dc.b	0,24,49,74,97,120,141,161,180,197,212,224
		dc.b	235,244,250,253,255,253,250,244,235,224
		dc.b	212,197,180,161,141,120,97,74,49,24

Simplet_Funk_Table
		dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128


Simplet_Period_Table
; Tuning 0, Normal
		dc.w 856,808,762,720,678,640,604,570,538,508,480,453
		dc.w 428,404,381,360,339,320,302,285,269,254,240,226
		dc.w 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
		dc.w 850,802,757,715,674,637,601,567,535,505,477,450
		dc.w 425,401,379,357,337,318,300,284,268,253,239,225
		dc.w 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
		dc.w 844,796,752,709,670,632,597,563,532,502,474,447
		dc.w 422,398,376,355,335,316,298,282,266,251,237,224
		dc.w 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
		dc.w 838,791,746,704,665,628,592,559,528,498,470,444
		dc.w 419,395,373,352,332,314,296,280,264,249,235,222
		dc.w 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
		dc.w 832,785,741,699,660,623,588,555,524,495,467,441
		dc.w 416,392,370,350,330,312,294,278,262,247,233,220
		dc.w 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
		dc.w 826,779,736,694,655,619,584,551,520,491,463,437
		dc.w 413,390,368,347,328,309,292,276,260,245,232,219
		dc.w 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
		dc.w 820,774,730,689,651,614,580,547,516,487,460,434
		dc.w 410,387,365,345,325,307,290,274,258,244,230,217
		dc.w 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
		dc.w 814,768,725,684,646,610,575,543,513,484,457,431
		dc.w 407,384,363,342,323,305,288,272,256,242,228,216
		dc.w 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
		dc.w 907,856,808,762,720,678,640,604,570,538,508,480
		dc.w 453,428,404,381,360,339,320,302,285,269,254,240
		dc.w 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
		dc.w 900,850,802,757,715,675,636,601,567,535,505,477
		dc.w 450,425,401,379,357,337,318,300,284,268,253,238
		dc.w 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
		dc.w 894,844,796,752,709,670,632,597,563,532,502,474
		dc.w 447,422,398,376,355,335,316,298,282,266,251,237
		dc.w 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
		dc.w 887,838,791,746,704,665,628,592,559,528,498,470
		dc.w 444,419,395,373,352,332,314,296,280,264,249,235
		dc.w 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
		dc.w 881,832,785,741,699,660,623,588,555,524,494,467
		dc.w 441,416,392,370,350,330,312,294,278,262,247,233
		dc.w 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
		dc.w 875,826,779,736,694,655,619,584,551,520,491,463
		dc.w 437,413,390,368,347,328,309,292,276,260,245,232
		dc.w 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
		dc.w 868,820,774,730,689,651,614,580,547,516,487,460
		dc.w 434,410,387,365,345,325,307,290,274,258,244,230
		dc.w 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
		dc.w 862,814,768,725,684,646,610,575,543,513,484,457
		dc.w 431,407,384,363,342,323,305,288,272,256,242,228
		dc.w 216,203,192,181,171,161,152,144,136,128,121,114


; Table qui contient les paramŠtres pour l'interruption Timer
; et le nombre de samples … calculer en fonction du Tempo

Simplet_Tempo_Table
	dc.l	$F0207F0,$E8207E8,$E1207E1,$DB207DB,$D5207D5,$CF207CF
	dc.l	$CA207CA,$C4207C4,$C0207C0,$BB207BB,$B6207B6,$B2207B2
	dc.l	$AE207AE,$AA207AA,$A6207A6,$A3207A3,$A0207A0,$9C2079C
	dc.l	$9920799,$9620796,$9320793,$9020790,$8E2078E,$8B2078B
	dc.l	$8920789,$8620786,$8420784,$8220782,$8020780,$7DA06FB
	dc.l	$7BA06F7,$79A06F3,$78206F0,$76206EC,$74206E8,$72A06E5
	dc.l	$70A06E1,$6F206DE,$6DA06DB,$6C206D8,$6AA06D5,$69206D2
	dc.l	$67A06CF,$66206CC,$65206CA,$63A06C7,$62206C4,$61206C2
	dc.l	$60206C0,$5EA06BD,$5DA06BB,$5CA06B9,$5B206B6,$5A106B4
	dc.l	$59106B2,$58106B0,$57106AE,$56106AC,$55106AA,$54106A8
	dc.l	$53106A6,$52906A5,$51B05FF,$50C05FC,$50105FA,$4F205F7
	dc.l	$4E305F4,$4D9069B,$4CE05F0,$4C10698,$4B505EB,$4AA05E9
	dc.l	$49B05E6,$4910692,$48705E2,$47C05E0,$47205DE,$46805DC
	dc.l	$45E05DA,$45305D8,$4490689,$43F05D4,$43505D2,$42A05D0
	dc.l	$4210684,$41B05CD,$4110682,$4090681,$40105C8,$3F705C6
	dc.l	$3ED04FB,$3E805C3,$3DE05C1,$3D805C0,$3CE05BE,$3C504F1
	dc.l	$3C104F0,$3BA05BA,$3B104EC,$3AA05B7,$3A104E8,$39B05B4
	dc.l	$39605B3,$38D04E3,$38605B0,$38104E0,$37904DE,$37504DD
	dc.l	$36D04DB,$36805AA,$36305A9,$35904D6,$35504D5,$34E05A5
	dc.l	$34904D2,$34405A3,$33F05A2,$33A05A1,$33405A0,$32D04CB
	dc.l	$32904CA,$32104C8,$31D04C7,$31904C6,$31104C4,$30D04C3
	dc.l	$30904C2,$30504C1,$30104C0,$2FC0595,$2F70594,$2F20593
	dc.l	$2ED04BB,$2E904BA,$2E504B9,$2DD058F,$2D904B6,$2D8058E
	dc.l	$2D3058D,$2CE058C,$2C904B2,$2C504B1,$2C104B0,$2BF0589
	dc.l	$2BA0588,$2B504AD,$2B104AC,$2AF0586,$2AA0585,$2A504A9
	dc.l	$2A104A8,$2A00583,$29B0582,$29904A6,$2960581,$29104A4
	dc.l	$28D04A3,$28904A2,$286057E,$28104A0,$28104A0,$27D049F
	dc.l	$279049E,$277057B,$272057A,$26D049B,$26D049B,$269049A
	dc.l	$2680578,$2620577,$2610498,$25D0576,$2590496,$2580575
	dc.l	$2550495,$2510494,$24E0573,$2490492,$2490492,$2450491
	dc.l	$2440571,$2410490,$23F0570,$23A056F,$23A056F,$235048D
	dc.l	$234056E,$231048C,$22F056D,$22D048B,$22A056C,$2250489
	dc.l	$2250489,$2210488,$220056A,$21D0487,$21B0569,$2190486
	dc.l	$2160568,$2110484,$2110484,$2110567,$20D0483,$20B0566
	dc.l	$2090482,$2060565,$2050481,$2010480,$2010480,$1FD047F
	dc.l	$1FC0563,$1F9047E,$1F70562,$1F5047D,$1F20561,$1F20561
	dc.l	$1ED047B,$1ED047B,$1ED0560,$1E9047A,$1E8055F,$1E50479
	dc.l	$1E2055E



; Variables de gestion

			ds.b	1
Simplet_Old_Module	ds.b	1
Simplet_Sequence_Adr	ds.l	1
Simplet_Patterns_Adr	ds.l	1
Simplet_Line_Size	ds.w	1
Simplet_Pattern_Size	ds.w	1
Simplet_Samples_Adr	ds.l	31

Simplet_Voices_Nb	ds.w	1
Simplet_Samples_Nb	ds.w	1

Simplet_Song_Position	ds.w	1
Simplet_Song_Length	ds.w	1
Simplet_Song_Restart	ds.w	1

Simplet_Pattern_Position	ds.w	1
Simplet_Pattern_Length		ds.w	1

Simplet_Pattern_Loop_Counter	ds.w	1
Simplet_Pattern_Loop_Position	ds.w	1
Simplet_Pattern_Break_Position	ds.w	1
Simplet_Position_Jump_Pos	ds.w	1
Simplet_Pattern_Loop_Flag	ds.b	1
Simplet_Pattern_Break_Flag	ds.b	1
Simplet_Position_Jump_Flag	ds.b	1
Simplet_Pattern_Delay_Time	ds.b	1
Simplet_Tempo			ds.b	1
Simplet_Speed			ds.b	1
Simplet_Counter			ds.b	1

Simplet_IT_In_Service		ds.b	1
Simplet_IT_Timer_Control	ds.b	1
Simplet_IT_Timer_Data		ds.b	1
Simplet_IT_Sample_Length	ds.w	1

Simplet_Voices			ds.b	8*Voice_Size

; Pour un enchainement st‚r‚o Amiga  L R R L L R R L
Increment_Voice_1		dc.w	2*Voice_Size
Increment_Voice_2		dc.w	-Voice_Size
Increment_Voice_3		dc.w	2*Voice_Size
Increment_Voice_4		dc.w	Voice_Size

; Pour un enchainement st‚r‚o simple L R L R L R L R
*Increment_Voice_1		dc.w	Voice_Size
*Increment_Voice_2		dc.w	Voice_Size
*Increment_Voice_3		dc.w	Voice_Size
*Increment_Voice_4		dc.w	Voice_Size

*******************************************************************
***********			Routine DSP		***********
*******************************************************************

DSP_Code
	dc.l	0,0,$20AF080,$4600,0,$10000002,$BF08000,$400000,$26,$20B
	dc.l	$F0800000,$6C000000,$2800,$208F4,$BF000800,0,$400000,$D00AAEA2
	dc.l	$4408,$E7AF0000,$408DFEF,$408,$F4A00000,$108F4A1
	dc.l	$1F808,$F4AC0041,$8F4AD,$580008,$F4BF0038,$AA822
	dc.l	$5F420FF,$FFFF05F4,$27000E73,$461A004,$66A774F4,$578
	dc.l	$464A020,$1B60F4,$3000,$6748E00,$605760,$5F5800
	dc.l	$AA98000,$610844,$2B0AA981,$6408,$F4ABBC61,$4E67F400
	dc.l	$300000,$FCB80C00,$6B0AA980,$6C08,$4E2B5401,$AA980
	dc.l	$7008,$70AB0000,$448300,$44020067,$30060F4,$578
	dc.l	$D009660,$F4000005,$780D00D3,$64F40000,$AF00600,$85
	dc.l	$2290000D,$962290,$D00D3,$44C1460,$F4000005,$780D00B2
	dc.l	$60F40000,$5780D00,$EF64F400,$AF006,0,$94229000
	dc.l	$D00C322,$90000D01,$44C14,$40A,$A9800000,$960858AB
	dc.l	$AA98000,$990844,$2B445800,$45810020,$58A00AA9,$8100009F
	dc.l	$8CC2B0A,$A9800000,$A2084F2B,$46F43B00,$8047F4,$8000
	dc.l	$6CD0000,$B00AA9,$800000AB,$8442B44,$58D05058,$C0505800
	dc.l	$C66,$820045D8,$45811,$47D80057,$D90044E1,$2000A0
	dc.l	$6010000,$C02000,$780E50C0,$ACD5744,$D9002000,$A0545E00
	dc.l	$57600000,$C6682,$45D800,$4581147,$D80057D9,$44E100
	dc.l	$6010000,$D056E6,$780E50CF,$ACD5744,$D9002000,$A2545E00
	dc.l	$57600000,$C0AA9,$800000D3,$858EB0A,$A9800000,$D608442B
	dc.l	$4C580045,$81002058,$A00AA981,$DC08,$CC2B0AA9,$800000DF
	dc.l	$84F2B46,$F43B0000,$8047F400,$800006,$CD000000,$ED0AA980
	dc.l	$E808,$442B4C58,$D05858C0,$58580000,$C6682,$4DD800
	dc.l	$458114F,$D8005FD9,$4CE100,$2000A006,$1000000,$FD200078
	dc.l	$E50FD0A,$CD574CD9,$2000A0,$5C5E005F,$60000000,$C668200
	dc.l	$4DD80004,$58114FD8,$5FD900,$4CE10006,$1000001,$D5EE678
	dc.l	$E510C0A,$CD574CD9,$2000A2,$5C5E005F,$60000000,$C000001
	dc.l	0,$10000,$1000001,$200,$20030,$3000

DSP_End		Even



	ifeq	DOWNLOAD
****************
	SECTION DATA
****************
	endc

mod_data	INCBIN	zlask.mod

	DS.B	10000			; Workspace
workspc	DS.W	1000

pic		dc.w	0
		dc.w	$007,$000,$666,$700


nomouse		dc.b	$12,$1a
yesmouse	dc.b	$14,$08

font		incbin	"ST.SET"	; 8*8 character set (256 chars).
		even
header_text
	dc.b	'Persistence of Vision  Doc displayer Version 2.1  '
	dc.b	189			; Copyright symbol.
	dc.b	' 1995 POV  Coded by Boris/MSD'
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
	dc.b	'              PERSISTENCE OF VISION DOC DISPLAYER HELP SCREEN'
	dc.b	0
	even

line5
	dc.b	''
	dc.b	0
	even

line6
	dc.b	'                    CODING BY:-  BORIS AND MSD  '
	dc.b	189		;copyright symbol
	dc.b	' 1995'
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
	even

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

text_file
	incbin	"discs.txt"		; Put your own file here.
	dc.b	0
	even



* colours for background
colours
 dc.w	$000
 dc.w	$008,$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f
 dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
 dc.w	$0f7,$0fe,$0f6,$0fd,$0f5,$0fc,$0f4,$0fb,$0f3,$0fa,$0f2,$0f9,$0f1,$0f8,$0f0
 dc.w	$8f0,$1f0,$9f0,$2f0,$af0,$3f0,$bf0,$4f0,$cf0,$5f0,$df0,$6f0,$ef0,$7f0,$ff0
 dc.w	$f70,$fe0,$f60,$fd0,$f50,$fc0,$f40,$fb0,$f30,$fa0,$f20,$f90,$f10,$f80,$f00
 dc.w	$700,$e00,$600,$d00,$500,$c00,$400,$b00,$300,$a00,$200,$900,$100,$800,$000
 dc.w	$080,$010,$090,$020,$0a0,$030,$0b0,$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
 dc.w	$078,$0e1,$069,$0d2,$05a,$0c3,$04b,$0b4,$03c,$0a5,$02d,$096,$01e,$087,$00f
 dc.w	$08f,$01f,$09f,$02f,$0af,$03f,$0bf,$04f,$0cf,$05f,$0df,$06f,$0ef,$07f,$0ff
 dc.w	$8f7,$1fe,$9f6,$2fd,$af5,$3fc,$bf4,$4fb,$cf3,$5fa,$df2,$6f9,$ef1,$7f8,$ff0
 dc.w	$ff8,$ff1,$ff9,$ff2,$ffa,$ff3,$ffb,$ff4,$ffc,$ff5,$ffd,$ff6,$ffe,$ff7,$fff
 dc.w	$7ff,$eff,$6ff,$dff,$5ff,$cff,$4ff,$b7f,$3ef,$a6f,$2df,$95f,$1cf,$84f,$0bf
 dc.w	$03f,$0af,$02f,$09f,$01f,$08f,$00f,$80f,$10f,$90f,$20f,$a0f,$30f,$b0f,$40f
 dc.w	$c0f,$50f,$d0f,$60f,$e0f,$70f,$f0f,$f07,$f0e,$f06,$f0d,$f05,$f8c,$f14,$f9b
 dc.w	$f23,$faa,$f32,$fb9,$f41,$fc8,$f50,$fd0,$f60,$fe0,$f70,$ff0,$7f0,$ef0,$6f0
 dc.w	$df0,$5f0,$cf0,$4f0,$bf0,$3f0,$af0,$2f0,$9f0,$1f0,$8f0,$0f0,$0f0,$0f0,$0f0
 dc.w	$0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040,$0b0,$030,$0a0,$020,$090,$010,$080


colours_end



	ifeq	DOWNLOAD
	SECTION BSS
	endc
bssstart

colour_offset	ds.w	1
temp		ds.w	1
black		ds.b	32
old_timerb	ds.l	1
oldtima		ds.l	1
oldtimd		ds.l	1
store		ds.l	1
oldkbd		ds.l	1
key		ds.w	1
ste_flag	ds.w	1
falcon_flag	ds.w	1
screen_bytes	ds.l	1
old_video	ds.w	1
oldvbl		ds.l	1
old_palette	ds.w	16
oldtimera	ds.l	1
stack_save	ds.l	1
old_scr_base	ds.l	1
screen_base	ds.l	1
original_rez	ds.b	1
s06		ds.l	1
s12		ds.l	1
s1d		ds.b	1
scr_now		ds.l	1
scr_xor		ds.l	1
	even

vsyncflag	ds.w	1

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
line_ptrs	ds.l	MAX_LINES


	ds.b	256
screens	ds.b	32000
	ds.b	32000


eobss


	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
