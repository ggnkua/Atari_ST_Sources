#
#	This module converts the call frame from the Pure C
#	call frame to the Personal Pascal Call frame the
#	ICD routines are expecting.
#
#	WARNING: These routines will fail miserably if "cdecl"
#            calling is specified under "Options/Compiler"
#            Only the ANSI, non-cdecl, call frame is supported.
#
#	Caveat:  This module should support the GNU gcc call frame
#            though I have not verified this yet. The appropriate
#            changes to the syntax must be made to work with the 
#            GNU assembler.
#
# A special thanks goes out to ICD for leaving the debug
# info in their module, and having their debug format be
# compatable with Pure C.
#

#
#	Allow these to be referenced outside this module
#
xdef	_dma
xdef	_xdma
xdef	_sxdma
xdef	ID
xdef	LUN
xdef	Command
xdef	SecBuf

#
#	Allow references to the routines in the module DMA.O
#	provided by ICD
#

xref	DMA
xref	XDMA
xref	SXDMA
xref	ICDBOOT

	.DATA
#
# These are defined here because I felt that if the DMA routines
# were going to require them, they should provide space for them.
# ICD left this to the programmer, and I choose to put them here.
#
ID:			ds.w	1
LUN:		ds.w	1
Command:	ds.b	16
SecBuf:		ds.b	512

	.TEXT
_dma:
		link	a6,#0
        movem.l d1-d7/a0-a5,-(sp)
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.l	a1,-(sp)
		move.w	d1,-(sp)
		move.w	d2,-(sp)
		move.l	8(a6),-(sp)
		bsr.s	_mode_ck
		jsr		DMA
        movem.l (sp)+,d1-d7/a0-a5
		unlk	a6
		rts

_xdma:
		link	a6,#0
        movem.l d2-d7/a2-a5,-(sp)
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.l	a1,-(sp)
		move.w	d1,-(sp)
		move.w	d2,-(sp)
		move.l	8(a6),-(sp)
		bsr.s	_mode_ck
		jsr		XDMA
        movem.l (sp)+,d2-d7/a2-a5
		unlk	a6
		rts

_sxdma:
		link	a6,#0
        movem.l d2-d7/a2-a5,-(sp)
		move.w	d0,-(sp)
		move.l	a0,-(sp)
		move.l	a1,-(sp)
		move.w	d1,-(sp)
		move.w	d2,-(sp)
		move.l	8(a6),-(sp)
		bsr.s	_mode_ck
		jsr		SXDMA
        movem.l (sp)+,d2-d7/a2-a5
		unlk	a6
		rts
#
# This next little hack prevents the ICD routines from
# trying to switch to Supervisor Mode if the program is 
# already in Supervisory mode. Without this routine two
# bombs appear in device drivers!
# 
# This will not work with a new version of DMA.O if
# ICD moves the variables INSUPER and RESONX.
# INSUPER and RESONX exist in the two words immediately
# before the function ICDBOOT, which I can fortunately
# find.
#
#
_mode_ck:
		lea.l	ICDBOOT,a2
		tst.l	-(a2)				; point to INSUPER
		move.w	SR,d2
		andi.w	#$2000,d2			; check for supervisory mode
		beq.s	_usr_md				; if not branch
        move.w	#1,(a2)+			; say already in super mode
		clr.w	(a2)				; say do not go back to USER mode
		bra.s	_cont
_usr_md:
		clr.l	(a2)
_cont:
		rts

		.end