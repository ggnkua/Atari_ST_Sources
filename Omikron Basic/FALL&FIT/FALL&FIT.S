
; 4(SP)         TABELLE
; 8(SP)         'Zeichensatz'
; 12(SP)        Ziel-Adresse
; 16(SP)        Breite in 'Zeichen'
; 18(SP)        Hîhe in 'Zeichen'

                movem.l (SP),D7-A3
                move.l  A3,D7
                subq.w  #1,D7

                move.l  D7,D0
                swap    D0
                mulu    D7,D0
                adda.l  D0,A0
                move.w  #1280,D0
                mulu    D7,D0
                adda.l  D0,A2
                lea     buffer(PC),A3
                moveq   #0,D0
                move.l  D0,(A3)+        ;40 Bytes dÅrften reichen
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                move.l  D0,(A3)+
                moveq   #0,D4

; A0            Quelle
; A1            Umsetzungstabelle
; A2            Ziel
; A3            Merk-Buffer fÅr Schatten
; D7 H          Breite
; D7            Y-ZÑhler
; D6            X-ZÑhler
; D5            Merker fÅr Schatten
; D4            Offset in chartab       (0, 32, 64, 96: Rand;
;                                        128, 132,... 252: Klîtze)

m1:             swap    D7
                move.w  D7,D6
                subq.w  #1,D6
                lea     buffer(PC),A3
                moveq   #0,D5
m2:             move.b  (A0)+,D4
                bmi.s   m3
                add.b   (A3),D4         ;Schatten einsetzen
                add.b   D5,D4
                add.b   D5,D4
                move.b  D5,(A3)+
                moveq   #0,D5
                bra.s   m4
m3:             addq.w  #4,D5           ;keinen Schatten einsetzen
                move.b  D5,(A3)+
                moveq   #8,D5
m4:             movea.l 0(A1,D4.l),A4   ;Zeichen ausgeben

                move.w  (A4)+,(A2)+
                move.w  (A4)+,78(A2)
                move.w  (A4)+,158(A2)
                move.w  (A4)+,238(A2)
                move.w  (A4)+,318(A2)
                move.w  (A4)+,398(A2)
                move.w  (A4)+,478(A2)
                move.w  (A4)+,558(A2)
                move.w  (A4)+,638(A2)
                move.w  (A4)+,718(A2)
                move.w  (A4)+,798(A2)
                move.w  (A4)+,878(A2)
                move.w  (A4)+,958(A2)
                move.w  (A4)+,1038(A2)
                move.w  (A4)+,1118(A2)
                move.w  (A4)+,1198(A2)

                dbra    D6,m2
                suba.w  D7,A2
                suba.w  D7,A2
                suba.w  D7,A0
                suba.w  D7,A0
                suba.w  #1280,A2
                swap    D7
                dbra    D7,m1
                rts

buffer:         DS.B 42
