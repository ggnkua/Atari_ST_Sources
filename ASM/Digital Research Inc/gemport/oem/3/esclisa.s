*************************************************************************
*									*
*				ESCLISA.S				*
*									*
*		GSX escapes for the LISA screen driver			*
*									*
*************************************************************************

	.text
	.globl	_CHK_ESC
	.globl	escfn2
	.globl	escfn3

* External Variables

	.xdef	_INTIN
	.xdef	_INTOUT
	.xdef	_CONTRL

* External Routines

	.xdef	_CLEARMEM
	.xdef	_v_show_c
	.xdef	_v_hide_c

* Local Constants

ldri_escape	.equ	19	* last DRI escape = 19.

null		.equ	$00	* ASCII null
esc		.equ	$1B	* ASCII escape

x_cells		.equ	90	* # of columns of 8x14 character cells
y_cells		.equ	25	* # of rows of 8x14 character cells


*
*	GEMDOS Function Codes
*
rawio		.equ	$06	* raw i/o to standard input/output
wntstr		.equ	$09	* write null terminated string to std output

* Local Storage
*	LISA BIOS Escape Sequences

		.data
		.even
zero		dc.w	0
cur_up		dc.b	esc,'A',null		* cursor up
cur_dn		dc.b	esc,'B',null		* cursor down
cur_rt		dc.b	esc,'C',null		* cursor right
cur_lt		dc.b	esc,'D',null		* cursor left
cur_home	dc.b	esc,'H',null		* home cursor
clr_eos		dc.b	esc,'J',null		* clear to end of screen
clr_eol		dc.b	esc,'K',null		* clear to end of line
curs_off	dc.b	esc,'f',esc,'E',null	* hide alpha cursor
curs_on		dc.b	esc,'E',esc,'e',null	* show alpha cursor
entr_rvid	dc.b	esc,'p',null		* enter reverse video
exit_rvid	dc.b	esc,'q',null		* exit reverse video
pos_cur		dc.b	esc,'Y'			* position cursor
pcy		dc.b	0
pcx		dc.b	0
		dc.b	null


	.page
	.text
*******************************************************************************
*									      *
*	_CHK_ESC:							      *
*		This routine decodes the escape functions.		      *
*									      *
*		input:	CONTRL[5] = escape function ID.			      *
*			CONTRL[6] = device handle.			      *
*			INTIN[]   = array of input parameters.		      *
*									      *
*		output:	CONTRL[2] = number of output vertices.		      *
*			CONTRL[4] = number of output parameters.	      *
*			INTOUT[]  = array of output parameters.		      *
*			PTSOUT[]  = array of output vertices.		      *
*									      *
*		destroys: everything.					      *
*									      *
*******************************************************************************

_CHK_ESC:
	movea.l	_CONTRL,a0	* get address of CONTRL array
	move.w	10(a0),d0	* get the escape function id
	cmp.w	#ldri_escape,d0	* is it too large?
	bhi	esc_out		* yes - do nothing (just return)
	asl.w	#1,d0		* convert id to a word offset
	move.w	esctbl(pc,d0.w),d0	* get offset from table to service rtn
	jmp	esctbl(pc,d0.w)		* jump to it
	.page
*************************************************************************
*									*
*	This table contains the offsets from the start of the		*
*	table to each of the escape sequence service routines in	*
*	ascending numerical order.					*
*									*
*************************************************************************
esctbl:
	dc.w	escfn0-esctbl
	dc.w	escfn1-esctbl
	dc.w	escfn2-esctbl
	dc.w	escfn3-esctbl
	dc.w	escfn4-esctbl
	dc.w	escfn5-esctbl
	dc.w	escfn6-esctbl
	dc.w	escfn7-esctbl
	dc.w	escfn8-esctbl
	dc.w	escfn9-esctbl
	dc.w	escfn10-esctbl
	dc.w	escfn11-esctbl
	dc.w	escfn12-esctbl
	dc.w	escfn13-esctbl
	dc.w	escfn14-esctbl
	dc.w	escfn15-esctbl
	dc.w	escfn16-esctbl
	dc.w	escfn17-esctbl
	dc.w	escfn18-esctbl
	dc.w	escfn19-esctbl
	.page
