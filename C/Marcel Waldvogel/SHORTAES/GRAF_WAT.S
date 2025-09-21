                EXPORT  graf_watchbox
                IMPORT  aes, intin, addrin

graf_watchbox:  move.l  A0,addrin               ;ptree
                movem.w D0-D2,intin+2           ;intin[0] ð reserved
                move.l  #$4B040101,D0
                bra     aes


