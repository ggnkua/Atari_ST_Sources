;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                %
;% Format d'une image INSHAPE [*.IIM]             %
;% +0  ®IS_IMAGE¯ identificateur                  %Offset =0
;% +8  2 octets inconnus (00,04)
;% +10 2 octets inconnus (00,18)
;% +12 2 octets Largeur
;% +14 2 octets Hauteur
;% +16 xxx octets RVB 24bits
;%                                                %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
 rsreset
inshape_header	rs.b 8
inshape_unknw	rs.w 1
inshape_bits	rs.w 1
inshape_largeur	rs.w 1
inshape_hauteur	rs.w 1
inshape_image	rs.b 1

dbg
teste_image_inshape
charge_image_inshape
 move.l buffer_fichier,a0
 cmp.l #"IS_I",(a0)
 bne erreur_format_chargement
 cmp.l #"MAGE",4(a0)
 bne erreur_format_chargement
 
 move inshape_largeur(a0),d0
 add d0,d0
 move d0,largeur_image
 move inshape_hauteur(a0),d0
 move d0,hauteur_image

 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement

 move.l buffer_fichier,a0
 lea inshape_image(a0),a0
 move.l fichier,a1 
 move.l taille_image,d7
 lsr.l d7
 subq.l #1,d7
.boucle_remape_image_tga
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 move.b (a0)+,d0		Rouge sur 8 bits
 move.b (a0)+,d1		Vert sur 8 bits
 move.b (a0)+,d2		Bleu sur 8 bits
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
