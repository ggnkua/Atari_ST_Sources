*
* Beispiel einer Funktion fr DIPS V1.1
* -------------------------------------
*
* Das Beispiel dient zum Aufzeigen der M”glichkeiten fr die Programmierung
* externer Funktionen in DIPS V1.1.
*
* Es sollten alle CPU-Register, die in der Funktion ver„ndert werden,
* vor Beginn der Funktion auf dem Stack gerettet werden. Als Parameter
* werden der Funktion immer folgende Adressen ber den Stack bergeben:
*
*  4(sp) = Adresse des Bildes 1 (32k-Worte) (Akku)
*  8(sp) = Adresse des Bildes 2 (32k-Worte)
* 12(sp) = Adresse des Bildes 3 (32k-Worte)
* 16(sp) = Adresse des Bildes 4 (32k-Worte)
* 20(sp) = Adresse eines Hilfsbuffers mit 131072 Worten. Dieser Buffer
*	   kann fr Zwischenrechnungen in der Funktion verwendet werden.
*	   Nach dem Ende einer Funktion kann dieser Buffer jedoch in DIPS
*	   ver„ndert werden!
* 24(sp) = Adresse der letzten Bildschirmkopie vor dem Einsprung in die
*	   Funktion (32000 Bytes). Der Bildschirm kann nach Ende der
*	   Funktion aus diesem Buffer wieder geladen werden.
* 28(sp) = Adresse des Einsprungpunkts der Maschinenroutinen in DIPS.EXE
* 32(sp) = **** frei fr sp„tere Erweiterungen ****
*	   In dieser Version nicht weiter verwenden!!!
* 36(sp) = Adresse eines Wortes mit der Antwort bei Alert-Buttons.
*	   0 wenn kein Button angeklickt wurde. Wert sonst fr Button
*	   von links nach rechts: 1,2,3, usw.
* 40(sp) = Adresse eines Wortes mit der Belegungsmaske des Stacks:
*	   Bit0=Bild 1 ... Bit3=Bild 4; Bit gesetzt, bedeutet Stackplatz
*	   belegt. Diese Maske kann von der Funktion auch ver„ndert werden.
*	   DIPS reagiert entsprechend auf die Ver„nderung der ersten 4 Bits
*	   im Wort. Die Bits 5-15 haben zur Zeit keine Funktion, k”nnen
*	   aber in sp„teren DIPS-Versionen ggf. Bedeutung erlangen.
*
* Als Rckgabeparameter k”nnen an DIPS Werte im Register d0.L zurckgegeben
* werden. Dabei sind folgende M”glichkeiten gegeben:
*
* d0=0	 : keine Meldung in DIPS, ordentliches Ende des Funktionsaufrufs.
*
* d0<0	 : alle negativen Werte sind Fehlermeldungen der Funktion an DIPS.
*	   Es wird ein Fehleralert ausgegeben, anschlieend wird die
*	   Funktion immer abgebrochen! Mit dem higher Wort (h.W) des Rck-
*	   gabewertes wird unterschieden:
*
*	   h.W=$FFFF : Es wird ein Funktionsfehler als Nummer ausgegeben.
*		       Die Nummer steht als negatives Wort im lower Wort
*		       von d0. D.h. durch Laden eines Langwortes von -1
*		       bis -65536 kann diese Ausgabe erzeugt werden.
*					
*	   h.W=$FFFE : Es wird ein DIPS-Fehler-Alert ausgegeben. Die Fehler-
*		       nummer steht als positiver Wert im lower Wort von d0.
*		       Z.Zt. sind die Fehler 1-39 definiert. Andere Zahlen
*		       werden ignoriert! D.h. es erfolgt ein Abbruch der
*		       Funktion ohne Fehlermeldung!
*
* d0>0	 : alle positiven Werte sind DIPS-Systemaufrufe und fhren nie zum
*	   Abbruch der Funktion. Das higher Wort (h.W) und das lower Wort
*	   (l.W) von d0 dienen zur Unterscheidung der einzelnen Optionen:
*
*	   h.W=$0000 : l.W=$FFFF : Bildschirmredraw aus dem internen Screen-
*				   Buffer, der auch ber 24(sp) angesprochen
*				   werden kann. Ver„nderungen in diesem
*				   Screenbuffer werden dann natrlich ange-
*				   zeigt!
*
*		       l.W=$FFFE : Bilder im Stack neuzeichnen entsprechend
*				   der aktuellen Maske in 40(sp).
*
*		       l.W=$FFFD : Bildschirm in den internen Screenbuffer
*				   kopieren.
*
*		       l.W=$FFFC : belegt fr sp„tere Erweiterungen. Z.Zt.
*		       bis $F000   keine Reaktion in DIPS (kann sich aber
*				   in sp„teren Versionen „ndern!).
*
*	   h.W.<>0   : d0 enth„lt eine Adresse mit weiteren Informationen:
*		       Dabei zeigt d0 auf ein Codewort. In dieser DIPS-
*		       Version ist nur die Codeziffer 2 definiert:
*
*		       (d0)=2	 : Alert ausgeben. Der Alert-String beginnt
*				   in 2(d0) mit einem Wort, das den Default-
*				   button kennzeichnet. Ab 4(d0) beginnt der
*				   Alert-String und endet mit einem Nullbyte.
*				   Aufbau entsprechend der GEM-Funktion
*				   ~FORM_ALERT().

	.text

	bra.s	start		* unbedingt erforderlich!!!
	dc.b	" ---- FUNKTIONSDEMO ---- " * max. 26 Zeichen!
	dc.b	0		* mu mit 0 abgeschlossen sein!
	.even			* Programm beginnt auf Wortadresse!

