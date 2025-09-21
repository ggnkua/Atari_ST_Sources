                EXPORT  menu_register
                IMPORT  aes, addrin, intin

menu_register:  move.w  D0,intin
                move.l  A0,addrin
                move.l  #$23010101,D0
                bra     aes


