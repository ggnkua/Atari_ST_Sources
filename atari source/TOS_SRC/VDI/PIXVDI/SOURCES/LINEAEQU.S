*******************************  lineaequ.s  *********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/lineaequ.s,v $
* ============================================================================
* $Author: lozben $	$Date: 91/07/29 14:55:44 $     $Locker:  $
* ============================================================================
*
* $Log:	lineaequ.s,v $
* Revision 3.1  91/07/29  14:55:44  lozben
* Created this file of needed equates for the new multitasking vdi.
* 
******************************************************************************

.include	"devequ.s"

*****************************************
*	Non-Overlayable Variables       *
*****************************************
angle		=	-910
beg_ang		=	-908
CUR_FONT	=	-906
del_ang		=	-902
deltay		=	-900
deltay1		=	-898
deltay2		=	-896
end_ang		=	-894
fil_intersect	=	-892
fill_maxy	=	-890
fill_miny	=	-888
n_steps		=	-886
odeltay		=	-884
s_begsty	=	-882
s_endsty	=	-880
s_fil_col	=	-878
s_fill_per	=	-876
s_patmsk	=	-874
s_patptr	=	-872
start		=	-868
xc		=	-866
xrad		=	-864
yc		=	-860
yrad		=	-858


mouse_cdb	=	-856	; define the mouse form storage area
m_pos_hx	=	-856	; Mouse hot spot - x coord
m_pos_hy	=	-854	; Mouse hot spot - y coord
m_planes	=	-852	; Mouse planes (reserved, but we used it!)
m_cdb_bg	=	-850	; Mouse background color as pel value
m_cdb_fg	=	-848	; Mouse foreground color as pel value
mask_form	=	-846	; Storage for mouse cursor mask and form

_INQ_TAB	=	-782
_DEV_TAB	=	-692

_GCURXY		=	-602
_GCURX		=	-602
_GCURY		=	-600

_HIDE_CNT	=	-598
_MOUSE_BT	=	-596
_REQ_COL	=	-594
_SIZ_TAB	=	-498
_TERM_CH	=	-468
_chc_mode	=	-466
_cur_work	=	-464	; pointer to current works attributes
_def_font	=	-460	; pointer to default font head
_font_ring	=	-456
_ini_font_count	=	-440
_line_cw	=	-438
_loc_mode	=	-436
_num_qc_lines	=	-434

trap14sav	=	-432	; space to save the return address
col_or_mask	=	-428	; some modes this is ored in VS_COLOR
col_and_mask	=	-424	; some modes this is anded in VS_COLOR
trap14bsav	=	-420	; space to sav ret adr (for reentrency)

_str_mode	=	-352
_val_mode	=	-350

_MOUSE_ST	=	-348
cur_ms_stat	=	-348	; Current mouse status bits
				;	 bits used as follows
				;
				;	 0   LEFT button state
				;	 1   RIGHT button state
				;	 2-4 not used
				;	 5   movement status
				;	 6   LEFT button changed
				;	 7   RIGHT button changed


disab_cnt	=	-346


_XYDRAW		=	-344
 xydraw		=	-344	; x,y communication block.
_DRAW_FLAG	=	-340
 draw_flag	=	-340	; Non-zero means draw mouse form on vblank


mouse_flag	=	-339	; Non-zero if mouse ints disabled

retsav		=	-338
sav_cxy		=	-334	; save area for cursor cell coords
sav_cx		=	-334	; save area for cursor cell coords X pos
sav_cy		=	-332	; save area for cursor cell coords Y pos

save_block	=	-330
save_len	=	-330
save_addr	=	-328	; screen address of 1st word of plane 0
save_stat	=	-324
save_area	=	-322	; save up to 4 planes. 16 longwords / plane

tim_addr	=	-66
tim_chain	=	-62
user_but	=	-58	; user button vector
user_cur	=	-54	; user cursor vector
user_mot	=	-50	; user motion vector

v_cel_ht	=	-46
v_cel_mx	=	-44
v_cel_my	=	-42
v_cel_wr	=	-40	; used in ST blitter code otherwise obsolete
v_col_bg	=	-38
v_col_fg	=	-36
v_cur_ad	=	-34
v_cur_off	=	-30
v_cur_cx	=	-28
v_cur_cy	=	-26
vct_init	=	-24	; v_cur_tim reload value.
v_cur_tim	=	-23
v_fnt_ad	=	-22
v_fnt_nd	=	-18
v_fnt_st	=	-16
v_fnt_wr	=	-14
v_hz_rez	=	-12
v_off_ad	=	-10
v_stat_0	=	-6
v_delay		=	-5
v_vt_rez	=	-4
_bytes_lin	=	-2	; copy of _v_lin_wr for concat.


