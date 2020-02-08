; Bitblit-Routine
; geschrieben von Simon Gleissner, 1993


			.GLOBL	bitblit

			.MACRO	READ_PLANES	quelle
			movem.w	(quelle)+,d0-d3	; 16 Pixel einlesen
			swap	d0				; Bitplane 0 erweitern
			swap	d1				; Bitplane 1 erweitern
			swap	d2				; Bitplane 2 erweitern
			swap	d3				; Bitplane 3 erweitern
			move.w	(quelle)+,d0	; weitere 16 Pixel einlesen
			move.w	(quelle)+,d1
			move.w	(quelle)+,d2
			move.w	(quelle)+,d3
			subq.w	#8,quelle		; Zeiger korrigieren...
			.ENDM

			.MACRO	WRITE_FULL_PLANES ziel
			movem.w	d0-d3,(ziel)	; 16 Pixel schreiben
			addq	#8,ziel			; und Zeiger anpassen
			.ENDM

			.MACRO	WRITE_EOR_PLANES ziel
			eor.w	d0,(ziel)+		; Bitplanes mit Ziel
			eor.w	d1,(ziel)+		; mit EOR verknÅpfen,
			eor.w	d2,(ziel)+		; d.h. Åberlagern
			eor.w	d3,(ziel)+
			.ENDM

			.MACRO	WRITE_AND_PLANES ziel
			and.w	d0,(ziel)+		; Bitplanes mit Ziel
			and.w	d1,(ziel)+		; mit AND verknÅpfen
			and.w	d2,(ziel)+		; d.h. ausmaskieren
			and.w	d3,(ziel)+
			.ENDM

			.MACRO	WRITE_MASK ziel,maske32
			and.l	maske32,(ziel)	; Maske mit Ziel verknÅpfen, 
			and.l	maske32,4(ziel)	; damit ein sauberer Rand entsteht
			.ENDM

			.MACRO	INVERT_PLANES
			not.w	d0				; Bitplanes invertieren
			not.w	d1
			not.w	d2
			not.w	d3
			.ENDM

			.MACRO	AND_PLANES	maske16
			and.w	maske16,d0		; Maske mit Bitplanes verknÅpfen
			and.w	maske16,d1
			and.w	maske16,d2
			and.w	maske16,d3
			.ENDM

			.MACRO	SHIFT_PLANES shift
			lsr.l	shift,d0	; Bitplane 0 verschieben
			lsr.l	shift,d1	; Bitplane 1 verschieben
			lsr.l	shift,d2	; Bitplane 2 verschieben
			lsr.l	shift,d3	; Bitplane 3 verschieben
			.ENDM




			.OFFSET

source_ad:	.DS.l	1	; Adresse des Bildspeichers
source_off:	.DS.w	1	; Offset auf nÑchste Zeile in Byte
dest_ad:	.DS.l	1
dest_off:	.DS.w	1


			.OFFSET

source_x:	.DS.w	1
source_y:	.DS.w	1
dest_x:		.DS.w	1
dest_y:		.DS.w	1
width:		.DS.w	1
height:		.DS.w	1

			.OFFSET
lines:		.DS.w	1
middle:		.DS.w	1
variablenmenge:


;	a0:	Screenbeschreibung 
;	a1:	Koordinaten
;	d0: Modus	(0=öberschreiben, 1=NAND - Ausmaskieren, 2=EOR - öberlagern)

; a6 : Pointer auf Quelle
; a5 : Pointer auf Ziel
; a4 : Pointer Quelle (anfang der Zeile)
; a3 : Pointer Ziel (Anfang der Zeile)
; a2 Zeiger auf Variablenspeicher

; d4 : Anzahl Shift-Schritte
; d7 : Linke Maske
; d6 : Rechte Maske
; d5 : Anzahl der mittleren Teile




			.TEXT
bitblit:	movem.l	d3-d7/a2-a6,-(sp)	; Register retten

			lea		varbuffer(pc),a2	; Variablenspeicher

; Anzahl der zu kopierenden Zeilen bestimmen
			move.w	height(a1),lines(a2)
			subq.w	#1,lines(a2)		; Åberhaupt etwas da zum Kopieren?
			bmi		the_end				; nî, wir kînnen gleich abbrechen

			tst.w	width(a1)
			beq		the_end
			bmi		the_end


; Quelle bestimmen
			move.l	source_ad(a0),a4	; Anfang des Quellspeichers
			move.w	source_y(a1),d7		; Y-Koordinate
			mulu	source_off(a0),d7	; mal Zeilenabstand
			move.w	source_x(a1),d6		; X-Koorinate
			and.w	#$fff0,d6			; Bit 4-15 verwenden
			asr.w	#1,d6				; /2
			ext.l	d6					; auf Langwort erweitern
			add.l	d6,d7				; zum Offset dazuaddieren
			add.l	d7,a4				; Startzeile im Speicher

