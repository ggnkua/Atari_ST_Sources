                EXPORT  appl_exit
                IMPORT  aes

appl_exit:      move.l  #$13000100,D0
                bra     aes


