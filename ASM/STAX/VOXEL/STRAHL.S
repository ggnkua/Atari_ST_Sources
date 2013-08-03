******* Source: Vorberechnung der Strahlen mit x,y Positionen ******

map_groesse	equ	256		; unsere Landschaft ist 256x256 groß

strahlen	equ	512		; volle Umdrehung = 512 Strahlen = 360 Grad
radius1		equ	40		; Kreis innen
radius2		equ 	170		; Kreis außen
punkte		equ	64		; wieviel Punkte nach vorne sehen - Richtung Horizont

bit_shift	equ	9		; 2**9 = 512 -> eine Zeile in der Landkarte 
					; siehe Landschaftsdaten

berechne_strahlen:

                lea     strahlen_speicher(PC),A0	; hier werden die Strahlen abgelegt
                lea     sin_tabelle(PC),A1		; Sinustabelle mit 1024 Eintraegen
                lea     cos_tabelle(PC),A4		; Kosinustabelle 

                moveq   #0,D0           	; Strahlenzähler initialisieren

strahlen_loop:
                move.l  D0,-(SP)

; pro Strahl durchlaufen ...

                move.w  D0,D4			
                mulu    #1024,D4		; 1024 Winkel in der Cos/Sin Tabelle ...
                divu    #strahlen,D4		; ... auf benötigte Strahlenwinkel umrechnen
                add.w   D4,D4			; fuer Tabellenzugriff ( pro Winkel ein Word)
                and.w   #$07FE,D4		; in der Tablle bleiben (sin+cos periodisch)
                move.w  0(A1,D4.w),D0		; Sinuswert (multipliziert mit 2**15)
                move.w  0(A4,D4.w),D1		; Kosinuswert (dito)
                move.w  D0,D2
                move.w  D1,D3
                muls    #radius1,D0		; X Startpunkt auf dem inneren Kreis	(x1)
                muls    #radius1,D1		; Y Startpunkt auf dem inneren Kreis	(y1)
                muls    #radius2,D2		; X Startpunkt auf dem äußeren Kreis	(x2)
                muls    #radius2,D3		; Y Startpunkt auf dem äußeren Kreis	(y2)
                add.l   D0,D0			; 2**15 * 2 = 2**16 
                add.l   D1,D1			; „
                add.l   D2,D2			; „
                add.l   D3,D3			; „
                swap    D0			; Multiplikation mit 2**16 rückgängigmachen
                swap    D1
                swap    D2
                swap    D3

                sub.w   D0,D2			; x2 - x1 = deltaX
                sub.w   D1,D3			; y2 - y1 = deltaY
                ext.l   D2			; für weitere Long Berechnungen erweitern
                ext.l   D3			; „

                suba.w  A2,A2			; A2 löschen - ist letzter x Wert
                suba.w  A3,A3			; A3 löschen - ist letzter y Wert

                moveq   #0,D4			; ist neuer x Wert
                moveq   #0,D5			; ist neuer y Wert

;--------------------------------------------------
; und jetzt die Positionsoffsets pro Strahl berechnen

                move.w  #punkte-1,D6

punkt_loop:
                movea.l D4,A5		; Aktuellen x Strahlwert sichern
                movea.l D5,A6		; gleiches für y

                divs    #punkte,D4	; zwischen Radius1 und radius2 auf dem Strahl bewegen ...
                divs    #punkte,D5	; Umrechnung, um die gewünschte Punktanzahl auf die
                add.w   D0,D4		; Distanz x1->x2, y1->y2 zu verteilen
                add.w   D1,D5
                ext.w   D4
                ext.w   D5

                movem.w D4-D5,-(SP)	; aktuelle x,y Position sichern
                sub.w   A2,D4		; von alter Position abziehen, ergibt Delta x ...
                sub.w   A3,D5		; Delta y für die Strahloffsets !
                movem.w (SP)+,A2-A3	; aktuelle Werte werden alte Position !

                and.l   #map_groesse-1,D4	; innerhalb der Landschaft bleiben x
                and.l   #map_groesse-1,D5	; innerhalb der Landschaft bleiben y

                moveq   #bit_shift,D7		; spezielles x+y Format erzeugen:
                lsl.l   D7,D5			; y mit Zeilenbreite multiplizieren
						; 256 für Höhen + 256 Pixel für Farben 
						; -> 512 = 2**9
                or.l    D4,D5			; x ins Lowword

                move.l  D5,(A0)+		; x+y Wert für den berechneten Punkt ablegen

;---------------------------------------

                move.l  A5,D4			; x+y Startwerte für Strahl wiederherstellen
                move.l  A6,D5

                add.l   D2,D4			; Weiter in x Richtung auf dem Strahl bewegen
                add.l   D3,D5			; weiter in y Richtung auf dem Strahl bewegen
                dbra    D6,punkt_loop		; Strahl abarbeiten

                move.l  (SP)+,D0

                addq.w  #1,D0			; naechster Strahl

                cmp.w   #strahlen,D0		; Schon alle Strahlen ?
                bne     strahlen_loop
                rts
