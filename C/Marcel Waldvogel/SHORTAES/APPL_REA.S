                EXPORT  appl_read
                IMPORT  aes, intin, addrin

appl_read:	movem.w D0-D1,intin
                move.l  A0,addrin
                move.l  #$0D020101,D0
                bra     aes


