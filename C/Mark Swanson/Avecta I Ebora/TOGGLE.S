          .globl _toggle
.text   
_toggle: link R14,#-4
         clr.l R0
         clr.l R1
         clr.l R2
         move.w 8(R14),R0
         move.w 10(R14),R1
         move.l 12(R14),R8
         mulu #2560,R1
         mulu #8,R0
         add.l R0,R1   
         add.l R1,R8
         clr.l R5
         move.w #15,R5
it:      move.l R8,R9
top:     move.w (R9),R4
         not R4
         move.w R4,(R9)
         move.w 2(R9),R4
         not R4
         move.w R4,2(R9)
         move.w 4(R9),R4
         not R4
         move.w R4,4(R9)
         move.w 6(R9),R4
         not R4
         move.w R4,6(R9)
         addq #8,R9 
         dbf R3,top
         add #160,R8
         dbf R5,it
         unlk R14
         rts
