

		text


; ---------------------------------------------------------
; 17.06.00/vk
; (drehbare) karte im 3d-fenster anzeigen
drawOverlayMap
		lea	clippingData,a1
		lea	c3p,a5
		move.w	C3PWIDTH(a5),d0
		move.w	doubleScan,d1
		lsl.w	d1,d0				; bei doubleScan die breite verdoppeln
		move.w	d0,d2
		subq.w	#1,d0
		move.w	d0,CLIPPINGMAXX(a1)
		move.w	C3PHEIGHT(a5),d1
		move.w	d1,d3
		subq.w	#1,d1
		move.w	d1,CLIPPINGMAXY(a1)

		lea	mapData,a1
		movea.l	playerDataPtr,a2
		move.l	PDSX(a2),MAPDATAMX(a1)		; kartenmittelpunkt ist spielerposition
		move.l	PDSY(a2),MAPDATAMY(a1)
		move.w	d2,MAPDATAWIDTH(a1)
		move.w	d3,MAPDATAHEIGHT(a1)
		lsr.w	#1,d2
		lsr.w	#1,d3
		move.w	d2,MAPDATAWIDTHHALF(a1)
		move.w	d3,MAPDATAHEIGHTHALF(a1)

		movea.l	screen3d,a0
		bsr	drawMapContent

		rts



		data



		bss

