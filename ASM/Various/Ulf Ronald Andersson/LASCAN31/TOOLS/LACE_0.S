;----------------------------------------------------------------------------
;File name:	LACE_0.S			Revision date:	1994.08.21
;Created by:	Ulf Ronald Andersson		Creation date:	1993.08.12
;Code purpose:	Set AutoLace switch to non_overscan mode
;----------------------------------------------------------------------------
;
	SECTION TEXT
;
;----------------------------------------------------------------------------
;
hw_kbcont	= $FFFFFC00
;
;----------------------------------------------------------------------------
;
start:
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,-(sp)
	move.b	#$96,(hw_kbcont).w	;clear RTS of keyboard ACIA
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	moveq	#3-1,d3
.loop:
	move	#$25,-(sp)
	trap	#14
	addq	#2,sp
	dbra	d3,.loop	;loop to ensure recognition of new state
	clr	-(sp)
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LACE_0.S
;----------------------------------------------------------------------------
