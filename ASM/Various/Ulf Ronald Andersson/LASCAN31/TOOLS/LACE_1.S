;----------------------------------------------------------------------------
;File name:	LACE_1.S			Revision date:	1994.08.21
;Created by:	Ulf Ronald Andersson		Creation date:	1993.08.12
;Code purpose:	Set AutoLace switch to overscan mode
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
	move.b	#$D6,(hw_kbcont).w	;set RTS of keyboard ACIA
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
;End of file:	LACE_1.S
;----------------------------------------------------------------------------
