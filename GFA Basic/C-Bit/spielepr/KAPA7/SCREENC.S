******** Kopieren von n Zeilen eines Lores - Screens *************

* In A0 befindet sich die Anfangsadresse Quelle
* In A1 die Anfangsadresse Ziel
* D0 ZÑhler fÅr die zu Åbertragenden Zeilen





**************** kopieren einer Zeile **************

zeile:

                movem.l (A0)+,D1-D7/A2-A6 ; die ersten 13 Longs lesen (Quelle)
                movem.l D1-D7/A1-A6,(A1) ;  schreiben (Ziel)
                lea     52(A1),A1       ;   Addiert 52 Bytes zu A1 dazu
                movem.l (A0)+,D1-D7/A2-A6 ; nochmal 13 Longs lesen (Quelle)
                movem.l D1-D7/A2-A6,(A1) ;  schreiben (Ziel)
                lea     52(A1),A1
                movem.l (A0)+,D1-D7/A2-A6 ; nochmal 13 longs lesen (Quelle)
                movem.l D1-D7/A2-A6,(A1) ;  schreiben (Ziel)
                lea     52(A1),A1
                move.l  (A0)+,(A1)+     ;   das lezte Long
                dbra    D0,zeile

*****************************************************




                END
