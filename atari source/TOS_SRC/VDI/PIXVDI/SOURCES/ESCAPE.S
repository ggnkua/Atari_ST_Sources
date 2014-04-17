********************************  escape.s  ***********************************
*
* $Revision: 3.4 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/escape.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/19 15:30:42 $     $Locker: lozben $
* =============================================================================
*
* $Log:	escape.s,v $
* Revision 3.4  91/02/19  15:30:42  lozben
* Made the file work with multiple linea var structures.
* 
* Revision 3.3  91/02/12  16:39:49  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.2  91/01/31  11:39:12  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.1  91/01/25  16:25:13  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* $Log:	escape.s,v $
* Revision 3.4  91/02/19  15:30:42  lozben
* Made the file work with multiple linea var structures.
* 
* Revision 3.3  91/02/12  16:39:49  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.2  91/01/31  11:39:12  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:07:06  lozben
* New generation VDI
* 
* Revision 2.7  90/10/10  13:03:23  lozben
* Fixed a bug in set foreground and background (esc b and c) routines.
* The routines subtracted 32 from the input. They no longer do that..
* 
* Revision 2.6  90/07/16  16:38:06  lozben
* Added negative clipping in cell_addr().
* 
* Revision 2.5  90/03/14  20:33:41  lozben
* Optimized (for speed) the neg_cell() routine.
* 
* Revision 2.4  90/02/26  17:39:03  lozben
* Fixed the code to work with turbo assembler.
* 
* Revision 2.3  90/02/09  18:37:59  lozben
* We don't use V_CEL_WD flag any more. Now the code looks at the
* offset table to determine if cell width is 8 or 16 bits. Also
* fixed a bug in calculating the relative character position in
* the font offset table.
* 
* Revision 2.2  90/01/18  15:53:03  lozben
* Moved hb_cell(), hb_scrup(), hb_scrdn(), hb_rect() into another file.
* The idea is to have all the hard blit code in independent files.
* Also Made changes to be able to deal with wordwide monospaced
* font.
* 
* Revision 2.1  89/02/21  17:19:03  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include	"lineaequ.s"
.include	"devequ.s"

ldri_escape	equ	19	; last DRI escape = 19.

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

M_CFLASH	equ	$0001	; cursor flash			0:disabled
F_CFLASH	equ	    0	;				1:enabled	
M_CSTATE	equ	$0002	; cursor flash state		0:off
F_CSTATE	equ	    1	; 				1:on

M_CEOL		equ	$0008	; cursor end of line handling	0:overwrite
F_CEOL		equ	    3	;				1:wrap

M_REVID		equ	$0010	; reverse video			0:on
F_REVID		equ	    4	;				1:off

M_SVPOS		equ	$0020	; position saved flag		0:false
F_SVPOS		equ	    5	;				1:true




	xdef	_v_bas_ad	* screen base address
	xdef	save_row	* saved row in escape Y command
	xdef	con_state	* state of conout state machine

*	external routines

	xdef	_v_show_c
	xdef	_v_hide_c
	xdef	 ringbel


*	public routines

	.globl	_asc_out
	.globl	normal_ascii
	.globl	conout
        .globl  st_move_cursor
	.globl	gsx_conout
	.globl	_con_out
	.globl	_CHK_ESC
	.globl	gl_f_init
	.globl	blank_it
	.globl	st_neg_cell
	.globl	esce
	.globl	escf

	.globl	blink
	.globl	_cursconf

	.text

*******************************************************************************
*									      *
*	_CHK_ESC:							      *
*		This routine decodes the escape functions.		      *
*									      *
*		input:	CONTRL[5] = escape function ID.			      *
*			CONTRL[6] = device handle.			      *
*			INTIN[]   = array of input parameters.		      *
*			PTSIN[]   = array of input vertices.		      *
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
	move.l  _lineAVar,a4		; a4 -> linea var struct

	move.l	_CONTRL(a4),a0		; a0 -> CONTRL array.
	move.w	10(a0),d0		; d0 <- ID.
	cmp.w	#ldri_escape,d0 	; compare with DRI limit.
	bhi	ce_more			; if ID > last DRI escape, branch.

	add.w	d0,d0			; word indexing
	move.w	esc_tbl(pc,d0.w),d0	; d0 <- offset to escape code
	jmp	esc_tbl(pc,d0.w)	; jump to the escape function

esc_tbl:

	dc.w	 escfn0-esc_tbl		; not implemented
	dc.w	 escfn1-esc_tbl		; inquire addressable alpha char cells
	dc.w	 escfn2-esc_tbl		; exit alpha mode
	dc.w	 escfn3-esc_tbl		; enter alpha mode
	dc.w	 escfn4-esc_tbl		; alpha cursor up
	dc.w	 escfn5-esc_tbl		; alpha cursor down
	dc.w	 escfn6-esc_tbl		; alpha cursor right
	dc.w	 escfn7-esc_tbl		; alpha cursor left
	dc.w	 escfn8-esc_tbl		; home alpha cursor
	dc.w	 escfn9-esc_tbl		; erase to end of alpha screen
	dc.w	escfn10-esc_tbl		; erase to end of alpha text line
	dc.w	escfn11-esc_tbl		; direct alpha cursor address
	dc.w	escfn12-esc_tbl		; output cursor addressable alpha text
	dc.w	escfn13-esc_tbl		; reverse video on
	dc.w	escfn14-esc_tbl		; reverse video off
	dc.w	escfn15-esc_tbl		; inquire current alpha cursor address
	dc.w	escfn16-esc_tbl		; inquire tablet status
	dc.w	escfn17-esc_tbl		; hardcopy
	dc.w	escfn18-esc_tbl		; place graphic cursor at location
	dc.w	escfn19-esc_tbl		; remove last graphic cursor


ce_more:

	cmp.w	#101,d0			; function 101: a silly routine that
	beq	escfn101		; sorta offsets the cursor in Y

	cmp.w	#102,d0			; function 102: user defined font
	beq	escfn102		; yes, branch.

	rts

		
escfn101:

	bsr	hide_cursor		; INTIN+00 = Y displacement on cursor
	move.l	_INTIN(a4),a0
	move.w	(a0),d0
	mulu	_v_lin_wr(a4),d0
	move.w	d0,v_cur_off(a4)	; d0 <- additional cursor y offset.
	bra	show_cursor		; show cursor.


