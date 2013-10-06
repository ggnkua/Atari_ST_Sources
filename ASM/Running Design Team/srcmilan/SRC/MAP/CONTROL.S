
MAPMAIN			equ	0		; fuer neue modi muss ggf. drawBackgroundIfRequired() in .\gfxrouts\backgrnd.s angepasst werden
MAPOVERLAY		equ	1
MAPEXTRAOVERLAY		equ	2

FIGURELENGTHSTANDARD	equ	20*16		; laenge der spielfiguren im standardfall

MAPZOOMMIN		equ	4
MAPZOOMMAX		equ	4096


; mapdata
			rsreset
MAPDATAMX		rs.l	1
MAPDATAMY		rs.l	1
MAPDATAWIDTH		rs.w	1
MAPDATAHEIGHT		rs.w	1
MAPDATAWIDTHHALF	rs.w	1
MAPDATAHEIGHTHALF	rs.w	1
MAPDATABYTES		rs.w	1



		text


; ---------------------------------------------------------
; kartenmodus ein- oder ausschalten
mapOnOff
		clr.b	(a1,d0.w)			; tastendruck loeschen

		lea	mapFlag,a0
		tst.w	(a0)
		bne.s	mooTurnOff

mooTurnOn	move.w	#1,(a0)				; kartenmodus einschalten
		bra	mooOut

mooTurnOff	clr.w	(a0)				; kartenmodus ausschalten
		bsr	clearCurrentMapBackground
mooOut
		rts


; ---------------------------------------------------------
; zwischen verschiedenen kartenmodi umschalten
mapSwitch
		clr.b	(a1,d0.w)			; tastendruck loeschen

		lea	mapFlag,a0
		tst.w	(a0)				; kartenmodus ueberhaupt aktiv?
		beq.s	msOut				; nein -> raus

		bsr.s	clearCurrentMapBackground

		lea	maps,a2
		lea	mapMode,a1
		move.w	(a1),d0				; aktueller map-modus-index
		addq.w	#1,d0				; index um eins erhoehen
		tst.w	(a2,d0.w*2)			; aktueller map-modus
		bpl.s	msNoListEnd
		moveq	#0,d0
msNoListEnd	move.w	d0,(a1)				; neuen map-modus-index eintragen

msOut
		rts


; ---------------------------------------------------------
; 23.07.00/vk
; zwischen den verschiedenen inhalten (standard/revolving)
; umschalten.
; wird von keyhit() aufgerufen.
mapContentSwitch
		clr.b	(a1,d0.w)			; tastendruck loeschen

		tst.w	mapFlag				; karte ueberhaupt aktiv?
		beq.s	mcsOut				; nein -> dann auch nichts aendern

		lea	mapContent,a0
		move.w	(a0),d0
		beq.s	mcsIsStandard
		moveq	#0,d0
		bra.s	mcsOk
mcsIsStandard	moveq	#1,d0
mcsOk		move.w	d0,(a0)

mcsOut
		rts





		data


		dc.w	-1
maps		dc.w	MAPMAIN
		dc.w	MAPOVERLAY
		dc.w	MAPEXTRAOVERLAY
		dc.w	-1

mapContent	dc.w	0

; routinen zur anzeige der karten
mapRouts	dc.l	drawStandardMap
		dc.l	drawOverlayMap
		dc.l	drawExtraMap

; routinen zum loeschen des hintergrunds nach deaktivierung der karten
mapClearRouts	dc.l	setFlagToClearBackground
		dc.l	setFlagToClearBackground
		dc.l	setFlagToClearBackground

; farben fuer kartenmodus
mapColors	dc.w	0,%1011010110010110
		dc.w	0,%1110011100011100
		dc.w	0,%1010010100010100
		dc.w	0,%1100011000011000


		bss


; allgemein
mapData		ds.b	MAPDATABYTES


