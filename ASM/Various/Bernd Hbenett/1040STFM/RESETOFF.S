reset_pc  equ $4
swv_vec   equ $46e

          .TEXT 
          pea       mod_swv(pc)
          move.w    #$26,-(sp)
          trap      #14
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1
mod_swv:  movea.l   reset_pc,a3
          move.w    #$4e75,d3
search:   cmp.w     (a3)+,d3
          bne.s     search
          subq.l    #2,a3
          move.l    a3,swv_vec
          rts       
          .END 

