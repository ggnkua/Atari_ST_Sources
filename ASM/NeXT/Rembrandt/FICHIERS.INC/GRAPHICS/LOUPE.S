;
; REMBRANDT 3.0 - ½  Dbug II
;
; Module de loupe fa‡on CrackArt/Degas. (1.0)
;
;
; Signification des bits de D0:
; 0 - SHIFT droit	4 - CAPS LOCK
; 1 - SHIFT gauche	5 - CLR HOME (bouton droit)
; 2 - CONTROL		6 - INSERT (bouton gauche)
; 3 - ALTERNATE
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT


s‚lectionne_zone_loupe
 bsr cache_curseur
 force_int‚rieur

 bsr calcule_grosseur_loupe

 relache			On attend que le bouton soit relach‚ !

 move #$f0f0,couleur_cycling	Les belles couleurs !!! Pour le cadre qui d‚fille...
 
.boucle_s‚lectionne_zone
 getmouse
 force_int‚rieur

 move largeur_loupe,d1
 lsr d1
 move mousex,d0
 sub d1,d0
 bpl.s .ok_x1
 moveq #0,d0		Si on d‚passe … gauche, on force … gauche
.ok_x1 
 move d0,x1
 add largeur_loupe,d0
 move largeur_image,d1
 lsr d1
 subq #1,d1
 cmp d1,d0
 ble.s .ok_x2
 move d1,d0		Si on d‚passe … droite, on force … droite
.ok_x2  
 move d0,x2
 sub largeur_loupe,d0
 move d0,x1
 
 move hauteur_loupe,d1
 lsr d1
 move mousey,d0
 sub d1,d0
 bpl.s .ok_y1
 moveq #0,d0		Si on d‚passe en haut, on force en haut
.ok_y1 
 move d0,y1
 add hauteur_loupe,d0
 move hauteur_image,d1
 subq #1,d1
 cmp d1,d0
 ble.s .ok_y2
 move d1,d0		Si on d‚passe par le bas, on force en bas
.ok_y2
 move d0,y2
 sub hauteur_loupe,d0
 move d0,y1
 
 move #2,type_ligne	On colorie en mode m‚morisation
 bsr trace_cadre_vide
 bsr vsync

 move #1,type_ligne	On redessine avec la bonne couleur
 bsr trace_cadre_vide

 cmp #1,mousek
 beq .valide_loupe
 cmp #2,mousek
 beq .quitte_loupe

 move couleur_cycling,d0
 rol d0
 move d0,couleur_cycling

 tst.b flag_touche_press‚e
 beq .boucle_s‚lectionne_zone
 getkey
 move code_scan,d0
 cmp.b #$3b,d0
 blt .boucle_s‚lectionne_zone
 cmp.b #$44,d0 
 bgt .boucle_s‚lectionne_zone
 bsr initialise_taille_loupe
 bsr calcule_grosseur_loupe

 bra .boucle_s‚lectionne_zone

.valide_loupe
 sf flag_quitte_loupe
 relache
 bsr montre_curseur
 rts

.quitte_loupe
 st flag_quitte_loupe
 relache
 bsr montre_curseur
 rts

;*********************
 
module_loupe
 bsr recopie_‚cran
 bsr initialise_taille_loupe
 bsr cache_zoomer_s‚lecteur
boucle_module_loupe
 bsr s‚lectionne_zone_loupe
 tst.b flag_quitte_loupe
 beq.s .loupe_demand‚e
 bsr vsync
 bsr montre_zoomer_s‚lecteur
 rts

.loupe_demand‚e
 move.l xy1,xy_loupe		On affiche au moins la bonne zone !!!

 move flag_scrolling,-(sp)
 move.b $484.w,-(sp)
 bset #1,$484.w

 sf flag_scrolling		Interdire le scroll hard durant la loupe
 sf flag_quitte_loupe
 move puissance_loupe,old_puissance_loupe
 
 bsr vsync
 bsr pr‚pare_loupe
 bsr calcule_grosseur_loupe
 bsr affiche_loupe_degas
