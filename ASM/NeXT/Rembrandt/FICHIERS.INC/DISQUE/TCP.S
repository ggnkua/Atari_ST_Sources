; REMBRANDT 3.0 - ½  Dbug II
;
; Module de chargement/sauvegarde d'images TCP. (1.0)
; [TCP=True Color Picture]
;
; Infos g‚n‚rales sur le format:
; - On ne peut sauver que des images au format TrueColor 16 bits du Falcon.
; - Il peut y avoir plusieurs images dans un fichier.
; - Chaque image peut avoir un mode de compactage diff‚rent.
; - Chaque image peut avoir une palette de travail.
; - On m‚morise toutes les infos pour l'affichage.
; - Possibilit‚ d'avoir des commentaires avec l'image.
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%
;% Format d'une image Rembrandt Type 1[*.TCP]
;% >L'entete principal du fichier
;%   8 octets d'entete ['TRUECOLR']
;%   4 octets donnant la longueur totale du fichier
;%   2 octets donnant la longueur de l'entete
;%   2 octets pour le num‚ro de version du format
;%   2 octets pour indiquer le nombre d'images stock‚es
;%
;% >L'entete de chaque image
;%   4 octets pour indiquer que l'on a une image ['PICT']
;%   4 octets donnant la longueur totale de l'image
;%   2 octets donnant la longueur de l'entete
;%   2 octets pour la largeur en pixels de l'image [Paire]
;%   2 octets pour la hauteur en pixels de l'image
;%   2 octets pour indiquer la couleur de transparence par d‚faut
;%   2 octets pour la couleur du crayon par d‚faut
;%   1 octet pour indiquer le mode de compactage [0:Aucun]
;%   1 octet pour indiquer la pr‚sence d'une palette [0:Aucune]
;%   1 octet pour indiquer si l'on doit utiliser l'overscan
;%   1 octet pour indiquer si l'on doit utiliser la double largeur
;%   1 octet pour indiquer si l'on doit utiliser la double hauteur
;% 175 octets de texte (4*35)
;% 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;

 rsreset
tcp_main_identificateur		rs.l 2
tcp_main_total_fichier		rs.l 1
tcp_main_offset			rs.w 1
tcp_main_version		rs.w 1
tcp_main_nombre_image		rs.w 1
tcp_main_longueur		rs.b 1

 rsreset
tcp_data_identificateur		rs.l 1
tcp_data_total_image		rs.l 1
tcp_data_offset			rs.w 1
tcp_data_largeur		rs.w 1
tcp_data_hauteur		rs.w 1
tcp_data_transparent		rs.w 1
tcp_data_crayon			rs.w 1
tcp_data_packing		rs.b 1
tcp_data_palette		rs.b 1
tcp_data_overscan		rs.b 1
tcp_data_double_largeur		rs.b 1
tcp_data_double_hauteur		rs.b 1
tcp_data_commentaires		rs.b 175
tcp_data_longueur		rs.b 1



 TEXT

 
charge_image_tcp
 move.l buffer_fichier,a0	D‚but du fichier charg‚
;
; Il faut lire tout l'entete afin de savoir si le fichier est valide.
; Cela permet de savoir aussi si il y a plusieurs images dans le fichier.
; Pour l'instant, on ignore le cas o— il y aurait plusieurs images.
;
 cmp.l #'TRUE',tcp_main_identificateur(a0)	V‚rifie l'entete
 bne erreur_format_chargement
 cmp.l #'COLR',tcp_main_identificateur+4(a0)
 bne erreur_format_chargement
 
 move.l taille_fichier,d0
 cmp.l tcp_main_total_fichier(a0),d0		Teste la taille.
 bne erreur_format_chargement
 
 move tcp_main_offset(a0),d7			Longueur de l'entete
 cmp #1,tcp_main_version(a0)			Version 1
 bne erreur_format_chargement
 
* move tcp_main_nombre_image(a0),nombre_images	1 seule image

 add d7,a0					Saute l'entete MAIN



 cmp.l #'PICT',tcp_data_identificateur(a0)	Identificateur
 bne erreur_format_chargement
 
 move.l tcp_data_total_image(a0),taille_image	Taille de l'image
 move tcp_data_offset(a0),d7			Longueur de l'entete
 move tcp_data_largeur(a0),d0			Largeur de l'image
 add d0,d0
 move d0,largeur_image
 move tcp_data_hauteur(a0),hauteur_image	Hauteur de l'image
 bsr.l pr‚pare_buffer_image			Fait de la place !
 bne erreur_format_chargement
 
