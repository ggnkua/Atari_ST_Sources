*-------------------------------------------------------------------------------
* MALLOC/MXALLOC: Reserviert und l”scht Speicher, MXALLOC reserviert _nur_ aus
*				  dem ST-Ram.
* ---> Malloc(L„nge)
* <--- D0.l = Speicheradresse oder Fehler=0
* <--- flag.eq = Fehler, flag.ne = alles io
*
* MFREE: Gibt Speicher frei.
* ---> Mfree(Adresse)
*
* MSHRINK: Verkleinert Speicher.
* ---> Mshrink(Adresse, L„nge)
*-------------------------------------------------------------------------------

		.EXPORT		MALLOC,MXALLOC,MFREE,MSHRINK
		.EXPORT		ACT_PD_ZEIGER,MXALLOC_FLAG

*-------------------------------------------------------------------------------

		.BSS
ACT_PD_ZEIGER:		ds.l	1
LOCAL_FLAG:			ds.b	1
MXALLOC_FLAG:		ds.b	1
		.EVEN

*-------------------------------------------------------------------------------

		.TEXT
MXALLOC:		st			LOCAL_FLAG
				bra.s		entry

*---------------

MALLOC:			sf			LOCAL_FLAG
entry:			movem.l		d1-a6,-(sp)

				jsr			TestMiNT
				beq.s		.MintInstalled
				movea.l		ACT_PD_ZEIGER,a6
				move.l		(a6),a5
				move.l		ProgrammStart,(a6)

.MintInstalled:	move.l		60(sp),d7
				bpl.s		MALLOC_IO
				cmp.l		#-1,d7
				bne.s		MALLOC_FEHLER

MALLOC_IO:		tst.b		LOCAL_FLAG
				beq.s		NO_MXALLOC
				tst.b		MXALLOC_FLAG
				beq.s		NO_MXALLOC
				clr.w		-(sp)
				move.l		d7,-(sp)
				move.w		#68,-(sp)
				trap		#1
				addq.w		#8,sp
				bra.s		CONT_MXALLOC
NO_MXALLOC:		move.l		d7,-(sp)
				move.w		#72,-(sp)
				trap		#1
				addq.w		#6,sp
CONT_MXALLOC:	tst.l		d0
				ble.s		MALLOC_FEHLER	; 0=kein Speicher, <0=sonstiger Gemdoserror

				tst.l		d7
				bmi.s		DONT_CLR_MEMORY

				movea.l		d0,a0
				move.l		d7,d0
				jsr			ClearMemory
				move.l		a0,d0

DONT_CLR_MEMORY:st			LOCAL_FLAG
				bra.s		MallocEnde

MALLOC_FEHLER:	sf			LOCAL_FLAG
MallocEnde:		jsr			TestMiNT
				beq.s		.MintInstalled
				move.l		a5,(a6)
.MintInstalled:	movem.l		(sp)+,d1-a6
				move.l		(sp)+,(sp)
				tst.b		LOCAL_FLAG
				rts

*-------------------------------------------------------------------------------

MFREE:			tst.l		4(sp)			; Blockadresse=0?
				beq.s		WRONG_BLOCK
				movem.l		d0-a6,-(sp)
				jsr			TestMiNT
				beq.s		.MintInstalled1
				movea.l		ACT_PD_ZEIGER,a6
				move.l		(a6),a5
				move.l		ProgrammStart,(a6)
.MintInstalled1:move.l		64(sp),-(sp)
				move.w		#73,-(sp)
				trap		#1
				addq.w		#6,sp
				jsr			TestMiNT
				beq.s		.MintInstalled2
				move.l		a5,(a6)
.MintInstalled2:movem.l		(sp)+,d0-a6
WRONG_BLOCK:	move.l		(sp)+,(sp)
				rts

*-------------------------------------------------------------------------------

MSHRINK:		movem.l		d0-a6,-(sp)
				jsr			TestMiNT
				beq.s		.MintInstalled1
				movea.l		ACT_PD_ZEIGER,a6
				move.l		(a6),a5
				move.l		ProgrammStart,(a6)
.MintInstalled1:move.l		68(sp),-(sp)
				move.l		68(sp),-(sp)
				clr.w		-(sp)
				move.w		#74,-(sp)
				trap		#1
				lea			12(sp),sp
				jsr			TestMiNT
				beq.s		.MintInstalled2
				move.l		a5,(a6)
.MintInstalled2:movem.l		(sp)+,d0-a6
				move.l		(sp)+,(sp)
				move.l		(sp)+,(sp)
				rts
