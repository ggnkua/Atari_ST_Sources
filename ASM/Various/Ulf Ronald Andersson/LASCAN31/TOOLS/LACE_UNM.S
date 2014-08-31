;----------------------------------------------------------------------------
;File name:	LACE_UNM.S			Revision date:	1994.09.04
;Created by:	Ulf Ronald Andersson		Creation date:	1994.08.19
;Code purpose:	Disable LaceScan physbase masking (unlike boot default)
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
	move	#0,lpt_phys_mask(a0)	;disable physbase masking
exit:
	clr	-(sp)			;gemdos	Pterm0 code
	trap	#1
;
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	LACE_UNM.S
;----------------------------------------------------------------------------

