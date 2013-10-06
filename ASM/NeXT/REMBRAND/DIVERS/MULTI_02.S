;
; Tests multitos...
;
;
 pea texte
 move #9,-(sp)
 trap #1
 addq #6,sp
 
 clr.l -(sp)
 move #$20,-(sp)
 trap #1
 addq #6,sp
 move.l d0,-(sp)
 
 move.b $ffff8265.w,d0
 move.b $44e.w,d0

 move #$20,-(sp)
 trap #1
 addq #6,sp

 move #7,-(sp)
 trap #1
 addq #2,sp
  
 clr -(sp)
 trap #1
 
texte
 dc.b 27,"ETest avec SUPER/SUPER",10,13
 dc.b "lecture de $ffff8265.w",10,13
 dc.b 0
  