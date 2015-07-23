
          move.w    #3,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a0
          move.l    d0,d1
          move.l    #1,(a0)
          adda.l    #160,a0
          move.l    #%00000000000000000000000000000001,(a0)
          lea.l     160(a0),a0
          move.l    #%10000000000000000000000000000000,(a0)
          lea.l     160(a0),a0
          bset      #31,(a0)
          lea.l     160(a0),a0
          bset      #0,(a0)
          movea.l   d1,a0
          move.l    #8000,d0
loop:     move.l    #0,(a0)+
          dbf       d0,loop
          move.w    #8,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          trap      #1