*    This console out routine doesn't interpret control characters,
*    it just prints them.

_asc_out:

	move.w	6(sp),d1		; Get character from bios call
	and.w	#$00FF,d1		; Limit to the chars we have
	bra	ascii_out		; go print it.


*    This is the standard console out.

_con_out:
  conout:

	move.w	6(sp),d1		; Get character from bios call


*    VDI entry point: d1 contains ascii code

gsx_conout:
	move.l  _lineAVar,a4		; a4 -> linea var struct

	and.w	#$00FF,d1		; Limit to the chars we have
	move.l	con_state,a0		; based on our state goto the correct
	jmp	(a0)			; stub routine


normal_ascii:

	cmp.w	#$20,d1			; If the character is printable ascii
	bge	ascii_out		; go print it.


*   We handle the following control characters as special. 
*   All others are thrown away.
*
*	 7 = bell
*	 8 = backspace
*	 9 = Horizontal tab
*	10 = Line feed
*	11 = Vertical tab	(Treated as line feed)
*	12 = Form Feed		(Treated as line feed)
*	13 = Carriage Return
*	27 = Escape		(Begin command sequence)


	cmp.b	#27,d1			; control characters are handled
	bne	handle_control		; immediately

	lea	esc_ch1(pc),a0		; wait for the next character
	bra	load_state		; in the escape sequence.


handle_control:

	subq.w	#7, d1			; Range check the character against
	bmi	exit_conout		; the ones we handle, and exit if out
	cmp.w	#6, d1			; of range.
	bgt	exit_conout

	add.w	d1,d1			; d1 <- offset to the offset
	move.w	ctrl_tbl(pc,d1.w),d1	; d1 <- offset to the control routine
	jmp	ctrl_tbl(pc,d1.w)


ctrl_tbl:

	dc.w	 do_bell-ctrl_tbl	; ^G  Bell
	dc.w	    escD-ctrl_tbl	; ^H  Backspace
	dc.w	  do_tab-ctrl_tbl	; ^I  Horizontal Tab
	dc.w	ascii_lf-ctrl_tbl	; ^J  Line Feed
	dc.w	ascii_lf-ctrl_tbl	; ^K  Vertical Tab
	dc.w	ascii_lf-ctrl_tbl	; ^L  Form Feed
	dc.w	ascii_cr-ctrl_tbl	; ^M  Carriage Return


do_bell:

	bra	ringbel			; need local variable in ctrl_tbl

do_tab:

	move.w	v_cur_cx(a4),d0		; d0 <- cursor cell X
	andi.w	#$FFF8,d0		; d0 <- previous 8 cell boundry
	addq.w	#8,d0			; d0 <- next 8 cell boundry
	move.w	v_cur_cy(a4),d1		; d1 <- cursor cell Y
	bra	move_cursor




* Handle the first character of an escape sequence

esc_ch1:

	lea	normal_ascii(pc),a0	; Most functions only use 1 additional
	bsr	load_state		; character so default to normal ascii
	sub.w	#$41,d1			; state.  Bias by lowest character
	bmi	exit_conout		; value. Exit if invalid.

	cmp.w	#12,d1			; If in the range A-M go handle
	ble	range_A2M

	cmp.w	#24,d1			; <esc> Y is direct cursor addressing
	bne	check_low_case		; and takes 2 additional characters

	lea	get_row(pc),a0		; 1st, fetch the cell Y


load_state:

	move.l	a0,con_state

exit_conout:

	rts




get_row:

	sub.w	#$20,d1			; Remove space bias
	cmp.w	v_cel_my(a4),d1		; d1 <- maximum row number
	bls	row_ok			; if value is too large ...

	move.w	v_cel_my(a4),d1		; clamp it to the maximum

row_ok:	move.w	d1,save_row		; and save until command complete
	lea	get_column(pc),a0	; now, fetch the cell X
	bra	load_state


get_column:

	sub.w	#$20,d1			; Remove space bias
	cmp.w	v_cel_mx(a4),d1		; d1 <- maximum column number
	bls	col_ok

	move.w	v_cel_mx(a4),d1		; clamp to maximum column

col_ok:	move.w	d1,d0			; d0 <- cell X
	move.w	save_row,d1		; d1 <- cell Y
	bsr	move_cursor		; move cursor

	lea	normal_ascii(pc),a0	; we have what we need.
	bra	load_state		; return to normal ascii.


*******************************************************************************
**	escape b.							     **
**			     Set Foreground Color.			     **
*******************************************************************************

get_fg_col:	lea	set_fg_col(pc),a0
		bra	load_state		; Next char is the FG color

set_fg_col:	lea	pal_map(a4),a0		; a0 -> virtual palette
		sub.w	#'0',d1			; mask out unneeded bits
		lsl.w	#2,d1			; make d1 long word offset
		move.l	(a0,d1.w),vl_col_fg(a4)	; set the foreground color.
		lea	normal_ascii(pc),a0
		bra	load_state


*******************************************************************************
**	escape c.							     **
**			     Set Background Color.			     **
*******************************************************************************

get_bg_col:	lea	set_bg_col(pc),a0	; Next char is the BG color
		bra	load_state


set_bg_col:	lea	pal_map(a4),a0		; a0 -> virtual palette
		sub.w	#'0',d1			; mask out unneeded bits
		lsl.w	#2,d1			; make d1 long word offset
		move.l	(a0,d1.w),vl_col_bg(a4)	; set the background color.
		lea	normal_ascii(pc),a0
		bra	load_state




check_low_case:

	sub.w	#$21,d1			; see if b to w range
	bmi	load_state

	cmp.w	#21,d1
	ble	range_b2w
	
	rts


range_A2M:

	add.w	d1,d1
	move.w	A2M_tbl(pc,d1.w),d1
	jmp	A2M_tbl(pc,d1.w)


range_b2w:

	add.w	d1,d1
	move.w	b2w_tbl(pc,d1.w),d1
	jmp	b2w_tbl(pc,d1.w)


