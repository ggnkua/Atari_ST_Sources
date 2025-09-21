                EXPORT  form_keybd
                IMPORT  aes, intin, addrin

form_keybd:     move.l  A1,-(A7)                ;A1 sichern
                move.l  A0,addrin               ;tree
                movem.w D0-D2,intin             ;object, obnext, char
                move.l  #$37030301,D0
                bsr     aes
                move.l  (A7)+,A1                ;A1 zurÅckholen
                move.w  (A0)+,(A1)              ;nxtobject
                move.l  4(A7),A1
                move.w  (A0)+,(A1)              ;nxtchar
                rts


