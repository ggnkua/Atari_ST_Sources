;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                %
;% Format d'une image TARGA [*.TGA]               %
;% +0  2 octets nuls                              %Offset =0
;% +2  2 octets pour le num‚ro de version         %
;% +4  4 octets nuls                              %
;% +8  2 octets pour l'abscisse de l'image        %
;% +10 2 octets pour l'ordonn‚e de l'image        %
;% +12 2 octets pour la largeur de l'image        %
;% +14 2 octets pour la hauteur de l'image        %
;% +16 1 octet pour le nombre de bits par pixel   %
;% +17 1 octet xxxx ????                          %Sens d'affichage !
;% +18 xxx octets d'image bitmap standard         %
;%                                                %
;% Attention, tout est cod‚ en format INTEL, et   %
;% les couleurs sont Bleu Vert Rouge              %
;%                                                %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
 rsreset
tga_header	rs.w 1
tga_version	rs.w 1
tga_null	rs.l 1
tga_abscisse	rs.w 1
tga_ordonn‚e	rs.w 1
tga_largeur	rs.w 1
tga_hauteur	rs.w 1
tga_bits	rs.b 1
tga_sens	rs.b 1	0-> … l'envers / [32|$20]-> … l'endroit
tga_image	rs.w 1

teste_image_tga 
charge_image_tga
 move.l buffer_fichier,a0
 move tga_largeur(a0),d0
 rol #8,d0
 add d0,d0
 move d0,largeur_image
 move tga_hauteur(a0),d0
 rol #8,d0
 move d0,hauteur_image

 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement

 move.l buffer_fichier,a0
 cmp.b #16,tga_bits(a0)
 beq.s transforme_tga_16_bits
 cmp.b #24,tga_bits(a0)
 beq.s transforme_tga_24_bits
 moveq #-1,d0
 rts
 
transforme_tga_16_bits
 lea tga_image(a0),a0
 move.l fichier,a1 
 move.l taille_image,d7
 lsr.l d7
 subq.l #1,d7
.boucle_remape_image_tga
 move.w (a0)+,d2
 rol #8,d2
 move d2,d3
 add d3,d3
 move d3,d4
 and #%1111100000000000,d3	Le rouge
 and #%0000011111000000,d4	Le vert
 and #%0000000000011111,d2	Le bleu
 or d3,d2
 or d4,d2
 move d2,(a1)+
 subq.l #1,d7
 bne .boucle_remape_image_tga
 moveq #0,d0
 rts
 
transforme_tga_24_bits 
 lea tga_image(a0),a0
 move.l fichier,a1 
 move.l taille_image,d7
 lsr.l d7
 subq.l #1,d7
.boucle_remape_image_tga
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 move.b (a0)+,d2		Bleu sur 8 bits
 move.b (a0)+,d1		Vert sur 8 bits
 move.b (a0)+,d0		Rouge sur 8 bits
 lsl #8,d0			Repositionne le rouge sur les bits 11 … 15
 and #%1111100000000000,d0
 lsl #3,d1			Repositionne le vert sur les bits  5 … 10
 and #%0000011111100000,d1
 lsr #3,d2			Repositionne le bleu sur les bits 0 … 4
 and #%0000000000011111,d2
 or d1,d0
 or d2,d0
 move d0,(a1)+
 subq.l #1,d7
 bne .boucle_remape_image_tga
 moveq #0,d0
 rts




sauve_image_tga_16bit
 move.l taille_image,d0				Taille de l'image
 add #18,d0					+ entetes
 move.l d0,taille_fichier
 lea buffer_fichier,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_sauvegarde

 move.l buffer_fichier,a0

 clr (a0)+		Un mot nul (Offset ?)
 move #$0200,(a0)+	TGA Type 2 (format INTEL)
 clr.l (a0)+		4 octets nuls	
 clr (a0)+		Abscisse de l'image
 clr (a0)+		Ordonn‚e de l'image
 move largeur_image,d0
 lsr d0
 rol #8,d0
 move d0,(a0)+		Largeur de l'image (format INTEL)
 move hauteur_image,d0
 rol #8,d0
 move d0,(a0)+		hauteur de l'image (format INTEL) 
 move #$1020,(a0)+	16 bits et … l'endroit
 
 move.l fichier,a1
 move.l taille_image,d7
 lsr.l d7
 moveq #9,d6		Pour le ROR qui est plus bas...
.recopie_image
 move (a1)+,d0
 and #%1111011110011110,d0
 move d0,d1
 and #%11111,d1			R‚cupŠre le bleu
 lsr d0				Le vert est sur 5 bits en TGA !
 and #%111111111100000,d0	Conserve rouge et vert
 or d1,d0			R‚introduit le bleu
 rol #8,d0			INTEL not inside...
 move d0,(a0)+
 subq.l #1,d7
 bne.s .recopie_image
 moveq #0,d0				Tout c'est bien pass‚ !
 rts

sauve_image_tga_24bit
 move.l taille_image,d0				Taille de l'image
 move.l d0,d1
 lsr.l d1
 add.l d1,d0
 add #18,d0					+ entetes
 move.l d0,taille_fichier
 lea buffer_fichier,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_sauvegarde

 move.l buffer_fichier,a0

 clr (a0)+		Un mot nul (Offset ?)
 move #$0200,(a0)+	TGA Type 2 (format INTEL)
 clr.l (a0)+		4 octets nuls	
 clr (a0)+		Abscisse de l'image
 clr (a0)+		Ordonn‚e de l'image
 move largeur_image,d0
 lsr d0
 rol #8,d0
 move d0,(a0)+		Largeur de l'image (format INTEL)
 move hauteur_image,d0
 rol #8,d0
 move d0,(a0)+		hauteur de l'image (format INTEL) 
 move #$1820,(a0)+	16 bits et … l'endroit
 
 move.l fichier,a1
 move.l taille_image,d7
 lsr.l d7
 moveq #9,d6		Pour le ROR qui est plus bas...
.recopie_image
 move (a1)+,d0

 move d0,d1
 lsl #3,d1
 and #%11111000,d1	Bleu
 move.b d1,(a0)+
 
 move d0,d1
 lsr #3,d1		Vert
 and #%11111100,d1
 move.b d1,(a0)+
 
 lsr #8,d0		Rouge
 and #%11111000,d0
 move.b d0,(a0)+
 
 subq.l #1,d7
 bne.s .recopie_image
 moveq #0,d0				Tout c'est bien pass‚ !
 rts
