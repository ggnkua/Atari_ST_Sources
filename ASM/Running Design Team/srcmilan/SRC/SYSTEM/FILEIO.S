
		rsreset
FILENAME	rs.l	1
FILEBUFFER	rs.l	1
FILEBYTES	rs.l	1
FILEIOBYTES	rs.w	1



		text

; todo: Errorcodes (stopSystem)

; ---------------------------------------------------------
; 29.07.00/vk
; laedt eine datei in den angegebenen speicherbereich.
; fileio = einzuladende datei
; rueckgabe: d6 = tatsaechlich geladene bytes (0, falls fehlerhaft)
;            a6 = fileio
; rettet alle register
loadFile
		movem.l	d0-d5/d7/a0-a5,-(sp)

		lea	fileIO,a6

		clr.w	-(sp)
		move.l	FILENAME(a6),-(sp)
		move.w	#61,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.w	d0
		bpl.s	lfNoOpenError
		bsr	fileOpenError
		bra.s	lfErrorReturn
lfNoOpenError	move.w	d0,d4

		move.l	FILEBUFFER(a6),-(sp)		; buffer
		move.l	FILEBYTES(a6),-(sp)		; bytes
		move.w	d4,-(sp)			; handle
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.l	d0,d6
		bpl.s	lfNoReadError
		bsr	fileReadError
		bra.s	lfErrorReturn
lfNoReadError
		move.w	d4,-(sp)			; handle
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.w	d0
		bpl.s	lfNoCloseError
		bsr	fileCloseError
lfErrorReturn	moveq	#0,d6
lfNoCloseError
		movem.l	(sp)+,d0-d5/d7/a0-a5
		rts


; ---------------------------------------------------------
; datei speichern
; ---------------------------------------------------------
saveFile
		lea	fileIO,a6

		clr.w	-(sp)
		move.l	FILENAME(a6),-(sp)
		move.w	#60,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.w	d0
		bmi.s	fileCreateError
		move.w	d0,d7

		move.l	FILEBUFFER(a6),-(sp)
		move.l	FILEBYTES(a6),-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		tst.l	d0
		bmi	fileWriteError

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.w	d0
		bmi	fileCloseError
		
		rts


; ---------------------------------------------------------
; gibt die dateigroesse zurueck
; a0 = filename
; rueckgabe: d0 = groesse in bytes (neg. bei fehler)
getFileSize

	; datei oeffnen

		clr.w	-(sp)				; nur lesbar oeffnen
		move.l	a0,-(sp)
		move.w	#61,-(sp)			; _fopen()
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7				; handle
		bmi.s	gfsError

	; leseposition auf dateiende
	; ziel: rueckgabewert ist die laenge der datei

		move.w	#2,-(sp)			; seekmode (vom dateiende)
		move.w	d7,-(sp)
		clr.l	-(sp)
		move.w	#66,-(sp)			; _fseek()
		trap	#1
		lea	10(sp),sp
		move.l	d0,d6				; groesse nach d6

	; datei wieder schliessen

		move.w	d7,-(sp)
		move.w	#62,-(sp)			; _fclose()
		trap	#1
		addq.l	#4,sp

		move.l	d6,d0
		bra.s	gfsOut

gfsError
		moveq	#-1,d0

gfsOut
		rts




fileOpenError	lea	stopSystemData,a0
		move.w	#SSFILEOPENERROR,SSCODE(a0)
		move.l	FILENAME(a6),SSMESSAGE(a0)
		bsr	stopSystem
		rts

fileCreateError	lea	stopSystemData,a0
		move.w	#SSFILECREATEERROR,SSCODE(a0)
		move.l	FILENAME(a6),SSMESSAGE(a0)
		bsr	stopSystem
		rts

fileReadError	lea	stopSystemData,a0
		move.w	#SSFILEREADERROR,SSCODE(a0)
		move.l	FILENAME(a6),SSMESSAGE(a0)
		bsr	stopSystem
		rts

fileWriteError	lea	stopSystemData,a0
		move.w	#SSFILEWRITEERROR,SSCODE(a0)
		move.l	FILENAME(a6),SSMESSAGE(a0)
		bsr	stopSystem
		rts

fileCloseError	lea	stopSystemData,a0
		move.w	#SSFILECLOSEERROR,SSCODE(a0)
		move.l	FILENAME(a6),SSMESSAGE(a0)
		bsr	stopSystem
		rts




		bss


fileIO		ds.b	FILEIOBYTES
