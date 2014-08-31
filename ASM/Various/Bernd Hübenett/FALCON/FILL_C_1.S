; ------------------------------------------
; -- F I L L E D  C I R C L E  ( DC-MODE) --
; ------------------------------------------
; Parameter:
;            D0.L = X-Koordinate
;            D1.L = Y-Koordinate
;            D2.L = Radius
; ------------------------------------------

fill_circle:    movem.l D0-D4,-(SP)

                movea.l buffscr,A1
                lsl.l   #1,D0
                adda.l  D0,A1
                mulu    #640,D1
                adda.l  D1,A1

                move.l  D2,D3           ; x& = r&        Zeile 30
                moveq   #0,D4           ; y& = 0         Zeile 28

                move.l  D2,D5           ; X-Z„hler = Radius
                lsl.l   #1,D5           ; X-Z„hler * 2
                move.l  D5,D1
                mulu    #320,D1
                movea.l D1,A2

                move.l  #$FFFFFFFF,D1   ; Farbe

                clr.l   D7              ; Y-Z„hler initialisieren
                movea.l D7,A3           ; Y-Z„hler initialisieren

                move.w  D3,D6
                lsl.w   #1,D6
                sub.w   D6,D2           ; Zeile 34

fill_Zeile35:   movea.l A1,A0           ; Oktant 3
                adda.l  D7,A0
                suba.l  D5,A0
                move.l  D3,D0
filla:          move.l  D1,(A0)+
                dbra    D0,filla

                movea.l A1,A0           ; Oktant 5
                suba.l  D5,A0
                suba.l  D7,A0
                move.l  D3,D0
fillb:          move.l  D1,(A0)+
                dbra    D0,fillb

                movea.l A1,A0           ; Oktant 4
                suba.l  A3,A0
                adda.l  A2,A0
                move.l  D4,D0
fill4:          move.l  D1,(A0)+
                dbra    D0,fill4

                movea.l A1,A0           ; Oktant 6
                suba.l  A3,A0
                suba.l  A2,A0
                move.l  D4,D0
fill6:          move.l  D1,(A0)+
                dbra    D0,fill6

                move.w  D4,D6
                lsl.w   #1,D6
                addq.w  #1,D6
                add.w   D6,D2           ; Zeile 49

                addq.w  #1,D4           ; Zeile 50
                add.w   #640,D7         ; n„chste Zeile
                addq.l  #2,A3           ; n„chste Spalte

                tst.w   D2              ; D2 = 0  ??
                ble.s   fill_Zeile54

                move.w  D3,D6
                lsl.w   #1,D6
                subq.w  #2,D6
                sub.w   D6,D2           ; Zeile 52

                subq.w  #1,D3           ; Zeile 53
                subq.w  #2,D5
                lea     -640(A2),A2     ; A2=A2-640

fill_Zeile54:   cmp.w   D3,D4
                blt     fill_Zeile35

                movea.l A1,A0           ; Oktant 4
                suba.l  A3,A0
                adda.l  A2,A0
                move.l  D4,D0
fille:          move.l  D1,(A0)+
                dbra    D0,fille

                movea.l A1,A0           ; Oktant 6
                suba.l  A3,A0
                suba.l  A2,A0
                move.l  D4,D0
fillf:          move.l  D1,(A0)+
                dbra    D0,fillf

fill_circle_end:movem.l (SP)+,D0-D4
                rts
