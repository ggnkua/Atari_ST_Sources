                EXPORT  objc_edit
                IMPORT  aes, intin, addrin

objc_edit:      move.l  A1,-(A7)                ;A1 speichern
                lea     intin,A1
                move.l  A0,addrin               ;tree (u.U. relativ zu A1)
                move.w  D0,(A1)+                ;object
                move.w  D1,(A1)+                ;char
                move.l  (A7),A0                 ;gespeichertes A1 auslesen
                move.w  (A0),(A1)+              ;idx
                move.l  #$2E040201,D0
                bsr     aes
                move.l  (A7)+,A1                ;A1 zurÅckholen
                move.w  (A0)+,(A1)              ;idx
                rts


