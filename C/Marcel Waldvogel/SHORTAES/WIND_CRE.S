                EXPORT  wind_create, wind_open
                IMPORT  aes, intin

wind_create:    move.l  #$64050100,A0
                bra.b   wind_5ii
wind_open:      move.l  #$65050100,A0
wind_5ii:       lea     intin,A1                ;5 IntIn
                move.w  D0,(A1)+                ;kind bzw. handle
                move.w  D1,(A1)+                ;wx
                move.w  D2,(A1)+                ;wy
                move.l  4(A7),(A1)+             ;ww, wh
                move.l  A0,D0
                bra     aes

