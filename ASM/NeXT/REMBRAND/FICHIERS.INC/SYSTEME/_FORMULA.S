; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion de pseudo ressources 3D. (1.3)
;
; - L'adresse de la ressource doit etre mise dans ADRESSE_RESSOURCE .l
; - Possibilit‚ d'affecter un raccourci clavier … une case.
; - La taille de la ressource est calcul‚e sur TOUS ses ‚l‚ments.
; - Possibilit‚ de chainer des morceaux de ressource.
; - Un texte peut comporter des retours … la ligne.
; - On peut afficher des blocs bitmap TrueColor.
; - Possibilit‚ d'utiliser des routines USER_DEF pour l'affichage.

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc
 
 section TEXT
 
gŠre_s‚lecteur
 bsr vsync
 getmouse
 tst.w mousek
 bne.s .teste_position
 
 getkey
 bsr force_majuscule
 bsr teste_touche
 tst.l d0
 beq .pas_routine_clavier
 jsr ([objet_routine,d0.l])
.pas_routine_clavier 
 tst.b flag_ferme_formulaire
 bne.s .fin_s‚lecteur
 bra gŠre_s‚lecteur

.teste_position
 cmp #2,mousek
 beq .fin_s‚lecteur

 move mousex,d0
 cmp min_x,d0
 blt .teste_click_ext‚rieur
 cmp max_x,d0
 bgt .teste_click_ext‚rieur
 move mousey,d0
 cmp min_y,d0
 blt .teste_click_ext‚rieur
 cmp max_y,d0
 bgt .teste_click_ext‚rieur

 bsr teste_case
 tst.l d0
 beq .pas_routine_case
 jsr ([objet_routine,d0.l])
.pas_routine_case
 tst.b flag_ferme_formulaire
 beq gŠre_s‚lecteur
.fin_s‚lecteur
 relache
 rts

.teste_click_ext‚rieur
 move.l adresse_ressource,a0
 tst.l -4(a0)
 beq gŠre_s‚lecteur
 jsr ([-4,a0])  
 tst.b flag_ferme_formulaire
 beq gŠre_s‚lecteur
 rts



centre_s‚lecteur
 tst.b flag_s‚lecteur_loupe
 beq.s .centre_s‚lecteur_standard
;
; Affiche le s‚lecteur dans l'angle sup‚rieur gauche de la fenˆtre zoom‚e...
;
 move offset_loupe,d0
 lsr d0
 move d0,affiche_x
 move #20,affiche_y
 bra .fin_centre_s‚lecteur
 
.centre_s‚lecteur_standard
 move largeur_ressource,d6
 subq #1,d6
 move hauteur_ressource,d7
 subq #1,d7

 move mousex,affiche_x
 move largeur_ressource,d0	-> La moiti‚e de la ressource en largeur
 lsr d0
 neg d0
 bsr repositionne_s‚lecteur_x
 add d0,affiche_x
 
 move mousey,affiche_y
 move hauteur_ressource,d0
 lsr d0
 neg d0
 bsr repositionne_s‚lecteur_y
 add d0,affiche_y

 st flag_d‚place_s‚lecteur

 tst affiche_x
 bpl.s .ok_x
 clr affiche_x 
 sf flag_d‚place_s‚lecteur
.ok_x 

 tst affiche_y
 bpl.s .ok_y
 clr affiche_y 
 sf flag_d‚place_s‚lecteur
.ok_y

.fin_centre_s‚lecteur
 move affiche_x,d0
 add d0,min_x
 add d0,max_x

 move affiche_y,d0
 add d0,min_y
 add d0,max_y
 rts


efface_s‚lecteur
 tst.b flag_s‚lecteur_loupe
 bne .fin_efface_s‚lecteur 
 bsr vsync

 move.l fichier,a0
 move.l ‚cran_s‚l,a1
 
 move affiche_x,d0		Position lat‚rale image/‚cran
 add d0,d0
 add d0,a0
 add d0,a1

 move affiche_y,d0		Position verticale sur l'image
 mulu largeur_image,d0
 add.l d0,a0

 move affiche_y,d0		Position verticale sur l'‚cran
 mulu largeur_‚cran_s‚l,d0
 add.l d0,a1

 move hauteur_ressource,d0
