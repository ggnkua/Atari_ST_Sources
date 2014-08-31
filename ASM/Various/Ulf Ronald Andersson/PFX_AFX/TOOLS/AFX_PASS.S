;----------------------------------------------------------------------------
;File name:	AFX_PASS.S		Revised:	1994.10.05
;Revised by:	Ulf Ronald Andersson	Revision date:	1993.01.12
;----------------------------------------------------------------------------
;File purpose:	Source of TOS program to set xAFX 'PASS' mode
;----------------------------------------------------------------------------
;
	section	TEXT
;
;----------------------------------------------------------------------------
;
start:
	clr.l	-(sp)
	move	#$20,-(sp)	;gemdos Super,!
	trap	#1
	addq	#6,sp
;
	move.l	d0,-(sp)	;push old SSP on stack for future 'Super'
;
	move.l	$5A0.w,d0
	beq.s	.exit		;exit if no cookie jar present
	move.l	d0,a0
.cookie_lp:
	move.l	(a0)+,d0
	beq.s	.exit
	cmp.l	#'xAFX',d0
	beq.s	.gotcha
	addq	#4,a0
	bra.s	.cookie_lp
;
.gotcha:
	move.l	(a0),a0
	move	SR,d2		;d2 = interrupt mask
	ori	#$0700,SR	;disable interrupts
;
	st	-4(a0)		;\/ Set xAFX
	or.l	#3,12(a0)	;/\ mode PASS
;
	move	d2,SR		;restore interrupt mask
.exit:
;
	move	#$20,-(sp)	;gemdos Super,()
	trap	#1
	addq	#6,sp
;
	clr	-(sp)		;gemdos Pterm0
	trap	#1
;
;
;----------------------------------------------------------------------------
	end
;----------------------------------------------------------------------------
;End of file:	AFX_PASS.S
;----------------------------------------------------------------------------
