;----------------------------------------------------------------------------
;File name:	VFNT_ALL.S			Revision date:	1995.10.04
;Created by:	Ulf Ronald Andersson		Creation date:	1995.10.04
;Code purpose:	Enable VDIFONT to enforce fonts in all workstations
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
	sf	VF_inhibit_f(a0)	;allow forcing system workstation
	st	VF_allvwk_f(a0)		;allow forcing virtuals too
exit:
	clr	-(sp)			;gemdos	Pterm0 code
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	VFNT_ALL.S
;----------------------------------------------------------------------------
