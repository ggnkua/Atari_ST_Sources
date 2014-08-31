; ----------------------------------------------------------------------------
; File name:	TermWin.S		Revision date:  1995.07.27
; Created by:	Ulf Ronald Andersson	Creation date:  1993.04.02
; ----------------------------------------------------------------------------
; Version:	1.03
; ----------------------------------------------------------------------------
; File purpose:	Assembler source code for a library of functions that
;		implement terminal handling (VT_52 etc.) for GEM windows.
;
; ----------------------------------------------------------------------------
; Copyright:	(c)1993 by Ulf Ronald Andersson
;
;		Release terms are given in the file TermWin.Doc,
;		which must always accompany other TermWin files.
;
; ----------------------------------------------------------------------------
; Comments:	This is a support library for any ST programming language,
;		and includes URAn_GFA.S to adapt all argument processing.
;
; ----------------------------------------------------------------------------
;
	include	URAn_DOS.S
	include	URAn_KEY.S
	include	URAn_LA.S
	include	URAn_GEM.S
	include	URAn_GFA.S
;
; ----------------------------------------------------------------------------
;
rectsize	=	32	;tw_lock GRECTS to be buffered per terminal
capbsize	=	4096	;size of capture buffer per terminal
;
; ----------------------------------------------------------------------------
;
	dc.b	'TermWin  Version 1.00  Created in December 1993',CR,LF
	dc.b	'(C)1993 Ulf Ronald Andersson.  All rights reserved.',CR,LF
	dc.b	'Released for use in programs by registered authors.',CR,LF
	dc.b	NUL
	even
;
; ----------------------------------------------------------------------------
;
;       Here begins the code of the "TermWin" library
;	starting with some GEM subroutines and data
;
	_uniref	sub_aes
	_uniref	sub_vdi
	make	GEM_links
;
contrl:	ds.w	12
intin:	ds.w	128
intout:	ds.w	64
ptsin:	ds.w	32
ptsout:	ds.w	16
;
; ----------------------------------------------------------------------------
;	The data structure below is used for individual window data.
;	"tw_init" Malloc's an area holding one such structure for each
;	window to have a terminal window interface.
;
	rsreset
tw_wind_o	rs.w	1	;0     ;&== GEM handle for the window
tw_cols_o	rs.w	1	;2     ;&== columns per row (may exceed window size)
tw_rows_o	rs.w	1	;4     ;&== rows in buffer (may exceed window size)
tw_scol_o	rs.w	1	;6     ;&== start column for window display
tw_srow_o	rs.w	1	;8     ;&== start row for window display
tw_vcol_o	rs.w	1	;10    ;&== visible columns in window
tw_vrow_o	rs.w	1	;12    ;&== visible rows in window
tw_ccol_o	rs.w	1	;14    ;&== cursor column
tw_crow_o	rs.w	1	;16    ;&== cursor row
tw_attr_o	rs.w	1	;18    ;&== current text attributes
tw_colr_o	rs.w	1	;20    ;&== current text colours  (foreground*16+background)
tw_stix_o	rs.w	1	;22    ;&== VT_52 cursor stack index
tw_escf_o	rs.b	1	;24    ;|== byte counter for escape sequence
tw_esc1_o	rs.b	1	;25    ;|== primary escape code
tw_esc2_o	rs.b	1	;26    ;|== secondary escape code (first argument)
tw_esc3_o	rs.b	1	;27    ;|== tertiary escape code (second argument)
tw_txtp_o	rs.l	1	;28    ;%-> buffer for window text data
tw_attp_o	rs.l	1	;32    ;%-> buffer for window text attributes
tw_colp_o	rs.l	1	;36    ;%-> buffer for window text colours
tw_stkp_o	rs.l	1	;40    ;%-> buffer for VT_52/ANSI stack operations
tw_wrkx_o	rs.w	1	;44    ;&== window pixel x coordinate
tw_wrky_o	rs.w	1	;46    ;&== window pixel y coordinate
tw_wrkw_o	rs.w	1	;48    ;&== window pixel width
tw_wrkh_o	rs.w	1	;50    ;&== window pixel height
tw_type_o	rs.w	1	;52    ;&== terminal protocol type for window
tw_fntp_o	rs.l	1	;54    ;%== font number or font pointer for window
tw_altx_o	rs.w	1	;58    ;\
tw_alty_o	rs.w	1	;60    ; \/ 'Altered full' window settings
tw_altw_o	rs.w	1	;62    ; /\ for "Fulled", "Sized" & "Moved"
tw_alth_o	rs.w	1	;64    ;/
tw_refx_o	rs.w	1	;66    ;\
tw_refy_o	rs.w	1	;68    ; \/ 'Reference' window settings
tw_refw_o	rs.w	1	;70    ; /\ for "Fulled", "Sized" & "Moved"
tw_refh_o	rs.w	1	;72    ;/
tw_orgx_o	rs.w	1	;74    ;\
tw_orgy_o	rs.w	1	;76    ; \/ 'Original' window settings
tw_orgw_o	rs.w	1	;78    ; /\ for "Closed"
tw_orgh_o	rs.w	1	;80    ;/
tw_fpts_o	rs.w	1	;82  character size (in gdos "points")
tw_yoff_o	rs.w	1	;84  character Y offset
tw_chrw_o	rs.w	1	;86  character width
tw_chrh_o	rs.w	1	;88  character height
tw_gads_o	rs.w	1	;90  gadgets of window
tw_char_o	rs.w	1	;92  curr o/p character
tw_mclr_o	rs.w	1	;94  maximal colour for terminal window
tw_cdif_o	rs.w	1	;96  colour difference enforcing flag
tw_hide_o	rs.w	1	;98  cursor hide counter  (0=visible)
tw_rold_o	rs.w	1	;100 screen roll director (direction*pixels)
tw_barx_o	rs.w	1	;102 hor scroll bar position
tw_bary_o	rs.w	1	;104 ver scroll bar position
tw_barw_o	rs.w	1	;106 hor scroll bar size
tw_barh_o	rs.w	1	;108 ver scroll bar size
tw_lock_o	rs.w	1	;110 flags window update mode
tw_lkpt_o	rs.l	1	;112 -> rectangle buffer
tw_lnsz_o	rs.w	1	;114 line size (padded to x*4)
tw_stat_o	rs.w	1	;116 lock status bits
tw_csit_o	rs.w	9	;118 ANSI CSI sequence value table
tw_http_o	rs.l	1	;136 -> horizontal tabulation table
tw_tops_o	rs.w	1	;140 top row of ANSI scroll region
tw_bots_o	rs.w	1	;142 bottom row of ANSI scroll region
tw_capm_o	rs.w	1	;144 capture mode: 0=off <256=ASCII 256=total
tw_caph_o	rs.w	1	;146 capture file handle
tw_capb_o	rs.l	1	;148 -> capture buffer
tw_capi_o	rs.l	1	;152 capture buffer index
tw_caps_o	rs.l	1	;156 capture buffer size
tw_atac_o	rs.w	1	;160 IBM colouring flag (reverses black/white)
tw_sizl_o	rs.w	1	;162 flags window size limitations
tw_resp_o	rs.l	1	;164 -> terminal response string, unless null
tw_resv_o	rs.b	256-__RS
tw_ends_o	=	__RS	;256 so	;\/ struct(tw_hand) at {tw_link_p+tw_hand*tw_ends_o}
tw_lpow		=	8	; and	;/\ struct(tw_hand) at {tw_link_p+(tw_hand<<tw_lpow)}
;
	ifne	tw_ends_o>(1<<tw_lpow)
	FAIL	'Time to extend terminal structure !!!'
	endc
;
; ----------------------------------------------------------------------------
;	Some global data is defined here:
;
tw_ssp_save:	dc.l	0
;
tw_limtype:	dc.w	6	;number of implemented terminal protocol types
	_debdef	tw_limtype,1
tw_null_l:	dc.l	0
tw_ones_l:	dc.l	-1
tw_link_p:	dc.l	-1
tw_limit:	dc.w	-1
	_debdef	tw_limit,1
tw_wshand:	dc.w	0
	_debdef	tw_wshand,1
;
tw_planes:	dc.w	0
	_debdef	tw_planes,1
tw_bytes_lin:	dc.w	0
tw_nxwd_w:	dc.w	0
tw_nxln_w:	dc.w	0
tw_nxpl_w:	dc.w	0
;
; two structures are used for line_A BITBLT parameters
;
tw_bltm_t:	ds.b	blt_size
tw_bltf_t:	ds.b	blt_size
;
; some arrays are used to translate bios colours to gem codes
; truecolour or TT-low codes are translated the same way
;
	_debdef	xbios_col_t,1
xbios_col_t:	ds.w	16
	_debdef	vdi_col_t,1
vdi_col_t:	ds.w	16
	_debdef	vt52_ibmc_t,1
vt52_ibmc_t:	ds.w	16

;
xbios_izcol_t:
	_debdef	xbios_izcol_t,1
;
	dc.w	1,0,1,0,1,0,1,0		;high	= 1 bit plane
	dc.w	1,0,1,0,1,0,1,0
;
	dc.w	3,1,2,1,2,1,2,0		;medium	= 2 bit planes
	dc.w	3,1,2,1,2,1,2,0
;
	dc.w	15,09,10,11,12,13,14,07	;low	= 4 bit planes
	dc.w	08,01,02,03,04,05,06,00
;
	dc.w	15,09,10,11,12,13,14,07	;TT low	= 8 bit planes
	dc.w	08,01,02,03,04,05,06,00
;
vdi_izcol_t:
	_debdef	vdi_izcol_t,1
;
	dc.w	1,0,1,0,1,0,1,0		;high	= 1 bit plane
	dc.w	1,0,1,0,1,0,1,0
;
	dc.w	1,2,3,2,3,2,3,0		;medium	= 2 bit planes
	dc.w	1,2,3,2,3,2,3,0
;
	dc.w	01,10,11,14,12,15,13,08	;low	= 4 bit planes
	dc.w	09,02,03,06,04,07,05,00
;
	dc.w	01,10,11,14,12,15,13,08	;TT low	= 8 bit planes
	dc.w	09,02,03,06,04,07,05,00
;
vt52_izibmc_t:
	_debdef	vdi_izcol_t,1
;
	dc.w	1,0,1,0,1,0,1,0		;high	= 1 bit plane
	dc.w	1,0,1,0,1,0,1,0
;
	dc.w	3,1,2,0,3,1,2,0		;medium	= 2 bit planes
	dc.w	3,1,2,0,3,1,2,0
;
	dc.w	15,01,02,03,04,05,06,07	;low	= 4 bit planes
	dc.w	08,09,10,11,12,13,14,00
;
	dc.w	15,01,02,03,04,05,06,07	;low	= 4 bit planes
	dc.w	08,09,10,11,12,13,14,00
;
truecol_t:	ds.w	16
	_debdef	truecol_t,1
;
	dc.w	$0000,$6000,$0300,$6300
	dc.w	$0018,$6018,$0318,$6318
	dc.w	$318C,$7D08,$23E8,$7FE8
	dc.w	$211F,$7D1F,$23FF,$7FFF
;
; ----------------------------------------------------------------------------
;
;	Here begins the segment of data and routines
;	that can be accessed from the main application
;
; ----------------------------------------------------------------------------
; Some global arrays are used for screen rectangle data
;
tw_full:	ds.w	4	;max outer rectangle of entire screen
tw_work:	ds.w	4	;max outer rectangle of screen work area
tw_cent:	ds.w	4	;center spot of screen work area
tw_smax:	ds.w	4	;max inner rectangle of win_create window
;
; Some globals are available to the calling program
;
	XDEF	tw_full
	XDEF	tw_work
	XDEF	tw_cent
	XDEF	tw_smax
;
; ----------------------------------------------------------------------------
;
	XDEF	tw_init		;long	tw_init(W tw_lim,W wshand,L gl_p)
;
; This is the main terminal initialization routine, which must be called
; before any other of the library routines may be used.
; It will Malloc the RAM needed to open terminal interfaces.
;
tw_init:
	gfafunc	8,wwl
	link	a6,#0
	tst.l	tw_link_p
	bgt	exit_err_1	;refuse double init's
;
	move.l	12(a6),aespb+4		;Address of the program's global array
	move	10(a6),tw_wshand	;The program's VDI workstation handle
	move	8(a6),tw_limit		;This limits the number of terminals
;
;	initialize some rez_dependent variables using line_A
;
	bsr	rc_init
	_a_t_init
;
	moveq	#5-1,d2
	lea	intern_fnt_t(pc),a2
.iz_intern_fnt:
	move.l	(a2)+,a1
	move.l	a1,d0
	add.l	d0,fnt_hor_tp(a1)
	add.l	d0,fnt_chr_tp(a1)
	add.l	d0,fnt_fbase(a1)
	dbra	d2,.iz_intern_fnt
;
	_a_init
	moveq	#4,d0
	cmp	#8,la_v_cel_ht(a0)
	bhi.s	.iz_font
	moveq	#3,d0
	cmp	#8,la_v_cel_ht(a0)
	beq.s	.iz_font
	moveq	#2,d0
.iz_font:
	bsr	find_font
	_a_t_sfont
;
	_a_init
	move	la_bytes_lin(a0),tw_bytes_lin
	move	la_planes(a0),d0
	move	d0,tw_planes
	asl	#1,d0
	move	d0,tw_nxwd_w
	cmp	#2,d0
	sgt	d0
	and	#2,d0
	ext	d0
	move	d0,tw_nxpl_w
	move	-2(a0),tw_nxln_w
;
;	initialize table for moving blits "tw_bltm_t"
;
	lea	tw_bltm_t(pc),a1
	move.l	#$03030303,blt_op_tab(a1)
	move	tw_nxwd_w(pc),blt_s_nxwd(a1)
	move	tw_nxln_w(pc),blt_s_nxln(a1)
	move	tw_nxpl_w(pc),blt_s_nxpl(a1)
	move	tw_nxwd_w(pc),blt_d_nxwd(a1)
	move	tw_nxln_w(pc),blt_d_nxln(a1)
	move	tw_nxpl_w(pc),blt_d_nxpl(a1)
;
;	initialize table for filling blits "tw_bltf_t"
;
	lea	tw_bltf_t(pc),a1
	clr	blt_s_xmin(a1)
	clr	blt_s_ymin(a1)
	lea	tw_ones_l(pc),a2
	move.l	a2,blt_s_form(a1)
	clr	blt_s_nxwd(a1)
	clr	blt_s_nxln(a1)
	clr	blt_s_nxpl(a1)
	move	tw_nxwd_w(pc),blt_d_nxwd(a1)
	move	tw_nxln_w(pc),blt_d_nxln(a1)
	move	tw_nxpl_w(pc),blt_d_nxpl(a1)
;
	move	tw_planes(pc),d0	;rez => 1,2,4,8...
	subq	#1,d0			;rez => 0,1,3,7...
	cmp	#2,d0
	bls.s	.know_rez
	moveq	#2,d0			;rez => 0,1,2,2...
.know_rez:
	tst.b	rc_maxcolours
	beq.s	.set_col_tabs
	moveq	#3,d0
.set_col_tabs:
	lsl	#5,d0		;each subtable has 16 2_byte words
	lea	vdi_izcol_t(pc),a0
	add	d0,a0
	lea	vdi_col_t(pc),a1
	lea	xbios_izcol_t(pc),a2
	add	d0,a2
	lea	xbios_col_t(pc),a3
	moveq	#16-1,d1	;prep for 16 turns dbra loop
.col_t_loop:			;loop start to move 16 words
	move	(a0)+,(a1)+
	move	(a2)+,(a3)+
	dbra	d1,.col_t_loop	;loop back to move 16 words
	bsr	try_truecol
;
	lea	vt52_izibmc_t(pc),a0
	add	d0,a0
	lea	vt52_ibmc_t(pc),a1
	moveq	#16-1,d1
.vt52_col_t_loop:
	move	(a0)+,(a1)+
	dbra	d1,.vt52_col_t_loop
;
	gem_aes	wind_get,!,#5	;get full screen rectangle
	lea	intout+2(pc),a1
	lea	tw_full(pc),a2
	move.l	(a1)+,(a2)+	;store xmin,ymin
	move.l	(a1)+,(a2)+	;store width,height
;
	gem_aes	wind_get,!,#4	;get screen work area rectangle
	move.l	intout+2(pc),tw_work
	move.l	intout+6(pc),tw_work+4
	move	intout+6(pc),d0	;d0.w=width
	lsr	#1,d0
	add	intout+2(pc),d0	;d0.w=xmin+width/2
	swap	d0
	move	intout+8(pc),d0	;d0.w=height
	lsr	#1,d0
	add	intout+4(pc),d0	;d0.w=ymin+height/2
	move.l	d0,tw_cent	;store center x,y
	clr.l	tw_cent+4	;but force this to be an empty rectangle
;
; A global pointer "tw_link_p" is ized here, pointing to an array of data
; structures, one per "tw_" window.
;
; The RAM used for the "tw_" structures is MALLOC'ed, and _must_ be released
; by a call to "tw_exit" before the program terminates.
;
	gemdos	Malloc,?
	clr.l	d1
	move	tw_limit,d1
	move	#tw_lpow,d2
	lsl.l	d2,d1
	cmp.l	d1,d0
	blt.s	exit_err_2
	gemdos	Malloc,d1
	move.l	d0,tw_link_p		;tw_link_p = Malloc(tw_limit*2^tw_lpow)
	blt.s	exit_err_2
	move.l	d0,a2			;a2 = tw_link_p
	moveq	#-1,d0
	move	tw_limit,d2
	subq	#1,d2
.izlink_loop:
	move	d0,tw_wind_o(a2)	;mark each terminal interface unused
	add	#tw_ends_o,a2
	dbra	d2,.izlink_loop
exit_zero:
	unlk	a6
	clr.l	d0
	rts
;
exit_err_1:
	unlk	a6
	moveq	#-1,d0
	rts
;
exit_err_2:
	unlk	a6
	moveq	#-2,d0
	rts
;
;	ends tw_init
; ----------------------------------------------------------------------------
;
	XDEF	tw_exit		;void	tw_exit()
;
; This releases the memory MALLOC'ed by "tw_init", as well as all memory
; used by any "tw_" windows, not yet closed by "tw_close".
; Thereafter no "tw_" calls are legal unless preceded by a new "tw_init"
;
tw_exit:
	gfaproc
	move.l	tw_link_p(pc),d0
	ble.s	.done_exit
	move	tw_limit(pc),d0
	ble.s	.done_exit
	subq	#1,d0
.exit_loop:
	move	d0,-(sp)
	bsr	tw_i_close			;release individual terminals
	move	(sp)+,d0
	dbra	d0,.exit_loop
	gemdos	Mfree|_ind,tw_link_p(pc)	;release terminal handler RAM
.done_exit:
	moveq	#-1,d0
	move.l	d0,tw_link_p
	move	d0,tw_limit
	rts
;
;	ends tw_exit
; ----------------------------------------------------------------------------
;
	XDEF	tw_cell		;long tw_cell(L font,W satt)
;
tw_cell:
	gfafunc	6,lw
	link	a6,#0
	tst.l	8(sp)
	bge.s	.keep_font
	gem_aes	graf_handle
	move.l	intout+2(pc),d0	;d0=default character width<<16+height
	cmp	#8,d0
	blt.s	.low_font
	beq.s	.mid_font
.high_font:
	move.l	#4,8(sp)
	bra.s	.keep_font
;
.mid_font:
	move.l	#3,8(sp)
	bra.s	.keep_font
;
.low_font:
	move.l	#2,8(sp)
.keep_font:
	tst	12(sp)
	bge.s	.keep_satt
	clr	12(sp)
.keep_satt:
	move	12(sp),d0
	move.l	8(sp),d1
	move	d0,-(sp)
	move.l	d1,-(sp)
	bsr	tw_calc		;d0.l=tw_calc(d1.l,d0.w)
	addq	#6,sp
	move.l	d0,d1
	lsr	#8,d0
	swap	d0
	and	#$FF,d1
	move	d1,d0
	unlk	a6
	rts		;RETURN SHL(mix% AND &HFF00,8) OR (mix% AND &HFF)
;
;	ends tw_cell
; ----------------------------------------------------------------------------
;
	XDEF	win_create	;long win_create(W gad,L tit,L inf,W x,W y,W w,W h)
;
; Parameters x,y,w,h are for the internal work area of the window.
; This method is best, since various TOS use various border sizes.
;
; Any of these values given as -1, will be taken as default values,
; which are here considered to be those of a maximized/centered window.
; The other parameters may also use -1 to choose standard defaults,
; which are: all gadgets active with null strings;
;
; eg: handle=win_create(-1,-1,-1,-1,-1,-1,-1)
;  1:         Creates a maximized window with all gadgets and empty strings.
;
; eg: handle=win_create(50,50,-1,-1,0,0,0)
;  2:         Creates a gadget_free square window at center of screen.
;
; Requesting an area exceeding legal limits will return an error code,
; indicating faulty parameters as follows:
;
; -1  X coordinate error
; -2  Y coordinate error
; -3  width error
; -4  height error
; -5  erroneous combination of legal X coord & legal width
; -6  erroneous combination of legal Y coord & legal height
; -7  strange gadget request in gad&=&H5555 (user error request)
; -8  GEM refused to create the window
;
; The tests are made in the order shown, and the first error returned.
; The user should then try again, after adjusting his request parameters,
; except after GEM refusal due to exceeded number of windows.
;
	rsreset		;This structure gives offsets from a6 to arguments
	rs.b	8	;offset for a6 link and return address
win_gad	rs.w	1
win_tit	rs.l	1
win_inf	rs.l	1
win_x	rs.w	1
win_y	rs.w	1
win_w	rs.w	1
win_h	rs.w	1
win_win	=	-2
;
;
win_create:
	gfafunc	18,wllwwww
	link	a6,#-2
	cmp	#-1,win_gad(a6)
	bne.s	.keep_gad
	move	#$0FFF,win_gad(a6)
.keep_gad
	tst.l	win_tit(a6)
	bgt.s	.keep_tit
	move.l	#tw_null_l,win_tit(a6)
.keep_tit:
	tst.l	win_inf(a6)
	bgt.s	.keep_inf
	move.l	#tw_null_l,win_inf(a6)
.keep_inf:
	gem_aes	wind_get,!,#4
	move.l	a5,-(sp)
	lea	intout(pc),a5
	gem_aes	wind_calc,#1,win_gad(a6),2(a5),4(a5),6(a5),8(a5)
	move.l	2(a5),tw_smax		;store min x,y
	move.l	6(a5),tw_smax+4	;store max w,h
	move.l	(sp)+,a5
;
	move	win_x(a6),d0
	cmp	#-1,d0
	beq.s	.keep_x_1
	blt	exit_err_1
	move	tw_smax(pc),d1
	cmp	d1,d0
	blt	exit_err_1
	add	tw_smax+4(pc),d1
	cmp	d1,d0
	bge	exit_err_1		;err 1 = illegal x
.keep_x_1:
;
	move	win_y(a6),d0
	cmp	#-1,d0
	beq.s	.keep_y_1
	blt	exit_err_2
	move	tw_smax+2(pc),d1
	cmp	d1,d0
	blt	exit_err_2
	add	tw_smax+6(pc),d1
	cmp	d1,d0
	bge	exit_err_2		;err 2 = illegal y
.keep_y_1:
;
	move	win_w(a6),d0
	cmp	#-1,d0
	beq.s	.keep_w_1
	blt	exit_err_3
	move	tw_smax+4(pc),d1
	cmp	d1,d0
	bgt	exit_err_3		;err 3 = illegal w
.keep_w_1:
;
	move	win_h(a6),d0
	cmp	#-1,d0
	beq.s	.keep_h_1
	blt	exit_err_4
	move	tw_smax+6(pc),d1
	cmp	d1,d0
	bgt	exit_err_4		;err 4 = illegal h
.keep_h_1:
;
	tst	win_x(a6)
	bpl.s	.keep_x_2
	tst	win_w(a6)
	bpl.s	.keep_w_2
	move	tw_smax+0(pc),win_x(a6)	;\/ Max X width
	move	tw_smax+4(pc),win_w(a6)	;/\ at min X pos
	bra.s	.fixed_x_1
;
.keep_w_2:
	move	tw_smax+4(pc),d0
	sub	win_w(a6),d0
	lsr	#1,d0
	add	tw_smax+0(pc),d0
	move	d0,win_x(a6)		;Centered X pos for given width
	bra.s	.fixed_x_1
;
.keep_x_2:
	tst	win_w(a6)
	bpl.s	.keep_w_3
	move	tw_smax+0(pc),d0
	add	tw_smax+4(pc),d0
	sub	win_x(a6),d0
	move	d0,win_w(a6)		;Maximum width at given X pos
	bra.s	.fixed_x_1
;
.keep_w_3:
	move	win_x(a6),d0
	add	win_w(a6),d0
	move	tw_smax+0(pc),d1
	add	tw_smax+4(pc),d1
	cmp	d1,d0
	bgt	exit_err_5		;err 5 = illegal x+w combination
