

.globl _rausmaus
.text
_rausmaus: link R14,#-4
           .dc.w $a000
           .dc.w $a00a
           unlk R14
           rts