.efface_ligne_s‚lecteur
 move.l a0,a2
 move.l a1,a3
 move largeur_ressource,d1
.efface_ligne 
 move (a2)+,(a3)+
 dbra d1,.efface_ligne 
 add largeur_image,a0
 add largeur_‚cran_s‚l,a1
 dbra d0,.efface_ligne_s‚lecteur
.fin_efface_s‚lecteur
 rts
 

teste_touche
 moveq #0,d0				Pas de case … priori.

 tst.l code_touche
 beq .fin_d‚codage
 move code_ascii,d1			Si c'est nul, rien n'a ‚t‚
 move code_scan,d2			press‚...
 
 move.l adresse_ressource,a0
 move.l -12(a0),a0			Liste des raccourcis claviers.
.d‚code_suivant
 cmp #-1,(a0)				Fin de la liste ???
 beq.s .fin_d‚codage

 move.b 1(a0),d3
 beq.s .pas_ascii_nul
 cmp.b d3,d1				C'est le meme code ASCII ???
 beq.s .valide_routine
.pas_ascii_nul
 move.b (a0),d3			
 beq.s .pas_scan_nul
 cmp.b d3,d2				C'est le meme SCAN code ???
 beq.s .valide_routine
.pas_scan_nul
 addq.l #6,a0				.B+.B+.L=6 octets
 bra.s .d‚code_suivant  

.valide_routine
 move.l 2(a0),a0			R‚cupŠre l'adresse de l'objet
 bsr calcule_xy_‚l‚ment			Calcule ses dimensions.
 move.l a0,d0 				Et renvoie la r‚ponse...
.fin_d‚codage 
 rts
 
teste_case
* move.l #$-1,$ffff9800.w
* bsr vsync
* move.l #0,$ffff9800.w
 
 moveq #0,d0				Pas de case … priori.
 move.l adresse_ressource,a0
 lea -longueur_d‚f(a0),a0		>>Une bidouille bien laide...
.d‚code_suivant
 lea longueur_d‚f(a0),a0		>>Pour commence en 0 !
 tst (a0)
 bpl.s .continue_d‚codage
 cmp #-1,(a0)
 beq .fin_d‚codage
 cmp #-2,(a0)				TrŠs peu probable..
 bne .fin_d‚codage
 move.l 2(a0),a0 			Effectue le lien !
.continue_d‚codage

 bsr calcule_xy_‚l‚ment
* Teste si l'on a cliqu‚ sur un objet en particulier

 tst.l objet_routine(a0)
 beq .d‚code_suivant
 
 move x1,d1
 move y1,d2
 cmp mousex,d1
 bge .d‚code_suivant
 cmp mousey,d2
 bge .d‚code_suivant

 add objet_largeur(a0),d1
 add objet_hauteur(a0),d2
 cmp mousex,d1
 ble .d‚code_suivant
 cmp mousey,d2
 ble .d‚code_suivant

 move.l a0,d0 
.fin_d‚codage 
 rts 






d‚code_ressource
 move.l adresse_ressource,a0
 lea -longueur_d‚f(a0),a0
.d‚code_suivant
 lea longueur_d‚f(a0),a0
 tst (a0)
 bpl.s .continue_d‚codage
 cmp #-1,(a0)				 Fin de la ressource
 beq .fin_d‚codage
 cmp #-2,(a0)				 Chainage demand‚
 bne .fin_d‚codage
 move.l 2(a0),a0 			Effectue le lien !
.continue_d‚codage

 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 bra .d‚code_suivant
.fin_d‚codage 
 rts


calcule_minimax
 move #9999,min_x
 move #0,max_x
 move #9999,min_y
 move #0,max_y
 move.l adresse_ressource,a0