.fixed_x_1:
;
	tst	win_y(a6)
	bpl.s	.keep_y_2
	tst	win_h(a6)
	bpl.s	.keep_h_2
	move	tw_smax+2(pc),win_y(a6)	;\/ Max Y height
	move	tw_smax+6(pc),win_h(a6)	;/\ at min Y pos
	bra.s	.fixed_y_1
;
.keep_h_2:
	move	tw_smax+6(pc),d0
	sub	win_h(a6),d0
	lsr	#1,d0
	add	tw_smax+2(pc),d0
	move	d0,win_y(a6)		;Centered Y pos for given width
	bra.s	.fixed_y_1
;
.keep_y_2:
	tst	win_h(a6)
	bpl.s	.keep_h_3
	move	tw_smax+2(pc),d0
	add	tw_smax+6(pc),d0
	sub	win_y(a6),d0
	move	d0,win_h(a6)		;Maximum height at given Y pos
	bra.s	.fixed_y_1
;
.keep_h_3:
	move	win_y(a6),d0
	add	win_h(a6),d0
	move	tw_smax+2(pc),d1
	add	tw_smax+6(pc),d1
	cmp	d1,d0
	bgt	exit_err_6		;err 6 = illegal y+h combination
.fixed_y_1:
;
	cmp	#$5555,win_gad(a6)
	beq	exit_err_7		;err 7 = user_requested error
;
	gem_aes	wind_get,!,#4		;get screen work area rectangle
	move.l	intout+2(pc),tw_work
	move.l	intout+6(pc),tw_work+4
	move	intout+6(pc),d0		;d0.w=width
	lsr	#1,d0
	add	intout+2(pc),d0		;d0.w=xmin+width/2
	swap	d0
	move	intout+8(pc),d0		;d0.w=height
	lsr	#1,d0
	add	intout+4(pc),d0		;d0.w=ymin+height/2
	move.l	d0,tw_cent		;store center x,y
	clr.l	tw_cent+4		;but force this to be an empty rectangle
;
	lea	tw_smax(pc),a2
	gem_aes	wind_calc,!,win_gad(a6),0(a2),2(a2),4(a2),6(a2)
	lea	intout(pc),a2
	gem_aes	wind_create,win_gad(a6),2(a2),4(a2),6(a2),8(a2)
	move	d0,win_win(a6)
	bmi	exit_err_8		;err 8 = GEM window creation failure
;
	btst	#0,win_gad+1(a6)
	beq.s	.skip_title
	move.l	win_tit(a6),intin+4
	gem_aes	wind_set,win_win(a6),#2
.skip_title:
;
	btst	#4,win_gad+1(a6)
	beq.s	.skip_info
	move.l	win_inf(a6),intin+4
	gem_aes	wind_set,win_win(a6),#3
.skip_info:
;
	gem_aes	wind_calc,!,win_gad(a6),win_x(a6),win_y(a6),win_w(a6),win_h(a6)
	move	intout+2(pc),win_x(a6)	;\
	move	intout+4(pc),win_y(a6)	; \/ Outer
	move	intout+6(pc),win_w(a6)	; /\ rectangle
	move	intout+8(pc),win_h(a6)	;/
;
	gem_aes	wind_open,win_win(a6),win_x(a6),win_y(a6),win_w(a6),win_h(a6)
	clr.l	d0
	move	win_win(a6),d0
	unlk	a6
	rts
;
exit_err_3:
	unlk	a6
	moveq	#-3,d0
	rts
;
exit_err_4:
	unlk	a6
	moveq	#-4,d0
	rts
;
exit_err_5:
	unlk	a6
	moveq	#-5,d0
	rts
;
exit_err_6:
	unlk	a6
	moveq	#-6,d0
	rts
;
exit_err_7:
	unlk	a6
	moveq	#-7,d0
	rts
;
exit_err_8:
	moveq	#-8,d0
exit_err_d0:
	unlk	a6
	rts
;
;	ends	win_create
; ----------------------------------------------------------------------------
;
	XDEF	tw_open		;long tw_open(W wind,W gad,W cols,W rows)
;
		rsreset		;This structure gives offsets from a6 to arguments
		rs.b	8	;offset for a6 link and return address
open_win	rs.w	1
open_gad	rs.w	1
open_col	rs.w	1
open_row	rs.w	1
;
open_thd	=	-2
;
tw_open:
	gfafunc	8,wwww
	link	a6,#-2
;
	tst	open_win(a6)
	blt	exit_err_1
;
	move	tw_limit(pc),d2
	ble	exit_err_1
	subq	#1,d2
;
	tst	open_win(a6)	;\
	sne	d0		; \/ This reserves slot 0
	and	#1,d0		; /\ for desktop window
	subq	#1,d2		;/
	blt	exit_err_1
;
	move	#tw_lpow,d3
	move.l	tw_link_p(pc),a0
.open_loop:
	move	d0,d1
	lsl	d3,d1
	tst	tw_wind_o(a0,d1)
	blt.s	.got_slot
	addq	#1,d0
	dbra	d2,.open_loop
	bra	exit_err_1	;exit with err 1 if no slot free
;
.got_slot:
	move	d0,open_thd(a6)
	lea	(a0,d1),a3	;a3->terminal structure
	bsr	rc_init
	move	open_col(a6),d3
	addq	#3,d3
	and	#$FFFC,d3
	mulu	open_row(a6),d3	;d3 = bytes per buffer
	move.l	d3,d0		;d0 = text buffer size
	add.l	d3,d0		;d0+= attr buffer size
	add.l	d3,d0		;d0+= colr buffer size
	add.l	#256,d0		;d0+= stkp stack size
	add.l	#8*rectsize,d0	;d0+= rectangle table size
	add.l	#256,d0		;d0+= ht table size
	add.l	#capbsize,d0	;d0+= capture buffer size
	gemdos	Malloc,d0
	tst.l	d0
	bmi	exit_err_d0
; here d0-> individual terminal RAM buffers
	move	#tw_ends_o-1,d2
	lea	(a3),a0
.clr_loop:			;loop start to clear terminal structure
	clr.b	(a0)+
	dbra	d2,.clr_loop	;loop back to clear terminal structure
	move	open_win(a6),tw_wind_o(a3)
	move	open_gad(a6),tw_gads_o(a3)
	move	open_col(a6),d1
	move	d1,tw_cols_o(a3)
	addq	#3,d1
	and	#$FFFC,d1
	move	d1,tw_lnsz_o(a3)
	move	open_row(a6),tw_rows_o(a3)
	move.l	d0,tw_txtp_o(a3)	;-> text ASCII buffer
	add.l	d3,d0
	move.l	d0,tw_attp_o(a3)	;-> text attribute buffer
	add.l	d3,d0
	move.l	d0,tw_colp_o(a3)	;-> text colour buffer
	add.l	d3,d0
	move.l	d0,tw_stkp_o(a3)	;-> terminal stack
	add.l	#$100,d0
	move.l	d0,tw_lkpt_o(a3)	;-> lock rectangle buffer
	add.l	#$100,d0
	move.l	d0,tw_http_o(a3)	;-> HT stop table
	add.l	#$100,d0
	move.l	d0,tw_capb_o(a3)	;-> capture buffer
;NB: if tw_capb_o-$100 == tw_http_o, no extra buffer is in use
	add.l	#capbsize,d0
	move.l	#capbsize,tw_caps_o(a3)
	gem_aes	graf_handle
	move.l	intout+2(pc),d0		;d0=default character width.height
	move.l	d0,tw_chrw_o(a3)	;store tw_chrw & tw_chrh
	cmp	#8,d0
	blt.s	.low_font
	beq.s	.mid_font
.high_font:
	move.l	#4,tw_fntp_o(a3)
	bra.s	.got_font
;
.mid_font:
	move.l	#3,tw_fntp_o(a3)
	bra.s	.got_font
;
.low_font:
	move.l	#2,tw_fntp_o(a3)
.got_font:
	clr	-(sp)
	move.l	tw_fntp_o(a3),-(sp)
	bsr	tw_calc
	addq	#6,sp
	clr.l	d1
	move	d0,d1
	lsl.l	#8,d1
	lsr	#8,d1
	move.l	d1,tw_chrw_o(a3)	;store tw_chrw & tw_chrh
	swap	d0
	move.b	d0,d1
	ext	d1
	move	d1,tw_yoff_o(a3)
	lsr	#8,d0
	move	d0,tw_fpts_o(a3)
;
	_a_init
	move	(a0),d0
	moveq	#1,d1
	lsl	d0,d1
	subq	#1,d1			;d1 = max XBIOS colour
	cmp	#15,d1
	ble.s	.keep_colr
	moveq	#15,d1			;d1 = max terminal colour
.keep_colr:
	move	d1,tw_mclr_o(a3)
	moveq	#$70,d1
	move	d1,tw_colr_o(a3)	;current terminal fg & bg colours
	move	#1,tw_cdif_o(a3)	;guarantee foreground visibility
	move.l	#'    ',d0
	lea	quadbyte_t(pc),a0
	lsl	#2,d1
	move.l	(a0,d1),d1
	move.l	tw_txtp_o(a3),a0
	move.l	tw_attp_o(a3),a1
	move.l	tw_colp_o(a3),a2
	move	open_row(a6),d3
	subq	#1,d3
.buff_loop_1:
	move	tw_lnsz_o(a3),d2
	lsr	#2,d2
	subq	#1,d2
.buff_loop_2:
	move.l	d0,(a0)+		;default text
	clr.l	(a1)+			;default attributes
	move.l	d1,(a2)+		;default colours
	dbra	d2,.buff_loop_2
	dbra	d3,.buff_loop_1
;
	move.l	tw_http_o(a3),a0
	move.l	#$08080808,d0
	move.l	d0,d1
	moveq	#32-1,d2
.set_ht_lp:
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	add.l	d1,d0
	dbra	d2,.set_ht_lp
;
	bsr	visi_work		;recalc tw_wrk? & tw_vcol & tw_vrow
;
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),d0		;d0 = outer x.y
	move.l	intout+6(pc),d1		;d1 = outer w.h
	move.l	d0,tw_refx_o(a3)
	move.l	d1,tw_refw_o(a3)
	move.l	d0,tw_altx_o(a3)
	move.l	d1,tw_altw_o(a3)
	move.l	d0,tw_orgx_o(a3)
	move.l	d1,tw_orgw_o(a3)
	moveq	#3,d0
	bsr	init_prot_d0
	move.l	#-1,tw_barx_o(a3)
	move.l	#-1,tw_barw_o(a3)
	bsr	tw_bars
	bsr	vt52_esc_ue
	move	tw_rows_o(a3),d0
	subq	#1,d0
	move	d0,tw_bots_o(a3)
	bsr	note_size
	move	open_thd(a6),d0
;
exit_ext_d0:
	unlk	a6
	ext.l	d0
	rts
;
;	ends tw_open
; ----------------------------------------------------------------------------
;
	XDEF	tw_close	;long	tw_close(W thd)
;
tw_close:
	gfafunc	2,w
tw_i_close:
	link	a6,#0
	move	8(a6),d0
	bmi	exit_err_1
	cmp	tw_limit(pc),d0
	bge	exit_err_1
	move	#tw_lpow,d1
	lsl	d1,d0
	move.l	tw_link_p(pc),a3
	bmi	exit_err_1
	add	d0,a3
	move	tw_wind_o(a3),d3
	blt	exit_err_1
	cmp.l	#capbsize,tw_caps_o(a3)
	bls.s	.no_xbuf
	gemdos	Mfree|_ind,tw_capb_o(a3)
.no_xbuf:
	gemdos	Mfree|_ind,tw_txtp_o(a3)
	move	#-1,tw_wind_o(a3)
	move	d3,d0
	bra	exit_ext_d0
;
;	ends tw_close
; ----------------------------------------------------------------------------
;
	XDEF	gem2tw_		;long	gem2tw_(whd)
;
gem2tw_:
	gfafunc	2,w
gem2tw_i:
	_debdef	gem2tw_i,3
	link	a6,#0
	move	tw_limit(pc),d2
	ble	exit_err_1
	subq	#1,d2
	move	#tw_lpow,d1
	move.l	tw_link_p(pc),a3
	bmi	exit_err_1
.slot_loop:
	move	d2,d0
	lsl	d1,d0
	move	tw_wind_o(a3,d0),d0
	cmp	8(a6),d0
	beq.s	.got_slot
	dbra	d2,.slot_loop
	bra	exit_err_1
;
.got_slot:
	move	d2,d0
	bra	exit_ext_d0
;
;	ends gem2tw_
; ----------------------------------------------------------------------------
;
	XDEF	tw_2gem		;long	tw_2gem(W thd)
;
tw_2gem:
	gfafunc	2,w
	move	4(sp),d0
	bra	tw_pfix
;
;	ends tw_2gem
; ----------------------------------------------------------------------------
;
	XDEF	tw_prot		;long	tw_prot(W thd,W type)
;
tw_prot:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_type_o(a3),d7
	move	10(a6),d0	;d0=type
	bmi.s	exit_ext_d7
	bsr.s	init_prot_d0
exit_ext_d7:
	move	d7,d0
	bra	exit_ext_d0
;
init_prot_d0:
	cmp	tw_limtype(pc),d0
	bhs.s	.exit
	cmp	#4,d0
	shs	d1
	and	#$0020,d1
	and	#$FFDF,tw_attr_o(a3)
	or	d1,tw_attr_o(a3)
	move	d0,tw_type_o(a3)
	lsl	#2,d0
	move.l	tw_typefn_t(pc,d0),tw_type_jump+2	;init protocol ptr
.exit:
	rts
;
tw_typefn_t:
	_debdef	tw_typefn_t,2
	dc.l	tw_chp0,tw_chp1,tw_chp2,tw_chp3	;ascii_7,ascii_8,vt52_7,vt52_8
	dc.l	tw_chp4,tw_chp5,tw_chp2,tw_chp3	;ansi_7,ansi_8
	dc.l	tw_chp0,tw_chp1,tw_chp2,tw_chp3
	dc.l	tw_chp0,tw_chp1,tw_chp2,tw_chp3
;
;	ends tw_prot
; ----------------------------------------------------------------------------
;
	XDEF	tw_font		;long	tw_font(W thd,L font)
;
tw_font:
	gfafunc	6,wl
tw_i_font:
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	tw_fntp_o(a3),d7
	move.l	10(a6),d0	;d0=font
	bmi.s	exit_d7
	move.l	d0,tw_fntp_o(a3)
	move	tw_attr_o(a3),-(sp)
	move.l	d0,-(sp)
	bsr	tw_calc
	addq	#6,sp
	clr.l	d1
	move	d0,d1
	lsl.l	#8,d1
	lsr	#8,d1
	move.l	d1,tw_chrw_o(a3)	;store tw_chrw & tw_chrh
	swap	d0
	move.b	d0,d1
	ext	d1
	move	d1,tw_yoff_o(a3)
	lsr	#8,d0
	move	d0,tw_fpts_o(a3)
	bsr	visi_calc		;recalc tw_vcol & tw_vrow
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,tw_wrkx,tw_wrky,tw_wrkw,tw_wrkh)
	bsr	note_size
exit_d7:
	move.l	d7,d0
	unlk	a6
	rts
;
;	ends tw_font
; ----------------------------------------------------------------------------
;
	XDEF	tw_satt		;long	tw_satt(W thd,W satt)
;
tw_satt:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_attr_o(a3),d7
	and	#$0F,d7
	move	10(a6),d0	;d0=satt
	bmi	exit_ext_d7
	and	#$0F,d0
	move	tw_attr_o(a3),d1
	and	#$FFF0,d1
	or	d1,d0
	move	d0,tw_attr_o(a3)
	eor	d7,d0
	and	#$10,d0
	beq	exit_ext_d7
	move	d7,-(sp)
	move.l	tw_fntp_o(a3),-(sp)
	move	8(a6),-(sp)
	bsr	tw_i_font			;recalc font sizes
	addq	#6,sp
	move	(sp)+,d7
	bra	exit_ext_d7
;
;	ends tw_satt
; ----------------------------------------------------------------------------
;
	XDEF	tw_inv		;long	tw_inv(W thd,W flag)
;
tw_inv:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_attr_o(a3),d7
	btst	#7,d7
	sne	d7
	ext	d7
	neg	d7
	move	10(a6),d0	;d0=flag
	bmi	exit_ext_d7
	beq.s	.clr_inv
.set_inv:
	or	#128,tw_attr_o(a3)
	bra	exit_ext_d7
;
.clr_inv:
	and	#-1-128,tw_attr_o(a3)
	bra	exit_ext_d7
;
;	ends tw_inv
; ----------------------------------------------------------------------------
;
	XDEF	tw_wrap		;long	tw_wrap(W thd,W flag)
;
tw_wrap:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_attr_o(a3),d7
	btst	#8,d7
	sne	d7
	and	#1,d7
	move	10(a6),d0	;d0=flag
	bmi	exit_ext_d7
	sne	d0
	and	#1,d0
	cmp	d0,d7
	beq	exit_ext_d7
	bchg	#0,tw_attr_o(a3)
	bra	exit_ext_d7
;
;	ends	tw_wrap
; ----------------------------------------------------------------------------
;
	XDEF	tw_showc	;long	tw_showc(W thd)
;
tw_showc:
	gfafunc	2,w
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_hide_o(a3),-(sp)
	bsr	tw_show
	clr.l	d0
	move	(sp)+,d0
	unlk	a6
	rts
;
;	ends	tw_showc
; ----------------------------------------------------------------------------
;
	XDEF	tw_hidec	;long	tw_hidec(W thd)
;
tw_hidec:
	gfafunc	2,w
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_hide_o(a3),-(sp)
	bsr	tw_hide
	clr.l	d0
	move	(sp)+,d0
	unlk	a6
	rts
;
;	ends	tw_hidec
; ----------------------------------------------------------------------------
;
	XDEF	tw_escf		;long	tw_escf(W thd)
;
tw_escf:
	gfafunc	2,w
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	clr.l	d0
	move	tw_escf_o(a3),d0
	unlk	a6
	rts
;
;	ends	tw_escf
; ----------------------------------------------------------------------------
;
	XDEF	tw_colr		;long	tw_colr(W thd,W colr)
;
tw_colr:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_colr_o(a3),d7
	move	10(a6),d0	;d0=colr
	bmi	exit_ext_d7
	move	d0,tw_colr_o(a3)
	bra	exit_ext_d7
;
;	ends tw_colr
; ----------------------------------------------------------------------------
;
	XDEF	tw_tcol		;long	tw_colr(W thd,W colix,W rgb)
;
tw_tcol:
	gfafunc	6,www
	link	a6,#0
	move	8(a6),d0
	bsr	tw_pfix
	bmi	exit_err_1
	lea	truecol_t(pc),a0
	clr.l	d7
	move	10(a6),d0	;d0=colix
	bmi.s	.read_only
	cmp	#16,d0
	bgt	exit_err_1
	add	d0,d0
	move	(a0,d0),d7
	move	12(a6),(a0,d0)
	bsr.s	try_truecol
	move.l	d7,d0
	unlk	a6
	rts
;
.read_only:
	neg	d0
	add	d0,d0
	move	(a0,d0),d7
	move.l	d7,d0
	unlk	a6
	rts
;
try_truecol:
	cmp	#$100,rc_maxcolours
	bls.s	.keep_tables
	movem.l	d0-d1/a0-a2,-(sp)
	lea	truecol_t(pc),a0
	lea	xbios_col_t(pc),a1
	lea	vdi_col_t(pc),a2
	moveq	#16-1,d0
.fix_tables:
	move	(a0)+,d1
	move	d1,(a1)+
	move	d1,(a2)+
	dbra	d0,.fix_tables
	movem.l	(sp)+,d0-d1/a0-a2
.keep_tables:
	rts
;
;	ends tw_tcol
; ----------------------------------------------------------------------------
;
	XDEF	tw_cdif		;long	tw_cdif(W thd,W flag)
;
tw_cdif:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_cdif_o(a3),d7
	move	10(a6),d0	;d0= flag
	bmi	exit_ext_d7
	move	d0,tw_cdif_o(a3)
	bra	exit_ext_d7
;
;	ends tw_cdif
; ----------------------------------------------------------------------------
;
	XDEF	tw_voff		;long	tw_voff(W flag)
;
tw_voff:
	gfafunc	2,w
	link	a6,#0
	move	rc_voff(pc),d7
	move	8(a6),d0	;d0= flag
	bmi	exit_ext_d7
	move	d0,rc_voff
	bra	exit_ext_d7
;
;	ends tw_voff
; ----------------------------------------------------------------------------
;
	XDEF	tw_lock		;long	tw_lock(W thd,W flag)
;
tw_lock:
	gfafunc	4,ww
tw_i_lock:
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_lock_o(a3),d7
	move	10(a6),d0	;d0= flag
	bmi	exit_ext_d7
	bgt.s	tw_lock_up
	bsr	tw_uselock
	clr	tw_lock_o(a3)
	unlk	a6
	rts
	
tw_lock_up:
	bsr	tw_uselock
	bne.s	.locked_up
	move	#1,tw_lock_o(a3)
.locked_up:
	unlk	a6
	rts
;
;
;	ends tw_lock
; ----------------------------------------------------------------------------
;
	XDEF	tw_setw		;void	tw_setw(W thd,W x,W y,W w,W,h)
;
tw_setw:
	gfaproc wwwww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	lea	10(a6),a0
	lea	intin+12(pc),a1
	move	(a0)+,-(a1)
	move	(a0)+,-(a1)
	move	(a0)+,-(a1)
	move	(a0)+,-(a1)
	gem_aes	wind_set,tw_wind_o(a3),#5
;
	bsr	visi_work		;recalc tw_wrk? & tw_vcol & tw_vrow
;
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_refx_o(a3)
	move.l	intout+6(pc),tw_refw_o(a3)
	bsr	note_size
	unlk	a6
	rts
;
;	ends tw_setw
; ----------------------------------------------------------------------------
;
	XDEF	tw_fixo		;void	tw_fixo(W thd,W x,W y,W w,W,h)
;
tw_fixo:
	gfaproc	wwwww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	lea	10(a6),a0
	lea	intin+12(pc),a1
	move	(a0)+,-(a1)
	move	(a0)+,-(a1)
	move	(a0)+,-(a1)
	move	(a0)+,-(a1)
	gem_aes	wind_set,tw_wind_o(a3),#5
;
	bsr	visi_work		;recalc tw_wrk? & tw_vcol & tw_vrow
;
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_refx_o(a3)
	move.l	intout+6(pc),tw_refw_o(a3)
	move.l	intout+2(pc),tw_orgx_o(a3)
	move.l	intout+6(pc),tw_orgw_o(a3)
	bsr	note_size
	unlk	a6
	rts
;
;	ends tw_fixo
; ----------------------------------------------------------------------------
;
	XDEF	tw_seto		;void	tw_seto(W thd)
;
tw_seto:
	gfaproc	w
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	tw_orgx_o(a3),intin+4
	move.l	tw_orgw_o(a3),intin+8
	gem_aes	wind_set,tw_wind_o(a3),#5
;
	bsr	visi_work		;recalc tw_wrk? & tw_vcol & tw_vrow
;
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_refx_o(a3)
	move.l	intout+6(pc),tw_refw_o(a3)
	bsr	note_size
	unlk	a6
	rts
;
;	ends tw_seto
; ----------------------------------------------------------------------------
;
	XDEF	tw_find		;long	tw_find(W x,W y)
;
tw_find:
	gfafunc	4,ww
	link	a6,#0
	gem_aes	wind_find,8(a6),10(a6)
	move	d0,-(sp)
	bsr	gem2tw_i
	addq	#2,sp
	bmi	exit_err_1
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	a3,d0
	sub.l	tw_link_p(pc),d0
	moveq	#tw_lpow,d1
	lsr	d1,d0		;d0 = top valid thd at given coordinates
	unlk	a6
	rts
;
;	ends	tw_find
; ----------------------------------------------------------------------------
;
	XDEF	tw_pich		;long	tw_pich(W thd,W x,W y)
;
tw_pich:
	gfafunc	6,www
	link	a6,#0
	move	8(a6),d0	;d0 = thd
	bsr	tw_pfix
	bmi	exit_err_1
	clr.l	d1
	clr.l	d2
	move	10(a6),d1	;d1 = x
	move	12(a6),d2	;d2 = y
	sub	tw_wrkx_o(a3),d1
	blt	exit_err_1
	sub	tw_wrky_o(a3),d2
	blt	exit_err_1
	cmp	tw_wrkw_o(a3),d1
	bge	exit_err_1
	cmp	tw_wrkh_o(a3),d2
	bge	exit_err_1
	divu	tw_chrw_o(a3),d1
	divu	tw_chrh_o(a3),d2
	add	tw_scol_o(a3),d1
	add	tw_srow_o(a3),d2
	bra.s	tw_ij_cich
;
; ----------------------------------------------------------------------------
;
	XDEF	tw_cich		;long	tw_cich(W thd,W col,W row)
