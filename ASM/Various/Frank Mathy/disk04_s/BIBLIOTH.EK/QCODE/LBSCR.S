*  Byteweises Scrolling (um 8 Pixel):
*  Linksscrollen:  lb_scroll(logbase,window);

.text
.xdef _lb_scroll
_lb_scroll:     movem.l d1-d3/a0-a1,-(a7) *Register retten

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
                subq.w  #1,d1           *Damit kein Åbertrag

lbs_j1:         move.w  d1,d2           *ZÑhler fÅr Breite
                move.l  a1,a0           *Zeiger kopieren

lbs_j2:         move.b  1(a0),(a0)      *Plane 0 kopieren
                move.b  8(a0),1(a0)
                move.b  3(a0),2(a0)     *Plane 1
                move.b  10(a0),3(a0)
                move.b  5(a0),4(a0)     *Plane 2
                move.b  12(a0),5(a0)
                move.b  7(a0),6(a0)     *Plane 3
                move.b  14(a0),7(a0)
                addq.l  #8,a0           *NÑchstes Wort
                dbra    d2,lbs_j2       *Schleife

                move.b  1(a0),(a0)      *Plane 0 kopieren
                move.b  3(a0),2(a0)     *Plane 1
                move.b  5(a0),4(a0)     *Plane 2
                move.b  7(a0),6(a0)     *Plane 3

                add.l   #160,a1         *NÑchste Zeile
                dbra    d0,lbs_j1       *Schleife

                movem.l (a7)+,d1-d3/a0-a1 *Register holen
lbs_end:        rts
