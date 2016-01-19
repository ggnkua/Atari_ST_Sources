* Einlesen eines Blocks: readblk(logbase,window,buffer);
* Buffer zeigt auf einen Speicher der folgende Grîûe
* besitzen muû: (x2-x1+1)*(y2-y1+1)*8 Bytes

.text
.xdef _readblk
_readblk:       movem.l d1-d3/a0-a2,-(a7) *Register retten

                movea.l 32(a7),a0       *Zeiger auf Fenster-Daten

                move.l  28(a7),a1       *Bildschirmstart
                move.w  4(a0),d3        *Fenster-X2
                asl.w   #3,d3           *Mal 8
                ext.l   d3              *Auf Langwort
                add.l   d3,a1           *Neue Bildschirmadresse
                move.w  2(a0),d3        *Y-Zeile
                mulu    #160,d3         *Zeilenoffset
                add.l   d3,a1           *Bildschirmadresse

                move.w  6(a0),d0        *Untere Koordinate
                sub.w   2(a0),d0        *Fensterhîhe - 1

                move.w  4(a0),d1        *Rechte Koordinate
                sub.w   (a0),d1         *Fensterbreite - 1

                movea.l 36(a7),a2       *Zeiger auf Puffer

reb_j1:         move.w  d1,d2           *ZÑhler fÅr Breite
                move.l  a1,a0           *Zeiger kopieren

reb_j2:         move.l  (a0),(a2)+      *Planes 0 und 1
                move.l  4(a0),(a2)+     *Planes 2 und 3
                subq.l  #8,a0           *NÑchste Spalte
                dbra    d2,reb_j2       *Schleife

                add.l   #160,a1         *NÑchste Zeile
                dbra    d0,reb_j1       *Schleife

                movem.l (a7)+,d1-d3/a0-a2 *Register holen
reb_end:        rts
