;	Uhr-Einsteller vX.X
;
;	written	1986 by	MABA
;	SOFTWARE FOUNDATION
;	Abt. FreeSoft
;
;	Address:	Martin Backschat
;			Bergstraûe 16
;			8071 Hepberg
;
;
;	Dieses geile Programm ist mit dem OMIKRON-ASSEMBLER ST geschrieben.
;	Weitere	Informationen Åber diesen Assembler erhalten Sie direkt
;	bei OMIKRON.

;Dieses	Programm dient zum Eintstellen die aktuellen Uhrzeit und des Datums.
;es ist	dazu gedacht, im Auto-Folder beim Systemstart aufgerufen zu werden.

;	Initialisierung	und BegrÅûungsausgabe auf dem Bildschirm

init:

	move.l	#text1,d7	;Adresse des 1.	Textes fÅr Routine merken
	bsr	print		;gibt String aus


;	Holt Uhrzeit; mit Subroutine get_tasten	wird nur auf '.' und Ziffern
;	reagiert.

	move.l	#muster1,a6	;Åbergibt der Tasten-Hol-Routine die Adresse
				;des Puffers, wo spÑter	die Uhrzeit steht
	move.l	#muster1a,a5	;Åbergibt die je hîchsten Werte	fÅr die	Eingaben

	bsr	holen		;Åberschreibt das Eingabemuster	mit echten
				;Werten

	; ------ Kodieren der Zeit in Bitmuster	und Speicherung	im Wort	ZEIT ------

	move.l	#muster1,a0	;Routine benîtigt Adresse des zu wandelnden 2-Byte-Formates
	bsr	kodieren	;kodiert...
	lsl.w	#05,d0		;schiebt Ergebnis um 11	Stellen	nach links (Std. sind ganz oben)
	lsl.w	#06,d0
	move.w	d0,ZEIT		;schreibt unbedingt das	Ergebnis nach Zwischenspeicher

	move.l	#muster1+3,a0	;Routinen wandelt Minuten in Bitmuster um
	bsr	kodieren	;wandelt...
	lsl.w	#5,d0		;schiebt Ergebnis um 5 Stellen nach links (Minuten stehen in der Mitte)
	or.w	d0,ZEIT		;verknÅpft nicht fertigen Zwischenspeicher mit Minuten-Bitmuster

	move.l	#muster1+6,a0	;Routine benîtigt Adresse des zu wandelnden Zwei-Byte-Formats in A0
	bsr	kodieren	;kodiert das Format in ein Bitmusterformat und ÅberlÑût	es D0
	lsr.b	#1,d0		;teilt praktisch durch 2
				;dies muû sein,	da das Sekundenformat nur in Zweierschritten angenommen	wird
	or.w	d0,ZEIT		;und mit dem gesamten Bitmuster	bestehend aus Std,Min,Sek verknÅpfen

	move.w	ZEIT,-(sp)	;Zeit setzen
	move.w	#$2d,-(sp)	;Funktionskode fÅr SETTIME
	trap	#1		;GEMDOS	- Aufruf
	addq.l	#4,sp		;Stack restaurieren

	bsr	tastatur	;Tastatur-Uhr einstellen


; ------------ 2.Teil -----------------------------------------------------------------------

	move.l	#text2,d7	;Adresse des 2.textes fÅr Routine merken
	bsr	print		;gibt String aus

