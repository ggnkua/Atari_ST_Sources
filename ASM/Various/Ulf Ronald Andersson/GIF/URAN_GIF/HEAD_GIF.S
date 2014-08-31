;----------------------------------------------------------------------------
;File name:	HEAD_GIF.S		Revision date:	1995.06.23
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.23
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;File purpose:	Code library for GIF reading
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	HEAD_GIF_defined
HEAD_GIF_defined	set	1
;
;----------------------------------------------------------------------------
CMAPSIZE	= 256
HASHSIZE	= 4096		; size of hash tables
OUTSIZE		= 1025		; size of output table
;----------------------------------------------------------------------------
;	GIF Screen Descriptor structure
;
GIF_sd_dx	= 0	;width
GIF_sd_dy	= 2	;height
GIF_sd_colors	= 4	;colors used
GIF_sd_bits	= 6	;bits per pixel
GIF_sd_cr	= 8	;color resolution  (bits_per_colour/3)
GIF_sd_gcm	= 10	;global color map flag
GIF_sd_bgnd	= 11	;background color
GIF_sd_size	= 12	;size of structure
;
;----------------------------------------------------------------------------
;	GIF Image Descriptor structure
;
GIF_id_x	= 0	;X position relative to top left corner
GIF_id_y	= 2	;Y position relative to top left corner
GIF_id_dx	= 4	;width
GIF_id_dy	= 6	;height
GIF_id_colors	= 8	;colors used
GIF_id_bits	= 10	;bits per pixel
GIF_id_lcm	= 12	;local color map flag
GIF_id_lace	= 13	;0 => sequential  !0 => interlaced
GIF_id_size	= 12	;size of structure
;
;----------------------------------------------------------------------------
	endc	;HEAD_GIF_defined
;----------------------------------------------------------------------------
;End of file:	HEAD_GIF.S
;----------------------------------------------------------------------------
