

		text



; ---------------------------------------------------------
; initialisiert den laptop (dimensionen u. a.), muss nach jedem
; aufloesungswechsel aufgerufen werden
initLaptop
		lea	laptop,a0

	; laptop auf maximalgroesse stellen

		move.w	#LAPTOPMAXX,LAPTOPX(a0)		; aktuelle groesse in buchstaben/zeilen
		move.w	#LAPTOPMAXY,LAPTOPY(a0)

	; fontdaten setzen und font als aktiv eintragen

		bsr	setLaptopFontTahoma

	; lineoffsets

		move.w	#LAPTOPMAXX*LAPTOPFONTMAXX*2,d0
		move.w	d0,LAPTOPLINEOFFSET(a0)
		move.w	d0,LAPTOPLINEOFFSETMEMORY(a0)

	; breite/hoehe und screenadresse

		bsr	laptopCalcDimensions

	; offscreen zeichenbereich

		move.l	#laptopScreenMemory,LAPTOPSCREENMEMORY(a0)

	; struktur fuer ascii-text-inhalt erzeugen

		bsr.s	ilCreateAsciiTextPtr

	; bildschirmspeicher loeschen

		bsr.s	laptopClearAsciiText

	; laptop einmal komplett im aktuellen zustand offscreen zeichnen

		bsr	laptopDrawOffscreen

		rts


; ---------------------------------------------------------
; 17.01.00/vk
; erstellt die pointer fuer den direkten zugriff auf
; jede laptop zeile (ascii text).
; a0 = laptop
ilCreateAsciiTextPtr
		lea	laptopTextPtr,a1
		move.l	a1,LAPTOPTEXTPTR(a0)
		lea	laptopText,a2
		move.w	#LAPTOPMAXY-1,d0
ilcatpLoop	move.l	a2,(a1)+
		adda.w	#LAPTOPMAXX,a2
		dbra	d0,ilcatpLoop
		rts
	

; ---------------------------------------------------------
; 17.01.00/vk
; loescht das gesamte textfeld des laptops im ascii-array.
; es findet kein update des grafikfeldes statt.
; die datenstruktur laptop muss bereits den korrekten
; laptoptextptr enthalten.
; es wird jeweils an den zeilenanfang eine -1 zum kennzeichen
; des endes der zeile geschrieben.
; rettet alle verwendeten register.
laptopClearAsciiText
		movem.l	d0-d1/a0-a1,-(sp)
		lea	laptop,a0
		movea.l	LAPTOPTEXTPTR(a0),a0
		move.w	#LAPTOPMAXY-1,d0
		moveq	#-1,d1
lcatLoop	movea.l	(a0)+,a1
;		move.b	d1,(a1)

		move.b	#"E",(a1)
		move.b	#"s",1(a1)
		move.b	#" ",2(a1)
		move.b	#"i",3(a1)
		move.b	#"s",4(a1)
		move.b	#"t",5(a1)
		move.b	#" ",6(a1)
		move.b	#"(",7(a1)
		move.b	#"9",8(a1)
		move.b	#")",9(a1)
		move.b	#"!",10(a1)
		move.b	#"4",11(a1)
		move.b	#"5",12(a1)
		move.b	#"6",13(a1)
		move.b	#"7",14(a1)
		move.b	#"8",15(a1)
		move.b	#"9",16(a1)
		add.b	d0,16(a1)
		move.b	d1,17(a1)

		dbra	d0,lcatLoop
		movem.l	(sp)+,d0-d1/a0-a1
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; loescht eine einzelne zeile des textfeldes im ascii-array.
; d6.w = zeilennummer
; rettet alle verwendeten register.
laptopClearAsciiTextOneRow

		move.l	a0,-(sp)
		lea	laptop,a0
		movea.l	LAPTOPTEXTPTR(a0),a0
		movea.l	(a0,d6.w*4),a0
		move.b	#-1,(a0)
		movea.l	(sp)+,a0
		rts


; ---------------------------------------------------------
; zeichnet den kompletten laptop im aktuellen zustand
; in den offscreen-buffer
laptopDrawOffscreen

		bsr	laptopDrawBackground
		bsr	laptopDrawAllRows

		rts


