                EXPORT  evnt_mesag
                IMPORT  aes, addrin

evnt_mesag:     move.l  A0,addrin
                move.l  #$17000101,D0
                bra     aes


