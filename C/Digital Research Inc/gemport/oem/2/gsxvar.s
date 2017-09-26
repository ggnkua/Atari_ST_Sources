******************************************************************************
*	This file contains the variables used by GSX (GEM VDI) gleaned from  *
*	the source files for ROMming.					     *
******************************************************************************

		.bss
*
		globl	local_pb
		globl	_CONTRL
		globl	_INTIN
		globl	_PTSIN
		globl	_INTOUT
		globl	_PTSOUT
*
		globl	_FG_BP_1
		globl	_FG_BP_2
		globl	_FG_BP_3
		globl	_FG_BP_4
*
		globl	_X1
		globl	_X2
		globl	_Y1
		globl	_Y2
		globl	_LSTLIN
		globl	_LN_MASK
		globl	_WRT_MODE
*
		globl	_v_planes
		globl	_v_lin_wr
*
		globl	_patptr
		globl	_patmsk
*
		globl	_CLIP
		globl	_XMN_CLIP
		globl	_XMX_CLIP
		globl	_YMN_CLIP
		globl	_YMX_CLIP
*
		globl	_multifill
		globl	_XACC_DDA
		globl	_DDA_INC
		globl	_T_SCLSTS
		globl	_MONO_STATUS
		globl	_SOURCEX
		globl	_SOURCEY
		globl	_DESTX
		globl	_DESTY
		globl	_DELX
		globl	_DELY
		globl	_FBASE
		globl	_FWIDTH
		globl	_STYLE
		globl	_LITEMASK
		globl	_SKEWMASK
		globl	_WEIGHT
		globl	_R_OFF
		globl	_L_OFF
		globl	_DOUBLE
		globl	_CHUP
		globl	_TEXT_FG
		globl	_scrtchp
		globl	_scrpt2
*
_v_planes:	ds.w	1		; number of video planes.
_v_lin_wr:	ds.w	1		; number of bytes/video line.
*
*
*
local_pb:
_CONTRL:	ds.l	1		; ptr to the CONTRL array.
_INTIN		ds.l	1		; ptr to the INTIN array.
_PTSIN		ds.l	1		; ptr to the PTSIN array.
_INTOUT		ds.l	1		; ptr to the INTOUT array.
_PTSOUT		ds.l	1		; ptr to the PTSOUT array.
*
*
*	The following 4 variables are accessed by the line-drawing routines
* 	as an array (to allow post-increment addressing).  They must be contiguous!!
*
_FG_BP_1	ds.w	1		; foreground bit_plane #1 value.
_FG_BP_2	ds.w	1		; foreground bit_plane #2 value.
_FG_BP_3	ds.w	1		; foreground bit_plane #3 value.
_FG_BP_4	ds.w	1		; foreground bit_plane #4 value.
_LSTLIN		ds.w	1		; 0 => not last line of polyline.
_LN_MASK	ds.w	1		; line style mask.
_WRT_MODE	ds.w	1		; writing mode.
*
*
*
_X1		ds.w	1		; _X1.
_Y1		ds.w	1		; _Y1.
_X2		ds.w	1		; _X2.
_Y2		ds.w	1		; _Y2.
_patptr		ds.l	1		; ptr to pattern.
_patmsk		ds.w	1		; pattern index. (mask)
_multifill	ds.w	1		; multi-plane fill flag. (0 => 1 plane)
*
_CLIP		ds.w	1		; clipping flag.
_XMN_CLIP	ds.w	1		; x minimum clipping value.
_YMN_CLIP	ds.w	1		; y minimum clipping value.
_XMX_CLIP	ds.w	1		; x maximum clipping value.
_YMX_CLIP	ds.w	1		; y maximum clipping value.
*
_XACC_DDA	ds.w	1		; accumulator for x DDA
_DDA_INC	ds.w	1		; the fraction to be added to the DDA
_T_SCLSTS	ds.w	1		; scale up or down flag.
_MONO_STATUS	ds.w	1		; non-zero - cur font is monospaced
_SOURCEX	ds.w	1
_SOURCEY	ds.w	1		; upper left of character in font file
_DESTX		ds.w	1
_DESTY		ds.w	1		; upper left of destination on screen
_DELX		ds.w	1
_DELY		ds.w	1		; width and height of character
_FBASE		ds.l	1		; pointer to font data
_FWIDTH		ds.w	1		; offset,segment and form with of font
_STYLE		ds.w	1		; special effects
_LITEMASK	ds.w	1		; special effects
_SKEWMASK	ds.w	1		; special effects
_WEIGHT		ds.w	1		; special effects
_R_OFF		ds.w	1
_L_OFF		ds.w	1		; skew above and below baseline
_DOUBLE		ds.w	1		; replicate pixels
_CHUP		ds.w	1		; character rotation vector
_TEXT_FG	ds.w	1		; text foreground color
_scrtchp	ds.l	1		; pointer to base of scratch buffer
_scrpt2		ds.w	1		; large buffer base offset

