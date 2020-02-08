******** Kopieren von n Zeilen eines Lores - Screens *************

* In A0 befindet sich die Anfangsadresse Quelle
* In A1 die Anfangsadresse Ziel
* In A2 Endadresse des Ziels (fr clipping)
* D0 Z„hler fr die zu bertragenden Zeilen
* D1 > 65535 = Vergr”žerung, D1 < 65535 Verkleinerung




**************** kopieren einer Zeile **************

zeile:
                swap    D1              ;alles was >65535 ins
*                                        niederwertige Wort
wie_oft:
                cmp.w   #0,D1           ;keine ganze Zeile ?
                beq.s   aus             ;dann raus
                cmpa.l  A2,A1           ;vergleiche jezige mit Endadresse
                bge.s   out             ;>= dann raus (sonst 2 Bomben)
                movem.l 0(A0),D3-D7/A3-A6 ; die ersten 9 Longs lesen (Quelle)
                movem.l D3-D7/A3-A6,0(A1) ;  schreiben (Ziel)
                movem.l 36(A0),D3-D7/A3-A6 ; nochmal 9 Longs der Zeile
                movem.l D3-D7/A3-A6,36(A1) ;  schreiben (Ziel)
                movem.l 72(A0),D3-D7/A3-A6 ; nochmal 9 Longs der Zeile
                movem.l D3-D7/A3-A6,72(A1) ;  schreiben (Ziel)
                movem.l 108(A0),D3-D7/A3-A6 ;nochmal 9 Longs
                movem.l D3-D7/A3-A6,108(A1) ;schreiben Ziel
                movem.l 144(A0),D3-D6   ;die letzten 4 Longs
                movem.l D3-D6,144(A1)   ;schreiben Ziel
                lea     160(A1),A1      ;n„chste Zeile des Ziels
                dbeq    D1,wie_oft      ;solange Zeilen
aus:            sub.w   D1,D1           ;D1 ist dann -1 also l”schen
                swap    D1              ;niederwertiges wieder nach oben
                add.l   D2,D1           ;Faktor dazuz„hlen
                lea     160(A0),A0      ;n„chste Zeile Quelle
                dbra    D0,zeile        ;solange Zeilen>=0
out:
*****************************************************
