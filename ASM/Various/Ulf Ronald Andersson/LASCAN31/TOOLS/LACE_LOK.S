;----------------------------------------------------------------------------
;File name:	LACE_LOK.S			Revision date:	1994.09.04
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.19
;Code purpose:	Enable LaceScan screen-lock (like boot default)
;----------------------------------------------------------------------------
;
	INCLUDE	findlace.s
;
;----------------------------------------------------------------------------
;
	SECTION TEXT
;
;----------------------------------------------------------------------------
;
start:
	find_lace
	beq.s	exit			;exit if no structure found
	move.l	d0,a0
	move	#-1,lpt_screen_lock(a0)	;enable LaceScan screen-lock
exit:
	clr	-(sp)			;gemdos	Pterm0 code
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LACE_LOK.S
;----------------------------------------------------------------------------

