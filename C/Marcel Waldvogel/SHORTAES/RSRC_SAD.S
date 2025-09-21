                EXPORT  rsrc_saddr
                IMPORT  aes, intin, addrin

rsrc_saddr:     move.l  A0,addrin               ;addr
                movem.w D0/D1,intin             ;type, index
                move.l  #$71020101,D0
                bra     aes


