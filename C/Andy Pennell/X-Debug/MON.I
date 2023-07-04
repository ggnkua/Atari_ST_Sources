
CREGS	reg	d2-d7/a2-a3/a5
CREGS2	reg	d2-d7/a2-a3/a5-a6

PROC	macro
	link	a6,#0
	movem.l	CREGS,-(sp)
	endm

ENDPROC	macro
	movem.l	(sp)+,CREGS
	unlk	a6
	rts
	endm

GETA4	macro
	xref	__LinkerDB
	lea	__LinkerDB,a4
	endm

* these must agree with mon.h
ERR_NOMEMORY	equ	6
ERR_NODCR	equ	89
ERR_BADLEVEL	equ	90
ERR_VIRTUAL	equ	91
ERR_DCRDIFF	equ	92
ERR_NOMMU	equ	87
ERR_OVERLAPS	equ	93
ERR_BADP	equ	1
ERR_TTREG	equ	96

ERRM_ALREADYLOADED	equ	12
ERRM_NOSYSMEM		equ	13

EXNUM_UNKNOWN	equ	64
EXNUM_TRAP	equ	65
EXNUM_UNUSEDTRAP equ	66

MAXY	equ	64

	rsreset
REG_PC	rs.l	1
REG_D0	rs.l	8
REG_A0	rs.l	8
REG_SSP	rs.l	1
REG_SR	rs.w	1
REG_MSP	rs.l	1		030 (low word=68000 IR)
REG_ISP	rs.l	1		030
* 68030 specials
REG_VBR	rs.l	1
REG_SFC	rs.l	1
REG_DFC	rs.l	1
REG_CACR	rs.l	1
REG_CAAR	rs.l	1
* MMU 030 regs
REG_CRP		rs.l	2
REG_SRP		rs.l	2
REG_TC		rs.l	1
REG_TT0		rs.l	1
REG_TT1		rs.l	1
REG_MMUSR	rs.w	1

	rsreset
bit_exitpc	rs.b	1
