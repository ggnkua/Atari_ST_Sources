* Stufenweises Åberlappen in 16-Pixel-Gruppen (horizontal)
* Aufruf: overlap(quelle,ziel,pause);
* quelle:       Startadresse der Quellseite
* ziel:         Startadresse der Zielseite

.xdef _overlap
_overlap:       movem.l d1-d4/a0-a1,-(a7) *Register retten
                move.w  #15,d0          *Erstes zu zeigendes Bit
                move.w  #$ffff,d1       *Maske

ov_j1:          bclr    d0,d1           *Bit lîschen
                move.w  d1,d2           *Maske kopieren
                not.w   d2              *Maskenkopier invertieren

                move.l  28(a7),a0       *Adresse der Quellseite
                move.l  32(a7),a1       *Adresse der Zielseite
                move.w  #15999,d3        *16000 Worte

ov_j2:          move.w  (a0)+,d4        *Wert laden
                and.w   d2,d4           *mit Maske verknÅpfen
                and.w   d1,(a1)         *Bits im Zielmuster lîschen
                or.w    d4,(a1)+        *Neues Muster kopieren
                dbra    d3,ov_j2        *In Schleife

ov_j3:          dbra    d0,ov_j1        *ZurÅck in Hauptschleife
                movem.l (a7)+,d1-d4/a0-a1 *Register zurÅckholen
                rts

