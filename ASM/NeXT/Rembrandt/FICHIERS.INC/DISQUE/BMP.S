;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                     %
;% Format d'une image au format WINDOWS BitMap [*.BMP] %
;%                                                     %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 TEXT
 
 rsreset
bmp_entete	rs.w 1	bfType		["BM"]
bmp_longueur	rs.l 1	bfSize		Taille totale du fichier
bmp_dumy1	rs.w 1	bfReserved1	0
bmp_dumy2	rs.w 1	bfReserved2	0
bmp_offset	rs.l 1	bfOffBits	Offset du BitMap dans le fichier
bmp__rs   rs.b 1 **=__rs

 rsreset
bmp_b_taille	rs.l 1	Taille du header
bmp_b_largeur	rs.l 1	Largeur de l'image en pixels
bmp_b_hauteur	rs.l 1	Hauteur de l'image en pixels
bmp_b_nbplan	rs.w 1	1 (???)
bmp_b_nbbits	rs.w 1	Nombre de bits par pixel (cons‚cutifs)
bmp_b_compresse	rs.l 1	[0] si pas compress‚...
bmp_b_longueur	rs.l 1	Taille de l'image en octets
bmp_b_xref	rs.l 1	Echelle horizontale
bmp_b_yref	rs.l 1	Echelle verticale
bmp_b_c_util	rs.l 1	Nombre de couleurs utilis‚es
bmp_b_c_import	rs.l 1	Nombre de couleurs importantes
bmp_b__rs  rs.b 1 **=__rs

sauve_image_windows
 move.l #65536*2,d0
 lea buffer_d‚packing,a0		Bloc de d‚finition
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_sauvegarde

 move largeur_image,d0
 lsr d0
 mulu hauteur_image,d0		Taille de l'image destination
 move.l d0,d1			M‚morise pour aprŠs
 add.l #bmp__rs+bmp_b__rs,d0	Entete de d‚part

 move.l d0,taille_fichier
 lea buffer_fichier,a0
 bsr.l r‚serve_bloc
 bmi erreur_m‚moire_sauvegarde

 move.l buffer_fichier,a0

 bra hello
;
; Cr‚ation des 2 entˆtes.
;
 move #'BM',bmp_entete(a0)
 move.l taille_fichier,d0 
 rol #8,d0
 swap d0
 rol #8,d0
 move.l d0,bmp_longueur(a0)		Longueur du fichier	

 move.l #bmp__rs+bmp_b__rs,d0		Longueur des entˆtes
 rol #8,d0
 swap d0
 rol #8,d0
 move.l d0,bmp_offset(a0)		Offset du BitMap dans le fichier

 lea bmp__rs(a0),a0

 moveq #0,d0
 move largeur_image,d0
 rol #8,d0
 swap d0
 rol #8,d0
 move.l d0,bmp_b_largeur(a0)		Largeur de l'image en pixels

 moveq #0,d0
 move hauteur_image,d0
 rol #8,d0
 swap d0
 rol #8,d0
 move.l d0,bmp_b_hauteur(a0)		Largeur de l'image en pixels

 move #$0100,bmp_b_nbplan(a0)		1 (???)
 move.l #0,bmp_b_compresse(a0)		[0] si pas compress‚...

 move.l #$01000000,bmp_b_xref(a0)	Echelle horizontale
 move.l #$01000000,bmp_b_yref(a0)	Echelle verticale

 rol #8,d1
 swap d1
 rol #8,d1
 move.l d1,bmp_b_longueur(a0)		Taille de l'image en octets

 move #$0800,bmp_b_nbbits(a0)		Nombre de bits par pixel (cons‚cutifs)

 move.l #$ff000000,bmp_b_c_util(a0)	Nombre de couleurs utilis‚es
 move.l #$ff000000,bmp_b_c_import(a0)	Nombre de couleurs importantes

 move.l #bmp_b__rs,d0
 rol #8,d0
 swap d0
 rol #8,d0
 move.l d0,bmp_b_taille(a0)		Taille du header

hello
 move.l buffer_d‚packing,a0
 move.l #65536,d0
.efface
 clr.l (a0)+
 subq.l #1,d0
 bne.s .efface
 
;
; On note le nombre d'occurences des couleurs dans l'image...
;
 move.l fichier,a0
 move.l buffer_d‚packing,a1
 move.l taille_image,d0
 lsr.l d0
 moveq #0,d1
.pixel_suivant
 move (a0)+,d1
* and #%1111011110011110,d1
 addq.l #1,(a1,d1.l*4)
 subq.l #1,d0
 bne.s .pixel_suivant 

;
; On compte le nombre de couleurs dans l'image...
;
 moveq #0,d1			Aucune couleur...
 move.l buffer_d‚packing,a0
 move.l #65536,d0
.compte_suivante
 tst.l (a0)+
 beq.s .pas_trouv‚
 addq.l #1,d1
