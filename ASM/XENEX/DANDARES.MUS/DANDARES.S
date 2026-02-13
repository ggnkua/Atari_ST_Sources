anf:
          move.w    #0,-(sp)
          pea       fname(pc)
          move.w    #$3d,-(sp)
          trap      #1
          addq.l    #8,sp
          move.w    d0,-(sp)

          pea       buffer(pc)
          move.l    #100000,-(sp)
          move.w    d0,-(sp)
          move.w    #$3f,-(sp)
          trap      #1
          lea       $0c(sp),sp

          move.w    #$3e,-(sp)
          trap      #1
          addq.l    #4,sp

          clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp

          move.b    $0484.w,old484
          move.b    #0,$0484.w
          move.b    $ffff820a.w,sync
          bset      #1,$ffff820a.w

          pea       text(pc)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          moveq     #0,d0
          bsr       buffer

          move.l    $04d6.w,oldvbl
          move.l    #buffer+$0e,$04d6.w

zeichen:  move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp
          cmp.b     #' ',d0
          beq.s     ende
          sub.b     #'1',d0
          bmi.s     zeichen
          cmp.b     #2,d0
          bgt.s     zeichen
          bsr       buffer
          bra.s     zeichen
ende:
          move.l    oldvbl(pc),$04d6.w
          move.b    sync(pc),$ffff820a.w
          move.b    old484(pc),$0484.w

          pea       pling(pc)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          clr.w     -(sp)
          trap      #1

          DATA
fname:    DC.B "DANDARES.DAT",0
text:     DC.B 27,"EDAN DARES III Musix",13,10
          DC.B "by David Whittaker",13,10
          DC.B "Ripped by TITAN",13,10
          DC.B "of XENEX on 07/25/90.",13,10
          DC.B "Try keys 1-3.",13,10,0
          EVEN
pling:    DC.B 7,0

          BSS
old484:   DS.B 1
sync:     DS.B 1
oldvbl:   DS.L 1
buffer:   DS.W 65535/2
          END