A2M_tbl:

	dc.w	       escA-A2M_tbl	; <Esc> A  Cursor Up
	dc.w	       escB-A2M_tbl	; <Esc> B  Cursor Down
	dc.w	       escC-A2M_tbl	; <Esc> C  Cursor Right
	dc.w	       escD-A2M_tbl	; <Esc> D  Cursor Left
	dc.w	       escE-A2M_tbl	; <Esc> E  Clear and Home
	dc.w	exit_conout-A2M_tbl	; <Esc> F  *** not supported
	dc.w	exit_conout-A2M_tbl	; <Esc> G  *** not supported
	dc.w	       escH-A2M_tbl	; <Esc> H  Home
	dc.w	       escI-A2M_tbl	; <Esc> I  Reverse Line Feed
	dc.w	       escJ-A2M_tbl	; <Esc> J  Erase to End of Screen
	dc.w	       escK-A2M_tbl	; <Esc> K  Erase to End of Line
	dc.w	       escL-A2M_tbl	; <Esc> L  Insert Line
	dc.w	       escM-A2M_tbl	; <Esc> M  Delete Line


b2w_tbl:

	dc.w	 get_fg_col-b2w_tbl	; <Esc> b  Set fore color (1 more char)
	dc.w	 get_bg_col-b2w_tbl	; <Esc> c  Set back color (1 more char)
	dc.w	       escd-b2w_tbl	; <Esc> d  Erase from beginning of page
	dc.w	       esce-b2w_tbl	; <Esc> e  Cursor On
	dc.w	       escf-b2w_tbl	; <Esc> f  Cursor Off
	dc.w	exit_conout-b2w_tbl	; <Esc> g  *** not supported
	dc.w	exit_conout-b2w_tbl	; <Esc> h  *** not supported
	dc.w	exit_conout-b2w_tbl	; <Esc> i  *** not supported
	dc.w	       escj-b2w_tbl	; <Esc> j  Save Cursor Position
	dc.w	       esck-b2w_tbl	; <Esc> h  Restore Cursor position
	dc.w	       escl-b2w_tbl	; <Esc> i  Erase line
	dc.w	exit_conout-b2w_tbl	; <Esc> m  *** not supported
	dc.w	exit_conout-b2w_tbl	; <Esc> n  *** not supported
	dc.w	       esco-b2w_tbl	; <Esc> o  Erase from Beginning of Line
	dc.w	       escp-b2w_tbl	; <Esc> p  Reverse Video On
	dc.w	       escq-b2w_tbl	; <Esc> q  Reverse Video Off
	dc.w	exit_conout-b2w_tbl	; <Esc> r  *** not supported
	dc.w	exit_conout-b2w_tbl	; <Esc> s  *** not supported
	dc.w	exit_conout-b2w_tbl	; <Esc> t  *** not supported
	dc.w	exit_conout-b2w_tbl	; <Esc> u  *** not supported
	dc.w	       escv-b2w_tbl	; <Esc> v  Wrap at End of Line
	dc.w	       escw-b2w_tbl	; <Esc> w  Overwrite at End of Line



*******************************************************************************
**	escape function 1.						     **
**									     **
**		   Inquire Addressable Alpha Character Cells.		     **
*******************************************************************************

escfn1:		move.l	_CONTRL(a4),a0		; a0 -> CONTRL array.
		move.w	#2,8(a0)		; 2 integers are returned.

		move.l	_INTOUT(a4),a0		; a0 -> INTOUT array.
		move.w	v_cel_mx(a4),d0		; d0 <- cell Xmax (zero based)
		addq.w	#1,d0			; d0 <- number of columns
		move.w	d0,2(a0)
		move.w	v_cel_my(a4),d0		; d0 <- cell Ymax (zero based)
		addq.w	#1,d0			; d0 <- number of rows
		move.w	d0,(a0)


  escfn0:
esc_exit:	rts


*******************************************************************************
**	escape function 17.						     **
**				    Hardcopy.				     **
*******************************************************************************

escfn17:	move.w	#20,-(sp)		; Invoke bios
		trap	#14

		addq.l	#2,sp			; clean up stack
		rts


*******************************************************************************
**	escape function 3.						     **
**				Enter Alpha Mode.			     **
*******************************************************************************

escfn3:		bsr	escE			; clear and home.
		bra	esce			; show cursor regardless of cnt


*******************************************************************************
**	escape function 2.						     **
**				 Exit Alpha Mode.			     **
*******************************************************************************

escfn2:		bsr	hide_cursor		; cursor hidden upon exit
*						; fall through to clr and home


*******************************************************************************
**	escape E.							     **
**			 Clear Screen and Home Cursor.			     **
*******************************************************************************

escE:		bsr	escH			; home cursor.
		bra	escJ			; clear screen.


*******************************************************************************
**	escape A.							     **
**	escape function 4.						     **
**				Alpha Cursor Up.			     **
*******************************************************************************

escA:
escfn4:		move.w	v_cur_cy(a4),d1		; d1 <- current cursor Y
		beq	esc_exit		; if top of screen, do nothing

up_cursor:	subq.w	#1,d1			; d1 <- Y of previous line
		move.w	v_cur_cx(a4),d0		; d0 <- current cursor X
		bra	move_cursor		; update cursor pos and globals


*******************************************************************************
**	escape B.							     **
**	escape function 5.						     **
**				Alpha Cursor Down.			     **
*******************************************************************************

escB:
escfn5:		move.w	v_cur_cy(a4),d1		; d1 <- current cursor Y
		cmp.w	v_cel_my(a4),d1
		beq	esc_exit		; if bottom of scrn, do nothing

down_cursor:	addq.w	#1,d1			; d1 <- Y of next line
		move.w	v_cur_cx(a4),d0		; d0 <- current cursor X
		bra	move_cursor		; update cursor pos and globals


*******************************************************************************
**	escape C.							     **
**	escape function 6.						     **
**				Alpha Cursor Right.			     **
*******************************************************************************

escC:
escfn6:

	move.w	v_cur_cx(a4),d0		; d0 <- current cursor X.
	cmp.w	v_cel_mx(a4),d0
	beq	esc_exit		; if right edge of screen, do nothing.

	addq.w	#1,d0			; d0 <- next X position right
	move.w	v_cur_cy(a4),d1		; d1 <- current cursor Y.
	bra	move_cursor		; update cursor position and globals.


*******************************************************************************
**	escape D.							     **
**	escape function 7.						     **
**				Alpha Cursor Left.			     **
*******************************************************************************

