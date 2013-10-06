
; bitmap file: wpcount.rbf (ziffern fuer waffenstandsanzeige)
CONSOLEWEAPONCOUNTERWIDTH	equ	63
CONSOLEWEAPONCOUNTERHEIGHT	equ	9



		text


; ---------------------------------------------------------
; 11.07.00/vk
; laedt die grafik zum zeichnen der waffenstandsanzeige
; (munitionsanzahl).
initWeaponCounterFile

		lea	fileIO,a0
		move.l	#wpcountFile,FILENAME(a0)
		move.l	#weaponCounter,FILEBUFFER(a0)
		move.l	#CONSOLEWEAPONCOUNTERWIDTH*CONSOLEWEAPONCOUNTERHEIGHT*2,FILEBYTES(a0)
		bsr	loadFile

		moveq	#10-1,d0
		lea	wpcountLetterWidth,a0
		lea	wpcountLetterOffset,a1
		moveq	#0,d1
iwcfLoop	move.w	d1,d2
		add.w	d2,d2
		move.w	d2,(a1)+
		add.w	(a0)+,d1
		dbra	d0,iwcfLoop

		rts


; ---------------------------------------------------------
; 11.07.00/vk
; zeichnet die angegebene munitionsanzahl in den logischen
; screen. routine mit gleichem inhalt ist cidsiDrawValue	; .\src\console\items.s
; d0.w = zu zeichnende munitionsanzahl
; rettet alle register
wpcountDrawValue
		movem.l	d0/a0-a1,-(sp)

		bsr	wpcountConvertInteger		; in: d0, out: a0 = ascii array
		bsr	wpcountClearLeadingZeros	; in: a0 = ascii array

		bsr	wpcountCalcAsciiPixelWidth	; in: a0 = ascii array, out: d0 = pixelbreite

		movea.l	screen_1,a1
		adda.l	wpcountOffset,a1		; durch consolen-zeichenroutine gesetztes aktuelles offset
		add.w	d0,d0
		suba.w	d0,a1				; zahl soll rechtsbuendig erscheinen
		bsr	wpcountDrawNumerals

		movem.l	(sp)+,d0/a0-a1
		rts


; ---------------------------------------------------------
; 11.07.00/vk
; zeichnet die ziffern des ascii-arrays.
; a0 = ascii array (nullterminiert)
; a1 = screen
; rettet alle register
wpcountDrawNumerals
		movem.l	d0-a6,-(sp)				; todo: register evtl. verringern

		lea	wpcountLetterOffset,a6
		lea	wpcountLetterWidth,a2
		move.w	#$000f,d1
		move.w	lineoffset,d7

wpcdnLoop	move.b	(a0)+,d0
		beq.s	wpcdnSkip

		subi.b	#$30,d0
		bmi.s	wpcdnSkip				; daten inkonsistent
		and.w	d1,d0
		move.w	(a2,d0.w*2),d2				; breite des buchstabens in pixeln

		move.w	d2,d5
		add.w	d5,d5
		ext.l	d5
		add.l	a1,d5					; position fuer folgenden buchstaben zwischenspeichern

		lea	weaponCounter,a5
		adda.w	(a6,d0.w*2),a5

	; a1 = screen
	; a5 = letterbitmap

		subq.w	#1,d2

		moveq	#CONSOLEWEAPONCOUNTERHEIGHT-1,d3	; hoehe des buchstabens in pixeln
wpcdnYLoop	move.w	d2,d4
		movea.l	a1,a3
		movea.l	a5,a4
wpcdnXLoop	move.w	(a4)+,d0
		beq.s	wpcdnPixelSkip
		move.w	d0,(a3)
wpcdnPixelSkip	addq.l	#2,a3
		dbra	d4,wpcdnXLoop
		adda.w	d7,a1					; lineoffset fuer screen
		adda.w	#CONSOLEWEAPONCOUNTERWIDTH*2,a5		; lineoffset fuer bitmap
		dbra	d3,wpcdnYLoop

		movea.l	d5,a1					; position fuer naechsten buchstaben

		bra.s	wpcdnLoop
