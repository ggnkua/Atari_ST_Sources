******************************** routines.s ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/mouse.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:18:47 $     $Locker:  $
* =============================================================================
*
* $Log:	mouse.s,v $
*******************************************************************************

.include	"vdiincld.s"

		.globl	_STHardList		; orig ST routines blitter
		.globl	_STSoftList		; orig ST routines no blitter
		.globl	_PixHardList		; pixel packed routines
		.globl	_PixSoftList		; pixel packed routines
		.globl	_SPPixSoftList		; SPARROW routines (hard blit)
		.globl	_SPPixHardList		; SPARROW routines (hard blit)


		.globl	hb_cell,hb_scrup,hb_scrdn,hb_blank,hb_bitblt
		.globl	hb_mono,hb_rect,hb_vline,hb_hline,hb_text
		.globl	_tt_vq_color,_tt_vs_color,_init_st_tt_sp
		.globl	_st_vq_color,_st_vs_color
		.globl	_sp_vq_color,_sp_vs_color
		.globl	st_cur_display,st_cur_replace,st_neg_cell
		.globl	st_move_cursor,ST_ABLINE,ST_HABLINE
		.globl	ST_PUTPIX,ST_GETPIX

_STHardList:	dc.l	hb_cell
		dc.l	hb_scrup
		dc.l	hb_scrdn
		dc.l	hb_blank
		dc.l	hb_bitblt
		dc.l	hb_mono
		dc.l	hb_rect
		dc.l	hb_vline
		dc.l	hb_hline
		dc.l	hb_text
		dc.l	_st_vq_color
		dc.l	_st_vs_color
		dc.l	_init_st_tt_sp
		dc.l	st_cur_display		; show mouse cursor
		dc.l	st_cur_replace		; hide mouse cursor
		dc.l	st_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor		; move cursor to X,Y pos
		dc.l	ST_ABLINE
		dc.l	ST_HABLINE
		dc.l	ST_RECTFILL
		dc.l	ST_PUTPIX		; output pixel out to screen
		dc.l	ST_GETPIX		; get pixel value at X,Y

		.globl	sb_cell,sb_scrup,sb_scrdn,sb_blank,sb_bitblt
		.globl	sb_mono,sb_rect,sb_vline,sb_hline,sb_text
		.globl	ST_RECTFILL

_STSoftList:	dc.l	sb_cell			; cell_xfer subroutine
		dc.l	sb_scrup		; p_sc_up   subroutine
		dc.l	sb_scrdn		; p_sc_dn   subroutine
		dc.l	sb_blank		; blank_it  subroutine
		dc.l	sb_bitblt		; bitblt    subroutine
		dc.l	sb_mono			; mono8xh   subroutine
		dc.l	sb_rect			; rect_fill subroutine
		dc.l	sb_vline		; vline     subroutine
		dc.l	sb_hline		; _HABLINE  subroutine
		dc.l	sb_text			; textblt   subroutine
		dc.l	_st_vq_color
		dc.l	_st_vs_color
		dc.l	_init_st_tt_sp
		dc.l	st_cur_display		; show mouse cursor
		dc.l	st_cur_replace		; hide mouse cursor
		dc.l	st_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor		; move cursor to X,Y pos
		dc.l	ST_ABLINE
		dc.l	ST_HABLINE
		dc.l	ST_RECTFILL
		dc.l	ST_PUTPIX		; output pixel out to screen
		dc.l	ST_GETPIX		; get pixel value at X,Y

		.globl  spx_scrup,spx_scrdn
		.globl	spx_cell,spx_blank,px_cur_display,px_cur_replace
		.globl	spx_neg_cell,_sp_vq_color,_sp_vs_color,spx_bitblt
		.globl	_Init16Pal,_Init32Pal,spx_vline,spx_hline,PX_ABLINE
		.globl	PX_HABLINE,PX_RECTFILL,spx_text,PX_PUTPIX,PX_GETPIX
		.globl	_vq_32_color,_vs_32_color,_vq_16_color,_vs_16_color
		.globl	hpx_bitblt


_PixHardList:
_PixSoftList:	dc.l	spx_cell		; done
		dc.l	spx_scrup		; done  changed 9/2/92
		dc.l	spx_scrdn		; done  changed 9/2/92
		dc.l	spx_blank		; done
		dc.l	spx_bitblt		; done
		dc.l	spx_mono		; done
		dc.l	sb_rect			; done (look PX_RECTFILL)
		dc.l	spx_vline		; done
		dc.l	spx_hline		; done
		dc.l	spx_text
		dc.l	_vq_32_color
		dc.l	_vs_32_color
		dc.l	_Init32Pal		; init sparrow virtual pal
		dc.l	px_cur_display		; show mouse cursor
		dc.l	px_cur_replace		; hide mouse cursor
		dc.l	spx_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor		; move cursor to X,Y pos
		dc.l	PX_ABLINE		; done
		dc.l	PX_HABLINE		; done
		dc.l	PX_RECTFILL		; done
		dc.l	PX_PUTPIX		; output pixel out to screen
		dc.l	PX_GETPIX		; get pixel value at X,Y

_SPPixSoftList:	dc.l	spx_cell		; done
		dc.l	spx_scrup		; done
		dc.l	spx_scrdn		; done
		dc.l	spx_blank		; done
		dc.l	spx_bitblt		; done
		dc.l	spx_mono		; done
		dc.l	0			; done (look PX_RECTFILL)
		dc.l	spx_vline		; done
		dc.l	spx_hline		; done
		dc.l	spx_text
		dc.l	_vq_16_color
		dc.l	_vs_16_color
		dc.l	_Init16Pal		; init sparrow virtual pal
		dc.l	px_cur_display		; show mouse cursor
		dc.l	px_cur_replace		; hide mouse cursor
		dc.l	spx_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor		; move cursor to X,Y pos
		dc.l	PX_ABLINE		; done
		dc.l	PX_HABLINE		; done
		dc.l	PX_RECTFILL		; done
		dc.l	PX_PUTPIX		; output pixel out to screen
		dc.l	PX_GETPIX		; get pixel value at X,Y

_SPPixHardList:	dc.l	spx_cell		; done
		dc.l	spx_scrup		; done
		dc.l	spx_scrdn		; done
		dc.l	spx_blank		; done
		dc.l	hpx_bitblt		; done
		dc.l	spx_mono		; done
		dc.l	0			; done (look PX_RECTFILL)
		dc.l	spx_vline		; done
		dc.l	spx_hline		; done
		dc.l	spx_text
		dc.l	_vq_16_color
		dc.l	_vs_16_color
		dc.l	_Init16Pal		; init sparrow virtual pal
		dc.l	px_cur_display		; show mouse cursor
		dc.l	px_cur_replace		; hide mouse cursor
		dc.l	spx_neg_cell		; negates alpha cursor
		dc.l	st_move_cursor		; move cursor to X,Y pos
		dc.l	PX_ABLINE		; done
		dc.l	PX_HABLINE		; done
		dc.l	PX_RECTFILL		; done
		dc.l	PX_PUTPIX		; output pixel out to screen
		dc.l	PX_GETPIX		; get pixel value at X,Y

	.end
