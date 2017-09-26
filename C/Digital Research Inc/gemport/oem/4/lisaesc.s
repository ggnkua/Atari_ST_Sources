*******************************************************************************
*									      *
*	date:   10/25/84 - started.					      *
*		11/14/84 - last update.					      *
*		21-Dec-84 lmd	Installed screenResolution shadow register    *
*		28-Jan-85 lmd,mh	Fixed 32K screen bug (etc).	      *
*		1-Feb-85 msh	Changed alpha_cell to use font offset table.  *
*		12-Mar-85 rjg	Added conout, fixed escI at top of screen     *
*				Added space bias to set color commands	      *
*		14-May_85 ewf	Added in the bell simulation code.
*******************************************************************************

		page
		.data
tempo:	.dc.w	$c00	* used for bell simulation
		.text
*
*	bell information:  data needed generate tones which simulates a bell
*
SNDCHIP		equ	$FCDD80		* where the tone chip is located
ACR		equ	$17		* register on the tone chip
SHFTREG		equ	$15		* register on the tone chip
LOLATCH		equ	$11		* register on the tone chip
HICOUNT		equ	$13		* register on the tone chip
*
*	font header structure equates.
*
FIRST		equ	36
LAST		equ	38
CEL_WD		equ	52
POFF		equ	72
PDAT		equ	76
FRM_WD		equ	80
FRM_HT		equ	82

M_CFLASH	equ	$0001		* cursor flash			0:disabled
F_CFLASH	equ	    0		*				1:enabled	

M_CSTATE	equ	$0002		* cursor flash state		0:off
F_CSTATE	equ	    1		*				1:on

M_CVIS		equ	$0004		* cursor visibility		0:invisible
F_CVIS		equ	    2		*				1:visible
*
*	  The visibility flag is also used as a semaphore to prevent
*	the interrupt-driven cursor blink logic from colliding with
*	escape function/sequence cursor drawing activity.
*

M_CEOL		equ	$0008		* cursor end of line handling	0:overwrite
F_CEOL		equ	    3		*				1:wrap

M_REVID		equ	$0010		* reverse video			0:on
F_REVID		equ	    4		*				1:off

F_SVPOS		equ	5		; position saved flag. (0=false, 1=true)
*
*
*		external variables
*
	.bss
		.xdef	_f8x12		* font header

_v_planes:	.ds.w	1		* number of planes			.w
_v_lin_wr:	.ds.w	1		* line wrap 				.w
v_cel_ht:	.ds.w	1		* cell height (width is 8)		.w
v_cel_mx:	.ds.w	1		* maximum cell # in x (minimum is 0)	.w
v_cel_my:	.ds.w	1		* maximum cell # in y (minimum is 0)	.w
v_cel_wr:	.ds.w	1		* cell wrap 				.w

v_vt_rez:	.ds.w	1		* vertical pixel resolution		.w
v_hz_rez:	.ds.w	1		* horizontal pixel resolution		.w

v_fnt_ad:	.ds.l	1		* address of current monospace font	.l
v_fnt_nd:	.ds.w	1		* ascii code of last cell in font	.w
v_fnt_st:	.ds.w	1		* ascii code of first cell in font	.w
v_fnt_wr:	.ds.w	1		* font cell wrap			.w
v_off_ad:	.ds.l	1		* address of font offset table	.l

v_col_fg:	.ds.w	1		* current foreground color		.w
v_col_bg:	.ds.w	1		* current background color		.w
v_cur_cx:	.ds.w	1		* current cursor cell x			.w
v_cur_cy:	.ds.w	1		* current cursor cell y			.w
v_cur_ad:	.ds.l	1		* current cursor address		.l

_v_bas_ad:	.ds.l	1		* screen base address			.l

v_stat_0:	.ds.b	1		* VIDEO CELL SYSTEM STATUS		.b
v_cur_tim:	.ds.b	1		* cursor blink timer.			.b

disab_cnt:	.ds.w	1		* disable depth count. (>0 => disabled) .w
sav_cxy:	.ds.w	2			* save area for cursor coords.

save_row:	.ds.w	1		* saved row in escape Y command
con_state:	.ds.l	1		* state of conout state machine

*		external routines

*		public routines

		globl	_con_out
		globl	_blink
		globl	_esc_init

		text			; open program segment.

		page
_con_out:
	move.w	6(sp), d1	* Get character from bios call
gsx_conout:			* Gsx enters here
	andi.w	#$FF, d1	* Limit to the chars we have
	movea.l	con_state, a0	*based on our state goto the correct
	jmp	(a0)		*stub routine

normal_ascii:
	cmp.w	#$20, d1	* If the character is printable ascii
	bge	ascii_out	* go print it.

* We handle the following control characters as special.  All others are thrown
* away.
*	 7 = bell
*	 8 = backspace
*	 9 = Horizontal tab
*	10 = Line feed
*	11 = Vertical tab (Treated as line feed)
*	12 = Form Feed (Treated as line feed)
*	13 = Carriage Return
*	27 = Escape (Start Command)

	cmp.b	#27, d1		* If escape character alter next state
	bne	handle_control	* else handle the control characters

	move.l	#esc_ch1, con_state
	rts

handle_control:
	subq.w	#7, d1		* Range check the character against
	bmi	exit_conout	* the ones we handle, and exit if out
	cmp.w	#6, d1		* of range.
	bgt	exit_conout

	lsl.w	#1, d1		* times 4 for longword addressing
	move.w	cntl_tab(pc,d1.w), a0
	adda.l	#do_bell, a0
	jmp	(a0)

cntl_tab:
	dc.w	do_bell-do_bell
	dc.w	escD-do_bell
	dc.w	do_tab-do_bell
	dc.w	ascii_lf-do_bell
	dc.w	ascii_lf-do_bell
	dc.w	ascii_lf-do_bell
	dc.w	ascii_cr-do_bell

exit_conout:
	rts

