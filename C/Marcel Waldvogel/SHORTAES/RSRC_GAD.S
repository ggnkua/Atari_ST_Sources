                EXPORT  rsrc_gaddr
                IMPORT  aes, contrl, intin, addrout

rsrc_gaddr:     movem.w D0/D1,intin             ;type, index
                move.l  A0,-(A7)                ;addr sichern
                move.l  #$70020100,D0
                bsr     aes
                move.l  (A7)+,A1                ;Adresse RÅckgabevariable
                move.l  addrout,(A1)            ;Adresse zurÅckschreiben
                rts


