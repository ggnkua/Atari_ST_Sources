;----------------------------------------------------------------------------
;File name:	RA_LA.I				Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1992.11.30
;(c)1992 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Symbol & Macro library for line_A operations
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_LA_defined
RA_LA_defined	set	1
;----------------------------------------------------------------------------
	include	RA_SYS.I
	include	RA_STRUC.I
;----------------------------------------------------------------------------
;	High level library macros
;_a_char	char,x,y
;_a_text	string_ad,x,y
;
;NB: Use "make _a_links" to include all referred code
;----------------------------------------------------------------------------
;	Line_a opcode macros:
;
;_a_init
;_a_put_pixel
;_a_get_pixel
;_a_line
;_a_hline
;_a_bar		= 	_a_recfl
;_a_pline
;_a_bitblt
;_a_textblt
;_a_show_c	or	_a_showm
;_a_hide_c	or	_a_hidem
;_a_form
;_a_undraw
;_a_draw
;_a_cpyfm
;_a_contour
;
;linea #n	;special concession to DS_DRAIN
;----------------------------------------------------------------------------
;	Line-A opcodes
;
la_op_init	= $a000
la_op_put_pixel	= $a001
la_op_get_pixel	= $a002
la_op_line	= $a003
la_op_hline	= $a004
la_op_recfl	= $a005
la_op_pline	= $a006
la_op_bitblt	= $a007
la_op_textblt	= $a008
la_op_show_c	= $a009
la_op_hide_c	= $a00a
la_op_form	= $a00b
la_op_undraw	= $a00c
la_op_draw	= $a00d
la_op_cpyfm	= $a00e
la_op_contour	= $a00f	;(post TOS 1.0)
;
;	Alternative opcode names
;
la_op_putpix	= $a001
la_op_getpix	= $a002
la_op_abline	= $a003
la_op_habline	= $a004
la_op_rectfill	= $a005
la_op_polyfill	= $a006
la_op_showm	= $a009
la_op_showcur	= $a009
la_op_hidem	= $a00a
la_op_hidecur	= $a00a
la_op_chgcur	= $a00b
la_op_unsprite	= $a00c
la_op_drsprite	= $a00d
la_op_copyrstr	= $a00e
la_op_seedfill	= $a00f	;(post TOS 1.0)
;----------------------------------------------------------------------------
;	BITBLT data structure (for ptr in a6)
;
	struct	blt_struct
	d_w	blt_b_wd	;00 block width  [Pixels]
	d_w	blt_b_ht	;02 block height [Pixels]
	d_w	blt_plane_ct	;04 bit planes
	d_w	blt_fg_col	;06 foreground colour
	d_w	blt_bg_col	;08 background colour
	char	blt_op_tab,4	;10 4 blitter opcodes
;
	d_w	blt_s_xmin	;14 source X offset within form [Pixels]
	d_w	blt_s_ymin	;16 source Y offset within form [Pixels]
	d_l	blt_s_form	;18 source form base address
	d_w	blt_s_nxwd	;22 offset between words of a plane  [Bytes]
	d_w	blt_s_nxln	;24 offset between source lines      [Bytes]
	d_w	blt_s_nxpl	;26 offset between source bit planes [Bytes]
;
	d_w	blt_d_xmin	;28 dest X offset within form [Pixels]
	d_w	blt_d_ymin	;30 dest Y offset within form [Pixels]
	d_l	blt_d_form	;32 dest form base address
	d_w	blt_d_nxwd	;36 offset between words of a plane [Bytes]
	d_w	blt_d_nxln	;38 offset between dest lines       [Bytes]
	d_w	blt_d_nxpl	;40 offset between dest bit planes  [Bytes]
;
	d_l	blt_p_addr	;42 source mask pattern address (0=unused) *1
	d_w	blt_p_nxln	;46 offset between pattern lines [2^x Bytes]
	d_w	blt_p_nxpl	;48 offset between pattern bit planes [Bytes]
	d_w	blt_p_mask	;50 pattern index mask [(2^x)*(2^y)-1]
;
	char	blt_work,24	;52 work area for BITBLT routines
	d_alias	blt_size	;"blt_" structure size = 76 Bytes
	d_end	blt_struct