boucle_loupe
 getmouse
 bsr teste_s‚paration_loupe

 cmp #1,mousek
 bne.s .pas_bouton_gauche
 bsr bouton_gauche_loupe
.pas_bouton_gauche 

 cmp #2,mousek
 bne.s .pas_bouton_droit
 bsr bouton_droit_loupe
.pas_bouton_droit
 
 getkey
 bsr force_majuscule
 
 move code_scan,d0
 move code_ascii,d1

 lea liste_touches_loupe,a0
.cherche_suivant
 move (a0)+,d2		Scan.b + Acii.b
 beq .fin_recherche_touche
 move.l (a0)+,a1

 tst.b d2
 beq .teste_scan_code
 
.teste_ascii
 cmp.b d1,d2
 beq .ex‚cute_routine
 bne .cherche_suivant
 
.teste_scan_code
 rol #8,d2
 cmp.b d0,d2
 bne .cherche_suivant
 
.ex‚cute_routine
 jsr (a1)
 bsr vide_clavier

.fin_recherche_touche
* bsr v‚rifie_touche_outils
 tst.b flag_quitte_loupe
 beq boucle_loupe

fin_boucle_loupe
 relache
***
 bsr vsync
 bsr efface_‚cran_loupe		Un peu de nettoyage avant de quitter
 bsr affiche_image		Puis r‚affiche tout comme il le faut !
 move.b (sp)+,$484.w
 move (sp)+,flag_scrolling
 bsr vsync
 bra boucle_module_loupe
* bsr montre_zoomer_s‚lecteur
* rts

 
*
* dc.b scan_code,code_ascii
* dc.l adresse_routine
*
liste_touches_loupe
 dc.b 0,' '			ESPACE
 dc.l s‚lecteur_de_couleur_loupe
* dc.b $61,0			UNDO
* dc.l routine_undo
 dc.b $4b,0			
 dc.l loupe_gauche
 dc.b $4d,0			
 dc.l loupe_droite
 dc.b $48,0			
 dc.l loupe_haut
 dc.b $50,0			
 dc.l loupe_bas
 dc.b $6d,0			1
 dc.l loupe_bas_gauche
 dc.b $6e,0			2
 dc.l loupe_bas
 dc.b $6f,0			3
 dc.l loupe_bas_droite
 dc.b $6a,0			4
 dc.l loupe_gauche
 dc.b $6c,0			6
 dc.l loupe_droite
 dc.b $67,0			7
 dc.l loupe_haut_gauche
 dc.b $68,0			8
 dc.l loupe_haut
 dc.b $69,0			9
 dc.l loupe_haut_droite
 dc.b $3b,0			F1
 dc.l change_taille_loupe
 dc.b $3c,0			F2
 dc.l change_taille_loupe
 dc.b $3d,0			F3
 dc.l change_taille_loupe
 dc.b $3e,0			F4
 dc.l change_taille_loupe
 dc.b $3f,0			F5
 dc.l change_taille_loupe
 dc.b $40,0			F6
 dc.l change_taille_loupe
 dc.b $41,0			F7
 dc.l change_taille_loupe
 dc.b $42,0			F8
 dc.l change_taille_loupe
 dc.b $43,0			F9
 dc.l change_taille_loupe
 dc.b $44,0			F10
 dc.l change_taille_loupe
 dc.b 1,0			ESCAPE ???
 dc.l quitte_loupe_perdu
 dc.b $72,0			ENTER ???
 dc.l quitte_loupe_m‚morise
 dc.b $1c,0			RETURN ???
 dc.l quitte_loupe_m‚morise
  
 dc.b 0,'*'
 dc.l loupe_segmente
 dc.b 0,'-'
 dc.l loupe_diminue
 dc.b 0,'+'
 dc.l loupe_augmente
 dc.w 0
 dc.l 0


;
; Si on choisie ESCAPE, on quitte sans m‚moriser les modifs (un UNDO quoi !)
; Si on choisie ENTER ou RETURN, on quitte en sauvant...
;
quitte_loupe_m‚morise
quitte_loupe_perdu
 st flag_quitte_loupe
 rts
 
