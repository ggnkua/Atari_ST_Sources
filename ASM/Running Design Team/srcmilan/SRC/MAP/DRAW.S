
; drawfigure
			rsreset
DRAWFIGUREX		rs.l	1
DRAWFIGUREY		rs.l	1
DRAWFIGUREANGLE		rs.w	1
DRAWFIGURECOLOR		rs.w	1
DRAWFIGURELENGTH	rs.w	1
DRAWFIGUREBYTES		rs.w	1



		text


; ---------------------------------------------------------
; 17.06.00/vk
; wenn eingeschaltet, die richtige karte anzeigen
drawMap
		tst.w	mapFlag
		beq.s	dmOut

		move.w	mapMode,d0			; map-modus-index
		lea	maps,a0
		move.w	(a0,d0.w*2),d0			; map-modus

		lea	mapRouts,a0
		move.l	(a0,d0.w*4),d0
		beq.s	dmOut

		movea.l	d0,a0
		jsr	(a0)
dmOut
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet den kompletten inhalt (content) einer map.
; a0 = zeiger auf linke obere ecke der map (screen)
; clippingdata
; mapdata
drawMapContent

		move.w	mapContent,d0
		lea	drawMapContentRoutines,a1
		movea.l	(a1,d0.w*4),a1
		jsr	(a1)
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; loescht den hintergrund der aktuellen karte
clearCurrentMapBackground
		lea	maps,a0
		move.w	mapMode,d0			; aktuellen map-modus-index holen
		move.w	(a0,d0.w*2),d0			; (absoluter) map-modus
		lea	mapClearRouts,a0		; routinen zum loeschen des hintergrunds
		move.l	(a0,d0.w*4),d0			; routine holen
		beq.s	ccmbOut				; gueltig?
		movea.l	d0,a0
		jsr	(a0)				; aufrufen
ccmbOut
		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet eine spielfigur
; a0 = screen
; drawfiguredata
; clippingdata
; mapdata
drawFigure
		lea	mapData,a3
		lea	drawFigureBuffer,a4	; hier werden die drei koordinaten zwischengespeichert
		lea	sinus512TabX,a5		; 16-byte-grenzen
		lea	drawFigureData,a6
		move.l	DRAWFIGUREX(a6),d6	; sx
		move.l	DRAWFIGUREY(a6),d7	; sy

		fmove.w	DRAWFIGURELENGTH(a6),fp2

		move.w	#$100*2,d0
		sub.w	DRAWFIGUREANGLE(a6),d0
		bsr	dfCalcPoint
		addi.w	#$68*2,d0
		bsr	dfCalcPoint
		addi.w	#$30*2,d0
		bsr	dfCalcPoint

		lea	drawFigureBuffer,a4
		move.w	(a4),12(a4)
		move.w	2(a4),14(a4)

		moveq	#2,d5
		moveq	#0,d4
		move.w	lineoffset,d4		; bleibt konstant
		move.w	DRAWFIGURECOLOR(a6),d7	; farbwert (bleibt konstant)
dfLoop
		move.w	(a4)+,d0
		move.w	MAPDATAHEIGHT(a3),d1
		move.w	d1,d3
		sub.w	(a4)+,d1
		move.w	(a4),d2
		sub.w	2(a4),d3
		movem.l	d4-d5/d7/a0/a3-a4,-(sp)
		bsr	lineWithClipping
		movem.l	(sp)+,d4-d5/d7/a0/a3-a4

		dbra	d5,dfLoop

		rts


; ---------------------------------------------------------
; 17.06.00/vk
; berechnen eine koordinate einer zu zeichnenden spielfigur
; d0 = alpha
; d6 = sx
; d7 = sy
; fp2 = FIGURELENGTH
; a0 = screen
; a3 = mapData
; a4 = drawFigureBuffer
; a5 = sinus512TabX
dfCalcPoint
		move.w	#$200,d1		; vollwinkel
		sub.w	d0,d1
		andi.w	#$1ff,d1

		lsl.w	#4,d1			; sinus/cosinus an 16-byte-grenzen
		fmove.x	(a5,d1.w),fp5		; sinus
		addi.w	#$40*2*16,d1
		andi.w	#$1fff,d1
		fmove.x	(a5,d1.w),fp4		; cosinus

		fmul.x	fp2,fp4
		fmul.x	fp2,fp5
		fmove.l	fp4,d4
		fmove.l	fp5,d5
		add.l	d6,d4
		add.l	d7,d5
		sub.l	MAPDATAMX(a3),d4
		sub.l	MAPDATAMY(a3),d5
		movea.l	playerDataPtr,a2
		move.w	PDMAPZOOM(a2),d2
		divs	d2,d4
		divs	d2,d5
		add.w	MAPDATAWIDTHHALF(a3),d4
		add.w	MAPDATAHEIGHTHALF(a3),d5

		move.w	d4,(a4)+
		move.w	d5,(a4)+

		rts



		data

drawMapContentRoutines
		dc.l	drawMapContentStandard
		dc.l	drawMapContentRevolving



		bss


; drawFigure
drawFigureData		ds.b	DRAWFIGUREBYTES
drawFigureBuffer	ds.w	4*2