do_bell:			* No bell on Lisa so it must be simulated
	lea	SNDCHIP, a0	* get address at which the tone chip is loc
	or.b	#$10, ACR(a0)
	move.b	#$f0, SHFTREG(a0)
	moveq	#0,  d1			* clear the d1 register
	move.b	#$a6, d0		* This will specify the G note
	move.b	#11,  d1		* This will be duration note held
	move.b	d0, LOLATCH(a0)		*
	clr.b	HICOUNT(a0)		*
delay:	move.w	tempo, d2		*
loop8:	dbra	d2, loop8		*
	dbra	d1, delay		*
	and.b	#$ef, ACR(a0)		*
	rts			

do_tab:
	move	v_cur_cx, d0
	andi.w	#$FFF8, d0
	addq	#8, d0
	move	v_cur_cy, d1
	bra	escY

* Handle the first character of an escape sequence

esc_ch1:
	move.l	#normal_ascii, con_state * Most functions only 2 chars so set
	sub.w	#$41, d1		* state to normal ascii.  Bias by low
	bmi	exit_conout		* char and get out if invalid
	cmp.w	#12, d1			* If in the range A-M go handle
	ble	range_A_M

	cmp.w	#24, d1			* Y is direct cursor addressing
	bne	check_low_case		* and takes 2 additional chars
	move.l	#get_row, con_state
	rts

get_row:
	sub.w	#$20, d1		* Remove space bias
	move.w	d1, save_row		* and save until command complete
	move.l	#get_column, con_state
	rts

get_column:
	sub.w	#$20, d1		* Remove space bias
	move.w	d1, d0
	move.w	save_row, d1
	move.l	#normal_ascii, con_state
	bra	escY

check_low_case
	sub.w	#$21, d1		* see if b to w
	bmi	exit_conout
	cmp.w	#21, d1
	ble	range_b_w
	rts

range_A_M:
	lsl.w	#1, d1
	move.w	AM_tab(pc, d1.w), a0
	adda.l	#exit_conout, a0
	jmp	(a0)

range_b_w:
	lsl.w	#1, d1
	move.w	bw_tab(pc, d1.w), a0
	adda.l	#exit_conout, a0
	jmp	(a0)

set_fg:
	move.l	#get_fg_col, con_state		* Next char is the FG color
	rts

get_fg_col:
	move.l	#normal_ascii, con_state	* Next char is not special
	sub.w	#$20, d1			* Remove space bias
	move.w	d1, d0
	bra	escb

set_bg:
	move.l	#get_bg_col, con_state	* Next char is the BG color
	rts

get_bg_col:
	move.l	#normal_ascii, con_state	* Next char is not special
	sub.w	#$20, d1			* Remove space bias
	move.w	d1, d0
	bra	escc

AM_tab:
	dc.w	escA-exit_conout		* Cursor Up
	dc.w	escB-exit_conout		* Cursor Down
	dc.w	escC-exit_conout		* Cursor Right
	dc.w	escD-exit_conout		* Cursor Left
	dc.w	escE-exit_conout		* Clear and Home
	dc.w	exit_conout-exit_conout		* <ESC> F not supported
	dc.w	exit_conout-exit_conout		* <ESC> G not supported
	dc.w	escH-exit_conout		* Home
	dc.w	escI-exit_conout		* Reverse Line Feed
	dc.w	escJ-exit_conout		* Erase to End of Screen
	dc.w	escK-exit_conout		* Erase to End of Line
	dc.w	escL-exit_conout		* Insert Line
	dc.w	escM-exit_conout		* Delete Line

bw_tab:
	dc.w	set_fg-exit_conout		* Set foreground color (1 more char)
	dc.w	set_bg-exit_conout		* Set background color (1 more char)
	dc.w	escd-exit_conout		* Erase from beginning of page
	dc.w	esce-exit_conout		* Cursor On
	dc.w	escf-exit_conout		* Cursor Off
	dc.w	exit_conout-exit_conout		* <ESC> g not supported
	dc.w	exit_conout-exit_conout		* <ESC> h not supported
	dc.w	exit_conout-exit_conout		* <ESC> i not supported
	dc.w	escj-exit_conout		* Save Cursor Position
	dc.w	esck-exit_conout		* Restore Cursor position
	dc.w	escl-exit_conout		* Erase line
	dc.w	exit_conout-exit_conout		* <ESC> m not supported
	dc.w	exit_conout-exit_conout		* <ESC> n not supported
	dc.w	esco-exit_conout		* Erase from Beginning of Line
	dc.w	escp-exit_conout		* Reverse Video On
	dc.w	escq-exit_conout		* Reverse Video Off
	dc.w	exit_conout-exit_conout		* <ESC> r not supported
	dc.w	exit_conout-exit_conout		* <ESC> s not supported
	dc.w	exit_conout-exit_conout		* <ESC> t not supported
	dc.w	exit_conout-exit_conout		* <ESC> u not supported
	dc.w	escv-exit_conout		* Wrap at End of Line
	dc.w	escw-exit_conout		* No Wrap at End of Line

*********************************************************
*	escape E.					*
*		Clear Screen and Home Cursor.		*
*********************************************************

escE:		bsr	escfn8		; home cursor.
		bra	escfn9		; clear screen.

*********************************************************
*	escape A.					*
*	escape function 4.				*
*		Alpha Cursor Up.			*
*********************************************************

escA:
escfn4:		move.w	v_cur_cy,d1	; d1 := current cursor y.
		beq	esc_out		; if at top of screen, branch.
escA1:		subq.w	#1,d1		; move the cursor up.
		move.w	v_cur_cx,d0	; d0 & d1 are inputs to "move_cursor".
		bra	move_cursor	; update cursor position and globals.

*********************************************************
*	escape B.					*
*	escape function 5.				*
*		Alpha Cursor Down.			*
*********************************************************