;
tw_cich:
	gfafunc	6,www
	link	a6,#0
	move	8(a6),d0	;d0 = thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d1	;d1.l = col
	move	12(a6),d2	;d2 = row
tw_ij_cich:
	and.l	#$FFFF,d1
	cmp	tw_cols_o(a3),d1
	bhs	exit_err_1	;error if col too high
	cmp	tw_rows_o(a3),d2
	bhs	exit_err_1	;error if row too high
	mulu	tw_lnsz_o(a3),d2
	add.l	d2,d1		;d1.l = tw_lnsz*row+col
	move.l	tw_txtp_o(a3),a0
	clr.l	d0
	move.b	(a0,d1.l),d0	;d0.l = buffer character
	unlk	a6
	rts
;
;	ends	tw_cich & tw_pich
; ----------------------------------------------------------------------------
;
	XDEF	tw_cout		;void	tw_cout(W thd,W data)
;
tw_cout:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d0	;d0=data
	bsr	tw_chop
	unlk	a6
	rts
;
;	ends	tw_cout
; ----------------------------------------------------------------------------
;
	XDEF	tw_sout		;void	tw_sout(W thd,L data_p)
;
tw_sout:
	gfaproc	wl
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	10(a6),a0	;a0=dat_p
	tst.b	(a0)
	beq	exit_zero
	move	tw_lock_o(a3),-(sp)
	bne.s	.do_sout
	move	#1,tw_lock_o(a3)
	bset	#0,tw_stat_o(a3)	;set autolock flag
.do_sout:
.sout_loop:
	move.l	10(a6),a0	;\/a0 = dat_p++
	addq.l	#1,10(a6)	;/\
	clr	d0
	move.b	(a0),d0
	beq.s	.done_sout
	bsr	tw_chop
	bra.s	.sout_loop
;
.done_sout:
	tst	(sp)+
	bne.s	.exit_sout
	bsr	tw_uselock
	clr	tw_lock_o(a3)
	bclr	#0,tw_stat_o(a3)	;clr autolock flag
.exit_sout:
	unlk	a6
	rts
;
;	ends	tw_sout
; ----------------------------------------------------------------------------
;
	XDEF	tw_del		;void	tw_del(W thd,W cols)
;
tw_del:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d0	;d0=cols
	bsr	tw_delp
	unlk	a6
	rts
;
;	ends	tw_del
; ----------------------------------------------------------------------------
;
	XDEF	tw_ins		;void	tw_ins(W thd,W cols)
;
tw_ins:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d0	;d0=cols
	bsr	tw_insp
	unlk	a6
	rts
;
;	ends	tw_ins
; ----------------------------------------------------------------------------
;
	XDEF	tw_ldel		;void	tw_ldel(W thd,W rows)
;
tw_ldel:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d0	;d0=rows
	bsr	tw_delr
	unlk	a6
	rts
;
;	ends	tw_ldel
; ----------------------------------------------------------------------------
;
	XDEF	tw_lins		;void	tw_lins(W thd,W rows)
;
tw_lins:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d0	;d0=rows
	bsr	tw_insr
	unlk	a6
	rts
;
;	ends	tw_lins
; ----------------------------------------------------------------------------
;
	XDEF	tw_clrl		;void	tw_clrl(W thd,W code)
;
tw_clrl:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d3	;d3=code
	bsr	ansi_csi_uk
	unlk	a6
	rts
;
;	ends tw_clrl
; ----------------------------------------------------------------------------
;
	XDEF	tw_clrs		;void	tw_clrs(W thd,W code)
;
tw_clrs:
	gfaproc	ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	10(a6),d3	;d3=code
	bsr	ansi_csi_uj
	unlk	a6
	rts
;
;	ends tw_clrs
; ----------------------------------------------------------------------------
;
	XDEF	tw_at		;void	tw_at(W thd,W col,W row)
;
tw_at:
	gfaproc	www
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	tw_ccol_o(a3),d2
	move	10(a6),d0	;d0=col
	bmi.s	.keep_col
	move	tw_cols_o(a3),d1
	subq	#1,d1
	cmp	d1,d0
	ble.s	.use_col_d0
	move	d1,d0
.use_col_d0:
	swap	d2
	move	d0,d2
	swap	d2
.keep_col:
	move	12(a6),d0	;d0=row
	bmi.s	.keep_row
	move	tw_rows_o(a3),d1
	subq	#1,d1
	cmp	d1,d0
	ble.s	.use_row_d0
	move	d1,d0
.use_row_d0:
	move	d0,d2
.keep_row:
	move.l	d2,d0
	bsr	tw_movc
	unlk	a6
	rts
;
;	ends tw_at
; ----------------------------------------------------------------------------
;
	XDEF	tw_colx		;long	tw_colx(W thd)
;
tw_colx:
	gfafunc	2,w
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_ccol_o(a3),d0
	bra	exit_ext_d0
;
;	ends tw_colx
; ----------------------------------------------------------------------------
;
	XDEF	tw_rowx		;long	tw_rowx(W thd)
;
tw_rowx:
	gfafunc	2,w
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_crow_o(a3),d0
	bra	exit_ext_d0
;
;	ends tw_rowx
; ----------------------------------------------------------------------------
;
	XDEF	tw_resp		;long	tw_resp(W thd)
;
tw_resp:
	gfafunc	2,w
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	tw_resp_o(a3),d0
	clr.l	tw_resp_o(a3)
	unlk	a6
	rts
;
;	ends tw_rowx
; ----------------------------------------------------------------------------
;
	XDEF	tw_caplk	;long	tw_caplk(W thd, W fhd)
;
tw_caplk:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_caph_o(a3),-(sp)
	move	10(a6),d0	;d0=fhd
	bmi.s	.old_fhd
	bne.s	.new_fhd
	bsr	flush_capture
	clr	tw_capm_o(a3)
.new_fhd:
	move	10(a6),tw_caph_o(a3)
.old_fhd:
	move	(sp)+,d0
	bra	exit_ext_d0
;
;	ends	tw_caplk
; ----------------------------------------------------------------------------
;
	XDEF	tw_capmd	;long	tw_capmd(W thd, W mode)
;
tw_capmd:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_caph_o(a3),-(sp)
	move	10(a6),d0	;d0=mode
	bmi.s	.old_mode
	bne.s	.new_mode
	bsr	flush_capture
.new_mode:
	move	10(a6),tw_capm_o(a3)
.old_mode:
	move	(sp)+,d0
	bra	exit_ext_d0
;
;	ends	tw_capmd
; ----------------------------------------------------------------------------
;
	XDEF	tw_capsz	;long	tw_capsz(W thd, L size)
;
tw_capsz:
	gfafunc	6,wl
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move.l	10(a6),d7	;d7=size
	bpl.s	.set_capb
	move.l	tw_caps_o(a3),d0
	bra.s	.exit
;
.set_capb:
	bsr	flush_capture
	cmp.l	#capbsize,tw_caps_o(a3)
	bls.s	.no_xbuf
	gemdos	Mfree|_ind,tw_capb_o(a3)
.no_xbuf:
	cmp.l	#capbsize,d7
	bls.s	.capb_internal
	gemdos	Malloc,d7
	tst.l	d0
	bpl.s	.capb_ok
.capb_internal:
	move.l	#capbsize,d7
	move.l	tw_http_o(a3),d0
	add.l	#$100,d0
.capb_ok:
	move.l	d7,tw_caps_o(a3)
	move.l	d0,tw_capb_o(a3)
.exit:
	unlk	a6
	rts
;
;	ends	tw_capsz
; ----------------------------------------------------------------------------
;
	XDEF	tw_invid	;long	tw_invid(W thd,W flag)
;
tw_invid:
	gfafunc	4,ww
	link	a6,#0
	move	8(a6),d0	;d0=thd
	bsr	tw_pfix
	bmi	exit_err_1
	move	tw_atac_o(a3),d7
	sne	d1
	move	10(a6),d0	;d0= flag
	bmi	exit_ext_d7
	move	d0,tw_atac_o(a3)
	sne	d0
	cmp.b	d0,d1
	beq	exit_ext_d7
	move	d7,-(sp)
	bsr	tw_redraw_2
	move	(sp)+,d7
	bra	exit_ext_d7
;
;	ends tw_invid
; ----------------------------------------------------------------------------
;
	XDEF	tw_menkey	;long	tw_menkey()
;
tw_menkey:
	gfafunc	2,w
	move.w	4(sp),d0
	men_key
	rts
;
	make	KEY_links
;
;	ends tw_menkey
; ----------------------------------------------------------------------------
;
	XDEF	tw_genkey	;long	tw_genkey()
;
tw_genkey:
	gfafunc	4,l
	move.l	4(sp),d0
	gen_key
	rts
;
	make	KEY_links
;
;	ends tw_genkey
; ----------------------------------------------------------------------------
;
	XDEF	tw_update	;long	tw_update(L msg_p)
;
upd_mt	= -26
upd_mx	= -24
upd_my	= -22
upd_mw	= -20
upd_mh	= -18
upd_cx	= -16
upd_cy	= -14
upd_cw	= -12
upd_ch	= -10
upd_fx	= -8
upd_fy	= -6
upd_fw	= -4
upd_fh	= -2
;
note_size:
	link	a6,#-26
	movem.l	d0-d7/a0-a6,-(sp)	;patch
	bsr	note_size_sub
	movem.l	(sp)+,d0-d7/a0-a6	;patch
	unlk	a6
	rts
;
tw_update:
	gfafunc	4,l
	link	a6,#-26
	move.l	8(a6),a0	;a0= msg_p
	move	(a0),d0
	move	d0,upd_mt(a6)
	cmp	#20,d0
	blt	exit_zero
	cmp	#29,d0
	bgt	exit_zero
	move	6(a0),-(sp)
	bsr	gem2tw_i
	addq	#2,sp
	bmi	exit_zero
	bsr	tw_pfix
	bmi	exit_zero
	move.l	8(a6),a0	;a0=msg_p
	move	8(a0),upd_mx(a6)
	move	10(a0),upd_my(a6)
	move	12(a0),upd_mw(a6)
	move	14(a0),upd_mh(a6)
	move	upd_mt(a6),d0
	sub	#20,d0
	lsl	#2,d0
	move.l	upd_c_t(pc,d0),a0
	jsr	(a0)
	bra	endsel_upd
;
;
upd_c_t:
	_debdef	upd_c_t,3
	dc.l	upd_c_20,upd_c_21,upd_c_22,upd_c_23
	dc.l	upd_c_24,upd_c_25,upd_c_26,upd_c_27
	dc.l	upd_c_28,upd_c_29
;
;
upd_c_20:	;Redraw
	_debdef	upd_c_20,3
	move.l	upd_mw(a6),-(sp)
	move.l	upd_mx(a6),-(sp)
	move	#2,-(sp)
	bsr	tw_redraw
	lea	10(sp),sp
	rts
;
;
upd_c_21:	;Topped
	_debdef	upd_c_21,3
upd_c_29:	;Newtop
	_debdef	upd_c_29,3
	gem_aes	wind_set,tw_wind_o(a3),#10
	rts
;
;
upd_c_22:	;Closed
	_debdef	upd_c_22,3
	move.l	tw_orgx_o(a3),intin+4
	move.l	tw_orgw_o(a3),intin+8
	gem_aes	wind_set,tw_wind_o(a3),#5
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_refx_o(a3)
	move.l	intout+6(pc),tw_refw_o(a3)
	bsr	visi_work		;recalc tw_wrk? & tw_vcol & tw_vrow
	bra	note_size_sub
;
;
upd_c_23:	;Fulled
	_debdef	upd_c_23,3
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),upd_cx(a6)
	move.l	intout+6(pc),upd_cw(a6)
;
	gem_aes	wind_get,tw_wind_o(a3),#7
	move.l	intout+2(pc),upd_fx(a6)
	move.l	intout+6(pc),upd_fw(a6)
;
	move.l	upd_cx(a6),d0
	move.l	upd_cw(a6),d1
	cmp.l	tw_refx_o(a3),d0
	bne.s	.non_r2f
	cmp.l	tw_refw_o(a3),d1
	bne.s	.non_r2f
;		;change from REF to FULL, updating ALT
	bra.s	.use_full
;
.non_r2f:
	cmp.l	upd_fx(a6),d0
	bne.s	.non_f2r
	tst.b	tw_sizl_o(a3)
	bne.s	.use_ref
	cmp.l	upd_fw(a6),d1
	bne.s	.non_f2r
;		;change from FULL size to REF
.use_ref:
	move.l	tw_refx_o(a3),intin+4
	move.l	tw_refw_o(a3),intin+8
	gem_aes	wind_set,tw_wind_o(a3),#5
	bra.s	.end_fulled
;
.non_f2r:
	cmp.l	tw_altx_o(a3),d0
	bne.s	.non_a2f
	cmp.l	tw_altw_o(a3),d1
	bne.s	.non_a2f
;		;change from ALT size to FULL, updating ALT
.use_full:
	move.l	upd_fx(a6),intin+4
	move.l	upd_fw(a6),intin+8
	gem_aes	wind_set,tw_wind_o(a3),#5
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_altx_o(a3)
	move.l	intout+6(pc),tw_altw_o(a3)
.end_fulled:
	bsr	visi_work		;recalc tw_wrk? & tw_vcol & tw_vrow
	bra	note_size_sub
;
.non_a2f:
      ;         ;strange settings;;; use as REF, change to FULL
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_refx_o(a3)
	move.l	intout+6(pc),tw_refw_o(a3)
	bra.s	.use_full
;
;
upd_c_24:	;Arrowed, upd_mx(a6) = arrow_code
	_debdef	upd_c_24,3
	move	upd_mx(a6),d0
	clr.l	d1
	move	tw_wrkh_o(a3),d1
	divu	tw_chrh_o(a3),d1
	move	d1,upd_mh(a6)		;mh = div(wrkh,chrh)
	swap	d1
	move	d1,upd_my(a6)		;my = mod(wrkh,chrh)
	clr.l	d1
	move	tw_wrkw_o(a3),d1
	divu	tw_chrw_o(a3),d1
	move	d1,upd_mw(a6)		;mw = div(wrkw,chrh)
	swap	d1
	move	d1,upd_mx(a6)		;mx = mod(wrkw,chrw)
	cmp	#7,d0
	bhi	endsel_arrow
	lsl	#2,d0
	move.l	arr_c_t(pc,d0),a0
	jsr	(a0)
	bra	endsel_arrow
;
;
arr_c_t:
	_debdef	arr_c_t,3
	dc.l	arr_c_0,arr_c_1,arr_c_2,arr_c_3
	dc.l	arr_c_4,arr_c_5,arr_c_6,arr_c_7
;
;
arr_c_0:	;page up
	_debdef	arr_c_0,3
	btst	#0,tw_gads_o(a3)
	beq.s	.done_pgup
	move	tw_srow_o(a3),d0
	beq.s	.done_pgup
	sub	upd_mh(a6),d0
	move	d0,tw_srow_o(a3)
	bge.s	.keep_srow
	clr	tw_srow_o(a3)
.keep_srow:
	move	tw_rows_o(a3),d0
	sub	tw_srow_o(a3),d0
	cmp	upd_mh(a6),d0
	ble.s	.use_vrow_d0
	move	upd_mh(a6),d0	;d0 = min(rows-srow,mh)
	tst	upd_my(a6)
	beq.s	.use_vrow_d0
	addq	#1,d0		;round up
.use_vrow_d0:
	move	d0,tw_vrow_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,tw_wrkx&,tw_wrky&,tw_wrkw&,tw_wrkh&)
.done_pgup:
	rts
;
;
arr_c_1:	;page down
	_debdef	arr_c_1,3
	btst	#0,tw_gads_o(a3)
	beq.s	.done_pgdn
	move	tw_srow_o(a3),d0
	add	upd_mh(a6),d0
	move	tw_rows_o(a3),d1
	sub	upd_mh(a6),d1
	cmp	d1,d0
	ble.s	.keep_row_d0
	move	d1,d0		;d0 = min(rows-mh,srow+mh)
.keep_row_d0:
	tst	d0
	bpl.s	.use_row_d0
	clr	d0
.use_row_d0:
	move	d0,tw_srow_o(a3)
	move	tw_rows_o(a3),d1
	sub	d0,d1
	cmp	upd_mh(a6),d1
	ble.s	.keep_row_d1
	move	upd_mh(a6),d1	;d1 = min(rows-srow,mh)
	tst	upd_my(a6)
	beq.s	.keep_row_d1
	addq	#1,d1		;round up
.keep_row_d1:
	move	d1,tw_vrow_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,tw_wrkx&,tw_wrky&,tw_wrkw&,tw_wrkh&)
.done_pgdn:
	rts
;
;
arr_c_2:	;line up
	_debdef	arr_c_2,3
	btst	#6,tw_gads_o+1(a3)
	beq.s	.done_lnup
	tst	tw_srow_o(a3)
	beq.s	.done_lnup
	subq	#1,tw_srow_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,tw_wrkx&,tw_wrky&,tw_wrkw&,tw_wrkh&)
.done_lnup:
	rts
;
;
arr_c_3:	;line down
	_debdef	arr_c_3,3
	btst	#7,tw_gads_o+1(a3)
	beq.s	.done_lndn
	move	tw_srow_o(a3),d0
	add	upd_mh(a6),d0
	cmp	tw_rows_o(a3),d0
	bge.s	.done_lndn
	addq	#1,tw_srow_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,wrkx,wrky,wrkw,wrkh)
.done_lndn:
	rts
;
;
arr_c_4:	;page left
	_debdef	arr_c_4,3
	btst	#3,tw_gads_o(a3)
	beq.s	.done_pglt
	move	tw_scol_o(a3),d0
	beq.s	.done_pglt
	sub	upd_mw(a6),d0
	move	d0,tw_scol_o(a3)
	bge.s	.keep_scol
	clr	tw_scol_o(a3)
.keep_scol:
	move	tw_cols_o(a3),d0
	sub	tw_scol_o(a3),d0
	cmp	upd_mw(a6),d0
	ble.s	.use_vcol_d0
	move	upd_mw(a6),d0	;d0 = min(cols-scol,mw)
	tst	upd_mx(a6)
	beq.s	.use_vcol_d0
	addq	#1,d0		;round up
.use_vcol_d0:
	move	d0,tw_vcol_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,wrkx,wrky,wrkw,wrkh)
.done_pglt
	rts
;
;
arr_c_5:	;page right
	_debdef	arr_c_5,3
	btst	#3,tw_gads_o(a3)
	beq.s	.done_pgrt
	move	tw_scol_o(a3),d0
	add	upd_mw(a6),d0
	move	tw_cols_o(a3),d1
	sub	upd_mw(a6),d1
	cmp	d1,d0
	ble.s	.keep_col_d0
	move	d1,d0		;d0 = min(cols-mw,scol+mw)
.keep_col_d0:
	tst	d0
	bpl.s	.use_col_d0
	clr	d0
.use_col_d0:
	move	d0,tw_scol_o(a3)
	move	tw_cols_o(a3),d1
	sub	d0,d1
	cmp	upd_mw(a6),d1
	ble.s	.keep_col_d1
	move	upd_mw(a6),d1
;
	move	upd_mw(a6),d1	;d1 = min(cols-scol,mw)
	tst	upd_mx(a6)
	beq.s	.keep_col_d1
	addq	#1,d1		;round up
.keep_col_d1:
	move	d1,tw_vcol_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,wrkx,wrky,wrkw,wrkh)
.done_pgrt:
	rts
;
;
arr_c_6:	;column left
	_debdef	arr_c_6,3
	btst	#1,tw_gads_o(a3)
	beq.s	.done_colt
	tst	tw_scol_o(a3)
	beq.s	.done_colt
	subq	#1,tw_scol_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,wrkx,wrky,wrkw,wrkh)
.done_colt:
	rts
;
;
arr_c_7:	;column right
	_debdef	arr_c_7,3
	btst	#2,tw_gads_o(a3)
	beq.s	.done_cort
	move	tw_scol_o(a3),d0
	add	upd_mw(a6),d0
	cmp	tw_cols_o(a3),d0
	bge.s	.done_cort
	addq	#1,tw_scol_o(a3)
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,wrkx,wrky,wrkw,wrkh)
.done_cort:
	rts
;
;
endsel_arrow:
	bsr	tw_bars
	rts
;
;
upd_c_25:	;Hslid, upd_mx(a6) = relative_pos * 1000
	_debdef	upd_c_25,3
	btst	#3,tw_gads_o(a3)
	beq.s	.done_hslid
	clr.l	d0
	move	tw_wrkw_o(a3),d0
	divu	tw_chrw_o(a3),d0
	move	d0,d1		;d1 = (wrkw / chrw)
	move	d0,d2		;d2 = (wrkw / chrw)
	sub	tw_cols_o(a3),d0
	bge.s	.keep_scol	;IF (wrkw / chrw) < cols
	neg	d0			;d0 = cols - (wrkw / chrw)
	mulu	upd_mx(a6),d0
	add.l	#500,d0
	divu	#1000,d0		;d0 = col 
	add	d0,d1			;d1 = col + (wrkw / chrw)
	sub	tw_cols_o(a3),d1	;d1 = col + (wrkw / chrw) - cols
	blt.s	.got_scol		;IF (col +(wrkw / chrw)) >= cols
	sub	d0,d1				;d1 = (wrkw / chrw) - cols
	neg	d1				;d1 = cols - (wrkw / chrw)
	move	d1,d0				;d0 = cols - (wrkw / chrw)
	bra.s	.set_scol
;					;ELSE
.got_scol:
	clr.l	d2
	move	tw_wrkw_o(a3),d2
	add	tw_chrw_o(a3),d2
	subq	#1,d2
	divu	tw_chrw_o(a3),d2
.set_scol:				;ENDIF
	move	d0,tw_scol_o(a3)
	move	d2,tw_vcol_o(a3)
	bsr	tw_redraw_2		;tw_redraw(2,wrkx,wrky,wrkw,wrkw)
	bra.s	.end_hslide
;				;ELSE  (wrkw / chrw) >= cols
.keep_scol:
	bsr	tw_remarg
.end_hslide:			;ENDIF
	bsr	tw_bars
.done_hslid:
	rts
;
;
upd_c_26:	;Vslid, upd_mx(a6) = relative_pos * 1000
	_debdef	upd_c_26,3
	btst	#0,tw_gads_o(a3)
	beq.s	.done_vslid
	clr.l	d0
	move	tw_wrkh_o(a3),d0
	divu	tw_chrh_o(a3),d0
	move	d0,d1		;d1 = (wrkh / chrh)
	move	d0,d2		;d2 = (wrkh / chrh)
	sub	tw_rows_o(a3),d0
	bge.s	.keep_srow	;IF (wrkh / chrh) < rows
	neg	d0			;d0 = rows - (wrkh / chrh)
	mulu	upd_mx(a6),d0
	add.l	#500,d0
	divu	#1000,d0		;d0 = row 
	add	d0,d1			;d1 = row + (wrkh / chrh)
	sub	tw_rows_o(a3),d1	;d1 = row + (wrkh / chrh) - rows
	blt.s	.got_srow		;IF (row +(wrkh / chrh)) >= rows
	sub	d0,d1				;d1 = (wrkh / chrh) - rows
	neg	d1				;d1 = rows - (wrkh / chrh)
	move	d1,d0				;d0 = rows - (wrkh / chrh)
	bra.s	.set_srow
;					;ELSE
.got_srow:
	clr.l	d2
	move	tw_wrkh_o(a3),d2
	add	tw_chrh_o(a3),d2
	subq	#1,d2
	divu	tw_chrh_o(a3),d2
.set_srow:				;ENDIF
	move	d0,tw_srow_o(a3)
	move	d2,tw_vrow_o(a3)
	bsr	tw_redraw_2		;tw_redraw(2,wrkx,wrky,wrkw,wrkh)
	bra.s	.end_vslide
;				;ELSE  (wrkh / chrh) >= rows
.keep_srow:
	bsr	tw_remarg
.end_vslide:			;ENDIF
	bsr	tw_bars
.done_vslid:
	rts
;
;
upd_c_27:	;Sized
	_debdef	upd_c_27,3
	bsr.s	upd_c_28
	bsr	visi_calc		;recalc tw_vcol & tw_vrow
note_size_sub:
	move.l	tw_wrkw_o(a3),upd_mw(a6)
	clr	d2
	move	tw_chrw_o(a3),d0
	mulu	tw_cols_o(a3),d0
	cmp	upd_mw(a6),d0
	bhs.s	.keep_w
	addq	#1,d2
	move	d0,upd_mw(a6)
.keep_w:
	move	tw_chrh_o(a3),d0
	mulu	tw_rows_o(a3),d0
	cmp	upd_mh(a6),d0
	bhs.s	.keep_h
	addq	#1,d2
	move	d0,upd_mh(a6)
.keep_h:
	tst	d2
	sne	tw_sizl_o(a3)
	bne.s	.limit_size
