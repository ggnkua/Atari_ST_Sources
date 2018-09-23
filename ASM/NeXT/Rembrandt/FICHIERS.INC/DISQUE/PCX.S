;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                 %
;% Format d'une image PCX [*.PCX]                  %
;%                                                 %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT

 rsreset
pcx_creator	rs.b 1		10
pcx_version	rs.b 1 		5
pcx_coding	rs.b 1		1
pcx_bits	rs.b 1		8
pcx_x1		rs.w 1		0
pcx_y1		rs.w 1		0
pcx_x2		rs.w 1		320
pcx_y2		rs.w 1		240
pcx_largeur	rs.w 1
pcx_hauteur	rs.w 1
pcx_colormap	rs.b 48
pcx_reserved	rs.b 1
pcx_nb_plans	rs.b 1
pcx_taille_plan	rs.w 1
pcx_color_info	rs.w 1
pcx_filler	rs.b 58
pcx_data	rs.w 1
 
teste_image_pcx
charge_image_pcx
 move.l buffer_fichier,a0
kkk
 move pcx_x2(a0),d0
 rol #8,d0
 move pcx_x1(a0),d1
 rol #8,d1
 sub d1,d0
 addq #1,d0
 add d0,d0
 move d0,largeur_image

 move pcx_y2(a0),d2
 rol #8,d2
 move pcx_y1(a0),d1
 rol #8,d1
 sub d1,d2
 addq #1,d2
 move d2,hauteur_image

 mulu d2,d0
 move.l d0,taille_image 
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_chargement
 move.l fichier,a1

 move pcx_taille_plan(a0),d0
 rol #8,d0
 moveq #0,d1
 move.b pcx_nb_plans(a0),d1
 move d1,nombre_plans
 mulu d1,d0
 move.l d0,longueur_ligne

; adr%=pic%+l-768+i*3
; rouge=SHL(BYTE{adr%+0} AND &X11111000,8)
; vert=SHL(BYTE{adr%+1} AND &X11111100,3)
; bleu=SHR(BYTE{adr%+2} AND &X11111000,3)
; couleur(i)=rouge+vert+bleu

;
; On recode la palette sur elle mˆme...
; 
 move.l buffer_fichier,a0
 add.l taille_fichier,a0
 sub.l #768,a0
 move.l a0,a2
 move.l a0,adresse_palette
 move #256-1,d7
.fait_palette
 move.b (a0)+,d0
 and #%11111000,d0
 lsl #8,d0
 move.b (a0)+,d1
 and #%11111100,d1
 lsl #3,d1
 move.b (a0)+,d2
 and #%11111000,d2
 lsr #3,d2
 or d1,d0
 or d2,d0
 move d0,(a2)+
 dbra d7,.fait_palette
   
 move.l buffer_fichier,a0
 lea pcx_data(a0),a0
 move.l taille_fichier,d7
 sub.l #128+769,d7			Taille du fichier pack‚.
 move.l fichier,a1
 move.l adresse_palette,a2
 bsr d‚code_pcx
 moveq #0,d0
 rts


*FOR  each  byte,  X,  read from the file
*	IF the top two bits of X are  1's then
*		count = 6 lowest bits of X
*		data = next byte following X
*	ELSE
*		count = 1
*		data = X

d‚code_pcx
octet_suivant
 moveq #0,d0
 move.b (a0)+,d0
 subq.l #1,d7
 beq fin_d‚codage
 
 move d0,d1
 lsr #6,d1
 cmp #3,d1
 bne cas_2

cas_1
 and #%111111,d0	Nombre de r‚p‚titions
 subq #1,d0
 move.b (a0)+,d1	L'octet … r‚p‚ter
 subq.l #1,d7
 beq fin_d‚codage

recopie_octet
 move (a2,d1.w*2),(a1)+
 dbra d0,recopie_octet
 bra octet_suivant 
  
cas_2
 move (a2,d0.w*2),(a1)+
 bra octet_suivant 

fin_d‚codage
 rts

erreur_pcx
 moveq #-1,d0
 rts
 
 BSS
 
longueur_ligne	ds.l 1

  