* zun„chst prfen, ob tats„chlich 2 Bilder im Stack sind:

start	movem.l d1-d7/a0-a6,-(sp)	* Alle Adressenangaben + 56 Bytes !
	move.l	96(sp),a2	* Adresse der Belegungsvariablen
	move	(a2),d0 	* Wert laden und Belegungsbits fr
	and	#3,d0		* ...Akku und Bild 2 herausl”sen
	bne.s	contin		* Dort weitertesten...
	move	#$fffe,d0	* DIPS-Error-Alert anfordern
	swap	d0		* Rckgabewert wird negativ
	move.w	#31,d0		* --> DIPS-Fehler #31 erzeugen
return	movem.l (sp)+,d1-d7/a0-a6	* Rcksprung zu DIPS
	rts

* Test, ob nur ein Bild geladen ist:

contin	cmp	#3,d0		* nur ein Bild geladen?
	beq.s	allesok 	* nein...
	move.l	#-1,d0		* --> Funktionsfehler 1 erzeugen
	bra	return

* jetzt ist alles ok: Demo ablaufen lassen...

allesok move.l	92(sp),a0	* Adresse der Button-Variablen
	move	(a0),d0 	* Buttonnummer laden, negativ?
	beq.s	cont		* dann wurde kein Button gedrckt!
	cmp	#1,d0		* linker Button ?
	bne.s	cont		* nein ...
	lea	demo(pc),a0	* Abbruch: eine nicht verwendete Demonummer ergibt
	move.w	#999,(a0)	* beim n„chsten Aufruf ein ordentliches Ende!
	move.l	#$ffff,d0	* Bildschirm-Redraw anfordern
	bra	return

cont	move	demo(pc),d1	* Hilfsvariable laden (PC-relativ!!!)
	beq	call0		* --> Funktionsmeldung 1234 geben
	cmp	#1,d1
	beq	call1		* --> Funktionsalert erzeugen
	cmp	#2,d1
	beq	call2		* --> Kopieranweisung abarbeiten & Redraw
	cmp	#3,d1
	beq	call3		* --> alle Bilder neu anzeigen
ende	lea	demo(pc),a0	* Demovariable
	clr	(a0)		* neu aufsetzen
	clr.l	d0		* ordentliches Ende der Funktion
	bra	return

* Funktionsmeldung 1234 ausgeben:

call0	move.l	#1234,d0	* higher Wort=0, lower Wort=1234
next	lea	demo(pc),a0
	add.w	#1,(a0) 	* n„chste Demo schon einstellen
	bra	return		* Funktion ausfhren... (DIPS-Rcksprung)

* Funktionsalert erzeugen:

call1	lea	alert(pc),a0	* Alert-String fr ~FORM_ALERT() laden
	move.l	a0,d0		* und an Rckgaberegister bergeben
	bra.s	next

* Hier geschieht nun endlich was einigermaen sinnvolles:

call2	move	#32767,d7	* Schleifenz„hler fr halbes Bild
	move.l	60(sp),a0	* Akku-Adresse
	move.l	64(sp),a1	* Adresse von Bild 2
	move	#127,d7 	* Zeilenz„hler
loopz	move	#255,d6 	* Spaltemz„hler
loops	move	(a0),d1 	* Pixel aus Akku laden
	move	(a1),(a0)+	* Pixel aus Bild 2 nach Akku kopieren
	move	d1,(a1)+	* Pixel in Bild 2 speichern
	dbra	d6,loops	* n„chste Spalte kopieren
	dbra	d7,loopz	* n„chste Zeile kopieren

* Bildschirm restaurieren:

	move.l	#$ffff,d0	* Bildschirm von 24(sp) zurckkopieren
	bra	next		* n„chste Demo (CALL3)

* Anzeige aller belegten Stackbilder:

call3	move.l	#$fffe,d0	* Bilder neu darstellen
	bra	next		* Demoende


*---------------------------------------------------------------------------
*
* Hier sind alle Zwischenspeicher. Zugriff PC-Relativ !!!

demo		dc.w	0		* Hilfsspeicher fr Aufruftest

* Der Aufbau fr einen Alert: (Codewort 2 ist unbedingt notwendig!)

alert		dc.w	2		* Codewort
		dc.w	2		* Defaultbutton ist:   [ weiter ]
		dc.b	"[3]["
		dc.b	"ACHTUNG|"
		dc.b	"Dies ist ein Funktions-Alert.|"
		dc.b	"N„chste Demo: Vertauschen der|"
		dc.b	"oberen H„lfte (128 Zeilen) von|"
		dc.b	"Bild 1 und Bild 2.]"
		dc.b	"[Abbruch| weiter ]"
		dc.b	0		* Ende des Strings mit Nullbyte!!!

		.end