escB:
escfn5:		move.w	v_cur_cy,d1	; d1 := current cursor y.
		cmp.w	v_cel_my,d1
		beq	esc_out		; if at bottom of screen, branch.
		addq.w	#1,d1		; move the cursor down.
		move.w	v_cur_cx,d0	; d0 & d1 are inputs to "move_cursor".
		bra	move_cursor	; update cursor position and globals.

*********************************************************
*	escape C.					*
*	escape function 6.				*
*		Alpha Cursor Right.			*
*********************************************************

escC:
escfn6:		move.w	v_cur_cx,d0	; d0 := current cursor x.
		cmp.w	v_cel_mx,d0
		beq	esc_out		; if at right edge of screen, branch.
		addq.w	#1,d0		; move the cursor right.
		move.w	v_cur_cy,d1	; d0 & d1 are inputs to "move_cursor".
		bra	move_cursor	; update cursor position and globals.

*********************************************************
*	escape D.					*
*	escape function 7.				*
*		Alpha Cursor Left.			*
*********************************************************

escD:
escfn7:		move.w	v_cur_cx,d0	; d0 := current cursor x.
		beq	esc_out		; if at left edge of screen, branch.
		subq.w	#1,d0		; move the cursor left.
		move.w	v_cur_cy,d1	; d0 & d1 are inputs to "move_cursor".
		bra	move_cursor	; update cursor position and globals.

*********************************************************
*	escape H.					*
*	escape function 8.				*
*		Home Alpha Cursor.			*
*********************************************************

escH:
escfn8:		moveq	#0,d0		; x coord.
		move.w	d0,d1		; y coord.
		bra	move_cursor

*********************************************************
*	escape J.					*
*	escape function 9.				*
*		Erase to End of Screen.			*
*********************************************************

escJ:
escfn9:		bsr	escfn10		; erase to end of line.
		move.w	v_cur_cy,d1
		cmp.w	v_cel_my,d1	; last line?
		beq	esc_out		; yes, done.
		addq.w	#1,d1		; no, drop down a line.
		swap	d1
		move.w	#0,d1		; upper left corner.
		move.w	v_cel_my,d2
		swap	d2
		move.w	v_cel_mx,d2	; lower right corner.
		bra	blnk_blt	; erase rest of screen.

*********************************************************
*	escape K.					*
*	escape function 10.				*
*		Erase to End of Line.			*
*********************************************************

escK:
escfn10:	bclr	#F_CEOL,v_stat_0 ; test and clear EOL handling bit. (overwrite)
		move.w	sr,-(sp)	; save result of test.
		bsr	escf		; hide cursor.
		bsr	escj		; save cursor position.
		move.w	v_cur_cx,d1	; test current x.
		btst.l	#0,d1		; even or odd?
		beq	ef10_blnk	; if even, branch.
		cmp.w	v_cel_mx,d1	; if odd, is x = x maximum?
		beq	ef10_space	; if so, just output a space.
		move.w	#$20,d1		; else output a space &
		bsr	ascii_out
		move.w	v_cur_cx,d1
ef10_blnk:	swap	d1		; blank to end of line.
		move.w	v_cur_cy,d1
		move.w	d1,d2
		swap	d1		; upper left coords.
		swap	d2
		move.w	v_cel_mx,d2	; lower right coords.
		bsr	blnk_blt
ef10_out:	move.w	(sp)+,ccr	; restore result of EOL test.
		beq	ef10_done	; if it was overwrite, just exit.
		bset	#F_CEOL,v_stat_0 ; else set it back to wrap.
ef10_done:	bsr	esck		; restore cursor position.
		bra	cntesce		; show cursor.

ef10_space:	move.w	#$20,d1		; output a space.
		bsr	ascii_out
		bra	ef10_out

*********************************************************
*	escape p.					*
*	escape function 13.				*
*		Reverse Video On.			*
*********************************************************

escp:
escfn13:	bset	#F_REVID,v_stat_0 ; set the reverse bit.
esc_out:
		rts	

*********************************************************
*	escape q.					*
*	escape function 14.				*
*		Reverse Video Off.			*
*********************************************************

escq:
escfn14:	bclr	#F_REVID,v_stat_0 ; clear the reverse bit.
		rts

*********************************************************
*	escape I.					*
*		Reverse Index.				*
*********************************************************

escI:		move.w	v_cur_cy,d1	; d1 := current cursor y.
		bne	escA1		; if not at top of screen, branch.
		move.w	v_cur_cx, -(sp)	; save current x position
		bsr	escL		; Insert a line
		move.w	(sp)+, d0
		moveq.l	#0, d1
		bra	escY

*********************************************************
*	escape L.					*
*		Insert Line.				*
*********************************************************

escL:		bsr	escf		; hide cursor.
		move.w	v_cur_cy,d1	; line to begin scrolling down.
		bsr	p_sc_dwn	; scroll down 1 line & blank current line.
esclmout:	clr.w	d0
		move.w	v_cur_cy,d1
		bsr	move_cursor	; move cursor to beginning of line.
		bra	cntesce		; show cursor.

*********************************************************
*	escape M.					*
*		Delete Line.				*
*********************************************************

escM:		bsr	escf		; hide cursor.
		move.w	v_cur_cy,d1	; line to begin scrolling up.
		bsr	p_sc_up		; scroll up 1 line & blank bottom line.
		bra	esclmout

*********************************************************
*	escape b.					*
*		Set Foreground Color.			*
*********************************************************

escb:		and.w	#$0F,d0		; low-order bits only.
		move.w	d0,v_col_fg	; set the foreground color.
		rts

*********************************************************
*	escape c.					*
*		Set Background Color.			*
*********************************************************

escc:		and.w	#$0F,d0		; low-order bits only.
		move.w	d0,v_col_bg	; set the background color.
escc_out:	rts

*********************************************************
*	escape d.					*
*		Erase from Beginning of Page.		*
*********************************************************