;----------------------------------------------------------------------------
;	Line-A Variables
;
la_cur_font	= -$38A	;->
;-$386 .. -$359 are reserved
la_m_pos_hx	= -$358	;w
la_m_pos_hy	= -$356	;w
la_m_planes	= -$354	;w
la_m_cdb_bg	= -$352	;w
la_m_cdb_fg	= -$350	;w
la_mask_form	= -$34e	;w*32
la_inq_tab	= -$30e	;w*45
;
la_inq_bgcolours= -$30C	;w
la_inq_bgcolors	= -$30C	;w
;
la_inq_planes	= -$306	;w
la_inq_lookup_f	= -$304	;w
la_inq_op_speed	= -$302	;w
;
la_dev_tab	= -$2b4	;w*45
la_workout	= -$2B4	;w*45
la_wk_xmax	= -$2B4	;w
la_wk_ymax	= -$2B2	;w
la_wk_coord_f	= -$2B0	;w
la_wk_pixwidth	= -$2AE	;w
la_wk_pixheight	= -$2AC	;w
la_wk_t_sizes	= -$2AA	;w
la_wk_l_types	= -$2A8	;w
la_wk_l_widths	= -$2A6	;w
la_wk_m_types	= -$2A4	;w
la_wk_m_sizes	= -$2A2	;w
la_wk_t_fonts	= -$2A0	;w
la_wk_f_p_pats	= -$29E	;w
la_wk_f_l_pats	= -$29C	;w
la_wk_maxcolours= -$29A	;w
la_wk_maxcolors	= -$29A	;w
la_wk_palregs	= -$29A	;w
;
la_wk_colour_f	= -$26E
la_wk_color_f	= -$26E
;
la_wk_palcolours= -$266	;w
la_wk_palcolors	= -$266	;w
la_wk_palvalues	= -$266	;w
;
la_gcurx	= -$25a	;w
la_gcury	= -$258	;w
la_m_hid_ct	= -$256	;w
la_mouse_bt	= -$254	;w
la_req_col	= -$252	;w*3*16
la_siz_tab	= -$1f2	;w*15
;-$1d4 .. -$1d1 are reserved
la_cur_work	= -$1d0	;->
la_def_font	= -$1cc	;->
;
la_font_ring	= -$1c8	;->*4
la_font_gdos	= -$1c0	;->
;
la_font_count	= -$1b8	;w
;-$1b6 .. -$15d are reserved
la_cur_ms_stat	= -$15c	;b
;-$15b is reserved
la_v_hid_cnt	= -$15a	;w
la_cur_x	= -$158	;w
la_cur_y	= -$156	;w
la_cur_flag	= -$154	;b
la_mouse_flag	= -$153	;b
;-$152 .. -$14f	are reserved
la_v_sav_xy	= -$14e	;w*2
la_save_len	= -$14a	;w
la_save_addr	= -$148	;->
la_save_stat	= -$144	;w
la_save_area	= -$142	;b*256
la_user_tim	= -$42	;->
la_next_tim	= -$3e	;->
la_user_but	= -$3a	;->
la_user_cur	= -$36	;->
la_user_mot	= -$32	;->
la_v_cel_ht	= -$2E	;w
la_v_cel_mx	= -$2C	;w
la_v_cel_my	= -$2A	;w
la_v_cel_wr	= -$28	;w
la_v_col_bg	= -$26	;w
la_v_col_fg	= -$24	;w
la_v_cur_ad	= -$22	;w
la_v_cur_of	= -$1E	;w
;
la_v_cur_xy	= -$1C	;w*2
la_v_cur_x	= -$1C	;w
la_v_cur_y	= -$1A	;w
;
la_v_period	= -$18	;b
la_v_cur_ct	= -$17	;b
la_v_fnt_ad	= -$16	;->
la_v_fnt_nd	= -$12	;w
la_v_fnt_st	= -$10	;w
la_v_fnt_wd	= -$0e	;w
la_v_rez_hz	= -$0C	;w
la_v_off_ad	= -$0a	;->
;-$06 .. -$05 are reserved
la_resv_n_1	= -$06
la_v_rez_vt	= -$04	;w
la_bytes_lin	= -$02	;w
la_planes	= $00	;w
la_width	= $02	;w
;
la_vdipb	= $04	;->*5
la_contrl_p	= $04	;->
la_intin_p	= $08	;->
la_ptsin_p	= $0C	;->
la_intout_p	= $10	;->
la_ptsout_p	= $14	;->
;
la_colbit0	= $18	;w
la_colbit1	= $1A	;w
la_colbit2	= $1C	;w
la_colbit3	= $1E	;w
la_lstlin	= $20	;w
la_lnmask	= $22	;w
la_wmode	= $24	;w
la_x1		= $26	;w
la_y1		= $28	;w
la_x2		= $2A	;w
la_y2		= $2C	;w
la_patptr	= $2E	;l
la_patmsk	= $32	;w
la_mfill	= $34	;w
la_clip		= $36	;w
;
la_cliprect	= $38	;w*4
la_xmincl	= $38	;w
la_ymincl	= $3a	;w
la_xmaxcl	= $3c	;w
la_ymaxcl	= $3e	;w
;
la_xdda		= $40	;w
la_ddainc	= $42	;w
la_scaldir	= $44	;w
la_mono		= $46	;w
la_sourcex	= $48	;w
la_sourcey	= $4a	;w
la_destx	= $4c	;w
la_desty	= $4e	;w
la_delx		= $50	;w
la_dely		= $52	;w
la_fbase	= $54	;->
la_fwidth	= $58	;w
la_style	= $5a	;w
la_litemask	= $5c	;w
la_skewmask	= $5e	;w
la_weight	= $60	;w
la_roff		= $62	;w
la_loff		= $64	;w
la_scale	= $66	;w
la_chup		= $68	;w
la_textfg	= $6a	;w
la_scrtchp	= $6c	;->
la_scrpt2	= $70	;w
la_textbg	= $72	;w
la_copytran	= $74	;w
la_seedabort	= $76	;-> (post TOS 1.0)
;
la_curblit_tb	= $7A
la_lk_scroller	= $7E	;-> scroll routine
la_lk_scrollend	= $82	;-> jump destination when scroll done
la_actblit_p	= $A2	;-> hard blitter link table
la_pasblit_p	= $A6	;-> soft blitter link table
la_blitstate	= $AA	;.w blitter active=3, passive=2, absent=0
;----------------------------------------------------------------------------
;	Line-A macros
;
_a_init	macro
	dc.w	la_op_init
	endm
