;----------------------------------------------------------------------------
;File name:	HOGLO_NC.S			Revision date:	2000.05.27
;Created by:	Ulf Ronald Andersson		Creation date:	2000.05.27
;----------------------------------------------------------------------------
	output	.BS
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
trace_mode	set	0
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
	bsr	show_text
	lea	($100000).l,a6		;use 1MB border as limit
	move.l	(_membot).w,a5		;a5 -> current lomem
	cmp.l	a6,a5			;check if it is below limit
	bhs.s	.exit			;else just exit
	lea	hogging_s(pc),a0	;\ Tell user
	bsr.s	show_text		;/ low memory was hogged
	move.l	a6,(_membot)		;fix lomem in '_membot' ptr
	cmp.l	(themd+4).w,a5		;was free mem at lomem ?
	bne.s	.exit			;if not, fix is complete
	lea	patching_s(pc),a0	;\ Tell user
	bsr.s	show_text		;/ memory desriptor was patched
	move.l	a6,(themd+4).w		;fix memptr in 'themd' struct
	move.l	a5,d5
	sub.l	a6,d5			;d5 = negative size difference
	add.l	d5,(themd+8).w		;adjust size in 'themd' struct
.exit:
	lea	_CPU_cid(pc),a0
	bsr	find_cookie
	bmi.s	done_CACR
	cmp.l	#30,d1
	bne.s	done_CACR
	lea	uncaching_s(pc),a0	;\ Tell user
	bsr.s	show_text		;/ CPU caches will be disabled
	move.l	#$0A0A,d0		;fix value for CACR
	movec.l	d0,CACR			;store d0 as cache control bits
done_CACR:
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
	trace_CODE
;----------------------------------------------------------------------------
	include	"bs_comp\FINDCOOK.S"
;----------------------------------------------------------------------------
_CPU_cid:
	dc.l	'_CPU'
title_s:
	dc.b	CR,LF
	dc.b	'Boot sector program HOGLO_NC active.',CR,LF
	dc.b	NUL
hogging_s:
	dc.b	'Hogging RAM up to $100000.',CR,LF
	dc.b	NUL
patching_s:
	dc.b	'Patching system memory descriptor',CR,LF
	dc.b	NUL
uncaching_s:
	dc.b	'Disabling CPU caches',CR,LF
	dc.b	NUL
exiting_s:
	dc.b	'Exiting HOGLO_NC.',CR,LF
	dc.b	NUL
	EVEN
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
;End of file:	HOGLO_NC.S
;----------------------------------------------------------------------------