;
;
initialise_taille_loupe
 lea liste_tailles_loupe,a0
 move code_scan,d0
 sub.b #$3b,d0
 ext.w d0
 move (a0,d0.w*2),puissance_loupe
 rts

change_taille_loupe
 move puissance_loupe,old_puissance_loupe
 bsr initialise_taille_loupe
 move puissance_loupe,d0
 cmp old_puissance_loupe,d0
 beq.s .mˆme_taille_choisie
 move d0,puissance_loupe
 bsr pr‚pare_loupe
 bsr calcule_grosseur_loupe
 bsr affiche_loupe_degas
 rts
.mˆme_taille_choisie
 st flag_quitte_loupe
 rts

 
teste_s‚paration_loupe
 move.l #curseur_crayon_dessin,d7
 move offset_loupe,d0
 lsr d0
 move d0,d1
 subq #1,d0
 addq #1,d1
 cmp mousex,d0
 bgt.s .pas_zone_sup
 cmp mousex,d1
 blt.s .pas_zone_sup
 move.l #curseur_tire_horizontal,d7
.pas_zone_sup
 move.l d7,adresse_curseur
 rts
 

bouton_gauche_loupe
 rts

;@
;@ Le bouton droit:
;@ - Si le click bouton droit est prolong‚, on passe en mode de capture de
;@   couleur.
;@ - Si le click bouton droit est bref, cela fait apparaitre le menu de
;@   s‚lection des outils. Yeahhh... C'est l'id‚e g‚niale.
;@
bouton_droit_loupe
 moveq #10,d0			10 Vbl... Est'ce suffisant ???
.attend_bouton
 bsr vsync
 getmouse			Lecture de la souris
 tst mousek
 beq .validation_outils
 dbra d0,.attend_bouton

.capture_couleur
 bsr vsync
 move.l fichier,a0
 move mousex,d0
 lea (a0,d0*2),a0
 move mousey,d0
 mulu largeur_image,d0
 move (a0,d0.l),couleur
 bsr colorie_curseur
 getmouse
 cmp #2,mousek
 beq .capture_couleur
 cmp #3,mousek
 beq .mode_d‚grad‚
 rts

.mode_d‚grad‚
 move couleur,sauve_couleur

.capture_d‚grad‚
 bsr vsync
 bsr.l affiche_le_zoomer
 move.l fichier,a0
 move mousex,d0
 lea (a0,d0*2),a0
 move mousey,d0
 mulu largeur_image,d0
 move (a0,d0.l),d3

 move sauve_couleur,d0	Ancienne couleur de r‚f‚rence...
 move d0,d2
 and #%11111,d2		D2=bleu
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 move d3,d5		La nouvelle teinte … m‚langer...
 and #%11111,d5		D2=bleu
 move d3,d4
 lsr #5,d4
 and #%111111,d4	D1=vert
 rol #5,d3
 and #%11111,d3		D0=rouge

 add d3,d0
 lsr d0
 add d4,d1
 lsr d1
 add d5,d2
 lsr d2
 
 ror #5,d0
 lsl #5,d1
 or d1,d0
 or d2,d0
   
 move d0,couleur

 bsr colorie_curseur
 getmouse
 cmp #3,mousek
 beq .capture_d‚grad‚
 cmp #2,mousek
 beq .capture_couleur

 relache			Attend que l'on ai relach‚ le bouton.
 rts
  
.validation_outils 
 st flag_s‚lecteur_loupe
 bsr module_choisie_outils 
 sf flag_s‚lecteur_loupe
 bsr affiche_fenetre_grossie
* bsr affiche_loupe_degas
 rts

s‚lecteur_de_couleur_loupe
 st flag_s‚lecteur_loupe
 bsr s‚lecteur_de_couleur
 sf flag_s‚lecteur_loupe
 bsr affiche_fenetre_grossie
* bsr affiche_loupe_degas
 rts