.size_limited:
	bsr	tw_remarg
	bsr	tw_bars
	rts
;
.limit_size:
	lea	intin(pc),a0
	clr	(a0)+
	move	tw_gads_o(a3),(a0)+
	move.l	tw_wrkx_o(a3),(a0)+
	move.l	upd_mw(a6),(a0)+
	sub_aes	#wind_calc
	lea	intout+2(pc),a0
	move.l	(a0)+,upd_mx(a6)
	move.l	(a0)+,upd_mw(a6)
	bsr.s	upd_c_28
	bsr	visi_calc		;recalc tw_vcol & tw_vrow
	bra.s	.size_limited
;
;
upd_c_28:	;Moved
	_debdef	upd_c_28,3
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),upd_cx(a6)
	move.l	intout+6(pc),upd_cw(a6)
	move.l	upd_mw(a6),intin+8
	move.l	upd_mx(a6),intin+4
	gem_aes	wind_set,tw_wind_o(a3),#5
	move.l	upd_cx(a6),d0
	move.l	upd_cw(a6),d1
	cmp.l	tw_altx_o(a3),d0
	bne.s	.non_alt
	cmp.l	tw_altw_o(a3),d1
	bne.s	.non_alt
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_altx_o(a3)
	move.l	intout+6(pc),tw_altw_o(a3)
.non_alt:
	move.l	upd_cx(a6),d0
	move.l	upd_cw(a6),d1
	cmp.l	tw_refx_o(a3),d0
	bne.s	.non_ref
	cmp.l	tw_refw_o(a3),d1
	bne.s	.non_ref
	gem_aes	wind_get,tw_wind_o(a3),#5
	move.l	intout+2(pc),tw_refx_o(a3)
	move.l	intout+6(pc),tw_refw_o(a3)
.non_ref
work_calc:
	gem_aes	wind_get,tw_wind_o(a3),#4
	move.l	intout+2(pc),tw_wrkx_o(a3)	;inner x.y
	move.l	intout+6(pc),tw_wrkw_o(a3)	;inner w.h
	rts
;
;
endsel_upd:
	move	upd_mt(a6),d0
	swap	d0
	move	tw_wind_o(a3),d0
	unlk	a6
	rts
;
;	ends tw_update
; ----------------------------------------------------------------------------
;
; All functions and procedures below are reserved for internal use ONLY ;;;
; In future versions any or all of them may be abolished/replaced.
;
; ----------------------------------------------------------------------------
;
tw_calc:	;long	tw_calc(long font,short attr)
	_debdef	tw_calc,2
	link	a6,#0
	move.l	8(a6),d0
	bsr.s	find_font
	move.l	d0,a0
	move.b	fnt_pts+1(a0),d0	;fpts
	lsl	#8,d0
	move.b	fnt_dbott+1(a0),d0	;yoff
	swap	d0
	move.b	fnt_cellw+1(a0),d0	;chrw
	lsl	#8,d0
	move.b	fnt_fheight+1(a0),d0	;chrh
	move	12(a6),d1
	and	#$10,d1
	beq.s	.keep_calc
	add.l	#$00010202,d0
.keep_calc:
	unlk	a6
	rts
;
;
find_font:
	_debdef	find_font,2
	tst.l	d0
	bpl.s	.test_font
.force_8_8:
	moveq	#3,d0
.test_font:
	cmp.l	#4,d0
	bgt.s	.gdos_font
	lsl	#2,d0
	move.l	intern_fnt_t(pc,d0),d0
	bra.s	find_font
;
.gdos_font:
	cmp.l	#$800,d0
	blo.s	.force_8_8
	rts
;
;
intern_fnt_t:
	dc.l	ansi_4_5_fnt
	dc.l	ansi_4_6_fnt,ansi_6_6_fnt
	dc.l	ansi_8_8_fnt,ansi_8_16_fnt
;
;
;	ends tw_calc
; ----------------------------------------------------------------------------
;
;long	tw_pfix(thd)
;
; NB: argument "thd" is received in d0, NOT on the stack
;
; Returns (and flags) d0 negative if thd is no legal terminal handle,
; but otherwise returns the corresponding GEM handle in d0.
;
; NB: at exit a3->selected terminal structure
;
tw_pfix:
	_debdef	tw_pfix,2
	link	a6,#0
	cmp	tw_limit(pc),d0
	bhs.s	.err_1
	moveq	#tw_lpow,d1
	lsl	d1,d0
	move.l	tw_link_p(pc),d1
	bmi.s	.err_1
	move.l	d1,a3
	add	d0,a3
	move	tw_wind_o(a3),d0
	bpl	exit_ext_d0
.err_1:
	bra	exit_err_1
;
;	ends tw_pfix
; ----------------------------------------------------------------------------
;
visi_work:
	bsr	work_calc
visi_calc:
	clr.l	d0
	move	tw_chrw_o(a3),d0
	subq	#1,d0
	add	tw_wrkw_o(a3),d0
	divu	tw_chrw_o(a3),d0
	move	tw_cols_o(a3),d1
	sub	tw_scol_o(a3),d1
	cmp	d0,d1
	bls.s	.set_vcol
	move	d0,d1			;d1=min(d0,d1)
.set_vcol:
	move	d1,tw_vcol_o(a3)
	clr.l	d0
	move	tw_chrh_o(a3),d0
	subq	#1,d0
	add	tw_wrkh_o(a3),d0
	divu	tw_chrh_o(a3),d0
	move	tw_rows_o(a3),d1
	sub	tw_srow_o(a3),d1
	cmp	d0,d1
	bls.s	.got_vrow
	move	d0,d1			;d1=min(d0,d1)
.got_vrow:
	move	d1,tw_vrow_o(a3)
	rts
;
;	ends visi_calc & visi_work
; ----------------------------------------------------------------------------
;
tw_remarg:
	_debdef	tw_remarg,2
	bsr	tw_marg
	beq.s	tw_remarg_rts
tw_redraw_2:	;calls tw_redraw(2,tw_wrkx&,tw_wrky&,tw_wrkw&,tw_wrkh&)
	move.l	tw_wrkw_o(a3),-(sp)
	move.l	tw_wrkx_o(a3),-(sp)
	move	#2,-(sp)
	bsr	tw_redraw
	lea	10(sp),sp
tw_remarg_rts:
	rts
;
;	ends	tw_remarg
; ----------------------------------------------------------------------------
;
tw_capture:
	_debdef	tw_capture,2
	tst	tw_capm_o(a3)
	beq.s	.exit
	tst	tw_caph_o(a3)
	beq.s	.exit
	move.l	tw_capb_o(a3),a0
	move.l	tw_capi_o(a3),d1
	move.b	d0,(a0,d1.l)
	addq.l	#1,d1
	move.l	d1,tw_capi_o(a3)
	cmp.l	tw_caps_o(a3),d1
	bhs.s	write_capture
.exit:
	rts
;
;	ends	tw_capture
; ----------------------------------------------------------------------------
;
flush_capture:
	_debdef	flush_capture,2
	tst	tw_capm_o(a3)
	beq.s	capture_exit
	tst	tw_caph_o(a3)
	beq.s	capture_exit
	tst.l	tw_capi_o(a3)
	beq.s	capture_exit
write_capture:
	gemdos	Fwrite|_ind,tw_caph_o(a3),tw_capi_o(a3),tw_capb_o(a3)
	clr.l	tw_capi_o(a3)
capture_exit:
	rts
;
;	ends	flush_capture
; ----------------------------------------------------------------------------
tw_chop:	;void	tw_chop		NB: o/p char in d0
	_debdef	tw_chop,2
	and	#$FF,d0
	move	d0,tw_char_o(a3)
	move	tw_capm_o(a3),d1
	beq.s	.use_proto			;IF capture is on
	tst	tw_caph_o(a3)
	beq.s	.use_proto			;ANDIF capture file linked
	tst.b	d1
	bne.s	.use_proto			;ANDIF capture everything
	bsr	tw_capture			;	tw_capture()
	move	tw_char_o(a3),d0
.use_proto:					;ENDIF
tw_type_jump:
	jmp	(tw_chp0).l			;use protocol via modifiable jmp
;
;	ends	tw_chop
; ----------------------------------------------------------------------------
tw_chp0:	;Standard ASCII character output
	_debdef	tw_chp0,2
	and	#$7F,tw_char_o(a3)
; ----------------------------------------------------------------------------
tw_chp1:	;Atari ASCII character output
	_debdef	tw_chp1,2
	move	tw_char_o(a3),d0
	cmp	#' ',d0
	bhs.s	norm_char
.ctrl_char:
	cmp	#9,d0
	bgt.s	.ctl_gt_9
	beq	vt52_ht
	cmp	#7,d0
	bgt	vt52_bs
	beq	vt52_bl
	rts
;
.ctl_gt_9:
	cmp	#10,d0
	beq	ctrl_lf
	cmp	#13,d0
	beq	ctrl_cr
	rts
;
norm_char:
	_debdef	norm_char,2
	move	tw_capm_o(a3),d1
	beq.s	.use_norm			;IF capture is on
	tst	tw_caph_o(a3)
	beq.s	.use_norm			;ANDIF capture file linked
	tst.b	d1
	beq.s	.use_norm			;ANDIF capture partial
	bsr	tw_capture
	move	tw_char_o(a3),d0
.use_norm:					;ENDIF
	move	tw_lnsz_o(a3),d1
	mulu	tw_crow_o(a3),d1
	move	tw_ccol_o(a3),a0
	add.l	a0,d1			;d1=(tw_lnsz)*tw_crow+tw_ccol
	move.l	tw_txtp_o(a3),a0
	move.l	tw_attp_o(a3),a1
	move.l	tw_colp_o(a3),a2
	move.b	d0,(a0,d1.l)		;buffer character
	move	tw_attr_o(a3),d2
	cmp.b	#' ',d0
	bne.s	.got_attr
.spc_attr:
	bclr	#3,d2			;this masks underline for space
.got_attr:
	move.b	tw_colr_o+1(a3),d0
	btst	#9,d2			;Highlight ?
	beq.s	.keep_colors
	or.b	#$80,d0
	cmp	#3,tw_mclr_o(a3)
	bgt.s	.keep_colors
	beq.s	.highlight_medium
.highlight_high:
	or	#$81,d2
	bra.s	.keep_colors
;
.highlight_medium:
	or	#$81,d2
.keep_colors:
	move.b	d2,(a1,d1.l)		;buffer attributes
	move.b	d0,(a2,d1.l)		;buffer colours
	bsr	tw_mfhide
	move.l	#$10001,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#2,-(sp)
	bsr	tw_retext		;tw_retext(2,tw_ccol,tw_crow,1,1)
	lea	10(sp),sp
	move	tw_ccol_o(a3),d0
	addq	#1,d0
	cmp	tw_cols_o(a3),d0	;next pos within line ?
	bhs.s	.next_line
	swap	d0
	move	tw_crow_o(a3),d0
	bsr	tw_mmovc		;tw_mmovc(tw_ccol+1,tw_crow)
	bra	tw_rshow
;
.next_line:
	btst	#0,tw_attr_o(a3)
	beq	tw_rshow
	move	tw_capm_o(a3),-(sp)
	bsr	crlf_sub
	move	(sp)+,tw_capm_o(a3)
	rts
;
;	ends tw_chp1 & tw_chp0
; ----------------------------------------------------------------------------
tw_chp2:	;Standard VT_52 character output
	_debdef	tw_chp2,2
	and	#$7F,tw_char_o(a3)
; ----------------------------------------------------------------------------
tw_chp3:	;Atari VT_52 character output
	_debdef	tw_chp3,2
	move	tw_char_o(a3),d0
	move	tw_escf_o(a3),d2
	bne.s	.esc_seq
.non_esc:
	cmp	#' ',d0
	bhs	norm_char	;norm_char is part of tw_chp1 above
.ctrl_char:
	cmp	#27,d0
	beq.s	.esc_char
	cmp	#15,d0
	bhi.s	.non_ctl
	lsl	#2,d0
	move.l	.ctl_fn_t(pc,d0),a0
	jmp	(a0)
;
.ctl_fn_t:
	dc.l	.non_ctl,.non_ctl,.non_ctl,.non_ctl
	dc.l	.non_ctl,.non_ctl,.non_ctl,vt52_bl
	dc.l	vt52_bs,vt52_ht,ctrl_lf,ctrl_lf
	dc.l	ctrl_lf,ctrl_cr,.non_ctl,.non_ctl
;
.esc_char:
	move	#$0100,tw_escf_o(a3)
.non_ctl:
	rts
;
.esc_seq:
	cmp.b	#2,tw_escf_o(a3)
	bgt	.esc_code_3
	beq	.esc_code_2
.esc_code_1:
	clr	tw_escf_o(a3)
	tst.b	d0
	bmi	.non_esc
	move	d0,d1
	sub.b	#'<',d1
	blo	.non_esc
	ext d1
	lsl	#2,d1
	move.l	.esc_fn_t(pc,d1),a0
	jmp	(a0)
;
.esc_fn_t:
	dc.l	vt52_esc_lt,.non_ctl,.non_ctl,.non_esc		;<=>?
	dc.l	.non_esc,vt52_esc_ua,vt52_esc_ub,vt52_esc_uc	;@ABC
	dc.l	vt52_esc_ud,vt52_esc_ue,.non_ctl,.non_ctl	;DEFG
	dc.l	vt52_esc_uh,vt52_esc_ui,vt52_esc_uj,vt52_esc_uk	;HIJK
	dc.l	vt52_esc_ul,vt52_esc_um,.non_esc,.non_esc	;LMNO
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;PQRS
	dc.l	.non_esc,.non_esc,.non_esc,.non_ctl		;TUVW
	dc.l	.non_ctl,.take_arg_1,.non_ctl,.non_esc		;XYZ[
	dc.l	.non_esc,.non_ctl,.non_ctl,.non_ctl		;\]^_
	dc.l	.non_esc,.non_esc,.take_arg_1,.take_arg_1	;`abc
	dc.l	vt52_esc_ld,vt52_esc_le,vt52_esc_lf,.non_esc	;defg
	dc.l	.non_esc,.non_esc,vt52_esc_lj,vt52_esc_lk	;hijk
	dc.l	vt52_esc_ll,.non_esc,.non_esc,vt52_esc_lo	;lmno
	dc.l	vt52_esc_lp,vt52_esc_lq,.non_esc,.non_esc	;pqrs
	dc.l	.non_esc,.non_esc,vt52_esc_lv,vt52_esc_lw	;tuvw
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;xyz{
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;|}~
;	
.take_arg_1:
	move	#$0200,d2
	move.b	d0,d2
	move	d2,tw_escf_o(a3)
	rts
;
.esc_code_2
	cmp.b	#'Y',d2			;incomplete esc Y ?
	bne.s	.non_esc_uy
	addq.b	#1,tw_escf_o(a3)	;esc Y needs 3 codes
	move.b	d0,tw_esc2_o(a3)
	rts
;
.non_esc_uy:	;completed b or c
	cmp.b	#'b',d2		;completed esc b ?
	bne.s	.got_esc_lc
.got_esc_lb:			;completed esc b !
	move	tw_colr_o(a3),d1
	and	#$0F,d1
	lsl	#4,d0
	or.b	d0,d1
	move	d1,tw_colr_o(a3)
	clr	tw_escf_o(a3)
	rts
;
.got_esc_lc:			;completed esc c !
	move	tw_colr_o(a3),d1
	and	#$F0,d1
	and	#$0F,d0
	or.b	d0,d1
	move	d1,tw_colr_o(a3)
	clr	tw_escf_o(a3)
	rts
;
.esc_code_3:	;Escape arg 3 completes Y
	clr	tw_escf_o(a3)
	sub	#' ',d0
	and	#$FF,d0
	swap	d0
	move.b	tw_esc2_o(a3),d0
	sub	#' ',d0
	and	#$FF,d0
	bra	tw_movc		;tw_movc(arg3-' ',arg2-' ')
;
;
vt52_esc_lt:	;esc  <
	move	tw_type_o(a3),d0
	add	#2,d0		;set ANSI protocol
	bsr	init_prot_d0
	rts
;
;
vt52_esc_ua:	;esc  A
	move.l	tw_ccol_o(a3),d0
	tst	d0
	beq.s	.skip_move
	subq	#1,d0
	bra	tw_movc		;tw_movc(tw_ccol&,tw_crow&-1)
;
.skip_move:
	rts
;
;
vt52_esc_ub:	;esc  B
	move.l	tw_ccol_o(a3),d0
	addq	#1,d0
	cmp	tw_rows_o(a3),d0
	bhs.s	.skip_move
	bra	tw_movc		;tw_movc(tw_ccol&,tw_crow&+1)
;
.skip_move:
	rts
;
;
vt52_esc_uc:	;esc  C
	move.l	tw_ccol_o(a3),d0
	swap	d0
	addq	#1,d0
	cmp	tw_cols_o(a3),d0
	bhs.s	.skip_move
	swap	d0
	bra	tw_movc		;tw_movc(tw_ccol&+1,tw_crow&)
;
.skip_move:
	rts
;
;
vt52_esc_ud:	;esc  D
	move.l	tw_ccol_o(a3),d0
	swap	d0
	tst	d0
	beq.s	.skip_move
	subq	#1,d0
	swap	d0
	bra	tw_movc		;tw_movc(tw_ccol&-1,tw_crow&)
;
.skip_move:
	rts
;
;
vt52_esc_ue:	;esc  E
	move	tw_lock_o(a3),-(sp)
	beq.s	.no_lock_1
	clr	tw_lock_o(a3)
.no_lock_1:
	clr.l	d0
	bsr	tw_mmovc	;tw_mmovc(0,0)
	clr.l	d0
	move.l	tw_cols_o(a3),d1
	bsr	tw_cls		;tw_cls(0,0,tw_cols&,tw_rows&)
	tst	(sp)+
	beq.s	.no_lock_2
	move	#1,tw_lock_o(a3)
.no_lock_2:
	rts
;
;
vt52_esc_uh:	;esc  H
	clr.l	d0
	bra	tw_movc		;tw_movc(0,0)
;
;
vt52_esc_ui:	;esc  I
	move.l	tw_ccol_o(a3),d0
	tst	d0
	beq.s	.need_scroll
	subq	#1,d0
	bra	tw_movc		;tw_movc(tw_ccol&,tw_crow&-1)
;
.need_scroll:
	moveq	#-1,d0
	clr	d0
	bra	tw_scrl		;tw_scrl(-1,0)
;
;
vt52_esc_uj:	;esc  J
	move.l	tw_ccol_o(a3),d0
	move	tw_cols_o(a3),d1
	sub	tw_ccol_o(a3),d1
	swap	d1
	move	#1,d1
	bsr	tw_cls		;tw_cls(tw_ccol&,tw_crow&,tw_cols&-tw_ccol&,1)
	clr.l	d0
	move	tw_crow_o(a3),d0
	addq	#1,d0
	move.l	tw_cols_o(a3),d1
	cmp	d1,d0
	bhs.s	.skip_cls
	sub	d0,d1
	bra	tw_cls		;tw_cls(0,tw_crow&+1,tw_cols&,tw_rows&-(tw_crow&+1))
;
.skip_cls:
	rts
;
;
vt52_esc_uk:	;esc  K
	move.l	tw_ccol_o(a3),d0
	move	tw_cols_o(a3),d1
	sub	tw_ccol_o(a3),d1
	swap	d1
	move	#1,d1
	bra	tw_cls		;tw_cls(tw_ccol&,tw_crow&,tw_cols&-tw_ccol&,1)
;
;
tw_insr:
	subq	#1,d0
	blt.s	.exit
.loop:
	move	d0,-(sp)
	bsr.s	vt52_esc_ul
	move	(sp)+,d0
	dbra	d0,.loop
.exit:
	rts
;
;
vt52_esc_ul:	;esc  L
	moveq	#-1,d0
	move	tw_crow_o(a3),d0
	bsr	tw_scrl		;tw_scrl(-1,tw_crow&)
	clr.l	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc		;tw_movc(0,tw_crow&)
;
;
tw_delr:
	subq	#1,d0
	blt.s	.exit
.loop:
	move	d0,-(sp)
	bsr.s	vt52_esc_um
	move	(sp)+,d0
	dbra	d0,.loop
.exit:
	rts
;
;
vt52_esc_um:	;esc  M
	clr.l	d0
	move	tw_crow_o(a3),d0
	bsr	tw_scrl		;tw_scrl(0,tw_crow&)
	clr.l	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc		;tw_movc(0,tw_crow&)
;
;
vt52_esc_ld:	;esc  d
	clr.l	d0
	move.l	tw_cols_o(a3),d1
	move	tw_crow_o(a3),d1
	beq.s	.skip_cls_above
	bsr	tw_cls		;tw_cls(0,0,tw_cols&,tw_crow&)
.skip_cls_above:
	move	tw_ccol_o(a3),d1
	beq.s	.skip_cls_left
	swap	d1
	move	#1,d1
	clr.l	d0
	move	tw_crow_o(a3),d0
	bra	tw_cls		;tw_cls(0,tw_crow&,tw_ccol&,1)
;
.skip_cls_left:
	rts
;
;
vt52_esc_le:	;esc  e
	bra	tw_show
;
;
vt52_esc_lf:	;esc  f
	bra	tw_hide
;
;
vt52_esc_lj:	;esc  j
	bra	tw_push
;
;
vt52_esc_lk:	;esc  k
	bra	tw_pull
;
;
vt52_esc_ll:	;esc  l
	clr.l	d0
	move	tw_crow_o(a3),d0
	bsr	tw_movc		;tw_movc(0,tw_crow&)
	move.l	tw_ccol_o(a3),d0
	move.l	tw_cols_o(a3),d1
	move	#1,d1
	bra	tw_cls		;tw_cls(0,tw_crow&,tw_cols&,1)
;
;
vt52_esc_lo:	;esc  o
	clr.l	d0
	move.l	tw_ccol_o(a3),d1
	move	d1,d0
	cmp.l	d0,d1
	beq.s	.skip_cls
	move	#1,d1
	bra	tw_cls		;tw_cls(0,tw_crow&,tw_ccol&,1)
;
.skip_cls
	rts
;
;
vt52_esc_lp:	;esc  p
	or	#$80,tw_attr_o(a3)
	rts
;
;
vt52_esc_lq:	;esc  q
	and	#$FF7F,tw_attr_o(a3)
	rts
;
;
vt52_esc_lv:	;esc  v
	or	#$100,tw_attr_o(a3)
	rts
;
;
vt52_esc_lw:	;esc  w
	and	#$FEFF,tw_attr_o(a3)
	rts
;
;
;ends tw_chp3 & tw_chp2
; ----------------------------------------------------------------------------
tw_chp4:	;7-bit ANSI character output
	_debdef	tw_chp2,2
	and	#$7F,tw_char_o(a3)
; ----------------------------------------------------------------------------
tw_chp5:	;Atari 8-bit ANSI character output
	_debdef	tw_chp3,2
	move	tw_char_o(a3),d0
	move	tw_escf_o(a3),d2
; escf < 0  == special escape sequence
;	 80xx  == normal CSI sequence awaiting number  (xx = old numbers)
;	 81xx  == normal CSI sequence reading number   (xx = old numbers)
;	 82xx  == escape to ignore 1 extra char
;	 84xx  == CSI ? Pn l  or  CSI ? Pn h  sequence  (xx = old numbers)
; escf > 0  == initial escape sequence
; escf = 0  == not escape sequence
	bmi	.csi_seq
	bne.s	.esc_seq
.non_esc:
	cmp	#$9B,d0
	beq	.set_csi
	cmp	#' ',d0
	bhs	norm_char	;norm_char is part of tw_chp1 above
.ctrl_char:
	cmp	#$1B,d0
	beq.s	.esc_char
	cmp	#15,d0
	bhi.s	.non_ctl
	lsl	#2,d0
	move.l	.ctl_fn_t(pc,d0),a0
	jmp	(a0)
;
.ctl_fn_t:
	dc.l	.non_ctl,.non_ctl,.non_ctl,.non_ctl
	dc.l	.non_ctl,.non_ctl,.non_ctl,vt52_bl
	dc.l	vt52_bs,ansi_ht,ctrl_lf,.non_ctl
	dc.l	vt52_esc_ue,ctrl_cr,.non_ctl,.non_ctl
;
.esc_char:
	move	#$0100,tw_escf_o(a3)
.non_ctl:
	rts
;
.esc_seq:
	clr	tw_escf_o(a3)
	tst.b	d0
	bmi	.non_esc
	move	d0,d1
	sub.b	#' ',d1
	blo	.non_esc
	ext d1
	lsl	#2,d1
	move.l	.esc_fn_t(pc,d1),a0
	jmp	(a0)
;
.esc_fn_t:
	dc.l	.non_esc,.non_esc,.non_esc,ansi_esc_item	; !"#
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;$%&'
	dc.l	ansi_esc_lp,ansi_esc_rp,.non_esc,.non_esc	;()*+
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;,-./
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;0123
	dc.l	.non_esc,.non_esc,.non_esc,ansi_esc_7		;4567
	dc.l	ansi_esc_8,.non_esc,.non_esc,.non_esc		;89:;
	dc.l	.non_esc,.non_ctl,.non_ctl,.non_esc		;<=>?
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;@ABC
	dc.l	ansi_esc_ud,crlf_sub,.non_ctl,.non_ctl		;DEFG
	dc.l	ansi_esc_uh,.non_ctl,.non_ctl,.non_ctl		;HIJK
	dc.l	.non_ctl,ansi_esc_um,.non_ctl,.non_ctl		;LMNO
	dc.l	.non_ctl,.non_ctl,.non_ctl,.non_ctl		;PQRS
	dc.l	.non_esc,.non_ctl,.non_esc,.non_ctl		;TUVW
	dc.l	.non_esc,.non_ctl,ansi_esc_uz,.set_csi		;XYZ[
	dc.l	.non_ctl,.non_ctl,.non_ctl,.non_esc		;\]^_
	dc.l	.non_esc,.non_ctl,.non_ctl,ansi_esc_lc		;`abc
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;defg
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;hijk
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;lmno
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;pqrs
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;tuvw
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;xyz{
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;|}~
;	
.set_csi:
	move	#$8000,tw_escf_o(a3)
	move.l	#-1,tw_csit_o(a3)
	clr	tw_esc2_o(a3)
	rts