escd:		bsr	esco		; erase from beginning of line.
		move.w	v_cur_cy,d2	; first line?
		beq	escc_out	; yes, done.
		subq.w	#1,d2		; no, move up a line.
		swap	d2
		move.w	v_cel_mx,d2	; lower right coord.
		moveq.l	#0,d1		; upper left coord.
		bra	blnk_blt	; erase rest of screen.

*********************************************************
*	escape e.					*
*		Enable Cursor.				*
*********************************************************

_esce:
esce:		tst.w	disab_cnt	; if disable count is zero (cursor
		beq	escc_out	; still shown) then return
		clr.w	disab_cnt	; 0 the disable counter.
esceok:		lea	v_stat_0,a0	
		btst	#F_CFLASH,(a0)	; else, see if flashing is enabled.
		bne	enc_flsh	; if enabled, branch.
comp_cur:	bset	#F_CVIS,(a0)	; set visibility bit.
comp_cr1:	move.w	v_cur_cx,d0	; fetch x and y coords.
		move.w	v_cur_cy,d1
		bsr	cell_addr
		bra	neg_cell	; complement cursor.

enc_flsh:	bsr	comp_cr1	; show cursor.
		bset	#F_CSTATE,(a0)	; cursor is on.
		bset	#F_CVIS,(a0)	; set visibility/semaphore bit.
		rts			; let interrupt routine show the cursor.

*********************************************************
*		Enable Cursor (counted depth).		*
*********************************************************

cntesce:	tst.w	disab_cnt	; if disable count is zero (cursor
		beq	escc_out	; still shown) then return
		subq.w	#1,disab_cnt	; decrement the disable counter.
		beq	esceok		; if 0, do the enable.
		rts

*********************************************************
*	escape f.					*
*		Disable Cursor.				*
*********************************************************

escf:		addq.w	#1,disab_cnt	; increment the disable counter.
		lea	v_stat_0,a0
		bclr	#F_CVIS,(a0)	; test and clear the visible state bit.
		beq	escc_out	; if already invisible, just return.
		btst	#F_CFLASH,(a0)	; else, see if flashing is enabled.
		beq	comp_cr1	; if disabled, branch to complement cursor.
*					; ...critical section.
		bclr	#F_CSTATE,(a0)	; is cursor on or off?
		bne	comp_cr1	; on => complement the cursor.
		rts			; off => return.

*********************************************************
*	escape j.					*
*		Save Cursor Position.			*
*********************************************************

escj:		bset	#F_SVPOS,v_stat_0 ; set "position saved" status bit.
		lea	sav_cxy,a0
		move.w	v_cur_cx,(a0)+
		move.w	v_cur_cy,(a0)	; save the x and y coords of cursor.
		rts

*********************************************************
*	escape k.					*
*		Restore Cursor Position.		*
*********************************************************

esck:		bclr	#F_SVPOS,v_stat_0 ; clear "position saved" status bit.
		beq	escfn8		; if position was not saved, home cursor.
		lea	sav_cxy,a0
		move.w	(a0)+,d0
		move.w	(a0),d1
		bra	move_cursor	; move cursor to saved position.

*********************************************************
*	escape l.					*
*		Erase Entire Line.			*
*********************************************************

escl:		bsr	escf		; hide cursor.
		move.w	v_cur_cy,d1
		move.w	d1,d2
		swap	d1
		clr.w	d1		; upper left coords. (0,y)
		swap	d2
		move.w	v_cel_mx,d2	; lower right coords. (max,y)
		bsr	blnk_blt	; blank whole line.
		bra	esclmout	; move cursor to BOL and show it.

*********************************************************
*	escape o.					*
*		Erase from Beginning of Line.		*
*********************************************************

esco:		bsr	escf		; hide cursor.
		bsr	escj		; save cursor position.
		move.w	v_cur_cx,d2	; test current x.
		beq	esco_space	; if x = x minimum, just output a space.
		btst	#0,d2		; x even or odd?
		bne	esco_blnk	; if odd, branch.
		move.w	#$20,d1		; else output a space &
		bsr	ascii_out
		move.w	v_cur_cx,d2
		subq.w	#2,d2		; back up 2 spaces.
esco_blnk:	swap	d2		; blank to end of line.
		move.w	v_cur_cy,d2
		move.w	d2,d1
		swap	d2		; lower right coords. (x,y)
		swap	d1
		clr.w	d1		; upper left coords. (0,y)
		bsr	blnk_blt	; blank from beginning of line.
esco_out:	bsr	esck		; restore cursor position.
		bra	cntesce		; show cursor.

esco_space:	move.w	#$20,d1		; output a space.
		bsr	ascii_out
		bra	esco_out

*********************************************************
*	escape v.					*
*		Wrap at End of Line.			*
*********************************************************

escv:		bset	#F_CEOL,v_stat_0 ; set the eol handling bit.
		rts

*********************************************************
*	escape w.					*
*		Discard at End of Line.			*
*********************************************************

escw:		bclr	#F_CEOL,v_stat_0 ; clear the eol handling bit.
		rts

*********************************************************
*	carriage return.				*
*********************************************************

ascii_cr:	move.w	v_cur_cy,d1
		clr.w	d0		; beginning of current line.
		bra	move_cur

*********************************************************
*	line feed.					*
*********************************************************

ascii_lf:	move.w	v_cur_cy,d0	; d0 := current cursor y.
		cmp.w	v_cel_my,d0	; at bottom of screen?
		bne	escB		; no, branch.
		bsr	escf		; yes, hide cursor.
		clr.w	d1		; line to begin scrolling up.
		bsr	p_sc_up		; scroll up 1 line & blank current line.
		bra	cntesce		; show cursor.

*********************************************************
*	cursor blink interrupt routine.			*
*********************************************************

