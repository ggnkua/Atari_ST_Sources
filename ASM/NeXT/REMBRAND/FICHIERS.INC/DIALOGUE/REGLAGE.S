; REMBRANDT 3.0 - ½  Dbug II
;
; Module de r‚glage de la configuration vid‚o. (1.3)
;
; - On peut adapter la r‚solution image … celle du type d'affichage
;   choisi avec les boutons.
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 TEXT

choix_parametre_image
 move.l ptr_parametre_ecran,adresse_formulaire
 clr premier_objet
 bsr affiche_formulaire

.boucle_param‚trage
 bsr gere_formulaire

 cmp #objet_annule_params,objet_exit
 beq .annule_param‚trages

;
; On a click‚ sur CONFIRMER, SAUVER, ou bien  sur ADAPTE.
; Dans tous les cas, on valide les param‚trages de visualisation.
;

 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire

 move #objet_overscan*24,d0		Num‚ro du bouton overscan
 lea flag_overscan,a1
 bsr m‚morise_bouton 

 move #objet_double_largeur*24,d0	Num‚ro du bouton largeur x2
 lea flag_double_largeur,a1
 bsr m‚morise_bouton 

 move #objet_double_hauteur*24,d0	Num‚ro du bouton hauteur x2
 lea flag_double_hauteur,a1
 bsr m‚morise_bouton 

 cmp #objet_resolution_ecran,objet_exit
 bne .valide_taille_image






.prends_taille_‚cran
 bclr.b #0,(ob_state+objet_resolution_ecran*24+1,a0)	Relever le bouton ADAPTE

 bsr calcule_dimensions				Calcule la taille physique de l'‚cran

 move.l ptr_parametre_ecran,a1			Pointeur sur le formulaire

 move.l ([ob_spec+objet_x_resolution*24,a1]),a0	Adresse chaine saisie
 moveq #0,d0
 move dim_largeur_‚cran,d0			R‚solution en X.w
 lsr d0						(On divise par deux avant d'afficher: C'est des pixels, pas des octets !!!)
 bsr inscrit_chaine

 move.l ([ob_spec+objet_y_resolution*24,a1]),a0	Adresse chaine saisie
 moveq #0,d0
 move dim_hauteur_‚cran,d0			R‚solution en Y.w
 bsr inscrit_chaine

 move.l ([ob_spec+objet_taille_image*24,a1]),a0	Adresse chaine saisie
 moveq #0,d0
 move dim_largeur_‚cran,d0
 mulu dim_hauteur_‚cran,d0
 bsr inscrit_chaine

 objc_draw adresse_formulaire,#objet_update_tailles,#1,x_form,y_form,l_form,h_form
 bra .boucle_param‚trage





  
.valide_taille_image 

*
* On commence par les dimensions de la nouvelle image.
* Si c'est les memes qu'avant, ce n'est pas la peine de se mettre
* martel en tete ! Sinon, on demande … l'utilisateur s'il ne d‚sire
* pas la sauver (si elle a ‚t‚ modifi‚e), ou annuler l'op‚ration !
*
 move largeur_image,d0		C'est une fa‡on bourrin de limiter
 swap d0			… un seul test la v‚rification X/Y
 move hauteur_image,d0		des coordon‚es.
 move.l d0,anciennes_dimensions
 
 move.l ptr_parametre_ecran,a1

 move.l ([ob_spec+objet_x_resolution*24,a1]),a0	Adresse chaine saisie
 bsr lit_chaine

 cmp #16,d0			V‚rifie que l'image fait au moins
 bge.s .ok_pas_minimum_x	16 pixels de large.
 moveq #16,d0
.ok_pas_minimum_x 
 add d0,d0
 move d0,largeur_image		R‚solution en X.w
 
 move.l ([ob_spec+objet_y_resolution*24,a1]),a0	Adresse chaine saisie
 bsr lit_chaine
 cmp #16,d0			V‚rifie qur l'image fait au moins
 bge.s .ok_pas_minimum_y	16 pixels de haut.
 moveq #16,d0
.ok_pas_minimum_y
 move d0,hauteur_image		R‚solution en Y.w

 move largeur_image,d0
 mulu hauteur_image,d0
 move.l d0,taille_image

 move.l ([ob_spec+objet_taille_image*24,a1]),a0	Adresse chaine saisie
 moveq #0,d0
 move.l taille_image,d0		Taille de l'image en octets
 bsr inscrit_chaine

 move largeur_image,d0		Si les nouvelles dimensions, sont
 swap d0			identiques aux anciennes, pourquoi
 move hauteur_image,d0		Effacer l'image ???
 cmp.l anciennes_dimensions,d0
 beq .continue_param‚trages
