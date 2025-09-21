                EXPORT  menu_icheck, menu_ienable, menu_tnormal
                IMPORT  aes, addrin, intin

menu_icheck:    move.l  #$1F020101,D2
                bra.b   menu_1ai2ii
menu_ienable:   move.l  #$20020101,D2
                bra.b   menu_1ai2ii
menu_tnormal:   move.l  #$21020101,D2
menu_1ai2ii:    move.l  A0,addrin               ;1 AddrIn, 2 IntIn
                movem.w D0-D1,intin
                move.l  D2,D0
                bra     aes

