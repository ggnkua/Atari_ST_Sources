;----------------------------------------------------------------------------
;File name:	CT2BUS_F.S			Revision date:	1999.05.17
;Created by:	Ulf Ronald Andersson		Creation date:	1999.03.20
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
	lea	locstk_top,sp
	gemdos	Mshrink,!,(a5),#(bss_end-basepage)
	bios	Kbshift,?				;get Kbshift flags
	and	#$0F,d0					;mask away nonsense
	move.b	d0,initial_kbshift			;store flags
	gemdos	Cconws,title_s				;show program title
	xbios	Supexec,main
	move.l	d0,a4					;a4 -> old PMMU regs
	move.l	d1,d4					;d4 = 'mapper response' flag
	and	#$0F,d0
	btst	#0,initial_kbshift			;Right shift pressed ?
	beq.s	done_hexdump				;if not, skip hexdump
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	a4,a0
	bsr	seemem					;show hexdump
	gemdos	Super,()
done_hexdump:
	tst	d4					;test 'mapper response' flag
	bmi.s	exit_nonresident
exit_resident:
	gemdos	Cconws,resident_s
	gemdos	Ptermres,#(code_end-basepage),!
;-------
exit_nonresident:
	gemdos	Cconws,nonresident_s
	gemdos	Pterm0
;----------------------------------------------------------------------------
main:
	lea	reserve_base,a0		;a0 -> base of reserved area
	move.l	a0,d0
	and.l	#-$100,d0		;d0 -> page boundary in reserved area
	move.l	d0,a6			;a6 -> FIX_RAM
	lea	CT2BUSFM_bin(pc),a0	;a0 -> CT2BUSFM program file
	lea	-ph_textbeg(a6),a1	;a1 -> place to load program
	cmpa.l	a0,a1
	beq.s	.done_move
	move.l	#CT2BUSFM_size-1,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	sub.l	#$10000,d0
	bpl.s	.loop
.done_move:
	lea	(a6),a0			;a0 -> textbeg
	lea	-ph_textbeg(a6),a1	;a1 -> program header
	bsr.s	relocate		;relocate program
	moveq	#-1,d0			;-1 means query (PMMU unaffected)
	cmp.b	#$0f,initial_kbshift	;<Alt><Ctrl><l_shift><r_shift> ?
	beq.s	exec_mapper
	moveq	#0,d0			;0 means init (PMMU reconfigured)
exec_mapper:
	move	d0,mapper_command
	jmp	(a6)
;----------------------------------------------------------------------------
	include	bs_comp\RELOCATE.S
	include	bs_comp\SEEMEM.S
;----------------------------------------------------------------------------
	ds.b	$100
	ds.b	ph_textbeg
reserve_base:
CT2BUSFM_bin:
	incbin	CT2BUSFM.BIN
	even
CT2BUSFM_end:
CT2BUSFM_size	=	CT2BUSFM_end-CT2BUSFM_bin
code_end:
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
title_s:
	dc.b	CR,LF,' ',ESC,'p'
	dc.b	 ' CT2BUS_F Version 1.2  (c)1999 RA ',ESC,'q',' ',CR,LF
	dc.b	NUL
resident_s:
	dc.b	'  CT2BUS_F installed. (PMMU in use) ',CR,LF,NUL
nonresident_s:
	dc.b	'  CT2BUS_F exited. (PMMU unchanged) ',CR,LF,NUL
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
bss_beg:
mapper_command:		ds.w	1
initial_kbshift:	ds.w	1
locstk_beg:		ds.b	$2000
locstk_top:
bss_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	CT2BUS_F.S
;----------------------------------------------------------------------------
