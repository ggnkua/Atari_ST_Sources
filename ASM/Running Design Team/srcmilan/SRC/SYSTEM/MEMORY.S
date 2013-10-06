

		text


; ---------------------------------------------------------
; speicherbereich allokieren
; d0.w = typ (0 = st-ram, 1 = tt-ram)
; d1.l = groesse
; rueckgabe: d0 = speicheradresse (oder nullzeiger)
;            a0 = speicheradresse (oder nullzeiger)
allocateMemory

		move.w	d0,almTempMode

	; protokollierung

		movem.l	d0-d1,-(sp)
		bsr	binToHex
		move.l	4(a0),ltMemoryTryToGetM2
		movem.l	(sp),d0-d1
		move.l	d1,d0
		bsr	binToHex
		lea	ltMemoryTryToGetM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltMemoryTryToGet,a0
		bsr	logString
		movem.l	(sp)+,d0-d1

	; speicheranforderung mittels betriebssystem

		move.w	d0,-(sp)			; mode
		move.l	d1,-(sp)			; amount
		move.w	#68,-(sp)
		trap	#1
		addq.l	#8,sp

		move.l	d0,-(sp)
		bne.s	almAllocateOk

	; nullpointer wurde zurueckgegeben
	; groessten freien speicherblock ermitteln und protokollieren

		move.w	almTempMode,-(sp)
		move.l	#-1,-(sp)
		move.w	#68,-(sp)
		trap	#1
		addq.l	#8,sp

		bsr	binToHex
		lea	ltMemoryErrorLBlockM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltMemoryErrorLBlock,a0
		bsr	logString
		bra.s	almOut

almAllocateOk

	; speicheranforderung erfolgreich

		bsr	binToHex
		lea	ltMemorySuccessfullM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltMemorySuccessfull,a0
		bsr	logString
		
almOut
		move.l	(sp)+,d0
		movea.l	d0,a0

		rts


; ---------------------------------------------------------
; laedt eine datei in einen zu allokierenden
; st-ram-speicherblock
; a0 = datei
; rueckgabe: d0 = speicherblock (oder nullpointer)
;            d1 = laenge des speicherblocks
;            a0 = speicherblock (oder nullpointer)
allocateMemoryAndLoadFile

		move.l	a0,-(sp)
		bsr	getFileSize		; dateigroesse bestimmen
		move.l	(sp)+,a0

		move.l	d0,-(sp)		; fehler datei aufgetreten -> mit fehler weitermachen
		bmi.s	amalfError

		move.l	d0,d1			; groesse
		clr.w	d0			; typ
		bsr	allocateMemory

		movem.l	d0-a6,-(sp)
		bsr	binToHexPrintLine
		movem.l	(sp)+,d0-a6
		
		tst.l	d0
		bne.s	amalfOut

amalfError
		clr.l	d0
		movea.l	d0,a0

amalfOut
		move.l	(sp)+,d1

		rts


; ---------------------------------------------------------
; 06.01.00/vk
; speicherblock wieder freigeben
; a0 = adresse speicherblock
; rueckgabe: d0 = 0 (erfolgreich), -1 (fehler aufgetreten)
freeMemory

	; protokollierung

		move.l	a0,-(sp)
		move.l	a0,d0
		bsr	binToHex
		lea	ltMemoryTryToFreeM,a1
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		lea	ltMemoryTryToFree,a0
		bsr	logString
		movea.l	(sp)+,a0

	; betriebssystemfunktion aufrufen

		move.l	a0,-(sp)
		move.w	#73,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.w	d0
		beq.s	fmOk

	; protokollierung

		bsr	binToHex
		lea	ltMemoryFreeErrorM,a1
		move.l	(a0),(a1)
		lea	ltMemoryFreeError,a0
		bsr	logString
		moveq	#-1,d0
		bra.s	fmOut

fmOk
		lea	ltMemoryFreeSuccess,a0
		bsr	logString
		moveq	#0,d0
fmOut
		rts




		data




		bss


almTempMode	ds.w	1


