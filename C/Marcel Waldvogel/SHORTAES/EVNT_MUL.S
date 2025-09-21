                EXPORT  evnt_multi
                IMPORT  aes, addrin, intin

evnt_multi:     move.l  A0,addrin               ;mgpbuff
                lea     4(A7),A0                ;A0 zeigt in Stackframe
                move.l  A1,-(A7)                ;A1 Sichern
                lea     intin,A1
                move.w  D0,(A1)+                ;flags
                move.w  D1,(A1)+                ;bclicks
                move.w  D2,(A1)+                ;bmask
                move.l  (A0)+,(A1)+             ;bstate, m1flags
                move.l  (A0)+,(A1)+             ;m1x, m1y
                move.l  (A0)+,(A1)+             ;m1width, m1height
                move.l  (A0)+,(A1)+             ;m2flags, m2x
                move.l  (A0)+,(A1)+             ;m2y, m2width
                move.l  (A0)+,(A1)+             ;m2height, tlocount
                move.w  (A0)+,(A1)+             ;thicount
                move.l  #$19100701,D0
                bsr     aes
                move.l  (A7)+,A1                ;A1 zurÅckholen
                move.w  (A0)+,(A1)              ;mox

                move.l  A2,D2                   ;A2 sichern
                lea     4+13*2(A7),A2           ;A2 zeigt in Stackframe (ehem. A0)
                moveq   #4,D1                   ;noch 5 RÅckgabeparameter
eml:            move.l  (A2)+,A1                ;Hole Adresse der Variable
                move.w  (A0)+,(A1)              ;und schreibe intout[i] dorthin
                dbf     D1,eml
                move.l  D2,A2                   ;A2 zurÅckholen
                rts