;
; On peut aller jusqu'… x2, mais dans ce cas on ne peut
; plus faire de segmentation
;
loupe_diminue
 cmp #2,puissance_loupe
 beq.s .pas_plus_petit
 subq #1,puissance_loupe
 bsr pr‚pare_loupe
 bsr calcule_grosseur_loupe
 bsr affiche_loupe_degas
.pas_plus_petit
 rts
 
loupe_augmente
 addq #1,puissance_loupe
 bsr pr‚pare_loupe
 bsr calcule_grosseur_loupe
 bsr affiche_loupe_degas
 rts

loupe_segmente
 not.b flag_loupe_segment‚e
 bsr pr‚pare_loupe
 bsr calcule_grosseur_loupe
 bsr affiche_loupe_degas
 rts

loupe_haut_gauche
 bsr calcule_loupe_haut
 bsr calcule_loupe_gauche
 bsr affiche_loupe_degas
 rts

loupe_haut
 bsr calcule_loupe_haut
 bsr affiche_loupe_degas
 rts

loupe_haut_droite
 bsr calcule_loupe_haut
 bsr calcule_loupe_droite
 bsr affiche_loupe_degas
 rts

loupe_gauche
 bsr calcule_loupe_gauche
 bsr affiche_loupe_degas
 rts

loupe_bas_gauche
 bsr calcule_loupe_bas
 bsr calcule_loupe_gauche
 bsr affiche_loupe_degas
 rts

loupe_bas
 bsr calcule_loupe_bas
 bsr affiche_loupe_degas
 rts

loupe_bas_droite
 bsr calcule_loupe_bas
 bsr calcule_loupe_droite
 bsr affiche_loupe_degas
 rts

loupe_droite
 bsr calcule_loupe_droite
 bsr affiche_loupe_degas
 rts





calcule_loupe_haut
 getshift
 btst #2,d0
 bne.s .force_coordonn‚e
 moveq #8,d7
 and #%11,d0
 bne.s .d‚place_loupe
 moveq #2,d7
.d‚place_loupe
 sub d7,y_loupe
 bra.s .fin_d‚place
.force_coordonn‚e
 clr y_loupe
.fin_d‚place
 rts

calcule_loupe_bas
 getshift
 btst #2,d0
 bne.s .force_coordonn‚e
 moveq #8,d7
 and #%11,d0
 bne.s .d‚place_loupe
 moveq #2,d7
.d‚place_loupe
 add d7,y_loupe
 bra.s .fin_d‚place
.force_coordonn‚e
 move hauteur_image,y_loupe
.fin_d‚place
 rts

calcule_loupe_gauche
 getshift
 btst #2,d0
 bne.s .force_coordonn‚e
 moveq #8,d7
 and #%11,d0
 bne.s .d‚place_loupe
 moveq #2,d7
.d‚place_loupe
 sub d7,x_loupe
 bra.s .fin_d‚place
.force_coordonn‚e
 clr x_loupe
.fin_d‚place
 rts

calcule_loupe_droite
 getshift
 btst #2,d0
 bne.s .force_coordonn‚e
 moveq #8,d7
 and #%11,d0
 bne.s .d‚place_loupe
 moveq #2,d7
.d‚place_loupe
 add d7,x_loupe
 bra.s .fin_d‚place
.force_coordonn‚e
 move largeur_image,x_loupe
.fin_d‚place
 rts




clippe_loupe_xy
 move x_loupe,d0
 bpl.s .teste_droite
 clr x_loupe
 bsr vide_clavier
 bra.s .teste_y
.teste_droite
 move largeur_image,d6
 lsr d6
 sub largeur_loupe,d6
 cmp d6,d0
 ble.s .teste_y
 move d6,x_loupe
 bsr vide_clavier

.teste_y
 move y_loupe,d0
 bpl.s .teste_bas
 clr y_loupe
 bsr vide_clavier
 bra.s .fin_clippe_xy
.teste_bas
 move hauteur_image,d6
 sub hauteur_loupe,d6
 cmp d6,d0
 ble.s .fin_clippe_xy
 move d6,y_loupe
 bsr vide_clavier
