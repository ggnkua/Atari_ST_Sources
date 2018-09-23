*
*
* Assombrissement de l'image si le facteur est inf‚rieur … 100,
* ‚claircissement si il est sup‚rieur … 100.
*
facteur=20		Pourcentage de r‚duction de la luminosit‚...

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

 mulu #facteur,d0
 divu #100,d0
 cmp #31,d0
 ble.s .ok_rouge
 moveq #31,d0
.ok_rouge 
 mulu #facteur,d1
 divu #100,d1
 cmp #63,d1
 ble.s .ok_vert
 moveq #63,d1
.ok_vert   
 mulu #facteur,d2
 divu #100,d2
 cmp #31,d2
 ble.s .ok_bleu
 moveq #31,d2
.ok_bleu

 ror #5,d0
 lsl #5,d1
 or d1,d0
 or d2,d0
   
 move d0,(a0)+
 subq.l #1,d7
 bne .traite_pixel_suivant  