escD:
escfn7:

	move.w	v_cur_cx(a4),d0		; d0 <- current cursor X.
	beq	esc_exit		; if left edge of screen, do nothing.

	subq.w	#1,d0			; d0 <- next X position left
	move.w	v_cur_cy(a4),d1		; d1 <- current cursor Y.
	bra	move_cursor		; update cursor position and globals.


*******************************************************************************
**	escape H.							     **
**	escape function 8.						     **
**			        Home Alpha Cursor.			     **
*******************************************************************************

escH:
escfn8:

	clr.w	d0			; d0 <- home X
	clr.w	d1			; d1 <- home Y
	bra	move_cursor


*******************************************************************************
**	escape J.							     **
**	escape function 9.						     **
**			     Erase to End of Screen.			     **
*******************************************************************************

escJ:
escfn9:

	bsr	escK		 	; erase to end of line.

*  on return:
*
*    d1 <- current cursor Y
*    d2 <- maximum cursor X

	move.w	v_cel_my(a4),d3		; d3 <- maximum cursor Y
	cmp.w	d3,d1			; if already on last line, exit.
	beq	esc_exit	

	clr.w	d0			; d0 <- region Xmin
	addq.w	#1,d1			; d1 <- Y of next line down
	bra	erase_region


*******************************************************************************
**	escape K.							     **
**	escape function 10.						     **
**			     Erase to End of Line.			     **
*******************************************************************************

escK:
escfn10:	move.w	v_cur_cx(a4),d0		; d0 <- current cursor X
		move.w	v_cur_cy(a4),d1		; d1 <- current line Y
		move.w	v_cel_mx(a4),d2		; d2 <- right most X
		move.w	d1,d3			; d3 <- current line Y
		bra	erase_region


*******************************************************************************
**	escape function 11.						     **
**			     Set Cursor Position.			     **
*******************************************************************************

escfn11:

	move.l	_INTIN(a4),a0		; a0 -> INTIN array
	move.w	(a0),d1			; d1 <- row number
	subq.w	#1,d1			; d1 <- Y (zero origin)
	move.w	2(a0),d0		; d0 <- column number
	subq.w	#1,d0			; d0 <- X (zero origin)
	bra	move_cursor


*******************************************************************************
**	escape function 12.						     **
**				 Output Text.				     **
*******************************************************************************

escfn12:

	move.l	_CONTRL(a4),a0		; a0 -> CONTRL array.
	move.w	6(a0),d0		; d0 <- character count.
	move.l	_INTIN(a4),a0		; a0 -> character array.
	bra	ef12_lend

ef12_loop:

	move.w	(a0)+,d1		; d1 <- next character from array.

	movem.l	d0/a0,-(sp)
	bsr	gsx_conout		; output character to console.
	movem.l	(sp)+,d0/a0

ef12_lend:

	dbra	d0,ef12_loop
	rts


*******************************************************************************
**	escape p.							     **
**	escape function 13.						     **
**			       Reverse Video On.			     **
*******************************************************************************

escp:
escfn13:	bset.b	#F_REVID,v_stat_0(a4)	 ; set reverse bit in v_stat_0
		rts	


*******************************************************************************
**	escape q.							     **
**	escape function 14.						     **
**			       Reverse Video Off.			     **
*******************************************************************************

escq:
escfn14:	bclr.b	#F_REVID,v_stat_0(a4)		; clr reverse bit in v_stat_0
		rts


*******************************************************************************
**	escape function 15.						     **
**			    Inquire Cursor Position.			     **
*******************************************************************************

escfn15:

	move.l	_CONTRL(a4),a0		; a0 -> CONTRL array.
	move.w	#2,8(a0)		; 2 integers are returned.
	move.l	_INTOUT(a4),a0		; a0 -> INTOUT array.
	move.w	v_cur_cy(a4),d0		; d0 <- cell Y (zero based)
	addq.w	#1,d0			; d0 <- row number
	move.w	d0,(a0)+		; return row number.
	move.w	v_cur_cx(a4),d0		; d0 <- cell X (zero based)
	addq.w	#1,d0			; d0 <- column number
	move.w	d0,(a0)			; return column number.
	rts


*******************************************************************************
**	escape function 16.						     **
**			    Inquire Tablet Status.			     **
*******************************************************************************

escfn16:

	moveq.l	#1,d0
	move.l	_CONTRL(a4),a0		; a0 -> CONTRL array.
	move.w	d0,8(a0)		; 1 integer is returned.
	move.l	_INTOUT(a4),a0		; a0 -> INTOUT array.
	move.w	d0,(a0)			; 1 => there is a mouse.
	rts


*******************************************************************************
**	escape function 18.						     **
**			     Place Graphic Cursor.			     **
*******************************************************************************

escfn18:

	movea.l	_INTIN(a4),a0		; a0 -> INTIN array.
	clr.w	(a0)			; INTIN(0)<- 0 =>  show regardless.
	jmp	_v_show_c		; show graphic cursor.


*******************************************************************************
**	escape function 19.						     **
**			    Remove Graphic Cursor.			     **
*******************************************************************************

escfn19:

	jmp	_v_hide_c		; hide graphic cursor.




*  The following routines are for VT-52 terminal emulation.


*******************************************************************************
*	escape I.							     **
*				 Reverse Index.				     **
*******************************************************************************

escI:

	move.w	v_cur_cy(a4),d1		; d1 <- current cursor Y
	bne	up_cursor		; if not at top, move cursor up 1 line

	bsr	hide_cursor
	bsr	p_sc_dn			; scroll screen down 1 line and
	bra	show_cursor		; blank the top line


*******************************************************************************
**	escape L.							     **
**				 Insert Line.				     **
*******************************************************************************

escL:

	bsr	hide_cursor
	move.w	v_cur_cy(a4),d1		; d1 <- Ymin of scroll region
	bsr	p_sc_dn			; scroll down 1 line. insert blank line

start_o_line:

	clr.w	d0			; d0 <- X of beginning of line
	move.w	v_cur_cy(a4),d1		; d1 <- current Y
	bsr	move_cursor
	bra	show_cursor


*******************************************************************************
**	escape M.							     **
**				 Delete Line.				     **
*******************************************************************************

escM:

	bsr	hide_cursor		; hide cursor.
	move.w	v_cur_cy(a4),d1		; line to begin scrolling up.
	bsr	p_sc_up			; scroll up 1 line & blank bottom line.
	bra	start_o_line


*******************************************************************************
**	escape d.							     **
**			Erase from Beginning of Page.			     **
*******************************************************************************