********************************************************************************
* Equated variables / assembler only variables
********************************************************************************
		.bss
		.even
		.globl	_fill_buffer

_fill_buffer	ds.w	256		* must be 256 words or equates will fail

*****************************************
*	Overlayable Variables           *
*****************************************

		.globl	_COPYTRAN
		.globl	_FLIP_Y
		.globl	_Q
		.globl	_Qbottom
		.globl	_Qhole
		.globl	_Qptr
		.globl	_Qtmp
		.globl	_Qtop
		.globl	_charx
		.globl	_chary
		.globl	_deftxbu
		.globl	_direction
		.globl	_gotseed
		.globl	_h_align
		.globl	_height
		.globl	_newxleft
		.globl	_newxright
		.globl	_notdone
		.globl	_oldxleft
		.globl	_oldxright
		.globl	_oldy
		.globl	_rmchar
		.globl	_rmcharx
		.globl	_rmchary
		.globl	_rmword
		.globl	_rmwordx
		.globl	_rmwordy
		.globl	_search_color
		.globl	_seed_type
		.globl	_v_align
		.globl	_width
		.globl	_wordx
		.globl	_wordy
		.globl	_xleft
		.globl	_xright

_COPYTRAN	.equ	_fill_buffer
_FLIP_Y		.equ	_fill_buffer+68	* Non-zero PTSOUT contains magnitueds
_Q		.equ	_fill_buffer+34	* storage for the seed points (.ds.w 200)
_Qbottom	.equ	_fill_buffer+4	* the bottom of the Q (zero)
_Qhole		.equ	_fill_buffer+12	* an empty space in the Q
_Qptr		.equ	_fill_buffer+8	* points to the active point
_Qtmp		.equ	_fill_buffer+10
_Qtop		.equ	_fill_buffer+6	* points top seed +3
_charx		.equ	_fill_buffer+58
_chary		.equ	_fill_buffer+60	* add this to each char for interchar
_deftxbu:	.equ	_fill_buffer+236	*scratch buffer for 8x16 (uses 276 bytes)
_direction	.equ	_fill_buffer+28	* is next scan line up or down?
_gotseed	.equ	_fill_buffer+32	* a seed was put in the Q
_h_align	.equ	_fill_buffer+40
_height		.equ	_fill_buffer+46	* extent of string set in dqt_extent
_newxleft	.equ	_fill_buffer+20	* ends of line at oldy +
_newxright	.equ	_fill_buffer+22	*     the current direction
_notdone	.equ	_fill_buffer+30	* does seedpoint==search_color?
_oldxleft	.equ	_fill_buffer+16	* left end of line at oldy
_oldxright	.equ	_fill_buffer+18	* right end
_oldy		.equ	_fill_buffer+14	* the previous scan line
_rmchar		.equ	_fill_buffer+62	* number of pixels left over
_rmcharx	.equ	_fill_buffer+64
_rmchary	.equ	_fill_buffer+66	* add this to use up remainder
_rmword		.equ	_fill_buffer+52	* the number of pixels left over
_rmwordx	.equ	_fill_buffer+54
_rmwordy	.equ	_fill_buffer+56	* add this to use up remainder
_search_color	.equ	_fill_buffer+2	* the color of the border
_seed_type	.equ	_fill_buffer	* indicates the type of fill
_v_align	.equ	_fill_buffer+42	* scaler alignments
_width		.equ	_fill_buffer+44
_wordx		.equ	_fill_buffer+48
_wordy		.equ	_fill_buffer+50	* add this to each space for interword
_xleft		.equ	_fill_buffer+24	* temporary endpoints
_xright		.equ	_fill_buffer+26