wpcdnSkip
		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 11.07.00/vk
; loescht durch verschieben des arrays fuehrende
; $30-asciicodes heraus.
; a0 = zeiger auf 6 byte ascii-array (unveraendert)
; rettet alle register
wpcountClearLeadingZeros

		move.l	d0,-(sp)

		moveq	#4-1,d0				; maximal duerfen 4 null geloescht werden
wpcclzLoop	cmpi.b	#"0",(a0)
		bne.s	wpcclzNoMore			; sobald erste nicht "0" beenden

		move.b	1(a0),(a0)
		move.b	2(a0),1(a0)
		move.b	3(a0),2(a0)
		move.b	4(a0),3(a0)
		move.b	5(a0),4(a0)

		dbra	d0,wpcclzLoop
wpcclzNoMore
		move.l	(sp)+,d0
		rts


; ---------------------------------------------------------
; 11.07.00/vk
; berechnet die breite (in pixeln) der zu zeichnenden
; ascii-zeichen.
; a0 = zeiger auf 6 byte ascii-array (unveraendert)
; rueckgabe: d0 = breite in pixel
; rettet alle register
wpcountCalcAsciiPixelWidth

		movem.l	d1-d2/a0-a1,-(sp)

		lea	wpcountLetterWidth,a1

		moveq	#0,d0
		moveq	#6-1,d2				; maximal duerfen 6 zeichen (inkl. null) berechnet werden
wpccapwLoop	move.b	(a0)+,d1
		beq.s	wpccapwOut
		subi.b	#"0",d1
		bmi.s	wpccapwOut			; daten inkonsistent
		andi.w	#$000f,d1			; maximalwert ist sowieso 9, daher kann so verknuepft werden

		add.w	(a1,d1.w*2),d0
		dbra	d2,wpccapwLoop
wpccapwOut
		movem.l	(sp)+,d1-d2/a0-a1
		rts


; ---------------------------------------------------------
; 11.07.00/vk
; berechnet die integerzahl in ascii-ziffern um.
; maximale laenge: 5 ziffern.
; d0.w = integer (unveraendert)
; rueckgabe: a0 = zeiger auf 6 byte ascii-array (nullterminiert)
; rettet alle register.
wpcountConvertInteger

		movem.l	d0-d1/a1,-(sp)

		lea	wpcountAscii,a0
		movea.l	a0,a1

		ext.l	d0
		divu.w	#10000,d0
		moveq	#$30,d1
		add.w	d1,d0
		move.b	d0,(a0)+

		swap	d0
		ext.l	d0
		divu.w	#1000,d0
		add.w	d1,d0
		move.b	d0,(a0)+

		swap	d0
		ext.l	d0
		divu.w	#100,d0
		add.w	d1,d0
		move.b	d0,(a0)+

		swap	d0
		ext.l	d0
		divu.w	#10,d0
		add.w	d1,d0
		move.b	d0,(a0)+

		swap	d0
		moveq	#$30,d1
		add.w	d1,d0
		move.b	d0,(a0)+

		clr.b	(a0)
		movea.l	a1,a0

		movem.l	(sp)+,d0-d1/a1

		rts




		data

wpcountFile	dc.b	"data\console\wpcount.rbf",0
		even

; breite der einzelnen buchstaben 0..9
wpcountLetterWidth
		dc.w	7
		dc.w	5
		dc.w	6
		dc.w	6
		dc.w	6
		dc.w	6
		dc.w	7
		dc.w	6
		dc.w	7
		dc.w	7

; offsets innerhalb der bitmap zum beginn des buchstabens
wpcountLetterOffset
		ds.w	10


		bss

wpcountOffset	ds.l	1					; screenoffset zum zeichnen der ziffern

wpcountAscii	ds.b	6


weaponCounter	ds.b	CONSOLEWEAPONCOUNTERWIDTH*CONSOLEWEAPONCOUNTERHEIGHT*2