;
_a_put_pixel	macro
	dc.w	la_op_put_pixel
	endm
;
_a_get_pixel	macro
	dc.w	la_op_get_pixel
	endm
;
_a_line	macro
	dc.w	la_op_line
	endm
;
_a_hline	macro
	dc.w	la_op_hline
	endm
;
_a_recfl	macro
	dc.w	la_op_recfl
	endm
;
_a_bar	macro
	dc.w	la_op_recfl
	endm
;
_a_pline	macro
	dc.w	la_op_pline
	endm
;
_a_bitblt	macro
	dc.w	la_op_bitblt
	endm
;
_a_textblt	macro
	dc.w	la_op_textblt
	endm
;
_a_show_c	macro
	dc.w	la_op_show_c
	endm
;
_a_showm	macro
	dc.w	la_op_showm
	endm
;
_a_hide_c	macro
	dc.w	la_op_hide_c
	endm
;
_a_hidem	macro
	dc.w	la_op_hidem
	endm
;
_a_form	macro
	dc.w	la_op_form
	endm
;
_a_undraw	macro
	dc.w	la_op_undraw
	endm
;
_a_draw	macro
	dc.w	la_op_draw
	endm
;
_a_cpyfm	macro
	dc.w	la_op_cpyfm
	endm
;
_a_contour	macro
	dc.w	la_op_contour	;(post TOS 1.0)
	endm
;
linea	macro	funcnum
	ifc	'#0','\1'
	dc.w	$a000
	endc
	ifc	'#1','\1'
	dc.w	$a001
	endc
	ifc	'#2','\1'
	dc.w	$a002
	endc
	ifc	'#3','\1'
	dc.w	$a003
	endc
	ifc	'#4','\1'
	dc.w	$a004
	endc
	ifc	'#5','\1'
	dc.w	$a005
	endc
	ifc	'#6','\1'
	dc.w	$a006
	endc
	ifc	'#7','\1'
	dc.w	$a007
	endc
	ifc	'#8','\1'
	dc.w	$a008
	endc
	ifc	'#9','\1'
	dc.w	$a009
	endc
	ifc	'#10','\1'
	dc.w	$a00a
	endc
	ifc	'#11','\1'
	dc.w	$a00b
	endc
	ifc	'#12','\1'
	dc.w	$a00c
	endc
	ifc	'#13','\1'
	dc.w	$a00d
	endc
	ifc	'#14','\1'
	dc.w	$a00e
	endc
	ifc	'#15','\1'
	dc.w	$a00f
	endc
	endm
