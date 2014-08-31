;----------------------------------------------------------------------------
;File name:	SEEMEM_P.S			Revision date:	2000.06.12
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
code_beg:
	move.l	4(sp),a5
	lea	loc_stktop(pc),sp
	gemdos	Mshrink,!,(a5),#($100+code_end-code_beg)
	gemdos	Super,!
	move.l	d0,-(sp)
	bsr	show_it
	gemdos	Super,()
	gemdos	Pterm0
;-------
show_it:
	dc.w	$a000		;a0 -> line_a variable base
	include	"bs_comp\seemem.s"
;-------
loc_stk:	ds.b	4096
loc_stktop:	ds.b	16
code_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	SEEMEM_P.S
;----------------------------------------------------------------------------
