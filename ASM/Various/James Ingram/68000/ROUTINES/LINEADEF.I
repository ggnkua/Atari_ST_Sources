* Line-A variable definitions
* as given in COMPUTE! book

linea_definitions	equ	1

cur_font	equ	-906	; pointer to current font header
m_pos_hx	equ	-856	; mouse hotspot x co-ord
m_pos_hy	equ	-854	; mouse hotspot y co-ord
m_planes	equ	-852	; mouse writing mode
m_cdb_bg	equ	-850	; mouse background colour
m_cdb_fg	equ	-848	; mouse foreground colour
mask_form	equ	-846	; mouse sprite data
inq_tab		equ	-782	; ?
dev_tab		equ	-692	; ?
gcurx		equ	-602	; mouse x position
gcury		equ	-600	; mouse y position
m_hid_ct	equ	-598	; number of time mouse pointer hidden
mouse_bt	equ	-596	; mouse button status
req_col		equ	-594	; VDI RGB values (?)
siz_tab		equ	-498	; VDI (?)
cur_work	equ	-464	; address of current VDI virtual workstation
def_font	equ	-460	; pointer to default font
font_ring	equ	-456	; font header list
font_count	equ	-440	; no of fonts in font_ring
cur_ms_stat	equ	-348	; mouse status change info
v_hid_cnt	equ	-346	; depth text cursor is hidden at
cur_x		equ	-344	; x co-ord of mouse sprite
cur_y		equ	-342	; y co-ord of mouse sprite
cur_flag	equ	-340	; flag of whether to draw mouse sprite
mouse_flag	equ	-339	; mouse interrupt processing flag
v_sav_xy	equ	-334	; saved pos of text cursor
save_len	equ	-330	; height of form saved behind mouse pointer
save_addr	equ	-328	; addr of first word of data behind mouse pointer
save_stat	equ	-324	; save area status flag
save_area	equ	-322	; save buffer area for mouse pointer
user_tim	equ	-66	; addr of user's interrupt routine
next_tim	equ	-62	; addr user's routine (above) should jump to
user_but	equ	-58	; button change vector VDI (?)
user_cur	equ	-54	; cursor change vector VDI (?)
user_mot	equ	-50	; mouse movement vector VDI (?)
v_cel_ht	equ	-46	; text cell height (pixels)
v_cel_mx	equ	-44	; max chars on line - 1
v_cel_my	equ	-42	; max text screen rows - 1
v_cel_wr	equ	-40	; no of bytes to next vertical char cell
v_col_bg	equ	-38	; colour of text background
v_col_fg	equ	-36	; colour of text foreground
v_cur_ad	equ	-34	; current text cursor addr
v_cur_of	equ	-30	; offset scrn addr to first text char
v_cur_xy	equ	-28	; text cursor position
v_period	equ	-24	; cursor blink rate
v_cur_ct	equ	-23	; countdown to next blink toggle
v_fnt_ad	equ	-22	; addr of monospaced font data
v_fnt_nd	equ	-18	; last ASCII char in font
v_fnt_st	equ	-16	; first ASCII char in font
v_fnt_wd	equ	-14	; width of font form
v_rez_hz	equ	-12	; horizontal pixel res
v_off_ad	equ	-10	; addr of font offset table
v_rez_vt	equ	-4	; vertical pixel res
bytes_lin	equ	-2	; width of dest memory form
planes		equ	0	; no of colour planes for scrn res
width		equ	3	; width of dest form (160 for low/med res)
contrl		equ	4	; pointer to CONTRL array
intin		equ	8	; pointer to INTIN array
ptsin		equ	12	; pointer to PTSIN array
intout		equ	16	; pointer to INTOUT array
ptsout		equ	20	; pointer to PTSOUT array
colbit0		equ	24	; colour plane bit 0
colbit1		equ	26	; colour plane bit 1
colbit2		equ	28	; colour plane bit 2
colbit3		equ	30	; colour plane bit 3
lstlin		equ	32	; flag for drawing last pixel in line or not
lnmask		equ	34	; line draw pattern mask
wmode		equ	36	; writing mode
x1		equ	38	; x co-ord for drawing
y1		equ	40	; y co-ord for drawing
x2		equ	42	; x2 co-ord for drawing
y2		equ	44	; y2 co-ord for drawing
patptr		equ	46	; pointer to current fill pattern
patmsk		equ	50	; index to fill pattern
mfill		equ	52	; single / multi plane fill pattern
clip		equ	54	; clipping flag
xmincl		equ	56	; x min co-ord of clipping rect
ymincl		equ	58	; y min co-ord of clipping rect
xmaxcl		equ	60	; x max co-ord of clipping rect
ymaxcl		equ	62	; y max co-ord of clipping rect
xdda		equ	64	; accumulator for text scaling (orig = $8000)
ddainc		equ	66	; scaling increment
scaldir		equ	68	; scaling up / down
mono		equ	70	; monospaced font flag
sourcex		equ	72	; x co-ord of char in font
sourcey		equ	74	; y co-ord of char in font
destx		equ	76	; x scrn pos for char
desty		equ	78	; y scrn pos for char
delx		equ	80	; width of char to print
dely		equ	82	; height of char
fbase		equ	84	; addr of font's char image
fwidth		equ	88	; width of font form in bytes
style		equ	90	; FX flag for char
litemask	equ	92	; lightening mask
skewmask	equ	94	; skew mask
weight		equ	96	; width to thicken by for bold
roff		equ	98	; offset for italics above baseline
loff		equ	100	; offset for italics below baseline
scale		equ	102	; scaling flag
chup		equ	104	; char rotation angle
textfg		equ	106	; text foreground colour
scrthchp	equ	108	; scratch buffers for FX
scrpt2		equ	112	; offset of second buffer from first
textbg		equ	114	; text background colour
copytran	equ	116	; line-a copy raster mode
seedabort	equ	118	; pointer to seedfill routine