;----------------------------------------------------------------------------
;	High level macros
;----------------------------------------------------------------------------
_a_links	macro
	_unidef	_a_t_init
	_unidef	_a_t_sfont,_a_t_sstyle
	_unidef	_a_t_sclip,_a_t_sscale
	_unidef	_a_t_colour
	_unidef	_a_t_text
	endm	;_a_links
;------------------------------------
_a_t_init	macro
	_uniref	_a_t_init
	pea	_a_t_init_code
	move	#$26,-(sp)
	trap	#14
	endm	;_a_t_init
;------------------------------------
_a_t_init_code	macro
	move.l	#'MagX',d1
	clr.l	d2
	move.l	(_cookies).w,d0
	beq.s	.store_cook_f
	move.l	d0,a0
.loop:
	tst.l	(a0)
	beq.s	.store_cook_f
	cmp.l	(a0),d1
	addq	#8,a0
	bne.s	.loop
	moveq	#-1,d2
.store_cook_f:
	clr.l	d1
	move	d2,_a_t_magx_f
	beq.s	.store_cook_v
	move.l	-4(a0),d1
.store_cook_v:
	move.l	d1,_a_t_magx_p
	move.l	d0,a0
	suba.l	a2,a2
	dc.w	la_op_init
	cmp	#0,a2
	sne	_a_t_modern_f
	bne.s	.exit
	lea	-15*4(a1),a2
.exit:
	movem.l	a0-a2,line_a_p
	move.l	8*4(a2),_a_t_text_call+2
	rts
;;;
_a_t_modern_f:	dc.w	0
line_a_p:	dc.l	0,0,0
;;;
_a_t_magx_f:	dc.w	0
_a_t_magx_p:	dc.l	0
;;;
_a_t_magx_fix_t:
		dc.w	00,02,03,06,04,07,05,08	;low-rez vdi colours
		dc.w	09,10,11,14,12,15,13,01
;;;
		dc.w	00,02,03,01,00,02,03,01	;mid-rez vdi colours
		dc.w	00,02,03,01,00,02,03,01
;;;
_a_t_ones:	dc.l	-1
_a_t_font_p:	dc.l	0
_a_t_chrw:	dc.w	0
;;;
_a_t_wmode:	dc.w	0
_a_t_clip:	dc.w	0
_a_t_xmincl:	dc.w	0
_a_t_ymincl:	dc.w	0
_a_t_xmaxcl:	dc.w	0
_a_t_ymaxcl:	dc.w	0
_a_t_ddainc:	dc.w	0
_a_t_scaldir:	dc.w	0
_a_t_delx:	dc.w	0
_a_t_dely:	dc.w	0
_a_t_destx:	dc.w	0
_a_t_desty:	dc.w	0
_a_t_style:	dc.w	0
_a_t_scale:	dc.w	0
_a_t_scrtchp:	dc.l	_a_t_buff_1
_a_t_scrpt2:	dc.w	_a_t_buff_2-_a_t_buff_1
;;;
_a_t_buff_1:	ds.b	1024
_a_t_buff_2:	ds.b	1024
	endm	;_a_t_init_code
;------------------------------------
_a_t_rotate	macro
	move.l	line_a_p(pc),a0
	move	d0,la_chup(a0)
	endm	;_a_t_rotate
;------------------------------------
_a_t_smode	macro
	move	d0,_a_t_wmode
	endm	;_a_t_smode
;------------------------------------
_a_t_colour	macro
	_uniref	_a_t_colour
	bsr	_a_t_colour_code
	endm	;_a_t_colour
