                EXPORT  shel_find
                IMPORT  aes, addrin

shel_find:      move.l  A0,addrin               ;pbuff
                move.l  #$7C000101,D0
                bra     aes


