;----------------------------------------------------------------------------
;File name:	HOGTTRAM.S			Revision date:	2000.02.04
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
find_cookie:
	move.l	d0,d2
	move.l	(_cookies).w,a0
	move.l	a0,d0
	beq.s	.error
.loop:
	movem.l	(a0)+,d0/d1
	cmp.l	d2,d0
	beq.s	.exit
	tst.l	d0
	bne.s	.loop
.error:
	moveq	#E_ERROR,d0
.exit:
	rts
;----------------------------------------------------------------------------
main_code:
	lea	title_s(pc),a0
	bsr	show_text
;-------
	clr.l	d7			;clear reset need flag
	clr.l	d6			;clear CT2 caution flag
	move.l	#'_CPU',d0
	bsr.s	find_cookie
	bmi.s	.done_cookies
	cmp	#20,d1
	blo.s	.done_CPU
	cmp	#30,d1
	bhi.s	.done_CPU
	lea	uncaching_s(pc),a0
	bsr	show_text
	move.l	#$00000A0A,d0
	movec.l	d0,CACR			;disable CACR RAM caching
.done_CPU:
	move.l	#'_MCH',d0
	bsr.s	find_cookie
	bmi.s	.done_cookies
	swap	d1
	cmp	#3,d1
	bne.s	.done_cookies
	move.l	#'_CT2',d0
	bsr.s	find_cookie
	bmi.s	.done_cookies
	st	d6			;set CT2 caution flag
.done_cookies:
;;;	tst.b	d6			;CT2 caution flag set ?
;;;	bne.s	.done_TT_RAM
	cmp.l	#$1357BD13,(ramvalid).w
	bne.s	.done_TT_RAM
	moveq	#$01,d3			;d3 = $00000001 \/ shorter code for
	ror.l	#8,d3			;d3 = $01000000 /\ move.l #$1000000,d3
	cmp.l	(ramtop).w,d3
	bge.s	.done_TT_RAM
	lea	hog_TT_RAM_s(pc),a0
	bsr.s	show_text
	move.l	d3,(ramtop).w
	clr.l	(ramvalid).w
	st	d7			;set reset need flag
.done_TT_RAM:
;-------
	lea	($100000).l,a6		;use 1MB border as limit
	move.l	(_membot).w,a5		;a5 -> current lomem
	cmp.l	a6,a5			;check if it is below limit
	bhs.s	.done_lomem		;else just exit
;-------
	lea	hogging_s(pc),a0
	bsr.s	show_text
	move.l	a6,(_membot)		;fix lomem in '_membot' ptr
	cmp.l	(themd+4).w,a5		;was free mem at lomem ?
	bne.s	.done_lomem		;if not, fix is complete
;-------
	lea	patching_s(pc),a0
	bsr.s	show_text
	move.l	a6,(themd+4).w		;fix memptr in 'themd' struct
	move.l	a5,d5
	sub.l	a6,d5			;d5 = negative size difference
	add.l	d5,(themd+8).w		;adjust size in 'themd' struct
.done_lomem:
	tst.b	d7			;test reset need flag
	beq.s	.done_show_reset
	lea	resetting_s(pc),a0
	bsr.s	show_text
.done_show_reset:
	lea	exiting_s(pc),a0
	bsr.s	show_text
.exit_loop:
	xbios	Kbshift,?
	and	#3,d0
	bne.s	.exit_loop		;delay while a shift key is pressed
	tst.b	d7			;test reset need flag
	beq.s	.exit
	move.l	(_sysbase).w,a0		;a0 -> OS header (may be a copy)
	move.l	os_selfbeg_p(a0),a0	;a0 -> Original OS header
	move.l	os_reset_p(a0),a0	;a0 -> reset routine
	jmp	(a0)			;perform reset
;-------
.exit:
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
	dc.b	'HOGTTRAM active',CR,LF
	dc.b	NUL
uncaching_s:
	dc.b	'Disabling RAM caches',CR,LF
	dc.b	NUL
hog_TT_RAM_s:
	dc.b	'Hogging all TT_RAM',CR,LF
	dc.b	NUL
hogging_s:
	dc.b	'Hogging ST_RAM up to $100000',CR,LF
	dc.b	NUL
patching_s:
	dc.b	"Patching 'themd'",CR,LF
	dc.b	NUL
resetting_s:
	dc.b	'Warm reset will be made at exit',CR,LF
	dc.b	NUL
exiting_s:
	dc.b	'Exiting HOGTTRAM',CR,LF
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
;End of file:	HOGTTRAM.S
;----------------------------------------------------------------------------