;	Holt das datum mit der gleichen	Routine	wie oben

	move.l	#muster2,a6	;Åbergibt der Eingabewarteschleife die Musterzeile
	move.l	#muster2a,a5	;Åbergibt wie oben die Adresse der maximalen Werte

	bsr	holen		;Åberschreibt die Datums-Musterzeile und Åbergibt die Benutzereingeben


	;kodieren als Bitmuster	des Datums (Tag,Monat,Jahr)

	move.l	#muster2,a0	;Basisadresse des tages
	bsr	kodieren	;kodiert Tag in	Bitmuster (siehe oben)
	move.w	d0,DATE		;Speichert unbedingt das Muster	als Initialisator in Zwischenspeicher

	move.l	#muster2+3,a0	;Basisadresse des Monats
	bsr	kodieren	;kodiert Monat in Bitmuster
	lsl.w	#5,d0		;um 5 Pos. nach	links
	or.w	d0,DATE		;verknÅpft Monat mit alten Zwischenspeicher


	move.l	#muster2+6,a0	;Basisadresse des Jahres
	clr.l	d0		;Arbeitsregister lîschen
	clr.l	d1
	clr.l	d2

	move.b	(a0)+,d1	;erstes, hîchstes Zeichen holen
	subi.b	#$30,d1		;und beginnend ab 0 ( -	9)
	mulu	#1000,d1	;Mal 1000, fÅr Jahrtausend
	move.w	d1,d0		;und zwischenspeichern
	clr.l	d1		;sowie Arbeitsregister wieder lîschen

	move.b	(a0)+,d1	;zweites Zeichen holen
	subi.b	#$30,d1		;0 - 9 nicht als Zeichen, sondern als Wert
	mulu	#100,d1		;Mal 100 fÅr Jahrhundert
	add.w	d1,d0		;und zwischenspeichern

	move.w	d0,d2		;Wert des Zwischenspeichers in anderes register

	bsr	kodieren	;den rest des Jahres kann die alte Routine bearbeiten

	add.w	d2,d0		;addiert das gesamte Jahr zusammen

	subi.l	#1980,d0	;zieht vom errechneten Jahr den	Offset 1980 ab,	um die effektive Zahl zu bekommen

	lsl.w	#4,d0		;11 Pos. nach links schieben, in richtige Position
	lsl.w	#5,d0

	or.w	d0,DATE

	move.w	DATE,-(sp)	;Datum setzen
	move.w	#$2b,-(sp)	;Funktionskode fÅr SETDATE
	trap	#1		;GEM DOS
	addq.l	#4,sp		;Stack wieder aktualisieren


;---------------3.Teil-------------------------------------------------------------------------------------

	move.l	#text3a,d7	;Adresse des textes fÅr	'Uhrzeit:'
	bsr	print		;ausgeben
	move.l	#muster1,d7	;Die neue Uhrzeit ausgeben
	bsr	print		;ausgeben

	move.l	#text3b,d7	;Adresse des textes fÅr	'Datum:'
	bsr	print		;ausgeben
	move.l	#muster2,d7	;Das neue Datum	ausgeben
	bsr	print		;ausgeben


	move.l	#text4,d7	;Text fÅr 'Taste drÅcken'
	bsr	print		;ausgeben

;	----------------------Wartet auf eine Taste-----------------

	move.w	#7,-(sp)	;Aufruf	AUF EINE TASTE WARTEN
	trap	#1		;GEM DOS
	addq.l	#2,sp		;Stack restaurieren

	move.l	#CUROFF,d7	;text fÅr ESC-Sequenz <CURSOR OFF>
	bsr	print		;gibt Sequenz aus

	move.w	#0,-(sp)	;Funktionsnummer fÅr PTERM
	trap	#1		;Programm beenden...


;	----------------------Unterroutine get_taste----------------
;	liest vom Anwender eine	Zeile ein, nimmt jedoch	nur den	'.' und
;	Ziffern	0-9 an.
;	Musterzeile:	  A6
;	Vergleichszeile:  A5

holen:
	move.l	#STORE,d7	;Textadresse fÅr Store Cursor Adress
	bsr print		;gibt Text aus

	move.l	a6,d7		;Åbergeben Mustertextadresse merken
	bsr print		;gibt Text aus

	move.l	#RESTORE,d7	;Textadresse fÅr Resore	Cursor Adress
	bsr print		;gibt Sequenz aus


;	Eingabewarteschleife
	move.l	#0,d2		;Position in Muster/Eingabezeile init. (=0)

