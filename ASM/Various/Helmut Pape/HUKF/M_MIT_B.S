* Dies ist die Maschinenroutine m_mit_bild fÅr das Programm HUKF

* Die verwendeten Register:

* a4, Åbergeben in reg%(12) zeigt in die Parameterliste auf par&(8),
*     Anfang der Bilder von kleinen Fischen.

*    Die Åbrigen Parameter sind mit folgenden Offsets von a4 zu erreichen:

*    -2 :  par&(7), wenn die ErnÑhrungsvariable ( = die linken 16 Bit des
*                   32 Bit langen Belegungswortes) eines Haies diesen Wert
*                   ("HUNGER") unterschreitet, beginnt der Hai zu hungern.
*    -4 :  par&(6), solange dauert es, bis sich ein Hai zum erstenmal
*                   vermehrt.
*    -6 :  par&(5), in diesem zeitlichen Abstand vermehrt sich ein Hai.
*    -8 :  par&(4), Anfangsbelegung ("SATT") fÅr die ErnÑhrungsvariable
*                   eines Haies.
*   -10 :  par&(3), in diesem zeitlichen Abstand vermehrt sich ein
*                   kleiner Fisch.
*   -12 :  par&(2), solange dauert es, bis sich ein kleiner Fisch
*                   zum erstenmal vermehrt
*   -14 :  par&(1), Anzahl der Haie
*   -16 :  par&(0), Anzahl der kleinen Fische


* a5, reg%(13) enthÑlt einen Zeiger in die Liste der Zufallszahlen.
*              Zufallszahlen besitzen WortlÑnge (16 Bit).

* a6, reg%(14) zeigt auf das Belegungs(lang)wort des bearbeiteten Platzes.

* d3, reg%(3)  falls <> 0 --> Einzelschritt

*********************** Hier beginnt das Programm:

* Zuerst werden die Bytes gelîscht, in denen sich das Programm merkt,
* welche Tiere wÑhrend der folgenden Behandlung ihren Platz verlassen haben.

	move.w	#3999,d6	4000 PlÑtze
	moveq.w	#0,d0		zum Lîschen
	lea	2(a6),a0	Zeiger auf erstes Byte

loop	move.b	d0,(a0)		Byte lîschen
	lea	40(a0),a0	zeigt jetzt auf nÑchstes Byte
	dbra	d6,loop

*********************** Hier beginnt die Hauptschleife

	move.w	#3999,d6	zÑhlt die 4000 PlÑtze durch

nplatz	move.w	(a6),d5		Platzinhalt holen
	beq	fertig		Platz leer? Dann nichts zu tun

	tst.b	2(a6)		Tier schon bearbeitet?
	bne	fertig		ja

	tst.w	d3		Einzelschritt, wenn d3 <> 0
	beq.s	los		kein Einzelschritt

*********************** Beginn der Einzelschrittbehandlung

* Platz blinken lassen, auf Tastendruck warten, wieder invertieren.
* Falls Taste 'z', Register d3 lîschen.

	moveq.w	#4,d1		Bild 5-mal invertieren (mit Pausen)
blink	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte
	moveq.w	#7,d0		8 Zeilen invertieren
inv1	not.b	(a1)		eine Zeile des Bildes invertieren
	lea	80(a1),a1	nÑchste Bildschirmzeile
	dbra	d0,inv1
verz	dbra	d0,verz		Verzîgerung
	dbra	d1,blink

* Tastatur abfragen

	move.w	#7,-(sp)	Tastaturabfrage ohne Echo auf Bildschirm
	trap	#1		GEMDOS aufrufen
	addq.l	#2,sp		Stackzeiger korrigieren

* Tastatureingabe bearbeiten. Das getippte Byte ist in d0 ganz rechts.

	cmp.b	#'z',d0		Einzelschrittmodus beenden ?
	bne.s	weiter		nein, also weiter

	clr.l	d3		Einzelschrittmodus abschalten

* Tastaturpuffer lîschen um Nachlaufen zu verhindern:

weiter	move.w	#1,-(sp)	Devicenummer ( 1 = Tastatur ) auf Stack
	move.w	#14,-(sp)	XBIOS 14 ( Iorec )
	trap	#14		XBIOS aufrufen
	addq.l	#4,sp		Stack aufrÑumen

