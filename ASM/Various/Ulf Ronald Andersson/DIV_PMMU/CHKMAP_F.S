;----------------------------------------------------------------------------
;File name:	CHKMAP_F.S			Revision date:	1999.03.23
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
	lea	locstk_top(pc),sp
	gemdos	Mshrink,!,(a5),#(bss_end-basepage)
	bios	Kbshift,?				;get Kbshift flags
	and	#$0F,d0					;mask away nonsense
	move.b	d0,initial_kbshift			;store flags
	gemdos	Cconws,title_s(pc)			;show program title
	xbios	Supexec,main
	move.l	d0,a4					;a4 -> old PMMU regs
	move	d1,d4					;d4 = 'mapper response' flag
	and	#$0F,d0
	btst	#0,initial_kbshift(pc)			;Right shift pressed ?
	beq.s	done_hexdump				;if not, skip hexdump
	gemdos	Super,!
	move.l	d0,-(sp)
	move.l	a4,a0
	bsr	seemem					;show hexdump
	gemdos	Super,()
done_hexdump:
	tst	d4					;test 'mapper response' flag
	bmi.s	exit_passive
exit_remapped:
	gemdos	Cconws,remapped_s(pc)
	gemdos	Pterm0
;-------
exit_passive:
	gemdos	Cconws,passive_s(pc)
	gemdos	Pterm0
;----------------------------------------------------------------------------
main:
	lea	reserve_base(pc),a0	;a0 -> base of reserved area
	move.l	a0,d0
	add.l	#$100-1,d0
	and.l	#-$100,d0		;d0 -> page boundary in reserved area
	move.l	d0,a6			;a6 -> FIX_RAM
	lea	CHKMAPFM_bin(pc),a0	;a0 -> CHKMAPFM program file
	lea	-ph_textbeg(a6),a1	;a1 -> place to load program
	move	#CHKMAPFM_size,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
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
CHKMAPFM_bin:
	incbin	CHKMAPFM.BIN
	even
CHKMAPFM_end:
CHKMAPFM_size	=	CHKMAPFM_end-CHKMAPFM_bin
	ds.b	ph_textbeg
reserve_base:
	ds.b	$100
	ds.b	CHKMAPFM_size
code_end:
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
title_s:
	dc.b	CR,LF,' ',ESC,'p'
	dc.b	 ' CHKMAP_F Version 1.01. (c)1999 RA ',ESC,'q',' ',CR,LF
	dc.b	NUL
remapped_s:
	dc.b	'  CHKMAP_F remapped. (PMMU in use) ',CR,LF,NUL
passive_s:
	dc.b	'  CHKMAP_F passive. (PMMU unchanged) ',CR,LF,NUL
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
;End of file:	CHKMAP_F.S
;----------------------------------------------------------------------------