.fin_clippe_xy
 rts





pr‚pare_loupe
 bsr vsync

 bsr efface_‚cran_loupe
 
 move.l ‚cran_scroll,a0		On trace deux lignes blanches en haut
 move largeur_‚cran,d0		de la loupe, l… o— l'on met les infos
 mulu #8,d0			importantes.
 lea (a0,d0.l),a1
 move largeur_‚cran,d0
 mulu #10,d0
 lea (a1,d0.l),a2
 move.l a2,a4
 move hauteur_visible,d0
 subq #1,d0
 mulu largeur_‚cran,d0
 lea (a0,d0.l),a3 
 move largeur_visible,d0
 lsr #2,d0
 subq #1,d0
.trace_lignes_blanche
 move.l #-1,(a0)+
 move.l #-1,(a1)+
 move.l #-1,(a2)+
 move.l #-1,(a3)+
 dbra d0,.trace_lignes_blanche

 add largeur_‚cran,a4

 moveq #0,d4
 move largeur_visible,d4
 move.l d4,d2
 divu #3,d4
 bclr #0,d4
 move d4,offset_loupe		Position horizontale de la zone grossie
 sub d4,d2
 move d2,largeur_ligne_loupe
 lsr d2
 divu puissance_loupe,d2
 move d2,largeur_loupe		Nombre de blocs en largeur
 subq #6,d4
 move d4,d0			Largeur de la fenetre en mots...
 lsr d0
 move d0,largeur_fenetre	...et en pixels

 lea (a4,d4.w,2),a4
 
 move hauteur_visible,d0
 sub #22,d0
 cmp hauteur_image,d0
 ble.s .image_assez_haute
 move hauteur_image,d0
.image_assez_haute  
 move d0,hauteur_fenetre 
 addq #2,d0
.trace_ligne_verticale
 move #-1,(a4)			Ligne de s‚paration verticale
 add largeur_‚cran,a4
 dbra d0,.trace_ligne_verticale
 
 moveq #0,d2
 move hauteur_visible,d2
 sub #20,d2			********
 divu puissance_loupe,d2
 move d2,hauteur_loupe
 rts


;
; A partir des dimensions visibles de la fenetre d'affichage, on
; r‚cupŠre les dimensions du bloc zoom‚, en pixels.
;
calcule_grosseur_loupe
 moveq #0,d4
 move largeur_visible,d4
 move.l d4,d2
 divu #3,d4
 bclr #0,d4
 move d4,offset_loupe		Position horizontale de la zone grossie
 sub d4,d2
 move d2,largeur_ligne_loupe
 lsr d2
 divu puissance_loupe,d2
 move d2,largeur_loupe		Nombre de blocs en largeur
*
 moveq #0,d2
 move hauteur_visible,d2
 sub #20,d2			********
 divu puissance_loupe,d2
 move d2,hauteur_loupe
 rts
 

affiche_loupe_degas
 bsr vsync
 bsr clippe_loupe_xy
 bsr affiche_texte_loupe
 bsr affiche_fenetre_image  
 bsr affiche_fenetre_grossie
 rts



efface_‚cran_loupe
 move.l ‚cran_scroll,a0		D'abord, effacer l'‚cran.
 move hauteur_visible,d7
 subq #1,d7
.efface_vertical
 move.l a0,a1
 move largeur_visible,d6
 subq #1,d6
.efface_ligne
 clr (a1)+
 dbra d6,.efface_ligne
 add largeur_‚cran,a0 
 dbra d7,.efface_vertical 
 rts

;
; Affichage dans la partie gauche de l'image repr‚sent‚ dans sa
; taille normale
;
affiche_fenetre_image  
 move.l fichier,a0
 move largeur_image,d1
 lsr d1
 sub largeur_fenetre,d1
 move x_loupe,d0
 cmp d1,d0
 ble.s .largeur_ok 
 move d1,d0
