;----------------------------------------------------------------------------
;File name:	LACE_UNL.S			Revision date:	1994.09.04
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.19
;Code purpose:	Disable LaceScan screen-lock (unlike boot default)
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
	move	#0,lpt_screen_lock(a0)	;disable LaceScan screen-lock
exit:
	clr	-(sp)			;gemdos	Pterm0 code
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LACE_UNL.S
;----------------------------------------------------------------------------

