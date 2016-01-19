*Logische VerknÅpfung von Bereichen von 2 Bildschirmseiten
*Aufruf mit opscreen(quelle,ziel,ystart,yend,operation)
*Operation steht fÅr:
*                     0: Ziel == Quelle AND Ziel
*                     1: Ziel == Quelle OR  Ziel
*                     2: Ziel == Quelle EOR Ziel
*                     3: Ziel == NOT Ziel

.text
.xdef _opscreen
_opscreen:              movem.l d0-d1/a0-a1,-(a7) *Register retten
                        movea.l 20(a7),a0         *Quellseite
                        movea.l 24(a7),a1         *Zielseite
                        move.w  28(a7),d0         *ystart laden
                        mulu    #40,d0            *Offset errechnen
                        adda.l  d0,a0             *Quelladresse
                        adda.l  d0,a1             *Zieladresse
                        move.w  30(a7),d0         *yende laden
                        sub.w   28(a7),d0         *yende - ystart
                        addq.w  #1,d0             *yende - ystart + 1
                        mulu    #40,d0            *da 40 Langwîrter per Zeile
                        subq.w  #1,d0             *da DBRA-Befehl

                        move.w  32(a7),d1       *Operation bestimmen
                        dbra    d1,ops_j1       *d1 war <> 0 --> Weiter

ops_and:                move.l  (a0)+,d1        *Wert laden
                        and.l   d1,(a1)+        *VerknÅpfen
                        dbra    d0,ops_and      *Schleife
                        bra.s   ops_end         *Ende

ops_j1:                 dbra    d1,ops_j2       *d1 war <> 1 --> Weiter

ops_or:                 move.l  (a0)+,d1        *Wert laden
                        or.l    d1,(a1)+        *VerknÅpfen
                        dbra    d0,ops_or       *Schleife
                        bra.s   ops_end         *Ende

ops_j2:                 dbra    d1,ops_j3       *d1 war <> 2 --> Weiter

ops_eor:                move.l  (a0)+,d1        *Wert laden
                        eor.l   d1,(a1)+        *VerknÅpfen
                        dbra    d0,ops_eor      *Schleife
                        bra.s   ops_end         *Ende

ops_j3:                 dbra    d1,ops_end      *d1 war <> 3 --> Weiter

ops_not:                not.l   (a1)+           *Invertieren
                        dbra    d0,ops_not      *Schleife

ops_end:                movem.l (a7)+,d0-d1/a0-a1 *Register holen
ops_quit:               rts
