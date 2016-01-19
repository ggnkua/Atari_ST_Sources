*  Pixelweises Scrolling (um 1 Pixel):
*  Rechtsscrollen: rp_scroll(logbase,window);

.xdef _rp_scroll
_rp_scroll:     movem.l d1-d3/a0-a1,-(a7) *Register retten

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
                sub.w   2(a0),d0        *Fensterh”he - 1

                move.w  4(a0),d1        *Rechte Koordinate
                sub.w   (a0),d1         *Fensterbreite - 1

rps_j1:         move.w  #3,d2           *4 Planes

rps_j2:         move.l  a1,a0           *Nach a0 kopieren
                move.w  d1,d3           *d3 als Z„hler
                move    #0,ccr          *Statusregister l”schen

rps_j3:         roxr.w  (a0)            *Word rotieren
                addq.l  #8,a0           *N„chstes Wort
                dbra    d3,rps_j3       *Schleife

                addq.l  #2,a1           *N„chste Plane
                dbra    d2,rps_j2       *Schleife

                add.l   #152,a1         *N„chste Zeile
                dbra    d0,rps_j1       *Schleife

                movem.l (a7)+,d1-d3/a0-a1 *Register holen
                rts
