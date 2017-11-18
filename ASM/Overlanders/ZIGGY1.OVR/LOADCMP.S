* Programme de d‚compactage (C) Copyright ZIGGY Stardust.
* Adr fichier dans A0, ecran A1.
decomp:
   	
      movem.l  D0-D5,-(A7)
      clr.l D0
      clr.l D1
      clr.l D2
      move.w	#15,D3	
      tst.b	(a0)
      bne	loopp
      addq.l	#1,a0
loopp: 
      move.b   (A0)+,D1
      move.w   D1,D2
      lsr      #4,D2
      andi.w   #$f,D1
      add.l    D2,D0
loops:
         subq.w   #1,D2
         btst     #1,D1
         beq      pl2
         bset     D3,D4
pl2:
         btst     #0,D1
         beq      pl3
         swap     D4
         bset     D3,D4
         swap     D4
pl3:
         btst     #3,D1
         beq      pl4
         bset     D3,D5
pl4:
         btst     #2,D1
         beq      finideco
         swap     D5
         bset     D3,D5
         swap     D5
finideco:
         subq     #1,D3
         tst      D3
         bge      findeco
         move.l   D4,(A1)+
         move.l   D5,(A1)+
         move.l   #0,D4
         move.l   #0,D5
         move.w   #15,D3
findeco:
         tst.w    D2
         bgt      loops

      cmpi.l   #64000,D0
      blt      loopp
      movem.l  (A7)+,D0-D5
      rts