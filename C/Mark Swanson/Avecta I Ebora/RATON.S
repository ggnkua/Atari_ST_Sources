

.globl _raton
.text
_raton:    link R14,#-4
           .dc.w $a000
           move.l 4(a0),a3
           move.l 8(a0),a4
           move.w #1,6(a3)
           move.w #0,2(a3)
           move.w #1,(a4)
           .dc.w $a009
           unlk R14
           rts
