 rept 10
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,8*4(a5)
 movem.l (a4)+,d2-d4
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 movem.l (a4)+,d5-d7/a6-a7
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d2-d5,16*4(a5)
*
 move.b  d1,(a0)   ; haute 2
 lea 20*4(a5),a5
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem.l d6-d7/a6-a7,(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,4*4(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6,12*4(a5)
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 movem.l (a4)+,d2-d6
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d2-d5,20*4(a5)
*
 move.b  d1,(a0)   ; haute 2
 lea 24*4(a5),a5
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 move.l a7,19*4-24*4(a5)
 move.l d6,(a5)+
 movem.l (a4)+,d2-d7/a6
 movem.l d2-d7/a6,(a5)
 lea 22+7*4(a5),a5
 lea 26*8(a4),a4
* 2 eme ligne mon pote !!
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,(a5)
 move.l (a4)+,d2
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 movem.l (a4)+,d3-d7
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d2-d5,8*4(a5)
*
 move.b  d1,(a0)   ; haute 2
 lea 12*4(a5),a5
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)

 move.l d6,(a5)+
 move.l d7,(a5)+
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,8*4(a5)
 move.l (a4)+,d2
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 movem.l (a4)+,d3-d7
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d2-d5,16*4(a5)
*
 move.b  d1,(a0)   ; haute 2
 lea 20*4(a5),a5
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 move.l d6,(a5)+
 move.l d7,(a5)+
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,8*4(a5)
 lea 26*8(a4),a4
 nop
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 lea 22+16*4(a5),a5
 pause 11
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 pause 11
 endr
 move.b  d1,(a0)   ; haute 2
 pause 2
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,8*4(a5)
 movem.l (a4)+,d2-d4
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 movem.l (a4)+,d5-d7/a6-a7
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d2-d5,16*4(a5)
*
 move.b  d1,(a0)   ; haute 2
 lea 20*4(a5),a5
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 movem.l d6-d7/a6-a7,(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6-a7,4*4(a5)
 movem.l (a4)+,d2-d7/a6-a7
 movem.l d2-d7/a6,12*4(a5)
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 movem.l (a4)+,d2-d6
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 movem.l d2-d5,20*4(a5)
*
 move.b  d1,(a0)   ; haute 2
 lea 24*4(a5),a5
 move.b  d0,(a0)   ; basse 0
 move.l (a2)+,(a3)
 move.l a7,19*4-24*4(a5)
 move.l d6,(a5)+
 movem.l (a4)+,d2-d7/a6
 movem.l d2-d7/a6,(a5)
 lea 22+7*4(a5),a5
 lea 26*8(a4),a4
