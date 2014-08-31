screen    equ $70000

x:        clr.l     -(sp)
          move.w    #$20,-(sp)
          trap      #1
          move.l    d0,savereg
          lea.l     screen,sp
          move.l    #moff,-(sp)
          clr.w     -(sp)
          move.w    #25,-(sp)
          trap      #14
          addq.l    #8,sp
          .DC.w $a00a
          move.l    $44e,oldscreen
          move.b    $ffff8260,d0
          andi.w    #3,d0
          move.w    d0,oldres
          move.w    #0,-(sp)
          move.l    #screen,-(sp)
          move.l    #screen,-(sp)
          move.w    #5,-(sp)
          trap      #14
          lea.l     12(sp),sp
          bsr       prepare
          move.b    $ffff820a,oldsync
          move.b    #$02,$ffff820a
          movem.l   $ff8240,d0-d7
          movem.l   d0-d7,oldpal
          movem.l   pal(pc),d0-d7
          movem.l   d0-d7,$ffff8240
          bsr       hblon
          move.w    #7,-(sp)
          trap      #1
          addq.l    #2,sp
          bsr       hbloff
          movem.l   oldpal(pc),d0-d7
          movem.l   d0-d7,$ffff8240
          move.b    oldsync(pc),$ffff820a
          move.w    oldres(pc),-(sp)
          move.l    oldscreen(pc),-(sp)
          move.l    oldscreen(pc),-(sp)
          move.w    #5,-(sp)
          trap      #14
          lea.l     12(sp),sp
          move.l    #mon,-(sp)
          clr.w     -(sp)
          move.w    #25,-(sp)
          trap      #14
          addq.l    #8,sp
          .DC.w $a009
          move.l    savereg,-(sp)
          move.w    #$20,-(sp)
          trap      #1
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1
prepare:  lea.l     screen,a0
          moveq.l   #0,d1
          move.w    #11500-1,d0
clsloop:  move.l    d1,(a0)+
          dbf       d0,clsloop
          movea.l   #34*160+24+4+screen,a6
          moveq.l   #0,d4
kgloop:   lea.l     kasten(pc),a0
          move.w    #16-1,d7
gzloop:   movea.l   a6,a1
          adda.w    #230,a6
          movem.l   (a0)+,d0/d1
          moveq.l   #28-1,d6
gsloop:   movem.l   d0/d1,(a1)
          addq.l    #8,a1
          dbf       d6,gsloop
          addq.w    #6,a1
          addq.w    #1,d4
          cmpi.w    #150,d4
          beq.s     kgende
          dbf       d7,gzloop
          bra.s     kgloop
kgende:   rts       

hblon:    move.l    $120,oldtb
          move.l    $70,old4
          move.l    $70,new4b+2
          move.b    $fffffa07,old07
          move.b    $fffffa09,old09
          move.b    $fffffa0f,old0f
          move.b    $fffffa11,old11
          move.b    $fffffa1b,old1b
          andi.b    #$df,$fffffa09
          andi.b    #$fe,$fffffa07
          move.l    #newtb,$120
          move.l    #new4,$70
          ori.b     #1,$fffffa07
          ori.b     #1,$fffffa13
          rts       
hbloff:   move.w    sr,-(sp)
          move.w    #$2700,sr
          move.b    old07(pc),$fffffa07
          move.b    old09(pc),$fffffa09
          move.b    old0f(pc),$fffffa0f
          move.b    old11(pc),$fffffa11
          move.b    old1b(pc),$fffffa1b
          move.l    oldtb,$120
          move.l    old4,$70
          move.w    (sp)+,sr
          rts       

new4:     clr.b     $fffffa1b
          move.b    #32-1,$fffffa21
          move.b    #8,$fffffa1b
new4b:    jmp       $00000000
newtb:    clr.b     $fffffa1b
          movem.l   d0-d7/a0-a6,-(sp)
          movea.w   #$fa21,a2
          move.b    #200,(a2)
          move.b    #8,$fffffa1b
          move.w    #$2700,sr
          movea.w   #$8209,a0
          movea.w   #$8260,a6
          movea.w   #$8240,a3
          moveq.l   #0,d0
          moveq.l   #0,d1
          moveq.l   #16,d2
          moveq.l   #2,d3
          moveq.l   #0,d4
          move.b    (a2),d7
wait:     cmp.b     (a2),d7
          beq       wait
waitloop: move.b    (a0),d0
          beq.s     waitloop
          sub.w     d0,d2
          lsl.w     d2,d1
anfang:   nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          moveq.l   #16,d0
delayloop1:         nop       
          dbf       d0,delayloop1
          lea.l     $ff820a,a0
          move.w    #150,d0
zeilenloop2:        nop       
          nop       
          nop       
          nop       
          nop       
          moveq.l   #18,d1
delayloop2:         nop       
          dbf       d1,delayloop2
          nop       
          nop       
          nop       
          move.b    d4,(a0)
          move.b    d3,(a0)
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          move.b    d3,(a6)
          nop       
          move.b    d4,(a6)
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          nop       
          move.b    d3,(a6)
          move.b    d4,(a6)
          dbf       d0,zeilenloop2
          movem.l   (sp)+,d0-d7/a0-a6
          bclr      #0,$fffffa0f
          rte       
          .DATA 
savereg:  .DC.l 0
oldscreen:          .DC.l 0
oldres:   .DC.w 0
oldpal:   .DC.l 0,0,0,0,0,0,0,0
oldsync:  .DC.b 0
          .EVEN 
mon:      .DC.b $08
moff:     .DC.b $12

pal:      .DC.w $0000,$0076,$0210,$0650,$0320,$0760,$0540,$0430
          .DC.w $0527,$0111,$0222,$0333,$0444,$0555,$0666,$0777

kasten:   .DC.w $0001,$0000,$ffff,$ffff,$7ffd,$7ffc,$8003,$ffff
          .DC.w $4005,$7ffc,$8003,$ffff,$5ff5,$7ffc,$8003,$ffff
          .DC.w $5015,$701c,$8fe3,$ffff,$57d5,$701c,$8fe3,$ffff
          .DC.w $5455,$739c,$8fe3,$ffff,$5555,$739c,$8fe3,$ffff
          .DC.w $5455,$739c,$8fe3,$ffff,$57d5,$701c,$8fe3,$ffff
          .DC.w $5015,$701c,$8fe3,$ffff,$5ff5,$7ffc,$8003,$ffff
          .DC.w $4005,$7ffc,$8003,$ffff,$7ffd,$7ffc,$8003,$ffff
          .DC.w $0001,$0000,$ffff,$ffff,$ffff,$0000,$ffff,$ffff

old4:     .DC.l 0
oldtb:    .DC.l 0
old07:    .DC.b 0
old09:    .DC.b 0
old0f:    .DC.b 0
old11:    .DC.b 0
old1b:    .DC.b 0
          .EVEN 
          .END 