_blink:		lea	v_stat_0,a0
		btst	#F_CVIS,(a0)	; test visibility/semaphore bit.
		beq	bl_out		; if invisible or blocked, return.
		btst	#F_CFLASH,(a0)	; test flash bit.
		beq	bl_out		; if not flashing, return.
		lea	v_cur_tim,a1
		subq.b	#1,(a1)		; decrement cursor flash timer.
		bne	bl_out		; if <> 0, return.
		move.b	#30,(a1)	; else reset timer.
		bchg	#F_CSTATE,(a0)	; toggle cursor state.
		bsr	comp_cr1	; complement cursor.
bl_out:		rts

***********************************************************
*      alpha_cell
*                            
* purpose:                   
*	                     
*     given an offset value, retrieve the address of the
*     source cell
*
* latest update:
*
*	25-sep-84
* in:
*	d1.w	  source cell code
* out:
*	D3.w		validity flag.  =0:valid  <>0:invalid
*	zero flag 	z:0 -> invalid code. no address returned  (ne)
*			z:1 -> valid address returned             (eq)
*	a0.l	  points to first byte of source cell if code was valid
***********************************************************

alpha_cell:
	move.w	v_fnt_st,d3
	cmp.w	d3,d1			* test against limits
	bcs	out_of_bounds

	cmp.w	v_fnt_nd,d1
	bhi	out_of_bounds

	move.l	v_off_ad,a0		; ptr to offset table.
	add.w	d1,d1			; word indexing.
	move.w	0(a0,d1.w),d1		; fetch offset.
	lsr.w	#3,d1			; convert from pixels to bytes.

	move.l	v_fnt_ad,a0
	adda.w	d1,a0			* a0 -> alpha source

	clr.w	d3			* z:1 -> valid address returned
	rts

out_of_bounds:
	moveq	#1,d3			* z:0 -> invalid code. no address returned
	rts

***********************************************************
* name:	                           
*     ascii_out
*                            
* purpose:                   
*
*     this routine interfaces with the BIOS.	                     
*     it prints an ascii character on the screen as if
*     there was a dumb terminal out there.
*
* latest update:
*
*	14-nov-84
* in:
*
*	d1.w	  ascii code for character
* out:
*	clobbered:	everything imaginable except
***********************************************************

ascii_out:
	bsr	alpha_cell		* a0 -> the character source
	beq	char_ok
	rts

char_ok:

	move.l	v_cur_ad,a1		* a1 -> the destination

	move.w	v_col_bg,d7
	swap	d7
	move.w	v_col_fg,d7


	btst	#F_REVID,v_stat_0
	beq	put_char

	swap	d7			* reverse fore and background

put_char:

	bclr	#F_CVIS,v_stat_0	; test and clear visibility bit ... semaphore.
	move.w	sr,-(sp)		; save result of test.

	bsr	cell_xfer		* put the cell out (this covers the cursor)

	move.l	v_cur_ad,a1
	move.w	v_cur_cx,d0
	move.w	v_cur_cy,d1

	bsr	next_cell		* advance the cursor
	beq	disp_cur

	move.w	v_cel_wr,d0		; perform cell carriage return.
	mulu	d1,d0
	move.l	_v_bas_ad,a1		* a1 -> first cell in line
	adda.l	d0,a1
	clr.w	d0			* set X to first cell in line

	cmp.w	v_cel_my,d1		; perform cell line feed.
	bcc	scroll_up

	adda.w	v_cel_wr,a1		* move down one cell
	addq	#1,d1
	bra	disp_cur

scroll_up:

	movem.l	d0/d1/a1,-(sp)
	moveq	#0,d1			; top of screen.
	bsr	p_sc_up			; do the scroll.
	movem.l	(sp)+,d0/d1/a1

disp_cur:
	move.l	a1,v_cur_ad		; update cursor address
	move.w	d0,v_cur_cx		; update the cursor coordinates
	move.w	d1,v_cur_cy		;   "     "    "        "
	move.w	(sp)+,ccr		; restore result of visibility test.
	beq	dc_out			; if invisible, just return.
	bsr	neg_cell		; else, display cursor.
	bset	#F_CSTATE,v_stat_0	; set state flag (cursor on).
	bset	#F_CVIS,v_stat_0	; set visibility bit...end of critical section.
dc_out:	rts

*


***********************************************************
*
*       title: Blank blt
*
*        date: 24 sept 84
*
*  This routine fills a cell-word aligned region with the background
*  color.  The rectangular region is specified by a top/left cell x,y
*  and a bottom/right cell x,y, inclusive.  Routine assumes top/left x is even
*  and bottom/right x is odd for cell-word alignment.
*
* in:
*	d1(31:16)	top/left cell y position
*	d1(15:00)	top/left cell x position (must be even)
*	d2(31:16)	bottom/right cell y position
*	d2(15:00)	bottom/right cell x position (must be odd)
*
* out:
*	none
*
*	destroyed:  d0.w,d1.l,d2.l,d3.w,d5.w,a1.l,a2.l
***********************************************************

blnk_blt:
	sub.l	d1,d2			*form cell delta x, delta y in d2
	move.w	d1,d0			*get cell x for cell_addr call
	swap	d1			*get cell y in d1.w

	bsr	cell_addr		*form screen address of top/left cell in a1

	asr.w	#1,d2			*d2 = # of cell-pairs per row in region -1
	move.w	_v_planes,d3		*# of planes -> d3
	cmpi.w	#4,d3			*form 1,2, or 3
	bne	b1			*    in d0 for shift purposes
	subq.w	#1,d3			*4 planes -> 3 shifts
b1:
	move.w	d2,d1			*
	addq.w	#1,d1			*d1 = # of cell-pairs per row in region
	asl.w	d3,d1			*d1 = total bytes per row in region
	move.w	_v_lin_wr,a2		*line wrap to a2
	suba.w	d1,a2			*line stride to a2

	move.w	d2,d1			*# of cell pairs per row in region -1
	swap	d2			*cell delta y in lo word
	addq.w	#1,d2			* # of vertical cells in region
	mulu	v_cel_ht,d2		* d2 = # of lines in region
	subq.w	#1,d2			* d2 = # of lines in region -1

	clr.l	d0			*assume 0 background color
	move.w	v_col_bg,d5		*background color to d5
	cmpi.w	#2,_v_planes		*test for 1, 2 or 4 planes
	bmi	mono			*br if monochrome
	beq	plane2			*br if 2 planes

