
LAPTOPBORDERP1MAX	equ	30
LAPTOPBORDERP4MAX	equ	20


		text


; ---------------------------------------------------------
; 17.01.00/vk
; zeichnet den rahmen um das laptop-textfeld.
; benutzt bitblt, um die bitmaps auf den logischen screen
; zu kopieren.
laptopDrawBorder

		movea.l	screenData1Ptr,a0
		move.w	SCREENDATAYOFFSET(a0),d0	; offset fuer logischen screen

		movea.l	screen_1,a0			; in den logischen screen zeichnen (wird nur ausgewertet, wenn bitblt ueber software)

		lea	laptop,a1			; variablen des laptops
		move.w	LAPTOPPOSITIONX(a1),d0
		move.w	LAPTOPPOSITIONY(a1),d1

	; unterseite inkl. eckteile (1 stretchstueck)

		move.w	d0,d6
		move.w	d1,d7
		add.w	LAPTOPHEIGHT(a1),d7

		lea	bmpLaptop08,a2
		sub.w	BITMAPWIDTH(a2),d6
		bsr	bitBlt

		add.w	BITMAPWIDTH(a2),d6

		move.w	LAPTOPWIDTH(a1),d5
		lea	bmpLaptop12,a2
		add.w	BITMAPWIDTH(a2),d5
		lea	bmpLaptop10,a2
		sub.w	BITMAPWIDTH(a2),d5		; breite des stretchstuecks
		lea	bmpLaptop09,a2
		bsr	d3bHorizontalStretch

		add.w	d5,d6
		lea	bmpLaptop10,a2
		bsr	bitBlt

		add.w	BITMAPWIDTH(a2),d6
		move.w	BITMAPHEIGHT(a2),d5
		lea	bmpLaptop11,a2
		sub.w	BITMAPHEIGHT(a2),d5
		add.w	d5,d7
		bsr	bitBlt

	; oberseite inkl. eckteile (1 stretchstueck)

		move.w	d0,d6
		move.w	d1,d7
		
		lea	bmpLaptop00,a2
		sub.w	BITMAPWIDTH(a2),d6
		sub.w	BITMAPHEIGHT(a2),d7
		bsr	bitBlt

		move.w	LAPTOPWIDTH(a1),d5
		move.w	d0,d6
		lea	bmpLaptop14,a2
		bsr	d3bHorizontalStretch

		add.w	d5,d6
		lea	bmpLaptop13,a2
		bsr	bitBlt

	; rechte seite

		move.w	d1,d7
		move.w	LAPTOPHEIGHT(a1),d4
		lea	bmpLaptop12,a2
		bsr	d3bVerticalStretch

	; linke seite

		move.w	d0,d6				; linke obere ecke des textfeldes
		move.w	d1,d7				; x (d6) wird unten noch nach links verschoben

		move.w	LAPTOPHEIGHT(a1),d5		; hoehe gesamt fuer 01 bis 07
		lea	bmpLaptop06,a2
		sub.w	BITMAPHEIGHT(a2),d5		; hoehe 06 abziehen (muss auf alle faelle gezeichnet werden)
		lea	bmpLaptop02,a2
		sub.w	BITMAPHEIGHT(a2),d5		; hoehe 02 abziehen (muss auf alle faelle gezeichnet werden)
		move.w	d5,d3				; d3 = verbleibende hoehe fuer 01,03,04,05,07
		cmpi.w	#LAPTOPBORDERP1MAX,d5		; ist diese verbl. hoehe groesser gleich der maximalen
		blt.s	ldbl01Set			; hoehe von 01, dann
		move.w	#LAPTOPBORDERP1MAX,d5		; auf p1max beschraenken
ldbl01Set
		move.w	d5,d4				; zu zeichnende hoehe des stretchstuecks 01 nach d4
		lea	bmpLaptop01,a2			; diese bitmap
		sub.w	BITMAPWIDTH(a2),d6		; d6 nun einmal fuer linke seite anpassen
		bsr	d3bVerticalStretch		; und stretchstueck 01 zeichnen

		sub.w	d4,d3				; d3 = verbleibende hoehe fuer 03,04,05,07

		add.w	d4,d7				; anzahl gezeichneter zeilen fuer 01 als yoffset addieren
		lea	bmpLaptop02,a2			; endstueck des ersten teilabschnittes
		bsr	bitBlt				; 02 zeichnen (muss gezeichnet werden, da stretchstueck 01 ja auch existiert)

		add.w	BITMAPHEIGHT(a2),d7		; gerade gezeichnete hoehe addieren

		lea	bmpLaptop03,a2			; wollen wir stueck 03,04,05 zeichnen, dann
		move.w	BITMAPHEIGHT(a2),d5		; muss mindestens platz fuer 03,05 vorhanden sein
		lea	bmpLaptop05,a2
		add.w	BITMAPHEIGHT(a2),d5		; d5 = benoetigter platz fuer 03,05

		cmp.w	d5,d3
		blt.s	ldblNo030405			; kein platz fuer 03,04,05 -> verzweigen

		lea	bmpLaptop03,a2			; drittes teilstueck kann nun gezeichnet werden
		bsr	bitBlt

		move.w	BITMAPHEIGHT(a2),d5		; d5 = gerade gezeichnete hoehe
		add.w	d5,d7				; auf y-koordinate addieren
		sub.w	d5,d3				; und von der zu zeichnen verbleibenden hoehe abziehen

		move.w	d3,d5				; stretchstueck 04 hat maximale hoehe
		cmpi.w	#LAPTOPBORDERP4MAX,d5
		blt.s	ldbl03Set
		move.w	#LAPTOPBORDERP4MAX,d5
ldbl03Set
		move.w	d5,d4
		lea	bmpLaptop04,a2
		bsr	d3bVerticalStretch		; stretchstueck 04 nun zeichnen

		sub.w	d4,d3				; gezeichnete hoehe von zu zeichnen verbleibender hoehe abziehen

		add.w	d4,d7				; auf y-koordinate addieren
		lea	bmpLaptop05,a2			; und das endstueck
		bsr	bitBlt				; vom zweiten teilabschnitt zeichnen

		move.w	BITMAPHEIGHT(a2),d5		; und offsets/variablen anpassen
		add.w	d5,d7
		sub.w	d5,d3		

ldblNo030405
		lea	bmpLaptop06,a2			; zeichnen des anfangsstueck fuer dritten teilabschnitt (06,07)
		bsr	bitBlt

		add.w	BITMAPHEIGHT(a2),d7		; gerade gezeichnete hoehe addieren

		move.w	d3,d4				; und jetzt noch
		lea	bmpLaptop07,a2			; den rest (drittes teilstueck)
		bsr	d3bVerticalStretch		; stretchstueck

		rts







		data







		bss


