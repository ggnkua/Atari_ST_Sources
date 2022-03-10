
macro   clc                             ; clear carry
        and     #$fe,ccr
endm

*-----------------------------------------------------------------------*
*-----------------------------------------------------------------------*
        XDEF    swaplong
swaplong:
        clc
        ror.w   #8,d0
        clc
        swap    d0
        ror.w   #8,d0
        rts

