                EXPORT  form_do, form_alert
                IMPORT  aes, intin, addrin

form_do:        move.l  #$32010101,D2
                bra.b   form_1ai1ii
form_alert:     move.l  #$34010101,D2
form_1ai1ii:    move.l  A0,addrin               ;1 AddrIn, 1 IntIn
                move.w  D0,intin
                move.l  D2,D0
                bra     aes