escd:

	move.w	v_cur_cy(a4),d3		; if were on the first line...
	beq	esco			; erase from beginning of line. return

	clr.w	d0			; d0 <- Xmin (left sideof screen)
	clr.w	d1			; d1 <- Ymin (top of screen)
	move.w	v_cel_mx(a4),d2		; d2 <- Xmax (right side of screen)
	subq.w	#1,d3			; d3 <- Ymax (line above the cursor)

	bsr	erase_region		; erase screen above cursor
	bra	esco			; erase from beginning of line. return


*******************************************************************************
**			Enable Cursor (counted depth).			     **
*******************************************************************************

show_cursor:

	move.w	disab_cnt(a4),d0	; old count=0  =>  cursor is visible
	beq	show_exit
	
	subq.w	#1,d0			; new count=0  =>  redisplay cursor
	beq	enable_it

	move.w	d0,disab_cnt(a4)	; otherwise, record current count

show_exit:

	rts


*******************************************************************************
**	escape e.							     **
**			Enable Cursor (always).				     **
*******************************************************************************

esce:
	move.l  _lineAVar,a4		; a4 -> linea var struct

	tst.w	disab_cnt(a4)		; if cursor is already displayed,
	beq	escj_exit		; we're done

enable_it:

	move.w	#1,disab_cnt(a4)	; set up for cursor redisplay
	move.l	v_cur_ad(a4),a1		; a1 -> current cursor position
	bra	show_alpha		


*******************************************************************************
**	escape f.							     **
**			  Disable Cursor (counted depth).		     **
*******************************************************************************

escf:
	move.l  _lineAVar,a4		; a4 -> linea var struct

hide_cursor:

	addq.w	#1,disab_cnt(a4)	; increment the disable counter.

	bclr.b	#F_CSTATE,v_stat_0(a4)	; a4 -> v_stat_0
	beq	escj_exit		; exit if cursor is currently invisible

	move.l	v_cur_ad(a4),a1		; turn cursor off and return
	bra	neg_cell		; from there


*******************************************************************************
**	escape j.							     **
**			     Save Cursor Position.			     **
*******************************************************************************

escj:		bset.b	#F_SVPOS,v_stat_0(a4)	; set "pos saved" status bit.
		move.l	v_cur_cx(a4),xydraw(a4)

escj_exit:	rts


*******************************************************************************
**	escape k.							     **
**			    Restore Cursor Position.			     **
*******************************************************************************

esck:

	bclr.b	#F_SVPOS,v_stat_0(a4)		; clear "position saved" status bit
	beq	escH			; if (X,Y) was not saved, home cursor

	move.w	sav_cx(a4),d0		; d0 <- saved X
	move.w	sav_cy(a4),d1		; d1 <- saved Y
	bra	move_cursor		; move cursor to saved position.


*******************************************************************************
**	escape l.							     **
**				Erase Entire Line.			     **
*******************************************************************************

escl:

	clr.w	d0
	move.w	v_cur_cy(a4),d1
	move.w	v_cel_mx(a4),d2
	move.w	d1,d3
	bsr	erase_region		; blank whole line.

	bra	move_cursor		; (d0,d1) is X,Y of beginning of line


*******************************************************************************
**	escape o.							     **
**			  Erase from Beginning of Line.			     **
*******************************************************************************

esco:

	clr.w	d0			; d0 <- Xmin
	move.w	v_cur_cy(a4),d1		; d1 <- Y of line to erase
	move.w	v_cur_cx(a4),d2		; d2 <- Xmax
	move.w	d1,d3			; d3 <- Y of same line

erase_region:

	bsr	hide_cursor		; hide cursor (if necessary)
	bsr	blank_it		; clear it out
	bra	show_cursor		; return from there


*******************************************************************************
**	escape v.							     **
**			      Wrap at End of Line.			     **
*******************************************************************************

escv:

	bset.b	#F_CEOL,v_stat_0(a4)	; set the eol handling bit in v_stat_0
	rts


*******************************************************************************
**	escape w.							     **
**			    Overwrite at End of Line.			     **
*******************************************************************************

escw:

	bclr.b	#F_CEOL,v_stat_0(a4)		; clear the eol bit in v_stat_0
	rts


*******************************************************************************
**				Carriage Return.			     **
*******************************************************************************

ascii_cr:

	clr.w	d0			; d0 <- X of beginning of line
	move.w	v_cur_cy(a4),d1		; d1 <- current Y
	bra	move_cursor		; move_cursor does CRITICAL SECTION


*******************************************************************************
**				  Line Feed.				     **
*******************************************************************************

ascii_lf:

	move.w	v_cur_cy(a4),d1		; d1 <- current cursor y.
	cmp.w	v_cel_my(a4),d1		; at bottom of screen?
	bne	down_cursor		; no, move cursor down one line

	bsr	hide_cursor
	clr.w	d1			; scroll region starts at top of screen
	bsr	p_sc_up			; scroll up 1 line & blank current line
	bra	show_cursor


*******************************************************************************
**			cursor blink interrupt routine.			     **
*******************************************************************************

*   If dsply_cnt is non-zero, the cursor is not processed
*
*   F_CFLASH indicates whether the cursor is static or flashing.
*   Setting the flag enables flashing cursor.
*   Clearing the flag enables static cursor.
*
*   CSTATE reflects the actual state of the alpha cursor. When main line
*   code erases the cursor, this flag should reflect the change.
*
*   Main line code should NOT redisplay the cursor. The interrupt routine 
*   has sole responsibility for displaying the cursor whether flashing
*   or static.
*
*   Code segments that remove the Alpha cursor form from the screen
*   should supress possible interference from the cursor interrupt routine
*   by incrementing the disab_cnt word and clearing the F_CSTATE flag at the
*   outset. Upon leaving the critical section, disab_cnt is decremented.
*   If the count becomes zero, arrangements must be made to redisplay the
*   cursor.
*
*   To cause the cursor to be redisplayed, the main routine should load 
*   v_cur_ct with the value in v_delay. CSTATE flag should be clear. The
*   cursor will be displayed only after there has been no activity for at
*   least v_delay-1 frames. Thus, excessive redisplaying of the cursor is
*   avoided.


