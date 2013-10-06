;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                        %
;% Format d'une image FULLSHOW [*.KID]    %
;%     2 octets d'entete [KD]             %
;%    32 octets de palette                %
;% 63020 octets d'image bitmap sp‚cial    %
;%                                        %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
charge_image_kid
 move.l buffer_fichier,a0
 cmpi #'KD',(a0)+
 bne erreur_format_chargement
 move.l a0,adresse_palette
 move.w #16,nombre_couleurs
 bsr recode_palette
 lea 32(a0),a0
 move.l a0,adresse_image
 move #896,largeur_image	448x274, c'est la taille fullscreen ST
 move #274,hauteur_image
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 move #6,offset_r‚siduel
 bsr charge_format_16_couleurs
 moveq #0,d0
 rts
