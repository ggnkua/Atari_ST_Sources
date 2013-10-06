 lea minuscules,a0
 
 move.l #255,d0

boucle
 cmp2.b bounds,d0
 bcs pas_minuscule
minuscule
 move.b d0,(a0)+
 nop
 nop
 nop
  
pas_minuscule
 nop
 nop
 dbra d0,boucle
 nop
 nop
 nop
 nop
 
bounds
 dc.b 'a'
 dc.b 'z'

minuscules
 ds.b 255
   