* Der XBIOS Aufruf hat in d0 einen Zeiger auf den Anfang der
* Beschreibung des Tastaturpuffers geliefert.
* Diese enthÑlt im Wort d0+6 die nÑchste Schreibposition und in d0+8
* die nÑchste Leseposition. Beide werden jetzt gelîscht, womit der
* Tastaturpuffer leer ist.

	move.l	d0,a0
	clr.l	6(a0)	

* Tierbild wieder zurÅckinvertieren

	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte
	moveq.w	#7,d1		8 Zeilen invertieren
inv2	not.b	(a1)		eine Zeile des Bildes invertieren
	lea	80(a1),a1	nÑchste Bildschirmzeile
	dbra	d1,inv2

*********************** Ende der Einzelschrittbehandlung

los	tst.w	d5		haben wir Hai oder kl. Fisch ?
	bmi	fisch		negativ? Dann ist es ein kleiner Fisch

*********************** Hier beginnt die Haibehandlung:

* a6 zeigt auf das Wort Hainahrung

	subq.w	#1,d5		Hainahrung um 1 verringern
	beq	fastvh		Hai ist fast verhungert

* Hier landen wir, wenn der Hai nicht fast verhungert ist:

	cmp.w	-2(a4),d5	HUNGER abziehen von Nahrung
	bmi	hungrig		ohne Register zu Ñndern !

* Hier landen wir, wenn der Hai nicht einmal hungrig ist:

* Friedlicher satter Hai will bloû herumschwimmen, es sei denn,
* er kann sich vermehren. Dann friût er auch einen k.F.

* Suche einen haifreien Platz in der Umgebung:
* Falls gefunden, steht am Ende in a2 ein Zeiger auf diesen Platz.

	lea	8(a6),a3	Zeiger auf Belegungslangwort plus 8 nach a3
*				Zeigt jetzt auf Anfang Nachbarliste
	move.w	(a5)+,d0	Zufallszahl nach d0 (0, 8, 16, 24)
	asr.w	#1,d0		durch 2 teilen gibt 0, 4, 8, 12
	adda.w	d0,a3		a3 zeigt jetzt in die Nachbarliste

	move.l	(a3)+,a2	Adresse des betrachteten Belegungswortes
	move.w	(a2),d0		dieses holen
	ble.s	haifrei		haifreier Platz gefunden

	move.l	(a3)+,a2
	move.w	(a2),d0
	ble.s	haifrei

	move.l	(a3)+,a2
	move.w	(a2),d0
	ble.s	haifrei

	move.l	(a3),a2
	move.w	(a2),d0
	ble.s	haifrei

* Der nicht hungrige Hai hat keinen haifreien Platz gefunden.
* Er ist also von lauter Haien umgeben und kann sich nicht
* bewegen und natÅrlich auch nicht vermehren.

* Haibild auf alten Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Haibild fertig

	move.w	d5,(a6)		Hainahrung zurÅckschreiben

	subq.w	#1,2(a6)	Vermehrung leider nicht mîglich.
	bne.s	verm1		also hinausschieben
	addq.w	#1,2(a6)

verm1	bra	fertig

* Der nicht hungrige Hai hat einen haifreien Platz gefunden.
* Dieser kann aber von einem kleinen Fisch besetzt sein.

* Wenn der Hai sich nicht vermehrt, tauscht er mit dem
* kleinen Fisch die PlÑtze.

haifrei	subq.w	#1,2(a6)	Haivermehrung um 1 verringern	
	beq	mehrh		Hai vermehrt sich

* Satter Hai vermehrt sich nicht:

	move.w	(a2),d1		haifreien Platz betrachten
	bne	tausch		Platz von k.F. besetzt

* Platz ist frei. Gehe dorthin. Lîsche alten Platz:

	move.w	d5,(a2)		Nahrung Åbertragen
	move.w	2(a6),2(a2)	Vermehrung Åbertragen
	not.b	2(a2)		Hai ist bereits behandelt

	clr.l	(a6)		Platz lîschen

* Bild auf altem Platz lîschen:

	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1
	clr.b	d0
	move.b	d0,(a1)		Byte lîschen
	lea	80(a1),a1	nÑchste Bildschirmzeile
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)

* Haibild auf neuem Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	bra	fertig

* Hai tauscht Platz mit kleinem Fisch:

