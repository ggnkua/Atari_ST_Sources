                EXPORT  rsrc_obfix
                IMPORT  aes, intin, addrin

rsrc_obfix:     move.l  A0,addrin               ;tree
                move.w  D0,intin                ;object
                move.l  #$72010101,D0
                bra     aes


