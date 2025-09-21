                EXPORT  graf_slidebox
                IMPORT  aes, intin, addrin

graf_slidebox:  move.l  A0,addrin               ;ptree
                movem.w D0-D2,intin
                move.l  #$4C030101,D0
                bra     aes


