;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                 %
;% Format d'une image DEGAS non compress‚e [*.PI1] %
;%     2 octets d'entete                           %
;%    32 octets de palette                         %
;% 32000 octets d'image bitmap standard            %
;%                                                 %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
teste_image_degas 
 move.l taille_fichier,d0
 cmp.l #32034,d0
 beq.s charge_degas_non_compact‚
 cmp.l #32066,d0
 beq.s charge_degas_non_compact‚
 bra charge_image_degas_pack‚e

cid
charge_image_degas
 move.l taille_fichier,d0
 cmp.l #32034,d0
 beq.s charge_degas_non_compact‚
 cmp.l #32066,d0
 bne erreur_format_chargement
 
charge_degas_non_compact‚
 move.l buffer_fichier,a0
 addq #2,a0
 move.l a0,adresse_palette
 move.w #16,nombre_couleurs
 bsr recode_palette
 move.l buffer_fichier,a0
 lea 34(a0),a0
 move.l a0,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 move #0,offset_r‚siduel
 bsr charge_format_16_couleurs
 moveq #0,d0
 rts

charge_image_degas_pack‚e
 move.l buffer_fichier,a0
 addq #2,a0
 move.l a0,adresse_palette
 move.w #16,nombre_couleurs
 bsr recode_palette

 move.l #32000,d0			Il est n‚c‚ssaire de r‚server un
 lea buffer_d‚packing,a0		bloc de m‚moire pour d‚packer une
 bsr.l r‚serve_bloc			image PC1.
 bmi erreur_m‚moire_d‚packing
 move #320,nombre_colonnes
 move #200,nombre_lignes
 move #4,nombre_plans
 move #40,largeur_plan
 move.l buffer_d‚packing,a1
 move.l buffer_fichier,a0
 lea 34(a0),a0
*****

depacke_rle
 moveq #1,d0
 bsr affiche_formulaire_chargement
 move.l a1,adresse_image

 move nombre_lignes,d4
 mulu nombre_plans,d4
 mulu largeur_plan,d4			D4=nombre MAX d'octets … d‚packer !

 move nombre_lignes,d7			200 lignes de haut
 subq #1,d7
.ligne_suivante
 lea buffer_ligne,a2
 move nombre_plans,d6 			4 plans par image
 subq #1,d6
.plan_suivant
 move largeur_plan,d5
.boucle_d‚packing
 move.b (a0)+,d0
 blt .n‚gatif
 ext d0
 sub d0,d5
 subq #1,d5
.recopie_octets
 move.b (a0)+,(a2)+
 subq.l #1,d4
 bmi erreur_format_chargement
 dbra d0,.recopie_octets
 bra .fin_controle

.n‚gatif
 cmp.b #-128,d0
 beq .fin_controle
 ext d0
 neg d0
 sub d0,d5
 subq #1,d5
 move.b (a0)+,d1
.duplique_octet
 move.b d1,(a2)+
 subq.l #1,d4
 bmi erreur_format_chargement
 dbra d0,.duplique_octet

.fin_controle
 tst d5
 bne.s .boucle_d‚packing
  
 dbra d6,.plan_suivant

 lea buffer_ligne,a2		Entrelacement des plans:

 move largeur_plan,d0		Taille d'un plan en octets
 move d0,d6
 lsr d6
 subq #1,d6			Nombre d'it‚rations
.mot_suivant
 move nombre_plans,d5
 subq #1,d5
 move.l a2,a3
 addq #2,a2
.mixe_plan_suivant
 move (a3),(a1)+		Recopie le plan
 add d0,a3			Saute au plan suivant
 dbra d5,.mixe_plan_suivant
 dbra d6,.mot_suivant
 dbra d7,.ligne_suivante
 bsr.l ferme_formulaire
 tst.l d4
 bne erreur_format_chargement
 
*****
.continue_d‚packing
 move.l buffer_d‚packing,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 bsr charge_format_16_couleurs
 lea buffer_d‚packing,a0		Et on ejecte le bloc que l'on avait
 bsr.l libŠre_bloc			utilis‚ pour le d‚packing.
 moveq #0,d0
 rts
  