blink:	move.l  _lineAVar,a4		 ; a4 -> linea var struct

	tst.w	disab_cnt(a4)
	bne	bl_exit			  ; if cursor is hidden, exit
	
	subq.b	#1,v_cur_tim(a4)	  ; decrement cursor activity timer.
	bne	bl_exit			  ; if <> 0, do not process.

	move.b	vct_init(a4),v_cur_tim(a4) ; reset timer with flash count

	btst	#F_CFLASH,v_stat_0(a4)		  ; test flash bit in v_stat_0
	beq	bl_static		  ; route to static or flashing cases

bl_flash:

	bchg	#F_CSTATE,v_stat_0(a4)	  ; toggle cursor state in v_stat_0

bl_neg:

	move.l	v_cur_ad(a4),a1		  ; fetch cursor address
	bra	neg_cell		  ; XOR cursor. return from there

bl_static:

	bset.b	#F_CSTATE,v_stat_0(a4)	  ; a4 -> v_stat_0
	beq	bl_neg			  ; if cursor was off, turn it on.

bl_exit:

	rts				  ; otherwise, exit.


_cursconf:
	move.l  _lineAVar,a4		; a4 -> linea var struct

	move.w	4(sp),d0		; fetch function number.
	cmp.w	#7,d0			; above 7?
	bhi	bl_exit			; yes, exit.

	add.w	d0,d0			; d0 <- offset to the offset
	move.w	conf_tbl(pc,d0.w),d0 	; d0 <- offset to the function
	jmp	conf_tbl(pc,d0.w)	; execute the function



conf_tbl:

	dc.w 	    escf-conf_tbl	; hide
	dc.w        esce-conf_tbl	; forced show
	dc.w	 onblink-conf_tbl	; turn on blinking
	dc.w	offblink-conf_tbl	; turn off blinking
	dc.w	 setrate-conf_tbl	; set blink rate
	dc.w	 getrate-conf_tbl	; get blink rate
	dc.w	setdelay-conf_tbl	; set delay value
	dc.w	getdelay-conf_tbl	; get delay value


onblink:

	bset.b	#F_CFLASH,v_stat_0(a4)	; a4 -> v_stat_0 (enable blinking)
	rts

offblink:

	bclr.b	#F_CFLASH,v_stat_0(a4)	; a4 -> v_stat_0 (disable blinking)
	rts

setrate:

	move.b	7(sp),vct_init(a4)	; set the blink rate.
	rts

getrate:

	moveq.l	#0,d0			; clear hi byte of lo word
	move.b	vct_init(a4),d0		; get the blink rate.
	rts

setdelay:

	move.b	7(sp),d0
	move.b	d0,v_delay(a4)		; set the delay period
	rts

getdelay:

	moveq.l	#0,d0			; clear hi byte of lo word
	move.b	v_delay(a4),d0		; get the delay period
	rts


*******************************************************************************
*
* name:	ascii_out
*
* purpose:	this routine interfaces with the BIOS.	                     
*		it prints an ascii character on the screen as if
*		there was a dumb terminal in here
*
* in:	d1.w	ascii code for character
*	V_CELL pointer to desired version of cell display routine
*
*******************************************************************************

ascii_out:	
	move.l  _lineAVar,a4		; a4 -> linea var struct

	cmp.w	v_fnt_st(a4),d1		; test against minimum
	bcs	out_of_bounds

	cmp.w	v_fnt_nd(a4),d1		; test against maximum
	bhi	out_of_bounds


	sub.w	v_fnt_st(a4),d1		; d1 <- relative charecter val
	move.l	v_off_ad(a4),a0		; a0 -> offset table.
	add.w	d1,d1			; d1 <- word offset into table
	move.w	(a0,d1.w),d1		; d1 <- pixel offset into font data
	lsr.w	#3,d1			; d1 <- byte offset into font data

	move.l	v_fnt_ad(a4),a0
	add.w	d1,a0			; a0 -> alpha source

	move.l	v_cur_ad(a4),a1		; a1 -> the destination
	move.w	v_col_fg(a4),d6		; d6 <- foreground color
	move.w	v_col_bg(a4),d7		; d7 <- background color

	cmp.w	#16,_v_planes(a4)	; see if we should use long val for col
	ble	col_ok2			; if not the just skip
	move.l	vl_col_fg(a4),d6	; d6 <- foreground color
	move.l	vl_col_bg(a4),d7	; d7 <- background color

col_ok2:
	btst.b	#F_REVID,v_stat_0(a4)	; test reverse video flag in v_stat_0
	beq	put_char
	exg	d6,d7			; reverse fore and background colours
            
put_char:

	addq.w	#1,disab_cnt(a4)	; <<< BEGIN CRITICAL SECTION >>>
 	bclr.b	#F_CSTATE,v_stat_0(a4)	; mark cursor invisible in v_stat_0

	move.l	V_ROUTINES(a4),a5	; a5 -> routines vector list
	move.l	V_CELL(a5),a5		; a5 -> to the desired routine
	jsr	(a5)


*   update cursor position to next cell position
*   perform carriage return and line feed if necessary

	move.w	v_cur_cx(a4),d0
	move.w	v_cur_cy(a4),d1

	cmp.w	v_cel_mx(a4),d0		; are we at right edge ?
	blt	next_cell		; no => increment cell ptr

end_o_line:

	btst.b	#F_CEOL,v_stat_0(a4)	; wrap or overwrite ?
	beq	show_alpha		; overwrite: stay put

	clr.w	d0			; d0 <- X of first cell in line
	move.l	_v_bas_ad,a1		; a1 -> base of screen

	cmp.w	v_cel_my(a4),d1		; is it time to scroll ? 
	blt	no_scroll

	move.w	d1,v_cur_cy(a4)		; save the cursor Y coordinate
	mulu	v_cel_ht(a4),d1		; d1 <- (cell height) * (cursor Y pos)
	mulu	_v_lin_wr(a4),d1	; d1 <-  offset to start of last line
	add.l	d1,a1			; a1 -> beginning of last line

	clr.w	d1			; scroll from top of screen.
	movem.l d0/a1,-(sp)		; SAVE ME!!!!!
	
;	pea	save_it(pc)		 return to "save_it"
;	bra	p_sc_up			 do the scroll.

	bsr	p_sc_up
	movem.l (sp)+,d0/a1		; RESTORE ME!
	bra	save_it

