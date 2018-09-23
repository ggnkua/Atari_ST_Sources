*
*
* Effet de flou horizontal par moyenne de deux points contigus...
*
 move.l ‚cran,a0
 lea copie,a1
 move.l taille_image,d7
 lsr.l d7
.traite_pixel_suivant  
 move (a1)+,d0		Pixel n1
 move d0,d2
 and #%11111,d2		D2=bleu
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 move (a1),d3		Pixel n2
 move d3,d5
 and #%11111,d5		D2=bleu
 move d3,d4
 lsr #5,d4
 and #%111111,d4	D1=vert
 rol #5,d3
 and #%11111,d3		D0=rouge

 add d3,d0
 lsr d0
 add d4,d1
 lsr d1
 add d5,d2
 lsr d2
 
 ror #5,d0
 lsl #5,d1
 or d1,d0
 or d2,d0
   
 move d0,(a0)+
 subq.l #1,d7
 bne .traite_pixel_suivant  
