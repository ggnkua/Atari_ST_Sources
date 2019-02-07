

.globl _spellfx
.text
.globl _zline
_spellfx:  link R14,#-4
           move.l 8(R14),R8
           move.l #8000,R0
           move.w #4,R1
           move.l R8,R9
again:     move.l (R8),R3
           cmp #0,R3
           beq next
           not R3
           move.l R3,(R8)
next:      addq #4,R8
           subq #1,R0
           cmp #0,R0
           bne again
           move.l #8000,R0
           move.l R9,R8
           subq #1,R1
           cmp #0,R1
           bne again
           unlk R14
           rts
