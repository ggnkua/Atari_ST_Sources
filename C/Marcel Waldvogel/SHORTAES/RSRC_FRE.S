                EXPORT  rsrc_free
                IMPORT  aes

rsrc_free:      move.l  #$6F000100,D0
                bra     aes


