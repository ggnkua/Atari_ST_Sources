;----------------------------------------------------------------------------
;File name:	Redir_Sh.S			Revision date:	1996.11.29
;Created by:	Ulf Ronald Andersson		Creation date:	1996.11.29
;Copyright:	(C)1996 Ulf Ronald Andersson	Version:	1.0
;----------------------------------------------------------------------------
;
	output	.PRG
;
	include	URAn_SYS.S
	include	URAn_DOS.S
;
;
	text
;
	opt	a+
	opt	o+
;	
;----------------------------------------------------------------------------
;
start:
	move.l	4(sp),a5		;a5->BP
	lea	loc_stack_top(pc),sp
	move.l	bp_bss_beg_p(a5),a0
	add.l	bp_bss_len(a5),a0
	sub.l	a5,a0			;a0 = total size of program
	gemdos	Mshrink,!,(a5),a0	;returns RAM to OS
	xbios	Supexec,pre_main
	bsr.s	main
	tst.l	d0
	bpl.s	.exit_program
	lea	main_error_s(pc),a0
	bsr	show_error
.exit_program:
	clr.l	d0
	gemdos	Pterm,d0
;
;----------------------------------------------------------------------------
;
pre_main:
	move	(_bootdev).w,d0
	add	#'A',d0
	move.b	d0,TOS_name_s
	move.b	d0,TOX_name_s
	rts
;
;----------------------------------------------------------------------------
;
main:
	clr.l	d3
	bios	Kbshift,?
	and	#$08,d0		;alternate key present ?
	beq.s	.try_redirect	;if not, go try REDIRECT as-is
;
	gemdos Frename,!,TOS_name_s(pc),TOX_name_s(pc)
	move.l	d0,d3
	bpl.s	.main_exit	;exit on successful disabling of REDIRECT.
	gemdos Frename,!,TOX_name_s(pc),TOS_name_s(pc)
	move.l	d0,d3
	bmi.s	.main_exit	;exit on failed enabling of REDIRECT.
	moveq	#-1,d3
.try_redirect:
	gemdos	Pexec,!,TOS_name_s(pc),null_s(pc),!
	tst.l	d3
	bpl.s	.main_exit
	move.l	d0,d3
.main_exit:
	move.l	d3,d0
	rts
;
;----------------------------------------------------------------------------
;
show_error:
	move.l	d0,-(sp)
	move.l	a0,-(sp)
.wait_exit:
	gemdos	Cconws,progname_s(pc)
	gemdos	Cconws,()
	gemdos	Cconws,errortail_s(pc)
	gemdos	Crawcin
	cmp.b	#CR,d0
	bne.s	.wait_exit
	move.l	(sp)+,a0
	move.l	(sp)+,d0
	rts
;
;----------------------------------------------------------------------------
;
	data
;
;----------------------------------------------------------------------------
;
progname_s:
	dc.b	CR,LF
	dc.b	ESC,'p'
	dc.b	'  Redir_Sh version 1.1  1996.07.17  ',ESC,'q',CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
main_error_s:
	dc.b	' Some error occurred in initializing',CR,LF
	dc.b	' your video redirection...!',CR,LF
	dc.b	NUL
;
errortail_s:
	dc.b	' Press [Return] to continue boot, or',CR,LF
	dc.b	' press RESET to abort boot process.',CR,LF
	dc.b	CR,LF
	dc.b	NUL
;
TOS_name_s:	dc.b	'A:\AUTO\REDIRECT.TOS',NUL
TOX_name_s:	dc.b	'A:\AUTO\REDIRECT.TOX',NUL
	even
;
null_s:
	dc.l	0
;
;----------------------------------------------------------------------------
;
	bss
;
;----------------------------------------------------------------------------
;
	ds.l	$100	;allow 256 longwords on minimum stack
loc_stack_top:
;
;----------------------------------------------------------------------------
;End of file:	Redir_Sh.S
;----------------------------------------------------------------------------
