

		text


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet den inhalt der drehbaren karte
; a0 = screenadresse (linke obere ecke der karte)
; clippingdata
drawMapContentRevolving

		bsr.s	dmcrWalls
		bsr	dmcrMonsters
		bsr.s	dmcrPlayer
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet die spielfigur.
; parameter siehe drawmaprevolving.
dmcrPlayer
		move.l	a0,-(sp)
		lea	drawFigureData,a4
		movea.l	playerDataPtr,a1
		move.l	PDSX(a1),DRAWFIGUREX(a4)
		move.l	PDSY(a1),DRAWFIGUREY(a4)
		move.w	#$40*2,DRAWFIGUREANGLE(a4)
		move.w	#$ffff,DRAWFIGURECOLOR(a4)
		move.w	#FIGURELENGTHSTANDARD,DRAWFIGURELENGTH(a4)
		bsr	drawFigure
		movea.l	(sp)+,a0

		rts


; ---------------------------------------------------------
; 17.06.00/vk
; parameter siehe drawmapcontentrevolving.
dmcrWalls
		tst.w	playerThings+PTHGBYTES*TREVOLVINGPLAN+PTHGFLAG
		beq.s	dmcrwOut
		tst.w	playerThings+PTHGBYTES*TREVOLVINGPLAN+PTHGACTFLAG
		bne.s	dmcrwMapPresent
		bsr	dmDrawMapActivationText
		bra.s	dmcrwOut

dmcrwMapPresent
		lea	c3pLines,a1
		move.w	c3pNbLines,d6
		bsr	dmcrC3pLines

		lea	c3pLinesDoors,a1
		move.w	c3pNbDoors,d6
		lsl.w	#2,d6
		bsr	dmcrC3pLines

		lea	c3pLinesThings,a1
		move.w	c3pNbThings,d6
		bsr	dmcrC3pLines

		lea	c3pLinesSwitches,a1
		move.w	c3pNbSwitches,d6
		bsr	dmcrC3pLines
dmcrwOut
		rts


; ---------------------------------------------------------
; 11.08.00/vk
; parameter siehe drawmapcontentrevolving.
; dmcrC3pLines muss gelaufen sein (berechnete arraywerte werden benoetigt)
dmcrMonsters
		tst.w	playerThings+PTHGBYTES*TMONDETECTOR+PTHGFLAG
		beq	dmcrmOut
		tst.w	playerThings+PTHGBYTES*TMONDETECTOR+PTHGACTFLAG
		bne.s	dmcrmMDetectorPresent
		bsr	dmDrawMDetectorActivationText
		bra	dmcrmOut

dmcrmMDetectorPresent

		move.w	monBufferNb,d7				; anzahl aktuell berechneter gegner holen
		bmi	dmcrmOut				; wenn negativ -> raus, keine gegner vorhanden

		movea.l	monBufferPtr,a1				; array der pointer auf gegner holen
		lea	c3pCalcPtsMonsters,a3			; (rotierte) koordinaten der gegner
		lea	drawFigureData,a4			; struktur zur aufnahme des zu zeichnenden gegners
		lea	dmcrc3plTemp,a5				; hier liegen die von dmcrc3plines berechneten zwischenwerte

		movea.l	playerDataPtr,a6
		move.w	PDMAPZOOM(a6),d6			; anzuwendender zoomfaktor

		move.w	PDALPHA(a6),d4				; winkeloffset (addition) berechnen
		addi.w	#$40*2+$80*2,d4

		move.l	#FIGURELENGTHSTANDARD,d0		; groesse der spielfigur entsprechend zoomfaktor
		divs.w	d6,d0
		move.w	d0,DRAWFIGURELENGTH(a4)

dmcrmLoop
		movea.l	(a1)+,a2				; naechsten gegner nach a2

		move.l	(a3)+,d1				; (rotiertes) koordinatenpaar holen
		move.l	(a3)+,d0
		neg.l	d0					; anpassen auf screen-koordinatensystem
		neg.l	d1
		divs.w	d6,d0
		divs.w	d6,d1
		add.w	(a5),d0					; mittelpunkt addieren
		add.w	2(a5),d1
		ext.l	d0
		ext.l	d1
		move.l	d0,DRAWFIGUREX(a4)			; zu zeichnenden screenkoordinaten abspeichern
		move.l	d1,DRAWFIGUREY(a4)

		move.w	#$100,d0
		moveq	#0,d1
		move.b	MONLINE+12+3(a2),d1
		sub.w	d1,d0
		add.w	d0,d0
		add.w	d4,d0
		move.w	d0,DRAWFIGUREANGLE(a4)

		move.w	#$07ff,DRAWFIGURECOLOR(a4)

		movem.l	d4-d7/a0-a1/a3-a5,-(sp)
		bsr	drawFigurePixelWithClipping
		movem.l	(sp)+,d4-d7/a0-a1/a3-a5

		dbra	d7,dmcrmLoop

dmcrmOut
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet die linien der c3p-struktur
; parameter siehe drawmapcontentrevolving.
; d6 = anzahl
; a1 = c3plines o. ae.
dmcrC3pLines
		tst.w	d6
		beq	dmcrc3pOut
		subq.w	#1,d6

		lea	dmcrc3plTemp,a4
		lea	clippingData,a5
		move.w	CLIPPINGMAXX(a5),d0
		move.w	CLIPPINGMAXY(a5),d1
		lsr.w	#1,d0
		lsr.w	#1,d1
		move.w	d0,(a4)
		move.w	d1,2(a4)

		lea	c3pCalcPts,a2
		lea	mapColors,a5

		moveq	#0,d4
		move.w	lineoffset,d4
		movea.l	playerDataPtr,a3
		move.w	PDMAPZOOM(a3),d5	; zoomfaktor

dmcrc3pLoop
		movem.l	d4-d6/a0-a2/a4-a5,-(sp)

		move.w	2(a1),d0
		move.w	6(a1),d2
		movem.l	(a2,d0.w),d0-d1		; x1/y1
		movem.l	(a2,d2.w),d2-d3		; x2/y2

		exg.l	d0,d1
		exg.l	d2,d3
		neg.l	d0
		neg.l	d1
		neg.l	d2
		neg.l	d3
		divs	d5,d0
		divs	d5,d1
		divs	d5,d2
		divs	d5,d3
		add.w	(a4),d0
		add.w	(a4),d2
		add.w	2(a4),d1
		add.w	2(a4),d3

		move.b	14(a1),d7		; bits 15..8 von line_flag_2
		andi.w	#%00001100,d7
		move.l	(a5,d7.w),d7		; farbe holen

		bsr	lineWithClipping

		movem.l	(sp)+,d4-d6/a0-a2/a4-a5
		lea	20(a1),a1
		dbra	d6,dmcrc3pLoop

dmcrc3pOut
		rts




		data




		bss


dmcrc3plTemp	ds.w	2