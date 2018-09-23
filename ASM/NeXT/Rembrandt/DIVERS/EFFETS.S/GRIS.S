*
*
* Transformation en niveaux de gris...
*
*
 move.l ‚cran,a0
 move.l taille_image,d7
 lsr.l d7
.traite_pixel_suivant  
 move (a0),d0
 move d0,d2
 and #%11111,d2		D2=bleu
 move d0,d1
 lsr #6,d1
 and #%11111,d1		D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 add d1,d0
 add d2,d0		D0=total des trois
 mulu #100,d0
 divu #300,d0 
 and #%11111,d0
 move d0,d1
 move d0,d2
 
 ror #5,d0
 lsl #6,d1
 or d1,d0
 or d2,d0
   
 move d0,(a0)+
 subq.l #1,d7
 bne .traite_pixel_suivant  
