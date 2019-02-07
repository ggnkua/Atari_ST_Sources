.globl _off
_off:   link R14,#-4
        move.l #1238,A2
        move.l #0,(A2)
        unlk R14
        rts

