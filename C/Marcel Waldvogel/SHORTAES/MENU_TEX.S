                EXPORT  menu_text
                IMPORT  aes, addrin, intin

menu_text:      movem.l A0-A1,addrin
                move.w  D0,intin
                move.l  #$22010102,D0
                bra     aes


