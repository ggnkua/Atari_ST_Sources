                EXPORT  form_button
                IMPORT  aes, intin, addrin

form_button:    move.l  A1,-(A7)                ;A1 sichern
                move.l  A0,addrin               ;tree
                movem.w D0-D2,intin             ;object, obnext, char
                move.l  #$38020201,D0
                bsr     aes
                move.l  (A7)+,A1                ;A1 zurÅckholen
                move.w  (A0)+,(A1)              ;nxtobject
                rts


