* Wort-Peek: wert=peek(adresse);

.text
.xdef _peek
_peek:          move.l  4(a7),adr
                pea     wsub
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                move.w  adr,d0
wpend:          rts

wsub:           movea.l adr,a0
                move.w  (a0),adr
                rts

.bss
adr:            ds.l    1
