
; v2.0
; - benutzt als temporaeren zwischenspeicher den logischen screen
; - speichert (nur noch) 24bit bmp komplett mit header ab


SSBMPHEADERLENGTH	equ	54
SSBMPHEADERXOFFSET	equ	$12
SSBMPHEADERYOFFSET	equ	$16




		text


; ---------------------------------------------------------
; 04.09.2000/vk
; erzeugt einen screenshot.
; benutzt den logischen screen als zwischenspeicher,
; bestimmt dabei automatisch den dateinamen.
; rettet alle register.
makeScreenshot
		movem.l	d0-a6,-(sp)

		lea	ssCounter,a0
		moveq	#0,d0
		move.w	(a0),d0
		addq.w	#1,(a0)
		bsr	binToHex

		lea	ssFilename,a1
		move.l	4(a0),4(a1)				; letzte 4 der insgesamt 8 ziffern benoetigt
		movea.l	a1,a0

		bsr.s	saveScreenToFile			; in: a0

		lea	ssMessage,a0
		bsr	installMessage

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 04.09.2000/vk
; speichert den inhalt des physikalischen screens
; auf die festplatte. verwendet eigene routinen zum
; oeffnen/schreiben/schliessen von dateien.
; a0 = dateiname (nullterminierter string)
; rueckgabe: d7 = 0 (erfolgreich), -1 (allgemeiner fehler)
; rettet alle register.
saveScreenToFile
		movem.l	d0-d6/a0-a6,-(sp)

		clr.w	sstfFileIsOpen				; flag fuer offene datei vorher loeschen

		clr.w	-(sp)					; fileattr. fuer normale datei
		move.l	a0,-(sp)				; filename
		move.w	#60,-(sp)				; _fcreate()
		trap	#1
		addq.l	#8,sp
		tst.w	d0					; _fcreate() fehlgeschlagen?
		bmi	sstfErrorAndOut				; ja -> dann raus
		move.w	d0,d7					; handle nach d7

		lea	ssBmpHeader,a0				; header auf aktuelle bildschirmgroessen anpassen (x)
		moveq	#0,d0
		move.w	width,d0
		move.b	d0,SSBMPHEADERXOFFSET(a0)
		lsl.l	#8,d0
		swap	d0
		move.b	d0,SSBMPHEADERXOFFSET+1(a0)

		moveq	#0,d0					; fuer y
		move.w	height,d0
		move.b	d0,SSBMPHEADERYOFFSET(a0)
		lsl.l	#8,d0
		swap	d0
		move.b	d0,SSBMPHEADERYOFFSET+1(a0)

		move.l	a0,-(sp)				; ...und abspeichern
		move.l	#SSBMPHEADERLENGTH,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)				; _fwrite()
		trap	#1
		lea	12(sp),sp

		movea.l	screen_2,a0				; physikalischer screen (erste bildschirmhaelfte)
		move.w	height,d0
		mulu.w	lineoffset,d0
		adda.l	d0,a0
		bsr.s	sstfSaveBlock

		movea.l	screen_2,a0				; zweite bildschirmhaelfte
		move.w	height,d0
		lsr.w	#1,d0
		mulu.w	lineoffset,d0
		adda.l	d0,a0
		bsr.s	sstfSaveBlock

		bsr	sstfCloseFile

		moveq	#0,d7
		bra.s	sstfOut

sstfErrorAndOut
		tst.w	sstfFileIsOpen
		beq.s	sstfeaoNotOpen
		bsr	sstfCloseFile
sstfeaoNotOpen	moveq	#-1,d7

sstfOut
		move.w	d7,-(sp)
		bsr	copyScreenPhysToLog
		move.w	(sp)+,d7

		movem.l	(sp)+,d0-d6/a0-a6
		rts


; ---------------------------------------------------------
; d7 = handle der bereits geoeffneten datei (unveraendert)
; a0 = block an dieser position bearbeiten
sstfSaveBlock
		move.w	d7,-(sp)

		lea	screen_1,a6
		lea	width,a5
		lea	height,a4

		movea.l	(a6),a1					; screen_1

		move.w	(a5),d0					; width
		move.w	(a4),d1					; height
		lsr.w	#1,d1

		subq.w	#1,d0					; breite fuer dbra
		subq.w	#1,d1					; hoehe fuer dbra

		move.w	lineoffset,d6
sstfsbLoop
		move.w	d0,d2
		suba.w	d6,a0
		movea.l	a0,a2
sstfsbLoop2
		move.w	(a2)+,d3
		move.w	d3,d4
		move.w	d3,d5
		andi.l	#%1111100000000000,d3
		andi.l	#%0000011111100000,d4
		andi.l	#%0000000000011111,d5
		lsl.l	#5,d3
		swap	d3
		lsr.w	#5,d4
		mulu.w	#255,d3
		mulu.w	#255,d4
		mulu.w	#255,d5
		divu.w	#31,d3
		divu.w	#63,d4
		divu.w	#31,d5
		move.b	d5,(a1)+				; reihenfolge: bgr
		move.b	d4,(a1)+
		move.b	d3,(a1)+
		dbra	d2,sstfsbLoop2

		dbra	d1,sstfsbLoop

		move.w	(a4),d0					; height
		lsr.w	#1,d0
		mulu.w	(a5),d0					; width
		move.l	d0,d1
		add.l	d0,d0
		add.l	d1,d0					; blockgroesse in bytes
		
		move.l	(a6),-(sp)				; screen_1 (zu speichernder buffer)
		move.l	d0,-(sp)				; groesse des zwischenspeichers
		move.w	d7,-(sp)
		move.w	#64,-(sp)				; _fwrite()
		trap	#1
		lea	12(sp),sp

		move.w	(sp)+,d7
		rts


; ---------------------------------------------------------
; d7 = handle
sstfCloseFile
		move.w	d7,-(sp)
		move.w	#62,-(sp)				; fclose()
		trap	#1
		addq.l	#4,sp
		rts





		data


sstfFileIsOpen	dc.w	0

ssCounter	dc.w	0

		even
ssFilename	dc.b	"pic00000.bmp",0
		even


ssBmpHeader	incbin	"include\system\header.bmp"


		IFEQ LANGUAGE
ssMessage	dc.b	"SCREEN SAVED TO FILE",0
		ELSE
ssMessage	dc.b	"BILDSCHIRMANZEIGE WURDE GESPEICHERT",0
		ENDC
		even