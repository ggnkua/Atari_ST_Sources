* Reinscrollen eines Bildes von unten rechts
* Aufruf: xyin(quelle,ziel)

.text
.xdef _xyin
_xyin:          movem.l d0-d3/a0-a1,-(a7) *Register retten
                move.l  #32000,d0       *Erstes zu schreibendes Wort
                move.l  #160,d1         *x_Offset am Anfang

xyi_j1:         sub.l   #1608,d0        *N„chstes Bild
                subq.l  #8,d1           *x_Offset-Z„hler
                movem.l 28(a7),a0-a1    *Adressen laden
                adda.l  d0,a1           *Zieladresse
                move.w  d0,d2           *Z„hler fr Ziel
xyi_j2:         move.w  d1,d3           *Z„hler fr x_Offset
xyi_j3:         move.l  (a0)+,(a1)+     *Kopieren
                move.l  (a0)+,(a1)+
                addq.w  #8,d2           *Z„hler fr Ziel erh”hen
                addq.w  #8,d3           *Z„hler fr x_Offset erh”hen
                cmp.w   #160,d3         *Ende der Zeile ?
                bne.s   xyi_j3          *Nein --> Zurck
                adda.l  d1,a1           *Zieladresse erh”hen
                adda.l  d1,a0           *Quelladresse erh”hen
                add.w   d1,d2           *Z„hler fr Ziel erh”hen
                cmp.l   #31999,d2       *d2 <= 31999 ?
                bls.s   xyi_j2          *Ja --> Zurck

                tst.l   d1              *Letzte Zeile ?
                bne.s   xyi_j1          *Nein --> Zurck

                movem.l (a7)+,d0-d3/a0-a1 *Register holen
                rts                     *Rckkehr
