.globl _ini_linea
.globl    _textblt

.text
_ini_linea:
     dc.w $a000     hole basis adresse der linea parameter
     movea.l   4(sp),a0
     move.l    a1,(a0)
     rts            initialisierung gibts im d0 zurueck

_textblt:
     dc.w $a008
     rts

     end

