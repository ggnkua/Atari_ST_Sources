; REMBRANDT 3.0 - ½  Dbug II
;
; Comment afficher simplement : "C'est pas cod‚ !"
;
 ifeq _main_part
 <pREMB_xxx.S>q doit ˆtre assembl‚ !!!
 END
 endc

 section TEXT

boite_alerte
 move.l ‚cran,‚cran_s‚l
 move largeur_‚cran,largeur_‚cran_s‚l

 bsr cache_zoomer_s‚lecteur
 
 bsr recopie_‚cran

 move.l adresse_curseur,sauvegarde_curseur
 move.l #curseur_flŠche,adresse_curseur
 
 move.l #d‚f_boite,adresse_ressource
 sf flag_ferme_formulaire

 bsr calcule_minimax
 bsr centre_s‚lecteur
 bsr d‚code_ressource

 relache
 
 bsr gŠre_s‚lecteur
 bsr efface_s‚lecteur

 jsr vide_clavier

 move.l sauvegarde_curseur,adresse_curseur
 bsr colorie_curseur

 bsr montre_zoomer_s‚lecteur
 rts

 
routine_fermeture_boite
 lea d‚f_boite_case_fermeture,a0
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 relache
 not objet_relief(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 st flag_ferme_formulaire
 rts


routine_boite_click
 bsr vsync

 lea d‚f_boite_texte,a0
 move.l #texte_boite_pas_cod‚_2,objet_texte(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_boite_icone,a0
 move.l #texte_boite_pacman,objet_texte(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 relache

 bsr vsync

 lea d‚f_boite_texte,a0
 move.l #texte_boite_pas_cod‚_1,objet_texte(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment

 lea d‚f_boite_icone,a0
 move.l #texte_boite_paneau,objet_texte(a0)
 bsr calcule_xy_‚l‚ment
 bsr affichage_‚l‚ment
 rts
 
 section DATA
 even

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
* +8  .w (relief)		Creu (-1) ou bosse (0)
* +10 .w (couleur centre)
* +12 .w (couleur cadre)	Gris (0) ou de la couleur principale (-1)
* +16 .l (s‚lection)		Adresse de la routine de gestion, sinon (0)
* +20 .l (texte)		Adresse d'un chaine de caractŠres, sinon (0)
*
* si en +0 on … -1	-> Fin de la ressource
*		-2	-> Lien vers un autre morceau de ressource.

raccourcis_clavier_boite
 raccourcis 0,27,d‚f_boite_case_fermeture
 raccourcis 0,32,d‚f_boite_case_fermeture
 dc.w -1
 
 dc.l raccourcis_clavier_boite
 dc.l d‚f_boite_titre_cadre
 dc.l routine_fermeture_boite
d‚f_boite
 dc.w g_box
 dc.w 000,000,143,44,0,0	Cadre principal
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,0

d‚f_boite_case_fermeture
 dc.w g_box
 dc.w 001,001,010,010,0,0	Case de fermeture en haut … gauche
 code_rvb 0,32,0		VERT
 dc.w color‚
 dc.l routine_fermeture_boite,texte_boite_case_fermeture

d‚f_boite_titre_cadre
 dc.w g_box
 dc.w 013,001,129,010,0,0	Entete pour le titre
 code_rvb 0,32,0		VERT
 dc.w color‚
 dc.l routine_d‚place_cadre,texte_boite_titre

d‚f_boite_texte
 dc.w g_box
 dc.w 001,013,141,30,0,0	Partie inf‚rieure
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l routine_boite_click,texte_boite_pas_cod‚_1

d‚f_boite_icone
 dc.w g_box
 dc.w 003,015,19,19,0,0		L'icone avec un paneau
 code_rvb 16,32,16		GRIS
 dc.w neutre
 dc.l no_prog,texte_boite_paneau
 dc.w -1
 
* Format des chaines de caractŠre:
* .w (Offset X)
* .w (Offset Y)
* .w (Couleur d'affichage)

 even
texte_boite_titre
 dc.w 2,2
 code_rvb 31,63,31
 dc.b "BOITE D'ALERTE...",0
 even

texte_boite_case_fermeture 
 dc.w 2,2,0
 dc.b "",0
 even

texte_boite_pas_cod‚_1
 dc.w 24,4
 code_rvb 31,63,31
 dc.b " Cette fonction",13
 dc.b " n'a pas encore",13
 dc.b "‚t‚ programm‚e !",0
 even

texte_boite_pas_cod‚_2
 dc.w 24,4
 code_rvb 31,0,0
 dc.b "Si vous n'etes",13
 dc.b "pas content...",0
 
texte_boite_pacman
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_pacman
 even

texte_boite_paneau
 dc.w 0,0
 code_rvb 0,0,0
 dc.w 0
 dc.l icone_paneau
 even

icone_pacman		incbin fichiers.inc\icones\pacman.icn
 even
icone_paneau		incbin fichiers.inc\icones\paneau.icn

 even
  