.d‚code_suivant
 tst (a0)
 bpl.s .continue_d‚codage
 cmp #-1,(a0)				 Fin de la ressource
 beq .fin_d‚codage
 cmp #-2,(a0)				 Chainage demand‚
 bne .fin_d‚codage
 move.l 2(a0),a0 			Effectue le lien !
.continue_d‚codage


 move objet_x(a0),d0
 move objet_y(a0),d1
.teste_xmin
 cmp min_x,d0
 bpl.s .teste_ymin
 move d0,min_x
.teste_ymin 
 cmp min_y,d1
 bpl.s .teste_xmax
 move d1,min_y
.teste_xmax
 add objet_largeur(a0),d0
 cmp max_x,d0
 blt.s .teste_ymax
 move d0,max_x
.teste_ymax
 add objet_hauteur(a0),d1
 cmp max_y,d1
 blt.s .fin_test
 move d1,max_y
.fin_test

 lea longueur_d‚f(a0),a0
 bra .d‚code_suivant
.fin_d‚codage 

 move max_x,d0
 sub min_x,d0
 move d0,largeur_ressource

 move max_y,d0
 sub min_y,d0
 move d0,hauteur_ressource
 rts
 

 rsreset
objet_type	rs.w 1
objet_x		rs.w 1
objet_y 	rs.w 1
objet_largeur	rs.w 1
objet_hauteur	rs.w 1
objet_‚paisseur	rs.w 1
objet_relief	rs.w 1
objet_couleur	rs.w 1
objet_cadre	rs.w 1
objet_routine	rs.l 1
objet_texte	rs.l 1
longueur_d‚f	rs.l 1	*** C'est bidon mais ca marche

 rsreset
objet_texte_x		rs.w 1
objet_texte_y		rs.w 1
objet_texte_couleur	rs.w 1
objet_texte_message	rs.w 1
objet_texte_icone	rs.l 1

click_x	ds.w 1
click_y	ds.w 1
click_k	ds.w 1

calcule_xy_‚l‚ment
 move.l d0,-(sp)
 move objet_x(a0),d0		+0
 add affiche_x,d0
 move d0,x1
 move objet_y(a0),d0		+4
 add affiche_y,d0
 move d0,y1
 move.l (sp)+,d0
 rts

*
* En param‚trage: A0=Adresse de la structure de l'‚l‚ment … afficher
*
*
affichage_‚l‚ment
 iif cpu_time move.l #-1,$ffff9800.w
 movem.l d0-a6,-(sp)

 move.l ‚cran_s‚l,a1	Adresse de l'‚cran
 move x1,d0
 lea (a1,d0.w*2),a1	+ X x2
 move y1,d0
 mulu largeur_‚cran_s‚l,d0	+ Y x640
 add.l d0,a1
 move.l a1,r‚f‚rence_‚cran

 cmp #1,objet_relief(a0)	Si '1', c'est que l'objet n'est pas en relief.
 bne.s .objet_relief		On r‚cupŠre la couleur affect‚e au cadre,
 move objet_cadre(a0),d6	et on met tous les registres affect‚s au tra‡age
 move d6,d7			du cadre dans cette couleur
 move d6,a4
 move d6,a5
 move d6,a6
 bra .effectue_trac‚_cadre
.objet_relief

*
* Calcule les d‚grad‚s
*   
 move #(16*2048)+(32*32)+(16),d0	Par d‚faut, c'est du gris
 tst objet_cadre(a0)			mais on peut aussi d‚grader
 beq.s .cadre_gris			le contour par rapport … la
 move objet_couleur(a0),d0		couleur centrale.
