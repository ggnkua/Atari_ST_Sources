;-----------------------------------------------------------------------;
; Spectrum Analyzer Converted from The amiga by	:-
;
;			The Caped Crusader..
;
; 	Date	15/2/91
;			
;-----------------------------------------------------------------------;
screen	equ	$78000
main_inc	equ	20		;max height for main freq bar
side_inc	equ	5		;max half heights for freq side bars
down_speed	equ	1		;rate at which bar decreases in amplitude
bar_max		equ	40		;max height the bar can reach
eq_height	equ	bar_max		;height of bitmap
eq_width	equ	160		;4*320/8	width of bitmap
;----------------------------------------------------------------------
; In your tracker(or similar) routine you must point the out of ALL four
; Channels too :-
;
; Labels EQ1P to EQ4P
;
;----------------------------------------------------------------------
; To use BSR or JSR to the below Label from The VBL...
;

equalizer:	lea	eq1p,a0		;ptr to note freq for channel 1
		bsr.s	eq_handler
		lea	eq2p,a0		;ptr to note freq for channel 2
		bsr.s	eq_handler
		lea	eq3p,a0		;ptr to note freq for channel 3
		bsr.s	eq_handler
		lea	eq4p,a0		;ptr to note freq for channel 4
		bsr	eq_handler

		lea	eq_table(pc),a1 	;table of current amplitude status
		lea	screen,a2		;ptr to bitmap
		lea	(eq_height-1)*eq_width(a2),a2	;get to bottom left corner

		moveq	#35,d0			;36 freq bars


eq_draw_loop:	clr.w	(a2)
		subq.b	#down_speed,(a1)	;dec amplitude
		moveq	#0,d1
		move.b	(a1)+,d1		;get bar amplitude
		bpl.s	eq_above_zero
		clr.b	-1(a1)			:reset to zero
		bra.s	eq_zero

eq_above_zero:	move.l	a2,a3
eq_draw_bar:	move.w	#$7ffe,(a3)		;bar pattern
		lea	-eq_width(a3),a3	;move up a line
		dbf	d1,eq_draw_bar
		clr.w	(a3)	
eq_zero:	lea	4(a2),a2
;		move.l	a2,d5
;		btst	#0,d5
;		bne.s	eq_right_bar
;		lea	2(a2),a2
eq_right_bar:	dbf	d0,eq_draw_loop		;move to next bar
		rts

***********************************************************************
;checks the equalser for new notes. If theres a new bar then it calcs
;the frequency bar to use. one found it increases its amplitude + the
;amplitudes of its side bands.

eq_handler:	move.w (a0),d0			;get note frequency
		bne.s	eq_handle_new_bar	;valid?
		rts

;-----------
eq_handle_new_bar:
		clr.w	(a0)			;wipe note data

;-----------
;work out the position of the note in the st note table.This determines
;which frequency bar to ise for that note.
;d0 holds the notes freuquency
;leaves with d1 holding bar number.

		lea notetable,a1
		moveq #0,d1
eq_get_bar:	cmp.w	(a1)+,d0	;compare with table note
		bcc	eq_got_bar	;table note of lower freq then quit
		addq.b	#1,d1		:move to next bar
		bra.s	eq_get_bar

;-----------
eq_got_bar:	lea	eq_table(pc),a1		;ptr to table holding current bar state
		add.l	d1,a1			;move to chosen bar
		add.b	#main_inc,(a1)		;main frequency : max value
		add.b	#side_inc,-1(a1)	;half frequency : max values
		add.b	#side_inc,1(a1)
		move.b	(a1),d0			;get current value for that freq bar
		cmp.b	#bar_max,d0		;check it doees not excede max height
		bcs.s	eq_hc1
		move.b	#bar_max,(a1)		;reset to max height
eq_hc1:		move.b	-1(a1),d0		;get side band freq height value
		cmp.b	#bar_max-2,d0		;check less than max height
		bcs.s	eq_hc2
		move.b	#bar_max-2,-1(a1)	;reset to max height
eq_hc2:		move.b	1(a1),d0		;get side band freq height value
		cmp.b	#bar_max-2,d0		;check less than max height
		bcs.s	eq_hc3
		move.b	#bar_max-2,1(a1)	;reset to max height
eq_hc3:		rts
	
;----Data---------------	
eq1p:		dc.w	381			;hold note just played
eq2p:		dc.w	381
eq3p:		dc.w	381
eq4p:		dc.w	381

eq_table:	dcb.w	40		;hold state of each frequency bar

notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226 
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000

	even
