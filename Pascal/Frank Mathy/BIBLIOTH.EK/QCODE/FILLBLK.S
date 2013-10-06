* FÅllen eines Blocks: fillblock(logbase,window,wert);

.text
.xdef _fillblock
_fillblock:     movem.l d1-d5/a0-a1,-(a7) *Register retten

                lea     bittab,a0       *Tabelle auf Bitmuster
                move.w  40(a7),d1       *Farbwert holen
                move.w  d1,d2           *merken
                and.w   #3,d1           *Plane 0 und 1 Farbwert
                asl.w   #2,d1           *mal 4, da Langworttabelle
                move.l  0(a0,d1.w),d4   *Werte Low-Langwort
                and.w   #12,d2          *Plane 2 und 3 Farbwert
                move.l  0(a0,d2.w),d5   *Werte High-Langwort

                movea.l 36(a7),a0       *Zeiger auf Fenster-Daten

                move.l  32(a7),a1       *Bildschirmstart
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

clb_j1:         move.w  d1,d2           *ZÑhler fÅr Breite
                move.l  a1,a0           *Zeiger kopieren

clb_j2:         move.l  d4,(a0)         *Planes 0 und 1
                move.l  d5,4(a0)        *Planes 2 und 3
                subq.l  #8,a0           *NÑchste Spalte
                dbra    d2,clb_j2       *Schleife

                add.l   #160,a1         *NÑchste Zeile
                dbra    d0,clb_j1       *Schleife

                movem.l (a7)+,d1-d5/a0-a1 *Register holen
                rts

.data
bittab:         dc.l    $00000000,$FFFF0000
                dc.l    $0000FFFF,$FFFFFFFF
