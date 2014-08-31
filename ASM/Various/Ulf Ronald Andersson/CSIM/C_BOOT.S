;----------------------------------------------------------------------------
;File name:	C_BOOT.S			Revision date:	2000.03.07
;Creator:	Ulf Ronald Andersson		Creation date:	1994.02.12
;(c)1994 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE
;----------------------------------------------------------------------------
;Purpose:	Source for C_Boot, forces C: as boot device
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	text
;----------------------------------------------------------------------------
BOOTDRIVE	=	'C'
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
	move	#BOOTDRIVE-'A',d0
	move	d0,new_booter
	add.b	d0,root_path_s
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
	move	new_booter(pc),d1
	cmp	loc_bootdev(pc),d1
	beq.s	.exit_ok
	lea	force_boot_s(pc),a3
	bsr.s	display
.exit_ok:
	gemdos	Dsetpath,root_path_s(pc)
	gemdos	Dsetdrv,new_booter(pc)
	gemdos	Fopen,dummy_fname_s(pc),!
	move.l	d0,d3
	bmi.s	.closed
	gemdos	Fclose,d3
.closed:
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
	moveq	#50/4,d3
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
dummy_fname_s:
	dc.b	'F',NUL
root_path_s:
	dc.b	'A:\',NUL
prog_head_s:
	dc.b	CR,LF
	dc.b	HT,ESC,"p","               ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","  C_Boot 1.01  ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","  Mar. 7 2000  ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","  R Andersson  ",ESC,"q",CR,LF
	dc.b	HT,ESC,"p","               ",ESC,"q",CR,LF
	dc.b	CR,LF,NUL
refuse_ACC_s:
	dc.b	"  Sorry, C_Boot is not an ACC-program!",NUL
refuse_ramerr_s:
	dc.b	"  System will not release C_Boot's RAM!",NUL
refuse_nodrive_s:
	dc.b	"  There is no such drive active, so to",CR,LF
	dc.b	"  activate C_Boot now could bomb system.",NUL
err_tail_s:
	dc.b	CR,LF
	dc.b	"  There will now be a brief pause so",CR,LF
	dc.b	"  that you have time to see this text.",NUL
boot_ok_s:
	dc.b	"  System is now booting C:",NUL
force_boot_s:
	dc.b	"  Forcing system to boot C: !",NUL
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
;End of file:	C_BOOT.S
;----------------------------------------------------------------------------
