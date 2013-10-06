******************************
* essai de rasters verticaux *
******************************

 dc.w $a00a
 lea.l pile,sp

 lea.l $1f0300,a0
 move.w #7999,d0
clr_all clr.l (a0)+
 dbf d0,clr_all

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

* fait des petites courbes sinusoidales

 lea.l courbe,a1
 jsr mak_courbe
 lea.l courbe_2,a1
 jsr mak_courbe

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,rpile+2

 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 
* precalcule les 16 positions du raster

 lea.l $90000,a6
 moveq.w #15,d0
decal_rast
 lea.l rast_mot,a0

 move.w (a0),d1
 or.w 2(a0),d1
 or.w 4(a0),d1
 not.w d1
 
 move.w 6(a0),d2
 or.w 8(a0),d2
 or.w 10(a0),d2
 not.w d2

 move.w d1,(a6)+
 move.w d1,(a6)+
 move.l (a0),(a6)+
 move.w 4(a0),(a6)+

 move.w d2,(a6)+
 move.w d2,(a6)+
 move.l 6(a0),(a6)+
 move.w 10(a0),(a6)+

 roxr.w (a0)
 roxr.w 6(a0)
 roxr.w 2(a0)
 roxr.w 8(a0)
 roxr.w 4(a0)
 roxr.w 10(a0)
 adda.l #24,a0
 dbf d0,decal_rast

 lea.l courbe,a6
 lea.l courbe_2,a5

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp
 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 movea.l ecr2,a1
 lea.l 16+$a0*10(a1),a1
 moveq.w #90,d0
 lea.l line,a3
aff_rast
 movea.l a3,a0
 rept 16
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 endr

 lea.l 32(a1),a1

 movea.l a3,a0
 adda.w (a6)+,a0
 lea.l $90000,a2
 adda.w (a6)+,a2

 move.l (a2)+,d1	; masque
 and.l d1,(a0)
 move.l (a2)+,d2
 or.l d2,(a0)+
 move.w (a2)+,d2
 and.w d1,(a0)
 or.w d2,(a0)+
 addq.w #2,a0
 move.l (a2)+,d1
 and.l d1,(a0)
 move.l (a2)+,d2
 or.l d2,(a0)+
 move.w (a2)+,d2
 and.w d1,(a0)
 or.w d2,(a0)+
 lea.l 4*4(a6),a6
 dbf d0,aff_rast 

 suba.l #4*91+91*4*4,a6

 lea.l -$a0(a1),a0
 moveq.w #90,d0
continue
 rept 16
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 endr
 lea.l 8*4(a1),a1
 lea.l -16*8-$a0(a0),a0
 dbf d0,continue

 adda.l #4*2,a6
 cmpa.l #courbe+360*4,a6
 blo nofin_a6
 lea.l courbe,a6
nofin_a6

 cmpi.b #$62,$fffffc02.w
 bne no_help
 move.w #$721,$ffff8240.w
no_help

 lea.l line,a0
 moveq.l #0,d0
 rept 40
 move.l d0,(a0)+
 endr 

 move.b ecr2+1,$ffff8201.w
 move.b ecr2+2,$ffff8203.w
 move.l ecr2,a0
 move.l ecr1,ecr2
 move.l a0,ecr1

 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1

mak_courbe
 lea.l cosinus,a0
 move.w #0,d0
make_courbe
 move.w #60,d1
 muls.w 2(a0,d0.w),d1
 asr.w #7,d1
 addi.w #120,d1
 move.w d1,d2
 lsr.w d1
 andi.w #$ffff-7,d1
 move.w d1,360*4(a1)
 move.w d1,360*4*2(a1)
 move.w d1,(a1)+
 lsr.w #3,d1
 lsl.w #4,d1
 sub.w d1,d2
 mulu.w #20,d2
 move.w d2,360*4(a1)
 move.w d2,360*4*2(a1)
 move.w d2,(a1)+
 addq.w #4,d0
 cmpi.w #1440,d0
 bne make_courbe
 rts
 
line even
 ds.l 40

palette even
 dc.w $000,$101,$212,$323,$434,$545,$656,$767
 dc.w $502,$421,$235,$420,$154,$425,$535,$777

ecr1 even
 dc.l $1f0300
ecr2 
 dc.l $1f8000

rast_mot
 dc.w $5588
 dc.w $33cc
 dc.w $0ff0
 dc.w 0,0,0

courbe even
 ds.w 360*2
 ds.w 360*2
 ds.w 360*2

courbe_2 even
 ds.w 360*2
 ds.w 360*2
 ds.w 360*2

cosinus even
 incbin cosinus.dat

 ds.l 5000
pile ds.l 100