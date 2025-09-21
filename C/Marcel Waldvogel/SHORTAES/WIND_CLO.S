                EXPORT  wind_close, wind_delete
                IMPORT  aes, intin

wind_close:     move.l  #$66050100,A0
                bra.b   wind_1ii
wind_delete:    move.l  #$67050100,A0
wind_1ii:       move.w  D0,intin                ;1 IntIn: handle
                move.l  A0,D0
                bra     aes