.cadre_gris

 move d0,d2
 and #31,d2	Bleu
 mulu #10,d2
 lsr #6,d0
 move d0,d1
 and #31,d1	Vert
 mulu #10,d1
 lsr #5,d0
 and #31,d0	Rouge
 mulu #10,d0
 lea table_d‚grad‚,a2
 lea (a2,d1.w),a3
 lea (a2,d2.w),a4
 movem (a2,d0.w),d3-d7	Charge le rouge
 lsl #5,d3
 lsl #5,d4
 lsl #5,d5
 lsl #5,d6
 lsl #5,d7
 or (a3)+,d3	Charge le vert
 or (a3)+,d4
 or (a3)+,d5
 or (a3)+,d6
 or (a3)+,d7
 lsl #6,d3
 lsl #6,d4
 lsl #6,d5
 lsl #6,d6
 lsl #6,d7
 or (a4)+,d3	Charge le bleu
 or (a4)+,d4
 or (a4)+,d5
 or (a4)+,d6
 or (a4)+,d7
 move d7,a6
 move d6,a5
 move d5,a4
 move d4,d7
 move d3,d6
*
* Commence par remplir l'int‚rieur
*  

 tst objet_relief(a0)
 beq.s .ok_relief
 exg d6,a6
 exg d7,a5
.ok_relief
 
.effectue_trac‚_cadre
 move objet_couleur(a0),d5
 
 move objet_hauteur(a0),d1
.loop_y
 move.l a1,a2
 move objet_largeur(a0),d0
.loop_x
 move d5,(a2)+		La couleur d'origine
 dbra d0,.loop_x
 add largeur_‚cran_s‚l,a1
 dbra d1,.loop_y
 
*
* Puis le pourtour avec l'‚clairage
*
* d6--d7--a4
*  |      |
* d7      a5
*  |      |
* a4--a5--a6
*
 move objet_‚paisseur(a0),d3
 move objet_largeur(a0),largeur_cadre
 move objet_hauteur(a0),hauteur_cadre
‚paissie_cadre
 move.l r‚f‚rence_‚cran,a1

 move.l a1,a2
 move d6,(a2)+		Le pixel blanc en haut … gauche
 move largeur_cadre,d2
 subq #2,d2
.loop_x_haut
 move d7,(a2)+		La bande gris claire du haut
 dbra d2,.loop_x_haut
 move a4,(a2)+		Le pixel gris en haut … droite

 move hauteur_cadre,d1
 subq #2,d1
 move largeur_cadre,d2
 add d2,d2
.loop_y_milieu
 add largeur_‚cran_s‚l,a1
 move d7,(a1)
 move a5,(a1,d2.w)
 dbra d1,.loop_y_milieu

 add largeur_‚cran_s‚l,a1
 move a4,(a1)+		Le pixel gris en bas … gauche
 move largeur_cadre,d2
 subq #2,d2
.loop_x_bas
 move a5,(a1)+		La bande gris sombre du bas
 dbra d2,.loop_x_bas
 move a6,(a1)+		Le pixel noir en bas … droite

 move.l r‚f‚rence_‚cran,a1
 subq #2,largeur_cadre
 subq #2,hauteur_cadre
 addq #1,x1
 addq #1,y1
 add largeur_‚cran_s‚l,a1
 addq #2,a1
 move.l a1,r‚f‚rence_‚cran
 dbra d3,‚paissie_cadre

 move.l objet_texte(a0),a2
 cmp.l #0,a2
 beq fin_affichage_‚l‚ment

 move (a2)+,d0			Offset en X
 cmp #-1,d0			Un offset n‚gatif indique la pr‚sence d'une
 bne.s .pas_routine_user_def	d'affichage sp‚cifique … cet objet.
;
; La routine USER_DEF re‡oit en param‚trages:
; A0 -> Pointe sur la structure de l'objet courant [Ex: objet_largeur(a0) ]
; A1 -> Adresse ‚cran de base de la bordure ext‚rieure de l'objet.
; A2 -> Adresse ‚cran de la bordure int‚rieure de l'objet.
;
 move objet_‚paisseur(a0),d1
 addq #1,d1
 add d1,d1
 move objet_largeur(a0),largeur_int‚rieure
 sub d1,largeur_int‚rieure
 move objet_hauteur(a0),hauteur_int‚rieure
 sub d1,hauteur_int‚rieure
 jsr ([a2])			Ex‚cute la routine G_USER_DEF
 bra fin_affichage_‚l‚ment
 
