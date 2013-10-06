

		text


; ---------------------------------------------------------
; 17.06.00/vk
; standardkarte anzeigen
drawStandardMap

		lea	clippingData,a1

		move.w	width,d0
		move.w	d0,d2
		subq.w	#1,d0
		move.w	d0,CLIPPINGMAXX(a1)
		move.w	height,d1
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

		movea.l	screen_1,a0
		bsr	drawMapContent			; a0/clippingdata/mapdata

		rts




		data


		bss

