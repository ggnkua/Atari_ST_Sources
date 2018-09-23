;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                         %
;% Format d'une image Art Director [*.ART] %
;% 32000 octets d'image bitmap standard    %
;%    32 octets de palette                 %
;%                                         %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
charge_image_art_director
 move.l taille_fichier,d0
 cmp.l #32032,d0
 beq.s .ok_art
 cmp.l #32512,d0
 bne erreur_format_chargement

.ok_art
 move.l buffer_fichier,a0
 lea 32000(a0),a0
 move.l a0,adresse_palette
 move.w #16,nombre_couleurs
 bsr recode_palette
 move.l buffer_fichier,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 move #0,offset_r‚siduel
 bsr charge_format_16_couleurs
 moveq #0,d0
 rts
