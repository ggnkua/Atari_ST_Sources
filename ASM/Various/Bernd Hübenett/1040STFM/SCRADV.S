cnecin    equ 8
logbase   equ 3

start:    move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          movea.l   d0,a6
          move.w    #16000,d1
schleife: 
          move.w    d1,(a6)+
          dbf       d1,schleife
          move.w    #400,d3
loop:     movea.l   d0,a6
          lea.l     80(a6),a5
          move.w    #399,d1
scr:      move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          move.l    (a5)+,(a6)+
          dbf       d1,scr
          dbf       d3,loop
          move.w    #cnecin,-(sp)
          trap      #1
          addq.l    #2,sp
          clr.w     -(sp)
          trap      #1
          .END 

