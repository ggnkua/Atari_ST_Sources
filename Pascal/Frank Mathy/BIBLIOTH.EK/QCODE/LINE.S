* Line C/pascal-Routine
* Aufruf: fline(x1,y1,x2,y2,farbe,logbase,clipping)

.text
.xdef _fline
_fline:         movem.l d0-d7/a0-a1,-(a7)
                movem.l 54(a7),a0-a1    *Adreûregister laden
                movem.w 44(a7),d0-d3    *x1, y1, x2 und y2 laden
                cmp.w   d0,d2           *x1 <= x2 ?
                bge.s   fl_j1           *Ja --> Weiter
                exg     d0,d2           *x1 <--> x2
                exg     d1,d3           *y1 <--> y2
                movem.w d0-d3,44(a7)    *Zwischenspeichern
fl_j1:          sub.w   d0,d2           *delta_x == x2 - x1
                sub.w   d1,d3           *delta_y == y2 - y1
                bmi.s   fl_j2           *Negativ --> Weiter
                move.w  #1,d6           *Y-Additionswert (Koordinate)
                move.l  #160,d7         *Y-Additionswert (Bildschirmspeicher)
                bra.s   fl_j3           *Weiter
fl_j2:          neg.w   d3              *Delta_y negieren
                move.w  #-1,d6          *Y-Additionswert (Koordinate)
                move.l  #-160,d7        *Y-Additionswert (Bildschirmspeicher)
fl_j3:          clr.w   d4              *ZÑhler lîschen
                move.w  d1,d5           *y_Koordinate
                muls    #160,d5         *y_Offset
                adda.l  d5,a0           *Logbase + y_Offset
                move.w  d0,d5           *x_Koordinate
                and.l   #$fff0,d5       *Bits 0-3 lîschen
                asr.w   #1,d5           *d5/2
                adda.l  d5,a0           *Logbase + x_Offset
                move.w  d0,d5           *x_Koordinate
                and.w   #$f,d5          *Bitnummer ermitteln
                eor.w   #$f,d5          *Umkehren
                add.w   d2,d4           *ZÑhler+Delta_x
                sub.w   d3,d4           *ZÑhler-Delta_y

fl_j4:          cmp.w   0(a1),d0        *x1 >= Clipping_x1 ?
                ble.s   fl_j8           *Nein --> Weiter
                cmp.w   4(a1),d0        *x1 <= Clipping_x2 ?
                bge.s   fl_j8           *Nein --> Weiter
                cmp.w   2(a1),d1        *y1 >= Clipping_y1 ?
                ble.s   fl_j8           *Nein --> Weiter
                cmp.w   6(a1),d1        *y1 <= Clipping_y1 ?
                bge.s   fl_j8           *Nein --> Weiter

                movem.w d2-d4,-(a7)     *Register retten
                clr.w   d2              *ZÑhler
                move.w  58(a7),d3       *Farbe
fl_j5:          move.w  0(a0,d2.w),d4   *Wort laden
                lsr.b   #1,d3           *Farbbit gesetzt?
                bcs.s   fl_j6           *Ja --> Weiter
                bclr    d5,d4           *Bit lîschen
                bra.s   fl_j7           *Weiter
fl_j6:          bset    d5,d4           *Bit setzen
fl_j7:          move.w  d4,0(a0,d2.w)   *Wort zurÅckschreiben
                addq.w  #2,d2           *ZÑhler erhîhen
                cmp.w   #8,d2           *ZÑhler = 8 ?
                bne.s   fl_j5           *Nein --> ZurÅck
                movem.w (a7)+,d2-d4     *Register zurÅckholen

fl_j8:          cmp.w   48(a7),d0       *x1 = x2 ?
                bne.s   fl_j9           *Nein --> Weiter
                cmp.w   50(a7),d1       *y1 = y2 ?
                bne.s   fl_j9           *Nein --> Weiter

                movem.l (a7)+,d0-d7/a0-a1 *Register zurÅckholen
                rts                     *RÅckkehr

fl_j9:          tst.w   d4              *ZÑhler testen
                bmi.s   fl_j11          *Negativ --> Weiter

                sub.w   d3,d4           *ZÑhler - Delta_y
                addq.w  #1,d0           *x1 erhîhen
                subq.w  #1,d5           *BitzÑhler erniedrigen
                bpl.s   fl_j10          *Positiv --> Weiter

                move.w  #15,d5          *d5 lîschen
                addq.l  #8,a0           *Zeiger erhîhen
fl_j10:         bra     fl_j4           *ZurÅck in die Schleife

fl_j11:         add.w   d2,d4           *ZÑhler + Delta_x
                add.w   d6,d1           *y1 + y_Additionswert
                adda.l  d7,a0           *Zeiger verÑndern
                bra     fl_j4           *ZurÅck in die Schleife
