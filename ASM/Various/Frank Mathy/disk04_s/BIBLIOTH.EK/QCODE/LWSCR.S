*  Wortweises Scrolling (um 16 Pixel):
*  Linksscrollen:  lw_scroll(logbase,window);

.text
.xdef _lw_scroll
_lw_scroll:     movem.l d1-d3/a0-a1,-(a7) *Register retten

                movea.l 28(a7),a0       *Zeiger auf Fenster-Daten

                move.l  24(a7),a1       *Bildschirmstart
                move.w  (a0),d3         *Fenster-X1
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
                subq.w  #1,d1           *Damit kein öbertrag

lws_j1:         move.w  d1,d2           *ZÑhler fÅr Breite
                move.l  a1,a0           *Zeiger kopieren

lws_j2:         move.l  8(a0),(a0)      *Planes 0 und 1
                move.l  12(a0),4(a0)    *Planes 2 und 3
                addq.l  #8,a0           *NÑchste Zeile
                dbra    d2,lws_j2       *Schleife

                add.l   #160,a1         *NÑchste Zeile
                dbra    d0,lws_j1       *Schleife

                movem.l (a7)+,d1-d3/a0-a1 *Register holen
lws_end:        rts
