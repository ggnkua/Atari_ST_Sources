;----------------------------------------------------------------------------
;File name:	XDEV_RST.S			Revision date:	2000.03.07
;Creator:	Ulf Ronald Andersson		Creation date:	2000.03.07
;(c)2000 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE
;----------------------------------------------------------------------------
;Purpose:	Source for XDEV_RST, force reset with active dev as boot dev
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	text
;----------------------------------------------------------------------------
rz:	;relative zero
init:
	move.l	4(sp),a5
	lea	local_st_top(pc),sp
	gemdos	Mshrink,!,(a5),#init_lim-rz+$100
main:
	gemdos	Dgetdrv
	move	d0,d3
	gemdos	Super,!
	move	d3,(_bootdev).w
	move.l	(_sysbase).w,a0		;a0 -> OS header (may be a copy)
	move.l	os_selfbeg_p(a0),a0	;a0 -> Original OS header
	move.l	os_reset_p(a0),a0	;a0 -> reset routine
	jmp	(a0)			;perform reset
;----------------------------------------------------------------------------
	bss
;----------------------------------------------------------------------------
local_stack:	ds.l	$1000
local_st_top:	ds.l	4
init_lim:
;----------------------------------------------------------------------------
;End of file:	XDEV_RST.S
;----------------------------------------------------------------------------
