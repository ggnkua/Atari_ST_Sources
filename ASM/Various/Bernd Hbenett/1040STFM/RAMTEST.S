super     equ 32
cnecin    equ 8
logbase   equ 3


start:    move.w    #logbase,-(sp)
          trap      #14
          addq.l    #2,sp
          move.l    d0,scr
          addi.l    #32000,d0
          move.l    d0,end_adr

          pea       0
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          move.l    d0,ssp
          move.l    #memory+256,d0
          andi.l    #$ffffff00,d0

          move.w    #-1,-(sp)
          move.l    d0,-(sp)
          move.l    d0,-(sp)
          move.w    #5,-(sp)
          trap      #14
          lea.l     $c(sp),sp

          movea.l   end_adr,a0
          movea.l   #anf_adr,a1
          move.l    #0,d0
go_on:    move.l    (a1)+,d1
          cmpa.l    a1,a0
          beq.s     out
          ;       cmp.l     d0,d1
          ;      beq       go_on
          ;     bsr       error
          jmp       go_on

out:      move.l    scr,d0
          move.w    #-1,-(sp)
          move.l    d0,-(sp)
          move.l    d0,-(sp)
          move.w    #5,-(sp)
          trap      #14
          lea.l     $c(sp),sp
          move.l    ssp,-(sp)
          move.w    #super,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1

error:    movem.l   d1-d7/a0-a6,savereg
          move.l    a1,d0
          subi.l    #4,d0
          move.w    #28,d3
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
          clr.l     d0
          movem.l   savereg,d1-d7/a0-a6
          rts       

          .DATA 
ziffern:  .DC.b '0123456789ABCDEF'
          .BSS 
savereg:  .DS.l 20
ssp:      .DS.l 1
end_adr:  .DS.l 1
scr:      .DS.l 1
memory:   .DS.b 32256
anf_adr:  .DS.l 1
          .END 

