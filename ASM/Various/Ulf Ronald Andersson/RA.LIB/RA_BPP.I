;----------------------------------------------------------------------------
;File name:	RA_BPP.I			Revision date:	1998.08.15
;Creator:	Ulf Ronald Andersson		Creation date:	1995.07.03
;(c)1995 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for basepage searching
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_BPP_defined
RA_BPP_defined	set	1
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
;Library macros:
;
;get_os_bp_p_p	=>  d0 -> -> running basepage
;
;----------------------------------------------------------------------------
;NB: You must include the following line somewhere after the macro calls
;	"make	BPP_links"
;NB: That will cause the needed routines to be included at that point.
;NB: You may do this several times (after further calls), and at each
;NB: point only the 'newly' referenced routines will be added to the code.
;NB: A dummy reference macro exists, so routines can be added to code even
;NB: without calling them.  The macro is '_uniref', used as below:
;	"_uniref get_os_bp_p_p"
;----------------------------------------------------------------------------
;	Macro definitions:
;----------------------------------------------------------------------------
;
BPP_links	macro
		_unidef	get_os_bp_p_p
		endm	;BPP_links
;
;----------------------------------------------------------------------------
;Macro:	get_os_bp_p_p	=> d0 -> -> running basepage
;
get_os_bp_p_p	macro
	_uniref	get_os_bp_p_p
	bsr	get_os_bp_p_p_code
	endm	;get_os_bp_p_p
;
;
get_os_bp_p_p_code	macro
	movem.l	d1-d4/a0-a2,-(sp)
	gemdos	Super|_ind,#1
	move.l	d0,d4
	bmi.s	.keep_super_1
	gemdos	Super,!
	move.l	d0,d4
.keep_super_1:
	movea.l	(_sysbase).w,a0
	movea.l	os_selfbeg_p(a0),a0
	cmpi.w	#$102,os_version(a0)
	blo.s	.older_tos		;if version < 1.02 goto .older_tos
	move.l	os_currbp_p_p(a0),d3
	bra.s	.exit
;
.older_tos:
	move.w	os_config(a0),d0
	asr.w	#1,d0
	subq.w	#4,d0
	bne.s	.old_tos_2
	move.l	#$873c,d3
	bra.s	.exit
;
.old_tos_2:
	move.l	#$602c,d3
.exit:
	tst.l	d4
	bmi.s	.keep_super_2
	gemdos	Super|_ind,d4
.keep_super_2:
	move.l	d3,d0
	movem.l	(sp)+,d1-d4/a0-a2
	rts
;
	ENDM	;get_os_bp_p_p_code
;
;----------------------------------------------------------------------------
	ENDC	;RA_BPP_defined
;----------------------------------------------------------------------------
;End of file:	RA_BPP.I
;----------------------------------------------------------------------------
