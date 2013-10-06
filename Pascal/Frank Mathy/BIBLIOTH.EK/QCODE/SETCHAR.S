* Setzen eines 16xn-Pixel hohen Zeichens
* Selbes Format wie das Sprite
* x-Koordinate in Wortform (0 bis 19)
* y-Koordinate in Pixelform (0 bis 199)
* Hîhe in n-1 Pixeln (0 bis 199)
* Clipping in Wort(x)/Pixel(y)-Form (0-19,0-199,0-19,0-199)
* Style: 0 = replace ; 1 = or

* Aufruf: fsetchar(x,y,height,data,logbase,clipping,style)

.text
.xdef _fsetchar
_fsetchar:      movem.l d1-d3/a0-a2,-(a7) *Register retten

                movea.l 42(a7),a1       *Clipping laden
                move.w  28(a7),d0       *x-Koordinate laden
                move.w  30(a7),d1       *y-Koordinate laden
                cmp.w   0(a1),d0        *x < clip_x1 ?
                blt     sch_exit        *Ja --> Abbruch
                cmp.w   4(a1),d0        *x > clip_x2 ?
                bgt     sch_exit        *Ja --> Abbruch
                cmp.w   6(a1),d1        *y > clip_y2
                bgt     sch_exit        *Ja --> Abbruch

                asl.w   #3,d0           *x mal 8
                ext.l   d0              *In Langwort
                mulu    #160,d1         *y_Offset berechnen
                movea.l 38(a7),a0       *Logbase laden
                movea.l 34(a7),a2       *Zeiger auf Daten
                adda.l  d0,a0           *x_Offset hinzu
                adda.l  d1,a0           *y_Offset hinzu
                move.w  30(a7),d1       *y laden
                move.w  32(a7),d0       *ZÑhler fÅr Hîhe

sch_j1:         cmp.w   2(a1),d1        *y >= clip_y1 ?
                bge.s   sch_j2          *Ja --> Weiter
                adda.l  #10,a2          *Datenzeiger erhîhen
                adda.l  #160,a0         *Screen-Zeiger erh.
                dbra    d0,sch_j1       *ZurÅck
                bra.s   sch_exit        *Abbruch

sch_j2:         tst.w   46(a7)          *Welcher Stil ?
                bne.s   sch_j4          *Or --> weiter

sch_j3:         cmp.w   6(a1),d1        *y == clip_y2 ?
                bge.s   sch_exit        *Ja --> Abbruch

                move.l  (a2)+,(a0)      *Daten auf Schirm bringen
                move.l  (a2)+,4(a0)

                addq.l  #2,a2           *Maskenwort Åberspringen
                adda.l  #160,a0         *NÑchste Zeile
                subq.w  #1,d1           *y erhîhen
                dbra    d0,sch_j3       *Schleife
                bra.s   sch_exit        *Ende

sch_j4:         cmp.w   6(a1),d1        *y == clip_y2 ?
                bge.s   sch_exit        *Ja --> Abbruch

                move.w  8(a2),d2        *Maskenwort holen
                swap    d2              *In High-Wort
                move.w  8(a2),d2        *Maskenwort holen
                not.l   d2              *Invertieren

                and.l   d2,(a0)         *Bild AND-verknÅpfen
                move.l  (a2)+,d3        *Daten laden
                or.l    d3,(a0)         *Daten setzen
                and.l   d2,4(a0)        *Bild AND-verknÅpfen
                move.l  (a2)+,d3        *Daten laden
                or.l    d3,4(a0)        *Daten setzen

                addq.l  #2,a2           *Maskenwort Åberspringen
                adda.l  #160,a0         *NÑchste Zeile
                subq.w  #1,d1           *y erhîhen
                dbra    d0,sch_j4       *Schleife

sch_exit:       movem.l (a7)+,d1-d3/a0-a2 *Register holen
                rts
