                EXPORT  menu_bar
                IMPORT  aes, addrin, intin

menu_bar:       move.l  A0,addrin
                move.w  D0,intin
                move.l  #$1E010101,D0
                bra     aes


