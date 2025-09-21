                EXPORT  evnt_keybd
                IMPORT  aes

evnt_keybd:     move.l  #$14000100,D0
                bra     aes


