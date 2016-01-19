*  Runterscroll: dn_scroll(logbase,window,schritte);

.text
.xdef _dn_scroll
_dn_scroll:     movem.l d1-d3/a0-a1,-(a7) *Register retten

                movea.l 28(a7),a0       *Zeiger auf Fenster-Daten
                move.w  6(a0),d0        *Untere Koordinate
                sub.w   2(a0),d0        *Fensterhîhe - 1
                sub.w   32(a7),d0       *Zu kopierende Zeilen-1

                move.w  4(a0),d1        *Rechte Koordinate
                sub.w   (a0),d1         *Fensterbreite - 1

                move.w  32(a7),d2       *Zahl der Schritte
                muls    #-160,d2        *Zu addierender Offset

                move.l  24(a7),a1       *Bildschirmstart
                move.w  (a0),d3         *Fenster-X1
                asl.w   #3,d3           *Mal 8
                ext.l   d3              *Auf Langwort
                add.l   d3,a1           *Neue Bildschirmadresse
                move.w  6(a0),d3        *Y-Zeile
                mulu    #160,d3         *Zeilenoffset
                add.l   d3,a1           *Bildschirmadresse
                move.l  a1,a0           *Nach a0 kopieren
                move.w  d1,d3           *d3 als ZÑhler

sd_j1:          move.l  (a0,d2.w),(a0)+ *Planes 0 und 1 kopieren
                move.l  (a0,d2.w),(a0)+ *Planes 2 und 3 kopieren
                dbra    d3,sd_j1        *Schleife fÅr Spalten

                move.w  d1,d3           *ZÑhler setzen
                sub.l   #160,a1         *NÑchste Zeile
                move.l  a1,a0           *Neuen Zeiger laden
                dbra    d0,sd_j1        *Schleife fÅr Zeilen

                movem.l (a7)+,d1-d3/a0-a1 *Register holen
                rts
