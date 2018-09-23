;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                         %
;% Format d'une image NeoChrome [*.NEO]    %
;%     4 octets d'entete                   %
;%    32 octets de palette                 %
;%    92 octets pour le cycling de palette %
;% 32000 octets d'image bitmap standard    %
;%                                         %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
teste_image_neo
teste_image_dali  
charge_image_neo
charge_image_dali
 move.l buffer_fichier,a0
 addq #4,a0
 move.l a0,adresse_palette
 move.w #16,nombre_couleurs
 bsr recode_palette
 move.l buffer_fichier,a0
 lea 128(a0),a0
 move.l a0,adresse_image
 move #640,largeur_image
 move #200,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 move #0,offset_r‚siduel
 bsr charge_format_16_couleurs
 moveq #0,d0
 rts
