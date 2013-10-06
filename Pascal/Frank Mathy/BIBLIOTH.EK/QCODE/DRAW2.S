* Plot-Routine fÅr C/Pascal
* Aufruf: fplot(x,y,farbe,logbase,clipping)

.text
.xdef _fplot
_fplot:         movem.l d0-d3/a0-a1,-(a7) *Register retten
                movea.l 34(a7),a0       *Zeiger auf Logbase
                movea.l 38(a7),a1       *Zeiger auf Clipping-Feld
                move.w  28(a7),d0       *x laden
                move.w  30(a7),d1       *y laden
                move.w  32(a7),d3       *Farbe in d3
                bsr.s   fp_main         *Hauptteil aufrufen
                movem.l (a7)+,d0-d3/a0-a1 *Register holen
                rts                     *Ende

fp_main:        cmp.w   0(a1),d0        *x >= clip_x1 ?
                blt.s   fp_end          *Nein --> Ende
                cmp.w   4(a1),d0        *x <= clip_x2 ?
                bgt.s   fp_end          *Nein --> Ende
                cmp.w   2(a1),d1        *y >= clip_y1 ?
                blt.s   fp_end          *Nein --> Ende
                cmp.w   6(a1),d1        *y <= clip_y2 ?
                bgt.s   fp_end          *Nein --> Ende

                move.w  d0,d2           *x in d2 kopieren
                mulu    #160,d1         *y_Zeile mal 160
                adda.l  d1,a0           *y_Offset hinzuaddieren
                and.l   #$ff0,d0        *Bits 0-3 ausblenden
                lsr.l   #1,d0           *durch 2
                adda.l  d0,a0           *x_Offset hinzuaddieren
                and.w   #$f,d2          *Pixelnummer isolieren
                eor.w   #$f,d2          *Invertieren
                clr.w   d1              *ZÑhler lîschen

fp_j2:          move.w  (a0),d0         *Wort aus Bildspeicher laden
                btst    d1,d3           *Test auf Farbbit
                bne.s   fp_j3           *Gesetzt --> Weiter
                bclr    d2,d0           *Bit lîschen
                bra.s   fp_j4           *Weiter
fp_j3:          bset    d2,d0           *Bit setzen
fp_j4:          move.w  d0,(a0)+        *Wort in Bildspeicher schreiben
                addq.w  #1,d1           *ZÑhler erhîhen
                cmp.w   #4,d1           *ZÑhler == 4 ?
                bne.s   fp_j2           *Nein --> ZurÅck
fp_end:         rts                     *Ende


* Kreis/Circle-Routine fÅr C/Pascal
* Aufruf: fcircle(x0,y0,r,farbe,logbase,clipping)

.text
.xdef _fcircle
_fcircle:       movem.l d0-d6/a0-a1,-(a7)
                tst.w   44(a7)          *Radius testen
                beq     fc_j3           *r == 0 --> Ende
                move.w  46(a7),d3       *Farbe
                move.l  52(a7),a1       *Clipping
                clr.w   d4              *x-Startwert = 0
                move.w  44(a7),d5       *y-Startwert = Radius
                bpl.s   fc_j0           *r > 0 --> Weiter
                neg.w   d5              *Negieren
fc_j0:          move.w  d5,d6           *ZÑhler
                subq.w  #1,d6           *ZÑhler-1

fc_j1:          tst.w   d6              *Teste ZÑhler
                bpl.s   fc_j2           *Positiv --> Weiter
                subq.w  #1,d5           *y_Wert erniedrigen
                add.w   d5,d6           *ZÑhler + y_Wert
                add.w   d5,d6           *ZÑhler + y_Wert

fc_j2:          move.w  40(a7),d0       *x_Koordinate
                add.w   d4,d0           *x_Wert addieren
                move.w  42(a7),d1       *y_Koordinate
                add.w   d5,d1           *y_Wert addieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 1 setzen

                move.w  40(a7),d0       *x_Koordinate
                sub.w   d4,d0           *x_Wert subtrahieren
                move.w  42(a7),d1       *y_Koordinate
                add.w   d5,d1           *y_Wert addieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 2 setzen

                move.w  40(a7),d0       *x_Koordinate
                add.w   d4,d0           *x_Wert addieren
                move.w  42(a7),d1       *y_Koordinate
                sub.w   d5,d1           *y_Wert subtrahieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 3 setzen

                move.w  40(a7),d0       *x_Koordinate
                sub.w   d4,d0           *x_Wert subtrahieren
                move.w  42(a7),d1       *y_Koordinate
                sub.w   d5,d1           *y_Wert subtrahieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 4 setzen

                move.w  40(a7),d0       *x_Koordinate
                add.w   d5,d0           *y_Wert addieren
                move.w  42(a7),d1       *y_Koordinate
                add.w   d4,d1           *x_Wert addieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 5 setzen

                move.w  40(a7),d0       *x_Koordinate
                sub.w   d5,d0           *y_Wert subtrahieren
                move.w  42(a7),d1       *y_Koordinate
                add.w   d4,d1           *x_Wert addieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 6 setzen

                move.w  40(a7),d0       *x_Koordinate
                add.w   d5,d0           *y_Wert addieren
                move.w  42(a7),d1       *y_Koordinate
                sub.w   d4,d1           *x_Wert subtrahieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 7 setzen

                move.w  40(a7),d0       *x_Koordinate
                sub.w   d5,d0           *y_Wert subtrahieren
                move.w  42(a7),d1       *y_Koordinate
                sub.w   d4,d1           *x_Wert subtrahieren
                movea.l 48(a7),a0       *Logbase
                bsr     fp_main         *Punkt 8 setzen

                sub.w   d4,d6           *ZÑhler - x_Wert
                sub.w   d4,d6           *ZÑhler - x_Wert
                subq.w  #1,d6           *ZÑhler - 1
                addq.w  #1,d4           *x_Wert + 1
                cmp.w   d5,d4           *x_Wert <= y_Wert ?
                ble     fc_j1           *Ja --> ZurÅck

fc_j3:          movem.l (a7)+,d0-d6/a0-a1 *Register zurÅckholen
fc_end:         rts                     *RÅckkehr