; Ziel bestimmen
			move.l	dest_ad(a0),a3		; Anfang des Zielspeichers
			move.w	dest_y(a1),d7		; Y-Koordinate
			mulu	dest_off(a0),d7		; mal Zeilenabstand
			move.w	dest_x(a1),d6		; X-Koordinate
			and.w	#$fff0,d6			; Bit 4-15 verwenden
			move.w	d6,d3				; wird noch einmal gebraucht...
			asr.w	#1,d6				; /2
			ext.l	d6					; auf Langwort erweitern
			add.l	d6,d7				; zum Offset dazuaddieren
			add.l	d7,a3				; Startzeile im Speicher

; Linke Maske bestimmen
			move.w	dest_x(a1),d7		; Zielkoordinate linker Rand
			move.w	d7,d6				; wird noch einmal gebraucht...
			and.w	#$f,d7				; nur unteren 4 Bit verwenden
			move.w	d7,d4				; wird noch einmal gebraucht...
			add.w	d7,d7				; d7=d7*4
			add.w	d7,d7
			move.l	lmask(pc,d7.w),d7	; Maske holen

; Rechte Maske bestimmen
			add.w	width(a1),d6
			move.w	d6,d5				; wird noch einmal gebraucht
			and.w	#$f,d6
			add.w	d6,d6				; d6=d6*4
			add.w	d6,d6
			add.w	#100,d6
			move.l	rmask-100(pc,d6.w),d6	; Maske holen

			tst.w	d7					; linke Maske testen
			bne.s	nofullleftmask		; kein voller Block?
			add.w	#16,d5				; voller Block:
nofullleftmask:							;	ein weiterer Mittelteil

; Mittelteil bestimmen
			and.w	#$fff0,d5			; nur Bit 4-15 verwenden
			sub.w	d3,d5				; Differenz bilden
			lsr.w	#4,d5				; /16
			subq.w	#1,d5				; kleine Korrektur...
			bpl.s	not_mini

; Nur ein Wort schreiben - Masken ineinander kopieren
			clr.w	d5					; kein Mittelteil
			eor.l	d7,d6				; Rechte Maske ist neue Gesamtmaske
			clr.l	d7					; Linke Maske verschwindet
not_mini:

; Anzahl Bits bestimmen, um die verschoben wird
			move.w	source_x(a1),d3
			and.w	#$000f,d3
			sub.w	d3,d4
			bpl.s	frueherlesen
			add.w	#16,d4
			addq	#8,a4
frueherlesen:
			subq	#8,a4


			move.w	d5,middle(a2)		; in Zwischenspeicher kopieren

; Schreibmodus wÑhlen
			cmp.w	#1,d0				; Modus untersuchen...
			bmi		m0					; öberschreibmodus
			beq		m1					; Maskiermodus
			bra		m2					; öberkopiermodus

the_end:	movem.l	(sp)+,d3-d7/a2-a6	; Register zurÅckholen
			rts

lmask:		.DC.l	$00000000,$80008000,$C000C000,$E000E000
			.DC.l	$F000F000,$F800F800,$FC00FC00,$FE00FE00
			.DC.l	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
			.DC.l	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE

rmask:		.DC.l	$00000000,$7FFF7FFF,$3FFF3FFF,$1FFF1FFF
			.DC.l	$0FFF0FFF,$07FF07FF,$03FF03FF,$01FF01FF
			.DC.l	$00FF00FF,$007F007F,$003F003F,$001F001F
			.DC.l	$000F000F,$00070007,$00030003,$00010001


varbuffer:	.DS.b	variablenmenge		; Variablenspeicher

			.EVEN



; Modus 0 - Block Åberschreiben

m0:
m0_next_line:
; Neue Zeile blitten
			move.l	a3,a5				; Zeilenanfang Ziel
			move.l	a4,a6				; Zeilenanfang Quelle

; Linke Seite schreiben
			tst.l				d7		; linke Seite Åberhaupt da?
			beq.s				m0_no_left	; nein, Åberspringen!
			READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			WRITE_MASK			a5,d7	; Ziel maskieren
			not.w				d7		; Maske invertieren
			AND_PLANES			d7		; Bitplanes maskieren
			not.w				d7		; Maske invertieren
			WRITE_EOR_PLANES	a5		; Bitplanes Åberkopieren
m0_no_left:

; Mittleren Teil schreiben
			move.w		middle(a2),d5	; Anzahl Zwischenteile
			beq.s		m0_no_middle	; Kein Zwischenteil - Åberspringen!
			subq.w				#1,d5	; kleine Korrektur... (fÅr dbra)
m0_middle:	READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			WRITE_FULL_PLANES	a5		; und schreiben
			dbra				d5,m0_middle
m0_no_middle:

