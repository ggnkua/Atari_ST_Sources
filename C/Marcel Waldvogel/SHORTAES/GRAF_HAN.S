                EXPORT  graf_handle, graf_mkstate
                IMPORT  aes

graf_handle:    move.l  #$4D000500,D0
                bra.b   graf_4io
graf_mkstate:   move.l  #$4F000500,D0
graf_4io:       move.l  A1,-(A7)                ;A1 sichern
                move.l  A0,-(A7)                ;A0 sichern
                bsr     aes
                move.l  (A7)+,A1                ;altes A0 zurÅckholen
                move.w  (A0)+,(A1)              ;und intout[1] speichern
                move.l  (A7)+,A1                ;A1
                move.w  (A0)+,(A1)              ;intout[2]
                move.l  4(A7),A1
                move.w  (A0)+,(A1)
                move.l  8(A7),A1
                move.w  (A0)+,(A1)
                rts


