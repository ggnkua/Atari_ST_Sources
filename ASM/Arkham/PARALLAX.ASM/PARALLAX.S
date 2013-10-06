* MOTIFS DEFILANT
*****************

 dc.w $a00a
 clr -(sp)
 pea $78000
 pea $78000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp
 pea routine
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr -(sp)
 trap #1

routine
 bsr precalcul
 clr $ff8240
 move.w #$777,$ff825e
 move.w #$222,$ff8242
 move.w #$444,$ff8244
 move.w #$666,$ff8246
 lea.l trajet,a6
prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr $ff8240
 cmpi.b #$39,$fffffc02.w
 beq end

 lea.l $78000,a0
 move.w (a6)+,d0
 cmpi.w #$ffff,(a6)
 bne ok
 lea.l trajet,a6
ok
 lea.l $60000,a1
 adda.w d0,a1 
 move.w #5,d0
motif
 move.l a1,-(sp)
 move.w #31,d1
motif2
 move.l (a1),(a0)
 move.l (a1),16(a0)
 move.l (a1),32(a0)
 move.l (a1),48(a0)
 move.l (a1),64(a0)
 move.l (a1),80(a0)
 move.l (a1),96(a0)
 move.l (a1),112(a0)
 move.l (a1),128(a0)
 move.l (a1)+,144(a0)
 
 move.l (a1),8(a0)
 move.l (a1),24(a0)
 move.l (a1),40(a0)
 move.l (a1),56(a0)
 move.l (a1),72(a0)
 move.l (a1),88(a0)
 move.l (a1),104(a0)
 move.l (a1),120(a0)
 move.l (a1),136(a0)
 move.l (a1)+,152(a0)

 adda.l #$a0,a0
 dbf d1,motif2
 move.l (sp)+,a1
 dbf d0,motif

* move.w #$222,$ff8240
 bra prog

end
 rts

precalcul 
 lea.l $60000,a1 
 move.w #31,d1
precalcul2
 lea.l data,a0
 move.w #31,d0
precalcul3
 move.l (a0),32*8(a1)
 move.l 4(a0),4+32*8(a1)
 move.l (a0),(a1)+
 move.l 4(a0),(a1)+
 move.w 4(a0),d3
 roxr.w (a0)
 roxr.w 4(a0)
 bsr clr_x
 or.w d3,(a0)
 move.w 6(a0),d3
 roxr.w 2(a0)
 roxr.w 6(a0) 
 bsr clr_x
 or.w d3,2(a0)
 adda.l #8,a0
 dbf d0,precalcul3
 adda.l #32*8,a1
 dbf d1,precalcul2
 rts

clr_x
 move.w sr,d2
 bclr #4,d2
 move.w d2,sr
 andi.w #1,d3
 ror.w d3
 rts
 
trajet even
 incbin trajetsin.dat
 dc.w $ffff

data even 
 incbin algue.dat