.largeur_ok 
 lea (a0,d0.w*2),a0
 
 move hauteur_image,d1
 sub hauteur_fenetre,d1
 bpl.s .taille_positive
 moveq #0,d0
 bra.s .force_taille
.taille_positive 
 move y_loupe,d0
 cmp d1,d0
 ble.s .hauteur_ok
 move d1,d0
.hauteur_ok 
 mulu largeur_image,d0
.force_taille
 add.l d0,a0
 
 move.l ‚cran_scroll,a1
 move #20,d0
 mulu largeur_‚cran,d0
 add.l d0,a1
  
 move.l a0,a2
 move.l a1,a3
  
 move hauteur_fenetre,d7
 subq #1,d7
.recopie_image_y 
 move.l a2,a4
 move.l a3,a5
 move largeur_fenetre,d6
 subq #1,d6
.recopie_ligne
 move (a4)+,(a5)+
 dbra d6,.recopie_ligne
 add largeur_image,a2
 add largeur_‚cran,a3
 dbra d7,.recopie_image_y 
 rts
 



affiche_fenetre_grossie
 move.l fichier,a0
 add x_loupe,a0
 add x_loupe,a0
 move y_loupe,d0
 mulu largeur_image,d0
 add.l d0,a0
 
 move.l ‚cran_scroll,a1
 move #20,d0
 mulu largeur_‚cran,d0
 add.l d0,a1
 add offset_loupe,a1
  
 move.l a0,a2			Image source
 move.l a1,a3			Position sur l'‚cran
 move.l a1,a4			(Pour la duplication des lignes)...
 
 move largeur_‚cran,d1		On utilise cet offset pour sauter les
 mulu puissance_loupe,d1	"n" lignes ‚crans n‚cessaires.

 movec cacr,d7
 bclr #13,d7	Write Allocate OFF
* bclr #12,d7	>>> Burst Mode (Aucun effet)
 bset #11,d7	Clear data cache
 bclr #9,d7	Not Freeze data cache
 bset #8,d7	Enable data cache

* bset #4,d7	>>> Burst Mode (Aucun effet)
 bset #3,d7	Clear instruction cache
 bclr #1,d7	Not Freeze instruction cache
 bset #0,d7	Enable instruction cache
 movec d7,cacr

 cmp #2,puissance_loupe		La loupe x2 ne peut pas ˆtre segment‚e...
 beq loupe_normale		(ca serait inutilisable)

 tst.b flag_loupe_segment‚e
 bne.s loupe_segment‚e
 cmp #3,puissance_loupe
 beq loupe_x3
   
loupe_normale
 move hauteur_loupe,d4
 subq #1,d4
.duplique_verticalement
 move.l a0,a2
 move.l a1,a3
 move largeur_loupe,d5
 subq #1,d5
.zoome_ligne
 move (a2)+,d0
 move puissance_loupe,d6
 subq #1,d6 
.zoome_pixel
 move d0,(a3)+
 dbra d6,.zoome_pixel
 dbra d5,.zoome_ligne
 add largeur_image,a0
 add.l d1,a1
 dbra d4,.duplique_verticalement
 bra duplique_loupe

loupe_x3
 move hauteur_loupe,d4
 subq #1,d4
.duplique_verticalement
 move.l a0,a2
 move.l a1,a3
 move largeur_loupe,d5
 subq #1,d5
.zoome_ligne
 move (a2)+,d0
 move d0,(a3)+
 move d0,(a3)+
 move d0,(a3)+
 dbra d5,.zoome_ligne
 add largeur_image,a0
 add.l d1,a1
 dbra d4,.duplique_verticalement
 bra duplique_loupe

loupe_segment‚e
 move hauteur_loupe,d4
 subq #1,d4
.duplique_verticalement
 move.l a0,a2
 move.l a1,a3
 move largeur_loupe,d5
 subq #1,d5
.zoome_ligne
 move (a2)+,d0
 move puissance_loupe,d6
 subq #2,d6 
.zoome_pixel
 move d0,(a3)+
 dbra d6,.zoome_pixel
 clr (a3)+
 dbra d5,.zoome_ligne
 add largeur_image,a0
 add.l d1,a1
 dbra d4,.duplique_verticalement

 
