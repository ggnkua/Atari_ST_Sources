;----------------------------------------------------------------------------
;File name:	FASTEN64.S			Revision date:	1999.03.26
;Created by:	Ulf Ronald Andersson		Creation date:	1999.03.26
;----------------------------------------------------------------------------
	output	.PRG
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
rz:
basepage	=	rz-$100
;----------------------------------------------------------------------------
code_beg:
	move.l	4(sp),a5
	lea	locstk_top(pc),sp
	gemdos	Mshrink,!,(a5),#(bss_end-basepage)
	gemdos	Maddalt,($04000000).l,#64*Mb
	tst.l	d0					;test failure flag
	bmi.s	exit_failure
exit_success:
	gemdos	Cconws,success_s(pc)
	gemdos	Pterm0
;-------
exit_failure:
	gemdos	Cconws,failure_s(pc)
	gemdos	Pterm0
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
title_s:
	dc.b	CR,LF,' ',ESC,'p'
	dc.b	 ' FASTEN64 Version 1.00. (c)1999 RA ',ESC,'q',' ',CR,LF
	dc.b	NUL
success_s:
	dc.b	'  FASTEN64 has activated 64MB FastRAM.',CR,LF,NUL
failure_s:
	dc.b	'  FASTEN64 failed to activate FastRAM.',CR,LF,NUL
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
bss_beg:
initial_kbshift:	ds.w	1
locstk_beg:		ds.b	$2000
locstk_top:
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	FASTEN64.S
;----------------------------------------------------------------------------
