                EXPORT  shel_read
                IMPORT  aes, addrin

shel_read:      movem.l A0/A1,addrin            ;pcmd, ptail
                move.l  #$78000102,D0
                bra     aes