; ---------------------------------------------------------
; 17.01.00/vk
; setzt die dimensionen des laptops neu, das gesamte textfeld
; wird im ascii-array geloescht. es findet kein update des
; grafikfeldes statt.
; d0 = breite in buchstaben
; d1 = hoehe in zeilen
; alle register werden gerettet.
laptopSetDimensions

		movem.l	d0-a6,-(sp)

		lea	laptop,a0
		move.w	d0,LAPTOPX(a0)				; breite und
		move.w	d1,LAPTOPY(a0)				; hoehe setzen

		bsr.s	laptopCalcDimensions			; dimensionen/interne variablen neu berechnen
		bsr	laptopClearAsciiText			; und gesamtes textfeld loeschen

		movem.l	(sp)+,d0-a6
		rts


; ---------------------------------------------------------
; 26.12.99/vk
; berechnet die aktuell eingestellten laptopdimensionen.
; muss nach jeder aenderung von laptopx(a0)/laptopy(a0)
; aufgerufen werden.
; rettet alle verwendeten register.
laptopCalcDimensions

		movem.l	d0-d2/a0-a1,-(sp)

	; breite und hoehe berechnen

		lea	laptop,a0
		movea.l	LAPTOPFONTDATAPTR(a0),a1	; pointer fuer datenstruktur font holen
		move.w	LFDELTAX(a1),d0			; durchschnittliche breite des fonts holen
		mulu.w	LAPTOPX(a0),d0			; multipliziert mit anzahl dargestellter buchstaben
		move.w	d0,LAPTOPWIDTH(a0)		; und als breite abspeichern
		move.w	LFDELTAY(a1),d0			; hoehe des fonts
		mulu.w	LAPTOPY(a0),d0
		move.w	d0,LAPTOPHEIGHT(a0)

	; screenadresse berechnen (absolute adresse im screen_1)

		bsr.s	laptopCalcScreenOffset

	; cursorposition

		bsr	laptopSetCursorLastLine

		movem.l	(sp)+,d0-d2/a0-a1
		rts


; ---------------------------------------------------------
; 21.01.00/vk
; berechnet das offset fuer die screenadresse der linken
; oberen ecke des laptops (textfeld).
; muss nach jeder aenderung der bildschirmaufloesung
; aufgerufen werden.
; rettet alle register
laptopCalcScreenOffset

		movem.l	d0-d2/a0,-(sp)

		lea	laptop,a0

		move.w	lineoffset,d1

		move.w	#LAPTOPPOSY,d0
		bmi.s	lcsoBottom
lcsoUp		move.w	d0,LAPTOPPOSITIONY(a0)
		mulu.w	d1,d0				; d0 = offset fuer zeilen
		bra.s	lcsoYOk
lcsoBottom	neg.w	d0
		move.w	height,d2
		sub.w	d0,d2
		sub.w	LAPTOPHEIGHT(a0),d2
		move.w	d2,LAPTOPPOSITIONY(a0)
		mulu.w	d1,d2
		move.l	d2,d0
lcsoYOk
		move.w	#LAPTOPPOSX,d1
		move.w	d1,LAPTOPPOSITIONX(a0)
		add.w	d1,d1
		ext.l	d1
		add.l	d1,d0
		move.l	d0,LAPTOPSCREENOFFSET(a0)

		movem.l	(sp)+,d0-d2/a0

		rts


; ---------------------------------------------------------
; todo: routine optimieren auf 32/64 bit
; 26.12.99/vk
; kopiert den offscreen-laptop (memory) in den 
; physikalischen bildschirmspeicher
laptopCopyToPhysicalVideoRam

		lea	laptop,a6			; datenstruktur
		movea.l	LAPTOPSCREENMEMORY(a6),a0	; memory mit offscreen grafik
		movea.l	screen_2,a1
		adda.l	LAPTOPSCREENOFFSET(a6),a1	; a1 = zieladresse
		move.w	LAPTOPWIDTH(a6),d6
		move.w	LAPTOPHEIGHT(a6),d7
		subq.w	#1,d6
		subq.w	#1,d7
		move.w	lineoffset,d3
		move.w	LAPTOPLINEOFFSET(a6),d4

lctpvrLoop1	move.w	d6,d5
		movea.l	a0,a2
		movea.l	a1,a3
lctpvrLoop2	move.w	(a2)+,(a3)+
		dbra	d5,lctpvrLoop2
		adda.w	d4,a0
		adda.w	d3,a1
		dbra	d7,lctpvrLoop1

		rts