*************************************************************************
*									*
*	Escape Function 1						*
*									*
*	This escape function returns the maximum addressable char-	*
*	acter cell row and column.					*
*									*
*	Inputs:		None						*
*									*
*	Outputs:							*
*	   _CONTRL[4] = 2 (# of integers returned)			*
*	   _INTOUT[0] = maximum character cell row			*
*	   _INTOUT[1] = maximum character cell column			*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn1:
	move.w	#2,8(a0)	* 2 integers are returned
	movea.l	_INTOUT,a0	* get address of INTOUT array
	move.w	#y_cells,(a0)+	* write max row number to array
	move.w	#x_cells,(a0)	* write max column number to array
escfn0:
esc_out:
	rts
	.page
*************************************************************************
*									*
*	Escape Function 2						*
*									*
*	This escape function causes the display to exit the alpha	*
*	mode and to enter the graphics mode.				*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn2:
	lea	curs_off,a0	* get address of cursor off esc seq
	bsr	esc_to_gemdos	* jump to common code to access gemdos
	bra	_CLEARMEM

	.page
*************************************************************************
*									*
*	Escape Function 3						*
*									*
*	This escape function causes the display to enter the alpha	*
*	mode and to exit the graphics mode.				*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn3:
	bsr	_CLEARMEM
	lea	curs_on, a0	* get address of exit graphics mode esc seq
	bra	esc_to_gemdos	* jump to common code to access gemdos
	.page
*************************************************************************
*									*
*	Escape Function 4						*
*									*
*	This escape function moves the alpha cursor up one line.	*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn4:
	lea	cur_up,a0	* get address of cursor up escape sequence
esc_to_gemdos:
	move.l	a0,-(a7)	* put address of character string on stack
	move.w	#wntstr,-(a7)	* put gemdos function code on stack
	trap	#1		* call gemdos
	addq.w	#6,a7		* get parameters off the stack
	rts

	.page
*************************************************************************
*									*
*	Escape Function 5						*
*									*
*	This escape function moves the alpha cursor down one line.	*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn5:
	lea	cur_dn,a0	* get address of cursor down escape sequence
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 6						*
*									*
*	This escape function moves the alpha cursor right one column.	*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn6:
	lea	cur_rt,a0	* get address of cursor right escape sequence
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 7						*
*									*
*	This escape function moves the alpha cursor left one column.	*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn7:
	lea	cur_lt,a0	* get address of cursor left escape sequence
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 8						*
*									*
*	This escape function homes the alpha cursor.			*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn8:
	lea	cur_home,a0	* get address of cursor home escape sequence
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 9						*
*									*
*	This escape function clears the screen from the alpha cursor	*
*	position to the end of the screen.				*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn9:
	lea	clr_eos,a0	* get address of clear to eos escape sequence
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 10						*
*									*
*	This escape function clears the screen from the alpha cursor	*
*	position to the end of the current line.			*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn10:
	lea	clr_eol,a0	* get address of clear to eol escape sequence
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 11						*
*									*
*	This escape function sets the cursor position.  The cursor	*
*	will be displayed at the new location if it is not currently	*
*	hidden.								*
*									*
*	Inputs:								*
*	   _INTIN[0] = cursor row (0 - max_y_cell)			*
*	   _INTIN[1] = cursor column (0 - max_x_cell)			*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d0, d1, a0				*
*									*
*************************************************************************

escfn11:
	movea.l	_INTIN,a0	* get address of _INTIN array
	move.w	(a0)+,d0	* get row number
	add.b	#$20, d0	* bias by space
	move.w	(a0),d1		* get column number
	add.b	#$20, d1	* bias by space
	lea	pos_cur,a0	* get address of position cursor escape seq
	move.w	d0,pcy-pos_cur(a0)	* put row number in sequence data
	move.w	d1,pcx-pos_cur(a0)	* put column number in sequence data
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 12						*
*									*
*	This escape function outputs cursor addressable alpha text.	*
*									*
*	Inputs:								*
*	   _CONTRL[3] = character count					*
*	   _INTIN = character array					*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	d0, a0					*
*									*
*************************************************************************

*
*	Get the number and address of the characters to display, set up
*	the stack, and jump into the display loop at the bottom in order
*	to test test for strings with 0 length and to predecrement the
*	character count so that we will not display 1 character too many.
*
escfn12:
	move.w	6(a0),d0	* get the character count
	movea.l	_INTIN,a0	* get address of the character array
	subq.w	#4,a7		* put space on stack for gemdos parameters
	bra	ef12_lend	* enter loop at end

*
*	Loop calling gemdos to display each character until the string is
*	exhausted.  Clean up the stack on exit.
*
ef12_loop:
	move.w	#rawio,(a7)	* put function code on stack (DOS trashes)
	move.w	(a0)+,2(a7)	* put next character on the stack
	trap	#1		* pass command to gemdos
ef12_lend:
	dbra	d0,ef12_loop	* loop until all characters displayed
	addq.w	#4,a7		* remove parameters from stack
	rts

	.page
*************************************************************************
*									*
*	Escape Function 13						*
*									*
*	This escape function causes all subsequently displayed		*
*	characters to appear in reverse video. 				*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	None					*
*									*
*************************************************************************

escfn13:
	lea	entr_rvid,a0	* get address enter reverse video
	bra	esc_to_gemdos	* jump to common code to access gemdos
	.page
*************************************************************************
*									*
*	Escape Function 14						*
*									*
*	This escape function causes all subsequently displayed		*
*	characters to appear in normal video.				*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	None					*
*									*
*************************************************************************

escfn14:
	lea	exit_rvid,a0	* get address enter reverse video
	bra	esc_to_gemdos	* jump to common code to access gemdos

	.page
*************************************************************************
*									*
*	Escape Function 15						*
*									*
*	This escape function returns the current x and y-coordi-	*
*	nates of the alpha cursor.  This function is currently		*
*	just a stub because this information is not readilly available. *
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	None					*
*									*
*************************************************************************

escfn15:
	move.w	#2,8(a0)	* 2 integers are returned
	movea.l	_INTOUT,a0	* get address of _INTOUT array
	clr.w	(a0)+		* return something
	clr.w	(a0)
	rts

	.page
*************************************************************************
*									*
*	Escape Function 16						*
*									*
*	This escape function returns the availability status of		*
*	a graphics tablet, mouse, joystick, or other similar		*
*	devices.							*
*									*
*	Inputs:		None						*
*									*
*	Outputs:							*
*	   _CONTRL[4] = 1  (# of parameters returned)			*
*	   _INTOUT[0] = 1  (mouse is available)				*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn16:
	move.w	#1,8(a0)	* 1 integer is returned
	movea.l	_INTOUT,a0	* get address of _INTOUT array
	move.w	#1,(a0)		* there is a mouse
	rts

	.page
*************************************************************************
*									*
*	Escape Function 17						*
*									*
*	This escape function is used to obtain hard copy of the		*
*	contents of the screen.  This function is currently just	*
*	a stub because it cannot be done on a lisa			*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	None					*
*									*
*************************************************************************

escfn17:
	rts

	.page
*************************************************************************
*									*
*	Escape Function 18						*
*									*
*	This escape function displays the graphics cursor at its	*
*	current address.						*
*									*
*	Inputs:		None						*
*									*
*	Outputs:							*
*	   _INTIN[0] = 0 (cursor is displayed regardless of the		*
*			  number of previous hide operations)		*
*									*
*	Registers Modified:	a0					*
*									*
*************************************************************************

escfn18:
	move.l	_INTIN, -(sp)	* save callers paramater block
	move.l	#zero,_INTIN	* INTIN[0] == 0 => show regardless
	jsr	_v_show_c	* display the graphics cursor
	move.l	(sp)+, _INTIN	* restore callers parameter block
	rts
	.page
*************************************************************************
*									*
*	Escape Function 19						*
*									*
*	This escape function hides the graphics cursor.			*
*									*
*	Inputs:		None						*
*									*
*	Outputs:	None						*
*									*
*	Registers Modified:	None					*
*									*
*************************************************************************

escfn19:
	jmp	_v_hide_c	* hide the graphics cursor
	.end
