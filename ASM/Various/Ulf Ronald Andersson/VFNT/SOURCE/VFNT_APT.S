;----------------------------------------------------------------------------
;File name:	VFNT_APT.S			Revision date:	1995.10.07
;Created by:	Ulf Ronald Andersson		Creation date:	1995.10.07
;Code purpose:	Toggle VDIFont enforcement state for virtual workstations
;----------------------------------------------------------------------------
;
	INCLUDE	findvfnt.s
;
;----------------------------------------------------------------------------
;
	SECTION TEXT
;
;----------------------------------------------------------------------------
;
start:
	move.l	4(sp),a5		;a5 -> basepage
	move.l	24(a5),d5		;d5 -> bss area start
	add.l	28(a5),d5		;d5 -> bss area end
	sub.l	a5,d5			;d5 =  total RAM size
	move.l	d5,-(sp)		;push RAM size
	move.l	a5,-(sp)		;push -> basepage
	move	#0,-(sp)		;push extra zero word
	move	#$4A,-(sp)		;push gemdos Mshrink op
	trap	#1			;call gemdos
	add	#12,sp			;cleanup stack
;
	find_VFnt
	beq.s	exit			;exit if no structure found
	move.l	d0,a0
	tst.b	VF_allvwk_f(a0)		;test if virtuals forced now
	seq	VF_allvwk_f(a0)		;and toggle that state
exit:
	clr	-(sp)			;gemdos	Pterm0 code
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	VFNT_APT.S
;----------------------------------------------------------------------------
