
; bitmap file: items.rbf
CONSOLEITEMSWIDTH		equ	34
CONSOLEITEMSHEIGHT		equ	1088
CONSOLEITEMSSINGLEHEIGHT	equ	34			; hoehe einer einzelnen ikone



		text


; ---------------------------------------------------------
; 12.07.00/vk
; laedt die grafik zum zeichnen der waffenstandsanzeige
; (ikonen fuer waffentyp).
initConsoleItemsFile

		lea	fileIO,a0
		move.l	#consoleItemsFile,FILENAME(a0)
		move.l	#consoleItems,FILEBUFFER(a0)
		move.l	#CONSOLEITEMSWIDTH*CONSOLEITEMSHEIGHT*2,FILEBYTES(a0)
		bsr	loadFile

		rts


; ---------------------------------------------------------
; 12.07.00/vk
; zeichnet das item mit dem angegebenen index in den logischen screen.
; d0 = itemindex (unveraendert)
; rettet alle register
consoleItemsDrawSingleIcon
		movem.l	d0-a6,-(sp)

		lea	bmpCItems,a2
		moveq	#0,d2
		move.w	#CONSOLEITEMSSINGLEHEIGHT,d3
		mulu.w	d0,d3
		move.w	#CONSOLEITEMSWIDTH,d4
		move.w	#CONSOLEITEMSSINGLEHEIGHT,d5

		movea.l	screen_1,a0
		move.w	consoleItemsXOffset,d6
		move.w	consoleItemsYOffset,d7
		bsr	bitBltSizeOffset

		bsr.s	cidsiDrawValue

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 03.08.00/vk
; zeichnet die anzahl des aktuell aufgenommenen gegenstandtyps.
; rettet alle register
cidsiDrawValue
		movem.l	d0/a0-a1,-(sp)

		movea.l	playerDataPtr,a0
		move.w	PDCURRENTITEM(a0),d0		; es ist gewaehrleistet, dass pdcurrentitem auf den richtigen gegenstand deutet, der auch angezeigt wird
		lea	playerThings,a0
		mulu.w	#PTHGBYTES,d0
		tst.w	PTHGMULTIPLE(a0,d0.l)		; gegenstand mehrfach aufnehmbar?
; todo		beq.s	cidsidvOut			; nein -> dann brauchen wir auch keine anzahl zeichnen (ist naemlich immer 1)

		move.w	PTHGNB(a0,d0.l),d0		; anzahl holen

		bsr	wpcountConvertInteger		; in: d0, out: a0 = ascii array
		bsr	wpcountClearLeadingZeros	; in: a0 = ascii array

		bsr	wpcountCalcAsciiPixelWidth	; in: a0 = ascii array, out: d0 = pixelbreite

		movea.l	screen_1,a1
		adda.l	#1280*200+640,a1
; todo		adda.l	wpcountOffset,a1		; durch consolen-zeichenroutine gesetztes aktuelles offset
		add.w	d0,d0
		suba.w	d0,a1				; zahl soll rechtsbuendig erscheinen
		bsr	wpcountDrawNumerals

cidsidvOut
		movem.l	(sp)+,d0/a0-a1
		rts




; ---------------------------------------------------------
; 30.07.00/vk
; ueberprueft das aktuelle item auf verfuegbarkeit
; (evtl. zwischenzeitlich wieder geloescht) und bestimmt
; u. U. das naechste anzeigbare item.
; liest direkt aus/schreibt direkt in pdcurrentitem.
; rettet alle register
recalcCurrentItem
		move.l	d0,-(sp)
		bsr.s	getCurrentItemPos
		move.l	(sp)+,d0
		rts


; ---------------------------------------------------------
; 30.07.00/vk
; bestimmt - ausgehend von pdcurrentitem - den aktuell
; anzuzeigenden gegenstand fuer die console.
; pdcurrentitem wird neu gesetzt.
; rueckgabe: d0 = thingpos
; rettet alle register
getCurrentItemPos

		movem.l	d1/a4-a6,-(sp)

		movea.l	playerDataPtr,a6
		move.w	PDCURRENTITEM(a6),d0
		bpl.s	gcipDoIt

		moveq	#0,d0

gcipDoIt
		lea	playerThings,a5
		move.w	#PTHGBYTES,d1
		mulu.w	d0,d1
		adda.l	d1,a5				; a5 = aufgen. gegenstand lt. pdcurrentitem
		movea.l	a5,a4				; in a4 zwischenspeichern

	; suche vorwaerts nach aufgenommenem gegenstand

gcipForwardLoop
		tst.w	PTHGFLAG(a5)			; diesen gegenstand aufgenommen?
		bne.s	gcipFound			; ja -> dann verzweigen
		addq.w	#1,d0				; andernfalls "vorwaerts" weitersuchen
		cmpi.w	#THINGSMAX,d0			; suche "vorwaerts" noch moeglich?
		bge.s	gcipDoReverse			; nein -> dann zu rueckwaertiger suche verzweigen
		adda.w	#PTHGBYTES,a5
		bra.s	gcipForwardLoop

gcipDoReverse

	; suche rueckwaerts nach aufgenommenem gegenstand

		move.w	PDCURRENTITEM(a6),d0		; rueckwaertige suche bei d0 beginnen
gcipReverseLoop
		subq.w	#1,d0				; suche "rueckwaerts" noch moeglich?
		bmi.s	gcipNotFound			; nein -> dann verzweigen
		suba.w	#PTHGBYTES,a4
		tst.w	PTHGFLAG(a4)
		bne.s	gcipFound
		bra.s	gcipReverseLoop

gcipNotFound
		moveq	#-1,d0
gcipFound
		move.w	d0,PDCURRENTITEM(a6)
gcipOut
		movem.l	(sp)+,d1/a4-a6
		rts





		data

consoleItemsFile	dc.b	"data\console\icons.rbf",0
			even


		bss

consoleItemsXOffset	ds.w	1					; screenoffset (dx)
consoleItemsYOffset	ds.w	1					; screenoffset (dy)

consoleItems		ds.b	CONSOLEITEMSWIDTH*CONSOLEITEMSHEIGHT*2
