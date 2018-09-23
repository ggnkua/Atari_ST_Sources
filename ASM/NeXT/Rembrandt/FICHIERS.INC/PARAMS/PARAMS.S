; REMBRANDT 3.0 - ½  Dbug II
;
; Module de gestion du fichier de param‚trage. (1.1)
;

 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc
 
 section TEXT

m‚morise_chemin_rembrandt
 move.l adresse_basepage,a0
 move.l $24(a0),a0		-> Page de base du pŠre (le bureau...)
 move.l $7C(a0),a0		-> Ligne de commande du pŠre
 move.l $36(a0),a0		??? Chemin d'accŠs au fils... (Mwai... enfin, ca marche !)

 lea chemin_param‚trage,a1
 move.l a1,a2
.recopie
 move.b (a0)+,(a1)+
 bne.s .recopie
.ote_extension
 move.b -(a1),d0
 cmp.b #"\",d0
 beq .fin_recherche
 cmp.b #":",d0
 beq .fin_recherche
 cmp.l a2,a1
 bne.s .ote_extension   
.fin_recherche 
 clr.b 1(a1)
 rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%                                                     %%
;%%  Chargement du fichier de param‚trage REMBRAND.INF  %%
;%%                                                     %%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

charge_param‚trage_image
 ifeq debug
 lea chemin_fichier,a0		En proc‚dant ainsi, on peut r‚utiliser le
 lea chemin_param‚trage,a1	meme chemin pour charger et sauver.
 bsr copie_chaine_texte
 subq #1,a1			On efface le z‚ro final...
 move.l #'REMB',(a1)+
 move.l #'RAND',(a1)+
 move.l #'.INF',(a1)+
 clr.b (a1)+			...et on le rajoute … la fin.

* fsel_exinput #chemin_param‚trage,#nom_fichier,#txt_chargement_par_nom
   
 move #1,-(sp)			Ouvre le fichier REMBRAND.INF
 pea chemin_param‚trage		en lecture avec FOpen
 move #$3d,-(sp)
 trap #1
 addq #8,sp
 tst d0
 bmi .erreur
 move d0,handle

 pea param‚trage_d‚but		Lecture des informations
 pea longueur_param‚trage	du fichier de param‚trage.
 move handle,-(sp)
 move #$3f,-(sp)
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi .erreur

 move handle,-(sp)	Fermeture du fichier de param‚trage
 move #$3e,-(sp)	Normalement, il ne devrait pas y avoir
 trap #1		d'erreur !
 addq #4,sp
 tst d0
 beq .pas_erreur
.erreur

* boite_alerte #1,#alert_charge_param‚trage	On emmerde pas !
.pas_erreur
 endc
 
***** Maintenant, il faut transf‚rer ces param‚trages dans les variables 
***** de travail standard.

 move.b param‚trage_overscan,flag_overscan
 move.b param‚trage_double_largeur,flag_double_largeur
 move.b param‚trage_double_hauteur,flag_double_hauteur
 move.b param‚trage_shrink_box,flag_shrink_box
 move.b param‚trage_format_pic,flag_format_pic
 move.b param‚trage_fileselect,flag_fileselect
 move.b param‚trage_recopier_palette,flag_recopier_palette
 move param‚trage_largeur_image,largeur_image
 move param‚trage_hauteur_image,hauteur_image
 move.w param‚trage_format_chargement,format_d‚faut_chargement
 move.w param‚trage_format_sauvegarde,format_d‚faut_sauvegarde

 move largeur_image,d0
 mulu hauteur_image,d0
 move.l d0,taille_image
 bsr valide_param‚trages
 rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%                                                     %%
;%%  Sauvegarde du fichier de param‚trage REMBRAND.INF  %%
;%%                                                     %%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sauve_param‚trage_image
 lea param‚trage_d‚but,a0	Il faut mettre … jour la ligne d'info, sinon
 move.l #'Remb',(a0)+		on ne saura pas de quelle version vient ce
 move.l #'rand',(a0)+		fichier de sauvegarde...
 move.l #'t V3',(a0)+
 move.l #'.06 ',(a0)+
 move.l #'á Fr',(a0)+

***** Avant de sauver, on r‚cupŠre les informations de travail standard.

 move.b flag_overscan,param‚trage_overscan
 move.b flag_double_largeur,param‚trage_double_largeur
 move.b flag_double_hauteur,param‚trage_double_hauteur
 move.b flag_shrink_box,param‚trage_shrink_box
 move.b flag_format_pic,param‚trage_format_pic
 move.b flag_fileselect,param‚trage_fileselect
 move.b flag_recopier_palette,param‚trage_recopier_palette
 move.w format_d‚faut_chargement,param‚trage_format_chargement
 move.w format_d‚faut_sauvegarde,param‚trage_format_sauvegarde
 move largeur_image,param‚trage_largeur_image
 move hauteur_image,param‚trage_hauteur_image

 move #0,-(sp)			Ouvre le fichier REMBRAND.INF
 pea chemin_param‚trage		en ‚criture avec FCr‚ate
 move #$3c,-(sp)
 trap #1
 addq #8,sp
 tst d0
 bmi .erreur
 move d0,handle

 pea param‚trage_d‚but		criture des informations
 pea longueur_param‚trage	dans le fichier de param‚trage.
 move handle,-(sp)
 move #$40,-(sp)
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi .erreur

 move handle,-(sp)	Fermeture du fichier de param‚trage
 move #$3e,-(sp)	Normalement, il ne devrait pas y avoir
 trap #1		d'erreur !
 addq #4,sp
 tst d0
 bmi .erreur   
 rts
  
.erreur 
 boite_alerte #1,#alert_sauve_param‚trage
 rts


	DATA
	  
; Format du fichier de param‚trage de Rembrandt.
;     12345678901234567890
; .b "Rembrandt V3.05 á Fr" 20 CaractŠres d'information
; .w Drapeau Overscan On/Off (Ignor‚ en mode VGA)
; .w Drapeau r‚solution doubl‚e (Interlac‚ en RVB-Simple ligne en VGA)
; .w R‚solution en X
; .w R‚solution en Y
; .w Drapeau GROW/SHRINK BOX
; .w Drapeau de choix des fichiers (par un type d‚fini/par l'extension)
;
param‚trage_d‚but
 dc.b "Rembrandt V3.06 á Fr"
param‚trage_overscan
 dc.w 0				Pas d'overscan
param‚trage_double_largeur
 dc.w 0				Simple largeur (40 colonnes)
param‚trage_double_hauteur
 dc.w 0				Simple hauteur (200 lignes non interlac‚es)
param‚trage_largeur_image
 dc.w 320*2
param‚trage_hauteur_image
 dc.w 200
param‚trage_shrink_box
 dc.w 0				Pas d'animation GROW/SHRINK BOX
param‚trage_format_pic
 dc.w 0				Mode 'type de fichier' par d‚faut.
param‚trage_fileselect
 dc.w 0				On utilise le FileSelector du systŠme
param‚trage_format_chargement
 dc.w 0				Par d‚faut, on charge le GIF
param‚trage_format_sauvegarde
 dc.w objet_sauve_tcp		Mais on sauve en mode TCP
param‚trage_recopier_palette
 dc.w 0




longueur_param‚trage=*-param‚trage_d‚but
