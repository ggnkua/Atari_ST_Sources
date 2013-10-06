

CALTTABSHOWTIME		equ	1000			; solange verbleibt die anzeige auf dem bildschirm (in msek.)
CALTTABNB		equ	7			; anzahl angezeigter gegenstaende (muss ungerade sein)
CALTTABCELLSPACING	equ	10
CALTTABDX		equ	CONSOLEITEMSWIDTH
CALTTABDY		equ	CONSOLEITEMSSINGLEHEIGHT
CALTTABWIDTH		equ	CALTTABDX*CALTTABNB+CALTTABCELLSPACING*(CALTTABNB-1)
CALTTABHEIGHT		equ	CALTTABDY
CALTTABLINEOFFSET	equ	CALTTABWIDTH*2
CALTTABBITMAPBYTES	equ	CALTTABLINEOFFSET*CALTTABHEIGHT

			rsreset
ALTTABFLAG		rs.w	1
ALTTABCOUNTER		rs.w	1
ALTTABBITMAP		rs.l	1
ALTTABMIDOFFSET		rs.w	1			; offset innerhalb der grafik zum mittleren icon
ALTTABNBLEFTORRIGHT	rs.w	1
ALTTABBYTES		rs.w	1



		text


; ---------------------------------------------------------
; 13.08.00/vk
; zeichnet - falls notwendig - die alttab-einblendung.
drawAltTabIfRequired

		lea	altTab,a0
		tst.w	ALTTABFLAG(a0)
		beq.s	datirOut

		move.w	ALTTABCOUNTER(a0),d0
		sub.w	vblTime1000,d0
		bmi.s	datirHide

		move.w	d0,ALTTABCOUNTER(a0)

		bsr.s	drawAltTab
		bra.s	datirOut

datirHide
		bsr	hideAltTab

datirOut
		rts


; ---------------------------------------------------------
; 13.08.00/vk
; erzeugt und zeichnet die alttab-einblendung.
drawAltTab
		lea	altTab,a0

		bsr.s	datCreateBitmap
		bsr	datDrawBitmap

		rts


; ---------------------------------------------------------
; 13.08.00/vk
; erzeugt die alttab-bitmap.
; a0 = alttab
; rettet alle register
datCreateBitmap
		move.l	a0,-(sp)

		movea.l	ALTTABBITMAP(a0),a1
		adda.w	ALTTABMIDOFFSET(a0),a1
		movea.l	playerDataPtr,a2

		move.w	ALTTABNBLEFTORRIGHT(a0),d7
		move.w	PDCURRENTITEM(a2),d0
		moveq	#1,d1
datcbLeftLoop	bsr.s	datcbSingleItem
		adda.w	#2*(CALTTABDX+CALTTABCELLSPACING),a1
		dbra	d7,datcbLeftLoop

		movea.l	ALTTABBITMAP(a0),a1
		adda.w	ALTTABMIDOFFSET(a0),a1
		suba.w	#2*(CALTTABDX+CALTTABCELLSPACING),a1

		move.w	ALTTABNBLEFTORRIGHT(a0),d7
		subq.w	#1,d7
		move.w	PDCURRENTITEM(a2),d0
		subq.w	#1,d0
		moveq	#-1,d1
datcbRightLoop	bsr.s	datcbSingleItem
		suba.w	#2*(CALTTABDX+CALTTABCELLSPACING),a1
		dbra	d7,datcbRightLoop

		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 13.08.00/vk
