
; groessenangaben fuer 320x240
EXTRAWIDTH	equ	64			; breite der extrakarte (nur 16er-Schritte)
EXTRAHEIGHT	equ	40			; hoehe
EXTRAPOSDELTAX	equ	12			; abstand zum rand
EXTRAPOSDELTAY	equ	12			; abstand zum rand

EXTRABACKCOLOR	equ	%0110000100000100	; hintergrundfarbwert



		text


; ---------------------------------------------------------
; 17.06.00/vk
; karte in extra fenster anzeigen
drawExtraMap
		bsr	drawExtraMapBorder
		bsr	drawExtraMapClearBackground

	; karte/linien zeichnen

		lea	clippingData,a1
		moveq	#0,d7				; lsl-bitanzahl fuer 320 festsetzen (also nicht verdoppeln)
		cmpi.w	#320,width
		beq.s	deomOk
		moveq	#1,d7				; fuer nicht 320-modi festsetzen (also verdoppeln)
deomOk
		move.w	#EXTRAWIDTH,d0
		lsl.w	d7,d0
		move.w	d0,d2
		subq.w	#1,d0
		move.w	d0,CLIPPINGMAXX(a1)
		move.w	#EXTRAHEIGHT,d1
		lsl.w	d7,d1
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
		move.w	#EXTRAPOSDELTAY+EXTRAHEIGHT,d1
		lsl.w	d7,d1
		move.w	height,d0
		sub.w	d1,d0
		mulu	lineoffset,d0
		move.w	#EXTRAPOSDELTAX,d1
		lsl.w	d7,d1
		add.w	d1,d1
		adda.l	d0,a0
		adda.w	d1,a0
		move.l	a0,screenExtra

		bsr	drawMapContent			; a0/clippingdata/mapdata

		rts


; ---------------------------------------------------------
; 17.06.00/vk
; zeichnet einen rahmen um das extra kartenfenster
drawExtraMapBorder

		moveq	#0,d0
		cmpi.w	#320,width
		beq.s	dembNoSmall
		moveq	#1,d0
dembNoSmall
		move.w	#EXTRAWIDTH,d4
		move.w	#EXTRAHEIGHT,d5
		move.w	#EXTRAPOSDELTAX,d6
		move.w	#EXTRAPOSDELTAY,d7

		lsl.w	d0,d4
		lsl.w	d0,d5
		lsl.w	d0,d6
		lsl.w	d0,d7

		movea.l	screen_1,a0
		lea	border3dExtraMap,a1
		move.w	d6,d0
		move.w	height,d1
		sub.w	d7,d1
		sub.w	d5,d1
		move.w	d4,d2
		move.w	d5,d3
		bsr	draw3dBorder

		rts


; ---------------------------------------------------------
; 17.06.00/vk
; hintergrund der extra-karte neu zeichnen.
; benutzt video hardware routine.
drawExtraMapClearBackground

		moveq	#0,d0
		cmpi.w	#320,width
		beq.s	demcbNoSmall
		moveq	#1,d0
demcbNoSmall
		moveq	#EXTRAWIDTH,d3
		moveq	#EXTRAHEIGHT,d4
		moveq	#EXTRAPOSDELTAX,d1
		moveq	#EXTRAPOSDELTAY,d7

		lsl.w	d0,d1				; d1 = x1
		lsl.w	d0,d3
		lsl.w	d0,d4
		lsl.w	d0,d7

		movea.l	screenData1Ptr,a0

		move.w	height,d2
		sub.w	d4,d2
		sub.w	d7,d2
		add.w	SCREENDATAYOFFSET(a0),d2	; d2 = y1

		add.w	d1,d3
		add.w	d2,d4
		subq.w	#1,d3				; d3 = x2
		subq.w	#1,d4				; d4 = y2

		move.w	#EXTRABACKCOLOR,d0
		bsr	mvdiSolidrect

		rts





		data





		bss


screenExtra	ds.l	1
