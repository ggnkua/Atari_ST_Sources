.text
.xdef _sbeg
_sbeg:          move.l  4(a7),d0        *Adresse laden
                addq.l  #1,d0
s_exit:         rts