duplique_loupe
 move.l a4,a0

 move puissance_loupe,d0
 subq #2,d0
 beq.s .pas_segment‚e
 tst.b flag_loupe_segment‚e
 beq.s .pas_segment‚e
 subq #1,d0
.pas_segment‚e
 
 move hauteur_loupe,d4
 subq #1,d4
.duplique_verticalement
 move.l a0,a2

 move d0,d3
.duplique_ligne 
 add largeur_‚cran,a2
 move.l a0,a1
 move.l a2,a3
 move largeur_ligne_loupe,d2
 lsr #2,d2
 subq #1,d2
.copie_ligne 
 move.l (a1)+,(a3)+
 dbra d2,.copie_ligne
 dbra d3,.duplique_ligne 
 add.l d1,a0				Passe … la rang‚e suivante
 dbra d4,.duplique_verticalement
 rts





affiche_texte_loupe
 lea texte_loupe,a0
 move.l #'Posi',(a0)+
 move.l #'tion',(a0)+
 move.l #' en ',(a0)+
 move.w #'X:',(a0)+

 moveq #0,d0
 move x_loupe,d0		La position horizontale de la loupe
 bsr inscrit_chaine

 move.b #' ',(a0)+
 move.l #'Posi',(a0)+
 move.l #'tion',(a0)+
 move.l #' en ',(a0)+
 move.w #'Y:',(a0)+
 
 moveq #0,d0
 move y_loupe,d0		La position verticale de la loupe
 bsr inscrit_chaine

 move.b #' ',(a0)+
 move.l #'Zoom',(a0)+
 move.w #':x',(a0)+
  
 moveq #0,d0
 move puissance_loupe,d0	Le facteur de grossissement
 bsr inscrit_chaine
 move.l #'    ',(a0)+
 move.l #'    ',(a0)+
 clr.b (a0)+			Inscrit la chaine

 lea texte_loupe,a0
 move.l ‚cran_scroll,a1
 add largeur_‚cran,a1
 add largeur_‚cran,a1
 bsr affiche_chaine_texte




 lea texte_d‚bogage,a0
 move.l #'Larg',(a0)+
 move.l #'eur:',(a0)+
 moveq #0,d0
 move largeur_fenetre,d0
 bsr inscrit_chaine

 move.b #' ',(a0)+
 
 move.l #'Haut',(a0)+
 move.l #'eur:',(a0)+
 moveq #0,d0
 move hauteur_fenetre,d0
 bsr inscrit_chaine

 move.b #' ',(a0)+

 move.l #'Larg',(a0)+
 move.l #'eur:',(a0)+
 moveq #0,d0
 move largeur_loupe,d0
 bsr inscrit_chaine

 move.b #' ',(a0)+
 
 move.l #'Haut',(a0)+
 move.l #'eur:',(a0)+
 moveq #0,d0
 move hauteur_loupe,d0
 bsr inscrit_chaine

 move.b #' ',(a0)+

 clr.b (a0)+

 lea texte_d‚bogage,a0
 move.l ‚cran_scroll,a1
 move largeur_‚cran,d0
 mulu #12,d0
 add.l d0,a1
 bsr affiche_chaine_texte
 rts
 

  
 DATA

liste_tailles_loupe
 dc.w 2,3,4,6,8
 dc.w 10,12,16,20,30
 


 BSS

puissance_loupe		ds.w 1
old_puissance_loupe	ds.w 1

texte_loupe		ds.b 80
texte_d‚bogage		ds.b 80
 
largeur_fenetre		ds.w 1
hauteur_fenetre		ds.w 1
largeur_loupe		ds.w 1
hauteur_loupe		ds.w 1
largeur_ligne_loupe	ds.w 1
flag_loupe_segment‚e	ds.w 1

limite_horizontale	ds.w 1

xy_loupe
x_loupe			ds.w 1
y_loupe			ds.w 1
offset_loupe		ds.w 1

couleur_cycling		ds.w 1
