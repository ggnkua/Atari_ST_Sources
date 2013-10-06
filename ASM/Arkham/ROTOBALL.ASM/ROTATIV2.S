* faux vectors balls
**********************

 section text

 dc.w $a00a

* efface ecran de travail

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 lea.l $100000,a0
 lea.l $1a0000,a1
 move.w #9199,d0
eff 
 move.l #$00,(a0)+
 move.l #$00,(a1)+
 dbf d0,eff
 
* precalcul positions des boules

 lea.l $90000,a0
 moveq.w #15,d0
calcul
 lea.l boule,a1
 moveq.w #12,d1
calcul2
 move.l (a1),(a0)+
 move.l 4(a1),(a0)+
 roxr.w (a1)
 roxr.w 4(a1)
 roxr.w 2(a1)
 roxr.w 6(a1)
 addq.w #8,a1
 dbf d1,calcul2
 dbf d0,calcul

* programme en superviseur

 pea 0
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,oldpile

 move.b #2,$ffff820a.w
 
 lea.l $ffff8240.w,a0
 move.l #$00000222,(a0)+
 move.l #$04440666,(a0)+

 lea.l tampon+90,a6

prog
 move.w #37,-(sp)
 trap #14
 addq.w #2,sp

 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

* efface vector balls

rot_reg
 lea.l rotative,a0

 move.w #89,d0
effbob
 movea.l oldecr,a1
 adda.w (a0)+,a1
 addq.w #2,a0
 
* efface une boule

n set 0
 rept 13 
 clr.l n+0(a1)
 clr.l n+8(a1)
n set n+160
 endr

 dbf d0,effbob

* et on tourne

 adda.l #90*4,a0
 cmpa.l #rotative2-90*4,a0	
 ble nofina0				
 suba.l #rotative2-rotative,a0
nofina0

* et on affiche

 suba.l #90,a6

 subq.b #1,compt
 bne nofina6
 move.b #216,compt
 adda.w #90,a6
 cmpa.l #tampon2,a6
 bne nofina6
 lea.l tampon,a6
nofina6
 move.w #89,d0
affbob
 movea.l oldecr,a1
 adda.w (a0)+,a1
 lea.l $90000,a2
 adda.w (a0)+,a2

 tst.b (a6)+
 beq noaff

* affiche une boule

n set 0
 rept 13 
 move.l (a2)+,d1
 or.l d1,n+0(a1)
 move.l (a2)+,d1
 or.l d1,n+8(a1)
n set n+160
 endr

noaff
 dbf d0,affbob

 move.l oldecr,a0
 move.l newecr,oldecr
 move.l a0,newecr
 
 move.l rot_reg+2,a0
 adda.l #90*4,a0
 cmpa.l #rotative2,a0
 bne nofinrot
 lea.l rotative,a0
nofinrot 
 move.l a0,rot_reg+2

 lea.l newecr+1,a0
 move.b (a0)+,$ff8201
 move.b (a0)+,$ff8203

 move.w #$100,$ffff8240.w
 bra prog


end 
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
 move.b #$1f,$ffff8201.w
 move.b #$80,$ffff8203.w

 move.l oldpile,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.w #6,sp

 clr -(sp)
 trap #1

 section data

oldpile even
 dc.l 0

compt even
 dc.b 216

tampon even
 dc.b 1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1
 dc.b 1,0,0,1,0,1,0,1,0,1,0,0,0,1,0,1,0,1
 dc.b 1,0,0,1,1,0,0,1,1,1,0,0,1,0,0,0,1,0
 dc.b 1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1,0
 dc.b 1,1,0,1,0,1,0,1,0,1,0,1,1,1,0,0,1,0 

 dc.b 1,1,0,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1
 dc.b 1,0,1,0,1,0,1,0,0,1,0,0,1,0,0,0,0,1
 dc.b 1,0,1,0,1,0,1,0,0,1,0,0,1,1,1,0,0,1
 dc.b 1,0,1,0,1,0,1,0,0,1,0,0,0,0,1,0,0,0
 dc.b 1,1,0,0,1,1,1,0,0,1,0,0,1,1,1,0,0,1
 
 dc.b 1,1,0,1,1,1,0,1,1,0,0,1,1,0,0,0,0,0
 dc.b 1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0,0
 dc.b 1,0,0,1,0,1,0,1,0,1,0,1,1,0,0,0,0,0
 dc.b 1,0,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0,0
 dc.b 1,1,0,1,1,1,0,1,1,0,0,1,1,0,0,0,0,0

 dc.b 1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 1,0,1,1,0,1,0,1,0,1,1,1,1,1,0,1,1,1
 dc.b 1,0,1,0,0,1,1,1,0,1,0,1,0,1,0,1,1,1
 dc.b 1,0,1,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1

 dc.b 1,1,1,0,1,1,1,0,1,1,1,0,1,0,0,0,0,1
 dc.b 1,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1
 dc.b 1,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,1
 dc.b 1,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,0,0
 dc.b 1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1
 
 dc.b 1,0,1,0,1,0,0,1,0,0,1,1,1,0,0,0,0,0
 dc.b 1,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0
 dc.b 1,1,1,0,1,0,0,1,0,0,0,1,0,1,1,1,0,1
 dc.b 1,0,1,0,1,0,0,0,0,0,0,1,0,1,0,1,0,0
 dc.b 1,0,1,0,1,0,0,1,0,0,0,1,0,1,1,1,0,1

 dc.b 1,1,1,0,1,1,1,1,0,1,0,0,0,1,0,1,1,1
 dc.b 1,0,0,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0 
 dc.b 1,1,0,0,1,1,1,1,0,0,0,1,0,0,0,1,1,0
 dc.b 1,0,0,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0
 dc.b 1,0,0,0,1,0,0,1,0,1,0,0,0,1,0,1,1,1

 dc.b 0,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,0
 dc.b 0,1,0,1,0,1,0,1,1,0,0,1,0,1,0,0,1,0
 dc.b 0,0,0,1,0,0,0,1,0,1,0,1,0,1,0,0,1,0
 dc.b 0,0,0,1,0,0,0,1,0,0,1,1,0,1,0,0,1,0
 dc.b 0,0,0,1,0,0,0,1,0,0,0,1,0,1,1,1,1,0

 dc.b 1,1,1,1,0,0,1,1,0,0,1,0,0,1,1,1,0,0
 dc.b 1,1,0,0,0,0,1,1,1,0,1,0,0,1,1,0,1,0
 dc.b 1,1,1,0,0,0,1,1,0,1,1,0,0,1,1,0,0,1
 dc.b 1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,1,0
 dc.b 1,1,1,1,0,0,1,1,0,0,1,0,0,1,1,1,0,0 

 rept 18*5
 dc.b 0
 endr

tampon2

oldecr even
 dc.l $100000
newecr even
 dc.l $1a0000

boule even
 incbin boule.dat

rotative even
 incbin rotative.dat
rotative2