loop1:
	jsr	Crawcin		;holt eine Taste, wobei	im Lowbyte des Hiword der Scan-Kode steht

	cmpi.b	#'.',d0		;ist es	der Punkt gewesen, dann	zur nÑchsten Eingabe springen
	beq	punkt		;es ist	der Punkt gewesen, also	zur Routine springen

	cmpi.b	#13,d0		;war es	ein RETURN, dann Subroutine beenden
	beq	return		;return	ist ein	Label fÅr das RTS

	cmpi.b	#8,d0		;war's ein BACKSPACE
	beq	bspace		;wenn ja, dann darauf reagieren

	cmpi.b	#'0',d0		;Ziffer	0
	blt	loop1		;kleiner, also ungÅltig...
	cmpi.b	#'9',d0		;grîûte	Ziffer 9
	bhi	loop1		;grîûer, also ungÅltig...

	;auf Ziffern 0-9 reagieren...

	move.b	0(a6,d2.l),d3	;gespeichertes Zeichen lesen
	cmpi.b	#0,d3		;war Zeichen eine Null (also Ende?)
	beq	loop1		;wenn ja, dann nichts machen und zurÅck...

	cmp.b	0(a5,d2.l),d0	;Musterzeile bzw. Eingabe mit dem je hîchst erlaubten Wert vergleichen
	bhi	loop1		;ist Eingabe hîher als erlaubt,	dann zurÅck zur	Eingabewarteschleife

	move.b	d0,0(a6,d2.l)	;Tastenkode in Muster speichern
loop4:	addq.l	#1,d2		;Pointer erhîhen

	bra	loop2		;zurÅckspringen


	;auf Punk reagiern -> zum nÑchsten Nicht-Punkt-Zeichen (achtet auch auf	Null!)
punkt:
	move.b	1(a6,d2.l),d3	;nÑchstes Zeichen auf Punkt testen (oder gar Ende?)

	cmpi.b	#0,d3		;schon Ende, dann gar nichts machen...
	beq	loop1		;und auf Tastendruck reagieren...

	bsr	right		;gibt eine CURSOR-RIGHT	Sequenz	aus
	addq.l	#1,d2		;Pointer um eins erhîhen

	cmpi.b	#'.',d3		;ist das nÑchste Zeichen ein Punkt gewesen?
	bne	punkt		;war's vorhin kein Punkt, dann weitermachen


	addq.l	#1,d2		;Zum Abschluû nochmal erhîhen

	bsr	right		;CURSOR	RIGHT ausgeben
back1:	bra	loop1		;zurÅck	zur Eingabewarteschleife


	;Ein Zeichen weiter nach rechts	und zurÅck...
loop2:
	move.w	d0,-(sp)	;wars eine Ziffer, dann	diese ausgeben
	move.w	#2,-(sp)	;Funktionskode fÅr ZEICHEN AUSGEBEN
	trap	#1		;GEM DOS Aufruf
	addq.l	#4,sp		;Stack restaurieren

	move.b	0(a6,d2.l),d0	;neues Zeichen lesen

	cmpi	#'.',d0		;ist das neue Zeichen ein Punkt?
	beq	loop4		;wenn ja, dann Pointer erhîhen und auf BS um eins weitergehen
	bne	loop1


	;BACK SPACE reagieren

bspace:
	cmpi.b	#0,d2		;ist der Pointer schon 0?
	beq back1		;ist der Pointer 0 gewesen, dann wieder	zur Eingabewarteschleife zurÅck

	bsr	left		;pos. den Cursor um ein	Zeichen	nach links
	subq.l	#1,d2		;den Pointer um	eins erniedrigen

	move.b	0(a6,d2.l),d3	;neues zeichen in D3 kopieren
	cmpi.b	#'.',d3		;ist das Zeichen ein Punkt?
	bne back2

	bsr	left		;pos. den Cursor zum 2.	Mal (da	Punkt!)	nach links
	subq.l	#1,d2		;und nochmal den Pointer erniedrigen

back2:
	bra back1		;und dasselbe nochmal


return:
	rts


;Diese Routine Crawcin holt ein	Zeichen	ohne Echo von der Tastatur.
;Im Lowbyte des	Lowword	ist der	ASCII, im Lowbyte des Highword ist der Scannkode

