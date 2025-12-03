
* Diese Routine schiebt einen rechteckigen Ausschnitt des Bildschirms
* um einen Bildpunkt nach links.  Dabei geht die vertikale Pixelreihe
* am linken Rand des Ausschnitts verloren und am rechten Rand wird eine
* Reihe von weien Pixeln nachgeschoben.  Der linke und der rechte Rand
* des Rechtecks liegen auf einer Wortgrenze (16 Bit).

* Hier soll die Routine fr das Programm HUKF verwendet werden.
* Links und rechts l„t das Rechteck jeweils 16 Pixel frei.
* Oben sind es 25, unten 10. 365 Zeilen sind zu verschieben.

* šbergebener Parameter in Adreregister A3 :

* Ein Zeiger auf das an die letzte zu verschiebende Bildschirmzeile
* rechts anschlieende Langwort (wegen der Adressierungsart -(Ax).


	move.w	#364,d7 	Zeilenz„hler

* Eine aus 38 Worten zu je 16 Bit bestehende Zeile um ein Bit
* nach links schieben:

weiter	move.w	#0,ccr		Extend Bit l”schen

	roxl.w	-(a3)  	 1  <-- Numerierung, damit wir uns
	roxl.w	-(a3)	 2      nicht verz„hlen
	roxl.w	-(a3)	 3
	roxl.w	-(a3)	 4
	roxl.w	-(a3)	 5
	roxl.w	-(a3)	 6
	roxl.w	-(a3)	 7
	roxl.w	-(a3)	 8
	roxl.w	-(a3)	 9
	roxl.w	-(a3)	10
	roxl.w	-(a3)	11
	roxl.w	-(a3)	12
	roxl.w	-(a3)	13
	roxl.w	-(a3)	14
	roxl.w	-(a3)	15
	roxl.w	-(a3)	16
	roxl.w	-(a3)	17
	roxl.w	-(a3)	18
	roxl.w	-(a3)	19
	roxl.w	-(a3)	20
	roxl.w	-(a3)	21
	roxl.w	-(a3)	22
	roxl.w	-(a3)	23
	roxl.w	-(a3)	24
	roxl.w	-(a3)	25
	roxl.w	-(a3)	26
	roxl.w	-(a3)	27
	roxl.w	-(a3)	28
	roxl.w	-(a3)	29
	roxl.w	-(a3)	30
	roxl.w	-(a3)	31
	roxl.w	-(a3)	32
	roxl.w	-(a3)	33
	roxl.w	-(a3)	34
	roxl.w	-(a3)	35
	roxl.w	-(a3)	36
	roxl.w	-(a3)	37
	roxl.w	-(a3)	38

	subq.l	#4,a3		Bis zur n„chsten Zeile 4 Bytes berspringen.

	dbra	d7,weiter

	rts