no_scroll:

	addq.w	#1,d1			; d1 <- Y of next line
	move.w	d1,d2			; d2 <- Y of next line
	mulu	v_cel_ht(a4),d2		; d1 <- (cell height) * (cursor Y pos)
	mulu	_v_lin_wr(a4),d2	; d1 <-  offset to start of last line
	add.l	d2,a1			; a1 -> next line
	bra	disp_cur


next_cell:
	move.l	v_off_ad(a4),a2		; a2 -> offset table
	move.w	byt_per_pix(a4),d2	; d2 <- # of bytes per pix
	beq	word_cell		; if zero means not pix packed
	mulu	2(a2),d2		; d2 <- offset to next cell
	adda.l	d2,a1			; a1 -> first cell of next word
	addq.w	#1,d0			; Xcell of next cell to right
	bra	disp_cur		; display cursor

word_cell:

	cmp.w	#16,2(a2)		; see if char cell is word wide
	bne	byte_cell		; if not inc a1 by one (byte)
	addq.w	#1,d0			; Xcell of next cell to right
	move.w	_v_planes(a4),d2
	add.w	d2,d2
	lea	(a1,d2.w),a1		; a1 -> first cell of next word
	bra	disp_cur		; display cursor

byte_cell:

	addq.w	#1,a1			; a1 -> next cell (if X was even)
	addq.w	#1,d0			; Xcell of next cell to right
	btst.l	#0,d0			; if X is even, move to next
	bne	disp_cur		; word in the plane

next_word:

	move.w	_v_planes(a4),d2
	add.w	d2,d2
	lea	-2(a1,d2.w),a1		; a1 -> first cell of next word

disp_cur:

	move.w	d1,v_cur_cy(a4)		; update the cursor Y coordinate

save_it:

	move.w	d0,v_cur_cx(a4)		; update the cursor X coordinate
	move.l	a1,v_cur_ad(a4)		; update cursor address
	

show_alpha:

	move.b	v_delay(a4),d6		; if v_delay=0 and v_hid_ct=1
	bne	set_delay		; redisplay cursor right now!

	move.w	disab_cnt(a4),d7	; d7 <- old hide count
	subq.w	#1,d7			; d7 <- new hide count
	bne	set_hide		; quit if cursor remains invisible

	bsr	neg_cell		; immediately redisplay cursor

	bset.b	#F_CSTATE,v_stat_0(a4)	; indicate cursor is now visible
	move.b	vct_init(a4),d6		; d6 <- new flash cycle

set_delay:

	move.b	d6,v_cur_tim(a4)	; toggle after a period of mourning

set_hide:

	subq.w	#1,disab_cnt(a4)	; <<< END CRITICAL SECTION >>>

out_of_bounds:

	rts


*******************************************************************************
*
* title:	Scroll
*
*		Scroll copies a source region as wide as the screen to an
*		overlapping destination region on a one cell-height offset
*		basis.  Two entry points are provided:  Partial-lower
*		scroll-up, partial-lower scroll-down. Partial-lower screen
*		operations require cell y # indicating the top line where
*		scrolling will take place.
*
*		After the copy is performed, any non-overlapping area of
*		the previous source region is "erased" by filling with the
*		background color.
*
* 
*  in:		d1.w	   cell Y of region top
*		v_cel_mx   cell Y of region bottom
*		V_SCRUP	   points to desired version of scroll up routine
*		V_SCRDN	   points to desired version of scroll down routine
*
*  munged:	d0-d7/a2-a3/a5
*
*******************************************************************************

p_sc_up:	move.l	V_ROUTINES(a4),a5	; a5 -> vector list
		move.l	V_SCRUP(a5),a5		; a5 -> version of p_sc_up
		jmp	(a5)			; 

p_sc_dn:	move.l	V_ROUTINES(a4),a5	; a5 -> vector list
		move.l	V_SCRDN(a5),a5		; a5 -> version of p_sc_dn
		jmp	(a5)			; 

*******************************************************************************
*
* title:	Blank it
*
* purpose:	This routine fills a cell-word aligned region with the
*		background color. The rectangular region is specified by
*		a top/left cell x,y and a bottom/right cell x,y, inclusive.
*
* in:		d0 	cell Xmin of region
*		d1	cell Ymin of region
*		d2	cell Xmax of region
*		d3	cell Ymax of region
*
*		V_BLANK  pointer to blanking routine (hb_blank uses BLASTER)
*
* mutated:	d3-d7/a2-a3/a5
*
*******************************************************************************

blank_it:	move.l	V_ROUTINES(a4),a5	; a5 -> vector list
		move.l	V_BLANK(a5),a5		; a5 -> version of blank_it
		jmp	(a5)			; 

*******************************************************************************
*
* name:		cell_addr
*
*
* purpose:	convert cell X,Y to a screen address. also clip cartesian 
*          	coordinates to the limits of the current screen.
*
*
* in:		d0.w	cell X
*		d1.w	cell Y
*
*
* out:		a1	points to first byte of cell
*		d0	X (clipped)
*		d1	Y (clipped)
*
*
* munged:	d2-d5
*
*******************************************************************************

* check bounds against screen limits

cell_addr:	move.w	v_cel_mx(a4),d2
		tst.w	d0			; test for negative x
		bge	clip_x
		moveq.l	#0,d0
		bra	x_clipped

clip_x:		cmp.w	d0,d2
		bpl	x_clipped
		move.w	d2,d0			; d0 <- clipped x

x_clipped:	move.w	v_cel_my(a4),d2
		tst.w	d1			; test for negative y
		bge	clip_y
		moveq.l	#0,d1
		bra	y_clipped
		
clip_y:		cmp.w	d1,d2
		bpl	y_clipped
		move.w	d2,d1			; d1 <- clipped Y


y_clipped:	move.w	d1,d3			; d3 <- clipped Y
		mulu	v_cel_ht(a4),d3
		mulu	_v_lin_wr(a4),d3	; d3 <- offset to row Y	

		move.w	d0,d2			; d2 <- clipped X

		move.l	v_off_ad(a4),a2		; a2 -> offset table
		move.w	byt_per_pix(a4),d5	; d5 <- # bytes per each pix
		bne	claddr_pix		; do pixel packed

		cmp.w	#16,2(a2)		; see if char cell is word wide
		bne	claddr1			; bra if cell is 1 byte
		add.w	d2,d2			; d2 <- d2 * 2 if cel = 2 bytes

