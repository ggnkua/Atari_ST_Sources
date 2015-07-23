*-------------------------------------------------------------------------------
* ClearMemory: Speicher mit Nullen fllen
* ---> D0.l = Anzahl Bytes (1-...)
* ---> A0.l = ab hier wird gel”scht
*
* ClearMemorySpace: Speicher mit Spaces fllen
* ---> D0.l = Anzahl Bytes (1-...)
* ---> A0.l = ab hier wird gel”scht
*-------------------------------------------------------------------------------

		.EXPORT		ClearMemory,ClearMemorySpace

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.BSS
CLEAR_ZERO:		ds.w	8										; einfach leer!

		.DATA
CLEAR_SPACE:	dc.l	$20202020,$20202020,$20202020,$20202020	; einfach leer!
				dc.l	$20202020,$20202020,$20202020,$20202020

*-------------------------------------------------------------------------------

		.TEXT
ClearMemorySpace:
				movem.l		d0-a1,-(sp)
				movem.l		CLEAR_SPACE,d1-d7/a1
				bra.s		entry

*---------------

ClearMemory:	movem.l		d0-a1,-(sp)
				movem.w		CLEAR_ZERO,d1-d7/a1
entry:			adda.l		d0,a0
				lsr.l		#1,d0
				bcc.s		.CLEAR_W
				move.b		d1,-(a0)
.CLEAR_W:		lsr.l		#1,d0
				bcc.s		.CLEAR_L
				move.w		d1,-(a0)
.CLEAR_L:		lsr.l		#1,d0
				bcc.s		.CLEAR_2L
				move.l		d1,-(a0)
.CLEAR_2L:		lsr.l		#1,d0
				bcc.s		.CLEAR_4L
				move.l		d1,-(a0)
				move.l		d1,-(a0)
.CLEAR_4L:		lsr.l		#1,d0
				bcc.s		.CLEAR_8L
				move.l		d1,-(a0)
				move.l		d1,-(a0)
				move.l		d1,-(a0)
				move.l		d1,-(a0)
.CLEAR_8L:		lsr.l		#1,d0
				bcc.s		.CLEAR_16L
				movem.l		d1-d7/a1,-(a0)
				bra.s		.CLEAR_16L
.CLEAR:			movem.l		d1-d7/a1,-(a0)
				movem.l		d1-d7/a1,-(a0)
.CLEAR_16L:		dbra		d0,.CLEAR
				subi.l		#$10000,d0
				bpl.s		.CLEAR
				movem.l		(sp)+,d0-a1
				rts
