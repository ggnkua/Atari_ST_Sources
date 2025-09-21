                EXPORT  wind_update
                IMPORT  aes, intin

wind_update:    move.w  D0,intin
                move.l  #$6B010100,D0
                bra     aes


