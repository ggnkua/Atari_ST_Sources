;----------------------------------------------------------------------------
;File name:	TST_PATH.S			Revision date:	2000.07.02
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
	output	.TOS
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
code_beg:
	move.l	4(sp),a5
	lea	loc_stktop(pc),sp
	gemdos	Mshrink,!,(a5),#($100+code_end-code_beg)
	move.l	a5,self_bp_p
	gemdos	Dgetdrv
	move	d0,drive_id
	gemdos	Dgetpath,buf_1(pc),!
	move	drive_id(pc),d0
	addq	#1,d0
	gemdos	Dgetpath,buf_2(pc),d0
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	(_sysbase).w,a0
	move.l	os_selfbeg_p(a0),a0
	move.l	os_currbp_p_p(a0),a1
	move.l	(a1),a1
	move.l	(a1),loc_curr_bp_p
	bsr.s	show_it
	gemdos	Super,()
	gemdos	Pterm0
;-------
show_it:
	lea	viewbase(pc),a0
	include	"bs_comp\seemem.s"
;-------
viewbase:
loc_curr_bp_p:	ds.l	1
self_bp_p:	ds.l	1
drive_id:	ds.w	1
		ds.b	6
buf_1:		ds.b	48
buf_2:		ds.b	1024
loc_stk:	ds.b	4096
loc_stktop:	ds.b	16
code_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	TST_PATH.S
;----------------------------------------------------------------------------
