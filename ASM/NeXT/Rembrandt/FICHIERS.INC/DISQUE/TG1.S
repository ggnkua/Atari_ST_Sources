;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                           %
;% Format d'une image au format COKE [*.TG1] %
;% 12 octets 'COKE format.'                  %
;%  2 octets pour la largeur de l'image      %
;%  2 octets pour la hauteur de l'image      %
;%  2 octets d'offset d‚but image            %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
 rsreset
tg1_entete	rs.b 12
tg1_largeur	rs.w 1
tg1_hauteur	rs.w 1
tg1_offset	rs.w 1

charge_image_coke
 move.l buffer_fichier,a0		D‚but du fichier charg‚
 cmp.l #'COKE',tg1_entete(a0)
 bne erreur_format_chargement
 cmp.l #' for',tg1_entete+4(a0)
 bne erreur_format_chargement
 cmp.l #'mat.',tg1_entete+8(a0)
 bne erreur_format_chargement
 
 move tg1_largeur(a0),d0
 add d0,d0
 move d0,largeur_image
 move tg1_hauteur(a0),hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement

 move.l buffer_fichier,a0	D‚but du fichier charg‚
 add tg1_offset(a0),a0		saute l'en-tete
 move.l fichier,a1		Destination dans le buffer d'image
 move largeur_image,d0
 mulu hauteur_image,d0		On a le nombre d'octets … recopier
 move.l d0,taille_image
 lsr.l d0
.boucle_recopie_image
 move (a0)+,(a1)+
 subq.l #1,d0
 bne.s .boucle_recopie_image
 moveq #0,d0
 rts




sauve_image_coke
 move.l taille_image,d0		Taille de l'image
 add #18,d0 			+ 18 octets d'entete
 move.l d0,taille_fichier	M‚morise tout cela pour plus tard.
 lea buffer_fichier,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_sauvegarde

 move.l buffer_fichier,a0
 move.l #'COKE',tg1_entete(a0)	L'identificateur de d‚but du fichier...
 move.l #' for',tg1_entete+4(a0)
 move.l #'mat.',tg1_entete+8(a0)
 move largeur_image,d0
 lsr d0
 move d0,tg1_largeur(a0)  		Largeur de l'image en pixels
 move hauteur_image,tg1_hauteur(a0)  	Hauteur de l'image
 move #18,tg1_offset(a0)		Offset avant image

 move.l fichier,a0
 move.l buffer_fichier,a1
 lea 18(a1),a1
 move.l taille_image,d0
 lsr.l d0
.recopie_image
 move (a0)+,(a1)+			Recopie l'image pixel par pixel...
 subq.l #1,d0
 bne.s .recopie_image
 moveq #0,d0				Tout c'est bien pass‚ !
 rts
   
 
 