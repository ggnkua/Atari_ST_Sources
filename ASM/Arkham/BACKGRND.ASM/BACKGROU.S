*********************
* MOVING BACKGROUND *
* BY TCHOOM         *
*********************

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 bsr predecal

 movem.l palette,d0-3
 movem.l d0-d3,$ffff8240.w

 lea.l courbe,a6

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 lea.l $90000,a2
 adda.w (a6)+,a2
 cmpa.l #courbe2,a6
 bne nofina6
 lea.l courbe,a6
nofina6

 lea.l $1f8000,a1
 move.w #6,d0
aff_background
 movea.l a2,a0
 rept 30
 move.l (a0),(a1)
 move.l 4(a0),8(a1)
 move.l (a0),16(a1)
 move.l 4(a0),24(a1)
 move.l (a0),32(a1)
 move.l 4(a0),40(a1)
 move.l (a0),48(a1)
 move.l 4(a0),56(a1)
 move.l (a0),64(a1)
 move.l 4(a0),72(a1)
 move.l (a0),80(a1)
 move.l 4(a0),88(a1)
 move.l (a0),96(a1)
 move.l 4(a0),104(a1)
 move.l (a0),112(a1)
 move.l 4(a0),120(a1)
 move.l (a0),128(a1)
 move.l 4(a0),136(a1)
 move.l (a0)+,144(a1)
 move.l (a0)+,152(a1)
 lea.l $a0(a1),a1
 endr

 dbf d0,aff_background

* move.w #$022,$ffff8240.w
 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile move.l #0,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1 

predecal

 lea.l $90000,a0
 move.w #31,d0
decal
 lea.l data,a1
 move.w #29,d1
decal1

 andi.w #$ffff-16,sr

 move.l (a1),30*8(a0)
 move.l 4(a1),30*8+4(a0)
 move.l (a1),(a0)+
 move.l 4(a1),(a0)+

 move.w 4(a1),d2
 ror.w #1,d2
 andi.w #32768,d2
 roxr.w (a1)		PLAN 1
 roxr.w 4(a1)
 or.w d2,(a1)

 andi.w #$ffff-16,sr

 move.w 6(a1),d2
 ror.w #1,d2
 andi.w #32768,d2
 roxr.w 2(a1)		PLAN 2
 roxr.w 6(a1)
 or.w d2,2(a1)

 addq.l #8,a1
 dbf d1,decal1
 adda.l #30*8,a0
 dbf d0,decal
 rts


palette even 
 dc.w $000,$200,$400,$600

courbe even
 incbin back.dat
courbe2

data even
 incbin boule.dat
data2