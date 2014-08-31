;----------------------------------------------------------------------------
;File name:	XDEV_AUT.S			Revision date:	2000.03.07
;Creator:	Ulf Ronald Andersson		Creation date:	2000.02.12
;(c)2000 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE
;----------------------------------------------------------------------------
;Purpose:	Source for XDev_Aut, force active dev as _bootdev in \auto\
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	text
;----------------------------------------------------------------------------
rz:	;relative zero
mainboot:
	moveq	#-1,d6
	lea	refuse_ACC_s(pc),a3
	move.l	a0,d0
	bne	refuse_a3
	move.l	4(sp),a5
	lea	local_st_top(pc),sp
	gemdos	Mshrink,!,(a5),#init_lim-rz+$100
	lea	refuse_ramerr_s(pc),a3
	move.l	d0,d6
	bmi	refuse_a3
;
	gemdos	Dgetdrv
	move	d0,new_booter
	add.b	d0,root_path_s
	add.b	d0,mess_drive_char
;-------
	gemdos	Super,!
	move.l	d0,d7
;-------
	moveq	#-1,d6
	lea	refuse_nodrive_s(pc),a3
	move.l	_drvbits,d0
	move	new_booter(pc),d1
	btst	d1,d0
	beq.s	super_err_a3
	move	(_bootdev).w,loc_bootdev
	move	new_booter(pc),(_bootdev).w
;-------
	gemdos	Super|_ind,d7
;-------
	gemdos	Dsetpath,root_path_s(pc)
	gemdos	Dsetdrv,new_booter(pc)
	clr.l	d6
	lea	boot_ok_s(pc),a3
	bsr.s	display
	gemdos	Pterm,!
;
super_err_a3:
	gemdos	Super|_ind,d7
refuse_a3:
	bsr.s	display
	gemdos	Pterm,d6
;
display:
	moveq	#50/5,d3
	gemdos	Cconws,prog_head_s(pc)
	gemdos	Cconws,(a3)
	tst.l	d6
	bpl.s	.no_err
	moveq	#50*2,d3
	gemdos	Cconws,err_tail_s(pc)
.no_err:
	gemdos	Cconws,prog_tail_s(pc)
.loop:
	xbios	Vsync
	dbra	d3,.loop
	rts
;----------------------------------------------------------------------------
	data
;----------------------------------------------------------------------------
root_path_s:
	dc.b	'A:\',NUL
prog_head_s:
	dc.b	CR,LF
	dc.b	HT,ESC,"p","               ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","    XDev_Aut   ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","  Mar. 7 2000  ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","  R Andersson  ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","               ",ESC,"q",CR,LF
	dc.b	CR,LF,NUL
refuse_ACC_s:
	dc.b	"  Sorry, XDev_Aut is not an ACC-program!",NUL
refuse_ramerr_s:
	dc.b	"  System will not release XDev_Aut's RAM!",NUL
refuse_nodrive_s:
	dc.b	"  There is no such drive active, so to",CR,LF
	dc.b	"  activate XDev_Aut could bomb system.",NUL
err_tail_s:
	dc.b	CR,LF
	dc.b	"  There will now be a brief pause so",CR,LF
	dc.b	"  that you have time to see this text.",NUL
boot_ok_s:
	dc.b	"  Boot device is now "
mess_drive_char:
	dc.b	"A:",NUL
prog_tail_s:
	dc.b	CR,LF,CR,LF,NUL
;----------------------------------------------------------------------------
	bss
;----------------------------------------------------------------------------
loc_bootdev:	ds.w	1
new_booter:	ds.w	1
local_stack:	ds.l	$100
local_st_top:	ds.l	4
init_lim:
;----------------------------------------------------------------------------
;End of file:	XDEV_AUT.S
;----------------------------------------------------------------------------
