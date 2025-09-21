                EXPORT  graf_mouse
                IMPORT  aes, intin, addrin

graf_mouse:     move.l  A0,addrin               ;faddr
                move.w  D0,intin                ;number
                move.l  #$4E010101,D0
                bra     aes