* now line-a variables as given in ST INTERNALS (if different)

v_planes	equ	0	; no of colour planes for scrn res
v_lin_wr	equ	3	; width of dest form (160 for low/med res)

_fg_bp_1	equ	24	; colour plane bit 0
_fg_bp_2	equ	26	; colour plane bit 1
_fg_bp_3	equ	28	; colour plane bit 2
_fg_bp_4	equ	30	; colour plane bit 3
_lstlin		equ	32	; flag for drawing last pixel in line or not
_ln_mask	equ	34	; line draw pattern mask
_wrt_mod	equ	36	; writing mode
_x1		equ	38	; x co-ord for drawing
_y1		equ	40	; y co-ord for drawing
_x2		equ	42	; x2 co-ord for drawing
_y2		equ	44	; y2 co-ord for drawing
_patptr		equ	46	; pointer to current fill pattern
_patmsk		equ	50	; index to fill pattern
_multifill	equ	52	; single / multi plane fill pattern
_clip		equ	54	; clipping flag
_xmn_clip	equ	56	; x min co-ord of clipping rect
_ymn_clip	equ	58	; y min co-ord of clipping rect
_xmx_clip	equ	60	; x max co-ord of clipping rect
_ymx_clip	equ	62	; y max co-ord of clipping rect
_xacc_dda	equ	64	; accumulator for text scaling (orig = $8000)
_dda_inc	equ	66	; scaling increment
_t_sclsts	equ	68	; scaling up / down
_mono_status	equ	70	; monospaced font flag
_sourcex	equ	72	; x co-ord of char in font
_sourcey	equ	74	; y co-ord of char in font
_destx		equ	76	; x scrn pos for char
_desty		equ	78	; y scrn pos for char
_delx		equ	80	; width of char to print
_dely		equ	82	; height of char
_fbase		equ	84	; addr of font's char image
_fwidth		equ	88	; width of font form in bytes
_style		equ	90	; FX flag for char
_litemask	equ	92	; lightening mask
_skewmask	equ	94	; skew mask
_weight		equ	96	; width to thicken by for bold
_r_off		equ	98	; offset for italics above baseline
_l_off		equ	100	; offset for italics below baseline
_scale		equ	102	; scaling flag
_chup		equ	104	; char rotation angle
_text_fg	equ	106	; text foreground colour
_scrthchp	equ	108	; scratch buffers for FX
_scrpt2		equ	112	; offset of second buffer from first
_text_bg	equ	114	; text background colour
_copytran	equ	116	; line-a copy raster mode

* definitions of font header offsets (from ST INTERNALS pg 219)

font_id		equ	0
font_size	equ	2
font_name	equ	4
lo_ASCII	equ	36
hi_ASCII	equ	38
rel_dists	equ	40
char_wid	equ	50
cell_wid	equ	52
linker_off	equ	54
right_off	equ	56
thickening	equ	58
lightening	equ	62
skewing		equ	64
font_flags	equ	66
horiz_off	equ	68
char_off_tab	equ	72
font_data	equ	76
form_wid	equ	80
form_height	equ	82
next_font	equ	84




