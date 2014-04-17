********************************** hard.s *************************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/mouse.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:18:47 $     $Locker:  $
* =============================================================================
*
* $Log:	mouse.s,v $
*******************************************************************************

.include	"vdiincld.s"

*+
* Link in this file if you choose to omit all the hardware assisted graphics
* routines and also aliminate font16x32. This files fixes the unresolved
* symboles problem.
*-

	.globl	sb_cell
	.globl	sb_scrup
	.globl	sb_scrdn
	.globl	sb_blank
	.globl	sb_bitblt
	.globl	sb_mono
	.globl	sb_rect
	.globl	sb_vline
	.globl	sb_hline
	.globl	sb_text
	.globl	_f16x32
	.globl	_off_8x8
	.globl	_dat_8x16

sb_cell:
sb_scrup:
sb_scrdn:
sb_blank:
sb_bitblt:
sb_mono:
sb_rect:
sb_vline:
sb_hline:
sb_text:	rts

_f16x32:

	dc.w	1					; WORD  font_id
	dc.w	10					; WORD  point
	dc.b	'8x16 system font                '	; BYTE  name[32]
	dc.w	0					; UWORD first_ade
	dc.w	255					; UWORD last_ade
	dc.w	13					; UWORD top
	dc.w	11					; UWORD ascent
	dc.w	8					; UWORD half
	dc.w	2					; UWORD descent
	dc.w	2					; UWORD bottom
	dc.w	7					; UWORD max_char_width
	dc.w	8					; UWORD max_cell_width
	dc.w	1					; UWORD left_offset
	dc.w	7					; UWORD right_offset
	dc.w	1					; UWORD thicken
	dc.w	1					; UWORD ul_size
	dc.w	0x5555					; UWORD lighten
	dc.w	0x5555					; UWORD skew
	dc.w	12					; UWORD flags
	dc.l	0					; UBYTE *hor_table
	dc.l	_off_8x8				; UWORD *off_table
	dc.l	_dat_8x16				; UWORD *dat_table
	dc.w	256					; UWORD form_width
	dc.w	16					; UWORD form_height
	dc.l	0					; UWORD *next_font
	dc.w	0					; UWORD next_seg


