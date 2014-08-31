;----------------------------------------------------------------------------
;File name:	CSIM_SET.S			Revision date:	2000.03.07
;Creator:	Ulf Ronald Andersson		Creation date:	2000.03.07
;(c)2000 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE
;----------------------------------------------------------------------------
;Purpose:	Source for CSIM_SET, forces C: as boot device
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	text
;----------------------------------------------------------------------------
BOOTDRIVE	=	'C'
;----------------------------------------------------------------------------
rz:	;relative zero
init:
	move.l	4(sp),a5
	lea	local_st_top(pc),sp
	gemdos	Mshrink,!,(a5),#init_lim-rz+$100
main:
	move	#BOOTDRIVE-'A',d0
	move	d0,d3
	gemdos	Super,!
	move.l	d0,a3
	move	d3,(_bootdev).w
	gemdos	Super,(a3)
	gemdos	Pterm0
;----------------------------------------------------------------------------
	bss
;----------------------------------------------------------------------------
local_stack:	ds.l	$1000
local_st_top:	ds.l	4
init_lim:
;----------------------------------------------------------------------------
;End of file:	CSIM_SET.S
;----------------------------------------------------------------------------
