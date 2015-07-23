hide_mouse          equ $a00a
show_mouse          equ $a009
cnecin    equ 8

          .DC.w hide_mouse
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          .DC.w show_mouse
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          trap      #1

          .END 