; ---------------------------------------------------------
; todo: routine optimieren auf 32/64 bit
; 26.12.99/vk
; kopiert den offscreen-laptop (memory) in den 
; bildschirmspeicher
laptopCopyToVideoRam

		lea	laptop,a6			; datenstruktur
		movea.l	LAPTOPSCREENMEMORY(a6),a0	; memory mit offscreen grafik
		movea.l	screen_1,a1
		adda.l	LAPTOPSCREENOFFSET(a6),a1	; a1 = zieladresse
		move.w	LAPTOPWIDTH(a6),d6
		move.w	LAPTOPHEIGHT(a6),d7
		subq.w	#1,d6
		subq.w	#1,d7
		move.w	lineoffset,d3
		move.w	LAPTOPLINEOFFSET(a6),d4

lctvrLoop1	move.w	d6,d5
		movea.l	a0,a2
		movea.l	a1,a3
lctvrLoop2	move.w	(a2)+,(a3)+
		dbra	d5,lctvrLoop2
		adda.w	d4,a0
		adda.w	d3,a1
		dbra	d7,lctvrLoop1

		rts


; ---------------------------------------------------------
; todo: routine optimieren auf 32/64 bit
; 01.01.00/vk
; kopiert den offscreen-laptop (memory) in den 
; bildschirmspeicher (nur eine zeile)
; d7 = zeilennummer
laptopCopyToVideoRamOneRow

		lea	laptop,a6			; datenstruktur
		movea.l	LAPTOPSCREENMEMORY(a6),a0	; memory mit offscreen grafik

		movea.l	LAPTOPFONTDATAPTR(a6),a1
		move.w	LFDELTAY(a1),d5
		mulu.w	d5,d7
		move.w	d7,d6
		move.w	LAPTOPLINEOFFSET(a6),d4
		mulu.w	d4,d7
		adda.l	d7,a0

		movea.l	screen_1,a1
		adda.l	LAPTOPSCREENOFFSET(a6),a1	; a1 = zieladresse

		move.w	lineoffset,d3
		mulu.w	d3,d6
		adda.l	d6,a1

		move.w	LAPTOPWIDTH(a6),d6
		subq.w	#1,d6
		move.w	d5,d7
		subq.w	#1,d7

lctvrorLoop1	move.w	d6,d5
		movea.l	a0,a2
		movea.l	a1,a3
lctvrorLoop2	move.w	(a2)+,(a3)+
		dbra	d5,lctvrorLoop2
		adda.w	d4,a0
		adda.w	d3,a1
		dbra	d7,lctvrorLoop1

		rts


; ---------------------------------------------------------
; 27.12.99/vk
; zeichnet den hintergrund des laptops ins offscreen memory
laptopDrawBackground
		lea	laptop,a0
		movea.l	LAPTOPSCREENMEMORY(a0),a0
		bsr.s	dlBackground
		rts


; ---------------------------------------------------------
; 26.12.99/vk
; todo: routine kann schneller gemacht werden, wenn schleife nicht pixelweise abgearbeitet wird
; zeichnet den hintergrund des laptops
; a0 = screenadresse laptop
dlBackground
		lea	laptop,a1
		move.w	LAPTOPWIDTH(a1),d6
		move.w	LAPTOPHEIGHT(a1),d7
		subq.w	#1,d6
		subq.w	#1,d7
		move.w	LAPTOPLINEOFFSET(a1),d4
		movea.l	LAPTOPFONTDATAPTR(a1),a2
		move.w	LFBACKCOLOR(a2),d3
dlbLoop1	move.w	d6,d5
		movea.l	a0,a1
dlbLoop2	move.w	d3,(a1)+
		dbra	d5,dlbLoop2
		adda.w	d4,a0
		dbra	d7,dlbLoop1

		rts


; ---------------------------------------------------------
; 23.01.00/vk
; todo: routine kann schneller gemacht werden, wenn schleife nicht pixelweise abgearbeitet wird
; zeichnet eine zeile des hintergrunds des laptops
; d0 = zeilennummer [0...]
; a0 = screenadresse laptop
dlBackgroundOneRow
		lea	laptop,a1
		move.w	LAPTOPWIDTH(a1),d6
		subq.w	#1,d6
		move.w	LAPTOPLINEOFFSET(a1),d4
		movea.l	LAPTOPFONTDATAPTR(a1),a2
		move.w	LFBACKCOLOR(a2),d3
		move.w	LFDELTAY(a2),d7
		mulu.w	d7,d0
		mulu.w	d4,d0
		adda.l	d0,a0
		subq.w	#1,d7