*****************************************
*	Non-Overlayable Variables       *
*****************************************

		.globl	cur_ms_stat
		.globl	disab_cnt
		.globl	draw_flag
		.globl	m_cdb_bg
		.globl	m_cdb_fg
		.globl	m_pos_hx
		.globl	m_pos_hy
		.globl	mask_form
		.globl	mouse_cdb
		.globl	mouse_flag
		.globl	newx
		.globl	newy
		.globl	retsav
		.globl	sav_cxy
		.globl	save_addr
		.globl	save_area
		.globl	save_len
		.globl	save_stat
		.globl	tim_addr
		.globl	tim_chain
		.globl	user_but
		.globl	user_cur
		.globl	user_mot
		.globl	v_cel_ht
		.globl	v_cel_mx
		.globl	v_cel_my
		.globl	v_cel_wr
		.globl	v_col_bg
		.globl	v_col_fg
		.globl	v_cur_ad
		.globl	v_cur_cx
		.globl	v_cur_cy
		.globl	v_cur_tim
		.globl	v_fnt_ad
		.globl	v_fnt_nd
		.globl	v_fnt_st
		.globl	v_fnt_wr
		.globl	v_hz_rez
		.globl	v_off_ad
		.globl	v_stat_0
		.globl	v_vt_rez

* mouse_cdb must be declared out of order since things are equated to it

mouse_cdb:	.ds.w	37		*define the mouse form storage area

cur_ms_stat	.ds.b	1	* Current mouse status
disab_cnt:	.ds.w	1
draw_flag	.ds.b	1	* Non-zero means draw mouse form on vblank
m_cdb_bg:	.equ	mouse_cdb+6	* Mouse background color as pel value
m_cdb_fg:	.equ	mouse_cdb+8	* Mouse foreground color as pel value
m_pos_hx:	.equ	mouse_cdb	* Mouse hot spot - x coord
m_pos_hy:	.equ	mouse_cdb+2	* Mouse hot spot - y coord
mask_form:	.equ	mouse_cdb+10	* Storage for mouse mask and cursor
mouse_flag:	.ds.b	1	* Non-zero if mouse ints disabled
newx		.ds.w	1	* New mouse x&y position
newy		.ds.w	1
retsav		.ds.l	1
sav_cxy:	.ds.w	2		* save area for cursor cell coords.
save_addr:	.ds.l	01
save_area:	.ds.l	$40
save_len:	.ds.w	01
save_stat:	.ds.b	01
tim_addr:	.ds.l	1
tim_chain	.ds.l	1
user_but	.ds.l	1	* user button vector
user_cur	.ds.l	1	* user cursor vector
user_mot	.ds.l	1	* user motion vector
v_cel_ht:	.ds.w	1
v_cel_mx:	.ds.w	1
v_cel_my:	.ds.w	1
v_cel_wr:	.ds.w	1
v_col_bg:	.ds.w	1
v_col_fg:	.ds.w	1
v_cur_ad:	.ds.l	1
v_cur_cx:	.ds.w	1
v_cur_cy:	.ds.w	1
v_cur_tim:	.ds.b	1
v_fnt_ad:	.ds.l	1
v_fnt_nd:	.ds.w	1
v_fnt_st:	.ds.w	1
v_fnt_wr:	.ds.w	1
v_hz_rez:	.ds.w	1
v_off_ad:	.ds.l	1
v_stat_0:	.ds.b	1
v_vt_rez:	.ds.w	1
		.end