claddr1:	bclr.l	#0,d2			; d2 <- word boundry X
		sne	d4			; d4 <- 0 if X even else <- FF
		mulu	_v_planes(a4),d2	; d2 <- offset in bytes to X
		add.b	d4,d4			; X was even => cy:0 else cy:1
		addx.l	d3,d2			; d2 <- total offset to X

		move.l	_v_bas_ad,a1
		add.w	v_cur_off(a4),a1	; another silly offset
		add.l	d2,a1			; a1 -> cell (X,Y)
		rts


claddr_pix:	mulu	2(a2),d2		; d2 <- # of pixels into line
		mulu	d5,d2			; d2 <- # of bytes into line
		add.l	d3,d2			; d2 <- (X, Y) offset in bytes
		move.l	_v_bas_ad,a1
		add.w	v_cur_off(a4),a1	; another silly offset
		add.l	d2,a1			; a1 -> cell (X,Y)

		rts


*******************************************************************************
*
* move_cursor:	go to the proper negate alpha cell routine
*
* purpose:	move the cursor and update global parameters
*		erase the old cursor (if necessary) and draw new
*		cursor (if necessary) 
*
* in:		d0.w	new cell X coordinate
*		d1.w	new cell Y coordinate
*
*******************************************************************************
move_cursor:	move.l	V_ROUTINES(a4),a1	; a1 -> routine vector list
		move.l	V_MOVEACUR(a1),a1	; a1 -> poper move routine
		jmp	(a1)

*******************************************************************************
*	                           
* name:		st_move_cursor (also works with pixel packed)
*                            
* purpose:	move the cursor and update global parameters
*		erase the old cursor (if necessary) and draw new
*		cursor (if necessary) 
*
* in:		d0.w	new cell X coordinate
*		d1.w	new cell Y coordinate
*
*******************************************************************************

st_move_cursor:	addq.w	#1,disab_cnt(a4)	; << BEGIN CRITICAL SECTION >>

		bclr.b	#F_CSTATE,v_stat_0(a4)	; is curs currently displayed ?
		beq	invisible		; if it isn't, don't invert it.

		move.l	v_cur_ad(a4),a1		; a1 -> present cursor
		bsr	neg_cell		; erase it now

invisible:	bsr	cell_addr		; get new clipped cursor pos

		move.w	d0,v_cur_cx(a4)		; save new cursor X
		move.w	d1,v_cur_cy(a4)		; save new cursor Y
		move.l	a1,v_cur_ad(a4)		; save new cursor address

		bra	show_alpha		; << END CRITICAL SECTION >>

*******************************************************************************
*
* neg_cell:	go to the proper negate alpha cell routine
*
*******************************************************************************
neg_cell:	move.l	V_ROUTINES(a4),a2	; a2 -> routine vector list
		move.l	V_NEGCELL(a2),a2	; a2 ->  ne alpha cursor routine
		jmp	(a2)

*******************************************************************************
*	
* name:		st_neg_cell
*
* purpose:	This routine negates the contents of an arbitrarily tall 
*		byte/word wide cell composed of an arbitrary number of
*		(atari styled) bit-planes. cursor display can be
*		acomplished via this procedure. since a second 
*		negation restores the original cell condition, there is
*		no need to save	the contents beneath the cursor block.
*
* in:		a1.l	  points to destination (1st plane, top of block)
*
*
* out:		destroyed:	d4-d7/a0-a2
*
*******************************************************************************


st_neg_cell:	move.w	_v_lin_wr(a4),d4
		move.w	v_cel_ht(a4),d5
		subq.w	#1,d5			; for dbra.
		move.w	_v_planes(a4),d7
		subq.w	#1,d7			; for dbra.

plane_loop:	move.l	a1,a2			; a2 -> top of curr dest plane
		move.w	d5,d6			; reset cell length counter
		move.l	v_off_ad(a4),a0		; a2 -> offset table

		cmp.w	#16,2(a0)		; see if char cell is word wide
		bne	neg_byte		; if not just neg one byte

neg_word:	not.w	(a2)
		add.w	d4,a2
		dbra	d6,neg_word

		addq.w	#2,a1			; a1 -> top of block nxt plane
		dbra	d7,plane_loop
		rts

neg_byte:	not.b	(a2)
		add.w	d4,a2
		dbra	d6,neg_byte

		addq.w	#2,a1			; a1 -> top of block nxt plane
		dbra	d7,plane_loop
		rts


*******************************************************************************
**	escape function 102.						     **
**									     **
**		          Install User Defined Font			     **
*******************************************************************************

escfn102:	move.l	_INTIN(a4),a0
		move.l	(a0),a0			; a0 -> font header.

* fall through to inialization sequence

*******************************************************************************
**		     Font Globals Initialization Routine		     **
**									     **
**			  a0 -> system font header			     **
*******************************************************************************

gl_f_init:	move.l  _lineAVar,a4		; a4 -> linea var struct
		move.w	FRM_HT(a0),d0		; fetch form height.
		move.w	d0,v_cel_ht(a4)		; init cell height.
		move.w	_v_lin_wr(a4),d1	; fetch bytes/line.
		mulu	d0,d1
		move.w	d1,v_cel_wr(a4)		; init cell wrap. (obsolete)
		moveq.l	#0,d1			; clear the hi word of dividend
		move.w	v_vt_rez(a4),d1		; fetch vertical res.
		divu	d0,d1			; vertical res/cell height.
		subq.w	#1,d1			; 0 origin.
		move.w	d1,v_cel_my(a4)		; init cell max y.
		moveq.l	#0,d1			; clear the hi word of dividend
		move.w	v_hz_rez(a4),d1		; fetch horizontal res.
		divu	CEL_WD(a0),d1		; horizontal res/cell width.
		subq.w	#1,d1			; 0 origin.
		move.w	d1,v_cel_mx(a4)		; init cell max x.
		move.w	FRM_WD(a0),v_fnt_wr(a4)	; init font wrap.
		move.w	FIRST(a0),v_fnt_st(a4)	; init font start ADE.
		move.w	LAST(a0),v_fnt_nd(a4)	; init font end ADE.
		move.l	PDAT(a0),v_fnt_ad(a4)	; init font data ptr.
		move.l	POFF(a0),v_off_ad(a4)	; init font offset ptr.

		rts

	.end