.pas_routine_user_def 
 add d0,d0		… rajouter … l'adresse de l'‚cran
 add d0,a1		
 move (a2)+,d0		+ l'offset vertical, et ca roule...
 mulu largeur_‚cran_s‚l,d0
 add.l d0,a1
 move (a2)+,d7		d7 = couleur d'affichage du texte

 tst (a2)		V‚rifie si c'est un texte ou une image
 beq gestion_affichage_icone
   
 lea fonte,a3
 move.l a1,a6
  
lettre_suivante
 moveq #0,d0
 move.b (a2)+,d0 		Prends le code ASCII du caractŠre
 beq fin_affichage_‚l‚ment	si 0, termin‚
 cmp.b #13,d0
 bne.s .pas_saut_de_ligne
 move largeur_‚cran_s‚l,d0
 lea (a6,d0.w*8),a6
 move.l a6,a1
 bra lettre_suivante
.pas_saut_de_ligne
 mulu #72,d0
 lea (a3,d0.w),a4	Adresse du caractŠre d‚sir‚
 move.l a1,a5		Adresse d'affichage du caractŠre
 moveq #6-1,d0
.affiche_lettre
 moveq #0,d3
 moveq #6-1,d1
.affiche_rang‚e 
 move (a4)+,d2
 beq .affiche_pas_pixel
 move d7,(a5,d3.w)
.affiche_pas_pixel
 addq #2,d3
 dbra d1,.affiche_rang‚e
 add largeur_‚cran_s‚l,a5
 dbra d0,.affiche_lettre 
 lea 12(a1),a1
 bra lettre_suivante

*
* On a d‚ja l'adresse d'affichage en A0.
*
gestion_affichage_icone
 move.l 2(a2),a2			Adresse de d‚but du bloc image
 move (a2)+,d0				Largeur en pixels
 move (a2)+,d1				Idem pour la hauteur
 subq #1,d0
 subq #1,d1
.recopie_icone_y
 move d0,d2

 move.l a1,a3
.recopie_icone_x
 move (a2)+,(a3)+			Recopie de facon trŠs optimis‚e !
 dbra d2,.recopie_icone_x
 add largeur_‚cran_s‚l,a1
 dbra d1,.recopie_icone_y

fin_affichage_‚l‚ment 

 movem.l (sp)+,d0-a6
 iif cpu_time move.l #0,$ffff9800.w
 rts


routine_d‚place_cadre
 tst.b flag_s‚lecteur_loupe
 bne.s .d‚placement_interdit
 tst.b flag_d‚place_s‚lecteur
 bne.s .d‚placement_autoris‚
.d‚placement_interdit
 rts
