;----------------------------------------------------------------------------
;File name:	FINDCOOK.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1998.06.25
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
find_cookie:
	move.l	(_cookies).w,a1
	move.l	a1,d0
	beq.s	.error_PTHNF
.loop:
	movem.l	(a1)+,d0/d1
	cmp.l	(a0),d0
	beq.s	.exit
	tst.l	d0
	bne.s	.loop
.error_FILNF:
	moveq	#E_FILNF,d0
	rts
;
.error_PTHNF:
	moveq	#E_PTHNF,d0
.exit:
	rts
;----------------------------------------------------------------------------
;End of file:	FINDCOOK.S
;----------------------------------------------------------------------------