dlborLoop1	move.w	d6,d5
		movea.l	a0,a1
dlborLoop2	move.w	d3,(a1)+
		dbra	d5,dlborLoop2
		adda.w	d4,a0
		dbra	d7,dlborLoop1

		rts


; ---------------------------------------------------------
; 27.12.99/vk
; zeichnet alle reihen der laptopanzeige neu ins
; offscreen memory
laptopDrawAllRows
		lea	laptop,a6
		move.w	LAPTOPY(a6),d6
		subq.w	#1,d6
		moveq	#0,d7
ldarLoop	movem.w	d6-d7,-(sp)
		bsr.s	laptopDrawOneRow
		movem.w	(sp)+,d6-d7
		addq.w	#1,d7
		dbra	d6,ldarLoop
		rts


; ---------------------------------------------------------
; 27.12.99/vk
; zeichnet angegebene reihe der laptopanzeige neu in
; die offscreen-grafik
; d7 = zeilennummer (0..)
laptopDrawOneRow	
		lea	laptop,a6
		movea.l	LAPTOPFONTDATAPTR(a6),a1

		move.w	LAPTOPLINEOFFSET(a6),d0
		move.w	LFLINEOFFSET(a1),d1

		move.w	LFDELTAY(a1),d2
		mulu.w	d7,d2
		mulu.w	d0,d2
		movea.l	LAPTOPSCREENMEMORY(a6),a0		
		adda.l	d2,a0

		movea.l	LFASCIICONVERTPTR(a1),a2
		movea.l	LFLETTERWIDTHPTR(a1),a3
		movea.l	LFLETTERGFXOFFSETPTR(a1),a4

		movea.l	LAPTOPTEXTPTR(a6),a5
		movea.l	(a5,d7.w*4),a5				; a5 = ascii-zeile

		move.w	LAPTOPX(a6),d6
		subq.w	#1,d6
ldorLoop	move.b	(a5)+,d7
		bmi.s	ldorSkip
		movem.l	d6/a0/a5,-(sp)
		bsr	dlOneLetter
		movem.l	(sp)+,d6/a0/a5
		add.w	d7,d7
		adda.w	d7,a0
		dbra	d6,ldorLoop
ldorSkip
		rts


; ---------------------------------------------------------
; 26.12.99/vk
; zeichnet einen einzelnen buchstaben
; register werden nicht gerettet
; d0.w = lineoffset (screen memory) - unveraendert
; d1.w = lineoffset (fontgrafik) - unveraendert
; d7.b = ascii code
; a0 = screenadresse fuer aktuellen buchstaben - unveraendert
; a1 = laptopfontdata
; a2 = ltasciiconvertptr
; a3 = ltletterwidthptr
; a4 = ltlettergfxoffsetptr
; rueckgabe:
; d7.w = breite des buchstaben in pixeln
dlOneLetter
		andi.w	#$7f,d7
		move.w	(a2,d7.w*2),d7			; d7 = index des buchstaben
		movea.l	LFGFXPTR(a1),a5			; a5 = texturdaten aller buchstaben
		adda.w	(a4,d7.w*2),a5			; a5 = pointer texturdaten des aktuellen buchstaben
		move.w	(a3,d7.w*2),d7			; breite des buchstaben in pixeln
		move.w	d7,d6				; breite des buchstabens absolut
		subq.w	#1,d6				; breite - 1 fuer dbra
		move.w	LFDELTAY(a1),d2			; hoehe des buchstablens absolut
		subq.w	#1,d2				; hoehe - 1 fuer dbra
		movem.l	a0-a1,-(sp)			; register retten
dlolLoop1	move.w	d6,d3				; schleifenzaehler breite kopieren
		movea.l	a0,a6				; ziel lokal nach a6
		movea.l	a5,a1				; quelle lokal nach a1
dlolLoop2	move.w	(a1)+,(a6)+			; pixel kopieren
		dbra	d3,dlolLoop2			; komplette breite abarbeiten
		adda.w	d0,a0
		adda.w	d1,a5
		dbra	d2,dlolLoop1
		movem.l	(sp)+,a0-a1
		rts

