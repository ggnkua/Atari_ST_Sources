; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion des effets graphiques. (1.3)
;
; Les effets impl‚ment‚s sont:
;
;  Global
;      Local
; - [x] [ ] Retournement vertical d'une image
; - [x] [ ] Retournement horizontal d'une image
; - [x] [ ] Rotation de 90ø dans le sens des aiguilles d'une montre
; - [x] [ ] Rotation de 90ø dans le sens inverse des aiguilles d'une montre
; - [x] [ ] Convolution 3x3
;
; - [x] [ ] Effet de flou par moyenne horizontale deux … deux
; - [x] [x] Assombrissement de l'image
; - [x] [x] claircissement de l'image
; - [x] [x] Mise en n‚gatif de l'image
; - [x] [x] Mise en niveaux de gris.
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc
 
 section TEXT


effet_retourne_horizontal
 bsr cache_zoomer_s‚lecteur
 
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr vsync
 bsr retourne_image_horizontal
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts



  
retourne_image_horizontal
 move.l ‚cran,a0		PremiŠre colonne de l'image
 move.l fichier,a1
 add largeur_image,a1		Derniere colonne de l'image

 move hauteur_image,d0		Nombre de lignes
 subq #1,d0

.ligne_suivante
 move.l a0,a2
 move.l a1,a3
 add largeur_‚cran,a0
 add largeur_image,a1

 move largeur_image,d1
 lsr d1
 subq #1,d1
.‚change_colonne
 move -(a3),(a2)+
 dbra d1,.‚change_colonne
 dbra d0,.ligne_suivante
 rts

effet_retourne_vertical
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr vsync
 bsr retourne_image_vertical
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts
 
retourne_image_vertical
 move.l ‚cran,a0		PremiŠre ligne de l'image
 move hauteur_image,d0
 subq #1,d0
 mulu largeur_image,d0
 move.l fichier,a1
 add.l d0,a1			DerniŠre ligne de l'image 

 move hauteur_image,d0		Nombre de lignes/2
 subq #1,d0
 
.ligne_suivante
 move.l a0,a2
 move.l a1,a3
 add largeur_‚cran,a0 
 sub largeur_image,a1 
 move largeur_image,d1
 lsr d1
 subq #1,d1
.‚change_lignes
 move (a3)+,(a2)+
 dbra d1,.‚change_lignes
 dbra d0,.ligne_suivante
 rts



;#
;# M‚thode utilis‚e pour faire pivoter de 90ø vers la droite:
;# 1/ - Recopier l'image vers le ECRAN_UNDO
;# 2/ - On transvase de ECRAN_UNDO vers FICHIER
;# 3/ - On ‚change les coordon‚es Largeur/Hauteur
;# 4/ - On recalcule le clipping ‚cran
;# 5/ - On r‚affiche l'image sur l'‚cran
;# 6/ - C'est tout !
;#
effet_pivote_90_droite
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr vsync
 bsr pivote_90_droite
 bsr valide_param‚trages

 lea ‚cran,a0
 move.l taille_‚cran,d0
 bsr realloc
 tst	d0
 beq .suite_rotate
 bsr pivote_90_gauche
 bsr valide_param‚trages
 ;; mettre boite d'alerte
 
.suite_rotate
 
 bsr affiche_image
 move.l sauvegarde_curseur,adresse_curseur
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts

pivote_90_droite
 rts
; move.l ‚cran_undo,a0
 move.l fichier,a1
 move largeur_image,d0
 lsr d0
 move hauteur_image,d1

 move d1,d6
 subq #1,d6
 add d1,d1
 add d1,a1				Commence en haut … droite
.boucle_horizontale
 subq #2,a1
 move.l a1,a2				D‚but de colonne
 move d0,d7
 subq #1,d7
.boucle_verticale
 move (a0)+,(a2)  
 add d1,a2
 dbra d7,.boucle_verticale
 dbra d6,.boucle_horizontale

 move d0,hauteur_image
 move d1,largeur_image
 rts


;#
;# M‚thode utilis‚e pour faire pivoter de 90ø vers la gauche:
;# 1/ - Recopier l'image vers le ECRAN_UNDO
;# 2/ - On transvase de ECRAN_UNDO vers FICHIER
;# 3/ - On ‚change les coordon‚es Largeur/Hauteur
;# 4/ - On recalcule le clipping ‚cran
;# 5/ - On r‚affiche l'image sur l'‚cran
;# 6/ - C'est tout !
;#
effet_pivote_90_gauche
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr vsync
 bsr pivote_90_gauche
 bsr valide_param‚trages


 lea ‚cran,a0
 move.l taille_‚cran,d0
 bsr realloc
 tst	d0
 beq .suite_rotate
 bsr pivote_90_droite
 bsr valide_param‚trages
 ;; mettre boite d'alerte
 
.suite_rotate

 bsr affiche_image
 move.l sauvegarde_curseur,adresse_curseur
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts

pivote_90_gauche
 rts
; move.l ‚cran_undo,a0
 move.l fichier,a1
 move largeur_image,d0
 lsr d0
 move hauteur_image,d1

 move d1,d6
 subq #1,d6

 add.l taille_image,a1
 add d1,d1
 sub d1,a1				Commence en bas … gauche
 
