
affiche_256_couleurs
 move.l adresse_zoomer,a1
 lea 640*15+404(a1),a1
 
 move #640,d1
 move d1,d2
 mulu #5,d2
 lea couleurs_palette,a0
 moveq #16-1,d7
.recopie_couleurs_y
 move.l a1,a2
 moveq #16-1,d6
.recopie_couleurs_x
 move (a0)+,d0
 move.l a2,a3
 moveq #5-1,d5
.duplique_couleur_y
 move d0,(a3)
 move d0,2(a3)
 move d0,4(a3)
 move d0,6(a3)
 move d0,8(a3)
 move d0,10(a3)
 move d0,12(a3)
 add d1,a3
 dbra d5,.duplique_couleur_y
 lea 7*2(a2),a2
 dbra d6,.recopie_couleurs_x
 add d2,a1
 dbra d7,.recopie_couleurs_y
 rts