tausch	move.w	(a2),d4		Vermehrung k.F. merken
	move.w	d5,(a2)		Nahrung Hai auf neuen Platz
	move.w	2(a6),2(a2)	Vermehrung Hai auf neuen Platz
	not.b	2(a2)		Hai ist bereits behandelt
	move.w	d4,(a6)		Vermehrung k.F. auf alten Platz
	clr.w	2(a6)		Rechte HÑlfte des Langwortes ist Null

* Kleinen Fisch auf alten Platz zeichnen:

	move.l	a4,a3		Zeiger auf Anfang kleine Fischbilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

* Haibild auf neuen Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	bra	fertig

* satter Hai vermehrt sich:

mehrh	addq.w	#1,-14(a4)	ein Hai mehr	

* suche einen kleinen Fisch in der Umgebung:
* Falls gefunden, steht am Ende in a1 ein Zeiger auf diesen Platz.

	lea	8(a6),a3	Zeiger auf Belegungslangwort plus 8 nach a3
*				Zeigt jetzt auf Anfang Nachbarliste
	move.w	(a5)+,d0	Zufallszahl nach d0 (0, 8, 16, 24)
	asr.w	#1,d0		durch 2 teilen gibt 0, 4, 8, 12
	adda.w	d0,a3		a3 zeigt jetzt in die Nachbarliste

	move.l	(a3)+,a1	Adresse des betrachteten Belegungswortes
	move.w	(a1),d0		dieses holen
	bmi	kfgef1		k.F. gefunden

	move.l	(a3)+,a1
	move.w	(a1),d0
	bmi	kfgef1

	move.l	(a3)+,a1
	move.w	(a1),d0
	bmi	kfgef1

	move.l	(a3),a1
	move.w	(a1),d0
	bmi	kfgef1

* satter Hai, der sich vermehren kann, findet keinen
* kleinen Fisch, aber ein Zeiger auf einen freien Platz
* steht noch in a2:

* Haimama schwimmt auf neuen Platz:

	move.w	-2(a4),(a2)	Hainahrung auf HUNGER
	move.w	-6(a4),2(a2)	Wiederholungswert fÅr Vermehrung
	not.b	2(a2)		Hai ist bereits behandelt

* ... und lÑût jungen Hai auf altem Platz zurÅck:

	move.w	-2(a4),(a6)	Hainahrung auf HUNGER
	move.w	-4(a4),2(a6)	Anfangswert fÅr Vermehrung

* Nun muû noch auf neuem und altem Platz je ein Hai gezeichnet werden:

* Haibild auf alten Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

* Haibild auf neuen Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	bra	fertig

* Satter Hai, der sich vermehren kann, findet kleinen Fisch.
* Ein Zeiger auf diesen steht in a1.
* Der Hai friût den k.F., vermehrt sich und ist dann immer noch satt.

kfgef1	subq.w	#1,-16(a4)	ein kleiner Fisch weniger
	move.l	a1,a2		Zeiger nach a2 (a1 wird gebraucht)

* Mama Hai schwimmt auf neuen Platz:

	move.w	-8(a4),(a2)	Hainahrung auf SATT
	move.w	-6(a4),2(a2)	Haivermehrung auf Wiederholungswert	
	not.b	2(a2)		Hai ist bereits behandelt

* Junger Hai wird hungrig geboren:

	move.w	-2(a4),(a6)	junger Hai ist hungrig
	move.w	-4(a4),2(a6)	vermehrt sich nicht so bald

* Haibild auf alten Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

* Haibild auf neuen Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	bra	fertig

* Hier landen wir, wenn der Hai hungrig ist:

* Suche einen kleinen Fisch in der Umgebung.
* Falls gefunden, steht am Ende in a2 ein Zeiger auf diesen Platz.

hungrig	lea	8(a6),a3	Zeiger auf Belegungslangwort plus 8 nach a3
*				Zeigt jetzt auf Anfang Nachbarliste
	move.w	(a5)+,d0	Zufallszahl nach d0 (0, 8, 16, 24)
	asr.w	#1,d0		durch 2 teilen gibt 0, 4, 8, 12
	adda.w	d0,a3		a3 zeigt jetzt in die Nachbarliste

	move.l	(a3)+,a2	Adresse des betrachteten Belegungswortes
	move.w	(a2),d0		dieses holen
	bmi	kfgef2		k.F. gefunden

	move.l	(a3)+,a2
	move.w	(a2),d0
	bmi	kfgef2

	move.l	(a3)+,a2
	move.w	(a2),d0
	bmi	kfgef2

	move.l	(a3),a2
	move.w	(a2),d0
	bmi	kfgef2