.d‚placement_autoris‚
 move.l adresse_ressource,a0		R‚cupŠre l'adresse du bloc de d‚f
 move.l -8(a0),a0			du titre. [Ptet qu'en 030 ???]
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 move mousex,click_x
 move mousey,click_y
 
 move largeur_ressource,d6
 move hauteur_ressource,d7

 moveq #0,d0
 move d7,d0
 mulu largeur_image,d0
 moveq #0,d5
 move d6,d5
 add d5,d5
 add.l d0,d5		Offset sur coin inf‚rieur droit du bloc.
 move.l d5,offset_bloc_image

 moveq #0,d0
 move d7,d0
 mulu largeur_‚cran_s‚l,d0
 moveq #0,d5
 move d6,d5
 add d5,d5
 add.l d0,d5		Offset sur coin inf‚rieur droit du bloc.
 move.l d5,offset_bloc_‚cran
 
 subq #1,d6
 subq #1,d7

 move.l ‚cran_s‚l,a0
 move affiche_x,d0
 lea (a0,d0.w*2),a0
 move affiche_y,d0
 mulu largeur_‚cran_s‚l,d0
 add.l d0,a0
 move.l a0,a1
   
.attend_click
 bsr vsync
 getmouse
 tst mousek
 beq .lache_click

 move affiche_x,old_affx
 move affiche_y,old_affy
 
 move mousex,d0
 sub click_x,d0

 bsr repositionne_s‚lecteur_x
 move d0,d‚placement_lat‚ral
 add d0,min_x
 add d0,max_x
 add d0,affiche_x
 add d0,d0
 add d0,a0

 move mousey,d0
 sub click_y,d0

 bsr repositionne_s‚lecteur_y
 move d0,d‚placement_vertical
 add d0,min_y
 add d0,max_y
 add d0,affiche_y
 muls largeur_‚cran_s‚l,d0
 add.l d0,a0

**** Transfert de bloc
 cmp.l a1,a0
 beq .pas_transfert
 bmi .remonte_bloc
.descend_bloc
 bsr vsync

 lea 2(a1,d5.l),a2
 lea 2(a0,d5.l),a3
   
 move d7,d4
 addq #1,d4
.copie_y1
 move d6,d3
 addq #1,d3
 move.l a2,a4
 move.l a3,a5
.copie_x1
 move -(a4),-(a5)
 dbra d3,.copie_x1
 sub largeur_‚cran_s‚l,a2
 sub largeur_‚cran_s‚l,a3
 dbra d4,.copie_y1
 clr.l $ffff9800.w
 bra .fin_transfert

.remonte_bloc
 bsr vsync

 move.l a1,a2
 move.l a0,a3
 
 move d7,d4
 addq #1,d4
.copie_y
 move d6,d3
 addq #1,d3
 move.l a2,a4
 move.l a3,a5
.copie_x
 move (a4)+,(a5)+
 dbra d3,.copie_x
 add largeur_‚cran_s‚l,a2
 add largeur_‚cran_s‚l,a3
 dbra d4,.copie_y
 bra .fin_transfert


.fin_transfert
 tst d‚placement_lat‚ral
 beq .pas_d‚placement_lat‚ral
 bmi .d‚placement_gauche
.d‚placement_droite
 bsr recopie_bande_gauche
 bra .pas_d‚placement_lat‚ral
.d‚placement_gauche
 bsr recopie_bande_droite
 bra .pas_d‚placement_lat‚ral
.pas_d‚placement_lat‚ral

 tst d‚placement_vertical
 beq .pas_d‚placement_vertical
 bmi .d‚placement_haut
.d‚placement_bas
 bsr recopie_bande_haut
 bra .pas_d‚placement_vertical
.d‚placement_haut
 bsr recopie_bande_bas
 bra .pas_d‚placement_vertical
.pas_d‚placement_vertical

.pas_transfert 
 
**** Fin de transfert de bloc

 move.l a0,a1
 move mousex,click_x
 move mousey,click_y
   
 bra .attend_click

.lache_click

 move.l adresse_ressource,a0		Idem qu'au d‚but, c'est l'adresse
 move.l -8(a0),a0			du bloc de titre de la ressource.
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 rts

d‚placement_lat‚ral	ds.w 1
d‚placement_vertical	ds.w 1

repositionne_s‚lecteur_x
 move affiche_x,d1
 add d0,d1		Ca donne X_min
 bpl .ok_min_x		On ‚vite de sortir par la gauche de l'‚cran !
 moveq #0,d0		Ca fait mauvais genre...
 sub affiche_x,d0
.ok_min_x 

 move affiche_x,d1	On est pas cens‚ non plus sortir par la droite.
 add d0,d1		Mais on ne sait jamais !
 add d6,d1		Ca donne X_max
 move largeur_maximum,d2
 lsr d2
 subq #1,d2
 cmp d2,d1		Si on d‚passe … droite:
 blt .ok_max_x
 move d2,d0		Maximum droite
 subq #1,d0
 sub d6,d0		- Largeur de la ressource
 sub affiche_x,d0	= Position d'affichage
.ok_max_x 
 rts

repositionne_s‚lecteur_y
 move affiche_y,d1
 add d0,d1
 bpl .ok_min_y		On ‚vite de sortir par le haut de l'‚cran !
 moveq #0,d0		C'est pas terrible non plus...
 sub affiche_y,d0
.ok_min_y

 move affiche_y,d1	Quand … la sortie par le bas de l'‚cran...
 add d0,d1		La honte !!!
 add d7,d1
 move hauteur_maximum,d2
 subq #1,d2
 cmp d2,d1
 blt .ok_max_y
 move d2,d0
 subq #1,d0
 sub d7,d0
 sub affiche_y,d0
.ok_max_y
 rts


recopie_bande_haut
 move.l fichier,a4		Reprendre le point de r‚f‚rence sur
 add old_affx,a4		l'image source (XXX*2+YYY*largeur_image)
 add old_affx,a4
 move old_affy,d0
 mulu largeur_image,d0
 add.l d0,a4
  
 move.l a1,a2
 move d‚placement_vertical,d1
 subq #1,d1
.recopie_y
 move d6,d0		Largeur de la bande
 addq #1,d0
 move.l a4,a5
 move.l a2,a3
.recopie_x
 move (a5)+,(a3)+
 dbra d0,.recopie_x
 add largeur_image,a4
 add largeur_‚cran_s‚l,a2
 dbra d1,.recopie_y
 rts

recopie_bande_bas
 lea (a1,d5.l),a2

 move.l fichier,a4
 add old_affx,a4		l'image source (XXX*2+YYY*largeur_image)
 add old_affx,a4
 move old_affy,d0
 mulu largeur_image,d0
 add.l d0,a4
 add.l offset_bloc_image,a4

 addq #2,a2
 addq #2,a4
 move d‚placement_vertical,d1
 neg d1
 subq #1,d1
.recopie_y
 move d6,d0		Largeur de la bande
 addq #1,d0
 move.l a4,a5
 move.l a2,a3
.recopie_x
 move -(a5),-(a3)
 dbra d0,.recopie_x
 sub largeur_image,a4
 sub largeur_‚cran_s‚l,a2
 dbra d1,.recopie_y
 rts

recopie_bande_gauche
 move.l a1,a2

 move.l fichier,a4		Reprendre le point de r‚f‚rence sur
 add old_affx,a4		l'image source (XXX*2+YYY*largeur_image)
 add old_affx,a4
 move old_affy,d0
 mulu largeur_image,d0
 add.l d0,a4

 move d‚placement_lat‚ral,d4
 subq #1,d4
 move d7,d1
 addq #1,d1
.recopie_y
 move d4,d0
 move.l a4,a5
 move.l a2,a3
.recopie_x
 move (a5)+,(a3)+
 dbra d0,.recopie_x
 add largeur_image,a4
 add largeur_‚cran_s‚l,a2
 dbra d1,.recopie_y
 rts

recopie_bande_droite    
 move.l a1,a2
 add.l d5,a2

 move.l fichier,a4
 add old_affx,a4		l'image source (XXX*2+YYY*largeur_image)
 add old_affx,a4
 move old_affy,d0
 mulu largeur_image,d0
 add.l d0,a4
 add.l offset_bloc_image,a4

 addq #2,a2
 addq #2,a4
 move d‚placement_lat‚ral,d4
 neg d4
 subq #1,d4
 move d7,d1
 addq #1,d1
.recopie_y
 move d4,d0
 move.l a4,a5
 move.l a2,a3
.recopie_x
 move -(a5),-(a3)
 dbra d0,.recopie_x
 sub largeur_image,a4
 sub largeur_‚cran_s‚l,a2
 dbra d1,.recopie_y
 rts

 section DATA
 even
 
fonte		incbin fichiers.inc\curseurs\6x6_fnt.tru
fonte_3x5
 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$ffff,$ffff

 dc.w $0000,$ffff,$0000
 dc.w $0000,$ffff,$0000
 dc.w $0000,$ffff,$0000
 dc.w $0000,$ffff,$0000
 dc.w $0000,$ffff,$0000

 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$0000
 dc.w $ffff,$ffff,$ffff

 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $0000,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $ffff,$ffff,$ffff

 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $0000,$0000,$ffff

 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$0000
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $ffff,$ffff,$ffff

 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$0000
 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$ffff,$ffff

 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $0000,$0000,$ffff

 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$ffff,$ffff

 dc.w $ffff,$ffff,$ffff
 dc.w $ffff,$0000,$ffff
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$ffff
 dc.w $ffff,$ffff,$ffff

 dc.w $0000,$0000,$0000
 dc.w $0000,$ffff,$0000
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$ffff,$0000
 dc.w $0000,$0000,$0000

 dc.w $0000,$0000,$0000
 dc.w $0000,$0000,$0000
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$0000
 dc.w $0000,$0000,$0000

 dc.w $0000,$0000,$0000
 dc.w $ffff,$0000,$ffff
 dc.w $0000,$ffff,$0000
 dc.w $ffff,$0000,$ffff
 dc.w $0000,$0000,$0000

 dc.w $0000,$0000,$0000
 dc.w $0000,$ffff,$0000
 dc.w $0000,$0000,$0000
 dc.w $0000,$ffff,$0000
 dc.w $0000,$0000,$0000

 dc.w $0000,$0000,$0000
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$0000
 dc.w $ffff,$ffff,$ffff
 dc.w $0000,$0000,$0000

 dc.w $0000,$0000,$0000
 dc.w $0000,$0000,$0000
 dc.w $0000,$0000,$0000
 dc.w $0000,$0000,$0000
 dc.w $0000,$0000,$0000


table_couleur_grise
 code_rvb 31,63,31	Blanc
 code_rvb 24,48,24	Gris clair
 code_rvb 16,32,16	Gris
 code_rvb 12,24,12	Gris sombre
 code_rvb 10,20,10	Noir

table_d‚grad‚
var set 0
 rept 32
var1 set var+(32-var)*50/100
var2 set var+(32-var)*35/100
 dc.w var1,var2
 dc.w var
var1 set var*70/100
var2 set var*50/100
 dc.w var1,var2
var set var+1 
 endr

*
* Explication du format:
* -12 .l (raccourcis)		Liste des raccourcis claviers.
* -8  .l (titre)		Adresse de l'objet titre.
* -4  .l (ext‚rieur)		Routine … ex‚cuter si on clique en dehors.
* {Adresse de base}
* +0  .w (ob_type)		Type de l'objet (R‚f‚renc‚ GEM)
* +2  .w (x,y)			Coordonn‚es du point en haut … gauche
* +4  .w (l,h)			Largeur et hauteur du cadre
* +6  .w (‚paisseur)		Nombre de bordures … tracer
* +8  .w (relief)		Creu (-1) ou bosse (0), ou cadre de couleur fixe (couleur cadre !)
* +10 .w (couleur centre)
* +12 .w (couleur cadre)	Gris (0) ou de la couleur principale (-1)
* +16 .l (s‚lection)		Adresse de la routine de gestion, sinon (0)
* +20 .l (texte)		Adresse d'un chaine de caractŠres, sinon (0)
*
* si en +0 on … -1	-> Fin de la ressource
*		-2	-> Lien vers un autre morceau de ressource.


 section BSS
 even
 
min_x			ds.w 1
max_x			ds.w 1
min_y			ds.w 1
max_y			ds.w 1

largeur_cadre		ds.w 1	Copie de OBJET_LARGEUR(A0) utilis‚ pour le
hauteur_cadre		ds.w 1	tra‡age des bordures d'‚paisseur variable.

largeur_int‚rieure	ds.w 1	Dimensions int‚rieures de l'objet courant.
hauteur_int‚rieure	ds.w 1

flag_ferme_formulaire	ds.w 1
affiche_x		ds.w 1
affiche_y		ds.w 1

largeur_ressource	ds.w 1
hauteur_ressource	ds.w 1

adresse_ressource	ds.l 1
sauvegarde_curseur	ds.l 1

offset_bloc_‚cran	ds.l 1
offset_bloc_image	ds.l 1

r‚f‚rence_‚cran		ds.l 1	Un pointeur sur la zone de l'‚cran o— l'on travaille...

old_affx		ds.w 1
old_affy		ds.w 1

‚cran_s‚l		ds.l 1
largeur_‚cran_s‚l	ds.l 1