*  4 planes

plane4:
	asr.w	d5			*shift background color plane 0 to cy
	negx.w	d0			*d0.w=$FFFF if cy=1, =$0000 if cy=0
	swap	d0			*put 1st bit in high word
	asr.w	d5			*shift plane 1 to cy
	negx.w	d0			*fill with all 1's if cy
*
	clr.l	d3			*assume all 0's for planes 2 & 3
	asr.w	d5
	negx.w	d3
	swap	d3
	asr.w	d5
	negx.w	d3

*  d0 & d3 packed as double long word of blanking background
*  a1 -> top/left cell to start blanking
*  a2 = stride length
*  d2 = # of lines in region -1
*  d1 = # of cell-pairs in region -1

plane4y:
	move.w	d1,d5			*reset cell-pair -1 count
plane4x:
	move.l	d0,(a1)+		*fill background to planes 0 & 1
	move.l	d3,(a1)+		*fill background to planes 2 & 3
	dbra	d5,plane4x		*go for rest of row

	add.l	a2,a1			*skip non-region area with stride advance
	dbra	d2,plane4y		*do all rows in region
	rts

plane2:
	asr.w	d5			*shift background color plane 0 to cy
	negx.w	d0			*d0.w=$FFFF if cy=1, =$0000 if cy=0
	swap	d0			*put 1st bit in high word
	asr.w	d5			*shift plane 1 to cy
	negx.w	d0			*fill with all 1's if cy

*  d0 packed as long word of blanking background
*
*  a1 -> top/left cell to start blanking
*  a2 = stride length
*  d2 = # of lines in region -1
*  d1 = # of cell-pairs in region -1

plane2y:
	move.w	d1,d5			*reset cell-pair -1 count
plane2x:
	move.l	d0,(a1)+		*fill background to planes 0 & 1
	dbra	d5,plane2x		*go for rest of row

	add.l	a2,a1			*skip non-region area with stride advance
	dbra	d2,plane2y		*do all rows in region
	rts

mono:
	asr.w	d5
	negx.w	d0

*  d0 packed as word of blanking background
*
*  a1 -> top/left cell to start blanking
*  a2 = stride length
*  d2 = # of lines in region -1
*  d1 = # of cell-pairs in region -1

plane1y:
	move.w	d1,d5			*reset cell-pair -1 count
plane1x:
	move.w	d0,(a1)+		*fill background to planes 0 & 1
	dbra	d5,plane1x		*go for rest of row

	add.l	a2,a1			*skip non-region area with stride advance
	dbra	d2,plane1y		*do all rows in region
	rts

***********************************************************
* name:	
*	 cell_addr
*
* purpose:
*	
*	convert cell X,Y to a screen address. also clip cartesian coordinates
*	to the limits of the current screen.
*
* latest update:
*
*	18-sep-84
* in:
*
*	d0.w	  cell X
*	d1.w	  cell Y
*
* out:
*	a1	points to first byte of cell
*
*	destroyed:	d3.l,d5.l
***********************************************************

cell_addr:

*	check bounds against screen limits

	move.w	v_cel_mx,d3
	cmp.w	d0,d3
	bpl	x_clipped

	move.w	d3,d0			* d0 <- clipped x

x_clipped:

	move.w	v_cel_my,d3
	cmp.w	d1,d3
	bpl	y_clipped

	move.w	d3,d1			* d1 <- clipped Y

y_clipped:

*	now we compute the relative displacement: X
*
*	X displacement = even(X) * _v_planes + Xmod2

	move.w	_v_planes,d3
	move.w	d0,d5
	bclr	#0,d5			* d5.w <- even(X)
	mulu	d5,d3			* d3.l <- planes * even(X)

	btst	#0,d0			* calculate Xmod2
	beq	y_disp			* Xmod2 = 0 ?

	addq.l	#1,d3			* Xmod2 = 1

y_disp:

*	Y displacement = Y * cell conversion factor


	move.w	v_cel_wr,d5
	mulu	d1,d5


*	cell address = screen base address + Y displacement + X displacement

	move.l	_v_bas_ad,a1		* d5 <- screen base address
	adda.l	d5,a1			* d5 <- screen addr + Y disp
	adda.l	d3,a1			* d5 <- cell address

	rts

***********************************************************
*	
* name:	
*	 cell_xfer
*
* purpose:
*
*	This routine performs a byte aligned block transfer for the purpose of 
*	manipulating monospaced byte-wide text. the routine maps an single
*	plane arbitrarilly long byte-wide image to a multi-plane bit map.
*	all transfers are byte aligned.
*
* latest update:
*
*	25-sep-84
*
* in:
*	a0.l	  points to contiguous source block (1 byte wide)
*	a1.l	  points to destination (1st plane, top of block)
*
* out:
*	a4	points to byte below this cell's bottom
*
*	destroyed:	a1.l,a3.l,d3.w,d4.w,d5.w,d6.w,d7.l
*
***********************************************************

plane_offset	equ	2

            
cell_xfer:
	move.w	v_fnt_wr,a2
	move.w	_v_lin_wr,a3
	move.w	v_cel_ht,d4
	subq.w	#1,d4			; for dbra.
        move.w	_v_planes,d6
	subq.w	#1,d6			; for dbra.
                                              
                         
p_lp0:              
	move.w	d4,d5  	 		* reset block length counter
	move.l	a0,a4			* a4 -> top of source block
	move.l	a1,a5			* a5 -> top of current dest plane
                     
	asr.l	#01,d7			* cy <- current foreground color bit 
	btst	#15,d7			* z  <- current background color bit
	beq	back_0
                     
                     
