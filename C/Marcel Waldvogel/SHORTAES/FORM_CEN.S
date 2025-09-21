                EXPORT  form_center
                IMPORT  aes, intin, addrin

form_center:    move.l  A0,addrin               ;tree
                move.l  A1,-(A7)                ;A1 speichern
                move.l  #$36000501,D0
                bsr     aes
                move.l  (A7)+,A1                ;A1 zurÅckholen
                move.w  (A0)+,(A1)              ;x

                move.l  A2,D2                   ;A2 sichern
                lea     4(A7),A2                ;A2 zeigt in Stackframe
                move.l  (A2)+,A1
                move.w  (A0)+,(A1)              ;y
                move.l  (A2)+,A1
                move.w  (A0)+,(A1)              ;w
                move.l  (A2)+,A1
                move.w  (A0)+,(A1)              ;h
                move.l  D2,A2                   ;A2 zurÅckholen
                rts