*
* Les dimensions sont diff‚rentes, alors, si l'image n'a pas ‚t‚
* modifi‚e, on continue. Sinon:
* [CONFIRME]	-> R‚alloue l'image, l'efface, et continue
* [SAUVE]	-> Sauve l'image, r‚allour la m‚moire puis continue
* [ANNULER]	-> Annulation de la proc‚dure IMAGE. Pas l'‚cran !
*
 tst.b flag_sauv‚e			Si l'image n'a pas ‚t‚ modifi‚e
* bne .continue_param‚trages		(flag=-1), pas de message
 bne .nettoie_buffer_image		(flag=-1), pas de message

.confirme_r‚glages
***
 bsr ferme_formulaire
 move.l ptr_redimensionne,adresse_formulaire
 clr premier_objet
 bsr affiche_formulaire
 bsr gere_formulaire
 cmp #objet_confirme_taille,objet_exit	[Valider sans sauver]
 beq.s .nettoie_buffer_image
 cmp #objet_annule_taille,objet_exit	[Annuler les changements]
 beq.s .annule_param‚trage_image
 cmp #objet_sauve_et_efface,objet_exit	[Sauver et valider]
 beq.s .sauve_image
.recalcule_taille
 bra.s .annule_param‚trage_image
 
.sauve_image
 bsr sauve_image			Si on ne sauve pas finalement,
 tst.b flag_sauv‚e			on repose la question !
 beq.s .confirme_r‚glages
.nettoie_buffer_image
 bsr pr‚pare_buffer_image		Sinon, dans tous les cas, on
 bra.s .continue_param‚trages 		fini par effacer l'image !

.annule_param‚trage_image
 move.l anciennes_dimensions,d0		Si on choisi d'annuler, on
 move d0,hauteur_image			reprend les dimensions qu'il
 swap d0				y avait avant !
 move d0,largeur_image

   
.continue_param‚trages 
 move flag_overscan,param‚trage_overscan
 move flag_double_largeur,param‚trage_double_largeur
 move flag_double_hauteur,param‚trage_double_hauteur

* bsr calcule_dimensions
* move dim_largeur_‚cran,largeur_‚cran
* move dim_hauteur_‚cran,hauteur_‚cran
* move dim_mode_r‚solution,mode_r‚solution
* bsr adapte_param‚trages   
 bsr calcule_r‚solution_sp‚ciale
 bsr valide_param‚trages
 bsr ferme_formulaire
 bsr compose_infos_fenetre		Met … jour la ligne d'infos !
 rts

.annule_param‚trages
 move.b param‚trage_overscan,flag_overscan
 move.b param‚trage_double_largeur,flag_double_largeur
 move.b param‚trage_double_hauteur,flag_double_hauteur
 bsr valide_param‚trages
 bsr ferme_formulaire
 bsr ferme_formulaire
 rts



valide_param‚trages
 move #objet_x_resolution*24,d0	Offset sur la structure
 move.l ptr_parametre_ecran,a0	Pointeur sur le formulaire
 move.l ([ob_spec,a0,d0.w]),a0	Adresse TEDINFO finale -> Chaine saisie
 moveq #0,d0
 move largeur_image,d0		R‚solution en X.w
 lsr d0				(On divise par deux avant d'afficher: C'est des pixels, pas des octets !!!)
 bsr inscrit_chaine

 move #objet_y_resolution*24,d0	Offset sur la structure
 move.l ptr_parametre_ecran,a0	Pointeur sur le formulaire
 move.l ([ob_spec,a0,d0.w]),a0	Adresse TEDINFO finale -> Chaine saisie
 moveq #0,d0
 move hauteur_image,d0		R‚solution en Y.w
 bsr inscrit_chaine

 move #objet_taille_image*24,d0	Offset sur la structure
 move.l ptr_parametre_ecran,a0	Pointeur sur le formulaire
 move.l ([ob_spec,a0,d0.w]),a0	Adresse TEDINFO finale -> Chaine saisie
 moveq #0,d0
 move.l taille_image,d0		x 2 => Taille de l'image en octets
 bsr inscrit_chaine


 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire

 move #objet_overscan*24,d0		Offset sur la structure
 lea flag_overscan,a1
 bsr positionne_bouton

 move #objet_double_largeur*24,d0	Offset sur la structure
 lea flag_double_largeur,a1
 bsr positionne_bouton

 move #objet_double_hauteur*24,d0	Offset sur la structure
 lea flag_double_hauteur,a1
 bsr positionne_bouton


 move.l ptr_preference,a0		Pointeur sur le formulaire
 
 move #objet_pref_shrink_box*24,d0	Offset sur la structure
 lea flag_shrink_box,a1
 bsr positionne_bouton

 bsr calcule_r‚solution_sp‚ciale
 rts