.pas_trouv‚
 subq.l #1,d0
 bne.s .compte_suivante

 lea nb_couleurs,a0
 move.l d1,d0
 bsr.l inscrit_chaine
 move.l #' cou',(a0)+
 move.l #'leur',(a0)+
 move.l #'(s).',(a0)+
 form_alert #1,#alert_nb_col

 moveq #-1,d0
 rts

alert_nb_col
 dc.b "[1][Cette image est en|"
nb_couleurs
 dc.b "                       ]"
 dc.b "[OK]",0
 even
 

trop_de_couleurs 
 form_alert #1,#alert_couleurs_exportation
 moveq #1,d0
 rts

  
charge_image_windows
 move.l buffer_fichier,a0	V‚rifie la pr‚sence de l'entete "BM"
 cmp #'BM',bmp_entete(a0)
 bne erreur_format_chargement
 move.l bmp_longueur(a0),d0
 rol #8,d0 
 swap d0
 rol #8,d0
 cmp.l taille_fichier,d0	V‚rifie la longueur du fichier (tronqu‚, mal ripp‚...)
 bne erreur_format_chargement

 move.l bmp_offset(a0),d0
 rol #8,d0
 swap d0
 rol #8,d0
 lea (a0,d0.l),a6		Pointe sur le BitMap (-->)
 
 lea bmp__rs(a0),a0		Passe au champ suivant d'infos

 move.l bmp_b_largeur(a0),d0
 rol #8,d0
 swap d0
 rol #8,d0
 add d0,d0
 move d0,largeur_image
   
 move.l bmp_b_hauteur(a0),d0
 rol #8,d0
 swap d0
 rol #8,d0
 move d0,hauteur_image
 
 bsr.l pr‚pare_buffer_image
 bne erreur_m‚moire_sauvegarde


 move bmp_b_nbbits(a0),d0	Nombre de bits par pixel (cons‚cutifs)
 rol #8,d0
 move d0,nombre_plans
 moveq #2,d1
 subq #1,d0
 lsl d0,d1
 move d1,nombre_couleurs

;
; Recodage de la palette
;
 move nombre_couleurs,d7
 subq #1,d7
 lea bmp_b__rs(a0),a0		Pointe sur la palette
 move.l a0,adresse_palette
 move.l a0,a1
 move.l a1,a5			Pointe sur la palette (-->)
.couleur_suivante
 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 move.b (a0)+,d2	Bleu
 move.b (a0)+,d1	Vert
 move.b (a0)+,d0	Rouge
 addq #1,a0
 lsl #8,d0
 and #%1111100000000000,d0
 lsl #3,d1
 and #%0000011111100000,d1
 lsr #3,d2
 and #%0000000000011111,d2
 or d2,d0
 or d1,d0
 move d0,(a1)+
 dbra d7,.couleur_suivante
;
; D‚codage du BitMap (TrŠs complexe !!!)
;
 move.l a5,a2			D‚but de la palette
 move largeur_image,d0
 lsr d0				Largeur en pixels
 move nombre_plans,d1
 mulu d1,d0			Largeur en bits (x1,x4,x8,x24)
 lsr.l #3,d0			Largeur en octets (doit etre multiple de 4 !)
 addq #3,d0
 and #-1-3,d0			Largeur multiple de 4...
 move hauteur_image,d1
 subq #1,d1
 mulu d0,d1			Offset sur la derniŠre ligne
 lea (a6,d1.l),a0		Pointe sur la derniŠre ligne de l'image
 move.l fichier,a1		Destination
 moveq #0,d7
 move hauteur_image,d1
 subq #1,d1
 
 moveq #0,d7
 cmp #8,nombre_plans
 beq bmp_256_couleurs
 cmp #4,nombre_plans
 beq bmp_16_couleurs
 bra erreur_m‚moire_sauvegarde
  
bmp_256_couleurs
.recopie_y
 move.l a0,a3
 sub d0,a0			Ligne pr‚c‚dente...
 move largeur_image,d2
 lsr d2
 subq #1,d2
.recopie_x
 move.b (a3)+,d7
 move (a2,d7.w*2),(a1)+
 dbra d2,.recopie_x
 dbra d1,.recopie_y
 moveq #0,d0
 rts

bmp_16_couleurs
.recopie_y
 move.l a0,a3
 sub d0,a0			Ligne pr‚c‚dente...
 move largeur_image,d2
 lsr #2,d2
 subq #1,d2
.recopie_x
 move.b (a3)+,d7
 move d7,d6
 and #15,d6
 lsr #4,d7
 move (a2,d7.w*2),(a1)+
 move (a2,d6.w*2),(a1)+
 dbra d2,.recopie_x
 move largeur_image,d2
 btst #1,d2
 beq.s .pas_impaire
 move.b (a3)+,d7
 lsr #4,d7
 move (a2,d7.w*2),(a1)+
.pas_impaire 
 dbra d1,.recopie_y
 moveq #0,d0
 rts