;------------------------------------
_a_t_colour_code	macro
	_debdef	_a_t_colour_code,3
	move.l	line_a_p(pc),a0
	move	d1,la_textbg(a0)	;text background
	move	d0,la_textfg(a0)	;text foreground
	beq.s	.exit			;textfg = 0 is valid in all systems
	tst	_a_t_magx_f
	beq.s	.exit			;avoid bugfix if magix absent
	cmp	#16,d0
	bhs.s	.exit			;skip bugfix for colours > 15
	movem.l	d2/a1,-(sp)
	move	la_planes(a0),d2
	cmp	#8,d2
	bhi.s	.done_magx_fix		;refuse bugfix on truecolour
	cmp	#2,d2
	blo.s	.done_magx_fix		;exit bugfix in monochrome mode
	lea	_a_t_magx_fix_t(pc),a1	;a1 -> bugfix table for non-ST_medium
	bne.s	.do_magx_fix		;go fix colour for ST_low or TT_medium/_low
	lea	16*2(a1),a1		;a0 -> bugfix table for ST_medium
.do_magx_fix:
	move	d0,d2
	add	d2,d2
	move	(a1,d2),la_textfg(a0)	;change fgc to vdi code for MagiX
.done_magx_fix:
	movem.l	(sp)+,d2/a1
.exit:
	rts
	endm	_a_t_colour_code
;------------------------------------
_a_t_sfont	macro
	_uniref	_a_t_sfont
	bsr	_a_t_sfont_code
	endm	;_a_t_sfont
;------------------------------------
_a_t_sfont_code	macro
;;;d0 -> font header, or is null or negative to use last font
	_debdef	_a_t_sfont_code,3
	tst.l	d0
	bgt.s	.use_d0_font
	move.l	_a_t_font_p(pc),d0
.use_d0_font:
	move.l	d0,_a_t_font_p
	move.l	d0,a2
	move.l	line_a_p(pc),a0
	move	fnt_cellw(a2),_a_t_delx
	move	fnt_fheight(a2),_a_t_dely
	move.l	fnt_fbase(a2),la_fbase(a0)
	move	fnt_fwidth(a2),la_fwidth(a0)
	move	fnt_litemask(a2),la_litemask(a0)
	move	fnt_skewmask(a2),la_skewmask(a0)
	move	fnt_weight(a2),la_weight(a0)
	clr.l	d1
	move	_a_t_style(pc),d0
	btst	#2,d0
	beq.s	.know_italic
	move.l	fnt_loff(a2),d1
	swap	d1
.know_italic:
	move.l	d1,la_roff(a0)				;roff, loff
	move	_a_t_delx(pc),d1
	btst	#4,d0
	beq.s	.know_outline
	addq	#2,d1
.know_outline:
	move	d1,_a_t_chrw
	btst	#3,fnt_flag+1(a2)
	sne	d0
	and	#1,d0
	move	d0,la_mono(a0)				;mono
	move.l	_a_t_scrtchp(pc),la_scrtchp(a0)		;scrtchp
	move	_a_t_scrpt2(pc),la_scrpt2(a0)		;scrpt2
	rts
	endm	;_a_t_sfont_code
;------------------------------------
_a_t_sstyle	macro
	_uniref	_a_t_sstyle
	bsr	_a_t_sstyle_code
	endm	;_a_t_sstyle
;------------------------------------
_a_t_sstyle_code	macro
;;;d0 = style, or negative to use last style
	_debdef	_a_t_sstyle_code,3
	move.l	_a_t_font_p(pc),a2
	move.l	line_a_p(pc),a0
	tst	d0
	bpl.s	.use_d0_style
	move	_a_t_style(pc),d0
.use_d0_style:
	move	d0,_a_t_style
	move	d0,la_style(a0)			;style
	clr.l	d1
	btst	#2,d0
	beq.s	.know_italic
	move.l	fnt_loff(a2),d1
	swap	d1
.know_italic:
	move.l	d1,la_roff(a0)			;roff, loff
	move	_a_t_delx(pc),d1
	btst	#4,d0
	beq.s	.know_outline
	addq	#2,d1
.know_outline:
	move	d1,_a_t_chrw
	rts
	endm	;_a_t_sstyle_code
;------------------------------------
_a_t_sclip	macro
	_uniref	_a_t_sclip
	bsr	_a_t_sclip_code
	endm	;_a_t_sclip
