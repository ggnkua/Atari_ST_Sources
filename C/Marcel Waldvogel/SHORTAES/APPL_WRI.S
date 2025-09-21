                EXPORT  appl_write
                IMPORT  aes, intin, addrin

appl_write:     movem.w D0-D1,intin
                move.l  A0,addrin
                move.l  #$0C020101,D0
                bra     aes