lineavar	=	0
_v_planes	=	0	; number of video planes.
_v_lin_wr	=	2	; number of bytes/video line.

local_pb	=	4

_CONTRL		=	4	; ptr to the CONTRL array.
_INTIN		=	8	; ptr to the INTIN array.
_PTSIN		=	12	; ptr to the PTSIN array.
_INTOUT		=	16	; ptr to the INTOUT array.
_PTSOUT		=	20	; ptr to the PTSOUT array.

_FG_BP_1	=	24	; foreground bit_plane #1 value.
_FG_BP_2	=	26	; foreground bit_plane #2 value.
_FG_BP_3	=	28	; foreground bit_plane #3 value.
_FG_BP_4	=	30	; foreground bit_plane #4 value.
_LSTLIN		=	32	; 0 => not last line of polyline.
_LN_MASK	=	34	; line style mask.
_WRT_MODE	=	36	; writing mode.


_X1		=	38	; _X1.
_Y1		=	40	; _Y1.
_X2		=	42	; _X2.
_Y2		=	44	; _Y2.
_patptr		=	46	; ptr to pattern.
_patmsk		=	50	; pattern index. (mask)
_multifill	=	52	; multi-plane fill flag. (0 => 1 plane)

_CLIP		=	54	; clipping flag.
_XMN_CLIP	=	56	; x minimum clipping value.
_YMN_CLIP	=	58	; y minimum clipping value.
_XMX_CLIP	=	60	; x maximum clipping value.
_YMX_CLIP	=	62	; y maximum clipping value.

_XACC_DDA	=	64	; accumulator for x DDA
_DDA_INC	=	66	; the fraction to be added to the DDA
_T_SCLSTS	=	68	; scale up or down flag.
_MONO_STATUS	=	70	; non-zero - cur font is monospaced
_SOURCEX	=	72
_SOURCEY	=	74	; upper left of character in font file
_DESTX		=	76
_DESTY		=	78	; upper left of destination on screen
_DELX		=	80
_DELY		=	82	; width and height of character
_FBASE		=	84	; pointer to font data
_FWIDTH		=	88	; offset,segment and form with of font
_STYLE		=	90	; special effects
_LITEMASK	=	92	; special effects
_SKEWMASK	=	94	; special effects
_WEIGHT		=	96	; special effects
_R_OFF		=	98
_L_OFF		=	100	; skew above and below baseline
_DOUBLE		=	102	; replicate pixels
_CHUP		=	104	; character rotation vector
_TEXT_FG	=	106	; text foreground color
_scrtchp	=	108	; pointer to base of scratch buffer
_scrpt2		=	112	; large buffer base offset
_TEXT_BG	=	114	; text background color
_COPYTRAN	=	116	; copy raster form type flag. (opaque/trans)
_quitfill	=	118	; ptr to routine for quitting seedfill.
UserDevInit	=	122	; ptr to user routine before dev_init
UserEscInit	=	126	; ptr to user routine before esc_init

V_ROUTINES	=	162	; pointer to drawing primitives vector list
CUR_DEV		=	166	; pointer to current device structure
_BLT_MODE	=	170

_REQ_X_COL	=	174	; extended request color array

sv_blk_ptr	=	1614	; points to the proper save block
_FG_B_PLANES	=	1618	; foreground bit planes flags (bit 0 is plane 0)

_FG_BP_5	=	1622	; foreground bit_plane #5 value.
_FG_BP_6	=	1624	; foreground bit_plane #6 value.
_FG_BP_7	=	1626	; foreground bit_plane #7 value.
_FG_BP_8	=	1628	; foreground bit_plane #8 value.

_save_block	=	1630
_save_len	=	1630
_save_addr	=	1632	; screen address of 1st word of plane 0
_save_stat	=	1636
_save_area	= 	1638	; save up to 8 planes. 16 longwords / plane

q_circle	=	2662	; space to build circle coordinates

******************* NEW EQUATES *******************

byt_per_pix	=	2822	; number of bytes per pixel (0 if < 1)
form_id		=	2824	; scrn form 2 ST, 1 stndrd, 3 pix
vl_col_bg	=	2826	; escape background color
vl_col_fg	=	2830	; escape foreground color
pal_map		=	2834	; either a maping of reg's or true val
V_PRIMITIVES	=	3858	; all the vectored primitives
