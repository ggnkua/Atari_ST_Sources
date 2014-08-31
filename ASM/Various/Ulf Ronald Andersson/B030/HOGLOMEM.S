;----------------------------------------------------------------------------
;File name:	HOGLOMEM.S			Revision date:	2000.02.04
;Created by:	Ulf Ronald Andersson		Creation date:	2000.02.04
;----------------------------------------------------------------------------
	output	.BS
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
code_beg:
	bra.s	main_code	;boot sector code link
;----------------------------------------------------------------------------
	ds.b	28		;boot sector parts reserved for BIOS use
;----------------------------------------------------------------------------
main_code:
	lea	title_s(pc),a0
	bsr.s	show_text
	lea	($100000).l,a6		;use 1MB border as limit
	move.l	(_membot).w,a5		;a5 -> current lomem
	cmp.l	a6,a5			;check if it is below limit
	bhs.s	.exit			;else just exit
	lea	hogging_s(pc),a0
	bsr.s	show_text
	move.l	a6,(_membot)		;fix lomem in '_membot' ptr
	cmp.l	(themd+4).w,a5		;was free mem at lomem ?
	bne.s	.exit			;if not, fix is complete
	lea	patching_s(pc),a0
	bsr.s	show_text
	move.l	a6,(themd+4).w		;fix memptr in 'themd' struct
	move.l	a5,d5
	sub.l	a6,d5			;d5 = negative size difference
	add.l	d5,(themd+8).w		;adjust size in 'themd' struct
.exit:
	lea	exiting_s(pc),a0
	bsr.s	show_text
.exit_loop:
	xbios	Kbshift,?
	and	#3,d0
	bne.s	.exit_loop		;delay while a shift key is pressed
	rts				;exit to normal boot routines
;----------------------------------------------------------------------------
show_text:
	move.l	a0,a3
.show_loop:
	clr	d0
	move.b	(a3)+,d0
	beq.s	.show_exit
	bios	Bconout,#2,d0
	bra.s	.show_loop
;-------
.show_exit:
	rts
;----------------------------------------------------------------------------
_CPU_cookie_name:
	dc.l	'_CPU'
_MCH_cookie_name:
	dc.l	'_MCH'
title_s:
	dc.b	CR,LF
	dc.b	'Boot sector program HOGLOMEM active.',CR,LF
	dc.b	NUL
hogging_s:
	dc.b	'Hogging _membot up to $100000.',CR,LF
	dc.b	NUL
patching_s:
	dc.b	'Patching system memory descriptor',CR,LF
	dc.b	NUL
exiting_s:
	dc.b	'Exiting HOGLOMEM.',CR,LF
	dc.b	NUL
;----------------------------------------------------------------------------
code_end:
code_size	=	code_end-code_beg
;----------------------------------------------------------------------------
	sz_pad	boot_sector,510,code_size
;
checksum:
	dc.w	0
;----------------------------------------------------------------------------
booter_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	HOGLOMEM.S
;----------------------------------------------------------------------------