;
.csi_seq:
; d2 =	 80xx  == normal CSI sequence awaiting number  (xx = old numbers)
; d2 =	 81xx  == normal CSI sequence reading number   (xx = old numbers)
; d2 =	 82xx  == escape to ignore 1 extra char
; d2 =	 84xx  == CSI ? Pn l  or  CSI ? Pn h  sequence  (xx = old numbers)
	btst	#9,d2
	bne	ansi_ign_ch
	btst	#10,d2
	bne	.csi_qm_seq
	cmp.b	#'0',d0
	blo.s	.csi_newnum
	cmp.b	#'9',d0
	bhi.s	.csi_newnum
	move	#10,d1
	mulu	tw_esc2_o(a3),d1
	and	#$FF,d0
	sub	#'0',d0
	add	d0,d1
	move	d1,tw_esc2_o(a3)
	bset	#0,tw_escf_o(a3)
	rts
;
.csi_newnum:
	move	tw_esc2_o(a3),d1
	clr	tw_esc2_o(a3)
	bclr	#0,tw_escf_o(a3)
	bne.s	.keep_newnum
	moveq	#-1,d1
.keep_newnum:
	move.b	tw_esc1_o(a3),d2
	and	#3,d2
	add	d2,d2
	move	d1,tw_csit_o(a3,d2)
	addq.b	#1,tw_esc1_o(a3)
	cmp.b	#';',d0
	bne.s	.csi_final
	move	#-1,tw_csit_o+2(a3,d2)
	rts
;
.csi_final:
	move.l	tw_csit_o(a3),D3
	swap	d3
	move.b	tw_esc1_o(a3),d2
	clr	tw_escf_o(a3)
	and	#$FF,d2
	cmp	#8,d2
	bls.s	.keep_argc
	moveq	#8,d2
.keep_argc:
	tst.b	d0
	bmi	.non_esc
	move	d0,d1
	sub.b	#' ',d1
	blo	.non_esc
	ext d1
	lsl	#2,d1
	move.l	.csi_fn_t(pc,d1),a0
	jmp	(a0)
