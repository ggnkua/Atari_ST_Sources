   .globl setstack
   
setstack:
   move.l  0(sp),d0
   move.l  4(sp),sp
   move.l  d0,-(sp)
   rts