Crawcin:
	move.w	#7,-(sp)	;Funktionsnummer fÅr Crawcin
	trap	#1		;GEM DOS Aufruf
	addq.l	#2,sp		;Stack reparieren

	rts


;Diese Routine positioniert den	Cursor um eine Pos. nach rechts

right:
	move.l	#RIGHT,d7	;Adresse des Ausrichtungstextes	merken
print:
	move.l	d7,-(sp)	;Adresse aus D7	auf den	Stack
	move.w	#9,-(sp)	;Funktionsnummer fÅr PRINT LINE
	trap	#1		;GEM DOS
	addq.l	#6,sp		;Stack restaurieren

	rts


;Diese Routine pos. den	Cursor um eine Pos. nach linsk

left:
	move.l	#LEFT,d7	;Adresse des Ausrichtungstextes	merken
	jmp print		;gibt Åber PRINT LINE den Text aus



;Diese Routine verwandelt ein in A0 (Lowword) Åbergebene Adresse eines Zweibyte-Formats	in
;dessen	benîtigtes Bitmusterformat,daû dann in D0 steht

kodieren:
	clr.l	d0		;Arbeitsregister lîschen
	clr.l	d1

	move.b	(a0)+,d1	;oberstes Byte der zwei	lesen
	subi.b	#$30,d1		;Bei einer Zahl	muû der	Wert $30 abgezogen werden,
				;um den	dezimal	kodierten Wert zu bekommen

	mulu	#10,d1		;mal 10	nehmen,	um das obere Byte richtig zustellen

	move.b	(a0),d0		;unteres Byte der zwei lesen
	subi.b	#$30,d0		;genau wie oben	auf dezimal umrechnen

	add.l	d1,d0		;und alles zusammenkopieren -> hexadez.	Wert

	rts			;und fertig!


;Diese Routine stellt die Uhrzeit des Tastatur-Prozessors...

tastatur:
	move.l	DATE,-(sp)	;da ZEIT hinter	DATE kommt, kann man das auch als 32-Bit Wert ansehen
	move.w	#22,-(sp)	;Funktionskode fÅr SETTIME & DATE
	trap	#14		;xBIOS aufrufen
	addq.l	#6,sp		;Stapel	wieder herstellen

	rts


;	------------------------------------------------------------------
;	--	Texte	--------------------------------------------------
;	------------------------------------------------------------------

text1:
	.dc.b	27,'E',27,'p',27,'w',27,'e'
	.dc.b	"            Uhr-Einsteller ST v1.2   by MABA  -  SOFTWARE FOUNDATION            ",27,'q',13,10,13,10
	.dc.b	"ACHTUNG: Bei Verwendung des ACCs <KONTROLLFELD> wird die Uhrzeit von diesem",13,10
	.dc.b	"         wieder Åberschrieben!",13,10,13,10,27,'v'
	.dc.b	"Bitte geben Sie die Uhrzeit im Format HH.MM.SS ein: >",0

text2:
	.dc.b	13,10
	.dc.b	"Bitte geben Sie das Datum im Format TT.MM.JJJJ ein: >",0

text3a:
	.dc.b	13,10,13,10
	.dc.b	"Eingestellte Uhrzeit: ",0

text3b:
	.dc.b	13,10
	.dc.b	"Eingestelltes Datum : ",0

text4:
	.dc.b	13,10,13,10
	.dc.b	"DrÅcken Sie eine Taste, um ins DESK-TOP zu gelangen...",0


muster1:
	.dc.b	"00.00.00",0
muster1a:
	.dc.b	"29.59.59"	;entÑlt	fÅr die	Musterzeile die	je hîchsten Werte

muster2:
	.dc.b	"15.04.1986",0
muster2a:
	.dc.b	"39.19.2999"


RIGHT:
	.dc.b	27,'C',0


LEFT:
	.dc.b	27,'D',0


CUROFF:
	.dc.b	27,'f',0


STORE:
	.dc.b	27,'j',27,'e',0		;store Cursor Pos. and Cursor ON


RESTORE:
	.dc.b	27,'k',0

.even

DATE:
	.dc.w	0

ZEIT:
	.dc.w	0

.even
