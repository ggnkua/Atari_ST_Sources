;----------------------------------------------------------------------------
;File name:	VMAP_7X.S			Revision date:	1999.03.25
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
	lea	(locstk_top).l,sp
	gemdos	Mshrink,!,(a5),#(bss_end-basepage)
	bios	Kbshift,?				;get Kbshift flags
	and	#$0F,d0					;mask away nonsense
	move.b	d0,initial_kbshift			;store flags
	gemdos	Cconws,(title_s).l			;show program title
	xbios	Supexec,main
	gemdos	Cconws,(exiting_s).l
	gemdos	Pterm0
;----------------------------------------------------------------------------
main:
	lea	(reserve_base).l,a0	;a0 -> base of reserved area
	move.l	a0,d0
	add.l	#$100-1,d0
	and.l	#-$100,d0		;d0 -> page boundary in reserved area
	move.l	d0,a6			;a6 -> FIX_RAM
	lea	VMAP_7XM_bin(pc),a0	;a0 -> VMAP_7XM program file
	lea	-ph_textbeg(a6),a1	;a1 -> place to load program
	move.l	#VMAP_7XM_size,d0
.loop:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.loop
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
;----------------------------------------------------------------------------
VMAP_7XM_bin:
	incbin	VMAP_7XM.BIN
	even
VMAP_7XM_end:
VMAP_7XM_size	=	VMAP_7XM_end-VMAP_7XM_bin
	ds.b	ph_textbeg
reserve_base:
	ds.b	$100
	ds.b	VMAP_7XM_size
code_end:
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
title_s:
	dc.b	CR,LF,' ',ESC,'p'
	dc.b	 ' VMAP_7X Version 1.01. (c)1999 RA ',ESC,'q',' ',CR,LF
	dc.b	NUL
exiting_s:
	dc.b	'  VMAP_7X exiting. (PMMU unchanged) ',CR,LF,NUL
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
;End of file:	VMAP_7X.S
;----------------------------------------------------------------------------