* hungriger Hai findet keinen kleinen Fisch:

* Von hier ab suchen wir einen freien Platz. Danach soll ein Zeiger
* auf das Belegungswort des freien Platzes in a2 stehen.

	lea	8(a6),a3	Zeiger auf Belegungslangwort plus 8 nach a3
*				Zeigt jetzt auf Anfang Nachbarliste
	move.w	(a5)+,d0	Zufallszahl nach d0 (0, 8, 16, 24)
	asr.w	#1,d0		durch 2 teilen gibt 0, 4, 8, 12
	adda.w	d0,a3		a3 zeigt jetzt in die Nachbarliste

	move.l	(a3)+,a2	Adresse des betrachteten Belegungswortes
	move.w	(a2),d0		dieses holen
	beq.s	fpgef1		freier Platz gefunden

	move.l	(a3)+,a2
	move.w	(a2),d0
	beq.s	fpgef1

	move.l	(a3)+,a2
	move.w	(a2),d0
	beq.s	fpgef1

	move.l	(a3),a2
	move.w	(a2),d0
	beq.s	fpgef1

* hungriger Hai hat nicht einmal einen freien Platz gefunden:

* Haibild auf alten Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	subq.w	#1,2(a6)	Haivermehrung verringern
	bne.s	verm2
	addq.w	#1,2(a6)	Vermehrung aufschieben
verm2	move.w	d5,(a6)		Hainahrung zurÅckschreiben

	bra	fertig

* hungriger Hai hat wenigstens einen freien Platz gefunden:

fpgef1	subq.w	#1,2(a6)	Haivermehrung verringern
	bne.s	verm3
	addq.w	#1,2(a6)	Vermehrung aufschieben
verm3	move.w	d5,(a6)		Hainahrung
	move.l	(a6),(a2)	Umzug
	not.b	2(a2)		Hai ist bereits behandelt
	clr.l	(a6)		alten Platz lîschen

* Haibild auf neuen Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

* alten Platz lîschen:
	
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1
	clr.b	d0
	move.b	d0,(a1)		Byte lîschen
	lea	80(a1),a1	nÑchste Bildschirmzeile
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)

	bra	fertig


* hungriger Hai findet kleinen Fisch:

kfgef2	subq.w	#1,-16(a4)	ein k.F. weniger

	subq.w	#1,2(a6)	Haivermehrung
	bne.s	verm4
	addq.w	#1,2(a6)	Vermehrung aufschieben

verm4	move.w	-8(a4),(a2)	Hai ist satt auf neuem Platz
	move.w	2(a6),2(a2)	Vermehrung Åbertragen
	not.b	2(a2)		Hai ist bereits behandelt
	clr.l	(a6)		alten Platz lîschen

* Haibild auf neuen Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

* alten Platz lîschen:
	
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1
	clr.b	d0
	move.b	d0,(a1)		Byte lîschen
	lea	80(a1),a1	nÑchste Bildschirmzeile
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)

	bra	fertig

* hier landen wir, wenn der Hai fast verhungert ist.
* Wir suchen einen kleinen Fisch in der NÑhe,
* der den Hai noch retten kann.

fastvh	lea	8(a6),a3	Zeiger auf Belegungslangwort nach a3
*				zeigt jetzt auf Anfang Nachbarliste
	move.w	(a5)+,d0	Zufallszahl nach d0 (0, 8, 16, 24)
	asr.w	#1,d0		durch 2 teilen gibt 0, 4, 8, 12
	adda.w	d0,a3		a3 zeigt jetzt in die Nachbarliste

* Von hier ab suchen wir einen kleinen Fisch. Danach soll ein Zeiger
* auf das Belegungswort des kleinen Fisches in a2 stehen.

	move.l	(a3)+,a2	Adresse des betrachteten Belegungswortes
	move.w	(a2),d0		dieses holen
	bmi.s	kfgef3		k.F. gefunden

	move.l	(a3)+,a2
	move.w	(a2),d0
	bmi.s	kfgef3

	move.l	(a3)+,a2
	move.w	(a2),d0
	bmi.s	kfgef3

	move.l	(a3),a2
	move.w	(a2),d0
	bmi.s	kfgef3

* leider nichts gefunden. Hai ist verhungert.

	subq.w	#1,-14(a4)	Ein Hai weniger
	clr.l	(a6)		Platz lîschen
	
	move.l	4(a6),a1	Haibild lîschen
	clr.b	d0
	move.b	d0,(a1)		Byte lîschen
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)

	bra	 fertig

