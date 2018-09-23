 move.l 4(sp),a0
 move.l $20(a0),a1
 
 clr -(sp)
 pea buffer
 move #$47,-(sp)
 trap #1
 addq #8,sp

 move #7,-(sp)
 trap #1
 addq #2,sp

 clr -(sp)
 trap #1
 
 nop
 nop
 dc.b "@@@@"
buffer
 dcb 64,0
 dc.b "@@@@"
 