* move tcp_data_transparent(a0),transparent	Couleur transparente
 move tcp_data_crayon(a0),couleur		Couleur de dessin
 
 move.b tcp_data_packing(a0),flag_compacter_image	Y'a compactage ?
 move.b tcp_data_palette(a0),flag_sauver_palette	Y'a palette ?

 move.b tcp_data_overscan(a0),flag_overscan
 move.b tcp_data_double_largeur(a0),flag_double_largeur
 move.b tcp_data_double_hauteur(a0),flag_double_hauteur

 lea tcp_data_commentaires(a0),a1	Il ne faut pas oublier de noter
 lea infos_texte,a2			les commentaires dans le fichier.
 moveq #35-1,d0
.recopie_commentaires 
 move.b 105(a1),105(a2)
 move.b 70(a1),70(a2)			On recopie les quatres chaines
 move.b 35(a1),35(a2)			simultan‚ment...
 move.b (a1)+,(a2)+
 dbra d0,.recopie_commentaires 
  
 add d7,a0

 move.l fichier,a1			Puis recopie toute l'image...
 move.l taille_image,d0
 lsr.l d0
.boucle_recopie_image
 move (a0)+,(a1)+
 subq.l #1,d0
 bne.s .boucle_recopie_image
 moveq #0,d0
 rts


sauve_image_tcp
 move.l taille_image,d0				Taille de l'image
 add #tcp_main_longueur+tcp_data_longueur,d0	+ entetes
 move.l d0,taille_fichier
 lea buffer_fichier,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_sauvegarde

 move.l buffer_fichier,a0

 move.l #'TRUE',tcp_main_identificateur(a0)	Identificateur
 move.l #'COLR',tcp_main_identificateur+4(a0)
 move.l taille_fichier,tcp_main_total_fichier(a0)	Taille du fichier
 move #tcp_main_longueur,tcp_main_offset(a0)	Longueur de l'entete
 move #1,tcp_main_version(a0)			Version 1
 move #1,tcp_main_nombre_image(a0)		1 seule image

 lea tcp_main_longueur(a0),a0			Saute l'entete MAIN

 move.l #'PICT',tcp_data_identificateur(a0)	Identificateur
 move.l taille_image,tcp_data_total_image(a0)	Taille de l'image
 move #tcp_data_longueur,tcp_data_offset(a0)	Longueur de l'entete
 move largeur_image,d0
 lsr d0
 move d0,tcp_data_largeur(a0)			Largeur de l'image
 move hauteur_image,tcp_data_hauteur(a0)	Hauteur de l'image

 move #0,tcp_data_transparent(a0)		Couleur transparente
 move couleur,tcp_data_crayon(a0)		Couleur de dessin
 
 move.b flag_compacter_image,tcp_data_packing(a0)	Y'a compactage ?
 move.b flag_sauver_palette,tcp_data_palette(a0)	Y'a palette ?

 move.b flag_overscan,tcp_data_overscan(a0)
 move.b flag_double_largeur,tcp_data_double_largeur(a0)
 move.b flag_double_hauteur,tcp_data_double_hauteur(a0)

 lea tcp_data_commentaires(a0),a1	Il ne faut pas oublier de noter
 lea infos_texte,a2			les commentaires dans le fichier.
 moveq #35-1,d0
.recopie_commentaires 
 move.b 105(a2),105(a1)
 move.b 68(a2),68(a1)			On recopie les trois chaines
 move.b 34(a2),34(a1)			simultan‚ment...
 move.b (a2)+,(a1)+
 dbra d0,.recopie_commentaires 
  
 lea tcp_data_longueur(a0),a0		Saute l'entete PICT
 
 move.l fichier,a1
 move.l taille_image,d0
 lsr.l d0
.recopie_image
 move (a1)+,(a0)+			Recopie l'image pixel par pixel...
 subq.l #1,d0
 bne.s .recopie_image
 moveq #0,d0				Tout c'est bien pass‚ !
 rts

 BSS
 