; Rechte Seite schreiben
			tst.l				d6		; rechte Seite Åberhaupt da?
			beq.s				m0_no_right	; nein, Åberspringen!
			READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			WRITE_MASK			a5,d6	; Ziel maskieren
			not.w				d6		; Maske invertieren
			AND_PLANES			d6		; Bitplanes maskieren
			not.w				d6		; Maske invertieren
			WRITE_EOR_PLANES	a5		; Bitplanes Åberkopieren
m0_no_right:

; nÑchste Zeile setzen
			add.w	source_off(a0),a4	; nÑchsten Zeilenanfang suchen
			add.w	dest_off(a0),a3		; nÑchsten Zeilenanfang suchen

			subq.w	#1,lines(a2)		; weitere Zeilen zu kopieren?
			bpl		m0_next_line		; Ja

			bra		the_end				; Nein, das war es schon!




; Modus 1 - Block Maskieren (NAND)
m1:
m1_next_line:
; Neue Zeile blitten
			move.l	a3,a5				; Zeilenanfang Ziel
			move.l	a4,a6				; Zeilenanfang Quelle

; Linke Seite schreiben
			tst.l				d7		; linke Seite Åberhaupt da?
			beq.s				m1_no_left	; nein, Åberspringen!
			READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			not.w				d7		; Maske invertieren
			AND_PLANES			d7		; Bitplanes maskieren
			not.w				d7		; Maske invertieren
			INVERT_PLANES				; Bitplanes invertieren
			WRITE_AND_PLANES	a5		; Bitplanes Åberkopieren
m1_no_left:

; Mittleren Teil schreiben
			move.w		middle(a2),d5	; Anzahl Zwischenteile
			beq.s		m1_no_middle	; Kein Zwischenteil - Åberspringen!
			subq.w				#1,d5	; kleine Korrektur... (fÅr dbra)
m1_middle:	READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			INVERT_PLANES				; und invertieren
			WRITE_AND_PLANES	a5		; und schreiben
			dbra				d5,m1_middle
m1_no_middle:

; Rechte Seite schreiben
			tst.l				d6		; rechte Seite Åberhaupt da?
			beq.s				m1_no_right	; nein, Åberspringen!
			READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			not.w				d6		; Maske invertieren
			AND_PLANES			d6		; Bitplanes maskieren
			not.w				d6		; Maske invertieren
			INVERT_PLANES				; Bitplanes invertieren
			WRITE_AND_PLANES	a5		; Bitplanes Åberkopieren
m1_no_right:

; nÑchste Zeile setzen
			add.w	source_off(a0),a4	; nÑchsten Zeilenanfang suchen
			add.w	dest_off(a0),a3		; nÑchsten Zeilenanfang suchen

			subq.w	#1,lines(a2)		; weitere Zeilen zu kopieren?
			bpl		m1_next_line		; Ja

			bra		the_end				; Nein, das war es schon!




; Modus 2 - Block Åberlagern (EOR)
m2:
m2_next_line:
; Neue Zeile blitten
			move.l	a3,a5				; Zeilenanfang Ziel
			move.l	a4,a6				; Zeilenanfang Quelle

; Linke Seite schreiben
			tst.l				d7		; linke Seite Åberhaupt da?
			beq.s				m2_no_left	; nein, Åberspringen!
			READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			not.w				d7		; Maske invertieren
			AND_PLANES			d7		; Bitplanes maskieren
			not.w				d7		; Maske invertieren
			WRITE_EOR_PLANES	a5		; Bitplanes Åberkopieren
m2_no_left:

; Mittleren Teil schreiben
			move.w		middle(a2),d5	; Anzahl Zwischenteile
			beq.s		m2_no_middle	; Kein Zwischenteil - Åberspringen!
			subq.w				#1,d5	; kleine Korrektur... (fÅr dbra)
m2_middle:	READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			WRITE_EOR_PLANES	a5		; und schreiben
			dbra				d5,m2_middle
m2_no_middle:

; Rechte Seite schreiben
			tst.l				d6		; rechte Seite Åberhaupt da?
			beq.s				m2_no_right	; nein, Åberspringen!
			READ_PLANES			a6		; Bitplanes lesen
			SHIFT_PLANES		d4		; und verschieben
			not.w				d6		; Maske invertieren
			AND_PLANES			d6		; Bitplanes maskieren
			not.w				d6		; Maske invertieren
			WRITE_EOR_PLANES	a5		; Bitplanes Åberkopieren
m2_no_right:

; nÑchste Zeile setzen
			add.w	source_off(a0),a4	; nÑchsten Zeilenanfang suchen
			add.w	dest_off(a0),a3		; nÑchsten Zeilenanfang suchen

			subq.w	#1,lines(a2)		; weitere Zeilen zu kopieren?
			bpl		m2_next_line		; Ja

			bra		the_end				; Nein, das war es schon!



			.END