;
.csi_fn_t:
	dc.l	ansi_csi_sp,.non_esc,.non_esc,.non_esc		; !"#
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;$%&'
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;()*+
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;,-./
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;0123
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;4567
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;89:;
	dc.l	.non_esc,.non_esc,.non_esc,ansi_csi_qm		;<=>?
	dc.l	ansi_csi_at,ansi_csi_ua,ansi_csi_ub,ansi_csi_uc	;@ABC
	dc.l	ansi_csi_ud,ansi_csi_ue,ansi_csi_uf,ansi_csi_ug	;DEFG
	dc.l	ansi_csi_uh,ansi_csi_ui,ansi_csi_uj,ansi_csi_uk	;HIJK
	dc.l	ansi_csi_ul,ansi_csi_um,ansi_csi_un,ansi_csi_uo	;LMNO
	dc.l	ansi_csi_up,ansi_csi_uq,ansi_csi_ur,ansi_csi_us	;PQRS
	dc.l	ansi_csi_ut,ansi_csi_uu,ansi_csi_uv,ansi_csi_uw	;TUVW
	dc.l	ansi_csi_ux,ansi_csi_uy,ansi_csi_uz,.non_esc	;XYZ[
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;\]^_
	dc.l	ansi_csi_bq,ansi_csi_la,ansi_csi_lb,ansi_csi_lc	;`abc
	dc.l	ansi_csi_ld,ansi_csi_le,ansi_csi_lf,ansi_csi_lg	;defg
	dc.l	ansi_csi_lh,.non_esc,.non_esc,.non_esc		;hijk
	dc.l	ansi_csi_ll,ansi_csi_lm,ansi_csi_ln,ansi_csi_lo	;lmno
	dc.l	.non_esc,ansi_csi_lq,ansi_csi_lr,ansi_csi_ls	;pqrs
	dc.l	.non_esc,ansi_csi_lu,.non_esc,.non_esc		;tuvw
	dc.l	ansi_csi_lx,ansi_csi_ly,.non_esc,.non_esc		;xyz{
	dc.l	.non_esc,.non_esc,.non_esc,.non_esc		;|}~
;	
;
.csi_qm_seq:
	cmp.b	#'0',d0
	blo.s	.csi_qm_new
	cmp.b	#'9',d0
	bhi.s	.csi_qm_new
	move	#10,d1
	mulu	tw_esc2_o(a3),d1
	and	#$FF,d0
	sub	#'0',d0
	add	d0,d1
	move	d1,tw_esc2_o(a3)
	bset	#0,tw_escf_o(a3)
	rts
;
.csi_qm_new:
	move	tw_esc2_o(a3),d1
	clr	tw_esc2_o(a3)
	bclr	#0,tw_escf_o(a3)
	bne.s	.keep_qm_new
	moveq	#-1,d1
.keep_qm_new:
	move.b	tw_esc1_o(a3),d2
	and	#7,d2
	add	d2,d2
	move	d1,tw_csit_o(a3,d2)
	addq.b	#1,tw_esc1_o(a3)
	cmp.b	#';',d0
	bne.s	.csi_qm_fin
	move	#-1,tw_csit_o+2(a3,d2)
	rts
;
.csi_qm_fin:
	move.l	tw_csit_o(a3),D3
	swap	d3
	move.b	tw_esc1_o(a3),d2
	clr	tw_escf_o(a3)
	and	#$FF,d2
	cmp	#8,d2
	bls.s	.keep_qm_argc
	moveq	#8,d2
.keep_qm_argc:
	cmp	#'l',d0
	beq.s	csi_qm_clr
	cmp	#'h',d0
	bne	.non_esc
csi_qm_set:
	cmp	#5,d3
	bne.s	.not_set_reverse
	bset	#7,tw_attr_o+1(a3)	;set reverse video mode
	rts
;
.not_set_reverse:
	cmp	#7,d3
	bne.s	.not_set_wrap
	or	#$0100,tw_attr_o(a3)	;set line_wrap mode
	rts
;
.not_set_wrap:
	rts
;
csi_qm_clr:
	cmp	#2,d3
	bne.s	.not_use_vt52
	move	tw_type_o(a3),d0
	subq	#2,d0			;set VT52 protocol
	bsr	init_prot_d0
	rts
;
.not_use_vt52:
	cmp	#5,d3
	bne.s	.not_clr_reverse
	bclr	#7,tw_attr_o+1(a3)	;clr reverse video mode
	rts
;
.not_clr_reverse:
	cmp	#7,d3
	bne.s	.not_clr_wrap
	and	#$FEFF,tw_attr_o(a3)	;clr line_wrap mode
	rts
;
.not_clr_wrap:
	rts
;
;
ansi_csi_sp:
ansi_esc_item:
ansi_esc_lp:
ansi_esc_rp:
	move	#$8200,tw_escf_o(a3)
	move.l	#-1,tw_csit_o(a3)
	rts
;
;
ansi_csi_un:
ansi_csi_uo:
ansi_csi_uq:
ansi_csi_ur:
ansi_csi_uw:
ansi_csi_uy:
;
ansi_csi_lb:
ansi_csi_lh:
ansi_csi_ll:
ansi_csi_lo:
ansi_csi_lq:
ansi_csi_lx:
;
ansi_ign_ch:
	clr	tw_escf_o(a3)
	rts
;
;
ansi_csi_lc:	;request Device Attributes
	subq	#1,d2			;any arguments received ?
	bgt.s	bad_csi_lc
	blt.s	.csi_lc_ok
	lea	tw_csit_o(a3),a1
	move	(a1)+,d1
	cmp	#0,d1
	bne.s	bad_csi_lc
.csi_lc_ok:
ansi_esc_uz:
	lea	dev_attr_resp_s(pc),a0
	bra	set_response
;
bad_csi_lc:
	rts
;
dev_attr_resp_s:
	dc.b	ESC,'[?1;2c',NUL
	even
;
;
ansi_esc_uh:	;Set a tab stop at cursor
	move	tw_ccol_o(a3),d3
	and	#$FF,d3
	beq.s	.exit
	move	d3,d2
	subq	#1,d2
	move.l	tw_http_o(a3),a0
	move.b	(a0,d2),d1
	cmp.b	d1,d3
	beq.s	.exit
.loop:
	move.b	d3,(a0,d2)
	cmp.b	-1(a0,d2),d1
	dbne	d2,.loop
.exit:
	rts
;
;
ansi_esc_lc:	;Reset terminal to initial state
reset_terminal:
;patch this for future complete implementation changes
	clr	tw_escf_o(a3)
	clr	tw_attr_o(a3)
	clr	tw_stix_o(a3)
	move	#$70,tw_colr_o(a3)
	clr	tw_tops_o(a3)
	move	tw_rows_o(a3),d0
	subq	#1,d0
	move	d0,tw_bots_o(a3)
	move	tw_attr_o(a3),-(sp)
	move.l	tw_fntp_o(a3),-(sp)
	bsr	tw_calc
	addq	#6,sp
	clr.l	d1
	move	d0,d1
	lsl.l	#8,d1
	lsr	#8,d1
	move.l	d1,tw_chrw_o(a3)	;store tw_chrw & tw_chrh
	swap	d0
	move.b	d0,d1
	ext	d1
	move	d1,tw_yoff_o(a3)
	lsr	#8,d0
	move	d0,tw_fpts_o(a3)
	bsr	visi_calc		;recalc tw_vcol & tw_vrow
	bsr	tw_marg
	bsr	tw_redraw_2	;tw_redraw(2,tw_wrkx,tw_wrky,tw_wrkw,tw_wrkh)
	bsr	note_size
	rts
;
;
ansi_csi_qm:		;start CSI ? sequence
	move.b	#$84,tw_escf_o(a3)
	rts
;
;
ansi_csi_at:	;insert p1 blank character(s) at C
	move	d3,d0
	bpl.s	.do_it
	moveq	#1,d0
.do_it:
	bra	tw_insp
;
;
ansi_csi_ua:	;move C up p1 row(s)
	move.l	tw_ccol_o(a3),d0
	tst	d3
	bgt.s	.do_it
	move	#1,d3
.do_it:
	sub	d3,d0
	bge.s	.keep_it
	clr	d0
.keep_it:
	bra	tw_movc
;
;
ansi_csi_ub:	;move C down p1 row(s)
ansi_csi_le:	;step C down p1 row(s)
	move.l	tw_ccol_o(a3),d0
	tst	d3
	bpl.s	.do_it
	move	#1,d3
.do_it:
	add	d3,d0
	bra	tw_movc
;
;
ansi_csi_uc:	;move C right p1 column(s)
ansi_csi_la:	;step C right p1 column(s)
	tst	d3
	bge.s	.do_it
	moveq	#1,d3
.do_it:
	move	tw_ccol_o(a3),d0
	add	d3,d0
	swap	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc
;
;
ansi_csi_ud:	;move C left p1 column(s)
	tst	d3
	bge.s	.do_it
	moveq	#1,d3
.do_it:
	move	tw_ccol_o(a3),d0
	sub	d3,d0
	bge.s	.keep_it
	clr	d0
.keep_it:
	swap	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc
;
;
ansi_csi_ue:	;move C down p1 row(s) and to BOL
	clr.l	d0
	move	d3,d0
	bpl.s	.do_it
	moveq	#1,d0
.do_it:
	add	tw_crow_o(a3),d0
	bra	tw_movc
;
;
ansi_csi_uf:	;move C up p1 row(s) and to BOL
	clr.l	d0
	move	d3,d0
	bpl.s	.do_it
	moveq	#1,d0
.do_it:
	sub	tw_crow_o(a3),d0
	neg	d0
	bra	tw_movc
;
;
ansi_csi_uh:	;move C to p2.p1  (same as ansi_csi_lf)
ansi_csi_lf:	;move C to p2.p1  (same as ansi_csi_uh)
	move.l	d3,d0
	swap	d0
	tst	d0
	bgt.s	.keep_col
	move	#1,d0
.keep_col:
	swap	d0
	tst	d0
	bgt.s	.keep_row
	move	#1,d0
.keep_row:
	sub.l	#$00010001,d0
	bra	tw_movc
;
;
ansi_csi_ui:	;move C forward p1 tab stop(s)
	subq	#1,d3
	bpl.s	.do_it
	moveq	#0,d3
.do_it:
	move	d3,-(sp)
	clr.l	d0
	bsr	ansi_ht
	move	(sp)+,d3
	dbra	d3,.do_it
	rts
;
;
ansi_csi_uj:	;erase: 0=>C_to_EOS  1=>BOS_to_C  2=>whole_screen
	cmp	#1,d3
	blt	vt52_esc_uj
	beq	vt52_esc_ld
	bra	vt52_esc_ue
;
;
ansi_csi_uk:	;erase: 0=>C_to_EOL  1=>BOL_to_C  2=>whole_line
	cmp	#1,d3
	blt	vt52_esc_uk
	beq	vt52_esc_lo
	bra	vt52_esc_ll
;
;
ansi_csi_ul:	;insert p1 line(s) at C (auto CR ?)
	move	d3,d0
	bpl.s	.do_it
	moveq	#1,d0
.do_it:
	bra	tw_insr
;
;
ansi_csi_um:	;remove p1 line(s) at C (auto CR ?)
	move	d3,d0
	bpl.s	.do_it
	moveq	#1,d0
.do_it:
	bra	tw_delr
;
;
ansi_csi_up:	;remove p1 characters at C
	move	d3,d0
	bpl.s	.do_it
	moveq	#1,d0
.do_it:
	bra	tw_delp
;
;
ansi_csi_us:	;scroll up p1 line(s)
	subq	#1,d3
	bpl.s	.do_it
	moveq	#0,d3
.do_it:
	move	d3,-(sp)
	clr.l	d0
	move	tw_tops_o(a3),d0
	bsr	tw_scrl_reg
	move	(sp)+,d3
	dbra	d3,.do_it
	rts
;
;
ansi_esc_ud:		;scroll ANSI region up
	clr.l	d0
	move	tw_tops_o(a3),d0
	bra	tw_scrl_reg
;
;
ansi_csi_ut:	;scroll down p1 line(s)
	subq	#1,d3
	bpl.s	.do_it
	moveq	#0,d3
.do_it:
	move	d3,-(sp)
	moveq	#-1,d0
	move	tw_tops_o(a3),d0
	bsr	tw_scrl_reg
	move	(sp)+,d3
	dbra	d3,.do_it
	rts
;
;
ansi_esc_um:		;scroll ANSI region down
	moveq	#-1,d0
	move	tw_tops_o(a3),d0
	bra	tw_scrl_reg
;
;
ansi_csi_uu:	;move p1 page(s) forward
;
;patch this for future implementation
;
	rts
;
;
ansi_csi_uv:	;move p1 page(s) back
ansi_csi_ly:	;move p1 preceding pages
;
;patch this for future implementation
;
	rts
;
;
ansi_csi_ux:	;erase: p1 character(s)
	move	d3,d1
	bpl.s	.do_it
	moveq	#1,d1
.do_it:
	swap	d1
	move	#1,d1
	move.l	tw_ccol_o(a3),d0
	bra	tw_cls
;
;
ansi_csi_uz:	;move C back p1 tab stop(s)
	subq	#1,d3
	bpl.s	.do_it
	moveq	#0,d3
.do_it:
	move	d3,-(sp)
	clr.l	d0
	bsr	ansi_back_ht
	move	(sp)+,d3
	dbra	d3,.do_it
	rts
;
;
ansi_csi_ug:	;move C to column p1
ansi_csi_bq:	;move C to column p1
	move	d3,d0
	bgt.s	.do_it
	moveq	#1,d0
.do_it:
	subq	#1,d0
	swap	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc
;
;
ansi_csi_ld:	;move C to row p1
	move.l	tw_ccol_o(a3),d0
	move	d3,d0
	bgt.s	.do_it
	moveq	#1,d0
.do_it:
	subq	#1,d0
	bra	tw_movc

;
;
ansi_csi_lg:	;clear tab stop(s): 0=>at_C  3=>all
;
;patch this for future implementation
;
	tst	d3
	bpl.s	.do_it
	clr	d3
.do_it:
	cmp	#3,d3
	beq.s	clr_all_tabs
	move	tw_ccol_o(a3),d0
	cmp	#0,d3
	beq.s	clr_1_tab
	rts
;
clr_1_tab:	;removes a tab stop at column d0
	move	d0,d3
	and	#$FF,d3
	move	d3,d2
	subq	#1,d2
	blt.s	.exit
	move.l	tw_http_o(a3),a0
	move.b	(a0,d3),d1
.loop:
	cmp.b	(a0,d2),d3
	bne.s	.exit
	move.b	d1,(a0,d2)
	dbra	d2,.loop
.exit:
	rts
;
clr_all_tabs:	;removes all tab stops
	moveq	#256/4-1,d2
	move.l	tw_http_o(a3),a0
.loop:
	clr.l	(a0)+
	dbra	d2,.loop
	rts
;
;
ansi_csi_lm:	;set graphic rendition: multiple arguments!
;	00 =>	Clr each of: bold, blink, blank, underscore, highlight, inverse ;,
;		and reset foreground and background colours to 7,0
;	01 =>	Set highlight
;	02 =>	Clr highlight
;	03 =>	Set italic
;	04 =>	Set underscore
;	05 =>	Set blink
;	06 =>	RESERVE
;	07 =>	Set reverse
;	08 =>	Set blank
;	10-12=>	Set font 0-2
;	3x =>	Set fg colour x \/ 0=Black  1=Red      2=Green  3=Yellow
;	4x =>	Set bg colour x /\ 4=Blue   5=Magenta  6=Cyan   7=White
;
	subq	#1,d2			;any arguments received ?
	bpl.s	.do_it_1
	clr	d2			;else set 1 argument
	clr	tw_csit_o(a3)		;default to normalize video
.do_it_1:
	lea	tw_csit_o(a3),a1
.loop:					;loop start for each argument
	move	(a1)+,d1
	bpl.s	.do_it_2
	clr	d1
.do_it_2:
	cmp	#48,d1
	bhs.s	.skip_it
	movem.l	d2/a1,-(sp)
	move	d1,d0
	lsl	#2,d1
	move.l	csi_lm_t(pc,d1),a0
	jsr	(a0)
	movem.l	(sp)+,d2/a1
.skip_it:
	dbra	d2,.loop		;loop back for each argument
csi_lm_xx:
	rts
;
csi_lm_t:
	dc.l	csi_lm_00,csi_lm_01,csi_lm_02,csi_lm_03,csi_lm_04
	dc.l	csi_lm_05,csi_lm_06,csi_lm_07,csi_lm_08,csi_lm_xx
	dc.l	csi_lm_10,csi_lm_11,csi_lm_12,csi_lm_xx,csi_lm_xx
	dc.l	csi_lm_xx,csi_lm_xx,csi_lm_xx,csi_lm_xx,csi_lm_xx
	dc.l	csi_lm_xx,csi_lm_xx,csi_lm_xx,csi_lm_xx,csi_lm_xx
	dc.l	csi_lm_xx,csi_lm_xx,csi_lm_xx,csi_lm_xx,csi_lm_xx
	dc.l	csi_lm_3x,csi_lm_3x,csi_lm_3x,csi_lm_3x,csi_lm_3x
	dc.l	csi_lm_3x,csi_lm_3x,csi_lm_3x,csi_lm_xx,csi_lm_xx
	dc.l	csi_lm_4x,csi_lm_4x,csi_lm_4x,csi_lm_4x,csi_lm_4x
	dc.l	csi_lm_4x,csi_lm_4x,csi_lm_4x
;
csi_lm_00:	;00 =>	Clr each of: bold, blink, blank, underscore, highlight, inverse;.
;defs:	bold=bold  ghost=blink  underline=underscore $200=highlight $400=blank
;	italic=italic inverse=inverse
;	also normalizes foreground and background colours
	and	#$F970,tw_attr_o(a3)	;normal attributes
	move	#$70,tw_colr_o(a3)	;colours white on black
	rts
;
;
csi_lm_01:	;01 =>	Set highlight
	or	#$0200,tw_attr_o(a3)
	rts
;
;
csi_lm_02:	;02 =>	Clr highlight	== combined underline & 
	and	#$FDFF,tw_attr_o(a3)
	rts
;
;
csi_lm_03:	;03 =>	Set italic	== italic
	or	#$0004,tw_attr_o(a3)
	rts
;
;
csi_lm_04:	;04 =>	Set underscore	== underline
	or	#$0008,tw_attr_o(a3)
	rts
;
;
csi_lm_05:	;05 =>	Set blink	== ghost
	or	#$0002,tw_attr_o(a3)
	rts
;
;
csi_lm_06:	;06 =>	RESERVE
;
;patch this for future implementation
;
	rts
;
;
csi_lm_07:	;07 =>	Set reverse	== inverse
	or	#$0080,tw_attr_o(a3)
	rts
;
;
csi_lm_08:	;08 =>	Set blank	== undefined
	or	#$0400,tw_attr_o(a3)
	rts
;
;
csi_lm_10:	;10-12=>	Set font 0-2	\ / IBM specific
csi_lm_11:	;10-12=>	Set font 0-2	 X  therefore
csi_lm_12:	;10-12=>	Set font 0-2	/ \ ignored
;
;patch this for future implementation
;
	rts
;
;
csi_lm_3x:	;3x =>	Set fg colour x \/ 1=Red    2=Green  3=Yellow ... 6=Cyan
	sub	#30,d0
	and	#$0F,d0
	lsl	#4,d0
	move	tw_colr_o(a3),d1
	and	#$0F,d1
	or	d1,d0
	move	d0,tw_colr_o(a3)
	rts
;
;
csi_lm_4x:	;4x =>	Set bg colour x /\ 1=Red  ...  4=Blue  5=Magenta  6=Cyan
	sub	#40,d0
	and	#$0F,d0
	move	tw_colr_o(a3),d1
	and	#$F0,d1
	or	d1,d0
	move	d0,tw_colr_o(a3)
	rts
;
;
ansi_csi_ln:	;device status report of type p1
;	05 =>	terminal status, answer:	CSI 0 n  (if ready)
;	06 =>	cursor position answer:		CSI p1 ; p2 R  (p1=row p2=column)
;	15 =>	printer status, answer: unknown !!!
;
	subq	#1,d2			;any arguments received ?
	bne.s	.bad_csi_ln
	lea	tw_csit_o(a3),a1
	move	(a1)+,d1
	cmp	#5,d1
	beq.s	.csi_ln_status
	cmp	#6,d1
	beq.s	.csi_ln_position
.bad_csi_ln:
	rts
;
.csi_ln_status:
	lea	status_resp_s(pc),a0
	bra.s	set_response
;
.csi_ln_position:
	lea	position_resp_s+2(pc),a0
	move	tw_crow_o(a3),d0
	bsr.s	put_dig
	move.b	#';',(a0)+
	move	tw_ccol_o(a3),d0
	bsr.s	put_dig
	move.b	#'R',(a0)+
	clr.b	(a0)+
	lea	position_resp_s(pc),a0
	bra.s	set_response
;
status_resp_s:
	dc.b	ESC,'[0n',NUL
	even
;
position_resp_s:
	dc.b	ESC,'[00000;00000R',NUL
	even
;
set_response:
	move.l	a0,tw_resp_o(a3)
	clr	tw_escf_o(a3)
	rts
;
;
put_dig:
	movem.l	d1/a1,-(sp)
	lea	.digbuf_end(pc),a1
.loop_1:
	divu	#10,d0
	swap	d0
	move	d0,d1
	add	#'0',d1
	move.b	d1,-(a1)
	clr	d0
	swap	d0
	tst	d0
	bne.s	.loop_1
.loop_2
	move.b	(a1)+,(a0)+
	bne.s	.loop_2
	subq	#1,a0
	movem.l	(sp)+,d1/a1
	rts
;
.digbuf_s:
	dc.b	'0000000000'
.digbuf_end:
	dc.b	NUL
	even
;
;
ansi_csi_lr:	;define scroll region at row p1 to row p2
;
;patch this for future implementation
;
	tst	d3
	bgt.s	.keep_tops
	move	#1,d3
.keep_tops:
	swap	d3
	tst	d3
	bgt.s	.keep_bots
	move	#1,d3
.keep_bots:
	sub.l	#$00010001,d3
	move.l	d3,tw_tops_o(a3)	;tw_tops.tw.bots = d3
	rts
;
;
ansi_esc_7:
ansi_csi_ls:	;save current C, font and attributes
	bra	tw_push
;
;
ansi_esc_8:
ansi_csi_lu:	;restore saved C, font and attributes
	bra	tw_pull
;
;
;ends tw_chp5 & tw_chp4
; ----------------------------------------------------------------------------
ansi_ht:			;ANSI horizontal tabulation
	move	tw_ccol_o(a3),d0
	and	#$FF,d0
	move.l	tw_http_o(a3),a0
	move.b	(a0,d0),d0
	cmp	tw_cols_o(a3),d0
	blt.s	.keep_tab
	move	tw_cols_o(a3),d0
	subq	#1,d0
.keep_tab:
	move	d0,d1
	sub	tw_ccol_o(a3),d1
	ble.s	.skip_tab
	swap	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc	;tw_movc(tw_ccol&+cols&,tw_crow&)
;
.skip_tab:
	rts
;
;	ends ansi_ht
; ----------------------------------------------------------------------------
ansi_back_ht:			;ANSI backwards horizontal tabulation
	move	tw_ccol_o(a3),d0
	and	#$FF,d0
	beq.s	.skip_tab
	move	d0,d2
	move.l	tw_http_o(a3),a0
	subq	#1,d2
.loop:
	cmp.b	(a0,d2),d0
	dbhi	d2,.loop
	bhi.s	.gotcha
	clr	d0
	bra.s	.keep_tab
;
.gotcha:
	move.b	(a0,d2),d0
	cmp	tw_cols_o(a3),d0
	blt.s	.keep_tab
	move	tw_cols_o(a3),d0
	subq	#1,d0
.keep_tab:
	swap	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc	;tw_movc(tw_ccol&+cols&,tw_crow&)
;
.skip_tab:
	rts
;
;	ends ansi_back_ht
; ----------------------------------------------------------------------------
;
vt52_bl:			;VT_52 Bell
	bios	Bconout,#2,#7
	rts
;
;	ends vt52_bl
; ----------------------------------------------------------------------------
vt52_bs:			;VT_52 backspace
	move	tw_ccol_o(a3),d0
	ble.s	.skip_bs
	subq	#1,d0
	swap	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc		;tw_movc(tw_ccol&-1,tw_crow&)
;
.skip_bs:
	rts
;
;	ends vt52_bs
; ----------------------------------------------------------------------------
vt52_ht:			;VT_52 horizontal tabulation
	move	tw_ccol_o(a3),d0
	move.l	tw_http_o(a3),a0
	move.b	(a0,d0),d0
	and	#$ff,d0
	cmp	tw_cols_o(a3),d0
	blt.s	.keep_tab
	move	tw_cols_o(a3),d0
	subq	#1,d0
.keep_tab:
	move	d0,d1
	sub	tw_ccol_o(a3),d1
	ble.s	.skip_tab
	move	d1,-(sp)
	swap	d0
	move	tw_crow_o(a3),d0
	bsr	tw_mmovc	;tw_mmovc(tw_ccol&+cols&,tw_crow&)
	move.l	tw_ccol_o(a3),d0
	clr.l	d1
	move	(sp)+,d1
	swap	d1
	sub.l	d1,d0
	move	#1,d1
	bsr	tw_cls		;tw_cls(tw_ccol&-cols&,tw_crow&,cols&,1)
	bra	tw_rshow
;
.skip_tab:
	rts
;
;	ends vt52_ht
; ----------------------------------------------------------------------------
crlf_sub:
	bsr.s	ctrl_cr
ctrl_lf:			;VT_52 line feed
	move	tw_capm_o(a3),d1
	beq.s	.use_lf			;IF capture is on
	tst	tw_caph_o(a3)
	beq.s	.use_lf			;ANDIF capture file linked
	tst.b	d1
	beq.s	.use_lf			;ANDIF capture partial
	move	#LF,d0
	bsr	tw_capture
.use_lf:				;ENDIF
	move.l	tw_ccol_o(a3),d0
	addq	#1,d0
	cmp	tw_rows_o(a3),d0
	bhs.s	.need_scroll
	bra	tw_movc		;tw_movc(tw_ccol&,tw_crow&+1)
;
.need_scroll:
	clr.l	d0
	bra	tw_scrl		;tw_scrl(0,0)
;
;	ends ctrl_lf
; ----------------------------------------------------------------------------
ctrl_cr:			;VT_52 carriage return
	move	tw_capm_o(a3),d1
	beq.s	.use_cr			;IF capture is on
	tst	tw_caph_o(a3)
	beq.s	.use_cr			;ANDIF capture file linked
	tst.b	d1
	beq.s	.use_cr			;ANDIF capture partial
	move	#CR,d0
	bsr	tw_capture
.use_cr:				;ENDIF
	tst	tw_ccol_o(a3)
	beq.s	.skip_cr
	clr.l	d0
	move	tw_crow_o(a3),d0
	bra	tw_movc		;tw_movc(0,tw_crow&)
;
.skip_cr:
	rts
;
;	ends ctrl_cr
; ----------------------------------------------------------------------------
tw_push:			;VT_52 push cursor
	_debdef	tw_push,2
	move	tw_stix_o(a3),d0
	subq	#8,d0
	and	#$FE,d0
	bne.s	.do_it
	subq	#8,d0		;restart stack on overflow
.do_it:
	move	d0,tw_stix_o(a3)
	move.l	tw_stkp_o(a3),a0
	move.l	tw_ccol_o(a3),(a0,d0)
	IFNE	push_attr_COND
	move	tw_attr_o(a3),4(a0,d0)
	ENDC
	IFNE	push_colr_COND
	move	tw_colr_o(a3),6(a0,d0)
	ENDC
	rts
;
;	ends tw_push
; ----------------------------------------------------------------------------
tw_pull:			;VT_52 pull cursor
	_debdef	tw_pull,2
	clr.l	d0
	move	tw_stix_o(a3),d0
	and	#$FE,d0
	beq.s	.bad_pull	;go use tw_movc(0,0) if pulled without push
	move.l	tw_stkp_o(a3),a0
	IFNE	push_colr_COND
	move	6(a0,d0),tw_colr_o(a3)
	ENDC
	IFNE	push_attr_COND
	move	4(a0,d0),tw_attr_o(a3)
	ENDC
	move.l	(a0,d0),d0
	addq	#8,tw_stix_o(a3)
.bad_pull:
	bra	tw_movc		;tw_movc(oldcol,oldrow) or tw_movc(0,0)
;
;	ends tw_pull
; ----------------------------------------------------------------------------
tw_rshow:			;VT_52 re_show cursor
	_debdef	tw_rshow,2
	tst	tw_hide_o(a3)
	beq.s	make_show
	rts
; ----------------------------------------------------------------------------
tw_show:			;VT_52 show cursor
	_debdef	tw_show,2
	tst	tw_hide_o(a3)
	beq.s	skip_show
	subq	#1,tw_hide_o(a3)
	bne.s	skip_show
make_show:
	_debdef	make_show,3
	move	tw_lnsz_o(a3),d0
	mulu	tw_crow_o(a3),d0
	move.l	d0,a0
	add	tw_ccol_o(a3),a0
	add.l	tw_attp_o(a3),a0
	or.b	#$40,(a0)	;set cursor attribute in buffer
	move.l	#$10001,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#2,-(sp)
	bsr	tw_retext		;tw_retext(2,tw_ccol,tw_crow,1,1)
	lea	10(sp),sp
skip_show:
	_debdef	skip_show,3
	rts
;
;	ends tw_show & tw_rshow
; ----------------------------------------------------------------------------
tw_mrshow:			;VT_52 masked re_show cursor
	_debdef	tw_mrshow,2
	tst	tw_hide_o(a3)
	beq.s	make_mshow
	rts
; ----------------------------------------------------------------------------
tw_mshow:			;VT_52 masked show cursor
	_debdef	tw_mshow,2
	tst	tw_hide_o(a3)
	beq.s	skip_mshow
	subq	#1,tw_hide_o(a3)
	bne.s	skip_mshow
make_mshow:
	_debdef	make_mshow,3
	move	tw_lnsz_o(a3),d0
	mulu	tw_crow_o(a3),d0
	move.l	d0,a0
	add	tw_ccol_o(a3),a0
	add.l	tw_attp_o(a3),a0
	or.b	#$40,(a0)	;set cursor attribute into buffer
skip_mshow:
	_debdef	skip_mshow,3
	rts
;
;	ends tw_mshow
; ----------------------------------------------------------------------------
tw_hide:			;VT_52 hide cursor
	_debdef	tw_hide,2
	addq	#1,tw_hide_o(a3)
	cmp	#1,tw_hide_o(a3)
	bne.s	.skip_hide
	move	tw_lnsz_o(a3),d0
	mulu	tw_crow_o(a3),d0
	move.l	d0,a0
	add	tw_ccol_o(a3),a0
	add.l	tw_attp_o(a3),a0
	and.b	#-1-$40,(a0)	;clr cursor attribute from buffer
	move.l	#$10001,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#2,-(sp)
	bsr	tw_retext		;tw_retext(2,tw_ccol,tw_crow,1,1)
	lea	10(sp),sp
.skip_hide
	rts
;
;	ends tw_hide
; ----------------------------------------------------------------------------
tw_mfhide:			;VT_52 masked force_hide cursor
	_debdef	tw_mfhide,2
	move	tw_lnsz_o(a3),d0
	mulu	tw_crow_o(a3),d0
	move.l	d0,a0
	add	tw_ccol_o(a3),a0
	add.l	tw_attp_o(a3),a0
	and.b	#-1-$40,(a0)	;clr cursor attribute from buffer
	rts
;
;	ends tw_mfhide
; ----------------------------------------------------------------------------
tw_movc:		;tw_movc(col&,row&)	;move cursor
	_debdef	tw_movc,2
	move.l	d0,-(sp)
	bsr	tw_hide
	move.l	(sp)+,d0
	bpl.s	.keep_col_1
	and.l	#$0000FFFF,d0
.keep_col_1:
	tst	d0
	bpl.s	.keep_row_1
	clr	d0
.keep_row_1:
	move.l	tw_cols_o(a3),d1
	subq	#1,d1
	cmp	d1,d0
	ble.s	.keep_row_2
	move	d1,d0
.keep_row_2:
	swap	d1
	swap	d0
	subq	#1,d1
	cmp	d1,d0
	ble.s	.keep_col_2
	move	d1,d0
.keep_col_2:
	swap	d0
	move.l	d0,tw_ccol_o(a3)
	bra	tw_show
;
;	ends tw_movc
; ----------------------------------------------------------------------------
tw_mmovc:		;tw_mmovc(col&,row&)	;masked move cursor
	_debdef	tw_mmovc,2
	move.l	d0,-(sp)
	bsr	tw_mfhide
	move.l	(sp)+,d0
	bpl.s	.keep_col_1
	and.l	#$0000FFFF,d0
.keep_col_1:
	tst	d0
	bpl.s	.keep_row_1
	clr	d0
.keep_row_1:
	move.l	tw_cols_o(a3),d1
	subq	#1,d1
	cmp	d1,d0
	ble.s	.keep_row_2
	move	d1,d0
.keep_row_2:
	swap	d1
	swap	d0
	subq	#1,d1
	cmp	d1,d0
	ble.s	.keep_col_2
	move	d1,d0
.keep_col_2:
	swap	d0
	move.l	d0,tw_ccol_o(a3)
	bra	tw_mrshow
;
;	ends tw_mmovc
; ----------------------------------------------------------------------------
tw_cls:			;tw_cls(col,row,w,h)	;clear text rectangle
	_debdef	tw_cls,2
;arguments:  d0=col.row  d1=w.h
;
	link	a6,#0
	movem.l	d0-d1,-(sp)
	move	tw_lnsz_o(a3),d2
	mulu	d0,d2
	move.l	d2,a0
	swap	d0
	add	d0,a0
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0
	add.l	tw_attp_o(a3),a1
	add.l	tw_colp_o(a3),a2
	subq	#1,d1
	blt.s	.skip_cls
	move	d1,d5		;d5=dbra value for rows
	move	tw_lnsz_o(a3),d3
	swap	d1
	sub	d1,d3		;d3=byte offset between rows
	blt.s	.skip_cls
	move	d1,d6		;d6=dbra value for columns
	move	#' ',d0		;ascii space
	move	tw_attr_o(a3),d1
	bclr	#3,d1		;this masks underline for space
	move	tw_colr_o(a3),d2
	subq	#1,d6
	blt.s	.skip_cls
.cls_loop_1:
	move	d6,d4
.cls_loop_2:
	move.b	d0,(a0)+
	move.b	d1,(a1)+
	move.b	d2,(a2)+
	dbra	d4,.cls_loop_2
	add	d3,a0
	add	d3,a1
	add	d3,a2
	dbra	d5,.cls_loop_1
	move	#1,-(sp)
	bsr	tw_retext	;tw_retext(1,col,row,w,h)
	lea	10(sp),sp
	bsr	tw_rshow
.skip_cls:
	unlk	a6
	rts
;
;	ends tw_cls
; ----------------------------------------------------------------------------
tw_insp:		;tw_insp(cnt)		;Insert spaces in tw_crow
	_debdef	tw_insp,2
;arguments:  d0=cnt
	link	a6,#0
	move	tw_cols_o(a3),d1
	sub	tw_ccol_o(a3),d1
	cmp	d1,d0
	bls.s	.keep_cnt
	move	d1,d0
.keep_cnt:
	move	d0,-(sp)		;W:-2(a6) = cnt  distance to move blocks
	ble	exit_err_1
	move	tw_cols_o(a3),d1
	sub	tw_ccol_o(a3),d1
	sub	d0,d1
	move	d1,-(sp)		;W:-4(a6) = s  size of blocks to move
	move	tw_lnsz_o(a3),d0
	mulu	tw_crow_o(a3),d0
	move.l	d0,a0
	add	tw_ccol_o(a3),a0
	move.l	a0,-(sp)		;L:-8(a6) = o  offset to source blocks
	tst	-4(a6)			;IF s>0
	ble.s	.no_move_1
	bsr	tw_hide
	move.l	-8(a6),a0		;a0 = offset to source blocks
	move	-4(a6),d2		;d2 = block size
	add	d2,a0			;a0 = offset to end of source blocks
	subq	#1,d2			;d2 = dbra counter for block move
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> source end in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move	-2(a6),d0		;d0 = cnt = move distance
.move_loop_1:
	move.b	-(a0),(a0,d0.l)
	move.b	-(a1),(a1,d0.l)
	move.b	-(a2),(a2,d0.l)
	dbra	d2,.move_loop_1
	move	tw_chrw_o(a3),d0
	mulu	-2(a6),d0
	neg	d0
	move	d0,tw_rold_o(a3)
.no_move_1:				;ENDIF
	move.l	-8(a6),a0		;a0 = offset to blocks
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> block in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move	-2(a6),d2		;d2 = cnt
	subq	#1,d2			;d2 = dbra count
	move	tw_attr_o(a3),d0
	bclr	#3,d0			;this masks underline for space
	move	tw_colr_o(a3),d1
.move_loop_2:
	move.b	#' ',(a0)+
	move.b	d0,(a1)+
	move.b	d1,(a2)+
	dbra	d2,.move_loop_2
	tst	-4(a6)			;IF s>0
	ble.s	.no_move_2
	bsr	tw_mshow
	move	tw_cols_o(a3),d0
	sub	tw_ccol_o(a3),d0
	swap	d0
	move	#1,d0
	move.l	d0,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#4,-(sp)
	bsr	tw_retext	;tw_retext(4,tw_ccol,tw_crow,tw_cols-tw_ccol,1)
	bra.s	.done_moves
;
.no_move_2:				;ELSE
	bsr	tw_mrshow
	move	-2(a6),d0
	swap	d0
	move	#1,d0
	move.l	d0,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#1,-(sp)
	bsr	tw_retext	;tw_retext(1,tw_ccol,tw_crow,cnt,1)
.done_moves:				;ENDIF
	unlk	a6
	rts
;
;	ends tw_insp
; ----------------------------------------------------------------------------
tw_delp:		;tw_delp(cnt)		;delete chars in tw_crow
	_debdef	tw_delp,2
;arguments:  d0=cnt
	link	a6,#0
	move	tw_cols_o(a3),d1
	sub	tw_ccol_o(a3),d1
	cmp	d1,d0
	bls.s	.keep_cnt
	move	d1,d0
.keep_cnt:
	move	d0,-(sp)		;W:-2(a6) = cnt  distance to move blocks
	ble	exit_err_1
	move	tw_cols_o(a3),d1
	sub	tw_ccol_o(a3),d1
	sub	d0,d1
	move	d1,-(sp)		;W:-4(a6) = s  size of blocks to move
	move	tw_lnsz_o(a3),d0
	mulu	tw_crow_o(a3),d0
	move.l	d0,a0
	add	tw_ccol_o(a3),a0
	move.l	a0,-(sp)		;L:-8(a6) = o  offset to dest blocks
	tst	-4(a6)			;IF s>0
	ble.s	.no_move_1
	move.l	-8(a6),a0		;a0 = offset to dest blocks
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> dest in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move	-2(a6),d0		;d0 = cnt = move distance
	move	-4(a6),d2		;d2 = block size
	subq	#1,d2			;d2 = dbra counter for block move
.move_loop_1:
	move.b	(a0,d0),(a0)+
	move.b	(a1,d0),(a1)+
	move.b	(a2,d0),(a2)+
	dbra	d2,.move_loop_1
	move	tw_chrw_o(a3),d0
	mulu	-2(a6),d0
	move	d0,tw_rold_o(a3)
.no_move_1:				;ENDIF
	move.l	-8(a6),a0		;a0 = offset to dest blocks
	add	-4(a6),a0		;a0 = offset to end of dest blocks
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> dest end in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move	tw_attr_o(a3),d0
	bclr	#3,d0			;this masks underline for space
	move	tw_colr_o(a3),d1
	move	-2(a6),d2		;d2 = cnt
	subq	#1,d2			;d2 = dbra count
.move_loop_2:
	move.b	#' ',(a0)+
	move.b	d0,(a1)+
	move.b	d1,(a2)+
	dbra	d2,.move_loop_2
	tst	-4(a6)			;IF s>0
	ble.s	.no_move_2
	move	tw_cols_o(a3),d0
	sub	tw_ccol_o(a3),d0
	swap	d0
	move	#1,d0
	move.l	d0,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#4,-(sp)
	bsr	tw_retext	;tw_retext(4,tw_ccol,tw_crow,tw_cols-tw_ccol,1)
	bsr	tw_rshow
	bra.s	.done_moves
;
.no_move_2:				;ELSE
	bsr	tw_mrshow
	move	-2(a6),d0
	swap	d0
	move	#1,d0
	move.l	d0,-(sp)
	move.l	tw_ccol_o(a3),-(sp)
	move	#1,-(sp)
	bsr	tw_retext	;tw_retext(1,tw_ccol,tw_crow,cnt,1)
.done_moves:				;ENDIF
	unlk	a6
	rts
;
;
;	ends tw_delp
; ----------------------------------------------------------------------------
; local variables for tw_scrl & tw_scrl_reg
;
	rsset	-16
sc_dir	rs.w	1
sc_trow	rs.w	1
sc_irow	rs.w	1
sc_brow	rs.w	1
sc_size	rs.l	1
sc_offs	rs.l	1
;
; ----------------------------------------------------------------------------
tw_scrl_reg:		;tw_scrl_reg(dir,row)	;scroll text rows
	_debdef	tw_scrl,2			;of ANSI region
	link	a6,#-16
	move	tw_bots_o(a3),sc_brow(a6)	;store sc_brow = tw_bots
	bra.s	tw_ij_scrl
;
tw_scrl:		;tw_scrl(dir,row)	;scroll text rows
	_debdef	tw_scrl,2			;of whole screen
	link	a6,#-16
	move	tw_rows_o(a3),sc_brow(a6)	;store  sc_brow = tw_rows
	subq	#1,sc_brow(a6)			;adjust sc_brow = tw_rows-1
tw_ij_scrl:
; scrolls all lines above (and including) row sc_brow
; dir&>=0  => scroll upwards, clearing row sc_brow
; dir&<0   => scroll downwards, clearing row sc_trow
	move.l	d0,sc_dir(a6)		;store dir.trow
	move	tw_lnsz_o(a3),d0
	mulu	sc_trow(a6),d0		;d0 = row*tw_lnsz
	move.l	d0,sc_offs(a6)		;store buffer offset to row
	move	tw_lnsz_o(a3),d0	;d0 = tw_lnsz
	move	sc_brow(a6),d1		;d1 = sc_brow
	sub	sc_trow(a6),d1		;d1 = sc_brow-sc_trow
	blt	exit_err_1	;exit if row illegal
	mulu	d1,d0			;d0 = (sc_brow-sc_trow)*tw_lnsz
	move.l	d0,sc_size(a6)		;store size of block to move
	bsr	tw_hide
	tst	tw_lock_o(a3)
	beq.s	.do_scroll
	bsr	tw_uselock
.do_scroll:
	tst.l	sc_size(a6)		;IF s>0
	ble	.no_move_1
	tst	sc_dir(a6)		;	IF dir<0	;Scroll down
	bpl.s	.scroll_up_1
.scroll_down_1:
	move.l	sc_offs(a6),a0		;a0 = offset to source blocks
	move.l	sc_size(a6),d2		;d2 = block size
	add.l	d2,a0			;a0 = offset to end of source blocks
	lsr.l	#2,d2			;d2 = longword count
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> source end in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move	tw_lnsz_o(a3),d0
	move.l	a3,d3
	move	d0,a3
	move	d0,a4
	move	d0,a5
	add.l	a0,a3
	add.l	a1,a4
	add.l	a2,a5
.down_loop:
	move.l	-(a0),-(a3)
	move.l	-(a1),-(a4)
	move.l	-(a2),-(a5)
	subq.l	#1,d2
	bgt.s	.down_loop
	move.l	d3,a3
	move	tw_chrh_o(a3),d0
	neg	d0
	move	d0,tw_rold_o(a3)
	bra.s	.scroll_done_1
;
.scroll_up_1:				;	ELSE	;Scroll up
	move.l	sc_offs(a6),a0		;a0 = offset to dest blocks
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> dest in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move	tw_lnsz_o(a3),d0
	move.l	a3,d3
	move	d0,a3
	move	d0,a4
	move	d0,a5
	add.l	a0,a3
	add.l	a1,a4
	add.l	a2,a5
	move.l	sc_size(a6),d2		;d2 = block size
	lsr.l	#2,d2			;d2 = longword count
.up_loop:
	move.l	(a3)+,(a0)+
	move.l	(a4)+,(a1)+
	move.l	(a5)+,(a2)+
	subq.l	#1,d2
	bgt.s	.up_loop
	move.l	d3,a3
	move	tw_chrh_o(a3),tw_rold_o(a3)
.scroll_done_1:				;	ENDIF
.no_move_1:				;ENDIF
	tst	sc_dir(a6)			;IF dir<0	;Insert above
	bpl.s	.scroll_up_2
.scroll_down_2:
	move	sc_trow(a6),sc_irow(a6)	;store insertion row = row
	bra.s	.scroll_done_2
;
.scroll_up_2:				;ELSE		;insert below
	move	sc_brow(a6),d0
	move	d0,sc_irow(a6)		;store insertion row = sc_brow
	move	tw_lnsz_o(a3),d0
	mulu	sc_irow(a6),d0
	move.l	d0,sc_offs(a6)		;offs = buffer offset to irow
.scroll_done_2:				;ENDIF
	move.l	sc_offs(a6),a0		;a0 = offset to blocks
	move.l	a0,a1
	move.l	a0,a2
	add.l	tw_txtp_o(a3),a0	;\
	add.l	tw_attp_o(a3),a1	; X -> block in each buffer
	add.l	tw_colp_o(a3),a2	;/
	move.l	#'    ',d0
	move	tw_attr_o(a3),d1
	and	#$FF,d1			;this masks upper byte
	bclr	#3,d1			;this masks underline for space
	lsl	#2,d1
	move.l	quadbyte_t(pc,d1),d1
	move	tw_colr_o(a3),d2
	lsl	#2,d2
	move.l	quadbyte_t(pc,d2),d2
	move	tw_lnsz_o(a3),d3	;d3 = tw_lnsz
	lsr	#2,d3
	subq	#1,d3			;d3 = dbra count
.clr_loop:
	move.l	d0,(a0)+
	move.l	d1,(a1)+
	move.l	d2,(a2)+
	dbra	d3,.clr_loop
	bra	tw_end_scrl
;
quadbyte_t:
;
  dc.l	$00000000,$01010101,$02020202,$03030303,$04040404,$05050505,$06060606,$07070707
  dc.l	$08080808,$09090909,$0a0a0a0a,$0b0b0b0b,$0c0c0c0c,$0d0d0d0d,$0e0e0e0e,$0f0f0f0f
  dc.l	$10101010,$11111111,$12121212,$13131313,$14141414,$15151515,$16161616,$17171717
  dc.l	$18181818,$19191919,$1a1a1a1a,$1b1b1b1b,$1c1c1c1c,$1d1d1d1d,$1e1e1e1e,$1f1f1f1f
  dc.l	$20202020,$21212121,$22222222,$23232323,$24242424,$25252525,$26262626,$27272727
  dc.l	$28282828,$29292929,$2a2a2a2a,$2b2b2b2b,$2c2c2c2c,$2d2d2d2d,$2e2e2e2e,$2f2f2f2f
  dc.l	$30303030,$31313131,$32323232,$33333333,$34343434,$35353535,$36363636,$37373737
  dc.l	$38383838,$39393939,$3a3a3a3a,$3b3b3b3b,$3c3c3c3c,$3d3d3d3d,$3e3e3e3e,$3f3f3f3f
  dc.l	$40404040,$41414141,$42424242,$43434343,$44444444,$45454545,$46464646,$47474747
  dc.l	$48484848,$49494949,$4a4a4a4a,$4b4b4b4b,$4c4c4c4c,$4d4d4d4d,$4e4e4e4e,$4f4f4f4f
  dc.l	$50505050,$51515151,$52525252,$53535353,$54545454,$55555555,$56565656,$57575757
  dc.l	$58585858,$59595959,$5a5a5a5a,$5b5b5b5b,$5c5c5c5c,$5d5d5d5d,$5e5e5e5e,$5f5f5f5f
  dc.l	$60606060,$61616161,$62626262,$63636363,$64646464,$65656565,$66666666,$67676767
  dc.l	$68686868,$69696969,$6a6a6a6a,$6b6b6b6b,$6c6c6c6c,$6d6d6d6d,$6e6e6e6e,$6f6f6f6f
  dc.l	$70707070,$71717171,$72727272,$73737373,$74747474,$75757575,$76767676,$77777777
  dc.l	$78787878,$79797979,$7a7a7a7a,$7b7b7b7b,$7c7c7c7c,$7d7d7d7d,$7e7e7e7e,$7f7f7f7f
  dc.l	$80808080,$81818181,$82828282,$83838383,$84848484,$85858585,$86868686,$87878787
  dc.l	$88888888,$89898989,$8a8a8a8a,$8b8b8b8b,$8c8c8c8c,$8d8d8d8d,$8e8e8e8e,$8f8f8f8f
  dc.l	$90909090,$91919191,$92929292,$93939393,$94949494,$95959595,$96969696,$97979797
  dc.l	$98989898,$99999999,$9a9a9a9a,$9b9b9b9b,$9c9c9c9c,$9d9d9d9d,$9e9e9e9e,$9f9f9f9f
  dc.l	$a0a0a0a0,$a1a1a1a1,$a2a2a2a2,$a3a3a3a3,$a4a4a4a4,$a5a5a5a5,$a6a6a6a6,$a7a7a7a7
  dc.l	$a8a8a8a8,$a9a9a9a9,$aaaaaaaa,$abababab,$acacacac,$adadadad,$aeaeaeae,$afafafaf
  dc.l	$b0b0b0b0,$b1b1b1b1,$b2b2b2b2,$b3b3b3b3,$b4b4b4b4,$b5b5b5b5,$b6b6b6b6,$b7b7b7b7
  dc.l	$b8b8b8b8,$b9b9b9b9,$babababa,$bbbbbbbb,$bcbcbcbc,$bdbdbdbd,$bebebebe,$bfbfbfbf
  dc.l	$c0c0c0c0,$c1c1c1c1,$c2c2c2c2,$c3c3c3c3,$c4c4c4c4,$c5c5c5c5,$c6c6c6c6,$c7c7c7c7
  dc.l	$c8c8c8c8,$c9c9c9c9,$cacacaca,$cbcbcbcb,$cccccccc,$cdcdcdcd,$cececece,$cfcfcfcf
  dc.l	$d0d0d0d0,$d1d1d1d1,$d2d2d2d2,$d3d3d3d3,$d4d4d4d4,$d5d5d5d5,$d6d6d6d6,$d7d7d7d7
  dc.l	$d8d8d8d8,$d9d9d9d9,$dadadada,$dbdbdbdb,$dcdcdcdc,$dddddddd,$dededede,$dfdfdfdf
  dc.l	$e0e0e0e0,$e1e1e1e1,$e2e2e2e2,$e3e3e3e3,$e4e4e4e4,$e5e5e5e5,$e6e6e6e6,$e7e7e7e7
  dc.l	$e8e8e8e8,$e9e9e9e9,$eaeaeaea,$ebebebeb,$ecececec,$edededed,$eeeeeeee,$efefefef
  dc.l	$f0f0f0f0,$f1f1f1f1,$f2f2f2f2,$f3f3f3f3,$f4f4f4f4,$f5f5f5f5,$f6f6f6f6,$f7f7f7f7
  dc.l	$f8f8f8f8,$f9f9f9f9,$fafafafa,$fbfbfbfb,$fcfcfcfc,$fdfdfdfd,$fefefefe,$ffffffff
;
tw_end_scrl:
	tst.l	sc_size(a6)		;IF s>0
	ble.s	.no_move_2
	move.l	tw_cols_o(a3),d0
	move	sc_brow(a6),d0
	addq	#1,d0
	sub	sc_trow(a6),d0
	move.l	d0,-(sp)
	clr.l	d0
	move	sc_trow(a6),d0
	move.l	d0,-(sp)
	move	#3,-(sp)
	bsr	tw_dotext			;tw_dotext(3,0,row,tw_cols,sc_brow-sc_trow+1)
	lea	10(sp),sp
	bra.s	.made_moves
;					;ELSE	
.no_move_2:
	move.l	tw_cols_o(a3),d0
	move	#1,d0
	move.l	d0,-(sp)
	clr.l	d0
	move	sc_irow(a6),d0
	move.l	d0,-(sp)
	move	#1,-(sp)
	bsr	tw_dotext			;tw_dotext(1,0,irow,tw_cols,1)
	lea	10(sp),sp
.made_moves:				;ENDIF
	bsr	tw_show
	unlk	a6
	rts
;
;	ends tw_scrl
; ----------------------------------------------------------------------------
tw_marg:		;flags NE if margins changed, otherwise flags EQ
	_debdef	tw_marg,2
	clr	d0			;d0 = 0
.fix_col:
	clr.l	d1
	move	tw_wrkw_o(a3),d1
	divu	tw_chrw_o(a3),d1	;d1 = wrkw/chrw
	move	tw_cols_o(a3),d2	;d2 = cols
	cmp	d1,d2
	bgt.s	.lim_vcol		;IF cols <= d1
	move	tw_scol_o(a3),d0
	bne.s	.new_vcol		;  IF scol != 0
	cmp	tw_vcol_o(a3),d2
	beq.s	.done_vcol		;  OR vcol != cols
.new_vcol:
	clr	tw_scol_o(a3)			;scol = 0
	move	tw_cols_o(a3),tw_vcol_o(a3)	;vcol = cols
	st	d0				;d0 = 1
	bra.s	.done_vcol		;  ENDIF
;
.lim_vcol:				;ELSE  ;cols > d1
	add	tw_scol_o(a3),d1		;d1 = scol + (wrkw / chrw)
	cmp	d2,d1
	ble.s	.keep_scol			;IF (scol + (wrkw / chrw)) > cols
	st	d0
	sub	tw_scol_o(a3),d1			;d1 = wrkw / chrw
	sub	d1,d2					;d2 = cols - (wrkw / chrw)
	move	d2,tw_scol_o(a3)
	move	d1,tw_vcol_o(a3)
	bra.s	.done_vcol
;						;ELSE  (scol + (wrkw / chrw)) <= cols
.keep_scol:
	beq.s	.set_lim_vcol				;IF (scol + (wrkw / chrw)) < cols
	clr.l	d2
	move	tw_wrkw_o(a3),d2
	add	tw_chrw_o(a3),d2
	subq	#1,d2
	divu	tw_chrw_o(a3),d2
	cmp	tw_vcol_o(a3),d2
	beq.s	.done_vcol
	st	d0
	move	d2,tw_vcol_o(a3)
	bra.s	.done_vcol
;							;ELSE  (scol + (wrkw / chrw) = cols
.set_lim_vcol:
	sub	tw_scol_o(a3),d1				;d1 = wrkw / chrw
	cmp	tw_vcol_o(a3),d1
	beq.s	.done_vcol
	st	d0
	move	d1,tw_vcol_o(a3)
.done_vcol:				;ENDIF	;ENDIF	;ENDIF
;
.fix_row:
	clr.l	d1
	move	tw_wrkh_o(a3),d1
	divu	tw_chrh_o(a3),d1	;d1 = wrkh/chrh
	move	tw_rows_o(a3),d2	;d2 = rows
	cmp	d1,d2
	bgt.s	.lim_vrow		;IF rows <= d1
	move	tw_srow_o(a3),d0
	bne.s	.new_vrow		;  IF srow != 0
	cmp	tw_vrow_o(a3),d2
	beq.s	.done_vrow		;  OR vrow != rows
.new_vrow:
	clr	tw_srow_o(a3)			;srow = 0
	move	tw_rows_o(a3),tw_vrow_o(a3)	;vrow = rows
	st	d0				;d0 = 1
	bra.s	.done_vrow		;  ENDIF
;
.lim_vrow:				;ELSE  ;rows > d1
	add	tw_srow_o(a3),d1		;d1 = srow + (wrkh / chrh)
	cmp	d2,d1
	ble.s	.keep_srow			;IF (srow + (wrkh / chrh)) > rows
	st	d0
	sub	tw_srow_o(a3),d1			;d1 = wrkh / chrh
	sub	d1,d2					;d2 = rows - (wrkh / chrh)
	move	d2,tw_srow_o(a3)
	move	d1,tw_vrow_o(a3)
	bra.s	.done_vrow
;						;ELSE  (srow + (wrkh / chrh)) <= rows
.keep_srow:
	beq.s	.set_lim_vrow				;IF (srow + (wrkh / chrh)) < rows
	clr.l	d2
	move	tw_wrkh_o(a3),d2
	add	tw_chrh_o(a3),d2
	subq	#1,d2
	divu	tw_chrh_o(a3),d2
	cmp	tw_vrow_o(a3),d2
	beq.s	.done_vrow
	st	d0
	move	d2,tw_vrow_o(a3)
	bra.s	.done_vrow
;							;ELSE  (srow + (wrkh / chrh) = rows
.set_lim_vrow:
	sub	tw_srow_o(a3),d1				;d1 = wrkh / chrh
	cmp	tw_vrow_o(a3),d1
	beq.s	.done_vrow
	st	d0
	move	d1,tw_vrow_o(a3)
.done_vrow:				;ENDIF	;ENDIF	;ENDIF
	ext	d0
	ext.l	d0
	rts
;
;	ends tw_marg
; ----------------------------------------------------------------------------
tw_bars:			;Update scroll bars
	_debdef	tw_bars,2
	btst	#3,tw_gads_o(a3)
	beq.s	.done_hslide
	bsr	tw_hpos
	cmp	tw_barx_o(a3),d0
	beq.s	.done_hpos
	move	d0,tw_barx_o(a3)
	move	d0,intin+4
	gem_aes	wind_set,tw_wind_o(a3),#8
.done_hpos:
	bsr	tw_hsize
	cmp	tw_barw_o(a3),d0
	beq.s	.done_hslide
	move	d0,tw_barw_o(a3)
	move	d0,intin+4
	gem_aes	wind_set,tw_wind_o(a3),#15
.done_hslide:
	btst	#0,tw_gads_o(a3)
	beq.s	.done_vslide
	bsr.s	tw_vpos
	cmp	tw_bary_o(a3),d0
	beq.s	.done_vpos
	move	d0,tw_bary_o(a3)
	move	d0,intin+4
	gem_aes	wind_set,tw_wind_o(a3),#9
.done_vpos:
	bsr.s	tw_vsize
	cmp	tw_barh_o(a3),d0
	beq.s	.done_vslide
	move	d0,tw_barh_o(a3)
	move	d0,intin+4
	gem_aes	wind_set,tw_wind_o(a3),#16
.done_vslide:
	rts
;
;	ends tw_bars
; ----------------------------------------------------------------------------
tw_vpos:			;= vertical scroll bar position
	_debdef	tw_vpos,2
	clr.l	d0
	move	tw_rows_o(a3),d1
	sub	tw_vrow_o(a3),d1
	ble.s	.exit
	move	tw_srow_o(a3),d0
	mulu	#1000,d0
	divu	d1,d0
	rts
;
.exit:
	clr	tw_srow_o(a3)
	move	tw_rows_o(a3),tw_vrow_o(a3)
	rts
;
;	ends tw_vpos
; ----------------------------------------------------------------------------
tw_hpos:			;= horizontal scroll bar position
	_debdef	tw_hpos,2
	clr.l	d0
	move	tw_cols_o(a3),d1
	sub	tw_vcol_o(a3),d1
	ble.s	.exit
	move	tw_scol_o(a3),d0
	mulu	#1000,d0
	divu	d1,d0
	rts
;
.exit:
	clr	tw_scol_o(a3)
	move	tw_cols_o(a3),tw_vcol_o(a3)
	rts
;
;	ends tw_hpos
; ----------------------------------------------------------------------------
tw_vsize:			;= vertical scroll bar size
	_debdef	tw_vsize,2
	move.l	#1000,d0
	clr.l	d1
	move	tw_wrkh_o(a3),d1
	divu	tw_chrh_o(a3),d1
	cmp	tw_rows_o(a3),d1
	bge.s	.exit
	mulu	d1,d0
	divu	tw_rows_o(a3),d0
	rts
;
.exit:
	rts
;
;	ends tw_vsize
; ----------------------------------------------------------------------------
tw_hsize:			;= horizontal scroll bar size
	_debdef	tw_hsize,2
	move.l	#1000,d0
	clr.l	d1
	move	tw_wrkw_o(a3),d1
	divu	tw_chrw_o(a3),d1
	cmp	tw_cols_o(a3),d1
	bge.s	.exit
	mulu	d1,d0
	divu	tw_cols_o(a3),d0
	rts
;
.exit:
	rts
;
;	ends tw_hsize
; ----------------------------------------------------------------------------
;
tw_uselock:			;long	tw_uselock()
	_debdef	tw_uselock,2
; returns:	lock depth before call:  0 = unlocked,  1 = empty.
; results:	empties the lock by updating the screen.
	link	a6,#0
	move	tw_lock_o(a3),d2
	beq	exit_zero
	move	d2,-(sp)
	subq	#2,d2
	blt.s	.lock_fixed
	move.l	tw_lkpt_o(a3),a4
.fixlock_lp:
	movem.l	(a4)+,d0-d1
	move	d2,-(sp)
	movem.l	d0-d1,-(sp)
	move	#2,-(sp)
	bsr	tw_dotext	;retext(2,d0>>16,d0,d1>>16,d1)
	lea	10(sp),sp
	move	(sp)+,d2
	dbra	d2,.fixlock_lp
.lock_fixed:
	move	#1,tw_lock_o(a3)
	move	(sp)+,d0
	bra	exit_ext_d0
;
; ----------------------------------------------------------------------------
; Arguments for tw_retext and tw_redraw (below) are identical, excepting that
; tw_retext uses ascii coordinates, and tw_redraw uses pixel coordinates.
; All the drawing subfunctions of tw_redraw also use the same arguments.
; Thus a common structure for these is defined here:
;
	rsreset
	rs.b	8	;offset for a6 link and return address
rw_md	rs.w	1	;This defines the drawing mode (clear, text, moves...)
rw_x	rs.w	1
rw_y	rs.w	1
rw_w	rs.w	1
rw_h	rs.w	1
rw_base	=	-4	;-> screen RAM base (for bitblt)
rw_clip	=	-12	;clipping GRECT
rw_dsiz	=	-14	;draw size
rw_dpos	=	-16	;draw position
;
; ----------------------------------------------------------------------------
tw_retext:		;tw_retext(md,x,y,w,h)	;redraw text rectangle
	_debdef	tw_retext,2
	link	a6,#-16
	move.l	tw_scol_o(a3),d0	;d0=tw_scol.tw_srow
	move.l	tw_vcol_o(a3),d1	;d1=tw_vcol.tw_vrow
	move.l	rw_x(a6),d2		;d2=x.y
	move.l	rw_w(a6),d3		;d3=w.h
	bsr	rc_intersect		;d0=mx.my  d1=mw.mh
	bmi	exit_err_1	;IF RC_INTERSECT(tw_scol,tw_srow,tw_vcol,tw_vrow,x,y,w,h)
	tst	tw_lock_o(a3)
	beq	do_retext
	cmp.l	tw_scol_o(a3),d0
	bne.s	.not_whole
	cmp.l	tw_vcol_o(a3),d1
	beq.s	join_full
.not_whole:			;ENDIF
	movem.l	d0-1,rw_x(a6)
	move	tw_lock_o(a3),d7
	subq	#2,d7
	blt.s	try_split
	move.l	tw_lkpt_o(a3),a4
rejoin_lp:
	movem.l	(a4)+,d2-d3
	bsr	rc_joint
	dbpl	d7,rejoin_lp
	bmi.s	try_split
	cmp.l	tw_scol_o(a3),d0
	bne.s	join_rect		;IF	x.y == 0.0
	cmp.l	tw_vcol_o(a3),d1
	bne.s	join_rect		;ANDIF	w.h == tw_cols.tw_rows
join_full:
	move.l	tw_lkpt_o(a3),a4
	addq	#8,a4
	move	#2,tw_lock_o(a3)		;full update restarts lock
join_rect:				;ENDIF
	move.l	d1,-(a4)
	move.l	d0,-(a4)
	unlk	a6
	rts
;
try_split:
	move	tw_lock_o(a3),d0
	cmp	#rectsize,d0
	bls.s	do_split
	bsr	tw_uselock
	moveq	#1,d0
do_split:
	addq	#1,d0
	move	d0,tw_lock_o(a3)
	subq	#2,d0
	lsl	#3,d0
	move.l	tw_lkpt_o(a3),a4
	add	d0,a4
	move.l	rw_x(a6),(a4)+
	move.l	rw_w(a6),(a4)+
	unlk	a6
	rts
;
; ----------------------------------------------------------------------------
tw_dotext:		;tw_dotext(md,x,y,w,h)	;draw text rectangle
	_debdef	tw_retext,2
	link	a6,#-16
	move.l	tw_scol_o(a3),d0	;d0=tw_scol.tw_srow
	move.l	tw_vcol_o(a3),d1	;d1=tw_vcol.tw_vrow
	move.l	rw_x(a6),d2		;d2=x.y
	move.l	rw_w(a6),d3		;d3=w.h
	bsr	rc_intersect		;d0=mx.my  d1=mw.mh
	bmi	exit_err_1	;IF RC_INTERSECT(tw_scol,tw_srow,tw_vcol,tw_vrow,x,y,w,h)
do_retext:
	swap	d0
	move	d0,d2			;d2 = x
	sub	tw_scol_o(a3),d2	;d2 = x-scol
	muls	tw_chrw_o(a3),d2	;d2 = (x-scol)*chrw
	add	tw_wrkx_o(a3),d2	;d2 = (x-scol)*chrw+wrkx
	move	d2,rw_x(a6)	; x = (x-scol)*chrw+wrkx
	swap	d0
	move	d0,d2			;d2 = y
	sub	tw_srow_o(a3),d2	;d2 = y-srow
	muls	tw_chrh_o(a3),d2	;d2 = (y-srow)*chrh
	add	tw_wrky_o(a3),d2	;d2 = (y-srow)*chrh+wrky
	move	d2,rw_y(a6)	; y = (y-srow)*chrh+wrky
	move.l	d1,d0			;d0 = d1 = w.h
	swap	d0			;d0 = w
	muls	tw_chrw_o(a3),d0	;d0 = w*chrw
	move	d0,rw_w(a6)		;w = w*chrw
	muls	tw_chrh_o(a3),d1	;d1 = h*chrh
	move	d1,rw_h(a6)		;h = h*chrh
;
;Here we simulate a pixel redraw, having checked and converted arguments.
;Thus we here simply jump into the function header of "tw_redraw"
;
	bra.s	tw_j_redraw
; ----------------------------------------------------------------------------
tw_redraw:		;tw_redraw(md,x,y,w,h)	;redraw pixel rectangle
	_debdef	tw_redraw,2
	link	a6,#-16
	cmp	#2,rw_md(a6)
	ble.s	tw_j_redraw		;IF scrolling
	bsr	tw_uselock		;	ensure screen validity
;					;ENDIF
tw_j_redraw:			
	movem.l	tw_wrkx_o(a3),d0-d1	;d0.d1 = wrkx.wrky.wrkw.wrkh
	movem.l	rw_x(a6),d2-d3		;d2.d3 = x.y.w.h
	bsr	rc_intersect
	bmi	.exit_redraw	;	IF RC_INTERSECT(wrkx,wrky,wrkw,wrkh,x,y,w,h)
	movem.l	tw_full(pc),d2-d3
	bsr	rc_intersect
	bmi	.exit_redraw	;	IF RC_INTERSECT(fullx,fully,fullw,fullh,x,y,w,h)
	movem.l	d0-d1,rw_x(a6)		;x.y.w.h = d0.d1
	gem_aes	wind_update,#1
	gem_aes	wind_update,#3
	xbios	Logbase
	move.l	d0,rw_base(a6)		;rw_base -> screen base
	move.l	a5,-(sp)
	move.l	a6,a5			;a5 = a6 allows access by subfunctions
	gem_aes	wind_get,tw_wind_o(a3),#11
.redraw_loop:
	movem.l	intout+2(pc),d0-d1	;d0 = x.y.w.h of current AES rectangle for window
	tst	d1
	beq	.done_redraw
	cmp.l	#$FFFF,d1
	bls	.done_redraw	;WHILE tw>0 AND th>0
	st	d2
	cmp.l	tw_wrkx_o(a3),d0
	bne.s	.not_whole
	cmp.l	tw_wrkw_o(a3),d1
	sne	d2
.not_whole:
	ext	d2
	move	d2,-(sp)	;push flag
	movem.l	rw_x(a6),d2-d3	;d2.d3 = x.y.w.h of redraw request
	bsr	rc_intersect
	bmi.s	.next_redraw	;IF RC_INTERSECT(x,y,w,h,tx,ty,tw,th)
	movem.l	d0-d1,rw_clip+0(a6)	;clip GRECT = d0.d1
	gem_aes	graf_mouse,#256,!
;
; NB: global clipping used to be done here, but is now replaced by the ability
;     of subfunctions to find clip rectangle via "rw_clip(a5)" .
;
; The specific draw mode subfunction is selected by "md"
; md: 1=blank  2=draw  3=ver_scroll  4=hor_scroll
;
	move	rw_md(a6),d0
	lsl	#2,d0
	move.l	draw_fn_t(pc,d0),a0
	move.l	rw_clip+4(a6),-(sp)
	move.l	rw_clip+0(a6),-(sp)
	move	rw_md(a6),-(sp)
	jsr	(a0)
	lea	10(sp),sp
	gem_aes	graf_mouse,#257,!
.next_redraw:			;ENDIF
	move	(sp)+,d0	;pull flag
	beq.s	.done_redraw
	gem_aes	wind_get,tw_wind_o(a3),#12
	bra	.redraw_loop
;				;WEND
.done_redraw:
	gem_aes	wind_update,#2
	gem_aes	wind_update,!
	move.l	(sp)+,a5
.exit_redraw			;ENDIF
	unlk	a6
tw_noop:
	rts
;
; The subfunctions in table "draw_fn_t" all have identical arguments,
; since they inherit the arguments of "tw_redraw".
; Even so, they may also call each other with modified arguments !
; They must clip all drawing, using the GRECT at rw_clip(a5)
;
draw_fn_t:
	dc.l	tw_draw,tw_blnk,tw_draw,tw_rolv	;future,blank,draw,v_roll
	dc.l	tw_rolh,tw_draw,tw_draw,tw_draw	;h_roll,future,future,future
;
;	ends tw_redraw & tw_retext
; ----------------------------------------------------------------------------
tw_draw:		;tw_draw(md,x,y,w,h)	;draw pixel rectangle
	_debdef	tw_draw,2
;
; This draw primitive does not check rectangle validity ;;;
; To do so is the responsibility of calling routines ;;;
;
	link	a6,#-16
tw_ij_draw:			;internal entry point from co_subfunctions
	_debdef	tw_ij_draw,2
	sub	#48,sp		;reserve additional local variables
; 	----------------------------------------------------------
;	To avoid mixups the extra variables are defined here !!!
;
	rsset	-64
rw_col	rs.w	1	;-$40
rw_row	rs.w	1	;-$3E
rw_x1	rs.w	1	;-$3C
rw_y1	rs.w	1	;-$3A
rw_bw	rs.w	1	;-$38
rw_bh	rs.w	1	;-$36
rw_r	rs.w	1	;-$34
rw_c	rs.w	1	;-$32
rw_t	rs.l	1	;-$30
rw_t_o	rs.l	1	;-$2C
rw_px	rs.w	1	;-$28
rw_py	rs.w	1	;-$26
rw_pw	rs.w	1	;-$24
rw_gemf	rs.w	1	;-$22	;now disused, free for other use
rw_gemb rs.w	1	;-$20	;now disused, free for other use
rw_attr	rs.w	1	;-$1E
rw_fgc	rs.w	1	;-$1C
rw_bgc	rs.w	1	;-$1A
rw_bl	rs.w	1	;-$18
;
; 	----------------------------------------------------------
	gemdos	Super,!
	move.l	d0,d7
	move.l	tw_fntp_o(a3),d0
	bsr	find_font
	_a_t_sfont
	clr.l	d0
	_a_t_sscale
	moveq	#1,d0
	_a_t_smode
	clr	d0
	_a_t_rotate
	movem.l	rw_clip(a5),d0/d1
	_a_t_sclip
	move.l	tw_wrkx_o(a3),d0	;d0= (x1=tw_wrkx).(y1=tw_wrky)
	move	tw_vcol_o(a3),d1
	mulu	tw_chrw_o(a3),d1	;bw= tw_vcol*tw_chrw
	move	tw_vrow_o(a3),d2
	mulu	tw_chrh_o(a3),d2	;bh= tw_vrow*tw_chrh
	swap	d1
	move	d2,d1			;d1= bw.bh
	movem.l	rw_x(a6),d2-d3		;d2.d3= x.y.w.h
	bsr	rc_intersect
	bmi	no_text		;IF RC_INTERSECT(x,y,w,h,x1,y1,bw,bh)
; This redraw does affect text buffer display
do_text:
	_debdef	do_text,3
	movem.l	d0-d1,rw_x1(a6)		;store x1.y1.bw.bh (limted to visible pixels)
	clr.l	d0
	move	rw_x1(a6),d0
	sub	tw_wrkx_o(a3),d0
	divu	tw_chrw_o(a3),d0
	add	tw_scol_o(a3),d0
m_rw_col:
	_debdef	m_rw_col,3
	move	d0,rw_col(a6)	;col=((x1-tw_wrkx) DIV tw_chrw)+tw_scol	;column incl leftpix
	clr.l	d0
	move	rw_y1(a6),d0
	sub	tw_wrky_o(a3),d0
	divu	tw_chrh_o(a3),d0
	add	tw_srow_o(a3),d0
m_rw_row:
	_debdef	m_rw_row,3
	move	d0,rw_row(a6)	;row=((y1-tw_wrky) DIV tw_chrh)+tw_srow	;row incl toppix
	clr.l	d0
	move	rw_x1(a6),d0
	add	rw_bw(a6),d0
	sub	tw_wrkx_o(a3),d0
	add	tw_chrw_o(a3),d0
	subq	#1,d0
	divu	tw_chrw_o(a3),d0
	add	tw_scol_o(a3),d0
	sub	rw_col(a6),d0
m_rw_bw:
	_debdef	m_rw_bw,3
	move	d0,rw_bw(a6)
;bw=(x1+bw-tw_wrkx+tw_chrw-1) DIV tw_chrw+tw_scol-col	;text width incl rightpix
	clr.l	d0
	move	rw_y1(a6),d0
	add	rw_bh(a6),d0
	sub	tw_wrky_o(a3),d0
	add	tw_chrh_o(a3),d0
	subq	#1,d0
	divu	tw_chrh_o(a3),d0
	add	tw_srow_o(a3),d0
	sub	rw_row(a6),d0
m_rw_bh:
	_debdef	m_rw_bh,3
	move	d0,rw_bh(a6)
;bh=(y1+bh-tw_wrky+tw_chrh-1) DIV tw_chrh+tw_srow-row	;text height incl lowpix
	move	rw_col(a6),d0
	sub	tw_scol_o(a3),d0
	mulu	tw_chrw_o(a3),d0
	add	tw_wrkx_o(a3),d0
m_rw_x1:
	_debdef	m_rw_x1,3
	move	d0,rw_x1(a6)	;x1=(col-tw_scol)*tw_chrw+tw_wrkx	;pixel X of 1'st char
	move	rw_row(a6),d0
	sub	tw_srow_o(a3),d0
	mulu	tw_chrh_o(a3),d0
	add	tw_wrky_o(a3),d0
m_rw_y1:
	_debdef	m_rw_y1,3
	move	d0,rw_y1(a6)	;y1=(row-tw_srow)*tw_chrh+tw_wrky	;pixel Y of 1'st char
	move	d0,rw_py(a6)	;py=y1	;current pixel Y = y1
	move	tw_lnsz_o(a3),d0
	move	d0,d1
	mulu	rw_row(a6),d0
	move.l	d0,a0
	add	rw_col(a6),a0
m_rw_t:
	_debdef	m_rw_t,3
	move.l	a0,rw_t(a6)	;t=tw_lnsz*row+col	;text offset of first char
	sub	rw_bw(a6),d1
	ext.l	d1
m_rw_t_o:
	_debdef	m_rw_t_o,3
	move.l	d1,rw_t_o(a6)	;t_o=tw_lnsz-bw	;text offset between rows
; Begin drawing text
	moveq	#-1,d6				;attribute flags = -1
	clr	rw_r(a6)
draw_row:			;REPEAT	;for each visible row
	_debdef	draw_row,2
	move	rw_x1(a6),rw_px(a6)	;px&=x1&	;current pixel X = x1
	clr	rw_c(a6)		;c&=0
draw_group:			;REPEAT	;for each character group in a row
	_debdef	draw_group,2
;
; patch character group drawing here
;
	move.l	tw_attp_o(a3),a0
	add.l	rw_t(a6),a0
	clr	d0
	move.b	(a0),d0		;d0= group attributes
	move	d0,rw_attr(a6)	;att=BYTE{tw_attp+t}	;set group attributes
	move.l	tw_colp_o(a3),a0
	add.l	rw_t(a6),a0
	clr	d1
	move.b	(a0),d1		;d1= group colours
	btst	#5,d0
	bne.s	.ansi_colours
.vt52_colours:
	move	d0,d2
	add	d2,d2		;align cursor flag to inverse flag pos
	eor.b	d0,d2		;combine cursor flag with inverse flag
	bpl.s	.done_vt52_inv	;skip inversion if bit 7 zero
.vt52_inv:
	ror.b	#4,d1		;exchange vt52 colours if (cursor XOR inverse)
.done_vt52_inv:
	move	d1,d0		;d0 = d1 = foreground*16 + background vt52 colours
	lsr	#4,d0		;\ Colour     / d0 = fgc
	and	#15,d1		;/ separation \ d1 = bgc
	tst	tw_atac_o(a3)	;atari colouring ?
	bne.s	.vt52_ata_colour
	add	d0,d0
	add	d1,d1
	lea	vt52_ibmc_t(pc),a0
	move	(a0,d0),d2
	move	(a0,d1),d3
	bra.s	.test_diff_vt52
;
.vt52_ata_colour:
	move	d0,d2
	move	d1,d3
.test_diff_vt52:
	cmp	d2,d3
	bne.s	.have_diff
	tst	tw_cdif_o(a3)
	beq.s	.have_diff
	eor	#$01,d2
	bra.s	.have_diff
;
.ansi_colours:
	move	d0,d2
	add	d2,d2		;align cursor flag to inverse flag pos
	eor.b	d0,d2		;combine cursor flag with inverse flag
	bpl.s	.done_ansi_inv	;skip inversion if bit 7 zero
.ansi_inv:
	eor	#$77,d1		;invert ansi colours if (cursor XOR inverse)
.done_ansi_inv:
	move	d1,d0		;d0 = d1 = foreground*16 + background ANSI colours
	lsr	#4,d0		;\ Colour     / d0 = fgc
	and	#15,d1		;/ separation \ d1 = bgc
.atac_0:
	tst	tw_atac_o(a3)	;atari colouring ?
	beq.s	.ibm_col_ansi
	move.b	.atac_tb(pc,d0),d0
	move.b	.atac_tb(pc,d1),d1
	bra.s	.ibm_col_ansi
;
.atac_tb:
	dc.b	15,9,10,11,12,13,14,0,7,1,2,3,4,5,6,8
;
.ibm_col_ansi:
	add	d0,d0
	add	d1,d1
	lea	xbios_col_t(pc),a0
	move	(a0,d0),d2
	move	(a0,d1),d3
	cmp	d2,d3
	bne.s	.have_diff
	tst	tw_cdif_o(a3)
	beq.s	.have_diff
	eor	#$0E,d0
	move	(a0,d0),d2
.have_diff:
_rw_fgc:
	_debdef	_rw_fgc,3
	move	d2,rw_fgc(a6)		;set fg XBIOS colour
_rw_bgc:
	_debdef	_rw_bgc,3
	move	d3,rw_bgc(a6)		;set bg XBIOS colour
;
;;;	lea	vdi_col_t(pc),a0
;;;_rw_gemf:
;;;	_debdef	_rw_gemf,3
;;;	move	(a0,d0),rw_gemf(a6)	;set fg GEM colour
;;;_rw_gemb:
;;;	_debdef	_rw_gemb,3
;;;	move	(a0,d1),rw_gemb(a6)	;set bg GEM colour
;
colour_ok:			;ENDIF:ENDIF
	_debdef	colour_ok,3
	move	rw_bw(a6),d0
	sub	rw_c(a6),d0
	move	d0,-(sp)
	move.l	rw_t(a6),d0
	move.l	tw_colp_o(a3),a0
	pea	(a0,d0.l)
	move.l	tw_attp_o(a3),a0
	pea	(a0,d0.l)
	bsr	tw_brklen	;bl& = tw_brklen(L:tw_attp+t,L:tw_colp+t,W:bw-c)
	lea	10(sp),sp
	move	d0,rw_bl(a6)
	mulu	tw_chrw_o(a3),d0
	move	d0,rw_pw(a6)	;pw& = MUL(bl&,tw_chrw&)
;
	movem.l	rw_px(a6),d0-d1
	move	tw_chrh_o(a3),d1
	movem.l	rw_clip+0(a5),d2-d3
	bsr	rc_intersect
	bmi	next_text
	move	rw_bgc(a6),d2
	move.l	rw_base(a5),a0
	bsr	rc_blank		;display colour bar for text background
;
;
; Now determine if attributes need to be changed, and do it if needed
;
	move	rw_attr(a6),d0
	and	#$0F,d0
	cmp	d0,d6
	beq.s	attr_ok
	move	d0,d6
	_a_t_sstyle
attr_ok:
	_debdef	attr_ok,3
;
; Now set text colours
;
	movem.w	rw_fgc(a6),d0/d1		;fgc.bgc
	_a_t_colour
;
; Now set coordinates
;
	move.l	rw_px(a6),_a_t_destx	;X.Y position of group text
	move	rw_bl(a6),d0		;group text block length
	move.l	rw_t(a6),a0		;a0 -> group text start
	add.l	tw_txtp_o(a3),a0
	_a_t_text
;
	btst	#3,_a_t_style+1(pc)
	beq.s	.no_underline
	move.l	rw_px(a6),d0
	move	rw_pw(a6),d1
	swap	d1
	move.l	_a_t_font_p(pc),a0
	move	#1,d1
	cmp	#16,fnt_fheight(a0)
	blt.s	.got_ulsize		;if height >= 16 pix use 2 to underline, else 1
	addq	#1,d1
.got_ulsize:
	add	tw_chrh_o(a3),d0
	sub	d1,d0
	movem.l	rw_clip(a5),d2/d3
	bsr	rc_intersect	;clip to legal limits
	bmi.s	.no_underline
	move	rw_fgc(a6),d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
.no_underline:			;ENDIF
;
next_text:
	_debdef	next_text,2
;
; character group drawing complete
;
	clr.l	d0
	move	rw_pw(a6),d0
	add	d0,rw_px(a6)	;ADD px,pw
	move	rw_bl(a6),d0	
	add.l	d0,rw_t(a6)	;ADD t,bl
	add	d0,rw_c(a6)	;ADD c,bl
	move	rw_c(a6),d0
	cmp	rw_bw(a6),d0
	blo	draw_group	;UNTIL c>=bw	;loop until row runs out of groups
	move.l	rw_t_o(a6),d0
	add.l	d0,rw_t(a6)	;ADD t,t_o
	move	tw_chrh_o(a3),d0
	add	d0,rw_py(a6)	;ADD py,tw_chrh
	addq	#1,rw_r(a6)
	move	rw_r(a6),d0
	cmp	rw_bh(a6),d0
	blo	draw_row	;UNTIL r>=bh	;loop until all visible rows done
;
; All text drawing complete
;
	move	rw_x(a6),d0
	add	rw_w(a6),d0
	cmp	rw_px(a6),d0
	ble.s	no_right_bar	;IF x+w>px	;redraw needed to right of text
;
	move.l	rw_px(a6),d0
	move	rw_y(a6),d0	;d0 = px.y
	move	rw_x(a6),d1
	add	rw_w(a6),d1
	swap	d1
	move	rw_py(a6),d1	;d1 = x+w.py
	sub.l	d0,d1		;d1 = x+w-px,py-y
	movem.l	rw_x(a6),d2/d3
	bsr	rc_intersect	;clip to legal limits
	bmi.s	no_right_bar
	clr	d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
no_right_bar:			;ENDIF
;
	move	rw_y(a6),d0
	add	rw_h(a6),d0
	cmp	rw_py(a6),d0
	ble.s	no_low_bar	;IF y+h>py	;redraw needed below text
;
	movem.l	rw_x(a6),d0/d1	;d0 = x.y,  d1 = w.h
	move	rw_py(a6),d0	;d0 = x.py
	add	rw_y(a6),d1	;d1 = w.h+y
	sub	d0,d1		;d1 = w.h+y-py
	movem.l	rw_x(a6),d2/d3
	bsr	rc_intersect	;clip to legal limits
	bmi.s	no_low_bar
	clr	d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
no_low_bar			;ENDIF
;
; redraw with text completed
;
	bra.s	done_draw
;				;ELSE
no_text:	; This redraw affects no text display
	_debdef	no_text,3
	movem.l	rw_x(a6),d0/d1
	clr	d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
done_draw:			;ENDIF
	_debdef	done_draw,3
	gemdos	Super|_ind,d7
	unlk	a6
	rts
;
;
;	ends tw_draw
; ----------------------------------------------------------------------------
tw_blnk:		;tw_blnk(md,x,y,w,h)	;blank pixel rectangle
	_debdef	tw_blnk,2
;
; This draw primitive does not check rectangle validity ;;;
; To do so is the responsibility of calling routines ;;;
;
	link	a6,#-16
	move.l	tw_wrkx_o(a3),d0	;d0= (x1=tw_wrkx).(y1=tw_wrky)
	move	tw_vcol_o(a3),d1
	mulu	tw_chrw_o(a3),d1	;bw= MUL(tw_vcol,tw_chrw)
	move	tw_vrow_o(a3),d2
	mulu	tw_chrh_o(a3),d2	;bh= MUL(tw_vrow,tw_chrh)
	swap	d1
	move	d2,d1			;d1= bw.bh
	move.l	rw_x(a6),d2		;d2= x.y
	move.l	rw_w(a6),d3		;d3= w.h
	bsr	rc_intersect
	bmi	.no_text		;IF RC_INTERSECT(x,y,w,h,x1,y1,bw,bh)
; This redraw does affect text buffer display
; Begin drawing text
	move.l	d0,d4			;d4= x1.y1
	move.l	d1,d5			;d5= bw.bh
	move	tw_colr_o(a3),d2
	move	tw_attr_o(a3),d6
	btst	#5,d6
	bne.s	.ansi_colour
.vt52_colour:
	btst	#7,d6		;test attr NE(inverse), EQ(normal
	beq.s	.done_inv_vt52
	lsr	#4,d2		;force VT_52 inverse bgc = fgc
.done_inv_vt52:
	and	#15,d2		;separation  d2 = vt52 bgc
	tst	tw_atac_o(a3)	;atari colouring ?
	bne.s	.ata_col_vt52
	add	d2,d2
	lea	vt52_ibmc_t(pc),a0
	move	(a0,d2),d2	;d2 = new vt52 bgc
.ata_col_vt52:
	bra.s	.have_bgc
;
.ansi_colour:
	btst	#7,d6			;test attr NE(inverse), EQ(normal
	beq.s	.done_inv_ansi
	eor	#7,d2		;invert ANSI bgc
.done_inv_ansi:
	and	#15,d2		;separation  d2 = ANSI bgc
.atac_0:
	tst	tw_atac_o(a3)	;atari colouring ?
	beq.s	.ibm_col_ansi
	lea	.atac_tb(pc),a0
	move.b	(a0,d2),d2	;d2 = new ANSI bgc
.ibm_col_ansi:
	add	d2,d2
	lea	xbios_col_t(pc),a0
	move	(a0,d2),d2	;d2 = XBIOS bgc
.have_bgc:
;
	move.l	d4,d0
	move.l	d5,d1
	move.l	rw_base(a5),a0
	bsr	rc_blank	;blank text area
;
	move.l	d4,d3
	add.l	d5,d3
	move	rw_x(a6),d0
	add	rw_w(a6),d0
	move.l	d3,d1
	swap	d1
	cmp	d1,d0
	ble.s	.no_right_bar	;IF x+w>px	;redraw needed to right of text
	move.l	d3,d0
	move	rw_y(a6),d0
	move	rw_x(a6),d1
	add	rw_w(a6),d1
	swap	d1
	move	d3,d1
	sub.l	d0,d1
	clr	d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
.no_right_bar:			;ENDIF
	move	rw_y(a6),d0
	add	rw_h(a6),d0
	cmp	d3,d0
	ble.s	.no_low_bar	;IF y+h>py	;redraw needed below text
	move.l	rw_x(a6),d0
	move	d3,d0
	move.l	rw_w(a6),d1
	move	rw_h(a6),d1
	sub	d5,d1
	clr	d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
.no_low_bar:			;ENDIF
	bra.s	.done_blnk
;				;ELSE
.no_text:	; This redraw affects no text display
	move.l	rw_x(a6),d0
	move.l	rw_w(a6),d1
	clr	d2
	move.l	rw_base(a5),a0
	bsr	rc_blank
.done_blnk:			;ENDIF
	unlk	a6
	rts
;
.atac_tb:
	dc.b	15,9,10,11,12,13,14,0,7,1,2,3,4,5,6,8
;
;	ends tw_blnk
; ----------------------------------------------------------------------------
tw_rolv:		;tw_rolv(md,x,y,w,h)	;roll rectangle vertically
	_debdef	tw_rolv,2
;
; This scrolling primitive does not check rectangle validity ;;;
; To do so is the responsibility of calling routines ;;;
;
	link	a6,#-16
	move.l	rw_x(a6),d0		;d0 = x.y
	move.l	rw_w(a6),d1		;d1 = w.h
	move	tw_rold_o(a3),d2	;d2 = dir
	move.l	rw_base(a5),a0		;a0 = vbase
	move	d2,d3
	bpl.s	.keep_dist
	neg	d3			;d3 = dist
.keep_dist:
	cmp	d1,d3
	bls.s	.keep_newh
	move	d1,d3			;d3 = min(dist,h)
.keep_newh:
	move	d3,rw_h(a6)		;newh = min(dist,h)
	move	d0,d4			;d4 = y
	tst	d2
	bmi.s	.keep_newy
	add	d1,d4			;d4 = y+h
	sub	d3,d4			;d4 = y+h-newh
.keep_newy:
	move	d4,rw_y(a6)		;newy = dir<0 ? y+h-newh : y
	bsr	rc_scroll
	bra	tw_ij_draw	;jump into tw_draw(md,x,y,w,h)
;
;
;	ends tw_rolv
; ----------------------------------------------------------------------------
tw_rolh:		;tw_rolh(md,x,y,w,h)	;roll rectangle horizontally
	_debdef	tw_rolh,2
;
; This scrolling primitive does not check rectangle validity ;;;
; To do so is the responsibility of calling routines ;;;
;
	link	a6,#-16
	move	tw_rold_o(a3),d0
	bpl.s	.keep_size
	neg	d0
.keep_size:
	move	d0,rw_dsiz(a6)
	sub	rw_w(a6),d0	;d0 = dsiz-w
	bge.s	.non_roll	;IF dsiz<w
	neg	d0			;d0 = w-dsiz	;bw=w-dsiz
	move	rw_x(a6),d1		;d1 = x		;sx=x
	move	d1,d2
	add	rw_dsiz(a6),d2		;d2 = x+dsiz	;dx=x+dsiz
	move	d1,rw_dpos(a6)		;dpos=x
	tst	tw_rold_o(a3)
	bmi.s	.roll_out		;IF tw_rold>=0
	exg	d1,d2				;SWAP sx,dx
	add	d0,rw_dpos(a6)			;ADD dpos,bw
.roll_out:				;ENDIF
	lea	tw_bltm_t(pc),a1
	move	d0,(a1)			;tw_bltm(0)=bw
	move	rw_h(a6),2(a1)		;tw_bltm(1)=h
	move	tw_planes(pc),4(a1)	;tw_bltm(2)=tw_planes
	clr.l	6(a1)			;tw_bltm(3)=0		;tw_bltm(4)=0
	move	d1,14(a1)		;tw_bltm(7)=sx
	move	rw_y(a6),16(a1)		;tw_bltm(8)=y
	move.l	rw_base(a5),18(a1)	;tw_bltm(9)=tw_bash	;tw_bltm(10)=tw_basl
	move	d2,28(a1)		;tw_bltm(14)=dx
	move	rw_y(a6),30(a1)		;tw_bltm(15)=y
	move.l	rw_base(a5),32(a1)	;tw_bltm(16)=tw_bash	;tw_bltm(17)=tw_basl
	clr.l	42(a1)			;tw_bltm(21)=0		;tw_bltm(22)=0
	pea	(a1)
	bsr.s	tw_bitblt
	addq	#4,sp
	move	rw_dpos(a6),rw_x(a6)	;x=dpos
	move	rw_dsiz(a6),rw_w(a6)	;w=dsiz
.non_roll:			;ENDIF
	bra	tw_ij_draw	;tw_draw(md,x,y,w,h)
;
;	ends tw_rolh
; ----------------------------------------------------------------------------
; These low_level subroutines were originally in a BASIC array
;
tw_super:
	_debdef	tw_super,2
	clr.l	d7
tw_sup_x:
	_debdef	tw_sup_x,2
	exg	d0,d7
	gemdos	Super|_ind,d0
	exg	d7,d0
	rts
;
tw_bitblt:
	_debdef	tw_bitblt,2
	jsr	tw_super
	move.l	a6,-(sp)
	move.l	8(sp),a6
	_a_bitblt
	move.l	(sp)+,a6
	jsr	tw_sup_x
	rts
;
; long tw_brklen(char *attp,char *colp,word maxlen);
tw_brklen:
	_debdef	tw_brklen,2
	move.l	4(sp),a0	;a0->attribute buffer
	move.l	8(sp),a1	;a1->colour buffer
	move.b	(a0)+,d0
	move.b	(a1)+,d1
	move.l	a0,a2
	move	12(sp),d2
	subq	#1,d2
	bgt.s	.prep_loop
	blt.s	.got_break
	moveq	#1,d0
	rts
;
.prep_loop:
	subq	#1,d2
.break_loop:
	cmp.b	(a0)+,d0
	bne.s	.got_break
	cmp.b	(a1)+,d1
	dbne	d2,.break_loop
.got_break:
	sub.l	a2,a0
	move.l	a0,d0
	rts
;
;	ends low_level subroutines
; ----------------------------------------------------------------------------
;
	include	URAn_RC.S
;
; ----------------------------------------------------------------------------
;
	make	GEM_links
	make	_a_links
;
; ----------------------------------------------------------------------------
;
	section	DATA
;
ansi_4_5_fnt:
	incbin	'fonts\stansi06.fnt
;
ansi_4_6_fnt:
	incbin	'fonts\stansi07.fnt
;
ansi_6_6_fnt:
	incbin	'fonts\stansi08.fnt
;
ansi_8_8_fnt:
	incbin	'fonts\stansi09.fnt
;
ansi_8_16_fnt:
	incbin	'fonts\stansi10.fnt
;
; ----------------------------------------------------------------------------
; End of file:  TermWin.S
; ----------------------------------------------------------------------------
