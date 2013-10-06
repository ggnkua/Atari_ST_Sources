* Langwort-Peek: wert=lpeek(adresse);

.text
.xdef _lpeek
_peek:          move.l  4(a7),adr
                pea     lsub
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                move.l  adr,d0
                rts

lsub:           movea.l adr,a0
                move.l  (a0),adr
                rts

.bss
adr:            ds.l    1
