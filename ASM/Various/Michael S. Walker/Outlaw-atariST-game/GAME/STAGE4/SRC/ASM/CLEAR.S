        xdef       _ClearScreen

_ClearScreen:
base equ 64
  movem.l    d0-7/a0-6,-(sp)
  movea.l    base(sp),a0
  add.l      #160*200,a0          ; end of screen.
  moveq      #0,d0		
  moveq      #0,d1
  moveq      #0,d2
  moveq      #0,d3
  moveq      #0,d4
  moveq      #0,d5
  moveq      #0,d6
  movea.l    d0,a1
  movea.l    d0,a2
  movea.l    d0,a3
  movea.l    d0,a4
  movea.l    d0,a5
  movea.l    d0,a6
  move.w     #153-1,d7

loop:
  movem.l    d0-d6/a1-a6,-(a0)
  movem.l    d0-d6/a1-a6,-(a0)
  movem.l    d0-d6/a1-a6,-(a0)  
  movem.l    d0-d6/a1-a6,-(a0)
  dbra       d7,loop

  movem.l    d0-d6/a1-a6,-(a0)
  movem.l    d0-d6/a1-a6,-(a0)
  movem.l    d0-d6/a1-a6,-(a0)
  movem.l    d0-d5,-(a0)        
  movem.l    (sp)+,d0-7/a0-6
  rts

  rts