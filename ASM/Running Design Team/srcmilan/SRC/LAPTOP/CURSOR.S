
LAPTOPCURSORBLINKTIME	equ	50		; blinkzeit des cursors in msek. (pro farbwechsel)

; struktur laptopcursordata (zeichnen des cursors)
LAPTOPCURSORVBLCOUNTER	equ	0
LAPTOPCURSORNBOFCOLORS	equ	2
LAPTOPCURSORCOLORPOS	equ	4
LAPTOPCURSORCOLORARRAY	equ	6




		text


; ---------------------------------------------------------
; 20.01.00/vk
; setzt den cursor auf die letzte angezeigte zeile des laptops
; an den zeilenanfang.
; rettet alle verwendeten register.
laptopSetCursorLastLine

		movem.l	d0/a0,-(sp)
		lea	laptop,a0
		clr.w	LAPTOPCURSORX(a0)
		clr.w	LAPTOPCURSOROFFSETX(a0)
		move.w	LAPTOPY(a0),d0				; aktuelle hoehe in zeilen
		subq.w	#1,d0					; anpassen auf letzten zeilenindex
		move.w	d0,LAPTOPCURSORY(a0)			; und zeilenindex schreiben
		movem.l	(sp)+,d0/a0
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; zeichnet den cursor an die aktuelle position im
; offscreen memory.
laptopDrawCursor

	; speicheradresse fuer linke obere ecke des cursors bestimmen (offscreen memory)

		lea	laptop,a6
		movea.l	LAPTOPSCREENMEMORY(a6),a0
		move.w	LAPTOPCURSORY(a6),d0		; zeilennummer (index)
		movea.l	LAPTOPFONTDATAPTR(a6),a1
		move.w	LFDELTAY(a1),d7			; hoehe einer zeile
		mulu.w	d7,d0
		move.w	LAPTOPLINEOFFSET(a6),d4		; brauchen d4 spaeter noch einmal, daher in register
		mulu.w	d4,d0
		adda.l	d0,a0
		move.w	LAPTOPCURSOROFFSETX(a6),d0
		add.w	d0,d0
		adda.w	d0,a0				; a0 = zielgrafikbereich

	; farbe des cursors bestimmen

		lea	laptopCursorData,a4
		move.w	LAPTOPCURSORVBLCOUNTER(a4),d5
		add.w	vblTime1000,d5
		cmpi.w	#LAPTOPCURSORBLINKTIME,d5
		blt.s	ldcNoColorChange

		moveq	#0,d5

		move.w	LAPTOPCURSORCOLORPOS(a4),d6
		addq.w	#1,d6
		cmp.w	LAPTOPCURSORNBOFCOLORS(a4),d6
		blt.s	ldcNoAnimRestart
		moveq	#0,d6
ldcNoAnimRestart
		move.w	d6,LAPTOPCURSORCOLORPOS(a4)
ldcNoColorChange
		move.w	d5,LAPTOPCURSORVBLCOUNTER(a4)

		move.w	LAPTOPCURSORCOLORPOS(a4),d6
		move.w	LAPTOPCURSORCOLORARRAY(a4,d6.w*2),d3	; farbwert holen

	; d3 = farbwert
	; d4 = laptoplineoffset
	; d7 = lfdeltay
	; a0 = screenadresse (cursor)
	; a1 = laptopfontdata

		move.w	LFDELTAX(a1),d6
		subq.w	#1,d6
		subq.w	#1,d7
ldcLoop1	move.w	d6,d5
		movea.l	a0,a2
ldcLoop2	move.w	d3,(a2)+
		dbra	d5,ldcLoop2
		adda.w	d4,a0
		dbra	d7,ldcLoop1

		rts








		data


; datenfeld laptopcursordata (zum zeichnen des cursors)
laptopCursorData
		dc.w	0					; zaehler
		dc.w	8					; anzahl an farben
		dc.w	0					; farbindex
		dc.w	%0000000000000000			; farbarray
		dc.w	%0011100111100111
		dc.w	%0111101111101111
		dc.w	%1100011000011000
		dc.w	%1111111111111111
		dc.w	%1100011000011000
		dc.w	%0111101111101111
		dc.w	%0011100111100111




		bss




