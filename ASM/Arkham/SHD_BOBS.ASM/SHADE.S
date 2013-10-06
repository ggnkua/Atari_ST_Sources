*************************
* SHADES BOBS by TCHOOM *
*************************

 dc.w $a00a
 dc.w $a000
 suba.l #602,a0
 move.l a0,linea

* efface ecran de travail

 lea.l $1d8c00,a0
clear_all
 clr.l (a0)+
 cmpa.l #$1f8000+$7d00,a0
 blo clear_all

* reloge la pile pour eviter d'avoir des merdes sur l'ecran

 lea.l stack,a7

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

 andi.w #$ffff-16,sr	; efface flag X
 lea.l $90000,a0
 move.w #15,d0
decal
 lea.l shade,a1
 move.w #12,d1
decal2
 move.l (a1),d2
 move.l d2,(a0)+
 ror.l d2
 move.l d2,(a1)+

 dbf d1,decal2
 dbf d0,decal

 movem.l palette,d0-d7
 movem.l d0-d7,$ffff8240.w

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp

 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

 movea.l linea,a0
 move.w (a0)+,d0	; X souris
 move.w (a0)+,d1	; Y souris

 cmp.w oldxy,d0
 bne nomeme
 cmp.w oldxy+2,d1
 beq meme

nomeme
 move.w d0,oldxy
 move.w d1,oldxy+2

 movea.l ecran,a0
 mulu.w #$a0,d1
 adda.w d1,a0
 move.w d0,d1
 lsr.w d0
 andi.w #$ffff-7,d0
 adda.w d0,a0
 divu.w #8,d0
 mulu.w #16,d0

 sub.w d0,d1 
 mulu.w #13*4,d1

 lea.l $90000,a1
 adda.w d1,a1
 
 move.w #12,d0
affshade

 move.w (a1)+,d1

 move.w (a0),d2
 eor.w d1,(a0)
 and.w d1,d2
 move.w d2,d1

 move.w 2(a0),d2
 eor.w d1,2(a0)
 and.w d1,d2
 move.w d2,d1

 move.w 4(a0),d2
 eor.w d1,4(a0)
 and.w d1,d2
 move.w d2,d1

 move.w 6(a0),d2
 eor.w d1,6(a0)
 and.w d1,d2
 move.w d2,d1

 move.w (a1)+,d1

 move.w 8(a0),d2
 eor.w d1,8(a0)
 and.w d1,d2
 move.w d2,d1

 move.w 10(a0),d2
 eor.w d1,10(a0)
 and.w d1,d2
 move.w d2,d1

 move.w 12(a0),d2
 eor.w d1,12(a0)
 and.w d1,d2
 move.w d2,d1

 move.w 14(a0),d2
 eor.w d1,14(a0)
 and.w d1,d2
 move.w d2,d1

 adda.l #$a0,a0
 dbf d0,affshade

meme
 move.w #$111,$ffff8240.w

* met nouvel ecran dans registre video

 lea.l ecran+1,a0
 move.b (a0)+,$ffff8201.w
 move.b (a0)+,$ffff8203.w

 add.l #$7d00,ecran
 cmpi.l #$1f8000+$7d00,ecran
 bne nofinecran
 move.l #$1d8c00,ecran
nofinecran

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


****************
* section data *
****************

ecran even
 dc.l $1f8000

oldxy
 dc.l 0

palette even
 dc.w $000,$001,$002,$003
 dc.w $004,$005,$006,$007
 dc.w $017,$027,$037,$047
 dc.w $057,$067,$077,$177

linea even
 dc.l 0

 ds.l 500
stack ds.l 3

shade even
 incbin shade.dat