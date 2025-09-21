                EXPORT  shel_get, shel_put
                IMPORT  aes, intin, addrin

shel_get:       move.l  #$7A010101,D2
                bra.b   shel_1ai1ii
shel_put:       move.l  #$7B010101,D2
shel_1ai1ii:    move.l  A0,addrin               ;addr
                move.w  D0,intin                ;len
                move.l  D2,D0
                bra     aes


