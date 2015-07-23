; ------------------------------------------
; ------ C I R C L E  ( DC-MODE) -----------
; ------------------------------------------
; V 1.0: Direkte Umsetzung von Gfa-Basic
; V 2.0: 2 statt 4 Schleifen
; V 3.0: Statt fÅr jeden Punkt die Adresse
;        zu berechen werden jetzt Pointer
;        verwendet. 60% schneller.
; Parameter:
;            D0.L = X-Koordinate
;            D1.L = Y-Koordinate
;            D2.L = Radius
; ------------------------------------------

circle:         movem.l D0-D4,-(SP)

                movea.l buffscr,A1
                move.l  D0,D6
                lsl.l   #1,D6
                adda.l  D6,A1
                move.l  D1,D6
                mulu    #640,D6
                adda.l  D6,A1

                move.l  D2,D3           ; x& = r&        Zeile 30
                moveq   #0,D4           ; y& = 0         Zeile 28

                move.l  D2,D5           ; X-ZÑhler = Radius
                lsl.l   #1,D5           ; X-ZÑhler * 2
                move.l  D5,D1
                mulu    #320,D1
                movea.l D1,A2

                clr.l   D7              ; Y-ZÑhler initialisieren
                clr.l   D0
                movea.l D0,A3

                move.w  D3,D6
                lsl.w   #1,D6
                sub.w   D6,D2           ; Zeile 34

Zeile35:        movea.l A1,A0           ; Oktant 1
                adda.l  D7,A0
                adda.l  D5,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 3
                adda.l  D7,A0
                suba.l  D5,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 5
                suba.l  D5,A0
                suba.l  D7,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 7
                adda.l  D5,A0
                suba.l  D7,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 2
                adda.l  D0,A0
                adda.l  D1,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 4
                suba.l  A3,A0
                adda.l  A2,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 6
                suba.l  D0,A0
                suba.l  D1,A0
                move.w  #$FFFF,(A0)

                movea.l A1,A0           ; Oktant 8
                adda.l  A3,A0
                suba.l  A2,A0
                move.w  #$FFFF,(A0)

                move.w  D4,D6
                lsl.w   #1,D6
                addq.w  #1,D6
                add.w   D6,D2           ; Zeile 49

                addq.w  #1,D4           ; Zeile 50
                add.w   #640,D7
                addq.l  #2,D1
                addq.l  #2,A3

                cmp.w   #0,D2
                ble.s   Zeile54

                move.w  D3,D6
                lsl.w   #1,D6
                sub.w   #2,D6
                sub.w   D6,D2           ; Zeile 52

                subq.w  #1,D3           ; Zeile 53
                subq.w  #2,D5
                sub.l   #640,D0
                lea     -640(A2),A2     ; A2=A2-640

Zeile54:        cmp.w   D3,D4
                blt     Zeile35

circle_end:     movem.l (SP)+,D0-D4
                rts
