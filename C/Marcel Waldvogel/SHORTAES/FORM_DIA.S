                EXPORT  form_dial
                IMPORT  aes, intin

form_dial:      lea     intin,A1
                move.w  D0,(A1)+                ;flag
                move.w  D1,(A1)+                ;littlx
                move.w  D2,(A1)+                ;littly
                lea     4(A7),A0                ;A0 in Stackframe
                move.l  (A0)+,(A1)+             ;littlw, littlh
                move.l  (A0)+,(A1)+             ;bigx, bigy
                move.l  (A0)+,(A1)+             ;bigw, bigh
                move.l  #$33090100,D0
                bra     aes

