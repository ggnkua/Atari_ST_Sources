;----------------------------------------------------------------------------
;File name:	FALGAMEP.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	output	.PRG
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
code_beg:
	move.l	4(sp),a5		;a5 -> basepage
	lea	(2*Mb).l,a6		;a6 -> end of FIX_RAM
	move.l	a6,d5
	sub.l	a5,d5			;d5 = needed block size
	gemdos Mshrink,!,(a5),d5
	tst.l	d0
	bmi.s	failed_shrink
	gemdos	Super,!
	move.l	d0,-(sp)
	bsr	main
	gemdos	Super,()
	gemdos	Ptermres,d5,!
;-------
failed_shrink:
	gemdos	Pterm,#-1
;----------------------------------------------------------------------------
main:
	move.l	a6,a4
	sub.l	#512*Kb,a4		;a4 -> FIX_RAM
	lea	FAL_GAME_bin(pc),a0	;a0 -> FAL_GAME program file
	lea	-ph_textbeg(a4),a1	;a1 -> place to load program
	move	#FAL_GAME_size,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	lea	(a4),a0			;a0 -> textbeg
	lea	-ph_textbeg(a4),a1	;a1 -> program header
	bsr.s	relocate		;relocate program
	jmp	(a4)			;jump to program
;----------------------------------------------------------------------------
	include	bs_comp\RELOCATE.S
;----------------------------------------------------------------------------
FAL_GAME_bin:
	incbin	FAL_GAME.BIN
FAL_GAME_end:
FAL_GAME_size	=	FAL_GAME_end-FAL_GAME_bin
;----------------------------------------------------------------------------
	ds.b	ph_textbeg
	TEXT
code_end:
	END
;----------------------------------------------------------------------------
;End of file:	FALGAMEP.S
;----------------------------------------------------------------------------