* der fast verhungerte Hai hat einen kleinen Fisch gefunden:

kfgef3	subq.w	#1,-16(a4)	Ein k.F. weniger

	move.w	-2(a4),(a2)	Hainahrung auf HUNGER
	move.w	2(a6),2(a2)	Vermehrung mitnehmen
	not.b	2(a2)		Hai ist bereits behandelt
	clr.l	(a6)		alten Platz lîschen

	move.l	4(a6),a1	altes Bild lîschen
	clr.b	d0
	move.b	d0,(a1)		Byte lîschen
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)

* Haibild auf neuen Platz zeichnen:

	lea	32(a4),a3	Zeiger auf Anfang Haibilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	bra	fertig

*********************** Hier beginnt die kl. Fischbehandlung:

fisch	lea	8(a6),a3	Zeiger auf Belegungslangwort plus 8 nach a3
*				Zeigt jetzt auf Anfang Nachbarliste
	move.w	(a5)+,d0	Zufallszahl nach d0 (0, 8, 16, 24)
	asr.w	#1,d0		durch 2 teilen gibt 0, 4, 8, 12
	adda.w	d0,a3		a3 zeigt jetzt in die Nachbarliste

* Von hier ab suchen wir einen freien Platz. Danach soll ein Zeiger
* auf das Belegungswort des freien Platzes in a2 stehen.

	move.l	(a3)+,a2	Adresse des betrachteten Belegungswortes
	move.w	(a2),d0		dieses holen
	beq.s	fpgef2		freier Platz gefunden

	move.l	(a3)+,a2
	move.w	(a2),d0
	beq.s	fpgef2

	move.l	(a3)+,a2
	move.w	(a2),d0
	beq.s	fpgef2

	move.l	(a3),a2
	move.w	(a2),d0
	beq.s	fpgef2

* Hier landen wir, wenn der kleine Fisch keinen freien Nachbarplatz hat.
* Also kleinen Fisch mit zufÑlliger Orientierung auf alten Platz zeichnen.

	move.l	a4,a3		Zeiger auf Anfang kleine Fischbilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	addq.w	#1,d5		Vermehrung rÅckt eins nÑher
	bne.s 	verm5
	subq.w	#1,d5		Vermehrung aufschieben
verm5	move.w	d5,(a6)
	bra	fertig

* Kleiner Fisch findet freien Nachbarplatz. a2 zeigt auf ihn.
* K.F. auf neuen Platz zeichnen.

fpgef2	move.l	a4,a3		Zeiger auf Anfang kleine Fischbilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a2),a1	Zeiger auf oberstes Bildschirmbyte nach a1

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	addq.w	#1,d5		Vermehrung rÅckt eins nÑher
	bne.s 	kverm		noch keine Vermehrung

	addq.w	#1,-16(a4)	ein kleiner Fisch mehr
	move.w	-10(a4),(a2)	Wiederholungswert Vermehrung k.F.
*				auf neuen Platz damit
	not.b	2(a2)		k.F. ist bereits behandelt

	move.w	-12(a4),(a6)	neuer k.F. auf alten Platz

* Kleinen Fisch auf alten Platz zeichnen:

	move.l	a4,a3		Zeiger auf Anfang kleine Fischbilder
	adda.w	(a5)+,a3	Zufallszahl 0, 8, 16 oder 24 addieren
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1

	move.b	(a3)+,(a1)	oberste Zeile des Bildes auf den Bildschirm
	lea	80(a1),a1	nÑchste Bildschirmzeile

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3)+,(a1)
	lea	80(a1),a1

	move.b	(a3),(a1)	Bild fertig

	bra.s fertig

kverm	move.w	d5,(a2)		k.F. vermehrt sich nicht, aber wandert
	not.b	2(a2)		k.F. ist bereits behandelt
	clr.w	(a6)		alten Platz lîschen
	
	move.l	4(a6),a1	Zeiger auf oberstes Bildschirmbyte nach a1
	clr.b	d0
	move.b	d0,(a1)		Byte lîschen
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)
	lea	80(a1),a1
	move.b	d0,(a1)


fertig	lea	40(a6),a6	nÑchster Platz

	dbra	d6,nplatz	ZÑhler 3999 ... -1 in d6

	rts

