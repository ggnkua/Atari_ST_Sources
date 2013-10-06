* Byte-Peek: wert=bpeek(adresse);

.text
.xdef _bpeek
_bpeek:         move.l  4(a7),adr
                pea     bsub
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                move.w  adr,d0
bpend:          rts

bsub:           movea.l adr,a0
                clr.w   d0
                move.b  (a0),d0
                move.w  d0,adr
                rts

.bss
adr:            ds.l    1
