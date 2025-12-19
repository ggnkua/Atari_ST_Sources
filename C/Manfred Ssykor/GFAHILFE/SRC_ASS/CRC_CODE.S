;
; Assemblieren mit MadMac: Kommandozeile -p
;
; oder mit Turboass als GFA-INLINE
;
                movea.l 4(SP),A0
                move.w  8(SP),D1
                clr.w   D0
                clr.w   D3
                bra.s   l1
loop0:          move.b  (A0)+,D3
                lsl.w   #8,D3
                eor.w   D3,D0

                moveq   #7,D2
loop1:          lsl.w   #1,D0
                bcc.s   .loop1
                eori.w  #$1021,D0
.loop1:         dbra    D2,loop1

l1:             dbra    D1,loop0
                rts
                END
; Das war's schon...
