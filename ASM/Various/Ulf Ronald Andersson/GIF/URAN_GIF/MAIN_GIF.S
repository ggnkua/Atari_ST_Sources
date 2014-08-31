;----------------------------------------------------------------------------
;File name:	MAIN_GIF.S		Revision date:	1995.06.24
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.23
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;File purpose:	Code library for GIF reading
;----------------------------------------------------------------------------
;	assembly parameters
;
MAXIMG		= 400000	; image (raster) buffer
MAXRAW		= 250000	; raw coded data buffer
;
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
start:	bra	main
;----------------------------------------------------------------------------
	include	READ_GIF.S
;----------------------------------------------------------------------------
;long	scan_MAGIC (infile_h, parse_s)
;long	scan_SD (infile_h, sd_p)
;long	scan_CM (infile_h, colors, cmap)
;long	scan_ID (infile_h, id_p)
;int	read_raster(infile_h,code_maxlen,rast_maxlen,code_p,rast_p)
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
;
gif_fd		ds.w	1
;
screen_desc:	ds.b	GIF_sd_size
image_desc:	ds.b	GIF_id_size
;
global_CMAP:	ds.b	CMAPSIZE*3	; Global color map
local_CMAP:	ds.b	CMAPSIZE*3	; color map used (global or local)
;
CodedGIF:	ds.b	MAXRAW		; raw LZW coded raster after unblock
Raster:		ds.b	MAXIMG		; final raster image of CMAP indici
;
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
;
main:
	lea	testfile_s(pc),a0
	bsr.s	load_gif_ia0
;
;	place file processing here
;
	gemdos	Pterm0
;
testfile_s:	dc.b	'work.gif',NUL
GIF87a_s:	dc.b	'GIF87a',NUL
;
	even
;
;----------------------------------------------------------------------------
;Start of:	'load_gif'
;----------------------------------------------------------------------------
load_gif_ia0:
	gemdos	Fopen,(a0),!
	tst.l	d0
	bmi	.exit		;exit with error if Fopen failed
	move	d0,gif_fd
;
	move	gif_fd,d0
	lea	GIF87a_s,a0
	bsr	scan_MAGIC	;scan_MAGIC(gif_fd,"GIF87a")
	tst.l	d0
	bmi	.exit
	move	gif_fd,d0
	lea	screen_desc,a0
	bsr	scan_SD		;scan_SD(gif_fd,&screen_desc)
	tst.l	d0
	bmi.s	.exit
;
	lea	screen_desc,a0
	tst.b	GIF_sd_gcm(a0)
	beq.s	.done_gcm
	move	gif_fd,d0
	move	GIF_sd_colors(a0),d1
	lea	global_CMAP,a0
	bsr	scan_CM		;scan_CM(gif_fd,screen_desc.sd_colors,&global_CMAP)
	tst.l	d0
	bmi.s	.exit
.done_gcm:
;
	move	gif_fd,d0
	lea	image_desc,a0
	bsr	scan_ID		;scan_ID(gif_fd,&image_desc)
	tst.l	d0
	bmi.s	.exit
;
	lea	image_desc,a0
	tst.b	GIF_id_lcm(a0)
	beq.s	.done_lcm
	move	gif_fd,d0
	move	GIF_id_colors(a0),d1
	lea	local_CMAP,a0
	bsr	scan_CM		;scan_CM(gif_fd,screen_desc.id_colors,&global_CMAP)
	tst.l	d0
	bmi.s	.exit
.done_lcm:
;
	move	gif_fd,d0
	move.l	#MAXRAW,d1
	move.l	#MAXIMG,d2
	lea	codedGIF,a0
	lea	Raster,a1
	bsr	read_raster
.exit:
	rts
;
; Here pixel data is available via 'Raster' and 'map' as shown below:
;
;	gifcolour	= Raster[ y * width + x ];
;	red		= map[ gifcolour ][ 0 ];
;	green		= map[ gifcolour ][ 1 ];
;	blue		= map[ gifcolour ][ 2 ];
;
;----------------------------------------------------------------------------
;End of:	'load_gif'
;----------------------------------------------------------------------------
;End of file:	MAIN_GIF.S
;----------------------------------------------------------------------------
