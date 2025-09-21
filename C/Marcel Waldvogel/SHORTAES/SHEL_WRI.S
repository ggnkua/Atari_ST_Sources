                EXPORT  shel_write
                IMPORT  aes, intin, addrin

shel_write:     movem.w D0-D2,intin             ;doex, isgr, isover
                movem.l A0/A1,addrin            ;pcmd, ptail
                move.l  #$79030102,D0
                bra     aes


