                EXPORT  graf_movebox
                IMPORT  aes, intin

graf_movebox:   lea     intin,A1
                move.w  D0,(A1)+                ;width
                move.w  D1,(A1)+                ;height
                move.w  D2,(A1)+                ;sourcex
                lea     4(A7),A0
                move.l  (A0)+,(A1)+             ;sourcey, destx
                move.w  (A0)+,(A1)+             ;desty
                move.l  #$48060100,D0
                bra     aes


