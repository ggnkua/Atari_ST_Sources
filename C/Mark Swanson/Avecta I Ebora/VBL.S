
.globl _vbl
.globl _animate
.text
_vbl:   link R14,#-4
        move.l #1238,A2
        move.l #_animate,(A2)
        unlk R14
        rts

        