.boucle_horizontale
 move.l a1,a2				D‚but de colonne
 move d0,d7
 subq #1,d7
.boucle_verticale
 move (a0)+,(a2)  
 sub d1,a2
 dbra d7,.boucle_verticale
 addq #2,a1
 dbra d6,.boucle_horizontale

 move d0,hauteur_image
 move d1,largeur_image
 rts





effet_rendre_flou_global
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr applique_effet_flou_global
 bsr vsync
 bsr affiche_image
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts

;
;
; Effet de flou global par moyenne des 8 points adjacents+point central
;
; Le pixel central contient la somme des composante:
; D0=rouge
; D1=vert
; D2=bleu
;
; On bosse sur d3/d4/d5 pour les composantes RVB des autres points.
; et l'on additionne au fur et a mesure sur d0/d1/d2.
;
coef_2=1	x4=8
coef_3=0	x4=4

applique_effet_flou_global
 move largeur_image,d0

 move #0,flou_1
 sub d0,flou_1
 move #0,flou_2
 add d0,flou_2

 move #-2,flou_3
 sub d0,flou_3
 move #+2,flou_4
 sub d0,flou_4

 move #-2,flou_5
 add d0,flou_5
 move #+2,flou_6
 add d0,flou_6
 
; move.l fichier,a0
; move.l ‚cran_undo,a1
 lea table_mul20,a3
 
 move.l taille_image,d7
 lsr.l d7
 move.l d7,a6
.traite_pixel_suivant  

 move (a1),d0		Charge le pixel central lui meme.
 move d0,d2
 and #%11111,d2		D2=bleu initial
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert initial
 rol #5,d0
 and #%11111,d0		D0=rouge initial

 move (a3,d0.w*2),d0	Fort coefficient pour le point central.
 move (a3,d1.w*2),d1
 move (a3,d2.w*2),d2
 
 lea liste_points,a2

 moveq #4-1,d7
.convolue_pixel_1
 move (a2)+,d6		Charge l'adresse_du_pixel
 move (a1,d6.w),d3	Charge le pixel lui meme.
 move d3,d5
 and #%11111,d5		D5=bleu
 move d3,d4
 lsr #5,d4
 and #%111111,d4	D4=vert
 rol #5,d3
 and #%11111,d3		D3=rouge

 add d3,d0		Ajoute au total courant
 add d3,d0		Ajoute au total courant
 add d4,d1
 add d4,d1
 add d5,d2
 add d5,d2
 dbra d7,.convolue_pixel_1

 moveq #4-1,d7
.convolue_pixel_2
 move (a2)+,d6		Charge l'adresse_du_pixel
 move (a1,d6.w),d3	Charge le pixel lui meme.
 move d3,d5
 and #%11111,d5		D5=bleu
 move d3,d4
 lsr #5,d4
 and #%111111,d4	D4=vert
 rol #5,d3
 and #%11111,d3		D3=rouge

 add d3,d0		Ajoute au total courant
 add d4,d1
 add d5,d2
 dbra d7,.convolue_pixel_2

; Les composantes obtenues sont x32 (D‚call‚es de 5 pos … gauche)
  
 lsl #6,d0			Met le rouge … gauche
 and #%1111100000000000,d0
 and #%0000011111100000,d1	Le vert...
 lsr #5,d2  			Met le bleu … droite
* and #%0000000000011111,d2
 or d1,d0
 or d2,d0
   
 move d0,(a0)+
 addq #2,a1
 subq.l #1,a6				y'a plus de registres libres !
 cmp.l #0,a6
 bne .traite_pixel_suivant  
 rts




effet_rendre_flou_horizontal
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr applique_effet_flou_horizontal
 bsr vsync
 bsr affiche_image
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts

*
*
* Effet de flou horizontal par moyenne de deux points contigus...
*
applique_effet_flou_horizontal
 rts
; move.l fichier,a0
; move.l ‚cran_undo,a1
 move.l taille_image,d7
 lsr.l d7
.traite_pixel_suivant  
 move (a1)+,d0		Pixel n1
 move d0,d2
 and #%11111,d2		D2=bleu
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 move (a1),d3		Pixel n2
 move d3,d5
 and #%11111,d5		D2=bleu
 move d3,d4
 lsr #5,d4
 and #%111111,d4	D1=vert
 rol #5,d3
 and #%11111,d3		D0=rouge

 add d3,d0		Rouge
 lsr d0
 add d4,d1		Vert
 lsr d1
 add d5,d2		Bleu
 lsr d2
 
 ror #5,d0
 lsl #5,d1
 or d1,d0
 or d2,d0
   
 move d0,(a0)+
 subq.l #1,d7
 bne .traite_pixel_suivant  
 rts


effet_assombrir
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr capture_taille_max
 move.l #50,d3
 bsr applique_lumiŠre
 bsr vsync
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts

effet_‚claircir
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr capture_taille_max
 move.l #150,d3
 bsr applique_lumiŠre
 bsr vsync
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts
 
