* Schnelle Linien-Routine fr horizontale Linen mit Muster.
* Monochrome-Version
* Geschriebem mit dem TurboAss V1.7.6
*
* (c) 1993 by Lucky of ST
*

                OPT X+

                move.w  #2,-(SP)
                trap    #14
                addq.l  #2,SP
                movea.l D0,A0

                lea     70*80(A0),A0
                move.l  #$AAAAAAAA,D7
                move.w  #3,D0
                move.w  #510,D1
                bsr.s   h_line

                clr.w   -(SP)
                trap    #1

* A0.l = Bildschirmadresse + y*80
* D0.w = Linker Punkt
* D1.w = Rechter Punkt
* D7.l = .w.w Muster

* Screen-Offset berechnen
h_line:         move.w  D0,D2
                and.w   #~15,D2
                sub.w   D2,D0
                sub.w   D2,D1
                ror.w   #3,D2
                adda.w  D2,A0

* D2 = Anzahl der Words zwischen den Punkten berechnen
                move.w  D1,D2
                and.w   #~15,D2
                sub.w   D0,D2
                and.w   #~15,D2
* Wenn Negativ, dann d0 und d1 im gleichen Word
                bmi.s   h_line_w0
                ror.w   #4,D2

* Linker Anfang zeichnen (falls vorhanden)
                tst.w   D0
                beq.s   h_line_w1
                add.w   D0,D0
                move.w  h_line_msk-*-2(PC,D0.w),D0
                and.w   D0,(A0)
                not.w   D0
                and.w   D7,D0
                or.w    D0,(A0)+
* Kein Linker Anfang:
h_line_w1:      btst    #0,D2
                beq.s   h_line_w2
                move.w  D7,(A0)+
                bclr    #0,D2
h_line_w2:      neg.w   D2
                jmp     h_line_j0(PC,D2.w)
                REPT 20
                move.l  D7,(A0)+
                ENDR
h_line_j0:

* Rechtes Ende Zeichnen (falls vorhanden)
                tst.w   D1
                beq.s   h_line_w3
                add.w   D1,D1
                move.w  h_line_msk-*(PC,D1.w),D1
                move.w  D1,D0
                not.w   D0
                and.w   D0,(A0)
                and.w   D7,D1
                or.w    D7,(A0)
h_line_w3:      rts

* Keine Words zwischen d0 und d1:
h_line_w0:      add.w   D0,D0
                add.w   D1,D1
                move.w  h_line_msk-*-2(PC,D0.w),D0
                move.w  h_line_msk-*(PC,D1.w),D1
                eor.w   D1,D0
                move.w  D0,D1
                not.w   D0
                and.w   D0,(A0)
                and.w   D7,D1
                or.w    D1,(A0)
                rts
pos             SET -1
h_line_msk:     REPT 640
                DC.W ~($8000>>pos-1)
pos             SET pos+1
                ENDR
                END
