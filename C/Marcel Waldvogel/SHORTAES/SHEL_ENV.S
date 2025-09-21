                EXPORT  shel_envrn
                IMPORT  aes, addrin

shel_envrn:     movem.l A0/A1,addrin
                move.l  #$7D000102,D0
                bra     aes


