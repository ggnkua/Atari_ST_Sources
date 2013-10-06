* Spiegeln um Y-Achse
* Aufruf: ymirror(ziel,ystart,yend)

.text
.xdef _ymirror
_ymirror:               movem.l d0-d5/a0-a1,-(a7)
                        move.l  36(a7),a0       *Zeiger auf Seite
                        move.w  40(a7),d0       *Startzeile
                        mulu    #160,d0         *Offset berechnen
                        adda.l  d0,a0           *Neue Adresse
                        move.w  42(a7),d0       *Letzte Zeile
                        sub.w   40(a7),d0       *Zeilenzahl - 1

ym_j0:                  movea.l a0,a1           *Kopieren
                        adda.l  #152,a1         *Letzte Gruppe der Zeile
                        move.w  #9,d1           *10*2 Gruppen/Zeile

ym_j1:                  move.w  #3,d2           *4 Gruppen
ym_j2:                  move.w  (a0),d3         *Plane 0 laden
                        move.w  (a1),d4

                        move.w  #15,d5          *16 Bits rotieren
ym_j3:                  roxr.w  #1,d3           *d3 Rechtsrotieren
                        roxl.w  #1,d4           *d4 Linksrotieren
                        dbra    d5,ym_j3        *Schleife
                        roxr.w  #1,d3           *Letztes Bit

                        move.w  d3,(a0)+        *Schreiben
                        move.w  d4,(a1)+

                        dbra    d2,ym_j2        *Schleife
                        sub.l   #16,a1          *ZurÅckzÑhlen
                        dbra    d1,ym_j1        *Schleife

                        adda.l  #80,a0          *NÑchste Zeile
                        dbra    d0,ym_j0        *Schleife

                        movem.l (a7)+,d0-d5/a0-a1
ym_end:                 rts
