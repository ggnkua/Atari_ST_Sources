;----------------------------------------------------------------------------
;File name:	FALCARTP.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	output	.PRG
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
INI_OFF	=	$40000	;offs to ident and init flags
MAP_OFF	=	$40400	;offs to translation tables etc
LIM_OFF	=	$7FF00	;phystop on coldboot must have higher offset
;----------------------------------------------------------------------------
	BSS
;----------------------------------------------------------------------------
bss_beg:
	ds.b	512*Kb
bss_end:
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
code_beg:
	gemdos	Super,!
	move.l	d0,-(sp)
	bsr	main
	gemdos	Super,()
	gemdos	Ptermres,#512*Kb,!
;----------------------------------------------------------------------------
main:
	lea	bss_beg(pc),a0		;a0 -> BSS start adress
	move.l	a0,d0
	add.l	#$100-1,d0
	and.l	#-$100,d0
	move.l	d0,a6			;a6 -> FIX_RAM
	lea	FAL_CART_bin(pc),a0	;a0 -> FAL_CART program file
	lea	-ph_textbeg(a6),a1	;a1 -> place to load program
	move	#FAL_CART_size,d0
.loop:
	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	lea	(a6),a0			;a0 -> textbeg
	lea	-ph_textbeg(a6),a1	;a1 -> program header
	bsr.s	relocate		;relocate program
	jmp	(a6)
;----------------------------------------------------------------------------
	include	bs_comp\RELOCATE.S
;----------------------------------------------------------------------------
FAL_CART_bin:
	incbin	FAL_CART.BIN
FAL_CART_end:
FAL_CART_size	=	FAL_CART_end-FAL_CART_bin
;----------------------------------------------------------------------------
	ds.b	ph_textbeg
	TEXT
code_end:
	END
;----------------------------------------------------------------------------
;End of file:	FALCARTP.S
;----------------------------------------------------------------------------
