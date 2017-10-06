start:    
          movea.l   4(sp),a5
          move.l    12(a5),d0
          add.l     20(a5),d0
          add.l     28(a5),d0
          addi.l    #$1100,d0
          move.l    a5,d1
          add.l     d0,d1
          andi.l    #-2,d1
          movea.l   d1,sp
          move.l    d0,-(sp)
          move.l    a5,-(sp)
          clr.w     -(sp)
          move.w    #$4a,-(sp)
          trap      #1
          adda.l    #12,sp
init:     move.w    #10,contrl
          clr.w     contrl+2
          move.w    #1,contrl+4
          clr.w     contrl+6
          clr.w     contrl+8
          bsr       aes
          move.w    #77,contrl
          clr.w     contrl+2
          move.w    #5,contrl+4
          clr.w     contrl+6
          clr.w     contrl+8
          bsr       aes
          move.w    intout,handle
          move.w    #100,contrl
          clr.w     contrl+2
          clr.w     contrl+4
          move.w    #11,contrl+6
          clr.w     contrl+8
          move.w    handle,contrl+12
          lea.l     intin,a0
          move.w    #9,d0
initloop: move.w    #1,(a0)+
          dbra      d0,loop
          move.w    #2,(a0)
          bsr       vdi
loop:     move.w    #52,contrl
          move.w    #1,contrl+2
          move.w    #1,contrl+4
          move.w    #1,contrl+6
          clr.w     contrl+8
          move.w    #1,intin
          move.l    #alert,addrin
          jsr       aes
          move.w    intout,d0
          cmpi.w    #1,d0
          beq.s     loop
          clr.w     -(sp)
          trap      #1
aes:      move.l    #aespara,d1
          move.w    #$c8,d0
          trap      #2
          rts       
vdi:      move.l    #vdipara,d1
          move.w    #$73,d0
          trap      #2
          rts       
          .DATA 













