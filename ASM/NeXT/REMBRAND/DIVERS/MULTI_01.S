;
; Tests multitos...
;
;
 pea texte
 move #9,-(sp)
 trap #1
 addq #6,sp
 
 pea routine_super
 move #$26,-(sp)
 trap #14
 addq #6,sp

 move #7,-(sp)
 trap #1
 addq #2,sp
  
 clr -(sp)
 trap #1


routine_super
 move.b $ffff8265.w,d0
 move.b $44e.w,d0
 rts
 
texte
 dc.b 27,"ETest avec SUPEXEC",10,13
 dc.b "lecture de $ffff8265.w",10,13
 dc.b 0
  