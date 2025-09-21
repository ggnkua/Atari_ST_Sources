                EXPORT  scrp_read, scrp_write
                IMPORT  aes, addrin

scrp_read:      move.l  #$50000101,D0
                bra.b   scrp_1ai
scrp_write:     move.l  #$51000101,D0
scrp_1ai:       move.l  A0,addrin
                bra     aes


