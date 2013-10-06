**************************
* etoiles 3d precalculee *
**************************

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 adda.l #6,sp
 move.l d0,rpile+2

 clr.w $ffff8240.w
 move.w #$777,$ffff8242.w
 move.w #$555,$ffff8244.w
 move.w #$333,$ffff8246.w

 move.w #$505,$ffff8248.w
 move.w #$003,$ffff8250.w
 move.w #$303,$ffff8258.w

* affiche message avec fonte

 lea.l text,a5
 lea.l $1f8000+70*$a0,a1
afftext
 clr.w d0
 move.b (a5)+,d0
 tst.b d0
 beq endtext
 cmpi.b #$20,d0
 bne nospace
 lea.l espace,a0
 bra.s letterok
nospace
 cmpi.b #10,d0
 bne nofinline
 adda.l #25*$a0,a1
 bra afftext
nofinline
 subi.b #65,d0
 mulu.w #25*8,d0
 lea.l font,a0
 adda.l d0,a0
 
letterok
 move.w #24,d0
affletter
 move.l (a0)+,4(a1)
 move.l (a0)+,12(a1)
 lea.l $a0(a1),a1
 dbf d0,affletter
 suba.l #$a0*25-16,a1 
 bra afftext 

endtext
 lea.l star,a6

prog
 move.w #37,-(sp)
 trap #14
 addq.l #2,sp

 clr.w $ffff8240.w
 cmpi.b #$b9,$fffffc02.w
 beq end

* efface les etoiles

 movea.l a6,a0
 lea.l $1f8000,a1
 move.w #99,d0
effstar
 move.w (a0)+,d1
 addq.l #4,a0
 clr.l (a1,d1.w)
 dbf d0,effstar

 cmpa.l #star2,a0
 bne nofina0
 lea.l star,a0
nofina0

* affichage des etoiles

 lea.l $1f8000,a1
 move.w #99,d0
affstar
 move.w (a0)+,d1
 move.w (a0)+,d2
 move.w (a0)+,d3

 cmpi.w #1,d3
 bne nocol1
 or.w d2,(a1,d1.w)
 bra.s fincol
nocol1
 cmpi.w #2,d3
 bne nocol2
 or.w d2,2(a1,d1.w)
 bra.s fincol
nocol2
 cmpi.w #3,d3
 bne fincol
 or.w d2,(a1,d1.w)
 or.w d2,2(a1,d1.w)
fincol
 dbf d0,affstar

 adda.l #600,a6
 cmpa.l #star2,a6
 bne nofinstar
 lea.l star,a6
nofinstar

 clr.l $1f8000

 cmpi.b #$62,$fffffc02.w
 bne nohelp
 move.w #$103,$ffff8240.w
nohelp

 bra prog

end
 clr.w $ffff8240.w
 move.w #$777,$ffff8246.w
rpile move.l #0,-(sp)
 move.w $20,-(sp)
 trap #1
 addq.l #6,sp
 clr -(sp)
 trap #1 

text even
 dc.b "  ANONYM  ",10
 dc.b " PRESENTS ",0

font even
 incbin metal.fnt

espace even
 rept 25*8
 dc.b 0
 endr

star 
 incbin star3d2.dat
star2
