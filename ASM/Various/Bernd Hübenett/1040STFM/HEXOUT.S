

start:    move.l    $118,d0
          bsr       printhex
          move.w    #8,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          trap      #1

printhex: move.w    #28,d3
          move.l    d0,d1
h_loop:   move.l    d1,d2
          lsr.l     d3,d2
          andi.w    #$f,d2
          lea.l     ziffern,a0
          move.b    0(a0,d2.w),d2
          move.w    d2,-(sp)
          move.w    #2,-(sp)
          trap      #1
          addq.l    #4,sp
          subq.w    #4,d3
          bpl       h_loop
          rts       

          .DATA 
ziffern:  .DC.b '0123456789ABCDEF'
          .BSS 
          .END 