;------------------------------------
_a_t_sclip_code	macro
;;;d0=0 for no clip, negative to reuse last clip, or x.y of new clip
;;;d1=w.h for a new clip
	_debdef	_a_t_sclip_code,3
	move.l	line_a_p(pc),a0
	tst.l	d0
	beq.s	.no_clip
	bmi.s	.use_clip
.new_clip:
	add	d0,d1
	subq	#1,d1
	swap	d0
	swap	d1
	add	d0,d1
	subq	#1,d1
	swap	d0
	swap	d1
	movem.l	d0/d1,_a_t_xmincl
.use_clip:
	move	#1,_a_t_clip
	move	#1,la_clip(a0)
	move.l	_a_t_xmincl(pc),la_xmincl(a0)	;xmincl, ymincl
	move.l	_a_t_xmaxcl(pc),la_xmaxcl(a0)	;xmaxcl, ymaxcl
	rts
;;;
.no_clip:
	clr	_a_t_clip
	clr	la_clip(a0)
	rts
	endm	;_a_t_sclip_code
;------------------------------------
_a_t_sscale	macro
	_uniref	_a_t_sscale
	bsr	_a_t_sscale_code
	endm	;_a_t_sscale
;------------------------------------
_a_t_sscale_code	macro
;;;d0=0 for no scaling, negative for old scaling, or ddainc value for new scaling
;;;d1=scaldir for new scaling
	_debdef	_a_t_sscale_code,3
	move.l	line_a_p(pc),a0
	tst.l	d0
	beq.s	.no_scale
	bmi.s	.use_scale
.new_scale:
	move	d0,_a_t_ddainc
	move	d1,_a_t_scaldir
.use_scale:
	move	#1,_a_t_scale
	move	#1,la_scale(a0)
	move.l	_a_t_ddainc(pc),la_ddainc(a0)	;ddainc, scaldir
	rts
;;;
.no_scale:
	clr	_a_t_scale
	clr	la_scale(a0)
	rts
	endm	;_a_t_sscale_code
;------------------------------------
_a_t_text	macro
	_uniref	_a_t_text
	bsr	_a_t_text_code
	endm	;_a_t_text
;------------------------------------
_a_t_text_code	macro
;;; d0 = string length   a0 -> string
	_debdef	_a_t_text_code,3
	movem.l	d3-d7/a3-a5,-(sp)
	move	d0,d5
	move.l	a0,a5
	subq	#1,d5
	blt	_a_t_text_exit
	move.l	line_a_p(pc),a0
	move	_a_t_wmode(pc),la_wmode(a0)	;wmode
	move	#$8000,la_xdda(a0)
	move.l	_a_t_font_p(pc),a1
	move	fnt_lasc(a1),d4
	move.l	fnt_chr_tp(a1),a4
	move	_a_t_dely(pc),la_dely(a0)
	move	_a_t_desty(pc),la_desty(a0)	;destx, desty
_a_t_text_loop:
	move.l	line_a_p(pc),a0
	move.l	_a_t_destx(pc),la_destx(a0)	;destx, desty
	move	_a_t_chrw(pc),d0
	add	d0,_a_t_destx
	clr	d0
	move.b	(a5)+,d0
	cmp	#' ',d0
	bne.s	.visible
	dbra	d5,_a_t_text_loop
	bra.s	_a_t_text_done
;
.visible:
	sub	d4,d0
	add	d0,d0
	move	0(a4,d0),d1
	move	2(a4,d0),d2
	sub	d1,d2
	move	d1,la_sourcex(a0)
	clr	la_sourcey(a0)
	move	d2,la_delx(a0)
	movem.l	d4-d5/a4-a5,-(sp)
_a_t_text_call:
	jsr	($C0DE).l		;patched by _a_t_init for _a_textblt sub
	movem.l	(sp)+,d4-d5/a4-a5
	dbra	d5,_a_t_text_loop
_a_t_text_done:
	move.l	line_a_p(pc),a0
	move	la_destx(a0),_a_t_destx
_a_t_text_exit:
	movem.l	(sp)+,d3-d7/a3-a5
	rts
	endm	;_a_t_text_code
;----------------------------------------------------------------------------
	endc	;RA_LA_defined
;----------------------------------------------------------------------------
;End of file:	RA_LA.I
;----------------------------------------------------------------------------
