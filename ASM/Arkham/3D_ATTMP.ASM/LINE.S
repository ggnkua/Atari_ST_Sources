*******************************
* routine de tracage de ligne *
*******************************

 clr -(sp)
 pea $1f8000
 pea $1f8000
 move.w #5,-(sp)
 trap #14
 adda.l #12,sp

 move.w #0,d0
 move.w #0,d1
 move.w #160,d2
 move.w #19,d3
 bsr draw

 move.w #7,-(sp)
 trap #1
 addq.l #2,sp
 clr -(sp)
 trap #1

draw

 movem.l d0-a6,-(sp)

 * calcul des 3 constantes

 lea.l constante,a0

 movem.w d0-d3,-(sp)
 sub.w d1,d3
 sub.w d0,d2
 move.w d3,(a0)+	; y'-y
 move.w d2,(a0)+	; x'-x
 movem.w (sp)+,d0-d3
 movem.w d0-d3,-(sp)
 muls.w d1,d2
 muls.w d3,d0
 sub.w d0,d2
 move.w d2,(a0)+	; (yx'-y'x)
 movem.w (sp)+,d0-d3

* trace la ligne

 lea.l constante,a0
 move.w (a0)+,d5
 move.w (a0)+,d6
 move.w (a0)+,d7
 move.w d2,d1

line
 move.w d0,d2
 muls.w d5,d2
 add.w d7,d2
 divs.w d6,d2

* d2 contient le Y correspondant au X
* donc on trace !

 move.w d0,d3

 lea.l $1f8000,a0
 mulu.w #160,d2
 adda.w d2,a0

 move.w d3,d2
 divu.w #2,d3
 andi.w #$ffff-7,d3
 adda.w d3,a0

 divu.w #8,d3
 mulu.w #16,d3
 sub.w d3,d2
 move.w #32768,d3
 lsr.w d2,d3
 or.w d3,(a0)
 
 addq.w #1,d0
 cmp.w d1,d0
 bne line

 movem.l (sp)+,d0-a6
 rts

constante even
 dc.l 3 

 