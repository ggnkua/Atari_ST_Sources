;
;
; Effet de flou global par moyenne des 8 points adjacents+point central
;
; Le pixel central contient la somme des composante:
; D0=rouge
; D1=vert
; D2=bleu
;
; On bosse sur d3/d4/d5 pour les composantes RVB des autres points.
; et l'on aditionne au fur et a mesure sur d0/d1/d2.
;
coef_1=16	x1=16
coef_2=1	x4=8
coef_3=0	x4=4

applique_effet_flou_global
 move largeur_image,d0
* sub d0,flou_1
* add d0,flou_2

* sub d0,flou_3
* sub d0,flou_4

* add d0,flou_5
* add d0,flou_6
 
 move.l ‚cran,a0
 move.l fichier,a1
 
 move.l taille_image,d7
 lsr.l d7
 move.l d7,a6
.traite_pixel_suivant  

 move (a1),d0		Charge le pixel central lui meme.
 move d0,d2
 and #%11111,d2		D2=bleu initial
 move d0,d1
 lsr #6,d1
 and #%11111,d1		D1=vert initial
 rol #5,d0
 and #%11111,d0		D0=rouge initial
 
 mulu #20,d0		Fort coefficient pour le point central.
 mulu #20,d1
 mulu #20,d2

* bra .zap
 
 lea liste_points(pc),a2

 moveq #5-1,d7		8
.convolue_pixel  
 move (a2)+,d6		Charge l'adresse_du_pixel
 move (a1,d6.w),d3	Charge le pixel lui meme.
 move d3,d5
 and #%11111,d5		D5=bleu
 move d3,d4
 lsr #6,d4
 and #%11111,d4		D4=vert
 rol #5,d3
 and #%11111,d3		D3=rouge

 move (a2)+,d6
 lsl d6,d3		Coefficiente les valeurs RVB du pixel lu
 lsl d6,d4
 lsl d6,d5

 add d3,d0		Ajoute au total courant
 add d4,d1
 add d5,d2
 dbra d7,.convolue_pixel  
  
.zap  
 lsr #5,d0  			Redivise tout par 32
 lsr #5,d1  
 lsr #5,d2  

 ror #5,d0
 lsl #6,d1
 or d1,d0
 or d2,d0
   
 move d0,(a0)+
 addq #2,a1
 subq.l #1,a6				y'a plus de registres libres !
 cmp.l #0,a6
 bne .traite_pixel_suivant  
 rts
 
liste_points
 dc.w -2,coef_2		Gauche
 dc.w +2,coef_2		Droite
flou_1
 dc.w -640,coef_2		Haut
flou_2
 dc.w +640,coef_2		Bas


flou_3
 dc.w -644,coef_3		Haut gauche
flou_4
 dc.w -642,coef_3		Haut droite
flou_5
 dc.w 638,coef_3		Bas gauche
flou_6
 dc.w 642,coef_3		bas droite
