
*********************************************************************
* Defines to control routines & mode that FDC source operates
* under.
*********************************************************************

;C_LINK		; Include external link information
;FORMAT		; Include formatting routines
;BOOTSECTOR	; Include bootsector routines
;FORMATDATA	; Include format tables
;DEBUG		; Include debugging info
;DOUGMACS	; Do not use my 'general.i' file

MAX_DENSITY	= 2	; High density

	ifd	DEBUG
	OPT	X+
	else
	OPT	X-
	endc

*********************************************************************
* Linking definitions
* These only appear if C_LINK is used
*********************************************************************

	ifd	C_LINK

	OPT	L2

	xdef	fdc_done
	xdef	fdc_init,fdc_kill
	xdef	kill_drive
	xdef	fdc_readwrite
	xdef	p_buffer,p_density,p_flags,p_track,p_side,p_drive,p_sector
	xdef	p_numsectors,p_numtracks,p_maxtrack,p_maxsector,p_maxside
	xdef	p_secsize,p_secmap,p_timeout,p_retries,p_tracktable
	ifd	FORMAT
	xdef	fdc_format
	xdef	st_9,st_10,pc_18
	xdef	ftw1
	xdef	ftw2
	xdef	ftw3
	xdef	ftw4
	endc
	ifd	BOOTSECTOR
	xdef	fdc_create_bootsector,fdc_write_bootsector
	xdef	bp_tracks,bp_sectors,bp_sides,bp_spc,bp_direntries
	xdef	bp_serial,bp_bootcode,bp_bootsize,bp_media
	endc

	endc

*********************************************************************
* Include some useful stuff
* (General macros, OS equates, hardware registers, etc.)
*********************************************************************

	ifnd	DOUGMACS
	include	"general.i"
	endc
	include	"gemdos.i"
	include	"mfp.i"
	include	"cache.i"
