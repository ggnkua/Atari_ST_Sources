; REMBRANDT 3.0 - Ω  Dbug II
;
; Module de gestion des fichiers. (1.9)
;
; Cette version permet de charger des fichiers au format:
; - *.ART (Art Director, Ω MirrorSoft Ltd)
; - *.BMP (Windows Bitmap, Ω Microsoft)
; - *.CA1 (Crack Art compactÇ et non compactÇ)
; - *.GIF (Graphic Interchange Format, Ω CompuServ)
; - *.IIM (Inshape IMage,Ω ???)
; - *.IFF (Interchange File Format, compactÇ ou non, avec rasters ou non)
; - *.JPG (Joint Photographic Expert Group)
; - *.KID (FullShow, Ω Killer D/FMC-CNX)
; - *.NEO (Neochrome, Ω Dave Staugas)
; - *.PC1 (Degas basse rÇsolution compactÇ, Ω Tom Hudson)
; + *.PCX (PC Paint Brush,Ω Z-Soft & Microsoft Corp)
; - *.PI1 (Degas basse rÇsolution non compactÇ, Ω Tom Hudson)
; - *.PNT (Prism Paint, Ω Lexicor Software)
; - *.SD0 (Dali basse rÇsolution) [Ö tester]
; - *.SPC (Spectrum 512 compactÇ, Ω TRIO Inc) 
; - *.SPU (Spectrum 512 non compactÇ, Ω TRIO Inc)
; - *.TCP (Rembrandt True Color Picture, Ω Dbug II/NeXT)
; - *.TG1 (COKE format)
; - *.TGA (Targa Bit Image)
; - *.TPI (True Paint, Ω HiSoft)
; - *.XGA (XGA Show)
;
;  AmÇliorations de la version 1.2:
;   - Le chargement fait appel Ö de l'allocation mÇmoire temporaire.
;     d'ou un gain de mÇmoire pour les opÇrations graphiques de type bloc !
;   - La petite taille de la BSS fait que si l'on ne charge rien, il ne
;     prends quasiment pas de place. D'ou de la place pour accÇder aux
;     accessoires ou aux utilitaires rÇsidents (Je ne parle pas de MultiTOS
;     parce que je ne pense pas qu'il sera utilisable avec !)
; 
;  AmÇliorations de la version 1.5:
;   - La routine de dÇpacking RLE (PackBits) fonctionne quelque soit le
;     nombre de lignes, de colonnes, et de plans...
; 
;  AmÇliorations de la version 1.6:
;   - La routine de chargement IFF est quasi terminÇe. Elle fonctionne
;     quel que soit la taille de l'image [?] et le nombre de plans. Les
;     images HAM sont parfaitement chargÇes (sauf les premiers pixels Ö
;     gauche de l'Çcran...
;
;  AmÇliorations de la version 1.7:
;   - PossibilitÇ de spÇcifier le type de format de l'image. Donc, la 
;     dÇtection ne se fait plus sur l'extension. Il devient possible de
;     charger une image Degas portant l'extension .PIC... Le titre du
;     sÇlecteur d'objet change selon la fonction choisie.
;
;  AmÇliorations de la version 1.8:
;   - PossibilitÇ de sauvegarder au format COKE TrueColor (TG1)
;   - ImplÇmentation du format TCP (type 1 non compactÇ)
;   - Limitation des plantages intempestifs de part l'utilisation de tests
;     sur la mÇmoire occupÇe aux divers stades du travail.
;
;  AmÇliorations de la version 1.9:
;   - Le format IFF est chargÇ en mode 64 et 256 couleurs.
;   - ImplÇmentation du format JPEG.
;   - ImplÇmentation du format BMP.
;   - [ImplÇmentation du format PCX].
;   - [Gestion des fichiers RIM].	-> Pipe
;   - ImplÇmentation des images InShape (IIM).
;
; A rajouter: Le RAW, et le DIS gÇnÇrÇs par POV.
;

 ifeq _main_part
 <pREMB_xxx.S>q doit àtre assemblÇ !!!
 END
 endc

version_tcp=1

 TEXT

; Pour quitter:
; BRA FIN_OPêRATION_DISK -> Uniquement si les buffers ont ÇtÇ touchÇs,
;                           et qu'un formulaire a ÇtÇ utilisÇ.
; BRA FERME_FORMULAIRE   -> Les autres cas
;

;
; On arrive ici en mode chargement automatique
;
charge_image_automatique
 st flag_format_pic
 move.l #txt_chargement_par_nom,adresse_txt_chargement
 bra.s charge_image

;
; On arrive ici en mode chargement selon le type
;
charge_image_sÇlection
 sf flag_format_pic
  
charge_image
 tst.b flag_sauvÇe			Si l'image n'a pas ÇtÇ modifiÇe
 bne .charge_image			(flag=-1), pas de message
 boite_alerte #1,#alert_image_pas_sauvÇe
 cmp #1,int_out
 bne ferme_formulaire
.charge_image

 clr.b nom_fichier			Efface le nom du fichier.
 lea nom_image,a0			RÇinstalle le nom antÇrieur de
 lea nom_fichier,a1			chargement s'est bien passÇ, on
.recopie_nom
 move.b (a0)+,(a1)+			mÇmorise le nom de l'image.
 bne.s .recopie_nom

; Selon le flag, on charge directement l'image, avec une reconnaissance
; automatique du format, ou alors on commence par sÇlectionner le type
; de fichier dans le sÇlecteur de drivers.
;
 tst.b flag_format_pic
 bne.s .appelle_sÇlecteur_fichiers

 bsr gere_chargement_sÇlection
 bmi fin_opÇrations_disk
 
.appelle_sÇlecteur_fichiers
 fsel_exinput #chemin_fichier,#nom_fichier,adresse_txt_chargement
 tst int_out+2			Cas oó l'on a fait ANNULER...
 beq restaure_nom_fichier
 tst int_out			Cas oó ???
 beq restaure_nom_fichier
 
 graf_mouse #2			Une abeille pendant qu'on travaille !!!

 bsr analyse_chemin_fichier
 bsr positionne_chemin		Modifie le chemin d'accäs au fichier
 bsr teste_existance_fichier
 bne fin_opÇrations_disk	Si le fichier n'existe pas !

 tst.b flag_format_pic		Si on a le formulaire, on ne teste pas
 beq.s .effectue_chargement	l'extension du fichier...

.vÇrifie_extension
 lea liste_formats_automatique,a0
 move.l extension,d0
.cherche_extension_chargement
 move.l (a0)+,d1
 cmp.l #-1,d1
 beq .extension_non_trouvÇe
 cmp.l d0,d1
 beq .extension_trouvÇe 
 addq #8,a0
 bra .cherche_extension_chargement

.extension_non_trouvÇe
 boite_alerte #1,#alert_mauvaise_extension	Connais pas ce format
 jmp fin_opÇrations_disk			d'image... Dommage.
  
.extension_trouvÇe	
 move.l (a0)+,adresse_routine_chargement

 move.l (a0)+,a0			Change le format dans la boite
 move.l ptr_chargement_image,a1
 move.l a0,([ob_spec+objet_chargement_form*24,a1])

.effectue_chargement
 lea fichier,a0				On commence par faire de la place
 bsr libäre_bloc			en mÇmoire. (Plus d'image)
   
 move.l taille_fichier,d0		Taille du fichier par FSFIRST.
 lea buffer_fichier,a0			Bloc de dÇfinition
 bsr rÇserve_bloc			Zou ! On veut de la mÇmoire mec !
 beq .ok_charge_le_fichier		Il semblerait qu'il y eu un petit
 boite_alerte #1,#alert_mÇmoire_chargement	probläme de place !!!
 jmp fin_opÇrations_disk
 
.ok_charge_le_fichier   
 moveq #0,d0
 bsr affiche_formulaire_chargement
 bsr charge_fichier			On charge le fichier en mÇmoire
 bsr ferme_formulaire
 tst d0					si il n'y a pas d'erreur, on le
 bne fin_opÇrations_disk		convertie, sinon Bye bye...

 bsr nettoye_avant_chargement
 clr nombre_couleurs			Pour dÇtecter les images TrueColor
 
 jsr ([adresse_routine_chargement])	ExÇcute la routine de conversion
 bmi fin_opÇrations_disk

 bsr copie_palette_image		Recopie la palette Çventuellement

 lea nom_fichier,a0			Lorsque l'on est sur que le 
 lea nom_image,a1			chargement s'est bien passÇ, on
.recopie_nom_image
 move.b (a0)+,(a1)+			mÇmorise le nom de l'image.
 bne.s .recopie_nom_image

 bsr compose_infos_fenetre		Met Ö jour la ligne d'infos !
    
fin_opÇrations_disk
 lea buffer_fichier,a0			Bloc de dÇfinition
 bsr libäre_bloc			Zou ! On libäre (Qu'il exista ou non !)
 lea buffer_dÇpacking,a0		Bloc de dÇfinition
 bsr libäre_bloc			Zou ! On libäre (Qu'il exista ou non !)
 bsr teste_image_pas_dÇfaut
 bsr ferme_formulaire
 graf_mouse #0				On remet la fläche...
 rts

;
; On aboutit ici chaque fois qu'un chargement Çchoue mais avant que l'on
; ai commencÇ de charger le bloc : L'image antÇrieure est toujours lÖ,
; donc on la maintient en entier !
;
restaure_nom_fichier
 lea nom_image,a0			Lorsque l'on est sur que le 
 lea nom_fichier,a1			chargement s'est bien passÇ, on
.recopie_nom
 move.b (a0)+,(a1)+			mÇmorise le nom de l'image.
 bne.s .recopie_nom

 lea buffer_dÇpacking,a0		Bloc de dÇfinition
 bsr libäre_bloc			Zou ! On libäre (Qu'il exista ou non !)

 bsr ferme_formulaire
 graf_mouse #0				On remet la fläche...
 rts
 
; Si pour une raison oó une autre, il se trouve que le chargement Çchoue,
; il faut forcer la crÇation d'une image vide.
;
;
teste_image_pas_dÇfaut
 tst.l fichier
 bne.s .image_ok
 move #640,largeur_image	On attribue par dÇfaut une image 320x200
 move #200,hauteur_image
 bsr.l prÇpare_buffer_image
.image_ok
 rts 
 

; Dans D0, on Ö le numÇro du titre Ö inscrire:
; 0-> Chargement
; 1-> DÇcompactage
; 2-> Transformation
; 3-> Sauvegarde
;
affiche_formulaire_chargement
 movem.l d0-a6,-(sp)
 move.l ptr_chargement_image,a0
 move.l a0,adresse_formulaire

 move.l #txt_sauve_image,d1
 cmp #3,d0
 beq.s .inscrit_chaine
 move.l #txt_convertie_image,d1
 cmp #2,d0
 beq.s .inscrit_chaine
 move.l #txt_dÇpacke_image,d1
 cmp #1,d0
 beq.s .inscrit_chaine
 move.l #txt_charge_image,d1

.inscrit_chaine
 move.l d1,([ob_spec+objet_chargement_quoi*24,a0])
 move.l #nom_fichier,([ob_spec+objet_chargement_nom*24,a0])

 bsr affiche_formulaire
 movem.l (sp)+,d0-a6
 rts





gere_format_sauvegarde
 move.l ptr_format_sauve,adresse_formulaire

 move.l adresse_formulaire,a0
 move format_dÇfaut_sauvegarde,d0
 mulu #24,d0
 bset #state_selected,ob_state+1(a0,d0.w)
 
 bsr affiche_formulaire
 bsr gere_formulaire
 move objet_exit,d0
 cmp #objet_sauve_annule,d0
 beq .annule_sauvegarde
 cmp #objet_sauve_confirme,d0
 bne .prends_format_choisi
 move format_dÇfaut_sauvegarde,d0	Si c'est CONFIRME, on prends le meme type !
.prends_format_choisi

; Si on arrive ici, c'est que l'on a choisi un des types de fichier
; proposÇ dans la ressource. Il faut donc acceder Ö la routine qui
; correspond.
 move d0,format_dÇfaut_sauvegarde
 
 lea liste_formats_sauvegarde,a0
.teste_format_suivant
 cmp 4(a0),d0
 beq.s .format_trouvÇ
 lea 14(a0),a0
 bra.s .teste_format_suivant

.format_trouvÇ 
 move.l (a0)+,extension
 addq #2,a0
 move.l (a0)+,adresse_routine_sauvegarde
 
 move.l (a0),a0			Chaine de caractäres correspondant
 lea txt_sauvegarde_choisie,a1	Message du fileselect
.recopie_texte
 move.b (a0)+,(a1)+
 bne.s .recopie_texte
   
.confirme_format_image  
 bsr ferme_formulaire
 moveq #0,d0
 rts

.annule_sauvegarde
 bsr ferme_formulaire
 moveq #-1,d0
 rts

  
nettoye_avant_chargement
 lea allocation_palettes,a0		RÇinitialise les pointeurs sur les
 lea fin_allocation_palettes,a1		diverses palettes (NeoMaster).
.efface_palettes
 clr.l (a0)+
 cmpa.l a1,a0
 blt.s .efface_palettes

 clr.b nom_image			Efface le nom de l'image
 clr.b infos_texte_1			ainsi que les commentaires qui
 clr.b infos_texte_2			l'accompagnent.
 clr.b infos_texte_3
 clr.b infos_texte_4
 rts




mÇmorise_chemin_disk
 move #$19,-(sp)		DGetDrv
 trap #1
 addq #2,sp
 add #'A',d0			On Ö la lettre qui correspond au lecteur
 lea chemin_fichier,a6		courant...
 move.b d0,(a6)+		êcrit le caractäre
 move.b #':',(a6)+		Puis le ':' qui suit le drive.
 
 clr -(sp)
 pea (a6)		*repertoire
 move #$47,-(sp)		DGetPath
 trap #1			On inscrit le rÇpertoire Ö la suite.
 addq #8,sp

.cherche_fin_rÇpertoire
 tst.b (a6)+
 bne.s .cherche_fin_rÇpertoire
 move.b #'\',-1(a6)		On met un '\' Ö la fin du rÇpertoire. 
 clr.b (a6)			Ne pas oublier le zÇro final !!!
 rts


 
positionne_chemin
 moveq #0,d0
 move.b repertoire,d0
 sub #'A',d0
 move d0,-(sp)		Il faut aussi changer le drive par dÇfaut...
 move #$e,-(sp)
 trap #1
 addq #4,sp

 pea repertoire		Change le rÇpertoire courant
 move #$3b,-(sp)	pour que les accäs suivants se fasse
 trap #1		dans le meme rÇpertoire
 addq #6,sp
 tst d0
 bmi erreur_fichier_absent
 rts






sauve_image_directe
sauve_image
 bsr gere_format_sauvegarde
 bmi fin_opÇrations_disk
 jsr ([adresse_routine_sauvegarde])	ExÇcute la routine de conversion
 bmi fin_opÇrations_disk

 lea nom_image,a0		RÇinstalle le nom antÇrieur de
 lea nom_fichier,a1		l'image pour pouvoir la sauver.
 moveq #8-1,d0			Le nom fait 8 caractäres au maximum.
.recopie_nom
 move.b (a0)+,d0
 beq.s .met_extension
 cmp.b #'.',d0
 beq.s .met_extension
 move.b d0,(a1)+
 dbra d0,.recopie_nom
.met_extension
 move.l extension,(a1)+
 clr.b (a1)+ 
 
 fsel_exinput #chemin_fichier,#nom_fichier,#txt_sauvegarde_image
 tst int_out+2
 beq fin_opÇrations_disk
 tst int_out
 beq fin_opÇrations_disk

 bsr analyse_chemin_fichier
 bsr positionne_chemin			Modifie le chemin d'accäs au fichier

 bsr teste_place_disque
 bmi fin_opÇrations_disk
  
 moveq #3,d0
 bsr affiche_formulaire_chargement
 bsr sauve_fichier			On charge le fichier en mÇmoire
 bsr ferme_formulaire

 st flag_sauvÇe
 sf flag_changÇe
 jmp fin_opÇrations_disk		puis on retourne au programme.


analyse_chemin_fichier   
 lea chemin_fichier,a0	On recherche le chemin d'accäs au fichier
 lea repertoire,a1	mais sans le nom du fichier lui meme
.recopie
 move.b (a0)+,(a1)+
 bne .recopie
.ote_extension
 move.b -(a1),d0
 cmp.b #"\",d0
 beq .fin_recherche
 cmp.b #":",d0
 beq .fin_recherche
 cmp.l #repertoire,a1
 bne .ote_extension   
.fin_recherche 
 clr.b 1(a1)
 rts



; Pour savoir si le fichier tiendra sur le disque que l'on Ö sÇlectionnÇ,
; il suffit de faire un calcul simple:
; - On prend la mÇmoire libre avec DFREE
; - On teste l'existance d'un fichier portant le meme nom. Si on en trouve
;   un, on rajoute la place occupÇe par ce fichier Ö la place libre.
; - On compare la place libre que l'on a trouvÇ Ö la taille de notre
;   fichier... C'est simple non ?
;
teste_place_disque
 clr -(sp)			Lecteur courant
 pea disk_infos			Buffer pour les informations
 move #$36,-(sp)
 trap #1
 addq #8,sp

 move.l taille_fichier,-(sp)
 bsr teste_existance_fichier
 bmi.s .fichier_inexistant
 move.l taille_fichier,d0
 move.l taille_secteur,d1
 divu.l d1,d0				-> Nombre de secteurs
 move.l secteurs_par_cluster,d1
 divu.l d1,d0				-> Nombre de clusters
 add.l d0,clusters_libres		Rajoute aux clusters libres !
.fichier_inexistant
 move.l (sp)+,taille_fichier  

 move.l taille_fichier,d0
 move.l taille_secteur,d1
 divu.l d1,d0				-> Nombre de secteurs
 move.l secteurs_par_cluster,d1
 divu.l d1,d0				-> Nombre de clusters
 cmp.l clusters_libres,d0
 ble.s .mÇmoire_suffisante
.mÇmoire_insuffisante 
 boite_alerte #1,#alert_disk_plein
 moveq #1,d0 
 rts

.mÇmoire_suffisante 
 moveq #0,d0 
 rts

 
teste_existance_fichier 
 clr -(sp)			Fichier normal
 pea nom_fichier		Nom du fichier
 move #$4e,-(sp)		> FSFIRST
 trap #1
 addq #8,sp
 tst d0
 beq.s .continue_analyse
 moveq #-1,d0
 rts
 
.continue_analyse
 lea my_dta+30,a0		On stocke l'extension du fichier pour 
.cherche_fin_chemin
 cmp.b #".",(a0)+		vÇrifier si le format est connu.	
 bne .cherche_fin_chemin
 move.l -1(a0),extension	MÇmorise l'extension du fichier

 move.l my_dta+26,taille_fichier	C'est utile pour la suite
 moveq #0,d0
 rts
 
charge_fichier 
 move #1,-(sp)			Ouvre en lecture
 pea nom_fichier		Nom du fichier
 move #$3d,-(sp)		> FOPEN
 trap #1
 addq #8,sp
 tst d0
 bmi erreur_ouverture_impossible
 move d0,handle

 move.l buffer_fichier,-(sp)		Adresse du buffer
 move.l taille_fichier,-(sp)		Longueur du fichier
 move handle,-(sp)
 move #$3f,-(sp)		> FREAD
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi erreur_durant_lecture

 move handle,-(sp)		On ferme le fichier
 move #$3e,-(sp)		> FCLOSE
 trap #1
 addq #4,sp
 tst d0
 bmi erreur_fermeture_impossible

 moveq #0,d0			Pas d'erreur. Fichier chargÇ !
 rts


sauve_fichier 
 clr -(sp)			Ouvre en Çcriture
 pea nom_fichier		Nom du fichier
 move #$3c,-(sp)		> FCREATE
 trap #1
 addq #8,sp
 tst d0
 bmi erreur_ouverture_impossible
 move d0,handle

 move.l buffer_fichier,-(sp)	Adresse du buffer
 move.l taille_fichier,-(sp)	Longueur du fichier
 move handle,-(sp)
 move #$40,-(sp)		> WRITE
 trap #1
 lea 12(sp),sp
 tst.l d0
 bmi erreur_durant_lecture

 move handle,-(sp)		On ferme le fichier
 move #$3e,-(sp)		> FCLOSE
 trap #1
 addq #4,sp
 tst d0
 bmi erreur_fermeture_impossible

 moveq #0,d0			Pas d'erreur. Fichier chargÇ !
 rts


sauve_dta_systäme
 move #$2f,-(sp)
 trap #1
 addq #2,sp
 move.l d0,sauve_dta

 pea my_dta
 move #$1a,-(sp)
 trap #1
 addq #6,sp
 rts

restore_dta_systäme
 move.l sauve_dta,-(sp)
 move #$1a,-(sp)
 trap #1
 addq #6,sp
 rts


erreur_mÇmoire_chargement
 boite_alerte #1,#alert_mÇmoire_chargement	PrÇvient l'utilisateur
 moveq #-1,d0					Code d'erreur
 rts

erreur_mÇmoire_sauvegarde
 boite_alerte #1,#alert_mÇmoire_sauvegarde	PrÇvient l'utilisateur
 moveq #-1,d0					Code d'erreur
 rts

erreur_fichier_absent
 boite_alerte #1,#alert_fichier_non_trouve
 moveq #-1,d0
 rts

erreur_ouverture_impossible
 boite_alerte #1,#alert_ouverture_impossible
 moveq #-1,d0
 rts

erreur_durant_Çcriture
erreur_durant_lecture
 boite_alerte #1,#alert_durant_lecture
 moveq #-1,d0
 rts

erreur_fermeture_impossible 
 boite_alerte #1,#alert_fermeture_impossible
 moveq #-1,d0
 rts

erreur_mÇmoire_dÇpacking
 boite_alerte #1,#alert_mÇmoire_dÇpacking
 moveq #-1,d0
 rts
 
erreur_format_chargement
 boite_alerte #1,#alert_format_chargement
 moveq #-1,d0
 rts


*****************************
*
* Le sÇlecteur de driver d'image
*
*****************************

gere_chargement_sÇlection
 move.l ptr_choix_driver,adresse_formulaire
 clr premier_objet
 
 bsr mise_Ö_jour_sÇlecteur
  
 bsr.l affiche_formulaire

.boucle_gäre_formulaire
 bsr.l gere_formulaire

 cmp #objet_confirme_rim,objet_exit -> On Ö appuyÇ sur la touche CONFIRMER
 beq .boucle_gäre_formulaire		.confirme_choix_driver
 cmp #objet_annuler_rim,objet_exit
 beq .quitte_formulaire

 cmp #objet_rim_monte,objet_exit
 bne.s .pas_fläche_haut
 tst.b flag_scroll_haut
 beq.s .boucle_gäre_formulaire
 subq #1,position_sÇlection_rim
 bra.s .fin_gäre_fläches
.pas_fläche_haut

 cmp #objet_rim_descend,objet_exit
 bne.s .sÇlection_driver		*pas_fläche_bas
 tst.b flag_scroll_bas
 beq.s .boucle_gäre_formulaire
 addq #1,position_sÇlection_rim
.pas_fläche_bas

.fin_gäre_fläches
 bsr mise_Ö_jour_sÇlecteur
 bsr rÇaffiche_liste_drivers
 bra .boucle_gäre_formulaire


.quitte_formulaire
 bsr.l ferme_formulaire
 moveq #-1,d0
 rts

.sÇlection_driver
 move position_sÇlection_rim,d0
 add objet_exit,d0
 sub #objet_titre_rim_1,d0		NumÇro de la ligne choisie
 move d0,numÇro_driver_courant
 lea liste_drivers_internes,a0
 mulu #40,d0
 add d0,a0
 move.l 32(a0),adresse_routine_chargement

 move.l #txt_chargement_par_type,adresse_txt_chargement

 move.l 36(a0),a0			Chaine de caractäres correspondant
 move.l ptr_chargement_image,a1
 move.l a0,([ob_spec+objet_chargement_form*24,a1])
 
 lea txt_type_choisi,a1		Message du fileselect
.recopie_texte
 move.b (a0)+,(a1)+
 bne.s .recopie_texte

 bsr.l ferme_formulaire
 moveq #0,d0
 rts
  

rÇaffiche_liste_drivers
 objc_draw ptr_choix_driver,#objet_rim_monte,#0,x_form,y_form,l_form,h_form
 lea liste_titres_rim,a2
 moveq #14-1,d7			; 9-1
.Çcrit_ligne_suivante
 move (a2)+,d6
 move d7,-(sp)
 pea (a2)
 objc_draw ptr_choix_driver,d6,#0,x_form,y_form,l_form,h_form
 move.l (sp)+,a2
 move (sp)+,d7
 dbra d7,.Çcrit_ligne_suivante
 objc_draw ptr_choix_driver,#objet_rim_descend,#0,x_form,y_form,l_form,h_form
 rts


 
mise_Ö_jour_sÇlecteur
 tst position_sÇlection_rim
 sne flag_scroll_haut

 move nombre_drivers,d6
 sub position_sÇlection_rim,d6
 sub #14+1,d6
 spl flag_scroll_bas

* move.l adresse_drivers_rim,a0
 move position_sÇlection_rim,d5
; mulu #50,d0
; add d0,a0

 move.l ptr_choix_driver,a1			Pointeur sur le formulaire

 move.l #ligne_quedal,([ob_spec+objet_rim_monte*24,a1])
 tst.b flag_scroll_haut
 beq.s .pas_scroll_haut
 move.l #ligne_monte,([ob_spec+objet_rim_monte*24,a1])
.pas_scroll_haut

 move nombre_drivers,d6
 moveq #14,d7
 cmp d7,d6
 bpl.s .ok_nombre_rim
 move d6,d7
.ok_nombre_rim
 subq #1,d7
 lea liste_titres_rim,a2
.Çcrit_ligne_suivante
 move (a2)+,d0					NumÇro de l'objet
 mulu #24,d0
 
 lea liste_drivers_internes,a0
 move d5,d4
 mulu #40,d4
 add d4,a0
 move.l a0,([ob_spec,a1,d0.w])			Adresse du texte RIM

 addq #1,d5					Driver suivant
 dbra d7,.Çcrit_ligne_suivante

 move.l #ligne_quedal,([ob_spec+objet_rim_descend*24,a1])
 tst.b flag_scroll_bas
 beq.s .pas_scroll_bas
 move.l #ligne_descend,([ob_spec+objet_rim_descend*24,a1])
.pas_scroll_bas
 rts

  

*****************************

 include FICHIERS.INC\DISQUE\_MACROS.S

;
; Les diffÇrents drivers internes pour le chargement et la sauvegarde.
;
 include FICHIERS.INC\DISQUE\ART.S
 include FICHIERS.INC\DISQUE\BMP.S
 include FICHIERS.INC\DISQUE\CRACKART.S
 include FICHIERS.INC\DISQUE\DEGAS.S
 include FICHIERS.INC\DISQUE\DELUXE.S
 include FICHIERS.INC\DISQUE\FULLSHOW.S
 include FICHIERS.INC\DISQUE\GIF.S
 include FICHIERS.INC\DISQUE\INSHAPE.S
 include FICHIERS.INC\DISQUE\JPEG.S
 include FICHIERS.INC\DISQUE\NEO.S
 include FICHIERS.INC\DISQUE\PRISM.S
 include FICHIERS.INC\DISQUE\PCX.S
 include FICHIERS.INC\DISQUE\SPECTRUM.S
 include FICHIERS.INC\DISQUE\TCP.S
 include FICHIERS.INC\DISQUE\TGA.S
 include FICHIERS.INC\DISQUE\TG1.S
 include FICHIERS.INC\DISQUE\XGA.S


 DATA

 even
 	
*
* .L - Extension gÇnÇrale affectÇe.
* .L - Adresse de la routine de chargement par type
* .L - Adresse de la routine de chargement par extension
* .L - Adresse du chaine de caractäres donnant le nom en ASCII
*
liste_formats_automatique
 dc.b ".PI1"
 dc.l charge_image_degas
 dc.l txt_format_degas

 dc.b ".PC1"
 dc.l charge_image_degas_packÇe
 dc.l txt_format_degas

 dc.b ".IIM"
 dc.l charge_image_inshape
 dc.l txt_format_inshape
 
 dc.b ".IFF"
 dc.l charge_image_iff
 dc.l txt_format_iff

 dc.b ".LBM"
 dc.l charge_image_iff
 dc.l txt_format_iff

 dc.b ".NEO"
 dc.l charge_image_neo
 dc.l txt_format_neochrome

 dc.b ".SPU"
 dc.l charge_image_spectrum_normale
 dc.l txt_format_spectrum

 dc.b ".SPC"
 dc.l charge_image_spectrum_compressÇe
 dc.l txt_format_spectrum

 dc.b ".CA1"
 dc.l charge_image_crackart
 dc.l txt_format_crackart

 dc.b ".SD0"
 dc.l charge_image_dali
 dc.l txt_format_dali

 dc.b ".TGA"
 dc.l charge_image_tga
 dc.l txt_format_tga

 dc.b ".KID"
 dc.l charge_image_kid
 dc.l txt_format_fullshow

 dc.b ".GIF"
 dc.l charge_image_gif
 dc.l txt_format_gif

 dc.b ".JPG"
 dc.l charge_image_jpeg
 dc.l txt_format_jpeg

 dc.b ".BMP"
 dc.l charge_image_windows
 dc.l txt_format_windows
  
 dc.b ".TCP"
 dc.l charge_image_tcp
 dc.l txt_format_tcp

 dc.b ".XGA"
 dc.l charge_image_xga
 dc.l txt_format_xga

 dc.b ".TG1"
 dc.l charge_image_coke
 dc.l txt_format_coke

 dc.b ".ART"
 dc.l charge_image_art_director
 dc.l txt_format_art

 dc.b ".PNT"
 dc.l charge_image_prism_paint
 dc.l txt_format_pnt

 dc.b ".PCX"
 dc.l charge_image_pcx
 dc.l txt_format_pcx
  
 dc.b ".TPI"
 dc.l charge_image_true_paint
 dc.l txt_format_tpi
 
 dc.l -1				Plus d'autre fichiers


liste_formats_sauvegarde
 dc.b ".TGA"
 dc.w objet_sauve_tga_16bit
 dc.l sauve_image_tga_16bit	TGA
 dc.l txt_format_tga_16bit
 dc.b ".TGA"
 dc.w objet_sauve_tga_24bit
 dc.l sauve_image_tga_24bit	TGA
 dc.l txt_format_tga_24bit
 dc.b ".TCP"
 dc.w objet_sauve_tcp
 dc.l sauve_image_tcp		TCP
 dc.l txt_format_tcp
 dc.b ".TG1"
 dc.w objet_sauve_coke
 dc.l sauve_image_coke		TG1
 dc.l txt_format_coke

  
txt_chargement_par_nom	dc.b "CHARGER SELON L'EXTENSION",0
txt_chargement_par_type	dc.b "CHARGER UNE IMAGE "
txt_type_choisi		dc.b ".........................",0
txt_sauvegarde_image	dc.b "SAUVER UNE IMAGE "
txt_sauvegarde_choisie	dc.b ".........................",0
 
txt_format_art		dc.b "ART DIRECTOR",0
txt_format_crackart	dc.b "CRACK ART",0
txt_format_dali		dc.b "DALI",0
txt_format_degas	dc.b "DEGAS",0
txt_format_iff		dc.b "DELUXE PAINT",0
txt_format_fullshow	dc.b "FULLSHOW",0
txt_format_gif		dc.b "GIF",0
txt_format_inshape	dc.b "INSHAPE",0
txt_format_jpeg		dc.b "JPEG",0
txt_format_pcx		dc.b "PAINT BRUSH",0
txt_format_pnt		dc.b "PRISM PAINT",0
txt_format_neochrome	dc.b "NEOCHROME",0
txt_format_tcp		dc.b "REMBRANDT",0
txt_format_spectrum	dc.b "SPECTRUM",0
txt_format_tga		dc.b "TGA",0
txt_format_tga_16bit	dc.b "TGA 16bits",0
txt_format_tga_24bit	dc.b "TGA 24bits",0
txt_format_coke		dc.b "TRUE COLOR",0
txt_format_tpi		dc.b "TRUE PAINT",0
txt_format_windows	dc.b "WINDOWS BMP",0
txt_format_xga		dc.b "XGA",0

txt_format_rim		dc.b "DRIVER RIM",0

txt_charge_image	dc.b "CHARGEMENT DE:",0
txt_dÇpacke_image	dc.b "DêCOMPACTAGE DE:",0
txt_convertie_image	dc.b "CONVERTION DE:",0
txt_sauve_image		dc.b "SAUVEGARDE DE:",0

nom_image		dc.b "SANS_NOM",0
			dcb.b 20,0		Par suretÇ...

nom_fichier		dc.b "SANS_NOM",0
			dcb.b 20,0		Par suretÇ...


liste_titres_rim
 dc objet_titre_rim_1
 dc objet_titre_rim_2
 dc objet_titre_rim_3
 dc objet_titre_rim_4
 dc objet_titre_rim_5
 dc objet_titre_rim_6
 dc objet_titre_rim_7
 dc objet_titre_rim_8
 dc objet_titre_rim_9
 dc objet_titre_rim_10
 dc objet_titre_rim_11
 dc objet_titre_rim_12
 dc objet_titre_rim_13
 dc objet_titre_rim_14


ligne_quedal
 dc.b '',0,0
 
ligne_monte
 dc.b '    ',0,0

ligne_descend
 dc.b '    ',0,0

*
* Les Formats internes Ö Rembrandt...
*
*dc.b "123456789012345678901234567890"
nombre_drivers_internes dc.w 18

liste_drivers_internes
 dc.b "Art Director             [ART]",0,0
 dc.l charge_image_art_director
 dc.l txt_format_art

 dc.b "Coke TRUE COLOR          [TG1]",0,0
 dc.l charge_image_coke
 dc.l txt_format_coke

 dc.b "CompuServ                [GIF]",0,0
 dc.l charge_image_gif
 dc.l txt_format_gif

 dc.b "Crack Art                [CA1]",0,0
 dc.l charge_image_crackart
 dc.l txt_format_crackart

 dc.b "Dali                     [SD0]",0,0
 dc.l charge_image_dali
 dc.l txt_format_dali

 dc.b "Degas/Degas Elite    [PI1/PC1]",0,0
 dc.l teste_image_degas
 dc.l txt_format_degas

 dc.b "Deluxe Paint         [IFF/LBM]",0,0
 dc.l charge_image_iff
 dc.l txt_format_iff

 dc.b "Fullshow                 [KID]",0,0
 dc.l charge_image_kid
 dc.l txt_format_fullshow

 dc.b "InShape                  [IIM]",0,0
 dc.l charge_image_inshape
 dc.l txt_format_inshape

 dc.b "JPEG                     [JPG]",0,0
 dc.l charge_image_jpeg
 dc.l txt_format_jpeg

 dc.b "NeoChrome                [NEO]",0,0
 dc.l charge_image_neo
 dc.l txt_format_neochrome

 dc.b "PC PaintBrush            [PCX]",0,0
 dc.l charge_image_pcx
 dc.l txt_format_pcx
  
 dc.b "Prism Paint              [PNT]",0,0
 dc.l charge_image_prism_paint
 dc.l txt_format_pnt

 dc.b "Rembrandt                [TCP]",0,0
 dc.l charge_image_tcp
 dc.l txt_format_tcp

 dc.b "Spectrum 512         [SPC/SPU]",0,0
 dc.l teste_image_spectrum
 dc.l txt_format_spectrum

 dc.b "TGA                      [TGA]",0,0
 dc.l charge_image_tga
 dc.l txt_format_tga

 dc.b "True Paint               [TPI]",0,0
 dc.l charge_image_true_paint
 dc.l txt_format_tpi

 dc.b "Windows Bitmap           [BMP]",0,0
 dc.l charge_image_windows
 dc.l txt_format_windows

 dc.b "XGA                      [XGA]",0,0
 dc.l charge_image_xga
 dc.l txt_format_xga
 
	BSS

 even

flag_scroll_haut	ds.w 1
flag_scroll_bas		ds.w 1

repertoire			ds.b taille_chemin
chemin_paramÇtrage		ds.b taille_chemin
chemin_fichier			ds.b taille_chemin

my_dta				ds.b 44	DTA de Rembrandt, utilisÇe par FsFirst/Next
tampon_dta			ds.l 1	Adresse de la nouvelle DTA allouÇe par Rembrandt
sauve_dta			ds.l 1	Adresse de la DTA systäme
extension			ds.l 1	Ex: Æ.GIFØ

disk_infos
clusters_libres			ds.l 1
total_clusters			ds.l 1
taille_secteur			ds.l 1
secteurs_par_cluster		ds.l 1

nombre_couleurs			ds.w 1
nombre_plans			ds.w 1
nombre_lignes			ds.w 1
nombre_colonnes			ds.w 1
largeur_plan			ds.w 1	Pour le PackBit/Pour la MFDB (Rim)
largeur_ligne			ds.w 1

format_dÇfaut_chargement	ds.w 1
format_dÇfaut_sauvegarde	ds.w 1

adresse_routine_chargement	ds.l 1
adresse_routine_sauvegarde	ds.l 1
adresse_txt_chargement		ds.l 1

adresse_image			ds.l 1
taille_fichier			ds.l 1

buffer_fichier			ds.l 1
buffer_dÇpacking		ds.l 1

flag_packed			ds.w 1
buffer_ligne			ds.l 1000	Pour le dÇpacking IFF/PC1/PNT
allocation_palettes		
adresse_palette			ds.l 1		Par dÇfaut, c'est une palette !!!
				ds.l 1000	Pour la conversion ST  True Color avÇ lä rasters !
fin_allocation_palettes