back_1:              
	bcc	blk_invrt		* back:1  fore:0  =>  invert block
	moveq	#-1,d3			; all ones.
	bra	blk_reg			* back:1  fore:1  =>  all ones
                     
back_0:              
	bcs	blk_xfer		* back:0  fore:1  =>  direct substitution
	moveq	#0,d3			; all zeroes.

*					* back:0  fore:0  =>  all zeros

blk_reg:	   			* inject a block of d3
	move.b	d3,(a5)
	adda.w	a3,a5
	dbra	d5,blk_reg

	addq.w	#plane_offset,a1	* a1 -> top of block in next plane
	dbra	d6,p_lp0
	rts
                   

blk_xfer:				* inject the source block
	move.b	(a4),(a5)
	adda.w	a3,a5
	adda.w	a2,a4	

	dbra	d5,blk_xfer

	addq.w	#plane_offset,a1	* a1 -> top of block in next plane
	dbra	d6,p_lp0
	rts


blk_invrt:				* inject the inverted source block
	move.b	(a4),d3
	not.b	d3
	move.b	d3,(a5)
	adda.w	a3,a5
	adda.w	a2,a4	

	dbra	d5,blk_invrt
          
	addq.w	#plane_offset,a1	* a1 -> top of block in next plane
	dbra	d6,p_lp0
	rts


***********************************************************
*	                           
* name:	                           
*	 move_cursor
*                            
* purpose:                   
*	                     
*	move the cursor and update global parameters
*	erase the old cursor (if necessary) and draw new cursor (if necessary)
*
* latest update:
*
*	14-nov-84
* in:
*	d0.w	new cell X coordinate
*	d1.w	new cell Y coordinate
*
*	destroyed:	a1.l,a2.l,a4.l,d4.w,d5.w,d6.w
***********************************************************

escY:
move_cursor:

*	update cell position

	cmp.w	v_cel_mx,d0	; clip x.
	bls	escYY		; no, branch.
	move.w	v_cel_mx,d0	; yes.
escYY:	cmp.w	v_cel_my,d1	; clip y.
	bls	escYok		; no, branch.
	move.w	v_cel_my,d1	; yes.

escYok:	move.w	d0,v_cur_cx
	move.w	d1,v_cur_cy

* 	erase old cursor (if cursor is presently visible)

	lea	v_stat_0,a0
	btst	#F_CVIS,(a0)			; is cursor visible?
	beq	invisible			; no, branch.
	btst	#F_CFLASH,(a0)			; is cursor flashing?
	beq	doit				; no, just do it.
	bclr	#F_CVIS,(a0)			; yes, make invisible...semaphore.
	btst	#F_CSTATE,(a0)			* is cursor presently displayed ?
	beq	mc_semout			; no, branch.

doit:	move.l	v_cur_ad,a1
	bsr	neg_cell			* erase present cursor

	bsr	cell_addr
	move.l	a1,v_cur_ad
	bsr	neg_cell			* write new cursor
	bset	#F_CVIS,v_stat_0		; end of critical section.
	rts

mc_semout:
	bset	#F_CVIS,(a0)			; end of critical section.

invisible:
	bsr	cell_addr
	move.l	a1,v_cur_ad

	rts	


***********************************************************
*	
* name:	
*	 neg_cell
*
* purpose:
*
*	This routine negates the contents of an arbitrarily tall byte wide cell 
*	composed of an arbitrary number of (atari styled) bit-planes.
*	cursor display can be acomplished via this procedure. since a second negation
*	restores the original cell condition, there is no need to save the contents
*	beneath the cursor block.
*
* latest update:
*
*	24-sep-84
*
* in:
*	a1.l	  points to destination (1st plane, top of block)
*
* out:
* 
*	destroyed:	d4.w,d5.w,d6.w,a1.l,a2.l,a4.l
***********************************************************


neg_cell:

	move.w	_v_lin_wr,a2
	move.w	v_cel_ht,d4
	subq.w	#1,d4			; for dbra.
	move.w	_v_planes,d6
	subq.w	#1,d6			; for dbra.


plane_loop:

	move.w	d4,d5			* reset cell length counter
	move.l	a1,a4			* a4 -> top of current dest plane

neg_loop:
	not.b	(a4)
	add.w	a2,a4
		
	dbra	d5,neg_loop

	addq.w	#plane_offset,a1	* a1 -> top of block in next plane
	dbra	d6,plane_loop
	rts


***********************************************************
*	                           
* name:	                           
*	 next_cell                 
*                            
*                            
* purpose:                   
*	                     
*	return the next cell address given the current position and screen constraints
*
* latest update:
*
*	19-sep-84
* in:
*	d0.w	  cell X
*	d1.w	  cell Y
*
*	a1.l	  points to current cell top
*
* out:
*	d0.w	  next cell X
*	d1.w	  next cell Y
*	d3.w	  =0:    no wrap condition exists  
*		  <>0:   CR LF required (position has not been updated)
*
*	a1.l	  points to first byte of next cell
*
* 
*	destroyed:	d3.l,d5.l
***********************************************************


next_cell:


*	check bounds against screen limits


	cmp.w	v_cel_mx,d0
	bne	inc_cell_ptr			* increment cell ptr

	btst	#F_CEOL,v_stat_0
	bne	new_line


*	overwrite in effect

	clr.w	d3				* no wrap condition exists
	rts					* dont change cell parameters



new_line:

	
*	call carriage return routine
*	call line feed routine

	moveq	#1,d3				* indicate that CR LF is required
	rts	


inc_cell_ptr:

	addq.w	#1,d0				* next cell to right

	btst	#0,d0				* if X is even, move to next
	beq	next_word			* word in the plane

	addq.w	#1,a1				* a1 -> new cell

	clr.w	d3				* indicate no wrap needed	
	rts


