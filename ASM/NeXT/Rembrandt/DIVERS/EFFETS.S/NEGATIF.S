*
*
* N‚gativation de l'image
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
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 moveq #31,d3		Rouge=inverse rouge
 sub d0,d3
 moveq #63,d4		Vert=inverse vert
 sub d1,d4
 moveq #31,d5		Bleu=inverse bleu
 sub d2,d5

 ror #5,d3
 lsl #5,d4
 or d4,d3
 or d5,d3
   
 move d3,(a0)+
 subq.l #1,d7
 bne .traite_pixel_suivant  