*
*
* Assombrissement de l'image si le facteur est inf‚rieur … 100,
* ‚claircissement si il est sup‚rieur … 100.
*
* En entr‚e:
* D3=Facteur d'assombrissement/claircissement

applique_lumiŠre
 bsr trie_rectangle	x1óx2 et y1óy2, sinon ca plante !
 bsr calcule_taille_effet

.traite_pixel_hauteur
 move d6,d5 
 move.l a0,a1
 add largeur_‚cran,a0
.traite_pixel_largeur
 move (a1),d0

 move d0,d2
 and #%11111,d2		D2=bleu
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 mulu d3,d0
 divu #100,d0
 cmp #31,d0
 ble.s .ok_rouge
 moveq #31,d0
.ok_rouge 
 mulu d3,d1
 divu #100,d1
 cmp #63,d1
 ble.s .ok_vert
 moveq #63,d1
.ok_vert   
 mulu d3,d2
 divu #100,d2
 cmp #31,d2
 ble.s .ok_bleu
 moveq #31,d2
.ok_bleu

 ror #5,d0
 lsl #5,d1
 or d1,d0
 or d2,d0

 move d0,(a1)+
 dbra d5,.traite_pixel_largeur
 dbra d7,.traite_pixel_hauteur
 rts




effet_n‚gativer
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr capture_taille_max
 bsr applique_n‚gatif
 bsr vsync
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts


*
*
* N‚gativation de l'image
*
*
applique_n‚gatif
 bsr trie_rectangle	x1óx2 et y1óy2, sinon ca plante !
 bsr calcule_taille_effet
 
.traite_pixel_hauteur
 move d6,d5 
 move.l a0,a1
 add largeur_‚cran,a0
.traite_pixel_largeur
 not (a1)+
 dbra d5,.traite_pixel_largeur
 dbra d7,.traite_pixel_hauteur
 rts

  


   
effet_transforme_gris
 bsr cache_zoomer_s‚lecteur
 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_sablier,adresse_curseur
 bsr vide_clavier
 bsr recopie_‚cran
 bsr capture_taille_max
 bsr applique_gris
 bsr vsync
 move.l sauvegarde_curseur,adresse_curseur
 st flag_chang‚e
 sf flag_sauv‚e
 bsr montre_zoomer_s‚lecteur
 rts

 
*
*
* Transformation en niveaux de gris...
*
*
applique_gris
 bsr trie_rectangle	x1óx2 et y1óy2, sinon ca plante !
 bsr calcule_taille_effet
 
 lea table_niveaux_gris,a2

.traite_pixel_hauteur
 move d6,d5 
 move.l a0,a1
 add largeur_‚cran,a0
.traite_pixel_largeur
 move (a1),d0
 move d0,d2
 add d2,d2
 and #%111110,d2	D2=bleu
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #6,d0
 and #%111110,d0	D0=rouge

 add d1,d0
 add d2,d0		D0=total des trois
 
 move (a2,d0.w*2),(a1)+
 dbra d5,.traite_pixel_largeur
 dbra d7,.traite_pixel_hauteur
 rts

trie_rectangle
 move x1,d0
 move x2,d1
 cmp d1,d0
 bmi .inverse_pas_x
 exg d0,d1
.inverse_pas_x
 move d0,x1
 move d1,x2

 move y1,d0
 move y2,d1
 cmp d1,d0
 bmi .inverse_pas_y
 exg d0,d1
.inverse_pas_y
 move d0,y1
 move d1,y2
 rts

calcule_taille_effet
 move.l ‚cran,a0
 move x1,d0
 add d0,d0
 add d0,a0
 move y1,d0
 mulu largeur_‚cran,d0
 add.l d0,a0		A0=adresse du coin sup‚rieur gauche … traiter...

 move y2,d7
 sub y1,d7		D7=nombre d'it‚rations en hauteur

 move x2,d6
 sub x1,d6		D6=nombre d'it‚rations en largeur
 rts

capture_taille_max
 move #0,x1		Choix des coordonn‚es ‚cran pour
 move #0,y1		appliquer l'effet...
 move largeur_image,d0
 lsr d0
 subq #1,d0
 move d0,x2
 move hauteur_image,d0
 subq #1,d0
 move d0,y2
 rts
 
 DATA

liste_points
 dc.w -2		Gauche
 dc.w +2		Droite
flou_1
 dc.w 0			Haut
flou_2
 dc.w 0			Bas


flou_3
 dc.w -2		Haut gauche
flou_4
 dc.w +2		Haut droite
flou_5
 dc.w -2		Bas gauche
flou_6
 dc.w +2		bas droite

table_mul20
var set 0
 rept 64
 dc.w var
var set var+20
 endr 

 
table_niveaux_gris
var set 0
rouge set 0
vert set 0
bleu set 0
 rept 64
 dc.w rouge<<11+vert<<5+bleu
 dc.w rouge<<11+vert<<5+bleu
 dc.w rouge<<11+vert<<5+bleu
vert set vert+1
var set 1-var
 ifeq var
rouge set rouge+1
bleu set bleu+1
 endc
 endr 
  