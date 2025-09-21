                EXPORT  rsrc_load
                IMPORT  aes, addrin

rsrc_load:      move.l  A0,addrin               ;pfname
                move.l  #$6E000101,D0
                bra     aes