next_word:

	move.w	_v_planes,d3
	asl.w	#1,d3
	subq.w	#1,d3				* d3 <- offset to next word in plane
	add.w	d3,a1				* a1 -> new cell (1st plane)

	clr.w	d3				* indicate no wrap
	rts

***********************************************************
*
*       title: Scroll
*
*  programmer: Dave Staugas
*
*        date: 24 sept 84
*		14 nov 84 - last update.
*
*   Scroll copies a source region as wide as the screen to an overlapping
*   destination region on a one cell-height offset basis.  Two entry points
*   are provided:  Partial-lower scroll-up, partial-lower scroll-down.
*   Partial-lower screen operations require the cell y # indicating the top line
*   where scrolling will take place.
*
*   After the copy is performed, any non-overlapping area of the previous
*   source region is "erased" by calling blnk_blt which fills the area
*   with the background color.
*
*   Parameters passed in registers:
*
*  in:  
*	d1.w		cell y of cell line to be used as top line in scroll
*
* out:
*	none
*
*
*	destroyed:
*		d0.w,d1.l,d2.l,d3.l,d5.w,a1.l,a2.l,a3.l
*
***********************************************************

p_sc_up:
	move.l	_v_bas_ad,a3	*get base addr to destination
	move.w	v_cel_wr,d3	*cell wrap to temp
	mulu	d1,d3		*cell y nbr * cell wrap is destination offset
	lea	(a3,d3.w),a3	*form destination add in a3
	neg.w	d1
	add.w	v_cel_my,d1	*form (max-1) - top row # for total rows to move
	move.w	v_cel_wr,d3	*cell wrap to temp d3
	lea	(a3,d3.w),a2	*form source address from cell wrap + base address
	mulu	d1,d3		*form # of bytes to move in d3
	asr.w	#2,d3		*divide by 4 for long byte moves
	bra	scrup1		*enter loop at test
*
scrup0:
	move.l	(a2)+,(a3)+	*move bytes
scrup1:
	dbra	d3,scrup0	*loop til finished
*
*
	move.w	v_cel_my,d1	*bottom line cell address y to top/left cell
scr_out:
	move.w	d1,d2		*for bottom/left cell too
	swap	d1
	swap	d2
	clr.w	d1		*top/left starts at left edge
	move.w	v_cel_mx,d2	*maximum x for right edge on bottom/right
	bra	blnk_blt	*exit thru blank out
*
*  Partial scroll down entry point:
*
*
p_sc_dwn:
	move.l	_v_bas_ad,a3	*screen base addr to source
	move.w	v_cel_my,d3	*max cell y # in d3
	mulu	v_cel_wr,d3	*form offset for bottom of second to last cell row
	lea	(a3,d3.w),a3	*form source address in a3
	move.w	v_cel_wr,d3	*cell wrap to add
	lea	(a3,d3.w),a2	*form destination from source + cell wrap
	move.w	d1,d0
	neg.w	d0		*do tricky subtract
	add.w	v_cel_my,d0	*  to form # of cell rows to move
	mulu	d0,d3		*form # of bytes to move in d3
	asr.w	#2,d3		*divide by 4 for long byte moves
	bra	scrdwn1		*enter loop at test
scrdwn0:
	move.l	-(a3),-(a2)	*scroll bytes
scrdwn1:
	dbra	d3,scrdwn0	*do all
	bra	scr_out

*********************************************************
*	escape initialization routine.			*
*********************************************************

_esc_init:
		move.w	#90, _v_lin_wr		* Set the line wrap
		move.w	#1, _v_planes		* Set the number of planes
		move.w	#360, v_vt_rez		* Set the vertical resolution
		move.w	#720, v_hz_rez		* Set the horizontal resolution

		lea	_f8x12, a0		* Load a0 with pointer to font

		bsr	gl_f_init		* init the global font variables.

		move.w	#-1, v_col_fg		* foreground color := 15.
		moveq.l	#0, d0
		move.w	d0, v_col_bg		* background color := 0.
		move.w	d0, v_cur_cx
		move.w	d0, v_cur_cy
		move.l	#$F8000, a0
		move.l	a0, _v_bas_ad		* set base address of screen
		move.l	a0, v_cur_ad		* home cursor.
		move.b	#1, v_stat_0		* invisible, flash, nowrap,
*							 & normal video.
		move.b	#30, v_cur_tim		* .5 second blink rate (@60 Hz vblank).
		move.w	#1, disab_cnt		* cursor disabled 1 level deep.

		move.w	#8189, d1

scr_loop:	move.l	d0, (a0)+		* Clear the screen
		dbra	d1, scr_loop

		move.l	#normal_ascii, con_state * Init conout state machine

		bra	esce			* Show the cursor

*********************************************************
*	font globals initialization routine.		*
*		input: a0 = ptr to system font header.	*
*********************************************************

gl_f_init:	move.w	FRM_HT(a0),d0	; fetch form height.
		move.w	d0,v_cel_ht	; init cell height.
		move.w	_v_lin_wr,d1	; fetch bytes/line.
		mulu	d0,d1
		move.w	d1,v_cel_wr	; init cell wrap.
		moveq	#0,d1
		move.w	v_vt_rez,d1	; fetch vertical res.
		divu	d0,d1		; vert res/cell height.
		subq.w	#1,d1		; 0 origin.
		move.w	d1,v_cel_my	; init cell max y.
		moveq	#0,d1
		move.w	v_hz_rez,d1	; fetch horizontal res.
		divu	CEL_WD(a0),d1	; hor res/cell width.
		subq.w	#1,d1		; 0 origin.
		move.w	d1,v_cel_mx	; init cell max x.
		move.w	FRM_WD(a0),v_fnt_wr	; init font wrap.
		move.w	FIRST(a0),v_fnt_st	; init font start ADE.
		move.w	LAST(a0),v_fnt_nd	; init font end ADE.
		move.l	PDAT(a0),v_fnt_ad	; init font data ptr.
		move.l	POFF(a0),v_off_ad	; init font offset ptr.
		rts
	.end
