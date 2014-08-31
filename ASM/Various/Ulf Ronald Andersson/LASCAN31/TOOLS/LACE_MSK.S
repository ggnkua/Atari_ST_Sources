;----------------------------------------------------------------------------
;File name:	LACE_MSK.S			Revision date:	1994.09.04
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.19
;Code purpose:	Enable LaceScan physbase masking (like boot default)
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
	move	#-1,lpt_phys_mask(a0)	;enable physbase masking
exit:
	clr	-(sp)			;gemdos	Pterm0 code
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LACE_MSK.S
;----------------------------------------------------------------------------