; erzeugt, ausgehend von einem bestimmten gegenstand und in
; der angegebenen richtung, nach dem naechsten vorhandenen
; gegenstand und zeichnet dieses in die bitmap ein.
; ist kein gegenstand mehr vorhanden, wird entsprechend
; eine schwarze bitmap erzeugt.
; d0 = aktueller, ausgehender gegenstand
; d1 = suchrichtung (+1 oder -1)
; a0 = alttab
; a1 = zielposition innerhalb der alttab-bitmap
; rueckgabe: d0 = aktuell gezeichnetes item + d1 (oder - wenn nichts mehr vorhanden: -1 oder thingsmax)
; rettet alle register
datcbSingleItem
		movem.l	d1-d7/a0-a6,-(sp)

		move.w	d0,d2					; ausgangsgegenstand kopieren

		lea	playerThings,a2
		mulu.w	#PTHGBYTES,d2
		adda.l	d2,a2

		move.w	d1,d2
		muls.w	#PTHGBYTES,d2				; d2 = +pthgbytes oder -pthgbytes

datcbsiLoop
		tst.w	d0					; sind wir noch im gueltigen bereich?
		bmi.s	datcbsiNoMoreItems			; untere grenze: nein -> dann schwarze bitmap
		cmpi.w	#THINGSMAX,d0				; obere grenze erreicht?
		bge.s	datcbsiNoMoreItems			; ja -> dann schwarze bitmap

		tst.w	PTHGFLAG(a2)				; gegenstand vorhanden?
		bne.s	datcbsiFound				; ja -> dann koennen wir zeichnen

		add.w	d1,d0					; andernfalls ab zum naechsten gegenstand
		adda.l	d2,a2

		bra.s	datcbsiLoop

datcbsiNoMoreItems

		move.w	#CALTTABDY-1,d7
datcbsinmiLoop1	move.w	#CALTTABDX-1,d6
		movea.l	a1,a6					; temp. zieladresse erstellen
datcbsinmiLoop2	clr.w	(a6)+
		dbra	d6,datcbsinmiLoop2
		adda.w	#CALTTABLINEOFFSET,a1
		dbra	d7,datcbsinmiLoop1

		bra.s	datcbsiOut

datcbsiFound
		move.w	d0,d2
		lea	things,a2
		movea.l	(a2,d0.w*4),a2
		move.w	THGGFXINDEX(a2),d2
		mulu.w	#CONSOLEITEMSWIDTH*CONSOLEITEMSSINGLEHEIGHT*2,d2
		lea	consoleItems,a2
		adda.l	d2,a2

		move.w	#CALTTABDY-1,d7
datcbsifLoop1	move.w	#CALTTABDX-1,d6
		movea.l	a1,a6					; temp. zieladresse erstellen
datcbsifLoop2	move.w	(a2)+,(a6)+
		dbra	d6,datcbsifLoop2
		adda.w	#CALTTABLINEOFFSET,a1
		dbra	d7,datcbsifLoop1

		add.w	d1,d0
datcbsiOut
		movem.l	(sp)+,d1-d7/a0-a6
		rts


; ---------------------------------------------------------
; 13.08.00/vk
; zeichnet die alttab-einblendung.
; a0 = alttab
; rettet alle register
datDrawBitmap
		move.l	a0,-(sp)

		move.w	width,d6
		subi.w	#CALTTABWIDTH,d6
		lsr.w	#1,d6
		move.w	height,d7
		subi.w	#CALTTABHEIGHT,d7
		lsr.w	#1,d7
		movea.l	screen_1,a0
		lea	bmpCAltTab,a2
		bsr	bitBlt

		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 13.08.00/vk
; aktiviert das alttab-anzeige (fuer die vordefinierte dauer).
; rettet alle register
bringUpAltTab
		move.l	a0,-(sp)
		lea	altTab,a0
		move.w	#1,ALTTABFLAG(a0)
		move.w	#CALTTABSHOWTIME,ALTTABCOUNTER(a0)
		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; 13.08.00/vk
; deaktiviert die alttab-anzeige (falls aktiviert gewesen).
; rettet alle register
hideAltTab
		move.l	a0,-(sp)
		lea	altTab,a0
		clr.w	ALTTABFLAG(a0)
		movea.l	(sp)+,a0
		rts




		data




		bss


altTab		ds.b	ALTTABBYTES

altTabBitmap	ds.b	CALTTABBITMAPBYTES



